-- =====================================================
-- SCHEMA: PWA Microcréditos Offline-First
-- Supabase PostgreSQL Database Schema
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- TABLE: tenants
-- =====================================================
CREATE TABLE IF NOT EXISTS tenants (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  nombre TEXT NOT NULL,
  usuarios_contratados INTEGER NOT NULL DEFAULT 1,
  usuarios_activos INTEGER NOT NULL DEFAULT 0,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- TABLE: users (extends Supabase auth.users)
-- =====================================================
CREATE TABLE IF NOT EXISTS users (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  email TEXT NOT NULL UNIQUE,
  nombre TEXT NOT NULL,
  rol TEXT NOT NULL CHECK (rol IN ('admin', 'cobrador', 'supervisor')),
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- TABLE: rutas
-- =====================================================
CREATE TABLE IF NOT EXISTS rutas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  activa BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, nombre)
);

-- =====================================================
-- TABLE: productos_credito
-- =====================================================
CREATE TABLE IF NOT EXISTS productos_credito (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  nombre TEXT NOT NULL,
  descripcion TEXT,
  interes_porcentaje DECIMAL(5, 2) NOT NULL,
  plazo_minimo INTEGER NOT NULL,
  plazo_maximo INTEGER NOT NULL,
  monto_minimo DECIMAL(12, 2) NOT NULL,
  monto_maximo DECIMAL(12, 2) NOT NULL,
  activo BOOLEAN NOT NULL DEFAULT true,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, nombre)
);

-- =====================================================
-- TABLE: clientes
-- =====================================================
CREATE TABLE IF NOT EXISTS clientes (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  created_by UUID NOT NULL REFERENCES users(id),
  nombre TEXT NOT NULL,
  numero_documento TEXT NOT NULL,
  tipo_documento TEXT NOT NULL CHECK (tipo_documento IN ('CC', 'CE', 'TI', 'NIT', 'PASAPORTE')),
  telefono TEXT NOT NULL,
  telefono_2 TEXT,
  direccion TEXT NOT NULL,
  barrio TEXT,
  referencia TEXT,
  ruta_id UUID NOT NULL REFERENCES rutas(id),
  latitud DECIMAL(10, 8),
  longitud DECIMAL(11, 8),
  nombre_fiador TEXT,
  telefono_fiador TEXT,
  creditos_activos INTEGER NOT NULL DEFAULT 0,
  saldo_total DECIMAL(12, 2) NOT NULL DEFAULT 0,
  dias_atraso_max INTEGER NOT NULL DEFAULT 0,
  estado TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'inactivo', 'bloqueado')),
  score INTEGER,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(tenant_id, numero_documento)
);

-- =====================================================
-- TABLE: creditos
-- =====================================================
CREATE TABLE IF NOT EXISTS creditos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  producto_id UUID NOT NULL REFERENCES productos_credito(id),
  cobrador_id UUID NOT NULL REFERENCES users(id),
  ruta_id UUID NOT NULL REFERENCES rutas(id),
  monto_original DECIMAL(12, 2) NOT NULL,
  interes_porcentaje DECIMAL(5, 2) NOT NULL,
  total_a_pagar DECIMAL(12, 2) NOT NULL,
  numero_cuotas INTEGER NOT NULL,
  valor_cuota DECIMAL(12, 2) NOT NULL,
  frecuencia TEXT NOT NULL CHECK (frecuencia IN ('diario', 'semanal', 'quincenal', 'mensual')),
  fecha_desembolso TIMESTAMPTZ NOT NULL,
  fecha_primera_cuota TIMESTAMPTZ NOT NULL,
  fecha_ultima_cuota TIMESTAMPTZ NOT NULL,
  estado TEXT NOT NULL DEFAULT 'activo' CHECK (estado IN ('activo', 'pagado', 'vencido', 'cancelado')),
  saldo_pendiente DECIMAL(12, 2) NOT NULL,
  cuotas_pagadas INTEGER NOT NULL DEFAULT 0,
  dias_atraso INTEGER NOT NULL DEFAULT 0,
  excluir_domingos BOOLEAN NOT NULL DEFAULT false,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES users(id),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- =====================================================
