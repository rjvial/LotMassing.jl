conn = DBInterface.connect(MySQL.Connection, "127.0.0.1", "root", "root")

DBInterface.execute(conn, "CREATE DATABASE db_cabida")
DBInterface.execute(conn, "use db_cabida")

DBInterface.execute(conn, """CREATE TABLE datosCabidaNormativa
                 (
                     ID INT NOT NULL AUTO_INCREMENT,
                     SEPMIN DOUBLE,
                     ANTEJARDIN DOUBLE,
                     RASANTE DOUBLE,
                     ALTURAMAX DOUBLE,
                     MAXPISOS INT,
                     COEFOCUPACION DOUBLE,
                     SUBPREDIALMIN DOUBLE,
                     DENSIDADMAX DOUBLE,
                     FLAGDENSIDADBRUTA DOUBLE,
                     COEFCONSTRUCTIBILIDAD DOUBLE,
                     ESTACIONAMIENTOSPORVIV DOUBLE,
                     PORCADICESTACVISITAS DOUBLE,
                     SUPPORESTACIONAMIENTO DOUBLE,
                     ESTBICICLETAPOREST DOUBLE,
                     BICICLETASPOREST DOUBLE,
                     FLAGCAMBIOESTPORBICICLETA BIT(1),
                     MAXSUBTE INT,
                     COEFOCUPACIONEST DOUBLE,
                     SEPESTMIN DOUBLE,
                     REDUCCIONESTPORDISTMETRO DOUBLE,
                     PRIMARY KEY (ID)
                 );""")


DBInterface.execute(conn, """INSERT INTO datosCabidaNormativa (SEPMIN, ANTEJARDIN, RASANTE, ALTURAMAX, MAXPISOS, COEFOCUPACION, SUBPREDIALMIN, DENSIDADMAX, FLAGDENSIDADBRUTA, COEFCONSTRUCTIBILIDAD, ESTACIONAMIENTOSPORVIV, PORCADICESTACVISITAS, SUPPORESTACIONAMIENTO, ESTBICICLETAPOREST, BICICLETASPOREST, FLAGCAMBIOESTPORBICICLETA, MAXSUBTE, COEFOCUPACIONEST, SEPESTMIN, REDUCCIONESTPORDISTMETRO)
                 VALUES
                 (5, 5, 2.75, 60, 30, .7, 1000, 2500, 1, 4, 1, .15, 34, .25, 3, 1, 10, .8, 7, 0);
              """)

queryData = DBInterface.execute(conn, "select * from datosCabidaNormativa")

row = DBInterface.execute(conn, "select * from datosCabidaNormativa") |> columntable
A = [getproperty(row, prop) for (i, prop) in enumerate(propertynames(row))]