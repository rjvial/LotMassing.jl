function combinaSoluciones_v2(fitness_ss, fitness_cs, lb, ub, numParticles, maxIterations)

    cond_1 = true
    xopt_1 = []
    fopt_1 = 0
    while cond_1
        xopt_1, fopt_1 = evol(fitness_ss, lb, ub, numParticles, maxIterations, false)
        if fopt_1 < 0
            cond_1 = false
            display("fitness_ss ok")
        end
    end
    cond = true
    delta = 1
    xopt_cs = xopt_1
    fopt_cs = fopt_1
#    while cond
        fopt_cs = fitness_cs(xopt_cs)
        if fopt_cs < 0
            display("fitness_cs ok")
            cond = false
        else
            numParticles_cs = numParticles
            maxIterations_cs = maxIterations
            lb_cs = xopt_cs - [3 0 0 3 3 0]'
            xopt_cs, fopt_cs = evol(fitness_cs, lb, xopt_cs, numParticles_cs, maxIterations_cs, false)
            display("fitness_cs ok")
        end
#    end

    return xopt_cs, fopt_cs
    
end