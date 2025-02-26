# Set variables
$CUSTOMER = "JoelBieber"    
$DB_USER = "postgres"       
$DB_PASS = "SAsuper"        
$DB_HOST = "localhost"
$DB_PORT = "5432"
$DB_NAME = "${CUSTOMER}_backup".ToLower()
$GCS_BUCKET = "growpath-${CUSTOMER}-storage-export"
$BACKUP_FILE = "D:\Needles-JoelBieber\trans\Grow Path\db.xz"
$DB_CONNECTION_STRING = "postgresql://$($DB_USER):$($DB_PASS)@$($DB_HOST):$($DB_PORT)"

# Unzip database
Write-Host "Unzipping db.xz to file db"
7z e db.xz -so > "db.bak"

# Create a new PostgreSQL database
Write-Host "Creating database '$DB_NAME'"
psql -c "CREATE DATABASE `"$DB_NAME`";" -U $DB_USER -h $DB_HOST -p $DB_PORT

# Load the backup
Write-Host "Decompressing and loading the backup into database '$DB_NAME'"
# & 'C:\Program Files\7-Zip\7z.exe' e $BACKUP_FILE -so | psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME
psql -h $DB_HOST -U $DB_USER -d $DB_NAME -f "db"

# Export 
