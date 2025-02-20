#!/bin/bash

# Database credentials
DB_HOST="localhost"
DB_PORT="5432"
DB_NAME="agentlang"
DB_USER="aj-47"
DB_PASSWORD="anuraj314159"

# API endpoint
API_URL="http://localhost:8080/api/Resource/Employee"

# Fetch data from PostgreSQL
export PGPASSWORD=$DB_PASSWORD

QUERY="SELECT \"Email\", \"First Name\", \"Last Name\", \"Preferred Name\", \"Team\", \"Role\", \"HR Level\", 
              \"Resource Type\", \"Organization\", \"Hourly Rate ($)\", \"Average Weekly Hours\", \"Calculated Annual Rate\", 
              \"Manager Name\", \"Org Tree\", \"Status\", \"Start Date\", \"End Date\", \"Work Location\", \"Location Category\", \"Team_2\"
       FROM employee;"

# Execute query and process result
psql -h $DB_HOST -p $DB_PORT -U $DB_USER -d $DB_NAME -t -A -F "," -c "$QUERY" | while IFS=',' read -r email first_name last_name preferred_name team role hr_level resource_type organization hourly_rate avg_weekly_hours calculated_annual_rate manager_name org_tree status start_date end_date work_location location_category team_2
do
  # Construct JSON payload
  JSON_PAYLOAD=$(jq -n \
    --arg email "$email" \
    --arg first_name "$first_name" \
    --arg last_name "$last_name" \
    --arg preferred_name "$preferred_name" \
    --arg team "$team" \
    --arg role "$role" \
    --arg hr_level "$hr_level" \
    --arg resource_type "$resource_type" \
    --arg organization "$organization" \
    --arg hourly_rate "$hourly_rate" \
    --arg avg_weekly_hours "$avg_weekly_hours" \
    --arg calculated_annual_rate "$calculated_annual_rate" \
    --arg manager_name "$manager_name" \
    --arg org_tree "$org_tree" \
    --arg status "$status" \
    --arg start_date "$start_date" \
    --arg end_date "$end_date" \
    --arg work_location "$work_location" \
    --arg location_category "$location_category" \
    --arg team_2 "$team_2" \
    '{
      "MyCompany/Employee": {
        "Email": $email,
        "FirstName": $first_name,
        "LastName": $last_name,
        "PreferredName": $preferred_name,
        "Team": $team,
        "Role": $role,
        "HRLevel": $hr_level|tonumber,
        "ResourceType": $resource_type,
        "Organization": $organization,
        "HourlyRate": ($hourly_rate|tonumber)?,
        "AverageWeeklyHours": $avg_weekly_hours|tonumber,
        "CalculatedAnnualRate": ($calculated_annual_rate|tonumber)?,
        "ManagerName": $manager_name,
        "OrgTree": $org_tree,
        "Status": $status,
        "StartDate": $start_date,
        "EndDate": ($end_date)?,
        "WorkLocation": $work_location,
        "LocationCategory": $location_category,
        "Team_2": $team_2
      }
    }')

  # Send the request
  curl --location --request POST "$API_URL" \
    --header 'Content-Type: application/json' \
    --data-raw "$JSON_PAYLOAD"

  echo "Processed: $email"
done
