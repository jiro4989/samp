import unittest, smath

let
  zeroArray: seq[float] = @[]
  x10 = [1.0, 2.0, 3.0, 4.0, 5.0, 6.0, 7.0, 8.0, 9.0, 10.0]

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
