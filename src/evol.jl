function evol(fitness, lb, ub, numParticles, maxiter, verbose)

    sr = [(lb[i], ub[i]) for i=1:length(lb)]
    
    fopt = 10000
    xopt = []
    for i=1:15
        println(i)
        result = BlackBoxOptim.bboptimize(fitness; SearchRange = sr, NumDimensions = length(lb),
                    Method = :adaptive_de_rand_1_bin_radiuslimited, MaxSteps = 18000,
                    TraceMode = :silent)
        f_i = BlackBoxOptim.best_fitness(result)
        if f_i < fopt
            fopt = f_i
            println(fopt)
            xopt = BlackBoxOptim.best_candidate(result)
        end
    end

    sr = [(xopt[i]-0.05*abs(xopt[i]), xopt[i]+0.05*abs(xopt[i])) for i=1:length(lb)]
    sr[end] = (lb[end], lb[end])
    
    result = BlackBoxOptim.bboptimize(fitness; SearchRange = sr, NumDimensions = length(lb),
            Method = :adaptive_de_rand_1_bin_radiuslimited, MaxSteps = 30000,
            TraceMode = :silent)
    fopt = BlackBoxOptim.best_fitness(result)
    xopt = BlackBoxOptim.best_candidate(result)

    return xopt, fopt

end

