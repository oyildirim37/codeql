import swift

from Method m, string path
where 
  m.hasLocation() and
  path = m.getFile().getRelativePath()
select m, path
