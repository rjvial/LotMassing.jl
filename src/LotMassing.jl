module LotMassing

using NPFinancial, JuMP, GAMS, Polyhedra, BlackBoxOptim, Random, ProgressMeter #, Cbc




mutable struct RotInfo
    mat
    cr
    theta
end

mutable struct SubPoly
    points
    ladoComun
end

mutable struct PolyData
    V
    A
    b
    proyeccion
end

mutable struct ConstraintData
    V
    k
    A
    b
    norm
end


mutable struct PolyShape
    Vertices
    NumRegions
end

mutable struct FlagPlotEdif3D
    predio
    volTeor
    restSombra
    edif
    sombraVolTeor_p
    sombraVolTeor_o
    sombraVolTeor_s
    sombraEdif_p
    sombraEdif_o
    sombraEdif_s
end

mutable struct ResultadoCabida
    SalidaNormativa
    SalidaArquitectonica
    SalidaIndicadores
    SalidaTerreno
    SalidaMonetaria
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
    SEPMIN
    ANTEJARDIN
    RASANTE
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
end

mutable struct datosCabidaArquitectura
    ALTURAPISO
    PORCSUPCOMUN
    PORCTERRAZA
    ANCHOMAX
    MATCELDASCONF
    MATCONFHOR
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

struct salidaGeometria
    config
    celdasConfig
    p1
    p2
    p3
    p4
    pos_x
    pos_y
    largo
end

export datosCabidaPredio, datosCabidaNormativa, datosCabidaArquitectura, datosCabidaComercial, datosCabidaUnit,
         datosCabidaFlujo, datosCabidaRentabilidad, RotInfo, SubPoly, PolyData, salidaArquitectonica, salidaIndicadores, salidaMonetaria,
         salidaTerreno, salidaOptimizacion, salidaNormativa, salidaFlujoCaja, salidaGeometria, PolyShape, FlagPlotEdif3D, ConstraintData,
         ResultadoCabida

struct particulaPso
    pos_x
    pos_y
    largo_x
    largo_y
    theta
    alt
end

struct polyPso
    poly
    Rmat
    cr
    p_1
    p_2
    p_3
    p_4
end

export particulaPso, polyPso


MATCELDASCONF_ = [[1 3 5];
                  [2 3 4]; #
                  [1 3 NaN];
                  [3 5 NaN]; #
                  [2 3 NaN]; #
                  [3 4 NaN]; #
                  [1 NaN NaN];
                  [2 NaN NaN]]; #
MATCONFHOR_ = [[1 0 1];
               [0 1 0];
               [1 0 NaN];
               [0 1 NaN];
               [0 1 NaN];
               [0 1 NaN];
               [1 NaN NaN];
               [0 NaN NaN]];


"""
MATCELDASCONF_ = [[1 3 5];
                  [1 3 NaN];
                  [1 NaN NaN]];
MATCONFHOR_ = [[1 0 1];
               [1 0 NaN];
               [1 NaN NaN]];
"""

export MATCELDASCONF_, MATCONFHOR_

include("generaMatCeldasConf.jl")
include("infoPredio.jl")
include("calculaAnguloRotacion.jl")
include("plotCabidaOptima.jl")
include("generaCalles.jl")
include("generaSombraEdificio.jl")
include("optiEdificio.jl")
include("displayResults.jl")
include("plotBaseEdificio3d.jl")
include("poly2D.jl")
include("polyShape.jl")
include("evol.jl")
include("resultConverter.jl")
include("executaCalculoCabidas.jl")
include("generaVol3d.jl")
include("generaSombraTeor.jl")
include("factorIgualaArea.jl")
include("generaSupBruta.jl")
include("generaSitiosAleatorios.jl")
include("ajusteArea.jl")

export generaMatCeldasConf, infoPredio, plotCabidaOptima, calculaAnguloRotacion,
       generaCalles, generaSombraEdificio, optiEdificio, displayResults, evol, poly2D, polyShape, 
       resultConverter, plotBaseEdificio3d, ajusteArea,
       executaCalculoCabidas, generaVol3d, generaSombraTeor, 
       generaSupBruta, generaSitiosAleatorios, factorIgualaArea
end
