
module MicroTimestamps

  # = Active Record Microsecond Timestamps
  #
  # Active Record automatically timestamps create and update operations if the
  # table has fields named <tt>created_at/created_on</tt> or
  # <tt>updated_at/updated_on</tt>.
  #
  # This module allows the default timestamps to be overridden with integers
  # representing the time since epoch in microseconds.
  #
  # Usage in the model:
  #
  # use_microtime_for :created_at, :updated_at

  module ActiveRecordExtensions

    extend ActiveSupport::Concern

    # Replace record_timestamps entirely

    included do
      self.record_timestamps = false if self.respond_to? :record_timestamps

      class_attribute :record_microtimestamps
      self.record_microtimestamps = true
    end

    module ClassMethods

      def use_microtime_for(*timestamps)
        @microtime_timestamps ||= []
        @microtime_timestamps += timestamps.collect { |t| t.to_s }
      end

      def microtime_timestamps
        @microtime_timestamps ||= []
        @microtime_timestamps.uniq
      end

    end

  private

    def create #:nodoc:
      if self.record_microtimestamps
        current_time = current_time_from_proper_timezone

        all_timestamp_attributes.each do |column|
          if respond_to?(column) && respond_to?("#{column}=") && self.send(column).nil?
            write_attribute(column.to_s, time_for(column.to_s, current_time))
          end
        end
      end

      super
    end

    def update(*args) #:nodoc:
      if should_record_microtimestamps?
        current_time = current_time_from_proper_timezone

        timestamp_attributes_for_update_in_model.each do |column|
          column = column.to_s
          next if attribute_changed?(column)
          write_attribute(column.to_s, time_for(column.to_s, current_time))
        end
      end
      super
    end

    def time_for(column, current_time)
      self.class.microtime_timestamps.include?(column) ? microtime_from(current_time) : current_time
    end

    def microtime_from(time)
      (time.to_f * 1000000.0).to_i
    end

    def should_record_microtimestamps?
      self.record_microtimestamps && (!partial_updates? || changed? || (attributes.keys & self.class.serialized_attributes.keys).present?)
    end
  end
end

