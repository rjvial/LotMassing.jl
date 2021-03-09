#module Cabida_nlo_evol

##############################################
# PARTE "1": CARGA CABIDA                    #
##############################################



using LotMassing, .poly2D, .polyShape, CSV, JLD2

#Random.seed!(1236)
#Random.seed!(1230)

##############################################
# PARTE "2": GENERACIÓN DE PARÁMETROS        #
##############################################

idPredio = 6 #8 predio = 1,2,3,4,5,6,7,8
conjuntoTemplates = [1] #4 [1:L, 2:C, 3:lll, 4:V]

@load "defaults.jld2" fpe dcn dca dcc dcu dcf dcr

if idPredio == 1
    dcc.SUPDEPTOUTIL = [30, 40, 50, 65] # SUPDEPTOUTIL (m2)
    dcc.PRECIOVENTA = [65, 58, 53, 50] # PRECIOVENTA (UF / m2 vendible) 

    factorCorreccion = 2;
    x = factorCorreccion * [0 30 40 45 10]';
    y = factorCorreccion * [10 0 15 35 30]';
# Calle: [4]
    dcp = datosCabidaPredio(x, y, [1 4], [20 20], 1, 200);

elseif idPredio == 2
    factorCorreccion = 5;
    x = factorCorreccion * [0 10 15 20 25 13 12 4 9]';
    y = factorCorreccion * [10 0 12 7 20 25 22 28 14]';
# Calle: [1 5]
    dcp = datosCabidaPredio(x, y, [1 5], [20 20], 1, 200);

elseif idPredio == 3
# EJEMPLO 1 (Córdova y Figueroa con Vargas Fontecilla, Quinta Normal)
    factorCorreccion = 0.8345;
    x = factorCorreccion * [-7869557.5 -7869559.7 -7869535.4 -7869535.5 -7869490.4 -7869488.3]';
    y = factorCorreccion * [-3952906.8 -3952965.7 -3952966.5 -3952970.9 -3952972.4 -3952909.6]';
# Calle: [1 6]
    dcp = datosCabidaPredio(x, y, [1 6], [18 20], 0, 200);

elseif idPredio == 4
# EJEMPLO 2 (Catedral llegando a General Velásquez, Quinta Normal)
    factorCorreccion = 0.8547;
    x = factorCorreccion * [-7869442.1 -7869413.9 -7869409.5 -7869438.5]';
    y = factorCorreccion * [-3953939.3 -3953935.5 -3953861.6 -3953864.5]';
# Calle: [1]
    dcp = datosCabidaPredio(x, y, [1], [20], 1, 200);

elseif idPredio == 5
    factorCorreccion = 1;
    x = factorCorreccion * [0 150 150 100 100 50 50 0]';
    y = factorCorreccion * [0 0 100 100 50 50 100 100]';
# Calle: [4]
    dcp = datosCabidaPredio(x, y, [1 8], [15 15], 1, 200);

elseif idPredio == 6
    # EJEMPLO 6 (Augusto Leguía)
    factorCorreccion = 0.4;
    x = factorCorreccion * [568 571 612 613 646 648 683 681]';
    y = factorCorreccion * [-339 -405 -403 -418 -419 -452 -442 -355]';
    # Calle: [1 6]
    dcp = datosCabidaPredio(x, y, [1 6 8], [15 10 20], 0, 200);

elseif idPredio == 7
    # EJEMPLO 7 (Independencia)

    dcn.SEPMIN = 5 # SEPMIN (m): max(4, separación mínima deslindes) OGUC 2.6.3
    dcn.ANTEJARDIN = 5 # ANTEJARDIN (m) 
    dcn.ALTURAMAX = 30 # 24, #ALTURAMAX (m)
    dcn.MAXPISOS = 20 # 9, #MAXPISOS (unidades)
    dcn.COEFOCUPACION = .5 # COEFOCUPACION (m2 / m2 de terreno)
    dcn.SUBPREDIALMIN = 300 # SUBPREDIALMIN (m2)
    dcn.DENSIDADMAX = 2000 # DENSIDADMAX (Habitantes / 10000 m2 de terreno bruto)
    dcn.COEFCONSTRUCTIBILIDAD = 3 # COEFCONSTRUCTIBILIDAD (m2 / m2 de terreno)

    dca.ANCHOMAX = 10 # ANCHOMAX (m)

    #dcc.SUPDEPTOUTIL = [20, 35, 50, 60] # SUPDEPTOUTIL (m2)
    #dcc.PRECIOVENTA = [65, 58, 53, 50] # PRECIOVENTA (UF / m2 vendible) 

    dcc.SUPDEPTOUTIL = [30, 40, 50, 65] # SUPDEPTOUTIL (m2)
    dcc.PRECIOVENTA = [65, 58, 53, 50] # PRECIOVENTA (UF / m2 vendible) 
    dcc.MAXPORCTIPODEPTO = [.50, .10, .33, .18] # MAXPORCTIPODEPTO  
    dcr = datosCabidaRentabilidad(1.15) # RetornoExigido

    nombreArchivo = "Independencia.csv"
    loadData = CSV.File(string("C:/Users/rjvia/Downloads/", nombreArchivo); header=false)
    numDatos = length(loadData)
    x = zeros(1,numDatos)
    y = zeros(1,numDatos)
    for i = 1:numDatos
        x[i] = loadData[i].Column1
        y[i] = loadData[i].Column2
    end
    areaSup = x[1]
    x = x[2:end]
    y = y[2:end]
    V = [x y]
    factorCorreccion = ajusteArea(V, areaSup)
    dcp = datosCabidaPredio(factorCorreccion * x, factorCorreccion * y, [1 4], [16.5 13.7], 1, 200);

