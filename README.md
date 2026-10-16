# GUTA Cosmetic POS

Ứng dụng quản lý bán hàng mỹ phẩm đa cửa hàng, gồm 4 vai trò: **Khách hàng**, **Nhân viên bán hàng**, **Quản lý** và **Chủ cửa hàng**.

## Cấu trúc

```
gutacosmetic/
├── app/       # Ứng dụng Flutter (Riverpod, GoRouter, Dio)
└── backend/   # API Node.js/Express + MongoDB
```

## Yêu cầu

- Flutter SDK (Dart ≥ 3.13)
- Node.js
- MongoDB chạy tại `127.0.0.1:27017`

## Chạy backend

```powershell
cd backend
npm install
copy .env.example .env      # rồi điền các giá trị cần thiết
npm run seed:demo-users     # tạo tài khoản demo (chỉ cần chạy lần đầu)
npm run seed:demo-stores
npm run dev                 # API chạy tại http://localhost:5000/api
```

## Chạy app

```powershell
cd app
flutter pub get
flutter run -d chrome --web-port 8080
```

Không truyền `API_BASE_URL` thì app tự gọi `http://localhost:5000/api` (Chrome) hoặc `http://10.0.2.2:5000/api` (Android emulator). Chạy trên điện thoại thật thì truyền IP máy chạy backend:

```powershell
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:5000/api
```

> **Lưu ý:** nếu đường dẫn thư mục có dấu tiếng Việt (vd. `KÌ 8`), `build_runner` và một số lệnh Flutter sẽ lỗi. Tạo đường dẫn tắt không dấu rồi chạy từ đó:
>
> ```powershell
> New-Item -ItemType Junction -Path E:\guta -Target "<đường dẫn tới>\gutacosmetic\app"
> cd E:\guta
> ```

## Tài khoản demo

Sau khi chạy `npm run seed:demo-users`:

| Vai trò | Email |
|---|---|
| Chủ cửa hàng | `owner.guta.demo@gmail.com` |
| Quản lý | `manager.guta.demo@gmail.com` |
| Nhân viên bán hàng | `sales.guta.demo@gmail.com` |
| Khách hàng | `customer.guta.demo@gmail.com` |

Mật khẩu được in ra khi chạy lệnh seed.
