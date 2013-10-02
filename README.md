# Veye

[VersionEye](http://www.versioneye.com/) is a cross-platform search engine and crowdsourcing app for opensource software libraries. 

 * Take advantage of the extended search to find any library you look for. 
 * Follow and track your favorite software packages via RSS feed.
 * Leave comments and add additional meta information to the libraries to improve the quality of the data. 
 * Contribute to this crowdsourcing project to make the world a better place for software developers.


**veye** is commandline tool to make all this available on command-line and manipulate results with awesome tools and scripts. 

**PS:** Our _premium customers_ can also use offline search. Please send your email to `contact@versioneye.com` to get more information.

Most endpoints require the api-key, which you can get it [here](https://www.versioneye.com/settings/api).

![Main help](http://dl.dropbox.com/u/19578784/versioneye/cli_start_page.png)


### Setup

###### Gem

```
  $> 
```

###### Download source
 ```bash
  $> git clone https://github.com/versioneye/veye.git
  $> cd veye
 ```

###### Run without installing
 ```
  $> bundle
  $> bundle exec bin/veye ping
 ```
 
###### Or build Gem file and install it as global command

  ```
  $> gem build veye.gemspec
  $> veye help
  $> veye ping
  ```
 
###### Set up default configuration

  ```bash
  $> veye initconfig
  #it creates configuration file for VersionEye CLI
  $> cat ~/.veye.rc
  
  :api_key: <add your key>
  :server: 127.0.0.1
  :port: "3000"
  ....
  ```

# Basic usage


### Check service 

 ```bash
   $> veye ping
   pong
 ```

### Search packages 

###### Get command help

 ```bash
   $> veye search help
 ```
 
###### Basic package search with language filtering

 ```bash
   $> veye search junit
   $> veye search -l java
   $> veye search --language java
   $> veye search --language-name=java
   
   #search packages for multiple languages
   $> veye search --lang=nodejs,php
 ```

###### Use result paging

  ```
    $> veye search junit --page 2
    $> veye search junit --page-number=2
    $> veye search json --lang=r,php --page=2
    
    #you can cancel pagination with --no-pagination argument
    $> veye search junit --page 3 --no-pagination
  ```

###### Use different output format

**pretty print** - human readable output
 
```bash
  $> veye search json --format=pretty
```
 
  ![Pretty format](https://s3-eu-west-1.amazonaws.com/veye/search_format_pretty.png)
 
 **csv** - to pipeline output to [awk](http://www.gnu.org/software/gawk/manual/gawk.html)
 
 ```bash
  $> veye search json --format=csv
 ```

 ![CSV format](https://s3-eu-west-1.amazonaws.com/veye/search_format_csv.png)

 **json** - for manipulating results with [jq](http://stedolan.github.com/jq/) . 
 Check out our jq recipes in [wiki](https://github.com/versioneye/veye/wiki/jq-recipes) .
 
 
 ```bash
  $> veye search json --format=json
 ```
 
 ![Json format](https://s3-eu-west-1.amazonaws.com/veye/search_format_json.png)
 
 **table view**
 
 ```bash
  $> veye search json --format=table
 ```
 ![Table output](https://s3-eu-west-1.amazonaws.com/veye/search_format_table.png)
 

###### Empty response

There will be situation, when [VersionEye](http://versioneye.com) dont have information about your search, then you will see similar response on commandline:

  ```
  No results for 'json' with given parameters: 
  {:q=>"json", :lang=>"python", :page=>1}
  ```
  
### Global options

You can override your default global options by adding proper keyword and value.
For example to override a number of port, when doing search:

```
  $> veye --port=4567 search json --lang=php,nodejs
```

### Package information

It supports also `--format` flag with same values.

  ```
    $> veye info junit/junit
    Asking information about: junit/junit
  ```
  
  ![Pretty print](https://s3-eu-west-1.amazonaws.com/veye/info_format_pretty.png)
  

### Products 

This command has subcommands to control your personal connections with libraries.

```
	;;follow some package to add it into your RSS feed
	$> veye products follow clojure/ztellman/aleph
	$> veye products unfollow clojure/ztellman/aleph
	
	;; show the list of products in your's RSS feed
	$> veye products
```

### Project

`project` command holds a multiple subcommands for working with our project files.

###### show existing projects

```
  $> veye project list
  $> veye project --format=table
```

###### show information of specific project
A `show` command expects a proper project_key, which you can from the list of already existing projects.

```
	$> veye project show rubygem_gemfile_1
	$> veye project show rubygem_gemfile_1 --format=table
```

###### upload project file
Use `upload` command to create new project. This command expects proper filepath to the file and the file is smaller than 500KB. VersionEye supports currently 8 different package managers(*Leiningen, Gem, Maven, NPM, Packagist, Pip, Setup.py, R*), Bower and Obj-C is already on pipeline.

```
  $> veye project upload test/files/Gemfile
  $> veye project upload test/files/maven.pom
```

###### re-upload project file for existing project

You can use `update` command to update the information of already existing project.
This command expects correct project_key and a path to file.

```
  $> veye project update rubygem_gemfile_1 test/files/Gemfile
  $> veye project update rubygem_gemfile_1 test/files/Gemfile --format=table
```


#####
;;;todo
;;;licences


### Me
;;; todo

