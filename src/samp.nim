const doc = """
samp is Sum Average Median Parcentile

usage:
  samp [options]
  samp [options] <filepath>...
  samp [options] (-f <ff>)...

options:
  -N, --nofilename          入力元ファイル名を出力しない
  -c --count                show count
  -n --min                  show minimum
  -x --max                  show maximum
  -a --average              show average
  -m --median               show median
  -p --parcentile=<n>       show parcentile [default: 95]
  -N --noheader             not show header
  -H, --header              ヘッダを出力する
  -d, --indelimiter=[d]     入力の区切り文字を指定 [default: "\t"]
  -D, --outdelimiter=[d]    出力の区切り文字を指定 [default: "\t"]
  -o, --outfile=[f]         出力ファイルパス
  -f, --fieldfilepath=[ff]  複数フィールド持つファイルと、その区切り位置指定 (ex: 1:data.csv)
  -I, --ignoreheader=[n]    入力データヘッダを指定行無視する

help options:
  -h --help         show this screen
  -v --version      show version
"""

import algorithm, math, docopt, strutils, os

type CalcResult = object
  fileName: string
  count: int
  min: float
  max: float
  sum: float
  average: float
  median: float
  parcentile: float

proc parcentile*[T](x: openArray[T], m: int): float =
  ## parcentile はパーセンタイル値を計算して返す
  let v = x.sorted(cmp)
  if m <= 0:
    result = v[0].float
    return
  if 100 <= m:
    result = v[v.len - 1].float
    return
  let k = (v.len+1) * m / 100
  let t = k.splitDecimal
  let i = t.intPart.int
  let f = t.floatPart
  if i <= 0:
    result = f * v[i].float
    return
  if v.len <= i:
    result = v[i-1].float
    return
  result = v[i-1].float + f * (v[i] - v[i-1]).float

proc median*[T](x: openArray[T]): float =
  ## median は中央値を計算して返す
  result = x.parcentile(50)
  
proc calc*(x: openArray[float]): CalcResult =
  ## calc は件数、最小値、最大値、合計値、平均値、中央値、パーセンタイル値を計算する
  result = CalcResult(count: x.len, min: x.min, max: x.max, sum: x.sum, average: x.sum / x.len.toFloat, median: x.median, parcentile: x.parcentile(95))

proc calcInput*(input: File): CalcResult =
  ## calcInput はファイル、あるいは標準入力を計算して返す
  var
    values: seq[float] = @[]
    line = ""
  while input.readLine line:
    values.add(line.parseFloat)
  defer: input.close
  result = values.calc

proc format*(arr: openArray[CalcResult], args: Table[string, Value]): seq[string] =
  ## format はオプション引数に応じた出力に加工して返す
  result = @["test", "test"]

if isMainModule:
  let
    args = docopt(doc, version = "v1.0.0")
    files = args["<filepath>"]
  var
    rets: seq[CalcResult] = @[]

  # ファイルがあればファイルを処理、なければ標準入力を処理
  if files.len < 1:
    rets.add stdin.calcInput
  else:
    for fp in files:
      let f = fp.open FileMode.fmRead
      # f はprocessInput内でcloseする
      var ret = f.calcInput
      ret.fileName = fp
      rets.add ret
  echo rets
