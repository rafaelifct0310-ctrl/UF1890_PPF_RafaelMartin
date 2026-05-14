-- ==================
-- Carga de Clientes
-- ==================
INSERT INTO dw1.dim_cliente (
    cliente_origen_id,
    nombre,
    email
)
SELECT 
    rp.id,
    COALESCE(NULLIF(TRIM(rp.name),''), 'Cliente sin nombre'),
    rp.email
FROM res_partner rp
WHERE rp.customer_rank > 0;

-- ===================
-- Carga de productos
-- ===================
INSERT INTO dw1.dim_producto (
    producto_origen_id,
    nombre,
    categoria
)
SELECT 
    pp.id,
    pt.name,
    pc.name
FROM product_product pp
JOIN product_template pt
    ON pp.product_tmpl_id = pt.id
LEFT JOIN product_category pc
    ON pt.categ_id = pc.id;


-- Carga de ventas
INSERT INTO dw1.fact_ventas (
    venta_linea_origen_id,
    id_cliente,
    id_producto,
    cantidad,
    precio,
    total,
    fecha
)
SELECT
    sol.id,
    dc.id_cliente,
    dp.id_producto,
    sol.product_uom_qty,
    sol.price_unit,
    sol.product_uom_qty * sol.price_unit,
    so.date_order::date
FROM sale_order_line sol
JOIN sale_order so
    ON sol.order_id = so.id
JOIN dw1.dim_cliente dc 
    ON dc.cliente_origen_id = so.partner_id
JOIN dw1.dim_producto dp
    ON dp.producto_origen_id = sol.product_id
WHERE so.state IN ('sale','done');
