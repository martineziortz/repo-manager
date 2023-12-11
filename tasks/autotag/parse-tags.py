from packaging.version import InvalidVersion, parse as parse_version
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

def get_json_data(filename):
    data = None
    if (os.path.exists(filename)):
        with open(filename, "r") as f:
            data = json.load(f)
    return data or json.loads("{}")

def get_labels_from_composer_json_file(json_data, mapping_data, key="require"):
    labels = []

    for package in json_data.get(key, []):
        labels.extend(map_to_alternate_tags(package, mapping_data) or [])
    return labels

def get_labels_from_composer_lock_file(lock_data, mapping_data, key="packages"):
    labels = []
    for package in lock_data.get(key, []):
        alternates = map_to_alternate_tags(package["name"], mapping_data)
        if len(alternates) == 0:
            continue

        labels.extend(alternates)

        try:
            version = get_major_version(package["version"])
        # Package versions might be things like dev-main, dev-develop#abc123, etc.
        # These will trigger a ValueError when attempting to parse. We currently
        # only care about stable major versions for tagging, so ignore things that
        # aren't.
        except InvalidVersion:
            pass
        else:
            labels.extend(map(lambda x: x + '-' + version, alternates))

    return labels

def get_major_version(version):
    # Change v1.0-dev into 1.0-dev
    cleaned = re.sub(r"^v", "", version)
    # Change 1.x-dev into 1.0-dev
    cleaned = re.sub(r"\.x", ".0", cleaned)
    parsed = parse_version(cleaned)

    return str(parsed.major)

def map_to_alternate_tags(data, mapping_data, partial_match=False):
    result = set()

    if isinstance(data, str):
        data = [data]

    for item in data:
        for tag, needles in mapping_data.items():
            if partial_match and any(needle in item for needle in needles):
                    result.add(tag)
            elif not partial_match and any(needle == item for needle in needles):
                    result.add(tag)
    return list(result)

def parse_composer(composer_file, mapping_data):
    composer_data = get_json_data(composer_file)

    composer_path = os.path.dirname(composer_file) or "."
    composer_lock_file = composer_path + "/composer.lock"
    lock_data = get_json_data(composer_lock_file)

    checked_text = []
    checked_text.extend([composer_data.get("name") or ""])
    checked_text.extend([composer_data.get("description") or ""])

    labels = []
    labels.extend(composer_data.get("keywords") or [])
    labels.extend([composer_data.get("type")])
    labels.extend(get_labels_from_composer_json_file(composer_data, mapping_data) or [])
    labels.extend(get_labels_from_composer_lock_file(lock_data, mapping_data) or [])
    labels.extend(get_labels_from_composer_lock_file(lock_data, mapping_data, "packages-dev") or [])

    return labels, checked_text

mapping_data = get_json_data(args.get("tag_file"))

# Text to parse for possible tag matches.
checked_text = [
    args.get("repo_name")
]

labels = []
if args.get("composer_file"):
    new_labels, new_text = parse_composer(args.get("composer_file"), mapping_data)
    labels.extend(new_labels)
    checked_text.extend(new_text)

# Uses the tag mapping file to look for partial text matches.
labels.extend(map_to_alternate_tags(checked_text, mapping_data, True))

# Filter empty strings
labels = [s for s in labels if s]
# Ensure labels are valid patterns
labels = map(slugify, labels)
# Ensure unique items only
labels = list(set(labels))
labels.sort()

print(json.dumps({"names": labels}))
