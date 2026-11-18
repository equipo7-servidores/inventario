-- ============================================================
--  Script de inicialización de la base de datos "inventario"
--  MySQL lo ejecuta automáticamente SOLO la primera vez,
--  cuando el volumen datos_mysql está vacío.
-- ============================================================

SET NAMES utf8mb4;
USE inventario;

CREATE TABLE IF NOT EXISTS equipos (
    id              INT AUTO_INCREMENT PRIMARY KEY,
    nombre          VARCHAR(100) NOT NULL,
    tipo ENUM('Diagnóstico por imagen','Esterilización','Cómputo',
          'Impresión','Redes','Seguridad','Otro') NOT NULL,
    marca           VARCHAR(50)  NOT NULL,
    numero_serie    VARCHAR(50)  NOT NULL UNIQUE,
    ubicacion       VARCHAR(100) NOT NULL,
    estado ENUM('Operativo','En mantenimiento','En calibración',
            'Fuera de servicio','Dado de baja')
       NOT NULL DEFAULT 'Operativo',
    fecha_registro  TIMESTAMP DEFAULT CURRENT_TIMESTAMP
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4;

-- Registros de ejemplo (datos ficticios)
INSERT INTO equipos (nombre, tipo, marca, numero_serie, ubicacion, estado) VALUES
('Equipo de rayos X digital', 'Diagnóstico por imagen', 'Carestream', 'PV-001', 'Sala de rayos X',   'Operativo'),
('Ultrasonido portátil',      'Diagnóstico por imagen', 'Mindray',    'PV-002', 'Consultorio 1',     'En calibración'),
('Autoclave de 18 litros',    'Esterilización',         'Tuttnauer',  'PV-003', 'Quirófano',         'En mantenimiento'),
('Laptop de recepción',       'Cómputo',                'Dell',       'PV-004', 'Recepción',         'Operativo'),
('Impresora de etiquetas',    'Impresión',              'Zebra',      'PV-005', 'Farmacia',          'Fuera de servicio'),
('Router principal',          'Redes',                  'TP-Link',    'PV-006', 'Cuarto de redes',   'Operativo'),
('Cámara de entrada',         'Seguridad',              'Hikvision',  'PV-007', 'Entrada principal', 'Operativo'),
('Computadora consultorio 2', 'Cómputo',                'HP',         'PV-008', 'Consultorio 2',     'Dado de baja');
