-- A few constants
OSROOT = "/PaulCC"

-- Let's wrap the APIs needed
-- (Note: certain APIs need to remain alive)
-- I cannot disable coroutines, as they are heavily used. Maybe disable the commands except yield in the user processes?
-- os.pullEventRaw is required to be wrapped; maybe os.pullEvent too.
-- We should handle disks too; mounting disks would be nice after all, but this means peripherals have to be wrapped too

-- Raw disk access is alright; we just need to wrap the file system
-- disk.isPresent is safe
-- disk.hasData is safe
rawdisk_getmountpath = disk.getMountPath
function disk_getMountPathReal(side)
  return disk.isPresent(side) and "mnt/" .. rawdisk_getmountpath(side) or nil
end
-- disk.setLabel is safe
-- disk.getID is safe
-- disk.hasAudio is safe
-- disk.getAudioTitle is safe
-- disk.playAudio is safe
-- disk.stopAudio is safe
-- disk.eject is safe

-- Wrapping the FS (note: absolute paths!)
mtabl = {}
rawfs_getdrive = fs.getDrive
rawfs_exists = fs.exists
rawfs_isdir = fs.isDir
rawfs_isreadonly = fs.isReadOnly
rawfs_list = fs.list
rawfs_getsize = fs.getSize
rawfs_getfreespace = fs.getFreeSpace
rawfs_makedir = fs.makeDir
rawfs_mode = fs.move
rawfs_copy = fs.copy
rawfs_delete = fs.delete
rawfs_open = fs.open
rawfs_find = fs.find -- for some reason it works separately
-- Find all mounted disks
for n, item in pairs(fs.list("")) do
  if (rawfs_getdrive(item) ~= "hdd") and (rawfs_getdrive(item) ~= "rom") then
    mtabl[rawfs_getdrive(item)] = item
  end
end

function resolve_path(

function isdisk(path)
  local realpath = path
  if string.sub(path, 1, 1) == "/" then realpath = string.sub(path, 2) end
  realpath = string.sub(realpath, 1, string.find(realpath, "/"))
  return realpath == "mnt"
end

rawfs_list = fs.list
function disklist(path)
  local realpath = path
  if string.sub(path, 1, 1) == "/" then realpath = string.sub(path, 2) end
  if realpath == "mnt" then
    local result = {}
    for index, _ in pairs(mtabl) do
      result[#result+1] = index
    end
    return result
  end
  if not isdisk(path) return nil
  realpath = string.sub(realpath, 5)
  disk = string.sub(realpath, 1, string.find(realpath, "/")-1) or disk
  if mtabl[disk] == nil then return nil end
end
function fs_listReal(path)
  return disklist(path) or rawfs_list(fs.combine(OSROOT, path))
end

rawfs_exists = fs.exists
function diskexists(path)
  if not isdisk(path) then return false end
  if string.sub(path, 1, 1) == "/" then path = string.sub(path, 2) end
  if path == "mnt" then return true end
  path = string.sub(path, 5)
  disk = string.sub(path, 1, string.find(path, "/")-1)
  if mtabl[disk] == nil then return false end
  return rawfs_exists(fs.combine(mtabl[disk], path))
end

function fs_existsReal(path)
  if isdisk(path) then return diskexists(path) else
  return rawfs_exists(fs.combine(OSROOT, path)) end
end

function fs_getDriveReal(path)
  local realpath = path
  if string.sub(path, 1, 1) == "/" then realpath = string.sub(path, 2) end
  if string.sub(realpath, 1, string.find(realpath, "/")-1) == "rom" then return "rom" end
  if string.sub(realpath, 1, string.find(realpath, "/")-1) ~= "mnt" then return "hdd" end
  local disk = string.sub(realpath, 1, string.find(realpath, "/")-1)
  return mtabl[disk] ~= nil and disk or nil
end
