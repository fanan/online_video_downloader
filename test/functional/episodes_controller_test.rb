require 'test_helper'

class EpisodesControllerTest < ActionController::TestCase
  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get parse" do
    get :parse
    assert_response :success
  end

  test "should get play" do
    get :play
    assert_response :success
  end

  test "should get download" do
    get :download
    assert_response :success
  end

  test "should get show" do
    get :show
    assert_response :success
  end

  test "should get destroy" do
    get :destroy
    assert_response :success
  end

end
