

This is the configuration repo of the data-plane of my private network.

Todos:

- Use etcd watch api to propagate pubkey, instead of git.

Ping many:

```sh
container=frr
netns=$(docker inspect $container --format {{.NetworkSettings.SandboxKey}})
nsenter --net=$netns ./pingmany.sh | grep 'bytes from'
```
