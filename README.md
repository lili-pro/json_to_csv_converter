Lib to convert Json file to csv file

Ruby version : 3.3.0

A CSV file will be generated in same directory with same name, but with .csv extension :
files/users.csv if files/users.json is the input.

For nested objects, headers are defined using dots as delimiter, like "profiles.facebook.id" for instance.
Array sub values must be in string type, and sub values will be delimited with comma.

How to use the converter : 

if your json file name is 'files/users.json',please run :

```
JsonToCsvConverter.new('files/users.json').call

```

You can choose your headers, you just need to add it in call params : 

```
custom_headers = ['name', 'email', 'profile.facebook']
JsonToCsvConverter.new('files/users.json').call(headers: custom_headers)
```

Also, you can choose your csv options, see ruby csv doc to know what options are allowed.
Example : 
```
JsonToCsvConverter.new('files/users.json').call(col_sep: ';')
```

How to run tests : 

```
ruby test/lib/json_to_csv_converter_test.rb
```