-- models/staging/ipl_data/stg_ipl_data__matches.sql

with source as (

    select * from {{ source('ipl_raw_data', 'ipl_match_data') }}

),

renamed as (

    select
        -- Match Identifiers
        match_id::integer as match_id,
        season::varchar as season,
        event_name::varchar as event_name,
        coalesce(match_number::varchar, 'N/A') as match_number, -- Handle potential nulls
        event_stage::varchar as event_stage,

        -- Match Details
        coalesce(dates_1::date, dates_2::date, dates_3::date, dates_4::date, dates_5::date, dates_6::date) as match_date, -- Combine date columns
        city::varchar as city,
        venue::varchar as venue,
        match_type::varchar as match_type,
        overs::integer as planned_overs,
        method::varchar as result_method, -- e.g., D/L

        -- Teams
        team_1::varchar as team_one,
        team_2::varchar as team_two,

        -- Toss
        toss_winner::varchar as toss_winner,
        toss_decision::varchar as toss_decision,

        -- Result
        match_result::varchar as match_result_type, -- e.g., Winner, No Result
        winner::varchar as winning_team,
        case 
            when by_wickets is not null then 'wickets'
            when by_runs is not null then 'runs'
            else null
        end as win_by_type,
        coalesce(by_wickets::integer, by_runs::integer) as win_margin,

        -- Officials and Awards
        player_of_match::varchar as player_of_match_name,
        player_of_match_id::varchar as player_of_match_id,
        umpire_1::varchar as umpire_one_name,
        umpire_1_id::varchar as umpire_one_id,
        umpire_2::varchar as umpire_two_name,
        umpire_2_id::varchar as umpire_two_id,
        tv_umpires::varchar as tv_umpire_name,
        tv_umpires_id::varchar as tv_umpire_id,
        match_referees::varchar as match_referee_name,
        match_referees_id::varchar as match_referee_id,
        reserve_umpires::varchar as reserve_umpire_name,
        reserve_umpires_id::varchar as reserve_umpire_id,

        -- Player Lists (Keep IDs for potential future joins, though dims are preferred)
        team_1_player_1_id, team_1_player_2_id, team_1_player_3_id, team_1_player_4_id, team_1_player_5_id, team_1_player_6_id, team_1_player_7_id, team_1_player_8_id, team_1_player_9_id, team_1_player_10_id, team_1_player_11_id, team_1_player_12_id,
        team_2_player_1_id, team_2_player_2_id, team_2_player_3_id, team_2_player_4_id, team_2_player_5_id, team_2_player_6_id, team_2_player_7_id, team_2_player_8_id, team_2_player_9_id, team_2_player_10_id, team_2_player_11_id, team_2_player_12_id

        -- Note: Removed player names from here as they belong in a player dimension

    from source

),

distinct_matches as (
    -- Since match info is repeated for each delivery, select distinct matches
    select 
        *
    from renamed
    qualify row_number() over (partition by match_id order by match_date desc) = 1 -- Pick one record per match
)

select * from distinct_matches

