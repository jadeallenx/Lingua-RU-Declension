#!/usr/bin/env perl
#PODNAME: mkflash.pl
#ABSTRACT: Generate comma seperated files for importing into Anki for flashcards

=head1 NAME mkflash.pl

=head1 SYNOPSIS

    $ mkflash.pl acc [plural]

=head1 OVERVIEW

This is a script to generate a file which will create some flashcards for use with
L<Anki|https://apps.ankiweb.net/>.

=cut

use 5.014;
use utf8;

use Lingua::RU::Declension;
use charnames ();
use Text::CSV qw(csv);

binmode STDOUT, ":utf8";

die "Supply a case\n" if (scalar @ARGV < 1);

my $case = $ARGV[0];
my $plural = defined $ARGV[1] ? 1 : 0;
my $arrow = charnames::string_vianame("RIGHTWARDS ARROW"); # →

sub cju {
    my ($type, $word) = @_;
    my $endpoint = $type eq "noun" ? "run" : "rua";

    return "https://cooljugator.com/$endpoint/$word";
}

my $rus = Lingua::RU::Declension->new();

my @out;
for (1..50) {
    # We will select our random words in "dictionary form" (nominative masculine singular)
    my $noun = $rus->choose_random_noun();
    my $adj = $rus->choose_random_adjective();
    my $pronoun = $rus->choose_random_pronoun();

    # We will use the nominative case for the front of the card
    # so that the phrase on the front of the card is grammatically
    # correct.
    my $np = $rus->decline_pronoun($pronoun, $noun, "nom", $plural);
    my $na = $rus->decline_adjective($adj, $noun, "nom", $plural);
    my $nn = $rus->decline_noun($noun, "nom", $plural);

    # Then the back of the card will use our input case
    my $dp = $rus->decline_pronoun($pronoun, $noun, $case, $plural);
    my $da = $rus->decline_adjective($adj, $noun, $case, $plural);
    my $dn = $rus->decline_noun($noun, $case, $plural);

    my $front = "$np $na $nn ($case)";
    my $adj_url = cju("adj", $adj);
    my $noun_url = cju("noun", $noun);
    my  $back = qq|$dp $da $dn<br>$np $arrow $dp ($pronoun)<br>$na $arrow $da (<a href="$adj_url">$adj</a>)<br>$nn $arrow $dn (<a href="$noun_url">$noun</a>)|;
    push @out, [$front, $back];
}

csv( in => \@out, out => "${case}_flash.csv", encoding => "UTF-8" );
