with source as (
    select * from {{ source('bronze', 'machine') }}
),

renamed as (
    select
        trim("Machine Name") as machine_name,
        trim("Machine Type") as machine_type
    from source
)

select * from renamed
