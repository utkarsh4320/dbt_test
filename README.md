# IPL Analytics dbt Project

This project processes raw IPL match and delivery data to create structured analytical models.

## Project Structure

- **`models/staging/ipl_data`**: Cleans and prepares raw data from the source (`ipl_raw_data.ipl_match_data` table in Snowflake).
  - `stg_ipl_data__matches`: Match-level details.
  - `stg_ipl_data__deliveries`: Ball-by-ball details.
- **`models/intermediate/dims`**: Dimension tables for entities like matches, players, teams, and venues.
- **`models/intermediate/facts`**: Fact tables, primarily `fct_deliveries` linking dimensions at the ball level.
- **`models/intermediate/agg`**: Aggregated tables for team performance at match and season levels (batting and bowling).
- **`models/marts/core`**: Final "golden" table (`fct_match_summary`) combining match details with team performance metrics, suitable for BI tools.

## Setup

1.  **Clone/Copy Project:** Place this project directory on your system.
2.  **Configure Snowflake Connection:**
    *   Copy `profiles.yml.example` to `~/.dbt/profiles.yml` (or a location specified by the `DBT_PROFILES_DIR` environment variable).
    *   Edit `profiles.yml` and fill in your Snowflake account details (account identifier, user, password/key, role, database, warehouse).
3.  **Load Raw Data:** Ensure the source data (`ipl_match_data.csv`) is loaded into a Snowflake table named `ipl_match_data` within the database and schema specified as the source in `models/staging/ipl_data/sources.yml` (you might need to adjust the database/schema in `sources.yml` to match where you loaded it).
4.  **Install Dependencies (if needed):**
    *   Create `packages.yml` in the project root with:
      ```yaml
      packages:
        - package: dbt-labs/dbt_utils
          version: ["~> 1.0"] # Or latest compatible version
      ```
    *   Run `dbt deps` in the project directory.
5.  **Run dbt:**
    *   Navigate to the project directory (`ipl_dbt_project`).
    *   Run `dbt run` to build all models.
    *   Run `dbt test` to execute tests defined in the YAML files.
    *   Run `dbt docs generate` and `dbt docs serve` to view the project documentation and lineage graph.

## Tableau Dashboard

Refer to `tableau_guidance.md` for instructions on connecting Tableau to Snowflake and using the `fct_match_summary` table.

## Model Flow (Lineage)

The lineage follows this path:

`Source Table` -> `Staging Models` -> `Dimension & Fact Models` -> `Aggregation Models` -> `Mart Models (fct_match_summary)`

You can visualize the exact dependencies using `dbt docs generate`.

