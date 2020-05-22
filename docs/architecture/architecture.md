# Architecture

## Jitsi Meet

### Components

A Jitsi Meet installation consists of the following different components:

1. `web` This container represents the web frontend and is the entrypoint for each user.
2. `jicofo` This component is responsible for managing media sessions between each of the participants and the videobridge.
3. `prosody` This is the XMPP server used for creating the MUCs (multi-user conferences).
4. `jvb` The Jitsi Videobridge is an XMPP server component that allows for multi-user video communication.

Jitsi uses the term "shard" to describe the composition that contains single containers for
`web`, `jicofo`, `prosody` and multiple containers of `jvb` running in parallel. The following diagram
depicts this setup:

![Architecture Jitsi Meet](build/shard.png)

In this setup the videobridges can be scaled up and down depending on the current load
(number of video conferences and participants). The videobridge typically is the component with the highest load and
therefore the main part that needs to be scaled.
Nevertheless, the single containers (`web`, `jicofo`, `prosody`) are also prone to running out of resources.
This can be solved by scaling to multiple shards. Currently, this is not implemented within this setup but will
be addressed at a later stage. More information about this topic can be found in the [Scaling Jitsi Meet in the Cloud Tutorial
](https://www.youtube.com/watch?v=Jj8a6ZRgehI).

### Kubernetes Setup

Making use of the Kubernetes framework the current shard setup looks as follows:

![Architecture Jitsi Meet](build/jitsi_meet.png)

The entrypoint for every user is the ingress that is defined in [jitsi-ingress.yaml](../../base/jitsi/jitsi-ingress.yaml)
and patched for each environment by [jitsi-ingress-patch.yaml](../../overlays/production/jitsi-ingress-patch.yaml).
At this point SSL is terminated and forwarded to the [`web` service](../../base/jitsi/web-service.yaml) in plaintext (port 80)
which in turn exposes the web frontend inside the cluster.

The single containers (`web`, `jicofo`, `prosody`) all run together inside a single pod called `jitsi`. This pod is
managed by a rolling [deployment](../../base/jitsi/jitsi-deployment.yaml).

When a user starts a conference it is assigned to a videobridge. The video streaming happens directly between the user
and this videobridge. Therefore the videobridges need to be open to the internet. This happens with a service of type `NodePort`
for each videobridge (on a different port).

The videobridges are managed by a [stateful set](../../base/jitsi/jvb/jvb-statefulset.yaml) (to get predictable pod names)
and is patched by each environment with different resource requests/limits.
A [horizontal pod autoscaler](../../base/jitsi/jvb/jvb-hpa.yaml) governs the number of running videobridges based on
the average value of the network traffic transmitted to/from the pods. A minimum of 2 videobridge pods are always running.

To achieve the setup of an additional `NodePort` service on a dedicated port per pod in the videobridge stateful set a
[custom controller](https://metacontroller.app/api/decoratorcontroller/) is used.
This [`service-per-pod` controller](../../base/metacontroller/service-per-pod-configmap.yaml) is triggered by the
creation of a new videobridge pod and sets up the new service binding to a port defined by a base port (30000) plus the
number of the videobridge pod (e.g. 30001 for pod `jvb-1`). A [startup script](../../base/jitsi/jvb/jvb-entrypoint-configmap.yaml)
handles the configuration of the port in use by videobridge.

In addition, all videobridges communicate with the `prosody` server via a [service](../../base/jitsi/prosody-service.yaml)
of type `ClusterIP`.

## Monitoring

The monitoring stack is comprised of a [kube-prometheus](https://github.com/coreos/kube-prometheus) setup that integrates
* [Prometheus Operator](https://github.com/coreos/prometheus-operator)
* Highly available [Prometheus](https://prometheus.io/)
* Highly available [Alertmanager](https://github.com/prometheus/alertmanager)
* [Prometheus node-exporter](https://github.com/prometheus/node_exporter)
* [Prometheus Adapter for Kubernetes Metrics APIs](https://github.com/DirectXMan12/k8s-prometheus-adapter)
* [kube-state-metrics](https://github.com/kubernetes/kube-state-metrics)
* [Grafana](https://grafana.com/)

This stack is adapted and patched to fit the needs of the Jitsi Meet setup.

The [deployment patch for Grafana](../../base/monitoring/grafana-deployment-patch.yaml) adds a permanent storage to retain
users and changes made in the dashboards. In addition, Grafana is configured to serve from the subpath `/grafana`.
An [ingress](../../base/monitoring/grafana-ingress.yaml) is defined to route traffic to the Grafana instance.
Again, SSL is terminated at the ingress.

A role and a role binding to let Prometheus monitor the `jitsi` namespace is defined in
[prometheus-roleBindingSpecificNamespaces.yaml](../../base/monitoring/prometheus-roleBindingSpecificNamespaces.yaml) and
[prometheus-roleSpecificNamespaces.yaml](../../base/monitoring/prometheus-roleSpecificNamespaces.yaml) respectively.

Prometheus also gets adapted by an environment specific [patch](../../overlays/production/prometheus-prometheus-patch.yaml)
that adjusts CPU/memory requests and adds a persistent volume.

Furthermore, [metrics-server](https://github.com/kubernetes-sigs/metrics-server) is used to aggregate resource usage data.

### Videobridge monitoring

The videobridge pods mentioned above have a sidecar container deployed that gathers metrics about the videobridge and
exposes them via a Rest endpoint. This endpoint is scraped by Prometheus based on the definition of a
[PodMonitor](../../base/monitoring/jvb-pod-monitor.yaml) available by the
[Prometheus Operator](https://github.com/coreos/prometheus-operator#customresourcedefinitions).
