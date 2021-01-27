##############################################
# PARTE "1": CARGA CABIDA                    #
##############################################

# cd("C:/Users/rjvia/.julia/dev/Cabida/src/")

# include("Cabida.jl")
# using .Cabida

using Cabida, NPFinancial, .poly2D, .polyShape



##############################################
# PARTE "2": GENERACIÓN DE PARÁMETROS        #
##############################################


#EJEMPLO 1 (Córdova y Figueroa con Vargas Fontecilla, Quinta Normal)
factorCorreccion = 0.8345;
x = factorCorreccion * [-7869557.5 -7869559.7 -7869535.4 -7869535.5 -7869490.4 -7869488.3]';
y = factorCorreccion * [-3952906.8 -3952965.7 -3952966.5 -3952970.9 -3952972.4 -3952909.6]';
# Calle: [1 6]
dcp = datosCabidaPredio(x, y, [1 6], [18 20], 0, 200);


"""
#EJEMPLO 2 (Catedral llegando a General Velásquez, Quinta Normal)
factorCorreccion=0.8547;
x=factorCorreccion*[-7869442.1 -7869413.9 -7869409.5 -7869438.5]';
y=factorCorreccion*[-3953939.3 -3953935.5 -3953861.6 -3953864.5]';
# Calle: [1]
dcp = datosCabidaPredio(x, y, [1], [20], 1, 200);
"""

"""
factorCorreccion = 5;
x = factorCorreccion * [0 10 15 20 25 13 12 4 9]';
y = factorCorreccion * [10 0 12 7 20 25 22 28 14]';
# Calle: [1 5]
dcp = datosCabidaPredio(x, y, [1 5], [20 20], 1, 200);
"""


dcn = datosCabidaNormativa(5, #SEPMIN (m)
                            5, #ANTEJARDIN (m) 
                            2.75, #RASANTE (m de altura / m de separación)
                            24, #ALTURAMAX (m)
                            9, #MAXPISOS (unidades)
                            .7, #COEFOCUPACION (m2 / m2 de terreno)
                            1000, #SUBPREDIALMIN (m2)
                            2500, #DENSIDADMAX (Habitantes / 10000 m2 de terreno bruto)
                            4, #COEFCONSTRUCTIBILIDAD (m2 / m2 de terreno)
                            [.5, 1, 1, 1], #ESTACIONAMIENTOSPORVIV (unidades / departamento)
                            .15, #PORCADICESTACVISITAS (unidades / estacionamiento vendible)
                            34, #SUPPORESTACIONAMIENTO (m2 / Estacionamiento)
                            .25, #ESTBICICLETAPORVIV
                            3, #ESTACPORBICICLETERO 
                            10, #MAXSUBTE (unidades)
                            .8, #COEFOCUPACIONEST (m2 / superficieTerreno)
                            7, #SEPESTMIN (m)
                            0 #REDUCCIONESTPORDISTMETRO
                            );

dca = datosCabidaArquitectura(2.625, #ALTURAPISO (m / piso)
                                .2, #PORCSUPCOMUN (m2 / m2 útil)
                                .05, #PORCTERRAZA (m2 / m2 útil)
                                12, #ANCHOMAX (m) 
                                MATCELDASCONF_, 
                                MATCONFHOR_
                                );

dcc = datosCabidaComercial([20, 30, 38, 45], #SUPDEPTOUTIL (m2)
                            [.3*1, 0, .4, 1], #MAXPORCTIPODEPTO  
                            [56, 55, 54, 52], #PRECIOVENTA (UF / m2 vendible) 
                            200 #PRECIOVENTAEST (UF / unidad)
                            );

dcu = datosCabidaUnit(30, #duracionProyecto 
                        20, #CostoTerreno 
                        2 * 1.19 / 100, #ComisionCorredor 
                        0.60, #Demolicion 
                        20, #LosaSNT 
                        10, #LosaBNT 
                        5, #EstacVisita 
                        3 / 100, #ExtrasPostVenta 
                        1.75 / 100, #Arquitectura 
                        2.75 / 100, #GestionAdministracion 
                        30, #ITO 
                        30, #Contabilidad
                        0.85 / 100, #Legales 
                        0.145, #Calculo 
                        250, #MecanicaSuelo 
                        50, #Topografia 
                        .45 / 100, #ProyectoElectrico 
                        0, #ProyectoSanitario 
                        0, #ProyectoSeguridad 
                        50, #ProyectoPavimentacion 
                        25, #ProyectoBasura 
                        0, #ProyectoCalefaccion 
                        1.2 / 100, #Marketing 
                        0.5 / 100, #PilotSalaVentas 
                        0, #NotarialesLegales 
                        0, #CBR
                        0, #EmpalmesAportes 
                        600, #DerechosPermisosMunicipales 
                        15, #InspeccionCertificacionTecnica 
                        0, #Contribuciones 
                        120, #CopiaPlanosArquitctura 
                        60, #CopiaPlanosObra 
                        300, #HallAcceso 
                        400, #JardinesPaisajismo 
                        0, #HabilitacionSalaUsosMultiples 
                        0, #HabilitacionPiscinaEnfermeria 
                        0, #CuentasServiciosDeptos 
                        0, #GastosComunes 
                        0, #ContribucionesDeptos 
                        0, #Seguros 
                        1 / 100, #ResponsabilidadCivil 
                        1 / 100, #PostVentaInmobiliaria 
                        0.1 / 100, #SeguroVentaEnVerde 
                        1 / 100 #Imprevistos
                        );

