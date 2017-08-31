disk.getMountPath = function(side)
  return coroutine.yield("syscall", "disk.getMountPath", side)
end
fs.list = function(path)
  return coroutine.yield("syscall", "fs.list", path)
end
fs.exists = function(path)
  return coroutine.yield("syscall", "fs.exists", path)
end
fs.getDrive = function(path)
  return coroutine.yield("syscall", "fs.getDrive", path)
end
