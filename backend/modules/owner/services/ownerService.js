const mongoose = require("mongoose");
const InventoryRequest = require("../../../models/InventoryRequest");
const Order = require("../../../models/Order");
const Product = require("../../../models/Product");
const Store = require("../../../models/Store");
const StoreInventory = require("../../../models/StoreInventory");
const StockTransfer = require("../../../models/StockTransfer");
const User = require("../../../models/User");
const AppError = require("../../../utils/AppError");
const { runInTransaction } = require("../../stock/services/transactionService");
const inventoryMutationService = require("../../stock/services/inventoryService");
const {
  ORDER_STATUSES,
  STORE_TYPES,
  USER_ROLES,
} = require("../../../constants/business");
const {
  normalizeEmail,
  normalizePhone,
  requireString,
  validateAddress,
  validateFullName,
  validatePassword,
} = require("../../../utils/authValidation");

const PRODUCT_FIELDS = "name sku brand category image price isActive";
const STAFF_ROLES = [USER_ROLES.OWNER, USER_ROLES.MANAGER, USER_ROLES.SALES];
// Owner chỉ tạo/sửa Manager và Sales; tài khoản Owner không quản lý ở đây.
const ASSIGNABLE_ROLES = [USER_ROLES.MANAGER, USER_ROLES.SALES];
const MAX_PRODUCT_GALLERY_IMAGES = 5;
const MAX_TRANSFER_QUANTITY = 1000;
// Đơn còn đang xử lý: chi nhánh có các đơn này thì chưa được ngừng hoạt động.
const ACTIVE_ORDER_STATUSES = [
  ORDER_STATUSES.PENDING_APPROVAL,
  ORDER_STATUSES.PENDING_PAYMENT,
  ORDER_STATUSES.PENDING,
  ORDER_STATUSES.PREPARING,
  ORDER_STATUSES.READY_FOR_PICKUP,
];
const escapeRegExp = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

const parseOptionalString = (value) =>
  typeof value === "string" ? value.trim() : "";

const parseStringArray = (value) => {
  if (Array.isArray(value)) {
    return value
      .map((item) => (typeof item === "string" ? item.trim() : ""))
      .filter(Boolean);
  }

  if (typeof value === "string") {
    return value
      .split(",")
      .map((item) => item.trim())
      .filter(Boolean);
  }

  return [];
};

const parseBoolean = (value, defaultValue = undefined) => {
  if (typeof value === "boolean") {
    return value;
  }

  if (typeof value === "string") {
    if (value === "true") {
      return true;
    }

    if (value === "false") {
      return false;
    }
  }

  return defaultValue;
};

const parseNonNegativeNumber = (value, fieldName, { required = false } = {}) => {
  if (value === undefined || value === null || value === "") {
    if (required) {
      throw new AppError(`${fieldName} is required`, 400, "VALIDATION_ERROR", {
        field: fieldName,
      });
    }

    return undefined;
  }

  const number = Number(value);

  if (!Number.isFinite(number) || number < 0) {
    throw new AppError(
      `${fieldName} must be a non-negative number`,
      400,
      "VALIDATION_ERROR",
      { field: fieldName }
    );
  }

  return number;
};

const ensureObjectId = (value, fieldName) => {
  const normalized = requireString(String(value || ""), fieldName);

  if (!mongoose.isValidObjectId(normalized)) {
    throw new AppError(`${fieldName} is invalid`, 400, "VALIDATION_ERROR", {
      field: fieldName,
    });
  }

  return normalized;
};

const normalizeIngredients = (value) => {
  if (!Array.isArray(value)) {
    return [];
  }

  return value
    .map((item) => {
      const title = parseOptionalString(item?.title);

      if (!title) {
        return null;
      }

      return {
        icon: parseOptionalString(item?.icon) || "leaf-outline",
        subtitle: parseOptionalString(item?.subtitle),
        title,
      };
    })
    .filter(Boolean);
};

const populateStaff = (query) =>
  query.populate("storeId", "name type address phone isActive");

const populateTransfer = (query) =>
  query.populate([
    { path: "fromStoreId", select: "name type address phone isActive" },
    { path: "toStoreId", select: "name type address phone isActive" },
    { path: "items.productId", select: PRODUCT_FIELDS },
    { path: "createdBy", select: "fullName email phone role" },
    { path: "confirmedBy", select: "fullName email phone role" },
  ]);

