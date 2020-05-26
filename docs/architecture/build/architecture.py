#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from diagrams import Diagram, Cluster
from diagrams.custom import Custom
from diagrams.k8s.clusterconfig import HPA
from diagrams.k8s.compute import Deployment, Pod, ReplicaSet, StatefulSet
from diagrams.k8s.network import Ingress, Service

globe_img = "resources/globe.png"

graph_attr = {
    "pad": "0.5"
}

with Diagram(filename="jitsi_meet", direction='LR', show=False, outformat='png', graph_attr=graph_attr):
    with Cluster("Conference 1"):
        users_1 = [Custom("user", globe_img) for _ in range(3)]
    with Cluster("Conference 2"):
        users_2 = [Custom("user", globe_img) for _ in range(2)]

    all_users = Custom("all users", globe_img)

    with Cluster("Namespace 'jitsi'"):
        ingress = Ingress("jitsi.messenger.schule")

        all_users >> ingress

        web_pod = Pod("web")
        prosody_pod = Pod("prosody")
        jicofo_pod = Pod("jicofo")
        Deployment("prosody") >> prosody_pod
        Deployment("jicofo") >> jicofo_pod
        Deployment("web") >> web_pod
        ingress >> Service("web") >> web_pod
        prosody_service = Service("prosody")
        prosody_service - web_pod
        prosody_service - prosody_pod
        prosody_service - jicofo_pod

        n_jvbs = 3
        with Cluster("Jitsi Videobridge"):
            jvb_pods = [Pod(f"jvb-{i}") for i in range(n_jvbs)]
            jvb_services = [Service(f"jvb-{i}") for i in range(n_jvbs)]
        [jvb_services[i] >> jvb_pods[i] >> prosody_service for i in range(n_jvbs)]
        jvb_pods << StatefulSet("jvb") << HPA("hpa")

        users_1 >> jvb_services[0]
        users_2 >> jvb_services[1]

