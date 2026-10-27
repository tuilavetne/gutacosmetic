const Product = require("../../../models/Product");
const InventoryAdjustment = require("../../../models/InventoryAdjustment");
const InventoryReceipt = require("../../../models/InventoryReceipt");
const InventoryReturnRequest = require("../../../models/InventoryReturnRequest");
const InventoryRequest = require("../../../models/InventoryRequest");
const Store = require("../../../models/Store");
const StoreInventory = require("../../../models/StoreInventory");
const StockTransfer = require("../../../models/StockTransfer");
const AppError = require("../../../utils/AppError");
const { USER_ROLES } = require("../../../constants/business");
const inventoryMutationService = require("./inventoryService");
const { runInTransaction } = require("./transactionService");

const LOW_STOCK_WARNING_THRESHOLD = 10;
const EXPIRY_WARNING_DAYS = 60;
const MAX_STOCK_RECEIVE_QUANTITY = 1000;
const UNIVERSAL_SKIN_TYPE = "Da thường/Mọi loại da";

const RETURN_REQUEST_TYPES = ["DAMAGED", "DEFECTIVE", "EXPIRED", "OTHER"];

const startOfToday = () => {
  const today = new Date();
  today.setHours(0, 0, 0, 0);
  return today;
};

// HSD gửi lên dạng ngày (yyyy-mm-dd hoặc ISO). Trống -> null.
// [allowPast] = false khi nhập lô mới: không nhận hàng đã hết hạn.
const parseExpiryDate = (value, { allowPast = false } = {}) => {
  if (value === undefined || value === null || value === "") {
    return null;
  }

  const date = new Date(value);

  if (Number.isNaN(date.getTime())) {
    throw new AppError("Expiry date is invalid", 400, "INVALID_EXPIRY_DATE");
  }

  if (!allowPast && date < startOfToday()) {
    throw new AppError(
      "Cannot receive stock that has already expired",
      400,
      "EXPIRY_DATE_IN_PAST"
    );
  }

  return date;
};

// Kho chưa quản lý theo lô: giữ HSD gần nhất (lô hết hạn sớm nhất) để cảnh
// báo. Lô cũ bán hết thì Manager sửa HSD bằng tay (updateInventoryExpiry).
const applyReceivedExpiry = async (storeId, productId, expiryDate, session) => {
  if (!expiryDate) {
    return;
  }

  await StoreInventory.updateOne(
    {
      storeId,
      productId,
      $or: [{ expiryDate: null }, { expiryDate: { $gt: expiryDate } }],
    },
    { $set: { expiryDate } },
    { session }
  );
};

const escapeRegExp = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

const buildProductQuery = ({ brand, category, productIds, search, skinType } = {}) => {
  const query = { isActive: true };

  if (productIds) {
    const ids = String(productIds)
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean);

    if (ids.length > 0) {
      query._id = { $in: ids };
    }
  }

  if (search) {
    const pattern = { $regex: escapeRegExp(search), $options: "i" };
    query.$or = [{ name: pattern }, { sku: pattern }, { brand: pattern }];
  }

  if (brand) {
    query.brand = brand;
  }

  if (skinType) {
    query.skinTypes = { $in: [skinType, UNIVERSAL_SKIN_TYPE] };
  }

  if (category) {
    query.category = category;
  }

  return query;
};

const getProductInventory = async (filters = {}) => {
  const parsedLimit = Number.parseInt(filters.limit, 10);
  const normalizedLimit =
    Number.isInteger(parsedLimit) && parsedLimit > 0
      ? Math.min(parsedLimit, 100)
      : null;
  // `projection` ẩn trường nội bộ (giá vốn) khi người gọi là khách hàng.
  const productQuery = Product.find(buildProductQuery(filters))
    .select(filters.projection || "")
    .sort({ createdAt: -1 });

  if (normalizedLimit) {
    productQuery.limit(normalizedLimit);
  }

  const [products, stores] = await Promise.all([
    productQuery.lean(),
    Store.find({ isActive: true }).sort({ name: 1 }).lean(),
  ]);

  if (products.length === 0) {
    return [];
  }

  const inventories = await StoreInventory.find({
    productId: { $in: products.map((product) => product._id) },
    storeId: { $in: stores.map((store) => store._id) },
  }).lean();

  const inventoryByProductStore = new Map(
    inventories.map((inventory) => [
      `${inventory.productId}:${inventory.storeId}`,
      inventory,
    ])
  );

  return products.map((product) => ({
    product,
    inventories: stores.map((store) => {
      const inventory = inventoryByProductStore.get(
        `${product._id}:${store._id}`
      );

      return {
        store: {
          _id: store._id,
          name: store.name,
          address: store.address,
          phone: store.phone,
          type: store.type,
        },
        totalStock: inventory?.totalStock || 0,
        reservedStock: inventory?.reservedStock || 0,
        availableStock: inventory?.availableStock || 0,
        expiryDate: inventory?.expiryDate || null,
        lowStockThreshold: inventory?.lowStockThreshold || 5,
      };
    }),
  }));
};

