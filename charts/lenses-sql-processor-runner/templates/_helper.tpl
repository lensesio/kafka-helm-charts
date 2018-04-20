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

{{- define "appId" -}}
{{- if .Values.applicationId -}}
{{- .Values.applicationId -}}
{{- else -}}
{{- include "fullname" . -}}
{{- end -}}
{{- end -}}

{{- define "metricTopic" -}}
{{- if .Values.metricsTopicSuffix -}}
_kafka_lenses_metrics_{{ .Values.metricsTopicSuffix }}
{{- else -}}
_kafka_lenses_metrics
{{- end -}}
{{- end -}}

{{- define "securityProtocol" -}}
{{- if and .Values.kafka.sasl.enabled .Values.kafka.ssl.enabled -}}
SASL_SSL
{{- end -}} 
{{- if and .Values.kafka.sasl.enabled (not .Values.kafka.ssl.enabled) -}}
SASL_PLAINTEXT
{{- end -}} 
{{- if and .Values.kafka.ssl.enabled (not .Values.kafka.sasl.enabled) -}}
SSL
{{- end -}} 
{{- if and (not .Values.kafka.ssl.enabled) (not .Values.kafka.sasl.enabled) -}}
PLAINTEXT
{{- end -}}
{{- end -}}

{{- define "bootstrapBrokers" -}}
{{- $protocol := include "securityProtocol" . -}}
{{ range $index, $element := .Values.kafka.bootstrapServers }}
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

{{- define "registries" -}}
{{- if .Values.schemaRegistries.enabled -}}
{{ range $index, $element := .Values.schemaRegistries.hosts }}
  {{- if $index -}},{{$element.protocol}}://{{$element.host}}:{{$element.port}}
  {{- else -}}{{$element.protocol}}://{{$element.host}}:{{$element.port}}
  {{- end -}}
  {{end}}
{{- end -}}
{{- end -}}


{{- define "extras" -}}
{
  "security.protocol" : {{ include "securityProtocol" . | quote }}
  {{- if .Values.kafka.sasl.enabled }}
  ,"security.mechanism" : "{{ .Values.kafka.sasl.mechanism }}"
  {{- end -}}
  {{- if .Values.kafka.ssl.enabled }}
  ,"ssl.key.password" : {{ .Values.kafka.ssl.keyPassword | quote }}
  ,"ssl.keystore.location" : "/mnt/secrets/client.keystore.jks"
  ,"ssl.keystore.password" : {{ .Values.kafka.ssl.keyStorePassword  | quote }}
  ,"ssl.truststore.location" : "/mnt/secrets/client.truststore.jks"
  ,"ssl.truststore.password" : {{ .Values.kafka.ssl.trustStorePassword | quote }}
  {{- end }}
}
{{- end -}}    

