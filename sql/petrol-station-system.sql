-- =============================
-- SCHEMA: Petrol Station System
-- =============================

-- Drop in dependency order (for repeatable runs)
DROP TABLE IF EXISTS sales CASCADE;
DROP TABLE IF EXISTS pumps CASCADE;
DROP TABLE IF EXISTS products CASCADE;
DROP TABLE IF EXISTS stations CASCADE;
-- Xóa các bảng nếu trong trường hợp đã tồn tại - IF EXISTS để tránh lỗi trong trường hợp bảng không có tồn tại
-- CASCADE dùng để khi xóa 1 bảng nếu có đối tượng phụ thuộc thì vẫn cho phép xóa

-- ---------
-- Stations
-- ---------
CREATE TABLE stations (
    station_id       BIGSERIAL PRIMARY KEY,
    code             VARCHAR(20) UNIQUE NOT NULL,        -- e.g., STN001
    name             VARCHAR(200) NOT NULL,
    address_line     VARCHAR(300),
    ward             VARCHAR(120),
    district         VARCHAR(120),
    province         VARCHAR(120),
    country          VARCHAR(80) DEFAULT 'Vietnam' NOT NULL,
    latitude         DECIMAL(9,6),
    longitude        DECIMAL(9,6),
    status           VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','inactive','maintenance')),
    opened_at        DATE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);
--Tạo chỉ mục index - giúp tăng tốc độ khi truy vấn tìm kiếm tên trạm (station)
CREATE INDEX idx_stations_name ON stations (name);
--Tương tự giúp tăng tốc độ khi tìm kiếm trạm theo tỉnh thành, quận huyện
CREATE INDEX idx_stations_province ON stations (province, district);

