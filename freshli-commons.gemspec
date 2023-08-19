# frozen_string_literal: true

begin
  require 'semver'
  # rubocop:disable Style/FormatStringToken
  semver_version = SemVer.find.format('%M.%m.%p%s%d')
  # rubocop:enable Style/FormatStringToken
rescue LoadError
  require 'yaml'
  version_data = YAML.load_file(File.join(__dir__, '.semver'))
  semver_version = "#{version_data[:major]}.#{version_data[:minor]}.#{version_data[:patch]}-#{version_data[:special]}"
end

Gem::Specification.new do |spec|
  spec.name = 'freshli-commons'

  spec.version = semver_version

  spec.authors = ['M. Scott Ford']
  spec.email = ['scott@corgibytes.com']

  spec.summary = 'Common build and testing code that is shared amongst the Freshli repositories'
  spec.homepage = 'https://github.com/corgibytes/freshli-commons'
  spec.required_ruby_version = '>= 3.0.0'

  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = spec.homepage

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files = Dir.chdir(__dir__) do
    git_files = `git ls-files -z`.split("\x0").reject do |f|
      (File.expand_path(f) == __FILE__) ||
        f.start_with?(*%w[bin/ test/ spec/ features/ .git .circleci appveyor Gemfile])
    end
    # include gRPC generated files in the gem
    generated_files = Dir.glob('lib/corgibytes/freshli/commons/step_definitions/grpc/*.rb')
    git_files + generated_files
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  # Uncomment to register a new dependency of your gem
  # spec.add_dependency "example-gem", "~> 1.0"
  spec.add_dependency 'aruba', '~> 2.1.0'
  spec.add_dependency 'grpc'
  spec.add_dependency 'rspec-expectations'
  spec.add_dependency 'sqlite3'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
