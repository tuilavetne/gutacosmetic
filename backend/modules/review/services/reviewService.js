const mongoose = require("mongoose");
const Review = require("../../../models/Review");
const Order = require("../../../models/Order");
const AppError = require("../../../utils/AppError");
const { ORDER_STATUSES } = require("../../../constants/business");

// ─── Guards ───────────────────────────────────────────────────────────────────

const assertValidObjectId = (id, label = "ID") => {
  if (!mongoose.isValidObjectId(id)) {
    throw new AppError(`${label} không hợp lệ`, 400, "INVALID_ID");
  }
};

// ─── Queries ──────────────────────────────────────────────────────────────────

const MAX_REVIEW_PAGE_SIZE = 50;
const DEFAULT_REVIEW_PAGE_SIZE = 10;

const parsePaginationNumber = (value, label, min) => {
  if (value === undefined || value === null || value === "") {
    return undefined;
  }

  const parsed = Number(value);
  if (!Number.isInteger(parsed) || parsed < min) {
    throw new AppError(
      `${label} phải là số nguyên ≥ ${min}`,
      400,
      "INVALID_PAGINATION"
    );
  }

  return parsed;
};

/**
 * Đánh giá của sản phẩm, mới nhất trước.
 *
 * - Không truyền gì: trả tất cả (giữ hành vi cũ).
 * - Chỉ `limit`: `limit` đánh giá mới nhất (giữ hành vi cũ).
 * - Có `page` hoặc `skip`: phân trang, `limit` mặc định 10, tối đa 50.
 *   `skip` được ưu tiên hơn `page`.
 */
const getReviewsByProduct = async (productId, { limit, page, skip } = {}) => {
  assertValidObjectId(productId, "Product ID");

  const parsedLimit = parsePaginationNumber(limit, "limit", 1);
  const parsedPage = parsePaginationNumber(page, "page", 1);
  const parsedSkip = parsePaginationNumber(skip, "skip", 0);
  const isPaged = parsedPage !== undefined || parsedSkip !== undefined;

  const pageSize = isPaged
    ? Math.min(parsedLimit ?? DEFAULT_REVIEW_PAGE_SIZE, MAX_REVIEW_PAGE_SIZE)
    : parsedLimit;
  const offset = isPaged ? parsedSkip ?? (parsedPage - 1) * pageSize : 0;

  const filter = { productId };
  const query = Review.find(filter).sort({ createdAt: -1, _id: -1 });

  if (offset) {
    query.skip(offset);
  }

  if (pageSize) {
    query.limit(pageSize);
  }

  const [reviews, total] = await Promise.all([
    query.lean(),
    Review.countDocuments(filter),
  ]);

  return {
    reviews,
    pagination: {
      total,
      skip: offset,
      limit: pageSize ?? null,
      page: pageSize ? Math.floor(offset / pageSize) + 1 : 1,
      hasMore: offset + reviews.length < total,
    },
  };
};

const getReviewsByOrder = async (orderId) => {
  assertValidObjectId(orderId, "Order ID");
  return Review.findOne({ orderId }).lean();
};

const getRatingSummary = async (productId) => {
  assertValidObjectId(productId, "Product ID");

  const groups = await Review.aggregate([
    { $match: { productId: new mongoose.Types.ObjectId(productId) } },
    { $group: { _id: "$rating", count: { $sum: 1 } } },
  ]);

  // Số đánh giá theo từng mức sao, luôn đủ 5 khóa "1"…"5".
  const ratingBreakdown = { 1: 0, 2: 0, 3: 0, 4: 0, 5: 0 };
  let reviewCount = 0;
  let ratingTotal = 0;

  groups.forEach(({ _id: star, count }) => {
    if (ratingBreakdown[star] === undefined) {
      return;
    }

    ratingBreakdown[star] = count;
    reviewCount += count;
    ratingTotal += star * count;
  });

  return {
    rating: reviewCount ? Math.round((ratingTotal / reviewCount) * 10) / 10 : 0,
    reviewCount,
    ratingBreakdown,
  };
};

// ─── Mutations ────────────────────────────────────────────────────────────────

/**
 * Tạo đánh giá mới cho một đơn hàng.
 * Chỉ áp dụng cho đơn COMPLETED chưa được đánh giá.
 */
const createReview = async ({ orderId, customerId, rating, comment, images = [] }) => {
  assertValidObjectId(orderId, "Order ID");

  // 1. Lấy thông tin đơn hàng và kiểm tra quyền sở hữu
  const order = await Order.findById(orderId).lean();
  if (!order) {
    throw new AppError("Không tìm thấy đơn hàng", 404, "ORDER_NOT_FOUND");
  }

  if (order.customerId?.toString() !== customerId.toString()) {
    throw new AppError("Bạn không có quyền đánh giá đơn hàng này", 403, "FORBIDDEN");
  }

  // 2. Kiểm tra trạng thái đơn hàng (phải là COMPLETED)
  if (order.status !== ORDER_STATUSES.COMPLETED) {
    throw new AppError(
      "Chỉ có thể đánh giá đơn hàng đã hoàn thành",
      400,
      "ORDER_NOT_COMPLETED"
    );
  }

  // 3. Ngăn đánh giá lặp lại
  if (order.isReviewed) {
    throw new AppError(
      "Đơn hàng này đã được đánh giá trước đó",
      400,
      "ALREADY_REVIEWED"
    );
  }

  // 4. Lấy productId đầu tiên trong đơn
  const productId = order.items[0]?.productId;
  if (!productId) {
    throw new AppError("Đơn hàng không có sản phẩm", 400, "NO_PRODUCT");
  }

  const customerName = order.customerName || "Khách hàng";

  // 5. Tạo review và cập nhật đơn hàng (transaction-safe dùng Promise.all)
  const [review] = await Promise.all([
    Review.create({ productId, orderId, customerId, customerName, rating, comment, images }),
    Order.findByIdAndUpdate(orderId, { isReviewed: true }),
  ]);

  return review;
};

/**
 * Cập nhật nội dung đánh giá.
 * Chỉ người đã đánh giá mới được sửa.
 */
const updateReview = async (reviewId, customerId, { rating, comment, images }) => {
  assertValidObjectId(reviewId, "Review ID");

  const review = await Review.findById(reviewId);
  if (!review) {
    throw new AppError("Không tìm thấy đánh giá", 404, "REVIEW_NOT_FOUND");
  }

  if (review.customerId?.toString() !== customerId.toString()) {
    throw new AppError("Bạn không có quyền chỉnh sửa đánh giá này", 403, "FORBIDDEN");
  }

  if (rating !== undefined) review.rating = rating;
  if (comment !== undefined) review.comment = comment;
  if (images !== undefined) review.images = images;

  await review.save();
  return review;
};

/**
 * Xóa đánh giá và reset isReviewed về false cho đơn hàng.
 */
const deleteReview = async (reviewId, customerId) => {
  assertValidObjectId(reviewId, "Review ID");

  const review = await Review.findById(reviewId);
  if (!review) {
    throw new AppError("Không tìm thấy đánh giá", 404, "REVIEW_NOT_FOUND");
  }

  if (review.customerId?.toString() !== customerId.toString()) {
    throw new AppError("Bạn không có quyền xóa đánh giá này", 403, "FORBIDDEN");
  }

  await Promise.all([
    Review.findByIdAndDelete(reviewId),
    Order.findByIdAndUpdate(review.orderId, { isReviewed: false }),
  ]);
};

module.exports = {
  createReview,
  deleteReview,
  getRatingSummary,
  getReviewsByOrder,
  getReviewsByProduct,
  updateReview,
};
