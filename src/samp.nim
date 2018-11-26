import algorithm, math

proc parcentile*[T](x: open_array[T], n: int): T =
  var p = (x.len * n / 100).ceil.int - 1
  if p < 0:
    p = 0
  if x.len - 1 < p:
    p = x.len - 1
  result = x.sorted(cmp)[p]

proc median*[T](x: open_array[T]): T =
  result = x.parcentile(50)