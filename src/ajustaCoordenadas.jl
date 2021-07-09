function ajustaCoordenadas(V, factorCorreccion)

    x = V[:,1]
    y = V[:,2]
    x = factorCorreccion * x
    y = factorCorreccion * y
    dx = minimum(x)
    dy = minimum(y)
    x = x .- dx
    y = y .- dy
    V = [x y]
    
    return V, dx, dy
end

function ajustaCoordenadas(V, factorCorreccion, dx, dy)

    x = V[:,1]
    y = V[:,2]
    x = factorCorreccion * x
    y = factorCorreccion * y
    x = x .- dx
    y = y .- dy
    V = [x y]
    
    return V
end