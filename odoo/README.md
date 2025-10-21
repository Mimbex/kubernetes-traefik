# Odoo Configuration

## 🚀 Performance Configuration

This Odoo deployment is configured for **production performance** with:

### **Workers & Gevent**

```ini
workers = 4                    # Multi-process mode
max_cron_threads = 2          # Cron workers
server_wide_modules = base,web # Enable gevent mode
```

**Why gevent?**
- ✅ Better concurrency for web requests
- ✅ Non-blocking I/O
- ✅ Handles more simultaneous users
- ✅ Lower memory footprint per connection

---

## 📊 Resource Allocation

### **Container Resources:**
```yaml
requests:
  memory: 2Gi   # Minimum guaranteed
  cpu: 1000m    # 1 CPU core
limits:
  memory: 4Gi   # Maximum allowed
  cpu: 2000m    # 2 CPU cores
```

### **Memory Limits (odoo.conf):**
```ini
limit_memory_hard = 2684354560  # 2.5 GB per worker
limit_memory_soft = 2147483648  # 2 GB per worker
```

**Calculation:**
- 4 workers × 2.5 GB = ~10 GB total (with overhead)
- Container limit: 4 GB (Kubernetes will manage)

---

## ⚙️ Workers Configuration

### **Formula for workers:**
```
workers = (CPU cores × 2) + 1
```

**Examples:**
- 1 CPU → 3 workers
- 2 CPU → 5 workers
- 4 CPU → 9 workers

**Current setup:**
- 2 CPU cores → 4 workers (conservative)

---

## 🔧 Tuning for Your Environment

### **Low Resources (1 CPU, 2GB RAM):**
```ini
workers = 2
max_cron_threads = 1
limit_memory_hard = 1073741824  # 1 GB
limit_memory_soft = 805306368   # 768 MB
```

### **Medium Resources (2 CPU, 4GB RAM):**
```ini
workers = 4
max_cron_threads = 2
limit_memory_hard = 2684354560  # 2.5 GB
limit_memory_soft = 2147483648  # 2 GB
```

### **High Resources (4 CPU, 8GB RAM):**
```ini
workers = 8
max_cron_threads = 4
limit_memory_hard = 2684354560  # 2.5 GB
limit_memory_soft = 2147483648  # 2 GB
```

---

## 🎯 Gevent vs Standard Mode

### **Standard Mode (workers = 0):**
- Single process
- Blocking I/O
- Good for: Development, testing
- Max users: ~10 concurrent

### **Gevent Mode (workers > 0):**
- Multi-process
- Non-blocking I/O
- Good for: Production
- Max users: ~100+ concurrent (depends on resources)

---

## 📝 Configuration Files

### **01-configmap.yaml**
Contains `odoo.conf` with all performance settings.

### **02-deployment.yaml**
Defines container resources and limits.

---

## 🔍 Monitoring Performance

### **Check worker status:**
```bash
kubectl exec -n odoo deployment/odoo -- ps aux | grep odoo
```

### **Check memory usage:**
```bash
kubectl top pod -n odoo
```

### **Check logs:**
```bash
kubectl logs -n odoo deployment/odoo -f
```

### **Check if gevent is active:**
```bash
kubectl logs -n odoo deployment/odoo | grep -i gevent
```

You should see:
```
INFO ? odoo.service.server: Evented Service (longpolling) running on ...
```

---

## ⚠️ Important Notes

1. **Workers = 0** disables multi-processing (dev mode)
2. **Workers > 0** enables production mode with gevent
3. **Gevent requires** `server_wide_modules = base,web`
4. **Memory limits** prevent OOM kills
5. **CPU limits** prevent resource starvation

---

## 🆘 Troubleshooting

### **Pod keeps restarting (OOMKilled):**
- Reduce `workers` or increase memory limits
- Check: `kubectl describe pod -n odoo`

### **Slow performance:**
- Increase `workers` if you have CPU available
- Check: `kubectl top pod -n odoo`

### **Database connection errors:**
- Check PostgreSQL is running
- Verify connection string in configmap

---

## 📚 References

- [Odoo Performance Documentation](https://www.odoo.com/documentation/17.0/administration/install/deploy.html)
- [Gevent Documentation](http://www.gevent.org/)
- [Kubernetes Resource Management](https://kubernetes.io/docs/concepts/configuration/manage-resources-containers/)
