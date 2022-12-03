# HDX Metadata

These files are examples of the data returned from HDX metadata methods, and have been formatted for readability.

See python notebook hdx_api_exploration.ipynb for more detailed code examples.

1. File `hdx_dataset_example.json` is the result of running the following commands and then formatting the output with a JSON formatter:

   `hdx_dataset = Dataset.read_from_hdx('kenya-who-is-doing-what-and-where-2017')`

   `print(hdx_dataset)`

2. File `hdx_resource_example.json` is the result of running the following command and then formatting the output with a JSON formatter:

   `print(hdx_dataset.resources[0])`


3. File `hdx_data_example.json` is the result of running the following command and then formatting the output with a JSON formatter:

   `print(hdx_dataset.data)`