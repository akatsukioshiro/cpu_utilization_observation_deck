#Libraries necessary
library(dygraphs)
library(xts)
library(htmlwidgets)
library(plotly)
Sys.setenv(RSTUDIO_PANDOC="/usr/lib/rstudio/bin/pandoc")

#Source File to Read from
output <- read.csv("./datasets/GWA-T-13_Materna-Workload-Traces/Materna-Trace-1/01.csv",sep=";", header=T)

#Extract only TimeStamp and CPU Usage
df <- subset(output, select = c(Timestamp, CPU.usage....))

#String to Date Type Conversion
df$Timestamp <- as.POSIXct(output$Timestamp,format="%d.%m.%Y %H:%M:%S",tz=Sys.timezone())

#Hour extracted
df$hour<-as.numeric(format(df$Timestamp,"%H"))

#Minute extracted
df$min <- as.numeric(format(df$Timestamp,"%M"))

#CPU Utilization extracted
df$cpu <- as.numeric(gsub(",", ".", df$CPU.usage....))

#Finalizing df
df <- subset(df, select = -c(CPU.usage....))

#Input Start Time
hour_1 <- {{input_time}}#set between 0-23

#Input Number of Hours
hrs_num <- {{input_hours}}#set this between 1-24

#Input End Time
hour_2 <- hour_1+hrs_num

#Input Day
day_0 <- {{input_day}}

#Calculated Start and End point
from<-((hour_1*12)+1)+((day_0-1)*288)
to<-((hour_1*12)+(hour_2-hour_1)*12)+((day_0-1)*288)

extract_dataset_vals <- function(hour_1,hour_2,day_0) {

  #Monthly Average extracted for given Timeframe from Total dataset
  ctr_h<-hour_1
  ctr_m<-0
  ea0<-c()

  while(ctr_h<hour_2)
  {
    ea0<-c(ea0,median(df[(df$hour == ctr_h)&(df$min == ctr_m),]$cpu))
    ctr_m<-ctr_m+5
    if(ctr_m==60){
      ctr_h<-ctr_h+1
      ctr_m<-0
    }
  }
  return(ea0)
}

ea<-extract_dataset_vals(hour_1,hour_2,day_0)
ea2<-ea#extract_dataset_vals(0,24,day_0)

#plot(from:to,ea,type="o")
concentration<-data.frame(ea=ea2,dn=dnorm(ea2,mean(ea2),sd(ea2)))
q<-plot_ly(concentration, x=concentration$ea,y=concentration$dn)
q<-add_trace(q, x=concentration$ea,y=concentration$dn, type="scatter", mode = "markers", marker = list(size = 10, color = '#00ddeeff', line = list(color = '#008888ff',width = 5)))
q<-layout(q,plot_bgcolor='#00000000')
q<-layout(q,paper_bgcolor='#00000000',font=list(color = "white"))
q<-layout(q,xaxis = list(gridcolor = "#006677dd"), yaxis = list(gridcolor = "#006677dd"))
#q

#sudo apt-get install libssl-dev
#sudo apt-get install r-cran-openssl

#Setting X-Axis values
dt<-df$Timestamp[from:to]

#Getting current CPU usage
cpu_now<-df$cpu[from:to]

#Preparing Dataframe for Dygraph (Monthly Average)
my_data <- data.frame(time=dt,ea=ea)
my_data$time <- strptime(my_data[,1],format="%Y-%m-%d %H:%M:%S")
my_data <- xts(my_data[,-1], order.by=my_data[,1], tz="GMT")

#Preparing Dataframe for Dygraph (Given date value)
my_data1 <- data.frame(time=dt,cpu_now=cpu_now)
my_data1$time <- strptime(my_data1[,1],format="%Y-%m-%d %H:%M:%S")
my_data1 <- xts(my_data1[,-1], order.by=my_data1[,1], tz="GMT")


#XTS formatted data creating dygraph
p<-dygraph(cbind(my_data,my_data1))
p<-dySeries(p,"my_data", label = "Exp. CPU %",fillGraph=TRUE,color="red")
p<-dySeries(p,"my_data1", label = "Cur. CPU %",fillGraph=TRUE,color="blue")
p<-dyOptions(p,stackedGraph = F)
p<-dyRangeSelector(p,height = 20)
#p

#Save Output as HTML File
saveWidget(p, "Graph.html", selfcontained = T,background = "#003040")
saveWidget(q, "Graph_denom.html", selfcontained = T,background = "#003040")
