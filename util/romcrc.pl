#!/bin/perl
sub crc16_ccitt2
{
	my($crc, $c) = @_;

  $crc  = ($crc >> 8) | ($crc << 8);
  $crc ^= $c;
  $crc ^= ($crc & 0xff) >> 4;
  $crc ^= $crc << 12;
  $crc ^= ($crc & 0xff) << 5;
  $crc &= 0xffff;
 return $crc;
}

sub gencrc
{
  my($crc, $c) = @_;
  my($i);
	$c =~ s/\s//g;
  for($i = 0;$i < length($c);$i+=2) {
  	$crc = crc16_ccitt2($crc, hex(substr($c, $i, 2)));
  }
  return $crc;
}

open f,"$ARGV[0]" or die "open romfile fail";
@txt = <f>;
close f;
$len = $len0 = $#txt;
$len = hex($ARGV[1]) if(@ARGV > 1);
for($i = 0, $crc = 0xffff;$i < $len;$i++) {
	if($i <= $len) {
		$_ = $txt[$i];
		s/\s//g;
		$wid = length($_) if($i == 0);
		$crc = gencrc($crc, $_);
		$txt[$i] = $_ . "\n";
	} else {
		$txt[$i] = join('', map('0', 1..$wid)) . "\n";
		$crc = gencrc($crc, $txt[$i]);
	}
}
if($wid > 4) {
	$txt[$len] = join('', map('0', 1..($wid - 4)));
	$crc = gencrc($crc, $txt[$i]);
	$txt[$len] .= sprintf("%04x", $crc);
} else {
	$txt[$len] .= sprintf("%02x\n%02x\n", $crc >> 8, $crc & 0xff);
}

printf "%02x\n%02x\n", $crc >> 8, $crc & 0xff;
open f,">$ARGV[0]";
print f @txt;
close f;
