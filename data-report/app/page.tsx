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

  const handleFileUpload = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (!file) return;

    const reader = new FileReader();
    reader.onload = (event) => {
      const binaryStr = event.target?.result;
      if (!binaryStr) return;

      const workbook = XLSX.read(binaryStr, { type: "binary" });
      const sheet = workbook.Sheets[workbook.SheetNames[0]];
      const jsonData: ExcelRow[] = XLSX.utils.sheet_to_json(sheet, {
        defval: "",
        range: 7,
      });
      setData(jsonData);
    };
    reader.readAsArrayBuffer(file);
  };
  const calculateTotal = () => {
    if (!data.length) return;

    const startParts = startTime.split(":").map(Number);
    const endParts = endTime.split(":").map(Number);

    const startMinutes = startParts[0] * 60 + startParts[1];
    const endMinutes = endParts[0] * 60 + endParts[1];

    const filtered = data.filter((row) => {
      const dateStr = row["Ngày"];
      const timeStr = row["Giờ"];
      const money = row["Thành tiền (VNĐ)"];
      if (!dateStr || !timeStr || !money) return false;

      // parse giờ
      const [h, m, s] = String(timeStr).split(":").map(Number);
      const minutes = h * 60 + m;

      return minutes >= startMinutes && minutes < endMinutes;
    });
    console.log(filtered);

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
