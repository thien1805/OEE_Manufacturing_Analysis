with machine_source as (
    select * from {{ ref('stg_machine') }}
)

select
    md5(machine_name) as machine_id,
    machine_name,
    machine_type
from machine_source
