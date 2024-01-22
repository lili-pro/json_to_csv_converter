require 'csv'
require 'json'

class JsonToCsvConverter
    class FormatError < StandardError; end
    class ForbiddenCharInKey < StandardError; end
    class UnsupportedSchema < StandardError; end

    def initialize(json_filename)
        @json_filename = json_filename
    end

    def call(**options)
        options[:headers] = computed_headers if options[:headers].nil?
        options[:write_headers] = true
        CSV.open(new_filename, 'w', **options) do |csv|
            data.each do |object|
                csv << csv_line_from_object(object, options[:headers], options[:col_sep])
            end
        end
    rescue UnsupportedSchema 
        File.delete(new_filename) if File.exist?(new_filename)
        raise
    end

    private

    attr_reader :data, :json_filename

    def data
        @data ||= JSON.parse(File.read(json_filename)).tap do |content|
            raise UnsupportedSchema.new('Json data must be an Array') unless content.is_a? Array
        end
    rescue JSON::ParserError
        raise FormatError.new('Please enter a json filename')
    end


    def csv_line_from_object(object, header, col_sep = ',')
        header = header.split(col_sep) if header.is_a? String
        header.map do |key|
            value = object.dig(*key.to_s.split('.'))
            check_value!(value)
            value = value.join(',') if value.is_a? Array
            value
        end
    end

    def check_value!(value)
        return unless value.is_a?(Array) && value.first.is_a?(Hash)
        raise UnsupportedSchema.new('Json cannot contains an array of hash.')
    end

    def new_filename
        "#{File.dirname(json_filename)}/#{File.basename(json_filename,'.*')}.csv"
    end

    def computed_headers
        headers = []
        data.first.each do |key, value|
            check_key!(key)
            headers << fetch_keys(key, value)
        end
        headers.flatten
    end

    def fetch_keys(key, value)
        return fetch_hash_keys(key, value) if value.is_a? Hash

        key
    end

    def fetch_hash_keys(key, value)
        value.map do |sub_key, sub_value|
            check_key!(sub_key)
            fetch_keys("#{key}.#{sub_key}", sub_value)
        end
    end

    def check_key!(key)
        return unless key.include?('.')

        raise ForbiddenCharInKey.new("Dot char is not allowed in key name, key in error : #{key}")
    end
end
