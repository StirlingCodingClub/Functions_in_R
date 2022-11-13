#' # Using functions in R
#' Thiago Silva - 17/11/2021
#'
#' ## Part 1 - Why functions?
#'
#' One of the main "rules" of programming is *"never write the same code twice"*.
#' This is not just a case of purism or efficiency, but also safety.
#' Every time you write something again, you increase the chance of introducing errors.
#'
#' This is where functions come in. They allow you to create reusable pieces of code,
#' saving you time and making sure your results are safely repeatable. Most operations
#' you do in R are already functions. For example, the mean function:

set.seed(1979)
myvec <- rnorm(10,0,1) # Draw 10 random numbers normal distrib w/ mean 0, std 1
mean(myvec) # caculate the mean

class(mean) # What class of object is mean?
class(rnorm) # What class of object is function?

mean # What is inside the mean function?
rnorm # Idem for rnorm

#' Most of R's base functions (knoowns as *primitive functions) are written
#' in the C language, and just called used `.Primitive()`.
#' That is why can't actually see the code when we call the function name.
#'
#' It turns out we can actually write our own functions in R!
#' For example, we could recreate the mean function ourselves.
#' Let's first write the code to calculate the mean manually:

sum_myvec <- sum(myvec) # Sum of all observations
n_myvec <- length(myvec) # length of all observations
mean_myvec <- sum_myvec / n_myvec # mean = sum / n
mean_myvec # show result
mean_myvec == mean(myvec) # testing if it works

#' Great, you have code to calculate the mean of myvec now.
#' But what if you then get a second set of data?
set.seed(1979)
other_vec <- rnorm(15,2,5)
other_vec

#' Now you need to redo all the calculations above.
#' Easy right, you just copy and pas...NO! BAD! BAD PROGRAMMER!
#' The answer is, you make it into a function!

# First step: initialise a new function
# and specify what inputs (parameters) it takes
my_mean <- function(x) { # this function takes one parameter
    sum_x <- sum(x) # Sum of all observations in x
    n_x <- length(x) # number of observations in x
    mean_x <- sum_x / n_x # mean = sum / n
}

#' As you can see, other than the variable names, the code is exactly the same.
#' But who is x? Well, x is any vector we pass as x.
#' So let's apply our function to other_vec:

my_mean(x = other_vec)

#' Oooops, why isn't it showing any output? What did we miss?
#'
#' Turns out functions don't automatically know which part of the code
#' you want to use it outside of the function, so you need to say it.

my_mean2 <- function(x) { # this function takes one parameter
    sum_x <- sum(x) # Sum of all observations in x
    n_x <- length(x) # number of observations in x
    mean_x <- sum_x / n_x # mean = sum / n
    return(mean_x)
}

# TADA
my_mean2(other_vec)

# As an aside, why many programmers hate R - inconsistency:
my_mean(other_vec)
other_mean <- my_mean(other_vec)
other_mean
# WHYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYYY?

# Second aside: why not write the function as:
my_mean3 <- function(x) return(sum(x)/length(x))
# Does it work?
my_mean2(other_vec) == my_mean3(other_vec)

# You may want to add new features to your function that reuse some of the
# intermediate steps. Also, it is easy to debug when there are errors, as you
# can check the function step by step. Finally, it is also easier to see changes
# if you use version control such as Git.

#' ## 2 - Function scopes
#'
#' The most important concept when working with functions is the notion of scope.
#' In R language this is determined by the "environment". In other languages, you
#' may hear the term "namespace".
#' Imagine that an environment is a box where you store all your variables.
#' If you look to the top right panel of default RStudio, the first tab you see\
#' is called "environment". And right under it, you see the name "global environment".
#' The global environment is the big box where all the stuff you create is stored.
#'
#' If you click the little down arrow beside "Global environment", you will see
#' that all packages that have been loaded also have their own environments.
#' This is why, for example, we can use functions such as `sum()` or `length()`,
#' even though they are not on the list of objects in the global environment.
#' They are stored in the `base` package environment.
#'
#' One thing we need to be really careful about is not to create variables or
#' functions with the same environment, as they will mask each other:

my_mean2 <- function(x) { # this function takes one parameter
    print("This is my custom mean")
    sum_x <- sum(x) # Sum of all observations in x
    n_x <- length(x) # number of observations in x
    mean_x <- sum_x / n_x # mean = sum / n
    return(mean_x)
}

my_mean2(other_vec)

mean <- my_mean2

mean(other_vec)
# Oh no we broke it.

