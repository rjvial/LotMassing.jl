function displayResults(resultados)
    numStructures =length(resultados)
    sn = resultados[1]
    sa = resultados[2]
    si = resultados[3]
    st = resultados[4]
    so = resultados[5]
    sm = resultados[6]
    sf = resultados[7]
    
    displayResults(sn, sa, si, st, so, sm, sf)
end


function displayResults(sn, sa, si, st, so, sm, sf)

    println("Características Generales de la Cabida Óptima:")
    println("----------------------------------------------")
    println("N° Deptos: ", sum(round.(sa.numDeptosTipo, digits = 2)), " (Máx. Densidad = ", round(sn.maxNumDeptos, digits = 2), ")")
    println("N° Deptos por Tipo: ", floor.(sa.numDeptosTipo, digits = 2)')
    println("Ocupacion: ", round(sa.ocupacion, digits = 2), " m2 (Máx. Ocupación = ", round(sn.maxOcupacion, digits = 2), " m2)")
    println("Constructibilidad: ", round(sa.constructibilidad, digits = 2), " m2 (Máx. Constructibilidad = ", round(sn.maxConstructibilidad, digits = 2), " m2)")
    println("N° Pisos: ", round(sa.numPisos, digits = 2), " (Máx. Pisos = ", round(sn.maxPisos, digits = 2), ")")
    println("Altura: ", round(sa.altura, digits = 2), " m2 (Máx. Altura = ", round(sn.maxAltura, digits = 2), " m2)")
    println("Superficie Útil SNT: ", round(sa.superficieUtilSNT, digits = 2), " m2")
    println("Superficie Común SNT: ", round(sa.superficieComunSNT, digits = 2), " m2")
    println("Superficie Edificada SNT: ", round(sa.superficieEdificadaSNT, digits = 2), " m2")
    println("Superficie por Piso: ", round(sa.superficiePorPiso, digits = 2))
    println("N° Estac. Vendibles: ", round(sa.estacionamientosVendibles, digits = 2))
    println("N° Estac. Visita: ", round(sa.estacionamientosVisita, digits = 2))
    println("N° Estac. Discapacitados: ", round(sn.minEstacionamientosDiscapacitados, digits = 2))
    println("N° Estac. Totales: ", round(sa.estacionamientosVendibles, digits = 2) + round(sa.estacionamientosVisita, digits = 2))
    println("N° Estac. Bicicletas: ", round(sa.numBicicleteros, digits = 2))
    println("N° Estac. a Descontar por Bicicletas: ", round(sa.descuentoEstBicicletas, digits = 2)) #descuentoEstBicicletas
    println("N° Estac. a Cambiar por Bicicletas: ", round(sa.cambioEstBicicletas, digits = 2)) #cambioEstBicicletas
    println("N° Estac. a Descontar por Cercanía Metro: ", round(sa.descuentoEstCercaniaMetro, digits = 2)) #descuentoEstCercaniaMetro

    println("")
    println(" Análisis de Holguras:")
    println("----------------------------------------------")
    println(" Rest. Coef. Ocupación: ", round(so.dualMaxOcupación, digits = 2), " m2")
    println(" Rest. Constructibilidad Máxima: ", round(so.dualMaxConstructibilidad, digits = 2), " m2")
    println(" Rest. Densidad Máxima: ", round(so.dualMaxDensidad, digits = 2), " unidades")

    println("")
    println("Características del Terreno:")
    println("----------------------------")
    println("Superficie Terreno: ", round(st.superficieTerreno, digits = 2), " m2")
    println("Superficie Bruta: ", round(st.superficieBruta, digits = 2), " m2")
    println("Costo Terreno antes Corredor: UF ", round(st.costoTerrenoAntesCorr, digits = 2), " (", round(st.costoUnitTerrenoAntesCorr, digits = 2), " UF/m2)")
    println("Costo Corredor: UF ", round(st.CostoCorredor, digits = 2), (" (IVA Inc.)"))
    println("Costo Total Terreno: UF ", round(st.costoTerreno, digits = 2), " (", round(st.costoUnitTerreno, digits = 2), " UF/m2)")

    println("")
    println("Indicadores de Desempeño:")
    println("-------------------------")
    println("Ingresos por Ventas: UF ", round(si.IngresosVentas, digits = 2))
    println("Costo Total: UF ", round(si.CostoTotal, digits = 2))
    println("Margen antes de Impuesto: UF ", round(si.MargenAntesImpuesto, digits = 2))
    println("Rentabilidad Total Bruta: UF+ ", round(si.RentabilidadTotalBruta, digits = 2) * 100," %")
    println("TIR antes Impuestos: UF+ ", round(si.TirAntesImpuestos, digits = 2) * 100," %")
    println("Impuesto Renta: UF ", round(si.ImpuestoRenta, digits = 2))
    println("Utilidad después Impuesto: UF ", round(si.UtilidadDespuesImpuesto, digits = 2))
    println("Rentabilidad Total Neta: UF+ ", round(si.RentabilidadTotalNeta, digits = 2) * 100," %")
    println("Incidencia Terreno: ", round(si.IncidenciaTerreno, digits = 2))


end