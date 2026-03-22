#!/usr/bin/env bash

BASE="http://localhost:8080"
INSIGHT="$BASE/actuator/ai-insight"

echo "=== AI Observer Demo ==="
echo ""

echo "[1/4] GET /hello (normal traffic)"
for i in {1..5}; do
  curl -s "$BASE/hello"
  echo ""
done

echo ""
echo "[2/4] GET /slow (2s latency x3 — triggers latency metrics)"
for i in {1..3}; do
  echo -n "  call $i: "
  curl -s "$BASE/slow"
  echo ""
done

echo ""
echo "[3/4] GET /error (exceptions x5 — feeds error collector)"
for i in {1..5}; do
  echo -n "  call $i: "
  curl -s "$BASE/error" | python3 -c "import sys,json; d=json.load(sys.stdin); print(d.get('message','?'))" 2>/dev/null || echo "(error response)"
done

echo ""
echo "[4/4] GET /leak (heap pressure x20 — should breach 70% threshold)"
for i in {1..20}; do
  echo -n "  call $i: "
  curl -s "$BASE/leak"
  echo ""
done

echo ""
echo "=== Waiting 10s for AI Observer to process ==="
sleep 10

echo ""
echo "=== AI Insight ==="
curl -s "$INSIGHT" | python3 -m json.tool 2>/dev/null || curl -s "$INSIGHT"
echo ""
