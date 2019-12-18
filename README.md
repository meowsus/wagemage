# Codeslave

A CLI for making changes to many GitHub-hosted git repositories.

## Inspiration

At [Workarea](https://github.com/workarea-commerce) we have adopted a mutli-repo architecture for our platform and its plugins. Though separation is good, we have a lot of repositories. Sometimes we need to make changes across a great deal of our repositories. Sometimes we go a bit insane doing so.

We tried using [Gitbot](https://github.com/clever/gitbot) but found that their solution only accounts for making changes to the default branch of each repository. This does not work for us, since we support many versions of our plugins and have therefore adopted a branching strategy that works for us.

Codeslave was born out of fear of mundane tasks. Maybe it can help you too!

## Installation

```sh
gem install codeslave
```

## Dependencies

1. A [Github account](https://github.com/join)
1. A [Github Personal Access Token](https://help.github.com/en/github/authenticating-to-github/creating-a-personal-access-token-for-the-command-line) with `repo` permissions
1. [Git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
1. [Hub](https://github.com/github/hub/releases)
1. One or more repositories owned by you or an organization of which you are a member

## What It Does

Codeslave hits the GitHub API to retrieve a list of repositories for the currently authenticated user. It can optionally be configured to search only within a given GitHub organization for this list of repositories.

Once the list of repositories is derived, Codeslave asks if you'd like to clone the full list. If you agree, they are cloned to a temporary directory on your machine that will be cleaned up once the operation is complete, unless otherwise specified.

Upon cloning all of the repositories, each is searched for a list of remote branches. Codeslave can optionally be configured to search for branches that match a specific pattern.

Once the list of branches is derived, Codeslave asks you to review the list of repositories and their branches to make sure that they look correct to you before executing the supplied script on each branch.

For each branch in each repository the following occurs:
1. A branch is checked out
1. A new, "temporary" branch based on the branch that has been checked out is created in the format `codeslave/[ORIGINAL_BRANCH_NAME]/[TIMESTAMP]`.
1. The supplied script is executed and is passed arguments in this order:
    1. The current repo's directory, and
    1. The current branch name
1. If the supplied script exits with a
    * non-zero exit code, the following steps are skipped
    * zero exit code, the following steps occur
1. All changes are added to the Git stage
1. A commit is made, based on the `stdout` of the supplied script
1. The branch is pushed
1. A pull request is automatically created, with configurable reviewers

## Usage

Note: You will be prompted to enter your Github Personal Access Token at runtime, unless it is supplied as the value for the `CODESLAVE_GITHUB_TOKEN` environment variable in your current session.

| Option | Description | Required? |
| ------ | ----------- | --------- |
| `-h`, `--help` | Displays the command's help and exits | No |
| `-v`, `--version` | Displays the command's version and exits | No |
| `-o`, `--org` | Find repositories within a given Github organization. | No. Defaults to all available repos for the authorized user. |
| `-r`, `--repo` | A regular expression on which to filter returned repository names. A repository name is the _full name of the repository_, i.e. `meowsus/codeslave` and not simply `codeslave`. | No. Defaults to all available repos. |
| `-b`, `--branch` | A regular express on which to filter discovered branch names, after a repository is cloned. | No. Defaults to all remote branches. |
| `-s`, `--script` | A path to any executable script file to run against all filtered branches across all filtered repos. | Yes |
| `--reviewers` | A comma delimited list of GitHub users to add to the resulting pull request, i.e. `meowsus,wumpus_hunter,code_lich` | No |
| `--debug` | Dry run. Doesn't push or issue a pull request, retains the temporary directory for review. | No |

## Examples

All master branches across all repositories in a given organization:

```sh
codeslave \
  --org workarea-commerce \
  --branch '^master$' \
  --script ~/path/to/some/script.sh
```

All master and development branches for a specific repository, and debug:

```sh
codeslave \
  --repo 'meowsus/codeslave' \
  --branch '^(master|develop)$' \
  --script ./relative/to/current/directory/script.sh \
  --debug
```

All stable release branches across the universe of Workarea and its plugins:

```sh
codeslave \
  --org workarea-commerce \
  --repo '^workarea-commerce/workarea' \
  --branch '(-stable$|^master$)' \
  --script ~/hunt_the_wumpus \
  --reviewers bencrouse,mttdffy,tubbo
```

## Scripting

As mentioned, the script is supplied with the current repository's path as the first argument and the current branch name as the second.

The script can be of any type that is executable by the host machine.

The script **must** exit with a zero exit code to be considered successful. Exiting with a non-zero exit code tells Codeslave to skip operation on the current branch in the current repository.

Peruse [the examples](./examples) for a better understanding of what to do and contribute your own if you've done something noteworthy!

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/codeslave. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Codeslave project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/codeslave/blob/master/CODE_OF_CONDUCT.md).
