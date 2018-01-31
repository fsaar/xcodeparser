![](https://img.shields.io/badge/Swift-4.0-orange.svg)
[![Travis Build Status](https://api.travis-ci.org/fsaar/filesize.svg?branch=master)](https://travis-ci.org/fsaar/filesize)
[![Bitrise Build Status](https://www.bitrise.io/app/6626b695887233f1.svg?token=ostvy4rBmYUNq6w1gatnBA&branch=master)](https://www.bitrise.io/app/6626b695887233f1)
[![Code Coverage](https://codecov.io/gh/fsaar/filesize/coverage.svg?branch=master)](https://codecov.io/gh/fsaar/filesize/branch/master)
[![Code Climate](https://codeclimate.com/github/fsaar/filesize/badges/gpa.svg)](https://codeclimate.com/github/fsaar/filesize)
[![codebeat badge](https://codebeat.co/badges/4ab21651-9ae0-423b-a49f-412427a2d2d5)](https://codebeat.co/projects/github-com-fsaar-filesize-master)

# filesize

### Tool to list files that have more than \<limit> number of lines
### Use it to find technical debt. Often in projects maintained about several years files and classes tend to grow. To find those files in Objective-C that have more than a 1000 lines use
~~~~
    fileize . --limit 1000 --objc
~~~~
If only Swift files need to be considered use
~~~~
    fileize . --limit 1000 --swift
~~~~
For Swift and Objective-C files drop the filetype option and just write
~~~~
    fileize . --limit 1000
~~~~

In general the format is as follows
~~~~ 
    filesize <path> --limit <number> --<Options>
    Options:
        --swift: consider only swift files
        --objc: consider only objc files
        --help: this help
~~~~

To build from source code use
~~~~
swift build -Xswiftc "-target" -Xswiftc "x86_64-apple-macosx10.12"  -Xswiftc -static-stdlib -c release
~~~~
