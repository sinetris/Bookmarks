class BookmarkEntity < Grape::Entity
  expose(:id, documentation: { type: Integer, desc: "unique ID" })
  expose(:url, documentation: { type: String, desc: "URL" })
  expose(:description, documentation: { type: String, desc: "Description" })
end
