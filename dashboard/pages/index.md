---
title: Plant OEE Executive Dashboard
---

# 🏭 Grandma Edna's Biscuits — Plant OEE Dashboard

Interactive manufacturing intelligence dashboard powered by **dbt Gold Layer** models directly querying [DuckDB](https://duckdb.org/) (`my_factory.duckdb`).

---

## 🎛️ Interactive Filters & Slicers

```sql filter_machines
select distinct machine_name
from oee_factory.production_runs_detailed
order by machine_name
```

```sql filter_types
select distinct machine_type
from oee_factory.production_runs_detailed
order by machine_type
```

```sql filter_products
select distinct product_name
from oee_factory.production_runs_detailed
order by product_name
```

<Grid cols=3>
    <div>
        <Dropdown data={filter_machines} name=selected_machine value=machine_name title="Machine">
            <DropdownOption value="%" valueLabel="All Machines" />
        </Dropdown>
    </div>
    <div>
        <Dropdown data={filter_types} name=selected_type value=machine_type title="Machine Type">
            <DropdownOption value="%" valueLabel="All Types" />
        </Dropdown>
    </div>
    <div>
        <Dropdown data={filter_products} name=selected_product value=product_name title="Product">
            <DropdownOption value="%" valueLabel="All Products" />
        </Dropdown>
    </div>
</Grid>

---

## 📌 Executive KPIs

```sql summary_kpi
select
    coalesce(sum(operating_hours) / nullif(sum(planned_hours), 0), 0) as availability_rate,
    coalesce(least(1.0, sum(total_biscuits) / nullif(sum(ideal_biscuits), 0)), 0) as performance_rate,
    coalesce(sum(good_biscuits) / nullif(sum(total_biscuits), 0), 0) as quality_rate,
    coalesce(
        (sum(operating_hours) / nullif(sum(planned_hours), 0)) *
        least(1.0, sum(total_biscuits) / nullif(sum(ideal_biscuits), 0)) *
        (sum(good_biscuits) / nullif(sum(total_biscuits), 0)),
        0
    ) as oee_rate,
    coalesce(sum(total_biscuits), 0) as total_produced,
    coalesce(sum(good_biscuits), 0) as total_good,
    coalesce(sum(scrap_biscuits), 0) as total_scrap
from oee_factory.production_runs_detailed
where machine_name like '${inputs.selected_machine.value}'
  and machine_type like '${inputs.selected_type.value}'
  and product_name like '${inputs.selected_product.value}'
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
        title="Availability (A)" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=performance_rate 
        title="Performance (P)" 
        fmt="0.0%" 
    />
    <BigValue 
        data={summary_kpi} 
        value=quality_rate 
        title="Quality (Q)" 
        fmt="0.0%" 
    />
</Grid>

---

## 📈 Daily OEE & 3 Pillars Trend

```sql daily_oee
select
    date_id,
    coalesce(sum(operating_hours) / nullif(sum(planned_hours), 0), 0) as availability,
    coalesce(least(1.0, sum(total_biscuits) / nullif(sum(ideal_biscuits), 0)), 0) as performance,
    coalesce(sum(good_biscuits) / nullif(sum(total_biscuits), 0), 0) as quality,
    coalesce(
        (sum(operating_hours) / nullif(sum(planned_hours), 0)) *
        least(1.0, sum(total_biscuits) / nullif(sum(ideal_biscuits), 0)) *
        (sum(good_biscuits) / nullif(sum(total_biscuits), 0)),
        0
    ) as oee
from oee_factory.production_runs_detailed
where machine_name like '${inputs.selected_machine.value}'
  and machine_type like '${inputs.selected_type.value}'
  and product_name like '${inputs.selected_product.value}'
group by date_id
order by date_id
```

<LineChart 
    data={daily_oee} 
    x=date_id 
    y={["oee", "availability", "performance", "quality"]}
    title="Daily OEE & Component Dynamics (Reactive to Slicers)"
    yFmt="0.0%"
/>

---

## ⏱️ Downtime Root Cause Breakdown

```sql downtime
select
    oee_category,
    round(sum(duration_hours), 1) as downtime_hours,
    count(*) as incident_count,
    sum(duration_hours) / nullif(sum(sum(duration_hours)) over (), 0) as pct_of_downtime
from oee_factory.production_runs_detailed
where not is_operating_time
  and machine_name like '${inputs.selected_machine.value}'
  and machine_type like '${inputs.selected_type.value}'
  and product_name like '${inputs.selected_product.value}'
group by oee_category
order by downtime_hours desc
```

<Grid cols=2>
    <BarChart 
        data={downtime} 
        x=oee_category 
        y=downtime_hours 
        swapXY=true 
        title="Downtime Duration by Failure Category"
    />
    <DataTable data={downtime}>
        <Column id=oee_category title="Downtime Reason" />
        <Column id=downtime_hours title="Duration (Hours)" fmt="0.0" />
        <Column id=incident_count title="Incidents" fmt="#,##0" />
        <Column id=pct_of_downtime title="Share (%)" fmt="0.0%" />
    </DataTable>
</Grid>

---

## ⚙️ Machine Performance Matrix

```sql machines
select
    machine_name,
    machine_type,
    round(sum(duration_hours), 1) as total_hours,
    round(sum(operating_hours), 1) as run_hours,
    coalesce(sum(operating_hours) / nullif(sum(planned_hours), 0), 0) as availability_rate,
    coalesce(least(1.0, sum(total_biscuits) / nullif(sum(ideal_biscuits), 0)), 0) as performance_rate,
    coalesce(sum(good_biscuits) / nullif(sum(total_biscuits), 0), 0) as quality_rate,
    coalesce(
        (sum(operating_hours) / nullif(sum(planned_hours), 0)) *
        least(1.0, sum(total_biscuits) / nullif(sum(ideal_biscuits), 0)) *
        (sum(good_biscuits) / nullif(sum(total_biscuits), 0)),
        0
    ) as oee_rate
from oee_factory.production_runs_detailed
where machine_name like '${inputs.selected_machine.value}'
  and machine_type like '${inputs.selected_type.value}'
  and product_name like '${inputs.selected_product.value}'
group by machine_name, machine_type
order by oee_rate desc
```

<DataTable data={machines} search=true rows=10>
    <Column id=machine_name title="Machine" />
    <Column id=machine_type title="Type" />
    <Column id=run_hours title="Run Hours" fmt="0.0" />
    <Column id=availability_rate title="Availability" fmt="0.0%" />
    <Column id=performance_rate title="Performance" fmt="0.0%" />
    <Column id=quality_rate title="Quality" fmt="0.0%" />
    <Column id=oee_rate title="OEE" fmt="0.0%" />
</DataTable>

---

## 🍪 Product Quality & Scrap Rate Analysis

```sql products
select
    product_name,
    sum(total_biscuits) as total_biscuits,
    sum(good_biscuits) as good_biscuits,
    sum(scrap_biscuits) as scrap_biscuits,
    coalesce(sum(scrap_biscuits) / nullif(sum(total_biscuits), 0), 0) as scrap_rate,
    coalesce(sum(good_biscuits) / nullif(sum(total_biscuits), 0), 0) as quality_rate
from oee_factory.production_runs_detailed
where is_operating_time
  and machine_name like '${inputs.selected_machine.value}'
  and machine_type like '${inputs.selected_type.value}'
  and product_name like '${inputs.selected_product.value}'
group by product_name
order by scrap_rate desc
```

<DataTable data={products} search=true rows=10>
    <Column id=product_name title="Product" />
    <Column id=total_biscuits title="Total Output" fmt="#,##0" />
    <Column id=good_biscuits title="Good Output" fmt="#,##0" />
    <Column id=scrap_biscuits title="Scrap Output" fmt="#,##0" />
    <Column id=scrap_rate title="Scrap Rate (%)" fmt="0.0%" />
    <Column id=quality_rate title="Quality Rate (%)" fmt="0.0%" />
</DataTable>
