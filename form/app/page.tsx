"use client";
import { ArrowLeftOutlined } from "@ant-design/icons";
import { useForm } from "react-hook-form";
import { z } from "zod";
import { zodResolver } from "@hookform/resolvers/zod";
import { notification } from "antd";
import { useState } from "react";

const schema = z.object({
  time: z.string().min(1, "Vui lòng chọn thời gian"),
  quantity: z.number().min(1, "Số lượng phải > 0"),
  pump: z.string().min(1, "Vui lòng chọn trụ"),
  revenue: z.number().min(0, "Doanh thu phải ≥ 0"),
  price: z.number().min(0, "Đơn giá phải ≥ 0"),
});

type FormData = z.infer<typeof schema>;

export default function Home() {
  const [notice, setNotice] = useState("");
  const {
    register,
    handleSubmit,
    formState: { errors },
    reset,
    setValue,
  } = useForm<FormData>({
    resolver: zodResolver(schema),
    defaultValues: {
      time: "",
      quantity: 0,
      pump: "",
      revenue: 0,
      price: 0,
    },
  });

  const onSubmit = (data: FormData) => {
    setNotice("Cập nhật thành công");
    reset();
  };
  return (
    <form
      onSubmit={handleSubmit(onSubmit)}
      className="grid grid-rows-[20px_1fr_20px] items-center justify-items-center min-h-screen p-8 pb-20 gap-16 sm:p-20"
    >
      <div className="flex flex-row w-full justify-between items-center">
        <button className="flex flex-row gap-2 items-center">
          <ArrowLeftOutlined />
          <span>Đóng</span>
        </button>
        <button
          type="submit"
          className="border-2 rounded-md p-3 bg-blue-500 text-white font-bold"
          onClick={() => {
            notification.open({
              message: "Notification Title",
              description: "This is the content of the notification.",
            });
          }}
        >
          Cập nhập
        </button>
      </div>
      <h1 className="text-2xl font-bold">Nhập giao dịch</h1>
      {notice && (
        <div className="p-3 text-green-700 bg-green-100 border border-green-300 rounded">
          {notice}
        </div>
      )}
      <div className="border-2 border-gray-300 rounded-md p-2 flex flex-col gap-2 w-full">
        <span className="text-sm font-bold">Thời gian</span>
        <input type="datetime-local" {...register("time")} />
        {errors.time && (
          <p className="text-red-500 text-sm">{errors.time.message}</p>
        )}
      </div>
      <div className="border-2 border-gray-300 rounded-md p-2 flex flex-col gap-2 w-full">
        <span className="text-sm font-bold">Số lượng</span>
        <input
          type="number"
          {...register("quantity", { valueAsNumber: true })}
        />
        {errors.quantity && (
          <p className="text-red-500 text-sm">{errors.quantity.message}</p>
        )}
      </div>
      <div className="border-2 border-gray-300 rounded-md p-2 flex flex-col gap-2 w-full">
        <span className="text-sm font-bold">Trụ</span>
        <select id="pump" {...register("pump")}>
          <option value="">-- Select --</option>
          <option value="01">01</option>
          <option value="02">02</option>
          <option value="03">03</option>
          <option value="04">04</option>
          <option value="05">05</option>
          <option value="06">06</option>
          <option value="07">07</option>
          <option value="08">08</option>
          <option value="09">09</option>
        </select>
        {errors.pump && (
          <p className="text-red-500 text-sm">{errors.pump.message}</p>
        )}
      </div>
      <div className="border-2 border-gray-300 rounded-md p-2 flex flex-col gap-2 w-full">
        <span className="text-sm font-bold">Doanh thu</span>
        <input
          type="number"
          {...register("revenue", { valueAsNumber: true })}
        />
        {errors.revenue && (
          <p className="text-red-500 text-sm">{errors.revenue.message}</p>
        )}
      </div>
      <div className="border-2 border-gray-300 rounded-md p-2 flex flex-col gap-2 w-full">
        <span className="text-sm font-bold">Đơn giá</span>
        <input type="number" {...register("price", { valueAsNumber: true })} />
        {errors.price && (
          <p className="text-red-500 text-sm">{errors.price.message}</p>
        )}
      </div>
    </form>
  );
}
