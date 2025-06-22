apiVersion: v1
kind: PersistentVolume
metadata:
  name: playlist-sync-pv
  namespace: playlist-sync
spec:
  capacity:
    storage: 100Gi
  accessModes:
    - ReadWriteMany
  persistentVolumeReclaimPolicy: Retain
  nfs:
    server: {{ .Values.nfs.server | quote }}
    path: {{ .Values.nfs.path | quote }}
