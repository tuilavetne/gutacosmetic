const express = require("express");
const userController = require("../controllers/customerController");
const protect = require("../../../middlewares/authMiddleware");
const { authorize } = require("../../../middlewares/roleMiddleware");
const { USER_ROLES } = require("../../../constants/business");
const { uploadAvatar } = require("../../../config/cloudinary");

const router = express.Router();

router.use(protect);

router.get(
  "/search",
  authorize(USER_ROLES.SALES, USER_ROLES.MANAGER),
  userController.searchCustomers
);
router.post(
  "/:customerId/redeem-points",
  authorize(USER_ROLES.MANAGER),
  userController.redeemCustomerPoints
);
router.put("/profile", userController.updateProfile);
router.get("/phone-available", userController.checkPhoneAvailable);
router.put("/profile/avatar", uploadAvatar, userController.updateAvatar);
router.delete("/profile/avatar", userController.removeAvatar);

module.exports = router;
