package xt::Test;
use strict; use warnings;

use Pegex::Parser;
use Pegex::Pegex::Grammar;
use Test::More;
use IO::All;
use Time::HiRes qw(gettimeofday tv_interval);

my $time;

use base 'Exporter';
our @EXPORT = qw(
    pegex_parser
    slurp
    test_grammar_paths
    gettimeofday
    tv_interval
    XXX
);

use constant TEST_GRAMMARS => [
    '../pegex-pgx/pegex.pgx',
    '../testml-pgx/testml.pgx',
    '../json-pgx/json.pgx',
    '../yaml-pgx/yaml.pgx',
    '../drinkup/share/drinkup.pgx',
    '../SQL-Parser-Neo/pegex/pg-lexer.pgx',
    '../SQL-Parser-Neo/pegex/Pg.pgx',
];

sub pegex_parser {
    my ($grammar) = @_;
    return Pegex::Parser->new(
        grammar => Pegex::Pegex::Grammar->new,
    );
}

sub slurp {
    my ($path) = @_;
    return scalar io->file($path)->all;
}

sub test_grammar_paths {
    my @paths;
    for my $grammar_source (@{TEST_GRAMMARS()}) {
        my $grammar_file = check_grammar($grammar_source)
            or next;
        push @paths, $grammar_file;
    }
    plan skip_all => 'No local grammars found to test'
        unless @paths;
    return @paths;
}

#-----------------------------------------------------------------------------#
sub check_grammar {
    my ($source) = @_;
    return unless -e $source;
    (my $file = $source) =~ s!.*/!!;
    my $path = "./xt/grammars/$file";
    if (not -e $path) {
        diag "$path not found. Copying from $source\n";
        copy_grammar($source, $path);
    }
    elsif (slurp($source) ne slurp($path)) {
        diag "$path is out of date. Copying from $source\n";
        copy_grammar($source, $path);
    }
    return $path;
}

sub copy_grammar {
    my ($source, $target) = @_;
    io->file($target)->assert->print(slurp($source));
}

1;