import hashlib

# Mimic the result of using shasum to generate a hash of file hashes
# Bash:
# ```sh
# shasum -- path/to/file path/to/another/file \
#   | awk '{print $1}' \
#   | shasum \
#   | awk '{print $1}'
# ```
def get_fileset_hash(filenames):
    hashes = []

    filenames = list(set(filenames))
    filenames.sort()

    # Get each file's hash.
    # This mimics shasum path/to/file | awk '{print $1}'
    for fn in filenames:
        o = open(fn, 'rb')
        f = o.read()
        hashes.append(hashlib.sha1(f).hexdigest())
        o.close()

    # Get the hash of each hash
    hl = hashlib.new("sha1")
    for h in hashes:
        hl.update(h.encode())
        # This newline is required to mimic the output of the full shasum chain
        hl.update("\n".encode())

    return hl.hexdigest()