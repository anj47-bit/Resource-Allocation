(component :Company)

(entity :Company/Employee
 {:Email {:type :Email :guid true}
  :FirstName :String
  :LastName :String
  :PreferredName :String
  :Team :String
  :Role :String
  :HRLevel :BigInteger
  :ResourceType :String
  :Organization :String
  :HourlyRate :BigInteger
  :AverageWeeklyHours :BigInteger
  :CalculatedAnnualRate :BigInteger
  :ManagerName :String
  :OrgTree :String
  :Status :String
  :StartDate :String
  :EndDate :String
  :WorkLocation :String
  :LocationCategory :String
  :Team_2 :String})

(import '(java.net URL HttpURLConnection)
        '(java.io BufferedReader InputStreamReader))

;; Function to make an HTTP GET request using Java interop
(defn http-get [url]
  (let [url-obj (URL. url)
        connection (.openConnection url-obj)]
    (.setRequestMethod connection "GET")
    (.connect connection)
    (let [reader (BufferedReader. (InputStreamReader. (.getInputStream connection)))]
      (let [response (apply str (line-seq reader))]
        (.close reader)
        response))))

;; Function to extract JSON key-value pairs using regex
(defn extract-json-value [json-string key]
  (let [pattern (re-pattern (str "\"" key "\"\\s*:\\s*\"?([^\",]+)\"?"))]
    (second (re-find pattern json-string))))

;; Function to fetch and parse all employee fields
(defn get-employee-by-email [email]
  (let [response (http-get (str "http://localhost:8000/api/employees/" email))]
    {:first_name (extract-json-value response "first_name")
     :last_name (extract-json-value response "last_name")
     :preferred_name (extract-json-value response "preferred_name")
     :email (extract-json-value response "email")
     :role (extract-json-value response "role")
     :team (extract-json-value response "team")
     :team_2 (extract-json-value response "team_2")
     :manager_name (extract-json-value response "manager_name")
     :status (extract-json-value response "status")
     :organization (extract-json-value response "organization")
     :org_tree (extract-json-value response "org_tree")
     :location_category (extract-json-value response "location_category")
     :work_location (extract-json-value response "work_location")
     :resource_type (extract-json-value response "resource_type")
     :start_date (extract-json-value response "start_date")
     :end_date (extract-json-value response "end_date")
     :annual_rate (extract-json-value response "annual_rate")
     :hourly_rate (extract-json-value response "hourly_rate")
     :avg_weekly_hours (extract-json-value response "avg_weekly_hours")
     :hr_level (extract-json-value response "hr_level")}))

(resolver :Company/EmployeeResolver
 {:with-methods
   {:query (fn [[entity-name query]]
             (let [[opr attr value] (:where query)]
               (when (and (= opr :=) (= attr :Email))
                    (println (str "looking up " value))
                    (println (get-employee-by-email value))
                 (when-let [employee (get-employee-by-email value)]
                    [employee]))))}
  :paths [:Company/Employee]})