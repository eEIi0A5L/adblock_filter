#!/usr/bin/perl
#$str = '/a/b/c/d/index.html';
#$str = "google.co.jp,google.com##.cu-container:has( > div > span > div > div > div > span:has-text(/^(Sponsored|スポンサー)/) )";
my $str = "";
my $token = "";
$str = $ARGV[0];
$token = $ARGV[1];
$count = $str;
#$count = $count =~ s/\///g;
#$count = $count =~ s/\)//g;
$count = $count =~ s/$token//g;
if ( $count eq "" ) {
    print "0\n"
} else {
    print "$count\n"
}