#' In the example above, since we create a function called mean in the global
#' environment, and by definition when we call an object R will first look for
#' it in the global environment, and only proceed to other environments if it
#' doesn't find it. However, we can specify the environment it should come from
#' if we want.

mean(other_vec)
mean

base::mean(other_vec)
base::mean

#' In some languages, such as Python, it is standard practice to always specify
#' the namespace/environment of the functions. It reduces the chance of masking
#' and also makes it more explicit which package is being used where. But it
#' makes the code more verbose.
#'
#' Before we continue, let's fix our mistake:

rm("mean") # removes the object named mean. As always, it will look on global first.
mean

#' But now back to function scopes. A scope means "what environments can it see?".
#' Unlike most languages, R functions have access to the global environment, so
#' the code below works:

global_x <- c(1,2,3) # define an object in global environment

myfun <- function(){ # function that has no inputs
    return(max(global_x)) # return the maximum value of global_x
}

# Now call the function
myfun()

#' However, once we create a function, all of the operations inside the function
#' are carried on a separate, temporary environment, and are destroyed once the
#' fucntion finishes running. Let us recall the contens of our `my_mean2` function:

my_mean2

#' We are creating `sum_x`, `n_x` and `mean_x` inside the function, but if you
#' look at the global environment, none of these objects exist. Even after
#' calling the function, I can't access them:

my_mean2(other_vec)
#num_x

#' So it is important to remember to `return()` from the function whatever
#' information you want to keep. It doesn't have to be a single number either,
#' `return` will return any type of R object that you create. Let us make a new
#' summary function:

my_summ <- function(x){
    n_x <- length(x)
    mean_x <- mean(x)
    sd_x <- sd(x)
    se_x <- sd_x / sqrt(n_x)
    cv_x <- sd_x / mean_x
    return(c(n_x, mean_x,sd_x,se_x,cv_x))
}

results <- my_summ(other_vec)
class(results)

# We can make it prettier:

my_summ <- function(x){
    n_x <- length(x)
    mean_x <- mean(x)
    sd_x <- sd(x)
    se_x <- sd_x / sqrt(n_x)
    cv_x <- sd_x / mean_x
    namevec <- c("N","Mean","Std. Dev.", "Std. Err.", "CV")
    out_vec <- c(n_x, mean_x,sd_x,se_x,cv_x)
    names(out_vec) <- namevec
    return(out_vec)
}
my_summ(other_vec)

# or even prettier:
my_summ <- function(x){
    n_x <- length(x)
    mean_x <- mean(x)
    sd_x <- sd(x)
    se_x <- sd_x / sqrt(n_x)
    cv_x <- sd_x / mean_x
    namevec <- c("N","Mean","Std. Dev.", "Std. Err.", "CV")
    out_df <- data.frame("Summary" = c(n_x, mean_x,sd_x,se_x,cv_x))
    rownames(out_df) <- namevec
    return(round(out_df,2))
}
my_summ(other_vec)

#' ## The anatomy of a function
#'
#' A function is composed of a set of *arguments* or *parameters*, the inputs to the function,
#' and the function *body* (as well as its environment). You can pass as many
#' parameters as you need to a function. You can also specify default values.

# A simple sum function
mysum <- function(x,y){
    return(x+y)
}

a <- 3
b <- 5
mysum(x=a,y=b)

#  We can specify default parameters
mysum(x=a)

mysum <- function(x,y=0){
    return(x+y)
}

mysum(x=a)

#' R can also associate values to positional arguments, based on the order. This
#' is commun usage in R, but usually recommended only for the first one or two
#' arguments. It will also do partial argument matching, so one good idea is to
#' avoid naming parameters with the same starting letters:
#'
mysum <- function(xargument,yargument=0){
    return(xargument+yargument)
}

mysum(x = a, y = b)

mysum(a,b)

#' Finally, you can pass all arguments to a function as a list (for example if they
#' are generated by the code itself), by using `do.call()` to call the function.

args <- list(a,b)
args

do.call(mysum,args)

#' ## Using functions to automate work
#'
#' Going back to the beginning, we can use a function to store any code we would
#' like to repeat for different objects. Let us imagine we have several data files
#' in csv format that we would like to read:
#'\

mydata <- read.csv('datafile_1.csv')

str(mydata)

mydata$X <- NULL
mydata$sample <- as.factor(mydata$sample)
mydata$month <- as.factor(mydata$month)
mydata$year <- as.factor(mydata$year)

mydata$lw_ratio <- mydata$length / mydata$weight


# TO BE CONTINUED ...
