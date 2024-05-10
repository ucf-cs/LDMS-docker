# LDMS-docker

## Build:

```bash
docker build -t ldms -f dockerfile .
```

## Run:

```bash
docker run -it ldms
```

Results are stored in `/simple_agg` in the container.

To experiment with LDMS, put some applications into the repo, so they will copy into the container. Then you can run them in the container to see how CPU and RAM usage changes.