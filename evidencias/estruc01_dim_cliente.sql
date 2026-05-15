-- ============================================================
-- RECREACIÓN: dw1.dim_cliente
-- Tipo : SCD Tipo 1
-- Modelo simplificado
-- ============================================================

DROP TABLE IF EXISTS dw1.dim_cliente CASCADE;

CREATE TABLE dw1.dim_cliente (

    -- PK surrogate del DW
    id_cliente SERIAL PRIMARY KEY,

    -- Clave natural Odoo
    cliente_origen_id INTEGER NOT NULL UNIQUE,

    -- Datos básicos
    nombre VARCHAR(150) NOT NULL,
    email  VARCHAR(150),

    -- Control ETL
    fecha_creacion      TIMESTAMP NOT NULL DEFAULT NOW(),
    fecha_actualizacion TIMESTAMP NOT NULL DEFAULT NOW()
);

-- ============================================================
-- ÍNDICE PRINCIPAL
-- ============================================================

CREATE INDEX idx_dim_cliente_origen
    ON dw1.dim_cliente (cliente_origen_id);

-- ============================================================
-- FUNCIÓN TIMESTAMP
-- ============================================================

CREATE OR REPLACE FUNCTION dw1.fn_actualizar_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.fecha_actualizacion = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ============================================================
-- TRIGGER
-- ============================================================

CREATE TRIGGER trg_dim_cliente_timestamp
    BEFORE UPDATE ON dw1.dim_cliente
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
  AND table_name   = 'dim_cliente'
ORDER BY ordinal_position;