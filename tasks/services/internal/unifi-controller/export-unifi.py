#!/usr/bin/env python3
"""Generate and download a settings-only Network backup using the local API."""

import json
import os
from pathlib import Path
import ssl
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import urlsplit
from urllib.request import HTTPSHandler, HTTPRedirectHandler, ProxyHandler, Request, build_opener


class NoRedirects(HTTPRedirectHandler):
    # Do not forward the API key to a redirect destination or a login page.
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def export_backup(destination, api_key):
    if not api_key or any(c in api_key for c in "\r\n"):
        raise ValueError("UNIFI_API_KEY is missing or invalid")
    # The published administration port uses UniFi's self-signed certificate.
    # Disable certificate validation only for this fixed loopback destination.
    base = "https://127.0.0.1:11443"
    opener = build_opener(
        HTTPSHandler(context=ssl._create_unverified_context()), NoRedirects(), ProxyHandler({})
    )
    headers = {"X-API-Key": api_key, "Content-Type": "application/json"}
    request = Request(
        base + "/proxy/network/api/s/default/cmd/backup",
        data=json.dumps({"cmd": "backup", "days": 0}).encode(),
        headers=headers,
        method="POST",
    )
    with opener.open(request, timeout=180) as response:
        result = json.load(response)
    if result.get("meta", {}).get("rc") != "ok":
        raise ValueError("UniFi rejected the backup request")
    data = result.get("data")
    if not isinstance(data, list) or not data or not isinstance(data[0], dict):
        raise ValueError("UniFi did not return a backup download URL")
    path = data[0].get("url")
    if not isinstance(path, str):
        raise ValueError("UniFi did not return a backup download URL")
    parsed = urlsplit(path)
    if parsed.scheme or parsed.netloc or parsed.query or parsed.fragment:
        raise ValueError("Unexpected UniFi backup download URL")
    if path.startswith("/dl/backup/"):
        path = "/proxy/network" + path
    prefix = "/proxy/network/dl/backup/"
    filename = path.removeprefix(prefix)
    if (not path.startswith(prefix) or not filename.endswith(".unf")
            or any(c in filename for c in "/\\%") or ".." in filename):
        raise ValueError("Unexpected UniFi backup download path")
    with opener.open(Request(base + path, headers={"X-API-Key": api_key}),
                     timeout=180) as response:
        content_type = response.headers.get("Content-Type", "").lower()
        if any(t in content_type for t in ("html", "json", "text/")):
            raise ValueError("UniFi returned an error document instead of a backup")
        with Path(destination).open("wb") as output:
            first = response.read(65536)
            if not first or first.lstrip().lower().startswith((b"<!doctype html", b"<html")):
                raise ValueError("UniFi returned an empty backup or an error document")
            try:
                document = json.loads(first)
            except (ValueError, UnicodeDecodeError):
                document = None
            if isinstance(document, (dict, list)):
                raise ValueError("UniFi returned JSON instead of a backup")
            output.write(first)
            size = len(first)
            while chunk := response.read(65536):
                output.write(chunk)
                size += len(chunk)
            expected = response.headers.get("Content-Length")
            if expected is not None and size != int(expected):
                raise ValueError("UniFi backup download was incomplete")
    # Transport checks cannot establish restorability. Test an actual restore.


if __name__ == "__main__":
    try:
        export_backup(sys.argv[1], os.environ.get("UNIFI_API_KEY", ""))
    except HTTPError as error:
        sys.exit(f"UniFi backup failed: HTTP {error.code}")
    except (OSError, ValueError, URLError, IndexError, TypeError, AttributeError) as error:
        # Do not print API response bodies or credentials.
        sys.exit(f"UniFi backup failed ({type(error).__name__}); no upload performed")
