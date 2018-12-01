import samp, unittest

let x10 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

suite "parcentile":
  test "1 == [1, 2, 3] 0":
    check(1 == [1, 2, 3].parcentile(0))
  test "2 == [1, 2, 3] 50":
    check(2 == [3, 2, 1].parcentile(50))
  test "細かい値":
    check(0.55 == x10.parcentile(5))
    check(5.5 == x10.parcentile(50))
    check(10 == x10.parcentile(95))
    check(3 == [1, 2, 3].parcentile(100))
  test "元データ量が少ない場合":
    check(1 == [1].parcentile(0))
    check(1 == [1].parcentile(100))
  test "if num < 0 then min value":
    check(2 == [9, 3, 2].parcentile(-1))
  test "if 100 < num then max value":
    check(9 == [9, 3, 2].parcentile(101))

suite "median":
  test "normal":
    check(2 == [1, 2, 3].median)
    check(2 == [3, 2, 1].median)
    check(2.5 == [3, 4, 2, 1].median)

suite "calc":
  test "normal":
    check(CalcResult(fileName: "", count: 10, min: 1.0, max: 10.0, sum: 55.0, average: 5.5, median: 5.5, parcentile: 10.0) == x10.calc(95))

suite "calcInput":
  test "normal":
    discard

suite "processInput":
  test "normal":
    discard

suite "format":
  test "normal":
    discard