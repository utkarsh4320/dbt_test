-- models/intermediate/dims/dim_teams.sql

with stg_matches as (
    select * from {{ ref(\'stg_ipl_data__matches\') }}
),

stg_deliveries as (
    select * from {{ ref(\'stg_ipl_data__deliveries\') }}
),

-- Teams from matches
match_teams as (
    select team_one as team_name from stg_matches where team_one is not null
    union
    select team_two as team_name from stg_matches where team_two is not null
    union
    select toss_winner as team_name from stg_matches where toss_winner is not null
    union
    select winning_team as team_name from stg_matches where winning_team is not null
),

-- Teams from deliveries (batting team)
delivery_teams as (
    select batting_team as team_name from stg_deliveries where batting_team is not null
),

-- Combine all teams
all_teams as (
    select team_name from match_teams
    union
    select team_name from delivery_teams
)

-- Select distinct teams
select
    {{ dbt_utils.generate_surrogate_key([\'team_name\']) }} as team_sk, -- Surrogate key based on name
    team_name
from all_teams
where team_name is not null -- Ensure no null team names
order by team_name

