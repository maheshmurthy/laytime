require 'test_helper'

class UsersControllerTest < ActionController::TestCase
  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create user" do
    assert_difference('User.count') do
      post :create, :user => Factory.attributes_for(:user)
    end
  end

#  test "should show user" do
#    get :show, :id => users(:one).to_param
#    assert_response :success
#  end

#  test "should get edit" do
#    get :edit, :id => users(:one).to_param
#    assert_response :success
#  end

#  test "should update user" do
#    put :update, :id => users(:one).to_param, :user => { :username => 'mahesh',
#                                                         :email => 'mahesh@mmurthy.com'}

#    assert_redirected_to user_path(assigns(:user))
#  end

  test "should destroy user" do
    user = Factory.create(:user)
    assert_difference('User.count', -1) do
      delete :destroy, :id => user.to_param
    end

    assert_redirected_to users_path
  end
end
