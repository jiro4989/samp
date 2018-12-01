import strutils

type
  FieldFilePath* = object
    fieldIndex*: int
    filePath*: string

proc parse*(s: string): FieldFilePath = 
  let arr = s.split(":")
  if arr.len < 2:
    result = FieldFilePath(filePath: s)
    return

  var fi: int
  try:
    fi = arr[0].strip.parseInt
  except ValueError:
    fi = -1
  let fp = arr[1].strip
  result = FieldFilePath(fieldIndex: fi, filePath: fp)
