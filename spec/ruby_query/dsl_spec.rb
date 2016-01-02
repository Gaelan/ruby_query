require_relative '../spec_helper'
require 'pry-byebug'

describe RubyQuery::DSL do
  let(:query) { double(RubyQuery, keys: {}, predicates: {}) }
  let(:path) { %w(a b c) }
  let(:dsl) { RubyQuery::DSL.new(path) }

  it 'returns a sub-DSL when unknown methods are called' do
    expect(dsl.some_property_name).to be_a RubyQuery::DSL
  end

  it 'returns a sub-DSL when indexing' do
    expect(dsl[:some_property_name]).to be_a RubyQuery::DSL
  end

  it 'tracks the path of sub-DSLs' do
    expect(dsl.d.instance_variable_get :@path).to eq %w(a b c d)
  end

  describe '#==' do
    subject { dsl == 'foo' }
    it { is_expected.to be_a RubyQuery::Predicate::EqualTo }
    it { is_expected.to have_path path }
    it { is_expected.to have_value 'foo' }
  end

  # Other comparison operators are not tested, but they are almost identical so
  # if one works, others should too. We do, however, have high-level tests for
  # all operators.
end
