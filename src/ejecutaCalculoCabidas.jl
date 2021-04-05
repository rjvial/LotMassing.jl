function ejecutaCalculoCabidas(dcp, dcn, dca, dcc, dcu, dcf, dcr, conjuntoTemplates)


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
    sepVecinos = dcn.DISTANCIAMIENTO;
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
    matConexionVertices, vecVertices, ps_volteor = generaVol3d(V_predio, V_bruto, rasante, dcn, dcp)
    V_volteor = ps_volteor.Vertices[1]
    ps_SombraVolTeor_p, ps_SombraVolTeor_o, ps_SombraVolTeor_s = generaSombraTeor(ps_volteor, matConexionVertices, vecVertices, ps_publico, ps_calles)
    rasante_sombra = dcn.RASANTESOMBRA;
    matConexionVertices_restSombra, vecVertices_restSombra, ps_volRestSombra = generaVol3d(V_predio, V_bruto, rasante_sombra, dcn, dcp)
    V_volRestSombra = ps_volRestSombra.Vertices[1]

    areaSombra_p = polyShape.polyArea_v2(ps_SombraVolTeor_p)
    areaSombra_o = polyShape.polyArea_v2(ps_SombraVolTeor_o)
    areaSombra_s = polyShape.polyArea_v2(ps_SombraVolTeor_s)

    vecAlturas_restSombra = sort(unique(V_volRestSombra[:,end]))
    altCorteVecinos = dcn.RASANTE * dcn.DISTANCIAMIENTO
    numVertices = size(V_areaEdif, 1);
    sepNaves = dca.ANCHOMAX

    maxSupConstruida = superficieTerreno * dcn.COEFCONSTRUCTIBILIDAD * (1 + 0.3 * dcp.FUSIONTERRENOS) * (1 + dca.PORCSUPCOMUN)

    superficieDensidad = dcn.FLAGDENSIDADBRUTA ? superficieTerrenoBruta : superficieTerreno
    maxDeptos = dcn.DENSIDADMAX / 4 * superficieDensidad / 10000;
    maxSupConstruidaDensidad = maxDeptos*maximum(dcc.SUPDEPTOUTIL) * (1 + dca.PORCSUPCOMUN)

    function fitness_restSombra(x)  # Función de Fitness Con Sombra

        alt, areaBasal, ps_base, ps_baseSeparada, psCorte = resultConverter(x, t, V_volRestSombra, matConexionVertices_restSombra, vecVertices_restSombra, vecAlturas_restSombra, sepNaves)
        
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


        total_fit = numPisos * areaBasal - 
                    100 * numPisos * (penalizacionCoefOcup + penalizacion_r) -
                    1000*(penalizacionSombra_p + penalizacionSombra_o + penalizacionSombra_s) -
                    1000*(penalizacionConstructibilidad + penalizacionDensidad)

        return -total_fit
    end

    numParticles = 4000# 2000;
    maxIterations = 300# 300;

    
    @time begin
        cont = 0

        t = conjuntoTemplates[1] # for t in conjuntoTemplates

        cont += 1

        display("Inicio de Cálculo")
        min_alt = min(maximum(vecAlturas_restSombra), dcn.RASANTE * dcn.DISTANCIAMIENTO); max_alt = maximum(vecAlturas_restSombra)
        min_theta = pi/2; max_theta =  pi;

        min_largo = sepNaves; max_largo = 100; 
        min_largo1 = sepNaves; max_largo1 = 100;
        min_largo2 = sepNaves; max_largo2 = 100;
        min_largo1_ = sepNaves; max_largo1_ = 100;
        min_largo2_ = sepNaves; max_largo2_ = 100;

        xmin = minimum(V_areaEdif[:,1]);  xmax = maximum(V_areaEdif[:,1]);
        ymin = minimum(V_areaEdif[:,2]);  ymax = maximum(V_areaEdif[:,2]);

        min_ancho = dca.ANCHOMIN; max_ancho = dca.ANCHOMAX;


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

        elseif t == 5
            largos, angulosExt, angulosInt, largosDiag =  polyShape.extraeInfoPoly(ps_areaEdif)
            maxDiagonal = maximum(largosDiag)

            lb = [min_alt, min_theta, xmin, ymin, min_largo, min_largo1_, min_largo1, min_largo2_, min_largo2, min_ancho];
            ub = [max_alt, max_theta, xmax, ymax, max_largo, max_largo1_, max_largo1, max_largo2_, max_largo2, max_ancho];


        end

        
        MaxStepsWithoutProgress = 5000

        sr = [(lb[i], ub[i]) for i = 1:length(lb)]
        fopt_restSombra = 10000
        xopt_restSombra = []
        MaxSteps_1 = 15000#18000
        a1 = 12#6
        linSpace1 = collect(range(-pi, pi, length = a1))
        kopt1 = 1
        @showprogress 1 "Exploración de Soluciones...." for k = 1:a1-1
            lb[2] = linSpace1[k]
            ub[2] = linSpace1[k+1]
            x_k, f_k = evol(fitness_restSombra, lb, ub, MaxSteps_1, MaxStepsWithoutProgress, false)
            if f_k < fopt_restSombra
                fopt_restSombra = f_k
                xopt_restSombra = x_k
                kopt1 = k
            end
        end
        lb2_opt = linSpace1[kopt1]
        ub2_opt = linSpace1[kopt1+1]

        a2 = 3#6
        MaxSteps_2 = 20000
        linSpace2 = collect(range(lb2_opt, ub2_opt, length = a2))
        kopt2 = 1
        @showprogress 1 "Optimización Focalizada......" for k = 1:a2
            if k <= a2-1
                lb[2] = linSpace2[k]
                ub[2] = linSpace2[k+1]
                x_k, f_k = evol(fitness_restSombra, lb, ub, MaxSteps_2, MaxStepsWithoutProgress, false)
            else
                lb[2] = linSpace2[kopt2]
                ub[2] = linSpace2[kopt2+1]
                x_k, f_k = evol(fitness_restSombra, lb, ub, MaxSteps_2*2, MaxStepsWithoutProgress, false)
            end
            if f_k < fopt_restSombra
                fopt_restSombra = f_k
                xopt_restSombra = x_k
                kopt2 = k
            end
        end

        
        alt, areaBasal, ps_base, ps_baseSeparada, psCorte = resultConverter(xopt_restSombra, t, V_volRestSombra, matConexionVertices_restSombra, vecVertices_restSombra, vecAlturas_restSombra, sepNaves)
        numPisos = Int(floor(alt / dca.ALTURAPISO))
        alturaEdif = numPisos * dca.ALTURAPISO
        sn, sa, si, st, so, sm, sf = optiEdificio(dcn, dca, dcp, dcc, dcu, dcf, dcr, alturaEdif, ps_base, superficieTerreno, superficieTerrenoBruta)
        xopt_restSombra[1] = sa.altura 
        numPisos = sa.numPisos
        resultados = ResultadoCabida(sn, sa, si, st, sm, so, sf, [xopt_restSombra])
        

        ps_sombraEdif_p, ps_sombraEdif_o, ps_sombraEdif_s = generaSombraEdificio(ps_baseSeparada, alt, ps_publico, ps_calles)
        
            
    end
    
    return resultados, ps_calles, ps_publico, ps_predio, ps_base, ps_baseSeparada, 
            ps_volteor, matConexionVertices, vecVertices,
            ps_volRestSombra, matConexionVertices_restSombra, vecVertices_restSombra,
            xopt_restSombra, fopt_restSombra, 
            ps_SombraVolTeor_p, ps_sombraEdif_p, 
            ps_SombraVolTeor_s, ps_sombraEdif_s, 
            ps_SombraVolTeor_o, ps_sombraEdif_o
end



