# Jitsi Meet

Scalable video conferencing on Kubernetes.

## Structure

The whole setup is based on Kubernetes YAML files and patches for these files.
It makes use of [kustomize](https://github.com/kubernetes-sigs/kustomize) to customize the raw YAMLs for each environment.

Every directory in the directory tree (depicted below) contains a `kustomize.yaml` file which defines resources (and possibly patches).

```
|-- base
|   |-- cert-manager
|   |-- dashboard
|   |-- ingress-nginx
|   |-- jitsi
|   |   `-- jvb
|   |-- metacontroller
|   `-- monitoring
|-- overlays
|   |-- development
|   `-- production
`-- resources
```

## Requirements

- [kubectl/v1.17.2+](https://kubernetes.io/docs/tasks/tools/install-kubectl/)
- [kustomize/v3.5.4+](https://github.com/kubernetes-sigs/kustomize/releases/tag/kustomize%2Fv3.5.4)

## Install

To install the full setup go to either `overlays/development` or `overlays/production` and run

```bash
$ kustomize build . | kubectl apply -f -
```

The setup was tested against a managed Kubernetes cluster (v1..17.2) running on [IONOS Cloud](https://dcd.ionos.com/).
