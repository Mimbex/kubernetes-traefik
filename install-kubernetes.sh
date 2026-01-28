#!/bin/bash

echo "🚀 Kubernetes Production Installation for Linux"
echo "================================================"
echo ""
echo "This script will install a production-ready Kubernetes cluster."
echo "Supports: Ubuntu/Debian and CentOS/RHEL"
echo ""

# Check if running on Linux
if [[ "$OSTYPE" != "linux-gnu"* ]]; then
    echo "❌ This script is for Linux servers only"
    echo "For local development on macOS, use Docker Desktop with Kubernetes"
    exit 1
fi

# Detect Linux distribution
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect Linux distribution"
    exit 1
fi

echo "📋 Detected OS: $OS"
echo "📋 Version: $VERSION_ID"
echo ""

# Check if running as root or with sudo
if [[ $EUID -ne 0 ]]; then
   echo "⚠️  This script requires sudo privileges"
   echo "Please run with: sudo ./install-kubernetes.sh"
   exit 1
fi

echo "✅ Running with sudo privileges"
echo ""

# Function to install on Ubuntu/Debian
install_ubuntu() {
    echo "📦 Installing Kubernetes on Ubuntu/Debian..."
    echo ""
    
    # Update system
    echo "1️⃣ Updating system packages..."
    apt-get update
    apt-get upgrade -y
    
    # Install dependencies
    echo ""
    echo "2️⃣ Installing dependencies..."
    apt-get install -y apt-transport-https ca-certificates curl gnupg lsb-release
    
    # Disable swap (required for Kubernetes)
    echo ""
    echo "3️⃣ Disabling swap..."
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    
    # Load kernel modules
    echo ""
    echo "4️⃣ Loading kernel modules..."
    modprobe overlay
    modprobe br_netfilter
    
    cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
    
    # Configure sysctl
    cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
    
    sysctl --system > /dev/null 2>&1
    
    # Install containerd
    echo ""
    echo "5️⃣ Installing containerd..."
    apt-get install -y containerd
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    
    # Enable SystemdCgroup (CRITICAL for Kubernetes)
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    
    systemctl restart containerd
    systemctl enable containerd
    
    # Verify containerd is running
    if ! systemctl is-active --quiet containerd; then
        echo "❌ containerd failed to start"
        systemctl status containerd
        exit 1
    fi
    echo "✅ containerd is running"
    
    # Install CNI plugins
    echo ""
    echo "5.5️⃣ Installing CNI plugins..."
    mkdir -p /opt/cni/bin
    CNI_VERSION="v1.3.0"
    wget -q https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz -O /tmp/cni-plugins.tgz
    tar -xzf /tmp/cni-plugins.tgz -C /opt/cni/bin/
    rm /tmp/cni-plugins.tgz
    echo "✅ CNI plugins installed"
    
    # Install kubeadm, kubelet, kubectl
    echo ""
    echo "6️⃣ Installing Kubernetes components..."
    # Clean up old key if exists to avoid interactive prompt
    rm -f /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
    echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | tee /etc/apt/sources.list.d/kubernetes.list
    apt-get update
    apt-get install -y kubelet kubeadm kubectl
    apt-mark hold kubelet kubeadm kubectl
    
    # Enable kubelet
    systemctl enable kubelet
    
    echo ""
    echo "✅ Kubernetes components installed"
}

