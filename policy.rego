package webiso

import future.keywords.contains
import future.keywords.if
import future.keywords.in

import data.userinfo
import data.orginfo

default allow := false
default user_allow := false
default org_allow := false
default user_action_permission := false
default org_action_permission := false
default is_exist := false

default user_url_permission := false
default org_url_permission := false
default user_allow_url := false
default org_allow_url := false
default allow_url := false


user := userinfo[input.user]
user_policy := user.policy
org_policy := orginfo[user.org].policy


#######################
##### RBI 사용 정책 ####
#######################

# user에 정의된 정책이 존재하는 경우, user 정책을 따름
allow {            
    user_allow 
}
# user에 정의된 정책이 존재하지 않는 경우, org_allow 를 사용한다
allow {
    is_exist==false    
    org_allow
}
user_allow {    
    user_action_permission
}
org_allow {    
    org_action_permission
}

is_exist if user_policy[input.action]
user_action_permission {
    user_policy[input.action] == "ON"
}
org_action_permission {
    org_policy[input.action] == "ON"
}

#######################
##### ACL #############
#######################
allow_url{
    user_allow_url
}
allow_url{
    org_allow_url
}
user_allow_url{
    user_url_permission
}
org_allow_url{
    org_url_permission
}

org_url_permission if input.url in org_graph_urls[user.org]
user_url_permission if input.url in user.urls

#상위 조직도의 urls 들을 모두 합친 urls 집합
org_graph[entity_name] := parents {
    orginfo[entity_name]
    parents:= {
       neighbor | orginfo[neighbor].child[_] == entity_name
    }
}
org_graph_urls[entity_name] := urls {
    orginfo[entity_name]
    reachable := graph.reachable(org_graph, {entity_name})
    urls := { item | reachable[k]; item:= orginfo[k].urls[_]}
}