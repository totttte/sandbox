#!/usr/bin/perl
open F,'<',$ARGV[0]or die$!;
for(;read F,$b,16;$l+=16){
  printf"[%08X] %s\n",$l,join' ',unpack'H2'x16,$b;
}
close F;
