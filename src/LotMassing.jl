module LotMassing

using NPFinancial, JuMP, GAMS, Polyhedra, BlackBoxOptim, Random, ProgressMeter, Cbc


mutable struct RotInfo
    mat
    cr
    theta
end


mutable struct SubPoly
    points
    ladoComun
end


mutable struct PolyShape
    Vertices
    NumRegions
end

mutable struct FlagPlotEdif3D
    predio
    volTeor
    volRestSombra
    edif
    sombraVolTeor_p
    sombraVolTeor_o
    sombraVolTeor_s
    sombraEdif_p
    sombraEdif_o
    sombraEdif_s
    FlagPlotEdif3D() = new()
end

mutable struct ResultadoCabida
    SalidaNormativa
    SalidaArquitectonica
    SalidaIndicadores
    SalidaTerreno
    SalidaMonetaria
    SalidaOptimizacion
    SalidaFlujoCaja
    Xopt
end


mutable struct datosCabidaPredio
    x
    y
    ladosConCalle
    ANCHOESPACIOPUBLICO
    FUSIONTERRENOS
    DISTANCIAMETRO
end

mutable struct datosCabidaNormativa
    DISTANCIAMIENTO
    ANTEJARDIN
    RASANTE
    RASANTESOMBRA
    ALTURAMAX
    MAXPISOS
    COEFOCUPACION
    SUBPREDIALMIN
    DENSIDADMAX
    FLAGDENSIDADBRUTA
    COEFCONSTRUCTIBILIDAD
    ESTACIONAMIENTOSPORVIV
    PORCADICESTACVISITAS
    SUPPORESTACIONAMIENTO
    ESTBICICLETAPOREST
    BICICLETASPOREST
    FLAGCAMBIOESTPORBICICLETA
    MAXSUBTE
    COEFOCUPACIONEST
    SEPESTMIN
    REDUCCIONESTPORDISTMETRO
    datosCabidaNormativa() = new()
end

mutable struct datosCabidaArquitectura
    ALTURAPISO
    PORCSUPCOMUN
    PORCTERRAZA
    ANCHOMIN
    ANCHOMAX
    datosCabidaArquitectura() = new()
end

mutable struct datosCabidaComercial
    SUPDEPTOUTIL
    MAXPORCTIPODEPTO
    PRECIOVENTA
    PRECIOVENTAEST
end

mutable struct datosCabidaUnit
    duracionProyecto
    CostoTerreno
    ComisionCorredor
    Demolicion
    LosaSNT
    LosaBNT
    EstacVisita
    ExtrasPostVenta
    Arquitectura
    GestionAdministracion
    ITO # por mes
    Contabilidad # por mes
    Legales
    Calculo
    MecanicaSuelo
    Topografia
    ProyectoElectrico
    ProyectoSanitario
    ProyectoSeguridad
    ProyectoPavimentacion
    ProyectoBasura
    ProyectoCalefaccion   
    Marketing
    PilotSalaVentas
    NotarialesLegales
    CBR
    EmpalmesAportes
    DerechosPermisosMunicipales
    InspeccionCertificacionTecnica # por mes
    Contribuciones
    CopiaPlanosArquitctura
    CopiaPlanosObra
    HallAcceso
    JardinesPaisajismo
    HabilitacionSalaUsosMultiples
    HabilitacionPiscinaEnfermeria    
    CuentasServiciosDeptos
    GastosComunes
    ContribucionesDeptos
    Seguros
    ResponsabilidadCivil
    PostVentaInmobiliaria
    SeguroVentaEnVerde    
    Imprevistos
    datosCabidaUnit() = new()
end

# flujos corresponden a meses: 0 6 12 18 24 30
mutable struct datosCabidaFlujo
    IngresosVentas
    CostoTerreno
    CostoConstruccion
    CostoHonorariosProyectos
    CostoVenta
    CostoInmobiliarioObra
    CostosHabilitacion
    CostosPuestaEnMarcha
    CostosAtencionCliente
    Imprevistos
    ingresoLineaCredito
    pagoLineaCredito
    TasaImpuestoRenta
    TasaInteresLineaCredito
    DuracionLineaCredito
    Tasaciones
