from datetime import datetime

from cosmos import DbtDag, ProjectConfig, ProfileConfig

from include.profiles import airflow_db
from include.constants import jaffle_shop_path, venv_execution_config

simple_dag = DbtDag(
    # dbt/cosmos-specific parameters
    project_config=ProjectConfig(jaffle_shop_path),
    profile_config=ProfileConfig(
        # these map to dbt/jaffle_shop/profiles.yml
        profile_name="airflow_db",
        target_name="dev",
        profiles_yml_filepath=jaffle_shop_path / "profiles.yml",
    ),
    execution_config=venv_execution_config,
    # normal dag parameters
    schedule_interval="@daily",
    start_date=datetime(2023, 1, 1),
    catchup=False,
    dag_id="dag_ota_daily",
    tags=["ota_daily"],
)
