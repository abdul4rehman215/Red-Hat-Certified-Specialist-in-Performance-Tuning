#!/bin/bash
echo "Starting DNS resolution tests..."
websites=(
 "google.com"
 "github.com"
 "stackoverflow.com"
 "redhat.com"
 "ubuntu.com"
 "kernel.org"
 "python.org"
 "nginx.org"
 "apache.org"
 "cloudflare.com"
)
for site in "${websites[@]}"; do
 echo "Resolving $site..."
 nslookup $site > /dev/null 2>&1
 host $site > /dev/null 2>&1
 dig $site > /dev/null 2>&1
 sleep 1
done
echo "Testing with different DNS servers..."
nslookup google.com 8.8.8.8 > /dev/null 2>&1
nslookup google.com 1.1.1.1 > /dev/null 2>&1
nslookup google.com 208.67.222.222 > /dev/null 2>&1
echo "DNS tests completed"
