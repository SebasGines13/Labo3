-- A) Realizar un procedimiento almacenado llamado sp_Agregar_Usuario que permita registrar un usuario en el sistema. El procedimiento debe recibir como parámetro DNI, Apellido, Nombre, Fecha de nacimiento y los datos del domicilio del usuario.
SET DATEFORMAT dmy;
GO
CREATE PROCEDURE sp_Agregar_Usuario (
    @DNI VARCHAR(10),    
    @APELLIDO VARCHAR(50),
    @NOMBRE VARCHAR(50),
    @FECHA_NACIMIENTO SMALLDATETIME,
    @IDLOCALIDAD INT,
    @DIRECCION VARCHAR(255),
    @TELEFONO VARCHAR(15)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @LastIdentity int;

            INSERT INTO DOMICILIOS (IDLOCALIDAD, DIRECCION, TELEFONO)
                VALUES (@IDLOCALIDAD, @DIRECCION, @TELEFONO)

            SET @LastIdentity = scope_identity()

            INSERT INTO USUARIOS(DNI, APELLIDO, NOMBRE, FECHA_NACIMIENTO, IDDOMICILIO)
                VALUES (@DNI, @APELLIDO, @NOMBRE, @FECHA_NACIMIENTO, @LastIdentity )

        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR('NO SE PUDO DAR DE ALTA EL USUARIO', 16, 1)
    END CATCH
END
GO


-- B) Realizar un procedimiento almacenado llamado sp_Agregar_Tarjeta que dé de alta una tarjeta. El procedimiento solo debe recibir el DNI del usuario.
-- Como el sistema sólo permite una tarjeta activa por usuario, el procedimiento debe:
-- Dar de baja la última tarjeta del usuario (si corresponde).
-- Dar de alta la nueva tarjeta del usuario
-- Traspasar el saldo de la vieja tarjeta a la nueva tarjeta (si corresponde)

CREATE PROCEDURE sp_Agregar_Tarjeta (
    @DNI VARCHAR(10)
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @IdUsuario int;
            SELECT @IdUsuario = ID from USUARIOS where DNI = @DNI

            IF @IdUsuario > 0 BEGIN
                DECLARE @IdTarjeta int
                DECLARE @Saldo int             
                DECLARE @LastIdentity int

                SELECT @IdTarjeta = ID, @Saldo = SALDO FROM (
                    SELECT T.ID, SUM( CASE  MOV.TIPOMOVIMIENTO WHEN 'C' THEN isnull(MOV.IMPORTE,0) ELSE (isnull(MOV.IMPORTE,0)*-1) END )SALDO 
                    FROM TARJETAS T
                    LEFT JOIN MOVIMIENTOS_TARJETAS MOV ON MOV.IDTARJETA = T.ID
                    WHERE T.IDUSUARIO = @IdUsuario AND T.ESTADO = 1
                    GROUP BY T.ID) AS T

                IF @IdTarjeta > 0 BEGIN
                    UPDATE TARJETAS
                    SET ESTADO = 0
                    WHERE ID = @IdTarjeta
                END                       

                INSERT INTO TARJETAS(FECHAALTA, IDUSUARIO)
                VALUES(GETDATE(),@IdUsuario)

                IF @Saldo > 0 BEGIN   
                    SET @LastIdentity = scope_identity()                                  
                    INSERT INTO MOVIMIENTOS_TARJETAS (FECHA, IDTARJETA, IMPORTE, TIPOMOVIMIENTO)
                    VALUES (GETDATE(), @LastIdentity, @Saldo, 'C')
                END

            END ELSE BEGIN
                PRINT('USUARIO NO ENCONTRADO')
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR('NO SE PUDO DAR DE ALTA LA TARJETA', 16, 1)
    END CATCH
END


-- C) Realizar un procedimiento almacenado llamado sp_Agregar_Viaje que registre un viaje a una tarjeta en particular. El procedimiento debe recibir: Número de tarjeta, importe del viaje, nro de interno y nro de línea.
-- El procedimiento deberá:
-- Descontar el saldo
-- Registrar el viaje
-- Registrar el movimiento de débito

-- NOTA: Una tarjeta no puede tener una deuda que supere los $10.
GO