-- ---------
-- Products
-- ---------
CREATE TABLE products (
    product_id       BIGSERIAL PRIMARY KEY,
    sku              VARCHAR(30) UNIQUE NOT NULL,        -- e.g., XANG_A95, XANG_E5, DAU_DO
    name             VARCHAR(120) NOT NULL,              -- Human-readable (A95, E5 RON92, DO, ...)
    unit             VARCHAR(10)  NOT NULL DEFAULT 'L',  -- liters
    active           BOOLEAN NOT NULL DEFAULT TRUE,
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_products_name ON products (name);

-- ------
-- Pumps
-- ------
CREATE TABLE pumps (
    pump_id          BIGSERIAL PRIMARY KEY,
    station_id       BIGINT NOT NULL REFERENCES stations(station_id) ON DELETE CASCADE,
    code             VARCHAR(30) NOT NULL,               -- e.g., P01, P02
    product_id       BIGINT NOT NULL REFERENCES products(product_id), -- each pump dispenses ONE product
    serial_no        VARCHAR(60),
    installed_at     DATE,
    status           VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active','inactive','maintenance')),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    UNIQUE (station_id, code)                             -- no duplicate pump codes inside a station
);
-- ON DELETE CASCADE - trường hợp bản ghi ở stations bị xóa thì những bản ghi liên quan ở pumps cũng bị xóa

CREATE INDEX idx_pumps_station ON pumps (station_id);
CREATE INDEX idx_pumps_product ON pumps (product_id);

-- -----
-- Sales
-- -----
CREATE TABLE sales (
    sale_id          BIGSERIAL PRIMARY KEY,
    pump_id          BIGINT NOT NULL REFERENCES pumps(pump_id) ON DELETE RESTRICT,
    product_id       BIGINT NOT NULL REFERENCES products(product_id),
    tx_time          TIMESTAMPTZ NOT NULL,               -- local time with offset
    quantity_liters  NUMERIC(12,3) NOT NULL CHECK (quantity_liters > 0),
    unit_price_vnd   NUMERIC(14,2) NOT NULL CHECK (unit_price_vnd >= 0),
    amount_vnd       NUMERIC(16,2) GENERATED ALWAYS AS (quantity_liters * unit_price_vnd) STORED,
    payment_method   VARCHAR(20) NOT NULL DEFAULT 'cash' CHECK (payment_method IN ('cash','card','transfer','e-wallet','other')),
    vehicle_plate    VARCHAR(20), -- lisence plate
    cashier_note     VARCHAR(400),
    created_at       TIMESTAMPTZ NOT NULL DEFAULT NOW(),
);

-- Commonly-used indexes for reporting
CREATE INDEX idx_sales_tx_time ON sales (tx_time);
CREATE INDEX idx_sales_pump_time ON sales (pump_id, tx_time);
CREATE INDEX idx_sales_product_time ON sales (product_id, tx_time);


-- =======================================
-- Sample dimension data (safe to remove):
-- =======================================
INSERT INTO products (sku, name) VALUES
('XANG_A95', 'Xăng RON95'),
('XANG_E5',  'Xăng E5 RON92'),
('DAU_DO',   'Dầu DO');

INSERT INTO stations (code, name, province, district) VALUES
('STN001','Cửa hàng Xăng Dầu 1','Hồ Chí Minh','Quận 1'),
('STN002','Cửa hàng Xăng Dầu 2','Hà Nội','Cầu Giấy');

INSERT INTO pumps (station_id, code, product_id) VALUES
(1,'P01', 1),
(1,'P02', 2),
(2,'P01', 3);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (1, 3, 3, '2025-08-04 01:10:00', 42.419, 21000, 'e-wallet', '92A-52454', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (2, 1, 1, '2025-08-10 21:58:00', 42.446, 25000, 'transfer', '67A-79270', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (3, 2, 2, '2025-08-11 02:07:00', 46.178, 23000, 'transfer', '75A-18913', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (4, 3, 3, '2025-08-12 23:03:00', 39.548, 21000, 'e-wallet', '55A-78684', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (5, 2, 2, '2025-08-09 04:05:00', 33.982, 23000, 'transfer', '87A-42716', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (6, 2, 2, '2025-08-02 18:42:00', 39.249, 23000, 'transfer', '87A-95411', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (7, 2, 2, '2025-08-17 19:48:00', 20.085, 23000, 'card', '87A-71178', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (8, 1, 1, '2025-08-14 02:03:00', 34.062, 25000, 'e-wallet', '26A-96722', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (9, 1, 1, '2025-08-04 07:06:00', 16.083, 25000, 'card', '96A-91835', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (10, 3, 3, '2025-08-05 19:47:00', 21.658, 21000, 'e-wallet', '58A-80270', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (11, 2, 2, '2025-08-06 09:49:00', 39.217, 23000, 'transfer', '34A-18394', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (12, 1, 1, '2025-08-14 22:44:00', 6.661, 25000, 'cash', '33A-44559', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (13, 1, 1, '2025-08-10 02:14:00', 6.848, 25000, 'cash', '20A-31041', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (14, 3, 3, '2025-08-01 07:59:00', 10.159, 21000, 'cash', '39A-27463', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (15, 2, 2, '2025-08-18 03:29:00', 19.919, 23000, 'card', '49A-23647', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (16, 2, 2, '2025-08-17 16:54:00', 15.656, 23000, 'e-wallet', '67A-51887', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (17, 3, 3, '2025-08-11 20:19:00', 33.395, 21000, 'cash', '94A-13221', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (18, 2, 2, '2025-08-07 02:39:00', 16.443, 23000, 'e-wallet', '13A-91642', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (19, 1, 1, '2025-08-15 08:53:00', 11.269, 25000, 'e-wallet', '53A-27727', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (20, 1, 1, '2025-08-20 19:57:00', 8.487, 25000, 'cash', '43A-61647', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (21, 1, 1, '2025-08-05 01:55:00', 38.777, 25000, 'card', '39A-51265', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (22, 3, 3, '2025-08-14 09:20:00', 15.33, 21000, 'e-wallet', '84A-99830', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (23, 2, 2, '2025-08-13 09:37:00', 31.198, 23000, 'e-wallet', '11A-37656', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (24, 1, 1, '2025-08-13 19:01:00', 35.763, 25000, 'transfer', '72A-32367', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (25, 2, 2, '2025-08-01 13:23:00', 14.94, 23000, 'card', '29A-53575', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (26, 3, 3, '2025-08-07 07:19:00', 8.994, 21000, 'transfer', '40A-71370', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (27, 3, 3, '2025-08-18 19:54:00', 17.046, 21000, 'card', '92A-94436', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (28, 2, 2, '2025-08-20 08:36:00', 33.826, 23000, 'transfer', '55A-21947', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (29, 1, 1, '2025-08-11 07:10:00', 18.616, 25000, 'transfer', '75A-94540', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (30, 2, 2, '2025-08-05 23:59:00', 48.396, 23000, 'cash', '32A-16899', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (31, 2, 2, '2025-08-12 19:20:00', 37.696, 23000, 'e-wallet', '79A-90519', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (32, 2, 2, '2025-08-05 18:30:00', 24.043, 23000, 'transfer', '31A-67292', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (33, 1, 1, '2025-08-16 22:49:00', 41.874, 25000, 'e-wallet', '44A-20493', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (34, 1, 1, '2025-08-11 09:47:00', 42.922, 25000, 'e-wallet', '83A-11495', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (35, 3, 3, '2025-08-20 00:14:00', 19.794, 21000, 'e-wallet', '23A-46857', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (36, 2, 2, '2025-08-01 10:46:00', 8.043, 23000, 'e-wallet', '51A-33877', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (37, 2, 2, '2025-08-18 18:51:00', 9.136, 23000, 'card', '38A-44417', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (38, 1, 1, '2025-08-09 04:01:00', 32.112, 25000, 'card', '21A-27286', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (39, 1, 1, '2025-08-01 16:24:00', 17.525, 25000, 'transfer', '38A-22871', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (40, 2, 2, '2025-08-15 17:23:00', 38.926, 23000, 'card', '26A-31462', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (41, 3, 3, '2025-08-20 16:56:00', 27.957, 21000, 'e-wallet', '59A-99705', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (42, 2, 2, '2025-08-17 00:34:00', 33.643, 23000, 'e-wallet', '79A-96442', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (43, 1, 1, '2025-08-11 06:56:00', 8.171, 25000, 'transfer', '38A-20318', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (44, 2, 2, '2025-08-03 00:54:00', 5.234, 23000, 'cash', '69A-51257', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (45, 3, 3, '2025-08-06 13:44:00', 42.578, 21000, 'transfer', '86A-84646', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (46, 2, 2, '2025-08-11 13:36:00', 46.299, 23000, 'cash', '32A-92408', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (47, 3, 3, '2025-08-05 05:51:00', 9.609, 21000, 'cash', '49A-68658', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (48, 1, 1, '2025-08-10 13:29:00', 45.187, 25000, 'card', '24A-34295', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (49, 3, 3, '2025-08-06 18:49:00', 45.253, 21000, 'card', '75A-92414', NULL);
INSERT INTO sales (sale_id, pump_id, product_id, tx_time, quantity_liters, unit_price_vnd, payment_method, vehicle_plate, cashier_note) VALUES (50, 1, 1, '2025-08-06 11:49:00', 15.251, 25000, 'card', '25A-66497', NULL);
-- 1. Tất cả giao dịch của 1 trạm trong khoảng ngày
SELECT s.*
FROM sales s
JOIN pumps p ON p.pump_id = s.pump_id
WHERE p.station_id = 1
  AND s.tx_time >= '2025-08-04 00:00:00'
  AND s.tx_time <  '2025-08-14 00:00:00'
ORDER BY s.tx_time;
-- 2. Tổng doanh thu theo ngày cho 1 trụ bơm
SELECT DATE(s.tx_time) AS sale_date,
       SUM(s.amount_vnd) AS total_amount_vnd,
       SUM(s.quantity_liters) AS total_liters
FROM sales s
WHERE s.pump_id = 1
  AND s.tx_time >= '2025-08-04 00:00:00'
  AND s.tx_time <  '2025-08-14 00:00:00'
GROUP BY DATE(s.tx_time)
ORDER BY sale_date;
-- 3. Tổng doanh thu theo ngày cho 1 trạm
SELECT DATE(s.tx_time) AS sale_date,
       SUM(s.amount_vnd) AS total_amount_vnd,
       SUM(s.quantity_liters) AS total_liters
FROM sales s
JOIN pumps p ON p.pump_id = s.pump_id
WHERE p.station_id = 1
  AND s.tx_time >= '2025-08-04 00:00:00'
  AND s.tx_time <  '2025-08-14 00:00:00'
GROUP BY DATE(s.tx_time)
ORDER BY sale_date;
-- 4. Top 3 hàng hoá bán chạy nhất (theo lít) tại một trạm trong tháng
WITH month_range AS (
  SELECT make_date(:year, :month, 1) AS start_date,
         (make_date(:year, :month, 1) + INTERVAL '1 month') AS end_date
)
SELECT pr.product_id, pr.name,
       SUM(s.quantity_liters) AS total_liters,
       SUM(s.amount_vnd) AS total_amount_vnd
FROM sales s
JOIN pumps p ON p.pump_id = s.pump_id
JOIN products pr ON pr.product_id = s.product_id
CROSS JOIN month_range mr
WHERE p.station_id = 1
  AND s.tx_time >= mr.start_date
  AND s.tx_time <  mr.end_date
GROUP BY pr.product_id, pr.name
ORDER BY total_liters DESC
LIMIT 3;
