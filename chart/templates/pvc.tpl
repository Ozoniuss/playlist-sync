apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: playlist-sync-pvc
  namespace: playlist-sync
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: {{ .Values.nfs.storage | quote }}
  storageClassName: ''
