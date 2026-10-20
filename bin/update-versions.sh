#!/usr/bin/env bash
set -euo pipefail

JSON_FILE="wordpress-versions.json"

echo "Fetching released WordPress versions from wordpress.org..."
STABLE_JSON=$(curl -sf "https://api.wordpress.org/core/stable-check/1.0/")

# Lowest major.minor we track, derived from the existing file.
MIN_BRANCH=$(jq -r '[.[] | objects | select(.version != null) | .version | capture("^(?<mm>[0-9]+\\.[0-9]+)") | .mm] | min' "$JSON_FILE")

echo "$STABLE_JSON" | jq -r 'keys[]' | while read -r version; do
  # Only consider plain x.y or x.y.z releases (skip oddities like 1.5.1.1).
  if [[ ! "$version" =~ ^[0-9]+\.[0-9]+(\.[0-9]+)?$ ]]; then
    continue
  fi

  branch=$(echo "$version" | grep -oE '^[0-9]+\.[0-9]+')
  if [ "$(printf '%s\n%s\n' "$MIN_BRANCH" "$branch" | sort -V | head -n1)" != "$MIN_BRANCH" ]; then
    continue
  fi

  if jq -e --arg v "$version" 'any(.[] | objects; .version == $v)' "$JSON_FILE" > /dev/null; then
    continue
  fi

  key="wordpress_$(echo "$version" | tr '.' '_')"
  if [[ "$version" =~ ^[0-9]+\.[0-9]+$ ]]; then
    key="${key}_0"
  fi

  echo "Adding $key (version $version)"
  jq --arg key "$key" --arg version "$version" \
    '.[$key] = {"version": $version, "hash": ""}' "$JSON_FILE" > "${JSON_FILE}.new"
  mv "${JSON_FILE}.new" "$JSON_FILE"
done

echo "Fetching the current WordPress beta or RC from wordpress.org..."
# The beta channel offers the newest beta or RC as the "development" response.
PRERELEASE=$(curl -sf "https://api.wordpress.org/core/version-check/1.7/?channel=beta" \
  | jq -r '[.offers[] | select(.response == "development") | .version
      | select(test("^[0-9]+(\\.[0-9]+)+-(beta|RC)[0-9]+$"))] | first // empty')

if [ -n "$PRERELEASE" ] && [ "$(jq -r '.prerelease.version // ""' "$JSON_FILE")" != "$PRERELEASE" ]; then
  echo "Setting prerelease to $PRERELEASE"
  jq --arg version "$PRERELEASE" \
    '.prerelease = {"version": $version, "hash": ""}' "$JSON_FILE" > "${JSON_FILE}.new"
  mv "${JSON_FILE}.new" "$JSON_FILE"
fi

# Sort wordpress_* entries numerically by version, point "latest" at the
# newest one, and keep "latest" and "prerelease" last.
jq '
  (to_entries | map(select(.key | startswith("wordpress_")))
    | sort_by(.value.version | split(".") | map(tonumber? // 0))) as $sorted
  | (to_entries | map(select(.key == "prerelease"))) as $pre
  | ($sorted + [{key: "latest", value: $sorted[-1].key}] + $pre) | from_entries
' "$JSON_FILE" > "${JSON_FILE}.new"
mv "${JSON_FILE}.new" "$JSON_FILE"

jsonfmt -w "$JSON_FILE"

echo "Done. Run bin/update-hashes.sh to fetch hashes for any new entries."
