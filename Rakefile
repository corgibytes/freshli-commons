# frozen_string_literal: true
require 'git-version-bump'

def version_file
  File.expand_path(File.join(File.dirname(__FILE__), 'lib', 'corgibytes', 'freshli', 'commons', 'version.rb'))
end

def write_version
  version_file_contents = <<~VERSION_FILE
  module Corgibytes
    module Freshli
      module Commons
        VERSION = '#{GVB.version}'
      end
    end
  end
  VERSION_FILE
  File.write(version_file, version_file_contents)
  load_version
end

def load_version
  unless require_relative version_file
    # forcefully reload version file
    Corgibytes::Freshli::Commons.send(:remove_const, :VERSION)
    load(version_file)
  end
end

write_version

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'

require 'fileutils'

# TODO: Copy the `freshli_agent.proto` from the `corgibytes/freshli` repository
# instead of having it live in this repository. Similar to what's being done
# with the health status proto file below.

# based on https://stackoverflow.com/a/29743469/243215
def download(url, target_path)
  # rubocop:disable Security/Open
  require 'open-uri'
  download = URI.open(url)
  # rubocop:enable Security/Open
  IO.copy_stream(download, target_path)
end

# Generate gRPC files from the freshli_agent.proto file
GENERATED_GRPC_FILES = [
  'lib/corgibytes/freshli/commons/step_definitions/grpc/freshli_agent_pb.rb',
  'lib/corgibytes/freshli/commons/step_definitions/grpc/freshli_agent_services_pb.rb',
  'lib/corgibytes/freshli/commons/step_definitions/grpc/health_services_pb.rb',
  'lib/corgibytes/freshli/commons/step_definitions/grpc/health_pb.rb'
].freeze
# rubocop:disable Metrics/BlockLength
namespace :grpc do
  task :generate do
    Rake::Task['grpc:generate:force'].invoke unless GENERATED_GRPC_FILES.all? { |file| File.exist?(file) }
  end

  namespace :generate do
    desc 'Generate gRPC files even if they already exist'
    task :force do
      system(
        'bundle exec grpc_tools_ruby_protoc -I ' \
        './protos/corgibytes/freshli/agent/grpc ' \
        '--ruby_out=./lib/corgibytes/freshli/commons/step_definitions/grpc ' \
        '--grpc_out=./lib/corgibytes/freshli/commons/step_definitions/grpc ' \
        './protos/corgibytes/freshli/agent/grpc/freshli_agent.proto'
      )

      FileUtils.mkdir_p('tmp')

      download(
        'https://raw.githubusercontent.com/grpc/grpc/e35cf362a49b4de753cbe69f3e836d2e40408ca2' \
        '/src/proto/grpc/health/v1/health.proto',
        File.expand_path(File.join(File.dirname(__FILE__), 'tmp', 'health.proto'))
      )
      system(
        'bundle exec grpc_tools_ruby_protoc -I tmp ' \
        '--ruby_out=lib/corgibytes/freshli/commons/step_definitions/grpc ' \
        '--grpc_out=lib/corgibytes/freshli/commons/step_definitions/grpc ' \
        'tmp/health.proto'
      )
    end
  end
end
# rubocop:enable Metrics/BlockLength

desc 'Generate gRPC files'
task grpc: %i[grpc:generate]

# Ensure that the grpc files are generated before the tests run
RSpec::Core::RakeTask.new(spec: 'grpc')

require 'rubocop/rake_task'

RuboCop::RakeTask.new

namespace :version do
  desc "Persist the the current version number as #{GVB.version}"
  task :persist do
    write_version
  end

  task :show do
    puts "Current version #{Corgibytes::Freshli::Commons::VERSION}"
  end
end

task :reload_and_build do
  Rake::Task.clear
  require "bundler/gem_helper"
  Bundler::GemHelper.new.install_tasks
  Rake::Task['build'].invoke
end

# Ensure that the grpc files are generated before the build runs
Rake::Task['build'].enhance(['grpc', 'version:bump:patch', 'version:persist', 'version:show', 'reload_and_build'])

task default: %i[grpc spec rubocop]

# Copied from https://github.com/mpalmer/git-version-bump/blob/c1af65cd82c131cb541fa717b3d24a9247973049/lib/git-version-bump/rake-tasks.rb
# to avoid an issue that was causing the version number of the `git-version-bump` gem to be used instead
# of this gem's version. That's because of how the `GVB.version` method determines the calling file.
namespace :version do
	namespace :bump do
   	desc "bump major version (x.y.z -> x+1.0.0)"
   	task :major do
			GVB.tag_version "#{GVB.major_version + 1}.0.0"

			puts "Version is now #{GVB.version}"
		end

   	desc "bump minor version (x.y.z -> x.y+1.0)"
   	task :minor do
			GVB.tag_version "#{GVB.major_version}.#{GVB.minor_version+1}.0"

			puts "Version is now #{GVB.version}"
		end

    desc "bump patch version (x.y.z -> x.y.z+1)"
		task :patch do
			GVB.tag_version "#{GVB.major_version}.#{GVB.minor_version}.#{GVB.patch_version+1}"

			puts "Version is now #{GVB.version}"
		end

		desc "Print current version"
		task :show do
			puts GVB.version
		end
	end
end
