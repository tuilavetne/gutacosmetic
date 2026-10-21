const { USER_ROLES } = require("../constants/business");

// Trường nội bộ của sản phẩm không trả cho khách hàng (giá vốn).
const CUSTOMER_HIDDEN_PRODUCT_FIELDS = "-costPrice";

/**
 * Projection mongoose cho Product theo người gọi API:
 * CUSTOMER không thấy giá vốn, nhân viên thấy đủ.
 */
const productProjectionFor = (user) =>
  user?.role === USER_ROLES.CUSTOMER ? CUSTOMER_HIDDEN_PRODUCT_FIELDS : "";

module.exports = {
  CUSTOMER_HIDDEN_PRODUCT_FIELDS,
  productProjectionFor,
};
