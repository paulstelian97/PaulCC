version = "v0.2"
 
function usage()
        print([[
        Usage: pack LIST_FILE ARCHIVE [TITLE]
        The file LIST_FILE is just a list
        the names of the files to be archived
        one per line.
        TITLE is displayed by the unpacker, if given.
        That's it.]])
        os.exit()
end
 
banner = string.format([[
Pack %s by neptune12100
This is FREE SOFWARE released under the GNU GPL
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
]],version)
 
obanner = string.format([[
Unpacker %s by neptune12100
This is FREE SOFTWARE released under the GNU GPL
]],version)
 
print(banner)
 
if #arg ~= 3 and #arg ~= 2 then
        usage()
end
 
title = arg[3] -- even if it's nil!
 
files = {}
 
print(string.format("Packing to %q",arg[2]))
 
ls = io.open(arg[1],"rb")
 
for f in ls:lines() do
        local infile,err = io.open(f,"rb")
        if err then print(err)
        else
                files[f] = infile:read("*a")
                print(string.format("Packed %q",f))
                infile:close()
        end
end
 
ls:close()
 
outfile = io.open(arg[2],"wb")
 
sfiles = {}
 
for f,c in pairs(files) do
        local s = string.format([[ [ %q ] = %q ]],f,c)
        table.insert(sfiles,s)
end
 
out = string.format([[
print("Installing %s")
]],title) ..
string.format([[
print(%q)
]],obanner) ..
[[
 
files = {
 
]] .. table.concat(sfiles," , ") ..
[[
 
}
 
for f,c in pairs(files) do
        print(string.format("Creating %q",f))
        local ofile,err = io.open(f,"wb")
        if err then
                print(err)
        else
                ofile:write(c)
                ofile:close()
        end
end
 
os.remove(arg[0])
]]
 
outfile:write(out)
outfile:close()
