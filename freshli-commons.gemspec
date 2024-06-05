# frozen_string_literal: true

begin
  require_relative 'lib/corgibytes/freshli/commons/version'
rescue LoadError
  module ::Corgibytes
    module Freshli
      module Commons
        VERSION = '0.0.0'
      end
    end
  end
end

Gem::Specification.new do |spec|
  spec.name = 'freshli-commons'

  spec.version = Corgibytes::Freshli::Commons::VERSION

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
    generated_files += ['lib/corgibytes/freshli/commons/version.rb']
    git_files + generated_files
  end
  spec.bindir = 'exe'
  spec.executables = spec.files.grep(%r{\Aexe/}) { |f| File.basename(f) }
  spec.require_paths = ['lib']

  spec.add_dependency 'aruba', '~> 2.1.0'
  spec.add_dependency 'grpc', '~> 1.64.0'
  spec.add_dependency 'grpc-tools', '~> 1.64.0'
  spec.add_dependency 'rspec-expectations', '~> 3.12.3'
  spec.add_dependency 'sqlite3', '~> 1.6.6'

  # For more information and examples about making a new gem, check out our
  # guide at: https://bundler.io/guides/creating_gem.html
  spec.metadata['rubygems_mfa_required'] = 'true'
end
