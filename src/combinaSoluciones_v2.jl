function combinaSoluciones_v2(fitness_ss, fitness_cs, lb, ub, numParticles, maxIterations)

    cond_1 = true
    xopt_1 = []
    fopt_1 = 0
    while cond_1
        xopt_1, fopt_1 = evol(fitness_ss, lb, ub, numParticles, maxIterations, false)
        if fopt_1 < 0
            cond_1 = false
        end
    end
    cond = true
    delta = 1
    xopt_cs = xopt_1
    fopt_cs = fopt_1
    while cond
        fopt_cs = fitness_cs(xopt_cs)
        if fopt_cs < 0
            cond = false
        else
            xopt_cs[1] -= delta
        end
    end

    return xopt_cs, fopt_cs
    
end