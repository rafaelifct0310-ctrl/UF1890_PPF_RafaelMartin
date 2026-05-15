-- ============================================================
-- CARGA DE DIM_CLIENTE
-- Origen : Odoo res_partner
-- Tipo    : SCD Tipo 1
-- ============================================================

INSERT INTO dw1.dim_cliente (
    cliente_origen_id,
    nombre,
    email
)

SELECT
    rp.id,

    COALESCE(
        NULLIF(TRIM(rp.name), ''),
        'Cliente sin nombre'
    ) AS nombre,

    NULLIF(TRIM(rp.email), '') AS email

FROM res_partner rp

WHERE
    COALESCE(rp.customer_rank, 0) > 0
    AND COALESCE(rp.active, TRUE) = TRUE

ON CONFLICT (cliente_origen_id)

DO UPDATE SET
    nombre              = EXCLUDED.nombre,
    email               = EXCLUDED.email,
    fecha_actualizacion = NOW();


-- ============================================================
-- CARGA DE DIM_PRODUCTO
-- Compatible con Odoo 19
-- ============================================================

INSERT INTO dw1.dim_producto (
    producto_origen_id,
    nombre,
    categoria
)

SELECT
    pp.id AS producto_origen_id,

    -- product_template.name = JSONB
    COALESCE(
        NULLIF(
            TRIM(pt.name->>'es_ES'),
            ''
        ),
        'Producto sin nombre'
    ) AS nombre,

    -- product_category.name = VARCHAR
    NULLIF(
        TRIM(pc.name),
        ''
    ) AS categoria

FROM product_product pp

INNER JOIN product_template pt
    ON pt.id = pp.product_tmpl_id

LEFT JOIN product_category pc
    ON pc.id = pt.categ_id

WHERE
    COALESCE(pt.active, TRUE) = TRUE

ON CONFLICT (producto_origen_id)

DO UPDATE SET
    nombre              = EXCLUDED.nombre,
    categoria           = EXCLUDED.categoria,
    fecha_actualizacion = NOW();


-- ─────────────────────────────────────────────────────────────
-- BLOQUE 1: DESTINO
-- Indicamos en qué tabla y en qué columnas vamos a insertar.
-- El orden aquí debe coincidir exactamente con el SELECT luego.
-- ─────────────────────────────────────────────────────────────
INSERT INTO dw1.fact_ventas (
    venta_linea_origen_id,   -- PK natural del origen; usada para detectar duplicados
    id_cliente,              -- FK hacia dw1.dim_cliente
    id_producto,             -- FK hacia dw1.dim_producto
    fecha,                   -- Fecha de la venta (DATE, no FK a dim_fecha)
    cantidad,                -- Unidades vendidas
    precio,                  -- Precio unitario en el momento de la venta
    total                    -- Importe total = cantidad × precio
)

-- ─────────────────────────────────────────────────────────────
-- BLOQUE 2: SELECCIÓN DE DATOS
-- ─────────────────────────────────────────────────────────────
SELECT
    sol.id,                                      -- ID de la línea de pedido en Odoo
    dc.id_cliente,                               -- ID del cliente en la dimensión
    dp.id_producto,                              -- ID del producto en la dimensión
    so.date_order::DATE,                         -- Fecha del pedido (sin hora)
    sol.product_uom_qty,                         -- Cantidad vendida
    sol.price_unit,                              -- Precio unitario
    sol.product_uom_qty * sol.price_unit         -- Total calculado

-- ─────────────────────────────────────────────────────────────
-- BLOQUE 3: TABLAS ORIGEN Y JOINS
-- ─────────────────────────────────────────────────────────────
FROM sale_order_line sol

    JOIN sale_order so
        ON sol.order_id = so.id

    LEFT JOIN dw1.dim_cliente dc
        ON dc.cliente_origen_id = so.partner_id

    LEFT JOIN dw1.dim_producto dp
        ON dp.producto_origen_id = sol.product_id

-- ─────────────────────────────────────────────────────────────
-- BLOQUE 4: FILTROS
-- ─────────────────────────────────────────────────────────────
WHERE
    -- 4a. Solo pedidos confirmados o completados
    so.state IN ('sale', 'done')

    -- 4b. Filtro incremental por rango de fechas
    AND so.date_order BETWEEN :fecha_inicio AND :fecha_fin

    -- 4c. Integridad referencial (evitar NULLs en FKs)
    AND dc.id_cliente IS NOT NULL
    AND dp.id_producto IS NOT NULL

-- ─────────────────────────────────────────────────────────────
-- BLOQUE 5: CONTROL DE DUPLICADOS
-- ─────────────────────────────────────────────────────────────
ON CONFLICT (venta_linea_origen_id) DO NOTHING;