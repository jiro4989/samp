proc readLines*(input: File): seq[string] =
  var 
    line: string
  while input.readLine line:
    result.add line
 