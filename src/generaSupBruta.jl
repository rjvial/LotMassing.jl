function generaSupBruta(ps_predio, conjuntoLadosCalle, anchoEspacioPublico)

    ps_bruto = polyShape.polyExpandSides_v2(ps_predio, anchoEspacioPublico/2, conjuntoLadosCalle)
    ps_publico = polyShape.polyExpandSides_v2(ps_predio, anchoEspacioPublico, conjuntoLadosCalle)

    return ps_bruto, ps_publico
end

