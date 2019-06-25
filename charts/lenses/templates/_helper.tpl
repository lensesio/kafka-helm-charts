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

{{- define "metadataTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_topics_metadata_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_topics_metadata
{{- end -}}
{{- end -}}

{{- define "topologyTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology
{{- end -}}
{{- end -}}

{{- define "externalMetricsTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
__topology__metrics_{{ .Values.lenses.topics.suffix }}
{{- else -}}
__topology__metrics
{{- end -}}
{{- end -}}

{{- define "connectorsTopic" -}}
{{- if .Values.lenses.topics.suffix -}}
_kafka_lenses_connectors_{{ .Values.lenses.topics.suffix }}
{{- else -}}
_kafka_lenses_processors
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

{{- define "kafkaMetrics" -}}
{
  type: {{ default "JMX" .Values.lenses.kafka.metrics.type | quote}},
  ssl: {{ default false .Values.lenses.kafka.metrics.ssl}},
  {{- if .Values.lenses.kafka.metrics.username}}
  user: {{ .Values.lenses.kafka.metrics.username | quote}},
  {{- end }}
  {{- if .Values.lenses.kafka.metrics.password}}
  password: {{ .Values.lenses.kafka.metrics.password | quote}},
  {{- end }}
  {{- if .Values.lenses.kafka.metrics.port}}
  default.port: {{ .Values.lenses.kafka.metrics.port }},
  {{- else}}
  port: [
    {{ range $index, $element := .Values.lenses.kafka.metrics.ports }}
    {{- if not $index -}}{id: {{$element.id}}, port: {{$element.port}}, host: "{{$element.host}}"}
    {{- else}},
    {id: {{$element.id}}, port: {{$element.port}}, host: "{{$element.host}}"}
    {{- end}}
  {{- end}}
  ]
  {{- end}}
}
{{- end -}}

{{- define "kafkaSchemaBasicAuth" -}}
  {{- if .Values.lenses.schemaRegistries.security.enabled -}}
    {{- if (.Values.lenses.schemaRegistries.security.authType)  and eq .Values.lenses.schemaRegistries.security.authType "USER_INFO" -}}
    {{- .Values.lenses.schemaRegistries.security.username}}:{{.Values.lenses.schemaRegistries.security.password}}
    {{- end -}}
  {{- end -}}
{{- end -}}

{{- define "jmxBrokers" -}}
[
  {{ range $index, $element := .Values.lenses.kafka.jmxBrokers }}
  {{- if not $index -}}{id: {{$element.id}}, port: {{$element.port}}}
  {{- else}},
  {id: {{$element.id}}, port: {{$element.port}}}
  {{- end}}
{{- end}}
]  
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
  {{ range $index, $element := .Values.lenses.zookeepers.hosts }}
  {{- if not $index -}}{url: "{{$element.host}}:{{$element.port}}"
  {{- if $element.metrics -}}, metrics: {
    url: "{{$element.host}}:{{$element.metrics.port}}", 
    type: "{{$element.metrics.type}}",
    ssl: {{default false $element.metrics.ssl}},
    {{- if $element.metrics.username -}}
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}},
    {{- end }}
  }{{- end}}}
  {{- else}},
  {url: "{{$element.host}}:{{$element.port}}"
  {{- if $element.metrics -}}, metrics: {
    url: "{{$element.host}}:{{$element.metrics.port}}", 
    type: "{{default "JMX" $element.metrics.type}}",
    ssl: {{default false $element.ssl}},
    {{- if $element.metrics.username -}}
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}}
    {{- end }}
  }{{- end}}}
  {{- end}}
{{- end}}
]  
{{- end -}}

{{- define "registries" -}}
{{- if .Values.lenses.schemaRegistries.enabled -}}
[
  {{ range $index, $element := .Values.lenses.schemaRegistries.hosts }}
  {{- if not $index -}}{url: "{{$element.protocol}}://{{$element.host}}:{{$element.port}}{{$element.path}}"
  {{- if $element.metrics -}}, metrics: {
    url: "{{$element.host}}:{{$element.metrics.port}}", 
    type: "{{$element.metrics.type}}",
    ssl: {{default false $element.metrics.ssl}}
    {{- if $element.metrics.username -}},
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}}
    {{- end }}
  }{{- end}}}
  {{- else}},
  {url: "{{$element.protocol}}://{{$element.host}}:{{$element.port}}"
  {{- if $element.metrics -}}, metrics: {
    url: "{{$element.host}}:{{$element.metrics.port}}", 
    type: "{{default "JMX" $element.metrics.type}}",
    ssl: {{default false $element.ssl}}
    {{- if $element.metrics.username -}},
    user: {{$element.metrics.username | quote}},
    {{- end }}
    {{- if $element.metrics.password -}}
    password: {{$element.metrics.password | quote}}
    {{- end }}
  }{{- end}}}
  {{- end}}
{{- end}}
]  
{{- end -}}
{{- end -}}


