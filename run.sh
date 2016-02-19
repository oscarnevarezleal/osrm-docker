#!/bin/bash
DATA_PATH=${DATA_PATH:="/data"}

_sig() {
  kill -TERM $child 2>/dev/null
}

trap _sig SIGKILL SIGTERM SIGHUP SIGINT EXIT

if [ "$PBF_RESOURCE" != "none" ]; then
  echo "Using a PBF Resource.."

  # Use environment PBF_RESOURCE
  curl -o /pbf_resource.osm.pbf $PBF_RESOURCE

  ./osrm-extract /pbf_resource.osm.pbf
  ./osrm-prepare /pbf_resource.osrm
  ./osrm-routed /pbf_resource.osrm --max-table-size 8000 &

  child=$!
  wait "$child"
else
  echo "Using data container.."

  # Use data container.
  if [ ! -f $DATA_PATH/$1.osrm ]; then
    if [ ! -f $DATA_PATH/$1.osm.pbf ]; then
      curl $2 > $DATA_PATH/$1.osm.pbf
    fi
    ./osrm-extract $DATA_PATH/$1.osm.pbf
    ./osrm-prepare $DATA_PATH/$1.osrm
    rm $DATA_PATH/$1.osm.pbf
  fi

  ./osrm-routed $DATA_PATH/$1.osrm --max-table-size 8000 &
  child=$!
  wait "$child"
fi
