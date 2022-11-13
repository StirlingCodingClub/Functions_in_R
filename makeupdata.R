# Make data up

for(i in c(1:100)){
    set.seed(1979)
    df = data.frame(sample = i,
    length = rnorm(20,20,5),
    weight = rnorm(20,5,3),
    month = as.integer(runif(20,1,13)),
    year =  1950 + i)
    fname = paste0('datafile_',i,'.csv')
    write.csv(df,fname)
}
