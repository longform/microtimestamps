module MicroTimestamps

  module SchemaDefinitionExtensions

    def self.included(base)
      base.send :include, InstanceMethods
    end

    module InstanceMethods

      def microtimestamps(*args)
        options = { :null => false, :limit => 8 }.merge(args.extract_options!)
        column(:created_at, :integer, options)
        column(:updated_at, :integer, options)
      end

    end

  end

end

