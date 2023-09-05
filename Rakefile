# frozen_string_literal: true

require 'bundler/gem_tasks'
require 'rspec/core/rake_task'
require 'git-version-bump/rake-tasks'

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

# Ensure that the grpc files are generated before the build runs
Rake::Task['build'].enhance(['grpc'])

task default: %i[grpc spec rubocop]
