import unittest, fieldfilepath

suite "parse":
  test "normal":
    check(FieldFilePath(fieldIndex: 1, filePath: "test/sample.txt") == "1:test/sample.txt".parse)
  test "strip whitespace":
    check(FieldFilePath(fieldIndex: 2, filePath: "foobar.txt") == "   2  :\n \t  foobar.txt    ".parse)
  test "(-1, hoge.txt) == foobar:hoge.txt":
    check(FieldFilePath(fieldIndex: -1, filePath: "hoge.txt") == "foobar:hoge.txt".parse)
  test "(0, hoge.txt) == hoge.txt":
    check(FieldFilePath(fieldIndex: 0, filePath: "hoge.txt") == "hoge.txt".parse)
