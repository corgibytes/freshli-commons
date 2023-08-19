# Corgibytes::Freshli::Commons

Common testing and build tools code used by [Freshli](https://github.com/corgibytes/freshli) projects.

## Installation

Install the gem and add to the application's Gemfile by executing:

    $ bundle add freshli-commons

If bundler is not being used to manage dependencies, install the gem by executing:

    $ gem install freshli-commons

## Usage

### Step Definitions

The following step definitions, and supporting classes, are defined in this repository:

Working with command output:

* `Then(/^it should (pass|fail) with exact output containing file paths:$/)`

Working with CycloneDX files:

* `Then('the CycloneDX file {string} should be valid')`
* `Then('the CycloneDX file {string} should contain {string}')`

Working with Git repositories:

* `Given('I clone the git repository {string} with the sha {string}')`
* `Then('running git status should not report any modifications for {string}')`

Working with Freshli Language Agent gRPC services:

* `Given('a test service is started on port {int}')`
* `Then('GetValidatingRepositories response should contain:')`
* `Then('RetrieveReleaseHistory response should be empty')`
* `Then('RetrieveReleaseHistory response should contain the following versions and release dates:')`
* `Then('the DetectManifests response contains the following file paths expanded beneath {string}:')`
* `Then('the freshli_agent.proto gRPC service is running on port {int}')`
* `Then('the GetValidatingPackages response should contain:')`
* `Then('the ProcessManifest response contains the following file paths expanded beneath {string}:')`
* `Then('there are no services running on port {int}')`
* `When('I call DetectManifests with the full path to {string} on port {int}')`
* `When('I call GetValidatingPackages on port {int}')`
* `When('I call GetValidatingRepositories on port {int}')`
* `When('I call ProcessManifest with the expanded path {string} and the moment {string} on port {int}')`
* `When('I call RetrieveReleaseHistory with {string} on port {int}')`
* `When('I wait for the freshli_agent.proto gRPC service to be running on port {int}')`
* `When('the gRPC service on port {int} is sent the shutdown command')`
* `When('the test service running on port {int} is stopped')`

### Execute

The `Corgibytes::Freshli::Commons::Execute` module contains methods for helping with executing shell commands in a shell/like Ruby script, such as `build.rb`, `test.rb`, `lint.rb`.

Files that use it should pull it in using:

    require 'corgibytes/freshli/commons/execute'
    # rubocop:disable Style/MixinUsage
    include Corgibytes::Freshli::Commons::Execute
    # rubocop:enable Style/MixinUsage

The `rubocop` disable/enable lines avoid a warning from Rubocop about including the modules contents into the global namespace.

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake spec` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `.semver`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and the created tag, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/corgibytes/freshli-commons.
