input=$1
output=$2

bedtools intersect -a $input.bed -b hg38_MapabilityAlign100mer.bed -wa |awk '$5 >= 1' >$input.100mer.bed
bedtools slop -l 150 -r 150 -s -i $input.100mer.bed -g hg38.genome | bedtools sort >$input.100mer.150bp.bed
bedtools intersect -a $input.100mer.150bp.bed -b hg38_MapabilityAlign24mer.bed -wa -wb >$input.100mer.150bp.24mer.bed
perl aver_24mer.pl $input.100mer.150bp.24mer.bed $input.100mer.150bp.24mer.aver.txt
awk '$5>0.5' $input.100mer.150bp.24mer.aver.txt | awk '{print $1, $2+149, $3-150, $5, ".", $4}' OFS="\t" >$output

rm $input.100mer.bed $input.100mer.150bp.bed $input.100mer.150bp.24mer.bed $input.100mer.150bp.24mer.aver.txt

