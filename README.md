# openshift-kni CI helpers

running e2e tests it's a process which encompasses five main phases:
1. setup the cluster. When this phase ends, the next phases can depend on having a valid KUBECONFIG they can use to do their tasks.
   Please note that the only responsability of this phase is to provide a KUBECONFIG. How to do it is entirely opaque,
   so anything is legal ranging from passing it through (= this phase is NOP) to setting up a brand new cluster.
2. setup the SW environment. When this phase ends, the next phases can depend on having all the SOFTWARE components deployed on the cluster.
   What to deploy is entirely phase-dependent, so this phase can range from being NOP to deploy large sets of operators.
3. run the e2e tests proper. The e2e tests are expected to validate the cluster both from HW and SW resources perspective and
   skip or fail if the preconditions are not met
4. undo any step done in step#2
5. undo any step done in step#1