const getScopedStoreId = (user, requestedStoreId) => {
  if (user.role === USER_ROLES.OWNER) {
    return requestedStoreId || null;
  }

  return String(user.storeId);
};

const ensureStoreCanProcessInventoryMutation = async ({
  allowOwnerOnBranch = false,
  storeId,
  user,
}) => {
  const store = await Store.findById(storeId).lean();

  if (!store) {
    throw new AppError("Store was not found", 404, "STORE_NOT_FOUND");
  }

  if (!store.isActive) {
    throw new AppError("Store is inactive", 409, "STORE_INACTIVE");
  }

  if (
    user.role === USER_ROLES.OWNER &&
    !allowOwnerOnBranch &&
    store.type !== "CENTRAL"
  ) {
    throw new AppError(
      "Owner can only update stock directly in the central warehouse",
      403,
      "OWNER_BRANCH_STOCK_MUTATION_FORBIDDEN"
    );
  }

  return store;
};

const getInventoryAlerts = async ({ storeId, user }) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const expiresBefore = new Date(
    Date.now() + EXPIRY_WARNING_DAYS * 24 * 60 * 60 * 1000
  );
  const query = {};

  if (scopedStoreId) {
    query.storeId = scopedStoreId;
  }

  const inventories = await StoreInventory.find(query)
    .populate("storeId", "name address phone type")
    .populate("productId", "name sku brand category image price")
    .sort({ availableStock: 1, expiryDate: 1 })
    .lean();

  return inventories.flatMap((inventory) => {
    const alerts = [];
    const threshold = Math.max(
      Number(inventory.lowStockThreshold || 0),
      LOW_STOCK_WARNING_THRESHOLD
    );

    if (inventory.availableStock < threshold) {
      alerts.push({
        type: "LOW_STOCK",
        severity: inventory.availableStock <= 0 ? "CRITICAL" : "WARNING",
        message:
          inventory.availableStock <= 0
            ? "Sản phẩm đã hết hàng tại chi nhánh"
            : `Sản phẩm còn dưới ${threshold} sản phẩm khả dụng`,
        inventoryId: inventory._id,
        store: inventory.storeId,
        product: inventory.productId,
        totalStock: inventory.totalStock,
        reservedStock: inventory.reservedStock,
        availableStock: inventory.availableStock,
        lowStockThreshold: threshold,
        expiryDate: inventory.expiryDate,
      });
    }

    if (inventory.expiryDate && inventory.expiryDate <= expiresBefore) {
      const isExpired = inventory.expiryDate.getTime() < Date.now();

      alerts.push({
        type: isExpired ? "EXPIRED" : "EXPIRING_SOON",
        severity: isExpired ? "CRITICAL" : "WARNING",
        message: isExpired
          ? "Sản phẩm đã quá hạn sử dụng"
          : `Sản phẩm sắp hết hạn trong ${EXPIRY_WARNING_DAYS} ngày`,
        inventoryId: inventory._id,
        store: inventory.storeId,
        product: inventory.productId,
        totalStock: inventory.totalStock,
        reservedStock: inventory.reservedStock,
        availableStock: inventory.availableStock,
        lowStockThreshold: threshold,
        expiryDate: inventory.expiryDate,
      });
    }

    return alerts;
  });
};

const REQUEST_USER_FIELDS = "fullName email phone role";

const populateInventoryRequest = (request) =>
  request.populate([
    { path: "storeId", select: "name address phone type" },
    { path: "productId", select: "name sku brand category image price" },
    { path: "requestedBy", select: REQUEST_USER_FIELDS },
    { path: "handledBy", select: REQUEST_USER_FIELDS },
    { path: "forwardedBy", select: REQUEST_USER_FIELDS },
    { path: "approvedBy", select: REQUEST_USER_FIELDS },
  ]);

