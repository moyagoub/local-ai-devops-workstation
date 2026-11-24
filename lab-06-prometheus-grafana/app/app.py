import time
from flask import Flask, Response, jsonify

app = Flask(__name__)
REQUEST_COUNT = 0
START_TIME = time.time()

@app.route("/health")
def health():
    global REQUEST_COUNT
    REQUEST_COUNT += 1
    return jsonify(status="ok", service="observability-api")

@app.route("/metrics")
def metrics():
    global REQUEST_COUNT
    REQUEST_COUNT += 1
    uptime = round(time.time() - START_TIME, 2)
    body = (
        "# HELP lab06_http_requests_total Total HTTP requests handled\n"
        "# TYPE lab06_http_requests_total counter\n"
        f"lab06_http_requests_total {REQUEST_COUNT}\n"
        "# HELP lab06_uptime_seconds Application uptime in seconds\n"
        "# TYPE lab06_uptime_seconds gauge\n"
        f"lab06_uptime_seconds {uptime}\n"
    )
    return Response(body, mimetype="text/plain")

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=8080)
