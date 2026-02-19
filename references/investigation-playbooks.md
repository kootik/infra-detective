# Investigation Playbooks

Layer-specific investigation procedures for infrastructure incidents. Each playbook includes specific commands, what to look for, and decision trees.

## Layer 5: User-Facing (HTTP errors, latency)

### Signals
- HTTP 5xx rate spike
- P99 latency exceeds SLO
- User-reported errors

### Investigation Steps
1. **Check ingress/load balancer**
   ```bash
   # Nginx ingress logs
   kubectl logs -n ingress-nginx -l app.kubernetes.io/name=ingress-nginx --tail=100 | grep "5[0-9][0-9]"
   # HAProxy stats
   curl -s http://localhost:8404/stats | grep -E "(FRONTEND|BACKEND)"
   ```

2. **Identify affected endpoints**
   ```promql
   # Top 5xx endpoints
   topk(10, sum by (path, status_code) (rate(http_requests_total{status_code=~"5.."}[5m])))
   # Latency by endpoint
   histogram_quantile(0.99, sum by (le, path) (rate(http_request_duration_seconds_bucket[5m])))
   ```

3. **Trace downstream**
   - Follow the request path: LB → ingress → service → pod → database/cache
   - At each hop, check: is the error generated here or passed through?

### Decision Tree
```
5xx spike detected
├── All endpoints affected?
│   ├── Yes → Infrastructure issue (Layer 2-3). Check nodes, DNS, service mesh.
│   └── No → Application issue (Layer 4). Check specific service pods.
├── New deployment in last 2h?
│   ├── Yes → Likely regression. Check deployment diff, consider rollback.
│   └── No → External trigger or resource exhaustion. Check metrics.
└── Gradual or sudden onset?
    ├── Sudden → Config change, deployment, or external dependency failure.
    └── Gradual → Resource leak, connection pool exhaustion, cache eviction.
```

---

## Layer 4: Application (OOM, crashes, connection issues)

### Signals
- Pod restart count increasing
- OOMKilled events
- Connection pool exhaustion
- Crash loop backoff

### Investigation Steps
1. **Pod health check**
   ```bash
   # Recent pod events
   kubectl get events --sort-by=.lastTimestamp -n <namespace> | head -30
   # OOM events
   kubectl get events -n <namespace> --field-selector reason=OOMKilling
   # Crash loops
   kubectl get pods -n <namespace> | grep -E "CrashLoopBackOff|Error|OOMKilled"
   # Pod resource usage vs limits
   kubectl top pods -n <namespace> --sort-by=memory
   ```

2. **Application logs**
   ```bash
   # Last restart logs
   kubectl logs <pod> -n <namespace> --previous --tail=200
   # Current logs with error filter
   kubectl logs <pod> -n <namespace> --tail=500 | grep -iE "error|fatal|panic|exception"
   ```

3. **Resource analysis**
   ```promql
   # Memory usage vs limit (OOM prediction)
   container_memory_working_set_bytes{namespace="<ns>"} / container_spec_memory_limit_bytes{namespace="<ns>"}
   # CPU throttling
   rate(container_cpu_cfs_throttled_periods_total{namespace="<ns>"}[5m]) / rate(container_cpu_cfs_periods_total{namespace="<ns>"}[5m])
   ```

### Common Patterns
| Pattern | Signal | Typical Cause |
|---------|--------|---------------|
| Sawtooth memory | Memory rises linearly, drops on restart | Memory leak |
| Sudden OOM | Memory jumps from normal to limit | Large allocation (file load, query result) |
| CPU throttle spiral | Throttle % rises, latency rises, more requests queue | Underprovisioned CPU limits |
| Connection storm | Connections spike, then errors | Missing connection pooling or pool exhaustion |

---

## Layer 3: Platform (K8s, DNS, Service Mesh)

### Signals
- Pods stuck in Pending
- DNS resolution failures
- Service mesh (Istio/Linkerd) sidecar errors
- Scheduling failures

