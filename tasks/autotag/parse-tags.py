import argparse
import json
import os
 
parser = argparse.ArgumentParser(description='Figure out what tags should be on a repository', 
                                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-r', '--repo-name', help='repoistory name', required=True)
parser.add_argument('-t', '--tag-file', help='tag mapping file path', default='tag-mapping.json', required=True)
parser.add_argument('-c', '--composer-file', help='composer.json file path', required=True)

args = vars(parser.parse_args())

f = open(args.get('tag_file'), 'r')
mapping_data = json.load(f)
f.close()

if (not os.path.exists(args.get('composer_file'))):
    composer_data = json.loads('{}')
else:
    f = open(args.get('composer_file'), 'r')
    composer_data = json.load(f)
    f.close()

labels = composer_data.get('keywords', [])

for tag, needles in mapping_data.items():
    if len(tag) == 0:
        continue
    for needle in needles:
        if len(needle) == 0:
            continue

        matches_repo = needle in args.get('repo_name')
        matches_composer_name = needle in composer_data.get('names', '')
        matches_composer_desc = needle in composer_data.get('description', '')

        if (matches_repo or matches_composer_name or matches_composer_desc):
            labels.append(tag)

labels = list(set(labels))
labels.sort()

print(json.dumps(labels))
