apiVersion: batch/v1
kind: CronJob
metadata:
  name: playlist-sync-job
  namespace: playlist-sync
spec:
  schedule: {{ .Values.cronjob.schedule }}
  successfulJobsHistoryLimit: 1
  failedJobsHistoryLimit: 3
  jobTemplate:
    spec:
      template:
        spec:
          containers:
            - name: playlist-sync
              image: {{ .Values.cronjob.image | quote }}
              command: {{ toJson .Values.cronjob.command }}
              env:
                - name: YOUTUBE_API_KEY
                  valueFrom:
                    secretKeyRef:
                      name: playlist-sync-secret
                      key: youtube_api_key
              volumeMounts:
                - name: playlist
                  mountPath: /mnt/playlist
          volumes:
            - name: playlist
              persistentVolumeClaim:
                claimName: playlist-sync-pvc
          restartPolicy: Never
