#!/bin/bash
TOP=/usr/local/ovis

mkdir -p /run/pid && chmod 777 /run/pid

if [ -z "$HOSTINDEX" ] ; then
  
  export LD_LIBRARY_PATH=$TOP/lib/:$TOP/lib64:$LD_LIBRARY_PATH
  export LDMSD_PLUGIN_LIBPATH=$TOP/lib/ovis-ldms/ 
  export ZAP_LIBPATH=$TOP/lib/ovis-ldms/
  export PATH=$TOP/sbin:$TOP/bin:$PATH 
  export PYTHONPATH=$TOP/lib/python3.6/site-packages/:$PYTHONPATH

  export SAMPLE_INTERVAL=1000000

  if [[ $HOSTNAME =~ cl([0-9]) ]] ; then
    export HOSTINDEX=${BASH_REMATCH[1]}
  else 
    export HOSTINDEX=0
  fi

else

  echo "LDMS setup was already performed"

fi

echo "LDMS setup complete, index: ${HOSTINDEX}"
