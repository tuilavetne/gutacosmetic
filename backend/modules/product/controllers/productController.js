const productService = require("../services/productService");
const reviewService = require("../../review/services/reviewService");
const { productProjectionFor } = require("../../../utils/productProjection");

const getProducts = async (req, res, next) => {
  try {
    const { search, skinType, category } = req.query;
    const products = await productService.getProducts(
      {
        search,
        skinType,
        category,
      },
      productProjectionFor(req.user)
    );
    res.json({ products });
  } catch (error) {
    next(error);
  }
};

const getProductDetail = async (req, res, next) => {
  try {
    const product = await productService.getProductById(
      req.params.id,
      productProjectionFor(req.user)
    );
    const ratingSummary = await reviewService.getRatingSummary(product._id);
    res.json({ product: { ...product, ...ratingSummary } });
  } catch (error) {
    next(error);
  }
};

module.exports = {
  getProductDetail,
  getProducts,
};