const populateInventoryReturnRequest = (request) =>
  request.populate([
    { path: "storeId", select: "name address phone type" },
    { path: "productId", select: "name sku brand category image price" },
    { path: "requestedBy", select: "fullName email phone role" },
    { path: "reviewedBy", select: "fullName email phone role" },
  ]);

const createRestockRequest = async ({
  productId,
  reason,
  requestedQuantity,
  storeId,
  user,
}) => {
  const scopedStoreId = getScopedStoreId(user, storeId);

  if (!scopedStoreId) {
    throw new AppError("Store ID is required", 400, "STORE_ID_REQUIRED");
  }

  if (!productId) {
    throw new AppError("Product ID is required", 400, "PRODUCT_ID_REQUIRED");
  }

  const quantity = Number(requestedQuantity);

  if (!Number.isFinite(quantity) || quantity < 1) {
    throw new AppError(
      "Requested quantity must be greater than zero",
      400,
      "INVALID_REQUESTED_QUANTITY"
    );
  }

  const inventory = await StoreInventory.findOne({
    productId,
    storeId: scopedStoreId,
  }).lean();

  if (!inventory) {
    throw new AppError("Inventory item was not found", 404, "INVENTORY_NOT_FOUND");
  }

  const existingOpenRequest = await InventoryRequest.findOne({
    productId,
    storeId: scopedStoreId,
    status: "OPEN",
  });

  if (existingOpenRequest) {
    existingOpenRequest.requestedQuantity = Math.max(
      existingOpenRequest.requestedQuantity,
      quantity
    );
    existingOpenRequest.reason = reason || existingOpenRequest.reason;
    existingOpenRequest.currentAvailableStock = inventory.availableStock;
    await existingOpenRequest.save();

    return populateInventoryRequest(existingOpenRequest);
  }

  const request = await InventoryRequest.create({
    storeId: scopedStoreId,
    productId,
    requestedBy: user._id,
    currentAvailableStock: inventory.availableStock,
    requestedQuantity: quantity,
    reason: reason || "Sales đề xuất bổ sung hàng cho sản phẩm này",
  });

  return populateInventoryRequest(request);
};

const getRestockRequests = async ({ status = "OPEN", storeId, user }) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const query = {};

  if (scopedStoreId) {
    query.storeId = scopedStoreId;
  }

  if (status && status !== "ALL") {
    query.status = status;
  }

  return InventoryRequest.find(query)
    .populate("storeId", "name address phone type")
    .populate("productId", "name sku brand category image price")
    .populate("requestedBy", REQUEST_USER_FIELDS)
    .populate("handledBy", REQUEST_USER_FIELDS)
    .populate("forwardedBy", REQUEST_USER_FIELDS)
    .populate("approvedBy", REQUEST_USER_FIELDS)
    .sort({ status: 1, createdAt: -1 })
    .lean();
};

const assertManagerOwnsRequest = (request, user) => {
  if (user.role !== USER_ROLES.MANAGER) {
    throw new AppError("Only managers can handle restock requests", 403, "FORBIDDEN");
  }

  if (String(request.storeId) !== String(user.storeId)) {
    throw new AppError("You cannot update another store request", 403, "FORBIDDEN");
  }
};

const findRestockRequestOrThrow = async (requestId, session) => {
  const request = await InventoryRequest.findById(requestId)
    .session(session || null)
    .catch(() => null);

  if (!request) {
    throw new AppError("Restock request was not found", 404, "REQUEST_NOT_FOUND");
  }

  return request;
};

// Manager hủy đề xuất (Sales vừa gửi hoặc đang chờ Owner duyệt). Bắt buộc
// ghi lý do để Sales biết vì sao không nhập hàng.
const updateRestockRequestStatus = async ({
  managerNote,
  requestId,
  status,
  user,
}) => {
  if (status !== "CANCELLED") {
    throw new AppError("Invalid request status", 400, "INVALID_REQUEST_STATUS");
  }

  const request = await findRestockRequestOrThrow(requestId);
  assertManagerOwnsRequest(request, user);

  if (!["OPEN", "FORWARDED"].includes(request.status)) {
    throw new AppError("This restock request is already closed", 409, "REQUEST_CLOSED");
  }

  if (!String(managerNote || "").trim()) {
    throw new AppError(
      "A note is required when cancelling a restock request",
      400,
      "MANAGER_NOTE_REQUIRED"
    );
  }

  request.status = "CANCELLED";
  request.managerNote = String(managerNote).trim();
  request.handledBy = user._id;
  request.resolvedAt = new Date();
  await request.save();

  return populateInventoryRequest(request);
};

