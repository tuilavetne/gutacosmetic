/// Thông điệp tiếng Việt cho mã lỗi của backend.
///
/// Backend trả phần lớn `message` bằng tiếng Anh, nên app hiển thị theo
/// `code`. Danh sách lấy từ các `new AppError(..., code)` trong backend.
String? translateErrorCode(String? code, Object? details) {
  if (code == null) return null;
  if (code == 'OTP_INCORRECT') {
    final remaining = details is Map ? details['attemptsRemaining'] : null;
    return remaining is num
        ? 'Mã OTP không đúng. Bạn còn ${remaining.toInt()} lần thử.'
        : 'Mã OTP không đúng.';
  }
  return _messages[code];
}

const _messages = <String, String>{
  // ---- Tài khoản / đăng nhập ----
  'INVALID_CREDENTIALS': 'Gmail/số điện thoại hoặc mật khẩu không đúng.',
  'ACCOUNT_DISABLED': 'Tài khoản đã bị khóa. Vui lòng liên hệ cửa hàng.',
  'ACCOUNT_DISABLED_PAYMENT_ABUSE':
      'Tài khoản đã bị khóa tự động do có quá nhiều đơn chuyển khoản hết hạn '
      'mà chưa thanh toán. Vui lòng liên hệ cửa hàng.',
  'ACCOUNT_EXISTS': 'Gmail hoặc số điện thoại đã được đăng ký.',
  'EMAIL_EXISTS': 'Gmail đã được đăng ký.',
  'PHONE_EXISTS': 'Số điện thoại đã được đăng ký.',
  'ACCOUNT_NOT_FOUND': 'Không tìm thấy tài khoản với Gmail/số điện thoại này.',
  'EMAIL_NOT_VERIFIED': 'Gmail chưa được xác thực.',
  'UNAUTHORIZED': 'Vui lòng đăng nhập để tiếp tục.',
  'FORBIDDEN': 'Bạn không có quyền thực hiện thao tác này.',
  'INVALID_FULL_NAME': 'Họ tên dài từ 2 đến 80 ký tự.',
  'INVALID_PHONE': 'Số điện thoại Việt Nam không hợp lệ.',
  'INVALID_ADDRESS': 'Địa chỉ dài từ 5 đến 250 ký tự.',
  'WEAK_PASSWORD':
      'Mật khẩu dài 8–72 ký tự, gồm chữ hoa, chữ thường và chữ số.',
  'PASSWORD_MISMATCH': 'Mật khẩu xác nhận không khớp.',
  'CURRENT_PASSWORD_REQUIRED': 'Vui lòng nhập mật khẩu hiện tại.',
  'INVALID_CURRENT_PASSWORD': 'Mật khẩu hiện tại không đúng.',
  'SAME_PASSWORD': 'Mật khẩu mới phải khác mật khẩu hiện tại.',
  'VALIDATION_ERROR': 'Vui lòng điền đầy đủ thông tin bắt buộc.',

  // ---- Ảnh đại diện ----
  'INVALID_IMAGE_TYPE': 'Ảnh đại diện phải là JPG, PNG hoặc WEBP.',
  'IMAGE_TOO_LARGE': 'Ảnh đại diện tối đa 5 MB.',
  'AVATAR_REQUIRED': 'Vui lòng chọn một ảnh.',
  'AVATAR_UPLOAD_FAILED': 'Không tải được ảnh lên. Vui lòng thử lại.',

  // ---- Google ----
  'GOOGLE_TOKEN_REQUIRED': 'Không nhận được thông tin đăng nhập từ Google.',
  'INVALID_GOOGLE_TOKEN': 'Xác thực Google thất bại. Vui lòng thử lại.',
  'GOOGLE_ACCOUNT_CONFLICT':
      'Gmail này đã liên kết với một tài khoản Google khác.',
  'GOOGLE_AUTH_NOT_CONFIGURED': 'Máy chủ chưa cấu hình đăng nhập Google.',

  // ---- OTP / quên mật khẩu ----
  'INVALID_OTP_FORMAT': 'Mã OTP gồm đúng 6 chữ số.',
  'OTP_EXPIRED': 'Mã OTP đã hết hạn. Vui lòng gửi lại mã mới.',
  'OTP_NOT_FOUND': 'Phiên xác thực OTP không tồn tại. Vui lòng gửi lại mã.',
  'OTP_ALREADY_USED': 'Mã OTP đã được sử dụng. Vui lòng gửi lại mã mới.',
  'OTP_ATTEMPTS_EXCEEDED':
      'Bạn đã nhập sai quá 5 lần. Vui lòng gửi lại mã mới.',
  'OTP_RESEND_COOLDOWN': 'Vui lòng chờ 30 giây trước khi gửi lại mã.',
  'OTP_RATE_LIMITED':
      'Bạn đã yêu cầu quá nhiều mã OTP. Vui lòng thử lại sau 1 giờ.',
  'OTP_DELIVERY_FAILED': 'Không gửi được mã OTP qua Gmail. Vui lòng thử lại.',
  'OTP_PROVIDER_NOT_CONFIGURED': 'Máy chủ chưa cấu hình gửi email OTP.',
  'INVALID_RESET_CHALLENGE': 'Phiên đặt lại mật khẩu không hợp lệ.',
  'INVALID_RESET_TOKEN':
      'Phiên đặt lại mật khẩu đã hết hạn. Vui lòng thực hiện lại.',
  'RESET_ALREADY_USED':
      'Phiên đặt lại mật khẩu đã được sử dụng. Vui lòng thực hiện lại.',

  // ---- Chi nhánh ----
  'ACTIVE_STORE_INVALID':
      'Chi nhánh đang làm việc không hợp lệ hoặc đã bị khóa.',
  'STORE_NOT_FOUND': 'Không tìm thấy cửa hàng.',
  'STORE_ID_REQUIRED': 'Vui lòng chọn cửa hàng.',
  'STORE_ACCESS_DENIED': 'Bạn không thể xử lý đơn của chi nhánh khác.',
  'STORE_ASSIGNMENT_REQUIRED': 'Tài khoản chưa được phân công chi nhánh.',
  'STORE_INACTIVE': 'Kho nguồn và chi nhánh đích đều phải đang hoạt động.',

  // ---- Sản phẩm / tồn kho ----
  'PRODUCT_NOT_FOUND': 'Không tìm thấy sản phẩm.',
  'PRODUCT_UNAVAILABLE': 'Một hoặc nhiều sản phẩm đã ngừng bán.',
  'INVALID_PRODUCT_ID': 'Mã sản phẩm không hợp lệ.',
  'INVALID_PAGINATION': 'Tham số phân trang không hợp lệ.',
  'SKU_EXISTS': 'SKU đã tồn tại.',
  'INSUFFICIENT_STOCK':
      'Một hoặc nhiều sản phẩm không đủ số lượng tại chi nhánh đã chọn.',
  'INVENTORY_NOT_FOUND': 'Không tìm thấy tồn kho của sản phẩm.',
  'INVENTORY_UPDATE_FAILED': 'Không cập nhật được tồn kho. Vui lòng tải lại.',
  'INVALID_INVENTORY_ITEM': 'Mỗi sản phẩm cần có số lượng nguyên dương.',
  'ITEMS_REQUIRED': 'Cần ít nhất một sản phẩm.',
  'INVALID_ADJUSTMENT': 'Thiếu cửa hàng hoặc sản phẩm.',
  'INVALID_ADJUSTMENT_QUANTITY': 'Số lượng trừ kho không hợp lệ.',
  'INVALID_ADJUSTMENT_TYPE': 'Loại trừ kho không hợp lệ.',
  'OWNER_BRANCH_STOCK_MUTATION_FORBIDDEN':
      'Owner chỉ được nhập/trừ kho trực tiếp tại kho tổng. '
      'Hãy dùng phiếu điều chuyển để đưa hàng xuống chi nhánh.',
  'INVALID_REQUESTED_QUANTITY': 'Số lượng đề xuất phải lớn hơn 0.',
  'INVALID_RECEIVED_QUANTITY': 'Số lượng nhận không hợp lệ.',
  'RECEIVED_QUANTITY_EXCEEDS_REQUEST':
      'Số lượng nhận không được vượt số lượng đề xuất.',
  'RECEIVED_QUANTITY_LIMIT_EXCEEDED': 'Mỗi lần nhập kho tối đa 1000 sản phẩm.',
  'INVALID_REQUEST_STATUS': 'Trạng thái yêu cầu không hợp lệ.',
  'REQUEST_CLOSED': 'Yêu cầu bổ sung này đã được xử lý.',
  'REQUEST_NOT_FOUND': 'Không tìm thấy yêu cầu bổ sung.',
  'INVALID_TRANSFER_SOURCE': 'Phiếu điều chuyển phải xuất từ kho tổng.',
  'INVALID_TRANSFER_DESTINATION': 'Phiếu điều chuyển chỉ chuyển đến chi nhánh.',
  'INVALID_TRANSFER_STATUS': 'Trạng thái phiếu điều chuyển không hợp lệ.',
  'TRANSFER_CLOSED': 'Chỉ hủy được phiếu đang chờ nhận.',
  'TRANSFER_NOT_FOUND': 'Không tìm thấy phiếu điều chuyển.',
  'RETURN_REQUEST_NOT_FOUND': 'Không tìm thấy yêu cầu trả hàng lỗi.',
  'RETURN_REQUEST_CLOSED': 'Yêu cầu trả hàng lỗi đã được xử lý.',
  'RETURN_REQUEST_QUANTITY_EXCEEDS_STOCK': 'Số lượng trả vượt tồn khả dụng.',
  'INVALID_RETURN_REQUEST_QUANTITY': 'Số lượng trả không hợp lệ.',
  'INVALID_RETURN_REQUEST_REASON': 'Lý do trả hàng không hợp lệ.',
  'INVALID_RETURN_REQUEST_STATUS': 'Trạng thái yêu cầu trả hàng không hợp lệ.',
  'INVALID_RETURN_REQUEST_REVIEW_STATUS': 'Kết quả duyệt không hợp lệ.',

  // ---- Đơn hàng ----
  'ORDER_NOT_FOUND': 'Không tìm thấy đơn hàng.',
  'INVALID_ORDER_ID': 'Mã đơn hàng không hợp lệ.',
  'INVALID_ORDER_STATE': 'Trạng thái đơn hàng không cho phép thao tác này.',
  'INVALID_CANCELLATION_REASON':
      'Vui lòng nhập lý do hủy đơn chi tiết hơn (ít nhất 15 ký tự).',
  'CANCELLATION_REASON_TOO_LONG': 'Lý do hủy đơn tối đa 255 ký tự.',
  'INVALID_ORDER_TRANSITION': 'Không thể chuyển đơn sang trạng thái này.',
  'INVALID_ORDER_CHANNEL': 'Chỉ đơn online mới thanh toán qua PayOS.',
  'INVALID_FULFILLMENT_TYPE':
      'Đơn online phải chọn giao hàng hoặc nhận tại cửa hàng.',
  'INVALID_PAYMENT_METHOD': 'Phương thức thanh toán không hợp lệ.',
  'INVALID_RESERVATION': 'Đơn hàng chưa được giữ hàng.',
  'SHIPPING_ADDRESS_REQUIRED': 'Đơn giao hàng cần có địa chỉ nhận.',
  'PICKUP_STORE_REQUIRED': 'Vui lòng chọn cửa hàng nhận hàng.',
  'PAYMENT_REQUIRED':
      'Đơn chuyển khoản phải được thanh toán trước khi hoàn tất.',
  'ORDER_ALREADY_PAID': 'Đơn hàng đã được thanh toán.',
  'TOO_MANY_UNPAID_BANK_TRANSFER_ORDERS':
      'Bạn có quá nhiều đơn chuyển khoản chưa thanh toán. '
      'Vui lòng thanh toán hoặc chờ mã QR cũ hết hạn.',

  // ---- Thanh toán PayOS ----
  'PAYMENT_QR_EXPIRED': 'Mã QR thanh toán đã hết hạn. Vui lòng đặt đơn mới.',
  'PAYOS_NOT_CONFIGURED': 'Máy chủ chưa cấu hình PayOS.',
  'PAYOS_CREATE_LINK_FAILED': 'Không tạo được mã QR PayOS. Vui lòng thử lại.',
  'PAYOS_PAYMENT_NOT_CREATED': 'Đơn hàng chưa có yêu cầu thanh toán PayOS.',

  // ---- Khách hàng / điểm ----
  'CUSTOMER_NOT_FOUND': 'Không tìm thấy khách hàng.',
  'INSUFFICIENT_POINTS': 'Khách hàng không đủ điểm.',
  'INVALID_POINTS_USED': 'Số điểm phải là số dương.',
  'REWARD_NAME_REQUIRED': 'Vui lòng nhập tên quà.',

  // ---- Đánh giá ----
  'ALREADY_REVIEWED': 'Đơn hàng này đã được đánh giá.',
  'ORDER_NOT_COMPLETED': 'Chỉ đánh giá được đơn đã hoàn tất.',
  'REVIEW_NOT_FOUND': 'Không tìm thấy đánh giá.',
  'INVALID_RATING': 'Số sao phải từ 1 đến 5.',
  'MISSING_FIELDS': 'Vui lòng chọn số sao và nhập bình luận.',
  'NO_PRODUCT': 'Đơn hàng không có sản phẩm.',
  'INVALID_ID': 'Mã đơn hàng hoặc đánh giá không hợp lệ.',
  // Lỗi của multer khi upload ảnh đánh giá.
  'LIMIT_FILE_SIZE': 'Mỗi ảnh tối đa 5 MB.',
  'LIMIT_UNEXPECTED_FILE': 'Mỗi đánh giá tối đa 5 ảnh.',

  // ---- Owner ----
  'STAFF_NOT_FOUND': 'Không tìm thấy nhân viên.',
  'SELF_DISABLE_FORBIDDEN': 'Bạn không thể tự khóa tài khoản của mình.',
  'SELF_ROLE_CHANGE_FORBIDDEN': 'Bạn không thể tự bỏ quyền Owner của mình.',
};
