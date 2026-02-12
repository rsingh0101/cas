# Centralized Monitoring Architecture (On-Prem, Multi-Cluster)

## Overview

This document describes a centralized Prometheus monitoring architecture for multiple on-prem Kubernetes clusters using:

- kube-prometheus-stack per entity cluster
- Prometheus remote_write
- Thanos Receive (central ingestion)
- HAProxy (TLS on port 10901)
- Object Storage (MinIO / S3-compatible)
- Thanos Query for global PromQL

---

## Constraints

- Single bridge IP between entities
- Production HAProxy already uses port 7443
- Port 10901 available for monitoring
- No additional IP allocation
- Outbound connectivity from entity clusters allowed
- No external NodePort exposure
- TLS required

---

## Architecture

### Entity Clusters

Each cluster runs:

- kube-prometheus-stack
- Prometheus scraping locally
- remote_write enabled

Traffic flow:

Prometheus (Cluster A)
    --> https://monitoring.company.com:10901/api/v1/receive

Prometheus (Cluster B)
    --> https://monitoring.company.com:10901/api/v1/receive

Outbound TCP 10901 only.

---

### Central Monitoring Site

DNS:
monitoring.company.com --> HAProxy IP

HAProxy:
- Listens on 10901
- Terminates TLS
- Routes internally to Thanos Receive (ClusterIP)

Kubernetes Central Cluster:
- Thanos Receive (>=2 replicas)
- Object Storage (MinIO / S3)
- Thanos Query
- Thanos Compactor

Dashboard / Custom App:
- Connects only to Thanos Query

---

## Entity Cluster Deployment

Install kube-prometheus-stack:

```bash
helm upgrade --install prometheus-a \
  prometheus-community/kube-prometheus-stack \
  -n monitoring --create-namespace \
  -f values-cluster-a.yaml

