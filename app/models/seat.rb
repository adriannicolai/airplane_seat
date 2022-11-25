class Seat < ApplicationRecord
  self.abstract_class = true
  @airplane_seats = []
  @seat_number = 1

  class << self
    # DOCU: Validate if the seat is a two-dimensional array
    def validate_seat_array(seat_array)
      response_data = { status: false, result: {}, error: "" }

      begin
        # Check if the seat_array is an array first
        raise "Seat array must be an array" unless seat_array.is_a?(Array)
        raise "Seat must have at least 1 array" unless seat_array.length >= 1

        accepted_numbers = (1..9).to_a

        # Then check if the array is a multidimensional array
        # Check if the length of the array is 2
        # Check if the content of the arrays are both 1-9
        seat_array.each do |seats|
          raise "Seat must be a multidimensional array" unless seats.is_a?(Array)
          raise "Seats must contain only 2 values" unless seats.length === 2
          raise "rows (the first numbers) must only contain numbers 1 to 9" unless accepted_numbers.include?(seats.first)
          raise "columns (the second numbers) must only contain numbers 1 to 9" unless accepted_numbers.include?(seats.last)
        end

        # The status is true if the checking passed
        response_data[:status] = true
      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
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
          @airplane_seats << temporary_seat
        end

        # There are possible 3 scenarios in filling up the seats depending on the number of group of seats
        # 1 - there is only 1 group of seats
        # 2 - there are 2 group of seats
        # 3 - there are 3 or more group of seats
        # TODO: Will refactor this later when I have time
        case seat_array[:result].length
        when 1
          # code when 1 group of seats
        when 2
          # Code when 2 group of seats
        else
          fill_aisle_seats_scenario_3(response_data)
        end

      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
    end

    def fill_aisle_seats_scenario_3(response_data)
      begin
        airplane_seats_row_count = @airplane_seats.length
        current_column_height    = 0
        p @airplane_seats
        @airplane_seats.each_with_index do |airplane_seat_group, airplane_seats_index|
          # Checker for the height of array/seat
          p  "================"
          p  "================"
          p airplane_seat_group
          p "================"
          p "================"
            # if airplane_seat_group.length >= current_column_height
            #   if airplane_seats_index === 0

            #   elsif airplane_seats_index === airplane_seats_row_count

            #   else

            #   end
            # end

          current_column_height = index
        end

      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
    end
  end
end
