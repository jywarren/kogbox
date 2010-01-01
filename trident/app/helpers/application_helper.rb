# Methods added to this helper will be available to all templates in the application.
module ApplicationHelper  
  # require 'htmlentities'
  # 
  # def htmlencode(string)
  #   HTMLEntities.new("coder")
  #   coder.encode(string)
  # end
  # 
  # def htmldecode(string)
  #   HTMLEntities.new(coder)
  #   coder.decode(string)
  # end
  
  def recent_snippets
    Snippet.find :all, :conditions => {:published => "public"}, :limit => 6, :order => 'id DESC'
  end
  def recent_comments
    Comment.find :all, :limit => 5, :order => 'id DESC'
  end

  
end

class String
  def i?(allowScientific = false)
      if allowScientific
        return (self =~ /^-?\d+(e-?\d+)?$/) != nil
      end
      (self =~ /^-?\d+$/) != nil
    end
end

class Float
  def i?
      self - self.to_i == 0
  end
end