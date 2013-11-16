#!/usr/bin/perl

open(korpus,"korpus.txt");
open(kueri_LD,"kueri_LD.txt");
open(hasil_LD,">hasil_LD.txt");
open(kueri_Soundex,"kueri_Soundex.txt");
open(hasil_Soundex,">hasil_Soundex.txt");

#kata unik dalam dokumen
%kata_unik = ();

while($baris = <korpus>){	

	#buang whitespace
	chomp($baris);
	
	#buang nomor dokumen
	if($baris =~ /<NO>/){
		$baris = ""; 
	}	
	
	#buang tag
	$baris =~ s/<DOK>//;
	$baris =~ s/<\/DOK>//;
	$baris =~ s/<JUDUL>//;
	$baris =~ s/<\/JUDUL>//;
	$baris =~ s/<TEKS>//;
	$baris =~ s/<\/TEKS>//;
		
	if($baris ne ""){
		#buat seluruh kata menjadi lowercase
		$baris =~ tr/A-Z/a-z/;	
		#buang tanda baca
		$baris =~ s/[^a-z0-9]+/ /g;	
		#buang angka
		$baris =~ s/[0-9]+/ /g;
		
		@temp = split(/\s+/,$baris);
		
		foreach $kata(@temp){
			if($kata ne ""){
				$kata_unik{$kata}++;
			}
		}
	}	
}

