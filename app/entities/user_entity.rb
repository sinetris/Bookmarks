class UserEntity < Grape::Entity
  expose(:id, documentation: { type: Integer, desc: "unique ID" })
  expose(:username, documentation: { type: String, desc: "username" })
end
