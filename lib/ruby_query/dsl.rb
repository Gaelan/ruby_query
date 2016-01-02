require 'ruby_query/predicates'

module RubyQuery
  # The DSL for a query. This is the object passed to RubyQuery.mongo blocks.
  class DSL # XXX Consider inheriting from BasicObject.
    attr_reader :path
    def initialize(path = [])
      @path = path
    end

    def method_missing(name)
      # Stuff breaks if we return something other than an array.
      super if name == :to_ary
      # Treating DSLs as predicates causes odd bugs. Let's not let that happen.
      super if name == :to_mongo
      self[name]
    end

    class << self
      private

      def predicate(name, predicate_class)
        define_method name do |value|
          predicate_class.new path, value
        end
      end
    end

    def [](name)
      self.class.new path + [name.to_s]
    end

    predicate :==,       Predicate::EqualTo
    predicate :>,        Predicate::GreaterThan
    predicate :>=,       Predicate::GreaterThanOrEqualTo
    predicate :<,        Predicate::LessThan
    predicate :<=,       Predicate::LessThanOrEqualTo
    predicate :!=,       Predicate::NotEqualTo
    predicate :key?,     Predicate::KeyIsDefined
    predicate :=~,       Predicate::MatchingRegex

    def any?
      Predicate::ContainsArrayElementMatching.new(path, (yield DSL.new))
    end

    def include?(value)
      any? { |it| it == value }
    end
  end
end