dcf = datosCabidaFlujo([0.05, 0.05, 0.05, 0.05, 0.10, 0.70], #IngresosVentas
                        [1, 0, 0, 0, 0, 0], #CostoTerreno
                        [0.05, 0.10, 0.35, 0.35, .15, 0], #CostoConstruccion
                        [0.40, 0.15, 0.15, 0.15, .15, 0], #CostoHonorariosProyectos
                        [0, 0.10, 0.20, 0.20, 0.25, 0.25], #CostoVenta
                        [0.1, 0.40, 0.25, 0.15, 0.05, 0.05], #CostoInmobiliarioObra
                        [0, 0, 0, 0, 0.50, 0.50], #CostosHabilitacion
                        [0, 0, 0, 0, 0.25, 0.75], #CostosPuestaEnMarcha
                        [0.05, 0.05, 0.05, 0.05, 0.05, 0.75], #CostosAtencionCliente
                        [0, 0.20, 0.20, 0.20, 0.20, 0.20], #Imprevistos
                        [0.05, 0.10, 0.35, 0.35, .15, 0], #ingresoLineaCredito
                        [0, 0, 0.10, 0.35, 0.35, .2], #pagoLineaCredito
                        .27, #TasaImpuestoRenta
                        .05, #TasaInteresLineaCredito 
                        0.8 * dcu.duracionProyecto, #DuracionLineaCredito 
                        15 #Tasaciones
                        );

MATCELDASCONF, MATCONFHOR, MATCONFVERT = generaMatCeldasConf(dca);
NumConfig, NumCeldas = size(MATCELDASCONF);

numTiposDepto = length(dcc.SUPDEPTOUTIL);

# Posiciona el origen del predio (esq. inferior izquierda) en el punto 0,0. Obtiene estrucura con las matrices de rotación
V_predio, R = infoPredio(dcp.x, dcp.y);
numLados = 3; # length(R);

# Calcula area del predio
superficieTerreno = polyArea(V_predio);

# Calcula matriz V_areaEdif asociada a los vértices del area de edificación
V_areaEdif = copy(V_predio);
numLadosPredio = size(V_areaEdif, 1);
conjuntoLados = 1:numLadosPredio;
conjuntoLadosCalle = dcp.ladosConCalle;
conjuntoLadosVecinos = setdiff(conjuntoLados, conjuntoLadosCalle);
sepVecinos = dcn.SEPMIN;
V_areaEdif = expandPolygonSides(V_areaEdif, -sepVecinos, conjuntoLadosVecinos);
V_areaEdif = expandPolygonSides(V_areaEdif, -dcn.ANTEJARDIN, conjuntoLadosCalle);

# Descompone el area de edificación no-convexa en la unión de varias areas convexas
aux, SP = nonconv2sumofconv_v2(PolyShape([V_areaEdif],1));
numNonConv = length(SP);
s_areaEdif = Array{PolyData,1}([]);
for i = 1:numNonConv
    s_V = V_areaEdif[SP[i].points,:];
    s_A, s_b = vert2con(s_V);
    push!(s_areaEdif, PolyData(s_V, s_A, s_b, []));
end

# Genera polihedro asociado al area bruta
for i = 1:length(conjuntoLadosCalle)
    if i == 1
        V_bruto = copy(V_predio);
    end
    V_bruto = expandPolygonSide(V_bruto, min(30, dcp.ANCHOESPACIOPUBLICO[i] / 2), conjuntoLadosCalle[i]);
    global V_bruto
end

# Descompone el area bruta no-convexa en la unión de varias areas convexas
aux, SP_bruto = nonconv2sumofconv_v2(PolyShape([V_bruto],1));
desplazamientoLadoComun = dcn.ALTURAMAX / dcn.RASANTE;
s_bruto = Array{PolyData,1}([]);
for i = 1:numNonConv
    flagLadosComunes = SP_bruto[i].ladoComun .> 0;
    ladosComunes = SP_bruto[i].ladoComun[flagLadosComunes];
    numLadosComunes = sum(flagLadosComunes);
    V_bruto_i = V_bruto[SP_bruto[i].points,:];
    for j = 1:numLadosComunes
        V_bruto_i = expandPolygonSide(V_bruto_i, desplazamientoLadoComun, ladosComunes[j]);
    end
    s_A, s_b = vert2con(V_bruto_i);
    s_proyeccion = (s_A[:,1].^2 + s_A[:,2].^2).^(.5);
    push!(s_bruto, PolyData(V_bruto_i, s_A, s_b, s_proyeccion));
end
superficieTerrenoBruta = polyArea(V_bruto);

# Calcula el volumen teórico
sepAlturaMax = dcn.ALTURAMAX / dcn.RASANTE;
alturaCorteVecinos = dcn.RASANTE * sepVecinos;
alturaCorteEspPublico = dcn.ALTURAMAX;
sepEspPublico = alturaCorteEspPublico / dcn.RASANTE;
deltaSepEspPublicoVecinos = sepEspPublico - sepVecinos;
V_corteVecinos = copy(V_areaEdif);
for i = conjuntoLadosVecinos
    if i == conjuntoLadosVecinos[1]
        V_corteEspPublico = copy(V_corteVecinos);
    end
    V_corteEspPublico = expandPolygonSide(V_corteEspPublico, -deltaSepEspPublicoVecinos, conjuntoLados[i]);
    global V_corteEspPublico
end
for i = conjuntoLadosCalle
    if i == conjuntoLadosCalle[1]
        V_corteAlturaMax = copy(V_corteEspPublico);
    end
#    V_corteAlturaMax = expandPolygonSide(V_corteAlturaMax, -(sepAlturaMax - sepEspPublico), conjuntoLados[i]);
    global V_corteAlturaMax
end
V_base = copy(V_areaEdif);
numVerticesBase = size(V_base, 1);
V_volteor = [V_base zeros(numVerticesBase, 1);
             V_corteVecinos alturaCorteVecinos * ones(numVerticesBase, 1);
             V_corteAlturaMax dcn.ALTURAMAX * ones(numVerticesBase, 1)
             ];


