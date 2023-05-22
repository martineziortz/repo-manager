# Tag Parsing

This script will look at a repository and print out a list of tags that should be used.

```sh
parse-tags.py \
  --repo-name example-repo \
  --tag-file tag-mapping.json \
  --composer-file path/to/composer.json
```

## Things that are looked at

If a `composer.json` is present then the `name`, `description`, `keywords`, and `type` values are checked. Additionally,
the packages required are reviewed and tags are created based on the provided tag mapping file. If a full package name 
is provided in the mapping file and a `composer.lock` is present then a versioned tag will be created.

For example, if `laravel/framework` is present and is version 8 then the output tag will be `laravel-8`.

## Output

```json
{
  "names": [
    "laravel",
    "laravel-10",
    "leaderboard",
    "project"
  ]
}
```

## Tag mapping configuration

The mapping configuration is a list of words to look for keyed by the tag to apply when those words are found.

Example:

```json
{
  "drupal": [
    "drupal",
    "drupal/core"
  ],
  "laravel": [
    "laravel",
    "laravel/framework"
  ],
  "provably-fair": [
    "provable",
    "provably"
  ]
}
```

This will look for `provable` and `provably`. If either of those is found it will add `provably-fair` to the tag output.
