 args <- commandArgs(T)
 data <- read.table(args[1],header=T)
 
 y <- dim(data)
 data.all <- data[,7:y[2]] 
 Max <- apply(data.all,1,max)
 Max_sample <- as.character(c(rep("0",nrow(data))))
 Max_sample <- apply(data.all,1,function(x)names(data.all)[which.max(x)])
 Number_of_samples <- rowSums(data.all>0)

 data.new<-cbind(data,Max,Max_sample,Number_of_samples)
 write.table(data.new,file=args[2],row.names=F,col.names=T,sep = "\t",quote = F,append = F)
 
 
