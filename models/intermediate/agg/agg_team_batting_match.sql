-- models/intermediate/agg/agg_team_batting_match.sql

with fct_deliveries as (
    select * from {{ ref(\'fct_deliveries\') }}
),

dim_matches as (
    select match_id, season from {{ ref(\'dim_matches\') }}
)

select
    fct.match_id,
    dm.season,
    fct.batting_team_sk,
    sum(fct.runs_scored_bat) as total_batting_runs,
    sum(fct.runs_scored_extras) as total_extras_received, -- Extras conceded by the bowling team while this team was batting
    sum(fct.runs_scored_total) as total_runs_scored,
    sum(case when fct.runs_scored_bat = 4 then 1 else 0 end) as count_4s,
    sum(case when fct.runs_scored_bat = 6 then 1 else 0 end) as count_6s,
    sum(fct.is_wicket_delivery) as wickets_lost,
    count(case when fct.extra_wides = 0 and fct.extra_noballs = 0 then 1 else null end) as balls_faced, -- Count only legal deliveries faced
    
    -- Calculate run rate (total runs / (balls faced / 6) )
    -- Avoid division by zero
    case 
        when count(case when fct.extra_wides = 0 and fct.extra_noballs = 0 then 1 else null end) > 0 then
            (sum(fct.runs_scored_total) * 6.0) / count(case when fct.extra_wides = 0 and fct.extra_noballs = 0 then 1 else null end)
        else 0 
    end as run_rate

from fct_deliveries fct
join dim_matches dm on fct.match_id = dm.match_id
where fct.inning_number <= 2 -- Exclude super overs for standard match stats
group by
    fct.match_id,
    dm.season,
    fct.batting_team_sk

