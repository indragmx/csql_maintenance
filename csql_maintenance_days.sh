#!/bin/bash

# Get the list of Cloud SQL instance names
instance_names=$(gcloud sql instances list --format='value(name)')

# Initialize an empty string to store the output
output=""
echo -n "" > cloud_sql_info.txt

# Loop through each instance name and get the maintenance version
while IFS= read -r instance; do
  maintenance_version=$(gcloud sql instances describe "$instance" --format='value(maintenanceVersion)')
  mv_temp=$(echo $maintenance_version | cut -d . -f 2)
  mv_yyymmdd=$(echo $mv_temp | cut -c 2-9)
  available_maintenance_version=$(gcloud sql instances describe "$instance" --format='value(availableMaintenanceVersions)')
  amv_temp=$(echo $available_maintenance_version | cut -d . -f 2)
  amv_yyymmdd=$(echo $amv_temp | cut -c 2-9)

  date1_epoch=$(date -d "$mv_yyymmdd" +%s)
  date2_epoch=$(date -d "$amv_yyymmdd" +%s)
  difference_seconds=$((date2_epoch - date1_epoch))
  difference_days=$((difference_seconds / 86400))

  output+="$instance - $maintenance_version ($mv_yyymmdd) - $available_maintenance_version ($amv_yyymmdd) - Different: $difference_days Days"
  echo "$output" >> cloud_sql_info.txt
  output=""
done <<< "$instance_names"

echo "Successfully retrieved Cloud SQL instance names and maintenance versions and saved to cloud_sql_info.txt"
