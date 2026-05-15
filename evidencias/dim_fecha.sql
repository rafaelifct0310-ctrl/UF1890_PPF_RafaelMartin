-- ============================================================
-- CREACIÓN: dw1.dim_fecha
-- Generada sintéticamente: NO viene de Odoo
-- Rango: ajusta fecha_inicio y fecha_fin según tu negocio
-- ============================================================

CREATE TABLE dw1.dim_fecha (

    -- PK en formato YYYYMMDD: fácil de leer y muy eficiente
    id_fecha            INTEGER         PRIMARY KEY,

    -- Fecha base
    fecha               DATE            NOT NULL UNIQUE,

    -- Descomposición temporal
    anio                SMALLINT        NOT NULL,
    trimestre           SMALLINT        NOT NULL CHECK (trimestre BETWEEN 1 AND 4),
    mes                 SMALLINT        NOT NULL CHECK (mes BETWEEN 1 AND 12),
    semana              SMALLINT        NOT NULL CHECK (semana BETWEEN 1 AND 53),
    dia_mes             SMALLINT        NOT NULL CHECK (dia_mes BETWEEN 1 AND 31),
    dia_semana          SMALLINT        NOT NULL CHECK (dia_semana BETWEEN 1 AND 7),

    -- Nombres descriptivos (útiles en reportes)
    nombre_mes          VARCHAR(20)     NOT NULL,
    nombre_dia          VARCHAR(20)     NOT NULL,

    -- Flags de análisis
    es_fin_de_semana    BOOLEAN         NOT NULL DEFAULT FALSE,
    es_festivo          BOOLEAN         NOT NULL DEFAULT FALSE
);

-- ============================================================
-- POBLACIÓN: genera un registro por día
-- Ajusta el rango según tus datos históricos en Odoo
-- ============================================================

INSERT INTO dw1.dim_fecha (
    id_fecha,
    fecha,
    anio,
    trimestre,
    mes,
    semana,
    dia_mes,
    dia_semana,
    nombre_mes,
    nombre_dia,
    es_fin_de_semana
)
SELECT
    -- ID en formato YYYYMMDD: ej. 20240315
    TO_CHAR(d, 'YYYYMMDD')::INTEGER,

    d::DATE,

    EXTRACT(YEAR    FROM d)::SMALLINT,
    EXTRACT(QUARTER FROM d)::SMALLINT,
    EXTRACT(MONTH   FROM d)::SMALLINT,
    EXTRACT(WEEK    FROM d)::SMALLINT,
    EXTRACT(DAY     FROM d)::SMALLINT,

    -- 1 = lunes … 7 = domingo (ISO)
    EXTRACT(ISODOW  FROM d)::SMALLINT,

    -- Nombres en español
    TO_CHAR(d, 'TMMonth'),
    TO_CHAR(d, 'TMDay'),

    -- Fin de semana si es sábado (6) o domingo (7)
    EXTRACT(ISODOW FROM d) IN (6, 7)

-- Genera una fila por día en el rango indicado
FROM GENERATE_SERIES(
    '2020-01-01'::DATE,   -- ← ajusta: fecha más antigua de tus ventas en Odoo
    '2027-12-31'::DATE,   -- ← ajusta: horizonte futuro deseado
    '1 day'::INTERVAL
) AS d;

-- ============================================================
-- ÍNDICES: aceleran JOINs y filtros temporales en análisis
-- ============================================================

CREATE INDEX idx_dim_fecha_fecha     ON dw1.dim_fecha (fecha);
CREATE INDEX idx_dim_fecha_anio_mes  ON dw1.dim_fecha (anio, mes);
CREATE INDEX idx_dim_fecha_trimestre ON dw1.dim_fecha (anio, trimestre);

-- ============================================================
-- VERIFICACIÓN
-- ============================================================

SELECT COUNT(*)         AS total_dias,
       MIN(fecha)       AS desde,
       MAX(fecha)       AS hasta
FROM dw1.dim_fecha;