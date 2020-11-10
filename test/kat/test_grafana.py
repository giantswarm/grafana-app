from typing import cast

import pykube
from pytest_helm_charts.clusters import Cluster


def test_grafana_login_page_available(kube_cluster: Cluster) -> None:
    srv = cast(pykube.Service, pykube.Service.objects(kube_cluster.kube_client).get_or_none(name="grafana-app"))
    if srv is None:
        raise ValueError("'grafana-app service not found in the 'default' namespace")
    login_page_res = srv.proxy_http_get("/login")
    assert login_page_res.ok
