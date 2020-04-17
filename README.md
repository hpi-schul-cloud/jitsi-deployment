# Setup

## Setup Dashboard

- Deploy Dashboard UI with `kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml` (see [documentation](https://github.com/kubernetes/dashboard/blob/master/docs/user/access-control/creating-sample-user.md))
- Create service account and cluster role binding by creating two files (e.g. `dashboard-service-account.yaml` and `dashboard-cluster-role-binding.yaml`, contents below) and run `kubectl apply -f dashboard-service-account.yaml -f dashboard-cluster-role-binding.yaml`

`dashboard-service-account.yaml` has the following content:
```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: admin-user
  namespace: kubernetes-dashboard
```

`dashboard-cluster-role-binding.yaml` has the following content:
```
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: admin-user
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
- kind: ServiceAccount
  name: admin-user
  namespace: kubernetes-dashboard
```

- Find the bearer token to login with `kubectl -n kubernetes-dashboard describe secret $(kubectl -n kubernetes-dashboard get secret | grep admin-user | awk '{print $1}')`
- Run `kubectl proxy` (this command must be kept running as long as the dashboard is in use) and access http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/
- Paste the previously found token in the given field on the login page

### Add Metrics Server

- Clone the repo with `git clone https://github.com/kubernetes-sigs/metrics-server.git`
- Add two more container arguments to the deployment in `metrics-server/deploy/kubernetes/metrics-server-deployment.yaml`:

```
--kubelet-insecure-tls
--kubelet-preferred-address-types=InternalIP,ExternalIP,Hostname
```

- Apply all changes with `kubectl apply -f metrics-server/deploy/kubernetes/`

## Install Jitsi Meet

- Create a new namespace with `kubectl create namespace jitsi`
- Create a secret with values (replace `<secret>` occurrences with actual secrets): `kubectl create secret -n jitsi generic jitsi-config --from-literal=JICOFO_COMPONENT_SECRET=<secret> --from-literal=JICOFO_AUTH_PASSWORD=<secret> --from-literal=JVB_AUTH_PASSWORD=<secret>`
- Deploy the service to listen for JVB UDP traffic on all cluster nodes port 30300 with `kubectl create -f https://raw.githubusercontent.com/jitsi/docker-jitsi-meet/dev/examples/kubernetes/jvb-service.yaml`

- Download https://raw.githubusercontent.com/jitsi/docker-jitsi-meet/dev/examples/kubernetes/deployment.yaml and replace

```
- name: DOCKER_HOST_ADDRESS
  value: <Set the address for any node in the cluster here>
```

with

```
- name: DOCKER_HOST_ADDRESS
  valueFrom:
    fieldRef:
      fieldPath: status.hostIP
```
- Apply the deployment with `kubectl apply -f deployment.yaml`
- Create a file named `jitsi-service.yaml` with the following content:

```
apiVersion: v1
kind: Service
metadata:
  labels:
    service: web
  name: web
  namespace: jitsi
spec:
  ports:
  - name: "https"
    port: 443
    targetPort: 443
  selector:
    k8s-app: jitsi
  type: LoadBalancer
```
- To expose the webapp apply this with `kubectl create -f jitsi-service.yaml`
- The service should now have an external IP address where you can reach the Jitsi installation

