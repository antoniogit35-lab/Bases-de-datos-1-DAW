-- Ejercicio 1
-- Crea una tabla en la base de datos librerias llamada proveedores que tenga los campos id, nombre, direccion, telefono. Luego elimínala.
CREATE TABLE proveedores (
    id INT PRIMARY KEY,
    nombre VARCHAR(50) NOT NULL,
    direccion VARCHAR(50) NOT NULL,
    telefono VARCHAR(9) NOT NULL
);
DROP TABLE proveedores;

-- Ejercicio 2
-- Inserta 3 libros en la base de datos de LIBROS
INSERT INTO libros (id, titulo, autor_id, seccion_id, fecha_edicion, precio)
VALUES
  (4, 'El Quijote',      1, 1, '2005-01-01', 19.95),
  (5, 'Cien años de soledad', 2, 1, '2010-05-15', 24.50),
  (6, 'La sombra del viento', 3, 1, '2018-09-20', 17.99);


-- Ejercicio 3
-- Cambia el nombre del campo fecha de la tabla FACTURAS y ponle "fecha_factura".Investiga la instrucción que te va a permitir hacerlo
ALTER TABLE facturas CHANGE COLUMN fecha fecha_factura DATE;

-- Ejercicio 4
-- Borra el índice único de la tabla CLIENTES y vuelve a crearlo como índice, pero no único, sin tipo. No se trata de borrar el campo en sí, sino el índice definido sobre ese campo.
SHOW INDEX FROM clientes;
DROP INDEX apellidos ON clientes;
CREATE INDEX apellidos ON clientes (apellidos);

-- Ejercicio 5
-- Crea una vista que muestre los campos título, nombre del autor, nombre de la sección y precio de los libros
CREATE VIEW Campos_Libros (titulo, nombre_del_autor, nombre_de_la_seccion, precio_libro) AS
    SELECT 
        libros.titulo,
        autores.nombre,
        secciones.nombre,
        libros.precio
    FROM
        libros
            JOIN
        autores ON libros.autor_id = autores.id
            JOIN
        secciones ON libros.seccion_id = secciones.id;

-- Ejercicio 6
-- Crea una vista que muestre de cada libro su título, el número de veces que ha sido vendido, la suma de ventas del mismo, la cantidad máxima de unidades que se han comprado alguna vez.
-- Ponle un título a la cabecera de cada uno de los datos que muestre la vista.alter
CREATE VIEW Ejercicio_6 (título , veces_vendido , suma_ventas , max_unidades) AS
    SELECT 
        libros.titulo,
        SUM(libros_facturas.cantidad),
        SUM(libros_facturas.cantidad * libros_facturas.precio),
        MAX(libros_facturas.cantidad)
    FROM
        libros
            JOIN
        libros_facturas ON libros.id = libros_facturas.libro_id
        GROUP BY libros.titulo; 

-- Ejercicio 7
-- Muestre el contenido de la vista del ejercicio 6, pero solo de aquellos libros que el número de veces que se ha vendido ha sido 3 o más
SELECT 
    título, veces_vendido, suma_ventas, max_unidades
FROM Ejercicio_6
WHERE veces_vendido >= 3;
