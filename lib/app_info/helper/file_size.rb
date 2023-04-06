# frozen_string_literal: true

module AppInfo::Helper
  module HumanFileSize
    def file_to_human_size(file, human_size:)
      number = ::File.size(file)
      human_size ? number_to_human_size(number) : number
    end

    FILE_SIZE_UNITS = %w[B KB MB GB TB].freeze

    def number_to_human_size(number)
      if number.to_i < 1024
        exponent = 0
      else
        max_exp = FILE_SIZE_UNITS.size - 1
        exponent = (Math.log(number) / Math.log(1024)).to_i
        exponent = max_exp if exponent > max_exp
        number = Kernel.format('%<number>.2f', number: (number / (1024**exponent.to_f)))
      end

      "#{number} #{FILE_SIZE_UNITS[exponent]}"
    end
  end
end
