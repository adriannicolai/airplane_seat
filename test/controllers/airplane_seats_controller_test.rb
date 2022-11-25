require "test_helper"

class AirplaneSeatsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get airplane_seats_index_url
    assert_response :success
  end
end
