-- models/intermediate/dims/dim_venues.sql

with stg_matches as (
    select * from {{ ref(\'stg_ipl_data__matches\') }}
)

-- Select distinct venues
select distinct
    {{ dbt_utils.generate_surrogate_key([\'venue\', \'city\']) }} as venue_sk, -- Surrogate key based on venue and city
    venue,
    city
from stg_matches
where venue is not null
order by city, venue

