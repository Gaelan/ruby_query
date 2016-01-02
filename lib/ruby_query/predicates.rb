module RubyQuery
  # A predicate is a limitation on the results to a query. There is roughly one
  # predicate class per Mongo $keyword.
  class Predicate
    def to_mongo
      fail NotImplementedError,
           "Predicate #{self.class.name} doesn't implement to_mongo"
    end

    def |(other)
      Or.new self, other
    end

    def &(other)
      And.new self, other
    end

    def !
      Not.new self
    end

    # The base class for simple predicates that apply to one property (equal to,
    # greater than, etc.)
    class PropertyPredicate < Predicate
      def initialize(path, value)
        @path = path
        @value = value
      end

      # Override this to customize. See ContainsArrayElementMatching.
      def mongo_value
        value
      end

      def self.mongo_name(name)
        define_method :core_mongo_predicate do
          { '$' + name.to_s => mongo_value }
        end
      end

      def to_mongo
        if path.empty?
          core_mongo_predicate
        else
          { path.join('.') => core_mongo_predicate }
        end
      end

      def has_value?(a_value) # rubocop:disable Style/PredicateName
        value == a_value
      end

      def has_path?(a_path) # rubocop:disable Style/PredicateName
        path == a_path
      end

      private

      attr_reader :path, :value
    end

    # The base class for predicates that apply to one or more other predicates
    # (or, and, nor).
    class LogicalPredicate
      def initialize(*predicates)
        @predicates = predicates
      end

      def self.mongo_name(name)
        define_method :to_mongo do
          { "$#{name}" => predicates.map(&:to_mongo) }
        end
      end

      private

      attr_reader :predicates
    end

    # rubocop:disable Style/Documentation
    class EqualTo < PropertyPredicate; mongo_name :eq; end
    class GreaterThan < PropertyPredicate; mongo_name :gt; end
    class GreaterThanOrEqualTo < PropertyPredicate; mongo_name :gte; end
    class LessThan < PropertyPredicate; mongo_name :lt; end
    class LessThanOrEqualTo < PropertyPredicate; mongo_name :lte; end
    class NotEqualTo < PropertyPredicate; mongo_name :ne; end
    class MatchingRegex < PropertyPredicate; mongo_name :regex; end
    class Or < LogicalPredicate; mongo_name :or; end
    class And < LogicalPredicate; mongo_name :and; end
    class KeyIsDefined < PropertyPredicate
      mongo_name :exists
      def path
        @path + [value]
      end

      def mongo_value
        true
      end
    end
    class Not
      def initialize(predicate)
        @predicate = predicate
      end

      def to_mongo
        { '$not' => predicate.to_mongo }
      end

      private

      attr_reader :predicate
    end
    class ContainsArrayElementMatching < PropertyPredicate
      mongo_name :elemMatch
      def mongo_value
        value.to_mongo
      end
    end
    # rubocop:enable Style/Documentation
  end
end
