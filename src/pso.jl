
function update_position!(x, p, fx, fp)
    i_update = (fx .< fp) 
    p[i_update, :] = copy(x[i_update, :])
    fp[i_update, :] = fx[i_update, :]
end


function pso(func, lb, ub; swarmsize=100, ω=0.5, ϕp=0.5, ϕg=0.5, maxiter=100, 
             verbose=false, swarmIni=[], particle_output=false)

    obj = x -> func(x)
    
    minstep=1e-8
    minfunc=1e-8 

    # Initialize the particle swarm
    vhigh = abs.(ub .- lb) .*0.2
    vlow = -vhigh .*0.2
    S = swarmsize
    D = length(lb)  # the number of dimensions each particle has

    if length(swarmIni)>=1
        x=swarmIni
    else
        x = lb' .+ rand(S, D) .* (ub .- lb)'  # particle positions
    end
    v = vlow' .+ rand(S, D) .* (vhigh .- vlow)'  # particle velocities
    p = zeros(S, D)  # best particle positions

    Vmin = ones(S,1) * vlow'
    Vmax = ones(S,1) * vhigh'

    fx = [obj(x[i, :]) for i = 1:S]  # current particle function values
    fp = ones(S) * Inf  # best particle function values

    g = copy(x[1, :])  # best swarm position
    fg = Inf  # best swarm position starting value

    # Store particle's best position (if constraints are satisfied)
    update_position!(x, p, fx, fp)

    # Update swarm's best position
    i_min = argmin(fp)
    if fp[i_min] < fg
        g = copy(p[i_min, :])
        fg = fp[i_min]
    end

    # Iterate until termination criterion met
    it = 1
    while it <= maxiter
        rp = rand(S, D)
        rg = rand(S, D)

        # Update the particles' velocities and positions
        ω = ω
        v = ω*v .+ ϕp*rp.*(p .- x) .+ ϕg*rg.*(g' .- x)
        v = min.(v,Vmax)
        v = max.(v,Vmin)

        x += v
        # Correct for bound violations
        maskl = x .< lb'
        masku = x .> ub'
        x = x.*(.~(maskl .| masku)) .+ lb'.*maskl .+ ub'.*masku

        # Update objectives and constraints
        for i = 1:S
            fx[i] = obj(x[i, :])
        end

        # Store particle's best position (if constraints are satisfied)
        update_position!(x, p, fx, fp)

        # Compare swarm's best position with global best position
        i_min = argmin(fp)
        if fp[i_min] < fg
            verbose && println("New best for swarm at iteration $(it): $(p[i_min, :]) $(fp[i_min])")

            p_min = copy(p[i_min, :])
            stepsize = √(sum((g .- p_min).^2))

            if abs.(fg .- fp[i_min]) <= minfunc
                verbose && println("Stopping search: Swarm best objective change less than $(minfunc)")
                return (g, fg, p, fp)
            end
            if stepsize <= minstep
                verbose && println("Stopping search: Swarm best position change less than $(minstep)")
                return (g, fg, p, fp)
            end

            g = copy(p_min)
            fg = fp[i_min]
        end

        verbose && println("Best after iteration $(it): $(g) $(fg)")
        it += 1
    end

    verbose && println("Stopping search: maximum iterations reached --> $(maxiter)")
    return particle_output ? (g, fg, p, fp) : (g, fg)
end
