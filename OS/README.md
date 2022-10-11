# Example use case structure


**Demo:**

https://user-images.githubusercontent.com/5921035/195056739-3ba67fc3-e47e-4a39-9acb-387197abdc12.mp4


## Use case description

Upkeeping kubernetes nodes can be a bit cumbersome. Why not use UOR to apply machine specific configuration ontop of an ephemeral OS like arch linux? Worker node cattle! 

## Demo resources
podman, VM or Baremetal Machine

## Demo instructions

### Prerequisites

This demo joins a k8s node into an existing cluster. Therefor, an existing cluster is needed. Generate a token using `kubeadm token create --print-join-command` and adjust the appropriate values in the [kubeadm-config](uor/etc/kubeadm/kubeadm.conf.yaml)

This demo utilizes nebula as an example of machine specific configuration. The node can be joined from outside the cluster's network assuming the cluster is also configured to use Nebula. In summary, place nebula configuration inside [nebula](uor/etc/nebula). More information on how to configure nebula can be found [here](https://nebula.defined.net/docs/guides/quick-start/)

### Preconfigured adjustable values are:

- The mac address used to identify the machine. `08:00:27:8a:30:7c` is used in this example. A machine can either be launched with this address, or values can be adjusted inside the [dataset-config](dataset-config.yaml), and the directory following [etc/nebula](etc/nebula).
- The address of the registry used. `go.registry` is used in this example. This can be adjusted inside the [automated_script.sh](airootfs/root/.automated_script.sh)


0. (Optional) Host a registry in memory! `podman run -d --name gocontainerreg -p 1338:1338 --restart unless-stopped ghcr.io/uor-framework/examples/gocontainerregistry`
1. Build the ISO.
`podman run --privileged -v .:/profile ghcr.io/uor-framework/examples/archiso:latest mkarchiso -v -w /tmp -o /profile/out /profile`
2. Build the collection.
`uor build collection uor go.registry:1338/test:latest --dsconfig=dataset-config.yaml `
3. Push the collection to the registry.
`uor push go.registry:1338/test:latest --insecure --plain-http`
4. Launch a VM with the mac address defined in the dataset-config.yaml.
5. Enjoy!

## What's next?

Configure more machine specifics! Maybe some machines in some regions would benefit from using a local mirror first? This can be adjusted in the crio configuration files. Give it a shot! 