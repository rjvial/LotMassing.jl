function evol(fitness, lb, ub, numParticles, maxiter, verbose)


    sr = [(lb[i], ub[i]) for i = 1:length(lb)]
    
    fopt = 10000
    xopt = []
    for k = 1:4
        sr[2] = (-pi + (k - 1) * pi / 2, -pi / 2 + (k - 1) * pi / 2)
        strProgress = "Optimizing " * string(k) * "/4..." 
        @showprogress strProgress for i = 1:5
            opt = bbsetup(fitness; SearchRange=sr, NumDimensions=length(lb),
                    Method=:adaptive_de_rand_1_bin_radiuslimited, MaxSteps=18000,
                    TraceMode=:silent)

            result = BlackBoxOptim.bboptimize(opt)

            f_i = BlackBoxOptim.best_fitness(result)
            # display(f_i)
            if f_i < fopt
                fopt = f_i
                xopt = BlackBoxOptim.best_candidate(result)
            end
        end
    end

    MaxFuncEvals = 50000

    # Minimum update interval 0.5 seconds
    Prog = ProgressMeter.Progress(MaxFuncEvals, 0.5, "Final Optimization...") 

    callback_progress_stepper = optcontroller -> ProgressMeter.update!(Prog, BlackBoxOptim.num_func_evals(optcontroller))

    sr = [(lb[i], ub[i]) for i = 1:length(lb)]
    sr[1] = (xopt[1] - 0.05 * xopt[1], xopt[1] + 0.05 * xopt[1])
    sr[2] = (xopt[2] - 0.05 * abs(xopt[2]), xopt[2] + 0.05 * abs(xopt[2]))
    #sr = [(xopt[i] - 0.05 * abs(xopt[i]), xopt[i] + 0.05 * abs(xopt[i])) for i = 1:length(lb)]
   
    result = BlackBoxOptim.bboptimize(fitness; 
            SearchRange = sr, 
            NumDimensions = length(lb),
            Method = :adaptive_de_rand_1_bin_radiuslimited, 
            MaxFuncEvals = MaxFuncEvals,
            CallbackFunction = callback_progress_stepper, 
            CallbackInterval = 0.0,
            TraceMode = :silent)
    f_f = BlackBoxOptim.best_fitness(result)
    x_f = BlackBoxOptim.best_candidate(result)

    if f_f < fopt
        fopt = f_f
        xopt = x_f
    end
    
    return xopt, fopt

end

