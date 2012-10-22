crafter={
  crafts={}
}

function crafter.register_craft(craft)
  assert(craft.type ~= nil and craft.recipe ~= nil and craft.output ~= nil,
    "Invalid craft definition, it must have type, recipe and output")
  assert(type(craft.recipe)=="table" and type(craft.recipe[1])=="table","'recipe' must be a bidimensional table")
  minetest.log("verbose","registerCraft ("..craft.type..", output="..craft.output.." recipe="..dump(craft.recipe))
  craft._h=#craft.recipe
  craft._w=#craft.recipe[1]
  -- TODO check that all the arrays have the same length...
  crafter.crafts[#crafter.crafts+1]=craft
end

function crafter.get_craft_result(data)
  assert(data.method ~= nil and data.items ~= nil, "Invalid call, method and items must be provided")
  --({method = "cooking", width = 1, items = srclist}
  local w = 1
  if data.width ~= nil and data.width>0 then
    w=data.width
  end
  for x,c in ipairs(crafter.crafts) do
    if c.type == data.method then
      -- Here we go..
      --print("Checking recipe for "..c.output.." length "..dump(#data.items))
      for i=1,w-c._h+1 do
        for j=1,w-c._w+1 do
          local p=(i-1)*w+j
          --print("Checking data.items["..dump(i).."]["..dump(j).."]("..dump(p)..")="..dump(data.items[p]).." vs craft.recipe[1][1]="..dump(c.recipe[1][1]))
          if data.items[p] == c.recipe[1][1] then
            for m=1,c._h do
              for n=1,c._w do
                local q=(i+m-1-1)*w+j+n-1
                --print("  Checking data.items["..dump(i+m-1).."]["..dump(j+n-1).."]("..dump(q)..")="..dump(data.items[q])..
                --" vs craft.recipe["..dump(m).."]["..dump(n).."]="..dump(c.recipe[m][n]))
                if c.recipe[m][n] ~= data.items[q] then
                  return nil
                end
              end
            end
            -- found! we still must check that is not any other stuff outside the limits of the recipe sizes...
            -- Checking at right of the matching square
            for m=i-c._h+1+1,w do
              for n=j+c._w,w do
                local q=(m-1)*w+n
                --print("  Checking right data.items["..dump(m).."]["..dump(n).."]("..dump(q)..")="..dump(data.items[q]))
                if data.items[q] ~= "" then
                  return nil
                end
              end
            end
            -- Checking at left of the matching square (the first row has been already scanned)
            for m=i-c._h+1+1+1,w do
              for n=1,j-1 do
                local q=(m-1)*w+n
                --print("  Checking left data.items["..dump(m).."]["..dump(n).."]("..dump(q)..")="..dump(data.items[q]))
                if data.items[q] ~= "" then
                  return nil
                end
              end
            end
            -- Checking at bottom of the matching square
            for m=i+1,w do
              for n=j,j+c._w do
                local q=(m-1)*w+n
                --print("  Checking bottom data.items["..dump(m).."]["..dump(n).."]("..dump(q)..")="..dump(data.items[q]))
                if data.items[q] ~= "" then
                  return nil
                end
              end
            end
            --print("Craft found! "..c.output)
            return {item=c.output}
          elseif data.items[p] ~= nil and data.items[p] ~= "" then
            --print("Invalid data item "..data.items[p])
            return nil
          end
        end
      end
    end
  end
  return nil
end
