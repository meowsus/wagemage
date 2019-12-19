# Codeslave

A CLI for making changes to many git repositories.

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

## Usage 

Note: You will be prompted to enter your Github Personal Access Token at runtime, unless it is supplied as the value for the `CODESLAVE_GITHUB_TOKEN` environment variable in your current session.

### View CLI Usage

```sh
codeslave --help
```

### Options

TODO:
    org is optional, default to authenticated user

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake test` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/[USERNAME]/codeslave. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the Codeslave project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/[USERNAME]/codeslave/blob/master/CODE_OF_CONDUCT.md).
