require "test_helper"

class SummariesControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get summaries_index_url
    assert_response :success
  end

  test "should get show" do
    get summaries_show_url
    assert_response :success
  end

  test "should get edit" do
    get summaries_edit_url
    assert_response :success
  end
end
