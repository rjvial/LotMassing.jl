function displayResults(resultados)
    numStructures =length(resultados)
    sn = resultados[1]
    sa = resultados[2]
    si = resultados[3]
    st = resultados[4]
    sm = resultados[5]
    sf = resultados[6]
    
    displayResults(sn, sa, si, st, sm, sf)
end


function displayResults(sn, sa, si, st, sm, sf)

    println("Características Generales de la Cabida Óptima:")
    println("----------------------------------------------")
    println("N° Deptos: ", sum(floor.(sa.numDeptosTipo)), " (Máx. Densidad = ", round(Int, sn.maxNumDeptos), ")")
    println("N° Deptos por Tipo: ", floor.(sa.numDeptosTipo)')
    println("Ocupacion: ", round(sa.ocupacion, digits = 2), " m2 (Máx. Ocupación = ", round(sn.maxOcupacion, digits = 2), " m2)")
    println("Constructibilidad: ", round(sa.constructibilidad, digits = 2), " m2 (Máx. Constructibilidad = ", round(sn.maxConstructibilidad, digits = 2), " m2)")
    println("N° Pisos: ", Int(floor(sa.numPisos)), " (Máx. Pisos = ", Int(floor(sn.maxPisos)), ")")
    println("Altura: ", round(sa.altura, digits = 2), " m2 (Máx. Altura = ", round(sn.maxAltura, digits = 2), " m2)")
    println("Superficie Útil SNT: ", round(sa.superficieUtilSNT, digits = 2), " m2")
    println("Superficie Común SNT: ", round(sa.superficieComunSNT, digits = 2), " m2")
    println("Superficie Edificada SNT: ", round(sa.superficieEdificadaSNT, digits = 2), " m2")
    println("Superficie No Utilizada SNT: ", round(sa.superficieNoUtilizada, digits = 2), " m2")
    println("Superficie por Piso: ", round(sa.superficiePorPiso, digits = 2))
    println("N° Estac. Vendibles: ", round(Int, sa.estacionamientosVendibles))
    println("N° Estac. Visita: ", round(Int, sa.estacionamientosVisita))
    println("N° Estac. Discapacitados: ", round(Int, sn.minEstacionamientosDiscapacitados))
    println("N° Estac. Totales: ", round(Int, sa.estacionamientosVendibles) + round(Int, sa.estacionamientosVisita) + round(Int, sn.minEstacionamientosDiscapacitados))
    println("N° Estac. Bicicletas: ", round(Int, sa.numBicicleteros))

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