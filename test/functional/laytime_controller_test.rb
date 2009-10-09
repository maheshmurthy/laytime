require 'test_helper'

class LaytimeControllerTest < ActionController::TestCase
  # Replace this with your real tests.
  test "the truth" do
    assert true
  end

  test "index" do
    get :index
    assert_response :success
  end
end