const buildProductPayload = (payload, { isCreate = false } = {}) => {
  const nextPayload = {};

  if (isCreate || payload.sku !== undefined) {
    nextPayload.sku = requireString(payload.sku, "sku").toUpperCase();
  }

  if (isCreate || payload.name !== undefined) {
    nextPayload.name = requireString(payload.name, "name");
  }

  if (isCreate || payload.brand !== undefined) {
    nextPayload.brand = requireString(payload.brand, "brand");
  }

  if (isCreate || payload.category !== undefined) {
    nextPayload.category = requireString(payload.category, "category");
  }

  if (isCreate || payload.price !== undefined) {
    nextPayload.price = parseNonNegativeNumber(payload.price, "price", {
      required: true,
    });
  }

  if (payload.costPrice !== undefined) {
    nextPayload.costPrice =
      payload.costPrice === null || payload.costPrice === ""
        ? null
        : parseNonNegativeNumber(payload.costPrice, "costPrice");
  }

  if (payload.originalPrice !== undefined) {
    nextPayload.originalPrice =
      payload.originalPrice === null || payload.originalPrice === ""
        ? null
        : parseNonNegativeNumber(payload.originalPrice, "originalPrice");
  }

  if (payload.description !== undefined) {
    nextPayload.description = parseOptionalString(payload.description);
  }

  if (payload.image !== undefined) {
    nextPayload.image = parseOptionalString(payload.image);
  }

  if (payload.images !== undefined) {
    nextPayload.images = parseStringArray(payload.images);

    if (nextPayload.images.length > MAX_PRODUCT_GALLERY_IMAGES) {
      throw new AppError(
        `A product can have at most ${MAX_PRODUCT_GALLERY_IMAGES} gallery images`,
        400,
        "TOO_MANY_PRODUCT_IMAGES"
      );
    }
  }

  if (payload.skinTypes !== undefined) {
    nextPayload.skinTypes = parseStringArray(payload.skinTypes);
  }

  if (payload.volume !== undefined) {
    nextPayload.volume = parseOptionalString(payload.volume);
  }

  if (payload.origin !== undefined) {
    nextPayload.origin = parseOptionalString(payload.origin);
  }

  if (payload.expiryDate !== undefined) {
    nextPayload.expiryDate = parseOptionalString(payload.expiryDate);
  }

  if (payload.ingredients !== undefined) {
    nextPayload.ingredients = normalizeIngredients(payload.ingredients);
  }

  if (payload.isActive !== undefined) {
    nextPayload.isActive = parseBoolean(payload.isActive, true);
  }

  return nextPayload;
};

const buildStorePayload = (payload, { isCreate = false } = {}) => {
  const nextPayload = {};

  if (isCreate || payload.name !== undefined) {
    nextPayload.name = requireString(payload.name, "name");
  }

  if (isCreate || payload.address !== undefined) {
    nextPayload.address = requireString(payload.address, "address");
  }

  if (isCreate || payload.phone !== undefined) {
    nextPayload.phone = requireString(payload.phone, "phone");
  }

  if (isCreate || payload.type !== undefined) {
    const type = requireString(payload.type, "type").toUpperCase();

    if (!Object.values(STORE_TYPES).includes(type)) {
      throw new AppError("Store type is invalid", 400, "VALIDATION_ERROR", {
        field: "type",
      });
    }

    nextPayload.type = type;
  }

  if (payload.isActive !== undefined) {
    nextPayload.isActive = parseBoolean(payload.isActive, true);
  }

  return nextPayload;
};

const ensureStoreExists = async (storeId) => {
  const store = await Store.findById(storeId);

  if (!store) {
    throw new AppError("Store was not found", 404, "STORE_NOT_FOUND");
  }

  return store;
};

const ensureProductExists = async (productId) => {
  const product = await Product.findById(productId);

  if (!product) {
    throw new AppError("Product was not found", 404, "PRODUCT_NOT_FOUND");
  }

  return product;
};

