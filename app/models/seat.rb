class Seat < ApplicationRecord
  self.abstract_class = true
  @seat = []

  class << self
    # DOCU: Valnm  idate if the seat is a two-dimensional array
    def validate_seat_array(seat_array)
      response_data = { status: false, result: {}, error: "" }

      begin
        # Check if the seat_array is an array first
        raise "Seat array must be an array" unless seat_array.is_a?(Array)
        raise "Seat must have at least 1 array" unless seat_array.size >= 1

        accepted_numbers = (1..9).to_a

        # Then check if the array is a multidimensional array
        # Check if the length of the array is 2
        # Check if the content of the arrays are both 1-9
        seat_array.each do |seats|
          raise "Seat must be a multidimensional array" unless seats.is_a?(Array)
          raise "Seats must contain only 2 values" unless seats.size === 2
          raise "rows (the first numbers) must only contain numbers 1 to 9" unless accepted_numbers.include?(seats.first)
          raise "columns (the second numbers) must only contain numbers 1 to 9" unless accepted_numbers.include?(seats.last)
        end

        # The status is true if the checking passed
        response_data[:status] = true
      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      return response_data
    end

    # DOCU: create a new seat, this will create the template for the seat
    def create_seat(params)
      response_data = { status: false, result: {}, error: "" }

      begin
        # Check if user added is json parsable
        seat_array = valid_json?(params["seat_array"])
        raise seat_array[:error] unless seat_array[:status]

        # Validate the seat array if it is on the correct format (multi dimensional array with 2 values)
        validate_seat_array = validate_seat_array(seat_array[:result])
        raise validate_seat_array[:error] if validate_seat_array[:error].present?

        # Then create the seats the input is valid
        seat_array[:result].each_with_index do |seat_settings, index|
          temporary_seat = []
          rows      = seat_settings.first
          columns   = seat_settings.last
          row_array = []

          # Create rows and columns
          until columns === 0 do
            until rows === 0 do
              row_array << 0
              rows -= 1
            end

            temporary_seat << row_array
            columns -= 1
          end

          # put the temporary seat in the seats variable
          @seat << temporary_seat
        end

        @seat
      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      return response_data
    end
  end
end
