import unittest, samp, fieldfilepath, strformat

let
  zeroArray: seq[float] = @[]
  x10 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  testFile1 = "tests/1_100.txt"
  testFile2 = "tests/1_100_illegal.txt"
  testFile3 = "tests/1_100_header.txt"
  csvFile1 = "tests/1_100.csv"

suite "calc":
  test "normal":
    check(CalcResult(fileName: "", count: 10, min: 1.0, max: 10.0, sum: 55.0, average: 5.5, median: 5.5, parcentile: 10.0) == x10.calc(95))

suite "calcInput":
  setup:
    let
      f = testFile1.open FileMode.fmRead
      f2 = testFile2.open FileMode.fmRead
      f3 = testFile3.open FileMode.fmRead
      res1 = CalcResult(count: 100, min: 1.0, max: 100.0, sum: 5050.0, average: 50.5, median: 50.5, parcentile: 95.95)
      res2 = CalcResult(count: 99, min: 2.0, max: 100.0, sum: 5049.0, average: 51.0, median: 51.0, parcentile: 96.0)
  teardown:
    f.close
    f2.close
    f3.close
  test "args is stdin":
    # TODO
    discard
  test "args is file":
    check(res1 == f.calcInput(95))
  test "ignore 1 header":
    check(res2 == f.calcInput(95, ignoreHeaderCount=1))
  test "if data file has illegal value then handle error (no panic)":
    check(res1 == f2.calcInput(95))
  test "ignore 2 header":
    check(res2 == f3.calcInput(95, ignoreHeaderCount=2))
  test "ignore 0 == ignore -1":
    check(res1 == f.calcInput(95, ignoreHeaderCount = -1))
  test "0 == ignore 65535":
    check(CalcResult(count: 1, min: 100.0, max: 100.0, sum: 100.0, average: 100.0, median: 100.0, parcentile: 100.0) == f3.calcInput(95, ignoreHeaderCount=65535))

suite "processInput":
  setup:
    let x = CalcResult(fileName: testFile1, count: 100, min: 1.0, max: 100.0, sum: 5050.0, average: 50.5, median: 50.5, parcentile: 95.95)
  test "stdin":
    # TODO
    discard
  test "existing files":
    check([x] == [testFile1].processInput(95))
    check([x, x] == [testFile1, testFile1].processInput(95))
  test "not existing files":
    expect(IOError):
      discard [testFile1, "hogefuga"].processInput(95)

suite "processFieldFilePath":
  setup:
    let x1 = CalcResult(fileName: csvFile1, count: 100, min: 1.0, max: 100.0, sum: 5050.0, average: 50.5, median: 50.5, parcentile: 95.95)
    let x2 = CalcResult(fileName: csvFile1, count: 99, min: 2.0, max: 100.0, sum: 5049.0, average: 51.0, median: 51.0, parcentile: 96.0)
    let x3 = CalcResult(fileName: csvFile1, count: 100, min: 1.0, max: 10000.0, sum: 338350.0, average: 3383.5, median: 2550.5, parcentile: 9206.45)
  test "normal":
    check([x1] == [FieldFilePath(fieldIndex: 2, filePath: csvFile1)].processFieldFilePath(",", 95))
    check([x3] == [FieldFilePath(fieldIndex: 3, filePath: csvFile1)].processFieldFilePath(",", 95))
  test "ignore 1 header":
    check([x2] == [FieldFilePath(fieldIndex: 2, filePath: csvFile1)].processFieldFilePath(",", 95, ignoreHeaderCount = 1))

suite "format":
  setup:
    let x = [CalcResult(fileName: testFile1, count: 100, min: 1.0, max: 100.0, sum: 5050.0, average: 50.5, median: 50.5, parcentile: 95.95)]
  test "only count":      check(&"{testFile1}\t100" == x.format(countFlag = true))
  test "only min":        check(&"{testFile1}\t1.0" == x.format(minFlag = true))
  test "only max":        check(&"{testFile1}\t100.0" == x.format(maxFlag = true))
  test "only sum":        check(&"{testFile1}\t5050.0" == x.format(sumFlag = true))
  test "only average":    check(&"{testFile1}\t50.5" == x.format(averageFlag = true))
  test "only median":     check(&"{testFile1}\t50.5" == x.format(medianFlag = true))
  test "only parcentile": check(&"{testFile1}\t95.95" == x.format(parcentileFlag = true))
  test "no filepath":     check("95.95" == x.format(parcentileFlag = true, noFileNameFlag = true))
  test "only count and show header":
    check(&"filepath\tcount\n{testFile1}\t100" == x.format(headerFlag = true, countFlag = true))
  test "all column":
    check(&"{testFile1}\t100\t1.0\t100.0\t5050.0\t50.5\t50.5\t95.95" == x.format(countFlag = true, minFlag = true, maxFlag = true, sumFlag = true, averageFlag = true, medianFlag = true, parcentileFlag = true))
  test "all column and show header":
    check(&"filepath\tcount\tmin\tmax\tsum\taverage\tmedian\t95parcentile\n{testFile1}\t100\t1.0\t100.0\t5050.0\t50.5\t50.5\t95.95" == x.format(headerFlag = true, countFlag = true, minFlag = true, maxFlag = true, sumFlag = true, averageFlag = true, medianFlag = true, parcentileFlag = true))
  test "all column and change separator":
    check(&"{testFile1},100,1.0,100.0,5050.0,50.5,50.5,95.95" == x.format(countFlag = true, minFlag = true, maxFlag = true, sumFlag = true, averageFlag = true, medianFlag = true, parcentileFlag = true, outDelimiter = ","))
  test "all column and change separator and show header":
    check(&"filepath,count,min,max,sum,average,median,95parcentile\n{testFile1},100,1.0,100.0,5050.0,50.5,50.5,95.95" == x.format(headerFlag = true, countFlag = true, minFlag = true, maxFlag = true, sumFlag = true, averageFlag = true, medianFlag = true, parcentileFlag = true, outDelimiter = ","))
  test "all column and change separator and show header and no header":
    check(&"count,min,max,sum,average,median,95parcentile\n100,1.0,100.0,5050.0,50.5,50.5,95.95" == x.format(headerFlag = true, countFlag = true, minFlag = true, maxFlag = true, sumFlag = true, averageFlag = true, medianFlag = true, parcentileFlag = true, outDelimiter = ",", noFileNameFlag = true))