class ApplicationRecord < ActiveRecord::Base
  primary_abstract_class

  class << self
    def check_fields(required_fields = [], optional_fields = [], params)
        response_data = { :status => false, :result => {}, :error => nil }

        begin
            invalid_fields = []
            all_fields     = required_fields + optional_fields

            all_fields.each do |key|
                if params[key].present?
                    response_data[:result][key] = params[key].is_a?(String) ? params[key].strip : params[key]
                elsif required_fields.include?(key)
                    invalid_fields << key
                    response_data[:error] = "Missing required fields"
                end
            end

            response_data.merge!(invalid_fields.empty? ? { :status => true, :result => response_data[:result].symbolize_keys } : { :result => invalid_fields, :error => "Missing required fields" })
        rescue Exception => ex
            response_data[:error] = ex.message
        end

        return response_data
    end
  end
end