// Manager chuyển đề xuất của Sales lên Owner (được sửa số lượng, ghi chú).
const forwardRestockRequest = async ({ note, quantity, requestId, user }) => {
  const request = await findRestockRequestOrThrow(requestId);
  assertManagerOwnsRequest(request, user);

  if (request.status !== "OPEN") {
    throw new AppError("This restock request is already handled", 409, "REQUEST_CLOSED");
  }

  const forwardedQuantity =
    quantity === undefined || quantity === null || quantity === ""
      ? request.requestedQuantity
      : Number(quantity);

  if (
    !Number.isInteger(forwardedQuantity) ||
    forwardedQuantity < 1 ||
    forwardedQuantity > MAX_STOCK_RECEIVE_QUANTITY
  ) {
    throw new AppError(
      `Forwarded quantity must be between 1 and ${MAX_STOCK_RECEIVE_QUANTITY}`,
      400,
      "INVALID_REQUESTED_QUANTITY"
    );
  }

  request.status = "FORWARDED";
  request.forwardedQuantity = forwardedQuantity;
  request.forwardedBy = user._id;
  request.forwardedAt = new Date();
  request.managerNote = String(note || "").trim();
  await request.save();

  return populateInventoryRequest(request);
};

const receiveDirectStock = async ({
  expiryDate: rawExpiryDate,
  note,
  productId,
  quantity,
  storeId,
  user,
}) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const receivedQuantity = Number.parseInt(quantity, 10);
  const expiryDate = parseExpiryDate(rawExpiryDate);

  if (!scopedStoreId) {
    throw new AppError("Store ID is required", 400, "STORE_ID_REQUIRED");
  }

  if (!productId) {
    throw new AppError("Product ID is required", 400, "PRODUCT_ID_REQUIRED");
  }

  if (!Number.isInteger(receivedQuantity) || receivedQuantity < 1) {
    throw new AppError("Received quantity is invalid", 400, "INVALID_RECEIVED_QUANTITY");
  }

  if (receivedQuantity > MAX_STOCK_RECEIVE_QUANTITY) {
    throw new AppError(
      `Received quantity cannot exceed ${MAX_STOCK_RECEIVE_QUANTITY}`,
      400,
      "RECEIVED_QUANTITY_LIMIT_EXCEEDED",
      {
        maxAllowedQuantity: MAX_STOCK_RECEIVE_QUANTITY,
        receivedQuantity,
      }
    );
  }

  await ensureStoreCanProcessInventoryMutation({
    storeId: scopedStoreId,
    user,
  });

  return runInTransaction(async (session) => {
    await inventoryMutationService.receiveStock(
      scopedStoreId,
      [{ productId, quantity: receivedQuantity }],
      session
    );
    await applyReceivedExpiry(scopedStoreId, productId, expiryDate, session);

    await InventoryReceipt.create(
      [
        {
          storeId: scopedStoreId,
          productId,
          quantity: receivedQuantity,
          expiryDate,
          source: "DIRECT",
          note: note || "",
          receivedBy: user._id,
        },
      ],
      { session }
    );

    const inventory = await StoreInventory.findOne({
      storeId: scopedStoreId,
      productId,
    })
      .populate("storeId", "name address phone type")
      .populate("productId", "name sku brand category image price")
      .session(session);

    return {
      inventory,
      note: note || "",
      receivedQuantity,
    };
  });
};

// Manager sửa HSD đang theo dõi của một sản phẩm tại chi nhánh (ví dụ lô cũ đã
// bán hết nên HSD gần nhất đổi). `expiryDate` trống -> bỏ theo dõi HSD.
const updateInventoryExpiry = async ({
  expiryDate: rawExpiryDate,
  productId,
  storeId,
  user,
}) => {
  const scopedStoreId = getScopedStoreId(user, storeId);

  if (!scopedStoreId || !productId) {
    throw new AppError(
      "Store ID and product ID are required",
      400,
      "INVALID_EXPIRY_UPDATE"
    );
  }

  await ensureStoreCanProcessInventoryMutation({ storeId: scopedStoreId, user });
  const expiryDate = parseExpiryDate(rawExpiryDate, { allowPast: true });

  const inventory = await StoreInventory.findOneAndUpdate(
    { storeId: scopedStoreId, productId },
    { $set: { expiryDate } },
    { new: true }
  )
    .populate("storeId", "name address phone type")
    .populate("productId", "name sku brand category image price");

  if (!inventory) {
    throw new AppError("Inventory item was not found", 404, "INVENTORY_NOT_FOUND");
  }

  return inventory;
};

