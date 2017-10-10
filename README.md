# Algorithm
Contains the algorith implementation, a list of protocols followed for successful implementation and sample input and out for usage purpose.
 
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
  * **K**: Number of clusters. Optional parameter, *Default* K = 2.
  * **Stop**: The stopping/convergence criteria. Optional Parameter,
    - *Default* Change in centroid position or 
    - SSE.
Default: Change in centroid position.
  * **Threshold**: Optional parameter, a limit below which if the value of the stopping criteria attribute
falls, convergence is achieved. *Default* Threshold = 1
  * **Iteration**: Optional parameter, a limit beyond which the algorithm halts irrespective of the convergence/stopping criteria. *Default* Iteration = 50.
  * **KmPP**: Optional parameter, Activates k-means++ algorithm for centroid initialization. *Default* KmPP =
FALSE.
  * **Normalize**: Optional parameter, whether to normalize or standardize the data provided in dt. Normalizing the data is necessary as this would negates the effect that the different scale of values that
each dimension/feature holds. The way I have normalized the values is:
  \[X_{n*q} \leftarrow \frac{x_{n*q}-\bar{x_q}}{\sigma_q}\]  
  where, $x_{n*q}$ cell value at a certain row $n$ and column $q$ in the data.  
  $\bar{x_q}$ is the mean of all the values for column $q$.  
  $\sigma_q$ is the standard deviation of column $q$.  
  $X_{n*q}$ is the new value that is substitute in-place of $x_{n*q}$  
  *Default* Normalize = FALSE

### Output
The kMeans function returns a list:  
  1. Cluster Labels  
  2. \# Iterations required for convergence.  
  3. SSE $\leftarrow$ only returned when ```Stop = SSE```  

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
unlist(Result[1])
unlist(Result[2])
unlist(Result[3])
```
