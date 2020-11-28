#!/bin/sh

echo Stopping directive processign script
kill -15 `ps | grep directive | grep sh | cut -d' ' -f 2`
