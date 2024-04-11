# Nerfstudio dockerfile

## Build with Makefile

The Makefile contains the target docker image tag, version and build_args (proxy server).

### Build the image only

``` bash
make build_nerf
```

### Build & push the image to Harbor

``` bash
make push_nerf
```
