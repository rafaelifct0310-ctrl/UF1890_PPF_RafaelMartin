-- Consulta Clientes ERP
SELECT * FROM public.res_partner LIMIT 10;

-- Consuta Productos ERP
SELECT * FROM public.product_product LIMIT 10;

-- Consulta Ventas ERP
SELECT * FROM public.sale_order_line LIMIT 10;

-- ========================
-- Consultas analíticas
-- ========================

-- Ventas por clientes
SELECT 
    c.nombre,
    SUM(f.total) AS ventas_totales
FROM dw1.fact_ventas f
JOIN dw1.dim_cliente c
    ON f.id_cliente = c.id_cliente
GROUP BY c.nombre
ORDER BY ventas_totales DESC;