const createInventoryAdjustment = async ({
  note,
  productId,
  quantity,
  storeId,
  type,
  user,
}) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const adjustmentType = String(type || "").toUpperCase();

  if (!["DAMAGED", "DEFECTIVE", "LOST", "EXPIRED", "OTHER"].includes(adjustmentType)) {
    throw new AppError("Inventory adjustment type is invalid", 400, "INVALID_ADJUSTMENT_TYPE");
  }

  const normalizedQuantity = Number.parseInt(quantity, 10);

  if (!Number.isInteger(normalizedQuantity) || normalizedQuantity < 1) {
    throw new AppError("Adjustment quantity is invalid", 400, "INVALID_ADJUSTMENT_QUANTITY");
  }

  if (!scopedStoreId || !productId) {
    throw new AppError("Store ID and product ID are required", 400, "INVALID_ADJUSTMENT");
  }

  await ensureStoreCanProcessInventoryMutation({
    storeId: scopedStoreId,
    user,
  });

  return runInTransaction(async (session) => {
    await inventoryMutationService.writeOffStock(
      scopedStoreId,
      [{ productId, quantity: normalizedQuantity }],
      session
    );

    const adjustment = await InventoryAdjustment.create(
      [
        {
          storeId: scopedStoreId,
          productId,
          type: adjustmentType,
          quantity: normalizedQuantity,
          note: note || "",
          createdBy: user._id,
        },
      ],
      { session }
    );

    return adjustment[0].populate([
      { path: "storeId", select: "name address phone type" },
      { path: "productId", select: "name sku brand category image price" },
      { path: "createdBy", select: "fullName email phone role" },
    ]);
  });
};

const getInventoryReturnRequests = async ({
  status = "ALL",
  storeId,
  user,
}) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const normalizedStatus = String(status || "ALL").toUpperCase();
  const query = {};

  if (!["ALL", "PENDING", "APPROVED", "REJECTED"].includes(normalizedStatus)) {
    throw new AppError(
      "Return request status is invalid",
      400,
      "INVALID_RETURN_REQUEST_STATUS"
    );
  }

  if (scopedStoreId) {
    query.storeId = scopedStoreId;
  }

  if (normalizedStatus !== "ALL") {
    query.status = normalizedStatus;
  }

  return InventoryReturnRequest.find(query)
    .populate("storeId", "name address phone type")
    .populate("productId", "name sku brand category image price")
    .populate("requestedBy", "fullName email phone role")
    .populate("reviewedBy", "fullName email phone role")
    .sort({ updatedAt: -1, createdAt: -1 })
    .lean();
};

