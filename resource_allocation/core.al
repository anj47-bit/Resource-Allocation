(component :ResourceAllocation.Core 
           {:refer [:ResourceAllocation.Schema]
            :clj-import [(:use [agentlang.inference.service.channel.cmdline])]})


{:Agentlang.Core/LLM {:Name :llm01}}

;; =====================
;; Agent Definition
;; =====================

{:Agentlang.Core/Agent
 {:Name :Resource.Core/Agent
  :LLM :llm01
  :Channels [{:channel-type :default
              :name :ResourceAllocation.Core/HttpChannel}
             {:channel-type :cmdline
              :name :ResourceAllocation.Core/ReplChannel
              :doc "I'm an intelligent agent who will help you manage the resources database."}]
  :Tools [:ResourceAllocation.Schema/Resource
          :ResourceAllocation.Schema/Project
          :ResourceAllocation.Schema/Allocation]
  :UserInstruction (str "Based on user input, either\n"
                        "Only perform the actions which \n"
                        "1. create a resource, project or allocation. Before creating a resource ask confirmation from the user.
                             - If a date is given for creating a resource. Ex: 21st Feb, 2024 -> 2024-02-21
                             - If the first letter of the first name and last name is in lower case convert the first letter to upper case.
                                Ex: muazzam -> Muazzam.
                                Also whichever attribute is default don't ask to provide a value for it.
                             \n"
                        "2. If a user asks to list all resources. List them without any criteria."
                        "3. query a resource, project or allocation.\n"
                        "4. delete a resource, project or allocation.\n"
                        "5. update a resource, project or allocation.\n")}}

;; Sample request: create a new resource, first name: muazzam, last name: ali, preferred name: muazzam, email: muazzam@gmail.com, role: software engineer, team: software, status: Active, Work Location: US
;; create a project with name: beta with owner: daniel status: Active, start date: 4th April, 2024, Terminated type: RTB Costcurrency: USD, description: project for now