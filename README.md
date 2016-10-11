sundata parser
==============

Parse files from SunData for Windows Mobile and output a csv result.

This initial version is written to process a specific set of data.
If you wish to use this for other collections of sundata output that's great!
I can be reached via the email address listed on [my GitHub profile](https://github.com/nuclearsandwich) if you have trouble.

Getting data into your spreadsheet application as quick as  
```
`ruby sundata_parser.rb --outfile "sunscan data.csv" "data/site 1 2013.TXT" "data/site 2 2013.TXT"`
```
The code here is released under [a permissive license](LICENSE). If for some reason you need a separate licensing option please contact me directly.

## Prerequisites

To use Sundata Parser you'll need:

- A macOS or Linux computer (Windows has not yet been tested)
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

As long as it says `ruby 2` you should be fine.

## SunData as a service. :smile:

I want this to be useful.
If you're in a completely Windows environment, don't have access to a supported version of the Ruby programming language, or for any reason aren't comfortable or able to follow the instructions provided that's totally okay!
[Send me an email](mailto:steven@nuclearsandwich.com) and I can either help you through the process or run this on your data for you and give you the result.
I'm exploring ways to make this tool more widely accessible and your feedback would be welcome.


## Installation

Download the zip file and extract it somewhere either near your data or within easy reach of your Terminal.


## Running locally

If your data is in a folder called `sundata` and you've extracted the `sundata-parser.zip` file into directory above you can run the following command to process all data.

```
ruby sundata_parser.rb --outfile sunscan-data.csv sundata/sunscan*.TXT
```

The above example will read all files in the `sundata` directory that begin with `sunscan` and end with `.TXT` (letter case is significant) and write the final output to a file called `sunscan-data.csv`.
Changing the output file or what files to read from requires only that you change those values when entering the command.

`--outfile`: The name of the to write csv output to.  
```
ruby sundata_parser.rb --outfile "sunscan data.csv" "data/file1.TXT" "data/file2.TXT"
```

`--fields`: Which fields to include in the output. By default all fields present in the data are kept.
All fields should be comma separated.
```
ruby sundata_parser.rb --outfile "sunscan data.csv" --fields "site,plot,transmitted,beam,lai,notes" "data/file 1.TXT" "data/file 2.TXT"
```

list of input files: A list of input files should follow the other options.
The list is separated by spaces so if you have spaces in your filenames, you will need to quote them.
```
ruby sundata_parser.rb "data/file 1.TXT" "data/file 2.TXT" data/other.TXT
```

Depending on your terminal environment using [globs](https://en.wikipedia.org/wiki/Glob_%28programming%29) may remove the need for quoting.


## Getting help

If you have trouble using this program I'm happy to help you sort it out!
If you have a GitHub.com account already, the best thing to do is open an [issue](https://github.com/nuclearsandwich/sundata-parser/issues/new).
If you don't have a GitHub account you can also email me directly: <steven@nuclearsandwich.com>.

## Setting which fields are output

By default, all fields that are present for every row will be in the output csv.
You may not need every field collected for your data or you may wish to include fields that only some data entries will have.
To explicitly set which fields should be in the output csv you can set them with the `--fields` option when running via Terminal or as an additional option to the `write_csv` method when running via Ruby script.


#### Specifying fields on the command line.

```
ruby sundata_parser.rb --outfile "sunscan data.csv" --fields "site,plot,transmitted,beam,lai,notes" "data/file 1.TXT" "data/file 2.TXT"
```


#### Specifying fields via Ruby script

```ruby
parser.write_csv(csv_filename, ["site", "plot", "transmitted", "beam", "lai", "notes"])
```


## Adding fields with a pre-processor

It's possible to add situation-specific information using Ruby.
I used this to add two fields to every row based on the name of the original sundata file.

In order to use this, you will need to create a file or modify the template file: `custom_preprocessor.rb` and add your custom information as fields to the rowdata_template.

```ruby
parser.preprocessor do |filename, rowdata_template|
  rowdata_template.original_filename = filename
end
```

## Known issues

This isn't perfect software and it's had real testing on a very limited set of data.
If there are any known issues they'll be listed on the [issues page](https://github.com/nuclearsandwich/sundata-parser/issues).


## Contributing

Contributions and changes are welcome!
Feel free to contact me with assistance making changes or if you want to just [submit a pull request](https://help.github.com/articles/creating-a-pull-request/) that's great too.

Because the sunscan data uses carriage return (`CR`, `\r`, `^M`) characters at the end of lines, you may run into issues with your Git configuration and see something like

```
fatal: CRLF would be replaced by LF in test/fixtures/2011-test-output.csv.
```

If you do see that, you can disable autocrlf for just this repository using

```
git config core.autocrlf false
```


#### A note about tests

Because I don't have permission to publish the data I initially wrote this program for, the test currently use randomly generated sample data.
If you have data to donate I'll gladly use it too, as long as you're able to provide it under a distribution license compatible with this software's [license](LICENSE).
