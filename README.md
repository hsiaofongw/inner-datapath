

This is the configuration repo of the data-plane of my private network.

Todos:

- Use etcd watch api to propagate pubkey, instead of git.

Ping many:

```sh
for f in data/*; do
  ip=$(cat $f/ipcidr | cut -d '/' -f1)
  ip vrf exec vrf-blue ping -c1 $ip
done
```
