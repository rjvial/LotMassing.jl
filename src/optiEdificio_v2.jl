function optiEdificio_v2(dcn, dca, dcp, dcc, dcu, dcf, dcr, alturaEdif, ps_base, superficieTerreno, superficieTerrenoBruta)

    areaBasalPso = polyShape.polyArea_v2(ps_base)
    numTiposDepto = length(dcc.SUPDEPTOUTIL);
    superficieDensidad = dcn.FLAGDENSIDADBRUTA ? superficieTerrenoBruta : superficieTerreno
    maxDeptos = dcn.DENSIDADMAX / 4 * superficieDensidad / 10000;
    numPisosMaxVol = Int(floor(alturaEdif / dca.ALTURAPISO))
    

    ##############################################
    # PARTE "3": DEFINICIÓN SOLVER               #
    ##############################################

    #m = Model(Cbc.Optimizer)
    #set_optimizer_attribute(m, "ratioGap", 0.001)
    #set_optimizer_attribute(m, "threads", 3)
    

    m = Model(GAMS.Optimizer)
    set_optimizer_attribute(m, "OptCR", 0.001)
    set_optimizer_attribute(m, "Threads", 3)
    set_optimizer_attribute(m, "logOption", 0)


    ##############################################
    # PARTE "4": VARIABLES DE DECISION           #
    ##############################################

    @variables(m, begin
        0 <= numPisos <= dcn.MAXPISOS, Int
        0 <= numDeptosTipo[u = 1:numTiposDepto], Int
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
    cambioEstBicicletas = dcn.FLAGCAMBIOESTPORBICICLETA ? estacionamientosNormales / 3 : 0
    estacionamientosVendibles = estacionamientosViviendas - descuentoEstCercaniaMetro - descuentoEstBicicletas - cambioEstBicicletas
    estacionamientosBicicletas = estacionamientosBicicletas + cambioEstBicicletas * dcn.BICICLETASPOREST
    estacionamientos = estacionamientosVendibles + estacionamientosVisitas + estacionamientosBicicletas / dcn.BICICLETASPOREST;
    

    # Cálculo de Superficies
    superficieUtilDepto = numDeptosTipo .* dcc.SUPDEPTOUTIL;
    superficieUtil = sum(superficieUtilDepto);
    superficieTerrazaDepto = 2 .* superficieUtilDepto .* dca.PORCTERRAZA;
    superficieInteriorDepto = superficieUtilDepto .* (1 - dca.PORCTERRAZA);
    superficieVendibleDepto = superficieInteriorDepto + .5 * superficieTerrazaDepto; # = superficieUtilDepto
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
    CostoConstruccionSNT = dcu.LosaSNT * superficieLosaSNT; # Costos con IVA
    CostoConstruccionBNT = dcu.LosaBNT * superficieLosaBNT; # Costos con IVA
    CostoEstacVisita = dcu.EstacVisita * dcn.SUPPORESTACIONAMIENTO * estacionamientosVisitas; # Costos con IVA
    devolucionIVA = (CostoConstruccionSNT + CostoConstruccionBNT + CostoEstacVisita) / 1.19 * 0.19 * 0.65; # Divide por 1.19 para dejar en base sin IVA
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
    DebitoIVA = (IngresosVentas - CostoTerreno) / 1.19 * 0.19;
    CreditoIVA = (CostoConstruccion + CostoVenta + CostosHabilitacion) / 1.19 * 0.19;
    CostoPagoIVA = DebitoIVA - CreditoIVA;

    # Cálculo Costo Total
    CostoTotal = CostoTerreno + CostoConstruccion + CostoHonorariosProyectos + 
                 CostoVenta + CostoInmobiliarioObra + CostosHabilitacion +
                 CostosPuestaEnMarcha + CostosAtencionCliente + Imprevistos + CostoPagoIVA;



    ##############################################
    # PARTE "6": RESTRICCIONES DEL MIP           #
    ##############################################

    @constraints(m, begin
    # Restricción de Altura Máxima y Área Basal Máxima (Coeficiente de Ocupación)
        maxAltura, numPisos * dca.ALTURAPISO <= alturaEdif
        
    # Restricciones que establecen relaciones entre areaBasal, numDeptos, largo y ancho
        superficieLosaSNT <= areaBasalPso * numPisos
        maxConstructibilidad, superficieUtil <= superficieTerreno * dcn.COEFCONSTRUCTIBILIDAD * (1 + 0.3 * dcp.FUSIONTERRENOS)

    # Restricciones de Rentabilidad Mínima
        minRentabilidad, IngresosVentas >= dcr.RetornoExigido * CostoTotal

    # Restricción Suma de Departamentos menor a Máximo Número de Departamentos
        maxDensidad, sum(numDeptosTipo) <= maxDeptos

    # Restricciones de Demanda
        maxDemanda, numDeptosTipo .<= maxDeptos .* dcc.MAXPORCTIPODEPTO


    end)


    ##############################################
    # PARTE "7": FUNCIÓN OBJETIVO Y EJECUCIÓN    #
    ##############################################

    @objective(m, Max, CostoUnitTerreno)
    # @objective(m, Max, sum(numDeptosTipo))
    # @objective(m, Max, IngresosVentas-CostoTotal)

    # Resuelve el problema de optimización
    JuMP.optimize!(m)

    if termination_status(m) == MOI.OPTIMAL
        status = true
        sn, sa, si, st, so, sm, sf = generaSalidaEntera(dcn, dca, dcp, dcc, dcu, dcf, dcr, superficieTerreno, superficieTerrenoBruta, CostoUnitTerreno,
        areaBasalPso, superficieUtil, numPisos, maxDeptos, numDeptosTipo, superficieVendible, superficieComun, estacionamientosVendibles, 
        estacionamientosVisitas, estacionamientosDiscapacitados, estacionamientosBicicletas,
        IngresosVentas, CostoTotal, CostoTerreno, CostoConstruccion, CostoHonorariosProyectos, CostoVenta, CostoInmobiliarioObra, CostosHabilitacion, CostosPuestaEnMarcha,
        CostosAtencionCliente, CostoPagoIVA, Imprevistos)

    else
        status = false
        sn = nothing
        sa = nothing
        si = nothing
        st = nothing
        sm = nothing
        sf = nothing
    end

    return sn, sa, si, st, so, sm, sf, status  



end