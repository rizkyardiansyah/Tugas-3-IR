#!/usr/bin/perl
# T2_1006770785-RizkyArdiansyah

open(IN, "1006770785.txt");

#hasil konkatenasi kata
$string_kata = "";

#kata-kata
@kata_kata;
#kata-kata yang memiliki imbuhan
@kata_berimbuhan;

#frekuensi dari imbuhan tetentu
%frek_imbuhan = ();
#kata-kata yang memiliki imbuhan tertentu
%kata_berimbuhan = ();
#hasil stem dari kata yang memiliki imbuhan tertentu
%stemmed_kata = ();

while($baris = <IN>){	

	#buang spasi di awal dan di akhir baris
	$baris =~ s/^\s*//;
	$baris =~ s/\s*$//;
	
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
		#buat semua kata menjadi lowercase
		$baris =~ tr/A-Z/a-z/;	
		#buang tanda baca
		$baris =~ s/[^a-z0-9]+/ /g;	
		#buang angka
		$baris =~ s/[0-9]+/ /g;
		
		$string_kata = $string_kata . " " . $baris;
	}
}

$string_kata =~ s/^\s*//;
$string_kata =~ s/\s*$//;
@kata_kata = split(/\s+/,$string_kata);

#pilih kata yang memiliki jumlah karakter lebih dari 3 untuk di-stem
foreach $kata(@kata_kata){
	my $jumlah_karakter = length($kata);
	if($jumlah_karakter>3){
		push @kata_berimbuhan, $kata;
	}
}

