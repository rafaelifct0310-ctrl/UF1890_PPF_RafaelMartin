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
    c.
