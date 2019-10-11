# frozen_string_literal: true

module AppInfo
  # AppInfo Util
  module Util
    FILE_SIZE_UNITS = %w[B KB MB GB TB].freeze

    def self.file_size(file, humanable)
      file_size = File.size(file)
      humanable ? size_to_humanable(file_size) : file_size
    end

    def self.size_to_humanable(number)
      if number.to_i < 1024
        exponent = 0
      else
        max_exp = FILE_SIZE_UNITS.size - 1
        exponent = (Math.log(number) / Math.log(1024)).to_i
        exponent = max_exp if exponent > max_exp
        number = format('%<number>.2f', number: (number / (1024**exponent.to_f)))
      end

      "#{number} #{FILE_SIZE_UNITS[exponent]}"
    end
  end
end
