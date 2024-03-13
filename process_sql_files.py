import pandas as pd
from openai import OpenAI
import os
import json

client = OpenAI(
    api_key=os.environ.get("OPENAI_API_KEY"),
)

sql_files_path = r"C:\Users\username\Documents\sql_queries_testing"

master_df_tables = pd.DataFrame(columns=["Table Name"])
master_df_columns = pd.DataFrame(columns=["Column Name"])

def analyze_sql_query(client, sql_query, master_df_tables, master_df_columns):
    """
    This function sends a SQL query to the GPT model, processes the response, and updates the master DataFrames.

    :param client: OpenAI client instancet that is defined above
    :param sql_query: SQL query to analyze
    :param master_df_tables: DataFrame for table names to append the output to
    :param master_df_columns: DataFrame for column names to append the output to
    :return: Updated master DataFrames with new table and column names.
    """
    prompt = f"Analyze the following SQL query: '{sql_query}'. Extract and return in JSON format two separate lists: the first list - list name - Tables - should contain all fully qualified table names without duplicates, and the second list - list name - Columns should include all column names with their full qualifier names (table.column), resolving any aliases to their original table and column names. Ensure that both lists are unique and no names are repeated."

    # Send the prompt to the model
    model_instance = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {
                "role": "user",
                "content": prompt,
            },
        ],
    )

    #Extract the response content
    json_response = model_instance.choices[0].message.content

    #parse the JSON response
    data = json.loads(json_response)

    #Loading JSON data to two their respective DataFrames
    df_table_names = pd.DataFrame(data["Tables"], columns=["Table Name"])
    df_column_names = pd.DataFrame(data["Columns"], columns=["Column Name"])

    # Concatenate new results to the master lists
    master_df_tables = pd.concat([master_df_tables, df_table_names]).drop_duplicates().reset_index(drop=True)
    master_df_columns = pd.concat([master_df_columns, df_column_names]).drop_duplicates().reset_index(drop=True)

    return master_df_tables, master_df_columns

for filename in os.listdir(sql_files_path):
    if filename.lower().endswith(".sql"):
        with open(os.path.join(sql_files_path, filename), 'r') as file:
            sql_query = file.read()
        
        # Call the function with the desired parameters for each SQL file
        master_df_tables, master_df_columns = analyze_sql_query(client, sql_query, master_df_tables, master_df_columns)

#Writing to an excel file in separate excel sheets
with pd.ExcelWriter(excel_file_path, engine='openpyxl') as writer:
    master_df_tables.to_excel(writer, sheet_name='Tables', index=False)
    master_df_columns.to_excel(writer, sheet_name='Columns', index=False)

