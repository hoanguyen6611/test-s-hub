# Task 1: Data Report

## 1. Mô tả cách thực hiện

- Cho người dùng upload file excel lên - chỉ nhận file với định dạng .xlsx và .xls
- Xử lý chuẩn hóa dữ liệu và xác định đúng header
- Lọc dữ liệu trong khoảng thời gian đã chọn
- Tính và thực hiện hiển thị kết quả
- Cách thực hiện:

* Upload file excel chứa dữ liệu bán hàng
* Chọn khung thời gian cần tính
* Nhấn Tính Tổng và chờ kết quả

## 2. Cấu trúc dự án

my-report-app/
├── app/
│ └── page.tsx # Trang báo cáo chính
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
