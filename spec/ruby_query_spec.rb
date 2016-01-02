require_relative 'spec_helper'

describe 'RubyQuery' do
  it 'supports $eq queries' do
    # XXX Use {'name': 'Foo'} shorthand?
    expect(RubyQuery.mongo { |person| person.name == 'Foo' })
      .to eq('name' => { '$eq' => 'Foo' })
  end
  it 'supports $gt queires' do
    expect(RubyQuery.mongo { |person| person.age > 5 })
      .to eq('age' => { '$gt' => 5 })
  end
  it 'supports $gte queires' do
    expect(RubyQuery.mongo { |person| person.age >= 5 })
      .to eq('age' => { '$gte' => 5 })
  end
  it 'supports $lt queries' do
    expect(RubyQuery.mongo { |product_type| product_type.price_range.max < 5 })
      .to eq('price_range.max' => { '$lt' => 5 })
  end
  it 'supports $lte queries' do
    expect(RubyQuery.mongo { |product_type| product_type.price_range.max <= 5 })
      .to eq('price_range.max' => { '$lte' => 5 })
  end
  it 'supports $ne predicates' do
    expect(RubyQuery.mongo { |product| product.manufacturer != 'Somecorp' })
      .to eq('manufacturer' => { '$ne' => 'Somecorp' })
  end # XXX Consider making ! == become $ne as well.

  it 'supports $elemMatch via #include?' do
    expect(RubyQuery.mongo { |product| product.tags.include? 'some-tag' })
      .to eq('tags' => { '$elemMatch' => { '$eq' => 'some-tag' } })
  end

  # XXX $in (item is one of these items, array containts any one of these items)
  # - how would these be expressed in idiomatic Ruby? Should we have custom
  # methods for them?

  it 'supports $or queries' do
    expect(RubyQuery.mongo do |person|
      (person.name == 'John') | (person.name == 'Joe')
    end).to eq('$or' => [
      { 'name' => { '$eq' => 'John' } },
      { 'name' => { '$eq' => 'Joe' } }
    ])
  end
  # XXX This example could be optimised to a $in. At some point, that might be
  # worth implementing. If so, we would need to use an example involving other
  # operators to demonstrate this.

  it 'supports $and queries' do
    expect(RubyQuery.mongo do |person|
      (person.name == 'John') & (person.age < 18)
    end).to eq('$and' => [
      { 'name' => { '$eq' => 'John' } },
      { 'age' => { '$lt' => 18 } }
    ])
  end
  # XXX The $and here is unnecessary, as the two keys don't conflict. It would
  # be good to remove the $and at some point, as well as adding a new test that
  # DOES require $and.

  # XXX Currently, predicate1 & predicate2 & predicate3 all will generate a
  # nested $and. Eventually, this could become one array. Same with $or.

  it 'supports $not queries' do
    expect(RubyQuery.mongo { |person| !(person.age < 18) })
      .to eq '$not' => { 'age' => { '$lt' => 18 } }
  end

  it 'supports $exists queries' do
    expect(RubyQuery.mongo { |person| person.key? :age })
      .to eq 'age' => { '$exists' => true }
  end

  # XXX Support for $type

  # XXX Support for $mod

  it 'supports $regex queries' do
    expect(RubyQuery.mongo { |person| person.name =~ /tables/ })
      .to eq 'name' => { '$regex' => /tables/ }
  end

  # XXX Support for $text

  # XXX Support for $where (use Opal?)

  # XXX Support for Geospatial operators

  # XXX Is there a Ruby equivelent to $all (array contains all of these
  # elements), or should it just be an optimization of #include? & #include?

  it 'supports $elemMatch queries via #any?' do
    expect(RubyQuery.mongo do |person|
      person.friends.any? { |friend| friend.name == 'Joe' }
    end).to eq 'friends' => { '$elemMatch' => { 'name' => { '$eq' => 'Joe' } } }
  end # XXX In cases where there is only one predicate, the $elemMatch can be
  # omitted, using the predicate as the value. At some point, we should support
  # this.

  # XXX Support for $size

  # XXX Support for bitwise operators

  # XXX Support for projection
end
