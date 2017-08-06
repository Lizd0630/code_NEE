#!/usr/bin/perl -w
use strict;

opendir FH,"./peptide";
my @all_file=readdir FH;
foreach my $file(@all_file)
{
    if($file=~/fa$/)
    {
        system("makeblastdb  -in ./peptide/$file -parse_seqids -dbtype prot");
    }
}

my %species;
my %length;

foreach my $file(@all_file)
{
    if($file=~/\.fa$/)
    {
    
        $species{$file}++;
        
        open IN,"./peptide/$file";
        while(<IN>)
        {
            chomp $_;
            my $seq=<IN>;
            chomp $seq;
            my $id=$_;
            $id=~s/>//;
            $length{$id}=length($seq);
        }
        
    }
}

mkdir "blast_out";

open OUT,">run_blast.bash";
my %all;
foreach my $file1(keys %species)
{
    foreach my $file2(keys %species)
    {
        if($file1 ne $file2)
        {
            
            my $fileout=$file1."_".$file2.".blast";
            print OUT join("\t","blastp -task  blastp   -query","./peptide/$file1", "-db","./peptide/$file2","-evalue 1e-5  -num_threads 40 -outfmt 6 -out", "./blast_out/$fileout"),"\n";
            
        }
        
    }
}

foreach my $file1(keys %species)
{
   
    my $fileout=$file1."_".$file1.".blast";
    print OUT join("\t","blastp -task  blastp   -query","./peptide/$file1", "-db","./peptide/$file1","-evalue 1e-5  -num_threads 40 -outfmt 6 -out", "./blast_out/$fileout"),"\n";

}

close(OUT);

system("bash run_blast.bash");


my @species=qw(Mm Gg Ps Xl Xt Dr Bf Ci);

for(my $i=0;$i<scalar(@species)-1;$i++)
{
    for(my $j=$i+1;$j<scalar(@species);$j++)
    {
        
        
        
        my $species1=$species[$i];
        my $species2=$species[$j];
        my $fileout1=$species1."_".$species2."_BSR_all_list.txt";
        print $fileout1,"\n";
        open OUT,">./blast_out/$fileout1";
        
        my $file1=$species1.".fa_".$species2.".fa.blast";
        my $file2=$species2.".fa_".$species1.".fa.blast";
        
        
        
       open IN1,"./blast_out/$file1";
       my %check_all1;
       while(<IN1>)
        {
            chomp $_;
             my ($id1,$id2,$e,$bit)=(split("\t",$_))[0,1,-2,-1];
             {
                $check_all1{$id1}{$e}{$bit}{$id2}++;
             }
        }
        
        close(IN1);
     
        my %can_use_1;
        foreach my $id1(keys %check_all1)
        {
            
            my @tmp_e=sort{$a<=>$b}keys %{$check_all1{$id1}};
            
            
            my $min_e=$tmp_e[0];
            my @tmp_bit=sort{$b<=>$a} keys %{$check_all1{$id1}{$min_e}};
            my $max=$tmp_bit[0];
            if(scalar(keys %{$check_all1{$id1}{$min_e}{$max}})==1)
            {
              
                my @id=keys %{$check_all1{$id1}{$min_e}{$max}};
                my $id2=$id[0];
                #my @tmp;
                #push(@tmp,$id1);
                #push(@tmp,$id2);
                #@tmp=sort @tmp;
                $can_use_1{$id1}=$id2;
            }
        }
        

           
       open IN1,"./blast_out/$file2";
       my %check_all2;
       while(<IN1>)
        {
            chomp $_;
             my ($id1,$id2,$e,$bit)=(split("\t",$_))[0,1,-2,-1];
             {
                $check_all2{$id1}{$e}{$bit}{$id2}++;
             }
        }
        
         close(IN1);
         
        my %can_use_2;
        foreach my $id1(keys %check_all2)
        {
             my @tmp_e=sort{$a<=>$b}keys %{$check_all2{$id1}};
            
            
            my $min_e=$tmp_e[0];
            my @tmp_bit=sort{$b<=>$a} keys %{$check_all2{$id1}{$min_e}};
            my $max=$tmp_bit[0];
            if(scalar(keys %{$check_all2{$id1}{$min_e}{$max}})==1)
            {
               
                 my @id=keys %{$check_all2{$id1}{$min_e}{$max}};
                my $id2=$id[0];
                
                $can_use_2{$id1}=$id2;
            }
        }
        

        foreach my $id1(keys %can_use_1)
        {
            my $id2=$can_use_1{$id1};
            if(exists $can_use_2{$id2} )
            {
                if($can_use_2{$id2} eq $id1)
                {
                    print OUT join("\t",$id1,$id2),"\n";
                }
            }
        }

    }
}



