# Centralized pipeline constants.
# Sourced by shell scripts and parsed by scripts/koordinates/config.py.
#
# Bump YEAR when Stats NZ publishes a new annual meshblock vintage,
# and update MESHBLOCK_LAYER_ID with the matching layer ID from
# https://datafinder.stats.govt.nz/data/category/geographic/.
export YEAR=2026
export MESHBLOCK_LAYER_ID=123521

# Prepend the current UTC clock time to a log line so per-step deltas are
# visible in workflow logs. Usage: log "-- Importing nz-addresses"
log() {
  printf '%s %s\n' "$(date -u +%H:%M:%S)" "$*"
}
