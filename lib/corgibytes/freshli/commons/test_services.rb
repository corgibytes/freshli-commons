# frozen_string_literal: true

require 'rspec/expectations'

module Corgibytes
  module Freshli
    module Commons
      # Controls running test services on specific ports. Used to force a specific port to be in use.
      class TestServices
        include RSpec::Matchers

        def initialize
          @test_services = {}
        end

        def start_on(port)
          expect(@test_services).not_to have_key(port)

          socket4 = Socket.new(Socket::Constants::AF_INET, Socket::Constants::SOCK_STREAM, 0)
          socket4.bind(Socket.pack_sockaddr_in(port, '0.0.0.0'))

          begin
            # bind to a socket using both ipv4 and ipv6
            socket6 = Socket.new(Socket::Constants::AF_INET6, Socket::Constants::SOCK_STREAM, 0)
            socket6.bind(Socket.pack_sockaddr_in(port, '::'))
          rescue Errno::EADDRINUSE
            # if ipv6 is not available, then just use ipv4
          end

          @test_services[port] = { v4: socket4, v6: socket6 }
        end

        def stop_on(port)
          expect(@test_services).to have_key(port)

          socket4 = @test_services[port][:v4]
          socket4.close
          socket6 = @test_services[port][:v6]
          socket6.close
        end
      end
    end
  end
end
