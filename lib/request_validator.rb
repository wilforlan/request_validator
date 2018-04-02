# This Gem help validate request parameters before
# they hit the models. Why do we need to validate
# in ActiveModel ? 
#
# Author::    Williams Isaac  (mailto:williamscalg@gmail.com)
# License::   MIT

# This Validator class holds all the method for our operation

class Validator
    require 'config/config'
    
    # Initialize the Validator.new and sets injected_params to
    # to be remembered thoughout the cause of operation
    #
    # @param params [Hash] value to be remembered
    # @return [Object] instance of class Validator
    #

    def initialize(params = {})
        @response = {
            has_errors: false,
            errors: []
        }
        @injected_params = params
    end

    # Returns new instance of configuration
    # @return [Object] instance of class Configuration
    #
    
    def self.configure
        @config ||= Configuration.new
        yield(@config) if block_given?
        @config
    end

    def config
        @config || Validator.configure
    end
    
    def validate(object, checks)
        raise ArgumentError, 'Object cannnot be empty' unless !object.empty? || config.skip_main_object_empty
        checks.each_pair do |key, againsts|
            res = @@functions_hash[againsts]
            if res.nil?
                next if config.error_mode == 'surpressed'
                raise ArgumentError, "Invalid identifier - #{againsts} - Corresponding method not found"
            end
            res = res.call(object[key], key)
            if !res[:valid]
                p res[:error] 
                @response[:errors] << res[:error] 
            end
        end
        @response[:has_errors] = @response[:errors].length > 0 ? true : false
        @response
    end

    def check(key)
        @value = @injected_params[key]
        @key = key
        self
    end

    def withMessage(message)
        @custom_error_message = message
    end

    def notEmpty
        @response[:errors] << message_composer(@key, "cannot be empty")  if @value.length < 1
        self
    end

    def isEmail
        check = (@value =~ /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/).nil?
        @response[:errors] << message_composer(@key, "is not a valid email address")  if check
        self
    end

    def isString
        check = !(@value =~ /[^a-zA-Z0-9]/).nil?
        @response[:errors] << message_composer(@key, "is not a valid string")  if check
        self
    end

    def isIn(arr)
        check = arr.include? @value
        @response[:errors] << message_composer(@key, "is not a valid option")  if !check
        self
    end

    def isArray
        check = @value.kind_of?(Array)
        @response[:errors] << message_composer(@key, "must be an array")  if !check
        self
    end

    def validUrl
        check = (@value =~ /^(http|https):\/\/[a-z0-9]+([\-\.]{1}[a-z0-9]+)*\.[a-z]{2,5}(:[0-9]{1,5})?(\/.*)?$/ix).nil?
        @response[:errors] << message_composer(@key, "is not a valid url")  if check
        self
    end

    def result
        @response[:has_errors] = @response[:errors].length > 0 ? true : false
        @response
    end

    # Structure
    # *********************************************
    # Returns
    # {
    #     valid: Boolean,
    #     error: String,
    #     checked: String
    # }

    private
        check_string = lambda { | value, key | 
            check = (value =~ /[^a-zA-Z0-9]/).nil?
            return {
                valid: check,
                error: check ? nil : "#{key} is not a valid string",
                checked: value
            }
        }
            
        check_email = lambda { | value, key| 
            # http://www.rubydoc.info/stdlib/uri/URI/MailTo
            check = (value =~ /\A[a-zA-Z0-9.!\#$%&'*+\/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*\z/)
            return {
                valid: check,
                error: check ? nil : "#{key} is not a valid email address",
                checked: value
            }
        }
            
        check_number = lambda { | value, key | 
            check = (value =~ /\A[-+]?[0-9]*\.?[0-9]+\Z/).nil?
            return {
                valid: check,
                error: check ? nil : "#{key} is not a valid number",
                checked: value
            }
        }
        
        @@functions_hash = {
            'string' => check_string,
            'email' => check_email,
            'number' => check_number
        }

        def message_composer(key, default_msg)
            if @custom_error_message
                "#{key} #{@custom_error_message}"
            else
                "#{key} #{default_msg}"
            end
        end

end
