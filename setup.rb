require 'sqlite3'
require 'sequel'

DB = Sequel.sqlite('we-grow1.db')

DB.create_table! :gardens do
  primary_key :garden_id
  String :garden_name
  String :garden_description
  String :garden_country
  String :garden_street_name
  String :garden_street_number
  String :garden_zip_code
  String :garden_city
  Float :latitude
  Float :longitude
  String :garden_size
  String :garden_crops
  String :garden_facilities
  String :garden_bring_your_own
  Integer :garden_experience_required
  String :garden_owner_id
  String :garden_owner_username
  TrueClass :garden_visibility
end

DB.create_table! :members do
  primary_key :member_id
  String :member_username
  String :member_password
  String :member_first_name
  String :member_last_name
  String :member_email
  String :member_phone
  String :member_country
  String :member_street_name
  String :member_street_number
  String :member_zip_code
  String :member_city
  String :member_description
  Integer :member_gardening_experience
  String :garden_id_when_owner
  String :garden_id_when_helper
  TrueClass :member_visibility
end

DB.create_table! :contacts do
  primary_key :contact_id
  String :contact_first_name
  String :contact_last_name
  String :contact_email
  String :contact_phone
  String :contact_message
end
