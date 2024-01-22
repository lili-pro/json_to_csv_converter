
require 'minitest/autorun'
require_relative '../../lib/json_to_csv_converter'

class JsonToCsvConverterTest < Minitest::Test

    def test_create_csv_file_from_json_file
        JsonToCsvConverter.new('test/files/users.json').call

        assert_equal File.read('test/files/expected_users.csv'), generated_file
        remove_generated_file
    end

    def test_raise_if_dot_in_one_key
        assert_raises JsonToCsvConverter::ForbiddenCharInKey do
            JsonToCsvConverter.new('test/files/users_with_dot_in_keys.json').call
        end
    end

    def test_raise_if_dot_in_one_sub_key
        assert_raises JsonToCsvConverter::ForbiddenCharInKey do
            JsonToCsvConverter.new('test/files/users_with_dot_in_sub_keys.json').call
        end
    end

    def test_raise_if_not_json
        assert_raises JsonToCsvConverter::FormatError do
            JsonToCsvConverter.new('test/files/users.xml').call
        end
    end

    def test_raise_if_not_an_array
        assert_raises JsonToCsvConverter::UnsupportedSchema do
            JsonToCsvConverter.new('test/files/user.json').call
        end
    end

    def test_raise_if_json_with_array_of_hash
        assert_raises JsonToCsvConverter::UnsupportedSchema do
            JsonToCsvConverter.new('test/files/users_with_array_of_hash.json').call
        end
    end

    def test_can_generate_csv_with_options
        JsonToCsvConverter.new('test/files/users.json').call(col_sep: ';', force_quotes: true)

        assert_equal File.read('test/files/expected_users_with_options.csv'), generated_file
        remove_generated_file
    end

    def test_can_choose_the_headers
        headers = [
            'id',
            'email',
            'tags',
            'profiles.facebook.id',
            'profiles.facebook.picture'
        ]
        JsonToCsvConverter.new('test/files/users.json').call(headers: headers)

        assert_equal File.read('test/files/expected_users_with_custom_headers.csv'), generated_file
        remove_generated_file
    end

    def test_can_use_string_headers
        headers = 'id;email;tags;profiles.facebook.picture;profiles.twitter.picture'
        JsonToCsvConverter.new('test/files/users.json').call(headers: headers, col_sep: ';')

        assert_equal File.read('test/files/expected_users_with_custom_string_headers.csv'), generated_file
        remove_generated_file
    end
    
    def test_nothing_raised_if_some_headers_do_not_have_any_values
        headers = [
            'id',
            'email',
            'name',
            'country'
        ]
        JsonToCsvConverter.new('test/files/users.json').call(headers: headers)

        assert_equal File.read('test/files/expected_users_with_missing_infos.csv'), generated_file
        remove_generated_file
    end

    private

    def generated_file
        File.read(expected_filename)
    end

    def remove_generated_file
        File.delete(expected_filename)
    end

    def expected_filename
        'test/files/users.csv'
    end
end