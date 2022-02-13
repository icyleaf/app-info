# frozen_string_literal: true

module AppInfo
  module Inflector
    def ai_snakecase
      gsub(/([A-Z]+)([A-Z][a-z])/, '\1_\2')
        .gsub(/([a-z\d])([A-Z])/, '\1_\2')
        .tr('-', '_')
        .gsub(/\s/, '_')
        .gsub(/__+/, '_')
        .downcase
    end

    def ai_camelcase(first_letter: :upper, separators: ['-', '_', '\s'])
      str = dup

      separators.each do |s|
        str = str.gsub(/(?:#{s}+)([a-z])/) { $1.upcase }
      end

      case first_letter
      when :upper, true
        str = str.gsub(/(\A|\s)([a-z])/) { $1 + $2.upcase }
      when :lower, false
        str = str.gsub(/(\A|\s)([A-Z])/) { $1 + $2.downcase }
      end

      str
    end
  end
end

class String
  include AppInfo::Inflector
end
