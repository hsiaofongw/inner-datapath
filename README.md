
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

```
container=frr
netns=$(docker inspect $container --format {{.NetworkSettings.SandboxKey}})
nsenter --net=$netns ./setup_vxlan.sh
```

See BGP sessions summary:

```
docker exec -it routereflector vtysh -c 'show bgp summary'
```

Ping 'all nodes':

```
container=frr
netns=$(docker inspect $container --format {{.NetworkSettings.SandboxKey}})
sudo nsenter --net=$netns ping 'ff02::1%br42'
```
