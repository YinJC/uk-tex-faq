lfs = require("lfs")

for entry in lfs.dir(".") do
  if string.match(entry, "^FAQ%-%w+%.md$") then
    print(entry)
    local file = assert(io.open(entry, "rb"))
    local contents = string.gsub(file:read("*all") .. "\n", "\r\n", "\n")
    io.close(file)
    while string.match(contents,"\n\n\n") do
      contents = string.gsub(contents,"\n\n\n","\n\n")
    end
    local newfile = io.open(entry, "w")
    io.output(newfile)
    io.write(contents)
    io.close(newfile)
  end
end