#!/bin/bash
echo "Installing MicroK8s..."
sudo snap install microk8s --classic --channel=1.28/stable
sudo usermod -a -G microk8s $USER
sudo chown -f -R $USER ~/.kube
sudo microk8s status --wait-ready
echo "Enabling Addons..."
sudo microk8s enable dns hostpath-storage ingress helm
sudo microk8s alias kubectl
echo "Kubernetes Ready!"
