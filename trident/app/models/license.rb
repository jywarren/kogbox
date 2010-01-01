class License < ActiveRecord::Base
  has_many :snippets
end
