class Snippet < ActiveRecord::Base
  belongs_to :user
  belongs_to :license
  has_many :comments, :dependent => :destroy
  has_many :includes, :dependent=>:destroy
  
  validates_length_of :method_name,    :within => 3..19
  validates_presence_of :method_name, :user_id, :version, :license_id, :published, :release, :code, :language
  validates_format_of :method_name,
                      :with => /^(\w)+$/,#/([a-zA-Z0-9_-])$/,
                      :message => "must be in the format 'your_method_name'"
  #Error thrown
  validates_associated :includes

  def validate
    errors.add("method_name", "cannot be entirely numerical") if !self.method_name.nil? && self.method_name.i?
  end

  def eponymous?
    Snippet.find_by_method_name(self.method_name).latest_id == self.id
  end

  def latest
    latest = Snippet.find :first, :conditions => {:user_id => self.user_id,:method_name => self.method_name}, :order => "id DESC"
    if latest.nil?
      0
    else
      self.id == latest.id
    end
  end

  def latest_id
    latest = Snippet.find :first, :conditions => {:user_id => self.user_id,:method_name => self.method_name}, :order => "id DESC"
    latest.id
  end

  def latest_version
    latest = Snippet.find :first, :conditions => {:user_id => self.user_id,:method_name => self.method_name}, :order => "id DESC"
    if latest.nil?
      0
    else
      latest.version
    end
  end

  def older_short
    Snippet.find :all, :conditions => {:user_id => self.user_id,:method_name => self.method_name}, :order => "id DESC", :limit => 10
  end

  def older
    Snippet.find :all, :conditions => {:user_id => self.user_id,:method_name => self.method_name}, :order => "id DESC"
  end
  
  def older_count
    Snippet.count :all, :conditions => {:user_id => self.user_id,:method_name => self.method_name}
  end
  
  def all_comments
    snippets = Snippet.find :all, :conditions => {:user_id => self.user_id,:method_name => self.method_name}, :order => "id DESC"
    all_comments = []
    for snippet in snippets
      all_comments = all_comments | snippet.comments if snippet.comments
    end
    all_comments
  end
  
  def includes
    parents = []
    for includee in Include.find :all, :conditions => {:parent_id => self.id}
      parents << includee.snippet
    end
    parents
  end
  
  def includers
    parents = []
    for includer in Include.find :all, :conditions => {:snippet_id => self.id}
      if includer.snippet.latest && includer.parent
        parents << includer.parent
      end
    end
    parents
  end
  
  def after_save
    #scan through the self.code for instances of
        #include_snippet(id,"method_name");
        #or 
        #include_snippet(id,"method_name",version_number);
    
    includes = []
    for match in self.code.scan(/include_snippet\(([0-9+]),[\'\"](\w+)[\'\"]\)/ix)
      includes << {:user_id => match[0], :method_name => match[1]}
    end
    
    versioned_includes = []
    for match in self.code.scan(/include_snippet\(([0-9+]),[\'\"](\w+)[\'\"],([0-9+])\)/ix)
      versioned_includes << {:user_id => match[0], :method_name => match[1], :version => match[2]}
    end
    
    snippets = []
    versioned_snippets = []
    
    for snippet in includes
      temp = Snippet.find :first, 
                          :conditions => { :user_id => snippet[:user_id],
                                           :method_name => snippet[:method_name]}, 
                          :order => 'version DESC'
      snippets << temp
    end
    for snippet in versioned_includes
      temp = Snippet.find :first, 
                          :conditions => { :user_id => snippet[:user_id],
                                           :method_name => snippet[:method_name],
                                           :version => snippet[:version]}
      versioned_snippets << temp
    end
    
    for snippet in (snippets | versioned_snippets).compact
      unless Include.find :first, :conditions => {:snippet_id => snippet.id, :user_id => snippet.user_id, :parent_id => self.id}
        included_snippet = Include.new({:snippet_id => snippet.id, :user_id => snippet.user_id, :parent_id => self.id})
        included_snippet.save
      end
    end
  end
  
  
  def descendents
    Snippet.find_all_by_ancestor_id self.id
  end
  
  def ancestor
    unless self.ancestor_id.blank? || self.ancestor_id == "NULL"
      Snippet.find(self.ancestor_id)
    end
  end

end
