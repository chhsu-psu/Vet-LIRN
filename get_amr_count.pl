$Vet_UTI = $Vet_Other = $NAHLN_UTI = $NAHLN_Other = 0;

#get Vet-LIRN isolates
foreach my $line (`cut -f 4,5 $ARGV[0]`) {
	chomp $line;
	$line =~ s/\r//g;
	$line =~ s/"//g;
	@f = split(/\t/, $line);
	if($f[0] eq "AMR genotypes core") {
		next;
	}
	if($f[1] eq "UTI") {
		$Vet_UTI++;
	}
	else {
		$Vet_Other++;
	}
	@genotypes = split(/\,/, $f[0]);
	for($i=0; $i<=$#genotypes; $i++) {
		@cols = split(/=/, $genotypes[$i]);
		$gene = $cols[0];
		unless(exists $amr{$gene}) {
			$amr{$gene} = 1;
		}
		if(exists $amr_count{$gene}{"Vet"}{$f[1]}) {
			$amr_count{$gene}{"Vet"}{$f[1]}++;
		}
		else {
			$amr_count{$gene}{"Vet"}{$f[1]} = 1;
		}		
	}
}

#get NAHLN isolates
foreach my $line (`cut -f 4,11 $ARGV[1]`) {
	chomp $line;
	$line =~ s/\r//g;
	$line =~ s/"//g;
	@f = split(/\t/, $line);
	if($f[1] eq "AMR genotypes core") {
		next;
	}
	if($f[0] eq "UTI") {
		$NAHLN_UTI++;
	}
	else {
		$NAHLN_Other++;
	}
	@genotypes = split(/\,/, $f[1]);
	for($i=0; $i<=$#genotypes; $i++) {
		@cols = split(/=/, $genotypes[$i]);
		$gene = $cols[0];
		unless(exists $amr{$gene}) {
			$amr{$gene} = 1;
		}
		if(exists $amr_count{$gene}{"NAHLN"}{$f[0]}) {
			$amr_count{$gene}{"NAHLN"}{$f[0]}++;
		}
		else {
			$amr_count{$gene}{"NAHLN"}{$f[0]} = 1;
		}
	}
}

#get amr info
foreach my $line (`cat $ARGV[2]`) {
	chomp $line;
	$line =~ s/\r//g;
	@f = split(/\t/, $line);
	$f[1] = uc($f[1]);
	$f[2] = uc($f[2]);
	$f[3] = uc($f[3]);
	if(exists $class{$f[0]}) {
		if(index($class{$f[0]}, $f[1]) == -1) {
			$class{$f[0]} = $class{$f[0]} . ", " . $f[1];
		}
		if(index($drug{$f[0]}, $f[2]) == -1) {
			$drug{$f[0]} = $drug{$f[0]} . ", " . $f[2];
		}
		$panel{$f[0]} = $f[3];
	}
	else {
		$class{$f[0]} = $f[1];
		$drug{$f[0]} = $f[2];
		$panel{$f[0]} = $f[3];
	}
}

print "AMR Genotype\tVet-LIRN Number \'Urine\'\tNAHLN Number \'Urine\'\tTotal VL+NAHLN Number \'Urine\'\tVet-LIRN Percentage \'Urine\'\tNAHLN Percentage \'Urine\'\tAverage VL+NAHLN Percentage \'Urine\'\tVet-LIRN Number \'Other\'\tNAHLN Number \'Other\'\tTotal VL+NAHLN Number \'Other\'\tVet-LIRN Percentage \'Other\'\tNAHLN Percentage \'Other\'\tAverage VL+NAHLN Percentage \'Other\'\tDrug Class\tDrug\tDrug on Panel\n";
foreach my $g (sort keys %amr) {
	unless(exists $amr_count{$g}{'Vet'}{'UTI'}) {
		$amr_count{$g}{'Vet'}{'UTI'} = 0;
	}
	unless(exists $amr_count{$g}{'NAHLN'}{'UTI'}) {
		$amr_count{$g}{'NAHLN'}{'UTI'} = 0;
	}
	unless(exists $amr_count{$g}{'Vet'}{'Other'}) {
		$amr_count{$g}{'Vet'}{'Other'} = 0;
	}	
	unless(exists $amr_count{$g}{'NAHLN'}{'Other'}) {
		$amr_count{$g}{'NAHLN'}{'Other'} = 0;
	}

	$total_VL_NAHLN_UTI = $amr_count{$g}{'Vet'}{'UTI'} + $amr_count{$g}{'NAHLN'}{'UTI'};
	$VL_per_UTI = $amr_count{$g}{'Vet'}{'UTI'} / $Vet_UTI;
	$NAHLN_per_UTI = $amr_count{$g}{'NAHLN'}{'UTI'} / $NAHLN_UTI;
	$VL_NAHLN_per_UTI = $total_VL_NAHLN_UTI / ($Vet_UTI + $NAHLN_UTI);
	$total_VL_NAHLN_Other = $amr_count{$g}{'Vet'}{'Other'} + $amr_count{$g}{'NAHLN'}{'Other'};
	$VL_per_Other = $amr_count{$g}{'Vet'}{'Other'} / $Vet_Other;
	$NAHLN_per_Other =  $amr_count{$g}{'NAHLN'}{'Other'} / $NAHLN_Other;
	$VL_NAHLN_per_Other = $total_VL_NAHLN_Other / ($Vet_Other + $NAHLN_Other);
	print "$g\t$amr_count{$g}{'Vet'}{'UTI'}\t$amr_count{$g}{'NAHLN'}{'UTI'}\t$total_VL_NAHLN_UTI\t$VL_per_UTI\t$NAHLN_per_UTI\t$VL_NAHLN_per_UTI\t$amr_count{$g}{'Vet'}{'Other'}\t$amr_count{$g}{'NAHLN'}{'Other'}\t$total_VL_NAHLN_Other\t$VL_per_Other\t$NAHLN_per_Other\t$VL_NAHLN_per_Other\t$class{$g}\t$drug{$g}\t$panel{$g}\n";
}

print "\n";
print "Vet-LIRN urine\t$Vet_UTI\n";
print "Vet-LIRN other\t$Vet_Other\n";
print "NAHLN urine\t$NAHLN_UTI\n";
print "NAHLN other\t$NAHLN_Other\n";