### Investigation Steps
1. **Scheduling issues**
   ```bash
   # Pending pods with reasons
   kubectl get pods --all-namespaces --field-selector=status.phase=Pending
   # Describe for scheduling failure reason
   kubectl describe pod <pending-pod> -n <namespace> | grep -A5 "Events:"
   # Node resource pressure
   kubectl describe nodes | grep -A5 "Conditions:" | grep -E "True|False"
   # Taints blocking scheduling
   kubectl get nodes -o custom-columns=NAME:.metadata.name,TAINTS:.spec.taints
   ```

2. **DNS investigation**
   ```bash
   # CoreDNS health
   kubectl get pods -n kube-system -l k8s-app=kube-dns
   kubectl logs -n kube-system -l k8s-app=kube-dns --tail=50
   # DNS resolution test from pod
   kubectl run dns-test --image=busybox --rm -it -- nslookup kubernetes.default
   # CoreDNS metrics
   kubectl top pods -n kube-system -l k8s-app=kube-dns
   ```

3. **Service mesh**
   ```bash
   # Istio proxy status
   istioctl proxy-status
   # Sidecar logs
   kubectl logs <pod> -c istio-proxy --tail=100
   # Envoy config dump (check routes, clusters)
   istioctl proxy-config routes <pod>
   ```

---

## Layer 2: Infrastructure (Nodes, Disks, Network)

### Signals
- Node NotReady
- Disk pressure
- Network partition indicators
- Cloud provider alerts

### Investigation Steps
1. **Node health**
   ```bash
   # Node conditions
   kubectl get nodes -o wide
   kubectl describe node <node> | grep -A15 "Conditions:"
   # System resources
   kubectl top nodes
   # Kernel logs (if SSH access)
   journalctl -k --since "1 hour ago" | grep -iE "error|oom|kill|panic"
   ```

2. **Disk pressure**
   ```bash
   # Disk usage per node
   kubectl get nodes -o jsonpath='{range .items[*]}{.metadata.name}{"\t"}{.status.conditions[?(@.type=="DiskPressure")].status}{"\n"}{end}'
   # PV/PVC status
   kubectl get pv,pvc --all-namespaces | grep -v Bound
   # Identify large consumers
   du -sh /var/lib/kubelet/pods/*/volumes/ 2>/dev/null | sort -rh | head -10
   ```

3. **Network**
   ```bash
   # Pod-to-pod connectivity test
   kubectl run net-test --image=nicolaka/netshoot --rm -it -- curl -s -o /dev/null -w "%{http_code}" http://<service>.<namespace>.svc.cluster.local
   # Network policy audit
   kubectl get networkpolicies --all-namespaces
   # CNI logs
   journalctl -u kubelet | grep -i "cni\|network" | tail -20
   ```

---

## Layer 1: External Dependencies

### Signals
- Third-party API errors (HTTP 502/503/timeout)
- Cloud provider status page alerts
- DNS root/TLD issues
- Certificate expiration

### Investigation Steps
1. **Cloud provider status**: Check provider status pages and recent incident reports
2. **Third-party health**: Test connectivity and response from inside cluster
   ```bash
   kubectl run ext-test --image=curlimages/curl --rm -it -- \
     curl -sv -o /dev/null -w "HTTP %{http_code} | DNS: %{time_namelookup}s | Connect: %{time_connect}s | Total: %{time_total}s\n" \
     https://api.external-service.com/health
   ```
3. **Certificate check**
   ```bash
   echo | openssl s_client -connect api.example.com:443 2>/dev/null | openssl x509 -noout -dates
   ```

---

## Cross-Layer Correlation Matrix

Use this to identify which layers to investigate based on symptom combinations:

| Symptom A | + Symptom B | Likely Layers | First Check |
|-----------|-------------|---------------|-------------|
| 5xx spike | Pod restarts | L4 + L5 | Application logs, OOM events |
| 5xx spike | No pod issues | L3 + L5 | DNS, service mesh, ingress config |
| Latency rise | CPU throttle | L4 | Resource limits, HPA config |
| Latency rise | Network errors | L2 + L3 | CNI, node networking, network policies |
| Pods Pending | Node NotReady | L2 | Node conditions, cloud provider |
| All services down | Single node affected | L2 | Node failure, disk pressure |
| All services down | All nodes affected | L1 + L2 | Cloud provider, DNS root, network partition |
| Intermittent errors | No pattern | L3 | DNS caching, service mesh retries, race conditions |
