rm(list=ls(all=TRUE))

require(ggplot2)
require(data.table)

EM.Clust <- function(data, Bound, Threshold, K, Normalize){
  ## Initializing Default values
  if(missing(Bound)){
    Bound=50
    message('Iterations set to ',Bound)
  }
  if(missing(Threshold)){
    Threshold=10 ^-10
    message('Threshold set to ',Threshold)
  }
  if(missing(K)){
    K=4
    message('# Clusters set to ',K)
  }
  if(missing(Normalize)){
    Normalize = FALSE
  }
  
  # Nromalizing the data
  if(Normalize==TRUE){
    demean <- sweep(data,2,colMeans(data))
    data <- sweep(demean,MARGIN = 2,FUN = '/',apply(data, 2, sd))
  }
  
  
  #### Random Initialization ####
  MU <- data[sample(nrow(data), K),]
  SIGMA <- replicate(K,diag(ncol(data)),simplify = FALSE)
  Pr <- replicate(K,1/K)
  W <- matrix(0, nrow = nrow(data), ncol = K)
  Iteration <- 1
  
  #### Algorithm ####
  while(TRUE){
    #### Expectation Step ####
    for(j in 1:nrow(data)){
      for(i in 1:K){
        while(TRUE){
          f <-  mvtnorm::dmvnorm(x = data[j,]
                                 ,mean = MU[i,]
                                 ,sigma = SIGMA[[i]])
          if(f == 0){
            SIGMA[[i]] <- SIGMA[[i]] + (diag(ncol(data)) * 10^-5)
          }
          else{break}
        }
        W[j,i] <- f * Pr[i]
      }
      W[j,] <- W[j,]/sum(W[j,])
    }
    
    #### Maximization Step ####
    NEW.MU <- matrix(0,nrow = K, ncol = ncol(data))
    NEW.SIGMA <- replicate(K,diag(ncol(data)),simplify = FALSE)
    NEW.Pr <- replicate(K,1/K)
    
    for(i in 1:K){
      
      ## Compute Mu
      temp.MU <- 0
      for(j in 1:nrow(data)){
        temp.MU <- temp.MU + (data[j,] * W[j,i])
      }
      NEW.MU[i,] <- t(as.matrix(temp.MU))/sum(W[,i])
      
      ## Compute Sigma
      temp.SIGMA <- 0
      for(j in 1:nrow(data)){
        Z <- as.matrix(data[j,] - NEW.MU[i,])
        temp.SIGMA <-  temp.SIGMA + (W[j,i] * ((Z) %*% t(Z)))
      }
      NEW.SIGMA[[i]] <-  temp.SIGMA/sum(W[,i])
      
      ## Compute Priors
      NEW.Pr[i] <- sum(W[,i])/nrow(data)
    }
    
    #### Checking exit condition ####
    Check <- sqrt(sum(colSums(apply(NEW.MU - MU, c(1,2), function(x) x^2))))
    message(Iteration," : ",Check)
    if(Check <= Threshold | Iteration > Bound){
      ## Check Collaspe ##
      W.dt <- data.table::data.table(W)
      cluster.present <- unique(colnames(W.dt)[apply(W.dt,1,which.max)])
      substrRight <- function(x, n){substr(x, nchar(x)-n+1, nchar(x))}
      if(length(cluster.present) != K){
        message('EM Collaspe Occurred!')
        for (i in setdiff(paste0('V',1:K),cluster.present)){
          col <- as.integer(substrRight(i,1))
          row <- which.max(W[,col])
          W[row,] <- .45/(K-1)
          W[row,col] <- .55
        }
      }
      stopifnot(sum(rowSums(W)) == nrow(data))
      W.dt <- data.table::data.table(W)
      return(list(colnames(W.dt)[apply(W.dt,1,which.max)],Iteration))
    }
    else{
      Iteration <- Iteration + 1
      MU <- NEW.MU
      SIGMA <- NEW.SIGMA
      Pr <- NEW.Pr
    }
  }
}