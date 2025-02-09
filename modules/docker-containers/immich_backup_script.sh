#!/bin/sh

# Paths
UPLOAD_LOCATION="/mnt/immich/Library"
DATABASE_LOCATION="/home/mateusp/ImmichDB"

docker exec -t immich_postgres pg_dumpall --clean --if-exists --username=postgres > "$DATABASE_LOCATION"/database-backup/immich-database.sql

### Append to remote Borg repository
borg create "/mnt/immich_backup/immich-borg::{now}" "$DATABASE_LOCATION/database-backup/immich-database.sql"
borg create "/mnt/immich_backup/immich-borg::{now}" "$UPLOAD_LOCATION" --exclude "$UPLOAD_LOCATION"/thumbs/ --exclude "$UPLOAD_LOCATION"/encoded-video/
borg prune --keep-weekly=4 --keep-monthly=3 "/mnt/immich_backup"/immich-borg
borg compact "/mnt/immich_backup"/immich-borg