const buildStaffPayload = async (payload, { isCreate = false } = {}) => {
  const nextPayload = {};

  if (isCreate || payload.fullName !== undefined) {
    nextPayload.fullName = validateFullName(payload.fullName);
  }

  if (isCreate || payload.email !== undefined) {
    nextPayload.email = normalizeEmail(payload.email);
  }

  if (isCreate || payload.phone !== undefined) {
    nextPayload.phone = normalizePhone(payload.phone);
  }

  if (isCreate || payload.address !== undefined) {
    nextPayload.address = validateAddress(payload.address);
  }

  if (payload.password !== undefined) {
    nextPayload.password = validatePassword(payload.password);
  }

  if (isCreate || payload.role !== undefined) {
    const role = requireString(payload.role, "role").toUpperCase();

    if (!ASSIGNABLE_ROLES.includes(role)) {
      throw new AppError(
        "Only Manager or Sales accounts can be managed here",
        400,
        "ROLE_NOT_ALLOWED",
        { field: "role" }
      );
    }

    nextPayload.role = role;
  }

  if (payload.storeId !== undefined) {
    nextPayload.storeId = payload.storeId
      ? ensureObjectId(payload.storeId, "storeId")
      : null;
  }

  if (payload.isActive !== undefined) {
    nextPayload.isActive = parseBoolean(payload.isActive, true);
  }

  if (payload.disabledReason !== undefined) {
    nextPayload.disabledReason = parseOptionalString(payload.disabledReason);
  }

  return nextPayload;
};

// Sales/Manager bắt buộc gán một chi nhánh đang hoạt động.
const assertStaffStore = async (role, storeId) => {
  if (!ASSIGNABLE_ROLES.includes(role)) {
    return;
  }

  if (!storeId) {
    throw new AppError(
      "Sales and Manager accounts must be assigned to a store",
      400,
      "STORE_REQUIRED",
      { field: "storeId" }
    );
  }

  const store = await ensureStoreExists(storeId);

  if (!store.isActive) {
    throw new AppError("Store is inactive", 409, "STORE_INACTIVE", {
      field: "storeId",
    });
  }
};

const seedInventoryForNewProduct = async (productId, session) => {
  const stores = await Store.find({}).select("_id").session(session).lean();

  if (stores.length === 0) {
    return;
  }

  await StoreInventory.insertMany(
    stores.map((store) => ({
      storeId: store._id,
      productId,
      totalStock: 0,
      reservedStock: 0,
      availableStock: 0,
    })),
    { session }
  );
};

const seedInventoryForNewStore = async (storeId, session) => {
  const products = await Product.find({}).select("_id").session(session).lean();

  if (products.length === 0) {
    return;
  }

  await StoreInventory.insertMany(
    products.map((product) => ({
      storeId,
      productId: product._id,
      totalStock: 0,
      reservedStock: 0,
      availableStock: 0,
    })),
    { session }
  );
};

const getManagedProducts = async ({
  category,
  includeInactive = true,
  search,
}) => {
  const query = {};

  if (!includeInactive) {
    query.isActive = true;
  }

  if (category) {
    query.category = category;
  }

  if (search) {
    const pattern = { $regex: escapeRegExp(search.trim()), $options: "i" };
    query.$or = [{ name: pattern }, { sku: pattern }, { brand: pattern }];
  }

  return Product.find(query).sort({ isActive: -1, createdAt: -1 }).lean();
};

const createManagedProduct = async (payload) => {
  const nextPayload = buildProductPayload(payload, { isCreate: true });

  return runInTransaction(async (session) => {
    const existingProduct = await Product.findOne({ sku: nextPayload.sku }).session(session);

    if (existingProduct) {
      throw new AppError("SKU already exists", 409, "SKU_EXISTS");
    }

    const product = await Product.create([nextPayload], { session });
    await seedInventoryForNewProduct(product[0]._id, session);
    return product[0];
  });
};

// SKU cố định sau khi tạo (đơn hàng, phiếu kho đã ghi theo SKU).
const updateManagedProduct = async (productId, payload) => {
  const product = await ensureProductExists(productId);

  if (
    payload.sku !== undefined &&
    String(payload.sku).trim().toUpperCase() !== product.sku
  ) {
    throw new AppError("SKU cannot be changed", 400, "SKU_IMMUTABLE");
  }

  const nextPayload = buildProductPayload({ ...payload, sku: undefined });

  return Product.findByIdAndUpdate(productId, nextPayload, {
    new: true,
    runValidators: true,
  });
};

const getManagedStores = async ({ includeInactive = true } = {}) => {
  const query = includeInactive ? {} : { isActive: true };
  return Store.find(query).sort({ isActive: -1, name: 1 }).lean();
};

