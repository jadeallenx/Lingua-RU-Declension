use 5.014;
use utf8;
use strict;
use warnings;

package Lingua::RU::Declension;

use Text::CSV qw(csv);
use File::Share qw(dist_file);
use Carp qw(confess);

# ABSTRACT: Decline Russian pronouns, adjectives and nouns

=encoding utf-8

=head1 SYNOPSIS

    use 5.014;
    use utf8;

    use Lingua::RU::Declension;

    my $rus = Lingua::RU::Declension->new();

    # Decline all words to accusitive case
    my $case = 'acc';
    my $friend = 'друг';
    my $acc_friend = $rus->decline_noun(friend, $case); # друга
    my $acc_new = $rus->decline_adjective('новый', $friend, $case); # нового
    my $acc_our = $rus->decline_pronoun('наш', $friend, $case); # нашeго

    # Я вижу нашeго нового друга!
    say $rus->russian_sentence_stem($case) . " $acc_our $acc_new $acc_friend!";

=head1 OVERVIEW

This module is an attempt to help me understand Russian
grammatical cases. It also has the helpful side effect
of letting me generate flash cards and quizzes on the
topic too.

The data files are UTF-8 encoded comma seperated lines
which contain the various nouns, adjectives and pronouns.
These are read into memory at class instantiation from the
'share' directory in this distribution. You can edit
these files to add your own pronouns, nouns, adjectives
and sentence stems.

Errors are fatal using L<Carp::confess>. If you want more
robust error handling, try using a module like L<Try::Tiny>.

=cut

=method new

This is the class constructor.

=cut

sub new {
    my $class = shift;

    if ( (scalar @_) and (scalar @_ % 2 != 0) ) {
        confess "Expected pairs for initialization values";
    }

    my $self = bless {}, $class;
    return $self->_load(@_);

}

sub _load {
    my $self = shift;

    

    my %defaults = (
             'nouns' => { 'file' => 'nouns_utf8.csv',
                           'key' => 'nom' },
        'adjectives' => { 'file' => 'adjectives_utf8.csv',
                           'key' => 'masc_nom' },
          'pronouns' => { 'file' => 'pronouns_utf8.csv',
                           'key' => 'masc_nom' },
             'stems' => { 'file' => 'sentence_stems_utf8.csv',
                           'key' => 'case' },
    );

    my %files = (%defaults);

    if ( @_ ) {
        %files = (%defaults, %{@_});
    }

    for my $k ( keys %files ) {
        my $c = $files{$k};
        $self->{$k} = csv(in => dist_file('Lingua-RU-Declension', 
                                          $c->{file}), 
                          key => $c->{key}, 
                          encoding => 'UTF-8');
    }

    return $self;
}

=method select_nouns

Return a list of nouns from the database which return true for the supplied
filter code block.

Example:

    my $code = sub {
        my $noun_data = shift;
        return 1 if $noun_data->{gender} eq "f";
        return 0;
    };

    my @feminine_nouns = $rus->select_nouns($code);

=cut

sub select_nouns {
    my $self = shift;
    my $code = shift;

    if ( ref($code) ne "CODE" ) {
        confess "Expected second parameter to be a code reference.";
    }

    return grep { $code->($self->{nouns}->{$_}) } 
                                         keys %{ $self->{nouns} };
}

=method decline_random_adjective

This function will randomly select and then decline an adjective from the database. You
must pass in a noun, a case, and if a plural form is wanted.  The return value is a
UTF-8 string.

=cut

sub decline_random_adjective {
    my $self = shift;
    return $self->decline_adjective($self->choose_random_adjective(), @_);
}

=method choose_random_adjective

This function will randomly select an adjective from the database and return it
as a UTF-8 string to the caller.

=cut

sub choose_random_adjective {
    my $self = shift;
    return $self->_choose_random($self->{adjectives})->{masc_nom};
}

sub _choose_random {
    my $self = shift;
    my $h = shift;

    return $h->{(keys %{ $h })[rand keys %{ $h }]};
}

=method decline_adjective

This function will decline the given adjective and return it as a UTF-8 string
to the caller. You must pass in the noun, a case, and if a plural form is
wanted.

=cut

sub decline_adjective {
    my $self = shift;
    my $adj = shift;

    if ( not exists $self->{adjectives}->{$adj} ) {
        confess "Couldn't find adjective '$adj' in my data.";
    }

    my $hk = $self->_select_hash_key(@_);

    return $self->{adjectives}->{$adj}->{$hk};
}

=method choose_random_pronoun

This function randomly selects a pronoun from the database and returns it as a
UTF-8 string to the caller.

=cut

sub choose_random_pronoun {
    my $self = shift;
    return $self->_choose_random($self->{pronouns})->{masc_nom};
}

