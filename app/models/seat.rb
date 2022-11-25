class Seat < ApplicationRecord
  self.abstract_class = true

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
        # destructure the params to get the seat array
        passenger_count,  = params.values_at(:passenger_count)

        create_seat_parameters = { seat_number: 1, passenger_count: passenger_count, airplane_seats: []}

        # Check if the passenger count is valid
        raise "The passenger count is required" unless passenger_count.present?
        raise "The passenger count should be an integer" if (passenger_count =~ /^\d+$/) === nil
        raise "The passenger count should be greater than 0" unless passenger_count.to_i > 0
        passenger_count = passenger_count.to_i

        # Check if user added is a valid json string
        raise "The seat array is required" unless params[:seat_array].present?
        seat_array = valid_json?(params[:seat_array]) # valid_json? is found in application_record.rb
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
          create_seat_parameters[:airplane_seats] << temporary_seat
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
          fill_aisle_seats_scenario_3(response_data, create_seat_parameters)
        end

      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
    end

    def fill_aisle_seats_scenario_3(response_data, create_seat_parameters)
      begin
        # Destructure create_seat_parameters
        seat_number, passenger_count, airplane_seats = create_seat_parameters.values_at(:seat_number, :passenger_count, :airplane_seats)

        airplane_seats_row_count = airplane_seats.length
        largest_column_height    = (0..get_largest_column_in_airplane_seat(airplane_seats) - 1).to_a
        current_column           = 0
        rows_array               = (0..get_largest_row_in_airplane_seat(airplane_seats) - 1).to_a

        # iterate the array to cover each seats vertically
        largest_column_height.each do |column_height|
          airplane_seats.each_with_index do |airplane_seat, index|
            if airplane_seat[column_height]
              # Fill up the left most part of seats
              if index === 0
                airplane_seat[column_height][-1] = seat_number
                seat_number += 1
              # Fill up the right part of seats
              elsif index === rows_array.last
                airplane_seat[column_height][0] = seat_number
                seat_number += 1
              # Fill up the middle seats if there are more than 3 seats in a column
              else
                airplane_seat[column_height][0] = seat_number
                seat_number += 1
                airplane_seat[column_height][-1] = seat_number
                seat_number += 1
              end
            end
          end
        end

        p airplane_seats
      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
    end

    # DOCU: Get the largest_column in the airplane seat - horizontal - width
    def get_largest_column_in_airplane_seat(airplane_seats)
      largest_column = 0

      airplane_seats.each do |airplane_seat_group|
        largest_column = airplane_seat_group.length if airplane_seat_group.length > largest_column
      end

      largest_column
    end

    # DOCU: Get the largest row in the airplane seat - vertical - height
    def get_largest_row_in_airplane_seat(airplane_seats)
      largest_row = 0

      airplane_seats.each do |airplane_seat_group|
        largest_row = airplane_seat_group.first.length if airplane_seat_group.first.length > largest_row
      end

      largest_row
    end
  end
end
