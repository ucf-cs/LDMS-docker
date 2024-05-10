# LDMS-docker

## Build:

```bash
docker build -t ldms -f dockerfile .
```

## Run:

```bash
docker run -it ldms
```

Results are stored in `/simple_agg/csv` in the container.

To experiment with LDMS, put some applications into the repo before building (or rebuilding), so they will copy into the container.
Then you can run them in the container to see how CPU and RAM usage changes.

`memeater.c` is in `/test_applications` as an example application. It can be built using
`gcc memeater.c memeater` `and run using `./memeater`.
LDMS should sample and log any changes to CPU and RAM usage caused by this application.