elseif idPredio == 8
    # EJEMPLO 7 (La Florida)

    dcn.SEPMIN = 5 # SEPMIN (m): max(4, separación mínima deslindes) OGUC 2.6.3
    dcn.ANTEJARDIN = 5 # ANTEJARDIN (m) 
    dcn.ALTURAMAX = 60 #47 # 24, #ALTURAMAX (m)
    dcn.MAXPISOS = 40 # 9, #MAXPISOS (unidades)
    dcn.COEFOCUPACION = .4 # COEFOCUPACION (m2 / m2 de terreno)
    dcn.SUBPREDIALMIN = 1000 # SUBPREDIALMIN (m2)
    dcn.DENSIDADMAX = 2000 # DENSIDADMAX (Habitantes / 10000 m2 de terreno bruto)
    dcn.COEFCONSTRUCTIBILIDAD = 3.2 # COEFCONSTRUCTIBILIDAD (m2 / m2 de terreno)

    dcc.SUPDEPTOUTIL = [20, 35, 45, 55] # SUPDEPTOUTIL (m2)
    dcc.PRECIOVENTA = [65, 63, 60, 57] # PRECIOVENTA (UF / m2 vendible) 
    dcc.MAXPORCTIPODEPTO = [0, 1, 1, 1];

    dca.ANCHOMAX = 8 # Ancho Crujía (m)

    nombreArchivo = "predioLaFlorida2.csv"
    loadData = CSV.File(string("C:/Users/rjvia/Downloads/", nombreArchivo); header=false)
    numDatos = length(loadData)
    x = zeros(1,numDatos)
    y = zeros(1,numDatos)
    for i = 1:numDatos
        x[i] = loadData[i].Column1
        y[i] = loadData[i].Column2
    end
    areaSup = x[1]
    x = x[2:end]
    y = y[2:end]
    V = [x y]
    V = polyShape.reversePath(V);
    x = V[1:end,1]
    y = V[1:end,2]
    factorCorreccion = ajusteArea(V, areaSup)
    dcp = datosCabidaPredio(factorCorreccion * x, factorCorreccion * y, [1 3], [17.5 55], 0, 200);

elseif idPredio == 9
    # EJEMPLO 9 (El Dante)

    dcn.SEPMIN = 8 # SEPMIN (m): max(4, separación mínima deslindes) OGUC 2.6.3
    dcn.ANTEJARDIN = 7 # ANTEJARDIN (m) 
    dcn.ALTURAMAX = 52.5 #47 # 24, #ALTURAMAX (m)
    dcn.MAXPISOS = 15 # 9, #MAXPISOS (unidades)
    dcn.COEFOCUPACION = .3 # COEFOCUPACION (m2 de base / m2 de terreno)
    dcn.SUBPREDIALMIN = 1500 # SUBPREDIALMIN (m2)
    dcn.DENSIDADMAX = 880 # DENSIDADMAX (Habitantes / 10000 m2 de terreno bruto)
    dcn.FLAGDENSIDADBRUTA = false # FLAGDENSIDADBRUTA
    dcn.COEFCONSTRUCTIBILIDAD = 2.8 # COEFCONSTRUCTIBILIDAD (m2 de Sup. Util/ m2 de terreno)
    dcn.ESTACIONAMIENTOSPORVIV = [1.5, 1.5, 1.5, 2] # ESTACIONAMIENTOSPORVIV
    dcn.FLAGCAMBIOESTPORBICICLETA = true # FLAGCAMBIOESTPORBICICLETA

    dcc.SUPDEPTOUTIL = [50, 90, 110, 140] # SUPDEPTOUTIL (m2)
    dcc.PRECIOVENTA = [95, 91, 89, 87] # PRECIOVENTA (UF / m2 vendible) 
    dcc.MAXPORCTIPODEPTO = [1, 1, 1, 1];
    dcc.PRECIOVENTAEST = 350 # PRECIOVENTAEST (UF / unidad)

    dcu.LosaSNT = 30 # LosaSNT 
    dcu.LosaBNT = 12 # LosaBNT 

    dca.ANCHOMAX = 8 # Ancho Crujía (m)
    dca.ALTURAPISO = 2.7 # 2.625, # ALTURAPISO (m / piso)
    dca.PORCSUPCOMUN = .2 # PORCSUPCOMUN (m2 / m2 útil)

    nombreArchivo = "el_dante_2.csv"
    #nombreArchivo = "predio_ElDante.csv"
    loadData = CSV.File(string("C:/Users/rjvia/Downloads/", nombreArchivo); header=false)
    numDatos = length(loadData)
    x = zeros(1,numDatos)
    y = zeros(1,numDatos)
    for i = 1:numDatos
        x[i] = loadData[i].Column1
        y[i] = loadData[i].Column2
    end
    areaSup = x[1]
    x = x[2:end]
    y = y[2:end]
    V = [x y]
    factorCorreccion = factorIgualaArea(V, areaSup)
    x = factorCorreccion * x
    y = factorCorreccion * y
    
    dcp = datosCabidaPredio(x, y, [1,2,3], [15,15,15], 0, 200);
#    dcp = datosCabidaPredio(x, y, [1,2,3,4,5,6], [15,15,15,15,15,20], 0, 200);

end

        

resultados, ps_predio, ps_base, xopt_cs, fopt_cs, polyCorte,
ps_SombraVolTeor_p, ps_sombraEdif_p, 
ps_SombraVolTeor_o, ps_sombraEdif_o, 
ps_SombraVolTeor_s, ps_sombraEdif_s = executaCalculoCabidas(dcp, dcn, dca, dcc, dcu, dcf, dcr, fpe, conjuntoTemplates);

