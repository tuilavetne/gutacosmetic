const mongoose = require("mongoose");
const InventoryRequest = require("../../../models/InventoryRequest");
const InventoryReturnRequest = require("../../../models/InventoryReturnRequest");
const Order = require("../../../models/Order");
const Product = require("../../../models/Product");
const StockTransfer = require("../../../models/StockTransfer");
const Store = require("../../../models/Store");
const User = require("../../../models/User");
const AppError = require("../../../utils/AppError");
const inventoryQueryService = require("../../stock/services/inventoryQueryService");
const { ORDER_STATUSES, USER_ROLES } = require("../../../constants/business");

// Ngày báo cáo tính theo giờ Việt Nam (UTC+7) để đơn lúc 23h không nhảy ngày.
const VN_OFFSET_MS = 7 * 60 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
// Khoảng dài hơn mức này thì biểu đồ gộp theo tháng.
const MAX_DAILY_BUCKETS = 62;
const MAX_RANGE_DAYS = 3 * 366;
const TOP_PRODUCT_LIMIT = 5;
const ACTIVE_ORDER_STATUSES = [
  ORDER_STATUSES.PENDING_APPROVAL,
  ORDER_STATUSES.PENDING_PAYMENT,
  ORDER_STATUSES.PENDING,
  ORDER_STATUSES.PREPARING,
  ORDER_STATUSES.READY_FOR_PICKUP,
];

const dayKey = (date) => new Date(date.getTime() + VN_OFFSET_MS).toISOString().slice(0, 10);
const monthKey = (date) => dayKey(date).slice(0, 7);

// "yyyy-mm-dd" (giờ VN) -> thời điểm 00:00 giờ VN.
const parseDay = (value, field) => {
  const match = /^(\d{4})-(\d{2})-(\d{2})$/.exec(String(value || ""));
  const time = match ? Date.UTC(+match[1], +match[2] - 1, +match[3]) - VN_OFFSET_MS : NaN;

  if (Number.isNaN(time) || dayKey(new Date(time)) !== value) {
    throw new AppError(`${field} must be a date (yyyy-mm-dd)`, 400, "INVALID_DATE_RANGE", {
      field,
    });
  }

  return new Date(time);
};

const todayStart = () => parseDay(dayKey(new Date()), "today");

const resolveRange = ({ from, to }) => {
  const end = to ? parseDay(to, "to") : todayStart();
  const start = from ? parseDay(from, "from") : new Date(end.getTime() - 29 * DAY_MS);
  const days = Math.round((end - start) / DAY_MS) + 1;

  if (days < 1 || days > MAX_RANGE_DAYS) {
    throw new AppError("Date range is invalid", 400, "INVALID_DATE_RANGE");
  }

  return {
    start,
    endExclusive: new Date(end.getTime() + DAY_MS),
    from: dayKey(start),
    to: dayKey(end),
    days,
  };
};

// Doanh thu chỉ tính đơn đã hoàn tất, theo thời điểm hoàn tất (đơn cũ chưa
// có completedAt thì lấy updatedAt).
const completedOrdersQuery = ({ start, endExclusive, storeId }) => ({
  status: ORDER_STATUSES.COMPLETED,
  ...(storeId ? { storeId } : {}),
  $or: [
    { completedAt: { $gte: start, $lt: endExclusive } },
    { completedAt: null, updatedAt: { $gte: start, $lt: endExclusive } },
  ],
});

const completedAtOf = (order) => new Date(order.completedAt || order.updatedAt);

const fetchCompletedOrders = (range) =>
  Order.find(completedOrdersQuery(range))
    .select("channel totalPrice items storeId completedAt updatedAt")
    .lean();

const emptyTotals = () => ({ revenue: 0, onlineRevenue: 0, offlineRevenue: 0, orders: 0 });

const addOrder = (totals, order) => {
  totals.revenue += order.totalPrice;
  totals.orders += 1;
  if (order.channel === "ONLINE") {
    totals.onlineRevenue += order.totalPrice;
  } else {
    totals.offlineRevenue += order.totalPrice;
  }
};

const buildBuckets = ({ start, endExclusive }, granularity) => {
  const keys = [];
  if (granularity === "day") {
    for (let t = start.getTime(); t < endExclusive.getTime(); t += DAY_MS) {
      keys.push(dayKey(new Date(t)));
    }
  } else {
    for (let t = start.getTime(); t < endExclusive.getTime(); t += DAY_MS) {
      const key = monthKey(new Date(t));
      if (keys[keys.length - 1] !== key) keys.push(key);
    }
  }
  return new Map(keys.map((key) => [key, { key, ...emptyTotals() }]));
};