=method decline_random_pronoun

This function will decline a randomly selected pronoun from the database and return it to the caller.

You must pass the noun, a case and if a plural form is wanted.

=cut

sub decline_random_pronoun {
    my $self = shift;
    return $self->decline_pronoun($self->choose_random_pronoun(), @_);
}

=method decline_pronoun

This function will decline a pronoun given the pronoun, its noun, a case, and
if a plural form is wanted.

=cut

sub decline_pronoun {
    my $self = shift;
    my $pronoun = shift;

    if ( not exists $self->{pronouns}->{$pronoun} ) {
        confess "Couldn't find pronoun '$pronoun' in my data.";
    }

    my $hk = $self->_select_hash_key(@_);

    return $self->{pronouns}->{$pronoun}->{$hk};
}

=method decline_noun

This function will decline the chosen noun to the
desired case and in a singular or plural form.

Input parameters:

=over 4

=item noun - this is the noun to decline. It must exist in the datafiles.

=item case - the desired case for the noun. It can be one of 'nom', 'gen',
'acc', 'dat', 'inst', 'prep'.  The default is 'nom'.

=item plural - set to 'plural' if a plural form is desired. The default is
singular.

=back

Output: UTF-8 string with the declined noun

=cut

sub decline_noun {
    my $self = shift;
    my $noun = shift;
    my $case = shift // 'nom';
    my $is_plural = shift // 0;
    $is_plural = $is_plural eq "plural" ? 1 : 0 ;

    if ( not exists $self->{nouns}->{$noun} ) {
        confess "Couldn't find noun '$noun' in my data.";
    }

    if ( $is_plural ) {
        return $self->{nouns}->{$noun}->{nmp} if $case eq "nom";
        return $self->{nouns}->{$noun}->{acp} if $case eq "acc";
        return $self->{nouns}->{$noun}->{gnp} if $case eq "gen";
        return $self->{nouns}->{$noun}->{dtp} if $case eq "dat";
        return $self->{nouns}->{$noun}->{itp} if $case eq "inst";
        return $self->{nouns}->{$noun}->{prp} if $case eq "prep";
    }
    else {
        return $self->{nouns}->{$noun}->{$case};
    }
}

=method choose_random_noun

This function will select one of the nouns in the database at random and
return it to the caller. It is a UTF-8 string.

=cut

sub choose_random_noun {
    my $self = shift;
    return $self->_choose_random($self->{nouns})->{nom};
}

=method decline_random_noun

This function will randomly select and then decline the chosen noun.

You must pass in the desired case and if a plural form is wanted, too.

=cut

sub decline_random_noun {
    my $self = shift;
    return $self->decline_noun($self->choose_random_noun(), @_);
}

=method russian_sentence_stem

This method returns a sentence stem in Russian as a UTF-8
string inthe specified case.

=cut 

sub russian_sentence_stem {
    my $self = shift;
    return $self->_select_sentence_stem(@_)->{rus};
}

=method english_sentence_stem

This method returns a sentence stem in English for the
specified case.

=cut

sub english_sentence_stem {
    my $self = shift;
    my $h = $self->_select_sentence_stem(@_)->{eng};
}

sub _select_sentence_stem {
    my $self = shift;
    my $case = shift;

    if ( not exists $self->{stems}->{$case} ) {
        confess "Could not find case $case in the sentence stem data.";
    }

    return $self->{stems}->{$case};
}

sub _select_hash_key {
    my $self = shift;
    my $noun = shift;
    my $case = shift // 'nom' ;
    my $is_plural = shift // 0;
    $is_plural = $is_plural eq "plural" ? 1 : 0 ;
    my $animate = $self->{nouns}->{$noun}->{animate};
    my $gender = $self->{nouns}->{$noun}->{gender};

    if ( $is_plural ) {
        if ( $case eq "acc" ) {
            return "pl_gen" if $animate eq "a"; #animate nouns get genitive endings
            return "pl_nom"; # inanimate nouns get nominative endings
        }

        return "pl_".$case;
    }
    else {
        if ( $gender eq "m" ) {
            if ( $case eq "acc" ) {
                return "masc_gen" if $animate eq "a";
                return "masc_nom";
            }
             return "masc_$case";
        }
        elsif ( $gender eq "f" ) {
             return "fem_nom" if $case eq "nom";
             return "fem_acc" if $case eq "acc";
             return "fem_oth";
        }
        elsif ( $gender eq "n" ) {
             return "neu_nom" if $case eq "nom";
             return "neu_nom" if $case eq "acc";
             return "masc_$case";
        }
        else {
             confess "I don't know how to decline '$noun' (gender: $gender, animate: $animate)";
        }
    }
}

1;
