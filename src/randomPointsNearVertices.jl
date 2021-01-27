function randomPointsNearVertices(V, point, NumPoints, radioIncidencia)

    numVertices = size(V,1);

    V_rand = poly2D.randomPointInPolygon(V, NumPoints)
    flagMat = zeros(NumPoints,numVertices)
    dist = sqrt.(sum( (V_rand - repeat(point,NumPoints,1)).^2, dims=2))
    flagIn = dist .<= radioIncidencia

    V_out = V_rand[flagIn[:] .== true, :]

    return V_out

end

