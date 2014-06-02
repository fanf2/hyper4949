#!/usr/bin/perl

use warnings;
use strict;

use File::Slurp;

my $rfc = read_file("rfc4949.txt", err_mode => 'carp');

my @pages = split m{
  # trailing blank lines
  \n+
  # footer
  Shirey[ ]+
  Informational[ ]+
  [[]Page[ ]+[0-9]+[]]
  # page break
  \n\f\n
  # header
  RFC[ ]4949[ ]+
  Internet[ ]Security[ ]Glossary,[ ]
  Version[ ]2[ ]+
  August[ ]2007
  # leading blank lines
  \n+
}x, $rfc;

for my $page (@pages) {
  # add a newline if the page continues the previous one
  $page = "\n".$page unless $page =~ m{^
  ([ ]{3,6}[(]?[a-z]
  |[ ]{6}-[ ]{2}
  # after footer 69
  |[ ]{6}Subcommittee[ ]27[ ]
  # after footer 75
  |[ ]{6}Information[ ]Security[ ]Foundation[ ]
  # after footer 113
  |[ ]{6}Usage"[ ]extension,[ ]
  # after footer 207 and 339 and 340
  |[ ]{6}[67][.][ ]
  # after footer 226
  |[ ]{6}Instead,[ ]
  )}x;
}

$rfc = join "\n", @pages;

print $rfc;
