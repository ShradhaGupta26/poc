{{/*
Default Template for Cluster Role. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.clusterroletemplate" }}
kind: ClusterRole
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: "{{ .Values.appName }}-service-role"
    namespace: "{{ $.Release.Namespace }}"
rules:
- apiGroups:
  - ""
  resources:
  - "*"
  verbs:
  - "*"
- apiGroups:
  - rbac.authorization.k8s.io
  resources:
  - "*"
  verbs:
  - "*"
- apiGroups:
  - apiextensions.k8s.io
  resources:
  - customresourcedefinitions
  verbs:
  - get
  - list
  - watch
  - create
  - delete
{{- end }}


{{/*
Default Template for Service Account. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.serviceaccounttemplate" }}
apiVersion: v1
kind: ServiceAccount
metadata:
    name: "{{ .Values.appName }}-service-role"
    namespace: "{{ $.Release.Namespace }}"
    annotations:
      eks.amazonaws.com/role-arn: {{ $.Values.global.ssmCsiRole }}

{{- end }}


{{/*
Default Template for Cluster Role Binding. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.rolebindingtemplate" }}
kind: ClusterRoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
    name: "{{ .Values.appName }}-service-role"
    namespace: "{{ $.Release.Namespace }}"
subjects:
-   kind: ServiceAccount
    name: "{{ .Values.appName }}-service-role"
    namespace: "{{ $.Release.Namespace }}"
roleRef:
    kind: ClusterRole
    name: "{{ .Values.appName }}-service-role"
    apiGroup: rbac.authorization.k8s.io
{{- end }}


{{/*
Default Template for Service. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.servicetemplate" }}
apiVersion: v1
kind: Service
metadata:
    name: "svc-{{ .Values.appName }}"
    namespace: "{{ $.Release.Namespace }}"
spec:
    ports:
        -   name: www
            port: 80
            protocol: TCP
            targetPort: {{ .Values.resources.containerInfo.containerPort }}
    selector:
        run: {{ .Values.appName }}
    type: ClusterIP
{{- end }}


{{/*
Default Template for HPA. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.hpatemplate" }}
{{- if .Values.autoscaling.enabled }}
apiVersion: autoscaling/v2beta1
kind: HorizontalPodAutoscaler
metadata:
    name: {{ .Values.appName }}
    namespace: {{ $.Release.Namespace }}
    labels:
        app: {{ .Values.appName }}
spec:
    scaleTargetRef:
        apiVersion: apps/v1beta1
        kind: Deployment
        name: {{ .Values.appName }}
    minReplicas: {{ .Values.autoscaling.minReplicas }}
    maxReplicas: {{ .Values.autoscaling.maxReplicas }}
    metrics:
        -   type: Resource
            resource:
                name: cpu
                target:
                    type: Utilization
                    averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
        -   type: Resource
            resource:
                name: memory
                target:
                    type: Utilization
                    averageUtilization: {{ .Values.autoscaling.targetCPUUtilizationPercentage }}
{{- end }}
{{- end }}


{{/*
Default Template for Secret Provider Class. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.spctemplate" }}
apiVersion: secrets-store.csi.x-k8s.io/v1
kind: SecretProviderClass
metadata:
  name: aws-secrets2
  namespace: {{ $.Release.Namespace }}
spec:
  provider: aws
  secretObjects:
    - secretName: vr-creds
      type: Opaque
      data:
        - objectName: rds-endpoint
          key: DATABASE_HOST_STRING_Secret
        - objectName: rds-password
          key: DB_PASSWORD_Secret
        - objectName: rds-user
          key: DB_USER_NAME_Secret
        - objectName: rds-name
          key: DATABASE_NAME_Secret
        - objectName: api-provider-user
          key: API_PROVIDER_USERNAME_Secret
        - objectName: api-provider-password
          key: API_PROVIDER_PASSWORD_Secret
        - objectName: app-ingestor-user
          key: APP_INGESTOR_USERNAME_Secret
        - objectName: app-ingestor-password
          key: APP_INGESTOR_PASSWORD_Secret
        - objectName: app-search-user
          key: APP_SEARCH_USERNAME_Secret
        - objectName: app-search-password
          key: APP_SEARCH_PASSWORD_Secret
        - objectName: core-service-user
          key: CORE_SERVICE_USERNAME_Secret
        - objectName: core-service-password
          key: CORE_SERVICE_PASSWORD_Secret
        - objectName: core-auth-user
          key: CORE_AUTH_USERNAME_Secret
        - objectName: core-auth-password
          key: CORE_AUTH_PASSWORD_Secret
        - objectName: core-content-user
          key: CORE_CONTENT_USERNAME_Secret
        - objectName: core-content-password
          key: CORE_CONTENT_PASSWORD_Secret
        - objectName: core-editorial-user
          key: CORE_EDITORIAL_USERNAME_Secret
        - objectName: core-editorial-password
          key: CORE_EDITORIAL_PASSWORD_Secret
        - objectName: subscriber-mgmt-user
          key: SUBS_MGMT_USERNAME_Secret
        - objectName: subscriber-mgmt-password
          key: SUBS_MGMT_PASSWORD_Secret
        - objectName: videoready-config-user
          key: VIDEO_CONFIG_USERNAME_Secret
        - objectName: videoready-config-password
          key: VIDEO_CONFIG_PASSWORD_Secret
        - objectName: rabbit-mq-endpoint
          key: RABBITMQ_HOST_Secret
        - objectName: rabbit-mq-username
          key: RABBIT_MQ_USERNAME_Secret
        - objectName: rabbit-mq-password
          key: RABBIT_MQ_PASSWORD_Secret
        - objectName: mongodb-admin-password
          key: MONGO_PASSWORD_Secret
        - objectName: mongodb-admin-user
          key: MONGO_USERNAME_Secret
        - objectName: mongodb-db-name
          key: MONGO_DB_NAME_Secret
        - objectName: mongodb-db-recommendation
          key: MONGO_DB_NAME_RECOM_Secret
        - objectName: mongodb-user-recommendation
          key: MONGO_DB_USERNAME_RECOM_Secret
        - objectName: mongodb-password-recommendation
          key: MONGO_DB_PASS_RECOM_Secret
        - objectName: mongodb-admin-db
          key: MONGO_AUTH_DB_Secret
        - objectName: mongodb-admin-host
          key: MONGO_HOST_Secret
        - objectName: search-db-name
          key: SEARCH_DB_NAME_Secret
        - objectName: elastic-host
          key: ELASTIC_HOST_Secret
        - objectName: elastic-user
          key: ELASTIC_USER_Secret
        - objectName: vr-scheduler-user
          key: VR-SCHEDULER_USERNAME_Secret
        - objectName: vr-scheduler-password
          key: VR-SCHEDULER_PASSWORD_Secret
  parameters:
    objects: |
        - objectName: "/{{ $.Release.Namespace }}/RDS/ENDPOINT"
          objectType: "ssmparameter"
          objectAlias: rds-endpoint
        - objectName: "/{{ $.Release.Namespace }}/RDS/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: rds-password
        - objectName: "/{{ $.Release.Namespace }}/RDS/USER"
          objectType: "ssmparameter"
          objectAlias: rds-user
        - objectName: "/{{ $.Release.Namespace }}/RDS/NAME"
          objectType: "ssmparameter"
          objectAlias: rds-name
        - objectName: "/{{ $.Release.Namespace }}/RDS/api-provider/USERNAME"
          objectType: "ssmparameter"
          objectAlias: api-provider-user
        - objectName: "/{{ $.Release.Namespace }}/RDS/api-provider/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: api-provider-password
        - objectName: "/{{ $.Release.Namespace }}/SEARCH_DB/application-ingestor/USERNAME"
          objectType: "ssmparameter"
          objectAlias: app-ingestor-user
        - objectName: "/{{ $.Release.Namespace }}/SEARCH_DB/application-ingestor/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: app-ingestor-password
        - objectName: "/{{ $.Release.Namespace }}/SEARCH_DB/application-search/USERNAME"
          objectType: "ssmparameter"
          objectAlias: app-search-user
        - objectName: "/{{ $.Release.Namespace }}/SEARCH_DB/application-search/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: app-search-password
        - objectName: "/{{ $.Release.Namespace }}/RDS/core/USERNAME"
          objectType: "ssmparameter"
          objectAlias: core-service-user
        - objectName: "/{{ $.Release.Namespace }}/RDS/core/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: core-service-password
        - objectName: "/{{ $.Release.Namespace }}/RDS/core-auth/USERNAME"
          objectType: "ssmparameter"
          objectAlias: core-auth-user
        - objectName: "/{{ $.Release.Namespace }}/RDS/core-auth/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: core-auth-password
        - objectName: "/{{ $.Release.Namespace }}/RDS/core-content/USERNAME"
          objectType: "ssmparameter"
          objectAlias: core-content-user
        - objectName: "/{{ $.Release.Namespace }}/RDS/core-content/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: core-content-password
        - objectName: "/{{ $.Release.Namespace }}/RDS/core-editorial/USERNAME"
          objectType: "ssmparameter"
          objectAlias: core-editorial-user
        - objectName: "/{{ $.Release.Namespace }}/RDS/core-editorial/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: core-editorial-password
        - objectName: "/{{ $.Release.Namespace }}/RDS/subscriber-management/USERNAME"
          objectType: "ssmparameter"
          objectAlias: subscriber-mgmt-user
        - objectName: "/{{ $.Release.Namespace }}/RDS/subscriber-management/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: subscriber-mgmt-password
        - objectName: "/{{ $.Release.Namespace }}/SEARCH_DB/NAME"
          objectType: "ssmparameter"
          objectAlias: search-db-name
        - objectName: "/{{ $.Release.Namespace }}/SEARCH_DB/videoready-config/USERNAME"
          objectType: "ssmparameter"
          objectAlias: videoready-config-user
        - objectName: "/{{ $.Release.Namespace }}/SEARCH_DB/videoready-config/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: videoready-config-password
        - objectName: "/{{ $.Release.Namespace }}/rabbit/ENDPOINT"
          objectType: "ssmparameter"
          objectAlias: rabbit-mq-endpoint
        - objectName: "/{{ $.Release.Namespace }}/rabbit/USERNAME"
          objectType: "ssmparameter"
          objectAlias: rabbit-mq-username
        - objectName: "/{{ $.Release.Namespace }}/rabbit/PASSWORD"
          objectType: "ssmparameter"
          objectAlias: rabbit-mq-password
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/MONGODB_ADMIN_PASSWORD"
          objectType: "ssmparameter"
          objectAlias: mongodb-admin-password
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/MONGO_DB_PASS_RECOM"
          objectType: "ssmparameter"
          objectAlias: mongodb-password-recommendation
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/ADMIN_USER"
          objectType: "ssmparameter"
          objectAlias: mongodb-admin-user
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/MONGO_DB_USERNAME_RECOM"
          objectType: "ssmparameter"
          objectAlias: mongodb-user-recommendation
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/ADMIN_DB"
          objectType: "ssmparameter"
          objectAlias: mongodb-admin-db
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/MONGODB_HOST"
          objectType: "ssmparameter"
          objectAlias: mongodb-admin-host
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/MONGO_DB_NAME"
          objectType: "ssmparameter"
          objectAlias: mongodb-db-name
        - objectName: "/{{ $.Release.Namespace }}/MongoDB/MONGO_DB_NAME_RECOM"
          objectType: "ssmparameter"
          objectAlias: mongodb-db-recommendation
        - objectName: "/{{ $.Release.Namespace }}/elasticsearch/host"
          objectType: "ssmparameter"
          objectAlias: elastic-host
        - objectName: "/{{ $.Release.Namespace }}/elasticsearch/user"
          objectType: "ssmparameter"
          objectAlias: elastic-user
{{- end }}

{{/*
Default Template for Secret-Provider-Class-Volume. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.spcvolume" }}
volumes:
- name: application-logs
  hostPath:
    path: /opt/logs/{{ .Values.appName }}
- name: creds-volume
  csi:
    driver: secrets-store.csi.k8s.io
    readOnly: true
    volumeAttributes:
        secretProviderClass: aws-secrets2
{{- end }}

{{- define "java-app.defaultEnvVars" -}}
- name: MODULE
  value: {{ .Values.appName }}
- name: ENV
  value: {{ .Release.Namespace }}
{{- end }}

{{- define "swagger-host.dnsValue" -}}
- name: SWAGGER_HOST
  value: "{{ .Values.global.prefix }}-{{ .Release.Namespace }}.demo.videoready.tv"
{{- end }}

{{- define "ingress-ssl-redirect-block" -}}
- http:
    paths:
    - path: /
      pathType: Prefix
      backend:
        service:
          name: ssl-redirect
          port:
            name: use-annotation
{{- end }}

{{/*
Default Template for Ingress. All Sub-Charts under this Chart can include the below template.
*/}}
{{- define "apps.ingresstemplate" }}
{{- with .Values.ingress }}
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: {{ $.Values.appName }}-ingress
  namespace: {{ $.Release.Namespace }}
  labels:
    app: {{ $.Values.appName }}-ingress
  {{- with .annotations }}
  annotations:
    {{- toYaml . | nindent 4 -}}
  {{- end }}
    alb.ingress.kubernetes.io/certificate-arn: "{{ $.Values.global.acmArn }}"
    {{- if .ssl_redirect }}
    alb.ingress.kubernetes.io/actions.ssl-redirect: '{"Type": "redirect", "RedirectConfig": { "Protocol": "HTTPS", "Port": "443", "StatusCode": "HTTP_301"}}'
    {{- end }}
spec:
  rules:
    {{ if .ssl_redirect }}
    {{ include "ingress-ssl-redirect-block" . | nindent 4 }}
    {{ end }}
    - http:
        paths:
        {{- range .paths }}
          - path: {{ .path }}
            pathType: Prefix
            backend:
              service:
                name: {{ .serviceName }}
                port:
                  number: {{ .servicePort }}
        {{- end }}
    {{- end }}
{{- end }}
