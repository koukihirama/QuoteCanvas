require "test_helper"

class ThoughtLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
  @user = users(:alice)
  sign_in @user
  @passage = passages(:one) # passages(:one) は fixtures で user: alice なので整合OK
end

  test "should get new" do
    get new_passage_thought_log_url(@passage)
    assert_response :success
  end
end