const createInventoryReturnRequest = async ({
  managerNote,
  productId,
  quantity,
  reasonType,
  user,
}) => {
  const scopedStoreId = getScopedStoreId(user);
  const normalizedType = String(reasonType || "").toUpperCase();
  const requestedQuantity = Number.parseInt(quantity, 10);

  if (user.role !== USER_ROLES.MANAGER) {
    throw new AppError(
      "Only managers can create faulty return requests",
      403,
      "FORBIDDEN"
    );
  }

  if (!scopedStoreId) {
    throw new AppError("Store ID is required", 400, "STORE_ID_REQUIRED");
  }

  if (!productId) {
    throw new AppError("Product ID is required", 400, "PRODUCT_ID_REQUIRED");
  }

  if (!RETURN_REQUEST_TYPES.includes(normalizedType)) {
    throw new AppError(
      "Return request reason is invalid",
      400,
      "INVALID_RETURN_REQUEST_REASON"
    );
  }

  if (!Number.isInteger(requestedQuantity) || requestedQuantity < 1) {
    throw new AppError(
      "Returned quantity is invalid",
      400,
      "INVALID_RETURN_REQUEST_QUANTITY"
    );
  }

  return runInTransaction(async (session) => {
    const inventory = await StoreInventory.findOne({
      productId,
      storeId: scopedStoreId,
    })
      .session(session)
      .lean();

    if (!inventory) {
      throw new AppError("Inventory item was not found", 404, "INVENTORY_NOT_FOUND");
    }

    if (requestedQuantity > inventory.availableStock) {
      throw new AppError(
        "Returned quantity exceeds the current available stock",
        400,
        "RETURN_REQUEST_QUANTITY_EXCEEDS_STOCK",
        {
          availableStock: inventory.availableStock,
          requestedQuantity,
        }
      );
    }

    // Khóa ngay số hàng trả (không bán được nữa) trong lúc chờ Owner duyệt.
    await inventoryMutationService.reserveStock(
      scopedStoreId,
      [{ productId, quantity: requestedQuantity }],
      session
    );

    const [request] = await InventoryReturnRequest.create(
      [
        {
          storeId: scopedStoreId,
          productId,
          quantity: requestedQuantity,
          currentAvailableStock: inventory.availableStock,
          reasonType: normalizedType,
          managerNote: managerNote || "",
          requestedBy: user._id,
          inventoryLocked: true,
        },
      ],
      { session }
    );

    return populateInventoryReturnRequest(request);
  });
};

const reviewInventoryReturnRequest = async ({
  requestId,
  reviewNote,
  status,
  user,
}) => {
  const normalizedStatus = String(status || "").toUpperCase();

  if (user.role !== USER_ROLES.OWNER) {
    throw new AppError(
      "Only owners can review faulty return requests",
      403,
      "FORBIDDEN"
    );
  }

  if (!["APPROVED", "REJECTED"].includes(normalizedStatus)) {
    throw new AppError(
      "Review status is invalid",
      400,
      "INVALID_RETURN_REQUEST_REVIEW_STATUS"
    );
  }

  return runInTransaction(async (session) => {
    const request = await InventoryReturnRequest.findById(requestId).session(session);

    if (!request) {
      throw new AppError(
        "Faulty return request was not found",
        404,
        "RETURN_REQUEST_NOT_FOUND"
      );
    }

    if (request.status !== "PENDING") {
      throw new AppError(
        "This faulty return request has already been reviewed",
        409,
        "RETURN_REQUEST_CLOSED"
      );
    }

    const items = [{ productId: request.productId, quantity: request.quantity }];

    if (request.inventoryLocked) {
      // Duyệt: trừ hẳn hàng đã khóa (reserved, total). Từ chối: trả lại vào
      // hàng bán được.
      if (normalizedStatus === "APPROVED") {
        await inventoryMutationService.completeReservedSale(
          request.storeId,
          items,
          session
        );
      } else {
        await inventoryMutationService.releaseReservedStock(
          request.storeId,
          items,
          session
        );
      }
    } else if (normalizedStatus === "APPROVED") {
      // Yêu cầu cũ chưa khóa hàng: trừ từ hàng khả dụng như trước.
      await inventoryMutationService.writeOffStock(
        request.storeId,
        items,
        session
      );
    }

    request.status = normalizedStatus;
    request.reviewNote = reviewNote || "";
    request.reviewedBy = user._id;
    request.reviewedAt = new Date();
    await request.save({ session });

    return populateInventoryReturnRequest(request);
  });
};

const getInventoryAdjustments = async ({ storeId, user }) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const query = {};

  if (scopedStoreId) {
    query.storeId = scopedStoreId;
  }

  return InventoryAdjustment.find(query)
    .populate("storeId", "name address phone type")
    .populate("productId", "name sku brand category image price")
    .populate("createdBy", "fullName email phone role")
    .sort({ createdAt: -1 })
    .limit(100)
    .lean();
};

const HISTORY_TYPES = ["RECEIPT", "ADJUSTMENT", "RETURN"];
const MAX_HISTORY_LIMIT = 300;

const productSummary = (product) =>
  product && typeof product === "object"
    ? { _id: product._id, name: product.name, sku: product.sku }
    : { _id: product };

const actorSummary = (actor) =>
  actor && typeof actor === "object"
    ? { _id: actor._id, fullName: actor.fullName, role: actor.role }
    : null;