// Báo cáo doanh thu: lọc theo khoảng ngày và cửa hàng, biểu đồ theo ngày
// (hoặc tháng nếu khoảng dài), so sánh chi nhánh, top sản phẩm, lợi nhuận gộp
// (chỉ tính phần sản phẩm đã có giá vốn).
const getRevenueReport = async (filters = {}) => {
  const range = resolveRange(filters);
  let storeId = null;

  if (filters.storeId) {
    if (!mongoose.isValidObjectId(filters.storeId)) {
      throw new AppError("Store ID is invalid", 400, "VALIDATION_ERROR", { field: "storeId" });
    }
    storeId = filters.storeId;
  }

  const granularity = range.days > MAX_DAILY_BUCKETS ? "month" : "day";
  const [orders, stores] = await Promise.all([
    fetchCompletedOrders({ ...range, storeId }),
    Store.find(storeId ? { _id: storeId } : {}).sort({ name: 1 }).lean(),
  ]);

  const productIds = [...new Set(orders.flatMap((o) => o.items.map((i) => String(i.productId))))];
  const products = await Product.find({ _id: { $in: productIds } })
    .select("name sku costPrice")
    .lean();
  const productById = new Map(products.map((p) => [String(p._id), p]));

  const summary = emptyTotals();
  const buckets = buildBuckets(range, granularity);
  const byStore = new Map(
    stores.map((store) => [String(store._id), { store, ...emptyTotals() }])
  );
  const productStats = new Map();
  let costedRevenue = 0;
  let costedCost = 0;
  const missingCost = new Set();

  for (const order of orders) {
    addOrder(summary, order);
    const at = completedAtOf(order);
    const bucket = buckets.get(granularity === "day" ? dayKey(at) : monthKey(at));
    if (bucket) addOrder(bucket, order);
    const storeEntry = byStore.get(String(order.storeId));
    if (storeEntry) addOrder(storeEntry, order);

    for (const item of order.items) {
      const id = String(item.productId);
      const stat = productStats.get(id) || {
        productId: id,
        name: item.name,
        sku: item.sku,
        quantity: 0,
        revenue: 0,
      };
      stat.quantity += item.quantity;
      stat.revenue += item.lineTotal;
      productStats.set(id, stat);

      const costPrice = productById.get(id)?.costPrice;
      if (typeof costPrice === "number" && Number.isFinite(costPrice)) {
        costedRevenue += item.lineTotal;
        costedCost += costPrice * item.quantity;
      } else {
        missingCost.add(id);
      }
    }
  }

  return {
    range: { from: range.from, to: range.to, granularity },
    summary: {
      ...summary,
      averageOrderValue: summary.orders ? Math.round(summary.revenue / summary.orders) : 0,
      // Lợi nhuận gộp chỉ trên các sản phẩm đã có giá vốn.
      costedRevenue,
      grossProfit: costedRevenue - costedCost,
      missingCostProductCount: missingCost.size,
      missingCostProducts: [...missingCost]
        .slice(0, 5)
        .map((id) => productById.get(id)?.name || productStats.get(id)?.name)
        .filter(Boolean),
    },
    series: [...buckets.values()],
    stores: [...byStore.values()]
      .filter((entry) => entry.store.isActive || entry.orders > 0)
      .sort((a, b) => b.revenue - a.revenue),
    topProducts: [...productStats.values()]
      .sort((a, b) => b.revenue - a.revenue)
      .slice(0, TOP_PRODUCT_LIMIT),
  };
};

// Trang chủ Owner: doanh thu hôm nay / tháng này, việc chờ duyệt, cảnh báo kho
// và tóm tắt từng chi nhánh (toàn chuỗi).
const getDashboard = async (owner) => {
  const today = todayStart();
  const todayKey = dayKey(today);
  const monthStart = parseDay(`${todayKey.slice(0, 7)}-01`, "month");
  const monthRange = { start: monthStart, endExclusive: new Date(today.getTime() + DAY_MS) };

  const [monthOrders, stores, activeOrders, staff, forwarded, returnsPending, transfersPending, alerts] =
    await Promise.all([
      fetchCompletedOrders(monthRange),
      Store.find({}).sort({ type: 1, name: 1 }).lean(),
      Order.aggregate([
        { $match: { status: { $in: ACTIVE_ORDER_STATUSES } } },
        { $group: { _id: "$storeId", count: { $sum: 1 } } },
      ]),
      User.aggregate([
        {
          $match: {
            role: { $in: [USER_ROLES.MANAGER, USER_ROLES.SALES] },
            isActive: true,
          },
        },
        { $group: { _id: "$storeId", count: { $sum: 1 } } },
      ]),
      InventoryRequest.countDocuments({ status: "FORWARDED" }),
      InventoryReturnRequest.countDocuments({ status: "PENDING" }),
      StockTransfer.countDocuments({ status: "PENDING" }),
      inventoryQueryService.getInventoryAlerts({ user: owner }),
    ]);

  const todayTotals = emptyTotals();
  const monthTotals = emptyTotals();
  const perStore = new Map(
    stores.map((store) => [
      String(store._id),
      {
        store,
        today: emptyTotals(),
        month: emptyTotals(),
        ordersInProgress: 0,
        activeStaff: 0,
        alerts: { lowStock: 0, outOfStock: 0, expiringSoon: 0, expired: 0 },
      },
    ])
  );

  for (const order of monthOrders) {
    const entry = perStore.get(String(order.storeId));
    addOrder(monthTotals, order);
    if (entry) addOrder(entry.month, order);
    if (dayKey(completedAtOf(order)) === todayKey) {
      addOrder(todayTotals, order);
      if (entry) addOrder(entry.today, order);
    }
  }

  for (const row of activeOrders) {
    const entry = perStore.get(String(row._id));
    if (entry) entry.ordersInProgress = row.count;
  }

  for (const row of staff) {
    const entry = perStore.get(String(row._id));
    if (entry) entry.activeStaff = row.count;
  }

  const alertTotals = { lowStock: 0, outOfStock: 0, expiringSoon: 0, expired: 0 };
  for (const alert of alerts) {
    const key =
      alert.type === "LOW_STOCK"
        ? alert.severity === "CRITICAL"
          ? "outOfStock"
          : "lowStock"
        : alert.type === "EXPIRED"
          ? "expired"
          : "expiringSoon";
    alertTotals[key] += 1;
    const entry = perStore.get(String(alert.store?._id || alert.store));
    if (entry) entry.alerts[key] += 1;
  }

  return {
    today: todayTotals,
    month: monthTotals,
    pending: {
      restockRequests: forwarded,
      returnRequests: returnsPending,
      transfersInTransit: transfersPending,
    },
    alerts: alertTotals,
    stores: [...perStore.values()],
  };
};

module.exports = {
  getDashboard,
  getRevenueReport,
};
