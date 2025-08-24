"use client";

import * as XLSX from "xlsx";
import { useState } from "react";

// Define a type for Excel row data
type ExcelRow = Record<string, string | number>;

export default function Home() {
  const [data, setData] = useState<ExcelRow[]>([]);
  const [startTime, setStartTime] = useState("08:00");
  const [endTime, setEndTime] = useState("12:00");
  const [total, setTotal] = useState<number | null>(null);

  //hàm đọc file excel và chuyển thành dữ liệu json
  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;
    //đọc file excel
    const reader = new FileReader();
    reader.onload = (event) => {
      //đọc file excel và chuyển thành dữ liệu json
      const binaryStr = event.target?.result;
      if (!binaryStr) return;

      const workbook = XLSX.read(binaryStr, { type: "binary" });
      //lấy sheet đầu tiên
      const sheet = workbook.Sheets[workbook.SheetNames[0]];
      //xác định dữ liệu từ sheet đầu tiên, xác định header và vị trí bằng lấy dữ liệu
      const jsonData: ExcelRow[] = XLSX.utils.sheet_to_json(sheet, {
        defval: "",
        range: 7, //lấy dữ liệu bắt đầu từ dòng thứ 8
      });
      setData(jsonData);
    };
    reader.readAsArrayBuffer(file);
  };
  const calculateTotal = () => {
    if (!data.length) return;
    //bỏ dữ liệu không cần thiết - cụ thể bỏ dấu ":" trong thời gian
    const startParts = startTime.split(":").map(Number);
    const endParts = endTime.split(":").map(Number);
    //chuyển thời gian thành phút
    const startMinutes = startParts[0] * 60 + startParts[1];
    const endMinutes = endParts[0] * 60 + endParts[1];
    //lọc dữ liệu theo thời gian
    const filtered = data.filter((row) => {
      const dateStr = row["Ngày"];
      const timeStr = row["Giờ"];
      const money = row["Thành tiền (VNĐ)"];
      if (!dateStr || !timeStr || !money) return false;

      // parse giờ thành phút
      const [h, m, s] = String(timeStr).split(":").map(Number);
      const minutes = h * 60 + m;
      //lọc dữ liệu theo thời gian
      return minutes >= startMinutes && minutes < endMinutes;
    });
    //tính tổng thành tiền
    const sum = filtered.reduce((acc, row) => {
      const val = String(row["Thành tiền (VNĐ)"]).replace(/[^\d]/g, "");
      return acc + (Number(val) || 0);
    }, 0);

    setTotal(sum);
  };
  return (
    <div className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20">
      <h1 className="text-2xl font-bold">📊 Báo cáo giao dịch xăng dầu</h1>
      <input
        className="border-2 border-gray-300 rounded-md p-2"
        type="file"
        accept=".xlsx,.xls"
        onChange={handleFileUpload}
      />
      <div style={{ marginTop: 20 }}>
        <label>
          Giờ bắt đầu:{" "}
          <input
            type="time"
            value={startTime}
            onChange={(e) => setStartTime(e.target.value)}
          />
        </label>
        <label style={{ marginLeft: 20 }}>
          Giờ kết thúc:{" "}
          <input
            type="time"
            value={endTime}
            onChange={(e) => setEndTime(e.target.value)}
          />
        </label>
        <button onClick={calculateTotal} style={{ marginLeft: 20 }}>
          Tính tổng
        </button>
      </div>

      {total !== null && (
        <h2 className="text-xl font-bold mt-4">
          💰 Tổng thành tiền: {total.toLocaleString()} VND
        </h2>
      )}
    </div>
  );
}