// Hệ thống chỉ có đúng một kho tổng (nguồn mặc định khi chuyển hàng).
const createManagedStore = async (payload) => {
  const nextPayload = buildStorePayload(payload, { isCreate: true });

  if (nextPayload.type === STORE_TYPES.CENTRAL) {
    const central = await Store.exists({ type: STORE_TYPES.CENTRAL });

    if (central) {
      throw new AppError(
        "The central warehouse already exists",
        409,
        "CENTRAL_STORE_EXISTS"
      );
    }
  }

  return runInTransaction(async (session) => {
    const store = await Store.create([nextPayload], { session });
    await seedInventoryForNewStore(store[0]._id, session);
    return store[0];
  });
};

// Chưa cho ngừng hoạt động khi còn đơn đang xử lý, còn nhân viên được gán
// hoặc còn phiếu chuyển hàng chưa nhận; kho tổng luôn phải hoạt động.
const assertStoreCanBeDeactivated = async (store) => {
  if (store.type === STORE_TYPES.CENTRAL) {
    throw new AppError(
      "The central warehouse cannot be deactivated",
      409,
      "CENTRAL_STORE_REQUIRED"
    );
  }

  const [activeOrders, staffCount, pendingTransfers] = await Promise.all([
    Order.countDocuments({
      storeId: store._id,
      status: { $in: ACTIVE_ORDER_STATUSES },
    }),
    User.countDocuments({
      storeId: store._id,
      role: { $in: ASSIGNABLE_ROLES },
      isActive: true,
    }),
    StockTransfer.countDocuments({
      status: "PENDING",
      $or: [{ fromStoreId: store._id }, { toStoreId: store._id }],
    }),
  ]);

  if (activeOrders > 0) {
    throw new AppError(
      "Store still has orders in progress",
      409,
      "STORE_HAS_ACTIVE_ORDERS",
      { count: activeOrders }
    );
  }

  if (staffCount > 0) {
    throw new AppError(
      "Move or disable the staff assigned to this store first",
      409,
      "STORE_HAS_STAFF",
      { count: staffCount }
    );
  }

  if (pendingTransfers > 0) {
    throw new AppError(
      "Store still has stock transfers waiting to be received",
      409,
      "STORE_HAS_PENDING_TRANSFERS",
      { count: pendingTransfers }
    );
  }
};

// Loại cửa hàng (kho tổng / chi nhánh) cố định sau khi tạo.
const updateManagedStore = async (storeId, payload) => {
  const store = await ensureStoreExists(storeId);

  if (
    payload.type !== undefined &&
    String(payload.type).trim().toUpperCase() !== store.type
  ) {
    throw new AppError("Store type cannot be changed", 400, "STORE_TYPE_IMMUTABLE");
  }

  const nextPayload = buildStorePayload({ ...payload, type: undefined });

  if (nextPayload.isActive === false && store.isActive) {
    await assertStoreCanBeDeactivated(store);
  }

  return Store.findByIdAndUpdate(storeId, nextPayload, {
    new: true,
    runValidators: true,
  });
};

const getManagedStaff = async ({ includeInactive = true } = {}) => {
  const query = { role: { $in: ASSIGNABLE_ROLES } };

  if (!includeInactive) {
    query.isActive = true;
  }

  return populateStaff(
    User.find(query).sort({ isActive: -1, role: 1, fullName: 1 })
  ).lean();
};

const assertUniqueStaffIdentity = async ({ email, phone, userId = null }) => {
  const query = {
    $or: [{ email }, { phone }],
  };

  if (userId) {
    query._id = { $ne: userId };
  }

  const existingUser = await User.findOne(query).lean();

  if (!existingUser) {
    return;
  }

  throw new AppError(
    existingUser.email === email ? "Email already exists" : "Phone already exists",
    409,
    existingUser.email === email ? "EMAIL_EXISTS" : "PHONE_EXISTS"
  );
};

const createManagedStaff = async (payload) => {
  const nextPayload = await buildStaffPayload(payload, { isCreate: true });

  if (!nextPayload.password) {
    throw new AppError("password is required", 400, "VALIDATION_ERROR", {
      field: "password",
    });
  }

  await assertStaffStore(nextPayload.role, nextPayload.storeId);
  await assertUniqueStaffIdentity({
    email: nextPayload.email,
    phone: nextPayload.phone,
  });

  return User.create({
    ...nextPayload,
    authProvider: "LOCAL",
    disabledAt: nextPayload.isActive === false ? new Date() : null,
    emailVerified: true,
  });
};

