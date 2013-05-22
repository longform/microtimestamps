require 'microtimestamps/activerecord_extensions'
require 'microtimestamps/schema_definition_extensions'
require 'microtimestamps/time_extensions'

ActiveRecord::Base.send(:include, MicroTimestamps::ActiveRecordExtensions)
ActiveRecord::ConnectionAdapters::TableDefinition.send(:include, MicroTimestamps::SchemaDefinitionExtensions)
Time.send(:include, MicroTimestamps::TimeExtensions)