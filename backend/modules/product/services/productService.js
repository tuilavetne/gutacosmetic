const mongoose = require("mongoose");
const Product = require("../../../models/Product");
const AppError = require("../../../utils/AppError");

const UNIVERSAL_SKIN_TYPE = "Da thường/Mọi loại da";

const escapeRegExp = (value) => value.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");

/**
 * @param {object} filters
 * @param {string} [projection] - ví dụ "-costPrice" để ẩn giá vốn với khách.
 */
const getProducts = ({ search, skinType, category } = {}, projection = "") => {
  const query = { isActive: true };

  if (search) {
    query.name = { $regex: escapeRegExp(search), $options: "i" };
  }

  if (skinType) {
    query.skinTypes = { $in: [skinType, UNIVERSAL_SKIN_TYPE] };
  }

  if (category) {
    query.category = category;
  }

  return Product.find(query).select(projection).sort({ createdAt: -1 }).lean();
};

const getProductById = async (productId, projection = "") => {
  if (!mongoose.isValidObjectId(productId)) {
    throw new AppError("Product ID is invalid", 400, "INVALID_PRODUCT_ID");
  }

  const product = await Product.findOne({
    _id: productId,
    isActive: true,
  })
    .select(projection)
    .lean();

  if (!product) {
    throw new AppError("Product was not found", 404, "PRODUCT_NOT_FOUND");
  }

  return product;
};

module.exports = {
  getProductById,
  getProducts,
};