const updateManagedStaff = async (actor, userId, payload) => {
  const staff = await User.findById(userId).select("+password");

  if (!staff || !ASSIGNABLE_ROLES.includes(staff.role)) {
    throw new AppError("Staff account was not found", 404, "STAFF_NOT_FOUND");
  }

  if (
    String(staff._id) === String(actor._id) &&
    parseBoolean(payload.isActive) === false
  ) {
    throw new AppError(
      "You cannot disable your own account",
      409,
      "SELF_DISABLE_FORBIDDEN"
    );
  }

  const nextPayload = await buildStaffPayload(payload);

  // Kiểm tra theo giá trị sau khi sửa: không được gỡ chi nhánh của Sales/Manager.
  if (nextPayload.role !== undefined || nextPayload.storeId !== undefined) {
    await assertStaffStore(
      nextPayload.role ?? staff.role,
      nextPayload.storeId !== undefined ? nextPayload.storeId : staff.storeId
    );
  }

  const nextEmail = nextPayload.email || staff.email;
  const nextPhone = nextPayload.phone || staff.phone;

  if (nextEmail !== staff.email || nextPhone !== staff.phone) {
    await assertUniqueStaffIdentity({
      email: nextEmail,
      phone: nextPhone,
      userId: staff._id,
    });
  }

  Object.assign(staff, nextPayload);

  // Đặt lại mật khẩu: các phiên đăng nhập cũ của nhân viên hết hiệu lực.
  if (nextPayload.password) {
    staff.passwordChangedAt = new Date();
  }

  if (nextPayload.isActive === false) {
    staff.disabledAt = new Date();
    staff.disabledReason = nextPayload.disabledReason || "Disabled by owner";
  }

  if (nextPayload.isActive === true) {
    staff.disabledAt = null;
    staff.disabledReason = "";
  }

  await staff.save();
  return populateStaff(User.findById(staff._id)).lean();
};

const getStockTransfers = async ({ status = "ALL", storeId } = {}) => {
  const query = {};

  if (status && status !== "ALL") {
    query.status = status;
  }

  if (storeId) {
    const normalizedStoreId = ensureObjectId(storeId, "storeId");
    query.$or = [{ fromStoreId: normalizedStoreId }, { toStoreId: normalizedStoreId }];
  }

  return populateTransfer(
    StockTransfer.find(query).sort({ createdAt: -1 })
  ).lean();
};

// Chuyển hàng giữa hai cửa hàng bất kỳ (chỉ Owner). Kho gửi bị trừ ngay khi
// tạo phiếu; chi nhánh nhận được cộng khi Manager xác nhận đã nhận.
const createTransferInSession = async (payload, owner, session, extra = {}) => {
  const fromStoreId = ensureObjectId(payload.fromStoreId, "fromStoreId");
  const toStoreId = ensureObjectId(payload.toStoreId, "toStoreId");

  if (fromStoreId === toStoreId) {
    throw new AppError(
      "Destination store must be different from source store",
      400,
      "VALIDATION_ERROR",
      { field: "toStoreId" }
    );
  }

  const [fromStore, toStore] = await Promise.all([
    ensureStoreExists(fromStoreId),
    ensureStoreExists(toStoreId),
  ]);

  if (!fromStore.isActive || !toStore.isActive) {
    throw new AppError(
      "Stock transfers require both source and destination stores to be active",
      409,
      "STORE_INACTIVE"
    );
  }

  const items = inventoryMutationService.normalizeItems(payload.items);

  if (items.some((item) => item.quantity > MAX_TRANSFER_QUANTITY)) {
    throw new AppError(
      `Each item can transfer at most ${MAX_TRANSFER_QUANTITY} units`,
      400,
      "TRANSFER_QUANTITY_LIMIT_EXCEEDED"
    );
  }

  await inventoryMutationService.writeOffStock(fromStoreId, items, session);

  const [transfer] = await StockTransfer.create(
    [
      {
        createdBy: owner._id,
        fromStoreId,
        items,
        toStoreId,
        note: String(payload.note || "").trim(),
        restockRequestId: extra.restockRequestId || null,
      },
    ],
    { session }
  );

  return transfer;
};

const createStockTransfer = async (payload, owner) =>
  runInTransaction(async (session) => {
    const transfer = await createTransferInSession(payload, owner, session);
    return populateTransfer(StockTransfer.findById(transfer._id)).session(session);
  });

