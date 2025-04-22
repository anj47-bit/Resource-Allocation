(component :ResourceAllocation.Core 
           {:refer [:ResourceAllocation.Schema
                    :ResourceAllocation.Slack]
            :clj-import [(:use [agentlang.inference.service.channel.cmdline]
                               [agentlang.inference.service.planner])]})

;; ——————————————
;; Count‐Resources DataFlow
;; ——————————————

;; (event :ResourceAllocation.Core/CountResources
;;         {})

;; (dataflow :ResourceAllocation.Core/CountResources
;;   {:ResourceAllocation.Schema/Resource {} :as [:resources]}
;;   {:ResourceCount
;;    {:Count? (fn [{:keys [resources]}]
;;                 (count resources))}})

;; (dataflow :CountResources
;;   ;; source: grab all Resource entities
;;   {:ResourceAllocation.Schema/Resource {}}
;;   ;; transform: apply Clojure’s count fn to the resulting sequence
;;   ;; the single arrow mapping means “take the vector of resources,
;;   ;; pass it to this fn, and emit that number as the flow’s result”
;;   :-> [(fn [resources]
;;          (count resources))])


{:Agentlang.Core/LLM {:Name :llm01}}

;; =====================
;; Agent Definition
;; =====================

(def agent-msg "I'm an intelligent agent who will help you manage the resources database.")

{:Agentlang.Core/Agent
 {:Name :Resource.Core/Agent
  :LLM :llm01
  :Channels [{:channel-type :default
              :name :ResourceAllocation.Core/HttpChannel}
             {:channel-type :cmdline
              :name :ResourceAllocation.Core/ReplChannel
              :doc agent-msg}
              {:channel-type :slack
              :name :Family.Core/SlackChannel
              :doc agent-msg}
             ]
  :Tools [:ResourceAllocation.Schema/Resource
          :ResourceAllocation.Schema/Project
          :ResourceAllocation.Schema/Allocation]
        ;;   :ResourceAllocation.Core/CountResources
  :UserInstruction (str "Based on user input, either\n"
                        "Only perform the actions which \n"
                        "1. create a resource, project or allocation. Before creating a resource ask confirmation from the user.
                             - If a date is given for creating a resource. Ex: 21st Feb, 2024 -> 2024-02-21
                             - If the first letter of the first name and last name is in lower case convert the first letter to upper case.
                                Ex: muazzam -> Muazzam.
                                Also whichever attribute is default don't ask to provide a value for it.
                             \n"
                        "2. If asked to count the number of resource return the total number of resource entities by counting."
                        "3. If a user asks to list all resources. List them without any criteria."
                        "4. query a resource, project or allocation.\n"
                        "5. delete a resource, project or allocation.\n"
                        "6. update a resource, project or allocation.\n")}}

;; Sample request: create a new resource, first name: muazzam, last name: ali, preferred name: muazzam, email: muazzam@gmail.com, role: software engineer, team: software, status: Active, Work Location: US
;; create a project with name: beta with owner: daniel status: Active, start date: 4th April, 2024, Terminated type: RTB Costcurrency: USD, description: project for now