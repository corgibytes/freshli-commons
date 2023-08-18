# frozen_string_literal: true

module Corgibytes
  module Freshli
    module Commons
      # Contains helper methods for coping with platform specific differences
      module Platform
        def self.null_output_target
          Gem.win_platform? ? 'NUL:' : '/dev/null'
        end

        def self.normalize_file_separators(value)
          separator = File::ALT_SEPARATOR || File::SEPARATOR
          value.gsub('/', separator)
        end
      end
    end
  end
end