# Sumber :  http://www.perlmonks.org/?node=Levenshtein%20distance%3A%20calculating%20similarity%20of%20strings
# Return the Levenshtein distance (also called Edit distance) 
# between two strings
#
# The Levenshtein distance (LD) is a measure of similarity between two
# strings, denoted here by s1 and s2. The distance is the number of
# deletions, insertions or substitutions required to transform s1 into
# s2. The greater the distance, the more different the strings are.
#
# The algorithm employs a promimity matrix, which denotes the 
# distances between substrings of the two given strings. Read the 
# embedded comments for more info. If you want a deep understanding 
# of the algorithm, printthe matrix for some test strings 
# and study it
#
# The beauty of this system is that nothing is magical - the distance
# is intuitively understandable by humans
#
# The distance is named after the Russian scientist Vladimir
# Levenshtein, who devised the algorithm in 1965
#
sub levenshtein{
	
	# $s1 and $s2 are the two strings
	# $len1 and $len2 are their respective lengths
	#
	my ($s1, $s2) = @_;
	my ($len1, $len2) = (length $s1, length $s2);

	# If one of the strings is empty, the distance is the length
	# of the other string
	#
	return $len2 if ($len1 == 0);
	return $len1 if ($len2 == 0);

	my %mat;

	# Init the distance matrix
	#
	# The first row to 0..$len1
	# The first column to 0..$len2
	# The rest to 0
	#
	# The first row and column are initialized so to denote distance
	# from the empty string
	#
	for (my $i = 0; $i <= $len1; ++$i)
	{
	for (my $j = 0; $j <= $len2; ++$j)
	{
	    $mat{$i}{$j} = 0;
	    $mat{0}{$j} = $j;
	}

	$mat{$i}{0} = $i;
	}

	# Some char-by-char processing is ahead, so prepare
	# array of chars from the strings
	#
	my @ar1 = split(//, $s1);
	my @ar2 = split(//, $s2);

	for (my $i = 1; $i <= $len1; ++$i)
	{
	for (my $j = 1; $j <= $len2; ++$j)
	{
	    # Set the cost to 1 iff the ith char of $s1
	    # equals the jth of $s2
	    # 
	    # Denotes a substitution cost. When the char are equal
	    # there is no need to substitute, so the cost is 0
	    #
	    my $cost = ($ar1[$i-1] eq $ar2[$j-1]) ? 0 : 1;

	    # Cell $mat{$i}{$j} equals the minimum of:
	    #
	    # - The cell immediately above plus 1
	    # - The cell immediately to the left plus 1
	    # - The cell diagonally above and to the left + the cost
	    #
	    # We can either insert a new char, delete a char of
	    # substitute an existing char (with an associated cost)
	    #
	    $mat{$i}{$j} = min([$mat{$i-1}{$j} + 1,
				$mat{$i}{$j-1} + 1,
				$mat{$i-1}{$j-1} + $cost]);
	}
	}

	# Finally, the distance equals the rightmost bottom cell
	# of the matrix
	#
	# Note that $mat{$x}{$y} denotes the distance between the 
	# substrings 1..$x and 1..$y
	#
	return $mat{$len1}{$len2};
}


# minimal element of a list
sub min{
	
	my @list = @{$_[0]};
	my $min = $list[0];

	foreach my $i (@list)
	{
	$min = $i if ($i < $min);
	}

	return $min;
}

sub soundex{

	my ($kata) = @_;

	$huruf_pertama = substr($kata,0,1);
	$sisa_huruf = substr($kata,1,length($kata)-1);

	#buang huruf {y, h, w}
	$sisa_huruf =~ s/[yhw]+//gi;

	#ubah huruf menjadi angka, dengan ketentuan :
	$sisa_huruf =~ s/[bfpv]+/1/gi;
	$sisa_huruf =~ s/[cgjkqsxz]+/2/gi;
	$sisa_huruf =~ s/[dt]+/3/gi;
	$sisa_huruf =~ s/[l]+/4/gi;
	$sisa_huruf =~ s/[mn]+/5/gi;
	$sisa_huruf =~ s/[r]+/6/gi;

	#hapus angka berurutan
	my @temp_array = split(//,$sisa_huruf);
	
	#cek jumlah digit
	my $temp_string;
	for($i=0; $i<=$#temp_array; $i++){
	    if($temp_array[$i] ne $temp_array[$i-1]){
		  $temp_string = $temp_string .  $temp_array[$i];
	    }
	}
	$sisa_huruf = $temp_string;

	#buang huruf {a, e, i, o, u}
	$sisa_huruf =~ s/[aeiou]+//gi;

	my $hasil = $huruf_pertama.$sisa_huruf;

	#hasil soundex terdiri atas 4 digit
	if(length($hasil) > 4){
	   $hasil = substr($hasil,0,4); 
	}
	elsif(length($hasil) < 4){
	    for($j=0; $j<4-length($hasil); $j++){
		  $hasil = $hasil . "0"; 
	    }
	}
	 
	#buat seluruh huruf menjadi uppercase
	$hasil =~ tr/a-z/A-Z/;	 
	     
	return($hasil);
}

while(my $kueri = <kueri_LD>){	
	
	#buang whitespace
	chomp($kueri);
	#buat seluruh huruf menjadi lowercase
	$kueri =~ tr/A-Z/a-z/;	 
	
	my @temp = split("_",$kueri);	
	my $hasil = "$kueri : ";
	
	#cek jarak levenshtein antara kueri dan kata dalam korpus
	my $counter = 0;			
	foreach $kata(sort keys %kata_unik){
		$jarak = &levenshtein($temp[0],$kata);
		if($jarak <= $temp[1] && $counter < 10){
			$hasil = $hasil . "$kata($jarak), ";
			$counter++;
		}
	}
	
	if($counter == 0){
		$hasil = $hasil . "Tidak Terdapat Kata Yang Memenuhi";
	}
	
	#buang koma di akhir baris
	$hasil =~ s/(, )$//gi;
	
	$hasil = $hasil . "\n";
	print hasil_LD $hasil;
}

while(my $kueri = <kueri_Soundex>){	
	
	#buang whitespace
	chomp($kueri);
	#buat seluruh huruf menjadi lowercase
	$kueri =~ tr/A-Z/a-z/;	 
	
	#hasil soundex dari kueri
	my $soundex = &soundex($kueri);
	
	my $hasil = "$kueri($soundex) : ";
	
	#cek soundex setiap kata dalam korpus
	my $counter = 0;			
	foreach $kata(sort keys %kata_unik){		
		my $temp = &soundex($kata);
		if($soundex eq $temp && $counter < 10){
			$hasil = $hasil . "$kata, ";
			$counter++;
		}
	}
	
	if($counter == 0){
		$hasil = $hasil . "Tidak Terdapat Kata Yang Memenuhi";
	}
	
	#buang koma di akhir baris
	$hasil =~ s/(, )$//gi;
	
	$hasil = $hasil . "\n";
	print hasil_Soundex $hasil;
}

close(korpus);
close(kueri_LD);
close(hasil_LD);
close(kueri_Soundex);
close(hasil_Soundex);
