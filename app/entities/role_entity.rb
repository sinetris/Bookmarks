class RoleEntity < Grape::Entity
  expose(:id, documentation: { type: Integer, desc: "unique ID" })
  expose(:name, documentation: { type: String, desc: "Name" })
end
