require "test_helper"

class StaticControllerTest < ActionDispatch::IntegrationTest
  test "should get guide" do
    get static_guide_url
    assert_response :success
  end
end
