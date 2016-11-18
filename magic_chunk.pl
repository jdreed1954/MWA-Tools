
# This is the magic to use my subroutine library in the ../lib directory
use File::Basename qw(dirname);
use Cwd qw(abs_path);
use lib dirname(dirname abs_path $0).'/lib';
use MyTools qw(tStamp getComplexes);
#  Magic off

