# Quick script to demo getting data from HDX using search
# Documentation: https://hdx-python-api.readthedocs.io/en/latest/
# Search URL: https://data.humdata.org/search?q=kenya+food+security&ext_search_source=main-nav
# API: https://docs.ckan.org/en/2.9/api/legacy-api.html?highlight=search#search-resources

from hdx.utilities.easy_logging import setup_logging
from hdx.api.configuration import Configuration
from hdx.data.dataset import Dataset
import pandas as pd

setup_logging()

Configuration.create(hdx_site="prod", user_agent="A_Quick_Example", hdx_read_only=True)

datasets = Dataset.search_in_hdx()

# Get the datasets
datasets = Dataset.search_in_hdx("kenya food security",rows=1000)
datasets_df = pd.DataFrame(datasets)
datasets_df.to_csv('datasets.csv')

# Get the resources for each dataset
#resources = Dataset.get_all_resources(datasets)
#resources_df = pd.DataFrame(resources)
#resources_df.to_csv('resources.csv')

