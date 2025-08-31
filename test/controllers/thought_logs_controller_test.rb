require "test_helper"

class ThoughtLogsControllerTest < ActionDispatch::IntegrationTest
  setup do
    @user = users(:one) # fixturesを使ってるならここを調整
    sign_in @user
    @passage = passages(:one) # fixturesのPassage
  end

  test "should get new" do
    get new_passage_thought_log_url(@passage)
    assert_response :success
  end
end