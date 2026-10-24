#!/usr/bin/env bash
set -euo pipefail

API_URL="${API_URL:-http://localhost:5101}"
CLIENT_ORIGIN="${CLIENT_ORIGIN:-http://localhost:5100}"

curl --fail --silent --show-error "$API_URL/health" | python3 -c 'import json, sys; payload = json.load(sys.stdin); assert payload.get("status") == "ok"; print("PASS: health")'

status_code=$(curl --silent --show-error --output /tmp/inventoryhub-products.json --write-out '%{http_code}' "$API_URL/api/productlist")
if [[ "$status_code" != "200" ]]; then
  echo "Expected HTTP 200 from $API_URL/api/productlist but got $status_code" >&2
  exit 1
fi

python3 - <<'PY'
import json
from pathlib import Path

payload = json.loads(Path('/tmp/inventoryhub-products.json').read_text())
assert isinstance(payload, list), 'API response should be a JSON array'
assert len(payload) == 2, 'Expected two product records'
assert payload[0]['name'] == 'Laptop'
assert payload[0]['category']['name'] == 'Electronics'
assert all(set(['id', 'name', 'price', 'stock', 'category']) <= set(item) for item in payload)
assert all(isinstance(item['price'], (int, float)) for item in payload)
assert all(isinstance(item['stock'], int) for item in payload)
print('PASS: API product JSON')
PY

curl --fail --silent --show-error -D - -o /dev/null -H "Origin: $CLIENT_ORIGIN" "$API_URL/api/productlist" \
  | tr -d '\r' \
  | grep -qi '^access-control-allow-origin: http://localhost:5100$'

not_found_status=$(curl --silent --show-error --output /tmp/inventoryhub-404.txt --write-out '%{http_code}' "$API_URL/does-not-exist" || true)
if [[ "$not_found_status" != "404" ]]; then
  echo "Expected HTTP 404 for an invalid route, got $not_found_status" >&2
  exit 1
fi

cached_one=$(curl --fail --silent --show-error "$API_URL/api/productlist")
cached_two=$(curl --fail --silent --show-error "$API_URL/api/productlist")
if [[ "$cached_one" != "$cached_two" ]]; then
  echo 'Product endpoint returned different payloads across repeated calls.' >&2
  exit 1
fi

echo 'PASS: health, product JSON, CORS, invalid route handling, and cache consistency'
