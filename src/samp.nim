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
  -s --sum                  show sum
  -a --average              show average
  -m --median               show median
  -p --parcentile=<n>       show parcentile [default: 95]
  -H --header               ヘッダを出力する
  -d --indelimiter=[d]      入力の区切り文字を指定 [default: "\t"]
  -D --outdelimiter=[d]     出力の区切り文字を指定 [default: "\t"]
  -o --outfile=[f]          出力ファイルパス
  -f --fieldfilepath=[ff]   複数フィールド持つファイルと、その区切り位置指定 (ex: 1:data.csv)
  -I --ignoreheader=[n]     入力データヘッダを指定行無視する

help options:
  -h --help         show this screen
  -v --version      show version
"""

import algorithm, math, docopt, strutils, logging

type
  CalcResult* = object
    fileName*: string
    count*: int
    min*: float
    max*: float
    sum*: float
    average*: float
    median*: float
    parcentile*: float

proc parcentile*[T](x: openArray[T], m: int): float =
  ## parcentile はパーセンタイル値を計算して返す
  if x.len <= 0:
    result = 0.0
    return
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
  
proc calc*(x: openArray[float], n: int): CalcResult =
  ## calc は件数、最小値、最大値、合計値、平均値、中央値、パーセンタイル値を計算する
  result = CalcResult(count: x.len, min: x.min, max: x.max, sum: x.sum, average: x.sum / x.len.toFloat, median: x.median, parcentile: x.parcentile(n))

proc calcInput*(input: File, n: int): CalcResult =
  ## calcInput はファイル、あるいは標準入力を計算して返す
  var
    values: seq[float] = @[]
    line = ""
  while input.readLine line:
    values.add(line.parseFloat)
  result = values.calc n

proc processInput*(files: openArray[string], n: int): seq[CalcResult] =
  ## processInput はファイルがあればファイルを処理、なければ標準入力を処理
  if files.len < 1:
    result.add stdin.calcInput n
  else:
    for fp in files:
      var f: File
      try:
        f = fp.open FileMode.fmRead
        var ret = f.calcInput n
        ret.fileName = fp
        result.add ret
      except IOError:
        error getCurrentExceptionMsg()
      finally:
        if f != nil:
          f.close


proc format*(arr: openArray[CalcResult],
             noFileNameFlag: bool = false,
             countFlag: bool = false,
             minFlag: bool = false,
             maxFlag: bool = false,
             sumFlag: bool = false,
             averageFlag: bool = false,
             medianFlag: bool = false,
             parcentileFlag: bool = false,
             parcentileNum: int = 95,
             headerFlag: bool = false,
             outDelimiter: string = "\t"
             ): string =
  ## format はオプション引数に応じた出力に加工して返す
  var
    records: seq[string]
    record: seq[string]
  
  # ヘッダレコードの追加
  if headerFlag:
    var header: seq[string]
    if countFlag: header.add "count"
    if minFlag: header.add "min"
    if maxFlag: header.add "max"
    if sumFlag: header.add "sum"
    if averageFlag: header.add "average"
    if medianFlag: header.add "median"
    if parcentileFlag: header.add($parcentileNum & "parcentile")
    records.add header.join(outDelimiter)

  # 値レコードの追加
  for v in arr:
    if countFlag: record.add $(v.count)
    if minFlag: record.add $(v.min)
    if maxFlag: record.add $(v.max)
    if sumFlag: record.add $(v.sum)
    if averageFlag: record.add $(v.average)
    if medianFlag: record.add $(v.median)
    if parcentileFlag: record.add $(v.parcentile)
    records.add record.join(outDelimiter)

  result = records.join("\n")

if isMainModule:
  var L = newConsoleLogger(fmtStr = verboseFmtStr)
  addHandler(L)

  let
    args = docopt(doc, version = "v1.0.0")
    files = @(args["<filepath>"])
    rets = files.processInput parseInt($args["--parcentile"])
  
  debug "args:", args
  debug rets
