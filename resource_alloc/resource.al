(component :Resource)

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

{:Agentlang.Core/Agent
 {:Name :resource-agent
  :Type :planner
  :Tools [:Resource/Employee]
  :Input :Resource/InvokeAgent}}

