-- =====================================================
-- SEED DATA - Execute AFTER creating auth users
-- =====================================================

-- Step 1: Create rutas
INSERT INTO rutas (id, tenant_id, nombre, descripcion, activa)
VALUES 
  ('10000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Ruta Centro', 'Zona centro de la ciudad', true),
  ('10000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Ruta Norte', 'Zona norte de la ciudad', true),
  ('10000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Ruta Sur', 'Zona sur de la ciudad', true)
ON CONFLICT (id) DO NOTHING;

-- Step 2: Create productos de crédito
INSERT INTO productos_credito (id, tenant_id, nombre, descripcion, interes_porcentaje, plazo_minimo, plazo_maximo, monto_minimo, monto_maximo, activo)
VALUES 
  ('20000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'Crédito Diario', 'Crédito con pago diario', 20.00, 30, 90, 100000, 1000000, true),
  ('20000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'Crédito Semanal', 'Crédito con pago semanal', 15.00, 4, 24, 200000, 2000000, true),
  ('20000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'Crédito Mensual', 'Crédito con pago mensual', 10.00, 3, 12, 500000, 5000000, true)
ON CONFLICT (id) DO NOTHING;

-- Step 3: Link auth user to users table
-- IMPORTANT: Replace 'YOUR_AUTH_USER_UUID' with the actual UUID from auth.users
-- You can get this from: SELECT id, email FROM auth.users;

-- Example (uncomment and replace UUID):
-- INSERT INTO users (id, tenant_id, email, nombre, rol, activo)
-- VALUES 
--   ('YOUR_AUTH_USER_UUID', '00000000-0000-0000-0000-000000000001', 'cobrador@demo.com', 'Juan Cobrador', 'cobrador', true)
-- ON CONFLICT (id) DO NOTHING;

-- Step 4: Create demo clientes (after linking user)
-- IMPORTANT: Replace 'YOUR_AUTH_USER_UUID' with the actual UUID

-- Example (uncomment and replace UUID):
-- INSERT INTO clientes (id, tenant_id, created_by, nombre, numero_documento, tipo_documento, telefono, direccion, ruta_id, latitud, longitud, estado)
-- VALUES 
--   ('30000000-0000-0000-0000-000000000001', '00000000-0000-0000-0000-000000000001', 'YOUR_AUTH_USER_UUID', 'María García', '1234567890', 'CC', '3001234567', 'Calle 10 #20-30', '10000000-0000-0000-0000-000000000001', 4.6097, -74.0817, 'activo'),
--   ('30000000-0000-0000-0000-000000000002', '00000000-0000-0000-0000-000000000001', 'YOUR_AUTH_USER_UUID', 'Pedro López', '0987654321', 'CC', '3009876543', 'Carrera 15 #25-40', '10000000-0000-0000-0000-000000000001', 4.6110, -74.0820, 'activo'),
--   ('30000000-0000-0000-0000-000000000003', '00000000-0000-0000-0000-000000000001', 'YOUR_AUTH_USER_UUID', 'Ana Martínez', '1122334455', 'CC', '3112233445', 'Avenida 20 #30-50', '10000000-0000-0000-0000-000000000002', 4.6150, -74.0850, 'activo')
-- ON CONFLICT (id) DO NOTHING;

-- Verification queries
SELECT 'Tenants:' as table_name, COUNT(*) as count FROM tenants
UNION ALL
SELECT 'Rutas:', COUNT(*) FROM rutas
UNION ALL
SELECT 'Productos:', COUNT(*) FROM productos_credito
UNION ALL
SELECT 'Users:', COUNT(*) FROM users
UNION ALL
SELECT 'Clientes:', COUNT(*) FROM clientes;
