use strict;
use File::Copy;
use File::Basename;
my $destination = "$ENV{TARGET_BUILD_DIR}/$ENV{PUBLIC_HEADERS_FOLDER_PATH}";

mkdir $destination unless -d $destination;
open Miele_h, ">", "$destination/OsiriX.h" or die $!;

print Miele_h "#ifndef __OsiriX_API\n#define __OsiriX_API\n\n";

my @fromdirs = ("$ENV{PROJECT_DIR}/cocoahttpserver", "$ENV{PROJECT_DIR}/Binaries/dcmtk-source/config", "$ENV{PROJECT_DIR}/Binaries/dcmtk-source/dcmsr", "$ENV{PROJECT_DIR}/Binaries/dcmtk-source/dcmdata", "$ENV{PROJECT_DIR}/Binaries/dcmtk-source/ofstd", "$ENV{PROJECT_DIR}/Binaries/dcmtk-source/dcmnet", "$ENV{PROJECT_DIR}/VTKHeaders", "$ENV{PROJECT_DIR}/Nitrogen/Sources", "$ENV{PROJECT_DIR}/Nitrogen/Sources/JSON", $ENV{PROJECT_DIR});

foreach my $root (@fromdirs) {
    opendir(DIR, $root);
    
    my @files = readdir(DIR);
    foreach (@files) {
        my $filename = $_;
        next unless -f "$root/$filename" && $filename =~ /\.h$/s;
        my @args = ( "cp", "-fp", "$root/$filename", "$destination/".(basename $filename) );
        system(@args) == 0 or die "Copy failed: $?";
        print Miele_h "#include <OsiriXAPI/$filename>\n";
    }
    
    closedir(DIR);
}

print Miele_h "\n#endif\n";
close Miele_h;

chdir "$ENV{TARGET_BUILD_DIR}/$ENV{FULL_PRODUCT_NAME}";
symlink "Versions/Current/Headers", "Headers";

exit 0;
