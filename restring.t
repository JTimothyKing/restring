#!/usr/bin/env perl
package restring::t;
use strict;
use warnings;

use Test::More;

BEGIN {
    eval {
        require 'restring.pl';
    } or BAIL_OUT($@);
}


my @test_cases = (
    # {
    #     test_name => '',
    #     source_string => '',
    #     from_string => '',
    #     to_string => '',
    #     expected_result => '',
    # },

    # regular strings
    {
        test_name => 'from-string is empty',
        source_string => 'foo bar baz qux quux',
        from_string => '',
        to_string => 'frobnitz',
        expected_result => 'foo bar baz qux quux',
    },
    {
        test_name => 'to-string is empty',
        source_string => 'foo bar baz qux quux',
        from_string => 'baz',
        to_string => '',
        expected_result => 'foo bar  qux quux',
    },
    {
        test_name => 'doing a simple replacement',
        source_string => 'foo bar baz qux quux',
        from_string => 'baz',
        to_string => 'frobnitz',
        expected_result => 'foo bar frobnitz qux quux',
    },
    {
        test_name => 'from-string is not found',
        source_string => 'foo bar baz qux quux',
        from_string => 'glorp',
        to_string => 'frobnitz',
        expected_result => 'foo bar baz qux quux',
    },
    {
        test_name => 'multiple from-strings are found',
        source_string => 'foo bar baz qux quux',
        from_string => 'ba',
        to_string => 'frobnitz',
        expected_result => 'foo frobnitzr frobnitzz qux quux',
    },
    {
        test_name => 'from-string is a substring of to-string',
        source_string => 'foo bar baz qux quux',
        from_string => 'b',
        to_string => 'frobnitz',
        expected_result => 'foo frobnitzar frobnitzaz qux quux',
    },

    # PHP-encoded strings
    {
        test_name => 'from-string is found outside a PHP-encoded string',
        source_string => 'foo s:11:\"bar baz qux\"; quux',
        from_string => 'foo',
        to_string => 'frobnitz',
        expected_result => 'frobnitz s:11:\"bar baz qux\"; quux',
    },
    {
        test_name => 'a PHP-encoded string is of length zero',
        source_string => 'foo s:0:\"\";bar baz qux quux',
        from_string => 'foo',
        to_string => 'frobnitz',
        expected_result => 'frobnitz s:0:\"\";bar baz qux quux',
    },
    {
        test_name => 'from-string is found within a PHP-encoded string',
        source_string => 'foo s:11:\"bar baz qux\"; quux',
        from_string => 'baz',
        to_string => 'frobnitz',
        expected_result => 'foo s:16:\"bar frobnitz qux\"; quux',
    },
    {
        test_name => 'multiple from-strings are found within a PHP-encoded string',
        source_string => 'foo s:11:\"bar baz qux\"; quux',
        from_string => 'ba',
        to_string => 'frobnitz',
        expected_result => 'foo s:23:\"frobnitzr frobnitzz qux\"; quux',
    },
    {
        test_name => 'multiple from-strings are found within multiple PHP-encoded strings',
        source_string => 'foo s:11:\"bar baz qux\";s:11:\"bar baz qux\"; quux',
        from_string => 'ba',
        to_string => 'frobnitz',
        expected_result => 'foo s:23:\"frobnitzr frobnitzz qux\";s:23:\"frobnitzr frobnitzz qux\"; quux',
    },
    {
        test_name => 'from-string is a substring of to-string, found within a PHP-encoded string',
        source_string => 'foo s:11:\"bar baz qux\"; quux',
        from_string => 'b',
        to_string => 'frobnitz',
        expected_result => 'foo s:25:\"frobnitzar frobnitzaz qux\"; quux',
    },
    {
        test_name => 'quotes are included inside a PHP-encoded string',
        source_string => 'foo s:13:\"bar \"baz\" qux\"; quux',
        from_string => 'ba',
        to_string => 'frobnitz',
        expected_result => 'foo s:25:\"frobnitzr \"frobnitzz\" qux\"; quux',
    },
    {
        test_name => 'PHP-encoded strings are nested',
        source_string => 'foo s:42:\"s:13:\"bar \"baz\" qux\";s:13:\"bar \"baz\" qux\";\"; quux',
        from_string => 'ba',
        to_string => 'frobnitz',
        expected_result => 'foo s:66:\"s:25:\"frobnitzr \"frobnitzz\" qux\";s:25:\"frobnitzr \"frobnitzz\" qux\";\"; quux',
    },
    {
        test_name => 'a PHP-encoded string is missing a final terminator (thus should be treated as regular)',
        source_string => 'foo s:11:\"bar baz qux;s:11:\"bar baz qux\" quux',
        from_string => 'ba',
        to_string => 'frobnitz',
        expected_result => 'foo s:11:\"frobnitzr frobnitzz qux;s:11:\"frobnitzr frobnitzz qux\" quux',
    },
);


plan tests => scalar(@test_cases);

foreach my $test_case (@test_cases) {
    my $observed_result = restring::replace_strings(
        $test_case->{source_string},
        $test_case->{from_string},
        $test_case->{to_string},
    );
    is( $observed_result, $test_case->{expected_result},
        $test_case->{test_name});
}


# end
