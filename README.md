# NAME

Lingua::RU::Declension - Decline Russian pronouns, adjectives and nouns

# VERSION

version 0.003

# SYNOPSIS

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

# OVERVIEW

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

Errors are fatal using [Carp::confess](https://metacpan.org/pod/Carp::confess). If you want more
robust error handling, try using a module like [Try::Tiny](https://metacpan.org/pod/Try::Tiny).

# METHODS

## new

This is the class constructor.

## select\_nouns

Return a list of nouns from the database which return true for the supplied
filter code block.

Example:

    my $code = sub {
        my $noun_data = shift;
        return 1 if $noun_data->{gender} eq "f";
        return 0;
    };

    my @feminine_nouns = $rus->select_nouns($code);

## decline\_random\_adjective

This function will randomly select and then decline an adjective from the database. You
must pass in a noun, a case, and if a plural form is wanted.  The return value is a
UTF-8 string.

## choose\_random\_adjective

This function will randomly select an adjective from the database and return it
as a UTF-8 string to the caller.

## decline\_adjective

This function will decline the given adjective and return it as a UTF-8 string
to the caller. You must pass in the noun, a case, and if a plural form is
wanted.

## choose\_random\_pronoun

This function randomly selects a pronoun from the database and returns it as a
UTF-8 string to the caller.

## decline\_random\_pronoun

This function will decline a randomly selected pronoun from the database and return it to the caller.

You must pass the noun, a case and if a plural form is wanted.

## decline\_pronoun

This function will decline a pronoun given the pronoun, its noun, a case, and
if a plural form is wanted.

## decline\_noun

This function will decline the chosen noun to the
desired case and in a singular or plural form.

Input parameters:

- noun - this is the noun to decline. It must exist in the datafiles.
- case - the desired case for the noun. It can be one of 'nom', 'gen',
'acc', 'dat', 'inst', 'prep'.  The default is 'nom'.
- plural - set to 'plural' if a plural form is desired. The default is
singular.

Output: UTF-8 string with the declined noun

## choose\_random\_noun

This function will select one of the nouns in the database at random and
return it to the caller. It is a UTF-8 string.

## decline\_random\_noun

This function will randomly select and then decline the chosen noun.

You must pass in the desired case and if a plural form is wanted, too.

## russian\_sentence\_stem

This method returns a sentence stem in Russian as a UTF-8
string inthe specified case.

## english\_sentence\_stem

This method returns a sentence stem in English for the
specified case.

# AUTHOR

Mark Allen <mallen@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2018 by Mark Allen.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
