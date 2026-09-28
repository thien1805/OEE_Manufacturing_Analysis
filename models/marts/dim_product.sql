with product_source as (
    select * from {{ ref('stg_product') }}
)

select
    md5(product_name) as product_id,
    product_name,
    biscuits_per_pack,
    biscuits_per_case,
    cases_per_pallet,
    biscuits_per_pallet
from product_source
