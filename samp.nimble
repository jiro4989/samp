# Package

version       = "0.1.0"
author        = "jiro4989"
description   = "sum average median parcentile"
license       = "MIT"

# Dependencies

requires "nim >= 0.17.2"
requires "docopt >= 0.6.7"

srcDir        = "src"
binDir        = "bin"
bin           = @[ "samp" ]
skipDirs      = @[ "tests" , "util" ]
