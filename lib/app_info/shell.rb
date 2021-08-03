# frozen_string_literal: true

require 'irb'

module AppInfo
  class Shell
    PREFIX = "app-info (#{AppInfo::VERSION})"

    PROMPT = {
      PROMPT_I: "#{PREFIX}> ",
      PROMPT_S: "#{PREFIX}> ",
      PROMPT_C: "#{PREFIX}> ",
      PROMPT_N: "#{PREFIX}> ",
      RETURN: "=> %s\n"
    }

    class << self
      def run
        setup

        irb = IRB::Irb.new
        irb.run
      end

      def setup
        IRB.setup nil

        IRB.conf[:PROMPT][:APPINFO] = PROMPT
        IRB.conf[:PROMPT_MODE] = :APPINFO
        IRB.conf[:AUTO_INDENT] = true
      end
    end
  end
end

