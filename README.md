# LDMS-docker

## Build:

```bash
docker build -t ldms -f dockerfile .
```

## Run:

```bash
docker run -it ldms
```

You can start the sampler and aggregator processes using the following commands:
```bash
bash ldms_configs/start-simple-sampler.sh
bash ldms_configs/start-simple-agg.sh
```

You can verify they are running with:
```bash
ldms_ls -p 10001
ldms_ls -p 10002
```

You can check their logs in `/logs/`.

You can stop them with:
```bash
pkill -f ldmsd
```

Results are stored in `/simple_agg/csv` in the container.

To experiment with LDMS, put some applications into the repo before building (or rebuilding), so they will copy into the container.
Then you can run them in the container to see how CPU and RAM usage changes.

`memeater.c` is in `/test_applications` as an example application. It can be built using
`gcc memeater.c memeater` and run using `./memeater`.
LDMS should sample and log any changes to CPU and RAM usage caused by this application.