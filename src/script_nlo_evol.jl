#module Cabida_nlo_evol

##############################################
# PARTE "1": CARGA CABIDA                    #
##############################################



using LotMassing, .poly2D, .polyShape, CSV

#Random.seed!(1236)
#Random.seed!(1230)

##############################################
# PARTE "2": GENERACIÓN DE PARÁMETROS        #
##############################################

idPredio = 3 #8 predio = 1,2,3,4,5,6,75,8
conjuntoTemplates = [2] #4 [1:L, 2:C, 4:V]

fpe = FlagPlotEdif3D(true,  # predio
                     true,  # volTeor
                     true,  # restSombra
                     true,  # edif
                     true,  # sombraVolTeor_p
                     true,  # sombraVolTeor_o
                     true,  # sombraVolTeor_s
                     true,  # sombraEdif_p
                     true,  # sombraEdif_o
                     true)  # sombraEdif_s


dcn = datosCabidaNormativa(5, # SEPMIN (m): max(4, separación mínima deslindes) OGUC 2.6.3
                     5, # ANTEJARDIN (m) 
                     2.75, # RASANTE (m de altura / m de separación)
                     60, # 24, #ALTURAMAX (m)
                     30, # 9, #MAXPISOS (unidades)
                     .7, # COEFOCUPACION (m2 / m2 de terreno)
                     1000, # SUBPREDIALMIN (m2)
                     2500, # DENSIDADMAX (Habitantes / 10000 m2 de terreno bruto)
                     true, # FLAGDENSIDADBRUTA
                     4, # COEFCONSTRUCTIBILIDAD (m2 / m2 de terreno)
                     [.5, 1, 1, 1], # ESTACIONAMIENTOSPORVIV (unidades / departamento)
                     .15, # PORCADICESTACVISITAS (unidades / estacionamiento vendible)
                     34, # SUPPORESTACIONAMIENTO (m2 / Estacionamiento)
                     .25, # ESTBICICLETAPORVIV (unidades / estacionamientos totales)
                     3, # BICICLETASPOREST 
                     true, # FLAGCAMBIOESTPORBICICLETA
                     10, # MAXSUBTE (unidades)
                     .8, # COEFOCUPACIONEST (m2 / superficieTerreno)
                     7, # SEPESTMIN (m)
                     0 # REDUCCIONESTPORDISTMETRO
                     );
     
dca = datosCabidaArquitectura(2.55, # 2.625, # ALTURAPISO (m / piso)
                         .2, # PORCSUPCOMUN (m2 / m2 útil)
                         .05, # PORCTERRAZA (m2 / m2 útil)
                         8,#12, # ANCHOMAX (m) 
                         [], 
                         []
                         );
                          
dcc = datosCabidaComercial([20, 30, 38, 45], # SUPDEPTOUTIL (m2)
                     [.3, .4, .4, 1], # MAXPORCTIPODEPTO  
                     [56, 55, 54, 52], # PRECIOVENTA (UF / m2 vendible) 
                     200 # PRECIOVENTAEST (UF / unidad)
                     );
     
dcu = datosCabidaUnit(30, # duracionProyecto 
             20, # CostoTerreno 
             2 * 1.19 / 100, # ComisionCorredor 
             0.60, # Demolicion 
             20, # LosaSNT 
             10, # LosaBNT 
             5, # EstacVisita 
             3 / 100, # ExtrasPostVenta 
             1.75 / 100, # Arquitectura 
             2.75 / 100, # GestionAdministracion 
             30, # ITO 
             30, # Contabilidad
             0.85 / 100, # Legales 
             0.145, # Calculo 
             250, # MecanicaSuelo 
             50, # Topografia 
             .45 / 100, # ProyectoElectrico 
             0, # ProyectoSanitario 
             0, # ProyectoSeguridad 
             50, # ProyectoPavimentacion 
             25, # ProyectoBasura 
             0, # ProyectoCalefaccion 
             1.2 / 100, # Marketing 
             0.5 / 100, # PilotSalaVentas 
             0, # NotarialesLegales 
             0, # CBR
             0, # EmpalmesAportes 
             600, # DerechosPermisosMunicipales 
             15, # InspeccionCertificacionTecnica 
             0, # Contribuciones 
             120, # CopiaPlanosArquitectura 
             60, # CopiaPlanosObra 
             300, # HallAcceso 
             400, # JardinesPaisajismo 
             0, # HabilitacionSalaUsosMultiples 
             0, # HabilitacionPiscinaEnfermeria 
             0, # CuentasServiciosDeptos 
             0, # GastosComunes 
             0, # ContribucionesDeptos 
             0, # Seguros 
             1 / 100, # ResponsabilidadCivil 
             1 / 100, # PostVentaInmobiliaria 
             0.1 / 100, # SeguroVentaEnVerde 
             1 / 100 # Imprevistos
             );
             
