# DMBM, a bookmarking extension for dmenu using bash

*DISCLAIMER: Read this code with a grain of salt.
It is not production code, and nowhere near as optimized for efficiency as
dmenu.*

## What is it?

I like bookmarks. I use bookmarks a lot. What I don't like about bookmarks,
is that they are integrated into whatever browser I happen to be using at the
time. 

DMBM is my attempt at circumnavigating browser-dependent bookmarks, while
integrating them seamlessly into dmenu.

DMBM saves your bookmarks as plain text files, which is nice for versioning.
It also supports folder structures, so you can organize your bookmarks to
your heart's delight.

## Usage:

Using DMBM is straight-forward and should be easy to pick up quickly.
It consists of two commands:
- `dmbm`, which asks the user which bookmark they want, and then outputs it to
wherever the user has focused (see examples below)
- `dmbm-add`, which grabs the current selection and prompts the user about
where to save the bookmark

## Installing:

### .deb package
To install using the .deb package, download the latest [RELEASE](link-somewhere),
`cd` to your `Downloads` folder (or wherever you saved the package) and run
`apt install ./dmbm.deb`.


