# NAME
    DupFind.pl - Tool for automated find duplicate files at specified directories.

# SYNOPSIS:
    DupFind.pl [path1 [path2 [path3 [...]]]] [-o:outfile] [-v] [-r]
    DupFind.pl --help

## Options:
* __path1, path2, path3, ...__
        Specify root directory, or list of directories, in which we scan for
        files. Used current directory if omitted.

* __outfile__
        Output file, where information about duplicates will be saved.

* __-v__  Verbose output

* __-r__  Disable recursively scan from specified folder(s). By default
        program scan for duplicates from specified root folder(s) as deep as
        possible.

* __--help__
        This help screen

# AUTHOR
    Copyright (c) 2009, An0ther0ne. This tool is free software. You can
    redistribute it and/or modify it under the same terms as Perl itself.

# SEE ALSO
    perl(1), Digest::MD5, File::Find.

