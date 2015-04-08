module Matterhorn
  class RejectLinksMiddleware

    def initialize(app)
      @app = app
    end

    def call(env)
      if reject_uri!(env)
        four_o_three
      elsif reject_body!(env) 
        four_o_three
      else
        @app.call(env)
      end
    end

    private 

    def reject_body!(env)
      request_form_hash = env['rack.request.form_hash']
      if request_form_hash
        nested_keys(request_form_hash).flatten.include?('links')
      else
        false
      end
    end

    def reject_uri!(env)
      path = env['PATH_INFO']
      #path[1..-1].gsub('.json','').split('/')[1..-1].include?('links')
      !%r{(\/\w*[.]?)(links)}.match(path).nil?
    end

    def four_o_three
      [403,{"Content-Type" => "text/html", "Content-Length" => "0"},[]]
    end

    def nested_keys(hash)
      keys = hash.keys
      keys.each do |k|
        if hash[k].kind_of? Hash
          keys << nested_keys(hash[k])
        end
      end
      keys
    end

  end
end
