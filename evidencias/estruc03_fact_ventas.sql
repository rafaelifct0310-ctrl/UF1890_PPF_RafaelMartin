CREATE TABLE dw1.fact_ventas (
	id_venta SERIAL PRIMARY KEY,
	venta_linea_origen_id INTEGER UNIQUE NOT NULL,
	id_cliente INTEGER REFERENCES dw1.dim_cliente(id_cliente),
	id_producto INTEGER REFERENCES dw1.dim_producto(id_producto),
	cantidad NUMERIC(12,2),
	precio NUMERIC(12,2),
	total NUMERIC(12,2),
	fecha DATE
);
