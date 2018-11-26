import algorithm, math

proc parcentile*[T](x: open_array[T], n: int): float =
  let v = x.sorted(cmp)
  let k = (v.len+1) * n / 100
  let t = k.split_decimal
  let i = t.int_part.int
  let f = t.float_part
  result = v[i-1].float + f * (v[i] - v[i-1]).float

proc median*[T](x: open_array[T]): float =
  result = x.parcentile(50)