#!/usr/bin/perl -w
use strict;

opendir FH,"./blast_out";
my @all_file=readdir FH;
my %mouse;
my %all;

my %all_species;
foreach my $file(@all_file)
{
    if($file=~/_BSR_all_list.txt$/ and $file=~/^Mm_/ and $file!~/Bf/ and $file!~/Ci/ )
    {
        open IN,"./blast_out/$file";
        my ($species1,$species2)=(split("_",$file))[0,1];
        $all_species{$species2}++;
        while(<IN>)
        {
            chomp $_;
            my ($mouse_id,$other_id)=(split("\t",$_))[0,1];
            $mouse{$mouse_id}{$species2}=$other_id;
        }
    }
    
    if($file=~/_BSR_all_list.txt$/ and $file!~/Bf/ and $file!~/Ci/ )
    {
        open IN,"./blast_out/$file";
        my ($species1,$species2)=(split("_",$file))[0,1];
        while(<IN>)
        {
            chomp $_;
            my ($mouse_id,$other_id)=(split("\t",$_))[0,1];
            my @id;
            push(@id,$mouse_id);
            push(@id,$other_id);
            my @sort_id=sort @id;
            $all{join("\t",@sort_id)}++;
        }
    }
        
}
open OUT,">out_6species.rbbh";
print OUT join("\t","Mm",sort keys %all_species),"\n";
foreach my $mouse_id(keys %mouse)
{
    my @species=keys %{$mouse{$mouse_id}};
    if(scalar(@species)==scalar(keys %all_species))
    {
        my @id_pool;
        foreach my $species(sort keys %{$mouse{$mouse_id}})
        {
            push(@id_pool,$mouse{$mouse_id}{$species});
            
        }
        my $m=0;
        my $n=0;
        for(my $i=0;$i<scalar(@id_pool)-1;$i++)
        {
            for(my $j=$i+1;$j<scalar(@id_pool);$j++)
            {
                my @tmp_id;
                push(@tmp_id,$id_pool[$i]);
                 push(@tmp_id,$id_pool[$j]);
                 my @sort_tmp_id=sort @tmp_id;
                 my $id_pair=join("\t",@sort_tmp_id);
                 if(exists $all{$id_pair})
                 {
                    $m++;
                 }
                 $n++;
            }
        }
        
        if($m==$n)
        {
            print OUT join("\t",$mouse_id,@id_pool),"\n";
        }
        
    }
}
