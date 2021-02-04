from typing import cast

import pykube
import pytest
from pytest_helm_charts.clusters import Cluster


# when grafana pod is up, it might be still starting and returning 503
@pytest.mark.flaky(reruns=10, reruns_delay=10)
@pytest.mark.functional
def test_grafana_login_page_available(kube_cluster: Cluster) -> None:
    srv = cast(pykube.Service, pykube.Service.objects(kube_cluster.kube_client).get_or_none(name="grafana"))
    if srv is None:
        raise ValueError("'grafana service not found in the 'default' namespace")
    login_page_res = srv.proxy_http_get("/login")
    assert login_page_res.ok
