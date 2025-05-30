import os
from read_yaml_metadata import read_yaml_metadata
from setup_logger import setup_logger

logger = setup_logger(__name__, log_file="generate_readme.log")

def generate_readmes_for_sql_files(sql_dir):
    """
    Generate a _README.md file in every directory that contains .sql files.

    Args:
        sql_dir (str): Path to the 'sql' directory.
    """
    for dirpath, _, filenames in os.walk(sql_dir):
        # Skip directories that start with an underscore
        if any(part.startswith("_") for part in dirpath.split(os.sep)):
            continue

        # Find all .sql files in sql_dir
        sql_files = [f for f in filenames if f.lower().endswith(".sql")]

        if sql_files:
            readme_path = os.path.join(dirpath, "_README.md")
            relative_path = os.path.relpath(dirpath, sql_dir)

            # Generate content for the README.md file
            content = f"# {relative_path.replace(os.sep, ' ').title()}\n\n"
            content += "| Script Name | Description |\n"
            content += "|-------------|-------------|\n"
            # content += "| Script Name | Description | Dependencies |\n"
            # content += "|-------------|-------------|-------------|\n"
            for sql_file in sorted(sql_files):
                file_path = os.path.join(dirpath, sql_file)
                metadata = read_yaml_metadata(file_path)
                description = metadata.get("description", "") if metadata else "No metadata found"
                # dependencies = metadata.get("dependencies", "") if metadata else "No metadata found"
                content += f"| {sql_file} | {description} |\n"
                # content += f"| {sql_file} | {description} | {dependencies} |\n"

            # Write the content to the README.md file
            with open(readme_path, "w", encoding="utf-8") as readme_file:
                readme_file.write(content)

            print(f"Created {readme_path}")

if __name__ == "__main__":
    # Define the root directories for SQL files
    sql_dirs = [
        r'D:\vance-law\needles\conversion'
    ]

    # Iterate over each directory and generate README.md files
    for sql_dir in sql_dirs:
        try:
            sql_dir = os.path.abspath(sql_dir)  # Convert to absolute path
            logger.debug(f"Processing directory: {sql_dir}")

            # Check if the directory exists
            if not os.path.exists(sql_dir):
                logger.error(f"Directory does not exist: {sql_dir}")
                continue

            generate_readmes_for_sql_files(sql_dir)
            logger.info(f"Generated readme in {sql_dir}")

        except Exception as e:
            logger.error(f"Error processing directory {sql_dir}: {e}")
            continue