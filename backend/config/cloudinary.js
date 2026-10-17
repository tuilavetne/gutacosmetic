const cloudinary = require("cloudinary").v2;
const { CloudinaryStorage } = require("multer-storage-cloudinary");
const multer = require("multer");
const AppError = require("../utils/AppError");

// ─── Kết nối Cloudinary bằng biến môi trường ──────────────────────────────────
cloudinary.config({
  cloud_name: process.env.CLOUDINARY_CLOUD_NAME,
  api_key: process.env.CLOUDINARY_API_KEY,
  api_secret: process.env.CLOUDINARY_API_SECRET,
});

// ─── Cấu hình CloudinaryStorage ───────────────────────────────────────────────
const reviewStorage = new CloudinaryStorage({
  cloudinary,
  params: {
    folder: "guta_cosmetic/reviews",
    allowed_formats: ["jpg", "jpeg", "png"],
    transformation: [{ width: 1200, height: 1200, crop: "limit", quality: "auto" }],
  },
});

// ─── Middleware upload – tối đa 5 ảnh, mỗi ảnh ≤ 5 MB ────────────────────────
const upload = multer({
  storage: reviewStorage,
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    const allowed = /jpeg|jpg|png/;
    if (allowed.test(file.mimetype)) {
      cb(null, true);
    } else {
      cb(new Error("Chỉ cho phép định dạng JPG, JPEG hoặc PNG"), false);
    }
  },
});

// ─── Ảnh đại diện – 1 ảnh ≤ 5 MB, cắt vuông 512×512 ưu tiên khuôn mặt ────────
const AVATAR_FOLDER = "guta_cosmetic/avatars";

const avatarUploader = multer({
  storage: new CloudinaryStorage({
    cloudinary,
    params: {
      folder: AVATAR_FOLDER,
      allowed_formats: ["jpg", "jpeg", "png", "webp"],
      transformation: [
        { width: 512, height: 512, crop: "fill", gravity: "face", quality: "auto" },
      ],
    },
  }),
  limits: { fileSize: 5 * 1024 * 1024 },
  fileFilter: (_req, file, cb) => {
    if (/jpeg|jpg|png|webp/.test(file.mimetype)) {
      cb(null, true);
    } else {
      cb(
        new AppError(
          "Avatar must be a JPG, PNG or WEBP image",
          400,
          "INVALID_IMAGE_TYPE"
        ),
        false
      );
    }
  },
}).single("avatar");

// Bọc multer để lỗi (quá dung lượng, sai field...) trả về mã lỗi rõ ràng.
const uploadAvatar = (req, res, next) => {
  avatarUploader(req, res, (error) => {
    if (!error) return next();
    if (error instanceof AppError) return next(error);
    if (error.code === "LIMIT_FILE_SIZE") {
      return next(new AppError("Avatar must be at most 5 MB", 400, "IMAGE_TOO_LARGE"));
    }
    if (error.code === "LIMIT_UNEXPECTED_FILE") {
      return next(new AppError("Only one avatar file is allowed", 400, "AVATAR_REQUIRED"));
    }
    return next(new AppError("Could not upload avatar", 502, "AVATAR_UPLOAD_FAILED"));
  });
};

/// public_id Cloudinary của ảnh đại diện do app upload (null nếu là ảnh khác,
/// ví dụ ảnh Google).
const avatarPublicIdFromUrl = (url) => {
  const match = String(url || "").match(
    new RegExp(`/(${AVATAR_FOLDER}/[^/.]+)\\.[a-z0-9]+$`, "i")
  );
  return match ? match[1] : null;
};

module.exports = { avatarPublicIdFromUrl, cloudinary, upload, uploadAvatar };
