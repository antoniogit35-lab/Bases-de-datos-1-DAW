-- Ejercicio 1
--  Importa la base de datos Alquiler_coches. Crea un trigger llamado TRGKmInicial que para la
-- tabla USOS_COCHE inserte en el kilómetro inicial el kilómetro final de la última vez que se
-- alquiló. Si no se ha alquilado nunca que lo ponga a 0.
DELIMITER //
CREATE TRIGGER TRGKmInicial 
BEFORE INSERT ON uso_coches
FOR EACH ROW
BEGIN 
IF NEW.km_inicial = 0 THEN SET NEW.km_inicial = 0;
ELSE SET NEW.km_inicial = (SELECT km_final FROM uso_coches WHERE coche = NEW.coche ORDER BY fecha DESC LIMIT 1);
END IF;
END //
DELIMITER ;

-- Ejercicio 2
-- Realiza un trigger llamado TRGmail que compruebe que el email introducido a un usuario
-- tiene el formato sin espacios, con texto, una sola arroba, texto después, un punto y tres
-- caracteres después. Si no cumple las condiciones, que lo deje vacío, que introduzca un valor nulo.
-- REGEXP ' ': Establece que no pueda tener espacios. (Entre las comillas hay un espacio)
DELIMITER //
CREATE TRIGGER TRGmail
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
	IF NEW.email REGEXP '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.com$' THEN
		SET NEW.email = NEW.email;
	ELSE SET NEW.email = NULL;
	END IF;
END //
DELIMITER ;

-- Ejercicio 3
-- Realiza un trigger llamado TRGDNI el cual compruebe antes de insertar un DNI si la letra del
-- mismo es correcta. Si no lo es que aparezca un mensaje de error, si lo es que la introduzca sin
-- mas y si por casualidad se ha puesto el DNI sin letra que el programa te la genere y la introduzca
-- dentro del DNI. (OPCIONAL)
-- CAST()
-- SUBSTRING()
-- % O MOD()
-- CONCAT()
DELIMITER //

CREATE TRIGGER TRGDNI 
BEFORE INSERT ON usuarios 
FOR EACH ROW 
BEGIN
	DECLARE num_dni INT;
	DECLARE letra_calc CHAR(1);
	DECLARE letras_dni VARCHAR(23) DEFAULT 'TRWAGMYFPDXBNJZSQVHLCKE';
	IF CHAR_LENGTH(NEW.DNI)=8 THEN
		SET num_dni = CAST(NEW.DNI AS UNSIGNED);
		SET letra_calc = SUBSTRING(letras_dni, MOD(num_dni,23) +1, 1);
		SET NEW.DNI = CONCAT(NEW.DNI, letra_calc);
	ELSEIF CHAR_LENGTH(NEW.DNI) = 9 THEN
		SET num_dni = CAST(SUBSTRING(NEW.DNI,1,8) AS UNSIGNED);
		SET letra_calc = SUBSTRING(letras_dni, MOD(num_dni, 23)+1,1);

		IF UPPER(SUBSTRING(NEW.DNI,9,1)) <> letra_calc THEN
			SIGNAL SQLSTATE '45000'
				SET MESSAGE_TEXT = 'Letra del DNI incorrecta';
		END IF;
        
	ELSE SIGNAL SQLSTATE '45000'
		SET MESSAGE_TEXT = 'Formato de DNI inválido';
	END IF;
END//

DELIMITER ;


-- Ejercicio 4
-- Supongamos que tenemos una base de datos de una EMPRESA y en ella tenemos una tabla
-- CLIENTES con los campos Id, Nombre, Apellidos e Id_empleado (un número que indica el código
-- del empleado que suele atender a este cliente). Realiza las siguientes operaciones con SQL:
-- a) Crea la tabla.
CREATE TABLE CLIENTES (
    id INT AUTO_INCREMENT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    id_empleado INT
);
-- b) Realiza un TRIGGER llamado ACTUALIZA_clientes125 para la tabla CLIENTES que en una
-- variable llamada clientes125 vaya contando el número de clientes que tiene asignados el empleado 125.
SET @clientes125 = 0;

DELIMITER //

CREATE TRIGGER ACTUALIZA_clientes125
AFTER INSERT ON CLIENTES
FOR EACH ROW
BEGIN
    IF NEW.id_empleado = 125 THEN
        SET @clientes125 = IFNULL(@clientes125, 0) + 1;
    END IF;
END//

DELIMITER ;
-- c) Inserta los siguientes registros en la tabla CLIENTES y observa el valor de la variable.
INSERT INTO CLIENTES (Nombre, Apellidos, Id_empleado) VALUES
('Antonio', 'García Sánchez', 125),
('María',  'Ruiz Bermúdez',   204),
('Laura',  'García Moreno',   125),
('Carmen', 'Pérez Labelda',   110),
('Rosa',   'Martos Palencia', 125),
('Juan',   'Sánchez Pons',    204);

