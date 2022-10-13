-- A) Realizar una vista que permita conocer los datos de los usuarios y sus respectivas tarjetas. La misma debe contener: Apellido y nombre del usuario, número de tarjeta SUBE, estado de la tarjeta y saldo.
CREATE VIEW VW_DATOSUSUARIOS_TARJETAS AS 
SELECT APELLIDO, NOMBRE, ID, ESTADO, SUM(IMPORTES) AS SALDO
FROM (
    SELECT U.APELLIDO, U.NOMBRE, T.ID, T.ESTADO, 
        CASE  MT.TIPOMOVIMIENTO 
            WHEN 'C' THEN MT.IMPORTE
            ELSE (MT.IMPORTE*-1)
        END AS IMPORTES
    FROM USUARIOS U
    INNER JOIN TARJETAS T ON T.IDUSUARIO = U.ID
    INNER JOIN MOVIMIENTOS_TARJETAS MT ON MT.IDTARJETA = T.ID
) DATOSUSUARIO
GROUP BY APELLIDO, NOMBRE, ID, ESTADO
GO

-- B) Realizar una vista que permita conocer los datos de los usuarios y sus respectivos viajes. La misma debe contener: Apellido y nombre del usuario, número de tarjeta SUBE, fecha del viaje, importe del viaje, número de interno y nombre de la línea.
CREATE VIEW VW_DATOSUSUARIOS_VIAJES AS  
    SELECT U.APELLIDO, U.NOMBRE, T.ID, MT.FECHA, MT.IMPORTE, V.INTERNO, L.NOMBRE AS LINEA FROM USUARIOS U
    INNER JOIN TARJETAS T ON T.IDUSUARIO = U.ID
    INNER JOIN MOVIMIENTOS_TARJETAS MT ON MT.IDTARJETA = T.ID
    INNER JOIN VIAJES V ON V.IDMOVIMIENTOTARJETA = MT.ID
    INNER JOIN LINEAS_COLECTIVO L ON L.COD = V.CODLINEACOLECTIVO
GO

-- C) Realizar una vista que permita conocer los datos estadísticos de cada tarjeta. La misma debe contener: Apellido y nombre del usuario, número de tarjeta SUBE, cantidad de viajes realizados, total de dinero acreditado (históricamente), cantidad de recargas, importe de recarga promedio (en pesos), estado de la tarjeta.
CREATE VIEW VW_DATOSTARJETAS AS 
SELECT U.APELLIDO, U.NOMBRE, T.ID,  
        ISNULL(( SELECT COUNT(*) FROM VIAJES V INNER JOIN MOVIMIENTOS_TARJETAS MOV ON MOV.ID = V.IDMOVIMIENTOTARJETA WHERE MOV.IDTARJETA = T.ID  ),0) AS CANT_VIAJES, 
        ISNULL(( SELECT COUNT(*) FROM MOVIMIENTOS_TARJETAS MOV_TARJ WHERE MOV_TARJ.IDTARJETA = T.ID AND MOV_TARJ.TIPOMOVIMIENTO='C'), 0)  AS CANTIDAD_RECARGAS,  
        ISNULL(( SELECT SUM( CASE  MOV.TIPOMOVIMIENTO 
            WHEN 'C' THEN MOV.IMPORTE
            ELSE (MOV.IMPORTE*-1)           
        END) FROM MOVIMIENTOS_TARJETAS MOV  WHERE MOV.IDTARJETA = T.ID  ), 0) AS TOTAL_ACREDITADO, 
        ISNULL(( SELECT AVG(MOV_TARJ.IMPORTE) FROM MOVIMIENTOS_TARJETAS MOV_TARJ WHERE MOV_TARJ.IDTARJETA = T.ID AND MOV_TARJ.TIPOMOVIMIENTO='C'), 0) AS IMPORTE_RECARGA_PROMEDIO, 
        T.ESTADO
FROM TARJETAS T
INNER JOIN USUARIOS U ON U.ID = T.IDUSUARIO
