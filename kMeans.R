rm(list=ls())
library(data.table)
library(ggplot2)

kMeans <- function(dt,K,Stop,Threshold,Iteration,KmPP,Normalize){
  DATA <- copy(dt)
  count <- 0
  Error <- c()
  collapse <- FALSE
  
  # Default Values for the parameters.
  if(missing(Stop)){
    Stop='Default'
    message('Setting Stopping Criteria as Default aka Change in centroid')
  }
  if(missing(Iteration)){
    Iteration=50
    message('Iterations set to ',Iteration)
  }
  if(missing(Threshold)){
    Threshold=1
    message('Threshold set to ',Threshold)
  }
  if(missing(K)){
    K=2
    message('# Clusters set to ',K)
  }
  if(missing(KmPP)){
    KmPP = FALSE
  }
  if(missing(Normalize)){
    Normalize = FALSE
  }
  
  # Nromalizing the data
  if(Normalize==TRUE){
    demean <- sweep(data.matrix(dt[,,with=FALSE]),2,data.matrix(colMeans(dt)))
    dt <- data.table(sweep(demean,MARGIN = 2,FUN = '/',apply(data.matrix(dt), 2, sd)))
  }
  
  
  if(K <= nrow(dt)){
    #### Initializing centroids ####
    # set.seed(100)
    if(KmPP == TRUE){
      X <- 1
      dt.copy <- copy(dt)
      dt.copy <- unique(dt.copy)
      c1 <- sample(1:nrow(dt.copy),1)
      centroid.DT <- dt.copy[c1,]
      dt.copy <- dt.copy[-c1,]
      while(X < K){
        dist <- c()
        for (C in 1:nrow(centroid.DT)){
          distFromCentroid <- sweep(data.matrix(dt.copy[,,with=FALSE]),2,data.matrix(centroid.DT[C]))
          dist <- cbind(dist,sqrt(rowSums(apply(distFromCentroid, c(1,2), function(x) x^2))))
        }
        SUM <- rowSums(dist)
        n <- length(unique(SUM))
        centroid.DT <- rbind(centroid.DT,dt.copy[which(SUM == sort(unique(SUM),partial=n-1)[n]),])
        dt.copy <- dt.copy[-which(SUM == sort(unique(SUM),partial=n-1)[n]),]
        X <- X + 1
      }
    }
    else{
      centroid.DT <- dt[sample(.N, K)]
    }
    All.Centroid <- copy(centroid.DT)
    All.Centroid[,Itr:=count]
    All.Centroid <- cbind('label'=c(paste0('V',1:K)),All.Centroid)
    
    #### Lloyd's algorithm for k-means ####
    flag <- TRUE
    while(flag == TRUE){
      if(count == 0){
        dist <- c()
        # Finds the distance from each centroid stored in centroid.DT
        for (C in 1:nrow(centroid.DT)){
          distFromCentroid <- sweep(data.matrix(dt[,,with=FALSE]),2,data.matrix(centroid.DT[C]))
          dist <- cbind(dist,sqrt(rowSums(apply(distFromCentroid, c(1,2), function(x) x^2))))
        }
        # Assign point to nearest centroid
        dist <- data.table(dist)
        centroid.names <- names(dist)
        dist <- cbind(dist,'label' = colnames(dist)[apply(dist,1,which.min)])
        
        #### Centroid Collapse ####
        while(length(unique(dist$label))!= K){
          if(collapse == TRUE){
            centroid.DT <- dt[sample(.N, K)]
            dist <- c()
            # Finds the distance from each centroid stored in centroid.DT
            for (C in 1:nrow(centroid.DT)){
              distFromCentroid <- sweep(data.matrix(dt[,,with=FALSE]),2,data.matrix(centroid.DT[C]))
              dist <- cbind(dist,sqrt(rowSums(apply(distFromCentroid, c(1,2), function(x) x^2))))
            }
            dist <- data.table(dist)
            dist <- cbind(dist,'label' = colnames(dist)[apply(dist,1,which.min)])
          }
          else{
            message('Centroid Collapse Occured ',setdiff(centroid.names,unique(dist$label)),' missing!')
            temp.dist <- copy(dist)
            temp.dist <- data.matrix(data.frame(temp.dist)[,-ncol(temp.dist)])
            SUM <- rowSums(temp.dist)
            temp.dist <- cbind(temp.dist,'SUM'=rowSums(temp.dist))
            CC <- length(centroid.names) - length(unique(dist$label))
            
            for(missing.centroid in setdiff(centroid.names,unique(dist$label))){
              CC <- CC - 1
              n <- length(unique(SUM))
              X <- which(SUM == sort(unique(SUM),partial=n-1)[n-CC])
              dist[X,label:=missing.centroid]
            }
            collapse <- TRUE
          }
        }
        
        Label <- data.frame(dist[,.(label)])
        colnames(Label) <- paste0('label_',1:ncol(Label))
      }
      
      else{
        dist <- c()
        temp <- cbind(dt,'label' = Label[,ncol(Label)])
        # Compute the centroids as per the newly formed clusters
        centroid.DT <- temp[, lapply(.SD, mean), by=label]
        
        # Saving computed centroids to datatable
        temp.centroid.DT <- copy(centroid.DT)
        temp.centroid.DT[,Itr:=count]
        All.Centroid <- rbind(All.Centroid,temp.centroid.DT)
        
        # Finds the distance from each centroid stored in centroid.DT
        for (C in 1:nrow(centroid.DT)){
          distFromCentroid <- sweep(data.matrix(dt[,,with=FALSE]),2,data.matrix(centroid.DT[C,-1,with=FALSE]))
          dist <- cbind(dist,sqrt(rowSums(apply(distFromCentroid, c(1,2), function(x) x^2))))
        }
        # Assign point to nearest centroid
        dist <- data.table(dist)
        dist <- cbind(dist,'label' = colnames(dist)[apply(dist,1,which.min)])
        
        #### Centroid Collapse ####
        while(length(unique(dist$label))!= K){
          if(collapse == TRUE){
            centroid.DT <- dt[sample(.N, K)]
            dist <- c()
            # Finds the distance from each centroid stored in centroid.DT
            for (C in 1:nrow(centroid.DT)){
              distFromCentroid <- sweep(data.matrix(dt[,,with=FALSE]),2,data.matrix(centroid.DT[C]))
              dist <- cbind(dist,sqrt(rowSums(apply(distFromCentroid, c(1,2), function(x) x^2))))
            }
            dist <- data.table(dist)
            dist <- cbind(dist,'label' = colnames(dist)[apply(dist,1,which.min)])
          }
          else{
            message('Centroid Collapse Occured ',setdiff(centroid.names,unique(dist$label)),' missing!')
            temp.dist <- copy(dist)
            temp.dist <- data.matrix(data.frame(temp.dist)[,-ncol(temp.dist)])
            SUM <- rowSums(temp.dist)
            temp.dist <- cbind(temp.dist,'SUM'=rowSums(temp.dist))
            CC <- length(centroid.names) - length(unique(dist$label))
            
            for(missing.centroid in setdiff(centroid.names,unique(dist$label))){
              CC <- CC - 1
              n <- length(unique(SUM))
              X <- which(SUM == sort(unique(SUM),partial=n-1)[n-CC])
              dist[X,label:=missing.centroid]
            }
            collapse <- TRUE
          }
        }
        Label <- cbind(Label,dist[,.(label)])
        colnames(Label) <- paste0('Iteration_',0:(ncol(Label)-1))
      }
      
      # Determining the stopping criteria
      if (count > 0){
        
        if(Stop == 'Default' | toupper(Stop) != 'SSE'){
          # Centroid movement
          A <- data.frame(All.Centroid[Itr == count,][,-1])
          A <- data.matrix(A[,-ncol(A)])
          B <- data.frame(All.Centroid[Itr == count-1,][,-1])
          B <- data.matrix(B[,-ncol(B)])
          Result <- (1/K) * sum(sqrt(rowSums(apply(A-B,c(1,2), function(x) x^2))))
          message(paste('Iteration',count,'Change in Centroid position',Result))
          if(Result < Threshold | count >= Iteration){
            flag <- FALSE
            return(list(Label[,ncol(Label)],count))
          }
        }
        
        else{
          # Checking SSE
          SSE <- c()
          dt.Label <- data.table(cbind(dt,'label' = Label[,ncol(Label)]))
          for (p in sort(unique(centroid.DT$label))){
            distFromCentroid <- sweep(data.matrix(dt.Label[label==p,-ncol(dt.Label),with=FALSE]),2,data.matrix(centroid.DT[label == p,-1,with=FALSE]))
            SSE <- c(SSE,sqrt(rowSums(apply(distFromCentroid, c(1,2), function(x) x^2))))
          }
          SSE <- sum(SSE)
          message(paste('Iteration',count,'SSE',SSE))
          if(SSE < Threshold | count >= Iteration){
            flag <- FALSE
            return(list(cbind(Label[,ncol(Label)]),count,SSE))
          }
        }
      }
      count <- count + 1
    }
  }
  else{
    return('Clustering Not Possible')
  }
}