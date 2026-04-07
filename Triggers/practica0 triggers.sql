-- Ejercicio 1
-- Crear un Trigger al que cuando ingreses un numero cualquiera en una
-- columna, este ingrese el doble del numero inicial.
DELIMITER //
CREATE TRIGGER duplicarNumero
BEFORE INSERT ON oficinas
FOR EACH ROW
BEGIN
	SET NEW.objetivo = NEW.objetivo * 2;
END //

DELIMITER ;

-- Ejercicio 2
-- Crear un Trigger al cual al número ingresado se le sume justo el
-- anterior, siendo el anterior ordenados por su ID.
DELIMITER //
CREATE TRIGGER sumaAnterior
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN
	IF NEW.id!=1 THEN
		SET NEW.cant = (SELECT cant FROM pedidos WHERE id = NEW.id) +NEW.cant;
	END IF;
END //

DELIMITER ;

-- Ejercicio 3
-- Crear un trigger el cual si una cantidad es menor que 1000
-- directamente se ingrese el número 1000.
DELIMITER //
CREATE TRIGGER cambiarCantidad
BEFORE INSERT ON pedidos
FOR EACH ROW
BEGIN 
	IF NEW.cant < 1000 THEN
		SET cant = 1000;
	END IF;
END //

DELIMITER ; 

-- Ejercicio 4
-- Ahora al anterior, si ingresáramos un numero negativo que aparezca un error.
-- SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = ‘mensaje que queremos indicar’;
DELIMITER //
CREATE TRIGGER mensajeError
BEFORE INSERT ON existencias
FOR EACH ROW
BEGIN
	IF NEW.existencias < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número no puede ser negativo'
	END IF;
END;

DELIMITER ;

-- Ejercicio 5
-- Ahora al anterior, vamos a añadir que si es cualquier otro número,
-- que se duplique la cantidad introducida.
DELIMITER //
CREATE TRIGGER mensajeError
BEFORE INSERT ON existencias
FOR EACH ROW
BEGIN
	IF NEW.existencias < 0 THEN
		SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El número no puede ser negativo';
	ELSE NEW.existencias = NEW.existencias * 2;
	END IF;
END;

DELIMITER ;

-- Ejercicio 6
-- Un trigger que evita que se inserten registros en la tabla “usuarios" si
-- el correo electrónico proporcionado no tiene un formato válido:
DELIMITER //
CREATE TRIGGER validarEmail
BEFORE INSERT ON usuarios
FOR EACH ROW
BEGIN
  IF (NEW.email NOT LIKE '%@%.%') THEN
    SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El email no tiene el formato correcto';
  END IF;
END //

DELIMITER ; 
