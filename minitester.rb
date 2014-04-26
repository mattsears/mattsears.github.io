require 'minitest/autorun'
require 'minitest/pride'
require 'date'

class Hipster
  def destroy!
  end

  def trendy?(time)
    puts "##################### #{time}  #{DateTime.now - 14}"
    time >= (DateTime.now - 14)
  end
end

# Test the Spec side of Minitest
describe Array, "Demonstration of " do

  # Executes before anything
  before do
    puts "running code in a before block!"
    @hipster = Hipster.new
  end

  # Runs after test suite is complete
  after do
    puts "running code after!"
    @hipster.destroy!
  end

  subject { Hipster.new }

  let(:traits) { ["silly hats", "skinny jeans"] }

  let(:labels) { Array.new }

  it 'should flunk' do
    # flunk "Epic fail!"
  end

  it 'pass' do
    pass "This should always pass"
  end

  it 'should skip' do
    skip "Need to debug this..."
  end

  it 'must return username' do
    traits.size.must_equal 2
    traits.must_include "skinny jeans"
    traits.size.must_be_within_delta  1,1
    traits.size.must_be_close_to 1,1
    traits.size.must_be_within_epsilon 1,1
    labels.must_be_empty
    subject.must_be_instance_of Hipster
    traits.must_be_kind_of Enumerable
    labels.first.must_be_nil
    traits.size.must_be :==, 2
    traits.first.must_match /silly hats/
    proc { print "#{traits.size}!" }.must_output "2!"
    proc { "no stdout or stderr" }.must_be_silent
    proc { traits.foo }.must_raise NoMethodError
    traits.must_respond_to :count
    traits.must_be_same_as traits
    traits.must_send [traits, :values_at, 0]
    proc { throw Exception if traits.any? }.must_throw Exception
  end
end


# The Unit side of Minitest
class TestUser < MiniTest::Unit::TestCase

  def setup
    @people = Array.new
    @subject = ["skinny jeans", "silly hat"]
  end

  def teardown
    puts "runs after everyhting"
  end

  def test_skip
    skip
  end

  def test_flunk
    #flunk
  end

  def test_stuff
    assert @subject.any?, "contains names"
    assert_equal @subject.size, 2
    assert_includes @subject, "skinny jeans"
    assert_in_delta @subject.size, 1, 1
    assert_in_epsilon @subject.size, 1, 1
    assert_empty @people
    assert_instance_of Array, @people
    assert_kind_of Enumerable, @people
    assert_nil @people.first
    assert_operator @people.size, :== , 0
    assert_match /skinny jeans/, @subject.first
    assert_output ("Size: 2") { print "Size: #{@subject.size}" }
    assert_silent { "Size: #{@subject.size}" }
    assert_raises (NoMethodError) { @subject.foo }
    assert_respond_to @subject, :count
    assert_same @subject, @subject, "It's the same object silly"
    assert_send [@subject, :values_at, 0]
    assert_throws (:done) { throw :done if @subject.any? }
    # assert_block { @subject.any? }
  end

end

# Makes all of our Twitter updates coolj
class Twipster
  def initialize(twitter)
    @twitter = twitter
  end

  def tweet(message)
    @twitter.update("#{message} #lolhipster")
  end

  def follower(name)
    return unless @twitter.followers_count > 100000

    @twitter.follow(name)
  end
end

# Try out the Mock features
describe Twipster, "Make every tweet a hipster tweet." do

  before do
    @twitter = MiniTest::Mock.new
  end

  let(:twipster){ Twipster.new(@twitter)}
  let(:message){ "Skyrim? Too mainstream." }

  it "should append a #lolhipster hashtag and updates Twitter status" do
    @twitter.expect :update, true, ["#{message} #lolhipster"]
    twipster.tweet(message)

    assert @twitter.verify
  end

end

describe Hipster, "Demonstrates stubbing with Minitest" do

  let(:hipster) { Hipster.new }

  it "trendy if time is now" do
    assert hipster.trendy? DateTime.now
  end

  it "it is NOT trendy if 2 weeks has past" do
    DateTime.stub :now, (Date.today.to_date - 15) do
      refute hipster.trendy? DateTime.now
    end
  end
end