{{- define "connect" -}}
{{- if .Values.lenses.connectClusters.enabled -}}
[
{{- range $index, $element := .Values.lenses.connectClusters.clusters -}}
  {{- $port := index $element "port" -}}
  {{- $protocol := index $element "protocol" -}}
  {{- if not $index -}}{
    name: "{{- index $element "name"}}",
    statuses: "{{index $element "statusTopic"}}",
    configs: "{{index $element "configTopic"}}",
    offsets: "{{index $element "offsetsTopic"}}",
    {{ if index $element "authType" }}auth: "{{index $element "authType"}}",{{- end -}}
    {{ if index $element "username" }}username: "{{index $element "username"}}",{{- end -}}
    {{ if index $element "password" }}password: "{{index $element "password"}}",{{- end -}}
    urls: [
      {{ range $index, $element := index $element "hosts" -}}
        {{- if not $index -}}
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
          url: "{{$element.host}}:{{$element.metrics.port}}",
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- else -}},
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
          url: "{{$element.host}}:{{$element.metrics.port}}",
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- end -}}
      {{- end}}
    ]
  }
  {{- else}},
  {  
    name: "{{- index $element "name"}}",
    statuses: "{{index $element "statusTopic"}}",
    configs: "{{index $element "configTopic"}}",
    offsets: "{{index $element "offsetsTopic"}}",
    {{ if index $element "authType" }}authType: "{{index $element "authType"}}",{{- end -}}
    {{ if index $element "username" }}username: "{{index $element "username"}}",{{- end -}}
    {{ if index $element "password" }}password: "{{index $element "password"}}",{{- end -}}
    urls:[ 
      {{ range $index, $element := index $element "hosts" -}}
        {{- if not $index -}}
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
          url: "{{$element.host}}:{{$element.metrics.port}}", 
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- else -}},
        {url: "{{$protocol}}://{{$element.host}}:{{$port}}"
        {{- if $element.metrics -}}, metrics: {
          url: "{{$element.host}}:{{$element.metrics.port}}", 
          type: "{{default "JMX" $element.metrics.type}}",
          ssl: {{default false $element.metrics.ssl}},
          {{- if $element.metrics.username -}}
          user: {{$element.metrics.username | quote}},
          {{- end }}
          {{- if $element.metrics.password -}}
          password: {{$element.metrics.password | quote}}
          {{- end }}
        }{{- end}}}
        {{- end -}}
      {{- end}}
    ]
  }
  {{- end}}
{{- end}}
]
{{- end -}}
{{- end -}}


