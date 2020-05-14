#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from diagrams import Diagram
from diagrams.custom import Custom
from diagrams.k8s.clusterconfig import HPA
from diagrams.k8s.compute import Deployment, Pod, ReplicaSet, StatefulSet
from diagrams.k8s.group import Namespace
from diagrams.k8s.network import Ingress, Service

with Diagram("Jitsi Meet", show=False):
    Namespace("jitsi")

    browser = Custom("browser", "resources/globe.png")
    ingress = Ingress("jitsi.messenger.schule")

    browser >> ingress

    jitsi_pods = [Pod("jitsi")]
    ingress >> Service("web") >> jitsi_pods << ReplicaSet("jitsi") << Deployment("jitsi")
    prosody_service = Service("prosody")
    prosody_service >> jitsi_pods

    n_jvbs = 3
    jvb_pods = [Pod(f"jvb-{i}") for i in range(n_jvbs)]
    jvb_services = [Service(f"jvb-{i}") for i in range(n_jvbs)]
    [jvb_services[i] >> jvb_pods[i] >> prosody_service for i in range(n_jvbs)]
    jvb_pods << StatefulSet("jvb") << HPA("hpa")

    browser >> jvb_services

