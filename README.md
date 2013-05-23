## Microsecond Timestamps for ActiveRecord

This gem allows regular magic `DateTime` timestamps on
ActiveRecord models to be overridden with microsecond
timestamps. It is currently only compatible with the MySQL
connection adaptor, and rails <= 3.2.13.

Because MySQL < 5.6 has no native support for microseconds
(or milliseconds), the timestamp is stored as a `BIGINT(20)`
representing microseconds since the Unix epoch. Alternative
formats such as `DECIMAL` are not supported.

In ActiveRecord, this translates to `Bignum`, and the column
is represented in the schema as `:integer, :limit => 8`.

There is no automatic conversion from the integer representation
and a `Time` instance. This is left up to the app. However,
the gem does provide a `to_microseconds` method on Ruby's `time`
class to make converting time to integer microseconds easier.

Microsecond timestamps should be specified on any model that
uses them with (for example):

`use_microtime_for :created_at, :updated_at`

Any model that does not declare `use_microtime_for` will
fall back to ActiveRecord's regular timestamps.

### Migrations

A `microtimestamps` migration helper is provided:

```
class CreateSomeModel < ActiveRecord::Migration
  def up
    create_table :some_model_table, :force => true do |t|
      ...
      t.microtimestamps
    end
  end
end
```

This adds the usual `created_at` and `updated_at` columns
in the microsecond timestamp format. It only supports MySQL.
Don't forget to specify `use_microtime_for` on the model,
or you'll end up with seconds in the database instead of microseconds,
which is bad.

See examples/migration.rb for an example of migrating from
regular timestamps to microtimestamps.

## Implementation Details

The gem sets `ActiveRecord::record_timestamps = false` 
globally and declares `ActiveRecord::record_microtimestamps = true`.
This has the effect of turning off native automatic timestamps entirely,
and handing over all control of timestamps to microtimestamps. This
could interfere with any other code that depends on explicitly
controlling the `ActiveRecord::record_timestamps` setting.
