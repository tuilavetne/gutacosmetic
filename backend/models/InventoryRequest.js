const mongoose = require("mongoose");

const inventoryRequestSchema = new mongoose.Schema(
  {
    storeId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Store",
      required: true,
    },
    productId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "Product",
      required: true,
    },
    requestedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      required: true,
    },
    handledBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
    acknowledgedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
    currentAvailableStock: {
      type: Number,
      required: true,
      min: 0,
    },
    requestedQuantity: {
      type: Number,
      required: true,
      min: 1,
    },
    reason: {
      type: String,
      required: true,
      trim: true,
      maxlength: 300,
    },
    // OPEN: Sales vừa đề xuất, chờ Manager xem.
    // FORWARDED: Manager đã chuyển lên Owner, chờ duyệt.
    // IN_TRANSIT: Owner duyệt và tạo phiếu chuyển hàng, chờ chi nhánh nhận.
    // RESOLVED: Manager xác nhận đã nhận hàng chuyển đến.
    // CANCELLED: Manager hủy hoặc Owner từ chối (có lý do).
    status: {
      type: String,
      enum: ["OPEN", "FORWARDED", "IN_TRANSIT", "RESOLVED", "CANCELLED"],
      default: "OPEN",
    },
    managerNote: {
      type: String,
      trim: true,
      maxlength: 300,
      default: "",
    },
    resolvedAt: {
      type: Date,
      default: null,
    },
    acknowledgedAt: {
      type: Date,
      default: null,
    },
    // Số lượng Manager chuyển lên Owner (có thể khác số Sales đề xuất).
    forwardedQuantity: {
      type: Number,
      min: 1,
      default: null,
    },
    forwardedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
    forwardedAt: {
      type: Date,
      default: null,
    },
    approvedQuantity: {
      type: Number,
      min: 1,
      default: null,
    },
    approvedBy: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "User",
      default: null,
    },
    approvedAt: {
      type: Date,
      default: null,
    },
    ownerNote: {
      type: String,
      trim: true,
      maxlength: 300,
      default: "",
    },
    transferId: {
      type: mongoose.Schema.Types.ObjectId,
      ref: "StockTransfer",
      default: null,
    },
  },
  { timestamps: true }
);

inventoryRequestSchema.index({ storeId: 1, status: 1, createdAt: -1 });
inventoryRequestSchema.index({ productId: 1, status: 1 });

module.exports = mongoose.model("InventoryRequest", inventoryRequestSchema);
