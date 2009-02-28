require 'test_helper'

class ProcessedSitesControllerTest < ActionController::TestCase
  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:processed_sites)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create processed_sites" do
    assert_difference('ProcessedSites.count') do
      post :create, :processed_sites => { }
    end

    assert_redirected_to processed_sites_path(assigns(:processed_sites))
  end

  test "should show processed_sites" do
    get :show, :id => processed_sites(:one).id
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => processed_sites(:one).id
    assert_response :success
  end

  test "should update processed_sites" do
    put :update, :id => processed_sites(:one).id, :processed_sites => { }
    assert_redirected_to processed_sites_path(assigns(:processed_sites))
  end

  test "should destroy processed_sites" do
    assert_difference('ProcessedSites.count', -1) do
      delete :destroy, :id => processed_sites(:one).id
    end

    assert_redirected_to processed_sites_path
  end
end
