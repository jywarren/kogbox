class SearchController < ApplicationController
  require "htmlentities"
  
  def index
    if params[:q]
      query = params[:q].encode_entities
      # query.strip!('"')
      # query.strip!("'")
      if params[:s] == "snippets"
        results = Snippet.find_by_sql "SELECT * FROM snippets WHERE method_name LIKE '%#{query}%' OR description LIKE '%"+params[:q]+"%' OR code LIKE '%"+params[:q]+"%' AND published = 'public' ORDER BY id DESC LIMIT 40"
        
      # elsif params[:s] == "description"
      #   @results = User.find :all, :conditions => {:login => params[:query]}
      elsif params[:s] == "users"
        results = User.find_by_sql "SELECT * FROM users WHERE users.login LIKE '%#{query}%' LIMIT 40"
      end
      if params[:s] == "users"
        @results = results
      else
        @results = []
        for snippet in results
          dupe = false
          for candidate in @results
            dupe = true if snippet.method_name == candidate.method_name && snippet.user_id == candidate.user_id
          end
          unless dupe
            @results << snippet
          end
        end
      end
    end
    @recent = Snippet.find :all, :conditions => {:release => "production", :published => "public"}, :limit => 6, :order => 'id DESC'
    @recentComments = Comment.find :all, :limit => 5, :order => 'id DESC'
  end
  
end
