const mongoose = require("mongoose");
const User = require("../../../models/User");
const Order = require("../../../models/Order");
const RewardRedemption = require("../../../models/RewardRedemption");
const AppError = require("../../../utils/AppError");
const { runInTransaction } = require("../../stock/services/transactionService");
const {
  avatarPublicIdFromUrl,
  cloudinary,
} = require("../../../config/cloudinary");
const {
  USER_ROLES,
} = require("../../../constants/business");
const {
  normalizePhone,
  validateAddress,
  validateFullName,
} = require("../../../utils/authValidation");

const searchCustomers = async (query = "") => {
  const keyword = String(query).trim();

  if (keyword.length < 2) {
    return [];
  }

  const escapedKeyword = keyword.replace(/[.*+?^${}()|[\]\\]/g, "\\$&");
  const pattern = new RegExp(escapedKeyword, "i");

  const registeredCustomers = await User.find({
    role: USER_ROLES.CUSTOMER,
    isActive: true,
    $or: [{ fullName: pattern }, { email: pattern }, { phone: pattern }],
  })
    .select("fullName email phone points")
    .sort({ updatedAt: -1 })
    .limit(8)
    .lean();

  const registeredPhones = new Set(
    registeredCustomers
      .map((customer) => customer.phone)
      .filter(Boolean)
      .map(String)
  );

  const guestOrders = await Order.aggregate([
    {
      $match: {
        customerId: null,
        customerPhone: { $regex: pattern },
      },
    },
    { $sort: { updatedAt: -1 } },
    {
      $group: {
        _id: "$customerPhone",
        fullName: { $first: "$customerName" },
        phone: { $first: "$customerPhone" },
        lastOrderAt: { $first: "$updatedAt" },
        orderCount: { $sum: 1 },
      },
    },
    { $limit: 8 },
  ]);

  const guestCustomers = guestOrders
    .filter((guest) => guest.phone && !registeredPhones.has(String(guest.phone)))
    .map((guest) => ({
      _id: `guest:${guest.phone}`,
      email: "",
      fullName: guest.fullName || "Khách vãng lai",
      isGuest: true,
      lastOrderAt: guest.lastOrderAt,
      orderCount: guest.orderCount,
      phone: guest.phone,
      points: 0,
    }));

  return [...registeredCustomers, ...guestCustomers].slice(0, 8);
};

const checkPhoneAvailable = async (userId, rawPhone) => {
  const phone = normalizePhone(rawPhone);
  const existingUser = await User.exists({ phone, _id: { $ne: userId } });

  return { available: !existingUser, phone };
};

const findUserOrThrow = async (userId) => {
  const user = await User.findById(userId);

  if (!user) {
    throw new AppError("Account was not found", 404, "ACCOUNT_NOT_FOUND");
  }

  return user;
};

// Xóa ảnh đại diện cũ trên Cloudinary (chỉ ảnh do app upload); lỗi thì bỏ qua.
const destroyOldAvatar = async (url) => {
  const publicId = avatarPublicIdFromUrl(url);
  if (!publicId) return;

  try {
    await cloudinary.uploader.destroy(publicId);
  } catch (error) {
    console.warn(`Could not delete old avatar ${publicId}: ${error.message}`);
  }
};

const updateAvatar = async (userId, file) => {
  if (!file || !file.path) {
    throw new AppError("Avatar image is required", 400, "AVATAR_REQUIRED");
  }

  const user = await findUserOrThrow(userId);
  const oldAvatarUrl = user.avatarUrl;
  user.avatarUrl = file.path;
  await user.save();
  await destroyOldAvatar(oldAvatarUrl);

  return user.toJSON();
};

const removeAvatar = async (userId) => {
  const user = await findUserOrThrow(userId);
  const oldAvatarUrl = user.avatarUrl;
  user.avatarUrl = "";
  await user.save();
  await destroyOldAvatar(oldAvatarUrl);

  return user.toJSON();
};

const updateProfile = async (userId, payload) => {
  const user = await User.findById(userId);

  if (!user) {
    throw new AppError("Account was not found", 404, "ACCOUNT_NOT_FOUND");
  }

  if (payload.fullName !== undefined) {
    user.fullName = validateFullName(payload.fullName);
  }

  if (payload.address !== undefined) {
    user.address = validateAddress(payload.address);
  }

  if (payload.phone !== undefined) {
    const phone = normalizePhone(payload.phone);
    const existingUser = await User.findOne({
      phone,
      _id: { $ne: user._id },
    }).lean();

    if (existingUser) {
      throw new AppError(
        "Phone number is already registered",
        409,
        "PHONE_EXISTS"
      );
    }

    user.phone = phone;
  }

  await user.save();

  return user.toJSON();
};

