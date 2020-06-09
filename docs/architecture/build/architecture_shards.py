#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from diagrams import Diagram, Cluster, Edge
from diagrams.custom import Custom
from diagrams.k8s.compute import Pod
from diagrams.k8s.network import Ingress

globe_img = "resources/globe.png"
jitsi_img = "resources/jitsi-logo-square.png"

graph_attr = {
    "pad": "0.5"
}

with Diagram(filename="jitsi_sharding", direction='TB', show=False, outformat='png', graph_attr=graph_attr):

    with Cluster("Conference 1"):
        users_1 = [Custom("user", globe_img) for _ in range(3)]

    with Cluster("Conference 2"):
        users_2 = [Custom("user", globe_img) for _ in range(2)]

    with Cluster("Kubernetes Cluster"):
        ingress = Ingress("jitsi.messenger.schule")
        with Cluster("HAProxy"):
            n_haproxy = 2
            haproxy_pods = [Pod(f"haproxy-{i}") for i in range(n_haproxy)]

        edge_conference_1 = Edge(color="red")
        edge_conference_2 = Edge(color="green")
        shard_0 = Custom("shard-0", jitsi_img)
        shard_1 = Custom("shard-1", jitsi_img)
        users_1 >> edge_conference_1 >> ingress
        users_2 >> edge_conference_2 >> ingress

        for haproxy in haproxy_pods:
            ingress >> haproxy

        for i in range(len(users_1)):
            haproxy_pods[i % len(haproxy_pods)] >> edge_conference_1 >> shard_0

        for i in range(len(users_2)):
            haproxy_pods[i % len(haproxy_pods)] >> edge_conference_2 >> shard_1
