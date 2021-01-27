function evol(fitness, lb, ub, numParticles, maxiter, verbose)

    method = DE(populationSize = numParticles, F = 0.9, K = 0.5*(0.9+1));
    #method = CMAES(mu = 300, lambda = 1200)
    bounds = Evolutionary.ConstraintBounds(lb,ub,[],[]);
    #pop = Evolutionary.initial_population(method, bounds);

    options = Evolutionary.Options(iterations=maxiter, show_trace = verbose)
    result = Evolutionary.optimize(fitness, bounds, method, options)


    xopt = Evolutionary.minimizer(result)
    fopt = Evolutionary.minimum(result)


    return xopt, fopt

end

