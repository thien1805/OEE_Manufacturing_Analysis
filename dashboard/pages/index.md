---
title: Plant OEE Executive Dashboard
---

# 🏭 Grandma Edna's Biscuits — Plant OEE Dashboard

Dữ liệu phân tích hiệu suất thiết bị tổng thể (**OEE**) được kết nối trực tiếp từ mô hình **dbt Gold Layer** (`my_factory.duckdb`).

```sql summary_kpi
select
    round(avg(oee_pct), 1) as avg_oee,
    round(avg(availability_pct), 1) as avg_availability,
    round(avg(performance_pct), 1) as avg_performance,
    round(avg(quality_pct), 1) as avg_quality,
    sum(total_biscuits) as total_produced,
    sum(good_biscuits) as total_good,
    sum(scrap_biscuits) as total_scrap
from oee_factory.daily_plant_oee
```

<Grid cols=4>
    <BigValue 
        data={summary_kpi} 
        value=avg_oee 
        title="Plant Overall OEE" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=avg_availability 
        title="Availability (Độ khả dụng)" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=avg_performance 
        title="Performance (Hiệu suất vận hành)" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=avg_quality 
        title="Quality (Chất lượng)" 
        fmt="0.0%" 
    />
</Grid>

---

## 📈 Xu Hướng OEE & 3 Trụ Cột Hàng Ngày

```sql daily_oee
select
    date_id,
    oee_pct as oee,
    availability_pct as availability,
    performance_pct as performance,
    quality_pct as quality
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
    availability_pct,
    performance_pct,
    quality_pct,
    oee_pct
from oee_factory.machine_performance
order by oee_pct desc
```

<DataTable data={machines} search=true rows=10>
    <Column id=machine_name title="Tên máy" />
    <Column id=machine_type title="Phân loại" />
    <Column id=run_hours title="Giờ chạy" fmt="0.0" />
    <Column id=availability_pct title="Availability" fmt="0.0%" />
    <Column id=performance_pct title="Performance" fmt="0.0%" />
    <Column id=quality_pct title="Quality" fmt="0.0%" />
    <Column id=oee_pct title="OEE" fmt="0.0%" />
</DataTable>

---

## 🍪 Phân Tích Tỷ Lệ Phế Phẩm Theo Sản Phẩm (Scrap Analysis)

```sql products
select
    product_name,
    total_biscuits,
    good_biscuits,
    scrap_biscuits,
    scrap_rate_pct,
    quality_pct
from oee_factory.product_quality
order by scrap_rate_pct desc
```

<DataTable data={products} search=true rows=10>
    <Column id=product_name title="Sản phẩm" />
    <Column id=total_biscuits title="Tổng sản lượng" fmt="#,##0" />
    <Column id=good_biscuits title="Đạt chuẩn" fmt="#,##0" />
    <Column id=scrap_biscuits title="Phế phẩm" fmt="#,##0" />
    <Column id=scrap_rate_pct title="Tỷ lệ phế phẩm (%)" fmt="0.0%" />
    <Column id=quality_pct title="Chất lượng (Quality %)" fmt="0.0%" />
</DataTable>
