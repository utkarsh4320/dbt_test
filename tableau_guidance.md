# Tableau Dashboard Guidance for IPL Analytics

This document provides guidance on connecting Tableau to your Snowflake database and utilizing the `fct_match_summary` golden table created by the dbt project for building insightful dashboards.

## 1. Connecting Tableau to Snowflake

1.  **Open Tableau Desktop.**
2.  **Connect to Data:** Under the "Connect" pane, click on "More..." under "To a Server" and select "Snowflake".
3.  **Enter Connection Details:**
    *   **Server:** Enter your Snowflake account identifier (e.g., `xy12345.us-east-1`). You can find this in your `profiles.yml` file (`account` field).
    *   **Authentication:** Choose the authentication method you configured in `profiles.yml` (e.g., Username & Password, or OAuth using Okta/External Browser if configured).
    *   **Credentials:** Enter your Snowflake `user` and `password` (or follow the prompts for other methods).
    *   **Warehouse:** Specify the Snowflake `warehouse` you want Tableau to use for running queries (from `profiles.yml`).
    *   **Database:** Enter the `database` where your dbt models were built (from `profiles.yml`).
    *   **Schema:** Leave this blank initially or select the specific schema later.
4.  **Sign In:** Click "Sign In".

## 2. Selecting the Golden Table

1.  **Select Schema:** Once connected, in the Data Source tab, select the schema where the mart models were built. Based on the `dbt_project.yml`, this should be `MARTS` (or whatever you configured).
2.  **Drag Table:** Find the `FCT_MATCH_SUMMARY` table (Snowflake object names are typically uppercase unless quoted) in the list and drag it onto the canvas.
3.  **Review Data:** You should now see a preview of the data from the golden table.

## 3. Building Dashboard Visualizations (Examples)

The `fct_match_summary` table is designed for analysis and contains pre-aggregated match-level statistics. Here are some ideas for dashboards:

*   **Overall Match Analysis:**
    *   **Matches per Season:** Bar chart showing the count of matches (`Match ID`) by `Season`.
    *   **Win Distribution:** Pie chart or bar chart showing the count of matches (`Match ID`) by `Winning Team`.
    *   **Win Margin Analysis:** Histogram or box plot of `Win Margin`, potentially filtered by `Win By Type` (Runs/Wickets).
    *   **Toss Impact:** Stacked bar chart showing `Toss Decision` (Bat/Field) vs. `Match Result Type` or `Winning Team`.
*   **Team Performance Dashboard:**
    *   **Team Win/Loss Record:** Table or bar chart showing wins (count `Match ID` where `Winning Team` = Team Name) and losses per `Season` for a selected team.
    *   **Batting Performance (Select Team):** Line chart showing `teamX_total_runs_scored` and `teamX_run_rate` over `Match Date` or aggregated by `Season`.
    *   **Bowling Performance (Select Team):** Line chart showing `teamX_runs_conceded`, `teamX_wickets_taken`, and `teamX_economy_rate` over `Match Date` or aggregated by `Season`.
    *   **Head-to-Head:** Filter matches for two specific teams (`Team One`, `Team Two`) and compare their win records and performance metrics.
*   **Venue Insights:**
    *   **Matches per Venue:** Bar chart showing count of `Match ID` by `Venue` or `City`.
    *   **Venue Toss Advantage:** Analyze if `Toss Winner` = `Winning Team` more often at specific `Venue`s.
    *   **Venue Scoring:** Average `team1_total_runs_scored` + `team2_total_runs_scored` per match by `Venue`.
*   **Player Awards:**
    *   **Player of the Match Leaders:** Bar chart showing count of `Match ID` by `Player Of Match Name`, perhaps filtered by `Season`.

## 4. Tips for Tableau

*   **Use Filters:** Allow users to filter dashboards by `Season`, `Team One`, `Team Two`, `Venue`, etc.
*   **Calculated Fields:** While the golden table is pre-aggregated, you might create simple calculated fields in Tableau for ratios or specific comparisons if needed.
*   **Data Types:** Ensure Tableau correctly interprets data types (e.g., `Match Date` as Date, numerical fields as Numbers).
*   **Performance:** Since the data is in Snowflake and the table is aggregated, performance should generally be good. Use extracts if needed for very large datasets or offline access.

This guidance provides a starting point. Explore the fields in `fct_match_summary` to uncover more insights and build dashboards tailored to your specific analytical questions.
