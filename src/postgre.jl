using LibPQ, Tables, DataFrames, CSV, IterTools

conn = LibPQ.Connection("dbname=LotMassing user=postgres password=********")

# Carga tabla de desde la base de datos
result = execute(conn, """
                        SELECT *
                        FROM public."tablaCabidaNormativa";
                        """;
                        throw_error=true,
                )

# Agrega fila de datos a una tabla
execute(conn, """
            INSERT INTO public."tablaCabidaNormativa" (
            "DISTANCIAMIENTO", "ANTEJARDIN", "RASANTE", "RASANTESOMBRA", "ALTURAMAX", "MAXPISOS", "COEFOCUPACION", "SUBPREDIALMIN", "DENSIDADMAX", "FLAGDENSIDADBRUTA", "COEFCONSTRUCTIBILIDAD", "ESTACIONAMIENTOSPORVIV", "PORCADICESTACVISITAS", "SUPPORESTACIONAMIENTO", "ESTBICICLETAPOREST", "BICICLETASPOREST", "FLAGCAMBIOESTPORBICICLETA", "MAXSUBTE", "COEFOCUPACIONEST", "SEPESTMIN", "REDUCCIONESTPORDISTMETRO", "id_Normativa") VALUES (
            '4'::double precision, '4'::double precision, '2.75'::double precision, '5'::double precision, '60'::double precision, '30'::integer, '0.7'::double precision, '1000'::double precision, '2500'::double precision, true::boolean, '4'::double precision, '1'::double precision, '.15'::double precision, '34'::double precision, '.5'::double precision, '3'::double precision, true::boolean, '10'::integer, '.8'::double precision, '7'::double precision, false::boolean, '2'::integer)
            """;
throw_error=true,
)

# o alternativamente
aaa = """INSERT INTO public."tablaCabidaNormativa" ("DISTANCIAMIENTO", "ANTEJARDIN", "RASANTE", "RASANTESOMBRA", "ALTURAMAX", "MAXPISOS", "COEFOCUPACION", "SUBPREDIALMIN", "DENSIDADMAX", "FLAGDENSIDADBRUTA", "COEFCONSTRUCTIBILIDAD", "ESTACIONAMIENTOSPORVIV", "PORCADICESTACVISITAS", "SUPPORESTACIONAMIENTO", "ESTBICICLETAPOREST", "BICICLETASPOREST", "FLAGCAMBIOESTPORBICICLETA", "MAXSUBTE", "COEFOCUPACIONEST", "SEPESTMIN", "REDUCCIONESTPORDISTMETRO", "id_Normativa") VALUES ('4'::double precision, '4'::double precision, '2.75'::double precision, '5'::double precision, '60'::double precision, '30'::integer, '0.7'::double precision, '1000'::double precision, '2500'::double precision, true::boolean, '4'::double precision, '1'::double precision, '.15'::double precision, '34'::double precision, '.5'::double precision, '3'::double precision, true::boolean, '10'::integer, '.8'::double precision, '7'::double precision, false::boolean, '3'::integer)"""
execute(conn, aaa; throw_error=true)
bbb = "INSERT INTO public.\"tablaCabidaNormativa\" (\"DISTANCIAMIENTO\", \"ANTEJARDIN\", \"RASANTE\", \"RASANTESOMBRA\", \"ALTURAMAX\", \"MAXPISOS\", \"COEFOCUPACION\", \"SUBPREDIALMIN\", \"DENSIDADMAX\", \"FLAGDENSIDADBRUTA\", \"COEFCONSTRUCTIBILIDAD\", \"ESTACIONAMIENTOSPORVIV\", \"PORCADICESTACVISITAS\", \"SUPPORESTACIONAMIENTO\", \"ESTBICICLETAPOREST\", \"BICICLETASPOREST\", \"FLAGCAMBIOESTPORBICICLETA\", \"MAXSUBTE\", \"COEFOCUPACIONEST\", \"SEPESTMIN\", \"REDUCCIONESTPORDISTMETRO\", \"id_Normativa\") VALUES ('4', '4', '2.75', '5', '60', '30', '0.7', '1000', '2500', true, '4', '1', '.15', '34', '.5', '3', true, '10', '.8', '7', false, '5')"
execute(conn, bbb; throw_error=true)

# y volver a cargar datos
result = execute(conn, """
                        SELECT *
                        FROM public."tablaCabidaNormativa"
                        WHERE "DISTANCIAMIENTO" = 5
                        ORDER BY "DISTANCIAMIENTO";
                        """;
                        throw_error=true,
                )

# borra las filas cuyo id_Normativa > 1
execute(conn, """
                DELETE FROM public."tablaCabidaNormativa" WHERE "id_Normativa">1;
                """;
                throw_error=true,
                )

numColumns = LibPQ.num_columns(result)
numRows = LibPQ.num_rows(result)
columnName_3 = LibPQ.column_name(result, 3)

data = columntable(result)
data[:ANTEJARDIN][1]

# Usando DataFrames
df = DataFrame(result)

anteJardin = df.ANTEJARDIN

nombreColumnas = names(df)
nombreColumnasAsSymbol = propertynames(df)

df[:, [:RASANTE, :RASANTESOMBRA]]
df[:, :RASANTE]

df_byRows = eachrow(df)
row_2 = df_byRows[2]
row_3_Antejardin = df_byRows[3][:ANTEJARDIN]

select(df, Not(:RASANTE)) # Selecciona columnas que no contienen :RASANTE
select(df, (r"RASAN")) # Selecciona columnas que contienen :RASAN*


#public.\"tablaCabidaNormativa\"
#insert_by_copy!(conn, "public.\"tablaCabidaNormativa\"", df, :id_Normativa)
function insert_by_copy!(con:: LibPQ.Connection, tablename:: AbstractString, df:: DataFrame, id::Symbol)

    id_max = maximum(df[!, id])
    df[!, id] .= Int32.(round.(df[!, id]; digits = 0) .+ id_max)

    row_strings = imap(eachrow(df)) do row
        join((ismissing(x) ? "" : x for x in row), ",")*"\n"
    end
    copyin = LibPQ.CopyIn("COPY $tablename FROM STDIN (FORMAT CSV);", row_strings)
    execute(con, copyin)
end



close(conn)

