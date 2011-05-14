#!/usr/bin/perl -w

while (<>) {
	@item = split;
	print "$item[0] ";
	for($i=0; $i<length $item[1]; $i+=2) {
		print substr ($item[1], $i, 2), " ";
	}
	print "\n";
}
