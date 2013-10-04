#!/usr/bin/env perl
package restring;
use strict;
use warnings;

__PACKAGE__->main() unless caller();


use constant DEBUG => 0;


sub _replace_PHP_encoded_strings {
    my ($string, $from_str, $to_str) = @_;
      warn "\$string = '$string'" if DEBUG;

    while ($string =~ m/s:([\d]+):\\"/g) {
        my $PHPstr_length = $1;
        next if ($PHPstr_length == 0);
          warn "\$PHPstr_length = $PHPstr_length" if DEBUG;

        my $idx_PHP_encoding = $-[0];
          warn "\$idx_PHP_encoding = $idx_PHP_encoding" if DEBUG;
        $string =~ m/( (?: \\. | [^\\] ){$PHPstr_length} )/gx;
        my $PHPstr = $1;
          warn "\$PHPstr = '$PHPstr'" if DEBUG;
        if ($string !~ m/\\";/g) {
            # at least 6 chars do not include another 's:#:\"'
            pos($string) = $idx_PHP_encoding + 6;
            next;
        }
        my $len_PHP_encoding = $+[0] - $idx_PHP_encoding;
          warn "\$len_PHP_encoding = $len_PHP_encoding" if DEBUG;

        $PHPstr = replace_strings($PHPstr, $from_str, $to_str);
          warn "\$PHPstr = '$PHPstr'" if DEBUG;
        my $new_PHPstr_length = length($PHPstr) - @{[ $PHPstr =~ m/\\/g ]};
          warn "\$new_PHPstr_length = $new_PHPstr_length" if DEBUG;
        my $new_PHP_encoding = 's:' . $new_PHPstr_length . ':\"' . $PHPstr . '\";';
          warn "\$new_PHP_encoding = $new_PHP_encoding" if DEBUG;
        substr($string, $idx_PHP_encoding, $len_PHP_encoding, $new_PHP_encoding);
          warn "\$string = '$string'" if DEBUG;

        pos($string) = $idx_PHP_encoding + length($new_PHP_encoding);
    }

    return $string;
}


sub _replace_regular_strings {
    my ($string, $from_str, $to_str) = @_;
    $string =~ s/\Q$from_str\E/$to_str/g unless $from_str eq '';
    return $string;
}


sub replace_strings {
    my ($string, $from_str, $to_str) = @_;
    $string = _replace_PHP_encoded_strings($string, $from_str, $to_str);
    $string = _replace_regular_strings($string, $from_str, $to_str);
    return $string;
}


sub main {
    # DTSTTCPW implementation
    my $from_str = shift;
    my $to_str = shift;
    while (<>) {
        print replace_strings($_, $from_str, $to_str);
    }
}

1; # end with a true value so that this file can be required or used

# end
