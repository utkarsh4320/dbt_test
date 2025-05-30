-- models/intermediate/agg/agg_team_batting_season.sql

with agg_batting_match as (
    select * from {{ ref(\'agg_team_batting_match\') }}
)

select
    season,
    batting_team_sk,
    sum(total_batting_runs) as season_total_batting_runs,
    sum(total_extras_received) as season_total_extras_received,
    sum(total_runs_scored) as season_total_runs_scored,
    sum(count_4s) as season_count_4s,
    sum(count_6s) as season_count_6s,
    sum(wickets_lost) as season_wickets_lost,
    sum(balls_faced) as season_balls_faced,
    
    -- Calculate overall season run rate
    case 
        when sum(balls_faced) > 0 then
            (sum(total_runs_scored) * 6.0) / sum(balls_faced)
        else 0 
    end as season_run_rate,

    count(distinct match_id) as matches_played

from agg_batting_match
group by
    season,
    batting_team_sk

