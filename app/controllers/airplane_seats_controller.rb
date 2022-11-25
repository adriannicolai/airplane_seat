class AirplaneSeatsController < ApplicationController
  def index
  end

  def create
    @seats = Seat.create_seat(params.require(:airplane_seat).permit(:seat_array, :passenger_count))

    render json: @seats
  end
end
