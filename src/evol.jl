function evol(fitness, lb, ub, MaxSteps, verbose)

    # Minimum update interval 0.5 seconds
    Prog = ProgressMeter.Progress(MaxSteps, 0.5, "Final Optimization...")

    callback_progress_stepper = optcontroller -> ProgressMeter.update!(Prog, BlackBoxOptim.num_steps(optcontroller))

    sr = [(lb[i], ub[i]) for i = 1:length(lb)]

    if verbose
        opt = bbsetup(fitness; 
            SearchRange = sr, 
            NumDimensions = length(lb),
            Method = :adaptive_de_rand_1_bin_radiuslimited, 
            #MaxFuncEvals = MaxFuncEvals,
            MaxSteps = MaxSteps,
            MaxStepsWithoutProgress = 5000,
            CallbackFunction = callback_progress_stepper, 
            CallbackInterval = 0.0,
            TraceMode = :silent)
    else
        opt = bbsetup(fitness; 
            SearchRange = sr, 
            MaxSteps = MaxSteps,
            MaxStepsWithoutProgress = 5000,
            NumDimensions = length(lb),
            Method = :adaptive_de_rand_1_bin_radiuslimited, 
            TraceMode = :silent)
    end
    result = BlackBoxOptim.bboptimize(opt)
    fopt = BlackBoxOptim.best_fitness(result)
    xopt = BlackBoxOptim.best_candidate(result)

    
    return xopt, fopt

end

