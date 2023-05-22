# frozen_string_literal: true

module Sprockets
  class CustomCompressor
    COMMENT_START = '/'
    SINGLE_LINE_COMMENT = '/'
    MULTI_LINE_COMMENT = '*'
    MULTI_LINE_COMMENT_END = '*/'
    END_LINE = "\n"

    def self.instance
      @instance ||= new
    end

    def self.call(input)
      instance.call(input)
    end

    def self.cache_key
      instance.cache_key
    end

    attr_reader :cache_key, :offset

    def initialize(options = {})
      @options = options
      @cache_key = "#{self.class.name}:#{DigestUtils.digest(options)}".freeze
      @offset = 0
    end

    def call(input)
      data = input[:data]

      compress(data)
    end

    private

    def compress(data)
      result = []
      tokens = data.chars
      length = tokens.length

      while offset < length
        token = tokens[offset]

        case token
        when COMMENT_START
          if tokens[offset+1] == SINGLE_LINE_COMMENT
            process_single_line_comment(tokens)
          elsif tokens[offset+1] == MULTI_LINE_COMMENT
            process_multi_line_comment(tokens)
          else
            result << token
            @offset += 1
          end
        else
          result << token
          @offset += 1
        end
      end

      result.join
    end

    def process_single_line_comment(tokens)
      @offset += 2
      index = offset

      loop do
        break if tokens[index] == END_LINE

        index += 1
        @offset += 1
      end
    end

    def process_multi_line_comment(tokens)
      @offset += 2
      index = offset

      loop do
        break if tokens[index..index+1].join == MULTI_LINE_COMMENT_END

        index += 1
        @offset += 1
      end

      @offset += 2
    end
  end
end
