function generaSalidaEntera(dcn, dca, dcp, dcc, dcu, dcf, dcr, alturaEdif, ps_base, superficieTerreno, 
    superficieTerrenoBruta, numPisos, numDeptosTipo, CostoUnitTerreno, estacionamientosVisitas, estacionamientosVendibles, estacionamientosBicicletasMin,
    descuentoEstCercaniaMetro, descuentoEstBicicletas, cambioEstBicicletas)


    areaBasalPso = polyShape.polyArea_v2(ps_base)
    numTiposDepto = length(dcc.SUPDEPTOUTIL);
    superficieDensidad = dcn.FLAGDENSIDADBRUTA ? superficieTerrenoBruta : superficieTerreno
    maxDeptos = floor(dcn.DENSIDADMAX / 4 * superficieDensidad / 10000);
    numPisosMaxVol = Int(floor(alturaEdif / dca.ALTURAPISO))

     ##############################################
    # PARTE "5": EXPRESIONES AUXILIARES          #
    ##############################################

    # Cálculo Número de Estacionamientos
    estacionamientosViviendas = sum(dcn.ESTACIONAMIENTOSPORVIV .* numDeptosTipo)     
    estacionamientosNormales = estacionamientosViviendas + estacionamientosVisitas
    estacionamientosDiscapacitados = (maxDeptos <= 20) ? 1 : 
                                     ((maxDeptos <= 50) ? 2 : 
                                     ((maxDeptos <= 200) ? 3 : 
                                     ((maxDeptos <= 400) ? 4 : 
                                     ((maxDeptos <= 500) ? 5 : (0.01*maxDeptos)))))
    estacionamientosVendiblesDesc = estacionamientosViviendas - descuentoEstCercaniaMetro - descuentoEstBicicletas
    estacionamientosBicicletas = estacionamientosBicicletasMin + cambioEstBicicletas * dcn.BICICLETASPOREST    

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
    # PARTE "8": PRESENTACION DE RESULTADOS      #
    ##############################################

        # Construye estructura con los resultados de la optimización   
    sn = salidaNormativa(
        maxDeptos, # maxNumDeptos
        dcn.COEFOCUPACION * superficieTerreno, # maxOcupacion
        superficieTerreno * dcn.COEFCONSTRUCTIBILIDAD * (1 + 0.3 * dcp.FUSIONTERRENOS), # maxConstructibilidad
        dcn.MAXPISOS, # maxPisos
        dcn.ALTURAMAX, # maxAltura
        ceil(JuMP.value(estacionamientosVendibles)), # minEstacionamientosVendible
        ceil(JuMP.value(estacionamientosVisitas)), # minEstacionamientosVisita
        ceil(estacionamientosDiscapacitados) # minEstacionamientosDiscapacitados
    )

    sa = salidaArquitectonica(
        JuMP.value.(numDeptosTipo), # numDeptosTipo
        sum(JuMP.value.(numDeptosTipo)), # numDeptos
        areaBasalPso, # ocupacion
        JuMP.value(superficieUtil), # constructibilidad
        JuMP.value(numPisos), # numPisos
        JuMP.value(numPisos) * dca.ALTURAPISO, # altura
        JuMP.value(superficieVendible), # superficieUtilSNT
        JuMP.value(superficieComun), # superficieComunSNT
        JuMP.value(superficieVendible) + JuMP.value(superficieComun), # superficieEdificadaSNT
        (JuMP.value(superficieVendible) + JuMP.value(superficieComun)) / JuMP.value(numPisos), # superficiePorPiso
        JuMP.value(estacionamientosVendibles), # estacionamientosVendibles
        JuMP.value(estacionamientosVisitas), # estacionamientosVisita
        JuMP.value(estacionamientosVendibles) + JuMP.value(estacionamientosVisitas), # numEstacionamientos Totales
        JuMP.value(estacionamientosBicicletas), # numBicicleteros
        JuMP.value(descuentoEstBicicletas), #descuentoEstBicicletas
        JuMP.value(cambioEstBicicletas), #cambioEstBicicletas
        JuMP.value(descuentoEstCercaniaMetro) #descuentoEstCercaniaMetro
    )


    st = salidaTerreno( 
        superficieTerreno, # superficieTerreno
        superficieTerrenoBruta, # superficieBruta
        0, # superficieEdificacion
        JuMP.value(CostoUnitTerreno * superficieTerreno), # costoTerrenoAntesCorr
        JuMP.value(CostoUnitTerreno), # costoUnitTerrenoAntesCorr
        JuMP.value(CostoUnitTerreno * superficieTerreno * dcu.ComisionCorredor), # CostoCorredor
        JuMP.value(CostoTerreno), # costoTerreno
        JuMP.value(CostoTerreno) / superficieTerreno # costoUnitTerreno
    )

    so = salidaOptimizacion(
        superficieTerreno * dcn.COEFOCUPACION - areaBasalPso,
        superficieTerreno * dcn.COEFCONSTRUCTIBILIDAD * (1 + 0.3 * dcp.FUSIONTERRENOS) - JuMP.value(superficieUtil), # dualMaxConstructibilidad
        maxDeptos - sum(JuMP.value.(numDeptosTipo)), # dualMaxDensidad
    )

    sm = salidaMonetaria( 
        JuMP.value(IngresosVentas), # IngresosVentas
        JuMP.value(CostoTotal), # CostoTotal
        JuMP.value(CostoTerreno), # CostoTerreno
        JuMP.value(CostoTerreno) / superficieTerreno, # CostoUnitarioTerreno
        JuMP.value(CostoConstruccion), # CostoConstruccion
        JuMP.value(CostoHonorariosProyectos), # CostoHonorariosProyectos
        JuMP.value(CostoVenta), # CostoVenta
        JuMP.value(CostoInmobiliarioObra), # CostoInmobiliarioObra
        (CostosHabilitacion), # CostosHabilitacion
        (CostosPuestaEnMarcha), # CostosPuestaEnMarcha
        JuMP.value(CostosAtencionCliente), # CostosAtencionCliente
        JuMP.value(Imprevistos), # Imprevistos
        JuMP.value(CostoPagoIVA) # CostoPagoIVA
    )


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
    tirAntesImpuesto = (NPFinancial.irr(fl_FlujoCajaNetoAntesImpuesto) + 1)^2 - 1;
    
    numFlujos = length(fl_FlujoCajaNetoAntesImpuesto);
    fl_FlujoCajaNetoAntesImpuestos_acum = cumsum(fl_FlujoCajaNetoAntesImpuesto);
    vecCorrel = 1:numFlujos;
    flag = cumsum(fl_FlujoCajaNetoAntesImpuestos_acum .> 0) .== 1;
    flagCorrel = vecCorrel .* flag;
    posNoNeg = findall(x -> x > 0, flagCorrel)
    fl_ImpuestoRenta = zeros(Float64, (numFlujos,));
    fl_ImpuestoRenta[posNoNeg] = fl_FlujoCajaNetoAntesImpuestos_acum[posNoNeg] * dcf.TasaImpuestoRenta;
    fl_FlujoCajaNetoDespuesImpuesto = fl_FlujoCajaNetoAntesImpuesto - fl_ImpuestoRenta;
    tirDespuesImpuesto = (NPFinancial.irr(fl_FlujoCajaNetoDespuesImpuesto) + 1)^2 - 1;
    
    fl_LineaCredito = (dcf.ingresoLineaCredito - dcf.pagoLineaCredito) * JuMP.value(CostoConstruccion);
    fl_MontoUtilizadoLineaCredito = cumsum(fl_LineaCredito);
    fl_InteresLineaCredito = fl_MontoUtilizadoLineaCredito * dcf.TasaInteresLineaCredito / 2;
    fl_CostoOperacionalCredito = fl_CostoConstruccion ./ sum(fl_CostoConstruccion) * dcf.DuracionLineaCredito * dcf.Tasaciones;
    fl_FlujoCajaApalancadoNetoAntesImpuesto = fl_FlujoCajaNetoAntesImpuesto + fl_LineaCredito - fl_InteresLineaCredito - fl_CostoOperacionalCredito;
    tirApalancadoAntesImpuestos = (NPFinancial.irr(fl_FlujoCajaApalancadoNetoAntesImpuesto) + 1)^2 - 1;
    

    sf = salidaFlujoCaja( 
        fl_IngresosVentas, # IngresosVentas
        fl_CostoTerreno, # CostoTerreno
        fl_CostoConstruccion, # CostoConstruccion
        fl_CostoHonorariosProyectos, # CostoHonorariosProyectos
        fl_CostoVenta, # CostoVenta
        fl_CostoInmobiliarioObra, # CostoInmobiliarioObra
        fl_CostosHabilitacion, # CostosHabilitacion
        fl_CostosPuestaEnMarcha, # CostosPuestaEnMarcha
        fl_CostosAtencionCliente, # CostosAtencionCliente
        fl_Imprevistos, # Imprevistos
        fl_CostoPagoIVA, # CostoPagoIVA
        fl_FlujoCajaNetoAntesImpuesto, # flujoCajaNetoAntesImpuestos
        tirAntesImpuesto, # TirAntesImpuestos
        fl_ImpuestoRenta, # ImpuestoRenta
        fl_FlujoCajaNetoDespuesImpuesto, # NetoDespuesImpuestos
        tirDespuesImpuesto, # TirDespuesImpuestos
        fl_LineaCredito, # LineaCredito
        fl_MontoUtilizadoLineaCredito, # MontoUtilizadoLineaCredito
        fl_InteresLineaCredito, # InteresLineaCredito
        fl_CostoOperacionalCredito, # CostoOperacionalCredito
        fl_FlujoCajaApalancadoNetoAntesImpuesto, # ApalancadoNetoAntesImpuesto
        tirApalancadoAntesImpuestos # TirApalancadoAntesImpuestos
    )
        
    si = salidaIndicadores( 
        JuMP.value(IngresosVentas), # IngresosVentas
        JuMP.value(CostoTotal), # CostoTotal
        JuMP.value(IngresosVentas) - JuMP.value(CostoTotal), # MargenAntesImpuesto
        tirAntesImpuesto, # TirAntesImpuestos
        dcf.TasaImpuestoRenta * (JuMP.value(IngresosVentas) - JuMP.value(CostoTotal)), # ImpuestoRenta
        JuMP.value(IngresosVentas) - JuMP.value(CostoTotal) - dcf.TasaImpuestoRenta * (JuMP.value(IngresosVentas) - JuMP.value(CostoTotal)), # UtilidadDespuesImpuesto
        (JuMP.value(IngresosVentas) - JuMP.value(CostoTotal)) / JuMP.value(CostoTotal), # RentabilidadTotalBruta
        (JuMP.value(IngresosVentas) - JuMP.value(CostoTotal) - dcf.TasaImpuestoRenta * (JuMP.value(IngresosVentas) - JuMP.value(CostoTotal))) / JuMP.value(CostoTotal), # RentabilidadTotalNeta
        JuMP.value(CostoTerreno) / JuMP.value(IngresosVentas), # IncidenciaTerreno
    )

    return sn, sa, si, st, so, sm, sf

end
