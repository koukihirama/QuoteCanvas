require "test_helper"

class DashboardControllerTest < ActionDispatch::IntegrationTest
  def setup
    # Confirmable を使ってる場合に備えて confirmed_at を入れておくと安全
    @user = User.create!(
      email: "tester@example.com",
      password: "password123",
      name: "テスター",
      confirmed_at: Time.current # Confirmable無効ならこの列がなくてもOK
    )
  end

  test "未ログインならサインインにリダイレクト" do
    get dashboard_url
    assert_response :redirect
    assert_redirected_to new_user_session_url
  end

  test "ログイン済みなら200で表示" do
    sign_in @user
    get dashboard_url
    assert_response :success
  end
end
