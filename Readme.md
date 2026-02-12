                                 On-Prem Data Center
┌───────────────────────────────────────────────────────────────────────────────────┐
│                                                                                   │
│  Entity Cluster A        Entity Cluster B                                         │
│ ┌──────────────────┐    ┌──────────────────┐                                      │
│ │ kube-prometheus- │    │ kube-prometheus- │                                      │
│ │ stack            │    │ stack            │                                      │
│ │ ┌──────────────┐ │    │ ┌──────────────┐ │   Outbound traffic on port 10901      │
│ │ │  Prometheus  │ │    │ │  Prometheus  │ │                                      │
│ │ │ remote_write │ │───>│ │ remote_write │ │───────────────────────────────────┐  │
│ │ └──────────────┘ │    │ └──────────────┘ │                                   │  │
│ └──────────────────┘    └──────────────────┘                                   │  │
│                                                                                │  │
└────────────────────────────────────────────────────────────────────────────────│──┘
                                                                                 │
         ┌───────────────────────────────────────────────────────────────────────┘
         ▼
┌───────────────────────────────────────────────────────────────────────────────────┐
│                        Central Monitoring Site                                    │
│                                                                                   │
│ ┌─────────────┐  TLS   ┌──────────────────┐   Plain   ┌─────────────────────────┐ │
│ │ Corporate   │ Term.  │     HAProxy      │   HTTP    │ Central K8s Cluster     │ │
│ │ DNS         ├───────>│ Frontend: 10901  ├──────────>│                         │ │
│ │ monitoring. │        │ Backend: workers │           │   ┌─────────────────┐   │ │
│ │ company.com │        └──────────────────┘           │   │ Thanos Receive  │   │ │
│ └─────────────┘                                       │   │ (Service)       │   │ │
│                                                       │   └─────────────────┘   │ │
│                                                       │            │            │ │
│                                                       │   ┌────────v────────┐   │ │
│                                                       │   │ Object Storage  │   │ │
│                                                       │   │ (e.g., MinIO)   │   │ │
│                                                       │   └────────┬────────┘   │ │
│                                                       │            │            │ │
│                                                       │   ┌────────v────────┐   │ │
│                                                       │   │ Thanos Query,   │   │ │
│                                                       │   │ Store, Compact  │   │ │
│                                                       │   └─────────────────┘   │ │
│                                                       └─────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────────────────┘



helm upgrade --install prometheus-a \
  prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f values-cluster-a.yaml


kubectl create secret generic thanos-objstore-config \
  --from-file=objstore.yml=./objstore.yml \
  -n monitoring


helm install thanos-hub bitnami/thanos \
  -n monitoring --create-namespace \
  -f values-thanos-hub.yaml
