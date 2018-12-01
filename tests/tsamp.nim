import samp, unittest

let
  zeroArray: seq[float] = @[]
  x10 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]
  testFile1 = "tests/1_100.txt"
  testFile2 = "tests/1_100_illegal.txt"

suite "parcentile":
  test "normal":
    check(0.55 == x10.parcentile(5))
    check(2 == [3, 2, 1].parcentile(50))
    check(5.5 == x10.parcentile(50))
    check(10 == x10.parcentile(95))
  test "a little datas":
    check(0 == zeroArray.parcentile(0))
    check(1 == [1].parcentile(0))
    check(1 == [1].parcentile(50))
    check(1 == [1].parcentile(100))
  test "boundary":
    check(2 == [9, 3, 2].parcentile(-1))
    check(1 == [1, 2, 3].parcentile(0))
    check(3 == [1, 2, 3].parcentile(100))
    check(9 == [9, 3, 2].parcentile(101))
    check(9 == [9, 3, 2].parcentile(65535))

suite "median":
  test "normal":
    check(2 == [1, 2, 3].median)
    check(2 == [3, 2, 1].median)
    check(2.5 == [3, 4, 2, 1].median)

suite "calc":
  test "normal":
    check(CalcResult(fileName: "", count: 10, min: 1.0, max: 10.0, sum: 55.0, average: 5.5, median: 5.5, parcentile: 10.0) == x10.calc(95))

suite "calcInput":
  setup:
    let f = testFile1.open FileMode.fmRead
    let f2 = testFile2.open FileMode.fmRead
  teardown:
    f.close
  test "args is stdin":
    # TODO
    discard
  test "args is file":
    check(CalcResult(count: 100, min: 1.0, max: 100.0, sum: 5050.0, average: 50.5, median: 50.5, parcentile: 95.95) == f.calcInput(95))
  test "if data file has illegal value then handle error (no panic)":
    check(CalcResult(count: 100, min: 1.0, max: 100.0, sum: 5050.0, average: 50.5, median: 50.5, parcentile: 95.95) == f2.calcInput(95))

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
    check([x] == [testFile1, "hogefuga"].processInput(95))

suite "format":
  setup:
    let x = [CalcResult(fileName: testFile1, count: 100, min: 1.0, max: 100.0, sum: 5050.0, average: 50.5, median: 50.5, parcentile: 95.95)]
  test "only count":      check("100" == x.format(countFlag = true))
  test "only min":        check("1.0" == x.format(minFlag = true))
  test "only max":        check("100.0" == x.format(maxFlag = true))
  test "only sum":        check("5050.0" == x.format(sumFlag = true))
  test "only average":    check("50.5" == x.format(averageFlag = true))
  test "only median":     check("50.5" == x.format(medianFlag = true))
  test "only parcentile": check("95.95" == x.format(parcentileFlag = true))
  test "all column":
    check("100\t1.0\t100.0\t5050.0\t50.5\t50.5\t95.95" == x.format(countFlag = true, minFlag = true, maxFlag = true, sumFlag = true, averageFlag = true, medianFlag = true, parcentileFlag = true))
  test "all column and show header":
    check("count\tmin\tmax\tsum\taverage\tmedian\t95parcentile\n100\t1.0\t100.0\t5050.0\t50.5\t50.5\t95.95" == x.format(headerFlag = true, countFlag = true, minFlag = true, maxFlag = true, sumFlag = true, averageFlag = true, medianFlag = true, parcentileFlag = true))