maxDeptos = dcn.DENSIDADMAX / 4 * superficieTerrenoBruta / 10000;



##############################################
# PARTE "3": DEFINICIÓN SOLVER               #
##############################################

using JuMP, Cbc, GAMS
#m = Model(Cbc.Optimizer)
#set_optimizer_attribute(m, "ratioGap", 0.001)
#set_optimizer_attribute(m, "threads", 3)

m = Model(GAMS.Optimizer)
set_optimizer_attribute(m, "OptCR", 0.001)
set_optimizer_attribute(m, "Threads", 3)


##############################################
# PARTE "4": VARIABLES DE DECISION           #
##############################################

@variables(m, begin
    0 <= pos_x[i = 1:NumCeldas]
    0 <= pos_y[i = 1:NumCeldas]
    0 <= largo_x[i = 1:NumCeldas, r = 1:numLados]
    0 <= largo_y[i = 1:NumCeldas, r = 1:numLados]
    0 <= largo[i = 1:NumCeldas]
    0 <= areaCelda[z = 1:dcn.MAXPISOS, i = 1:NumCeldas]
    0 <= areaBasal[z = 1:dcn.MAXPISOS]
    0 <= altura[i = 1:NumCeldas] <= dcn.ALTURAMAX
    pisoActivoCeldas[i = 1:NumCeldas, j = 1:dcn.MAXPISOS], Bin
    pisoActivo[z = 1:dcn.MAXPISOS], Bin
    0 <= numDeptosTipo[u = 1:numTiposDepto]
    configSel[i = 1:NumConfig], Bin
    d[i = 1:numLados], Bin
    q1[i = 1:NumCeldas, j = 1:numNonConv], Bin
    q2[i = 1:NumCeldas, j = 1:numNonConv], Bin
    q3[i = 1:NumCeldas, j = 1:numNonConv], Bin
    q4[i = 1:NumCeldas, j = 1:numNonConv], Bin
    w1[i = 1:NumCeldas, j = 1:numNonConv], Bin
    w2[i = 1:NumCeldas, j = 1:numNonConv], Bin
    w3[i = 1:NumCeldas, j = 1:numNonConv], Bin
    w4[i = 1:NumCeldas, j = 1:numNonConv], Bin
    0 <= CostoUnitTerreno
end)



##############################################
# PARTE "5": EXPRESIONES AUXILIARES          #
##############################################

# Cálculo Número de Estacionamientos
estacionamientosViviendas = sum(dcn.ESTACIONAMIENTOSPORVIV .* numDeptosTipo) 
estacionamientosVisitas = estacionamientosViviendas * dcn.PORCADICESTACVISITAS;
estacionamientosNormales = estacionamientosViviendas + estacionamientosVisitas
estacionamientosDiscapacitados = (maxDeptos <= 20) ? 1 : 
                                 ((maxDeptos <= 50) ? 2 : 
                                 ((maxDeptos <= 200) ? 3 : 
                                 ((maxDeptos <= 400) ? 4 : 
                                 ((maxDeptos <= 500) ? 5 : (0.01*maxDeptos)))))
estacionamientosBicicletas = estacionamientosNormales * dcn.ESTBICICLETAPOREST;
descuentoEstCercaniaMetro = estacionamientosNormales * 0.5*dcn.REDUCCIONESTPORDISTMETRO
descuentoEstBicicletas = estacionamientosBicicletas/dcn.BICICLETASPOREST
estacionamientosNormales = estacionamientosNormales - descuentoEstCercaniaMetro - descuentoEstBicicletas
cambioEstBicicletas = estacionamientosNormales / 3
estacionamientosVendibles = estacionamientosViviendas - descuentoEstCercaniaMetro - descuentoEstBicicletas - cambioEstBicicletas
estacionamientosBicicletas = estacionamientosBicicletas + cambioEstBicicletas * dcn.BICICLETASPOREST
estacionamientos = estacionamientosVendibles + estacionamientosVisitas + estacionamientosDiscapacitados + estacionamientosBicicletas / dcn.BICICLETASPOREST;

# Cálculo de Superficies
superficieUtilDepto = numDeptosTipo .* dcc.SUPDEPTOUTIL;
superficieUtil = sum(superficieUtilDepto); # Superficie Util incluye terrazas.
superficieTerrazaDepto = 2 .* superficieUtilDepto .* dca.PORCTERRAZA;
superficieVendibleDepto = superficieUtilDepto .* (1-dca.PORCTERRAZA) + superficieTerrazaDepto * .5; # = superficieUtilDepto
superficieVendible = sum(superficieVendibleDepto);
superficieComun = dca.PORCSUPCOMUN * superficieUtil;
superficieLosaSNT = superficieVendible + superficieComun;
superficieLosaBNT = dcn.SUPPORESTACIONAMIENTO * estacionamientosVendibles;

# Cálculo de Ingresos por Ventas
ingresosVentaDeptos = sum(superficieVendibleDepto .* dcc.PRECIOVENTA);
ingresosVentaEstacionamientos = estacionamientosVendibles * dcc.PRECIOVENTAEST;
IngresosVentas = ingresosVentaDeptos + ingresosVentaEstacionamientos;

# Cálculo de Costos de Terreno y Construcción
CostoTerreno = CostoUnitTerreno * superficieTerreno * (1 + dcu.ComisionCorredor);
CostoConstruccionSNT = dcu.LosaSNT * superficieLosaSNT;
CostoConstruccionBNT = dcu.LosaBNT * superficieLosaBNT;
CostoEstacVisita = dcu.EstacVisita * dcn.SUPPORESTACIONAMIENTO * estacionamientosVisitas;
devolucionIVA = (CostoConstruccionSNT + CostoConstruccionBNT + CostoEstacVisita) / 1.19 * 0.19 * 0.65;
CostoConstruccion = dcu.Demolicion * superficieTerreno + CostoConstruccionSNT + CostoConstruccionBNT + CostoEstacVisita +
                    dcu.ExtrasPostVenta * (CostoConstruccionSNT + CostoConstruccionBNT) - devolucionIVA;

