class ChangeTimestampsToMicrotime < ActiveRecord::Migration

  def setup
    @timestamp_columns = ['created_at', 'updated_at', 'added_at']
    @models = [
      Post # a model with :created_at, :updated_at,
           # and a manually managed :added_at field
           # that should also be migrated (See 
           # previous line).
    ]
  end

  def up
    setup
    iterate 'up'
  end

  def down
    setup
    iterate 'down'
  end

  private

  def iterate(direction)
    @models.each do |klass|
      model_columns = klass.columns_hash
      columns_to_update = @timestamp_columns.reject { |c| model_columns[c].nil? }
      table_name = klass.table_name
      columns_to_update.each do |column_name|
        column_data = klass.columns_hash[column_name]
        self.send("column_#{direction}", table_name, column_name, column_data)
      end
    end
  end

  # Mysql-specific!

  def column_up(table_name, column_name, column_data)

    if column_data.type == :datetime or (column_data.type == :integer and column_data.limit < 8)

      begin
        execute "ALTER TABLE `#{table_name}` ADD COLUMN #{column_name}_micro BIGINT(20)"
      rescue
        puts "#{table_name}.#{column_name}_micro exists."
        # it's safe to proceed. this is a temporary column.
      end

      if column_data.type == :datetime
        execute "UPDATE `#{table_name}` SET #{column_name}_micro = (UNIX_TIMESTAMP(#{column_name}) * 1000000)"
      elsif column_data.type == :integer and column_data.limit < 8 # exclude fields that are already microtime
        execute "UPDATE `#{table_name}` SET #{column_name}_micro = (#{column_name} * 1000000)"
      end

      execute "ALTER TABLE `#{table_name}` DROP COLUMN #{column_name}"
      execute "ALTER TABLE `#{table_name}` CHANGE #{column_name}_micro #{column_name} BIGINT(20)"
    end

  end

  def column_down(table_name, column_name, column_data)

    if column_data.type == :integer and column_data.limit >= 8
      begin
        execute "ALTER TABLE `#{table_name}` ADD COLUMN #{column_name}_macro DATETIME"
      rescue
        puts "#{table_name}.#{column_name}_macro exists."
        # it's safe to proceed. this is a temporary column.
      end

      execute "UPDATE `#{table_name}` SET #{column_name}_macro = (FROM_UNIXTIME(#{column_name} / 1000000))"
      execute "ALTER TABLE `#{table_name}` DROP COLUMN #{column_name}"
      execute "ALTER TABLE `#{table_name}` CHANGE #{column_name}_macro #{column_name} DATETIME"
    end

  end

end