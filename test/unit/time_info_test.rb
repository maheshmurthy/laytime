require 'test_helper'

class TimeInfoTest < ActiveSupport::TestCase
  # Replace this with your real tests.
  test "the sum of two timeinfos is correct" do
    one = TimeInfo.new(:days => 5, :hours => 5, :mins => 45)
    two = TimeInfo.new(:days => 7, :hours => 22, :mins => 55)
    total = one.add(two)
    assert_equal 13, total.days
    assert_equal 4, total.hours
    assert_equal 40, total.mins
  end

  test "the diff of two timeinfos is correct" do
    two = TimeInfo.new(:days => 7, :hours => 2, :mins => 45)
    one = TimeInfo.new(:days => 5, :hours => 15, :mins => 55)
    diff = two.diff(one)
    assert_equal 1, diff.days
    assert_equal 10, diff.hours
    assert_equal 50, diff.mins
  end

  test "diff is absolute" do
    two = TimeInfo.new(:days => 7, :hours => 2, :mins => 45)
    one = TimeInfo.new(:days => 5, :hours => 15, :mins => 55)
    diff = one.diff(two)
    assert_equal 1, diff.days
    assert_equal 10, diff.hours
    assert_equal 50, diff.mins
  end

  test "convert time info to mins" do
    two = TimeInfo.new(:days => 7, :hours => 2, :mins => 45)
    assert_equal 10245, two.to_mins
  end

end
