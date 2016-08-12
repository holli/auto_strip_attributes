module AutoStripAttributes
  module Matchers

    def auto_strip(*attrs)
      AutoStrip.new(attrs)
    end

    class AutoStrip

      attr_reader :attrs, :model, :descriptions, :failure_messages
      def initialize(attrs)
        @attrs = attrs
        @failure_messages = []
        @descriptions = ["auto strips attributes `#{attrs.join(', ')}`"]
      end

      def matches?(model)
        @model = model
        _examples.all? do |ex|
          execute_example(ex)
        end
      end

      def failure_message
        failure_messages.join(' ')
      end

      def description
        descriptions.join(' ')
      end

      def squish(bool = true)
        if bool
          _examples.append(['squ  ish', 'squ ish'])
        else
          _examples.append(['squ  ish', 'squ  ish'])
        end
        self
      end

      def examples(ary)
        descriptions << "with examples: `#{ary}`"
        @examples = ary
        self
      end

      def example(actual, expected)
        descriptions << "with example: `#{actual}` to `#{expected}`"
        @examples = [[actual, expected]]
        self
      end

      private

      def execute_example(example)
        attrs.each do |attribute|
          model.send("#{attribute}=", example[0])
        end
        model.valid?
        out = attrs.all? do |attribute|
                model.send(attribute) == example[1]
              end
        append_error(example) unless out
        out
      end

      def append_error(example)
        failure_messages << "change `#{example[0]}` to `#{example[1].nil? ? 'nil' : example[1]}`"
      end

      def _examples
        @examples ||= [
          [" aaa \t", 'aaa'],
          ['', nil]
        ]
      end
    end
  end
end
