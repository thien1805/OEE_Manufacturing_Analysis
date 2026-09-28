with source as (
    select * from {{ source('bronze', 'product') }}
),

renamed as (
    select
        trim("Product Name") as product_name,
        cast("Biscuits_PER_PACK" as integer) as biscuits_per_pack,
        cast("Biscuits_PER_CASE" as integer) as biscuits_per_case,
        cast("Biscuits_PER_PALLET" as integer) as cases_per_pallet,
        cast("Bsicuits Per Pallet" as integer) as biscuits_per_pallet
    from source
)

select * from renamed
