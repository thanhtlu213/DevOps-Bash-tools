#!/usr/bin/env bash
#  vim:ts=4:sts=4:sw=4:et
#  args: echo {repo} is found at {dir}
#
#  Author: Hari Sekhon
#  Date: 2016-01-17 12:14:06 +0000 (Sun, 17 Jan 2016)
#
#  https://github.com/harisekhon/bash-tools
#
#  License: see accompanying Hari Sekhon LICENSE file
#
#  If you're using my code you're welcome to connect with me on LinkedIn and optionally send me feedback to help improve or steer this or other code I publish
#
#  https://www.linkedin.com/in/harisekhon
#

set -euo pipefail
[ -n "${DEBUG:-}" ] && set -x
srcdir="$(cd "$(dirname "$0")" && pwd)"

# shellcheck disable=SC1090
. "$srcdir/lib/utils.sh"

# shellcheck disable=SC2034,SC2154
usage_description="
Run a command against each Pingdom check

All arguments become the command template

The command template replaces the following for convenience in each iteration:

{id}   - with the check id   <-- this is the one you want for chaining API queries with pingdom_api.sh
{name} - with the check name

eg.
    ${0##*/} 'echo check id = {id} and name = {name}'

For real usage examples, see:

    pingdom_checks_outages.sh
    pingdom_checks_latency_by_hour.sh
"

# used by usage() in lib/utils.sh
# shellcheck disable=SC2034
usage_args="<cmd>"

help_usage "$@"

min_args 1 "$@"

cmd_template="$*"

while read -r check_id check_name; do
    echo "# ============================================================================ #" >&2
    echo "# $check_id - $check_name" >&2
    echo "# ============================================================================ #" >&2
    cmd="$cmd_template"
    cmd="${cmd//\{check_id\}/$check_id}"
    cmd="${cmd//\{check_name\}/$check_name}"
    cmd="${cmd//\{id\}/$check_id}"
    cmd="${cmd//\{name\}/$check_name}"
    eval "$cmd"
done < <("$srcdir/pingdom_api.sh" /checks | jq -r '.checks[] | [.id, .name] | @tsv')