-- TABLE: cuotas
-- =====================================================
CREATE TABLE IF NOT EXISTS cuotas (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  credito_id UUID NOT NULL REFERENCES creditos(id) ON DELETE CASCADE,
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  numero INTEGER NOT NULL,
  valor DECIMAL(12, 2) NOT NULL,
  fecha_programada TIMESTAMPTZ NOT NULL,
  fecha_pago TIMESTAMPTZ,
  monto_pagado DECIMAL(12, 2) NOT NULL DEFAULT 0,
  estado TEXT NOT NULL DEFAULT 'pendiente' CHECK (estado IN ('pendiente', 'pagada', 'vencida')),
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  UNIQUE(credito_id, numero)
);

-- =====================================================
-- TABLE: pagos
-- =====================================================
CREATE TABLE IF NOT EXISTS pagos (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
  credito_id UUID NOT NULL REFERENCES creditos(id) ON DELETE CASCADE,
  cliente_id UUID NOT NULL REFERENCES clientes(id) ON DELETE CASCADE,
  cobrador_id UUID NOT NULL REFERENCES users(id),
  monto DECIMAL(12, 2) NOT NULL,
  fecha TIMESTAMPTZ NOT NULL,
  latitud DECIMAL(10, 8) NOT NULL,
  longitud DECIMAL(11, 8) NOT NULL,
  observaciones TEXT,
  comprobante_foto_url TEXT,
  device_id TEXT NOT NULL,
  app_version TEXT NOT NULL,
  created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  created_by UUID NOT NULL REFERENCES users(id)
);

-- =====================================================
-- INDEXES for Performance
-- =====================================================

-- Users indexes
CREATE INDEX idx_users_tenant_id ON users(tenant_id);
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_tenant_activo ON users(tenant_id, activo);

-- Rutas indexes
CREATE INDEX idx_rutas_tenant_id ON rutas(tenant_id);
CREATE INDEX idx_rutas_tenant_activa ON rutas(tenant_id, activa);

-- Clientes indexes
CREATE INDEX idx_clientes_tenant_id ON clientes(tenant_id);
CREATE INDEX idx_clientes_ruta_id ON clientes(ruta_id);
CREATE INDEX idx_clientes_numero_documento ON clientes(numero_documento);
CREATE INDEX idx_clientes_tenant_ruta ON clientes(tenant_id, ruta_id);
CREATE INDEX idx_clientes_tenant_estado ON clientes(tenant_id, estado);

-- Productos indexes
CREATE INDEX idx_productos_tenant_id ON productos_credito(tenant_id);
CREATE INDEX idx_productos_tenant_activo ON productos_credito(tenant_id, activo);

-- Creditos indexes
CREATE INDEX idx_creditos_tenant_id ON creditos(tenant_id);
CREATE INDEX idx_creditos_cliente_id ON creditos(cliente_id);
CREATE INDEX idx_creditos_cobrador_id ON creditos(cobrador_id);
CREATE INDEX idx_creditos_ruta_id ON creditos(ruta_id);
CREATE INDEX idx_creditos_tenant_estado ON creditos(tenant_id, estado);
CREATE INDEX idx_creditos_cliente_estado ON creditos(cliente_id, estado);
CREATE INDEX idx_creditos_cobrador_estado ON creditos(cobrador_id, estado);

-- Cuotas indexes
CREATE INDEX idx_cuotas_credito_id ON cuotas(credito_id);
CREATE INDEX idx_cuotas_tenant_id ON cuotas(tenant_id);
CREATE INDEX idx_cuotas_credito_numero ON cuotas(credito_id, numero);
CREATE INDEX idx_cuotas_credito_estado ON cuotas(credito_id, estado);
CREATE INDEX idx_cuotas_fecha_programada ON cuotas(fecha_programada);

