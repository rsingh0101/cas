Centralized Monitoring Architecture (On-Prem, Multi-Cluster)
Overview

This document describes the centralized Prometheus monitoring architecture for multiple on-prem Kubernetes entity clusters using:

kube-prometheus-stack per entity cluster

Prometheus remote_write

Central Thanos Receive

HAProxy (port 10901, TLS enabled)

Object storage backend (MinIO / S3-compatible)

Thanos Query for global PromQL

This design:

Uses outbound-only communication from entity clusters

Avoids exposing NodePorts externally

Keeps production HAProxy port 7443 untouched

Uses dedicated port 10901 for monitoring traffic

High-Level Architecture
                                 On-Prem Data Center
┌───────────────────────────────────────────────────────────────────────────────────┐
│                                                                                   │
│  Entity Cluster A        Entity Cluster B                                         │
│ ┌──────────────────┐    ┌──────────────────┐                                      │
│ │ kube-prometheus- │    │ kube-prometheus- │                                      │
│ │ stack            │    │ stack            │                                      │
│ │ ┌──────────────┐ │    │ ┌──────────────┐ │   Outbound traffic on port 10901    │
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
│ └─────────────┘                                       │   │ (ClusterIP)     │   │ │
│                                                       │   └─────────────────┘   │ │
│                                                       │            │            │ │
│                                                       │   ┌────────v────────┐   │ │
│                                                       │   │ Object Storage  │   │ │
│                                                       │   │ (MinIO / S3)    │   │ │
│                                                       │   └────────┬────────┘   │ │
│                                                       │            │            │ │
│                                                       │   ┌────────v────────┐   │ │
│                                                       │   │ Thanos Query,   │   │ │
│                                                       │   │ Store, Compactor│   │ │
│                                                       │   └─────────────────┘   │ │
│                                                       └─────────────────────────┘ │
└───────────────────────────────────────────────────────────────────────────────────┘

Design Decisions
Chosen Model: Remote Write

Prometheus scrapes locally in each cluster

Metrics pushed to central Thanos Receive

No StoreAPI fan-out

No inbound access to entity clusters required

Networking

Single bridge IP

Port 10901 dedicated to monitoring

TLS termination at HAProxy

HAProxy routes internally to Kubernetes ClusterIP service

No external NodePort exposure

Entity Cluster Configuration

Each entity cluster deploys kube-prometheus-stack with remote write enabled.

Install kube-prometheus-stack
helm upgrade --install prometheus-a \
  prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f values-cluster-a.yaml

Example values-cluster-a.yaml
prometheus:
  prometheusSpec:
    externalLabels:
      cluster: cluster-a

    remoteWrite:
      - url: "https://monitoring.company.com:10901/api/v1/receive"
        tlsConfig:
          insecureSkipVerify: false


Each cluster must use a unique externalLabels.cluster value.

Central Monitoring Deployment
1. Create Object Storage Secret
kubectl create secret generic thanos-objstore-config \
  --from-file=objstore.yml=./objstore.yml \
  -n monitoring

2. Deploy Thanos Hub
helm install thanos-hub bitnami/thanos \
  -n monitoring --create-namespace \
  -f values-thanos-hub.yaml


Central components:

Thanos Receive (≥ 2 replicas)

Thanos Query

Thanos Store

Thanos Compactor

Object Storage backend (MinIO / S3-compatible)

HAProxy Configuration (Conceptual)

HAProxy listens on 10901 and terminates TLS.

frontend monitoring_receive
  bind *:10901 ssl crt /etc/haproxy/certs/monitoring.pem
  mode http
  default_backend thanos_receive

backend thanos_receive
  balance roundrobin
  server r1 10.0.1.10:19291 check
  server r2 10.0.1.11:19291 check


Notes:

monitoring.company.com resolves to HAProxy IP.

HAProxy forwards internally to Thanos Receive service.

Production HAProxy port 7443 remains untouched.

Security Model

TLS enforced on port 10901

Unique external labels per cluster

No NodePort exposed externally

Monitoring plane logically separated from production traffic

Optional mTLS support if required

Scaling Strategy
Scale Thanos Receive

Scale based on total ingestion rate:

Increase replicas

HAProxy balances across replicas

Shared object storage backend required

Scale Thanos Query

Horizontal scaling

Stateless component

Can run multiple replicas behind service

Validation Checklist
1. Test Connectivity

From entity cluster:

curl -vk https://monitoring.company.com:10901/api/v1/receive


Should respond (even if 405).

2. Verify Ingestion

In Thanos Query:

up


You should see metrics from multiple clusters with cluster label.

3. Cross-Cluster Query
sum(rate(container_cpu_usage_seconds_total[5m])) by (cluster)


Confirms global aggregation.

Final Characteristics

✔ Outbound-only connectivity
✔ Single monitoring ingress port (10901)
✔ TLS secured
✔ No external NodePort exposure
✔ Production traffic isolated
✔ Horizontally scalable
✔ Enterprise-grade on-prem design
