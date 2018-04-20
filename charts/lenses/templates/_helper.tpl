{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "name" -}}
{{- default .Chart.Name .Values.nameOverride -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 24 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
*/}}
{{- define "fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}

{{- define "ingressPath" -}}
{{- if .Values.ingress.path -}}
{{- .Values.ingress.path -}}
{{- else -}}
{{- include "fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "metricTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_metrics
{{- end -}}
{{- end -}}

{{- define "auditTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_audits_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_audits
{{- end -}}
{{- end -}}

{{- define "processorTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_processors_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_processors
{{- end -}}
{{- end -}}

{{- define "alertTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_alerts_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_alerts
{{- end -}}
{{- end -}}

{{- define "profileTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_profiles_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_profiles
{{- end -}}
{{- end -}}

{{- define "alertSettingTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_alert_settings_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_alert_settings
{{- end -}}
{{- end -}}

{{- define "clusterTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_cluster_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_cluster
{{- end -}}
{{- end -}}

{{- define "lsqlTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_lsql_storage_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_lsql_storage
{{- end -}}
{{- end -}}

{{- define "securityProtocol" -}}
{{- if and .Values.lenses.kafka.sasl.enabled .Values.lenses.kafka.ssl.enabled -}}
SASL_SSL
{{- end -}} 
{{- if and .Values.lenses.kafka.sasl.enabled (not .Values.lenses.kafka.ssl.enabled) -}}
SASL_PLAINTEXT
{{- end -}} 
{{- if and .Values.lenses.kafka.ssl.enabled (not .Values.lenses.kafka.sasl.enabled) -}}
SSL
{{- end -}} 
{{- if and (not .Values.lenses.kafka.ssl.enabled) (not .Values.lenses.kafka.sasl.enabled) -}}
PLAINTEXT
{{- end -}}
{{- end -}}

{{- define "bootstrapBrokers" -}}
{{- $protocol := include "securityProtocol" . -}}
{{ range $index, $element := .Values.lenses.kafka.bootstrapServers }}
  {{- if $index -}}
    {{- if eq $protocol "PLAINTEXT" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.port}}
    {{- end -}}  
    {{- if eq $protocol "SSL" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.sslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_SSL" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.saslSslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_PLAINTEXT" -}}
  ,{{$protocol}}://{{$element.name}}:{{$element.saslPlainTextPort}}
    {{- end -}}
  {{- else -}}
    {{- if eq $protocol "PLAINTEXT" -}}
  {{$protocol}}://{{$element.name}}:{{$element.port}}
    {{- end -}}  
    {{- if eq $protocol "SSL" -}}
  {{$protocol}}://{{$element.name}}:{{$element.sslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_SSL" -}}
  {{$protocol}}://{{$element.name}}:{{$element.saslSslPort}}
    {{- end -}}
    {{- if eq $protocol "SASL_PLAINTEXT" -}}
  {{$protocol}}://{{$element.name}}:{{$element.saslPlainTextPort}}
    {{- end -}}
  {{- end -}}  
  {{end}}
{{- end -}}

{{- define "alertManagers" -}}
{{ range $index, $element := .Values.lenses.alertManagers.endpoints }}
  {{- if $index -}},{{$element.protocol}}://{{$element.host}}:{{$element.port}}
  {{- else -}}{{$element.protocol}}://{{$element.host}}:{{$element.port}}
  {{- end -}}
  {{end}}
{{- end -}}

{{- define "zookeepers" -}}
[
  {{ range $index, $element := .Values.lenses.zookeepers }}
  {{- if not $index -}}{
    "url":"{{$element.host}}:{{$element.port}}" 
    ,"jmx":"{{$element.host}}:{{$element.jmxPort}}"
  }
  {{- else}}
  ,{
    "url":"{{$element.host}}:{{$element.port}}"
    ,"jmx":"{{$element.host}}:{{$element.jmxPort}}"
  }
  {{- end}}
{{- end}}
]  
{{- end -}}

{{- define "registries" -}}
{{- if .Values.lenses.schemaRegistries.enabled -}}
[
  {{ range $index, $element := .Values.lenses.schemaRegistries.hosts }}
  {{- if not $index -}}{
    "url":"{{$element.protocol}}://{{$element.host}}:{{$element.port}}"
    ,"jmx":"{{$element.host}}:{{$element.jmxPort}}"
  }
  {{- else}}
  ,{
    "url":"{{$element.protocol}}://{{$element.host}}:{{$element.port}}"
    ,"jmx":"{{$element.host}}:{{$element.jmxPort}}"
  }
  {{- end}}
{{- end}}
]  
{{- end -}}
{{- end -}}


{{- define "connect" -}}
{{- if .Values.lenses.connectClusters.enabled -}}
[
{{- range $index, $element := .Values.lenses.connectClusters.clusters -}}
  {{- $jmxPort := index $element "jmxPort" -}}
  {{- $port := index $element "port" -}}
  {{- if not $index}}
  {  
    "name": "{{- index $element "name"}}",
    "statuses": "{{index $element "statusesTopic"}}",
    "configs": "{{index $element "configsTopic"}}",
    "offsets": "{{index $element "offsetsTopic"}}",
    "urls":[ 
      {{ range $index, $element := index $element "hosts"}}
      {{- if not $index -}}
      {
        "url":"{{$element}}:{{$port}}"
        ,"jmx":"{{$element}}:{{$jmxPort}}"
      }
      {{- else}}
      ,{
        "url":"{{$element}}:{{$port}}" 
        ,"jmx":"{{$element}}:{{$jmxPort}}"
      }
      {{- end -}}
      {{- end}}
    ]
  }
  {{else}},{
    "name": "{{- index $element "name"}}",
    "statuses": "{{index $element "statusesTopic"}}",
    "configs": "{{index $element "configsTopic"}}",
    "offsets": "{{index $element "offsetsTopic"}}",
    "urls":[ 
      {{ range $index, $element := index $element "hosts"}}
      {{- if not $index -}}
      {
        "url":"{{$element}}:{{$port}}", 
        "jmx":"{{$element}}:{{$jmxPort}}"
      }
      {{- else}}
      ,{
        "url":"{{$element}}:{{$port}}", 
        "jmx":"{{$element}}:{{$jmxPort}}"
      }
      {{- end -}}
      {{- end -}}
    ]
  }
  {{- end -}} 
{{- end}}
]
{{- end -}}
{{- end -}}


{{- define "userGroups" -}}
[
  {{ range $index, $element := .Values.lenses.security.groups}}
  {{- if not $index -}}
    {
      "name": "{{$element.name}}", 
      "roles":[
      {{- range $index, $element := index $element "roles" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]
  }
  {{- else}}  ,{
      "name": "{{$element.name}}",
      "roles": [
      {{- range $index, $element := index $element "roles" -}}
      {{- if not $index -}}"{{$element}}"
      {{- else -}}, "{{$element}}"
      {{- end -}}
      {{- end -}}
    ]
  }
  {{- end}}
{{end -}}
]
{{- end -}}



{{- define "users" -}}
[
  {{ range $index, $element := .Values.lenses.security.users}}
  {{- if not $index -}}
    {
      "name": "{{$element.username}}", 
      "displayname": "{{$element.displayname}}",
      "password": "{{$element.password}}",
      "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]{{- if index $element "topic" }},
      {{- $topic := index $element "topic"}}
      "topic": {
        {{- if index $topic "whitelist"}}
        "whitelist": [
          {{- range $index, $element:= index $topic "whitelist"}}
          {{- if not $index -}} "{{$element}}"
          {{- else -}}, "{{$element}}"
          {{- end -}}
          {{- end -}}
        ]
        {{- end}}
        {{- if index $topic "blacklist"}}
        "blacklist": [
          {{- range $index, $element:= index $topic "blacklist"}}
          {{- if not $index -}} "{{$element}}"
          {{- else -}}, "{{$element}}"
          {{- end -}}
          {{- end -}}
        ]
        {{- end}}
      }  
      {{- end}}
  }
  {{- else}}  ,{
      "name": "{{$element.username}}",
      "displayname": "{{$element.displayname}}",
      "password": "{{$element.password}}",
      "groups": [
      {{- range $index, $element := index $element "groups" -}}
      {{- if not $index -}}"{{$element}}"
      {{- else -}}, "{{$element}}"
      {{- end -}}
      {{- end -}}
    ]
  }
  {{- end}}
{{end -}}
]
{{- end -}}

{{- define "serviceAccounts" -}}
[
  {{ range $index, $element := .Values.lenses.security.serviceAccounts}}
  {{- if not $index -}}
    {
      "username": "{{$element.username}}", 
      "token": "{{$element.token}}",
      "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]
  }
  {{- else}}  ,{
      "username": "{{$element.username}}", 
      "token": "{{$element.token}}",
      "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]
  }
  {{- end}}
{{end -}}
]
{{- end -}}

