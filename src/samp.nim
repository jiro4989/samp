const doc = """
samp is Sum Average Median Parcentile

usage:
  samp [-h|--help]
  samp [-v|--version]
  samp [-c|--count]
       [-n|--min]
       [-x|--max]
"""

import algorithm, math, docopt

let args = docopt(doc, version = "v1.0.0")
echo args

proc parcentile*[T](x: open_array[T], n: int): float =
  var m = n
  let v = x.sorted(cmp)
  if m <= 0:
    return v[0].float
  if 100 <= m:
    return v[v.len - 1].float
  let k = (v.len+1) * m / 100
  let t = k.split_decimal
  let i = t.int_part.int
  let f = t.float_part
  result = v[i-1].float + f * (v[i] - v[i-1]).float

proc median*[T](x: open_array[T]): float =
  result = x.parcentile(50)
