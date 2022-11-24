class AirplaneSeatsController < ApplicationController
  def index
  end

  def create
    @seats = Seat.create_seat(params.require(:airplane_seat).permit(:seat_array))

    render json: @seats
  end
end
