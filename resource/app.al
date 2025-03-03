(component :MyApp)

(entity :MyApp/Employee
 {:FirstName :String
  :LastName :String
  :PreferredName :String
  :Team :String
  :Role :String
  :HRLevel :BigInt
  :ResourceType :String
  :Organization :String
  :HourlyRate :BigInt
  :AverageWeeklyHours :BigInt
  :AnnualRate :BigInt
  :ManagerName :String
  :OrgTree :String
  :Status :String
  :StartDate :String
  :EndDate :String
  :WorkLocation :String
  :LocationCategory :String
  :Email {:type :Email :guid true}
  :Team2 :String})

;; API Endpoint Configuration
(def api-url "http://localhost:8000/api/employees")

;; Create/Update Employee
(defn upsert [inst]
  (println (str "Upserting employee " (:Email inst)))
  (http/post api-url {:body inst})
  inst)

;; Delete Employee
(defn delete [inst]
  (println (str "Deleting employee " (:Email inst)))
  (http/delete (str api-url "/" (:Email inst)))
  inst)

;; Query Employee
(defn query [[entity-name query]]
  (let [[opr attr value] (:where query)]
    (when (and (= opr :=) (= attr :Email))
      (println (str "Looking up employee " value))
      (when-let [inst (http/get (str api-url "/" value))]
        [inst]))))

(resolver :MyApp/EmployeeResolver
  {:with-methods
   {:create upsert
    :update upsert
    :delete delete
    :query query}
   :paths [:MyApp/Employee]})
