import logging
from typing import List

import pykube
import pytest
from pytest_helm_charts.clusters import Cluster
from pytest_helm_charts.k8s.deployment import wait_for_deployments_to_run

logger = logging.getLogger(__name__)

namespace_name = "monitoring"
deployment_name = "grafana"

timeout: int = 560

@pytest.mark.smoke
def test_api_working(kube_cluster: Cluster) -> None:
    """
    Testing apiserver availability.
    """
    assert kube_cluster.kube_client is not None
    assert len(pykube.Node.objects(kube_cluster.kube_client)) >= 1


# scope "module" means this is run only once, for the first test case requesting! It might be tricky
# if you want to assert this multiple times
@pytest.fixture(scope="module")
def deployment(kube_cluster: Cluster) -> List[pykube.Deployment]:
    logger.info("Waiting for deployment of %s in namespace %s to be running.", deployment_name, namespace_name)

    deployments = wait_for_deployments_to_run(
        kube_cluster.kube_client,
        [deployment_name],
        namespace_name,
        timeout,
    )

    logger.info("%s deployment is running in namespace %s.", deployment_name, namespace_name)

    return deployments


@pytest.fixture(scope="module")
def pods(kube_cluster: Cluster) -> List[pykube.Pod]:
    pods = pykube.Pod.objects(kube_cluster.kube_client)

    pods = pods.filter(
        namespace=namespace_name,
        selector={
            "app.kubernetes.io/name": "grafana",
            "app.kubernetes.io/instance": "grafana",
        },
    )

    return pods


# when we start the tests on circleci, we have to wait for pods to be available, hence
# this additional delay and retries
@pytest.mark.smoke
@pytest.mark.upgrade
@pytest.mark.flaky(reruns=5, reruns_delay=10)
def test_pods_available(deployment: List[pykube.Deployment]):
    logger.info(deployment)
    for d in deployment:
        logger.info(d)
        assert int(d.obj["status"]["readyReplicas"]) == int(d.obj["status"]["replicas"])