const REWARD_NAME_MAX_LENGTH = 120;
const REDEMPTION_NOTE_MAX_LENGTH = 300;

// Manager đổi quà cho khách tại quầy: trừ điểm và lưu lịch sử. Trừ điểm bằng
// điều kiện `points >= pointsUsed` trong cùng một lệnh nên hai thu ngân đổi
// cùng lúc không làm điểm âm.
const redeemCustomerPoints = async ({ customerId, manager, note, points, rewardName }) => {
  const pointsUsed = Number(points);
  const normalizedRewardName = String(rewardName || "").trim();
  const normalizedNote = String(note || "").trim();

  if (!Number.isInteger(pointsUsed) || pointsUsed <= 0) {
    throw new AppError(
      "Points used must be a positive number",
      400,
      "INVALID_POINTS_USED"
    );
  }

  if (!normalizedRewardName) {
    throw new AppError(
      "Reward name is required",
      400,
      "REWARD_NAME_REQUIRED"
    );
  }

  if (
    normalizedRewardName.length > REWARD_NAME_MAX_LENGTH ||
    normalizedNote.length > REDEMPTION_NOTE_MAX_LENGTH
  ) {
    throw new AppError(
      "Reward name or note is too long",
      400,
      "REWARD_TEXT_TOO_LONG"
    );
  }

  if (!manager.storeId) {
    throw new AppError(
      "Manager account is not assigned to a store",
      403,
      "STORE_ASSIGNMENT_REQUIRED"
    );
  }

  if (!mongoose.isValidObjectId(customerId)) {
    throw new AppError("Customer was not found", 404, "CUSTOMER_NOT_FOUND");
  }

  return runInTransaction(async (session) => {
    const customerFilter = {
      _id: customerId,
      role: USER_ROLES.CUSTOMER,
      isActive: true,
    };
    const customer = await User.findOneAndUpdate(
      { ...customerFilter, points: { $gte: pointsUsed } },
      { $inc: { points: -pointsUsed } },
      { new: true, session }
    );

    if (!customer) {
      const exists = await User.exists(customerFilter).session(session || null);
      throw exists
        ? new AppError(
            "Customer does not have enough points",
            409,
            "INSUFFICIENT_POINTS"
          )
        : new AppError("Customer was not found", 404, "CUSTOMER_NOT_FOUND");
    }

    const [redemption] = await RewardRedemption.create(
      [
        {
          customerId: customer._id,
          storeId: manager.storeId,
          redeemedBy: manager._id,
          rewardName: normalizedRewardName,
          pointsUsed,
          note: normalizedNote,
        },
      ],
      { session }
    );

    return {
      customer: customer.toJSON(),
      redemption,
    };
  });
};

// Lịch sử đổi quà: theo khách (mọi chi nhánh) khi có `customerId`, ngược lại
// là các lần đổi quà tại chi nhánh đang làm.
const getRedemptions = async ({ customerId, limit, manager }) => {
  const parsedLimit = Number.parseInt(limit, 10);
  const max =
    Number.isInteger(parsedLimit) && parsedLimit > 0
      ? Math.min(parsedLimit, 200)
      : 50;
  let query;

  if (customerId) {
    if (!mongoose.isValidObjectId(customerId)) {
      throw new AppError("Customer was not found", 404, "CUSTOMER_NOT_FOUND");
    }
    query = { customerId };
  } else {
    if (!manager.storeId) {
      throw new AppError(
        "Manager account is not assigned to a store",
        403,
        "STORE_ASSIGNMENT_REQUIRED"
      );
    }
    query = { storeId: manager.storeId };
  }

  return RewardRedemption.find(query)
    .populate("customerId", "fullName phone email points role")
    .populate("storeId", "name")
    .populate("redeemedBy", "fullName role")
    .sort({ createdAt: -1 })
    .limit(max)
    .lean();
};

module.exports = {
  checkPhoneAvailable,
  getRedemptions,
  redeemCustomerPoints,
  removeAvatar,
  updateAvatar,
  searchCustomers,
  updateProfile,
};
