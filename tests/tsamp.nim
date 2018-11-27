import ../src/samp, unittest, lists

suite "parcentile":
  test "normal":
    check(1 == @[1, 2, 3].parcentile(0))
    check(2 == @[3, 2, 1].parcentile(50))
    check(5.5 == @[1, 2, 3, 4, 5, 6, 7, 8, 9, 10].parcentile(50))
    check(3 == @[1, 2, 3].parcentile(100))
    check(1 == @[1].parcentile(0))
    check(1 == @[1].parcentile(100))
  test "if num < 0 then min value":
    check(2 == @[9, 3, 2].parcentile(-1))
  test "if 100 < num then max value":
    check(9 == @[9, 3, 2].parcentile(101))

suite "median":
  test "normal":
    check(2 == @[1, 2, 3].median)
    check(2 == @[3, 2, 1].median)
    check(2.5 == @[3, 4, 2, 1].median)