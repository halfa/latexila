Guidelines for LaTeXila
=======================

LaTeXila source code is maintained using the Git version control system and is
available at the following location:

    git://git.gnome.org/latexila

A web interface is available at:

    http://git.gnome.org/browse/latexila

You can download the source code from the Git repository by doing:

    $ git clone git://git.gnome.org/latexila

Later, to take the new commits you just have to do:

    $ git pull

An easy way to build LaTeXila and its dependencies is to use jhbuild
(gnome-world moduleset). Example of a jhbuildrc file for LaTeXila:

    https://people.gnome.org/~swilmet/latexila/jhbuildrc

Commits
=======

To create a patch, make first one or several commits (in another branch) and
then use the 'git format-patch' command. You can submit your patch to the
GNOME bugzilla.

A GitHub repository is available, so you can fork it easily:

    https://github.com/GNOME/latexila

Git commits should have maximum 72 characters for the first line, followed by a
blank line and then a longer description.

Code conventions
================

For consistency, there are some conventions to follow when coding.

For Vala and C:
    - no trailing spaces
    - use blank lines to space out blocks of code (only one blank line is enough)
    - as a general rule of thumb, when modifying a file use the same coding
      style of that file.

For Vala:
    - indentation: 4 spaces
    - lines: 90 characters maximum (in some cases it can be a little more)
    - /* ... */ comments for delimiting code sections
    - // ... comments otherwise (e.g. for explaining just one line)
    - some spaces almost everywhere:
        - function (blah);                // not function(blah);
        - int num = 5;                    // not int num=5;
        - if (! foo)                      // not if (!foo)
        - for (int i = 0 ; i < max ; i++) // not for(int i=0;i<max;i++)
        - etc...
    - do not use 'var' for declaring variables, unless the type is very long.
      The type of a variable is a form of auto-documentation.

For C:
    - follow the GLib/GTK+ conventions:
      https://wiki.gnome.org/Projects/GTK%2B/BestPractices
    - indentation: GNU style
    - no maximum line length (but short lines are better)
    - only /* ... */ comments (for C89 compatibility)
    - spacing differences with Vala:
    	- if (!foo)
	- for (int i = 0; i < max; i++)

Debug
=====

How to debug LaTeXila with gdb?
    Build LaTeXila with the option -g in the CFLAGS.

    Here is how you can get the backtrace after a crash:
    $ gdb latexila
    > run
    [segmentation fault]
    > backtrace
    > quit
