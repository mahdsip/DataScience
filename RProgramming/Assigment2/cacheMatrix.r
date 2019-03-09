## This function creates a special "matrix" object that can cache its inverse.
makeCacheMatrix <- function(x = matrix()) {
        m <- NULL
        set <- function(y) {
                x <<- y
                m <<- NULL
        }
        get <- function() x
        setinverse <- function(inverse) m <<- inverse
        getinverse <- function() m
        list(set = set, get = get,
             setmean = setmean,
             getmean = getmean)
}

## Return a matrix that is the inverse of 'x'
##This function computes the inverse of the special "matrix" returned by makeCacheMatrix above. 
##First check if the objects exits before return it 
##If is not present it is calculated, stored in caché and returned
cacheSolve <- function(x, ...) {
        m <- x$getinverse()
        if(!is.null(m)) {
                message("getting cached data")
                return(m)
        }
        data <- x$get()
        m <- solve(data, ...)
        x$setinverse(m)
        m
}
