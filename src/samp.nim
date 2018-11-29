const doc = """
samp is Sum Average Median Parcentile

usage:
  samp [options]
  samp [options] <filepath>...

options:
  -c --count        show count
  -n --min          show minimum
  -x --max          show maximum
  -a --average      show average
  -m --median       show median
  -p --parcentile   show parcentile
  -h --help         show this screen
  -v --version      show version
"""

import algorithm, math, docopt

if isMainModule:
  let args = docopt(doc, version = "v1.0.0")
  let files = args["<filepath>"]
  if files.len < 1:
    # 標準入力を対象に処理
    var line = stdin.read_line
    var lines: seq[string] = @[]
    while line != "":
      lines.add line
      line = stdin.read_line
    echo lines
  else:
    # ファイルを対象に処理
    echo "file"

proc parcentile*[T](x: open_array[T], m: int): float =
  let v = x.sorted(cmp)
  if m <= 0:
    result = v[0].float
    return
  if 100 <= m:
    result = v[v.len - 1].float
    return
  let k = (v.len+1) * m / 100
  let t = k.split_decimal
  let i = t.int_part.int
  let f = t.float_part
  result = v[i-1].float + f * (v[i] - v[i-1]).float

proc median*[T](x: open_array[T]): float =
  result = x.parcentile(50)
