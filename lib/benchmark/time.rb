module Benchmark
  module Time

    attr_reader :start_time, :end_time

    module ClassMethods
      def manage_timestamps list
        @items_name = list
      end

      def items_name
        @items_name
      end
    end

    def self.included(base)
      base.extend(ClassMethods)
    end

    def initialize opts={}
      self.instance_variable_set "@#{items_name}", []
      @start_time = Float::INFINITY
      @end_time = 0
    end

    def items_name
      self.class.items_name
    end

    def add_item item
      items << item

      if item.timestamp
        @start_time = item.timestamp if item.timestamp < @start_time
        @end_time = item.timestamp if item.timestamp > @end_time
      end

      items
    end

    def items
      self.instance_variable_get "@#{items_name}"
    end

    def items_at timestamp
      items.select {|i| i.timestamp == timestamp }
    end

    def trim start_time, end_time
      items.keep_if do |m|
        m.timestamp > start_time && m.timestamp < end_time
      end

      sorted = items.sort_by &:timestamp
      @start_time = sorted.first.timestamp
      @end_time = sorted.last.timestamp

      items
    end

    def total_minutes
      total_seconds/60
    end

    def total_seconds
      @end_time - @start_time
    end

  end
end
