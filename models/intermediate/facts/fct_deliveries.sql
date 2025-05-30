-- models/intermediate/facts/fct_deliveries.sql

with stg_deliveries as (
    select * from {{ ref(\'stg_ipl_data__deliveries\') }}
),

dim_matches as (
    select match_id from {{ ref(\'dim_matches\') }}
),

dim_players as (
    select player_sk, player_name from {{ ref(\'dim_players\') }}
),

dim_teams as (
    select team_sk, team_name from {{ ref(\'dim_teams\') }}
)

-- Note: dim_venues is not directly joined here as match_id provides the link
--       It can be joined in downstream models (like marts) if venue details are needed alongside delivery facts.

select
    -- Surrogate Key
    stg_deliveries.delivery_id,

    -- Dimension Foreign Keys
    stg_deliveries.match_id,
    coalesce(batting_team_dim.team_sk, -1) as batting_team_sk, -- Use -1 for unknown/missing keys
    coalesce(bowling_team_dim.team_sk, -1) as bowling_team_sk, -- Derived below
    coalesce(batter_dim.player_sk, -1) as batter_sk,
    coalesce(bowler_dim.player_sk, -1) as bowler_sk,
    coalesce(non_striker_dim.player_sk, -1) as non_striker_sk,
    coalesce(player_dismissed_dim.player_sk, -1) as player_dismissed_sk,
    coalesce(fielder_one_dim.player_sk, -1) as fielder_one_sk,
    coalesce(fielder_two_dim.player_sk, -1) as fielder_two_sk,

    -- Degenerate Dimensions (already present in staging)
    stg_deliveries.inning_number,
    stg_deliveries.over_number,
    stg_deliveries.ball_of_over,
    stg_deliveries.wicket_type,
    stg_deliveries.is_powerplay,
    stg_deliveries.is_super_over,

    -- Measures
    stg_deliveries.runs_scored_bat,
    stg_deliveries.runs_scored_extras,
    stg_deliveries.runs_scored_total,
    stg_deliveries.extra_wides,
    stg_deliveries.extra_noballs,
    stg_deliveries.extra_byes,
    stg_deliveries.extra_legbyes,
    stg_deliveries.extra_penalty,
    stg_deliveries.is_wicket::integer as is_wicket_delivery -- Cast boolean to integer (0 or 1)

    -- Ignoring target and review details for the core fact table, can be added if needed

from stg_deliveries
inner join dim_matches on stg_deliveries.match_id = dim_matches.match_id -- Ensure match exists in dimension
left join dim_teams as batting_team_dim 
    on stg_deliveries.batting_team = batting_team_dim.team_name
left join dim_players as batter_dim 
    on stg_deliveries.batter_name = batter_dim.player_name
left join dim_players as bowler_dim 
    on stg_deliveries.bowler_name = bowler_dim.player_name
left join dim_players as non_striker_dim 
    on stg_deliveries.non_striker_name = non_striker_dim.player_name
left join dim_players as player_dismissed_dim 
    on stg_deliveries.player_dismissed_name = player_dismissed_dim.player_name
left join dim_players as fielder_one_dim 
    on stg_deliveries.fielder_one_name = fielder_one_dim.player_name
left join dim_players as fielder_two_dim 
    on stg_deliveries.fielder_two_name = fielder_two_dim.player_name
-- Derive bowling team (the team not batting in that delivery)
-- This requires joining back to dim_matches to know team_one and team_two
left join {{ ref(\'dim_matches\') }} match_info on stg_deliveries.match_id = match_info.match_id
left join dim_teams as bowling_team_dim 
    on case 
        when stg_deliveries.batting_team = match_info.team_one then match_info.team_two
        when stg_deliveries.batting_team = match_info.team_two then match_info.team_one
        else null -- Handle cases where batting team doesn\'t match either team in dim_matches (shouldn\'t happen with good data)
       end = bowling_team_dim.team_name

