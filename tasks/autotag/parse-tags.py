from pkg_resources import parse_version
from pkg_resources.extern import packaging
from slugify import slugify
import argparse
import json
import os
import re

parser = argparse.ArgumentParser(description="Figure out what tags should be on a repository",
                                 formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument("-r", "--repo-name", help="repoistory name", required=True)
parser.add_argument("-t", "--tag-file",
                    help="tag mapping file path", default="tag-mapping.json")
parser.add_argument("-c", "--composer-file",
                    help="composer.json file path", required=True)

args = vars(parser.parse_args())

mapping_data = json.loads("{}")
composer_data = json.loads("{}")
composer_path = os.path.dirname(args.get("composer_file")) or "."
composer_lock_file = composer_path + "/composer.lock"


def get_json_data(filename):
    data = None
    if (os.path.exists(filename)):
        with open(filename, "r") as f:
            data = json.load(f)
    return data or json.loads("{}")


def get_labels_from_composer_lock_file(lock_data, key="packages"):
    labels = []
    for package in lock_data.get(key, []):
        try:
            tag = package["name"].split(
                "/")[0] + "-" + get_major_version(package["version"])
        # Package versions might be things like dev-main, dev-develop#abc123, etc.
        # These will trigger a ValueError when attempting to parse. We currently
        # only care about stable major versions for tagging, so ignore things that
        # aren't.
        except ValueError:
            pass
        else:
            if package["name"] in ["laravel/framework", "drupal/core"]:
                labels.append(tag)

    return labels


def get_major_version(version):
    # Change v1.0-dev into 1.0-dev
    cleaned = re.sub("^v", "", version)
    # Change 1.x-dev into 1.0-dev
    cleaned = re.sub("\.x", ".0", cleaned)
    parsed = parse_version(cleaned)

    # If something was not close to a semver it gets parsed as-is
    # We want to err on the side of caution, so abort.
    if (isinstance(parsed, packaging.version.LegacyVersion)):
        raise ValueError("Version format unsupported: " + str(version))
    return str(parsed.major)


mapping_data = get_json_data(args.get("tag_file"))
composer_data = get_json_data(args.get("composer_file"))
lock_data = get_json_data(composer_lock_file)

labels = composer_data.get("keywords") or []
labels += [composer_data.get("type")] or []
labels += get_labels_from_composer_lock_file(lock_data) or []
labels += get_labels_from_composer_lock_file(lock_data, "packages-dev") or []

# Text to parse for possible tag matches.
# Uses the tag mapping file to look for partial text matches.
checked_text = [
    args.get("repo_name"),
    (composer_data.get("name") or ""),
    (composer_data.get("description") or "")
]

for tag, needles in mapping_data.items():
    if len(tag) == 0:
        continue
    for needle in needles:
        if len(needle) == 0:
            continue

        if (any(needle in string for string in checked_text)):
            labels.append(tag)

# Ensure unique items only
labels = list(set(map(slugify, labels)))
# Filter empty strings
labels = [s for s in labels if s]
labels.sort()

print(json.dumps({"names": labels}))
