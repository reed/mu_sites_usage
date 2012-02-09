# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
computing_sites = Department.create({:display_name => "Computing Sites", :short_name => "computingsites"})
admin = computing_sites.users.create({:username => "reednj", :name => "Nick Reed", :email => "reednj@missouri.edu", :role => "administrator"})