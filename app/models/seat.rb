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
          rows      = (0..seat_settings.first - 1).to_a
          columns   = (0..seat_settings.last - 1).to_a

          # Create rows and columns
          columns.each do
            row_array = []

              rows.each do
                row_array << 0
              end

              temporary_seat << row_array
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

    # DOCU: Fill aisle seats
    def fill_aisle_seats_scenario_3(response_data, fill_aisle_seat_parameters)
      begin
        # Destructure fill_aisle_seat_parameters
        seat_number, passenger_count, airplane_seats = fill_aisle_seat_parameters.values_at(:seat_number, :passenger_count, :airplane_seats)
        passenger_count = (passenger_count.to_i + 1)

        largest_column_height    = (0..get_largest_column_in_airplane_seat(airplane_seats) - 1).to_a
        rows_array               = (0..get_largest_row_in_airplane_seat(airplane_seats) - 1).to_a

        # TODO: For refactor - repeated function
        # iterate the array to cover each seats vertically
        largest_column_height.each do |column_height|
          airplane_seats.each_with_index do |airplane_seat, index|
            if airplane_seat[column_height]
              # Fill up the right most part of seats
              if index === 0
                airplane_seat[column_height][-1] = seat_number
                seat_number += 1
              # Fill up the left most part of seats
              elsif index === rows_array.last
                airplane_seat[column_height][0] = seat_number
                seat_number += 1
              # Fill up the first and last seats if there are more than 3 seats in a column
              else
                airplane_seat[column_height][0] = seat_number
                seat_number += 1

                break if passenger_count === seat_number

                airplane_seat[column_height][-1] = seat_number
                seat_number += 1
              end

              break if passenger_count === seat_number
            end
          end

            break if passenger_count === seat_number
        end

        # Guard clause if the passenger count is already reached
        if passenger_count === seat_number
          return response_data.merge!({ status: true, result: {airplane_seats: airplane_seats} })
        end

        fill_window_seats_parameters = {
          passenger_count: passenger_count,
          airplane_seats: airplane_seats,
          seat_number: seat_number,
          rows_array: rows_array,
          largest_column_height: largest_column_height
        }

        # Fill the window seats
        fill_window_seats_scenario_3(response_data, fill_window_seats_parameters)
      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
    end

    # DOCU: Fill the window_seats
    def fill_window_seats_scenario_3(response_data, fill_window_seats_parameters)
      begin
        # Destructure the fill_window_seats_parameters
        passenger_count, airplane_seats, seat_number, rows_array, largest_column_height = fill_window_seats_parameters.values_at(:passenger_count, :airplane_seats, :seat_number, :rows_array, :largest_column_height)

        # TODO: For refactor - repeated function
        largest_column_height.each do |column_height|
          airplane_seats.each_with_index do |airplane_seat, index|
            if airplane_seat[column_height]
              # Fill up the left most part of seats
              if index === 0
                airplane_seat[column_height][0] = seat_number
                seat_number += 1
              # Fill up the right part of seats
              elsif index === rows_array.last
                airplane_seat[column_height][-1] = seat_number
                seat_number += 1
              end

                break if passenger_count === seat_number
            end
          end

            break if passenger_count === seat_number
        end

        # Guard clause if the passenger count is already reached
        if passenger_count === seat_number
          return response_data.merge!({ status: true, result: {airplane_seats: airplane_seats} })
        end


        fill_middle_seats_parameters = {
          passenger_count: passenger_count,
          airplane_seats: airplane_seats,
          seat_number: seat_number,
          rows_array: rows_array,
          largest_column_height: largest_column_height
        }

        fill_middle_seats_scenario_3(response_data, fill_middle_seats_parameters)
      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
    end

    # DOCU: Fill the middle seats
    def fill_middle_seats_scenario_3(response_data, fill_middle_seats_parameters)
      begin
        # Destructure the fill_window_seats_parameters
        passenger_count, airplane_seats, seat_number, rows_array, largest_column_height = fill_middle_seats_parameters.values_at(:passenger_count, :airplane_seats, :seat_number, :rows_array, :largest_column_height)

        # TODO: For refactor - repeated function
        largest_column_height.each do |column_height|
          airplane_seats.each_with_index do |airplane_seat, index|
            if airplane_seat[column_height]
              # Fill up the middle seats only if there are more than 3 seats for the middle seat to
              if airplane_seat[column_height].length >= 3

                airplane_seat[column_height].each_with_index do |airplane_seat_to_update, index|
                  if airplane_seat_to_update === 0
                    airplane_seat[column_height][index] = seat_number
                    seat_number += 1
                  end

                  break if passenger_count === seat_number
                end
              end
            end
          end

          break if passenger_count === seat_number
        end

        # Guard clause if the passenger count is already reached or has a remainder in the passenger count
        if passenger_count >= seat_number
          unboarded_passengers = passenger_count - seat_number
          return response_data.merge!({ status: true, result: {airplane_seats: airplane_seats, unboarded_passengers: unboarded_passengers }})
        end

      rescue Exception => ex
        response_data.merge!({ error: ex.message })
      end

      response_data
    end

    # TODO: Move to helper. put here for easier code review
    # DOCU: Get the largest_column in the airplane seat - horizontal - width
    def get_largest_column_in_airplane_seat(airplane_seats)
      largest_column = 0

      airplane_seats.each do |airplane_seat_group|
        largest_column = airplane_seat_group.length if airplane_seat_group.length > largest_column
      end

      largest_column
    end

    # TODO: Move to helper. put here for easier code review
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