# Cálculo de Costos de Permisos, Habilitación, Puesta en Marcha y Atención de Clientes
CostoInmobiliarioObra = dcu.EmpalmesAportes * sum(numDeptosTipo) + dcu.DerechosPermisosMunicipales +
                    dcu.duracionProyecto * dcu.InspeccionCertificacionTecnica + dcu.Contribuciones * (dcu.duracionProyecto / 12) * 4 +
                    dcu.CopiaPlanosArquitctura + dcu.CopiaPlanosObra;
CostosHabilitacion = dcu.HallAcceso + dcu.JardinesPaisajismo + dcu.HabilitacionSalaUsosMultiples + dcu.HabilitacionPiscinaEnfermeria;
CostosPuestaEnMarcha = dcu.duracionProyecto * dcu.CuentasServiciosDeptos + dcu.duracionProyecto * dcu.GastosComunes +
                    dcu.ContribucionesDeptos + dcu.Seguros;
CostosAtencionCliente = dcu.ResponsabilidadCivil * CostoConstruccion + dcu.PostVentaInmobiliaria * CostoConstruccion +
                    dcu.SeguroVentaEnVerde * CostoConstruccion;

# Cálculo de Honorarios de Proyecto, Administración y Gestión de Venta
CostoHonorariosProyectos = dcu.Arquitectura * ingresosVentaDeptos + dcu.GestionAdministracion * ingresosVentaDeptos +
                    dcu.duracionProyecto * (dcu.ITO + dcu.Contabilidad) + dcu.Legales * CostoConstruccion +
                    dcu.Calculo * (superficieLosaSNT + superficieLosaBNT) + dcu.MecanicaSuelo + dcu.Topografia +
                    dcu.ProyectoElectrico * CostoConstruccion + dcu.ProyectoSanitario * CostoConstruccion +
                    dcu.ProyectoSeguridad * CostoConstruccion + dcu.ProyectoPavimentacion + dcu.ProyectoBasura + dcu.ProyectoCalefaccion;
CostoPromocionVenta = dcu.Marketing * IngresosVentas + dcu.PilotSalaVentas * IngresosVentas;
CostoOtrosVenta = dcu.NotarialesLegales * sum(numDeptosTipo) + dcu.CBR * sum(numDeptosTipo);
CostoVenta = CostoPromocionVenta + CostoOtrosVenta;

# Cálculo de Otros Costos
Imprevistos = dcu.Imprevistos * IngresosVentas;
DebitoIVA = (IngresosVentas - CostoTerreno) * 0.19 / 1.19;
CreditoIVA = (CostoConstruccion + CostoVenta + CostosHabilitacion) * 0.19 / 1.19;
CostoPagoIVA = DebitoIVA - CreditoIVA;

# Cálculo Costo Total
CostoTotal = CostoTerreno + CostoConstruccion + CostoHonorariosProyectos + CostoVenta + CostoInmobiliarioObra + CostosHabilitacion +
            CostosPuestaEnMarcha + CostosAtencionCliente + Imprevistos + CostoPagoIVA;


# Variables tipo flag asociadas a las celdas activas según configuración seleccionada
flagConfHor = configSel' * MATCONFHOR;
flagConfVert = configSel' * MATCONFVERT;
celdasConfig = configSel' * MATCELDASCONF;

