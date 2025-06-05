# Place the Cluster Under GitOps Management

Now that [the AKS cluster](./05-aks-cluster.md) has been deployed, the next step to configure a GitOps management solution on our cluster, Flux in this case.

## Steps

GitOps allows a team to author Kubernetes manifest files, persist them in their git repo, and have the Kubernetes manifest files automatically applied to a cluster as changes are made in the source repository. In this reference implementation, Flux is used to managing cluster-level configurations. This is distinct from workload-level concerns, which would be possible as well to manage via Flux, and would typically be done by additional Flux operators in the cluster. The namespace `cluster-baseline-settings` will be used to provide a logical division of the cluster configuration from workload configuration. Example configureation that would be managed with Flux are:

* Cluster Role Bindings for the AKS-managed Microsoft Entra integration
* KeyVault Flex Volume
* The workload's namespace and its resource quotas
* Zero trust Kubernetes Network Policies within the backend namespace
* Kubernetes RBAC permissions for Azure Application Insights
* Resource Quotas for the workload namespaces

Flux was intalled as [AKS Flux extension](https://learn.microsoft.com/azure/azure-arc/kubernetes/tutorial-use-gitops-flux2) during the cluster deploy.

1. Install `kubectl` 1.24 or newer. (`kubectl` supports +/-1 Kubernetes version.)

   ```bash
   sudo az aks install-cli
   kubectl version --client
   ```

1. Get the cluster name.

   ```bash
   export AKS_CLUSTER_NAME=$(az deployment group show --resource-group rg-shipping-dronedelivery-${LOCATION} -n cluster-stamp --query properties.outputs.aksClusterName.value -o tsv)
   ```

1. Get AKS `kubectl` credentials (as a user that has admin permissions to the cluster).

   > In the [Microsoft Entra Integration](03-auth.md) step, we placed our cluster under Microsoft Entra group-backed RBAC. This is the first time we see this used. `az aks get-credentials` allows you to use `kubectl` commands against your cluster. Without the Microsoft Entra integration, you'd have to use `--admin` here, which isn't what we want to happen. Here, you'll log in with a user added to the Microsoft Entra security group used to back the Kubernetes RBAC admin role. Executing the first `kubectl` command below invokes the Microsoft Entra login process to auth the _user of your choice_, which will then be checked against Kubernetes RBAC to act. The user you choose to log in with _must be a member of the Microsoft Entra group bound_ to the `cluster-admin` ClusterRole. For simplicity could either use the "break-glass" admin user created in [Microsoft Entra Integration](03-auth.md) (`dronedelivery-admin`) or any user you assign to the `cluster-admin` group assignment in your [`user-facing-cluster-role-entra-group.yaml`](/cluster-manifests/user-facing-cluster-role-entra-group.yaml) file. If you skipped those steps, use `--admin` to proceed, but proper Microsoft Entra group-based RBAC access is a critical security function that you should invest time in setting up.

   ```bash
   az aks get-credentials -g rg-shipping-dronedelivery-${LOCATION} -n $AKS_CLUSTER_NAME
   ```

   :warning: At this point, two important steps are happening:

      * The `az aks get-credentials` command will fetch a `kubeconfig` context file containing references to your AKS cluster.
      * To _actually_ use the cluster, you will need to authenticate. For that, run any `kubectl` commands, which at this stage will prompt you to authenticate against Microsoft Entra ID. For example, run the following command:

   ```bash
   kubectl get nodes
   ```

   Once the authentication happens successfully, some new items will be added to your `kubeconfig` file, such as an `access-token` with an expiration period. For more information on how this process works in Kubernetes, see <https://kubernetes.io/docs/reference/access-authn-authz/authentication/#openid-connect-tokens>)


Generally speaking, this will be the last time you should need to use `kubectl` for day-to-day operations on this cluster (outside of break-fix situations). Between ARM for Azure Resource definitions and the application of manifests via Flux, all configuration activities can be performed without the need to use `kubectl`. You will, however, see us use it for the upcoming workload deployment. This is because the SDLC component of workloads are not in scope for this reference implementation, as this is focused the infrastructure and baseline configuration.

### Next step

:arrow_forward: [Prepare for the workload by installing its prerequisites](./07-workload-prerequisites.md)
