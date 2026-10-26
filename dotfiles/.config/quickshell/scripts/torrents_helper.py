#!/usr/bin/env python3
"""
qBittorrent helper for the Quickshell torrents card.

Credentials are read from a local config file (never passed as command-line
arguments), specifically to avoid the /proc/<pid>/cmdline exposure that the
real omarchy-torrents plugin's author found and fixed in their own project.

Config file format (~/.config/quickshell/bar2/qbittorrent.conf):
    host=localhost
    port=8080
    username=admin
    password=yourpassword

Usage:
    torrents_helper.py list
    torrents_helper.py pause <hash>
    torrents_helper.py resume <hash>
    torrents_helper.py delete <hash> [--with-files]
    torrents_helper.py add <magnet-or-url>
"""

import sys
import json
import os
import urllib.request
import urllib.parse
import urllib.error

CONFIG_PATH = os.path.expanduser("~/.config/quickshell/bar2/qbittorrent.conf")


def load_config():
    if not os.path.isfile(CONFIG_PATH):
        print(json.dumps({"error": f"config file not found: {CONFIG_PATH}"}))
        sys.exit(1)

    # Reject symlinks - same defensive pattern the real plugin uses for its
    # own config/torrent file handling
    if os.path.islink(CONFIG_PATH):
        print(json.dumps({"error": "config file must not be a symlink"}))
        sys.exit(1)

    config = {"host": "localhost", "port": "8080"}
    with open(CONFIG_PATH, "r") as f:
        for line in f:
            line = line.strip()
            if not line or line.startswith("#") or "=" not in line:
                continue
            key, _, value = line.partition("=")
            config[key.strip()] = value.strip()

    if "username" not in config or "password" not in config:
        print(json.dumps({"error": "config file missing username/password"}))
        sys.exit(1)

    return config


def qbt_request(base_url, path, cookie=None, data=None, timeout=8):
    url = base_url + path
    headers = {}
    if cookie:
        headers["Cookie"] = cookie

    if data is not None:
        headers["Content-Type"] = "application/x-www-form-urlencoded"
        body = urllib.parse.urlencode(data).encode("utf-8")
        req = urllib.request.Request(url, data=body, headers=headers, method="POST")
    else:
        req = urllib.request.Request(url, headers=headers, method="GET")

    with urllib.request.urlopen(req, timeout=timeout) as resp:
        # Size-capped read, matching the real plugin's response-capping
        # hardening - refuse to buffer an unbounded response
        raw = resp.read(10 * 1024 * 1024)
        return resp, raw


def login(config):
    base_url = f"http://{config['host']}:{config['port']}"
    try:
        resp, raw = qbt_request(base_url, "/api/v2/auth/login", data={
            "username": config["username"],
            "password": config["password"],
        })
    except (urllib.error.URLError, TimeoutError) as e:
        print(json.dumps({"error": f"connection failed: {e}"}))
        sys.exit(1)

    set_cookie = resp.headers.get("Set-Cookie", "")
    # Newer qBittorrent versions name this cookie "QBT_SID_<port>" rather
    # than the older plain "SID" - match by substring so both work, and
    # capture the exact name=value pair to echo back unchanged, rather
    # than assuming the cookie is literally named "SID".
    cookie_pair = None
    for part in set_cookie.split(";"):
        part = part.strip()
        if "=" in part and "SID" in part.split("=")[0]:
            cookie_pair = part
            break

    if not cookie_pair:
        print(json.dumps({"error": "login failed - check username/password"}))
        sys.exit(1)

    return base_url, cookie_pair


def format_eta(seconds):
    if seconds is None or seconds >= 8640000:  # qBittorrent's "infinite" sentinel
        return "∞"
    seconds = int(seconds)
    h, rem = divmod(seconds, 3600)
    m, s = divmod(rem, 60)
    if h > 0:
        return f"{h}h{m}m"
    if m > 0:
        return f"{m}m{s}s"
    return f"{s}s"


def format_speed(bytes_per_sec):
    mb = bytes_per_sec / (1024 * 1024)
    if mb >= 1:
        return f"{mb:.2f} MB/s"
    kb = bytes_per_sec / 1024
    return f"{kb:.0f} KB/s"


def cmd_list(config):
    base_url, cookie = login(config)
    resp, raw = qbt_request(base_url, "/api/v2/torrents/info", cookie=cookie)
    torrents = json.loads(raw)

    result = []
    for t in torrents:
        result.append({
            "hash": t.get("hash", ""),
            "name": t.get("name", "Unknown"),
            "progress": round(t.get("progress", 0) * 100, 1),
            "dlspeed": format_speed(t.get("dlspeed", 0)),
            "upspeed": format_speed(t.get("upspeed", 0)),
            "eta": format_eta(t.get("eta")),
            "ratio": round(t.get("ratio", 0), 2),
            "state": t.get("state", "unknown"),
            "size_bytes": t.get("size", 0),
            "downloaded_bytes": t.get("downloaded", 0),
        })

    print(json.dumps({"torrents": result}))


def cmd_action(config, action, torrent_hash, with_files=False):
    base_url, cookie = login(config)

    endpoint_map = {
        "pause": "/api/v2/torrents/pause",
        "resume": "/api/v2/torrents/resume",
        "delete": "/api/v2/torrents/delete",
    }
    if action not in endpoint_map:
        print(json.dumps({"error": f"unknown action: {action}"}))
        sys.exit(1)

    data = {"hashes": torrent_hash}
    if action == "delete":
        data["deleteFiles"] = "true" if with_files else "false"

    qbt_request(base_url, endpoint_map[action], cookie=cookie, data=data)
    print(json.dumps({"ok": True}))


def cmd_add(config, magnet_or_url):
    base_url, cookie = login(config)
    qbt_request(base_url, "/api/v2/torrents/add", cookie=cookie, data={"urls": magnet_or_url})
    print(json.dumps({"ok": True}))


def main():
    if len(sys.argv) < 2:
        print(json.dumps({"error": "no command given"}))
        sys.exit(1)

    config = load_config()
    command = sys.argv[1]

    if command == "list":
        cmd_list(config)
    elif command in ("pause", "resume"):
        if len(sys.argv) < 3:
            print(json.dumps({"error": f"{command} requires a torrent hash"}))
            sys.exit(1)
        cmd_action(config, command, sys.argv[2])
    elif command == "delete":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "delete requires a torrent hash"}))
            sys.exit(1)
        with_files = "--with-files" in sys.argv[3:]
        cmd_action(config, "delete", sys.argv[2], with_files=with_files)
    elif command == "add":
        if len(sys.argv) < 3:
            print(json.dumps({"error": "add requires a magnet link or URL"}))
            sys.exit(1)
        cmd_add(config, sys.argv[2])
    else:
        print(json.dumps({"error": f"unknown command: {command}"}))
        sys.exit(1)


if __name__ == "__main__":
    main()
