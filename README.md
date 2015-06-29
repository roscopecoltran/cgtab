# cgtab
cmake-git-thirdparty-and-binarys prof of concept

"if all you have is a hammer, everything looks like a nail"

## Why git

Repositorys on the internet are nice, since they have easy access, but when they became big, 
loading them over mobile data becames less an option.
Sharing big files over usb drives is a lot of manual work, keping the files in sync with coworkers.
The idea is to use a repo in internet and clone on an usb drive, if avaibale the usb drive should be used.
git has some build in features
* alows to habe mutiple remotes
* every repository is self contained

## Test Results

## TODO

*   test how fast a git repository works with binary files, git clone --depth 1 is maybe suitable 
*   split binary files and thirdparty libs in seperate git repository, cmake should then test if the repositorys have the right version
*   very big files could be stored on local storage, cmake could then test diffrent sources for the repository

