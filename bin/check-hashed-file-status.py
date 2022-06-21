import argparse
import json
import os
import subprocess

parser = argparse.ArgumentParser(description='Determine status for files in a repository', 
                                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('-r', '--repo-name', help='repository name', required=True)
parser.add_argument('-c', '--current-hash', help='The hash of the current version of the file(s)', required=True)
parser.add_argument('-d', '--hash-dir', help='Path to the hash history', required=True)
parser.add_argument('files', metavar='FILE', nargs='+')

args = vars(parser.parse_args())

files=args.get('files') or []
hash_dir=args.get('hash_dir')
repo_name=args.get('repo_name')
hash_current=args.get('current_hash')

files_found=True
hash_repository=None
is_latest=False
is_existing_match=False

files = list(set(files))
files.sort()
for fn in files:
    files_found &= os.path.exists(fn)

if (files_found):
    hash_repository=subprocess.run(['./bin/generate-hash.sh'] + files, stdout=subprocess.PIPE).stdout.decode("utf-8").strip()
    if (os.path.exists(hash_dir + '/' + hash_repository + '.sha1')):
        is_existing_match=True

if (hash_repository == hash_current):
    is_latest=True

result = {
    'has-latest': int(is_latest),
    'has-match': int(is_existing_match),
    'was-found': int(files_found),
    'hash-current': hash_current or '',
    'hash-remote': hash_repository or '',
}

print(json.dumps(result))
