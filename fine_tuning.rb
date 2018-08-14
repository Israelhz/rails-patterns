# FINE TUNING

# Faster queries
items = Item.where('due_at < ?', 2.days.from_now)
# This query returns all attributes from items
# But we can reduces the number of columns loaded from the database
# to select only the ones we need

items = Item.select(:id).where('due_at < ?', 2.days.from_now)

items.class => ActiveRecord::Relation::ActiveRecord_Relation_Item
items.first.class => Item(id: integer, name: string, due_at: datetime)

# Rails creates a different ActiveRecord object for each row returned from the database

item = Item.where('due_at < ?', 2.days.from_now).pluck(:id, :name)

# Returns an array of arrays
# [[31, "Chair"], [32, "Table"]]

# Pluck method is a great way to reduce application's memory footprint

# Filter sensitive parameters
# config/application.rb
config.filter_parameters += [:password, :ssh]

# prevents password and ssn from being added to the logs
Parameters: { "password" => "[FILTERED]", "ssn" => "[FILTERED]"}
