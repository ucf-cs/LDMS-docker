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

Subsequent commands are run from within the Docker container shell.

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
From outside the container in your host's terminal, you can copy out the CSV data with the following command:

```bash
docker cp {CONTAINER_ID}:/simple_agg/csv/ "{host system output path}"
```

## Notes

### CSV Format

The header and results are stored in separate files. The can be combined with the `cat` command.
For example:
```bash
[root@7e3d4a218b02 /]# cd /simple_agg/csv
[root@7e3d4a218b02 csv]# ls
meminfo.1718393324  meminfo.HEADER.1718393324  procstat.1718393324  procstat.HEADER.1718393324
[root@7e3d4a218b02 csv]# cat meminfo.HEADER.1718393324 meminfo.1718393324 > meminfo.csv
[root@7e3d4a218b02 csv]# cat procstat.HEADER.1718393324 procstat.1718393324 > procstat.csv
```

### Adding and Building Applications

To experiment with LDMS, put some applications into the repo before building (or rebuilding), so they will copy into the container.
Then you can run them in the container to see how CPU and RAM usage changes.

`memeater.c` is in `/test_applications` as an example application. It can be built using
`gcc memeater.c -o memeater` and run using `./memeater`.
LDMS should sample and log any changes to CPU and RAM usage caused by this application.

### Sampler Frequency

To change the sampling frequency, change `SAMPLE_INTERVAL` in the container, then restart the sampler and aggregator.
```bash
# Set the sample interval to 1000000 microseconds (1 second)
export SAMPLE_INTERVAL=1000000
```

## Example of a Complete Run

```console
~$ git clone --depth=1 https://github.com/ucf-cs/LDMS-docker.git
~$ cd LDMS-docker
~/LDMS-docker$ docker build -t ldms -f dockerfile .
~/LDMS-docker$ docker run -it ldms
LDMS setup complete, index: 0
```
Set the sample interval to 1 second.
```console
[root@5f79b38ae87b /]# export SAMPLE_INTERVAL=1000000
[root@5f79b38ae87b /]# bash ldms_configs/start-simple-sampler.sh
[root@5f79b38ae87b /]# bash ldms_configs/start-simple-agg.sh
[root@5f79b38ae87b /]# ldms_ls -p 10001
5f79b38ae87b/procstat
5f79b38ae87b/meminfo
[root@5f79b38ae87b /]# ldms_ls -p 10002
5f79b38ae87b/procstat
5f79b38ae87b/meminfo
```
Run an application to analyze.
```console
[root@5f79b38ae87b /]# cd /test_applications
[root@5f79b38ae87b test_applications]# gcc memeater.c -o memeater
[root@5f79b38ae87b test_applications]# ./memeater
^C
[root@5f79b38ae87b test_applications]# pkill -f ldmsd
[root@5f79b38ae87b test_applications]# cd /simple_agg/csv
[root@5f79b38ae87b csv]# ls
meminfo.1718393892  meminfo.HEADER.1718393892  procstat.1718393892  procstat.HEADER.1718393892
[root@5f79b38ae87b csv]# cat meminfo.HEADER.1718393892 meminfo.1718393892 > meminfo.csv
[root@5f79b38ae87b csv]# cat procstat.HEADER.1718393892 procstat.1718393892 > procstat.csv
[root@5f79b38ae87b csv]# exit
```
Now copy the csv data to your physical machine and analyze the results with a tool such as Excel or matplotlib.
```console
~$ mkdir -p ./csv_output/
~$ docker cp 5f79b38ae87b:/simple_agg/csv/*.csv ./csv_output/
```