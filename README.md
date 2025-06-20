# Dig Test

Iterate `dig` with parameter or argument, parameters:

- Server: target
- Domain: target domain
- Timeout: Timeout threshold
- Interval: Checking interval
- Log_file: Script log
- Requests: Number of requests

Example:

```shell
SERVER="8.8.8.8"
DOMAIN="google.com"
TIMEOUT=1
INTERVAL=0.2
LOG_FILE="dig-test-$(date +%Y%m%d-%H%M%S).log"
REQUESTS=${1:-3000}  # or pass with arg
```

Run:

```shell
./dig-test.sh
```

Run with custom iterations:

```shell
./dig-test.sh 5
```

Run in background:

```shell
nohup ./dig-test.sh 10800 > dig-run.log 2>&1 &
```