// Lịch sử kho của chi nhánh: phiếu nhập (gồm hàng chuyển đến), ghi giảm và
// trả hàng lỗi gộp thành một dòng thời gian, mới nhất trước. Hàng bán ra
// (theo đơn) không nằm ở đây. `totalChange` là thay đổi của totalStock;
// `lockedChange` là thay đổi của số hàng bị khóa (đang giữ) do trả hàng.
const getInventoryHistory = async ({ limit, productId, storeId, type, user }) => {
  const scopedStoreId = getScopedStoreId(user, storeId);

  if (!scopedStoreId) {
    throw new AppError("Store ID is required", 400, "STORE_ID_REQUIRED");
  }

  const normalizedType = type ? String(type).toUpperCase() : null;

  if (normalizedType && !HISTORY_TYPES.includes(normalizedType)) {
    throw new AppError("History type is invalid", 400, "INVALID_HISTORY_TYPE");
  }

  const parsedLimit = Number.parseInt(limit, 10);
  const max =
    Number.isInteger(parsedLimit) && parsedLimit > 0
      ? Math.min(parsedLimit, MAX_HISTORY_LIMIT)
      : 100;
  const query = { storeId: scopedStoreId, ...(productId ? { productId } : {}) };
  const wants = (t) => !normalizedType || normalizedType === t;
  const productFields = "name sku";
  const actorFields = "fullName role";

  const [receipts, adjustments, returns] = await Promise.all([
    wants("RECEIPT")
      ? InventoryReceipt.find(query)
          .populate("productId", productFields)
          .populate("receivedBy", actorFields)
          .sort({ createdAt: -1 })
          .limit(max)
          .lean()
      : [],
    wants("ADJUSTMENT")
      ? InventoryAdjustment.find(query)
          .populate("productId", productFields)
          .populate("createdBy", actorFields)
          .sort({ createdAt: -1 })
          .limit(max)
          .lean()
      : [],
    wants("RETURN")
      ? InventoryReturnRequest.find(query)
          .populate("productId", productFields)
          .populate("requestedBy", actorFields)
          .populate("reviewedBy", actorFields)
          .sort({ updatedAt: -1 })
          .limit(max)
          .lean()
      : [],
  ]);

  const entries = [
    ...receipts.map((r) => ({
      id: `receipt:${r._id}`,
      type: "RECEIPT",
      event: r.source,
      at: r.createdAt,
      product: productSummary(r.productId),
      quantity: r.quantity,
      totalChange: r.quantity,
      lockedChange: 0,
      expiryDate: r.expiryDate || null,
      note: r.note || "",
      actor: actorSummary(r.receivedBy),
      referenceId: r.referenceId || null,
    })),
    ...adjustments.map((a) => ({
      id: `adjustment:${a._id}`,
      type: "ADJUSTMENT",
      event: a.type,
      at: a.createdAt,
      product: productSummary(a.productId),
      quantity: a.quantity,
      totalChange: -a.quantity,
      lockedChange: 0,
      expiryDate: null,
      note: a.note || "",
      actor: actorSummary(a.createdBy),
      referenceId: null,
    })),
    ...returns.flatMap((r) => {
      const base = {
        type: "RETURN",
        product: productSummary(r.productId),
        quantity: r.quantity,
        expiryDate: null,
        referenceId: r._id,
      };
      const created = {
        ...base,
        id: `return:${r._id}:created`,
        event: "RETURN_REQUESTED",
        at: r.createdAt,
        totalChange: 0,
        lockedChange: r.inventoryLocked ? r.quantity : 0,
        note: r.managerNote || "",
        actor: actorSummary(r.requestedBy),
      };

      if (r.status === "PENDING") {
        return [created];
      }

      // Yêu cầu tạo trước khi có cơ chế khóa: duyệt thì trừ từ hàng khả dụng.
      const wasLocked = Boolean(r.inventoryLocked);
      return [
        created,
        {
          ...base,
          id: `return:${r._id}:reviewed`,
          event: r.status === "APPROVED" ? "RETURN_APPROVED" : "RETURN_REJECTED",
          at: r.reviewedAt || r.updatedAt,
          totalChange: r.status === "APPROVED" ? -r.quantity : 0,
          lockedChange: wasLocked ? -r.quantity : 0,
          note: r.reviewNote || "",
          actor: actorSummary(r.reviewedBy),
        },
      ];
    }),
  ];

  return entries
    .sort((a, b) => new Date(b.at) - new Date(a.at))
    .slice(0, max);
};

