function generaSitiosAleatorios(n)

    min_theta = -pi; max_theta =  pi;
    min_anchoLado0 = 10; max_anchoLado0 = 60
    min_anchoLado1 = 10; max_anchoLado1 = 60
    min_anchoLado2 = 10; max_anchoLado2 = 60
    min_largo0 = 20; max_largo0 = 100
    min_largo1 = 20; max_largo1 = 100
    min_largo2 = 20; max_largo2 = 100


    pos_x0 = 0
    pos_y0 = 0
    theta = min_theta .+ rand(n,1).*(max_theta - min_theta)
    anchoLado0 = min_anchoLado0 .+ rand(n,1).*(max_anchoLado0 - min_anchoLado0)
    anchoLado1 = min_anchoLado1 .+ rand(n,1).*(max_anchoLado1 - min_anchoLado1)
    anchoLado2 = min_anchoLado2 .+ rand(n,1).*(max_anchoLado2 - min_anchoLado2)
    largo0 = min_largo0 .+ rand(n,1).*(max_largo0 - min_largo0)
    largo1 = min_largo1 .+ rand(n,1).*(max_largo1 - min_largo1)
    largo2 = min_largo2 .+ rand(n,1).*(max_largo2 - min_largo2)

    predios = []
    publicos = []
    calles = []
    for i = 1:n
        R_theta = poly2D.rotationMatrix(theta[i]);
        cr_theta  = [pos_x0; pos_y0];

        if rand() <= .5            
            p1_0  = (R_theta * ([pos_x0; pos_y0                        ] - cr_theta) + cr_theta)'
            p2_0  = (R_theta * ([pos_x0 + largo0[i]; pos_y0               ] - cr_theta) + cr_theta)'
            p3_0  = (R_theta * ([pos_x0 + largo0[i]; pos_y0 + anchoLado0[i]  ] - cr_theta) + cr_theta)'
            p4_0  = (R_theta * ([pos_x0; pos_y0 + anchoLado0[i]           ] - cr_theta) + cr_theta)'

            p1_1  = (R_theta * ([pos_x0; pos_y0                      ] - cr_theta) + cr_theta)';
            p2_1  = (R_theta * ([pos_x0 + anchoLado1[i]; pos_y0         ] - cr_theta) + cr_theta)';
            p3_1  = (R_theta * ([pos_x0 + anchoLado1[i]; pos_y0 + largo1[i]] - cr_theta) + cr_theta)';
            p4_1  = (R_theta * ([pos_x0; pos_y0 + largo1[i]             ] - cr_theta) + cr_theta)';
                    
            p1_2  = (R_theta * ([pos_x0 + largo0[i] - anchoLado2[i]; pos_y0         ] - cr_theta) + cr_theta)';
            p2_2  = (R_theta * ([pos_x0 + largo0[i]; pos_y0                      ] - cr_theta) + cr_theta)';
            p3_2  = (R_theta * ([pos_x0 + largo0[i]; pos_y0 + largo2[i]             ] - cr_theta) + cr_theta)';
            p4_2  = (R_theta * ([pos_x0 + largo0[i] - anchoLado2[i]; pos_y0 + largo2[i]] - cr_theta) + cr_theta)';
        else
            p1_0  = (R_theta * ([pos_x0; pos_y0                        ] - cr_theta) + cr_theta)'
            p2_0  = (R_theta * ([pos_x0 + largo0[i]; pos_y0               ] - cr_theta) + cr_theta)'
            p3_0  = (R_theta * ([pos_x0 + largo0[i]; pos_y0 + anchoLado0[i]  ] - cr_theta) + cr_theta)'
            p4_0  = (R_theta * ([pos_x0; pos_y0 + anchoLado0[i]           ] - cr_theta) + cr_theta)'

            p1_1  = (R_theta * ([pos_x0; pos_y0                      ] - cr_theta) + cr_theta)';
            p2_1  = (R_theta * ([pos_x0 + largo1[i]; pos_y0         ] - cr_theta) + cr_theta)';
            p3_1  = (R_theta * ([pos_x0 + largo1[i]; pos_y0 + anchoLado1[i]] - cr_theta) + cr_theta)';
            p4_1  = (R_theta * ([pos_x0; pos_y0 + anchoLado1[i]             ] - cr_theta) + cr_theta)';
                    
            p1_2  = (R_theta * ([pos_x0; pos_y0                      ] - cr_theta) + cr_theta)';
            p2_2  = (R_theta * ([pos_x0 + largo2[i]; pos_y0         ] - cr_theta) + cr_theta)';
            p3_2  = (R_theta * ([pos_x0 + largo2[i]; pos_y0 + anchoLado2[i]] - cr_theta) + cr_theta)';
            p4_2  = (R_theta * ([pos_x0; pos_y0 + anchoLado2[i]             ] - cr_theta) + cr_theta)';
        end

        V0 = [p1_0;p2_0;p3_0;p4_0]
        V1 = [p1_1;p2_1;p3_1;p4_1]
        V2 = [p1_2;p2_2;p3_2;p4_2]
    
        ps0 = PolyShape([V0], 1)
        ps1 = PolyShape([V1], 1)
        ps2 = PolyShape([V2], 1)
    
        ps_predio = polyShape.polyUnion_v2(ps0, ps1)
        ps_predio = polyShape.polyUnion_v2(ps_predio, ps2)
    
        V_predio = ps_predio.Vertices[1]
        p0 = minimum(V_predio, dims=1)
        V_predio = V_predio - repeat(p0,size(V_predio,1),1)

        numVertices = size(V_predio,1)
        vec_id_aux = [numVertices; collect(1:numVertices); 1]
        vecFlag = zeros(numVertices,1)
        for v = 1:numVertices
            q = V_predio[v,:]
            p1 = V_predio[vec_id_aux[v],:]
            p2 = V_predio[vec_id_aux[v+2],:]
            vecFlag[v] = poly2D.distPointLine(q, p1, p2) > .1 ? 1 : 0
        end
        V_predio = V_predio[vecFlag[:] .== 1,:]
        numVertices = size(V_predio,1)

        ps_predio = PolyShape([V_predio], 1)    
        areaBasal = polyShape.polyArea_v2(ps_predio)
    
        push!(predios, ps_predio)

        C = zeros(numVertices,2)
        C[1:numVertices-1,1] = 1:numVertices-1
        C[1:numVertices-1,2] = 2:numVertices
        C[end,:] = [numVertices, 1]
    
        id_nc = poly2D.findNonConvexVert(V_predio)
        id_aux = findall(x -> x in id_nc, C)
        id_c = [id_aux[k][1] for k=1:length(id_aux)]

        C_ = C[setdiff(1:numVertices,id_c),:]
        conjuntoCallesFactibles = C_[:,1]
        numCallesFactible = length(conjuntoCallesFactibles)
        numCallesSelec = rand(1:numCallesFactible)
        conjuntoLadosCalle = C_[sort(randperm(numCallesFactible)[1:numCallesSelec])]
        anchoEspacioPublico = 7 .+ rand(numCallesSelec,1) .* (30-7)
        ps_bruto, ps_publico = generaSupBruta(ps_predio, conjuntoLadosCalle, anchoEspacioPublico)
        ps_calles = generaCalles(ps_predio, ps_publico, anchoEspacioPublico)

        push!(publicos, ps_publico)
        push!(calles, ps_calles)
    end



    return predios, publicos, calles

end