class Polygon < ActiveRecord::Base
   set_rgeo_factory_for_column(:boundary,
    RGeo::Geographic.spherical_factory(:srid => 4326))
   set_rgeo_factory_for_column(:x5,
    RGeo::Geographic.spherical_factory(:srid => 4326))




	def self.import(file_name)
		text=File.open(file_name).read
		text.each_line do |line|
		begin
		  name,polygon,*rest=line.split('**|**')
		  #print "#{polygon}\n"
		  p=Polygon.new
		  p.name=name
		  p.boundary=polygon
		  p.poly_type="locality"
		  p.visibility=true
		  p.save
		rescue Exception => e
		  binding.pry
		  puts "hello"
		end	
		end
	end
	def self.read
		Polygon.all.find_each do |polygon|
			print "#{polygon}\n"
	end
	end
	def self.update_object(params)
		Polygon.find(params["polygon"]["id"]).update_attributes(params["polygon"])	
	end
end
