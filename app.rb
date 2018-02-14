require 'sinatra'
require 'sqlite3'
require 'sequel'
require 'geocoder'

DB = Sequel.sqlite('we-grow1.db')

get '/' do # Index page, listing all gardens

  # Select only gardens marked as visible
  @gardens = DB[:gardens].where(:garden_visibility => true)

  # Create array of arrays with key info and location coordinates for each garden, to be used for the map view
  @garden_locations = []
  @gardens.each do |garden|
    @garden_locations << [garden[:garden_id], garden[:garden_name], garden[:latitude], garden[:longitude], garden[:garden_city]]
  end
  erb :index
end


get '/garden/new' do # Open page - add new garden
  # Select only members marked as visible, for the Owner section in the new garden form
  @members = DB[:members].where(:member_visibility => true)
  erb :new_garden
end


post '/garden' do # Form submit - add new garden

  # Save address coordinates and use geocoder to obtain longitude and latitude based on that
  query = [params[:street_name], params[:street_number], params[:zip_code], params[:city]].compact.join(", ")
  first_result = Geocoder.search(query).first
  lat = first_result.latitude
  long = first_result.longitude
  puts lat, long

  # Insert new garden in the :gardens table based on info submitted in the form
  DB[:gardens].insert(
    garden_name: params[:name],
    garden_description: params[:description],
    garden_street_name: params[:street_name],
    garden_street_number: params[:street_number],
    garden_zip_code: params[:zip_code],
    garden_city: params[:city],
    latitude: lat,
    longitude: long,
    garden_size: params[:size],
    garden_experience_required: params[:experience],
    garden_crops: params[:crops],
    garden_facilities: params[:facilities],
    garden_bring_your_own: params[:bring_your_own],
    garden_visibility: true,
    garden_owner_username: params[:owner_username],
    # Save garden_owner_id by looking it up in the :members table by the member's username
    garden_owner_id: DB[:members][{member_username: params[:owner_username]}][:member_id]
  )

  # Save also garden_id for the respective member who posted it
  DB[:members].where(:member_username => params['owner_username']).update(:garden_id_when_owner => params[:id])
  redirect '/'
end


get '/member/new' do # Open page - add new member
  erb :new_member
end


post '/member' do # Form submit - add new member
  # Insert new member in the :members table based on info submitted in the form
  DB[:members].insert(
    member_username: params[:username],
    member_password: params[:password],
    member_first_name: params[:first_name],
    member_last_name: params[:last_name],
    member_email: params[:email],
    member_phone: params[:phone],
    member_street_name: params[:street_name],
    member_street_number: params[:street_number],
    member_zip_code: params[:zip_code],
    member_city: params[:city],
    member_description: params[:description],
    member_gardening_experience: params[:experience],
    member_visibility: true
  )
  redirect '/admin'
end


get '/garden/:id' do # Open page - view individual garden
  # Search for the required garden by its id
  @garden = DB[:gardens][:garden_id => params['id']]
  erb :view_garden
end


get '/garden/:id/edit' do # Open page - edit individual garden
  # Search for the required garden by its id
  @garden = DB[:gardens][:garden_id => params['id']]
  erb :edit_garden
end


put '/garden/:id' do # Form submit - edit individual garden

  # Rerun the geocoder to calculate latitude and longitude based on updated coordinates
  query = [params[:street_name], params[:street_number], params[:zip_code], params[:city]].compact.join(", ")
  first_result = Geocoder.search(query).first
  lat = first_result.latitude
  long = first_result.longitude
  puts lat, long

  # Search for the required garden based on its id and update each column based on info submitted through the form
  DB[:gardens].where(:garden_id => params['id']).update(
  :garden_name => params['name'], :garden_description => params['description'], :garden_street_name => params['street_name'],
  :garden_street_number => params['street_number'], :garden_zip_code => params['zip_code'], :garden_city => params['city'],
  :latitude => lat, :longitude => long,
  :garden_size => params['size'], :garden_experience_required => params['experience'], :garden_crops => params['crops'],
  :garden_facilities => params['facilities'], :garden_bring_your_own => params['bring_your_own'])
  redirect "/garden/#{params['id']}"
