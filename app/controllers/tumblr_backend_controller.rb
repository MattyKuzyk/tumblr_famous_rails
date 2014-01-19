class TumblrBackendController < ApplicationController
	require 'oauth/consumer'
	@@globalSession = true
	def tags
		if @@globalSession
			@@consumer=OAuth::Consumer.new "HkKQKdz8qmb2WTWTPWjd0FkRFQIGihbBkASyVdTtkIeihRFt4Z", "NScqGFcG2ymequqpFWMe7qKIs3ux0XyE6iS0ESByK6UySbMZwi", {site: "http://www.tumblr.com"}
			@@request_token = @@consumer.get_request_token( { :oauth_callback => 'http://localhost:3000/callback' } )
	    session[:request_token]=@@request_token
	    redirect_to @@request_token.authorize_url
	  end
		# @request_token = @consumer.get_request_token(exclude_callback: true)
		# redirect_to @request_token.authorize_url
		# @access_token = @request_token.get_access_token
		# @response = @access_token.get "/agreements.xml"
		@@tags = params[:data]
		@@tags = JSON.parse @@tags
		prng = Random.new
		@@tag = @@tags[prng.rand(@@tags.count)]
		@@tag.squish!
		@@tag.sub! " ", "+"
		if !@@globalSession
			note_count = 0
      @@client.tagged(@@tag, :limit => 20).each do |p|
				if p["note_count"] > note_count
					note_count = p["note_count"]
					@post = p
				end
			end
			@@client.reblog @@client.info['user']['name']+".tumblr.com", id: @post['id'], reblog_key: @post['reblog_key']
			render nothing: true
		end
		

	end

	def callback
    request_token = ActiveSupport::JSON.decode(@@request_token.to_json)

        if !(request_token.present?)
          $request_token_value = "Response failed"  
        else
          $request_token_value = request_token  
        end
        # access_token = @@request_token.get_access_token({:oauth_verifier=>params[:oauth_verifier],:oauth_token=>params[:oauth_token]}) 
        # @@access_token =    @@request_token.get_access_token(:oauth_verifier=>params[:oauth_verifier]) 
        @@access_token = @@request_token.get_access_token :oauth_verifier => params[:oauth_verifier]
        oauth_token = @@access_token.token
        oauth_token_secret = @@access_token.secret
        # puts @@access_token
        # access_json = ActiveSupport::JSON.decode(@@access_token.to_json)
        puts "****************************"  
        puts oauth_token
        puts oauth_token_secret
        puts "****************************"
        @@client = Tumblr::Client.new({
        	consumer_key: "HkKQKdz8qmb2WTWTPWjd0FkRFQIGihbBkASyVdTtkIeihRFt4Z",
      		consumer_secret: "NScqGFcG2ymequqpFWMe7qKIs3ux0XyE6iS0ESByK6UySbMZwi",
      		oauth_token: oauth_token,
      		oauth_token_secret: oauth_token_secret
        	})
				note_count = 0
        @@client.tagged(@@tag, :limit => 20).each do |p|
					if p["note_count"] > note_count
						note_count = p["note_count"]
						@post = p
					end
				end
				@@client.reblog @@client.info['user']['name']+".tumblr.com", id: @post['id'], reblog_key: @post['reblog_key']
				@@globalSession = false
        render nothing: true   
  end

	# def tokenGrabber
	# 	byebug
	# end
end
