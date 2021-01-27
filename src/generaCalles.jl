function generaCalles(ps_predio, ps_publico, anchoEspacioPublico)

    conjuntoAnchoEspPublico = unique(anchoEspacioPublico)

    ps_predio_ = polyShape.polyExpand(ps_predio, .01)
    ps_calles_ = polyShape.polyDifference_v3(ps_publico, ps_predio_)

    ps_calles = PolyShape([], 0)
    for i = 1:ps_calles_.NumRegions
        V_i = ps_calles_.Vertices[i]
        ps_calle_i = PolyShape([V_i], 1) 
        for k = 1:size(V_i,1)
            q = V_i[k,:]
            if k <= size(V_i,1)-2
                p1 = V_i[k+1,:]
                p2 = V_i[k+2,:]
            elseif k == size(V_i,1)-1
                p1 = V_i[k+1,:]
                p2 = V_i[1,:]
            elseif k == size(V_i,1)
                p1 = V_i[1,:]
                p2 = V_i[2,:]
            end
            dist = poly2D.distPointLine(q, p1, p2)

            for j = conjuntoAnchoEspPublico
                if abs(dist - j) <= .111
                    ps_calle_i = polyShape.polyExpandSides(ps_calle_i, 100, k)
                end
            end
        end
        ps_calles.Vertices = push!(ps_calles.Vertices, ps_calle_i.Vertices[1])
    end

    ps_calles.NumRegions = length(ps_calles.Vertices)

    return ps_calles

end