# Function to install on CentOS/RHEL
install_centos() {
    echo "📦 Installing Kubernetes on CentOS/RHEL..."
    echo ""
    
    # Update system
    echo "1️⃣ Updating system packages..."
    yum update -y
    
    # Install dependencies
    echo ""
    echo "2️⃣ Installing dependencies..."
    yum install -y curl yum-utils device-mapper-persistent-data lvm2
    
    # Disable swap
    echo ""
    echo "3️⃣ Disabling swap..."
    swapoff -a
    sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
    
    # Load kernel modules
    echo ""
    echo "4️⃣ Loading kernel modules..."
    modprobe overlay
    modprobe br_netfilter
    
    cat <<EOF | tee /etc/modules-load.d/k8s.conf
overlay
br_netfilter
EOF
    
    # Configure sysctl
    cat <<EOF | tee /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-iptables  = 1
net.bridge.bridge-nf-call-ip6tables = 1
net.ipv4.ip_forward                 = 1
EOF
    
    sysctl --system > /dev/null 2>&1
    
    # Disable SELinux
    echo ""
    echo "5️⃣ Configuring SELinux..."
    setenforce 0
    sed -i 's/^SELINUX=enforcing$/SELINUX=permissive/' /etc/selinux/config
    
    # Install containerd
    echo ""
    echo "6️⃣ Installing containerd..."
    yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo
    yum install -y containerd.io
    mkdir -p /etc/containerd
    containerd config default | tee /etc/containerd/config.toml
    
    # Enable SystemdCgroup (CRITICAL for Kubernetes)
    sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml
    
    systemctl restart containerd
    systemctl enable containerd
    
    # Verify containerd is running
    if ! systemctl is-active --quiet containerd; then
        echo "❌ containerd failed to start"
        systemctl status containerd
        exit 1
    fi
    echo "✅ containerd is running"
    
    # Install CNI plugins
    echo ""
    echo "6.5️⃣ Installing CNI plugins..."
    mkdir -p /opt/cni/bin
    CNI_VERSION="v1.3.0"
    wget -q https://github.com/containernetworking/plugins/releases/download/${CNI_VERSION}/cni-plugins-linux-amd64-${CNI_VERSION}.tgz -O /tmp/cni-plugins.tgz
    tar -xzf /tmp/cni-plugins.tgz -C /opt/cni/bin/
    rm /tmp/cni-plugins.tgz
    echo "✅ CNI plugins installed"
    
    # Install kubeadm, kubelet, kubectl
    echo ""
    echo "7️⃣ Installing Kubernetes components..."
    cat <<EOF | tee /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/
enabled=1
gpgcheck=1
gpgkey=https://pkgs.k8s.io/core:/stable:/v1.28/rpm/repodata/repomd.xml.key
EOF
    
    yum install -y kubelet kubeadm kubectl
    systemctl enable kubelet
    
    echo ""
    echo "✅ Kubernetes components installed"
}

# Install based on OS
case $OS in
    ubuntu|debian)
        install_ubuntu
        ;;
    centos|rhel|fedora|rocky|almalinux)
        install_centos
        ;;
    *)
        echo "❌ Unsupported OS: $OS"
        echo "Supported: Ubuntu, Debian, CentOS, RHEL, Fedora, Rocky Linux, AlmaLinux"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "✅ Kubernetes Installation Complete!"
echo "=========================================="
echo ""
echo "📋 Installed components:"
kubeadm version 2>/dev/null && echo "   ✅ kubeadm $(kubeadm version -o short)"
kubelet --version 2>/dev/null && echo "   ✅ kubelet $(kubelet --version | cut -d' ' -f2)"
kubectl version --client --short 2>/dev/null && echo "   ✅ kubectl $(kubectl version --client --short | cut -d' ' -f3)"

echo ""
echo "🚀 Next Steps - Initialize Kubernetes Cluster:"
echo "=============================================="
echo ""
echo "1️⃣ Initialize the master node:"
echo "   sudo kubeadm init --pod-network-cidr=10.244.0.0/16"
echo ""
echo "2️⃣ Configure kubectl for your user:"
echo "   mkdir -p \$HOME/.kube"
echo "   sudo cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config"
echo "   sudo chown \$(id -u):\$(id -g) \$HOME/.kube/config"
echo ""
echo "3️⃣ Install a Pod network (Flannel):"
echo "   kubectl apply -f https://github.com/flannel-io/flannel/releases/latest/download/kube-flannel.yml"
echo ""
echo "4️⃣ Verify cluster is ready:"
echo "   kubectl get nodes"
echo "   kubectl get pods --all-namespaces"
echo ""
echo "5️⃣ (Optional) Allow scheduling on master node:"
echo "   kubectl taint nodes --all node-role.kubernetes.io/control-plane-"
echo ""
echo "6️⃣ Deploy Odoo stack:"
echo "   cd $(dirname $(readlink -f $0))"
echo "   cp .env.example .env"
echo "   nano .env  # Configure your domain"
echo "   ./scripts/deploy-all.sh"
echo ""
echo "📚 Documentation:"
echo "   - Kubernetes Docs: https://kubernetes.io/docs/"
echo "   - kubeadm: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/"
echo ""
echo "⚠️  IMPORTANT NOTES:"
echo "   - This is a single-node cluster setup"
echo "   - For production, consider a multi-node cluster"
echo "   - Firewall ports: 6443, 2379-2380, 10250-10252, 30000-32767"
echo ""
echo "🎉 Happy Kubernetes!"
