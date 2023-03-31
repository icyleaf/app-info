# frozen_string_literal: true

# require 'stringio'
# require 'openssl'

# module AppInfo
#   module Android
#     module Signature
#       module BlockUtil
#         def length_prefix_block(io, raw: false)
#           offset = io.size - io.pos
#           AppInfo.logger.debug "source full size #{io.size}, pos #{io.pos}, offset #{offset}"
#           if offset < 4
#             raise SecurityError,
#                   'Remaining buffer too short to contain length of length-prefixed field.'
#           end

#           size = io.read(4).unpack1('I')
#           raise SecurityError, 'Negative length' if size.negative?

#           if size > io.size
#             raise SecurityError,
#                   "Underflow while reading length-prefixed value. \
#                   length: #{size}, remaining: #{io.size}"
#           end

#           raw_data = io.read(size)
#           raw ? raw_data : StringIO.new(raw_data)
#         end
#       end
#     end
#   end
# end
