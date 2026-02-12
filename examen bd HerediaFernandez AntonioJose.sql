-- A) GROUP BY Y HAVING
-- Ejercicio 1
 -- Cuenta cuántos pedidos hay por representante (rep) y muestra rep y total_pedidos. 9 filas
 SELECT 
    rep, COUNT(num_pedido) AS numero_pedidos
FROM
    pedidos
GROUP BY rep;

-- Ejercicio 2
--  Calcula el importe total vendido (SUM(importe)) por cliente (clie) y muéstralo ordenado de mayor a menor. 15 filas
SELECT 
    SUM(importe) AS importe_total
FROM
    pedidos
GROUP BY clie
ORDER BY importe_total DESC;

-- Ejercicio 3
--  Muestra las oficinas (oficina) con el total de ventas de sus representantes (SUM(repventas.ventas)) agrupado por oficina. 5 filas
SELECT 
    oficinas.oficina, SUM(repventas.ventas) total_ventas
FROM
    oficinas
        JOIN
    repventas ON oficinas.oficina = repventas.oficina_rep
GROUP BY oficinas.oficina;

-- Ejercicio 4
-- Devuelve los representantes (rep) cuyo importe total de pedidos (SUM(importe)) sea mayor que 20000 (usa HAVING). 7 filas
SELECT 
    rep, SUM(importe) AS importe_total
FROM
    pedidos
GROUP BY rep
HAVING importe_total > 20000;

-- Ejercicio 5
-- Devuelve los clientes (clie) que tengan 2 o más pedidos (COUNT(*)) (usa HAVING). 9 filas
SELECT 
    clie
FROM
    pedidos
GROUP BY clie
HAVING COUNT(*) >= 2;

-- Ejercicio 6
-- Para cada fabricante (fab), calcula el importe medio de pedido (AVG(importe)) y muestra solo los fabricantes con media > 5000 (HAVING). 3 filas
SELECT 
    fab, AVG(importe) AS importe_medio
FROM
    pedidos
GROUP BY fab
HAVING importe_medio > 5000;

-- Ejercicio 7
-- Muestra por ciudad de oficina (oficinas.ciudad) el número de representantes asignados (COUNT(repventas.num_empl)). 5 filas
SELECT 
    oficinas.ciudad,
    COUNT(repventas.num_empl) AS número_representantes
FROM
    oficinas
        JOIN
    repventas ON oficinas.oficina = repventas.oficina_rep
GROUP BY oficinas.ciudad;

-- Ejercicio 8
-- Muestra por región (oficinas.región) el total de pedidos (COUNT(pedidos.num_pedido)) realizados por representantes de oficinas de esa región. 2 filas
SELECT 
    oficinas.región, COUNT(pedidos.num_pedido) AS total_pedidos
FROM
    pedidos
        JOIN
    repventas ON pedidos.rep = repventas.num_empl
        JOIN
    oficinas ON repventas.oficina_rep = oficinas.oficina
GROUP BY oficinas.región;

-- Ejercicio 9
--  Para cada representante, muestra: total_pedidos, importe_total y el importe_medio; y filtra con HAVING los que tengan al menos 3 pedidos y un importe_total > 15000. 5 filas
SELECT 
    COUNT(num_pedido) AS total_pedidos,
    SUM(importe) AS importe_total,
    AVG(importe) AS importe_medio
FROM
    pedidos
GROUP BY rep
HAVING total_pedidos >= 3
    AND importe_total > 15000;

-- Ejercicio 10
-- Muestra las oficinas cuyo objetivo (oficinas.objetivo) se haya superado con las ventas reales de la oficina (usa SUM(repventas.ventas) 
-- agrupando por oficina y HAVING SUM(repventas.ventas) > oficinas.objetivo). 3 filas
SELECT 
    oficinas.oficina,
    oficinas.objetivo,
    SUM(repventas.ventas) AS ventas_reales
FROM
    oficinas
        JOIN
    repventas ON oficinas.oficina = repventas.oficina_rep
GROUP BY oficinas.oficina
HAVING (SUM(repventas.ventas) > oficinas.objetivo);

-- B) SUBCONSULTAS
-- Ejercicio 1
-- Muestra los representantes cuyo valor de ventas sea mayor que la media de ventas de todos los representantes. 5 filas
SELECT 
    *
FROM
    repventas
WHERE
    ventas > ALL(SELECT 
            AVG(ventas)
        FROM
            repventas);

-- Ejercicio 2
-- Muestra los productos cuyo precio sea mayor que el precio máximo de los productos del fabricante 'ACI'. 2 filas
SELECT 
    *
FROM
    productos
WHERE
    precio > (SELECT 
            MAX(precio)
        FROM
            productos
        WHERE
            id_fab = 'ACI');

-- Ejercicio 3
-- Muestra los clientes cuyo límite de crédito sea mayor que el límite de crédito medio de todos los clientes. 11 filas
SELECT 
    *
FROM
    clientes
WHERE
    límite_crédito > ALL (SELECT 
            AVG(límite_crédito)
        FROM
            clientes);

-- Ejercicio 4
-- Muestra las oficinas (oficina, ciudad) que no tengan ningún representante asignado (usa subconsulta). 0 filas
SELECT 
    oficinas.oficina, oficinas.ciudad
FROM
    oficinas
        JOIN
    repventas ON oficinas.oficina = repventas.oficina_rep
WHERE
    NOT EXISTS( SELECT 
            repventas.nombre
        FROM
            repventas
        WHERE
            oficina_rep IS NULL);

-- Ejercicio 5
-- Muestra los pedidos cuyo importe sea mayor que el importe medio de los pedidos del mismo cliente (subconsulta correlacionada). 9 filas
SELECT 
    *
FROM
    pedidos
WHERE
    importe > (SELECT 
            AVG(p2.importe)
        FROM
            pedidos p2
        WHERE
            pedidos.clie = p2.clie);

-- Ejercicio 6
-- Muestra los clientes que tengan al menos un pedido (usa EXISTS o NOT EXISTS). 15 filas
SELECT 
    *
FROM
    clientes
WHERE
    EXISTS( SELECT 
            *
        FROM
            pedidos
        WHERE
            clientes.num_clie = pedidos.clie);

-- Ejercicio 7
-- Muestra los representantes que atienden a algún cliente con límite de crédito > 60000 (usa subconsulta con IN o EXISTS). 3 filas
SELECT 
    *
FROM
    repventas
WHERE
    EXISTS( SELECT 
            *
        FROM
            clientes
        WHERE
            repventas.num_empl = clientes.rep_clie
                AND clientes.límite_crédito > 60000);

-- Ejercicio 8
-- Muestra los representantes que no han realizado ningún pedido (usa NOT EXISTS). 1 filas
SELECT 
    *
FROM
    repventas
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            pedidos
        WHERE
            repventas.num_empl = pedidos.rep);

-- Ejercicio 9
-- Muestra el/los cliente(s) con el mayor importe de pedido (si hay empate, deben salir todos) usando subconsulta. 1 fila
SELECT 
    empresa
FROM
    clientes
        JOIN
    pedidos ON clientes.num_clie = pedidos.clie
WHERE
    pedidos.importe = (SELECT 
            MAX(importe)
        FROM
            pedidos);

-- Ejercicio 10
-- Muestra las oficinas en las que todos los representantes tienen más de 40 años (usa NOT EXISTS). 2 filas
SELECT 
    *
FROM
    oficinas
WHERE
    NOT EXISTS( SELECT 
            *
        FROM
            repventas
        WHERE
            repventas.oficina_rep = oficinas.oficina
                AND edad <= 40);
