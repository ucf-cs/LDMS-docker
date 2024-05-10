FROM rockylinux:8

ARG SLURM_TAG=slurm-22-05-8-1
ARG GOSU_VERSION=1.11

RUN set -x && echo "--- Installing Dev tools"

RUN set -ex && yum makecache
RUN set -ex && yum -y update
RUN set -ex && yum -y install dnf-plugins-core
RUN set -ex && yum config-manager --set-enabled powertools
RUN set -ex && yum -y install wget bzip2 perl gcc gcc-c++ git gnupg make munge munge-devel python3-devel python3-pip python3 mariadb-server mariadb-devel psmisc bash-completion vim-enhanced http-parser-devel json-c-devel autoconf automake libevent libevent-devel autogen doxygen gettext openssl-devel readline-devel readline glib2-devel swig libcurl-devel munge-libs perl-ExtUtils-MakeMaker pam-devel rpm-build perl-DBI perl-Switch libtool bison-devel bison flex jansson-devel libuuid-devel swig rpcgen
RUN set -ex && yum clean all
RUN set -ex && rm -rf /var/cache/yum

RUN alternatives --set python /usr/bin/python3

RUN pip3 install "Cython<3" nose numpy pandas


RUN set -ex \
    && wget -O /usr/local/bin/gosu "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64" \
    && wget -O /usr/local/bin/gosu.asc "https://github.com/tianon/gosu/releases/download/$GOSU_VERSION/gosu-amd64.asc" \
    && export GNUPGHOME="$(mktemp -d)" \
    && gpg --batch --keyserver hkps://keys.openpgp.org --recv-keys B42F6819007F00F88E364FD4036A9C25BF357DD4 \
    && gpg --batch --verify /usr/local/bin/gosu.asc /usr/local/bin/gosu \
    && rm -rf "${GNUPGHOME}" /usr/local/bin/gosu.asc \
    && chmod +x /usr/local/bin/gosu \
    && gosu nobody true


RUN set -x && echo "--- Installing SLURM"

# COPY slurm/ ./slurm/

WORKDIR /
RUN mkdir -p slurm
RUN set -x && git clone -b ${SLURM_TAG} --single-branch --depth=1 https://github.com/SchedMD/slurm.git /slurm
WORKDIR /slurm
# RUN set -x && autoreconf
RUN set -x && ./configure --enable-debug --prefix=/usr --sysconfdir=/etc/slurm \
        --with-mysql_config=/usr/bin  --libdir=/usr/lib64
RUN set -x && make install -j$(nproc)
RUN set -x && install -D -m644 etc/cgroup.conf.example /etc/slurm/cgroup.conf.example
RUN set -x && install -D -m644 etc/slurm.conf.example /etc/slurm/slurm.conf.example
RUN set -x && install -D -m644 etc/slurmdbd.conf.example /etc/slurm/slurmdbd.conf.example
RUN set -x && install -D -m644 contribs/slurm_completion_help/slurm_completion.sh /etc/profile.d/slurm_completion.sh
WORKDIR /
RUN set -x && rm -rf slurm
RUN set -x && groupadd -r --gid=990 slurm
RUN set -x && useradd -r -g slurm --uid=990 slurm
RUN set -x && mkdir /etc/sysconfig/slurm \
                                   /var/spool/slurmd \
                                   /var/run/slurmd \
                                   /var/run/slurmdbd \
                                   /var/lib/slurmd \
                                   /var/log/slurm \
                                   /data
RUN set -x && touch /var/lib/slurmd/node_state \
                    /var/lib/slurmd/front_end_state \
                    /var/lib/slurmd/job_state \
                    /var/lib/slurmd/resv_state \
                    /var/lib/slurmd/trigger_state \
                    /var/lib/slurmd/assoc_mgr_state \
                    /var/lib/slurmd/assoc_usage \
                    /var/lib/slurmd/qos_usage \
                    /var/lib/slurmd/fed_mgr_state
RUN set -x && chown -R slurm:slurm /var/*/slurm*
RUN set -x && /sbin/create-munge-key

# COPY slurm.conf /etc/slurm/slurm.conf
# COPY slurmdbd.conf /etc/slurm/slurmdbd.conf
# RUN set -x \
#     && chown slurm:slurm /etc/slurm/slurmdbd.conf \
#     && chmod 600 /etc/slurm/slurmdbd.conf


# COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
# ENTRYPOINT ["/usr/local/bin/docker-entrypoint.sh"]

# CMD ["slurmdbd"]

RUN echo "--- Installing SOS"

WORKDIR /
RUN git clone -b SOS-6 --single-branch --depth=1 https://github.com/ovis-hpc/sos
WORKDIR /sos
RUN ./autogen.sh
RUN mkdir build
WORKDIR /sos/build
RUN ../configure --prefix=/usr/local/ovis
RUN make #-j$(nproc)
RUN make install -j$(nproc)

RUN set -x && echo "--- Installing LDMS"

WORKDIR /
RUN git clone --single-branch --branch OVIS-4 https://github.com/ovis-hpc/ovis
WORKDIR /ovis
RUN git checkout 70ea2017de535bdb42bce3174c442280183efd08
RUN ./autogen.sh
RUN mkdir build
WORKDIR /ovis/build
RUN ../configure --prefix=/usr/local/ovis --enable-sos --with-sos=/usr/local/ovis --enable-swig 
RUN make -j$(nproc)
RUN make install -j$(nproc)

RUN set -x && echo "--- Installing NumSOS"

WORKDIR /
RUN git clone https://github.com/nick-enoent/numsos
WORKDIR /numsos
RUN git checkout 1467f96979f77776a50f377cb20dc928b7b5a1ea
RUN ./autogen.sh
RUN mkdir build
WORKDIR /numsos/build
RUN PYTHON=/usr/bin/python3 ../configure --prefix=/usr/local/ovis --with-sos=/usr/local/ovis
RUN make -j$(nproc)
RUN make install -j$(nproc)

WORKDIR /
COPY . .

ENTRYPOINT /entrypoint.sh
