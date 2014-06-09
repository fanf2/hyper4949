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

my $entry = "\n   \$ ";
my $entre = quotemeta $entry;

$rfc =~ m{^
  (.*\n)
   \n4[.][ ]Definitions\n
   $entre(.*\n)
  (\n5[.][ ]Security[ ]Considerations\n
   \n.*)
}xs;

my ($front,$defs,$back) = ($1,$2,$3);

my @defs = split $entre, $defs;

my %def;
my @key;
for my $def (@defs) {
  # one-line cross-references
  $def =~ s{^([^ \n]+) (See: [^\n]+)$}{$1\n$2};
  # multiple keywords to a definition
  if ($def =~ m{^[^\n]+$}) {
    push @key, $def;
    next;
  }
  die "$def" unless $def =~ m{^([^\n]+)\n(.*)$}s;
  my ($key,$text) = ($1,$2);
  $key =~ s{[(]trademark[)]}{™}g;
  $key =~ s{[(]service mark[)]}{℠}g;
  $key =~ s{, version \d}{};
  $key =~ s{, Inc\.}{};
  $key =~ s{\.$}{};
  $key =~ s{^(.+) [(](algorithm) or (protocol)[)]$}{$1, $1 $2, $1 $3};
  # acromyms at end
  $key =~ s{ [(]([^()]+)[)]$}{, $1};
  # acromyms in middle
  $key =~ s{^(.+) [(]([^( )]+)[)] (.+)$}{$1 $3, $2 $3};
  # avoid treating these as a list
  $key =~ s{^(.+) [(]([^( )]+)[)], (.+)$}{$1, $3, $2};
  # lists
  $key =~ s{, or }{, };
  if ($key =~ m{^([^,]+ )?((\w+, ){2,}\w+)( [^,]+)?$}) {
    my ($pre,$suf) = ($1 || "", $4 || "");
    push @key, map "$pre$_$suf", split m{, }, $2;
  } elsif ($key =~ m{, }) {
    push @key, split m{, }, $key;
  } else {
    push @key, $key;
  }
  $def{$_} = $text for @key;
  undef @key;
}

print map "$_\n", sort keys %def;
