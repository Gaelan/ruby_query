require_relative '../spec_helper'

RSpec.shared_examples 'predicate' do
  it 'can be converted into a mongo query' do
    expect(predicate.to_mongo).to be_a Hash
  end
end

describe RubyQuery::Predicate do
  it "can be or'd with other predicates" do
    expect(RubyQuery::Predicate.new | RubyQuery::Predicate.new)
      .to be_a RubyQuery::Predicate::Or
  end
end

describe RubyQuery::Predicate::EqualTo do
  subject(:predicate) do
    RubyQuery::Predicate::EqualTo.new %w(name first), 'foo'
  end
  it { is_expected.to have_value 'foo' }
  it { is_expected.not_to have_value 7 }
  it { is_expected.to have_path %w(name first) }
  it { is_expected.not_to have_path %w(name last) }
  it_behaves_like 'predicate'
  it 'creates an equality query' do
    expect(predicate.to_mongo).to eq 'name.first' => { '$eq' => 'foo' }
  end
end

describe RubyQuery::Predicate::Or do
  let(:p1) { double(RubyQuery::Predicate, to_mongo: :p1) }
  let(:p2) { double(RubyQuery::Predicate, to_mongo: :p2) }
  subject(:predicate) do
    RubyQuery::Predicate::Or.new p1, p2
  end
  it 'creates an or query' do
    expect(predicate.to_mongo).to eq '$or' => [:p1, :p2]
  end
end

describe RubyQuery::Predicate::Or do
  let(:p1) { double(RubyQuery::Predicate, to_mongo: :p1) }
  subject(:predicate) do
    RubyQuery::Predicate::Not.new p1
  end
  it 'creates an or query' do
    expect(predicate.to_mongo).to eq '$not' => :p1
  end
end

# Other comparison predicates are not tested, but they are almost identical so
# if one works, others should too. We do, however, have high-level tests for all
# predicates.
