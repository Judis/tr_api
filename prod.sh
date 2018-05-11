#!/bin/sh
docker build -t tr_client_production -f Dockerfile.prod .
docker tag tr_api_production judis/app.l11n.api
docker push judis/app.l11n.api