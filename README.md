# Algorithm
Contains the algorithm implementation, a list of protocols followed for successful implementation and sample input and out for usage purpose.
 
## K-Means

### Protocols/Strategy followed:

#### Initializing centroids
Centroids are assigned randomly. Choosing K centroids from the given data points.\\
  
#### Maintaining K centroids
On assigning data-points to its nearest centroid, a situation may arise - for some of the centroids there is no data-point assigned. This is referred to as centroid collapse.  
To counter this, I have incorporated the following strategy:  
  + Sum of distances for each data point from the existing centroids.  
  + The data point(s) with the maximum distance are chosen as the new centroids  
  + Implicitly stating that the new clusters would have at least one data point(centroid itself) associated with it.  
  + Now, the re-computation of the centroids is done by taking the mean of the data-points associated with the now-new clusters.  
  +  There might occur a condition when this method might not resolve the problem, in that case I redo the random centroid initialization.  
   
#### Deciding ties
A tie occurs when one data point is equidistant from one or more centroids. 
If a tie occurs, the data point is labelled to the centroid that comes first alphabetically.  
  
#### Stopping criteria
The implementation is such that it gives the user the preference to chose from 2 stopping criteria.  
  + **Default**: Change in the centroid position.  
  + **SSE**: Total SSE for all the clusters.  

The threshold specified much be stated as per the stopping criteria. A bound on the iterations can also be set, this is vital in circumstances when the stopping parameter never comes below the threshold.

### Input/Parameters
  * **dt**: The data, this is a compulsory parameter.
  * **K**: Number of clusters. Optional parameter, *Default: K = 2*.
  * **Stop**: The stopping/convergence criteria. Optional Parameter,
    - *Default: Change in centroid position* or 
    - SSE.
  * **Threshold**: Optional parameter, a limit below which if the value of the stopping criteria attribute
falls, convergence is achieved. *Default: Threshold = 1*
  * **Iteration**: Optional parameter, a limit beyond which the algorithm halts irrespective of the convergence/stopping criteria. *Default: Iteration = 50*.
  * **KmPP**: Optional parameter, Activates k-means++ algorithm for centroid initialization. *Default: KmPP = FALSE*.
  * **Normalize**: Optional parameter, whether to normalize or standardize the data provided in dt. *Default: Normalize = FALSE*.

### Output
The _kMeans_ function returns a list:  
  1. Cluster Labels  
  2. \# Iterations required for convergence.  
  3. SSE, only returned when ```Stop = SSE```  

### Usage
```
dt <- data.table('X1'=c(1,1,0,5,6,4),'X2'=c(4,3,4,1,2,0))
Result <- kMeans(dt = dt
                 ,K = 2
                 ,Threshold = 1
                 ,Iteration = 100
                 ,KmPP = TRUE
                 ,Normalize = F
                 ,Stop = 'SSE')
Cluster.label <- unlist(Result[1])
Itr <- unlist(Result[2])
SSE <- unlist(Result[3])
```

## Expectatation Maximization -- Gaussian Mixture Model

### Protocols/Strategy followed:

#### Initialization
  - Initializing each Gaussian: Randomly initialize the means for every Gaussian by choosing K data-points from the total data-points without replacement.  
  - The initial covariance matrix(SIGMA): Assigned as a identity matrix of the order _d x d_, where _d_ are the number of columns in the data-matrix.
  - Prior probabilities are taken as equal, meaning that the data-point has equal probability of appearing/associating with each cluster/Gaussian. 

#### Deciding ties
  If tie occurs, i.e. a data-point exhibits equal probability of belonging to more than one Gaussian, then the Gaussian which appears first chronologically gets that data-point. 

#### Stopping criteria
  Convergence is said to have occurred if ![equation](https://latex.codecogs.com/gif.latex?%24%5Csum_%7Bi%3D1%7D%5E%7BK%7D%7C%7C%5Cmu_t%20-%20%5Cmu_%7Bt-1%7D%7C%7C%20%5Cleq%20%5Cepsilon%24.%20%24%5Cepsilon%24) is taken to be or the order 10^{-10}. Now, there are situations when this criteria will not be met, in which case a bound on the iterate is issued, the value of which is kept to 25 iterations.

#### Dealing with Singular matrix
  Singular matrix is encountered if the determinant of matrix results in 0. I have explored 3 method of getting around this situation. Discussing them below:  
  + Consider convergence in the weights(probabilities) of the W(i-1) iteration, as the W(i) would be 0, due to results in the singular matrix sigma. By doing this, convergence is not achieved.  
  + Neglect the run and have a fresh initialization done. Perform this until we get to convergence. This method ensures that the EM algorithm leads to convergence but, we end up initializing from a set of cluster(Gaussian) means that remain relatively consistent over the numerous run of the EM algorithm. Any other initialization would obviously result in singular matrix, thus, redoing the entire process.  
  + Perform pseudo inverse: This helps deal with few cases. We need to think of a matrix to substitute with Sigma to get its determinant. I decided to substitute it with pseudo inverse matrix. This might not be the best solution to this as this is a random thought that came in my mind.  
  + Introduce a small error(10^-5) if the sigma is singular.  
Of all the above methods, introducing a small error(10^-5) is the best. As the error appears to have minimized.

### Input/Parameters
  * **data**: The data, this is a compulsory parameter. Expects a data to be passed as a _data.matrix_.
    
  * **K**: Number of clusters. Optional parameter, *Default:K=2*.
    
  * **Threshold**: Optional parameter, a limit below which if the value of the stopping criteria attribute falls, convergence is achieved. *Default: Threshold = 10^{-10}*.
    
  * **Bound**: Optional parameter, a limit beyond which the algorithm halts irrespective of the convergence/stopping criteria. *Default:Bound = 50*.
    
  * **Normalize**: Optional parameter, whether to normalize or standardize the data provided in data. *Default: Normalize = FALSE*.
    
### Output
The _EM.Clust_ function returns a list as output. The list consists of 2 elements: 
\begin{enumerate}
  - A vector that contains cluster labels.
  - \# Iterations taken to achieve convergence.
  
### Usage
```
data <- fread('https://archive.ics.uci.edu/ml/machine-learning-databases/ionosphere/ionosphere.data')
Observed <- data$V35  
data$V35 <- NULL
data$V2 <- NULL
Result <- EM.Clust(data = data.matrix(data)
                   ,Normalize = T)
Cluster.label <- unlist(Result[1])
Itr <- unlist(Result[2])
```  