
## Introduction

This is the configuration repo of the data-plane of my private network.

## Memos

Ping many:

```sh
container=frr
netns=$(docker inspect $container --format {{.NetworkSettings.SandboxKey}})
nsenter --net=$netns ./pingmany.sh | grep 'bytes from'
```

Setup VxLAN:

```sh
container=frr
netns=$(docker inspect $container --format {{.NetworkSettings.SandboxKey}})
sudo nsenter --net=$netns ./setup_vxlan.sh
```

See BGP sessions summary:

```sh
docker exec -it routereflector vtysh -c 'show bgp summary'
```

Ping 'all nodes':

```sh
container=frr
netns=$(docker inspect $container --format {{.NetworkSettings.SandboxKey}})
sudo nsenter --net=$netns ping 'ff02::1%br42'
```

Ping all nodes in `vrf2`:

```sh
vrfname=vtest2
for x in {101..105}; do
  sudo ip vrf exec $vrfname ping -n -c1 10.0.2.$x | grep 'bytes from'
done
```

## First time setup

```sh
./start_frr.sh
sudo ./setup_wg.sh
nskey=$(docker inspect frr --format {{.NetworkSettings.SandboxKey}})
sudo nsenter --net=$nskey ./setup_vxlan.sh
./setup_bridges.sh # do this only after bird is up
```

## Dump all images to another host

```sh
docker image ls --format {{.Repository}}:{{.Tag}} | while read img; do
  echo img: $img
  docker image save $imgid | ssh <target_node> docker image load
done
```

