sundata parser
==============

Parse files from SunData for Windows Mobile and output a csv result.

This initial version is written for a specific situation and could be rebuilt for others.

Getting data into your spreadsheet application as quick as  
`ruby sundata_parser.rb --outfile "sunscan data.csv" "data/site 1 2013.TXT" "data/site 2 2013.TXT"`

## Prerequisites

To use Sundata Parser you'll need:

- A MacOS or Linux computer (Windows has not yet been tested)
- The Ruby language (Recent versions of MacOS have Ruby available by default)
- To be able to use some basic terminal commands

Sundata Parser relies only on the Ruby programming language and its standard library.
You do need Ruby 2.0 or newer installed. To check, run the Terminal command

```
ruby -v
```

The output will be something like

```
ruby 2.3.1p112 (2016-04-26 revision 54768) [x86_64-linux]
```

As log as it says `ruby 2` you should be fine.

## Installation

Download the zip file and extract it somewhere either near your data or within easy reach of your Terminal.

## Running

If your data is in a folder called `sundata` and you've extracted the `sundata-parser.zip` file into directory above you can run the following command to process all data.

```
ruby sundata_parser.rb --outfile sunscan-data.csv sundata/sunscan*.TXT
```

The above example will read all files in the `sundata` directory that begin with `sunscan` and end with `.TXT` (letter case is significant) and write the final output to a file called `sunscan-data.csv`.
Changing the output file or what files to read from requires only that you change those values when entering the command.

`--outfile`: The name of the to write csv output to.  
list of input files: A list of input files should follow the output file. The list is separated by spaces so if you have spaces in your filenames, you will need to quote them. For example:
```
ruby sundata_parser.rb --outfile "sunscan data.csv" "data/site 1 2013.TXT" "data/site 2 2013.TXT"
```
Depending on your terminal environment using [globs](https://en.wikipedia.org/wiki/Glob_%28programming%29) may remove the need for quoting.

The code here is released under [a permissive license](LICENSE). If for some reason you need a separate licensing option please contact me directly.

## Getting help

If you have trouble using this program I'm happy to help you sort it out!
If you have a GitHub.com account already, the best thing to do is open an [issue](https://github.com/nuclearsandwich/sundata-parser/issues/new).
If you don't have a GitHub account you can also email me: <steven@nuclearsandwich.com>.

## Changing the output data

TODO. Contact me via the email address on [my profile](https://github.com/nuclearsandwich) for assistance with this.

## Changing the parsing strategy

TODO. Contact me via the email address on [my profile](https://github.com/nuclearsandwich) for assistance with this.

## Contributing

Contributions and changes are welcome! Feel free to contact me with assistance making changes or if you want to just [submit a pull request](https://help.github.com/articles/creating-a-pull-request/) that's great too.

Because the sunscan data uses carriage return (`CR`, `\r`, `^M`) characters at the end of lines, you may run into issues with your Git configuration and see something like

```
fatal: CRLF would be replaced by LF in test/fixtures/2011-test-output.csv.
```

If you do see that, you can disable autocrlf for just this repository using

```
git config core.autocrlf false
```

#### A note about tests

Because I don't have permission to publish the data I initially wrote this program for, the test currently fail without the provided fixtures.
I will in the future fake some data in order to provide public fixtures.
If you have data to donate I'll gladly use it too, as long as you're able to provide a license to the data compatible with this software's [license](LICENSE) to distribute the test data.
