#!/usr/bin/env perl
use strict;
use warnings;

use HTTP::Request;
use HTTP::Response;
use LWP::UserAgent;                                     #Library for working with APIs
use UUID::Generator::PurePerl;                          #Library for generating ids

my $ua = LWP::UserAgent->new;                           
my $ug = UUID::Generator::PurePerl->new();

$ua->ssl_opts( verify_hostname => 0 );  


print "How many containers would you like to make?\n";
my $i = <>;                                              #number of qr-codes to create 
my @a = (1..$i);                                         #array for loop


my $dir = "./qrCodePngFiles";
mkdir( $dir ) or die " $!, delete the folder 'qrCodePngFiles' if you want to generate new qr-codes and execute the script again. Alternatively, you can change the name of the 'dir' variable, as well as the directory name specified in the 'filename' variable within the forloop below to have multiple folders.";


open(FHText, '>', 'qrCodes.txt') or die $!;                 #Writes file containing qr-code by container
open(FHTextNokeys, '>', 'qrCodesNoKeys.txt') or die $!;
for $i (@a){
    my $str = 'container' . $i;
    my $uuid1 = $ug->generate_v4();
    print $str . " ID: " . $uuid1->as_string(), "\n";    #prints to screen the qr codes as they're created

    #This section sends a get request to quickchart api endpoint for qr codes, returning a png of the qr code specified
    my $req = HTTP::Request->new("GET" => "https://quickchart.io/qr?text=" . $uuid1->as_string());   #Text parameter is the value you want to encode (The generated code) 
    $req->content_type('image/png');
    my $res = $ua->request($req);

    my $filename = './qrCodePngFiles/' . $str . '.png';                 #Naming the qr code image files  based on the container number they were generated for
    open(FHData, '>' , $filename) or die $!;             #creates an empty file with this name (or overwrites it) 

    if ($res->is_success) {	
	print FHData $res->decoded_content;                  #writes the qr data from the get request into the empty file, resulting in a finished qr-code image
	print FHText $str . ": " . $uuid1->as_string() . "\n";   #writes the container name and qr-code into a text file formatted: (containerX: qrcode "\n")
	print FHTextNokeys $uuid1->as_string() . "\n";                 #writes only qr codes to file
    }
    else {
	print STDERR $res->status_line, "\n";            #if get request fails, an error message is printed
    }
    close(FHData);                                       #closes png image file

    
}#end for
close(FHText);       #closes the text file 
close(FHTextNokeys);
