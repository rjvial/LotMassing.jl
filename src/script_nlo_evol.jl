# module Cabida_nlo_evol

##############################################
# PARTE "1": CARGA CABIDA                    #
##############################################



using LotMassing, .poly2D, .polyShape

# Random.seed!(1236)
# Random.seed!(1230)

##############################################
# PARTE "2": GENERACIÓN DE PARÁMETROS        #
##############################################

idPredio = 1 # 8 predio = 1,2,3,4,5,6,7,9
conjuntoTemplates = [1] # 4 [1:L, 2:C, 3:lll, 4:V, 5:H]


conn_LotMassing = pg_julia.connection("LotMassing", "postgres", "postgres")
conn_mygis_db = pg_julia.connection("mygis_db", "postgres", "postgres")


dcc = datosCabidaComercial()
dcc.SUPDEPTOUTIL = [50, 90, 110, 140]
dcc.MAXPORCTIPODEPTO = [1.0, 1.0, 1.0, 1.0]
dcc.PRECIOVENTA = [95, 92, 90, 89]
dcc.PRECIOVENTAEST = 200
dcr = datosCabidaRentabilidad(1.2)
dcf = datosCabidaFlujo([0.05, 0.05, 0.05, 0.05, 0.1, 0.7], [1, 0, 0, 0, 0, 0], [0.05, 0.1, 0.35, 0.35, 0.15, 0.0], [0.4, 0.15, 0.15, 0.15, 0.15, 0.0], [0.0, 0.1, 0.2, 0.2, 0.25, 0.25], [0.1, 0.4, 0.25, 0.15, 0.05, 0.05], [0.0, 0.0, 0.0, 0.0, 0.5, 0.5], [0.0, 0.0, 0.0, 0.0, 0.25, 0.75], [0.05, 0.05, 0.05, 0.05, 0.05, 0.75], [0.0, 0.2, 0.2, 0.2, 0.2, 0.2], [0.05, 0.1, 0.35, 0.35, 0.15, 0.0], [0.0, 0.0, 0.1, 0.35, 0.35, 0.2], 0.27, 0.05, 24.0, 15)

df_arquitectura = pg_julia.query(conn_LotMassing, """SELECT * FROM public."tabla_arquitectura_default";""")
dca = datosCabidaArquitectura()
for field_s in fieldnames(datosCabidaArquitectura)
    value_ = df_arquitectura[:, field_s][1]
    setproperty!(dca, field_s, value_)
end

df_costosunitarios = pg_julia.query(conn_LotMassing, """SELECT * FROM public."tabla_costosunitarios_default";""")
dcu = datosCabidaUnit()
for field_s in fieldnames(datosCabidaUnit)
    value_ = df_costosunitarios[:, field_s][1]
    setproperty!(dcu, field_s, value_)
end

df_flagplot = pg_julia.query(conn_LotMassing, """SELECT * FROM public."tabla_flagplot_default";""")
fpe = FlagPlotEdif3D()
for field_s in fieldnames(FlagPlotEdif3D)
    value_ = df_flagplot[:, field_s][1]
    setproperty!(fpe, field_s, value_)
end



# Sql parametros del predio 
queryStr = """
SELECT codigo_predial, sup_terreno_edif, zona, densidad_bruta_hab_ha, densidad_neta_viv_ha, subdivision_predial_minima,
coef_constructibilidad, ocupacion_suelo, ocupacion_pisos_superiores, coef_constructibilidad_continua, ocupacion_suelo_continua,
ocupacion_pisos_superiores_continua, coef_area_libre, rasante, num_pisos_continua, altura_max_continua, num_pisos_sobre_edif_continua,
altura_max_sobre_edif_continua, num_pisos_total, altura_max_total, antejardin_sobre_edif_continua, distanciamiento_sobre_edif_continua,
antejardin, distanciamiento, ochavo, adosamiento_edif_continua, adosamiento_edif_aislada, ST_AsText(geom_predios,3857) as predios_str,
area_calculada
FROM datos_predios_vitacura
WHERE codigo_predial = 151600044500516
"""
#   151600094590126  151600044500516 151600050990072 151600041300008 151600108990001 151600147500003
df = pg_julia.query(conn_mygis_db, queryStr)

dcn = datosCabidaNormativa()
dcn.DISTANCIAMIENTO = df.distanciamiento[1]
dcn.ANTEJARDIN = df.antejardin[1]
dcn.RASANTE = tan(df.rasante[1]/180*pi)
dcn.RASANTESOMBRA = 5
dcn.ALTURAMAX = df.altura_max_total[1] == -1 ? 100 : df.altura_max_total[1]  
dcn.MAXPISOS = df.num_pisos_total[1] == -1 ? 30 : df.num_pisos_total[1]
dcn.COEFOCUPACION = df.ocupacion_suelo[1]
dcn.SUBPREDIALMIN = df.subdivision_predial_minima[1]
dcn.DENSIDADMAX = df.densidad_bruta_hab_ha[1] 
dcn.FLAGDENSIDADBRUTA = true
dcn.COEFCONSTRUCTIBILIDAD = df.coef_constructibilidad[1] 
dcn.ESTACIONAMIENTOSPORVIV = 1
dcn.PORCADICESTACVISITAS = .15
dcn.SUPPORESTACIONAMIENTO = 30
dcn.ESTBICICLETAPOREST = .5
dcn.BICICLETASPOREST = 3
dcn.FLAGCAMBIOESTPORBICICLETA = true
dcn.MAXSUBTE = 7
dcn.COEFOCUPACIONEST = .8
dcn.SEPESTMIN = 7
dcn.REDUCCIONESTPORDISTMETRO = false

