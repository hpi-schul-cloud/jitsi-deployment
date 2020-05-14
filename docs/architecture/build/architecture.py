#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from diagrams import Diagram, Cluster
from diagrams.custom import Custom
from diagrams.k8s.clusterconfig import HPA
from diagrams.k8s.compute import Deployment, Pod, ReplicaSet, StatefulSet
from diagrams.k8s.group import Namespace
from diagrams.k8s.network import Ingress, Service

globe_img = "resources/globe.png"

with Diagram(filename="jitsi_meet", direction='LR', show=False, outformat='svg'):
    with Cluster("Conference 1"):
        users_1 = [Custom("user", globe_img) for _ in range(3)]
    with Cluster("Conference 2"):
        users_2 = [Custom("user", globe_img) for _ in range(2)]

    all_users = Custom("all users", globe_img)

    with Cluster("Namespace 'jitsi'"):
        Namespace("jitsi")
        ingress = Ingress("jitsi.messenger.schule")

        all_users >> ingress

        jitsi_pods = [Pod("jitsi")]
        ingress >> Service("web") >> jitsi_pods << ReplicaSet("jitsi") << Deployment("jitsi")
        prosody_service = Service("prosody")
        prosody_service >> jitsi_pods

        n_jvbs = 3
        with Cluster("Jitsi Videobridge"):
            jvb_pods = [Pod(f"jvb-{i}") for i in range(n_jvbs)]
            jvb_services = [Service(f"jvb-{i}") for i in range(n_jvbs)]
        [jvb_services[i] >> jvb_pods[i] >> prosody_service for i in range(n_jvbs)]
        jvb_pods << StatefulSet("jvb") << HPA("hpa")

        users_1 >> jvb_services[0]
        users_2 >> jvb_services[1]

