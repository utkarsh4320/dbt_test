-- models/intermediate/agg/agg_team_bowling_match.sql

with fct_deliveries as (
    select * from {{ ref(\'fct_deliveries\') }}
),

dim_matches as (
    select match_id, season from {{ ref(\'dim_matches\') }}
)

select
    fct.match_id,
    dm.season,
    fct.bowling_team_sk, -- Group by the team that was bowling
    sum(fct.runs_scored_total) as total_runs_conceded,
    sum(fct.runs_scored_extras) as total_extras_conceded,
    sum(fct.extra_wides) as total_wides_conceded,
    sum(fct.extra_noballs) as total_noballs_conceded,
    sum(fct.extra_byes) as total_byes_conceded,
    sum(fct.extra_legbyes) as total_legbyes_conceded,
    sum(fct.is_wicket_delivery) as total_wickets_taken,
    count(case when fct.extra_wides = 0 and fct.extra_noballs = 0 then 1 else null end) as balls_bowled, -- Count only legal deliveries bowled
    
    -- Calculate economy rate (total runs conceded / (balls bowled / 6) )
    -- Avoid division by zero
    case 
        when count(case when fct.extra_wides = 0 and fct.extra_noballs = 0 then 1 else null end) > 0 then
            (sum(fct.runs_scored_total) * 6.0) / count(case when fct.extra_wides = 0 and fct.extra_noballs = 0 then 1 else null end)
        else 0 
    end as economy_rate,

    -- Calculate strike rate (balls bowled / wickets taken)
    -- Avoid division by zero
    case
        when sum(fct.is_wicket_delivery) > 0 then
            count(case when fct.extra_wides = 0 and fct.extra_noballs = 0 then 1 else null end) * 1.0 / sum(fct.is_wicket_delivery)
        else null -- Or potentially a large number or 0, depending on desired representation
    end as strike_rate

from fct_deliveries fct
join dim_matches dm on fct.match_id = dm.match_id
where fct.inning_number <= 2 -- Exclude super overs for standard match stats
and fct.bowling_team_sk is not null -- Ensure we have a valid bowling team
group by
    fct.match_id,
    dm.season,
    fct.bowling_team_sk

