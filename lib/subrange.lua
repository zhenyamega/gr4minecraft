local subrange = {}

function subrange.subrange(data, first, last)
  local sub = {}
  local index_sub = 1

  for index = first, last do
    table.insert(sub, data[index])
    index_sub = index_sub + 1
  end
  
  return sub
end

return subrange