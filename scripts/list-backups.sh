#!/bin/bash

echo "📋 Available Backups"
echo "===================="

# Get a pod with access to backup storage
POD=$(kubectl get pod -n backups -l job-name -o jsonpath='{.items[0].metadata.name}' 2>/dev/null)

if [ -z "$POD" ]; then
    # Create a temporary pod to access backups
    echo "Creating temporary pod to access backups..."
    kubectl run backup-viewer --image=postgres:17 -n backups --restart=Never --rm -i --tty \
        --overrides='
        {
          "spec": {
            "containers": [{
              "name": "backup-viewer",
              "image": "postgres:17",
              "command": ["ls", "-lh", "/backups"],
              "volumeMounts": [{
                "name": "backup-storage",
                "mountPath": "/backups"
              }]
            }],
            "volumes": [{
              "name": "backup-storage",
              "persistentVolumeClaim": {
                "claimName": "backup-storage"
              }
            }]
          }
        }'
else
    kubectl exec -n backups $POD -- ls -lh /backups
fi
