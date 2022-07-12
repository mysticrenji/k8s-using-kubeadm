# k8s-using-kudeadm
Terraforming k8s cluster using kubeadm

The complete guide for the setup can be found in medium space -
https://faun.pub/create-a-self-managed-cluster-using-kubeadm-and-terraform-a148f00f440f

    terraform init
    terrform plan -parallelism=0 -out plan.tfplan
    terraform apply -auto-approve

