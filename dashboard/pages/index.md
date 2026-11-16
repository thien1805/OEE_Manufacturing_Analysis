---
title: Plant OEE Executive Dashboard
---

# 🏭 Grandma Edna's Biscuits — Plant OEE Dashboard

Dữ liệu phân tích hiệu suất thiết bị tổng thể (**OEE**) được kết nối trực tiếp từ mô hình **dbt Gold Layer** (`my_factory.duckdb`).

```sql summary_kpi
select
    sum(operating_hours) / nullif(sum(planned_hours), 0) as availability_rate,
    1.00 as performance_rate,
    sum(good_biscuits) / nullif(sum(total_biscuits), 0) as quality_rate,
    (sum(operating_hours) / nullif(sum(planned_hours), 0)) *
    1.00 *
    (sum(good_biscuits) / nullif(sum(total_biscuits), 0)) as oee_rate,
    sum(total_biscuits) as total_produced,
    sum(good_biscuits) as total_good,
    sum(scrap_biscuits) as total_scrap
from oee_factory.daily_plant_oee
```

<Grid cols=4>
    <BigValue 
        data={summary_kpi} 
        value=oee_rate 
        title="Plant Overall OEE" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=availability_rate 
        title="Availability (Độ khả dụng)" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=performance_rate 
        title="Performance (Hiệu suất vận hành)" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=quality_rate 
        title="Quality (Chất lượng)" 
        fmt="0.0%" 
    />
</Grid>

---

## 📈 Xu Hướng OEE & 3 Trụ Cột Hàng Ngày

```sql daily_oee
select
    date_id,
    oee_rate as oee,
    availability_rate as availability,
    performance_rate as performance,
    quality_rate as quality
from oee_factory.daily_plant_oee
order by date_id
```

<LineChart 
    data={daily_oee} 
    x=date_id 
    y={["oee", "availability", "performance", "quality"]}
    title="Biến thiên OEE và 3 nhân tố theo ngày"
    yFmt="0.0%"
/>

---

## ⏱️ Phân Tích Nguyên Nhân Dừng Máy (Downtime Losses)

```sql downtime
select
    oee_category,
    downtime_hours,
    incident_count,
    pct_of_downtime
from oee_factory.downtime_summary
```

<Grid cols=2>
    <BarChart 
        data={downtime} 
        x=oee_category 
        y=downtime_hours 
        swapXY=true 
        title="Tổng số giờ dừng máy theo danh mục sự cố"
    />
    <DataTable data={downtime}>
        <Column id=oee_category title="Nguyên nhân dừng máy" />
        <Column id=downtime_hours title="Thời gian (Giờ)" fmt="0.0" />
        <Column id=incident_count title="Số lần dừng" fmt="#,##0" />
        <Column id=pct_of_downtime title="Tỷ trọng (%)" fmt="0.0%" />
    </DataTable>
</Grid>

---

## ⚙️ Xếp Hạng Hiệu Suất Theo Thiết Bị (Machine Matrix)

```sql machines
select
    machine_name,
    machine_type,
    run_hours,
    availability_rate,
    performance_rate,
    quality_rate,
    oee_rate
from oee_factory.machine_performance
order by oee_rate desc
```

<DataTable data={machines} search=true rows=10>
    <Column id=machine_name title="Tên máy" />
    <Column id=machine_type title="Phân loại" />
    <Column id=run_hours title="Giờ chạy" fmt="0.0" />
    <Column id=availability_rate title="Availability" fmt="0.0%" />
    <Column id=performance_rate title="Performance" fmt="0.0%" />
    <Column id=quality_rate title="Quality" fmt="0.0%" />
    <Column id=oee_rate title="OEE" fmt="0.0%" />
</DataTable>

---

## 🍪 Phân Tích Tỷ Lệ Phế Phẩm Theo Sản Phẩm (Scrap Analysis)

```sql products
select
    product_name,
    total_biscuits,
    good_biscuits,
    scrap_biscuits,
    scrap_rate,
    quality_rate
from oee_factory.product_quality
order by scrap_rate desc
```

<DataTable data={products} search=true rows=10>
    <Column id=product_name title="Sản phẩm" />
    <Column id=total_biscuits title="Tổng sản lượng" fmt="#,##0" />
    <Column id=good_biscuits title="Đạt chuẩn" fmt="#,##0" />
    <Column id=scrap_biscuits title="Phế phẩm" fmt="#,##0" />
    <Column id=scrap_rate title="Tỷ lệ phế phẩm (%)" fmt="0.0%" />
    <Column id=quality_rate title="Chất lượng (Quality %)" fmt="0.0%" />
</DataTable>