CREATE PROCEDURE sp_Agregar_Viaje (
    @IdTarjeta int,
    @Importe money,
    @Interno smallint,
    @Linea varchar(5)
) AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @MSJERROR VARCHAR(255) = 'NO SE PUDO DAR DE ALTA EL VIAJE'
            DECLARE @ExisteTarjeta bit 

            SELECT @ExisteTarjeta = COUNT(*) FROM TARJETAS WHERE ID = @IdTarjeta AND ESTADO = 1

            IF @ExisteTarjeta = 1 BEGIN
                DECLARE @Saldo money
                SELECT @Saldo = SALDO FROM (
                    SELECT SUM( CASE  MOV.TIPOMOVIMIENTO WHEN 'C' THEN isnull(MOV.IMPORTE,0) ELSE (isnull(MOV.IMPORTE,0)*-1) END )SALDO 
                    FROM TARJETAS T
                    LEFT JOIN MOVIMIENTOS_TARJETAS MOV ON MOV.IDTARJETA = T.ID
                    WHERE T.ID = @IdTarjeta
                    GROUP BY T.ID) AS T
                
                IF ( @saldo - @Importe ) >= -10 BEGIN
                    DECLARE @ExisteLinea bit 
                    SELECT @ExisteLinea = COUNT(*) FROM LINEAS_COLECTIVO WHERE COD = @Linea

                    IF @ExisteLinea = 1 BEGIN
                        IF @Interno >= 0 BEGIN
                            DECLARE @LastIdentity int
                            INSERT INTO MOVIMIENTOS_TARJETAS (FECHA, IDTARJETA, IMPORTE, TIPOMOVIMIENTO)
                                VALUES (GETDATE(), @IdTarjeta, @Importe, 'D')
                            
                            SET @LastIdentity = scope_identity()
                            INSERT INTO VIAJES (INTERNO, IDMOVIMIENTOTARJETA, CODLINEACOLECTIVO)
                                VALUES ( @Interno, @LastIdentity, @Linea)
                        END
                        ELSE BEGIN
                            SET @MSJERROR = @MSJERROR + ' - INTERNO INCORRECTO'
                            RAISERROR(@MSJERROR, 16, 1)
                        END
                    END 
                    ELSE BEGIN
                        SET @MSJERROR = @MSJERROR + ' - LINEA DE COLECTIVO NO ENCONTRADA'
                        RAISERROR(@MSJERROR, 16, 1)
                    END
                END
                ELSE BEGIN
                    SET @MSJERROR = @MSJERROR + ' - SALDO INSUFICIENTE'
                    RAISERROR(@MSJERROR, 16, 1)
                END
            END
            ELSE BEGIN
                SET @MSJERROR = @MSJERROR + ' - TARJETA NO ENCONTRADA O DADA DE BAJA'
                RAISERROR(@MSJERROR, 16, 1)
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR(@MSJERROR, 16, 1)
    END CATCH
END

-- D) Realizar un procedimiento almacenado llamado sp_Agregar_Saldo que registre un movimiento de crédito a una tarjeta en particular. El procedimiento debe recibir: El número de tarjeta y el importe a recargar. Modificar el saldo de la tarjeta.

GO

CREATE PROCEDURE sp_Agregar_Saldo (
    @IdTarjeta int,
    @Importe money
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @MSJERROR VARCHAR(255) = 'NO SE PUDO DAR DE ALTA LA RECARGA'
            DECLARE @ExisteTarjeta bit 

            SELECT @ExisteTarjeta = COUNT(*) FROM TARJETAS WHERE ID = @IdTarjeta AND ESTADO = 1

            IF @ExisteTarjeta = 1 BEGIN
                IF @Importe > 0 BEGIN
                    INSERT INTO MOVIMIENTOS_TARJETAS (FECHA, IDTARJETA, IMPORTE, TIPOMOVIMIENTO)
                            VALUES (GETDATE(), @IdTarjeta, @Importe, 'C')
                END
                ELSE BEGIN
                    SET @MSJERROR = @MSJERROR + ' - EL IMPORTE DE RECARGA DEBE SER MAYOR A CERO'
                    RAISERROR(@MSJERROR, 16, 1)
                END
            END
            ELSE BEGIN
                SET @MSJERROR = @MSJERROR + ' - TARJETA NO ENCONTRADA O DADA DE BAJA'
                RAISERROR(@MSJERROR, 16, 1)
            END
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR(@MSJERROR, 16, 1)
    END CATCH
END


-- E) Realizar un procedimiento almacenado llamado sp_Baja_Fisica_Usuario que elimine un usuario del sistema. La eliminación deberá ser 'en cascada'. Esto quiere decir que para cada usuario primero deberán eliminarse todos los viajes y recargas de sus respectivas tarjetas. Luego, todas sus tarjetas y por último su registro de usuario.

GO

CREATE PROCEDURE sp_Baja_Fisica_Usuario (
    @IdUsuario int
)
AS
BEGIN
    BEGIN TRY
        BEGIN TRANSACTION
            DECLARE @MSJERROR VARCHAR(255) = 'NO SE PUDO DAR DE BAJA AL USUARIO'
            DECLARE @ExisteUsuario bit 

            SELECT @ExisteUsuario = COUNT(*) FROM USUARIOS WHERE ID = @IdUsuario

            IF @ExisteUsuario = 1 BEGIN
                DELETE FROM VIAJES WHERE IDMOVIMIENTOTARJETA IN ( 
                    SELECT MOV.ID FROM MOVIMIENTOS_TARJETAS MOV
                    INNER JOIN TARJETAS T ON T.ID = MOV.IDTARJETA 
                    WHERE T.IDUSUARIO = @IdUsuario
                )

                DELETE FROM MOVIMIENTOS_TARJETAS WHERE ID IN ( 
                    SELECT ID FROM TARJETAS
                    WHERE IDUSUARIO = @IdUsuario
                )

                DELETE FROM TARJETAS WHERE IDUSUARIO = @IdUsuario

                DELETE FROM USUARIOS WHERE ID = @IdUsuario
            END
            ELSE BEGIN
                SET @MSJERROR = @MSJERROR + ' - NO SE ENCONTRO EL USUARIO'
                RAISERROR(@MSJERROR, 16, 1)
            END
            
        COMMIT TRANSACTION
    END TRY
    BEGIN CATCH
        ROLLBACK TRANSACTION
        RAISERROR(@MSJERROR, 16, 1)
    END CATCH
END