end

# Rentabilidad exigida
mutable struct datosCabidaRentabilidad
    RetornoExigido
end

struct salidaNormativa
    maxNumDeptos
    maxOcupacion
    maxConstructibilidad
    maxPisos
    maxAltura
    minEstacionamientosVendibles
    minEstacionamientosVisita
    minEstacionamientosDiscapacitados
end

struct salidaArquitectonica
    numDeptosTipo
    numDeptos
    ocupacion
    constructibilidad
    numPisos
    altura
    superficieUtilSNT
    superficieComunSNT
    superficieEdificadaSNT
    superficiePorPiso
    estacionamientosVendibles
    estacionamientosVisita
    numEstacionamientos
    numBicicleteros
end

struct salidaTerreno
    superficieTerreno
    superficieBruta
    superficieEdificacion
    costoTerrenoAntesCorr
    costoUnitTerrenoAntesCorr
    CostoCorredor
    costoTerreno
    costoUnitTerreno
end

struct salidaOptimizacion
    dualMaxOcupación
    dualMaxConstructibilidad
    dualMaxDensidad
end


struct salidaIndicadores
    IngresosVentas
    CostoTotal
    MargenAntesImpuesto
    TirAntesImpuestos
    ImpuestoRenta
    UtilidadDespuesImpuesto
    RentabilidadTotalBruta
    RentabilidadTotalNeta
    IncidenciaTerreno
end

struct salidaMonetaria
    IngresosVentas
    CostoTotal
    CostoTerreno
    CostoUnitarioTerreno
    CostoConstruccion
    CostoHonorariosProyectos
    CostoVenta
    CostoInmobiliarioObra
    CostosHabilitacion
    CostosPuestaEnMarcha
    CostosAtencionCliente
    Imprevistos
    CostoPagoIVA
end

struct salidaFlujoCaja
    IngresosVentas
    CostoTerreno
    CostoConstruccion
    CostoHonorariosProyectos
    CostoVenta
    CostoInmobiliarioObra
    CostosHabilitacion
    CostosPuestaEnMarcha
    CostosAtencionCliente
    Imprevistos
    CostoPagoIVA
    flujoCajaNetoAntesImpuestos
    TirAntesImpuestos
    ImpuestoRenta
    NetoDespuesImpuestos
    TirDespuesImpuestos
    LineaCredito
    MontoUtilizadoLineaCredito
    InteresLineaCredito
    CostoOperacionalCredito
    ApalancadoNetoAntesImpuesto
    TirApalancadoAntesImpuestos
end


export datosCabidaPredio, datosCabidaNormativa, datosCabidaArquitectura, datosCabidaComercial, datosCabidaUnit,
         datosCabidaFlujo, datosCabidaRentabilidad, SubPoly, salidaArquitectonica, salidaIndicadores, salidaMonetaria,
         salidaTerreno, salidaOptimizacion, salidaNormativa, salidaFlujoCaja, PolyShape, FlagPlotEdif3D,
         ResultadoCabida, RotInfo


include("infoPredio.jl")
include("calculaAnguloRotacion.jl")
include("generaCalles.jl")
include("generaSombraEdificio.jl")
include("optiEdificio.jl")
include("displayResults.jl")
include("plotBaseEdificio3d.jl")
include("poly2D.jl")
include("polyShape.jl")
include("evol.jl")
include("resultConverter.jl")
include("ejecutaCalculoCabidas.jl")
include("generaVol3d.jl")
include("generaSombraTeor.jl")
include("factorIgualaArea.jl")
include("generaSupBruta.jl")
include("pg_julia.jl")

export infoPredio, calculaAnguloRotacion,
       generaCalles, generaSombraEdificio, optiEdificio, displayResults, evol, poly2D, polyShape, 
       resultConverter, plotBaseEdificio3d, ejecutaCalculoCabidas, generaVol3d, generaSombraTeor, 
       generaSupBruta, factorIgualaArea, pg_julia
end
