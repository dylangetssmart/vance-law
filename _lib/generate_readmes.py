import os
import yaml
import chardet

def detect_encoding(file_path):
    """Detect the encoding of a file using chardet."""
    with open(file_path, 'rb') as file:
        raw_data = file.read()
        result = chardet.detect(raw_data)
    return result['encoding']

def extract_yaml_metadata(sql_file):
    """
    Extract YAML metadata from a comment block at the top of an SQL file.

    Args:
        sql_file (str): Path to the SQL file.

    Returns:
        dict: Parsed YAML metadata as a dictionary, or None if no metadata is found.
    """
    try:
        with open(sql_file, 'r', encoding=detect_encoding(sql_file)) as file:
            lines = file.readlines()

        yaml_content = []
        in_metadata_block = False

        for line in lines:
            stripped_line = line.strip()
            if line.strip().startswith('/* ######################################################################################') and not in_metadata_block:
                in_metadata_block = True
            elif stripped_line.endswith('*/') and in_metadata_block:
                break
            elif in_metadata_block:
                yaml_content.append(stripped_line.lstrip('*').strip())

        if yaml_content:
            try:
                return yaml.safe_load('\n'.join(yaml_content))
            except yaml.YAMLError as e:
                print(f"Error parsing YAML metadata in {sql_file}: {e}")
        return None
    except UnicodeDecodeError as e:
        print(f"Error reading file {sql_file}: {e}")
        return None
def generate_readmes_for_sql_files(sql_dir):
    """
    Generate a README.md file in every directory that contains .sql files.

    Args:
        sql_dir (str): Path to the 'sql' directory.
    """
    for dirpath, _, filenames in os.walk(sql_dir):
        # Skip directories that start with an underscore
        if any(part.startswith("_") for part in dirpath.split(os.sep)):
            continue

        # Find all .sql files in the current directory
        sql_files = [f for f in filenames if f.lower().endswith(".sql")]

        if sql_files:
            readme_path = os.path.join(dirpath, "README.md")
            relative_path = os.path.relpath(dirpath, sql_dir)

            # Generate content for the README.md file
            content = f"# {relative_path.replace(os.sep, ' ').title()}\n\n"
            content += "| Script Name | Description | Dependencies |\n"
            content += "|-------------|-------------|-------------|\n"
            for sql_file in sorted(sql_files):
                file_path = os.path.join(dirpath, sql_file)
                metadata = extract_yaml_metadata(file_path)
                description = metadata.get("description", "") if metadata else "No metadata found"
                dependencies = metadata.get("dependencies", "") if metadata else "No metadata found"
                content += f"| {sql_file} | {description} | {dependencies} |\n"

            # Write the content to the README.md file
            with open(readme_path, "w", encoding="utf-8") as readme_file:
                readme_file.write(content)

            print(f"Created {readme_path}")

if __name__ == "__main__":
    # Define the root SQL directory
    sql_dir = "sql"  # Adjust this path if necessary
    generate_readmes_for_sql_files(sql_dir)