SELECT @clientes125;
-- d) Crea una tabla nueva llamada CLIENTES_MODIF
-- en la que, cada vez que se cambie el empleado asignado a un cliente, se registren el nombre y
-- apellidos del cliente al que se la ha hecho el cambio, el antiguo empleado que tenía asignado, el
-- nuevo, el usuario que ha hecho la operación y el momento en el que se ha producido. Añade un
-- campo id al principio de la tabla que identifique cada operación.
CREATE TABLE CLIENTES_MODIF (
    Id INT AUTO_INCREMENT PRIMARY KEY,
    Nombre VARCHAR(50) NOT NULL,
    Apellidos VARCHAR(100) NOT NULL,
    Empleado_antiguo INT NOT NULL,
    Empleado_nuevo INT NOT NULL,
    Usuario VARCHAR(100) NOT NULL,
    Momento DATETIME NOT NULL
);
-- e) Crea un TRIGGER llamado CAMBIO_EMPLEADO que cuando se vaya a hacer un cambio en la
-- tabla CLIENTES registre los datos en CLIENTES_MODIF. Para registrar el usuario existe una
-- función, CURRENTUSER() que te devuelve el usuario actual. Y para el momento actual puedes
-- utilizar alguna función ya conocida.
DELIMITER //

CREATE TRIGGER CAMBIO_EMPLEADO
AFTER UPDATE ON CLIENTES
FOR EACH ROW
BEGIN
    IF OLD.Id_empleado != NEW.Id_empleado THEN
        INSERT INTO CLIENTES_MODIF (
            Nombre,
            Apellidos,
            Empleado_antiguo,
            Empleado_nuevo,
            Usuario,
            Momento
        ) VALUES (
            NEW.Nombre,
            NEW.Apellidos,
            OLD.Id_empleado,
            NEW.Id_empleado,
            CURRENT_USER(),
            NOW()
        );
    END IF;
END//

DELIMITER ;
-- f) Realiza los siguientes cambios en la tabla CLIENTES y visualiza después el contenido de la tabla CLIENTES_MODIF.
-- • Asigna a Laura García Moreno el empleado 110.
-- • Asigna a Carmen Pérez Labelda el empleado 125
UPDATE CLIENTES
SET id_empleado = 110
WHERE nombre = 'Laura'
  AND apellidos = 'García Moreno';

UPDATE CLIENTES
SET id_empleado = 125
WHERE nombre = 'Carmen'
  AND apellidos = 'Pérez Labelda';

-- Ejercicio 5
--  Cambia el campo Id de CLIENTES por el campo DNI. Crea en la misma un campo llamado
-- CONTRASEÑA y otro llamado TELÉFONO.
ALTER TABLE CLIENTES
CHANGE COLUMN Id DNI VARCHAR(9) NOT NULL;

ALTER TABLE CLIENTES
ADD COLUMN CONTRASEÑA VARCHAR(100),
ADD COLUMN TELÉFONO VARCHAR(15);

-- Ejercicio 6
-- Realiza un TRIGGER llamado TRIG5 para la tabla CLIENTES que verifique que cuando se
-- introducen los datos de un nuevo cliente, si hemos dejado la contraseña vacía, que genere
-- automáticamente una contraseña aleatoria. Una idea puede ser aplicarle alguna función al DNI
-- del cliente. La contraseña debe tener como mucho 10 caracteres. 
DELIMITER //

CREATE TRIGGER TRIG5
BEFORE INSERT ON CLIENTES
FOR EACH ROW
BEGIN
    IF NEW.CONTRASEÑA IS NULL OR TRIM(NEW.CONTRASEÑA) = '' THEN
        SET NEW.CONTRASEÑA = SUBSTRING(MD5(CONCAT(NEW.DNI, RAND())), 1, 10);
    END IF;
END//

DELIMITER ;

-- Ejercicio 7
-- Realiza un TRIGGER llamado TRIG6 para la tabla CLIENTES que cuando se introduzca un nuevo
-- cliente y el teléfono solo tenga 6 dígitos, lo complete con el prefijo de Granada. Piensa cómo
-- sería si el TELÉFONO es de tipo VARCHAR o si el TELÉFONO es INT.(OPCIONAL PERO RECOMENDABLE)
DELIMITER //

CREATE TRIGGER TRIG6
BEFORE INSERT ON CLIENTES
FOR EACH ROW
BEGIN
    IF NEW.TELÉFONO IS NOT NULL
       AND CHAR_LENGTH(NEW.TELÉFONO) = 6 THEN
        SET NEW.TELÉFONO = CONCAT('958', NEW.TELÉFONO);
    END IF;
END//

DELIMITER ;