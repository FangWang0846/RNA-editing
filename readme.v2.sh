# REDML, REDItools, SPRINT, samtools and bedtools are required for this pipeline. Please installed them first. 

#Step 1 Detecting candidate sites for each sample via three methods independently; 
# Step 1.0 Building index for bam files.
samtools index input.bam

#Step 1.1 REDItools 
python REDItoolDenovo.py -i input.bam -f hg38.fa -o Dir.out -m 50 -u -T 6-0 -n 0.0

#Step 1.2 RED-ML
perl red_ML.pl --rnabam input.bam --reference hg38.fa --dbsnp snp151.vcf --simpleRepeat hg38.simpleRepeat.bed --alu hg38.alu.bed --outdir Dir.out

#Step 1.3 SPRINT
python sprint_from_bam.py -rp hg38_repeat.txt input.bam hg38.fa Dir.out


#Step 1.4 Converting the results of REDItools/RED-ML/SPRINT to bed format
cat input_REDItools.out | awk '$11~/^AG$/ && $12~/[0-9]\.[0-9]/ && $1!~/^chrM$/ && $1!~/^chrY$/' | awk '{print $1, $2-1, $2, $5, $12, "+"}' OFS="\t"  > input_REDItools.bed
cat input_REDItools.out | awk '$11~/^TC$/ && $12~/[0-9]\.[0-9]/ && $1!~/^chrM$/ && $1!~/^chrY$/' | awk '{print $1, $2-1, $2, $5, $12, "-"}' OFS="\t"  >> input_REDItools.bed

cat input_RED-ML.out | awk '$1~/^chr*/ && $4~/^A$/ && $6~/^G$/ && $1!~/^chrM$/ && $1!~/^chrY$/' | awk '{print $1, $2-1, $2, $3, $7/$3, "+"}' OFS="\t"  > input_RED-ML.bed
cat input_RED-ML.out | awk '$1~/^chr*/ && $4~/^T$/ && $6~/^C$/ && $1!~/^chrM$/ && $1!~/^chrY$/' | awk '{print $1, $2-1, $2, $3, $7/$3, "-"}' OFS="\t"  >> input_RED-ML.bed.minus

cat input_SPRINT.out | awk '$1~/^chr*/ && $4~/AG|TC/ && $1!~/^chrM$/ && $1!~/^chrY$/' | sed 's/\:/\t/g' | awk '{print $1, $2, $3, $8, $7/$8, $6}' | sort -k1,1 -k2,2n > input_SPRINT.bed


#Step 1.5 Reporting the unique coordinates of all candidates from all samples via each method.
cat *_REDItools.bed | cut -f 1-3,6 | sort -u  >list.REDItools.bed
cat *_RED-ML.bed | cut -f 1-3,6 | sort -u     >list.RED-ML.bed
cat *_SPRINT.bed | cut -f 1-3,6 | sort -u     >list.SPRINT.bed


#Step 2.1 Filtering SNPs and repeats
bedtools intersect -a list.REDItools.bed -b snp.bed rmsk.bed -v > list.REDItools.out.snp.rmsk.bed
bedtools intersect -a list.RED-ML.bed    -b snp.bed rmsk.bed -v > list.RED-ML.out.snp.rmsk.bed
bedtools intersect -a list.SPRINT.bed    -b snp.bed rmsk.bed -v > list.SPRINT.out.snp.rmsk.bed
   

#Step 2.2 Filtering sites via Mappability score (parameters are input file and output file)
sh 2.2_filter.sh list.REDItools.out.snp.rmsk     list.REDItools.candidate.bed
sh 2.2_filter.sh list.RED-ML.out.snp.rmsk        list.RED-ML.candidate.bed
sh 2.2_filter.sh list.SPRINT.out.snp.rmsk        list.SPRINT.candidate.bed


#Step 3.1 Merged the editing level of all sites from all samples in each combination 
#The column names were methods/samples and the row names were the coordinates, and the contents were the editing level. 
#Input parameters: Dir (for bed with editing levels for all samples via each method), lists of candidates of 3 methods, list of samples, output file 
perl  merge_editing_level.pl Dir list.REDItools.candidate.bed list.RED-ML.candidate.bed list.SPRINT.candidate.bed samplelist list.all.candidate.editing.level.txt

#Step 3.2 Extract the maximum level and sample shared number (parameters are input file and output file)
Rscript cal.summary.r list.all.candidate.editing.level.txt list.all.candidate.editing.level.summary.txt

#Step 3.3 Spliting the list of sites to annotated and unannotated
awk '$1~/Chr/' annotated.sites.bed list.all.candidate.editing.level.summary.txt >list.all.candidate.editing.level.summary.annotated.txt ##header
awk 'NR==FNR{a[$1,$2,$3,$6];next}($1,$2,$3,$4) in a' annotated.sites.bed list.all.candidate.editing.level.summary.txt >>list.all.candidate.editing.level.summary.annotated.txt
awk 'NR==FNR{a[$1,$2,$3,$6];next}!(($1,$2,$3,$4) in a)' annotated.sites.bed list.all.candidate.editing.level.summary.txt >list.all.candidate.editing.level.summary.unannotated.txt


