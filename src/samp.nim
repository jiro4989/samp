const doc = """
samp is Sum Average Median Parcentile

usage:
  samp [options]
  samp [options] <filepath>...
  samp [options] (-f <ff>)...

options:
  -N --nofilename          入力元ファイル名を出力しない
  -c --count                show count
  -n --min                  show minimum
  -x --max                  show maximum
  -s --sum                  show sum
  -a --average              show average
  -m --median               show median
  -p --parcentile=<n>       show parcentile [default: 0]
  -H --header               ヘッダを出力する
  -d --indelimiter=<d>      入力の区切り文字を指定 [default: \t]
  -D --outdelimiter=<d>     出力の区切り文字を指定 [default: \t]
  -o --outfile=<f>          出力ファイルパス
  -f --fieldfilepath=<ff>   複数フィールド持つファイルと、その区切り位置指定 (ex: 1:data.csv)
  -I --ignoreheader=<n>     入力データヘッダを指定行無視する [default: 0]
  -X --debug                turn on debug flag

help options:
  -h --help         show this screen
  -v --version      show version
"""

import math, docopt, strutils, logging, strformat, sequtils, nre, times, os
import smath, sutil, fieldfilepath

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

proc calc*(x: openArray[float], parcentileNum: int): CalcResult =
  ## calc は件数、最小値、最大値、合計値、平均値、中央値、パーセンタイル値を計算する
  result = CalcResult(count: x.len, min: x.min, max: x.max, sum: x.sum, average: x.sum / x.len.toFloat, median: x.median, parcentile: x.parcentile(parcentileNum))

proc calcInput*(input: File, parcentileNum: int, ignoreHeaderCount: int = 0): CalcResult =
  ## calcInput はファイル、あるいは標準入力を計算して返す
  ## 不正なデータが混じっていた場合は warn を出力するが処理自体は継続する
  var n = ignoreHeaderCount
  let lines = input.readLines
  if n < 0:
    n = 0
  if lines.len - 1 < n:
    n = lines.len - 1
  var vals: seq[float]
  for v in lines[n..lines.len - 1]:
    try:
      vals.add v.parseFloat
    except ValueError:
      warn &"不正な入力値:value={v}"
  result = vals.calc(parcentileNum)

proc processInput*(files: openArray[string], parcentileNum: int, ignoreHeaderCount: int = 0): seq[CalcResult] =
  ## processInput はファイルがあればファイルを処理、なければ標準入力を処理
  if files.len < 1:
    result.add stdin.calcInput(parcentileNum, ignoreHeaderCount=ignoreHeaderCount)
    return
  for fp in files:
    var f: File
    try:
      f = fp.open FileMode.fmRead
      var ret = f.calcInput(parcentileNum, ignoreHeaderCount=ignoreHeaderCount)
      ret.fileName = fp
      result.add ret
    finally:
      if f != nil:
        f.close

proc processFieldFilePath*(ps: openArray[FieldFilePath], inDelimiter: string, parcentileNum: int, ignoreHeaderCount: int = 0): seq[CalcResult] =
  ## processFieldFilePath はフィールド番号を指定してファイルを集計する
  for v in ps:
    let i = v.fieldIndex
    var f: File
    try:
      f = v.filePath.open FileMode.fmRead
      let lines = f.readLines
      var 
        vals: seq[float]
        res: CalcResult
      for v in lines[ignoreHeaderCount..lines.len - 1]:
        try:
          vals.add v.split(inDelimiter)[i-1].parseFloat
        except IndexError:
          warn &"フィールド数が不足:value={v}"
        except ValueError:
          warn &"不正な入力値:value={v}"
      res = vals.calc(parcentileNum)
      res.fileName = v.filePath
      result.add res
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
  
  # ヘッダレコードの追加
  if headerFlag:
    var header: seq[string]
    if not noFileNameFlag and
        arr.filterIt(it.fileName != "").len != 0:
      header.add "filepath"
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
    var record: seq[string]
    if not noFileNameFlag and v.fileName != "":
      record.add v.fileName
    if countFlag: record.add $(v.count)
    if minFlag: record.add $(v.min)
    if maxFlag: record.add $(v.max)
    if sumFlag: record.add $(v.sum)
    if averageFlag: record.add $(v.average)
    if medianFlag: record.add $(v.median)
    if parcentileFlag: record.add $(v.parcentile)
    records.add record.join(outDelimiter)

  result = records.join("\n")

