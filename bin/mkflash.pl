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
my $plural = defined $ARGV[1] ? "plural" : 0;
my $arrow = charnames::string_vianame("RIGHTWARDS ARROW"); # →

sub forvo {
    my ($word) = @_;

    return qq|<a href="https://www.forvo.com/search/$word/">$word</a>|;
}

sub opr {
    my ($word) = @_;

    return qq|<a href="https://en.openrussian.org/ru/$word">$word</a>|;
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
    my $pro_url = opr($pronoun);
    my $adj_url = opr($adj);
    my $noun_url = opr($noun);
    my $answer = join " ", (map {; forvo($_) } ($dp, $da, $dn));
    my $back = qq|$answer<br>$np $arrow $dp ($pro_url)<br>$na $arrow $da ($adj_url)<br>$nn $arrow $dn ($noun_url)|;
    push @out, [$front, $back];
}

my $outname = $plural ? "plural_${case}_flash.csv" : "${case}_flash.csv";
csv( in => \@out, out => $outname, encoding => "UTF-8" );
