class Page < Content
  
  validates_presence_of :title, :body
  validates_uniqueness_of :title
end
