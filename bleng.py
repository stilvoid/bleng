#!/usr/bin/env python

from bottle import template
from markdown.preprocessors import Preprocessor
from markdown import markdown
import email
import json
from markdown.extensions import Extension
import os
import re
import subprocess
import sys
import time

SUPPORTED_EXTENSIONS = (".markdown", ".mdown", ".mdwn", ".mkdn", ".mkd", ".md", ".txt")

config = {
    "root": "https://example.com",
    "source_dir": "./content",
    "target_dir": "./www",
    "template_dir": "./templates",
    "default_template": "default",
    "templates": {},
    "tags": [],
}

now = str(int(time.time()))

class HeaderBumpPreprocessor(Preprocessor):
    def run(self, lines):
        return [
            re.sub(r"^(\s*#)", r"\1#", line)
            for line in lines
        ]

class HeaderBumpExtension(Extension):
    def extendMarkdown(self, md, md_globals):
        md.preprocessors["headerbump"] = HeaderBumpPreprocessor(md)

def load_article(article):
    """
    Load an article
    """

    split_path = article["path"].split("/")

    # Default - override later
    article["timestamp"] = now
    article["is_index"] = False
    article["file_path"] = article["content"]

    if not article["content"] or os.path.splitext(os.path.basename(article["content"]))[0] == "index":
        article["is_index"] = True

    if article["path"] == "":
        article["url"] = "/"
        article["tags"] = []
        article["parent"] = None
    else:
        article["url"] = "/{}/".format(article["path"])
        article["tags"] = article["path"].split("/")[:-1]

        if article["is_index"]:
            if len(split_path) > 1:
                article["parent"] = "/".join(split_path[:-1])
            else:
                article["parent"] = None
        else:
            if len(split_path) > 2:
                article["parent"] = "/".join(split_path[:-2])
            else:
                article["parent"] = None

    article["tags"] = list(set(article["tags"] + config["tags"]))

    if not article["content"]:
        article["title"] = split_path[-1]
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

    article["timestamp"] = headers.get("timestamp", [now])[0]

    title, content = content.split("\n", 1)
    article["title"] = title[2:]
    article["content"] = markdown(
        content,
        output_format="html5",
        extensions=[HeaderBumpExtension()]
    )

def main():
    # Build a picture of what's there

    hidden_paths = []
    pages = {}
    dirs = {}

    for path, _, files in os.walk(config["source_dir"]):
        path = os.path.relpath(path, config["source_dir"])

        if path == ".":
            path = ""

        dir_config = {}

        if "config.json" in files:
            with open(os.path.join(config["source_dir"], path, "config.json")) as f:
                dir_config = json.load(f)

            files.remove("config.json")

        if dir_config.get("hidden") or os.path.dirname(path) in hidden_paths:
            hidden_paths.append(path)

        for filename in files:
            (filepath, ext) = os.path.splitext(filename)

            if ext not in SUPPORTED_EXTENSIONS:
                continue

            if filepath == "index":
                filepath = path
            else:
                filepath = os.path.join(path, filepath)

            pages[filepath] = {
                "path": filepath,
                "content": os.path.join(path, filename),
                "hidden": path in hidden_paths,
            }
            
            pages[filepath].update(dir_config)

        # Create an index if there isn't one
        if path not in pages:
            pages[path] = {
                "path": path,
                "content": None,
                "hidden": path in hidden_paths,
            }

            pages[path].update(dir_config)

        if path == "":
            continue

        if path in hidden_paths or os.path.dirname(path) in hidden_paths:
            continue

        # Build the directory map
        current_dir = dirs
        for part in path.split("/"):
            if part not in current_dir:
                current_dir[part] = {}
            current_dir = current_dir[part]

    # Load all the articles in
    for i, path in enumerate(pages.keys()):
        percent = int((i + 1) / len(pages) * 100)
        prog = int(percent / 2)

        print("[{}{}] {}%".format("=" * prog, " " * (50 - prog), percent), end="\r")
        load_article(pages[path])
    print()

    # Clear out the dist dir
    for r, d, f in os.walk(config["target_dir"], topdown=False):
        for name in f:
            os.remove(os.path.join(r, name))
        for name in d:
            os.rmdir(os.path.join(r, name))

    # Build the pages
    for path in sorted(pages.keys()):
        article = pages[path]

        articles = [
            page for page in pages.values()
            if not page["hidden"] or article["hidden"]
        ]

        if article.get("sort") == "timestamp":
            articles = sorted(articles, key=lambda a: a["timestamp"] + a["path"], reverse=True)
        else:
            articles = sorted(articles, key=lambda a: a["title"])

        # Create the folder
        dist_path = os.path.join(config["target_dir"], path)
        try:
            os.makedirs(dist_path)
        except:
            pass

        template_name = config["templates"].get(path, config["default_template"])

        # Write the page
        with open(os.path.join(dist_path, "index.html"), "w") as f:
            f.write(template(template_name, {
                "dirs": dirs,
                "config": config,
                "page": article,
                "articles": articles,
            }))

    # Write RSS
    with open(os.path.join(config["target_dir"], "rss.xml"), "w") as f:
        public_articles = [
            page for page in pages.values()
            if not page["hidden"]
            if not page["is_index"]
            if page["path"].startswith("blog/")
        ]

        public_articles = sorted(public_articles, key=lambda a: a["timestamp"] + a["path"], reverse=True)

        public_articles = public_articles[:10]

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
