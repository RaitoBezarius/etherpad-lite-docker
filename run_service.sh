#!/bin/bash
docker run --env ETHERPAD_DB_PASSWORD="test" --name Etherpad -p 9001:9001 --link DB:postgres -d etherpad-lite