proc isTrueParam(args: Table[string, Value], key: string): bool =
  ## isTrueParam はdocoptの引数がtrueかどうかを判定して返す
  result = parseBool($args[key])

proc validDefaultParamAndFormat(res: seq[CalcResult], args: Table[string, Value]): string =
  ## validDefaultParamAndFormat はdocoptの引数の特定の組み合わせの時にオプション引数をtrueにしてから計算する。
  ## 以下のいずれもfalseの場合は、それらすべてをtrueに変更して計算する(デフォルト値)
  ## - count
  ## - min
  ## - max
  ## - sum
  ## - average
  ## - median
  ## 目的としては wc コマンドみたいに指定しないときは出力するけれど
  ## 一つでも指定したら指定したフィールドだけ出力するようにしたいため
  result = if args.isTrueParam("--count") or 
      args.isTrueParam("--min") or 
      args.isTrueParam("--max") or 
      args.isTrueParam("--sum") or 
      args.isTrueParam("--average") or 
      args.isTrueParam("--median"):
    res.format(
        noFileNameFlag = parseBool($args["--nofilename"]),
        countFlag = parseBool($args["--count"]),
        minFlag = parseBool($args["--min"]),
        maxFlag = parseBool($args["--max"]),
        sumFlag = parseBool($args["--sum"]),
        averageFlag = parseBool($args["--average"]),
        medianFlag = parseBool($args["--median"]),
        parcentileFlag = parseInt($args["--parcentile"]) != 0,
        parcentileNum = parseInt($args["--parcentile"]),
        headerFlag = parseBool($args["--header"]),
        outDelimiter = $($args["--outdelimiter"]).replace("\\t", "\t"))
   else:
    res.format(
        noFileNameFlag = parseBool($args["--nofilename"]),
        countFlag = true,
        minFlag = true,
        maxFlag = true,
        sumFlag = true,
        averageFlag = true,
        medianFlag = true,
        parcentileFlag = parseInt($args["--parcentile"]) != 0,
        parcentileNum = parseInt($args["--parcentile"]),
        headerFlag = parseBool($args["--header"]),
        outDelimiter = $($args["--outdelimiter"]).replace("\\t", "\t"))

proc initLogger(args: Table[string, Value]) =
  ## initLoggerはロガーを初期化する
  ## オプション引数に指定があれば全ログレベルを出力するフラグをたてる
  var lvl: logging.Level
  if parseBool($args["--debug"]):
    lvl = lvlAll
  else:
    lvl = lvlInfo
  var L = newConsoleLogger(lvl, fmtStr = "$datetime [$levelname]$appname:")
  addHandler(L)

if isMainModule:
  let
    args = docopt(doc, version = "v1.0.0")
    files = @(args["<filepath>"])
    fieldFilePaths = @(args["--fieldfilepath"])
  initLogger args
  debug "args:", args

  # 引数を解析して計算結果を取得
  # --filedfilepath指定があった場合は、<fielpath>...指定があったとしても、--fieldfilepathを優先
  var res: seq[CalcResult]
  if 0 < fieldFilePaths.len:
    let ffps = fieldFilePaths.mapIt(it.parse)
    debug "ffps:", ffps
    try:
      res = ffps.processFieldFilePath($args["--indelimiter"], parseInt($args["--parcentile"]))
    except:
      let
        msg = getCurrentExceptionMsg()
        errMsg = &"何らかのエラー: filedFilePaths={ffps}, error={msg}"
      error errMsg
      quit 1
  else:
    try:
      res = files.processInput(parseInt($args["--parcentile"]), parseInt($args["--ignoreheader"]))
    except IOError:
      let
        msg = getCurrentExceptionMsg()
        errMsg = &"ファイル読み込みに失敗: filePath={files}, error={msg}"
      error errMsg
      quit 1
  debug "res:", res

  # オプション引数に応じて出力結果を整形
  # 特定のオプションの指定がない場合は全部trueにする
  let outData = res.validDefaultParamAndFormat(args)
  debug "outData:", outData

  # 出力先指定がなければ標準出力
  # あったらファイル出力
  if not args["--outfile"]:
    echo outData
    quit 0

  let outFilePath = $args["--outfile"]
  try:
    let f = outFilePath.open FileMode.fmWrite
    defer: f.close
    f.write outData
  except IOError:
    let
      msg = getCurrentExceptionMsg()
      errMsg = &"ファイル出力に失敗: outFilePath={outFilePath}, error={msg}"
    error errMsg
    quit 2