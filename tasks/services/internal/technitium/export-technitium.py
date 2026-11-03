#!/usr/bin/env python3
"""Download and validate a Technitium settings backup through the local API."""

import os
from pathlib import Path
import sys
from urllib.error import HTTPError, URLError
from urllib.parse import urlencode
from urllib.request import HTTPRedirectHandler, ProxyHandler, Request, build_opener
import zipfile


class NoRedirects(HTTPRedirectHandler):
    # Keep the bearer token on the fixed loopback destination.
    def redirect_request(self, req, fp, code, msg, headers, newurl):
        return None


def export_backup(destination, api_token):
    if not api_token or any(c in api_token for c in "\r\n"):
        raise ValueError("TECHNITIUM_API_TOKEN is missing or invalid")
    options = dict.fromkeys((
        "authConfig", "clusterConfig", "webServiceSettings", "dnsSettings",
        "logSettings", "zones", "allowedZones", "blockedZones", "blockLists",
        "apps", "scopes", "stats", "logs",
    ), "true")
    request = Request(
        "http://127.0.0.1:8081/api/settings/backup?" + urlencode(options),
        headers={"Authorization": "Bearer " + api_token},
    )
    opener = build_opener(NoRedirects(), ProxyHandler({}))
    with opener.open(request, timeout=180) as response:
        # API failures can return HTTP 200 with a JSON error body.
        if response.headers.get_content_type() != "application/zip":
            raise ValueError("Technitium did not return a ZIP backup")
        with Path(destination).open("wb") as output:
            size = 0
            while chunk := response.read(65536):
                output.write(chunk)
                size += len(chunk)
        expected = response.headers.get("Content-Length")
        if expected is not None and size != int(expected):
            raise ValueError("Technitium backup download was incomplete")
    with zipfile.ZipFile(destination) as archive:
        if not archive.namelist() or archive.testzip() is not None:
            raise ValueError("Technitium backup ZIP validation failed")
    # ZIP integrity does not establish restorability. Test an actual restore.


if __name__ == "__main__":
    try:
        export_backup(sys.argv[1], os.environ.get("TECHNITIUM_API_TOKEN", ""))
    except HTTPError as error:
        sys.exit(f"Technitium backup failed: HTTP {error.code}")
    except (OSError, ValueError, URLError, IndexError, zipfile.BadZipFile,
            RuntimeError, NotImplementedError) as error:
        # Do not print API response bodies or credentials.
        sys.exit(f"Technitium backup failed ({type(error).__name__}); no upload performed")
