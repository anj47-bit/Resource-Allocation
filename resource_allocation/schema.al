(component :ResourceAllocation.Schema)

;; =====================
;; Entity Definitions
;; =====================

;; (entity :ResourceCount
;;         {:Count :Int})

(entity :Resource
        {:Id {:type :Identity :default agentlang.util/uuid-string}
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
        {:Id {:type :Identity :default agentlang.util/uuid-string}
         :Name {:type :String :unique true}
         :Owner :String
         :Description {:type :String :optional true}
         :Status {:oneof ["Active" "Completed" "Paused" "Proposed" "Terminated"]
                  :default "Active"}
         :Type {:oneof ["Key Initiative" "RTB" "Ongoing"]}
         :Location {:type :String :optional true}
         :StartDate {:type :Date :optional true}
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