(component
 :ResourceAllocation.Slack
 {:clj-import (quote [(:require [agentlang.util.http :as http]
                                [clojure.string :as s]
                                [agentlang.util.logger :as log]
                                [markdown.core :as md]
                                [agentlang.util :as u]
                                [agentlang.component :as cn]
                                [agentlang.connections.client :as cc]
                                [clojure.set :as set]
                                [agentlang.interpreter :as ip]
                                [agentlang.util.http :as uh]
                                [hiccup.core :refer [html]]
                                [agentlang.datafmt.json :as json]
                                [agentlang.inference.service.channel.core :as ch])])})

(def ^:private tag :slack)

(def ^:private run-flags (atom {}))

(defn- can-run? [channel-name]
  (get @run-flags channel-name))

(defn- extract-msg-ids [r]
  (:ts r))

(defn- make-welcome-message [doc schema-doc]
  (str
   "*"
   (if doc doc "*Hi, I'm intelligent agent here to help you.*\n")
   "*\n\n"
   (when schema-doc
     (str "You can refer to the following definitions while interacting with me:\n\n"
          schema-doc))))

(def send-msg-fn (atom nil))
(def last-sent-ids (atom nil))

(defmethod ch/channel-send tag [{msg :message}]
  (when-let [send @send-msg-fn]
    (reset! last-sent-ids (send msg))
    true))

(defn- last-sent-msg-id? [id]
  (when-let [[_ lstid] @last-sent-ids]
    (= id lstid)))

(defn slack-api-key
  []
  (System/getenv "SLACK_API_KEY"))

(defn slack-api-channel-key
  []
  (System/getenv "SLACK_CHANNEL_ID"))


(defn- http-opts
  []
  {:headers {"Authorization" (str "Bearer " (slack-api-key))
             "Content-Type" "application/json"}})

(def slack-base-url
  "Base URL for Slack API endpoints"
  "https://slack.com/api")

(defn send-message-to-channel
  ([channel msg msgtype]
   (let [url (str slack-base-url "/chat.postMessage")
         res (http/do-post url (http-opts) {:channel channel msgtype msg})]
     (log/info (str "kkk1 " res))
     (json/decode (:body res))))
  ([channel msg]
   (send-message-to-channel channel msg :text)))

(defn get-last-message [channel]
  (let [url (str slack-base-url "/conversations.history?channel=" channel "&limit=1")
        res (http/do-get url (http-opts))]
    (json/decode (:body res))))

(defn format-card [msg]
  (let [msg (dissoc msg :type-*-tag-*- :-*-type-*- :__path__ :__parent__)]
    (for [[k v] msg]
      (cond
        (string? v) {:type :section :text {:type "mrkdwn" :text (str "*" (name k) "*: " v)}}
        (coll? v) {:type :section :text {:type "mrkdwn" :text (str "*" (name k) "*: " (pr-str v))}}
        :else {:type :section :text {:type "mrkdwn" :text (str "*" (name k) "*: " v)}}))))

(defn format-table [msg]
  (cons
   {:type "header",
    :text {:type "plain_text",
           :text (last (:-*-type-*- (first msg)))}}
   (apply concat (interpose [{:type "divider"}] (map format-card msg)))))

(defn- format-message [msg]
  (try (cond
         (map? msg) [:blocks (json/encode (format-card msg))]
         (and (coll? msg) (= (count msg) 1)) [:blocks (json/encode (format-card (first msg)))]
         (coll? msg) [:blocks (json/encode (format-table msg))]
         :else [:text msg])
       (catch Exception e
         [:text msg])))

(defmethod ch/channel-start :slack [{channel-name :name agent-name :agent
                                     doc :doc schema-doc :schema-doc}]
  (swap! run-flags assoc channel-name true)
  (let [send (partial ch/send-instruction-to-agent channel-name agent-name (name channel-name))
        can-run? #(can-run? channel-name)
        channel (slack-api-channel-key)
        send-msg (fn [msg]
                   (let  [[msg-type msg] (format-message msg)
                          r (send-message-to-channel channel msg msg-type)]
                     (extract-msg-ids r)))]
    (reset! send-msg-fn send-msg)
    (u/parallel-call
     {:delay-ms 2000}
     (fn []
       (let [msg-id
             (extract-msg-ids
              (send-message-to-channel channel (make-welcome-message doc schema-doc)))]
         (loop [last-msg-id msg-id]
           (when (can-run?)
             (Thread/sleep 10000)
             (let [r (get-last-message channel)
                   msg (first (:messages r))
                   id (:ts msg)]
               (log/info (str "l" " " r " " last-msg-id " " id))
               (if (and (not= last-msg-id id) (not (last-sent-msg-id? id)))
                 (let [resp (send (:text msg))
                       last-msg-id (send-msg resp)]
                   (recur last-msg-id))
                 (recur last-msg-id)))))))))
  channel-name)

(defmethod ch/channel-shutdown tag [{channel-name :name}]
  (swap! run-flags dissoc channel-name)
  channel-name)
