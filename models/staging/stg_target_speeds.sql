with source as (
    select * from {{ source('bronze', 'target_speeds') }}
),

renamed as (
    select
        trim("Machine") as machine_name,
        trim("Product") as product_name,
        cast("TARGET_Biscuits_per_hour" as double) as target_biscuits_per_hour
    from source
)

select * from renamed
