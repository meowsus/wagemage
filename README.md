# Wagemage

> (noun) A magician, usually hermetic, employed by a corporation or government.

A CLI for making changes to many GitHub-hosted git repositories.

[![Tests Status](https://github.com/meowsus/wagemage/workflows/Tests/badge.svg)](https://github.com/meowsus/wagemage/actions)

## Apology and Explanation

This library was developed to handle the unwanted and repetitive tasks I encountered as the release manager at my previous job. While performing these tasks I would frequently imagine myself as a "Wageslave" of the William Gibson / Shadowrun / Cyberpunk universe. Realizing that few people would understand that term, I dubbed this repo "Codeslave." I recognize that the popularity of the cyberpunk universe has no baring on how inappropriately I named this library, and I formally apologize for its unfortunate and initial naming. I have renamed it "Wagemage" as this conveys what I had first attempted to convey in an arguably less racist way.

## Inspiration

At [Workarea](https://github.com/workarea-commerce) we have adopted a mutli-repo architecture for our platform and its plugins. Though separation is good, we have a lot of repositories. Sometimes we need to make changes across a great deal of our repositories. Sometimes we go a bit insane doing so.

We tried using [Gitbot](https://github.com/clever/gitbot) but found that their solution only accounts for making changes to the default branch of each repository. This does not work for us, since we support many versions of our plugins and have therefore adopted a branching strategy that works for us.

Wagemage was born out of fear of mundane tasks. Maybe it can help you too!

## Installation

```sh
gem install wagemage
```

## Dependencies

1. A [Github account](https://github.com/join)
1. A [Github Personal Access Token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) with `repo` permissions
1. [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
1. [Hub](https://github.com/github/hub/releases)
1. One or more repositories owned by you or an organization of which you are a member

## What It Does

Wagemage hits the GitHub API to retrieve a list of repositories for the currently authenticated user. It can optionally be configured to search only within a given GitHub organization for this list of repositories.

Once the list of repositories is derived, Wagemage asks if you'd like to clone the list of repos it has found. If you agree, they are cloned to a temporary directory on your machine that will be cleaned up once the operation is complete, unless otherwise specified.

Upon cloning all of the repositories, each is searched for a list of remote branches. Wagemage can optionally be configured to search for remote branches that match a specific pattern.

Once the list of branches is derived, Wagemage asks you to review the list of repositories and their branches to make sure that they look correct to you before executing the supplied script on each branch.

For each branch in each repository the following occurs:
1. The branch is checked out
1. A new, "temporary" branch based on the branch that has been checked out is created in the format `[PREFIX]/[ORIGINAL_BRANCH_NAME]/[TIMESTAMP]`.
1. The supplied script is executed and is passed arguments in this order:
    1. The current repo's directory, and
    1. The current repo's name, and
    1. The current branch name
1. **The following steps are skipped if**
    * the script exits with a _non-zero exit code_
    * the script exits with a _zero exit code_ but no changes were made to the repository
1. All changes are added to the Git stage
1. A commit is made, based on the `stdout` of the supplied script
1. **The following steps are skipped if the `--debug` option is supplied**
1. The branch is pushed
1. A pull request is automatically created, with configurable reviewers

## Usage

```sh
$ wagemage --help

usage: wagemage [options]
    -h, --help       print this help
    -v, --version    print the version
    -o, --org        github org
    -r, --repo       regex against which to match repo names
    -b, --branch     regex against which to match branches
    -s, --script     the script to run on each repo's branch
    --first-branch   operate only on the "oldest" branch
    --reviewers      array of github users to put on the PR
    --branch-prefix  prefix of the new branch
    --debug          don't push or issue PR, keep the tmp directory
```

You will be prompted to enter your Github Personal Access Token at runtime, unless it is supplied as the value for the `WAGEMAGE_GITHUB_TOKEN` environment variable in your current session.

### Options

#### `--org` (or `-o`)

Limits repository search to a specified GitHub organization.

```
--org workarea-commerce
```

* **Type**: String
* **Required?**: No
* **Default**: All repos available to the authenticated user

#### `--repo` (or `-r`)

Filter returned repositories based on name. Repository names are returned as full names: `meowsus/wagemage` instead of just `wagemage`.

```
--repo '^workarea-commerce/workarea-' # returns all Workarea plugin repos
```

* **Type**: Regex String
* **Required?**: No
* **Default**: None

#### `--branch` (or `-b`)

Filter available remote branches based on name.

```
--branch '(-stable$|^master$)' # returns all potentially stable branches
```

* **Type**: Regex String
* **Required?**: No
* **Default**: None

#### `--script` (or `-s`)

An path to a script to be executed on each derived branch across all derived repositories. This path can be absolute or relative to the directory in which the `wagemage` command is run.

```
--script ~/wagemage_scripts/hunt_the_wumpus
--script /path/to/wagemage_scripts/angband
--script ./wagemage_scripts/arena_of_octos
--script scripts/dwarf_fortress
```

* **Type**: Path String
* **Required?**: Yes
* **Default**: None

#### `--first-branch`

A boolean option to indicate that only the first branch in the derived list of branches for a repository should be operated upon.

```
--branch '(-stable$|^master$)' \ # potentially returns `v2.1-stable, master`
--first-branch # operates on `v2.1-stable` only
```

* **Type**: Boolean
* **Required?**: No
* **Default**: None

#### `--reviewers`

A comma-delineated list of GitHub users to add to the issued pull request. This list must not contain spaces.

```
--reviewers bencrouse,mttdffy,tubbo,jyucis,meowsus
```

* **Type**: Array
* **Required?**: Yes
* **Default**: None

#### `--branch-prefix`

The prefix of the "temporary" branch that is created before changes are made to the repository.

```
--branch-prefix WORKAREA-123
```

* **Type**: String
* **Required?**: Yes
* **Default**: `wagemage`

#### `--help` (or `-h`)

Displays the command's help and exits

#### `--version` (or `-v`)

Displays the command's version and exits

#### `--debug`

Prevents
* pushing branches to GitHub
* issuing pull requests
* temporary directory cleanup

### Examples

All master branches across all repositories in a given organization:

```sh
wagemage \
  --org workarea-commerce \
  --branch '^master$' \
  --script ~/path/to/some/script.sh
```

All master and development branches for a specific repository, and debug:

```sh
wagemage \
  --repo 'meowsus/wagemage' \
  --branch '^(master|develop)$' \
  --script relative/to/current/directory/script.sh \
  --debug
```

All stable release branches across the universe of Workarea and its plugins, prefixed with a Jira issue key to enable the Jira/GitHub integration, with all team members added to the pull request:

```sh
wagemage \
  --org workarea-commerce \
  --repo '^workarea-commerce/workarea' \
  --branch '(-stable$|^master$)' \
  --script ./hunt_the_wumpus \
  --branch-prefix WORKAREA-123 \
  --reviewers bencrouse,mttdffy,tubbo,jyucis
```

## Scripting

As mentioned, the script is supplied with the current repository's path as the first argument, the current repository's name as the second, and the current branch name as the third.

The script can be of any type that is executable by the host machine.

The script **must** exit with a zero exit code to be considered successful. Exiting with a non-zero exit code tells Wagemage to skip operation on the current branch in the current repository.

Peruse [the examples](./examples) for a better understanding of what to do and contribute your own if you've done something noteworthy!

Any data sent to `STDERR` will be printed to your terminal after the command runs.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/meowsus/wagemage. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Wagemage project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/meowsus/wagemage/blob/master/CODE_OF_CONDUCT.md).
