function factorIgualaArea(V, areaSup)

    fmin = 90000
    fmax = 110000

    cond = true
    while cond
        factor = (fmin + fmax)/2
        V_ = factor .* copy(V)
        areaCalc = poly2D.polyArea(V_)
        if abs(areaCalc - areaSup) <= 1
            cond = false
            return factor        
        elseif areaCalc <= areaSup
            fmin = factor
            factor = (factor + fmax)/2
        else
            fmax = factor
            factor = (factor + fmin)/2
        end
    end

    return factor
end