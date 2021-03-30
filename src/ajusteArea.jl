function ajusteArea(V, areaSup)

    fmin = 90000
    fmax = 110000

    cond = true
    areaCalc = 0
    while cond
        factor = (fmin + fmax)/2
        V_ = factor .* copy(V)
        areaCalc = poly2D.polyArea(V_)
        if abs(areaCalc - areaSup) <= 1
            cond = false
            return factor, areaCalc        
        elseif areaCalc <= areaSup
            fmin = factor
            factor = (factor + fmax)/2
        else
            fmax = factor
            factor = (factor + fmin)/2
        end
    end

    return factor, areaCalc
end