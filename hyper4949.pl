#!/usr/bin/perl

use warnings;
use strict;

use File::Slurp;

my $nl = qr{\r?\n};

my $rfc = read_file("rfc4949.txt", err_mode => 'carp');

my @pages = split m{
  # trailing blank lines
  $nl+
  # footer
  Shirey[ ]+
  Informational[ ]+
  [[]Page[ ]+[0-9]+[]]
  # page break
  $nl \f $nl
  # header
  RFC[ ]4949[ ]+
  Internet[ ]Security[ ]Glossary,[ ]
  Version[ ]2[ ]+
  August[ ]2007
  # leading blank lines
  $nl+
}x, $rfc;
