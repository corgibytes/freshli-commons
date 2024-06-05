# frozen_string_literal: true

require 'timeout'

require 'rspec/expectations'

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__), 'step_definitions', 'grpc')))

require 'freshli_agent_services_pb'
require 'health_services_pb'

module Corgibytes
  module Freshli
    module Commons
      # Test driver client for communicating with the gRPC API.
      class GrpcClient
        include RSpec::Matchers

        def initialize(port)
          @port = port
        end

        def shutdown!
          client = grpc_agent_client_on(@port)
          response = client.shutdown(::Google::Protobuf::Empty.new)
          expect(response).to be_a(::Google::Protobuf::Empty)
        end

        def detect_manifests(project_path)
          client = grpc_agent_client_on(@captured_port)
          response = client.detect_manifests(::Com::Corgibytes::Freshli::Agent::ProjectLocation.new(path: project_path))

          response.map(&:path)
        end

        # rubocop:disable Naming/AccessorMethodName
        def get_validating_packages
          client = grpc_agent_client_on(@port)
          response = client.get_validating_packages(::Google::Protobuf::Empty.new)

          response.map(&:purl)
        end

        def get_validating_repositories
          client = grpc_agent_client_on(@port)
          response = client.get_validating_repositories(::Google::Protobuf::Empty.new)

          response.map(&:url)
        end
        # rubocop:enable Naming/AccessorMethodName

        def process_manifest(manifest_path, moment_in_time)
          client = grpc_agent_client_on(@port)
          response = client.process_manifest(
            ::Com::Corgibytes::Freshli::Agent::ProcessingRequest.new(
              manifest: ::Com::Corgibytes::Freshli::Agent::ManifestLocation.new(path: manifest_path),
              moment: ::Google::Protobuf::Timestamp.from_time(moment_in_time.to_time)
            )
          )
          response.path
        end

        def retrieve_release_history(package_url)
          client = grpc_agent_client_on(@port)
          response = client.retrieve_release_history(::Com::Corgibytes::Freshli::Agent::Package.new(purl: package_url))
          response.map do |release|
            {
              version: release.version,
              released_at: release.released_at.to_time.to_datetime.new_offset('0:00')
            }
          end
        end

        def health_check
          client = Grpc::Health::V1::Health::Stub.new("localhost:#{@port}", :this_channel_is_insecure)
          response = client.check(
            Grpc::Health::V1::HealthCheckRequest.new(
              service: Com::Corgibytes::Freshli::Agent::Agent::Service.service_name
            )
          )
          response.status
        end

        # rubocop:disable Naming/PredicateName
        def is_running!
          expect(health_check).to eq(:SERVING)
        end
        # rubocop:enable Naming/PredicateName

        # rubocop:disable Metrics/MethodLength
        def wait_until_running!
          Timeout.timeout(5) do
            attempts = 0
            loop do
              attempts += 1
              yield(attempts) if block_given?

              status = nil
              begin
                status = health_check
              rescue GRPC::Unavailable, GRPC::NotFound
                status = nil
              end

              break if status == :SERVING

              sleep 0.1
            end
          end
        end
        # rubocop:enable Metrics/MethodLength

        private

        def grpc_agent_client_on(_port)
          Com::Corgibytes::Freshli::Agent::Agent::Stub.new("localhost:#{@port}", :this_channel_is_insecure)
        end
      end
    end
  end
end
