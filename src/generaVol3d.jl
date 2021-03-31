function generaVol3d(V_predio, V_bruto, rasante, dcn, dcp)

    numLadosPredio = size(V_predio, 1);
    conjuntoLados = 1:numLadosPredio
    conjuntoLadosCalle = dcp.ladosConCalle;
    numCalles = length(conjuntoLadosCalle)
    conjuntoLadosVecinos = setdiff(conjuntoLados, conjuntoLadosCalle);
    alturaMax = dcn.ALTURAMAX
    sepVecinos = dcn.DISTANCIAMIENTO
    antejardin = dcn.ANTEJARDIN
    anchoEspacioPublico = dcp.ANCHOESPACIOPUBLICO


    # Genera vector de separaciones entre el comienzo de la rasante (separacion predial o eje esp. público) 
    # y la línea de edificación
    vecSeparacion = zeros(numLadosPredio)
    for i in conjuntoLadosVecinos
        vecSeparacion[i] = sepVecinos
    end
    numCalles = length(conjuntoLadosCalle)
    for i= 1:numCalles
        vecSeparacion[conjuntoLadosCalle[i]] = anchoEspacioPublico[i]/2 + antejardin
    end
    conjSepDist = 1:.1:alturaMax/rasante
    numSepDistintas = length(conjSepDist)

    
    # Genera Volumen Teórico a partir de múltiples cortes a distintas alturas 
    vec_psVolteor = Array{PolyShape, 1}(undef, numSepDistintas)
    vec_altVolteor = zeros(numSepDistintas,1)
    id = 1
    for j = 1:numSepDistintas # Para cada una de las separaciones distintas        
        vecDelta_j = max.(0,vecSeparacion .- conjSepDist[j])
        ps_corte = PolyShape([copy(V_bruto)],1)
        ps_corte = polyShape.polyExpandSides_v2(ps_corte, -vecDelta_j, conjuntoLados)
        ps_corte = polyShape.polyExpand(ps_corte, -conjSepDist[j]);
        if ps_corte.NumRegions >= 1
            vec_psVolteor[id] = ps_corte
            vec_altVolteor[id] = conjSepDist[j]*rasante
            id += 1
        end
    end
    vec_psVolteor = vec_psVolteor[1:id-1]
    vec_psVolteor = [vec_psVolteor[1]; vec_psVolteor]
    vec_altVolteor = vec_altVolteor[1:id-1]
    vec_altVolteor = [0; vec_altVolteor]


    # Determina las alturas en las cuales hay cambios
    vec_psVolteor_ = copy(vec_psVolteor)
    vec_altVolteor_ = copy(vec_altVolteor)
    flagAlt = zeros(length(vec_altVolteor),1)
    flagAlt[1] = 1
    for i = 3:length(vec_altVolteor_)
        n_i = size(vec_psVolteor_[i].Vertices[1],1)
        n_i1 = size(vec_psVolteor_[i-1].Vertices[1],1)
        n_i2 = size(vec_psVolteor_[i-2].Vertices[1],1)
        if n_i < n_i1 
            flagAlt[i-1] = 1
            flagAlt[i] = 1
        elseif n_i == n_i1 && n_i1 == n_i2
            pos_i = vec_psVolteor_[i].Vertices[1]
            pos_i1 = vec_psVolteor_[i-1].Vertices[1]
            pos_i2 = vec_psVolteor_[i-2].Vertices[1]
            dist_01 = sqrt.(sum((pos_i .- pos_i1).^2, dims=2))
            dist_12 = sqrt.(sum((pos_i1 .- pos_i2).^2, dims=2))
            for j = 1:length(dist_01)
                if dist_01[j] > 0.01 && dist_12[j] < 0.01
                    flagAlt[i] = 1
                end
            end
        end
    end
    flagAlt[end] = 1
    vec_psVolteor_ = vec_psVolteor_[flagAlt[:] .== 1]
    vec_altVolteor_ = vec_altVolteor_[flagAlt[:] .== 1]


    # Genera arreglo de ids de los vertices de cada nivel
    vecVertices = []
    cont = 0
    for i = 1:size(vec_psVolteor_,1)
        vecAux = zeros(size(vec_psVolteor_[i].Vertices[1],1),1)
        for j = 1:size(vec_psVolteor_[i].Vertices[1],1)
            cont += 1
            vecAux[j] = Int(cont)
        end
        vecVertices = push!(vecVertices, vecAux)
    end

    
    # Genera matriz de conexiones entre vertices
    matConexionVertices = zeros(size(vec_psVolteor_,1) * size(vec_psVolteor_[1].Vertices[1],1), 2)
    cont = 0
    for i = 1:length(vec_psVolteor_)-1
        V_il = vec_psVolteor_[i].Vertices[1] # matriz Vertices capa low
        V_iu = vec_psVolteor_[i+1].Vertices[1] # matriz Vertices capa up
        for j = 1:size(V_il,1)
            min_dist = 10000
            cont += 1
            if j == 1 || size(V_il,1) != size(V_iu,1) # Para el j inicial y para los casos en que las capas tienen distinto n° de vertices
                for k = 1:size(V_iu,1) # Busca el vertice k (capa up) más cercano al vertice j (capa low)
                    p_l_j = V_il[j,:] # coordenadas vertice j de la capa low
                    p_u_k = V_iu[k,:] # coordenadas vertice k de la capa up
                    dist_jk = sqrt.(sum((p_l_j .- p_u_k).^2))
                    id_l_j = vecVertices[i][j] # id vertice j de la capa low
                    id_u_k = vecVertices[i+1][k] # id vertice k de la capa up
                    if dist_jk < min_dist - 1
                        matConexionVertices[cont,:] = [id_l_j id_u_k]
                        min_dist = dist_jk
                    end
                end
            else #para los casos en que las capas tienen igual n° de vertices
                id_u_a = matConexionVertices[cont-1,2] # id vertice capa up del vertice anterior 
                pos_u_a = findall(x->x == id_u_a, vecVertices[i+1])[1][1] # pos capa up del vertice id_u_a
                id_l_j = vecVertices[i][j] # id vertice j de la capa low
                if pos_u_a + 1 <= size(V_iu,1)
                    id_u = vecVertices[i+1][pos_u_a + 1] # id siguiente vertice de la capa up
                else
                    id_u = vecVertices[i+1][1] # id siguiente vertice de la capa up
                end
                matConexionVertices[cont,:] = [id_l_j id_u]
            end
        end
    end
    matConexionVertices = matConexionVertices[matConexionVertices[:,1] .>= 1,:]

    matVolteor = [0 0 0]
    for i = 1:size(vec_psVolteor_,1)
        matVolteor = [matVolteor; vec_psVolteor_[i].Vertices[1] vec_altVolteor_[i]*ones(size(vec_psVolteor_[i].Vertices[1],1),1)]
    end
    matVolteor = matVolteor[2:end, :]
    ps_volteor = PolyShape([matVolteor],1)

    return matConexionVertices, vecVertices, ps_volteor

end

# vec_psVolteor, vec_altVolteor, vec_psVolteor_, vec_altVolteor_
