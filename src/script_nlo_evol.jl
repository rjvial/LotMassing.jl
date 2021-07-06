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
conjuntoTemplates = [2] # 4 [1:L, 2:C, 3:lll, 4:V, 5:H]


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



# Sql calles contenidas en buffer del predio 
queryStr = """ 
WITH buffer_predio AS (select ST_Buffer(geom_predios, .0001) as geom
			from datos_predios_vitacura
			where codigo_predial = 151600094590126 
			),
	 calles AS (select ST_Transform(mc.geom, 4326) as geom
		    from maestro_de_calles as mc 
		    where mc.comuna = 'VITACURA')
select ST_AsText(st_intersection(buffer_predio.geom, calles.geom)) as calles_str
from calles join buffer_predio on st_intersects(buffer_predio.geom, calles.geom)
"""
df_ = pg_julia.query(conn_mygis_db, queryStr)

# Sql segmentos del predio 
queryStr = """
select ST_AsText((ST_Dump(geom_segmentos)).geom) as segmentos_str
from datos_predios_vitacura
where codigo_predial = 151600094590126
"""
df__ = pg_julia.query(conn_mygis_db, queryStr)

# Sql parametros del predio 
queryStr = """
SELECT codigo_predial, sup_terreno_edif, zona, densidad_bruta_hab_ha, densidad_neta_viv_ha, subdivision_predial_minima,
coef_constructibilidad, ocupacion_suelo, ocupacion_pisos_superiores, coef_constructibilidad_continua, ocupacion_suelo_continua,
ocupacion_pisos_superiores_continua, coef_area_libre, rasante, num_pisos_continua, altura_max_continua, num_pisos_sobre_edif_continua,
altura_max_sobre_edif_continua, num_pisos_total, altura_max_total, antejardin_sobre_edif_continua, distanciamiento_sobre_edif_continua,
antejardin, distanciamiento, ochavo, adosamiento_edif_continua, adosamiento_edif_aislada, ST_AsText(geom_predios,3857) as predios_str
FROM datos_predios_vitacura
WHERE codigo_predial = 151600046100076
"""
#   151600094590126
df = pg_julia.query(conn_mygis_db, queryStr)

dcn = datosCabidaNormativa()
dcn.DISTANCIAMIENTO = df.distanciamiento[1]
dcn.ANTEJARDIN = df.antejardin[1]
dcn.RASANTE = tan(df.rasante[1]/180*pi)
dcn.RASANTESOMBRA = 5
dcn.ALTURAMAX = df.altura_max_total[1]  
dcn.MAXPISOS = df.num_pisos_total[1] 
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

sup_terreno_edif = df.sup_terreno_edif[1]
predios_str = df.predios_str[1]
ps = astext2polyshape(predios_str)

is_ccw = polyShape.polyOrientation(ps)
V = ps.Vertices[1]
if is_ccw == -1 #counter clockwise?
    V = polyShape.reversePath(V)
end
factorCorreccion = factorIgualaArea(V, sup_terreno_edif)
x = V[:,1]
y = V[:,2]
x = factorCorreccion * x
y = factorCorreccion * y
x = x .- minimum(x)
y = y .- minimum(y)
V = [x y]
dcp = datosCabidaPredio(x, y, [1], [15], 0, 200);




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