const getInventoryReceipts = async ({ storeId, user }) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const query = {};

  if (scopedStoreId) {
    query.storeId = scopedStoreId;
  }

  return InventoryReceipt.find(query)
    .populate("storeId", "name address phone type")
    .populate("productId", "name sku brand category image price")
    .populate("receivedBy", "fullName email phone role")
    .sort({ createdAt: -1 })
    .limit(100)
    .lean();
};

const getIncomingTransfers = async ({ status = "PENDING", storeId, user }) => {
  const scopedStoreId = getScopedStoreId(user, storeId);
  const normalizedStatus = String(status || "PENDING").toUpperCase();

  if (!scopedStoreId) {
    throw new AppError("Store ID is required", 400, "STORE_ID_REQUIRED");
  }

  if (!["ALL", "PENDING", "CONFIRMED", "CANCELLED"].includes(normalizedStatus)) {
    throw new AppError("Transfer status is invalid", 400, "INVALID_TRANSFER_STATUS");
  }

  const query = { toStoreId: scopedStoreId };

  if (normalizedStatus !== "ALL") {
    query.status = normalizedStatus;
  }

  return StockTransfer.find(query)
    .populate("fromStoreId", "name address phone type")
    .populate("toStoreId", "name address phone type")
    .populate("items.productId", "name sku brand category image price")
    .populate("createdBy", "fullName email phone role")
    .populate("confirmedBy", "fullName email phone role")
    .sort({ updatedAt: -1, createdAt: -1 })
    .lean();
};

const confirmIncomingTransfer = async ({ transferId, user }) =>
  runInTransaction(async (session) => {
    if (user.role !== USER_ROLES.MANAGER) {
      throw new AppError(
        "Only the destination store manager can confirm incoming transfers",
        403,
        "FORBIDDEN"
      );
    }

    const transfer = await StockTransfer.findById(transferId).session(session);

    if (!transfer) {
      throw new AppError("Stock transfer was not found", 404, "TRANSFER_NOT_FOUND");
    }

    if (
      user.role !== USER_ROLES.OWNER &&
      String(transfer.toStoreId) !== String(user.storeId)
    ) {
      throw new AppError("You cannot confirm another store transfer", 403, "FORBIDDEN");
    }

    if (transfer.status !== "PENDING") {
      throw new AppError("This stock transfer is already closed", 409, "TRANSFER_CLOSED");
    }

    const sourceStore = await Store.findById(transfer.fromStoreId)
      .select("name")
      .session(session)
      .lean();

    await inventoryMutationService.receiveStock(
      transfer.toStoreId,
      transfer.items,
      session
    );

    await InventoryReceipt.create(
      transfer.items.map((item) => ({
        storeId: transfer.toStoreId,
        productId: item.productId,
        quantity: item.quantity,
        source: "TRANSFER",
        note: sourceStore?.name
          ? `Received from stock transfer: ${sourceStore.name}`
          : "Received from stock transfer",
        referenceId: transfer._id,
        receivedBy: user._id,
      })),
      { session }
    );

    transfer.status = "CONFIRMED";
    transfer.confirmedBy = user._id;
    await transfer.save({ session });

    if (transfer.restockRequestId) {
      await InventoryRequest.updateOne(
        { _id: transfer.restockRequestId, status: "IN_TRANSIT" },
        {
          $set: {
            status: "RESOLVED",
            handledBy: user._id,
            resolvedAt: new Date(),
          },
        },
        { session }
      );
    }

    return transfer.populate([
      { path: "fromStoreId", select: "name address phone type" },
      { path: "toStoreId", select: "name address phone type" },
      { path: "items.productId", select: "name sku brand category image price" },
      { path: "createdBy", select: "fullName email phone role" },
      { path: "confirmedBy", select: "fullName email phone role" },
    ]);
  });

module.exports = {
  confirmIncomingTransfer,
  createInventoryAdjustment,
  createInventoryReturnRequest,
  createRestockRequest,
  forwardRestockRequest,
  getIncomingTransfers,
  getInventoryAdjustments,
  getInventoryReceipts,
  getInventoryReturnRequests,
  getInventoryAlerts,
  getInventoryHistory,
  getProductInventory,
  getRestockRequests,
  receiveDirectStock,
  reviewInventoryReturnRequest,
  updateInventoryExpiry,
  updateRestockRequestStatus,
};
