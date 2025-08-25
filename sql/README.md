# Task 3: SQL

## Bảng & quan hệ chính

- stations: thông tin trạm (code, tên, địa chỉ, toạ độ, trạng thái…).

- products: danh mục hàng hoá (xăng A95, E5, dầu DO…).

- pumps: trụ bơm, mỗi trụ thuộc một trạm và một loại hàng hoá.

- sales: giao dịch bán, gắn với pump và product, có thời gian, số lít, đơn giá, thành tiền (cột sinh tự động), phương thức thanh toán…

### Chỉ mục tối ưu các truy vấn báo cáo:

- sales (tx_time), (pump_id, tx_time), (product_id, tx_time)

- pumps (station_id), products (name), stations (province, district)

### Ràng buộc toàn vẹn:

- PK/UK đầy đủ; pumps unique (station_id, code); check quantity > 0, price ≥ 0.
