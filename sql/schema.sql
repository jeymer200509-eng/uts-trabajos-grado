-- =====================================================================
-- SISTEMA DE GESTIÓN Y SEGUIMIENTO DE TRABAJOS DE GRADO
-- UNIDADES TECNOLÓGICAS DE SANTANDER (UTS)
-- Script DDL y DML compatible con MySQL / MariaDB (XAMPP)
-- =====================================================================

DROP DATABASE IF EXISTS uts_trabajos_grado;
CREATE DATABASE uts_trabajos_grado CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
USE uts_trabajos_grado;

-- ---------------------------------------------------------------------
-- 1. TABLA: roles
-- ---------------------------------------------------------------------
CREATE TABLE roles (
    id_rol INT AUTO_INCREMENT PRIMARY KEY,
    nombre_rol VARCHAR(50) NOT NULL UNIQUE,
    descripcion VARCHAR(255) NOT NULL
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 2. TABLA: programas
-- ---------------------------------------------------------------------
CREATE TABLE programas (
    id_programa INT AUTO_INCREMENT PRIMARY KEY,
    codigo_programa VARCHAR(20) NOT NULL UNIQUE,
    nombre_programa VARCHAR(150) NOT NULL,
    nivel ENUM('Tecnología', 'Profesional') NOT NULL DEFAULT 'Tecnología'
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 3. TABLA: usuarios
-- ---------------------------------------------------------------------
CREATE TABLE usuarios (
    id_usuario INT AUTO_INCREMENT PRIMARY KEY,
    id_rol INT NOT NULL,
    id_programa INT NULL,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    documento VARCHAR(30) NOT NULL UNIQUE,
    nombres VARCHAR(100) NOT NULL,
    apellidos VARCHAR(100) NOT NULL,
    correo VARCHAR(150) NOT NULL UNIQUE,
    clave VARCHAR(64) NOT NULL, -- SHA-256
    telefono VARCHAR(30) NULL,
    semestre INT NULL,
    activo TINYINT(1) NOT NULL DEFAULT 1,
    fecha_registro TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_usuario_rol FOREIGN KEY (id_rol) REFERENCES roles(id_rol) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_usuario_programa FOREIGN KEY (id_programa) REFERENCES programas(id_programa) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 4. TABLA: ideas (Banco de Ideas)
-- ---------------------------------------------------------------------
CREATE TABLE ideas (
    id_idea INT AUTO_INCREMENT PRIMARY KEY,
    id_programa INT NOT NULL,
    id_coordinador INT NOT NULL,
    titulo VARCHAR(255) NOT NULL,
    descripcion TEXT NOT NULL,
    linea_investigacion VARCHAR(150) NOT NULL,
    cupos INT NOT NULL DEFAULT 1,
    estado ENUM('Disponible', 'Asignada') NOT NULL DEFAULT 'Disponible',
    fecha_publicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_idea_programa FOREIGN KEY (id_programa) REFERENCES programas(id_programa) ON DELETE RESTRICT ON UPDATE CASCADE,
    CONSTRAINT fk_idea_coordinador FOREIGN KEY (id_coordinador) REFERENCES usuarios(id_usuario) ON DELETE RESTRICT ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 5. TABLA: anteproyectos
-- Un estudiante solo puede tener un anteproyecto activo (UNIQUE en id_estudiante)
-- ---------------------------------------------------------------------
CREATE TABLE anteproyectos (
    id_anteproyecto INT AUTO_INCREMENT PRIMARY KEY,
    id_estudiante INT NOT NULL UNIQUE,
    id_idea INT NULL,
    id_director INT NULL,
    id_evaluador INT NULL,
    titulo VARCHAR(255) NOT NULL,
    linea_investigacion VARCHAR(150) NOT NULL,
    planteamiento_problema TEXT NOT NULL,
    justificacion TEXT NULL,
    objetivo_general TEXT NOT NULL,
    objetivos_especificos TEXT NOT NULL,
    resumen TEXT NOT NULL,
    enlace_documento VARCHAR(500) NOT NULL,
    version VARCHAR(10) NOT NULL DEFAULT '1.0',
    estado ENUM(
        'Idea seleccionada',
        'Anteproyecto radicado',
        'En revisión por director',
        'Devuelto con observaciones',
        'Aprobado por director',
        'En revisión por evaluador',
        'Aprobado',
        'Rechazado',
        'En desarrollo',
        'Documento final entregado',
        'Sustentado'
    ) NOT NULL DEFAULT 'Anteproyecto radicado',
    enlace_documento_final VARCHAR(500) NULL,
    resumen_documento_final TEXT NULL,
    fecha_entrega_final DATETIME NULL,
    enlace_desprendible VARCHAR(500) NULL,
    enlace_aval_director VARCHAR(500) NULL,
    enlace_informe_director VARCHAR(500) NULL,
    enlace_acta_final VARCHAR(500) NULL,
    fecha_radicacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    fecha_actualizacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    CONSTRAINT fk_anteproyecto_estudiante FOREIGN KEY (id_estudiante) REFERENCES usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_anteproyecto_idea FOREIGN KEY (id_idea) REFERENCES ideas(id_idea) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_anteproyecto_director FOREIGN KEY (id_director) REFERENCES usuarios(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_anteproyecto_evaluador FOREIGN KEY (id_evaluador) REFERENCES usuarios(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 6. TABLA: historial_estados (Trazabilidad de ciclo de vida)
-- ---------------------------------------------------------------------
CREATE TABLE historial_estados (
    id_historial INT AUTO_INCREMENT PRIMARY KEY,
    id_anteproyecto INT NOT NULL,
    id_usuario INT NOT NULL,
    estado_anterior VARCHAR(60) NULL,
    estado_nuevo VARCHAR(60) NOT NULL,
    observacion TEXT NULL,
    fecha_cambio TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_historial_anteproyecto FOREIGN KEY (id_anteproyecto) REFERENCES anteproyectos(id_anteproyecto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_historial_usuario FOREIGN KEY (id_usuario) REFERENCES usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 7. TABLA: calificaciones
-- ---------------------------------------------------------------------
CREATE TABLE calificaciones (
    id_calificacion INT AUTO_INCREMENT PRIMARY KEY,
    id_anteproyecto INT NOT NULL,
    id_docente INT NOT NULL,
    tipo_evaluacion ENUM('Anteproyecto - Director', 'Anteproyecto - Evaluador', 'Documento Final - Director', 'Documento Final - Evaluador') NOT NULL,
    nota DECIMAL(3,1) NOT NULL, -- 0.0 a 5.0
    observaciones TEXT NOT NULL,
    estado_decision ENUM('Aprobado', 'Devuelto', 'Rechazado') NOT NULL,
    fecha_calificacion TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    CONSTRAINT fk_calificacion_anteproyecto FOREIGN KEY (id_anteproyecto) REFERENCES anteproyectos(id_anteproyecto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_calificacion_docente FOREIGN KEY (id_docente) REFERENCES usuarios(id_usuario) ON DELETE CASCADE ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 8. TABLA: sustentaciones
-- ---------------------------------------------------------------------
CREATE TABLE sustentaciones (
    id_sustentacion INT AUTO_INCREMENT PRIMARY KEY,
    id_anteproyecto INT NOT NULL UNIQUE,
    fecha_hora DATETIME NOT NULL,
    lugar_enlace VARCHAR(255) NOT NULL,
    jurado1_id INT NULL,
    jurado2_id INT NULL,
    nota_sustentacion DECIMAL(3,1) NULL,
    acta_numero VARCHAR(50) NULL,
    estado ENUM('Programada', 'Aprobada', 'Reprobada', 'Cancelada') NOT NULL DEFAULT 'Programada',
    observaciones TEXT NULL,
    CONSTRAINT fk_sustentacion_anteproyecto FOREIGN KEY (id_anteproyecto) REFERENCES anteproyectos(id_anteproyecto) ON DELETE CASCADE ON UPDATE CASCADE,
    CONSTRAINT fk_sustentacion_jurado1 FOREIGN KEY (jurado1_id) REFERENCES usuarios(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE,
    CONSTRAINT fk_sustentacion_jurado2 FOREIGN KEY (jurado2_id) REFERENCES usuarios(id_usuario) ON DELETE SET NULL ON UPDATE CASCADE
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 9. TABLA: calendario (Cronograma institucional)
-- ---------------------------------------------------------------------
CREATE TABLE calendario (
    id_evento INT AUTO_INCREMENT PRIMARY KEY,
    titulo VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    tipo_etapa ENUM('Radicacion', 'Revision_Director', 'Revision_Evaluador', 'Sustentacion', 'General') NOT NULL DEFAULT 'General',
    fecha_inicio DATE NOT NULL,
    fecha_fin DATE NOT NULL,
    estado ENUM('Activo', 'Finalizado', 'Proximo') NOT NULL DEFAULT 'Activo'
) ENGINE=InnoDB;

-- ---------------------------------------------------------------------
-- 10. TABLA: formatos (Documentos y guías)
-- ---------------------------------------------------------------------
CREATE TABLE formatos (
    id_formato INT AUTO_INCREMENT PRIMARY KEY,
    codigo VARCHAR(30) NOT NULL UNIQUE,
    nombre VARCHAR(150) NOT NULL,
    descripcion TEXT NULL,
    version VARCHAR(10) NOT NULL DEFAULT '1.0',
    enlace_descarga VARCHAR(500) NOT NULL,
    categoria VARCHAR(50) NOT NULL DEFAULT 'Trabajos de Grado',
    fecha_publicacion DATE NOT NULL
) ENGINE=InnoDB;

-- =====================================================================
-- DATOS DE PRUEBA (DML)
-- =====================================================================

-- Roles
INSERT INTO roles (id_rol, nombre_rol, descripcion) VALUES
(1, 'ADMIN', 'Administrador del sistema con control total de usuarios'),
(2, 'COORDINACION', 'Coordinador de Trabajos de Grado de la facultad'),
(3, 'DIRECTOR', 'Docente Director tutor de anteproyectos'),
(4, 'EVALUADOR', 'Docente Evaluador o jurado de proyectos'),
(5, 'ESTUDIANTE', 'Estudiante de Tecnología o Profesional en Grado');

-- Programas Académicos UTS
INSERT INTO programas (id_programa, codigo_programa, nombre_programa, nivel) VALUES
(1, 'TSI', 'Tecnología en Desarrollo de Sistemas Informáticos', 'Tecnología'),
(2, 'ISI', 'Ingeniería de Sistemas', 'Profesional'),
(3, 'TEL', 'Tecnología en Electrónica Industrial', 'Tecnología'),
(4, 'TGE', 'Tecnología en Gestión Empresarial', 'Tecnología');

-- Usuarios
-- Contraseñas hasheadas con SHA-256:
-- admin123        -> SHA2('admin123', 256)
-- coord123        -> SHA2('coord123', 256)
-- docente123      -> SHA2('docente123', 256)
-- eval123         -> SHA2('eval123', 256)
-- est123          -> SHA2('est123', 256)

INSERT INTO usuarios (id_usuario, id_rol, id_programa, codigo, documento, nombres, apellidos, correo, clave, telefono, semestre, activo) VALUES
(1, 1, NULL, 'ADM001', '1098000001', 'Super', 'Administrador', 'admin@uts.edu.co', SHA2('admin123', 256), '3151112233', NULL, 1),
(2, 2, 1, 'CRD001', '1098000002', 'Héctor', 'González Parra', 'coordinacion@uts.edu.co', SHA2('coord123', 256), '3152223344', NULL, 1),
(3, 3, 1, 'DIR001', '1098000003', 'Carlos Eduardo', 'Pérez Moreno', 'director1@uts.edu.co', SHA2('docente123', 256), '3153334455', NULL, 1),
(4, 3, 1, 'DIR002', '1098000004', 'María Jimena', 'Gómez Suárez', 'director2@uts.edu.co', SHA2('docente123', 256), '3154445566', NULL, 1),
(5, 4, 1, 'EVA001', '1098000005', 'Juan Camilo', 'Rodríguez Peña', 'evaluador1@uts.edu.co', SHA2('eval123', 256), '3155556677', NULL, 1),
(6, 4, 1, 'EVA002', '1098000006', 'Laura Marcela', 'Mendoza Duarte', 'evaluador2@uts.edu.co', SHA2('eval123', 256), '3156667788', NULL, 1),
(7, 5, 1, '1098765432', '1098765432', 'Andrés Felipe', 'Torres Rueda', 'estudiante1@uts.edu.co', SHA2('est123', 256), '3167778899', 6, 1),
(8, 5, 1, '1098765433', '1098765433', 'Valentina', 'Castro Mejía', 'estudiante2@uts.edu.co', SHA2('est123', 256), '3168889900', 6, 1),
(9, 5, 2, '1098765434', '1098765434', 'Camilo Andrés', 'Silva Vargas', 'estudiante3@uts.edu.co', SHA2('est123', 256), '3169990011', 10, 1),
(10, 5, 1, '1098765435', '1098765435', 'Daniela Sofía', 'Ramírez Ortiz', 'estudiante4@uts.edu.co', SHA2('est123', 256), '3170001122', 6, 1);

-- Ideas (Banco de Ideas)
INSERT INTO ideas (id_idea, id_programa, id_coordinador, titulo, descripcion, linea_investigacion, cupos, estado) VALUES
(1, 1, 2, 'Sistema IoT de Monitoreo de Calidad de Aire en Campus UTS', 'Desarrollo de prototipo con microcontroladores ESP32 y sensores MQ para registrar contaminantes particulados y visualizarlos en dashboard web institucional.', 'Internet de las Cosas y Sistemas Embebidos', 1, 'Asignada'),
(2, 1, 2, 'Plataforma Web con Inteligencia Artificial para Detección de Plagas en Cultivos Santandereanos', 'Aplicación web progresiva orientada a pequeños agricultores que permite diagnosticar plagas en cítricos mediante modelos de visión por computador.', 'Inteligencia Artificial y Software Aplicado', 1, 'Asignada'),
(3, 1, 2, 'Sistema de Información para la Gestión de Inventarios en PyMEs de Calzado de Bucaramanga', 'Software web integral para control de materia prima, órdenes de producción y punto de venta en fábricas del sector calzado del barrio San Francisco.', 'Ingeniería de Software y Transformación Digital', 1, 'Disponible'),
(4, 2, 2, 'Arquitectura de Microservicios para la Optimización de Trámites Académicos UTS', 'Estudio e implementación de servicios distribuidos con alta tolerancia a fallos para matrículas y cancelaciones académicas.', 'Arquitectura de Software y Sistemas Distribuidos', 2, 'Disponible');

-- Anteproyectos
-- Caso 1: Estudiante 1 (Andrés Torres) - En revisión por director
INSERT INTO anteproyectos (id_anteproyecto, id_estudiante, id_idea, id_director, id_evaluador, titulo, linea_investigacion, planteamiento_problema, justificacion, objetivo_general, objetivos_especificos, resumen, enlace_documento, version, estado) VALUES
(1, 7, 1, 3, 5, 'Sistema IoT de Monitoreo de Calidad de Aire en Campus UTS', 'Internet de las Cosas y Sistemas Embebidos', 
'En el campus de las UTS no se cuenta con métricas en tiempo real de material particulado PM2.5 y gases generados por el tráfico vehicular aledaño.',
'Permitirá tomar decisiones sobre bienestar institucional y mitigación ambiental.',
'Diseñar e implementar un prototipo IoT para medir y reportar la calidad del aire en el campus de las UTS.',
'1. Caracterizar sensores MQ y PMS.\n2. Programar firmware en ESP32.\n3. Implementar plataforma web en JSP y MySQL.',
'El proyecto propone una solución de bajo costo para el monitoreo ambiental continuo en el campus universitario.',
'https://drive.google.com/file/d/1UTS_ejemplo_anteproyecto1/view', '1.0', 'En revisión por director');

-- Caso 2: Estudiante 2 (Valentina Castro) - Aprobado por director (en revisión por evaluador)
INSERT INTO anteproyectos (id_anteproyecto, id_estudiante, id_idea, id_director, id_evaluador, titulo, linea_investigacion, planteamiento_problema, justificacion, objetivo_general, objetivos_especificos, resumen, enlace_documento, version, estado) VALUES
(2, 8, 2, 4, 6, 'Plataforma Web con Inteligencia Artificial para Detección de Plagas en Cultivos Santandereanos', 'Inteligencia Artificial y Software Aplicado',
'Los productores de cítricos en Lebrija y Rionegro pierden hasta un 30% de sus cosechas por diagnóstico tardío de la mosca blanca y HLB.',
'Acercar herramientas tecnológicas a los agricultores de la región santandereana sin altos costos de infraestructura.',
'Construir una plataforma web asistida por modelos convolucionales para la detección oportuna de plagas en cítricos.',
'1. Recolectar dataset fotográfico regional.\n2. Entrenar red neuronal convolucional.\n3. Integrar API con interfaz web responsiva.',
'Prototipo funcional web para diagnóstico visual de fitopatologías en tiempo oportuno.',
'https://drive.google.com/file/d/1UTS_ejemplo_anteproyecto2/view', '1.1', 'En revisión por evaluador');

-- Caso 3: Estudiante 4 (Daniela Sofía Ramírez) - En desarrollo
INSERT INTO anteproyectos (id_anteproyecto, id_estudiante, id_idea, id_director, id_evaluador, titulo, linea_investigacion, planteamiento_problema, justificacion, objetivo_general, objetivos_especificos, resumen, enlace_documento, version, estado) VALUES
(3, 10, NULL, 3, 5, 'Sistema de Alerta Temprana de Deslizamientos en la Comuna 14 de Bucaramanga', 'Gestión de Riesgo y Tecnologías Geoespaciales',
'Las zonas de ladera de Bucaramanga sufren recurrentes movimientos en masa durante temporadas invernales que ponen en peligro vidas humanas.',
'Aportar una herramienta de mitigación y alerta comunitaria para la gestión de desastres en Santander.',
'Desarrollar un prototipo de monitoreo de humedad de suelo e inclinación en laderas vulnerables.',
'1. Levantar variables geológicas.\n2. Desplegar nodos sensores.\n3. Generar visualización en mapa satelital.',
'Red de sensores interconectados para enviar alertas tempranas por SMS y web a líderes comunitarios.',
'https://drive.google.com/file/d/1UTS_ejemplo_anteproyecto3/view', '2.0', 'En desarrollo');

-- Historial de estados
INSERT INTO historial_estados (id_anteproyecto, id_usuario, estado_anterior, estado_nuevo, observacion) VALUES
(1, 7, NULL, 'Idea seleccionada', 'Estudiante seleccionó la idea del banco institucional'),
(1, 7, 'Idea seleccionada', 'Anteproyecto radicado', 'Radicación formal del documento preliminar v1.0'),
(1, 2, 'Anteproyecto radicado', 'En revisión por director', 'Coordinación asignó como Director al docente Carlos Eduardo Pérez'),
(2, 8, NULL, 'Idea seleccionada', 'Estudiante vinculada al proyecto de IA'),
(2, 8, 'Idea seleccionada', 'Anteproyecto radicado', 'Radicación formal del documento preliminar'),
(2, 2, 'Anteproyecto radicado', 'En revisión por director', 'Coordinación asignó como Directora a María Jimena Gómez'),
(2, 4, 'En revisión por director', 'Aprobado por director', 'Director aprueba con nota 4.3 y remite a evaluación'),
(2, 2, 'Aprobado por director', 'En revisión por evaluador', 'Coordinación asignó como Evaluadora a Laura Marcela Mendoza'),
(3, 10, NULL, 'Anteproyecto radicado', 'Propuesta propia radicada por estudiante'),
(3, 2, 'Anteproyecto radicado', 'En revisión por director', 'Asignación de director'),
(3, 3, 'En revisión por director', 'Aprobado por director', 'Excelente pertinencia técnica (Nota 4.5)'),
(3, 5, 'Aprobado por director', 'Aprobado', 'Evaluador emite concepto favorable (Nota 4.6)'),
(3, 2, 'Aprobado', 'En desarrollo', 'Coordinación autoriza inicio de fase de desarrollo');

-- Calificaciones
INSERT INTO calificaciones (id_anteproyecto, id_docente, tipo_evaluacion, nota, observaciones, estado_decision) VALUES
(2, 4, 'Anteproyecto - Director', 4.3, 'El planteamiento y la delimitación regional en Santander son sólidos. Se recomienda precisar el tamaño de muestra de entrenamiento.', 'Aprobado'),
(3, 3, 'Anteproyecto - Director', 4.5, 'Propuesta de alto impacto social para el municipio de Bucaramanga. Metodología impecable.', 'Aprobado'),
(3, 5, 'Anteproyecto - Evaluador', 4.6, 'Cumple con los estándares del manual de grado UTS. Se aprueba para desarrollo inmediato.', 'Aprobado');

-- Calendario Académico
INSERT INTO calendario (id_evento, titulo, descripcion, tipo_etapa, fecha_inicio, fecha_fin, estado) VALUES
(1, 'Publicación de Banco de Ideas 2026-II', 'Coordinación pone a disposición el catálogo de líneas y propuestas de investigación.', 'General', '2026-08-01', '2026-08-15', 'Finalizado'),
(2, 'Radicación de Anteproyectos', 'Plazo máximo para que los estudiantes inscriban su propuesta y enlace del documento preliminar.', 'Radicacion', '2026-08-16', '2026-09-15', 'Finalizado'),
(3, 'Revisión y Ajustes con Director', 'Jornada de evaluación, emisión de concepto y retroalimentación docente tutoral.', 'Revision_Director', '2026-09-16', '2026-10-31', 'Activo'),
(4, 'Evaluación por Jurados Evaluadores', 'Revisión técnica de anteproyectos aprobados por directores.', 'Revision_Evaluador', '2026-11-01', '2026-11-20', 'Proximo'),
(5, 'Sustentaciones de Trabajos de Grado', 'Jornada pública de sustentación oral ante tribunal examinador UTS.', 'Sustentacion', '2026-12-01', '2026-12-12', 'Proximo');

-- Formatos de Grado UTS
INSERT INTO formatos (id_formato, codigo, nombre, descripcion, version, enlace_descarga, categoria, fecha_publicacion) VALUES
(1, 'F-DC-01', 'Formato Propuesta de Trabajo de Grado', 'Estructura oficial para radicación de anteproyecto (problema, objetivos, marco, cronograma).', '3.0', 'https://www.uts.edu.co/formatos/F-DC-01-Propuesta-Grado-UTS.docx', 'Anteproyecto', '2026-01-15'),
(2, 'F-DC-02', 'Carta de Aceptación Director de Grado', 'Modelo de aval suscrito por el docente director para acompañar el trabajo de grado.', '2.0', 'https://www.uts.edu.co/formatos/F-DC-02-Carta-Aceptacion-Director.docx', 'Tutoría', '2026-01-15'),
(3, 'F-DC-03', 'Rúbrica de Evaluación de Anteproyecto', 'Criterios de calificación de 0.0 a 5.0 empleados por directores y evaluadores.', '2.1', 'https://www.uts.edu.co/formatos/F-DC-03-Rubrica-Anteproyecto-UTS.pdf', 'Evaluación', '2026-02-01'),
(4, 'F-DC-04', 'Plantilla Oficial Monografía de Grado UTS (Normas APA 7ma)', 'Guía de estilo, márgenes y citación para la entrega final del documento escrito.', '4.0', 'https://www.uts.edu.co/formatos/F-DC-04-Plantilla-Monografia-UTS.docx', 'Documento Final', '2026-02-10'),
(5, 'F-DC-05', 'Acta de Sustentación Oral y Veredicto', 'Documento formal para asentar la calificación del jurado calificador.', '1.5', 'https://www.uts.edu.co/formatos/F-DC-05-Acta-Sustentacion-UTS.pdf', 'Sustentación', '2026-02-15');