foreach $kata(@kata_berimbuhan){	
	
	#awalan
	$dp = "";
	
	#akhiran
	$ds = "";
	
	#infleksional kepunyaan
	$pp = "";
	
	#infleksional partikel
	$p = "";
	
	$hasil_stem = $kata;
	
	#cek infleksional partikel: -kah, -lah, -tah
	if($hasil_stem =~ /[a-z]{3,}kah$/){	
		$hasil_stem =~ s/kah$//;
		$p = "-kah";
	}
	elsif($hasil_stem =~ /[a-z]{3,}lah$/){
		$hasil_stem =~ s/lah$//;
		$p = "-lah";
	}
	elsif($hasil_stem =~ /bantah/){
		$p = "";
	}
	elsif($hasil_stem =~ /[a-z]{4,}tah$/){
		$hasil_stem =~ s/tah$//;
		$p = "-tah";
	}
	
	#cek infleksional kepunyaan: -ku, -mu, -nya
	if($hasil_stem =~ /[a-z]{3,}ku$/){	
		$hasil_stem =~ s/ku$//;
		$pp = "-ku";	
	}
	elsif($hasil_stem =~ /[a-z]{3,}mu$/){
		$hasil_stem =~ s/mu$//;
		$pp = "-mu";
	}
	elsif($hasil_stem =~ /[a-z]{3,}nya$/){
		$hasil_stem =~ s/nya$//;
		$pp = "-nya";
	}
	
	#cek akhiran: -i, -kan, -an. karena tidak menggunakan kamus, beberapa special case dibuat
	if($hasil_stem =~ /[a-z]{4,}i$/){
		if($hasil_stem =~ /\binformasi\b/ || $hasil_stem =~ /\bkomisi\b/ || $hasil_stem =~ /\bfungsi\b/ ||
		$hasil_stem =~ /\bkomunikasi\b/ || $hasil_stem =~ /\bpartai\b/ || $hasil_stem =~ /\bkoalisi\b/
		 || $hasil_stem =~ /\bekonomi\b/ || $hasil_stem =~ /\tragedi\b/ || $hasil_stem =~ /\bpolitisi\b/
		 || $hasil_stem =~ /\bsurvei\b/ || $hasil_stem =~ /\bmenteri\b/ || $hasil_stem =~ /\bteknologi\b/){
			$ds = "";
		}
		#eliminasi imbuhan yang tidak diizinkan
		elsif($hasil_stem =~ /^be/ || $hasil_stem =~ /^ke/ || $hasil_stem =~ /^se/){
			$hasil_stem = "-";
		}
		else{	
			$hasil_stem =~ s/i$//;
			$ds = "-i";
		}
	}	
	elsif($hasil_stem =~ /[a-z]{3,}kan$/){
		#eliminasi imbuhan yang tidak diizinkan
		if($hasil_stem =~ /^ke/ || $hasil_stem =~ /^se/){
			$hasil_stem = "-";
		}
		else{
			$hasil_stem =~ s/kan$//;
			$ds = "-kan";
		}
	}
	elsif($hasil_stem =~ /[a-z]{3,}an$/){
		if($hasil_stem =~ /\bjangan\b/ || $hasil_stem =~ /\bdengan\b/ || $hasil_stem =~ /\bperan\b/ ||
		$hasil_stem =~ /\bbantuan\b/ || $hasil_stem =~ /\brincian\b/ || $hasil_stem =~ /\bdewan\b/
		 || $hasil_stem =~ /\bkalangan\b/ || $hasil_stem =~ /\bkawasan\b/ || $hasil_stem =~ /\bmakan\b/
		 || $hasil_stem =~ /\bkorban\b/){	
			$ds = "";
		}
		#eliminasi imbuhan yang tidak diizinkan
		elsif($hasil_stem =~ /^di/ || $hasil_stem =~ /^me/){
			$hasil_stem = "-";
		}
		else{
			$hasil_stem =~ s/an$//;
			$ds = "-an";
		}
	}
	
	#cek awalan: di-, ke-, se- 
	if($hasil_stem =~ /^di[a-z]{3,}/){
		$hasil_stem =~ s/^di//;
		$dp = "di-";
	}
	elsif($hasil_stem =~ /^ke[a-z]{3,}/){
		$hasil_stem =~ s/^ke//;
		$dp = "ke-";
	}
	elsif($hasil_stem =~ /^se[a-z]{3,}/){
		$hasil_stem =~ s/^se//;
		$dp = "se-";
	}
	
	#cek awalan: be-
	if($hasil_stem =~ /^be[a-z]{3,}/){
		if($hasil_stem =~ /^ber[aiueo]/){
			$hasil_stem =~ s/^ber//;
			$dp = $dp . "ber-";
		}
		else{
			$hasil_stem =~ s/^ber//;
			$dp = $dp . "ber-";
		}
	}
	#special case untuk kata 'belajar'
	elsif($hasil_stem =~ /\bbelajar\b/){
		$hasil_stem =~ s/^bel//;
		$dp = $dp ."be-";
	}
	
	#cek awalan: te-
	elsif($hasil_stem =~ /^te[a-z]{3,}/){
		if($hasil_stem =~ /^ter[aiueo]/){
			$hasil_stem =~ s/^ter//;
			$dp = $dp ."ter-";
		}
		else{
			$hasil_stem =~ s/^ter//;
			$dp = $dp . "ter-";
		}
	}
	#cek awalan: me-
	elsif($hasil_stem =~ /^me[a-z]{3,}/){
		if($hasil_stem =~ /^me[lrwy][aiueo]/){
			$hasil_stem =~ s/^me//;
			$dp = $dp ."me-";
		}
		elsif($hasil_stem =~ /^mem[bfv]/){
			$hasil_stem =~ s/^mem//;
			$dp = $dp . "mem-";
		}
		elsif($hasil_stem =~ /^mempe[rl]/){
			$hasil_stem =~ s/^mempe//;
			$dp = $dp . "mem-pe-";
		}
		elsif($hasil_stem =~ /^mem[aiueo]/){
			$hasil_stem =~ s/^mem//;
			$hasil_stem = "p". $hasil_stem;
			$dp = $dp . "me-p-";
		}
		elsif($hasil_stem =~ /^men[cdjz]/){
			$hasil_stem =~ s/^men//;
			$dp = $dp ."men-";
		}
		elsif($hasil_stem =~ /^men[aiueo]/){
			$hasil_stem =~ s/^men//;
			$hasil_stem = "t". $hasil_stem;
			$dp = $dp . "me-t-";
		}
		elsif($hasil_stem =~ /^meng[ghq]/){
			$hasil_stem =~ s/^meng//;
			$dp = $dp . "meng-";
		}
		elsif($hasil_stem =~ /^meng[aiueo]/){
			$hasil_stem =~ s/^meng//;
			$hasil_stem = "k". $hasil_stem;
			$dp = $dp ."meng-k-";
		}
		elsif($hasil_stem =~ /^meny[aiueo]/){
			$hasil_stem =~ s/^meny//;
			$hasil_stem = "s". $hasil_stem;
			$dp = $dp . "meny-s-";
		}
		elsif($hasil_stem =~ /^memp[aiuo]/){
			$hasil_stem =~ s/^memp//;
			$hasil_stem = "p". $hasil_stem;
			$dp = $dp . "mem-p-";
		}
		else{
			$hasil_stem =~ s/^me//;
			$dp = $dp ."me-";
		}
	}
	#cek awalan: pe-
	elsif($hasil_stem =~ /^pe[a-z]{3,}/){
		if($hasil_stem =~ /^pe[wy][aiueo]/){
			$hasil_stem =~ s/^pe//;
			$dp = $dp . "pe-";
		}
		elsif($hasil_stem =~ /^per[aiueo]/){
			$hasil_stem =~ s/^per//;
			$dp = $dp . "per-";
		}
		elsif($hasil_stem =~ /^per[a-z]/){
			$hasil_stem =~ s/^per//;
			$dp = $dp . "per-";
		}
		elsif($hasil_stem =~ /^pem[bfv]/){
			$hasil_stem =~ s/^pem//;
			$dp = $dp . "pem-";
		}
		elsif($hasil_stem =~ /^pem[raiueo]/){
			$hasil_stem =~ s/^pem//;
			$hasil_stem = "p". $hasil_stem;
			$dp = $dp . "pem-p-";
		}
		elsif($hasil_stem =~ /^pen[cdjz]/){
			$hasil_stem =~ s/^pen//;
			$dp = $dp . "pen-";
		}
		elsif($hasil_stem =~ /^pen[aiueo]/){
			$hasil_stem =~ s/^pen//;
			$hasil_stem = "t". $hasil_stem;
			$dp = $dp . "pen-t-";
		}
		elsif($hasil_stem =~ /^pen[ghq]/){
			$hasil_stem =~ s/^peng//;
			$dp = $dp . "peng-";
		}
		elsif($hasil_stem =~ /^peng[aiueo]/){
			$hasil_stem =~ s/^peng//;
			$hasil_stem = "k". $hasil_stem;
			$dp = $dp . "peng-k-";
		}
		elsif($hasil_stem =~ /^peny[aiueo]/){
			$hasil_stem =~ s/^peny//;
			$hasil_stem = "s". $hasil_stem;
			$dp = $dp . "peny-s-";
		}
		elsif($hasil_stem =~ /\bpelajar\b/){
			$hasil_stem =~ s/^pel//;
			$dp = $dp . "pe-";
		}
		elsif($hasil_stem =~ /^pel[aiueo]/){
			$hasil_stem =~ s/^pe//;
			$dp = $dp . "pe-l-";
		}
		else{
			$hasil_stem =~ s/^pe//;
			$dp = $dp . "pe-";
		}
	}
	
	#gabungkan imbuhan
	$imbuhan = "$dp$ds$pp$p";
	
	#eliminasi kata dasar dan kata yang mengandung imbuhan yang tidak diizinkan
	if($imbuhan ne "" && $hasil_stem ne "-"){
		
		$frek_imbuhan{$imbuhan}++;	
		
		# 'ubah imbuhan'
		if($imbuhan eq "di--kan"){
			unless($kata_berimbuhan{$imbuhan} =~ /$kata/){			
				$kata_berimbuhan{$imbuhan} = $kata_berimbuhan{$imbuhan} . $kata .", ";
				#cetak kata-kata yang memiliki imbuhan 'di--kan'. untuk imbuhan lain, silakan 'ubah imbuhan'
				print "$kata,";
			}
			unless($stemmed_kata{$imbuhan} =~ /$hasil_stem/){
				$stemmed_kata{$imbuhan} = $stemmed_kata{$imbuhan} . $hasil_stem.", ";
				#cetak kata-kata yang berhasil di-stem berdasarkan imbuhan 'di--kan'. untuk imbuhan lain, silakan 'ubah imbuhan'
				print "$hasil_stem\n";
			}
		}
	}
}

$counter=0;

#cetak 10 imbuhan dengan frekuensi terbanyak
foreach $imbuhan(sort {$frek_imbuhan{$b} <=> $frek_imbuhan{$a}} keys %frek_imbuhan){
	if($counter<10){
		print " $imbuhan,$frek_imbuhan{$imbuhan}\n";
		$counter++;
	}
}

close(IN);