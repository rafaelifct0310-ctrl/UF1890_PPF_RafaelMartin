-- ============================================================
-- RECREACIÓN: dw1.dim_producto
-- Tipo : SCD Tipo 1
-- Modelo simplificado
-- ============================================================

DROP TABLE IF EXISTS dw1.dim_producto CASCADE;

CREATE TABLE dw1.dim_producto (

    -- PK surrogate del DW
    id_producto SERIAL PRIMARY KEY,

    -- Clave natural Odoo
    producto_origen_id INTEGER NOT NULL UNIQUE,

    -- Datos básicos
    nombre   VARCHAR(150) NOT NULL,
    categoria VARCHAR(150),

    -- Control ETL
    fecha_creacion      TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ÍNDICES
-- ============================================================

CREATE INDEX idx_dim_producto_origen
    ON dw1.dim_producto (producto_origen_id);

CREATE INDEX idx_dim_producto_categoria
    ON dw1.dim_producto (categoria);

-- ============================================================
-- TRIGGER TIMESTAMP
-- Reutiliza:
-- dw1.fn_actualizar_timestamp()
-- ============================================================

CREATE TRIGGER trg_dim_producto_timestamp
    BEFORE UPDATE ON dw1.dim_producto
    FOR EACH ROW
    EXECUTE FUNCTION dw1.fn_actualizar_timestamp();

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

SELECT
    ordinal_position AS pos,
    column_name,
    data_type,
    character_maximum_length AS largo,
    column_default,
    is_nullable
FROM information_schema.columns
WHERE table_schema = 'dw1'
  AND table_name   = 'dim_producto'
ORDER BY ordinal_position;