(component :Resource.Core)

(entity :Employee
  {:FirstName :String
   :LastName :String
   :PreferredName :String
   :Team :String
   :Role :String
   :HRLevel :BigInteger
   :ResourceType :String
   :Organization :String
   :HourlyRate {:type :BigInteger :optional true}
   :AverageWeeklyHours :BigInteger
   :CalculatedAnnualRate {:type :BigInteger :optional true}
   :ManagerName :String
   :OrgTree :String
   :Status :String
   :StartDate :String
   :EndDate {:type :String :optional true}
   :WorkLocation :String
   :LocationCategory :String
   :Email {:type :Email :guid true}
   :Team_2 :String})

(event :GetEmployee
  {:Email :Email})

(dataflow :GetEmployee
  {:Resource.Core/Employee
   {:Email? :GetEmployee.Email}
   :as [:Employee]})
   
(event :CreateEmployee
  {:FirstName :String
   :LastName :String
   :PreferredName :String
   :Team :String
   :Role :String
   :HRLevel :BigInteger
   :ResourceType :String
   :Organization :String
   :HourlyRate {:type :BigInteger :optional true}
   :AverageWeeklyHours :BigInteger
   :CalculatedAnnualRate {:type :BigInteger :optional true}
   :ManagerName :String
   :OrgTree :String
   :Status :String
   :StartDate :String
   :EndDate {:type :String :optional true}
   :WorkLocation :String
   :LocationCategory :String
   :Email {:type :Email :guid true}
   :Team_2 :String})

(dataflow :CreateEmployee
  {:Resource.Core/Employee
   {:FirstName :CreateEmployee.FirstName
    :LastName :CreateEmployee.LastName
    :PreferredName :CreateEmployee.PreferredName
    :Team :CreateEmployee.Team
    :Role :CreateEmployee.Role
    :HRLevel :CreateEmployee.HRLevel
    :ResourceType :CreateEmployee.ResourceType
    :Organization :CreateEmployee.Organization
    :HourlyRate :CreateEmployee.HourlyRate
    :AverageWeeklyHours :CreateEmployee.AverageWeeklyHours
    :CalculatedAnnualRate :CreateEmployee.CalculatedAnnualRate
    :ManagerName :CreateEmployee.ManagerName
    :OrgTree :CreateEmployee.OrgTree
    :Status :CreateEmployee.Status
    :StartDate :CreateEmployee.StartDate
    :EndDate :CreateEmployee.EndDate
    :WorkLocation :CreateEmployee.WorkLocation
    :LocationCategory :CreateEmployee.LocationCategory
    :Email :CreateEmployee.Email
    :Team_2 :CreateEmployee.Team_2}})


(event :UpdateEmployee
  {:FirstName {:type :String :optional true}
   :LastName {:type :String :optional true}
   :Email {:type :Email :optional true}
   :Role {:type :String :optional true}
   :HourlyRate {:type :BigInteger :optional true}})

(dataflow :UpdateEmployee
  [:try
   ;; Step 1: If Email is missing, fetch it using FirstName & LastName
   {:Resource.Core/Employee
    {:FirstName? :UpdateEmployee.FirstName
     :LastName? :UpdateEmployee.LastName}
    :as [:Employee]}
   
   ;; Step 2: If Employee is found, update the details
   :ok
   [{:Resource.Core/Employee
     {:Email? :Employee.Email}
     :set {:Role :UpdateEmployee.Role
           :HourlyRate :UpdateEmployee.HourlyRate}}]
   
   ;; Step 3: If No Employee Found, Return Error
   :not-found
   [{:error "No employee found with the given name. Provide an Email for updates."}]])


(event :DeleteEmployee
  {:Email :Email})

(dataflow :DeleteEmployee
  {:Resource.Core/Employee
   {:Email? :DeleteEmployee.Email}
   :delete true})

(event :ListEmployees {})

(dataflow :ListEmployees
  {:Resource.Core/Employee
   {} :as [:Employees]})

{:Agentlang.Core/Agent
 {:Name :resource-agent
  :Type :planner
  :Tools [:Resource.Core/Employee
          :Resource.Core/CreateEmployee
          :Resource.Core/GetEmployee
          :Resource.Core/UpdateEmployee
          :Resource.Core/DeleteEmployee
          :Resource.Core/ListEmployees]
  :UserInstruction "You are a resource management agent responsible for handling employee records. 
  - If the user requests to create an employee, call `CreateEmployee`.
  - If the user requests to retrieve an employee's details, call `GetEmployee`.
  - If the user requests to update an employee, use `UpdateEmployee`. The update must always be performed using the employee's `Email`. If only the name is provided, first fetch the employee's `Email` using `GetEmployee`, then update.
  - If the user requests to delete an employee, use `DeleteEmployee`.
  - If the user requests to list all employees, use `ListEmployees`."
  :Input :Resource.Core/InvokeAgent}}