{{- define "userGroups" -}}
[
  {{ range $index, $element := .Values.lenses.security.groups}}
  {{- if not $index -}}
  {{- $topic := index $element "topic" -}}
    {"name": "{{$element.name}}", "roles":[
      {{- range $index, $element := index $element "roles" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]
      {{- if $topic }}, "topic": {"whitelist":[
          {{- range $index, $element := index $topic "whitelist" -}}
            {{- if not $index -}} "{{$element}}"
            {{- else -}}, "{{$element}}"
            {{- end -}}
          {{- end -}}], "blacklist":[
          {{- range $index, $element := index $topic "blacklist" -}}
            {{- if not $index -}} "{{$element}}"
            {{- else -}}, "{{$element}}"
            {{- end -}}
          {{- end -}}]}
      {{- end -}}}
  {{- else -}},
  {{- $topic := index $element "topic" -}}
  {"name": "{{$element.name}}", "roles":[
      {{- range $index, $element := index $element "roles" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]
      {{- if $topic }}, "topic": {"whitelist":[
          {{- range $index, $element := index $topic "whitelist" -}}
            {{- if not $index -}} "{{$element}}"
            {{- else -}}, "{{$element}}"
            {{- end -}}
          {{- end -}}], "blacklist":[
          {{- range $index, $element := index $topic "blacklist" -}}
            {{- if not $index -}} "{{$element}}"
            {{- else -}}, "{{$element}}"
            {{- end -}}
          {{- end -}}]}
      {{- end -}}}
  {{- end -}}
  {{- end }}
]
{{- end -}}



{{- define "users" -}}
{{- if .Values.lenses.security.users -}}
[
  {{ range $index, $element := .Values.lenses.security.users}}
  {{- if not $index -}}
  {{- $topic := index $element "topic" -}}
    {"username": "{{$element.username}}", "displayName": "{{$element.displayname}}", "password": "{{$element.password}}", "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}]
    }
  {{- else -}},
  {{- $topic := index $element "topic" }}
  {"username": "{{$element.username}}", "displayName": "{{$element.displayname}}", "password": "{{$element.password}}", "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}]
      }
  {{- end -}}
  {{- end }}
]
{{end -}}
{{- end -}}

{{- define "serviceAccounts" -}}
{{- if .Values.lenses.security.serviceAccounts -}}
[
  {{ range $index, $element := .Values.lenses.security.serviceAccounts}}
  {{- if not $index -}}
    {"username": "{{$element.username}}", "token": "{{$element.token}}", "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]}
  {{- else -}},
  {"username": "{{$element.username}}", "token": "{{$element.token}}", "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]}
  {{- end -}}
  {{- end }}
]
{{end -}}
{{- end -}}


{{- define "kerberos" -}}
{{- if eq .Values.lenses.security.mode "KERBEROS" }}
lenses.security.kerberos.service.principal={{ .Values.lenses.security.kerberos.servicePrincipal | quote }}
lenses.security.kerberos.keytab=/mnt/secrets/lenses.keytab
lenses.security.kerberos.debug={{ .Values.lenses.security.kerberos.debug | quote }}
lenses.security.mappings=[
  {{ range $index, $element := .Values.lenses.security.kerberos.mappings}}
  {{- if not $index -}}
    {"username": "{{$element.username}}", "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]}
  {{- else -}},
  {"username": "{{$element.username}}", "groups":[
      {{- range $index, $element := index $element "groups" -}}
        {{- if not $index -}} "{{$element}}"
        {{- else -}}, "{{$element}}"
        {{- end -}}
      {{- end -}}
      ]}
  {{- end -}}
  {{- end }}
]
{{end -}}
{{- end -}}

{{- define "securityConf" -}}
lenses.security.mode={{ .Values.lenses.security.mode }} 
{{ if .Values.lenses.security.users -}}
lenses.security.users={{ include "users" . }}
{{- end }}

{{- if .Values.lenses.security.groups -}}
lenses.security.groups={{ include "userGroups" . }}
{{- end -}}

{{ if .Values.lenses.security.serviceAccounts }}
lenses.security.service.accounts={{ include "serviceAccounts" . }}
{{- end -}}

{{- if eq .Values.lenses.security.mode "LDAP" }}
lenses.security.ldap.url={{ .Values.lenses.security.ldap.url }}
lenses.security.ldap.base={{ .Values.lenses.security.ldap.base }}
lenses.security.ldap.user={{ .Values.lenses.security.ldap.user }}
lenses.security.ldap.password={{ .Values.lenses.security.ldap.password }}
lenses.security.ldap.filter={{ .Values.lenses.security.ldap.filter }}
lenses.security.ldap.plugin.class={{ .Values.lenses.security.ldap.plugin.class }}
lenses.security.ldap.plugin.memberof.key={{ .Values.lenses.security.ldap.plugin.memberofKey }}
lenses.security.ldap.plugin.group.extract.regex={{ .Values.lenses.security.ldap.plugin.groupExtractRegex }} 
lenses.security.ldap.plugin.person.name.key={{ .Values.lenses.security.ldap.plugin.personNameKey }}
{{- end -}} 
{{- if eq .Values.lenses.security.mode "KERBEROS" -}}
{{ include "kerberos" .}}
{{- end -}}
{{- end -}}

