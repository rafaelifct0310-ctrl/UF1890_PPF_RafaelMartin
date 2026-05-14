CREATE TABLE dw1.dim_cliente (
	id_cliente SERIAL PRIMARY KEY,
	cliente_origen_id INTEGER UNIQUE NOT NULL,
	nombre VARCHAR(150),
	email VARCHAR(150)
);