end


get '/member/:id' do # Open page - view individual member
  # Search for the required member based on their id
  @member = DB[:members][:member_id => params['id']]
  # Save a dataset of all gardens they posted by querying the :gardens table based for garden_owner_id matching member id
  @gardens_owned = DB[:gardens].where(:garden_owner_id => params['id'])
  erb :view_member
end


get '/member/:id/edit' do # Open page - edit individual member
  # Search for the required member based on their id
  @member = DB[:members][:member_id => params['id']]
  erb :edit_member
end


put '/member/:id' do # Form submit - edit individual member

  # Search for required member based on their id and update each column based on info submitted through the form
  DB[:members].where(:member_id => params['id']).update(:member_username => params['username'], :member_password => params['password'],
  :member_first_name => params['first_name'], :member_last_name => params['last_name'], :member_email => params['email'], :member_phone => params['phone'],
  :member_street_name => params['street_name'], :member_street_number => params['street_number'],
  :member_zip_code => params['zip_code'], :member_city => params['city'], :member_description => params['description'],
  :member_gardening_experience => params['experience']
  )

  # In case the username changed, update this firld for each garden they posted
  DB[:gardens].where(:garden_owner_id => params['id']).update(:garden_owner_username => params['username'])
  redirect "/member/#{params['id']}"
end


get '/admin' do # Open page - view index as admin - view all gardens and all members, with buttons to show / hide / delete them
  @gardens = DB[:gardens]
  @members = DB[:members]
  erb :admin
end


put '/admin/hide/garden' do # Form submit - hide individual garden
  # Search for the required garden based on its id and update its visibility to false
  DB[:gardens].where(
    garden_id: params[:garden_to_hide]
  ).update(:garden_visibility => false)
  redirect '/admin'
end


put '/admin/show/garden' do # Form submit - restore visibility to individual garden
  # Search for the required garden based on its id and update its visibility to true
  DB[:gardens].where(
    garden_id: params[:garden_to_show]
  ).update(:garden_visibility => true)
  redirect '/admin'
end


put '/admin/delete/garden' do # Form submit - delete individual garden
  # Search for the required garden based on its id and delete it from table
  DB[:gardens].where(
    garden_id: params[:garden_to_delete]
  ).delete
  redirect '/admin'
end


put '/admin/hide/member' do #Form submit - hide individual member, and all associated gardens they posted

  # Search for the required member based on their id and update their visibility to false
  DB[:members].where(
    member_id: params[:member_to_hide]
  ).update(:member_visibility => false)

  # Search for all gardens they posted by their member id and update their visibility to false
  DB[:gardens].where(
    garden_owner_id: params[:member_to_hide]
  ).update(:garden_visibility => false)
  redirect '/admin'
end


put '/admin/show/member' do # Form submit - restore visibility to individual member, and all associated gardens they posted

  # Search for the required member based on their id and update their visibility to true
  DB[:members].where(
    member_id: params[:member_to_show]
  ).update(:member_visibility => true)

  # Search for all gardens they posted by their member id and update their visibility to true
  DB[:gardens].where(
    garden_owner_id: params[:member_to_show]
  ).update(:garden_visibility => true)
  redirect '/admin'
end


put '/admin/delete/member' do # Form submit - delete individual member

  # Search for the required member based on their id and delete from table
  DB[:members].where(
    member_id: params[:member_to_delete]
  ).delete

  # Search for all gardens they posted based on their member id and delete from table
  DB[:gardens].where(
    garden_owner_id: params[:member_to_delete]
  ).delete
  redirect '/admin'
end


post '/contact/submit' do # Form submit - contact form
  # Add new entry into :contacts table with the info submitted through the contact form
  DB[:contacts].insert(
    contact_first_name: params[:first_name],
    contact_last_name: params[:last_name],
    contact_email: params[:email],
    contact_phone: params[:phone],
    contact_message: params[:message],
  )
  redirect '/'
end
