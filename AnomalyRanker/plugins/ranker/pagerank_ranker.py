# -*- coding: utf-8 -*-
"""The module that contains anomaly ranker that ranks the anomalies by
pagerank metric.
"""
from plugins.ranker.general_ranker import GeneralRanker
import numpy as np
import networkx as nx


class PageRankRanker(GeneralRanker):
    """This class ranks the anomalies by pagerank metric.
    """
    @classmethod
    def rank(cls, anomalies_seq, re_vector, graph=None):

        """Implementation of rank. See class doc for more information.

        Args:
            anomalies_seq(list): A list of sets, each set contains the
                anomalies' indices at a timestamp.

        Returns:
            A list whose elements are the anomaly list. Each anomaly list
            contains the tuples of KPI index and rankings. Example: [[${KPI
            index 1}, ${KPI ranking 1}, ${KPI index 2}, ${KPI ranking 2}, ...],
            ...]
        """

        if len(anomalies_seq) is 0:
            return [], []

        # anomaly_list = sorted(list(anomalies_seq))
        anomaly_list = list(anomalies_seq)
        print("anomaly_list: ",anomaly_list)
        print("re_vector:", re_vector)

        if not graph:
            sub_matrix = cls.sub_matrix(anomaly_list)  # extract the propagation graph from the saved GC graph
            graph = nx.DiGraph(sub_matrix)
            
        print(" --------- GRAPH VIsualization ---------")
        for node_idx in nx.nodes(graph):
            print(graph.nodes[node_idx])

        print("\nPageRank. Propagation Graph Matrix:\n")
        for row in sub_matrix:
            print(row)
            
        print("\nPageRank. Propagation Graph Edges:", list(graph.edges))

        # pr = nx.pagerank(graph, max_iter=10000, alpha=0.85, personalization=re_vector)
        pr = nx.pagerank(graph, max_iter=10000, personalization=re_vector)
        # pr = nx.pagerank(graph, max_iter=10000)

        val_list = list(pr.values())
        val_list = [np.absolute(v) for v in val_list]
        id_val_list = list(zip(anomaly_list, val_list))

        sorted_list = sorted(id_val_list, key=lambda x: np.absolute(x[1]), reverse=True)

        rankings = []
        values = []

        for (idx, value) in sorted_list:
            # if value == 0:
            #    break
            rankings.append(idx)
            values.append(value)

        return rankings, values
