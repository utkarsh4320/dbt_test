-- models/intermediate/dims/dim_players.sql

with stg_deliveries as (
    select * from {{ ref(\'stg_ipl_data__deliveries\') }}
),

stg_matches as (
    select * from {{ ref(\'stg_ipl_data__matches\') }}
),

-- Extract players from deliveries
delivery_players as (
    select batter_name as player_name from stg_deliveries where batter_name is not null
    union
    select bowler_name as player_name from stg_deliveries where bowler_name is not null
    union
    select non_striker_name as player_name from stg_deliveries where non_striker_name is not null
    union
    select player_dismissed_name as player_name from stg_deliveries where player_dismissed_name is not null
    union
    select fielder_one_name as player_name from stg_deliveries where fielder_one_name is not null
    union
    select fielder_two_name as player_name from stg_deliveries where fielder_two_name is not null
),

-- Extract player of the match
match_players as (
    select player_of_match_name as player_name from stg_matches where player_of_match_name is not null
    -- Note: We could also try to extract players from team lists in stg_matches if needed,
    -- but names aren\'t directly available there, only IDs which seem inconsistent.
),

-- Combine all players
all_players as (
    select player_name from delivery_players
    union
    select player_name from match_players
)

-- Select distinct players
select
    {{ dbt_utils.generate_surrogate_key([\'player_name\']) }} as player_sk, -- Surrogate key based on name
    player_name
from all_players
order by player_name

