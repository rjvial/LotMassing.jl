function factorIgualaArea(V, areaSup)

    fmin = 0
    fmax = 110000

    cond = true
    cont = 0
    factor = 0
    while cond
        cont = cont + 1
        factor = (fmin + fmax)/2
        V_ = factor .* copy(V)
        areaCalc = poly2D.polyArea(V_)
        if abs(areaCalc - areaSup) <= .1 || cont >= 20000
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
    display(cont)
    return factor
end