require 'active_support/core_ext/hash/keys'
require 'active_support/core_ext/hash/transform_values'
require 'ruby_query/dsl'

# The main RubyQuery module. Provides simple wrappers for creating queries.
module RubyQuery
  def self.mongo
    yield(DSL.new).to_mongo
  end
end
