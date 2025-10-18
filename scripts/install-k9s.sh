#!/bin/bash

echo "🎨 Installing k9s - Terminal UI for Kubernetes"
echo "==============================================="
echo ""

# Detect OS
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$ID
else
    echo "❌ Cannot detect OS"
    exit 1
fi

case $OS in
    ubuntu|debian)
        echo "📦 Installing k9s on Ubuntu/Debian..."
        
        # Download latest k9s
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
        
        wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
        tar -xzf k9s_Linux_amd64.tar.gz
        sudo mv k9s /usr/local/bin/
        rm k9s_Linux_amd64.tar.gz README.md LICENSE
        ;;
        
    centos|rhel|fedora|rocky|almalinux)
        echo "📦 Installing k9s on CentOS/RHEL..."
        
        # Download latest k9s
        K9S_VERSION=$(curl -s https://api.github.com/repos/derailed/k9s/releases/latest | grep tag_name | cut -d '"' -f 4)
        
        wget https://github.com/derailed/k9s/releases/download/${K9S_VERSION}/k9s_Linux_amd64.tar.gz
        tar -xzf k9s_Linux_amd64.tar.gz
        sudo mv k9s /usr/local/bin/
        rm k9s_Linux_amd64.tar.gz README.md LICENSE
        ;;
        
    *)
        echo "❌ Unsupported OS: $OS"
        exit 1
        ;;
esac

echo ""
echo "✅ k9s installed successfully!"
echo ""
echo "=========================================="
echo "🎨 k9s - Terminal UI for Kubernetes"
echo "=========================================="
echo ""
echo "🚀 Launch k9s:"
echo "   k9s"
echo ""
echo "⌨️  Keyboard shortcuts:"
echo "   0 - Show all namespaces"
echo "   : - Command mode"
echo "   / - Filter"
echo "   d - Describe resource"
echo "   l - View logs"
echo "   e - Edit resource"
echo "   ? - Help"
echo "   Ctrl+C - Exit"
echo ""
echo "📚 Navigate:"
echo "   :pods     - View pods"
echo "   :svc      - View services"
echo "   :deploy   - View deployments"
echo "   :ns       - View namespaces"
echo ""
echo "💡 Try it now:"
echo "   k9s"
echo ""
