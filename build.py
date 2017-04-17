#!/usr/bin/env python

from bottle import template
from markdown import markdown
import email
import os
import subprocess
import sys
import time

config = {
    "root": "http://example.com",
    "source_dir": "./content",
    "target_dir": "./www",
    "template_dir": "./templates",
    "default_template": "default",
    "templates": {},
    "tags": [],
}

now = str(int(time.time()))

def load_article(article):
    """
    Load an article
    """

    if article["path"] == "":
        article["is_index"] = True
        article["tags"] = []
    elif article["content"] and os.path.basename(article["content"]) == "index.md":
        article["is_index"] = True
        article["tags"] = article["path"].split("/")
    else:
        article["is_index"] = False
        article["tags"] = article["path"].split("/")[:-1]

    # Default - override later
    article["timestamp"] = now

    if not article["content"]:
        return

    filename = os.path.join(config["source_dir"], article["content"])
    with open(filename, "r") as content_file:
        content = content_file.read().strip()

    message = email.message_from_string(content)

    headers = {
        key.lower(): [
            value.strip().lower()
            for value
            in values.split(",")
        ]
        for key, values
        in message.items()
    }

    content = message.get_payload()

    # Prep plain text
    (_, ext) = os.path.splitext(article["content"])
    if ext == ".txt":
        content = content.split("\n")
        content = "\n".join(["# " + content[0], "<pre>"] + [line + "  " for line in content[2:]] + ["</pre>"])

    article["tags"] += headers.get("tags", [])

    article["timestamp"] = headers["timestamp"][0]

    title, content = content.split("\n", 1)
    article["title"] = title[2:]
    article["content"] = markdown(content, output_format="html5")

def main():
    # Build a picture of what's there

    pages = {}
    dirs = {}
    for path, _, files in os.walk(config["source_dir"]):
        path = os.path.relpath(path, config["source_dir"])

        if path == ".":
            path = ""

        pages[path] = {
            "root": config["root"],
            "path": path,
            "content": os.path.join(path, "index.md") if "index.md" in files else None,
            "hidden": ".hidden" in files or pages.get(os.path.dirname(path), {}).get("hidden") == True,
        }

        for filename in files:
            if filename not in ["index.md", ".hidden"]:
                (filepath, _) = os.path.splitext(filename)
                filepath = os.path.join(path, filepath)

                pages[filepath] = {
                    "path": filepath,
                    "content": os.path.join(path, filename),
                    "hidden": pages[path]["hidden"],
                }

        if path == "":
            continue

        if ".hidden" in files or pages[os.path.dirname(path)]["hidden"]:
            continue

        current_dir = dirs
        for part in path.split("/"):
            if part not in current_dir:
                current_dir[part] = {}
            current_dir = current_dir[part]

    # Load all the articles in
    for i, path in enumerate(pages.keys()):
        percent = int(i / len(pages) * 101)
        prog = int(percent / 2)

        print("[{}{}] {}%".format("=" * prog, " " * (50 - prog), percent), end="\r")
        load_article(pages[path])
    print()

    articles = sorted(pages.keys(), key=lambda path: pages[path]["timestamp"] + path, reverse=True)

    # Clear out the dist dir
    for r, d, f in os.walk(config["target_dir"], topdown=False):
        for name in f:
            os.remove(os.path.join(r, name))
        for name in d:
            os.rmdir(os.path.join(r, name))

    # Build the content
    # Build the pages
    for path in sorted(pages.keys()):
        # Let's ditch this at some point
        check_path = "blog" if path == "" else path

        other_articles = [
            pages[a] for a in articles
            if pages[a]["path"].startswith("{}/".format(check_path))
            if pages[a]["path"] != path
            if pages[a]["content"]
            if not pages[a]["is_index"]
            if not pages[a]["hidden"] or os.path.dirname(a) == check_path
        ]

        blurb = pages[path]

        if not blurb["content"]:
            blurb = None

        if blurb and not other_articles:
            other_articles = [blurb]
            blurb = None

        if not blurb and not other_articles:
            continue

        article = blurb or other_articles[0]

        data = {
            "url": path.lower().split(os.path.sep) if path else [],
            "title": article["title"],
            "tags": sorted(set(article["tags"] + config["tags"])),
            "blurb": blurb,
            "articles": other_articles,
            "dirs": dirs,
        }

        # Create the folder
        dist_path = os.path.join(config["target_dir"], path)
        os.makedirs(dist_path)

        template_name = config["templates"].get(path, config["default_template"])

        # Write the page
        with open(os.path.join(dist_path, "index.html"), "w") as f:
            f.write(template(template_name, data))

    # Write RSS
    with open(os.path.join(config["target_dir"], "rss.xml"), "w") as f:
        public_articles = [
            pages[a] for a in articles
            if not pages[a]["hidden"]
        ]

        f.write(template("rss", root=config["root"], title=public_articles[0]["title"], articles=public_articles))

    # Create the site map
    with open(os.path.join(config["target_dir"], "map.xml"), "w") as f:
        f.write(template("map", root=config["root"], pages=sorted([
            "{}/".format(path) if path else ""
            for path in pages.keys()
            if not pages[path]["hidden"]
        ])))

if __name__ == "__main__":
    main()
