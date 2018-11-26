# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "sum average median parcentile"
license       = "MIT"

# Dependencies

requires "nim >= 0.17.2"

srcDir        = "src"                     # ソースフォルダ
binDir        = "bin"                     # 実行モジュールを配置するフォルダ
bin           = @[ "samp" ]                # アプリケーションファイル名
skipDirs      = @[ "tests" , "util" ]     # nimble install時にスキップするフォルダ
