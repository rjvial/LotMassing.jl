function evol(fitness, lb, ub, numParticles, maxiter, verbose)

    sr = [(lb[i], ub[i]) for i = 1:length(lb)]
    
    fopt = 10000
    xopt = []
    for k = 4:4
        sr[2] = (-pi+(k-1)*pi/2, -pi/2+(k-1)*pi/2)
        for i = 1:5
            display(i)

            opt = bbsetup(fitness; SearchRange=sr, NumDimensions=length(lb),
                    Method=:adaptive_de_rand_1_bin_radiuslimited, MaxSteps=18000,
                    TraceMode=:silent)

            result = BlackBoxOptim.bboptimize(opt)

            f_i = BlackBoxOptim.best_fitness(result)
            display(f_i)
            if f_i < fopt
                fopt = f_i
                xopt = BlackBoxOptim.best_candidate(result)
            end
        end
    end

    sr = [(xopt[i] - 0.05 * abs(xopt[i]), xopt[i] + 0.05 * abs(xopt[i])) for i = 1:length(lb)]
    sr[end] = (lb[end], lb[end])
    
    result = BlackBoxOptim.bboptimize(fitness; SearchRange=sr, NumDimensions=length(lb),
            Method=:adaptive_de_rand_1_bin_radiuslimited, MaxSteps=30000,
            TraceMode=:silent, NThreads=Threads.nthreads())
    fopt = BlackBoxOptim.best_fitness(result)
    xopt = BlackBoxOptim.best_candidate(result)

    return xopt, fopt

end

