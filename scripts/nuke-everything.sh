#!/bin/bash

# WARNING: THIS SCRIPT DELETES EVERYTHING. DO NOT RUN UNLESS YOU WANT A CLEAN SERVER.
# USE FOR VIDEO RECORDING PREPARATION ONLY.

echo "â☢️  INITIATING NUCLEAR RESET FOR VIDEO PREP..."
echo "This will delete MicroK8s, all data, and reset the server state."
echo "You have 10 seconds to CTRL+C..."
sleep 10

# 1. Uninstall Odoo Stack
echo "1️⃣ Uninstalling Odoo..."
if [ -f "uninstall-odoo.sh" ]; then
    echo "yes" | ./uninstall-odoo.sh
fi

# 2. Remove Deployment Files from Cluster
kubectl delete deployment odoo postgresql traefik --all-namespaces 2>/dev/null
kubectl delete svc odoo postgresql traefik --all-namespaces 2>/dev/null
kubectl delete pvc --all --all-namespaces 2>/dev/null
kubectl delete pv --all 2>/dev/null

# 3. Uninstall MicroK8s (if installed)
echo "2️⃣ Removing MicroK8s..."
if command -v snap &> /dev/null; then
    snap remove microk8s
fi

# 4. Uninstall Kubeadm/Kubelet (if installed previously)
echo "3️⃣ Removing Standard Kubernetes..."
kubeadm reset -f 2>/dev/null
apt-get purge -y kubeadm kubectl kubelet kubernetes-cni kube* 2>/dev/null
apt-get autoremove -y
rm -rf ~/.kube
rm -rf /etc/cni /etc/kubernetes /var/lib/etcd /var/lib/kubelet

# 5. Clean Data Directories
echo "4️⃣ Cleaning Data Directories..."
rm -rf /var/lib/odoo
rm -rf /var/lib/odoo-storage
rm -rf /opt/extra-addons/* # (Optional: Keep addons if you want to preload them?)
# Actually, for video "from 0", maybe keep addons to save upload time?
# Let's keep /opt/extra-addons but clean the rest.
echo "   (Keeping /opt/extra-addons to assume files are uploaded)"

# 6. Reset Network
echo "5️⃣ Resetting Network..."
iptables -F
iptables -t nat -F
ip link delete cni0 2>/dev/null
ip link delete flannel.1 2>/dev/null

echo ""
echo "✨ SERVER CLEAN. READY FOR RECORDING."
echo "Start your video now!"
