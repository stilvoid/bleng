#!/bin/bash

SITES="offend.me.uk engledow.me"

now=$(date +%s)

for site in $SITES; do
    s3cmd sync -P --delete-removed --no-mime-magic --cf-invalidate dist/$site/ s3://$site/
done
