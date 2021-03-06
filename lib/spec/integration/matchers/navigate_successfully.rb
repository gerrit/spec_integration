module Spec
  module Integration
    module Matchers
      
      class NavigateSuccessfully #:nodoc:
        def initialize(where)
          @where = where
        end
        
        def matches?(example)
          if example.response.error? || example.response.body =~ /Exception caught/
            @failure_message = extract_exception(example)
          elsif example.response.missing?
            @failure_message = "Missing document #{example.request.method}'ing #{@where}"
          end
          @failure_message.nil?
        end
        
        def failure_message
          @failure_message
        end
        
        def negative_failure_message
          "expected failure navigating #{@where}"
        end
        
        private
          def extract_exception(example)
            exception = example.controller.rescued_exception
            message = "Unexpected #{example.response.response_code} error #{example.request.method}'ing #{@where}\n#{exception.message}"
            if exception.respond_to? :line_number
              message << "\nOccurred on line #{exception.line_number} in #{exception.file_name}"
            else
              backtrace = Spec::Runner::QuietBacktraceTweaker.new.tweak_backtrace(example.controller.rescued_exception)
              message << "\n#{backtrace * "\n"}"
            end
          end
      end
      
      # Specify that a response should be a good one: successful, not missing,
      # no server errors, etc. This is used internally by
      # Spec::Integration::DSL::NavigationExampleMethods, made available to
      # you for good pleasure.
      def have_navigated_successfully(where = request.request_uri)
        NavigateSuccessfully.new(where)
      end
      
    end
  end
end