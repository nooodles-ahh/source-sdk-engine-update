#!/bin/bash
docker run -v $(pwd)/../..:$(pwd)/../.. -w $(pwd) --rm -it registry.gitlab.steamos.cloud/steamrt/sniper/sdk ./creategameprojects_new && make -f games.mak