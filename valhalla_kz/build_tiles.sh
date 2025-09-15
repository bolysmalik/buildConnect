#!/bin/bash

set -e

PBF_FILE="kazakhstan.osm.pbf"
CONF="conf.json"

# Удалим старые тайлы, если есть
rm -rf valhalla_tiles valhalla_tiles.tar

# Скачай PBF вручную и положи в ту же папку, либо:
# wget https://download.geofabrik.de/asia/kazakhstan-latest.osm.pbf -O $PBF_FILE

# Построим тайлы
valhalla_build_tiles -c $CONF $PBF_FILE

# Соберем .tar
valhalla_tar_tiles -c $CONF