-- Pagos indexes
CREATE INDEX idx_pagos_tenant_id ON pagos(tenant_id);
CREATE INDEX idx_pagos_credito_id ON pagos(credito_id);
CREATE INDEX idx_pagos_cliente_id ON pagos(cliente_id);
CREATE INDEX idx_pagos_cobrador_id ON pagos(cobrador_id);
CREATE INDEX idx_pagos_tenant_fecha ON pagos(tenant_id, fecha);
CREATE INDEX idx_pagos_credito_fecha ON pagos(credito_id, fecha);
CREATE INDEX idx_pagos_cobrador_fecha ON pagos(cobrador_id, fecha);

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES
-- =====================================================

-- Enable RLS on all tables
ALTER TABLE tenants ENABLE ROW LEVEL SECURITY;
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE rutas ENABLE ROW LEVEL SECURITY;
ALTER TABLE productos_credito ENABLE ROW LEVEL SECURITY;
ALTER TABLE clientes ENABLE ROW LEVEL SECURITY;
ALTER TABLE creditos ENABLE ROW LEVEL SECURITY;
ALTER TABLE cuotas ENABLE ROW LEVEL SECURITY;
ALTER TABLE pagos ENABLE ROW LEVEL SECURITY;

-- Tenants policies
CREATE POLICY "Users can view their own tenant"
  ON tenants FOR SELECT
  USING (id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- Users policies
CREATE POLICY "Users can view users in their tenant"
  ON users FOR SELECT
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- Rutas policies
CREATE POLICY "Users can view rutas in their tenant"
  ON rutas FOR SELECT
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Admins can insert rutas"
  ON rutas FOR INSERT
  WITH CHECK (
    tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid())
    AND (SELECT rol FROM users WHERE id = auth.uid()) = 'admin'
  );

-- Productos policies
CREATE POLICY "Users can view productos in their tenant"
  ON productos_credito FOR SELECT
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- Clientes policies
CREATE POLICY "Users can view clientes in their tenant"
  ON clientes FOR SELECT
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can insert clientes in their tenant"
  ON clientes FOR INSERT
  WITH CHECK (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can update clientes in their tenant"
  ON clientes FOR UPDATE
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- Creditos policies
CREATE POLICY "Users can view creditos in their tenant"
  ON creditos FOR SELECT
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can insert creditos in their tenant"
  ON creditos FOR INSERT
  WITH CHECK (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

CREATE POLICY "Users can update creditos in their tenant"
  ON creditos FOR UPDATE
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- Cuotas policies
CREATE POLICY "Users can view cuotas in their tenant"
  ON cuotas FOR SELECT
  USING (tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid()));

-- Pagos policies
CREATE POLICY "Users can view pagos in their tenant"
  ON pagos FOR SELECT
  USING (
    tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid())
    AND (
      cobrador_id = auth.uid()
      OR (SELECT rol FROM users WHERE id = auth.uid()) IN ('admin', 'supervisor')
    )
  );

CREATE POLICY "Cobradores can insert their own pagos"
  ON pagos FOR INSERT
  WITH CHECK (
    tenant_id = (SELECT tenant_id FROM users WHERE id = auth.uid())
    AND cobrador_id = auth.uid()
  );

-- =====================================================
-- FUNCTIONS for updated_at timestamps
-- =====================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply triggers to all tables with updated_at
CREATE TRIGGER update_tenants_updated_at BEFORE UPDATE ON tenants
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_rutas_updated_at BEFORE UPDATE ON rutas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_productos_updated_at BEFORE UPDATE ON productos_credito
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_clientes_updated_at BEFORE UPDATE ON clientes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_creditos_updated_at BEFORE UPDATE ON creditos
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_cuotas_updated_at BEFORE UPDATE ON cuotas
  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- =====================================================
-- SEED DATA (Optional - for development)
-- =====================================================

-- Insert demo tenant
INSERT INTO tenants (id, nombre, usuarios_contratados, usuarios_activos)
VALUES ('00000000-0000-0000-0000-000000000001', 'Demo Tenant', 10, 1)
ON CONFLICT (id) DO NOTHING;

-- Note: Users must be created through Supabase Auth first
-- Then linked to this table with their tenant_id
