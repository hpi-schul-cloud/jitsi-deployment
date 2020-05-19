#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from diagrams import Diagram, Cluster, Edge
from diagrams.custom import Custom
from diagrams.k8s.compute import Pod

globe_img = "resources/globe.png"

graph_attr = {
    "pad": "0.5"
}

with Diagram(filename="shard", direction='TB', show=False, outformat='png', graph_attr=graph_attr):
    user_1 = [Custom("user", globe_img) for _ in range(1)]

    with Cluster("Shard"):
        web, jicofo, prosody = [Pod("web"), Pod("jicofo"), Pod("prosody")]

        user_1 >> web

        web >> prosody
        jicofo >> Edge() << prosody

        n_jvbs = 3
        with Cluster("Jitsi Videobridge"):
            jvb_pods = [Pod(f"jvb-{i}") for i in range(n_jvbs)]
        [jvb_pods[i] >> Edge() << prosody for i in range(n_jvbs)]

        user_1 >> jvb_pods[0]
