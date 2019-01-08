nnet_g <- function(X, Y, step_size = 0.5, reg = 0.001, h = 10, niteration){  
    # get dim of input  
    N <- nrow(X) # number of examples  
    K <- ncol(Y) # number of classes  
    D <- ncol(X) # dimensionality   
    # initialize parameters randomly  
    W <- 0.01 * matrix(rnorm(D*h), nrow = D)  
    b <- matrix(0, nrow = 1, ncol = h)  
    W2 <- 0.01 * matrix(rnorm(h*K), nrow = h)  
    b2 <- matrix(0, nrow = 1, ncol = K)   
    # gradient descent loop to update weight and bias  
    for (i in 0:niteration){    
        # hidden layer, ReLU activation    
        hidden_layer <- pmax(0, X %*% W + matrix(rep(b,N), nrow = N, byrow = T))    
        hidden_layer <- matrix(hidden_layer, nrow = N)    
        # class score    
        scores <- hidden_layer %*% W2 + matrix(rep(b2,N), nrow = N, byrow = T)     
        # compute and normalize class probabilities    
        exp_scores <- exp(scores)    
        probs <- exp_scores / rowSums(exp_scores)     
        # compute the loss: softmax and regularization    
        corect_logprobs <- -log(probs)    
        data_loss <- sum(-log(probs) * Y) / N    
        reg_loss <- 0.5*reg*sum(W*W) + 0.5*reg*sum(W2*W2)    
        loss <- data_loss + reg_loss    
        # check progress    
        if (i%%1000 == 0 | i == niteration){      
            print(paste("iteration", i,': loss', loss))}     
        # compute the gradient on scores    
        dscores <- probs-Y    
        dscores <- dscores/N     
        # backpropate the gradient to the parameters    
        dW2 <- t(hidden_layer)%*%dscores    
        db2 <- colSums(dscores)    
        # next backprop into hidden layer    
        dhidden <- dscores%*%t(W2)    
        # backprop the ReLU non-linearity    
        dhidden[hidden_layer <= 0] <- 0    
        # finally into W,b    
        dW <- t(X)%*%dhidden    
        db <- colSums(dhidden)     
        # add regularization gradient contribution    
        dW2 <- dW2 + reg * W2    
        dW <- dW + reg * W     
        # update parameter     
        W <- W-step_size*dW    
        b <- b-step_size*db    
        W2 <- W2-step_size*dW2    
        b2 <- b2-step_size*db2  }  
    return(list(W=W, b=as.vector(b), W2=W2, b2=as.vector(b2)))}
