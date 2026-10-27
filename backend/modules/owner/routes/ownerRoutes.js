const express = require("express");
const ownerController = require("../controllers/ownerController");
const protect = require("../../../middlewares/authMiddleware");
const { authorize } = require("../../../middlewares/roleMiddleware");
const { uploadProductImages } = require("../../../config/cloudinary");
const { USER_ROLES } = require("../../../constants/business");

const router = express.Router();

router.use(protect);
router.use(authorize(USER_ROLES.OWNER));

router.get("/dashboard", ownerController.getDashboard);
router.get("/analytics/revenue", ownerController.getRevenueReport);

router.post(
  "/products/images",
  uploadProductImages,
  ownerController.uploadProductImages
);

router
  .route("/products")
  .get(ownerController.getProducts)
  .post(ownerController.createProduct);

router.patch("/products/:productId", ownerController.updateProduct);

router
  .route("/stores")
  .get(ownerController.getStores)
  .post(ownerController.createStore);

router.patch("/stores/:storeId", ownerController.updateStore);

router
  .route("/staff")
  .get(ownerController.getStaff)
  .post(ownerController.createStaff);

router.patch("/staff/:userId", ownerController.updateStaff);

router
  .route("/transfers")
  .get(ownerController.getTransfers)
  .post(ownerController.createTransfer);

router.patch("/transfers/:transferId/cancel", ownerController.cancelTransfer);

// Đề xuất nhập hàng Manager đã chuyển lên: duyệt (tạo phiếu chuyển) / từ chối.
router.post(
  "/restock-requests/:requestId/approve",
  ownerController.approveRestockRequest
);
router.post(
  "/restock-requests/:requestId/reject",
  ownerController.rejectRestockRequest
);

module.exports = router;
