-- models/staging/ipl_data/stg_ipl_data__deliveries.sql

with source as (

    select * from {{ source(\'ipl_raw_data\', \'ipl_match_data\') }}

),

renamed as (

    select
        -- Identifiers
        match_id::integer as match_id,
        innings::integer as inning_number,
        over_number::integer as over_number,
        delivery_number::integer as ball_of_over,
        -- Composite key for uniqueness
        match_id::varchar || \'-\' || innings::varchar || \'-\' || over_number::varchar || \'-\' || delivery_number::varchar as delivery_id,

        -- Teams & Players involved in delivery
        team::varchar as batting_team, 
        -- Assuming \'team\' column indicates the batting team for the delivery
        batter::varchar as batter_name,
        bowler::varchar as bowler_name,
        non_striker::varchar as non_striker_name,

        -- Runs Scored
        runs_batter::integer as runs_scored_bat,
        runs_extras::integer as runs_scored_extras,
        runs_total::integer as runs_scored_total,

        -- Extras Details
        coalesce(extras_wides::integer, 0) as extra_wides,
        coalesce(extras_noballs::integer, 0) as extra_noballs,
        coalesce(extras_byes::integer, 0) as extra_byes,
        coalesce(extras_legbyes::integer, 0) as extra_legbyes,
        coalesce(extras_penalty::integer, 0) as extra_penalty,

        -- Wicket Details
        wicket_kind::varchar as wicket_type, -- e.g., caught, bowled, run out
        wicket_player_out::varchar as player_dismissed_name,
        wicket_fielder_1::varchar as fielder_one_name,
        wicket_fielder_2::varchar as fielder_two_name,
        case when wicket_kind is not null then true else false end as is_wicket,

        -- Contextual Flags
        powerplay::boolean as is_powerplay, -- Assuming \'yes\'/'no\' or similar, adjust casting if needed
        super_over::boolean as is_super_over, -- Assuming 0/1 or similar, adjust casting if needed

        -- Target (if applicable, usually for 2nd innings)
        target_remaining::integer as target_runs_remaining,
        balls_remaining::integer as target_balls_remaining,

        -- Review Details (can be normalized later if needed)
        review_by::varchar as review_taken_by_team,
        review_umpire::varchar as review_umpire_name,
        review_batter::varchar as review_batter_name,
        review_decision::varchar as review_decision,
        review_type::varchar as review_type,
        review_umpires_call::boolean as is_review_umpires_call -- Assuming 0/1 or similar

        -- Ignoring replacement columns for now unless specifically needed

    from source

)

select * from renamed

