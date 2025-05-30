-- models/marts/core/fct_match_summary.sql

with dim_matches as (
    select * from {{ ref(\'dim_matches\') }}
),

dim_teams as (
    select * from {{ ref(\'dim_teams\') }}
),

agg_batting as (
    select * from {{ ref(\'agg_team_batting_match\') }}
),

agg_bowling as (
    select * from {{ ref(\'agg_team_bowling_match\') }}
),

-- Join teams to get SKs for joining with aggregations
matches_with_teams as (
    select
        dm.*,
        t1.team_sk as team_one_sk,
        t2.team_sk as team_two_sk
    from dim_matches dm
    left join dim_teams t1 on dm.team_one = t1.team_name
    left join dim_teams t2 on dm.team_two = t2.team_name
)

select 
    m.match_id,
    m.season,
    m.match_date,
    m.venue,
    m.city,
    m.team_one,
    m.team_two,
    m.toss_winner,
    m.toss_decision,
    m.match_result_type,
    m.winning_team,
    m.win_by_type,
    m.win_margin,
    m.player_of_match_name,

    -- Team 1 Batting Stats (when team 1 batted)
    bat1.total_batting_runs as team1_total_batting_runs,
    bat1.total_extras_received as team1_extras_received,
    bat1.total_runs_scored as team1_total_runs_scored,
    bat1.count_4s as team1_count_4s,
    bat1.count_6s as team1_count_6s,
    bat1.wickets_lost as team1_wickets_lost,
    bat1.balls_faced as team1_balls_faced,
    bat1.run_rate as team1_run_rate,

    -- Team 1 Bowling Stats (when team 2 batted)
    bowl1.total_runs_conceded as team1_runs_conceded,
    bowl1.total_extras_conceded as team1_extras_conceded,
    bowl1.total_wickets_taken as team1_wickets_taken,
    bowl1.balls_bowled as team1_balls_bowled,
    bowl1.economy_rate as team1_economy_rate,
    bowl1.strike_rate as team1_strike_rate,

    -- Team 2 Batting Stats (when team 2 batted)
    bat2.total_batting_runs as team2_total_batting_runs,
    bat2.total_extras_received as team2_extras_received,
    bat2.total_runs_scored as team2_total_runs_scored,
    bat2.count_4s as team2_count_4s,
    bat2.count_6s as team2_count_6s,
    bat2.wickets_lost as team2_wickets_lost,
    bat2.balls_faced as team2_balls_faced,
    bat2.run_rate as team2_run_rate,

    -- Team 2 Bowling Stats (when team 1 batted)
    bowl2.total_runs_conceded as team2_runs_conceded,
    bowl2.total_extras_conceded as team2_extras_conceded,
    bowl2.total_wickets_taken as team2_wickets_taken,
    bowl2.balls_bowled as team2_balls_bowled,
    bowl2.economy_rate as team2_economy_rate,
    bowl2.strike_rate as team2_strike_rate

from matches_with_teams m
-- Join Team 1 Batting Stats
left join agg_batting bat1 
    on m.match_id = bat1.match_id 
    and m.team_one_sk = bat1.batting_team_sk
-- Join Team 2 Batting Stats
left join agg_batting bat2 
    on m.match_id = bat2.match_id 
    and m.team_two_sk = bat2.batting_team_sk
-- Join Team 1 Bowling Stats (Team 1 bowled when Team 2 batted)
left join agg_bowling bowl1 
    on m.match_id = bowl1.match_id 
    and m.team_one_sk = bowl1.bowling_team_sk
-- Join Team 2 Bowling Stats (Team 2 bowled when Team 1 batted)
left join agg_bowling bowl2 
    on m.match_id = bowl2.match_id 
    and m.team_two_sk = bowl2.bowling_team_sk
order by
    m.season desc,
    m.match_date desc,
    m.match_id

