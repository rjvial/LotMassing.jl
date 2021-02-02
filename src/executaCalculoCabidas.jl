function executaCalculoCabidas(dcp, dcn, dca, dcc, dcu, dcf, dcr, fpe, conjuntoTemplates)


    numTiposDepto = length(dcc.SUPDEPTOUTIL);

    # Posiciona el origen del predio (esq. inferior izquierda) en el punto 0,0. Obtiene estructura con las matrices de rotación
    V_predio, R = infoPredio(dcp.x, dcp.y);
       

    # Calcula matriz V_areaEdif asociada a los vértices del area de edificación
    V_areaEdif = copy(V_predio);
    numLadosPredio = size(V_areaEdif, 1);
    conjuntoLados = 1:numLadosPredio;
    conjuntoLadosCalle = dcp.ladosConCalle;
    conjuntoLadosVecinos = setdiff(conjuntoLados, conjuntoLadosCalle);
    anchoLado = dca.ANCHOMAX
    sepVecinos = dcn.SEPMIN;
    rasante = dcn.RASANTE; 
    alturaMax = dcn.ALTURAMAX
    anchoEspacioPublico = dcp.ANCHOESPACIOPUBLICO
    antejardin = dcn.ANTEJARDIN
    ps_areaEdif = PolyShape([V_predio], 1)
    ps_areaEdif = polyShape.polyExpandSides_v2(ps_areaEdif, -ones(length(conjuntoLadosVecinos),1)*sepVecinos, conjuntoLadosVecinos)
    ps_areaEdif = polyShape.polyExpandSides_v2(ps_areaEdif, -ones(length(conjuntoLadosCalle),1)*antejardin, conjuntoLadosCalle)
    V_areaEdif = ps_areaEdif.Vertices[1] 

    ps_predio = PolyShape([V_predio], 1)
    superficieTerreno = polyShape.polyArea_v2(ps_predio);
    ps_bruto, ps_publico = generaSupBruta(ps_predio, conjuntoLadosCalle, anchoEspacioPublico)
    ps_calles = generaCalles(ps_predio, ps_publico, anchoEspacioPublico)
    V_bruto = ps_bruto.Vertices[1]
    V_publico = ps_publico.Vertices[1]

    # global altCorteVecinos, areaSombra_p, areaSombra_o, areaSombra_s
    ps_bruto = PolyShape([V_bruto], 1)
    superficieTerrenoBruta = polyShape.polyArea_v2(ps_bruto);
    ps_publico = PolyShape([V_publico], 1)
    ps_areaEdif = PolyShape([V_areaEdif], 1)    

    # Calcula el volumen y sombra teórica 
    rasante_ss = dcn.RASANTE; 
    matConexionVertices_ss, vecVertices_ss, ps_volteor = generaVol3d_v4(V_predio, V_bruto, rasante_ss, dcn, dcp)
    V_volteor = ps_volteor.Vertices[1]
    ps_SombraVolTeor_p, ps_SombraVolTeor_o, ps_SombraVolTeor_s = generaSombraTeor_v3(ps_volteor, matConexionVertices_ss, vecVertices_ss, ps_publico, ps_calles)
    rasante_cs = 5;
    matConexionVertices_cs, vecVertices_cs, ps_restSombra = generaVol3d_v4(V_predio, V_bruto, rasante_cs, dcn, dcp)
    V_restSombra = ps_restSombra.Vertices[1]


    areaSombra_p = polyShape.polyArea_v2(ps_SombraVolTeor_p)
    areaSombra_o = polyShape.polyArea_v2(ps_SombraVolTeor_o)
    areaSombra_s = polyShape.polyArea_v2(ps_SombraVolTeor_s)

    vecAlturas_ss = sort(unique(V_volteor[:,end]))
    vecAlturas_cs = sort(unique(V_restSombra[:,end]))
    altCorteVecinos = dcn.RASANTE * dcn.SEPMIN
    numVertices = size(V_areaEdif, 1);


    function fitness_ss(x)  # Función de Fitness Sin Sombra
        alt, areaBasal, ps_base, ps_baseSeparada, psCorte = resultConverter_v2(x, V_restSombra, anchoLado, matConexionVertices_cs, vecVertices_cs, vecAlturas_cs)
        
        total_fit = 0

        ps_r = polyShape.polyDifference_v3(ps_base, psCorte) #Sector de la base del edificio que sobrepasa el areaEdif
        area_r = polyShape.polyArea_v2(ps_r) #Area del sector que sobrepasa
        penalizacion_r = area_r^1.1
        penalizacionCoefOcup = max(0, areaBasal - dcn.COEFOCUPACION * superficieTerreno)

        total_fit = alt*(areaBasal - 5*(penalizacionCoefOcup + penalizacion_r))

        return -total_fit
    end


    function fitness_cs(x)  # Función de Fitness Con Sombra

        alt, areaBasal, ps_base, ps_baseSeparada, psCorte = resultConverter_v2(x, V_restSombra, anchoLado, matConexionVertices_cs, vecVertices_cs, vecAlturas_cs)
        
        total_fit = 0
        ps_sombraEdif_p, ps_sombraEdif_o, ps_sombraEdif_s = generaSombraEdificio(ps_baseSeparada, alt, ps_publico, ps_calles)

        areaSombraEdif_p = polyShape.polyArea_v2(ps_sombraEdif_p)
        areaSombraEdif_o = polyShape.polyArea_v2(ps_sombraEdif_o)
        areaSombraEdif_s = polyShape.polyArea_v2(ps_sombraEdif_s)
        penalizacionSombra_p = max(0, areaSombraEdif_p - areaSombra_p)
        penalizacionSombra_o = max(0, areaSombraEdif_o - areaSombra_o)
        penalizacionSombra_s = max(0, areaSombraEdif_s - areaSombra_s)
        
        ps_r = polyShape.polyDifference_v3(ps_base, psCorte) #Sector de la base del edificio que sobrepasa el areaEdif
        area_r = polyShape.polyArea_v2(ps_r) #Area del sector que sobrepasa
        penalizacion_r = area_r^1.1

        penalizacionCoefOcup = max(0, areaBasal - dcn.COEFOCUPACION * superficieTerreno)

        total_fit = alt*(areaBasal - 5*(penalizacion_r + penalizacionCoefOcup + penalizacionSombra_p + penalizacionSombra_o + penalizacionSombra_s))


        return -total_fit
    end

    
    resultados = fill(ResultadoCabida(nothing, nothing, nothing, nothing, nothing, nothing, []), length(conjuntoTemplates), 1)
    
    @time begin
        cont = 0

        t = conjuntoTemplates[1] # for t in conjuntoTemplates

        cont += 1

        display("Inicio de Cálculo")
        min_alt = min(maximum(vecAlturas_ss), dcn.RASANTE * dcn.SEPMIN)
        max_alt = maximum(vecAlturas_ss)
        min_theta = -pi;
        max_theta =  pi;

        min_largo = anchoLado;
        max_largo = 100;
        min_largo1 = anchoLado;
        max_largo1 = 100;
        min_largo2 = anchoLado;
        max_largo2 = 100;

        xmin = minimum(V_areaEdif[:,1]);  xmax = maximum(V_areaEdif[:,1]);
        ymin = minimum(V_areaEdif[:,2]);  ymax = maximum(V_areaEdif[:,2]);

        if t == 1
            min_alfa = 0;
            max_alfa = pi / 2;

            lb = [min_alt, min_theta, min_alfa, xmin, ymin, min_largo1, min_largo2,t];
            ub = [max_alt, max_theta, max_alfa, xmax, ymax, max_largo1, max_largo2,t];

            numParticles = 1500# 500;
            maxIterations = 200# 100;
            xopt_cs, fopt_cs = evol(fitness_cs, lb, ub, numParticles, maxIterations, false)

        elseif t == 2
            largos, angulosExt, angulosInt, largosDiag =  polyShape.extraeInfoPoly(ps_areaEdif)
            maxDiagonal = maximum(largosDiag)

            min_phi1 = 0; max_phi1 =  pi / 2;
            min_phi2 = 0; max_phi2 =  pi / 2;
            min_largo0 = 3 * anchoLado; max_largo0 = maxDiagonal

            lb = [min_alt, min_theta, min_phi1, min_phi2, xmin, ymin, min_largo0, min_largo1, min_largo2, t];
            ub = [max_alt, max_theta, max_phi1, max_phi2, xmax, ymax, max_largo0, max_largo1, max_largo2, t];       

            numParticles = 3000# 500;
            maxIterations = 70# 100;
            xopt_cs, fopt_cs = evol(fitness_cs, lb, ub, numParticles, maxIterations, false)
            
        elseif t == 3
            

        elseif t == 4
            largos, angulosExt, angulosInt, largosDiag =  polyShape.extraeInfoPoly(ps_areaEdif)
            maxDiagonal = maximum(largosDiag)

            min_alfa = 0;
            max_alfa =  pi / 2;
            min_largo1 = anchoLado; max_largo1 = maxDiagonal
            min_largo2 = anchoLado; max_largo2 = maxDiagonal

            lb = [min_alt, min_theta, min_alfa, xmin, ymin, min_largo1, min_largo2, t];
            ub = [max_alt, max_theta, max_alfa, xmax, ymax, max_largo1, max_largo2, t];

            numParticles = 2000# 2000;
            maxIterations = 300# 300;
            xopt_cs, fopt_cs = evol(fitness_cs, lb, ub, numParticles, maxIterations, false)
 
        end
            
        
        alt, areaBasal, ps_base, ps_baseSeparada, psCorte = resultConverter_v2(xopt_cs, V_restSombra, anchoLado, matConexionVertices_cs, vecVertices_cs, vecAlturas_cs)
        numPisos = Int(floor(alt / dca.ALTURAPISO))
        alturaEdif = numPisos * dca.ALTURAPISO
        sn, sa, si, st, sm, sf = optiEdificio(dcn, dca, dcp, dcc, dcu, dcf, dcr, alturaEdif, ps_base, superficieTerreno, superficieTerrenoBruta)
        xopt_cs[1] = sa.altura 
        numPisos = sa.numPisos
        resultados[cont] = ResultadoCabida(sn, sa, si, st, sm, sf, [xopt_cs])
        resultados_ = [sn, sa, si, st, sm, sf, [xopt_cs]]

        ps_sombraEdif_p, ps_sombraEdif_o, ps_sombraEdif_s = generaSombraEdificio(ps_baseSeparada, alt, ps_publico, ps_calles)
        
        fig = plotBaseEdificio3d_v2(fpe, resultados[cont].Xopt[1], dca.ALTURAPISO, ps_predio, 
                                    ps_volteor, matConexionVertices_ss, vecVertices_ss, 
                                    ps_restSombra, matConexionVertices_cs, vecVertices_cs, 
                                    ps_publico, ps_calles, ps_base, ps_baseSeparada);

        displayResults(resultados_)
        println(" ")
        println(" ")
        println(" ")
            
    end
    
    return resultados, ps_predio, ps_base, xopt_cs, fopt_cs, psCorte, 
            ps_SombraVolTeor_p, ps_sombraEdif_p, ps_SombraVolTeor_s, ps_sombraEdif_s, ps_SombraVolTeor_o, ps_sombraEdif_o
end



