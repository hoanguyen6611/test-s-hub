# Task 1: Form

## 1. Mô tả cách thực hiện

- Tạo các input với các trường dữ liệu như yêu cầu và nút cập nhập
- Sử dụng thư viện React-hook-form và zod để tạo validate cho các trường dữ liệu
- Cách bước thực hiện

-- Truy cập - điền các trường thông tin theo yêu cầu, theo đúng định dạng
-- Nhấn nút cập nhập để kiểm tra đúng định dạng chưa, nếu chưa sẽ hiện ra định dạng chưa đúng, sai như thế nào cập nhập lại, nếu đã đúng định dạng thì hiển thị thông báo thành công và reset lại form về giá trị mặc định

## 2. Cấu trúc dự án

my-report-app/
├── app/
│ └── page.tsx # Trang chính hiện form
│ └── layout.tsx # Layout gốc Next.js
├── public/ # Tài nguyên tĩnh (nếu có)
├── package.json
├── tsconfig.json
└── README.md # Tài liệu hướng dẫn

## 3. Hướng dẫn thực thi

- Clone dự án về
- Thực hiện lệnh yarn install để cài đặt các package và thực hiện cần thiết
- Chạy lệnh yarn run dev để khởi chạy dự án
- Truy cập http://localhost:3000 để xem kết quả
