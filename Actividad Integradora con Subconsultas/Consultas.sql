
-- 1) ¿Cuál es la cantidad de pacientes que no se atendieron en el año 2015?
SELECT
count (DISTINCT p.IDPACIENTE) as 'Cantidad no se atendieron en 2015'
from pacientes p
WHERE P.IDPACIENTE not IN
(select
P.IDPACIENTE
FROM PACIENTES P
INNER JOIN TURNOS T ON T.IDPACIENTE=p.IDPACIENTE
where (year(t.FECHAHORA)=2015))

-- 2) ¿Cuál es el costo de la consulta promedio de cualquier especialista en "Oftalmología"?
SELECT AVG(COSTO_CONSULTA) FROM MEDICOS MED
INNER JOIN ESPECIALIDADES ESP ON ESP.IDESPECIALIDAD = MED.IDESPECIALIDAD
WHERE ESP.NOMBRE = 'Oftalmología'

-- 3) ¿Cuáles son el/los paciente/s que se atendieron más veces? (indistintamente del sexo del paciente)
SELECT P.IDPACIENTE, P.NOMBRE, P.APELLIDO, COUNT(*) FROM PACIENTES P
INNER JOIN TURNOS T ON T.IDPACIENTE = P.IDPACIENTE
GROUP BY P.IDPACIENTE, P.NOMBRE, P.APELLIDO
ORDER BY COUNT(*)  DESC

-- 4) ¿Cuál es el apellido del médico (sexo masculino) con más antigüedad de la clínica?
SELECT M.APELLIDO FROM MEDICOS M
WHERE M.SEXO = 'M'
ORDER BY M.FECHAINGRESO ASC

-- 5) ¿Cuántos médicos tienen la especialidad "Gastroenterología" ó "Pediatría"?
SELECT COUNT(*) FROM MEDICOS M
INNER JOIN ESPECIALIDADES E ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE IN ('Gastroenterología', 'Pediatría')


--6) ¿Qué Obras Sociales cubren a pacientes que se hayan atendido en algún turno con algún médico de especialidad 'Odontología'?
SELECT DISTINCT OS.NOMBRE FROM OBRAS_SOCIALES OS 
INNER JOIN PACIENTES PAC ON PAC.IDOBRASOCIAL = OS.IDOBRASOCIAL
INNER JOIN TURNOS T ON T.IDPACIENTE = PAC.IDPACIENTE
INNER JOIN MEDICOS M ON M.IDMEDICO = T.IDMEDICO
INNER JOIN ESPECIALIDADES E ON E.IDESPECIALIDAD = M.IDESPECIALIDAD
WHERE E.NOMBRE = 'Odontología'

-- 7) ¿Cuántos pacientes distintos se atendieron en turnos que duraron más que la duración promedio?
-- Ejemplo hipotético: Si la duración promedio de los turnos fuese 50 minutos. ¿Cuántos pacientes distintos se atendieron en turnos que duraron más que 50 minutos?
SELECT COUNT(DISTINCT IDPACIENTE) FROM TURNOS
WHERE DURACION > (SELECT AVG(DURACION) FROM TURNOS)

-- 8) ¿Cuántos turnos fueron atendidos por la doctora Flavia Rice?
SELECT COUNT(*) FROM TURNOS T
INNER JOIN MEDICOS M ON M.IDMEDICO = T.IDMEDICO
WHERE M.NOMBRE = 'Flavia' AND M.APELLIDO='Rice'

-- 9) ¿Cuántas médicas cobran sus honorarios de consulta un costo mayor a $1000?
SELECT COUNT(*) FROM MEDICOS M
WHERE M.SEXO = 'F' AND M.COSTO_CONSULTA > 1000

-- 10) ¿Cuánto tuvo que pagar la consulta el paciente con el turno nro 146?
-- Teniendo en cuenta que el paciente debe pagar el costo de la consulta del médico menos lo que cubre la cobertura de la obra social. La cobertura de la obra social está expresado en un valor decimal entre 0 y 1. Siendo 0 el 0% de cobertura y 1 el 100% de la cobertura.
-- Si la cobertura de la obra social es 0.2, entonces el paciente debe pagar el 80% de la consulta.
SELECT M.COSTO_CONSULTA, (M.COSTO_CONSULTA * (1- O.COBERTURA))FROM TURNOS T
INNER JOIN PACIENTES P ON P.IDPACIENTE = T.IDPACIENTE
INNER JOIN OBRAS_SOCIALES O ON O.IDOBRASOCIAL = P.IDOBRASOCIAL
INNER JOIN MEDICOS M ON M.IDMEDICO = T.IDMEDICO
WHERE T.IDTURNO = 146
