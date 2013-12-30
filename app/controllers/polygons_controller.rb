class PolygonsController < ApplicationController
	before_filter :set_headers

	
  def index

  	polygon = "POLYGON((#{params[:ln0]} #{params[:lt0]},#{params[:ln1]} #{params[:lt0]},#{params[:ln1]} #{params[:lt1]}, #{params[:ln0]} #{params[:lt1]},#{params[:ln0]} #{params[:lt0]}))"
	#.select() selects the rows of the table according to the condition in the where clause
	bound = Polygon.select("ST_AREA(ST_GeomFromText('#{polygon}',4326)) as c").where(:id=>136471)
	boundarea=bound.first.c
	#creating a virtual table with attributes area, id and boundary 
	@polyareas = Polygon.find_by_sql("SELECT area,boundary,id FROM 
								(
									SELECT ST_AREA(ST_SETSRID(boundary::geometry,4326)) as area ,id as id,
									boundary as boundary
									FROM polygons
									WHERE ST_CONTAINS(ST_GeomFromText('#{polygon}',4326),ST_TRANSFORM(boundary::geometry,4326))
								)vt 
								WHERE area >= (#{boundarea}/5000)")
	#creating an empty hash 
	a={}
	@polyareas.each{|t|
			begin
				a[t.id]=[]				#the key for hash is the id of the polygon and the value is an empty array at that key
				t.boundary.exterior_ring.points.each{|k| 
		 		a[t.id].push({:lat=>k.y,:lng=>k.x, :ind=>t.id})
		 		}
		  	rescue => e
		  		puts e.message
		  	end
	 		}
	        render :json=>a
	
  end
  def show
    idofpolygon=params[:id]
    a=[]
  	polygon=Polygon.where(:id=>idofpolygon).select([:name,:id,:boundary,:visibility,:poly_type])
  	if polygon.first
	  	polygon.first.boundary.exterior_ring.points.each{|k|
	  		a.push({:lat=>k.y,:lng=>k.x, })
	  	}
    end
  	polyg = polygon.first.as_json rescue nil
  	polyg[:points] = a unless polyg.nil?  # polyg is specified hash here by polyg[:points]
  	render :json=> polyg

  end
  
	#polyarea=bound2.first.c2
	#a = {}
	 	# @polygons = Polygon.where("ST_CONTAINS
	 	# 	(ST_SETSRID(ST_GeomFromText(?),4326),
	 	# 		ST_TRANSFORM(boundary::geometry,4326))
	 	# 	 ", polygon).where("#{polyarea}>=(#{boundarea}/100)").limit(100).each{|t| 
	 	# 	begin
		 # 		a[t.id]=[]
		 # 		t.boundary.exterior_ring.points.each{|k| 
		 # 			a[t.id].push({:lat=>k.y,:lng=>k.x})
		 # 		}
		 # 	rescue => e
		 # 		puts e.message
		 # 	end
	 	# 	}
	        #render :json=>a
	
  def import
	 Polygon.import(params[:file])
	redirect_to root_url, notice: "Polygons imported."
  end

  def update
  	#polygon is the key and has an attribute boundary...chunking the last point (it is repeated in the polygon[bug in the e wicket api])
	params["polygon"]["boundary"]=params["polygon"]["boundary"][0,params["polygon"]["boundary"].rindex(",")]+"))"
	boundary = params["polygon"]["boundary"]
	params["polygon"]["boundary"] = Polygon.select("ST_GeomFromText('#{boundary}',4326) as b").where(:id=>Polygon.first.id).first.b
	Polygon.find(params["polygon"]["id"]).update_attributes(update_params)
	render :json => {:message=>:updated},:status =>200
	
  end

  def update_params
	  params.require(:polygon).as_json(:only =>["boundary"])
  end

  #these are the headers for the permissions for the ajax calls 
  private
	def set_headers
	  if request.headers["HTTP_ORIGIN"]
	  # better way check origin
	  # if request.headers["HTTP_ORIGIN"] && /^https?:\/\/(.*)\.some\.site\.com$/i.match(request.headers["HTTP_ORIGIN"])
	    headers["Access-Control-Allow-Origin"] = request.headers["HTTP_ORIGIN"]
	    headers["Access-Control-Allow-Methods"] = 'GET, POST, PATCH, PUT, DELETE, OPTIONS, HEAD'
	    headers['Access-Control-Expose-Headers'] = 'ETag'
	    headers['Access-Control-Allow-Headers'] = '*,x-requested-with,Content-Type,If-Modified-Since,If-None-Match,Auth-User-Token'
	    headers['Access-Control-Max-Age'] = '1728000'
	    headers['Access-Control-Allow-Credentials'] = 'true'
	  end
	end
	
end