const cancelStockTransfer = async (transferId) =>
  runInTransaction(async (session) => {
    const transfer = await StockTransfer.findById(transferId).session(session);

    if (!transfer) {
      throw new AppError("Stock transfer was not found", 404, "TRANSFER_NOT_FOUND");
    }

    if (transfer.status !== "PENDING") {
      throw new AppError(
        "Only pending transfers can be cancelled",
        409,
        "TRANSFER_CLOSED"
      );
    }

    await inventoryMutationService.receiveStock(
      transfer.fromStoreId,
      transfer.items,
      session
    );

    transfer.status = "CANCELLED";
    await transfer.save({ session });

    // Phiếu tạo từ đề xuất nhập hàng: đề xuất quay về chờ Owner duyệt lại.
    if (transfer.restockRequestId) {
      await InventoryRequest.updateOne(
        { _id: transfer.restockRequestId, status: "IN_TRANSIT" },
        {
          $set: {
            status: "FORWARDED",
            transferId: null,
            approvedBy: null,
            approvedAt: null,
            approvedQuantity: null,
          },
        },
        { session }
      );
    }

    return populateTransfer(StockTransfer.findById(transfer._id)).session(session);
  });

const findForwardedRequest = async (requestId, session) => {
  const request = await InventoryRequest.findById(ensureObjectId(requestId, "requestId"))
    .session(session || null);

  if (!request) {
    throw new AppError("Restock request was not found", 404, "REQUEST_NOT_FOUND");
  }

  if (request.status !== "FORWARDED") {
    throw new AppError(
      "Only requests forwarded by a manager can be reviewed",
      409,
      "REQUEST_NOT_FORWARDED"
    );
  }

  return request;
};

// Owner duyệt đề xuất: tạo phiếu chuyển hàng (mặc định từ kho tổng) tới chi
// nhánh đề xuất. Đề xuất tự hoàn tất khi Manager xác nhận đã nhận hàng.
const approveRestockRequest = async (requestId, payload, owner) =>
  runInTransaction(async (session) => {
    const request = await findForwardedRequest(requestId, session);
    const quantity =
      payload.quantity === undefined || payload.quantity === null || payload.quantity === ""
        ? request.forwardedQuantity || request.requestedQuantity
        : Number(payload.quantity);

    if (!Number.isInteger(quantity) || quantity < 1 || quantity > MAX_TRANSFER_QUANTITY) {
      throw new AppError(
        `Approved quantity must be between 1 and ${MAX_TRANSFER_QUANTITY}`,
        400,
        "INVALID_REQUESTED_QUANTITY"
      );
    }

    let fromStoreId = payload.fromStoreId;

    if (!fromStoreId) {
      const central = await Store.findOne({ type: STORE_TYPES.CENTRAL, isActive: true })
        .session(session)
        .lean();

      if (!central) {
        throw new AppError(
          "No active central warehouse to transfer from",
          409,
          "CENTRAL_STORE_NOT_FOUND"
        );
      }

      fromStoreId = central._id;
    }

    const note = String(payload.note || "").trim();
    const transfer = await createTransferInSession(
      {
        fromStoreId: String(fromStoreId),
        toStoreId: String(request.storeId),
        items: [{ productId: String(request.productId), quantity }],
        note: note || "Duyệt đề xuất nhập hàng của chi nhánh",
      },
      owner,
      session,
      { restockRequestId: request._id }
    );

    request.status = "IN_TRANSIT";
    request.approvedQuantity = quantity;
    request.approvedBy = owner._id;
    request.approvedAt = new Date();
    request.ownerNote = note;
    request.transferId = transfer._id;
    await request.save({ session });

    return { request, transfer };
  });

// Owner từ chối đề xuất — bắt buộc ghi lý do (Manager và Sales đều thấy).
const rejectRestockRequest = async (requestId, payload, owner) => {
  const note = String(payload.note || "").trim();

  if (!note) {
    throw new AppError(
      "A reason is required when rejecting a restock request",
      400,
      "OWNER_NOTE_REQUIRED"
    );
  }

  const request = await findForwardedRequest(requestId);
  request.status = "CANCELLED";
  request.ownerNote = note;
  request.handledBy = owner._id;
  request.resolvedAt = new Date();
  await request.save();
  return request;
};

module.exports = {
  approveRestockRequest,
  cancelStockTransfer,
  createManagedProduct,
  createManagedStaff,
  createManagedStore,
  createStockTransfer,
  getManagedProducts,
  getManagedStaff,
  getManagedStores,
  getStockTransfers,
  updateManagedProduct,
  updateManagedStaff,
  rejectRestockRequest,
  updateManagedStore,
};
