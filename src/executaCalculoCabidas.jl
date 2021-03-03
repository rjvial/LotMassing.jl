function executaCalculoCabidas(dcp, dcn, dca, dcc, dcu, dcf, dcr, fpe, conjuntoTemplates)


    numTiposDepto = length(dcc.SUPDEPTOUTIL);

    # Posiciona el origen del predio (esq. inferior izquierda) en el punto 0,0. Obtiene estructura con las matrices de rotación
    V_predio, R = infoPredio(dcp.x, dcp.y);
    ps_predio = PolyShape([V_predio], 1)
    # Corrección por expropiación #
    ps_predio = polyShape.polyExpandSides_v2(ps_predio, [-1.5, -1.5, -1.5], [1, 2, 3]) 
    # #############################
    superficieTerreno = polyShape.polyArea_v2(ps_predio);
       

    # Calcula matriz V_areaEdif asociada a los vértices del area de edificación
    V_areaEdif = copy(V_predio);
    numLadosPredio = size(V_areaEdif, 1);
    conjuntoLados = 1:numLadosPredio;
    conjuntoLadosCalle = dcp.ladosConCalle;
    conjuntoLadosVecinos = setdiff(conjuntoLados, conjuntoLadosCalle);
    sepVecinos = dcn.SEPMIN;
    rasante = dcn.RASANTE; 
    alturaMax = dcn.ALTURAMAX
    anchoEspacioPublico = dcp.ANCHOESPACIOPUBLICO
    antejardin = dcn.ANTEJARDIN
    ps_areaEdif = PolyShape([V_predio], 1)
    ps_areaEdif = polyShape.polyExpandSides_v2(ps_areaEdif, -ones(length(conjuntoLadosVecinos),1)*sepVecinos, conjuntoLadosVecinos)
    ps_areaEdif = polyShape.polyExpandSides_v2(ps_areaEdif, -ones(length(conjuntoLadosCalle),1)*antejardin, conjuntoLadosCalle)
    V_areaEdif = ps_areaEdif.Vertices[1] 

    ps_bruto, ps_publico = generaSupBruta(ps_predio, conjuntoLadosCalle, anchoEspacioPublico)
    superficieTerrenoBruta = polyShape.polyArea_v2(ps_bruto);
    ps_calles = generaCalles(ps_predio, ps_publico, anchoEspacioPublico)
    V_bruto = ps_bruto.Vertices[1]
    V_publico = ps_publico.Vertices[1]


    # Calcula el volumen y sombra teórica 
    rasante_ss = rasante; 
    matConexionVertices_ss, vecVertices_ss, ps_volteor = generaVol3d(V_predio, V_bruto, rasante_ss, dcn, dcp)
    V_volteor = ps_volteor.Vertices[1]
    ps_SombraVolTeor_p, ps_SombraVolTeor_o, ps_SombraVolTeor_s = generaSombraTeor(ps_volteor, matConexionVertices_ss, vecVertices_ss, ps_publico, ps_calles)
    rasante_cs = 5;
    matConexionVertices_cs, vecVertices_cs, ps_restSombra = generaVol3d(V_predio, V_bruto, rasante_cs, dcn, dcp)
    V_restSombra = ps_restSombra.Vertices[1]

    areaSombra_p = polyShape.polyArea_v2(ps_SombraVolTeor_p)
    areaSombra_o = polyShape.polyArea_v2(ps_SombraVolTeor_o)
    areaSombra_s = polyShape.polyArea_v2(ps_SombraVolTeor_s)

    vecAlturas_cs = sort(unique(V_restSombra[:,end]))
    altCorteVecinos = dcn.RASANTE * dcn.SEPMIN
    numVertices = size(V_areaEdif, 1);
    sepNaves = dca.ANCHOMAX

    maxSupConstruida = superficieTerreno * dcn.COEFCONSTRUCTIBILIDAD * (1 + 0.3 * dcp.FUSIONTERRENOS) * (1 + dca.PORCSUPCOMUN)

    superficieDensidad = dcn.FLAGDENSIDADBRUTA ? superficieTerrenoBruta : superficieTerreno
    maxDeptos = dcn.DENSIDADMAX / 4 * superficieDensidad / 10000;
    maxSupConstruidaDensidad = maxDeptos*maximum(dcc.SUPDEPTOUTIL) * (1 + dca.PORCSUPCOMUN)

    function fitness_cs(x)  # Función de Fitness Con Sombra

        alt, areaBasal, ps_base, ps_baseSeparada, psCorte = resultConverter(x, t, V_restSombra, matConexionVertices_cs, vecVertices_cs, vecAlturas_cs, sepNaves)
        
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
        numPisos = Int(floor(alt / dca.ALTURAPISO)) 
        penalizacionConstructibilidad = max(0, areaBasal*numPisos - maxSupConstruida)
        penalizacionDensidad = max(0, areaBasal*numPisos - maxSupConstruidaDensidad)

        penalizacionNumPisos = numPisos

        total_fit = numPisos * (areaBasal - 100*penalizacionCoefOcup - 100*penalizacion_r) -
                    1000*(penalizacionSombra_p + penalizacionSombra_o + penalizacionSombra_s) -
                    numPisos * penalizacionNumPisos - 1000*(penalizacionConstructibilidad + penalizacionDensidad)

        return -total_fit
    end

    numParticles = 4000# 2000;
    maxIterations = 300# 300;

    resultados = fill(ResultadoCabida(nothing, nothing, nothing, nothing, nothing, nothing, []), length(conjuntoTemplates), 1)
    
    @time begin
        cont = 0

        t = conjuntoTemplates[1] # for t in conjuntoTemplates

        cont += 1

        display("Inicio de Cálculo")
        min_alt = min(maximum(vecAlturas_cs), dcn.RASANTE * dcn.SEPMIN); max_alt = maximum(vecAlturas_cs)
        #min_theta = -pi; max_theta =  pi;
        min_theta = pi/2; max_theta =  pi;

        min_largo = sepNaves; max_largo = 100; 
        min_largo1 = sepNaves; max_largo1 = 100;
        min_largo2 = sepNaves; max_largo2 = 100;

        xmin = minimum(V_areaEdif[:,1]);  xmax = maximum(V_areaEdif[:,1]);
        ymin = minimum(V_areaEdif[:,2]);  ymax = maximum(V_areaEdif[:,2]);

        min_ancho = 6; max_ancho = 16;


        if t == 1
            min_alfa = 0; max_alfa = pi / 2;

            lb = [min_alt, min_theta, xmin, ymin, min_alfa, min_largo1, min_largo2, min_ancho];
            ub = [max_alt, max_theta, xmax, ymax, max_alfa, max_largo1, max_largo2, max_ancho];

        elseif t == 2
            largos, angulosExt, angulosInt, largosDiag =  polyShape.extraeInfoPoly(ps_areaEdif)
            maxDiagonal = maximum(largosDiag)

            min_phi1 = 0; max_phi1 =  pi / 2;
            min_phi2 = 0; max_phi2 =  pi / 2;
            min_largo0 = 3 * sepNaves; max_largo0 = maxDiagonal
    
            lb = [min_alt, min_theta, xmin, ymin, min_phi1, min_phi2, min_largo0, min_largo1, min_largo2, min_ancho];
            ub = [max_alt, max_theta, xmax, ymax, max_phi1, max_phi2, max_largo0, max_largo1, max_largo2, max_ancho];       
                       
        elseif t == 3
            min_unidades = .5001; max_unidades = 5.4999;
            min_var = -50; max_var = 50;
            min_sep = sepNaves; max_sep = 100; 

            lb = [min_alt, min_theta, xmin, ymin, min_unidades, min_largo, min_var, min_sep, min_ancho];
            ub = [max_alt, max_theta, xmax, ymax, max_unidades, max_largo, max_var, max_sep, max_ancho];

        elseif t == 4
            largos, angulosExt, angulosInt, largosDiag =  polyShape.extraeInfoPoly(ps_areaEdif)
            maxDiagonal = maximum(largosDiag)

            min_alfa = 0; max_alfa = pi / 2;

            lb = [min_alt, min_theta, xmin, ymin, min_alfa, min_largo1, min_largo2, min_ancho];
            ub = [max_alt, max_theta, xmax, ymax, max_alfa, max_largo1, max_largo2, max_ancho];
 
        end

        MaxSteps = 18000
        MaxStepsWithoutProgress = 5000
        sr = [(lb[i], ub[i]) for i = 1:length(lb)]
        fopt_cs = 10000
        xopt_cs = []
        h = 6
        kopt = 0
        @showprogress 1 "Calculando Cabida..." for k = 1:2#2*h+1
            if k <= 2*h
                lb[2] = -pi + (k - 1) * pi / h
                ub[2] = -pi / h + (k - 1) * pi / h
                x_k, f_k = evol(fitness_cs, lb, ub, MaxSteps, MaxStepsWithoutProgress, false)
            else
                lb[2] = -pi + (kopt - 1) * pi / h
                ub[2] = -pi / h + (kopt - 1) * pi / h
                x_k, f_k = evol(fitness_cs, lb, ub, MaxSteps*2, MaxStepsWithoutProgress, false)
            end
            if f_k < fopt_cs
                fopt_cs = f_k
                xopt_cs = x_k
                kopt = k
            end

        end

        
        alt, areaBasal, ps_base, ps_baseSeparada, psCorte = resultConverter(xopt_cs, t, V_restSombra, matConexionVertices_cs, vecVertices_cs, vecAlturas_cs, sepNaves)
        numPisos = Int(floor(alt / dca.ALTURAPISO))
        alturaEdif = numPisos * dca.ALTURAPISO
        sn, sa, si, st, so, sm, sf = optiEdificio_v2(dcn, dca, dcp, dcc, dcu, dcf, dcr, alturaEdif, ps_base, superficieTerreno, superficieTerrenoBruta)
        xopt_cs[1] = sa.altura 
        numPisos = sa.numPisos
        resultados[cont] = ResultadoCabida(sn, sa, si, st, sm, sf, [xopt_cs])
        resultados_ = [sn, sa, si, st, so, sm, sf, [xopt_cs]]

        ps_sombraEdif_p, ps_sombraEdif_o, ps_sombraEdif_s = generaSombraEdificio(ps_baseSeparada, alt, ps_publico, ps_calles)
        
        fig = plotBaseEdificio3d(fpe, resultados[cont].Xopt[1], dca.ALTURAPISO, ps_predio, 
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



