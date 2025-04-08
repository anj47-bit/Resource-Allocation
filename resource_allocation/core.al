(component :ResourceAllocation.Core
{:clj-import [(:use [agentlang.inference.service.channel.cmdline])]})

;; =====================
;; Entity Definitions
;; =====================

(entity :Resource
        {:Id :Identity
         :FirstName :String
         :LastName :String
         :PreferredName :String
         :Email {:type :Email :unique true}
         :Role :String
         :Team :String
         :Status {:oneof ["Active" "Inactive"]}
         :WorkLocation :String
         :rbac [{:roles ["admin"] :allow [:create :update :read :delete]}
                {:roles ["user"] :allow [:read]}]
         :meta {:audit :true}})

(entity :Project
        {:Id :Identity
         :Name {:type :String :unique true}
         :Owner :String
         :Manager :String
         :Description :String
         :Status {:oneof ["Active" "Completed" "Paused" "Proposed" "Terminated"]
                  :default "Active"}
         :Type {:oneof ["Key Initiative" "RTB" "Ongoing"]}
         :Location {:type :String :optional true}
         :StartDate :Date
         :EndDate {:type :Date :optional true}
         :Cost {:type :Int :optional true}
         :CostCurrency {:type :String :default "USD"}
         :AllowOvertime {:type :Boolean :default true}
         :rbac [{:roles ["admin"] :allow [:create :update :read :delete]}
                {:roles ["user"] :allow [:read]}]
         :meta {:audit :true}})

(entity :Allocation
        {:GlobalId {:type :UUID :id true :default agentlang.util/uuid-string}
         :Id {:type :UUID :id true :default agentlang.util/uuid-string}
         :Resource :UUID ; Link to Resource.Id
         :Project :UUID ; Link to Project.Id
         :ProjectName :String
         :Period {:type :String :indexed true}
         :Duration {:oneof ["day" "week" "month" "year"] :default "week"}
         :AllocationEntered {:type :Double :check (fn [num] (and (number? num) (<= 0 num 2)))}
         :Notes {:type :String :optional true}
         :ExOverAllocated {:type :Boolean :default false}
         :ExUnderAllocated {:type :Boolean :default false}
         :rbac [{:roles ["admin"] :allow [:create :update :read :delete]}
                {:roles ["user"] :allow [:read]}]
         :meta {:audit :true}})

(entity :Team
  {:Id :Identity
   :Name {:type :String :unique true}
   :Status {:oneof ["Active" "Inactive"] :default "Active"}
   :rbac [{:roles ["admin"] :allow [:create :update :read :delete]}
          {:roles ["user"] :allow [:read]}]
   :meta {:audit true}})



;; =====================
;; Relationships
;; =====================

;; (relationship :ResourceAllocations
;;               {:meta {:between [:ResourceAllocation.Core/Resource :ResourceAllocation.Core/Allocation]}})

;; (relationship :ProjectAllocations
;;               {:meta {:between [:ResourceAllocation.Core/Project :ResourceAllocation.Core/Allocation]}})


(event :CreateResource
       {:FirstName :String
        :LastName :String
        :PreferredName :String
        :Email :Email
        :Role :String
        :Team :String
        :Status {:oneof ["Active" "Inactive"]}
        :WorkLocation :String})

(dataflow :CreateResource
          {:ResourceAllocation.Core/Resource
           {:FirstName :CreateResource.FirstName
            :LastName :CreateResource.LastName
            :PreferredName :CreateResource.PreferredName
            :Email :CreateResource.Email
            :Role :CreateResource.Role
            :Team :CreateResource.Team
            :Status :CreateResource.Status
            :WorkLocation :CreateResource.WorkLocation}})

(event :CreateProject
       {:Name :String
        :Owner :String
        :Manager :String
        :Description :String
        :Status {:oneof ["Active" "Completed" "Paused" "Proposed" "Terminated"]}
        :Type {:oneof ["Key Initiative" "RTB" "Ongoing"]}
        :Location {:type :String :optional true}
        :StartDate :Date
        :EndDate {:type :Date :optional true}
        :Cost {:type :Int :optional true}
        :CostCurrency {:type :String :default "USD"}
        :AllowOvertime {:type :Boolean :default true}})

(dataflow :CreateProject
          {:ResourceAllocation.Core/Project
           {:Name :CreateProject.Name
            :Owner :CreateProject.Owner
            :Manager :CreateProject.Manager
            :Description :CreateProject.Description
            :Status :CreateProject.Status
            :Type :CreateProject.Type
            :Location :CreateProject.Location
            :StartDate :CreateProject.StartDate
            :EndDate :CreateProject.EndDate
            :Cost :CreateProject.Cost
            :CostCurrency :CreateProject.CostCurrency
            :AllowOvertime :CreateProject.AllowOvertime}})

(event :AllocateResource
       {:ResourceEmail :Email
        :ProjectName :String
        :Period :String
        :Duration {:oneof ["day" "week" "month" "year"]}
        :AllocationEntered :Double
        :Notes {:type :String :optional true}})

(dataflow :AllocateResource
          [:try

   ;; Step 1: Find Resource by Email
           {:ResourceAllocation.Core/Resource
            {:Email? :AllocateResource.ResourceEmail}
            :as [:Resource]}

   ;; Step 2: If Resource found,
           :ok
           [{:ResourceAllocation.Core/Project
             {:Name? :AllocateResource.ProjectName}
             :as [:Project]}

    ;; Step 3: If Project found, create the Allocation
            {:ResourceAllocation.Core/Allocation
             {:Resource :Resource.Id
              :Project :Project.Id
              :ProjectName :Project.Name
              :Period :AllocateResource.Period
              :Duration :AllocateResource.Duration
              :AllocationEntered :AllocateResource.AllocationEntered
              :Notes :AllocateResource.Notes}}

    ;; Step 4: Create Relationships
        ;;     {:-> [[{:ResourceAllocation.Core/ResourceAllocations {}} :Resource]
        ;;           [{:ResourceAllocation.Core/ProjectAllocations {}} :Project]]}
                ]

   ;; Step 5: If Resource Not Found
           :not-found
           [{:error "Resource not found with the provided email."}]])


;; =====================
;; Agent Definition
;; =====================

(def agent-msg "I'm an intelligent agent who will help you manage the family database.")

{:Agentlang.Core/Agent
 {:Name :resource-agent
  :Tools [:ResourceAllocation.Core/Resource
          :ResourceAllocation.Core/Project
          :ResourceAllocation.Core/Allocation]
  :Channels [{:channel-type :default
              :name :ResourceAllocation.Core/HttpChannel}
             {:channel-type :cmdline
              :name :ResourceAllocation.Core/ReplChannel
              :doc agent-msg}]
  :UserInstruction "You are a resource management agent responsible for handling resources, projects, and allocations."
  :Input :ResourceAllocation.Core/InvokeAgent}}
