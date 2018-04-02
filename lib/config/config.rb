class Configuration
    attr_accessor :skip_main_object_empty, :error_mode

    def initialize
        @skip_main_object_empty = false
        @error_mode = 'strict'
    end

    def [](value)
        self.public_send(value)
    end
end
