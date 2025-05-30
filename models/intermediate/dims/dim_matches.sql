-- models/intermediate/dims/dim_matches.sql

with stg_matches as (

    select * from {{ ref(\'stg_ipl_data__matches\') }}

)

select
    match_id,
    season,
    match_date,
    event_name,
    match_number,
    event_stage,
    city,
    venue,
    match_type,
    planned_overs,
    result_method,
    team_one,
    team_two,
    toss_winner,
    toss_decision,
    match_result_type,
    winning_team,
    win_by_type,
    win_margin,
    player_of_match_name,
    player_of_match_id,
    umpire_one_name,
    umpire_one_id,
    umpire_two_name,
    umpire_two_id,
    tv_umpire_name,
    tv_umpire_id,
    match_referee_name,
    match_referee_id,
    reserve_umpire_name,
    reserve_umpire_id

from stg_matches

