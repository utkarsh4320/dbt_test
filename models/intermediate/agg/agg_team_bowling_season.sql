-- models/intermediate/agg/agg_team_bowling_season.sql

with agg_bowling_match as (
    select * from {{ ref(\'agg_team_bowling_match\') }}
)

select
    season,
    bowling_team_sk,
    sum(total_runs_conceded) as season_total_runs_conceded,
    sum(total_extras_conceded) as season_total_extras_conceded,
    sum(total_wides_conceded) as season_total_wides_conceded,
    sum(total_noballs_conceded) as season_total_noballs_conceded,
    sum(total_byes_conceded) as season_total_byes_conceded,
    sum(total_legbyes_conceded) as season_total_legbyes_conceded,
    sum(total_wickets_taken) as season_total_wickets_taken,
    sum(balls_bowled) as season_balls_bowled,
    
    -- Calculate overall season economy rate
    case 
        when sum(balls_bowled) > 0 then
            (sum(total_runs_conceded) * 6.0) / sum(balls_bowled)
        else 0 
    end as season_economy_rate,

    -- Calculate overall season strike rate
    case
        when sum(total_wickets_taken) > 0 then
            sum(balls_bowled) * 1.0 / sum(total_wickets_taken)
        else null
    end as season_strike_rate,

    count(distinct match_id) as matches_played

from agg_bowling_match
group by
    season,
    bowling_team_sk