dcf = datosCabidaFlujo([0.05, 0.05, 0.05, 0.05, 0.10, 0.70], # IngresosVentas
             [1, 0, 0, 0, 0, 0], # CostoTerreno
             [0.05, 0.10, 0.35, 0.35, .15, 0], # CostoConstruccion
             [0.40, 0.15, 0.15, 0.15, .15, 0], # CostoHonorariosProyectos
             [0, 0.10, 0.20, 0.20, 0.25, 0.25], # CostoVenta
             [0.1, 0.40, 0.25, 0.15, 0.05, 0.05], # CostoInmobiliarioObra
             [0, 0, 0, 0, 0.50, 0.50], # CostosHabilitacion
             [0, 0, 0, 0, 0.25, 0.75], # CostosPuestaEnMarcha
             [0.05, 0.05, 0.05, 0.05, 0.05, 0.75], # CostosAtencionCliente
             [0, 0.20, 0.20, 0.20, 0.20, 0.20], # Imprevistos
             [0.05, 0.10, 0.35, 0.35, .15, 0], # ingresoLineaCredito
             [0, 0, 0.10, 0.35, 0.35, .2], # pagoLineaCredito
             .27, # TasaImpuestoRenta
             .05, # TasaInteresLineaCredito 
             0.8 * dcu.duracionProyecto, # DuracionLineaCredito 
             15 # Tasaciones
             );
     
dcr = datosCabidaRentabilidad(1.20) # RetornoExigido
     

if idPredio == 1
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
    dcn.DENSIDADMAX = 20000 # DENSIDADMAX (Habitantes / 10000 m2 de terreno bruto)
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
    dcn.COEFOCUPACION = .3 # COEFOCUPACION (m2 / m2 de terreno)
    dcn.SUBPREDIALMIN = 1500 # SUBPREDIALMIN (m2)
    dcn.DENSIDADMAX = 880 # DENSIDADMAX (Habitantes / 10000 m2 de terreno bruto)
    dcn.FLAGDENSIDADBRUTA = false # FLAGDENSIDADBRUTA
    dcn.COEFCONSTRUCTIBILIDAD = 2.8 # COEFCONSTRUCTIBILIDAD (m2 / m2 de terreno)
    dcn.ESTACIONAMIENTOSPORVIV = [1, 2, 2, 2] # ESTACIONAMIENTOSPORVIV
    dcn.FLAGCAMBIOESTPORBICICLETA = false # FLAGCAMBIOESTPORBICICLETA

    dcc.SUPDEPTOUTIL = [50, 90, 110, 140] # SUPDEPTOUTIL (m2)
    dcc.PRECIOVENTA = [95, 91, 89, 87] # PRECIOVENTA (UF / m2 vendible) 
    dcc.MAXPORCTIPODEPTO = [1, 1, 1, 1];
    dcc.PRECIOVENTAEST = 350 # PRECIOVENTAEST (UF / unidad)

    dcu.LosaSNT = 30 # LosaSNT 
    dcu.LosaBNT = 10 # LosaBNT 

    dca.ANCHOMAX = 8 # Ancho Crujía (m)
    dca.ALTURAPISO = 2.7 # 2.625, # ALTURAPISO (m / piso)
    dca.PORCSUPCOMUN = .2 # PORCSUPCOMUN (m2 / m2 útil)

    #nombreArchivo = "el_dante_2.csv"
    nombreArchivo = "predio_ElDante.csv"
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
    x = factorCorreccion * x
    y = factorCorreccion * y
    
#    dcp = datosCabidaPredio(x, y, [1,2,3], [15,15,15], 0, 200);
    dcp = datosCabidaPredio(x, y, [1,2,3,4,5,6], [15,15,15,15,15,20], 0, 200);

end

        

resultados, ps_predio, ps_base, xopt_cs, fopt_cs, polyCorte,
ps_SombraVolTeor_p, ps_sombraEdif_p, 
ps_SombraVolTeor_o, ps_sombraEdif_o, 
ps_SombraVolTeor_s, ps_sombraEdif_s = executaCalculoCabidas(dcp, dcn, dca, dcc, dcu, dcf, dcr, fpe, conjuntoTemplates);

