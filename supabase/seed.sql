-- =====================================================
-- SEED DATA for Development/Testing
-- PWA Microcréditos Offline-First
-- =====================================================

-- Insert demo tenant
INSERT INTO tenants (id, nombre, usuarios_contratados, usuarios_activos, activo)
VALUES 
  ('00000000-0000-0000-0000-000000000001', 'Microfinanzas Demo', 10, 3, true)
ON CONFLICT (id) DO NOTHING;

-- Insert demo rutas
INSERT INTO rutas (id, tenant_id, nombre, descripcion, activa)
VALUES 
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Ruta Centro', 'Zona centro de la ciudad', true),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Ruta Norte', 'Zona norte de la ciudad', true),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Ruta Sur', 'Zona sur de la ciudad', true)
ON CONFLICT (id) DO NOTHING;

-- Insert demo productos de crédito
INSERT INTO productos_credito (id, tenant_id, nombre, descripcion, interes_porcentaje, plazo_minimo, plazo_maximo, monto_minimo, monto_maximo, activo)
VALUES 
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Crédito Diario', 'Crédito con pago diario', 20.00, 30, 90, 100000, 1000000, true),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Crédito Semanal', 'Crédito con pago semanal', 15.00, 4, 24, 200000, 2000000, true),
  ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Crédito Mensual', 'Crédito con pago mensual', 10.00, 3, 12, 500000, 5000000, true)
ON CONFLICT (id) DO NOTHING;

-- Note: Users must be created through Supabase Auth first
-- After creating auth users, link them with this SQL:
-- 
-- Example for creating a demo cobrador:
-- 1. Create user in Supabase Auth dashboard with email: cobrador@demo.com
-- 2. Get the user UUID from auth.users
-- 3. Run this SQL:
--
-- INSERT INTO users (id, tenant_id, email, nombre, rol, activo)
-- VALUES 
--   ('USER_UUID_HERE', '00000000-0000-0000-0000-000000000001', 'cobrador@demo.com', 'Juan Cobrador', 'cobrador', true);

-- Insert demo clientes (after creating users)
-- Uncomment and adjust UUIDs after creating users
/*
INSERT INTO clientes (id, tenant_id, created_by, nombre, numero_documento, tipo_documento, telefono, direccion, ruta_id, latitud, longitud, estado)
VALUES 
  ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'USER_UUID_HERE', 'María García', '1234567890', 'CC', '3001234567', 'Calle 10 #20-30', '10000000-0000-0000-0000-000000000001', 4.6097, -74.0817, 'activo'),
  ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'USER_UUID_HERE', 'Pedro López', '0987654321', 'CC', '3009876543', 'Carrera 15 #25-40', '10000000-0000-0000-0000-000000000001', 4.6110, -74.0820, 'activo'),
  ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'USER_UUID_HERE', 'Ana Martínez', '1122334455', 'CC', '3112233445', 'Avenida 20 #30-50', '10000000-0000-0000-0000-000000000002', 4.6150, -74.0850, 'activo');
*/

-- Insert demo créditos (after creating users and clientes)
-- Uncomment and adjust UUIDs after creating users and clientes
/*
INSERT INTO creditos (
  id, tenant_id, cliente_id, producto_id, cobrador_id, ruta_id,
  monto_original, interes_porcentaje, total_a_pagar, numero_cuotas, valor_cuota,
  frecuencia, fecha_desembolso, fecha_primera_cuota, fecha_ultima_cuota,
  estado, saldo_pendiente, created_by
)
VALUES 
  (
    '40000000-0000-0000-0000-000000000001',
    '00000000-0000-0000-0000-000000000001',
    '30000000-0000-0000-0000-000000000001',
    '20000000-0000-0000-0000-000000000001',
    'USER_UUID_HERE',
    '10000000-0000-0000-0000-000000000001',
    500000,
    20.00,
    600000,
    60,
    10000,
    'diario',
    NOW(),
    NOW() + INTERVAL '1 day',
    NOW() + INTERVAL '60 days',
    'activo',
    600000,
    'USER_UUID_HERE'
  );
*/

-- Generate cuotas for the demo crédito
-- This would normally be done by the application
-- Uncomment after creating the crédito above
/*
INSERT INTO cuotas (credito_id, tenant_id, numero, valor, fecha_programada, estado)
SELECT 
  '40000000-0000-0000-0000-000000000001',
  '00000000-0000-0000-0000-000000000001',
  generate_series,
  10000,
  NOW() + (generate_series || ' days')::INTERVAL,
  'pendiente'
FROM generate_series(1, 60);
*/

-- =====================================================
-- Verification Queries
-- =====================================================

-- Check tenants
-- SELECT * FROM tenants;

-- Check rutas
-- SELECT * FROM rutas;

-- Check productos
-- SELECT * FROM productos_credito;

-- Check users (after creating them)
-- SELECT * FROM users;

-- Check clientes (after creating them)
-- SELECT * FROM clientes;

-- Check creditos (after creating them)
-- SELECT * FROM creditos;

-- Check cuotas (after creating them)
-- SELECT * FROM cuotas ORDER BY numero LIMIT 10;
