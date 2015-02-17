class PaginationEntity < Grape::Entity
  expose :limit
  expose :offset
  expose :total
end