# Variables auxiliares asociadas a la posición de los vertices de las celdas.
p1 = [(R[r].mat * ([pos_x'; pos_y'] - repeat(R[r].cr, 1, NumCeldas)) + repeat(R[r].cr, 1, NumCeldas))' for r=1:numLados];
p2 = [(R[r].mat * ([pos_x' + largo_x[:,r]';pos_y'] - repeat(R[r].cr, 1, NumCeldas)) + repeat(R[r].cr, 1, NumCeldas))' for r=1:numLados];
p3 = [(R[r].mat * ([pos_x' + largo_x[:,r]';pos_y' + largo_y[:,r]'] - repeat(R[r].cr, 1, NumCeldas)) + repeat(R[r].cr, 1, NumCeldas))' for r=1:numLados];
p4 = [(R[r].mat * ([pos_x'; pos_y' + largo_y[:,r]'] - repeat(R[r].cr, 1, NumCeldas)) + repeat(R[r].cr, 1, NumCeldas))' for r=1:numLados];



##############################################
# PARTE "6": RESTRICCIONES DEL MIP           #
##############################################

@constraints(m, begin
# Restricción de Altura Máxima y Área Basal Máxima (Coeficiente de Ocupación)
    [i = 1:NumCeldas], sum(pisoActivoCeldas[i,:]) * dca.ALTURAPISO <= altura[i]    
    [i = 1:NumCeldas, z = 1:dcn.MAXPISOS - 1], pisoActivoCeldas[i, z + 1] <= pisoActivoCeldas[i, z]
    [z = 1:dcn.MAXPISOS], sum(pisoActivoCeldas[:, z]) <= pisoActivo[z] * 500
    areaPorPiso[z = 1:dcn.MAXPISOS], areaBasal[z] <= pisoActivo[z] * dcn.COEFOCUPACION * superficieTerreno
    maxPisosCeldas[i = 1:NumCeldas], sum(pisoActivoCeldas[i,:]) <= dcn.MAXPISOS
    alturaMaxCeldas[i = 1:NumCeldas], altura[i] <= celdasConfig[i] * min(dcn.ALTURAMAX, dcn.MAXPISOS*3.5)

# Restricciones que establecen relaciones entre areaBasal, numDeptos, largo y ancho
    [i = 1:NumCeldas, z = 1:dcn.MAXPISOS], areaCelda[z,i] <= 5000 * pisoActivoCeldas[i,z]
    [z = 1:dcn.MAXPISOS], areaCelda[z,:]  .<= largo .* dca.ANCHOMAX
    areaBasal .<= sum(areaCelda, dims = 2)
    superficieLosaSNT <= sum(areaBasal)
    maxCoefConstructibilidad, sum(areaBasal) <= superficieTerreno * dcn.COEFCONSTRUCTIBILIDAD * (1 + 0.3 * dcp.FUSIONTERRENOS)
    

# Restricciones de separación predial mínima
    restPredialPunto1[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_areaEdif[i].A * p1[r][j,:] .<= s_areaEdif[i].b .+ 500 * (1 - q1[j,i]) .+ 500 * (1 - d[r])
    restPredialPunto2[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_areaEdif[i].A * p2[r][j,:] .<= s_areaEdif[i].b .+ 500 * (1 - q2[j,i]) .+ 500 * (1 - d[r])
    restPredialPunto3[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_areaEdif[i].A * p3[r][j,:] .<= s_areaEdif[i].b .+ 500 * (1 - q3[j,i]) .+ 500 * (1 - d[r])
    restPredialPunto4[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_areaEdif[i].A * p4[r][j,:] .<= s_areaEdif[i].b .+ 500 * (1 - q4[j,i]) .+ 500 * (1 - d[r])
    [j = 1:NumCeldas], sum(q1[j,:]) == 1
    [j = 1:NumCeldas], sum(q2[j,:]) == 1
    [j = 1:NumCeldas], sum(q3[j,:]) == 1
    [j = 1:NumCeldas], sum(q4[j,:]) == 1

    
# Restricción de Rasante
    restRasantePunto1[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_bruto[i].A * dcn.RASANTE ./ s_bruto[i].proyeccion * p1[r][j,:] .+ altura[j] .<= s_bruto[i].b * dcn.RASANTE ./ s_bruto[i].proyeccion .+ 500 * (1 - w1[j,i]) .+ 500 * (1 - d[r])
    restRasantePunto2[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_bruto[i].A * dcn.RASANTE ./ s_bruto[i].proyeccion * p2[r][j,:] .+ altura[j] .<= s_bruto[i].b * dcn.RASANTE ./ s_bruto[i].proyeccion .+ 500 * (1 - w2[j,i]) .+ 500 * (1 - d[r])
    restRasantePunto3[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_bruto[i].A * dcn.RASANTE ./ s_bruto[i].proyeccion * p3[r][j,:] .+ altura[j] .<= s_bruto[i].b * dcn.RASANTE ./ s_bruto[i].proyeccion .+ 500 * (1 - w3[j,i]) .+ 500 * (1 - d[r])
    restRasantePunto4[j = 1:NumCeldas, i = 1:numNonConv, r = 1:numLados], s_bruto[i].A * dcn.RASANTE ./ s_bruto[i].proyeccion * p4[r][j,:] .+ altura[j] .<= s_bruto[i].b * dcn.RASANTE ./ s_bruto[i].proyeccion .+ 500 * (1 - w4[j,i]) .+ 500 * (1 - d[r])
    [j = 1:NumCeldas], sum(w1[j,:]) == 1
    [j = 1:NumCeldas], sum(w2[j,:]) == 1
    [j = 1:NumCeldas], sum(w3[j,:]) == 1
    [j = 1:NumCeldas], sum(w4[j,:]) == 1

# Restricción de Ancho máximo
    [r = 1:numLados], largo_x[:,r] .<= dca.ANCHOMAX .+ flagConfHor' * 500
    [r = 1:numLados], largo_y[:,r] .<= dca.ANCHOMAX .+ flagConfVert' * 500
    [r = 1:numLados], largo_x[:,r] .>= dca.ANCHOMAX * celdasConfig' .- 500 * (1 - d[r])
    [r = 1:numLados], largo_y[:,r] .>= dca.ANCHOMAX * celdasConfig' .- 500 * (1 - d[r])
    [r = 1:numLados], largo_x[:,r] .<= celdasConfig' * 500
    [r = 1:numLados], largo_y[:,r] .<= celdasConfig' * 500
    [r = 1:numLados], largo_x[:,r] .<= d[r] * 500
    [r = 1:numLados], largo_y[:,r] .<= d[r] * 500

# Restricciones de No Interesección de Celdas
    [r = 1:numLados], pos_x[2] + largo_x[2,r] <= pos_x[3]
    [r = 1:numLados], pos_x[3] + largo_x[3,r] <= pos_x[4]
    [r = 1:numLados], pos_y[2] + largo_y[2,r] <= pos_y[1]
    [r = 1:numLados], pos_y[3] + largo_y[3,r] <= pos_y[1]
    [r = 1:numLados], pos_y[4] + largo_y[4,r] <= pos_y[1]
    [r = 1:numLados], pos_y[5] + largo_y[5,r] <= pos_y[2]
    [r = 1:numLados], pos_y[5] + largo_y[5,r] <= pos_y[3]
    [r = 1:numLados], pos_y[5] + largo_y[5,r] <= pos_y[4]

# Restricciones de Rentabilidad Mínima
    restRentabilidadMin, IngresosVentas >= 1.20 * CostoTotal

# Restricciones que obligan a elegir una configuración y una rotación
    sum(configSel) == 1
    sum(d) == 1

# Restricción Suma de Departamentos menor a Máximo Número de Departamentos
    RestDensidadMax, sum(numDeptosTipo) <= maxDeptos

# Restricciones de Demanda
    RestDemanda, numDeptosTipo .<= maxDeptos .* dcc.MAXPORCTIPODEPTO

# Restricciones Auxiliares
    largo .<= celdasConfig' * 500
    largo .<= sum(largo_x, dims = 2) .+ flagConfVert' * 500
    largo .<= sum(largo_y, dims = 2) .+ flagConfHor' * 500

# Restricciones de Testeo
    #numDeptosTipo[1:end-1] .== 0; #Sólo deptos tipo 4
    #sum(configSel[1:2]) == 0  #Elimina configuraciones con 3 naves
    

end)


##############################################
# PARTE "7": FUNCIÓN OBJETIVO Y EJECUCIÓN    #
##############################################

@objective(m, Max, CostoUnitTerreno)
#@objective(m, Max, sum(numDeptosTipo))
#@objective(m, Max, IngresosVentas-CostoTotal)

# Resuelve el problema de optimización
JuMP.optimize!(m)


##############################################
# PARTE "8": PRESENTACION DE RESULTADOS      #
##############################################

# Cálculo del Flujo de Caja y la Tir
fl_IngresosVentas = dcf.IngresosVentas .* JuMP.value(IngresosVentas);
fl_CostoTerreno = dcf.CostoTerreno .* JuMP.value(CostoTerreno);
fl_CostoConstruccion = dcf.CostoConstruccion .* JuMP.value(CostoConstruccion);
fl_CostoHonorariosProyectos = dcf.CostoHonorariosProyectos .* JuMP.value(CostoHonorariosProyectos);
fl_CostoVenta = dcf.CostoVenta .* JuMP.value(CostoVenta);
fl_CostoInmobiliarioObra = dcf.CostoInmobiliarioObra .* JuMP.value(CostoInmobiliarioObra);
fl_CostosHabilitacion = dcf.CostosHabilitacion .* CostosHabilitacion;
fl_CostosPuestaEnMarcha = dcf.CostosPuestaEnMarcha .* CostosPuestaEnMarcha;
fl_CostosAtencionCliente = dcf.CostosAtencionCliente .* JuMP.value(CostosAtencionCliente);
fl_Imprevistos = dcf.Imprevistos .* JuMP.value(Imprevistos);
fl_CostoPagoIVA = fl_IngresosVentas .* (1 - JuMP.value(CostoTerreno) / sum(fl_IngresosVentas)) .* (0.19 / 1.19) -
                (fl_CostoConstruccion + fl_CostoVenta + fl_CostosHabilitacion) .* (0.19 / 1.19);
fl_FlujoCajaNetoAntesImpuesto = fl_IngresosVentas - fl_CostoTerreno - fl_CostoConstruccion - fl_CostoHonorariosProyectos - fl_CostoVenta -
                            fl_CostoInmobiliarioObra - fl_CostosHabilitacion - fl_CostosPuestaEnMarcha - fl_CostosAtencionCliente -
                            fl_Imprevistos - fl_CostoPagoIVA;
tirAntesImpuesto = (irr(fl_FlujoCajaNetoAntesImpuesto) + 1)^2 - 1;

numFlujos = length(fl_FlujoCajaNetoAntesImpuesto);
fl_FlujoCajaNetoAntesImpuestos_acum = cumsum(fl_FlujoCajaNetoAntesImpuesto);
vecCorrel = 1:numFlujos;
flag = cumsum(fl_FlujoCajaNetoAntesImpuestos_acum .> 0) .== 1;
flagCorrel = vecCorrel .* flag;
posNoNeg = findall(x->x > 0, flagCorrel)
fl_ImpuestoRenta = zeros(Float64, (numFlujos,));
fl_ImpuestoRenta[posNoNeg] = fl_FlujoCajaNetoAntesImpuestos_acum[posNoNeg] * dcf.TasaImpuestoRenta;
fl_FlujoCajaNetoDespuesImpuesto = fl_FlujoCajaNetoAntesImpuesto - fl_ImpuestoRenta;
tirDespuesImpuesto = (irr(fl_FlujoCajaNetoDespuesImpuesto) + 1)^2 - 1;

fl_LineaCredito = (dcf.ingresoLineaCredito - dcf.pagoLineaCredito) * JuMP.value(CostoConstruccion);
fl_MontoUtilizadoLineaCredito = cumsum(fl_LineaCredito);
fl_InteresLineaCredito = fl_MontoUtilizadoLineaCredito * dcf.TasaInteresLineaCredito / 2;
fl_CostoOperacionalCredito = fl_CostoConstruccion ./ sum(fl_CostoConstruccion) * dcf.DuracionLineaCredito * dcf.Tasaciones;
fl_FlujoCajaApalancadoNetoAntesImpuesto = fl_FlujoCajaNetoAntesImpuesto + fl_LineaCredito - fl_InteresLineaCredito - fl_CostoOperacionalCredito;
tirApalancadoAntesImpuestos = (irr(fl_FlujoCajaApalancadoNetoAntesImpuesto) + 1)^2 - 1;


# Construye estructura con los resultados de la optimización   
sn = salidaNormativa(
    maxDeptos, # maxNumDeptos
    dcn.COEFOCUPACION * superficieTerreno, # maxOcupacion
    superficieTerreno * dcn.COEFCONSTRUCTIBILIDAD * (1 + 0.3 * dcp.FUSIONTERRENOS), # maxConstructibilidad
    dcn.MAXPISOS, # maxPisos
    dcn.ALTURAMAX, # maxAltura
    JuMP.value(estacionamientosVendibles), # minEstacionamientosVendible
    JuMP.value(estacionamientosVisitas), # minEstacionamientosVisita
    estacionamientosDiscapacitados # minEstacionamientosDiscapacitados
)

sa = salidaArquitectonica(
    JuMP.value.(numDeptosTipo), #numDeptosTipo
    sum(JuMP.value.(numDeptosTipo)), #numDeptos
    maximum(JuMP.value.(areaBasal)), #ocupacion
    sum(JuMP.value.(areaBasal)), #constructibilidad
    maximum(cumsum(JuMP.value.(pisoActivoCeldas),dims=2)), #numPisos
    maximum(JuMP.value.(altura)), #altura
    JuMP.value(superficieVendible), #superficieUtilSNT
    JuMP.value(superficieComun), #superficieComunSNT
    JuMP.value(superficieVendible)+JuMP.value(superficieComun), #superficieEdificadaSNT
    sort(JuMP.value.(areaBasal), rev=true), #superficiePorPiso
    JuMP.value(estacionamientosVendibles), #estacionamientosVendibles
    JuMP.value(estacionamientosVisitas), #estacionamientosVisita
    JuMP.value(estacionamientosVendibles)+JuMP.value(estacionamientosVisitas), #numEstacionamientos
    JuMP.value(estacionamientosBicicletas) #numBicicleteros
    )

si = salidaIndicadores( 
    JuMP.value(IngresosVentas), #IngresosVentas
    JuMP.value(CostoTotal), #CostoTotal
    JuMP.value(IngresosVentas)-JuMP.value(CostoTotal), #MargenAntesImpuesto
    tirAntesImpuesto, #TirAntesImpuestos
    dcf.TasaImpuestoRenta*(JuMP.value(IngresosVentas)-JuMP.value(CostoTotal)), #ImpuestoRenta
    JuMP.value(IngresosVentas)-JuMP.value(CostoTotal) - dcf.TasaImpuestoRenta*(JuMP.value(IngresosVentas)-JuMP.value(CostoTotal)), #UtilidadDespuesImpuesto
    (JuMP.value(IngresosVentas)-JuMP.value(CostoTotal))/JuMP.value(CostoTotal), #RentabilidadTotalBruta
    (JuMP.value(IngresosVentas)-JuMP.value(CostoTotal) - dcf.TasaImpuestoRenta*(JuMP.value(IngresosVentas)-JuMP.value(CostoTotal)))/JuMP.value(CostoTotal), #RentabilidadTotalNeta
    JuMP.value(CostoTerreno)/JuMP.value(IngresosVentas), #IncidenciaTerreno
)

st = salidaTerreno( 
    superficieTerreno, #superficieTerreno
    polyArea(V_bruto), #superficieBruta
    polyArea(V_areaEdif), #superficieEdificacion
    JuMP.value(CostoUnitTerreno * superficieTerreno), #costoTerrenoAntesCorr
    JuMP.value(CostoUnitTerreno), #costoUnitTerrenoAntesCorr
    JuMP.value(CostoUnitTerreno * superficieTerreno * dcu.ComisionCorredor), #CostoCorredor
    JuMP.value(CostoTerreno), #costoTerreno
    JuMP.value(CostoTerreno)/superficieTerreno #costoUnitTerreno
)

sm = salidaMonetaria( 
    JuMP.value(IngresosVentas), #IngresosVentas
    JuMP.value(CostoTotal), #CostoTotal
    JuMP.value(CostoTerreno), #CostoTerreno
    JuMP.value(CostoTerreno)/superficieTerreno, #CostoUnitarioTerreno
    JuMP.value(CostoConstruccion), #CostoConstruccion
    JuMP.value(CostoHonorariosProyectos), #CostoHonorariosProyectos
    JuMP.value(CostoVenta), #CostoVenta
    JuMP.value(CostoInmobiliarioObra), #CostoInmobiliarioObra
    (CostosHabilitacion), #CostosHabilitacion
    (CostosPuestaEnMarcha), #CostosPuestaEnMarcha
    JuMP.value(CostosAtencionCliente), #CostosAtencionCliente
    JuMP.value(Imprevistos), #Imprevistos
    JuMP.value(CostoPagoIVA) #CostoPagoIVA
)

sf = salidaFlujoCaja( 
    fl_IngresosVentas, #IngresosVentas
    fl_CostoTerreno, #CostoTerreno
    fl_CostoConstruccion, #CostoConstruccion
    fl_CostoHonorariosProyectos, #CostoHonorariosProyectos
    fl_CostoVenta, #CostoVenta
    fl_CostoInmobiliarioObra, #CostoInmobiliarioObra
    fl_CostosHabilitacion, #CostosHabilitacion
    fl_CostosPuestaEnMarcha, #CostosPuestaEnMarcha
    fl_CostosAtencionCliente, #CostosAtencionCliente
    fl_Imprevistos, #Imprevistos
    fl_CostoPagoIVA, #CostoPagoIVA
    fl_FlujoCajaNetoAntesImpuesto, #flujoCajaNetoAntesImpuestos
    tirAntesImpuesto, #TirAntesImpuestos
    fl_ImpuestoRenta, #ImpuestoRenta
    fl_FlujoCajaNetoDespuesImpuesto, #NetoDespuesImpuestos
    tirDespuesImpuesto, #TirDespuesImpuestos
    fl_LineaCredito, #LineaCredito
    fl_MontoUtilizadoLineaCredito, #MontoUtilizadoLineaCredito
    fl_InteresLineaCredito, #InteresLineaCredito
    fl_CostoOperacionalCredito, #CostoOperacionalCredito
    fl_FlujoCajaApalancadoNetoAntesImpuesto, #ApalancadoNetoAntesImpuesto
    tirApalancadoAntesImpuestos #TirApalancadoAntesImpuestos
)

vecPosNumLado = collect(1:numLados);
r_opt = Int(round(vecPosNumLado' * JuMP.value.(d)));
p1_vec = (R[r_opt].mat * ([pos_x'; pos_y'] - repeat(R[r_opt].cr, 1, NumCeldas)) + repeat(R[r_opt].cr, 1, NumCeldas))';
p2_vec = (R[r_opt].mat * ([pos_x' + largo_x[:,r_opt]';pos_y'] - repeat(R[r_opt].cr, 1, NumCeldas)) + repeat(R[r_opt].cr, 1, NumCeldas))';
p3_vec = (R[r_opt].mat * ([pos_x' + largo_x[:,r_opt]';pos_y' + largo_y[:,r_opt]'] - repeat(R[r_opt].cr, 1, NumCeldas)) + repeat(R[r_opt].cr, 1, NumCeldas))';
p4_vec = (R[r_opt].mat * ([pos_x'; pos_y' + largo_y[:,r_opt]'] - repeat(R[r_opt].cr, 1, NumCeldas)) + repeat(R[r_opt].cr, 1, NumCeldas))';
sg = salidaGeometria( 
    JuMP.value.(configSel), #config
    vec(celdasConfig), #celdasConfig
    p1_vec, #p1
    p2_vec, #p2
    p3_vec, #p3
    p4_vec, #p4
    pos_x, #pos_x
    pos_y, #pos_y
    JuMP.value.(largo) #largo
);

println("Características Generales de la Cabida Óptima:")
println("----------------------------------------------")
println("N° Deptos: ", sum(round.(sa.numDeptosTipo)' .- round.([.6 .3 .1 0]*(sum(round.(sa.numDeptosTipo))-sum(sa.numDeptosTipo)))), " (Máx. Densidad = ", round(Int, sn.maxNumDeptos), ")")
println("N° Deptos por Tipo: ", round.(sa.numDeptosTipo)' .- round.([.6 .3 .1 0]*(sum(round.(sa.numDeptosTipo))-sum(sa.numDeptosTipo))))
println("Ocupacion: ", round(sa.ocupacion, digits=2), " m2 (Máx. Ocupación = ", round(sn.maxOcupacion, digits=2), " m2)")
println("Constructibilidad: ", round(sa.constructibilidad, digits=2), " m2 (Máx. Constructibilidad = ", round(sn.maxConstructibilidad, digits=2), " m2)")
println("N° Pisos: ", Int(round(sa.numPisos)), " (Máx. Pisos = ", Int(sn.maxPisos), ")")
println("Altura: ", round(sa.altura, digits=2), " m2 (Máx. Altura = ", round(sn.maxAltura, digits=2), " m2)")
println("Superficie Útil SNT: ", round(sa.superficieUtilSNT, digits=2), " m2")
println("Superficie Común SNT: ", round(sa.superficieComunSNT, digits=2), " m2")
println("Superficie Edificada SNT: ", round(sa.superficieEdificadaSNT, digits=2), " m2")
println("Superficie por Piso: ", round.(sa.superficiePorPiso, digits=2))
println("N° Estac. Vendibles: ", round(Int, sa.estacionamientosVendibles))
println("N° Estac. Visita: ", round(Int, sa.estacionamientosVisita))
println("N° Estac. Discapacitados: ", round(Int, sn.minEstacionamientosDiscapacitados))
println("N° Estac. Totales: ", round(Int, sa.estacionamientosVendibles) + round(Int, sa.estacionamientosVisita) + round(Int, sn.minEstacionamientosDiscapacitados))
println("N° Estac. Bicicletas: ", round(Int, sa.numBicicleteros))

println("")
println("Características del Terreno:")
println("----------------------------")
println("Superficie Terreno: ", round(st.superficieTerreno, digits=2), " m2")
println("Superficie Bruta: ", round(st.superficieBruta, digits=2), " m2")
println("Superficie Edificacion: ", round(st.superficieEdificacion, digits=2), " m2")
println("Costo Terreno antes Corredor: UF ", round(st.costoTerrenoAntesCorr, digits=2), " (", round(st.costoUnitTerrenoAntesCorr, digits=2), " UF/m2)")
println("Costo Corredor: UF ", round(st.CostoCorredor, digits=2), (" (IVA Inc.)"))
println("Costo Total Terreno: UF ", round(st.costoTerreno, digits=2), " (", round(st.costoUnitTerreno, digits=2), " UF/m2)")

println("")
println("Indicadores de Desempeño:")
println("-------------------------")
println("Ingresos por Ventas: UF ", round(si.IngresosVentas, digits=2))
println("Costo Total: UF ", round(si.CostoTotal, digits=2))
println("Margen antes de Impuesto: UF ", round(si.MargenAntesImpuesto, digits=2))
println("Rentabilidad Total Bruta: UF+ ", round(si.RentabilidadTotalBruta, digits=2)*100," %")
println("TIR antes Impuestos: UF+ ", round(si.TirAntesImpuestos, digits=2)*100," %")
println("Impuesto Renta: UF ", round(si.ImpuestoRenta, digits=2))
println("Utilidad después Impuesto: UF ", round(si.UtilidadDespuesImpuesto, digits=2))
println("Rentabilidad Total Neta: UF+ ", round(si.RentabilidadTotalNeta, digits=2)*100," %")
println("Incidencia Terreno: ", round(si.IncidenciaTerreno, digits=2))

# Grafica Predio
ps_predio = PolyShape([V_predio],1) 
fig, ax, ax_mat = plotPolyshape3d_v2(ps_predio, 0, nothing, nothing, nothing, "green", 0.25)

# Grafica cabida óptima
vecPosNumCeldas = collect(1:NumCeldas);
celdasConfig = JuMP.value.(configSel)' * MATCELDASCONF;
setCeldasActivas = [i for i in Int.(round.(vecPosNumCeldas' .* celdasConfig)) if i >= 1]
fig, ax, ax_mat = plotCabidaOptima(setCeldasActivas, JuMP.value.(pisoActivoCeldas), JuMP.value.(pos_x), JuMP.value.(pos_y), JuMP.value.(largo_x), JuMP.value.(largo_y), R, r_opt, dca, fig, ax, ax_mat)

# Grafica Volumen Teórico
ps_volteor = PolyShape([V_volteor],1)
fig, ax, ax_mat = plotPolyshape3d_v2(ps_volteor, nothing, fig, ax, ax_mat, "grey", 0.25)
