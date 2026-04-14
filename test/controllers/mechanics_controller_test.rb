require "test_helper"

class MechanicsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get mechanics_index_url
    assert_response :success
  end

  test "should get show" do
    get mechanics_show_url
    assert_response :success
  end

  test "should get new" do
    get mechanics_new_url
    assert_response :success
  end

  test "should get edit" do
    get mechanics_edit_url
    assert_response :success
  end
end
