class Include < ActiveRecord::Base
  belongs_to :user
  belongs_to :snippet
  
  # validates_associated :snippet
  
  def parent
    begin
      Snippet.find self.parent_id
    rescue
      return nil
    end
  end
  
end
