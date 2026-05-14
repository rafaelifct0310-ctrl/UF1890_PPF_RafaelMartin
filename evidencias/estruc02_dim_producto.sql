CREATE TABLE dw1.dim_producto (
	id_producto SERIAL PRIMARY KEY,
	producto_origen_id INTEGER UNIQUE NOT NULL,
	nombre VARCHAR(150),
	categoria VARCHAR(150)
);