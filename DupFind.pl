use strict;
use warnings;
use Cwd qw/cwd/;
use Digest::MD5;
use File::Find;

my $debug   = 1;
my $verbose = 0;
my $norecursive = 0;
my $rootdir = cwd;
print "+++ Current directory='$rootdir'\n" if $debug;
my $outfl='DupFind.out';
my @dirlist;
my %filehashes;

# --- Some procs

sub Usage{
   `perldoc $0`;
}

sub findfile{
   return if $_ =~ /^\.+$/;
   $File::Find::prune = 1 if $norecursive;
   my $flpath = $File::Find::name;
   return if -d $flpath;
   $flpath =~ s|/|\\|g;
#   $flpath=~s/\,/\\\,/g;
   open(my $FIO,"<".$flpath) || die "Can't open $flpath : $!\n";
   binmode($FIO);
   my $cont = Digest::MD5->new;
   $cont->addfile($FIO);
   my $digest = $cont->hexdigest();
   close($FIO);
   $filehashes{$flpath} = $digest;
   print "$digest => $flpath\n" if $verbose;
}

# --- Parse command line

for (my $i=@ARGV; $i>0; $i--){
   my $opti = shift;
   print "+++ Option = '$opti'\n" if $debug;
   if      ($opti =~ /^-o:(.+)$/i){
      $outfl = $1;
   } elsif ($opti =~ /^-{1,2}h$/i){
      die Usage;
   } elsif ($opti =~ /-v/i){
      $verbose++;
   } elsif ($opti =~ /-r/i){
      $norecursive++;
   } else {
      if (-e $opti and -d $opti){
         push @dirlist, $opti;
      } elsif ($debug) {
         if (not -e $opti){
            print "+++ Error: '$opti' does not exists\n";
         } elsif (not -d $opti){
            print "+++ Error: '$opti' is not directory\n";
         }
      }
   }
}

push @dirlist, $rootdir if !@dirlist;

if ($debug){
   $,=', ';
   print "+++ Program initialised with options:\n";
   print "+++ 1) Directory list: ";
   print @dirlist;
   print "\n+++ 2) Outfile: '$outfl'\n";
   print "+++ 3) Other: ";
   print "Verbose " if $verbose;
   print "RecursionDisabled " if $norecursive;
   print "\n";
}

print "+++ Scan for duplicates...\n" if $debug;
find(\&findfile, @dirlist);

print "+++ Save result to $outfl\n" if $debug;
open(FO, ">$outfl");
my $prevdg = '';
my $prevfl = '';
my $dupfnd = 0;
foreach my $key (sort {$filehashes{$a} cmp $filehashes{$b}} keys %filehashes){
   if ($prevdg eq $filehashes{$key}){
      print FO "$prevfl\n";
      $dupfnd++;
   }elsif ($dupfnd){
      $dupfnd = 0;
      print FO "$prevfl\n\n";
   }
   $prevfl = $key;
   $prevdg = $filehashes{$key};
}
close(FO);
print "+++ All done!\n" if $debug;
exit(0);

__END__

=head1 NAME

B<DupFind.pl> - Find duplicated files at specified directories.

=head1 SYNOPSIS:

  DupFind.pl [path1 [path2 [path3 [...]]]] [-o:outfile] [-v] [-r]
  DupFind.pl --help
  
=head2 Options:

=over

=item B<path1, path2, path3, ...>

Specify root directory, or list of directories, in which we scan for files. Used current directory if omitted.

=item B<outfile>

Output file, where information about duplicates will be saved.

=item B<-v>

Verbose output

=item B<-r>

Disable recursively scan from specified folder(s). By default program scan for duplicates from specified root folder(s) as deep as possible.

=item B<--help>

This help screen

=back

=head1 AUTHOR

Copyright (c) 2009, An0ther0ne.
This tool is free software. You can redistribute it and/or modify it under the same terms as Perl itself.

=head1 SEE ALSO

perl(1), Digest::MD5, File::Find.

=cut
