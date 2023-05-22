# Repository Manager

This project is responsible for managing shared files across all projects in the organization. Any procedural/meta files 
that exist across multiple repositories should be here. Examples of such files are:

* `.editorconfig`
* Lando configuration
* Dependabot configuration and auto-merging
* PHP-CS configuration and checking
* Composer validation scripts

Scripts, tasks, and packages may have additional documentation included with them.

## Packages

The system works by defining packages. Packages consist of a definition file and one or more files to manage. Packages 
should be used when the goal is to copy and update files across repositories. Packages rely on the filter configuration 
to determine which repositories to apply their files to. 

### Package structure

Packages should be placed in the package directory. They must contain a YAML configuration file named after the package
itself. They should also include a `files` directory to place managed files in to.

```
packages/<packagename>/
packages/<packagename>/<packagename>.yml
packages/<packagename>/files
```

So, if a package is called `ExamplePackage` the directory would be `packages/ExamplePackage` and the definition file 
would be `packages/ExamplePackage/ExamplePackage.yml`.

### Package definition

Package definitions are YAML files and support a list of files.

Example:

```yml
---
filter:
  topics:
    - topic1
    - topic2
files:
  file1.json: path/in/target/repo/file1.json
  file1-config.json: path/file2.yml
```

This Example package would apply to all repositories with both the `topic1` and `topic2` topics. When it executes it 
will copy files from the package files directory into the repository. The destination name does not have to match the 
original name.

## Tasks

Tasks are bundles of scripts and configuration that are executed under certain conditions. They are a way to organize
related files.

## Repository Topics and Autotagging

Most of the management functionality is reliant on tagging to control what executes. GitHub Topics are used to filter
repository lists and run packages and tasks against.

In order to help with the repository tagging process there is an autotagging task. This task analyzes the repository to
create a list of tags based on various files and metadata. It runs automatically on a fixed schedule to update and add
tags to repositories.

## Hashing

Whenever changes are made to packages a hash is made of their files. This hash is stored for comparison to repositories.
If a stored hash is matched then it means it is safe to update the repository files. If no match is found it means the
repository has a custom version of the file.

**Note: The comparison functionality is temporarily removed.**
