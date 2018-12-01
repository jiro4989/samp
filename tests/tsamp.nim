import samp, unittest

suite "parcentile":
  test "normal":
    check(1 == [1, 2, 3].parcentile(0))
    check(2 == [3, 2, 1].parcentile(50))
  test "細かい値":
    check(0.55 == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].parcentile(5))
    check(5.5 == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].parcentile(50))
    check(10 == [1, 2, 3, 4, 5, 6, 7, 8, 9, 10].parcentile(95))
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
    discard

suite "calcInput":
  test "normal":
    discard

suite "processInput":
  test "normal":
    discard

suite "format":
  test "normal":
    discard