sup_terreno_edif = df.sup_terreno_edif[1]<1 ? df.area_calculada[1] : df.sup_terreno_edif[1]
predios_str = df.predios_str[1]
ps = astext2polyshape(predios_str)

# Simplifica, corrige orientacion y escala del predio
is_ccw = polyShape.polyOrientation(ps)
V = ps.Vertices[1]
if is_ccw == -1 #counter clockwise?
    V = polyShape.reversePath(V)
end
if size(V,1) > 8
    ps = PolyShape([V],1)
    ps = polySimplify(ps, .00003)
    V = ps.Vertices[1]
end
factorCorreccion = factorIgualaArea(V, sup_terreno_edif)
V, dx, dy = ajustaCoordenadas(V, factorCorreccion)
ps_predio = PolyShape([V],1)
x = V[:,1]
y = V[:,2]



# Sql segmentos del predio 
V_seg = []
numSeg = size(V,1)
for i = 1:numSeg
    if i < numSeg
        V_seg_i = [V[i,1] V[i,2]; V[i+1,1] V[i+1,2]]
    else
        V_seg_i = [V[i,1] V[i,2]; V[1,1] V[1,2]]
    end
    push!(V_seg, V_seg_i)
end
ls_segmentos = LineShape(V_seg, numSeg)
seg_center = partialCentroid(ls_segmentos)

"""
matDist_seg = ones(seg_center.NumPoints, seg_center.NumPoints)*100000
for i = 1:seg_center.NumPoints-1
    shape_i = subShape(seg_center,i)
    for j = 1:seg_center.NumPoints
        shape_j = subShape(seg_center,j)
        matDist_seg[i,j] = i == j ? 100000 : shapeDistance(shape_i, shape_j)
    end
end
minDistSeg = minimum(matDist_seg, dims=2)
"""


# Sql calles contenidas en buffer del predio
queryStr = """ 
WITH buffer_predio AS (select ST_Buffer(geom_predios, .0003) as geom
			from datos_predios_vitacura
			where codigo_predial = 151600044500516
			),
	 calles AS (select ST_Transform(mc.geom, 4326) as geom
		    from maestro_de_calles as mc 
		    where mc.comuna = 'VITACURA')
select ST_AsText(st_intersection(buffer_predio.geom, calles.geom)) as calles_str
from calles join buffer_predio on st_intersects(buffer_predio.geom, calles.geom)
"""
df_ = pg_julia.query(conn_mygis_db, queryStr)
ls_calles = astext2lineshape(df_.calles_str)
for i = 1:ls_calles.NumLines
    V_i = ls_calles.Vertices[i]
    V_i = ajustaCoordenadas(V_i, factorCorreccion, dx, dy)
    ls_calles.Vertices[i] = V_i
end
V_calles_nvo = []
for i = 1:ls_calles.NumLines
    V_calles_i = ls_calles.Vertices[i]
    if size(V_calles_i,1) >= 3
        for j = 1:size(V_calles_i,1)-1
            V_calles_ij = [V_calles_i[j,1] V_calles_i[j,2]; V_calles_i[j+1,1] V_calles_i[j+1,2]]
            push!(V_calles_nvo,V_calles_ij)
        end
    else
        push!(V_calles_nvo,V_calles_i)
    end
end
ls_calles = LineShape(V_calles_nvo, size(V_calles_nvo,1))
calles_center = partialCentroid(ls_calles)


matDist_seg_calles = partialDistance(seg_center, calles_center)

numSeg = seg_center.NumPoints
vecSecConCalle = []
vecAnchoCalle = []
for i = 1:numSeg
    minDist_i = minimum(matDist_seg_calles[i,:])
    if minDist_i <= 20
        idSegmentoCalle_i = argmin(matDist_seg_calles[i,:])
        semiAnchoCalle_i = shapeDistance(subShape(seg_center,i), subShape(ls_calles,idSegmentoCalle_i))
        push!(vecSecConCalle, Int64(i))
        push!(vecAnchoCalle, semiAnchoCalle_i*2) 
    end
end


dcp = datosCabidaPredio(x, y, vecSecConCalle, vecAnchoCalle, 0, 200);


resultados, ps_calles, ps_publico, ps_predio, ps_base, ps_baseSeparada, 
ps_volteor, matConexionVertices, vecVertices,
ps_volRestSombra, matConexionVertices_restSombra, vecVertices_restSombra,
xopt_restSombra, fopt_restSombra, 
ps_SombraVolTeor_p, ps_sombraEdif_p, 
ps_SombraVolTeor_s, ps_sombraEdif_s, 
ps_SombraVolTeor_o, ps_sombraEdif_o = ejecutaCalculoCabidas(dcp, dcn, dca, dcc, dcu, dcf, dcr, conjuntoTemplates);


fig = plotBaseEdificio3d(fpe, xopt_restSombra, dca.ALTURAPISO, ps_predio, 
ps_volteor, matConexionVertices, vecVertices, 
ps_volRestSombra, matConexionVertices_restSombra, vecVertices_restSombra, 
ps_publico, ps_calles, ps_base, ps_baseSeparada);

resultados_ = [resultados.SalidaNormativa, 
                resultados.SalidaArquitectonica, 
                resultados.SalidaIndicadores, 
                resultados.SalidaTerreno, 
                resultados.SalidaOptimizacion, 
                resultados.SalidaMonetaria, 
                resultados.SalidaFlujoCaja, [xopt_restSombra]]
displayResults(resultados_)
println(" ")
println(" ")
println(" ")