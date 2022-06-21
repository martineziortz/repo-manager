import argparse
from lib.get_fileset_hash import get_fileset_hash

parser = argparse.ArgumentParser(description='Generate hash for a list of files. Normalizes the file order first for consistent results.',
                                formatter_class=argparse.ArgumentDefaultsHelpFormatter)
parser.add_argument('files', metavar='FILE', nargs='+')

args = vars(parser.parse_args())

print(get_fileset_hash(args.get('files') or []))
