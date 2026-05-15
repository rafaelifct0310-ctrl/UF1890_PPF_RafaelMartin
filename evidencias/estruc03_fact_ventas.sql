-- ============================================================
-- RECREACIÓN: dw1.fact_ventas
-- Modelo simplificado
-- Fecha almacenada directamente
-- ============================================================

DROP TABLE IF EXISTS dw1.fact_ventas CASCADE;

CREATE TABLE dw1.fact_ventas (

    -- PK surrogate
    id_venta SERIAL PRIMARY KEY,

    -- Clave natural Odoo
    venta_linea_origen_id INTEGER NOT NULL UNIQUE,

    -- FK dimensiones
    id_cliente  INTEGER NOT NULL,
    id_producto INTEGER NOT NULL,

    -- Fecha de la venta
    fecha DATE NOT NULL,

    -- Métricas
    cantidad NUMERIC(12,2) NOT NULL,
    precio   NUMERIC(12,2) NOT NULL,
    total    NUMERIC(12,2) NOT NULL,

    -- ========================================================
    -- FOREIGN KEYS
    -- ========================================================

    CONSTRAINT fk_fact_ventas_cliente
        FOREIGN KEY (id_cliente)
        REFERENCES dw1.dim_cliente (id_cliente),

    CONSTRAINT fk_fact_ventas_producto
        FOREIGN KEY (id_producto)
        REFERENCES dw1.dim_producto (id_producto)
);

-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX idx_fact_ventas_cliente
    ON dw1.fact_ventas (id_cliente);

CREATE INDEX idx_fact_ventas_producto
    ON dw1.fact_ventas (id_producto);

CREATE INDEX idx_fact_ventas_fecha
    ON dw1.fact_ventas (fecha);

CREATE INDEX idx_fact_ventas_origen
    ON dw1.fact_ventas (venta_linea_origen_id);

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

SELECT
    ordinal_position AS pos,
    column_name,
    data_type,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'dw1'
  AND table_name   = 'fact_ventas'
ORDER BY ordinal_position;