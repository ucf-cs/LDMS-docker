# LDMS-docker

NOTE: The scripts used by the container require Unix-style line endings. If you clone this repo using Windows, the default behavior of Git is to change the line endings to Windows-style. You can either [disable this behavior](https://docs.github.com/en/get-started/getting-started-with-git/configuring-git-to-handle-line-endings), clone and run these commands using [WSL](https://learn.microsoft.com/en-us/windows/wsl/setup/environment), or use a Unix-like machine (Linux or MacOS) to host the docker container.

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
`gcc memeater.c -o memeater` and run using `./memeater`.
LDMS should sample and log any changes to CPU and RAM usage caused by this application.

To change the sampling frequency, change `SAMPLE_INTERVAL` in the container, then restart the sampler and aggregator.
```bash
# Set the sample interval to 1000000 microseconds (1 second)
export SAMPLE_INTERVAL=1000000
```