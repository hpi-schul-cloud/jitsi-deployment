#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from diagrams import Diagram, Cluster
from diagrams.custom import Custom
from diagrams.k8s.clusterconfig import HPA
from diagrams.k8s.compute import Deployment, Pod, StatefulSet
from diagrams.k8s.network import Ingress, Service

globe_img = "resources/globe.png"

graph_attr = {
    "pad": "0.5"
}

with Diagram(filename="jitsi_meet", direction='TB', show=False, outformat='png', graph_attr=graph_attr):
    with Cluster("Conference 1"):
        users_1 = [Custom("user", globe_img) for _ in range(3)]
    with Cluster("Conference 2"):
        users_2 = [Custom("user", globe_img) for _ in range(2)]

    all_users = Custom("all users", globe_img)

    with Cluster("Namespace 'jitsi'"):
        n_shards = 2
        n_haproxy = 2
        haproxy_sts = StatefulSet("haproxy")
        haproxy_pods = [Pod(f"haproxy-{j}") for j in range(n_haproxy)]
        haproxy_sts >> haproxy_pods
        web_service = Service("web")
        ingress = Ingress("jitsi.messenger.schule")
        ingress >> Service("haproxy") >> haproxy_pods >> web_service

        for k in range(n_shards):
            with Cluster(f"Shard-{k}"):
                web_pod = Pod(f"shard-{k}-web")
                prosody_pod = Pod(f"shard-{k}-prosody")
                jicofo_pod = Pod(f"shard-{k}-jicofo")
                Deployment(f"shard-{k}-prosody") >> prosody_pod
                Deployment(f"shard-{k}-jicofo") >> jicofo_pod
                web_service >> web_pod
                prosody_service = Service(f"shard-{k}-prosody")
                prosody_service >> prosody_pod
                prosody_service << web_pod
                prosody_service << jicofo_pod

                n_jvbs = 3
                with Cluster(f"Jitsi Videobridge Shard-{k}"):
                    jvb_pods = [Pod(f"shard-{k}-jvb-{i}") for i in range(n_jvbs)]
                    jvb_services = [Service(f"shard-{k}-jvb-{i}") for i in range(n_jvbs)]
                [jvb_services[i] >> jvb_pods[i] >> prosody_service for i in range(n_jvbs)]
                jvb_pods << StatefulSet(f"shard-{k}-jvb") << HPA(f"shard-{k}-hpa")
                if k == 0:
                    users_1 >> jvb_services[0]
                if k == 1:
                    users_2 >> jvb_services[1]
        all_users >> ingress






