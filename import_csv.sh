#!/bin/bash

# API endpoint
API_URL="http://localhost:8080/api/Resource/Employee"

# CSV file path
CSV_FILE="/Users/aj-47/Dev/Resource_1.csv"

# Read the CSV file and process each line (skipping header)
tail -n +2 "$CSV_FILE" | while IFS=',' read -r first_name last_name preferred_name team role hr_level resource_type organization hourly_rate avg_weekly_hours calculated_annual_rate manager_name org_tree status start_date end_date work_location location_category email team_2
do
  # Construct JSON payload
  JSON_PAYLOAD=$(jq -n \
    --arg first_name "$first_name" \
    --arg last_name "$last_name" \
    --arg preferred_name "$preferred_name" \
    --arg team "$team" \
    --arg role "$role" \
    --arg hr_level "$hr_level" \
    --arg resource_type "$resource_type" \
    --arg organization "$organization" \
    --arg avg_weekly_hours "$avg_weekly_hours" \
    --arg manager_name "$manager_name" \
    --arg org_tree "$org_tree" \
    --arg status "$status" \
    --arg start_date "$start_date" \
    --arg end_date "$end_date" \
    --arg work_location "$work_location" \
    --arg location_category "$location_category" \
    --arg email "$email" \
    --arg team_2 "$team_2" \
    --argjson hourly_rate "$(if [[ -n "$hourly_rate" ]]; then echo "$hourly_rate"; else echo "null"; fi)" \
    --argjson calculated_annual_rate "$(if [[ -n "$calculated_annual_rate" ]]; then echo "$calculated_annual_rate"; else echo "null"; fi)" \
    '{
      "Resource/Employee": {
        "FirstName": $first_name,
        "LastName": $last_name,
        "PreferredName": $preferred_name,
        "Team": $team,
        "Role": $role,
        "HRLevel": ($hr_level|tonumber),
        "ResourceType": $resource_type,
        "Organization": $organization,
        "HourlyRate": $hourly_rate,
        "AverageWeeklyHours": ($avg_weekly_hours|tonumber),
        "CalculatedAnnualRate": $calculated_annual_rate,
        "ManagerName": $manager_name,
        "OrgTree": $org_tree,
        "Status": $status,
        "StartDate": $start_date,
        "EndDate": ($end_date),
        "WorkLocation": $work_location,
        "LocationCategory": $location_category,
        "Email": $email,
        "Team_2": $team_2
      }
    }')

  # echo "$JSON_PAYLOAD"
  # Send the request
  curl --location --request POST "$API_URL" \
    --header 'Content-Type: application/json' \
    --data-raw "$JSON_PAYLOAD"

  echo "Processed: $email"
done
