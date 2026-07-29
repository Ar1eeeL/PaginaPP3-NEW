-- phpMyAdmin SQL Dump
-- version 5.2.2
-- https://www.phpmyadmin.net/
--
-- Servidor: localhost:3306
-- Tiempo de generación: 19-12-2025 a las 19:04:45
-- Versión del servidor: 11.8.3-MariaDB-log
-- Versión de PHP: 7.2.34

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Base de datos: `u319084656_campus`
--

DELIMITER $$
--
-- Procedimientos
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_contenido_enlaces` (IN `p_contenido_id` INT, IN `p_enlaces_json` JSON)   BEGIN
    DECLARE i INT DEFAULT 0;
    DECLARE total_enlaces INT DEFAULT 0;
    DECLARE v_enlace_texto VARCHAR(255);
    DECLARE v_enlace_url TEXT;

    -- Primero, borramos todos los enlaces antiguos asociados a esta publicación.
    DELETE FROM `contenido_enlaces` WHERE `contenido_id` = p_contenido_id;

    -- Verificamos si la lista de enlaces JSON no está vacía.
    IF p_enlaces_json IS NOT NULL AND JSON_LENGTH(p_enlaces_json) > 0 THEN
        SET total_enlaces = JSON_LENGTH(p_enlaces_json);

        -- Iniciamos un bucle que se repetirá por cada enlace en la lista.
        WHILE i < total_enlaces DO
            -- Extraemos el título y la URL de cada elemento de la lista.
            SET v_enlace_texto = JSON_UNQUOTE(JSON_EXTRACT(p_enlaces_json, CONCAT('$[', i, '].titulo')));
            SET v_enlace_url = JSON_UNQUOTE(JSON_EXTRACT(p_enlaces_json, CONCAT('$[', i, '].url')));

            -- Insertamos la nueva fila en la tabla de enlaces.
            INSERT INTO `contenido_enlaces` (contenido_id, enlace_texto, enlace_url, orden)
            VALUES (p_contenido_id, v_enlace_texto, v_enlace_url, i);
            
            -- Incrementamos el contador para pasar al siguiente enlace.
            SET i = i + 1;
        END WHILE;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `actualizar_estado_materia` (IN `p_materia_id` INT, IN `p_nuevo_estado` TINYINT(1))   BEGIN
    UPDATE materias 
    SET activa = p_nuevo_estado 
    WHERE id = p_materia_id;
    
    -- Se elimina la línea "SELECT 'mensaje'..." que causaba el conflicto.
    -- Si la consulta UPDATE falla por alguna razón (ej: la materia no existe),
    -- el motor de la base de datos ya genera un error por sí mismo.
    -- Si no hay error, se asume que fue exitosa.
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `asignar_especialidades_profesor` (IN `p_profesor_id` INT, IN `p_especialidades_ids` TEXT, IN `p_especialidad_principal_id` INT)   BEGIN
    DECLARE v_especialidad_id INT;
    DECLARE v_done INT DEFAULT FALSE;
    DECLARE v_pos INT DEFAULT 1;
    DECLARE v_id VARCHAR(10);
    
    -- Eliminar especialidades anteriores
    DELETE FROM profesor_especialidad WHERE profesor_id = p_profesor_id;
    
    -- Procesar cada ID en la lista
    WHILE v_pos <= LENGTH(p_especialidades_ids) DO
        -- Extraer el siguiente ID
        SET v_id = SUBSTRING_INDEX(SUBSTRING_INDEX(p_especialidades_ids, ',', v_pos), ',', -1);
        
        -- Convertir a número y asignar si no está vacío
        IF v_id != '' THEN
            SET v_especialidad_id = CAST(v_id AS UNSIGNED);
            
            -- Insertar la especialidad
            INSERT INTO profesor_especialidad (profesor_id, especialidad_id, es_principal)
            VALUES (p_profesor_id, v_especialidad_id, 
                  IF(v_especialidad_id = p_especialidad_principal_id, 1, 0));
        END IF;
        
        SET v_pos = v_pos + 1;
    END WHILE;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `asignar_materia_grado` (IN `p_materia_id` INT, IN `p_grado_id` INT)   BEGIN
    DECLARE v_count INT;
    
    -- Verificar que la materia existe
    SELECT COUNT(*) INTO v_count FROM materias WHERE id = p_materia_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Materia no encontrada';
    END IF;
    
    -- Verificar que el grado existe
    SELECT COUNT(*) INTO v_count FROM grados WHERE id = p_grado_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Grado no encontrado';
    END IF;
    
    -- Asignar materia al grado
    INSERT INTO materia_grado (materia_id, grado_id)
    VALUES (p_materia_id, p_grado_id)
    ON DUPLICATE KEY UPDATE materia_id = materia_id;
    
    SELECT 'Materia asignada exitosamente al grado' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `asignar_materia_profesor` (IN `p_profesor_id` INT, IN `p_materia_id` INT)   BEGIN
    DECLARE v_count INT;
    
    -- Verificar que el profesor existe
    SELECT COUNT(*) INTO v_count FROM profesores WHERE id = p_profesor_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Profesor no encontrado';
    END IF;
    
    -- Verificar que la materia existe
    SELECT COUNT(*) INTO v_count FROM materias WHERE id = p_materia_id;
    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Materia no encontrada';
    END IF;
    
    -- Asignar materia al profesor
    INSERT INTO profesor_materia (profesor_id, materia_id)
    VALUES (p_profesor_id, p_materia_id)
    ON DUPLICATE KEY UPDATE profesor_id = profesor_id;
    
    SELECT 'Materia asignada exitosamente al profesor' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `asignar_profesor_materia_grado` (IN `p_profesor_id` INT, IN `p_materia_id` INT, IN `p_grado_id` INT, IN `p_anio_lectivo` YEAR)   BEGIN
    INSERT INTO profesor_materia_grado (profesor_id, materia_id, grado_id, anio_lectivo)
    VALUES (p_profesor_id, p_materia_id, p_grado_id, p_anio_lectivo)
    ON DUPLICATE KEY UPDATE profesor_id = profesor_id;
    
    SELECT 'Asignación creada/actualizada exitosamente' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `autenticar_usuario` (IN `p_dni` VARCHAR(20), IN `p_password` VARCHAR(255))   BEGIN
    DECLARE v_user_id INT;
    DECLARE v_primer_login TINYINT;
    DECLARE v_password_temporal TINYINT;
    DECLARE v_rol_id INT;
    DECLARE v_activo TINYINT;
    DECLARE v_persona_id INT;
    DECLARE v_nombre VARCHAR(100);
    DECLARE v_apellido VARCHAR(100);
    
    -- Buscar usuario por DNI (sin verificar contraseña aquí)
    -- La verificación de contraseña se hace en PHP con password_verify()
    SELECT 
        u.id, 
        u.primer_login,
        u.password_temporal,
        u.rol_id,
        u.activo,
        u.persona_fisica_id,
        pf.nombre,
        pf.apellido
    INTO 
        v_user_id,
        v_primer_login,
        v_password_temporal,
        v_rol_id,
        v_activo,
        v_persona_id,
        v_nombre,
        v_apellido
    FROM usuarios u
    LEFT JOIN personas_fisicas pf ON u.persona_fisica_id = pf.id
    WHERE u.usuario = p_dni;
    
    IF v_user_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Usuario no encontrado';
    ELSEIF v_activo = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Cuenta inactiva. Contacte al administrador.';
    ELSE
        -- Actualizar último acceso
        UPDATE usuarios SET ultimo_acceso = NOW() WHERE id = v_user_id;
        
        -- Devolver información del usuario (sin verificar contraseña)
        SELECT 
            v_user_id AS id,
            p_dni AS dni,
            v_rol_id AS rol_id,
            r.nombre AS rol_nombre,
            v_primer_login AS necesita_cambiar_password,
            v_password_temporal AS password_temporal,
            v_persona_id AS persona_fisica_id,
            CONCAT(v_nombre, ' ', v_apellido) AS nombre_completo,
            CASE 
                WHEN v_primer_login = 1 OR v_password_temporal = 1 THEN 1
                ELSE 0
            END AS forzar_cambio_password
        FROM roles r
        WHERE r.id = v_rol_id;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `buscar_alumno` (IN `p_busqueda` VARCHAR(100))   BEGIN
    SELECT 
        u.id AS usuario_id,
        a.id AS alumno_id,
        pf.nombre,
        pf.apellido,
        pf.dni,
        pf.email,
        pf.fecha_nacimiento,
        pf.direccion,
        pf.localidad,
        pf.codigo_postal,
        pf.telefono,
        g.nombre AS grado,
        IFNULL(t.nombre, 'No especificado') AS turno,
        d.nombre AS division,
        a.nacionalidad,
        a.lugar_nacimiento,
        a.hermanos,
        a.enfermedades,
        a.asistencia_psicopedagogica,
        a.especialidad,
        a.telefono_emergencia,
        a.contacto_emergencia,
        a.fecha_ingreso,
        a.fecha_egreso,
        a.egresado
    FROM usuarios u
    JOIN alumnos a ON u.id = a.usuario_id
    JOIN personas_fisicas pf ON a.persona_fisica_id = pf.id
    LEFT JOIN grados g ON a.grado_id = g.id
    LEFT JOIN turnos t ON g.turno_id = t.id
    LEFT JOIN divisiones d ON g.division_id = d.id
    WHERE (pf.dni LIKE CONCAT('%', p_busqueda, '%') OR
           pf.nombre LIKE CONCAT('%', p_busqueda, '%') OR
           pf.apellido LIKE CONCAT('%', p_busqueda, '%'))
      AND u.rol_id = 2;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `calificar_entrega` (IN `p_entrega_id` INT, IN `p_profesor_id` INT, IN `p_calificacion` DECIMAL(4,2), IN `p_comentario_profesor` TEXT)   BEGIN
    DECLARE v_profesor_autor_id INT;

    -- Verificamos que el profesor que califica sea el autor del contenido (tarea)
    SELECT mc.profesor_id INTO v_profesor_autor_id
    FROM tarea_entregas te
    JOIN materia_contenido mc ON te.contenido_id = mc.id
    WHERE te.id = p_entrega_id;

    IF v_profesor_autor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: La entrega no existe.';
    ELSEIF v_profesor_autor_id != p_profesor_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No tiene permisos para calificar esta entrega.';
    ELSE
        UPDATE tarea_entregas
        SET
            calificacion = p_calificacion,
            comentario_profesor = p_comentario_profesor,
            fecha_calificacion = NOW()
        WHERE id = p_entrega_id;
        
        SELECT 'Calificación guardada exitosamente.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `cambiar_password` (IN `p_usuario_id` INT, IN `p_password_actual` VARCHAR(255), IN `p_nuevo_password` VARCHAR(255))   BEGIN
    DECLARE v_password_actual_db VARCHAR(255);
    DECLARE v_primer_login TINYINT;
    DECLARE v_usuario VARCHAR(200);
    DECLARE v_dni VARCHAR(20);
    
    -- Obtener contraseña actual, estado de primer login y usuario
    SELECT password, primer_login, usuario INTO v_password_actual_db, v_primer_login, v_usuario
    FROM usuarios WHERE id = p_usuario_id;
    
    -- Extraer el DNI del campo usuario (parte antes del |)
    SET v_dni = SUBSTRING_INDEX(v_usuario, '|', 1);
    
    -- Verificar contraseña actual (excepto en primer login)
    -- La verificación se hace en PHP con password_verify()
    IF v_primer_login = 0 AND v_password_actual_db != '' THEN
        -- Si no es primer login y hay contraseña, la verificación se hace en PHP
        -- Este procedimiento solo actualiza si PHP confirma que es válida
        IF LENGTH(p_nuevo_password) < 8 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña debe tener al menos 8 caracteres';
        ELSEIF p_nuevo_password = v_dni THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña no puede ser igual al DNI';
        ELSE
            -- Actualizar contraseña (ya hasheada en PHP)
            UPDATE usuarios 
            SET password = p_nuevo_password,
                primer_login = 0,
                password_temporal = 0,
                actualizado_en = CURRENT_TIMESTAMP()
            WHERE id = p_usuario_id;
            
            SELECT 'Contraseña cambiada exitosamente' AS mensaje;
        END IF;
    ELSE
        -- Es primer login o no hay contraseña anterior
        IF LENGTH(p_nuevo_password) < 8 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña debe tener al menos 8 caracteres';
        ELSEIF p_nuevo_password = v_dni THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La contraseña no puede ser igual al DNI';
        ELSE
            -- Actualizar contraseña (ya hasheada en PHP)
            UPDATE usuarios 
            SET password = p_nuevo_password,
                primer_login = 0,
                password_temporal = 0,
                actualizado_en = CURRENT_TIMESTAMP()
            WHERE id = p_usuario_id;
            
            SELECT 'Contraseña cambiada exitosamente' AS mensaje;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CargarNotasMaraExistente` ()   BEGIN
    -- 1. Declaración de variables
    DECLARE v_alumno_id INT;
    DECLARE v_grado_id INT DEFAULT 12;    -- 6to B (Orientado Economía)
    DECLARE v_anio INT DEFAULT 2025;      -- Año lectivo según tus datos
    DECLARE v_profesor_default INT DEFAULT 3; -- Profesor genérico para asignar los temas
    
    -- Variables para el control de bucles
    DECLARE done_materias INT DEFAULT FALSE;
    DECLARE v_materia_id INT;
    DECLARE v_eval_num INT;
    DECLARE v_tema_id INT;

    -- 2. Definimos las materias de 6to Año (IDs extraídos de tu BD)
    DECLARE cur_materias CURSOR FOR 
        SELECT id FROM materias 
        WHERE id IN (51, 52, 53, 54, 55, 56, 57, 58, 59, 66, 67, 68, 69);
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_materias = TRUE;

    -- 3. BUSCAR A LA ALUMNA "MARA LLORET"
    -- Se busca por nombre y apellido en la tabla personas_fisicas y se une con alumnos
    SELECT a.id INTO v_alumno_id
    FROM alumnos a
    JOIN personas_fisicas pf ON a.persona_fisica_id = pf.id
    WHERE pf.apellido = 'LLORET' AND pf.nombre = 'MARA'
    LIMIT 1;

    -- 4. Lógica de inserción (Solo si encontramos a la alumna)
    IF v_alumno_id IS NOT NULL THEN
        
        -- Aseguramos que esté asignada al grado correcto (6to B)
        UPDATE alumnos SET grado_id = v_grado_id WHERE id = v_alumno_id;

        OPEN cur_materias;

        -- Bucle por cada Materia
        materia_loop: LOOP
            FETCH cur_materias INTO v_materia_id;
            IF done_materias THEN
                LEAVE materia_loop;
            END IF;

            -- Bucle por Evaluaciones (1 a 8)
            SET v_eval_num = 1;
            WHILE v_eval_num <= 8 DO
                SET v_tema_id = NULL;

                -- A. Buscamos si ya existe el "Tema de Evaluación" (la carpeta donde va la nota)
                SELECT id INTO v_tema_id 
                FROM temas_evaluacion 
                WHERE materia_id = v_materia_id 
                  AND grado_id = v_grado_id 
                  AND evaluacion_id = v_eval_num 
                  AND anio_lectivo = v_anio
                LIMIT 1;

                -- B. Si no existe el tema, lo creamos automáticamente
                IF v_tema_id IS NULL THEN
                    INSERT INTO temas_evaluacion (
                        materia_id, profesor_id, grado_id, evaluacion_id, tipo_evaluacion_id, 
                        nombre_tema, descripcion, fecha_establecida, fecha_evaluacion, 
                        fecha_inicio, fecha_fin, anio_lectivo
                    ) VALUES (
                        v_materia_id, v_profesor_default, v_grado_id, v_eval_num, 1, 
                        CONCAT('Evaluación N° ', v_eval_num), 'Carga automática', 
                        CURDATE(), CURDATE(), CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), v_anio
                    );
                    SET v_tema_id = LAST_INSERT_ID();
                END IF;

                -- C. Insertamos la Nota (Aleatoria entre 6 y 10)
                INSERT INTO calificaciones (
                    alumno_id, tema_evaluacion_id, nota, fecha_calificacion, 
                    observaciones, intento, recuperatorio
                ) VALUES (
                    v_alumno_id, 
                    v_tema_id, 
                    TRUNCATE(RAND() * (10 - 6) + 6, 2), -- Genera nota entre 6.00 y 9.99
                    CURDATE(), 
                    'Nota cargada por sistema', 
                    1, 
                    0
                )
                ON DUPLICATE KEY UPDATE nota = VALUES(nota); -- Si ya tiene nota, la actualiza

                SET v_eval_num = v_eval_num + 1;
            END WHILE;

        END LOOP;

        CLOSE cur_materias;
        
        SELECT CONCAT('Notas cargadas exitosamente para la alumna ID: ', v_alumno_id) AS Resultado;
        
    ELSE
        SELECT 'Error: No se encontró a la alumna LLORET, MARA en la base de datos.' AS Resultado;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `CargarNotasMaraTodasMaterias` ()   BEGIN
    -- Declaración de variables
    DECLARE v_alumno_id INT;
    DECLARE v_grado_id INT DEFAULT 12;    -- 6to B (Orientado Economía)
    DECLARE v_anio INT DEFAULT 2025;
    DECLARE v_profesor_default INT DEFAULT 3; 

    DECLARE done_materias INT DEFAULT FALSE;
    DECLARE v_materia_id INT;
    DECLARE v_eval_num INT;
    DECLARE v_tema_id INT;
    DECLARE v_materias_cargadas INT DEFAULT 0;

    -- =========================================================================
    -- LISTA CONFIRMADA DE MATERIAS DE 6TO AÑO (ECONOMÍA)
    -- =========================================================================
    DECLARE cur_materias CURSOR FOR 
        SELECT id FROM materias 
        WHERE id IN (
            51, -- Matemática 6°
            52, -- Lengua y Literatura 6°
            53, -- Química 6°
            54, -- Inglés 6°
            55, -- Teatro 6°
            56, -- Ciudadanía y Política 6°
            57, -- Filosofía 6°
            58, -- Educación Física 6°
            59, -- Formación para la Vida y el Trabajo 6°
            66, -- Sistemas de Información Contable 6°
            67, -- Economía 6°
            68, -- Derecho 6°
            69  -- Marco Jurídico de las Organizaciones 6°
        );
        
    DECLARE CONTINUE HANDLER FOR NOT FOUND SET done_materias = TRUE;

    -- 1. BUSCAR ALUMNA
    SELECT a.id INTO v_alumno_id
    FROM alumnos a
    JOIN personas_fisicas pf ON a.persona_fisica_id = pf.id
    WHERE pf.apellido = 'LLORET' AND pf.nombre = 'MARA'
    LIMIT 1;

    IF v_alumno_id IS NOT NULL THEN
        -- Asegurar grado correcto
        UPDATE alumnos SET grado_id = v_grado_id WHERE id = v_alumno_id;

        OPEN cur_materias;

        -- 2. BUCLE POR CADA MATERIA
        materia_loop: LOOP
            FETCH cur_materias INTO v_materia_id;
            IF done_materias THEN
                LEAVE materia_loop;
            END IF;

            -- 3. BUCLE POR 8 EVALUACIONES
            SET v_eval_num = 1;
            WHILE v_eval_num <= 8 DO
                SET v_tema_id = NULL;

                -- Buscar o Crear Tema de Evaluación
                SELECT id INTO v_tema_id 
                FROM temas_evaluacion 
                WHERE materia_id = v_materia_id 
                  AND grado_id = v_grado_id 
                  AND evaluacion_id = v_eval_num 
                  AND anio_lectivo = v_anio
                LIMIT 1;

                IF v_tema_id IS NULL THEN
                    INSERT INTO temas_evaluacion (
                        materia_id, profesor_id, grado_id, evaluacion_id, tipo_evaluacion_id, 
                        nombre_tema, descripcion, fecha_establecida, fecha_evaluacion, 
                        fecha_inicio, fecha_fin, anio_lectivo
                    ) VALUES (
                        v_materia_id, v_profesor_default, v_grado_id, v_eval_num, 1, 
                        CONCAT('Evaluación N° ', v_eval_num), 'Automática', 
                        CURDATE(), CURDATE(), CURDATE(), DATE_ADD(CURDATE(), INTERVAL 30 DAY), v_anio
                    );
                    SET v_tema_id = LAST_INSERT_ID();
                END IF;

                -- Insertar Nota
                INSERT INTO calificaciones (
                    alumno_id, tema_evaluacion_id, nota, fecha_calificacion, 
                    observaciones, intento, recuperatorio
                ) VALUES (
                    v_alumno_id, v_tema_id, TRUNCATE(RAND() * (10 - 6) + 6, 2), 
                    CURDATE(), 'Carga Completa', 1, 0
                )
                ON DUPLICATE KEY UPDATE nota = VALUES(nota);

                SET v_eval_num = v_eval_num + 1;
            END WHILE;
            
            SET v_materias_cargadas = v_materias_cargadas + 1;

        END LOOP;
        CLOSE cur_materias;

        -- 4. VERIFICACIÓN FINAL
        SELECT 
            pf.apellido, pf.nombre, 
            COUNT(DISTINCT m.id) as materias_con_nota,
            COUNT(c.id) as total_notas_cargadas
        FROM calificaciones c
        JOIN temas_evaluacion te ON c.tema_evaluacion_id = te.id
        JOIN materias m ON te.materia_id = m.id
        JOIN alumnos a ON c.alumno_id = a.id
        JOIN personas_fisicas pf ON a.persona_fisica_id = pf.id
        WHERE a.id = v_alumno_id;
        
    ELSE
        SELECT 'Error: Alumna no encontrada' as Mensaje;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `crear_alumno` (IN `p_dni` VARCHAR(20), IN `p_nombre` VARCHAR(100), IN `p_apellido` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_fecha_nacimiento` DATE, IN `p_direccion` VARCHAR(255), IN `p_localidad` VARCHAR(100), IN `p_codigo_postal` VARCHAR(10), IN `p_telefono` VARCHAR(20), IN `p_nacionalidad` VARCHAR(100), IN `p_lugar_nacimiento` VARCHAR(100), IN `p_telefono_emergencia` VARCHAR(20), IN `p_contacto_emergencia` VARCHAR(100), IN `p_grado_id` INT, IN `p_especialidad` VARCHAR(50), IN `p_hermanos` INT, IN `p_enfermedades` TEXT, IN `p_asistencia_psicopedagogica` TINYINT(1), IN `p_observaciones` TEXT)   BEGIN
    DECLARE v_persona_id INT;
    DECLARE v_usuario_id INT;
    DECLARE v_grado_nombre VARCHAR(50);
    DECLARE v_especialidad_valida ENUM('Bachiller en Economía y Administración', 'Bachiller en Turismo');

    -- Obtener nombre del grado
    SELECT nombre INTO v_grado_nombre FROM grados WHERE id = p_grado_id;

    -- Validar especialidad solo para grados 4°, 5° y 6°
    IF v_grado_nombre REGEXP '^[456]' THEN
        IF p_especialidad IS NULL OR p_especialidad = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe especificar una especialidad para este grado';
        END IF;

        -- Validar y normalizar la especialidad
        IF p_especialidad IN ('Bachiller en Economía y Administración', 'Bachiller en Turismo') THEN
            SET v_especialidad_valida = p_especialidad;
        ELSEIF p_especialidad LIKE '%Econom%' THEN
            SET v_especialidad_valida = 'Bachiller en Economía y Administración';
        ELSEIF p_especialidad LIKE '%Turis%' THEN
            SET v_especialidad_valida = 'Bachiller en Turismo';
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Especialidad no válida.';
        END IF;
    ELSE
        SET v_especialidad_valida = NULL;
    END IF;

    -- Crear usuario (solo con DNI)
    CALL crear_usuario(p_dni, 2, 1);
    SET v_usuario_id = LAST_INSERT_ID();

    -- Insertar datos personales
    INSERT INTO personas_fisicas (
        dni, nombre, apellido, email, fecha_nacimiento,
        direccion, localidad, codigo_postal, telefono
    ) VALUES (
        p_dni, p_nombre, p_apellido, p_email, p_fecha_nacimiento,
        p_direccion, p_localidad, p_codigo_postal, p_telefono
    );
    SET v_persona_id = LAST_INSERT_ID();

    -- Actualizar usuario con persona_fisica_id
    UPDATE usuarios SET persona_fisica_id = v_persona_id WHERE id = v_usuario_id;

    -- Insertar datos de alumno
    INSERT INTO alumnos (
        usuario_id, persona_fisica_id, grado_id,
        nacionalidad, lugar_nacimiento, telefono_emergencia,
        contacto_emergencia, especialidad, hermanos,
        enfermedades, asistencia_psicopedagogica, observaciones
    ) VALUES (
        v_usuario_id, v_persona_id, p_grado_id,
        p_nacionalidad, p_lugar_nacimiento, p_telefono_emergencia,
        p_contacto_emergencia, v_especialidad_valida, p_hermanos,
        p_enfermedades, p_asistencia_psicopedagogica, p_observaciones
    );

    SELECT 'Alumno creado exitosamente' AS mensaje, v_usuario_id AS usuario_id, v_persona_id AS persona_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `crear_horario` (IN `p_profesor_materia_id` INT, IN `p_grado_id` INT, IN `p_dia_semana` ENUM('Lunes','Martes','Miércoles','Jueves','Viernes','Sábado'), IN `p_hora_inicio` TIME, IN `p_hora_fin` TIME, IN `p_aula` VARCHAR(20))   BEGIN
    DECLARE v_conflicto INT DEFAULT 0;
    DECLARE v_profesor_id_actual INT;
    DECLARE v_mensaje_error VARCHAR(500); -- Variable adicional para el mensaje

    -- Validar que hora_inicio sea menor que hora_fin
    IF p_hora_inicio >= p_hora_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La hora de inicio debe ser anterior a la hora de fin.';
    END IF;

    -- Obtener el profesor_id real para la verificación
    SELECT pm.profesor_id INTO v_profesor_id_actual
    FROM profesor_materia pm
    WHERE pm.id = p_profesor_materia_id;

    IF v_profesor_id_actual IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El ID de la asignación profesor-materia no es válido.';
    END IF;
    
    -- Verificar conflicto de horario para el PROFESOR
    SELECT COUNT(*) INTO v_conflicto
    FROM horarios h
    JOIN profesor_materia pm_existing ON h.profesor_materia_id = pm_existing.id
    WHERE pm_existing.profesor_id = v_profesor_id_actual
      AND h.dia_semana = p_dia_semana
      AND p_hora_inicio < h.hora_fin 
      AND p_hora_fin > h.hora_inicio;

    IF v_conflicto > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conflicto: El profesor ya tiene una clase asignada en este día y rango horario.';
    END IF;
    
    -- Verificar conflicto de horario para el GRADO
    SET v_conflicto = 0; 
    SELECT COUNT(*) INTO v_conflicto
    FROM horarios h
    WHERE h.grado_id = p_grado_id
      AND h.dia_semana = p_dia_semana
      AND p_hora_inicio < h.hora_fin 
      AND p_hora_fin > h.hora_inicio;

    IF v_conflicto > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Conflicto: Este grado/división ya tiene una clase asignada en este día y rango horario.';
    END IF;
    
    -- Verificar conflicto de AULA
    SET v_conflicto = 0;
    SELECT COUNT(*) INTO v_conflicto
    FROM horarios h
    WHERE h.aula = p_aula
      AND h.dia_semana = p_dia_semana
      AND p_hora_inicio < h.hora_fin 
      AND p_hora_fin > h.hora_inicio;

    IF v_conflicto > 0 THEN
        -- Usar variable temporal para el mensaje concatenado
        SET v_mensaje_error = CONCAT('Conflicto: El aula ', p_aula, ' ya está ocupada el ', p_dia_semana, ' de ', TIME_FORMAT(p_hora_inicio, '%H:%i'), ' a ', TIME_FORMAT(p_hora_fin, '%H:%i'), '.');
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = v_mensaje_error;
    END IF;
    
    INSERT INTO horarios (
        profesor_materia_id, 
        grado_id, 
        dia_semana, 
        hora_inicio, 
        hora_fin, 
        aula
    ) VALUES (
        p_profesor_materia_id, 
        p_grado_id, 
        p_dia_semana,
        p_hora_inicio, 
        p_hora_fin, 
        p_aula
    );
    
    SELECT 'Horario creado exitosamente' AS mensaje, LAST_INSERT_ID() as horario_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `crear_profesor` (IN `p_dni` VARCHAR(20), IN `p_nombre` VARCHAR(100), IN `p_apellido` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_fecha_nacimiento` DATE, IN `p_direccion` VARCHAR(255), IN `p_localidad` VARCHAR(100), IN `p_codigo_postal` VARCHAR(10), IN `p_telefono` VARCHAR(20), IN `p_titulo` VARCHAR(100), IN `p_especialidad` VARCHAR(100), IN `p_fecha_ingreso` DATE, IN `p_observaciones` TEXT)   BEGIN
    DECLARE v_persona_id INT;
    DECLARE v_usuario_id INT;
    
    -- Primero crear el usuario (solo con DNI)
    CALL crear_usuario(p_dni, 3, 1);
    SET v_usuario_id = LAST_INSERT_ID();
    
    -- Insertar datos personales
    INSERT INTO personas_fisicas (
        dni, nombre, apellido, email, fecha_nacimiento, 
        direccion, localidad, codigo_postal, telefono
    ) VALUES (
        p_dni, p_nombre, p_apellido, p_email, p_fecha_nacimiento,
        p_direccion, p_localidad, p_codigo_postal, p_telefono
    );
    
    SET v_persona_id = LAST_INSERT_ID();
    
    -- Actualizar usuario con persona_fisica_id
    UPDATE usuarios SET persona_fisica_id = v_persona_id WHERE id = v_usuario_id;
    
    -- Insertar datos específicos de profesor
    INSERT INTO profesores (
        usuario_id, persona_fisica_id, titulo,
        especialidad, fecha_ingreso, observaciones
    ) VALUES (
        v_usuario_id, v_persona_id, p_titulo,
        p_especialidad, p_fecha_ingreso, p_observaciones
    );
    
    SELECT 'Profesor creado exitosamente' AS mensaje, v_usuario_id AS usuario_id, v_persona_id AS persona_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `crear_usuario` (IN `p_dni` VARCHAR(20), IN `p_rol_id` INT, IN `p_activo` TINYINT(1))   BEGIN
    DECLARE v_existe INT;
    
    -- Verificar si el usuario ya existe
    SELECT COUNT(*) INTO v_existe FROM usuarios WHERE usuario = p_dni;
    IF v_existe > 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Ya existe un usuario con este DNI';
    END IF;
    
    -- Insertar el usuario con contraseña temporal vacía
    -- La contraseña se hashea en PHP y se actualiza después
    INSERT INTO usuarios (
        usuario, 
        password, 
        rol_id,
        primer_login,
        password_temporal,
        activo
    ) VALUES (
        p_dni,
        '',
        p_rol_id,
        1,
        1,
        p_activo
    );
    
    SELECT LAST_INSERT_ID() AS usuario_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `dar_baja_profesor` (IN `p_profesor_id` INT)   BEGIN
    DECLARE v_usuario_id INT;
    DECLARE v_profesor_existe INT DEFAULT 0;

    -- Verificar que el profesor exista y obtener su ID de usuario
    SELECT usuario_id, activo INTO v_usuario_id, v_profesor_existe 
    FROM profesores WHERE id = p_profesor_id;

    IF v_usuario_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El profesor no existe.';
    END IF;
    
    -- Iniciar transacción
    START TRANSACTION;

    -- ✅ CORRECCIÓN CLAVE: Actualizamos el estado en la tabla 'usuarios'
    UPDATE usuarios SET activo = 0 WHERE id = v_usuario_id;

    -- 2. Eliminar todos sus horarios actuales
    DELETE h FROM horarios h
    JOIN profesor_materia pm ON h.profesor_materia_id = pm.id
    WHERE pm.profesor_id = p_profesor_id;

    -- 3. Eliminar las asignaciones de materias a grados para el año lectivo actual
    DELETE FROM profesor_materia_grado WHERE profesor_id = p_profesor_id AND anio_lectivo = YEAR(CURDATE());

    -- 4. Eliminar las asignaciones generales de materias al profesor
    DELETE FROM profesor_materia WHERE profesor_id = p_profesor_id;

    -- Confirmar todos los cambios
    COMMIT;

    SELECT 'Profesor dado de baja y materias desasignadas exitosamente.' AS mensaje;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `desactivar_materia` (IN `p_materia_id` INT)   BEGIN
    UPDATE materias 
    SET activa = 0 
    WHERE id = p_materia_id;
    
    SELECT CONCAT('Materia ', nombre, ' marcada como inactiva') AS mensaje
    FROM materias
    WHERE id = p_materia_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_contenido_materia` (IN `p_contenido_id` INT, IN `p_profesor_id` INT)   BEGIN
    DECLARE v_profesor_autor_id INT;

    -- Verificar si el contenido existe y obtener el ID del profesor que lo creó
    SELECT profesor_id INTO v_profesor_autor_id
    FROM materia_contenido
    WHERE id = p_contenido_id;

    -- Si el contenido no existe, mostrar un error
    IF v_profesor_autor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El contenido que intenta eliminar no existe.';
    -- Si el profesor que intenta borrar no es el autor, mostrar un error
    ELSEIF v_profesor_autor_id != p_profesor_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No tiene permisos para eliminar este contenido, ya que no es el autor.';
    ELSE
        -- Si todas las verificaciones pasan, eliminar el contenido
        DELETE FROM materia_contenido WHERE id = p_contenido_id;
        SELECT 'Contenido eliminado exitosamente.' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `eliminar_tema_evaluacion` (IN `p_tema_id` INT, IN `p_profesor_id` INT)   BEGIN
    DECLARE v_profesor_autor_id INT;
    DECLARE v_calificaciones_count INT;

    -- Primero, verificar que el tema exista y obtener el ID del profesor autor
    SELECT profesor_id INTO v_profesor_autor_id 
    FROM temas_evaluacion 
    WHERE id = p_tema_id;

    -- Si el tema no existe, mostrar un error
    IF v_profesor_autor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El tema de evaluación no existe.';
    -- Si el profesor que intenta borrar no es el autor, mostrar un error
    ELSEIF v_profesor_autor_id != p_profesor_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No tiene permisos para eliminar este tema.';
    ELSE
        -- Contar si hay calificaciones asociadas a este tema
        SELECT COUNT(*) INTO v_calificaciones_count 
        FROM calificaciones 
        WHERE tema_evaluacion_id = p_tema_id;

        -- Si hay calificaciones, mostrar un error
        IF v_calificaciones_count > 0 THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No se puede eliminar el tema porque ya tiene calificaciones registradas.';
        ELSE
            -- Si todas las verificaciones pasan, eliminar el tema
            DELETE FROM temas_evaluacion WHERE id = p_tema_id;
            SELECT 'Tema de evaluación eliminado exitosamente' AS mensaje;
        END IF;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_alumnos_prueba` ()   BEGIN
    -- Declaramos las variables que usaremos
    DECLARE v_grado_id INT DEFAULT 1;
    DECLARE v_contador_alumno INT DEFAULT 1;
    -- Empezamos con un DNI alto para no chocar con datos existentes
    DECLARE v_dni_base INT DEFAULT 90000000; 
    DECLARE v_dni_actual VARCHAR(20);
    DECLARE v_nombre_alumno VARCHAR(100);
    DECLARE v_apellido_alumno VARCHAR(100);
    DECLARE v_email_alumno VARCHAR(100);
    DECLARE v_especialidad_actual VARCHAR(50);
    DECLARE v_grado_nombre VARCHAR(50);
    DECLARE v_grado_tipo_ciclo VARCHAR(50);

    -- ==================================================================
    -- BUCLE 1: Recorrer todos los grados (asumiendo IDs del 1 al 12)
    -- ==================================================================
    WHILE v_grado_id <= 12 DO
        
        -- Obtenemos el nombre y tipo de ciclo del grado actual
        -- Esto es crucial para la validación de la especialidad
        SELECT nombre, tipo_ciclo INTO v_grado_nombre, v_grado_tipo_ciclo
        FROM grados WHERE id = v_grado_id;
        
        -- Asignamos la especialidad correcta según el grado
        -- Tu procedimiento `crear_alumno` valida esto.
        IF v_grado_nombre REGEXP '^[456]' THEN -- Si es 4to, 5to o 6to
            IF v_grado_tipo_ciclo = 'Orientado Turismo' THEN
                SET v_especialidad_actual = 'Bachiller en Turismo';
            ELSEIF v_grado_tipo_ciclo = 'Orientado Economía' THEN
                SET v_especialidad_actual = 'Bachiller en Economía y Administración';
            ELSE
                SET v_especialidad_actual = NULL; -- Default por si acaso
            END IF;
        ELSE
            SET v_especialidad_actual = NULL; -- Para 1ro, 2do y 3ro
        END IF;
        
        -- Reseteamos el contador de alumnos para este grado
        SET v_contador_alumno = 1;
        
        -- ==================================================================
        -- BUCLE 2: Crear 10 alumnos para el grado actual
        -- ==================================================================
        WHILE v_contador_alumno <= 10 DO
            
            -- Generamos datos de prueba únicos
            SET v_dni_actual = CAST(v_dni_base AS CHAR);
            SET v_nombre_alumno = CONCAT('Nombre Alumno ', v_contador_alumno);
            SET v_apellido_alumno = CONCAT('Apellido G', v_grado_id); -- Ej: Apellido G1, Apellido G2
            SET v_email_alumno = CONCAT('alumno.', v_dni_actual, '@example.com');
            
            -- Llamamos a tu procedimiento existente `crear_alumno`
            -- Esto crea el usuario, la persona física y el alumno
            CALL `crear_alumno`(
                v_dni_actual,                               -- p_dni
                v_nombre_alumno,                            -- p_nombre
                v_apellido_alumno,                          -- p_apellido
                v_email_alumno,                             -- p_email
                '2010-05-15',                               -- p_fecha_nacimiento (ejemplo)
                'Calle Falsa 123',                          -- p_direccion
                'Córdoba',                                  -- p_localidad
                '5000',                                     -- p_codigo_postal
                '351000000',                                -- p_telefono
                'Argentino/a',                              -- p_nacionalidad
                'Córdoba',                                  -- p_lugar_nacimiento
                '351999999',                                -- p_telefono_emergencia
                'Tutor de Prueba',                          -- p_contacto_emergencia
                v_grado_id,                                 -- p_grado_id (del bucle)
                v_especialidad_actual,                      -- p_especialidad (calculada arriba)
                0,                                          -- p_hermanos
                'Ninguna',                                  -- p_enfermedades
                0,                                          -- p_asistencia_psicopedagogica
                'Alumno de prueba generado por script.'     -- p_observaciones
            );
            
            -- Incrementamos los contadores
            SET v_contador_alumno = v_contador_alumno + 1;
            SET v_dni_base = v_dni_base + 1; -- DNI único para el próximo alumno
            
        END WHILE; -- Fin bucle de 10 alumnos
        
        -- Pasamos al siguiente grado
        SET v_grado_id = v_grado_id + 1;
        
    END WHILE; -- Fin bucle de grados
    
    -- Mensaje final
    SELECT 'Script completado. Se intentó crear 120 alumnos (10 por cada grado).' AS mensaje;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `insertar_alumnos_prueba_lote` ()   BEGIN
    DECLARE v_grado_id INT DEFAULT 1;
    DECLARE v_contador_alumno INT DEFAULT 1;
    DECLARE v_dni_base INT DEFAULT 90000000; 
    DECLARE v_dni_actual VARCHAR(20);
    DECLARE v_nombre_alumno VARCHAR(100);
    DECLARE v_apellido_alumno VARCHAR(100);
    DECLARE v_email_alumno VARCHAR(100);
    DECLARE v_especialidad_actual VARCHAR(50);
    DECLARE v_grado_nombre VARCHAR(50);
    DECLARE v_grado_tipo_ciclo VARCHAR(50);

    -- Bucle para recorrer los 12 grados
    WHILE v_grado_id <= 12 DO
        
        -- Obtenemos el tipo de ciclo del grado actual
        SELECT nombre, tipo_ciclo INTO v_grado_nombre, v_grado_tipo_ciclo
        FROM grados WHERE id = v_grado_id;
        
        -- Asignamos la especialidad correcta según el grado
        IF v_grado_nombre REGEXP '^[456]' THEN -- Si es 4to, 5to o 6to
            IF v_grado_tipo_ciclo = 'Orientado Turismo' THEN
                SET v_especialidad_actual = 'Bachiller en Turismo';
            ELSEIF v_grado_tipo_ciclo = 'Orientado Economía' THEN
                SET v_especialidad_actual = 'Bachiller en Economía y Administración';
            ELSE
                SET v_especialidad_actual = NULL; 
            END IF;
        ELSE
            SET v_especialidad_actual = NULL; -- Para 1ro, 2do y 3ro
        END IF;
        
        SET v_contador_alumno = 1;
        
        -- Bucle para crear 10 alumnos por grado
        WHILE v_contador_alumno <= 10 DO
            
            SET v_dni_actual = CAST(v_dni_base AS CHAR);
            SET v_nombre_alumno = CONCAT('Nombre Alumno ', v_contador_alumno);
            SET v_apellido_alumno = CONCAT('Apellido G', v_grado_id);
            SET v_email_alumno = CONCAT('alumno.', v_dni_actual, '@example.com');
            
            -- ¡LLAMAMOS A LA VERSIÓN SILENCIOSA!
            CALL `crear_alumno_silencioso`(
                v_dni_actual, v_nombre_alumno, v_apellido_alumno, v_email_alumno,
                '2010-05-15', 'Calle Falsa 123', 'Córdoba', '5000', '351000000',
                'Argentino/a', 'Córdoba', '351999999', 'Tutor de Prueba',
                v_grado_id, v_especialidad_actual, 0, 'Ninguna', 0,
                'Alumno de prueba generado por script.'
            );
            
            SET v_contador_alumno = v_contador_alumno + 1;
            SET v_dni_base = v_dni_base + 1; 
            
        END WHILE; -- Fin bucle de 10 alumnos
        
        SET v_grado_id = v_grado_id + 1;
        
    END WHILE; -- Fin bucle de grados
    
    SELECT 'Script completado. Se intentó crear 120 alumnos.' AS mensaje;
    
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modificar_alumno` (IN `p_dni` VARCHAR(20), IN `p_nombre` VARCHAR(100), IN `p_apellido` VARCHAR(100), IN `p_email` VARCHAR(100), IN `p_direccion` VARCHAR(255), IN `p_localidad` VARCHAR(100), IN `p_codigo_postal` VARCHAR(10), IN `p_telefono` VARCHAR(20), IN `p_fecha_nacimiento` DATE, IN `p_nacionalidad` VARCHAR(100), IN `p_lugar_nacimiento` VARCHAR(100), IN `p_hermanos` INT, IN `p_enfermedades` TEXT, IN `p_asistencia_psicopedagogica` BOOLEAN, IN `p_especialidad` VARCHAR(50), IN `p_telefono_emergencia` VARCHAR(20), IN `p_contacto_emergencia` VARCHAR(100))   BEGIN
    DECLARE v_persona_id INT;
    DECLARE v_grado_id INT;
    DECLARE v_grado_nombre VARCHAR(50);
    DECLARE v_especialidad_valida ENUM('Bachiller en Economía y Administración', 'Bachiller en Turismo');

    -- Obtener el ID de la persona física y el grado del alumno
    SELECT a.persona_fisica_id, a.grado_id INTO v_persona_id, v_grado_id
    FROM alumnos a
    JOIN personas_fisicas pf ON a.persona_fisica_id = pf.id
    WHERE pf.dni = p_dni;
    
    IF v_persona_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alumno no encontrado';
    END IF;

    -- Obtener nombre del grado
    SELECT nombre INTO v_grado_nombre FROM grados WHERE id = v_grado_id;

    -- Validar especialidad solo para grados 4°, 5° y 6°
    IF v_grado_nombre REGEXP '^[456]' THEN
        IF p_especialidad IS NULL OR p_especialidad = '' THEN
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Debe especificar una especialidad para este grado';
        END IF;

        -- Validar y normalizar la especialidad
        IF p_especialidad IN ('Bachiller en Economía y Administración', 'Bachiller en Turismo') THEN
            SET v_especialidad_valida = p_especialidad;
        ELSEIF p_especialidad LIKE '%Econom%' THEN
            SET v_especialidad_valida = 'Economía';
        ELSEIF p_especialidad LIKE '%Turis%' THEN
            SET v_especialidad_valida = 'Turismo';
        ELSE
            SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Especialidad no válida. Debe ser "Bachiller en Economía y Administracíon" o "Bachiller en Turismo"';
        END IF;
    ELSE
        SET v_especialidad_valida = NULL;
    END IF;

    -- Actualizar datos en personas_fisicas
    UPDATE personas_fisicas 
    SET 
        nombre = p_nombre,
        apellido = p_apellido,
        email = p_email,
        direccion = p_direccion,
        localidad = p_localidad,
        codigo_postal = p_codigo_postal,
        telefono = p_telefono,
        fecha_nacimiento = p_fecha_nacimiento,
        actualizado_en = CURRENT_TIMESTAMP()
    WHERE id = v_persona_id;
    
    -- Actualizar datos en alumnos
    UPDATE alumnos
    SET
        nacionalidad = p_nacionalidad,
        lugar_nacimiento = p_lugar_nacimiento,
        hermanos = p_hermanos,
        enfermedades = p_enfermedades,
        asistencia_psicopedagogica = p_asistencia_psicopedagogica,
        especialidad = v_especialidad_valida,
        telefono_emergencia = p_telefono_emergencia,
        contacto_emergencia = p_contacto_emergencia,
        actualizado_en = CURRENT_TIMESTAMP()
    WHERE persona_fisica_id = v_persona_id;
    
    SELECT 'Alumno modificado exitosamente' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `modificar_tema_evaluacion` (IN `p_tema_id` INT, IN `p_profesor_id` INT, IN `p_materia_id` INT, IN `p_grado_id` INT, IN `p_evaluacion_id` INT, IN `p_tipo_evaluacion_id` INT, IN `p_nombre_tema` VARCHAR(255), IN `p_descripcion` TEXT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_fecha_evaluacion` DATE)   BEGIN
    DECLARE v_profesor_autor_id INT;

    -- Verificar que el tema exista y pertenezca al profesor
    SELECT profesor_id INTO v_profesor_autor_id FROM temas_evaluacion WHERE id = p_tema_id;
    
    IF v_profesor_autor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El tema de evaluación no existe.';
    ELSEIF v_profesor_autor_id != p_profesor_id THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: No tiene permisos para modificar este tema.';
    ELSE
        -- Actualizar el tema con todos los campos
        UPDATE temas_evaluacion
        SET
            materia_id = p_materia_id,
            grado_id = p_grado_id,
            evaluacion_id = p_evaluacion_id,
            tipo_evaluacion_id = p_tipo_evaluacion_id,
            nombre_tema = p_nombre_tema,
            descripcion = p_descripcion,
            fecha_inicio = p_fecha_inicio,
            fecha_fin = p_fecha_fin,
            fecha_evaluacion = p_fecha_evaluacion,
            actualizado_en = CURRENT_TIMESTAMP()
        WHERE id = p_tema_id;

        SELECT 'Tema de evaluación modificado exitosamente' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_boletin` (IN `p_alumno_id` INT, IN `p_anio_lectivo` YEAR)   BEGIN
    DECLARE v_grado_id INT;

    -- Obtener grado del alumno
    SELECT grado_id INTO v_grado_id FROM alumnos WHERE id = p_alumno_id;

    IF v_grado_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alumno no encontrado o sin grado asignado.';
    END IF;

    -- Retornar información del grado
    SELECT 
        g.nombre AS grado,
        d.nombre AS division,
        IFNULL(t.nombre, 'No especificado') AS turno
    FROM grados g
    JOIN divisiones d ON g.division_id = d.id
    LEFT JOIN turnos t ON g.turno_id = t.id
    WHERE g.id = v_grado_id;

    -- Obtener el boletín con el estado de cada evaluación
    SELECT
        e.numero_evaluacion,
        e.nombre AS evaluacion,
        m.nombre AS materia,
        te.nombre_tema,
        MAX(CASE WHEN c.intento = 1 THEN c.nota ELSE NULL END) AS nota_primer_intento,
        MAX(CASE WHEN c.intento = 2 THEN c.nota ELSE NULL END) AS nota_primer_recuperatorio,
        MAX(CASE WHEN c.intento = 3 THEN c.nota ELSE NULL END) AS nota_segundo_recuperatorio,
        COALESCE(
            MAX(CASE WHEN c.intento = 3 THEN c.nota ELSE NULL END),
            MAX(CASE WHEN c.intento = 2 THEN c.nota ELSE NULL END),
            MAX(CASE WHEN c.intento = 1 THEN c.nota ELSE NULL END)
        ) AS nota_final,
        CASE
            WHEN COALESCE(
                MAX(CASE WHEN c.intento = 3 THEN c.nota ELSE NULL END),
                MAX(CASE WHEN c.intento = 2 THEN c.nota ELSE NULL END),
                MAX(CASE WHEN c.intento = 1 THEN c.nota ELSE NULL END)
            ) >= 6.00 THEN 'Aprobado'
            WHEN COALESCE(
                MAX(CASE WHEN c.intento = 3 THEN c.nota ELSE NULL END),
                MAX(CASE WHEN c.intento = 2 THEN c.nota ELSE NULL END),
                MAX(CASE WHEN c.intento = 1 THEN c.nota ELSE NULL END)
            ) IS NULL THEN 'Pendiente'
            ELSE 'Desaprobado'
        END AS estado
    FROM evaluaciones e
    JOIN temas_evaluacion te ON e.id = te.evaluacion_id
    JOIN materias m ON te.materia_id = m.id
    LEFT JOIN calificaciones c ON te.id = c.tema_evaluacion_id AND c.alumno_id = p_alumno_id
    WHERE e.anio_lectivo = p_anio_lectivo
      AND te.grado_id = v_grado_id
    GROUP BY e.id, m.id, te.id
    ORDER BY e.numero_evaluacion, m.nombre;

    -- Obtener resumen de asistencias (se mantiene igual)
    SELECT
        COUNT(*) AS total_dias,
        SUM(CASE WHEN estado = 'Presente' THEN 1 ELSE 0 END) AS presentes,
        SUM(CASE WHEN estado = 'Ausente' THEN 1 ELSE 0 END) AS ausentes,
        SUM(CASE WHEN estado = 'Justificado' THEN 1 ELSE 0 END) AS justificados,
        SUM(CASE WHEN estado = 'Tardanza' THEN 1 ELSE 0 END) AS tardanzas
    FROM asistencias
    WHERE alumno_id = p_alumno_id
    AND YEAR(fecha) = p_anio_lectivo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_entregas_por_tarea` (IN `p_contenido_id` INT)   BEGIN
    SELECT 
        te.id AS entrega_id,
        te.fecha_entrega,
        te.ruta_archivo,
        te.comentario_alumno,
        te.calificacion,
        te.comentario_profesor,
        a.id AS alumno_id,
        CONCAT(pf.apellido, ', ', pf.nombre) AS nombre_completo
    FROM tarea_entregas te
    JOIN alumnos a ON te.alumno_id = a.id
    JOIN personas_fisicas pf ON a.persona_fisica_id = pf.id
    WHERE te.contenido_id = p_contenido_id
    ORDER BY pf.apellido, pf.nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_evaluaciones_por_profesor` (IN `p_profesor_id` INT, IN `p_anio_lectivo` YEAR)   BEGIN
    -- Obtener todas las evaluaciones con sus temas creados por este profesor
    SELECT 
        e.numero_evaluacion,
        e.nombre AS nombre_evaluacion,
        te.id AS tema_evaluacion_id,
        te.nombre_tema,
        m.nombre AS materia,
        g.nombre AS grado,
        d.nombre AS division,
        te.fecha_inicio,
        te.fecha_fin,
        te.fecha_evaluacion,
        COUNT(c.id) AS cantidad_calificaciones
    FROM evaluaciones e
    LEFT JOIN temas_evaluacion te ON e.id = te.evaluacion_id 
                                  AND te.profesor_id = p_profesor_id
                                  AND YEAR(te.fecha_establecida) = p_anio_lectivo
    LEFT JOIN materias m ON te.materia_id = m.id
    LEFT JOIN grados g ON te.grado_id = g.id
    LEFT JOIN divisiones d ON g.division_id = d.id
    LEFT JOIN calificaciones c ON te.id = c.tema_evaluacion_id
    GROUP BY e.id, te.id
    ORDER BY e.numero_evaluacion, m.nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_horario` (IN `p_grado_id` INT)   BEGIN
    -- Verificar que el grado existe
    IF NOT EXISTS (SELECT 1 FROM grados WHERE id = p_grado_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Grado no encontrado';
    END IF;
    
    -- Obtener horario ordenado por día y hora
    SELECT 
        h.dia_semana,
        h.hora_inicio,
        h.hora_fin,
        m.nombre AS materia,
        CONCAT(pf.nombre, ' ', pf.apellido) AS profesor,
        h.aula
    FROM horarios h
    JOIN profesor_materia pm ON h.profesor_materia_id = pm.id
    JOIN materias m ON pm.materia_id = m.id
    JOIN profesores pr ON pm.profesor_id = pr.id
    JOIN personas_fisicas pf ON pr.persona_fisica_id = pf.id
    WHERE h.grado_id = p_grado_id
    ORDER BY 
        FIELD(h.dia_semana, 'Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado'),
        h.hora_inicio;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_info_alumno` (IN `p_alumno_id` INT)   BEGIN
    -- Información básica del alumno
    SELECT 
        a.id AS alumno_id,
        pf.dni,
        pf.nombre,
        pf.apellido,
        pf.fecha_nacimiento,
        pf.direccion,
        pf.localidad,
        pf.codigo_postal,
        pf.telefono,
        pf.email,
        g.nombre AS grado,
        d.nombre AS division,
        IFNULL(t.nombre, 'No especificado') AS turno,
        a.nacionalidad,
        a.lugar_nacimiento,
        a.telefono_emergencia,
        a.contacto_emergencia,
        a.fecha_ingreso,
        a.fecha_egreso,
        a.egresado,
        a.especialidad,
        a.hermanos,
        a.enfermedades,
        a.asistencia_psicopedagogica,
        a.observaciones
    FROM alumnos a
    JOIN personas_fisicas pf ON a.persona_fisica_id = pf.id
    JOIN grados g ON a.grado_id = g.id
    JOIN divisiones d ON g.division_id = d.id
    LEFT JOIN turnos t ON g.turno_id = t.id
    WHERE a.id = p_alumno_id;
    
    -- Tutores del alumno
    SELECT 
        at.id AS vinculacion_id,
        pf.dni,
        pf.nombre,
        pf.apellido,
        at.parentesco,
        at.es_principal
    FROM alumno_tutor at
    JOIN usuarios u ON at.tutor_id = u.id
    JOIN personas_fisicas pf ON u.persona_fisica_id = pf.id
    WHERE at.alumno_id = p_alumno_id;
    
    -- Historial de sanciones
    SELECT 
        tipo,
        fecha,
        descripcion,
        medidas,
        fecha_resolucion
    FROM sanciones
    WHERE alumno_id = p_alumno_id
    ORDER BY fecha DESC;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_materias_activas_grado` (IN `p_grado_id` INT)   BEGIN
    SELECT m.id, m.nombre, m.descripcion, m.horas_semanales, m.es_especialidad
    FROM materia_grado mg
    JOIN materias m ON mg.materia_id = m.id
    WHERE mg.grado_id = p_grado_id
    AND m.activa = 1
    ORDER BY m.nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_materias_para_gestion` (IN `p_grado_id` INT)   BEGIN
    SELECT m.id, m.nombre, m.descripcion, m.activa
    FROM materia_grado mg
    JOIN materias m ON mg.materia_id = m.id
    WHERE mg.grado_id = p_grado_id
    ORDER BY m.nombre;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `obtener_profesores_por_especialidad` (IN `p_especialidad_id` INT)   BEGIN
    SELECT 
        p.id AS profesor_id,
        CONCAT(pf.nombre, ' ', pf.apellido) AS nombre_completo,
        pf.dni,
        p.titulo,
        e.nombre AS especialidad,
        pe.es_principal,
        COUNT(pm.materia_id) AS total_materias
    FROM profesores p
    JOIN personas_fisicas pf ON p.persona_fisica_id = pf.id
    JOIN profesor_especialidad pe ON p.id = pe.profesor_id
    JOIN especialidades e ON pe.especialidad_id = e.id
    LEFT JOIN profesor_materia pm ON p.id = pm.profesor_id
    WHERE pe.especialidad_id = p_especialidad_id
    GROUP BY p.id, pf.nombre, pf.apellido, pf.dni, p.titulo, e.nombre, pe.es_principal
    ORDER BY pe.es_principal DESC, nombre_completo;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reactivar_materia` (IN `p_materia_id` INT)   BEGIN
    UPDATE materias 
    SET activa = 1 
    WHERE id = p_materia_id;
    
    SELECT CONCAT('Materia ', nombre, ' reactivada') AS mensaje
    FROM materias
    WHERE id = p_materia_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `reactivar_profesor` (IN `p_profesor_id` INT)   BEGIN
    DECLARE v_usuario_id INT;
    DECLARE v_profesor_activo INT;

    -- Verificar que el profesor exista y obtener su ID de usuario y estado actual
    SELECT p.usuario_id, u.activo INTO v_usuario_id, v_profesor_activo
    FROM profesores p
    JOIN usuarios u ON p.usuario_id = u.id
    WHERE p.id = p_profesor_id;

    IF v_usuario_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: El profesor no existe.';
    ELSEIF v_profesor_activo = 1 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error: Este profesor ya se encuentra activo.';
    END IF;

    -- Reactivar al usuario asociado al profesor
    UPDATE usuarios SET activo = 1 WHERE id = v_usuario_id;

    SELECT 'Profesor reactivado exitosamente. Ahora puede asignarle materias y horarios.' AS mensaje;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_asistencia` (IN `p_alumno_id` INT, IN `p_fecha` DATE, IN `p_estado` ENUM('Presente','Ausente','Justificado','Tardanza'), IN `p_observaciones` TEXT, IN `p_registrado_por` INT)   BEGIN
    DECLARE v_existe INT;
    
    -- Verificar si ya existe un registro para este alumno en la fecha
    SELECT COUNT(*) INTO v_existe 
    FROM asistencias 
    WHERE alumno_id = p_alumno_id AND fecha = p_fecha;
    
    IF v_existe > 0 THEN
        -- Actualizar registro existente
        UPDATE asistencias
        SET
            estado = p_estado,
            observaciones = p_observaciones,
            registrado_por = p_registrado_por
        WHERE alumno_id = p_alumno_id AND fecha = p_fecha;
        
        SELECT 'Asistencia actualizada exitosamente' AS mensaje;
    ELSE
        -- Crear nuevo registro
        INSERT INTO asistencias (
            alumno_id, fecha, estado, observaciones, registrado_por
        ) VALUES (
            p_alumno_id, p_fecha, p_estado, p_observaciones, p_registrado_por
        );
        
        SELECT 'Asistencia registrada exitosamente' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_calificacion` (IN `p_alumno_id` INT, IN `p_tema_evaluacion_id` INT, IN `p_nota` DECIMAL(4,2), IN `p_fecha_calificacion` DATE, IN `p_observaciones` TEXT, IN `p_intento` TINYINT)   BEGIN
    DECLARE v_fecha_inicio DATE;
    DECLARE v_fecha_fin DATE;
    DECLARE v_profesor_tema_id INT;
    DECLARE v_mensaje_error VARCHAR(500);

    -- Obtener datos del tema de evaluación incluyendo el profesor_id
    SELECT fecha_inicio, fecha_fin, profesor_id 
    INTO v_fecha_inicio, v_fecha_fin, v_profesor_tema_id
    FROM temas_evaluacion 
    WHERE id = p_tema_evaluacion_id;

    -- Validar fecha de calificación
    IF p_fecha_calificacion NOT BETWEEN v_fecha_inicio AND v_fecha_fin THEN
        SET v_mensaje_error = CONCAT('La fecha de calificación debe estar entre ', 
                                   DATE_FORMAT(v_fecha_inicio, '%d/%m/%Y'), ' y ', 
                                   DATE_FORMAT(v_fecha_fin, '%d/%m/%Y'));
        SIGNAL SQLSTATE '45000' 
        SET MESSAGE_TEXT = v_mensaje_error;
    END IF;

    -- Insertar o actualizar la calificación (sin usar profesor_id en la inserción)
    INSERT INTO calificaciones (
        alumno_id,
        tema_evaluacion_id,
        nota,
        fecha_calificacion,
        observaciones,
        recuperatorio,
        intento
    ) VALUES (
        p_alumno_id,
        p_tema_evaluacion_id,
        p_nota,
        p_fecha_calificacion,
        p_observaciones,
        CASE WHEN p_intento > 1 THEN 1 ELSE 0 END,
        p_intento
    )
    ON DUPLICATE KEY UPDATE
        nota = VALUES(nota),
        fecha_calificacion = VALUES(fecha_calificacion),
        observaciones = VALUES(observaciones),
        recuperatorio = VALUES(recuperatorio),
        intento = VALUES(intento);

    SELECT 'Calificación registrada/actualizada exitosamente' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_calificacion_por_tema` (IN `p_alumno_id` INT, IN `p_tema_evaluacion_id` INT, IN `p_profesor_id` INT, IN `p_calificacion` DECIMAL(4,2), IN `p_fecha_calificacion` DATE, IN `p_observaciones` TEXT)   BEGIN
    DECLARE v_materia_id INT;
    DECLARE v_grado_id INT;
    DECLARE v_tipo_evaluacion_id INT;
    DECLARE v_anio_lectivo INT;
    DECLARE v_profesor_tema_id INT;
    DECLARE v_calificacion_existente INT DEFAULT 0;

    -- Verificar si ya existe una calificación para este alumno y tema
    SELECT COUNT(*) INTO v_calificacion_existente
    FROM calificaciones
    WHERE alumno_id = p_alumno_id AND tema_evaluacion_id = p_tema_evaluacion_id;

    IF v_calificacion_existente > 0 THEN
        -- Si ya existe, actualizamos la nota existente
        UPDATE calificaciones
        SET
            nota = p_calificacion,
            fecha_calificacion = p_fecha_calificacion,
            observaciones = p_observaciones,
            profesor_id = p_profesor_id,
            actualizado_en = CURRENT_TIMESTAMP()
        WHERE
            alumno_id = p_alumno_id AND tema_evaluacion_id = p_tema_evaluacion_id;
        
        SELECT 'Calificación actualizada exitosamente' AS mensaje;

    ELSE
        -- Si no existe, obtenemos los datos del tema para crear la nueva calificación
        SELECT materia_id, grado_id, tipo_evaluacion_id, anio_lectivo, profesor_id
        INTO v_materia_id, v_grado_id, v_tipo_evaluacion_id, v_anio_lectivo, v_profesor_tema_id
        FROM temas_evaluacion
        WHERE id = p_tema_evaluacion_id;

        -- Validamos que el profesor que califica sea el mismo que creó el tema
        IF v_profesor_tema_id != p_profesor_id THEN
             SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Error de permiso: Usted no es el autor de este tema de evaluación.';
        ELSE
            -- Insertamos la nueva calificación
            INSERT INTO calificaciones (
                alumno_id,
                materia_id,
                grado_id,
                profesor_id,
                tipo_evaluacion_id,
                anio_lectivo,
                nota,
                fecha_calificacion,
                observaciones,
                creado_en,
                tema_evaluacion_id
            ) VALUES (
                p_alumno_id,
                v_materia_id,
                v_grado_id,
                p_profesor_id,
                v_tipo_evaluacion_id,
                v_anio_lectivo,
                p_calificacion,
                p_fecha_calificacion,
                p_observaciones,
                CURRENT_TIMESTAMP(),
                p_tema_evaluacion_id
            );
            
            SELECT 'Calificación registrada exitosamente' AS mensaje;
        END IF;
    END IF;

END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_egreso` (IN `p_alumno_id` INT, IN `p_anio_egreso` YEAR, IN `p_fecha_egreso` DATE, IN `p_motivo` VARCHAR(255), IN `p_observaciones` TEXT)   BEGIN
    DECLARE v_count INT;

    -- Verifica que el alumno exista
    SELECT COUNT(*) INTO v_count FROM alumnos WHERE id = p_alumno_id;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El alumno no existe';
    ELSE
        -- Registrar el egreso
        INSERT INTO egresos (
            alumno_id, anio_egreso, fecha_egreso, motivo, observaciones
        ) VALUES (
            p_alumno_id, p_anio_egreso, p_fecha_egreso, p_motivo, p_observaciones
        );
        
        -- Marcar al alumno como egresado
        UPDATE alumnos 
        SET 
            egresado = 1,
            fecha_egreso = p_fecha_egreso
        WHERE id = p_alumno_id;
        
        SELECT 'Egreso registrado exitosamente' AS mensaje;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_evento` (IN `p_titulo` VARCHAR(100), IN `p_descripcion` TEXT, IN `p_fecha_inicio` DATETIME, IN `p_fecha_fin` DATETIME, IN `p_ubicacion` VARCHAR(100), IN `p_tipo` ENUM('Académico','Cultural','Deportivo','Administrativo','Otro'))   BEGIN
    -- Validar fechas
    IF p_fecha_fin IS NOT NULL AND p_fecha_fin < p_fecha_inicio THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de fin no puede ser anterior a la fecha de inicio';
    END IF;
    
    -- Insertar evento
    INSERT INTO eventos (
        titulo, descripcion, fecha_inicio, fecha_fin, 
        ubicacion, tipo
    ) VALUES (
        p_titulo, p_descripcion, p_fecha_inicio, p_fecha_fin,
        p_ubicacion, p_tipo
    );
    
    SELECT 'Evento registrado exitosamente' AS mensaje, LAST_INSERT_ID() AS evento_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_sancion` (IN `p_alumno_id` INT, IN `p_tipo` ENUM('Amonestación','Suspensión','Observación','Otro'), IN `p_fecha` DATE, IN `p_descripcion` TEXT, IN `p_medidas` TEXT, IN `p_fecha_resolucion` DATE)   BEGIN
    -- Validar que el alumno existe
    IF NOT EXISTS (SELECT 1 FROM alumnos WHERE id = p_alumno_id) THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alumno no encontrado';
    END IF;
    
    -- Validar fechas
    IF p_fecha_resolucion IS NOT NULL AND p_fecha_resolucion < p_fecha THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de resolución no puede ser anterior a la fecha de sanción';
    END IF;
    
    -- Insertar sanción
    INSERT INTO sanciones (
        alumno_id, tipo, fecha, descripcion, 
        medidas, fecha_resolucion
    ) VALUES (
        p_alumno_id, p_tipo, p_fecha, p_descripcion,
        p_medidas, p_fecha_resolucion
    );
    
    SELECT 'Sanción registrada exitosamente' AS mensaje;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `registrar_tema_evaluacion` (IN `p_materia_id` INT, IN `p_profesor_id` INT, IN `p_grado_id` INT, IN `p_evaluacion_id` TINYINT, IN `p_tipo_evaluacion_id` INT, IN `p_nombre_tema` VARCHAR(255), IN `p_descripcion` TEXT, IN `p_fecha_inicio` DATE, IN `p_fecha_fin` DATE, IN `p_fecha_evaluacion` DATE)   BEGIN
    DECLARE v_anio_lectivo YEAR;
    DECLARE v_count INT;

    -- Validar fechas
    IF p_fecha_inicio > p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de inicio no puede ser posterior a la fecha de fin.';
    END IF;
    
    IF p_fecha_evaluacion NOT BETWEEN p_fecha_inicio AND p_fecha_fin THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'La fecha de evaluación debe estar dentro del rango de fechas del período.';
    END IF;

    -- Obtener año actual como año lectivo
    SET v_anio_lectivo = YEAR(CURDATE());

    -- Validar que el profesor está asignado a esa materia y grado en el año lectivo actual
    SELECT COUNT(*) INTO v_count
    FROM profesor_materia_grado
    WHERE profesor_id = p_profesor_id
      AND materia_id = p_materia_id
      AND grado_id = p_grado_id
      AND anio_lectivo = v_anio_lectivo;

    IF v_count = 0 THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'El profesor no está asignado a esta materia/grado para el año lectivo actual.';
    END IF;

    -- Insertar el nuevo tema de evaluación (CON LA CORRECCIÓN)
    INSERT INTO temas_evaluacion (
        materia_id,
        profesor_id,
        grado_id,
        evaluacion_id,
        tipo_evaluacion_id,
        nombre_tema,
        descripcion,
        fecha_establecida,
        fecha_evaluacion,
        fecha_inicio,
        fecha_fin,
        anio_lectivo -- <-- CAMBIO: Columna añadida
    ) VALUES (
        p_materia_id,
        p_profesor_id,
        p_grado_id,
        p_evaluacion_id,
        p_tipo_evaluacion_id,
        p_nombre_tema,
        p_descripcion,
        CURDATE(),
        p_fecha_evaluacion,
        p_fecha_inicio,
        p_fecha_fin,
        v_anio_lectivo -- <-- CAMBIO: Valor añadido
    );

    SELECT 'Tema de evaluación registrado exitosamente' AS mensaje, LAST_INSERT_ID() AS tema_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `vincular_tutor` (IN `p_alumno_id` INT, IN `p_tutor_dni` VARCHAR(20), IN `p_parentesco` VARCHAR(50), IN `p_es_principal` TINYINT(1))   BEGIN
    DECLARE v_tutor_id INT;
    DECLARE v_persona_id INT;
    
    -- Obtener ID del tutor (usuario con rol tutor)
    SELECT u.id INTO v_tutor_id
    FROM usuarios u
    JOIN personas_fisicas pf ON u.persona_fisica_id = pf.id
    WHERE pf.dni = p_tutor_dni AND u.rol_id = 6;
    
    IF v_tutor_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Tutor no encontrado. Verifique el DNI o que tenga el rol correcto';
    END IF;
    
    -- Verificar que el alumno existe
    SELECT persona_fisica_id INTO v_persona_id
    FROM alumnos
    WHERE id = p_alumno_id;
    
    IF v_persona_id IS NULL THEN
        SIGNAL SQLSTATE '45000' SET MESSAGE_TEXT = 'Alumno no encontrado';
    END IF;
    
    -- Si se marca como principal, quitar principal a otros tutores
    IF p_es_principal = 1 THEN
        UPDATE alumno_tutor
        SET es_principal = 0
        WHERE alumno_id = p_alumno_id;
    END IF;
    
    -- Vincular tutor a alumno
    INSERT INTO alumno_tutor (
        alumno_id, tutor_id, parentesco, es_principal
    ) VALUES (
        p_alumno_id, v_tutor_id, p_parentesco, p_es_principal
    )
    ON DUPLICATE KEY UPDATE 
        parentesco = p_parentesco,
        es_principal = p_es_principal;
    
    SELECT 'Tutor vinculado exitosamente' AS mensaje;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumnos`
--

CREATE TABLE `alumnos` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `persona_fisica_id` int(11) NOT NULL,
  `grado_id` int(11) DEFAULT NULL,
  `nacionalidad` varchar(100) DEFAULT NULL,
  `lugar_nacimiento` varchar(100) DEFAULT NULL,
  `telefono_emergencia` varchar(20) DEFAULT NULL,
  `contacto_emergencia` varchar(100) DEFAULT NULL,
  `fecha_ingreso` date DEFAULT curdate() COMMENT 'Fecha de ingreso al establecimiento',
  `fecha_egreso` date DEFAULT NULL COMMENT 'Fecha de egreso del establecimiento',
  `egresado` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 = No egresado, 1 = Egresado',
  `especialidad` enum('Bachiller en Economía y Administración','Bachiller en Turismo') DEFAULT NULL COMMENT 'Solo para 4º, 5º y 6º año',
  `hermanos` int(11) DEFAULT NULL COMMENT 'Cantidad de hermanos',
  `enfermedades` text DEFAULT NULL,
  `asistencia_psicopedagogica` tinyint(1) DEFAULT 0 COMMENT '0 = No, 1 = Sí',
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `alumnos`
--

INSERT INTO `alumnos` (`id`, `usuario_id`, `persona_fisica_id`, `grado_id`, `nacionalidad`, `lugar_nacimiento`, `telefono_emergencia`, `contacto_emergencia`, `fecha_ingreso`, `fecha_egreso`, `egresado`, `especialidad`, `hermanos`, `enfermedades`, `asistencia_psicopedagogica`, `observaciones`, `creado_en`, `actualizado_en`) VALUES
(3, 9, 20, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(4, 10, 21, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(5, 11, 22, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(6, 12, 23, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(7, 13, 24, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(8, 14, 25, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(9, 15, 26, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(10, 16, 27, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(11, 17, 28, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(12, 18, 29, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(13, 19, 30, 12, 'Argentina', 'Córdoba', '3519999999', 'Madre/Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(14, 20, 31, 12, 'Bolivia', 'Argentina', '3517414545', 'Mama', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 05:42:34', '2025-12-19 05:42:34'),
(16, 30, 39, 12, 'Argentina', 'Argentina', '3517414545', 'Mama', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, '', 0, '', '2025-12-19 06:09:39', '2025-12-19 06:09:39'),
(22, 36, 45, 2, 'Argentina', 'Córdoba', '3519999991', 'Madre', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 0, '', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(23, 37, 46, 2, 'Argentina', 'Córdoba', '3519999992', 'Padre', '2025-12-19', NULL, 0, NULL, 0, 'Alergia', 0, '', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(24, 38, 47, 2, 'Argentina', 'Córdoba', '3519999993', 'Abuela', '2025-12-19', NULL, 0, NULL, 2, 'Ninguna', 1, '', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(25, 39, 48, 2, 'Argentina', 'Villa Allende', '3519999994', 'Tío', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(26, 40, 49, 2, 'Argentina', 'Carlos Paz', '3519999995', 'Madre', '2025-12-19', NULL, 0, NULL, 1, 'Asma', 0, '', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(27, 41, 50, 1, 'Argentina', 'Córdoba', '3519999996', 'Padre', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(28, 42, 51, 1, 'Argentina', 'Córdoba', '3519999997', 'Madre', '2025-12-19', NULL, 0, NULL, 1, 'Celiaquía', 0, '', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(29, 43, 52, 1, 'Argentina', 'Córdoba', '3519999998', 'Tía', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 1, 'Apoyo escolar', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(30, 44, 53, 1, 'Argentina', 'Córdoba', '3519999999', 'Abuelo', '2025-12-19', NULL, 0, NULL, 2, 'Ninguna', 0, '', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(31, 45, 54, 1, 'Argentina', 'Córdoba', '3519999900', 'Madre', '2025-12-19', NULL, 0, NULL, 0, 'Miopía', 0, '', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(32, 46, 55, 3, 'Argentina', 'Córdoba', '3519999901', 'Padre', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 0, '', '2025-12-19 13:17:13', '2025-12-19 13:17:13'),
(33, 47, 56, 3, 'Argentina', 'Córdoba', '3519999902', 'Madre', '2025-12-19', NULL, 0, NULL, 0, 'Asma', 0, '', '2025-12-19 13:17:13', '2025-12-19 13:17:13'),
(34, 48, 57, 3, 'Argentina', 'Córdoba', '3519999903', 'Abuela', '2025-12-19', NULL, 0, NULL, 2, 'Ninguna', 1, 'Dificultad en matemáticas', '2025-12-19 13:17:13', '2025-12-19 13:17:13'),
(35, 49, 58, 3, 'Argentina', 'Córdoba', '3519999904', 'Tío', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:17:14', '2025-12-19 13:17:14'),
(36, 50, 59, 3, 'Argentina', 'Córdoba', '3519999905', 'Padre', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 0, '', '2025-12-19 13:17:14', '2025-12-19 13:17:14'),
(37, 51, 60, 4, 'Argentina', 'Córdoba', '3519999906', 'Madre', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(38, 52, 61, 4, 'Argentina', 'Córdoba', '3519999907', 'Padre', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 0, '', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(39, 53, 62, 4, 'Argentina', 'Córdoba', '3519999908', 'Abuelo', '2025-12-19', NULL, 0, NULL, 0, 'Alergia a penicilina', 0, '', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(40, 54, 63, 4, 'Argentina', 'Córdoba', '3519999909', 'Madre', '2025-12-19', NULL, 0, NULL, 2, 'Ninguna', 0, '', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(41, 55, 64, 4, 'Argentina', 'Córdoba', '3519999910', 'Padre', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 1, 'Acompañante terapéutico', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(42, 56, 65, 5, 'Argentina', 'Córdoba', '3519999911', 'Madre', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 0, '', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(43, 57, 66, 5, 'Argentina', 'Córdoba', '3519999912', 'Padre', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(44, 58, 67, 5, 'Argentina', 'Córdoba', '3519999913', 'Tía', '2025-12-19', NULL, 0, NULL, 2, 'Diabetes tipo 1', 0, 'Requiere control de insulina', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(45, 59, 68, 5, 'Argentina', 'Córdoba', '3519999914', 'Madre', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(46, 60, 69, 5, 'Argentina', 'Córdoba', '3519999915', 'Abuelo', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 1, 'Dificultad de aprendizaje', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(47, 61, 70, 6, 'Argentina', 'Córdoba', '3519999916', 'Madre', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(48, 62, 71, 6, 'Argentina', 'Córdoba', '3519999917', 'Padre', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 0, '', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(49, 63, 72, 6, 'Argentina', 'Córdoba', '3519999918', 'Abuela', '2025-12-19', NULL, 0, NULL, 2, 'Ninguna', 1, 'Seguimiento por inasistencias', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(50, 64, 73, 6, 'Argentina', 'Córdoba', '3519999919', 'Tío', '2025-12-19', NULL, 0, NULL, 0, 'Ninguna', 0, '', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(51, 65, 74, 6, 'Argentina', 'Córdoba', '3519999920', 'Madre', '2025-12-19', NULL, 0, NULL, 1, 'Ninguna', 0, '', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(52, 66, 75, 7, 'Argentina', 'Córdoba', '3519999921', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 0, 'Ninguna', 0, '', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(53, 67, 76, 7, 'Argentina', 'Córdoba', '3519999922', 'Padre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 1, 'Ninguna', 0, '', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(54, 68, 77, 7, 'Argentina', 'Córdoba', '3519999923', 'Abuela', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 2, 'Asma', 0, '', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(55, 69, 78, 7, 'Argentina', 'Córdoba', '3519999924', 'Tío', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 0, 'Ninguna', 1, 'Dificultades de atención', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(56, 70, 79, 7, 'Argentina', 'Córdoba', '3519999925', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 1, 'Ninguna', 0, '', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(57, 71, 80, 8, 'Argentina', 'Córdoba', '3519999926', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, 'Ninguna', 0, '', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(58, 72, 81, 8, 'Argentina', 'Córdoba', '3519999927', 'Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 1, 'Ninguna', 0, '', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(59, 73, 82, 8, 'Argentina', 'Córdoba', '3519999928', 'Abuelo', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 2, 'Alergia al polen', 0, '', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(60, 74, 83, 8, 'Argentina', 'Córdoba', '3519999929', 'Tía', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, 'Ninguna', 1, 'Seguimiento académico', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(61, 75, 84, 8, 'Argentina', 'Córdoba', '3519999930', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 1, 'Ninguna', 0, '', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(62, 76, 85, 9, 'Argentina', 'Córdoba', '3519999931', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 0, 'Ninguna', 0, '', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(63, 77, 86, 9, 'Argentina', 'Córdoba', '3519999932', 'Padre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 1, 'Ninguna', 0, '', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(64, 78, 87, 9, 'Argentina', 'Córdoba', '3519999933', 'Abuela', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 2, 'Celiaquía', 0, '', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(65, 79, 88, 9, 'Argentina', 'Córdoba', '3519999934', 'Tío', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 0, 'Ninguna', 1, 'Acompañante externo', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(66, 80, 89, 9, 'Argentina', 'Córdoba', '3519999935', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 1, 'Ninguna', 0, '', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(67, 81, 90, 10, 'Argentina', 'Córdoba', '3519999936', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, 'Ninguna', 0, '', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(68, 82, 91, 10, 'Argentina', 'Córdoba', '3519999937', 'Padre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 1, 'Ninguna', 0, '', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(69, 83, 92, 10, 'Argentina', 'Córdoba', '3519999938', 'Abuelo', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 2, 'Ninguna', 1, 'Refuerzo en matemáticas', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(70, 84, 93, 10, 'Argentina', 'Córdoba', '3519999939', 'Tío', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 0, 'Alergia estacional', 0, '', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(71, 85, 94, 10, 'Argentina', 'Córdoba', '3519999940', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Economía y Administración', 1, 'Ninguna', 0, '', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(72, 86, 95, 11, 'Argentina', 'Córdoba', '3519999941', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 1, 'Ninguna', 0, '', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(73, 87, 96, 11, 'Argentina', 'Córdoba', '3519999942', 'Padre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 0, 'Asma', 0, '', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(74, 88, 97, 11, 'Argentina', 'Córdoba', '3519999943', 'Abuela', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 2, 'Ninguna', 1, 'Orientación vocacional', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(75, 89, 98, 11, 'Argentina', 'Córdoba', '3519999944', 'Tío', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 0, 'Ninguna', 0, '', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(76, 90, 99, 11, 'Argentina', 'Córdoba', '3519999945', 'Madre', '2025-12-19', NULL, 0, 'Bachiller en Turismo', 1, 'Ninguna', 0, '', '2025-12-19 13:26:59', '2025-12-19 13:26:59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno_respuestas`
--

CREATE TABLE `alumno_respuestas` (
  `id` int(11) NOT NULL,
  `formulario_id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `pregunta_id` int(11) NOT NULL,
  `opcion_seleccionada_id` int(11) DEFAULT NULL,
  `fecha_respuesta` timestamp NOT NULL DEFAULT current_timestamp(),
  `respuesta_texto` text DEFAULT NULL,
  `es_correcta` decimal(4,2) DEFAULT 0.00 COMMENT 'Puntaje: 1.00 es correcto, 0.00 incorrecto, decimales parcial'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `alumno_tutor`
--

CREATE TABLE `alumno_tutor` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `tutor_id` int(11) NOT NULL COMMENT 'ID del usuario con rol tutor',
  `parentesco` varchar(50) DEFAULT NULL,
  `es_principal` tinyint(1) DEFAULT 1 COMMENT '1 = tutor principal, 0 = no principal',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `alumno_tutor`
--

INSERT INTO `alumno_tutor` (`id`, `alumno_id`, `tutor_id`, `parentesco`, `es_principal`, `creado_en`) VALUES
(8, 16, 23, NULL, 1, '2025-12-19 12:36:40'),
(9, 10, 23, NULL, 1, '2025-12-19 12:36:40');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencias`
--

CREATE TABLE `asistencias` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `fecha` date NOT NULL,
  `estado` enum('Presente','Ausente','Justificado','Tardanza') NOT NULL,
  `observaciones` text DEFAULT NULL,
  `registrado_por` int(11) NOT NULL COMMENT 'Usuario que registró la asistencia',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `asistencia_justificaciones`
--

CREATE TABLE `asistencia_justificaciones` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `fecha_inasistencia` date NOT NULL,
  `motivo_html` text NOT NULL,
  `archivo_adjunto` varchar(255) DEFAULT NULL,
  `estado` enum('pendiente','aprobado','rechazado') NOT NULL DEFAULT 'pendiente',
  `respuesta_preceptor` text DEFAULT NULL,
  `fecha_respuesta` datetime DEFAULT NULL,
  `preceptor_usuario_id` int(11) DEFAULT NULL,
  `fecha_solicitud` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `calificaciones`
--

CREATE TABLE `calificaciones` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `tema_evaluacion_id` int(11) NOT NULL,
  `nota` decimal(4,2) NOT NULL,
  `fecha_calificacion` date NOT NULL,
  `fecha_creacion` timestamp NOT NULL DEFAULT current_timestamp(),
  `observaciones` text DEFAULT NULL,
  `intento` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = primer intento, 2 = primer recuperatorio, 3 = segundo recuperatorio',
  `recuperatorio` tinyint(1) NOT NULL DEFAULT 0 COMMENT '0 = evaluación normal, 1 = recuperatorio',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `calificaciones`
--

INSERT INTO `calificaciones` (`id`, `alumno_id`, `tema_evaluacion_id`, `nota`, `fecha_calificacion`, `fecha_creacion`, `observaciones`, `intento`, `recuperatorio`, `creado_en`, `actualizado_en`) VALUES
(2, 3, 2, 6.57, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(3, 4, 2, 7.91, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(4, 5, 2, 9.85, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(5, 6, 2, 9.51, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(6, 7, 2, 8.00, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(7, 8, 2, 7.48, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(8, 9, 2, 9.39, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(9, 10, 2, 8.51, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(10, 11, 2, 4.41, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(11, 12, 2, 4.51, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(12, 13, 2, 5.32, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(13, 14, 2, 9.07, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(14, 16, 2, 6.63, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(17, 3, 3, 5.73, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(18, 4, 3, 8.50, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(19, 5, 3, 9.32, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(20, 6, 3, 5.08, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(21, 7, 3, 5.47, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(22, 8, 3, 8.09, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(23, 9, 3, 8.05, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(24, 10, 3, 5.99, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(25, 11, 3, 7.80, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(26, 12, 3, 5.02, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(27, 13, 3, 9.73, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(28, 14, 3, 5.57, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(29, 16, 3, 7.16, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(32, 3, 4, 6.64, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(33, 4, 4, 9.19, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(34, 5, 4, 4.03, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(35, 6, 4, 6.59, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(36, 7, 4, 4.89, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(37, 8, 4, 6.65, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(38, 9, 4, 8.61, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(39, 10, 4, 7.12, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(40, 11, 4, 5.75, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(41, 12, 4, 9.40, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(42, 13, 4, 7.76, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(43, 14, 4, 6.61, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(44, 16, 4, 9.95, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(47, 3, 5, 5.03, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(48, 4, 5, 9.84, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(49, 5, 5, 6.10, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(50, 6, 5, 9.00, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(51, 7, 5, 4.72, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(52, 8, 5, 4.58, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(53, 9, 5, 4.77, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(54, 10, 5, 6.12, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(55, 11, 5, 6.29, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(56, 12, 5, 9.08, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(57, 13, 5, 4.52, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(58, 14, 5, 9.39, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(59, 16, 5, 6.26, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(62, 3, 6, 6.78, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(63, 4, 6, 7.73, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(64, 5, 6, 8.32, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(65, 6, 6, 8.43, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(66, 7, 6, 7.17, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(67, 8, 6, 6.56, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(68, 9, 6, 7.32, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(69, 10, 6, 6.91, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(70, 11, 6, 8.58, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(71, 12, 6, 6.20, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(72, 13, 6, 7.27, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(73, 14, 6, 7.75, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(74, 16, 6, 7.47, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(77, 3, 7, 7.50, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(78, 4, 7, 6.67, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(79, 5, 7, 6.85, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(80, 6, 7, 4.24, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(81, 7, 7, 8.64, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(82, 8, 7, 8.49, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(83, 9, 7, 6.53, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(84, 10, 7, 9.18, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(85, 11, 7, 4.34, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(86, 12, 7, 8.13, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(87, 13, 7, 5.66, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(88, 14, 7, 5.92, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(89, 16, 7, 8.55, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(92, 3, 8, 9.25, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(93, 4, 8, 4.46, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(94, 5, 8, 8.54, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(95, 6, 8, 7.33, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(96, 7, 8, 7.03, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(97, 8, 8, 9.19, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(98, 9, 8, 8.85, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(99, 10, 8, 6.70, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(100, 11, 8, 8.95, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(101, 12, 8, 8.66, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(102, 13, 8, 6.45, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(103, 14, 8, 8.27, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(104, 16, 8, 6.37, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(107, 3, 9, 7.32, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(108, 4, 9, 8.53, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(109, 5, 9, 4.67, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(110, 6, 9, 5.78, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(111, 7, 9, 4.89, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(112, 8, 9, 9.11, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(113, 9, 9, 8.89, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(114, 10, 9, 7.12, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(115, 11, 9, 4.96, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(116, 12, 9, 5.42, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(117, 13, 9, 8.22, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(118, 14, 9, 8.87, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(119, 16, 9, 8.18, '2025-12-19', '2025-12-19 16:18:56', 'Nota generada automáticamente', 1, 0, '2025-12-19 16:18:56', '2025-12-19 16:34:52'),
(130, 16, 10, 7.81, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(131, 16, 11, 8.51, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(132, 16, 12, 9.14, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(133, 16, 13, 6.16, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(134, 16, 14, 9.40, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(135, 16, 15, 6.53, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(136, 16, 16, 6.44, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(137, 16, 17, 6.60, '2025-12-19', '2025-12-19 16:26:40', 'Nota cargada por sistema', 1, 0, '2025-12-19 16:26:40', '2025-12-19 16:34:52'),
(154, 16, 18, 7.72, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(155, 16, 19, 8.78, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(156, 16, 20, 6.74, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(157, 16, 21, 9.35, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(158, 16, 22, 8.57, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(159, 16, 23, 8.80, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(160, 16, 24, 8.29, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(161, 16, 25, 9.06, '2025-12-19', '2025-12-19 16:29:14', 'Carga Completa', 1, 0, '2025-12-19 16:29:14', '2025-12-19 16:34:52'),
(186, 16, 26, 6.42, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(187, 16, 27, 6.92, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(188, 16, 28, 9.37, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(189, 16, 29, 8.08, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(190, 16, 30, 6.28, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(191, 16, 31, 9.16, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(192, 16, 32, 8.98, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(193, 16, 33, 7.43, '2025-12-19', '2025-12-19 16:33:05', 'Carga Completa', 1, 0, '2025-12-19 16:33:05', '2025-12-19 16:34:52'),
(226, 16, 34, 8.19, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(227, 16, 35, 8.68, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(228, 16, 36, 8.85, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(229, 16, 37, 8.22, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(230, 16, 38, 8.53, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(231, 16, 39, 7.99, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(232, 16, 40, 8.39, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(233, 16, 41, 7.98, '2025-12-19', '2025-12-19 16:33:35', 'Carga Completa', 1, 0, '2025-12-19 16:33:35', '2025-12-19 16:34:52'),
(274, 16, 42, 8.73, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(275, 16, 43, 9.71, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(276, 16, 44, 8.36, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(277, 16, 45, 6.67, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(278, 16, 46, 6.27, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(279, 16, 47, 9.34, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(280, 16, 48, 9.89, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(281, 16, 49, 7.45, '2025-12-19', '2025-12-19 16:33:51', 'Carga Completa', 1, 0, '2025-12-19 16:33:51', '2025-12-19 16:34:52'),
(330, 16, 50, 9.59, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:52'),
(331, 16, 51, 7.62, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:52'),
(332, 16, 52, 7.32, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:52'),
(333, 16, 53, 7.73, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:52'),
(334, 16, 54, 6.71, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:52'),
(335, 16, 55, 8.36, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:52'),
(336, 16, 56, 7.69, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:47'),
(337, 16, 57, 7.38, '2025-12-19', '2025-12-19 16:34:07', 'Carga Completa', 1, 0, '2025-12-19 16:34:07', '2025-12-19 16:34:52'),
(394, 16, 58, 7.83, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(395, 16, 59, 7.02, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(396, 16, 60, 9.62, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(397, 16, 61, 9.03, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(398, 16, 62, 6.29, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(399, 16, 63, 6.39, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(400, 16, 64, 7.07, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(401, 16, 65, 6.20, '2025-12-19', '2025-12-19 16:34:11', 'Carga Completa', 1, 0, '2025-12-19 16:34:11', '2025-12-19 16:34:52'),
(466, 16, 66, 7.77, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(467, 16, 67, 6.29, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(468, 16, 68, 6.11, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(469, 16, 69, 9.70, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(470, 16, 70, 8.19, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(471, 16, 71, 9.85, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(472, 16, 72, 6.70, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(473, 16, 73, 9.92, '2025-12-19', '2025-12-19 16:34:13', 'Carga Completa', 1, 0, '2025-12-19 16:34:13', '2025-12-19 16:34:52'),
(546, 16, 74, 7.53, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(547, 16, 75, 9.88, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(548, 16, 76, 8.82, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(549, 16, 77, 8.45, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(550, 16, 78, 9.81, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(551, 16, 79, 9.71, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(552, 16, 80, 9.10, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(553, 16, 81, 6.40, '2025-12-19', '2025-12-19 16:34:28', 'Carga Completa', 1, 0, '2025-12-19 16:34:28', '2025-12-19 16:34:52'),
(634, 16, 82, 6.71, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(635, 16, 83, 8.33, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(636, 16, 84, 7.54, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(637, 16, 85, 6.72, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(638, 16, 86, 9.00, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(639, 16, 87, 6.82, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(640, 16, 88, 9.11, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(641, 16, 89, 7.09, '2025-12-19', '2025-12-19 16:34:31', 'Carga Completa', 1, 0, '2025-12-19 16:34:31', '2025-12-19 16:34:52'),
(730, 16, 90, 6.12, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(731, 16, 91, 7.33, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(732, 16, 92, 8.30, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(733, 16, 93, 9.51, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(734, 16, 94, 8.64, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(735, 16, 95, 8.70, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(736, 16, 96, 7.57, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(737, 16, 97, 9.74, '2025-12-19', '2025-12-19 16:34:47', 'Carga Completa', 1, 0, '2025-12-19 16:34:47', '2025-12-19 16:34:52'),
(834, 16, 98, 8.01, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(835, 16, 99, 8.83, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(836, 16, 100, 6.11, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(837, 16, 101, 6.07, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(838, 16, 102, 6.02, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(839, 16, 103, 9.90, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(840, 16, 104, 9.44, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(841, 16, 105, 7.52, '2025-12-19', '2025-12-19 16:34:52', 'Carga Completa', 1, 0, '2025-12-19 16:34:52', '2025-12-19 16:34:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contenido_archivos`
--

CREATE TABLE `contenido_archivos` (
  `id` int(11) NOT NULL,
  `contenido_id` int(11) NOT NULL,
  `nombre_archivo` varchar(255) NOT NULL,
  `ruta_archivo` varchar(512) NOT NULL,
  `orden` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `contenido_archivos`
--

INSERT INTO `contenido_archivos` (`id`, `contenido_id`, `nombre_archivo`, `ruta_archivo`, `orden`) VALUES
(1, 5, 'Oferta y Demanda.pdf', '../uploads/contenido/doc_6945552fb7cd7.pdf', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `contenido_enlaces`
--

CREATE TABLE `contenido_enlaces` (
  `id` int(11) NOT NULL,
  `contenido_id` int(11) NOT NULL,
  `enlace_texto` varchar(255) NOT NULL,
  `enlace_url` text NOT NULL,
  `orden` int(11) NOT NULL DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `cuotas_mensuales`
--

CREATE TABLE `cuotas_mensuales` (
  `id` int(11) NOT NULL,
  `anio` year(4) NOT NULL,
  `mes` varchar(20) NOT NULL,
  `monto` decimal(10,2) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `cuotas_mensuales`
--

INSERT INTO `cuotas_mensuales` (`id`, `anio`, `mes`, `monto`, `creado_en`, `actualizado_en`) VALUES
(1, '2025', 'marzo', 5.00, '2025-11-18 04:28:17', '2025-12-19 12:37:32'),
(2, '2025', 'abril', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(3, '2025', 'mayo', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(4, '2025', 'junio', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(5, '2025', 'julio', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(6, '2025', 'agosto', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(7, '2025', 'septiembre', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(8, '2025', 'octubre', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(9, '2025', 'noviembre', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27'),
(10, '2025', 'diciembre', 86000.00, '2025-11-18 04:28:17', '2025-12-19 15:59:27');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `divisiones`
--

CREATE TABLE `divisiones` (
  `id` int(11) NOT NULL,
  `nombre` varchar(10) NOT NULL COMMENT 'A, B, C, etc.',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `divisiones`
--

INSERT INTO `divisiones` (`id`, `nombre`, `creado_en`, `actualizado_en`) VALUES
(1, 'A', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(2, 'B', '2025-08-10 04:34:18', '2025-08-10 04:34:18');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `egresos`
--

CREATE TABLE `egresos` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `anio_egreso` year(4) NOT NULL,
  `fecha_egreso` date NOT NULL,
  `motivo` varchar(255) DEFAULT NULL,
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `especialidades`
--

CREATE TABLE `especialidades` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `especialidades`
--

INSERT INTO `especialidades` (`id`, `nombre`, `descripcion`, `creado_en`, `actualizado_en`) VALUES
(1, 'Matemática', 'Área de matemáticas', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(2, 'Física', 'Área de física', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(3, 'Química', 'Área de química', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(4, 'Biología', 'Área de biología', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(5, 'Lengua y Literatura', 'Área de lengua y literatura', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(6, 'Historia', 'Área de historia', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(7, 'Geografía', 'Área de geografía', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(8, 'Inglés', 'Área de inglés', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(9, 'Educación Física', 'Área de educación física', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(10, 'Economía', 'Área de economía', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(11, 'Turismo', 'Área de turismo', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(12, 'Tecnología', 'Área de tecnología', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(13, 'Arte', 'Área de arte', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(14, 'Informática', 'Área de informática y programación', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(15, 'Filosofía', 'Área de filosofía', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(16, 'Psicología', 'Área de psicología', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(17, 'Otra', 'Otra especialidad no listada', '2025-08-10 04:34:18', '2025-08-10 04:34:18');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `evaluaciones`
--

CREATE TABLE `evaluaciones` (
  `id` tinyint(2) NOT NULL,
  `numero_evaluacion` tinyint(2) NOT NULL COMMENT '1 a 8',
  `nombre` varchar(50) NOT NULL COMMENT 'Evaluación 1, Evaluación 2, etc.',
  `descripcion` varchar(255) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `evaluaciones`
--

INSERT INTO `evaluaciones` (`id`, `numero_evaluacion`, `nombre`, `descripcion`) VALUES
(1, 1, 'Evaluación 1', NULL),
(2, 2, 'Evaluación 2', NULL),
(3, 3, 'Evaluación 3', NULL),
(4, 4, 'Evaluación 4', NULL),
(5, 5, 'Evaluación 5', NULL),
(6, 6, 'Evaluación 6', NULL),
(7, 7, 'Evaluación 7', NULL),
(8, 8, 'Evaluación 8', NULL);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `eventos`
--

CREATE TABLE `eventos` (
  `id` int(11) NOT NULL,
  `titulo` varchar(100) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_inicio` datetime NOT NULL,
  `fecha_fin` datetime DEFAULT NULL,
  `ubicacion` varchar(100) DEFAULT NULL,
  `tipo` enum('Académico','Cultural','Deportivo','Administrativo','Otro') NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formularios`
--

CREATE TABLE `formularios` (
  `id` int(11) NOT NULL,
  `contenido_id` int(11) NOT NULL COMMENT 'Vincula con la pestaña en materia_contenido',
  `titulo` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `limite_tiempo_minutos` int(11) DEFAULT NULL,
  `tema_evaluacion_id` int(11) DEFAULT NULL COMMENT 'Vincula el formulario a un tema de evaluación para calcular notas automáticas'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formulario_entregas`
--

CREATE TABLE `formulario_entregas` (
  `id` int(11) NOT NULL,
  `formulario_id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `fecha_entrega` datetime NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formulario_preguntas`
--

CREATE TABLE `formulario_preguntas` (
  `id` int(11) NOT NULL,
  `formulario_id` int(11) NOT NULL,
  `texto_pregunta` text NOT NULL,
  `tipo` enum('unica','multiple','texto') NOT NULL DEFAULT 'unica',
  `orden` int(11) NOT NULL DEFAULT 0,
  `puntaje` int(11) NOT NULL DEFAULT 1
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `formulario_sesiones`
--

CREATE TABLE `formulario_sesiones` (
  `id` int(11) NOT NULL,
  `formulario_id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `tiempo_inicio` datetime NOT NULL COMMENT 'Momento en que se inició o reanudó la sesión.',
  `tiempo_restante_seg` int(11) DEFAULT NULL COMMENT 'Tiempo restante en segundos.',
  `respuestas_parciales` longtext DEFAULT NULL COMMENT 'Respuestas incompletas del alumno en formato JSON.',
  `ultima_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp() COMMENT 'Marca la última vez que se guardó el progreso.'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `grados`
--

CREATE TABLE `grados` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL COMMENT 'Ej: 1°, 2°, etc.',
  `turno_id` int(11) DEFAULT NULL COMMENT 'Solo 1° tiene turno mañana y tarde',
  `division_id` int(11) NOT NULL,
  `tipo_ciclo` enum('Básico','Orientado Economía','Orientado Turismo') NOT NULL DEFAULT 'Básico' COMMENT 'Tipo de ciclo al que pertenece el grado',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `grados`
--

INSERT INTO `grados` (`id`, `nombre`, `turno_id`, `division_id`, `tipo_ciclo`, `creado_en`, `actualizado_en`) VALUES
(1, '1°', 2, 1, 'Básico', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(2, '1°', 1, 2, 'Básico', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(3, '2°', 2, 1, 'Básico', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(4, '2°', 1, 2, 'Básico', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(5, '3°', 1, 1, 'Básico', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(6, '3°', 1, 2, 'Básico', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(7, '4°', 1, 1, 'Orientado Turismo', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(8, '4°', 1, 2, 'Orientado Economía', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(9, '5°', 1, 1, 'Orientado Turismo', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(10, '5°', 1, 2, 'Orientado Economía', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(11, '6°', 1, 1, 'Orientado Turismo', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(12, '6°', 1, 2, 'Orientado Economía', '2025-08-10 04:34:18', '2025-08-10 04:34:18');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `horarios`
--

CREATE TABLE `horarios` (
  `id` int(11) NOT NULL,
  `profesor_materia_id` int(11) NOT NULL,
  `grado_id` int(11) NOT NULL,
  `dia_semana` enum('Lunes','Martes','Miércoles','Jueves','Viernes') NOT NULL,
  `hora_inicio` time NOT NULL,
  `hora_fin` time NOT NULL,
  `aula` varchar(20) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `horarios`
--

INSERT INTO `horarios` (`id`, `profesor_materia_id`, `grado_id`, `dia_semana`, `hora_inicio`, `hora_fin`, `aula`, `creado_en`) VALUES
(110, 6, 2, 'Lunes', '11:00:00', '11:01:00', '1a', '2025-12-19 16:02:02'),
(111, 7, 12, 'Jueves', '09:00:00', '11:00:00', 'A5', '2025-12-19 16:02:02'),
(112, 8, 12, 'Lunes', '07:00:00', '08:00:00', 'A1', '2025-12-19 16:02:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `intentos_login`
--

CREATE TABLE `intentos_login` (
  `id` int(11) NOT NULL,
  `usuario` varchar(50) NOT NULL,
  `intentos` int(11) DEFAULT 0,
  `bloqueado_hasta` datetime DEFAULT NULL,
  `factor_penalizacion` int(11) DEFAULT 1,
  `ultimo_intento` timestamp NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `intentos_login`
--

INSERT INTO `intentos_login` (`id`, `usuario`, `intentos`, `bloqueado_hasta`, `factor_penalizacion`, `ultimo_intento`) VALUES
(10, '45190987', 4, NULL, 1, '2025-12-19 06:06:01');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `materias`
--

CREATE TABLE `materias` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `horas_semanales` int(11) NOT NULL DEFAULT 0,
  `activa` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = materia activa, 0 = materia inactiva',
  `es_especialidad` tinyint(1) DEFAULT 0 COMMENT '1 = materia de especialidad, 0 = materia común',
  `especialidad` enum('Economía','Turismo','Común') NOT NULL DEFAULT 'Común' COMMENT 'Especialidad a la que pertenece la materia',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `materias`
--

INSERT INTO `materias` (`id`, `nombre`, `descripcion`, `horas_semanales`, `activa`, `es_especialidad`, `especialidad`, `creado_en`, `actualizado_en`) VALUES
(1, 'Lengua y Literatura 1°', 'Gramática, comprensión lectora y producción escrita para primer año', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(2, 'Matemática 1°', 'Matemáticas básicas para primer año', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(3, 'Biología 1°', 'Introducción a las ciencias biológicas', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(4, 'Física 1°', 'Conceptos básicos de física', 3, 0, 0, 'Común', '2025-08-10 04:34:19', '2025-09-26 04:38:00'),
(5, 'Geografía 1°', 'Geografía general y Argentina', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(6, 'Inglés 1°', 'Inglés básico para primer año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(7, 'Educación Artística 1°', 'Artes plásticas y visuales', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(8, 'Educación Tecnológica 1°', 'Tecnología y procesos productivos básicos', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(9, 'Ciudadanía y Participación 1°', 'Formación ciudadana inicial', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(10, 'Educación Física 1°', 'Deportes y actividad física para primer año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(11, 'Lengua y Literatura 2°', 'Gramática y literatura para segundo año', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(12, 'Matemática 2°', 'Matemáticas para segundo año', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(13, 'Química 2°', 'Introducción a la química', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(14, 'Biología 2°', 'Biología para segundo año', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(15, 'Historia 2°', 'Historia Argentina y mundial', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(16, 'Inglés 2°', 'Inglés para segundo año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(17, 'Educación Artística 2°', 'Expresión artística y musical', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(18, 'Educación Tecnológica 2°', 'Tecnología aplicada', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(19, 'Ciudadanía y Participación 2°', 'Participación ciudadana', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(20, 'Educación Física 2°', 'Deportes y actividad física para segundo año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(21, 'Lengua y Literatura 3°', 'Gramática avanzada y literatura', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-10-15 21:08:02'),
(22, 'Matemática 3°', 'Matemáticas avanzadas', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-10-15 21:08:02'),
(23, 'Física 3°', 'Física para tercer año', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(24, 'Química 3°', 'Química avanzada', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-10-15 21:08:02'),
(25, 'Geografía 3°', 'Geografía económica y política', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(26, 'Historia 3°', 'Historia contemporánea', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(27, 'Inglés 3°', 'Inglés para tercer año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-10-15 21:08:02'),
(28, 'Educación Artística 3°', 'Artes integradas', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-10-15 21:08:02'),
(29, 'Educación Tecnológica 3°', 'Tecnología y sociedad', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(30, 'Formación para la Vida y el Trabajo 3°', 'Orientación vocacional inicial', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(31, 'Educación Física 3°', 'Deportes y actividad física para tercer año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(32, 'Matemática 4°', 'Matemáticas aplicadas', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(33, 'Lengua y Literatura 4°', 'Literatura y comunicación', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(34, 'Biología 4°', 'Biología con enfoque social', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(35, 'Geografía 4°', 'Geografía mundial', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(36, 'Historia 4°', 'Historia del siglo XX', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(37, 'Inglés 4°', 'Inglés técnico', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(38, 'Educación Artística 4°', 'Artes y sociedad', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(39, 'Educación Física 4°', 'Deportes para cuarto año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(40, 'Formación para la Vida y el Trabajo 4°', 'Orientación laboral', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(41, 'Matemática 5°', 'Matemáticas financieras básicas', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(42, 'Lengua y Literatura 5°', 'Comunicación organizacional', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(43, 'Física 5°', 'Física con enfoque social', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(44, 'Geografía 5°', 'Geografía del desarrollo', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(45, 'Historia 5°', 'Historia contemporánea', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(46, 'Inglés 5°', 'Inglés para negocios', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(47, 'Educación Artística 5°', 'Cultura y sociedad', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(48, 'Psicología 5°', 'Psicología social', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(49, 'Educación Física 5°', 'Deportes para quinto año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(50, 'Formación para la Vida y el Trabajo 5°', 'Habilidades para el trabajo', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(51, 'Matemática 6°', 'Estadística aplicada', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(52, 'Lengua y Literatura 6°', 'Redacción profesional', 4, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(53, 'Química 6°', 'Química y sociedad', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(54, 'Inglés 6°', 'Inglés técnico avanzado', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(55, 'Teatro 6°', 'Expresión corporal', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(56, 'Ciudadanía y Política 6°', 'Políticas públicas', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(57, 'Filosofía 6°', 'Ética y sociedad', 3, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(58, 'Educación Física 6°', 'Deportes para sexto año', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(59, 'Formación para la Vida y el Trabajo 6°', 'Proyecto profesional', 2, 1, 0, 'Común', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(60, 'Sistemas de Información Contable 4°', 'Fundamentos de contabilidad', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(61, 'Administración 4°', 'Introducción a la administración', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(62, 'Administración de la Producción y Comercialización 4°', 'Gestión de producción', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(63, 'Sistemas de Información Contable 5°', 'Contabilidad intermedia', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(64, 'Economía 5°', 'Micro y macroeconomía', 4, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(65, 'Administración Financiera 5°', 'Finanzas corporativas', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(66, 'Sistemas de Información Contable 6°', 'Contabilidad avanzada', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(67, 'Economía 6°', 'Economía argentina y mundial', 4, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(68, 'Derecho 6°', 'Derecho comercial y laboral', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(69, 'Marco Jurídico de las Organizaciones 6°', 'Normativas organizacionales', 3, 1, 1, 'Economía', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(70, 'Turismo y Sociedad 4°', 'Impacto social del turismo', 3, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(71, 'Tecnologías de la Información y la Comunicación 4°', 'TIC aplicadas al turismo', 3, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(72, 'Administración de Organizaciones Turísticas 4°', 'Gestión de empresas turísticas', 4, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(73, 'Patrimonio Turístico 5°', 'Recursos patrimoniales', 3, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(74, 'Organizaciones Turísticas 5°', 'Tipos de organizaciones turísticas', 3, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(75, 'Administración de Organizaciones Turísticas 5°', 'Gestión avanzada de turismo', 4, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(76, 'Patrimonio Turístico 6°', 'Patrimonio mundial', 3, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(77, 'Turismo y Desarrollo Sustentable 6°', 'Turismo sostenible', 3, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19'),
(78, 'Estrategias de Comunicación y Relaciones Públicas 6°', 'Marketing turístico', 3, 1, 1, 'Turismo', '2025-08-10 04:34:19', '2025-08-10 04:34:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `materia_contenido`
--

CREATE TABLE `materia_contenido` (
  `id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `grado_id` int(11) NOT NULL,
  `profesor_id` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL COMMENT 'El nombre de la pestaña (Ej: Clase 1, Tarea Final)',
  `descripcion_html` text DEFAULT NULL COMMENT 'El contenido principal de la pestaña en formato HTML',
  `fecha_visible` datetime NOT NULL DEFAULT current_timestamp() COMMENT 'A partir de cuándo es visible para el alumno',
  `fecha_entrega` datetime DEFAULT NULL COMMENT 'Si no es nulo, la publicación incluye una tarea.',
  `fecha_limite_formulario` datetime DEFAULT NULL,
  `orden` int(11) NOT NULL DEFAULT 0 COMMENT 'Para ordenar las pestañas',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `publicado` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = Publicado, 0 = Oculto',
  `tipo_contenido` enum('Bienvenida','Clase','Tarea','Formulario','Enlace','Mixto') NOT NULL DEFAULT 'Clase'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `materia_contenido`
--

INSERT INTO `materia_contenido` (`id`, `materia_id`, `grado_id`, `profesor_id`, `titulo`, `descripcion_html`, `fecha_visible`, `fecha_entrega`, `fecha_limite_formulario`, `orden`, `creado_en`, `publicado`, `tipo_contenido`) VALUES
(5, 67, 12, 3, 'Introducción al Mercado: Oferta y Demanda', '<p>Hola a todos, En la clase de hoy abordaremos los dos pilares fundamentales de la economía de mercado: la <strong>Oferta</strong> y la <strong>Demanda</strong>. El objetivo es entender cómo la interacción entre compradores y vendedores determina el precio de los bienes y servicios.</p><ul><li><strong>Puntos clave que veremos:</strong></li><li><strong>La Ley de la Demanda:</strong> ¿Por qué compramos menos cuando el precio sube?</li><li><strong>La Ley de la Oferta:</strong> ¿Por qué los productores venden más cuando el precio sube?</li><li><strong>El Punto de Equilibrio:</strong> Donde todos están satisfechos.</li><li><strong>Instrucciones:</strong></li></ul><ol><li>Lean el PDF adjunto \"Capítulo 1: Fundamentos\".</li><li>Observen el gráfico de las curvas en la presentación.</li><li>Respondan al cuestionario breve al final de la lectura.</li></ol><ul><li><strong>Archivos Adjuntos:</strong></li><li><em>Subir un PDF con la lectura teórica.</em></li></ul>', '2025-12-19 13:37:51', NULL, NULL, 0, '2025-12-19 13:37:51', 1, 'Clase'),
(7, 2, 2, 2, 'Clase de Matemática - Marzo', '<p>Contenido correspondiente a la clase del <strong>1 de Marzo de 2025</strong>.</p>', '2025-03-01 08:00:00', NULL, NULL, 3, '2025-12-19 15:54:47', 1, 'Clase'),
(8, 2, 2, 2, 'Clase de Matemática - Abril', '<p>Contenido correspondiente a la clase del <strong>1 de Abril de 2025</strong>.</p>', '2025-04-01 08:00:00', NULL, NULL, 4, '2025-12-19 15:54:47', 1, 'Clase'),
(9, 2, 2, 2, 'Clase de Matemática - Mayo', '<p>Contenido correspondiente a la clase del <strong>1 de Mayo de 2025</strong>.</p>', '2025-05-01 08:00:00', NULL, NULL, 5, '2025-12-19 15:54:47', 1, 'Clase'),
(10, 2, 2, 2, 'Clase de Matemática - Junio', '<p>Contenido correspondiente a la clase del <strong>1 de Junio de 2025</strong>.</p>', '2025-06-01 08:00:00', NULL, NULL, 6, '2025-12-19 15:54:47', 1, 'Clase'),
(11, 2, 2, 2, 'Clase de Matemática - Julio', '<p>Contenido correspondiente a la clase del <strong>1 de Julio de 2025</strong>.</p>', '2025-07-01 08:00:00', NULL, NULL, 7, '2025-12-19 15:54:47', 1, 'Clase'),
(12, 2, 2, 2, 'Clase de Matemática - Agosto', '<p>Contenido correspondiente a la clase del <strong>1 de Agosto de 2025</strong>.</p>', '2025-08-01 08:00:00', NULL, NULL, 8, '2025-12-19 15:54:47', 1, 'Clase'),
(13, 2, 2, 2, 'Clase de Matemática - Septiembre', '<p>Contenido correspondiente a la clase del <strong>1 de Septiembre de 2025</strong>.</p>', '2025-09-01 08:00:00', NULL, NULL, 9, '2025-12-19 15:54:47', 1, 'Clase'),
(14, 2, 2, 2, 'Clase de Matemática - Octubre', '<p>Contenido correspondiente a la clase del <strong>1 de Octubre de 2025</strong>.</p>', '2025-10-01 08:00:00', NULL, NULL, 10, '2025-12-19 15:54:47', 1, 'Clase'),
(15, 2, 2, 2, 'Clase de Matemática - Noviembre', '<p>Contenido correspondiente a la clase del <strong>1 de Noviembre de 2025</strong>.</p>', '2025-11-01 08:00:00', NULL, NULL, 11, '2025-12-19 15:54:47', 1, 'Clase'),
(16, 2, 2, 3, 'Clase de Matemática - Marzo', '<p>Contenido correspondiente a la clase del <strong>1 de Marzo de 2025</strong>.</p>', '2025-03-01 08:00:00', NULL, NULL, 3, '2025-12-19 16:01:16', 1, 'Clase'),
(17, 2, 2, 3, 'Clase de Matemática - Abril', '<p>Contenido correspondiente a la clase del <strong>1 de Abril de 2025</strong>.</p>', '2025-04-01 08:00:00', NULL, NULL, 4, '2025-12-19 16:01:16', 1, 'Clase'),
(18, 2, 2, 3, 'Clase de Matemática - Mayo', '<p>Contenido correspondiente a la clase del <strong>1 de Mayo de 2025</strong>.</p>', '2025-05-01 08:00:00', NULL, NULL, 5, '2025-12-19 16:01:16', 1, 'Clase'),
(19, 2, 2, 3, 'Clase de Matemática - Junio', '<p>Contenido correspondiente a la clase del <strong>1 de Junio de 2025</strong>.</p>', '2025-06-01 08:00:00', NULL, NULL, 6, '2025-12-19 16:01:16', 1, 'Clase'),
(20, 2, 2, 3, 'Clase de Matemática - Julio', '<p>Contenido correspondiente a la clase del <strong>1 de Julio de 2025</strong>.</p>', '2025-07-01 08:00:00', NULL, NULL, 7, '2025-12-19 16:01:16', 1, 'Clase'),
(21, 2, 2, 3, 'Clase de Matemática - Agosto', '<p>Contenido correspondiente a la clase del <strong>1 de Agosto de 2025</strong>.</p>', '2025-08-01 08:00:00', NULL, NULL, 8, '2025-12-19 16:01:16', 1, 'Clase'),
(22, 2, 2, 3, 'Clase de Matemática - Septiembre', '<p>Contenido correspondiente a la clase del <strong>1 de Septiembre de 2025</strong>.</p>', '2025-09-01 08:00:00', NULL, NULL, 9, '2025-12-19 16:01:16', 1, 'Clase'),
(23, 2, 2, 3, 'Clase de Matemática - Octubre', '<p>Contenido correspondiente a la clase del <strong>1 de Octubre de 2025</strong>.</p>', '2025-10-01 08:00:00', NULL, NULL, 10, '2025-12-19 16:01:16', 1, 'Clase'),
(24, 2, 2, 3, 'Clase de Matemática - Noviembre', '<p>Contenido correspondiente a la clase del <strong>1 de Noviembre de 2025</strong>.</p>', '2025-11-01 08:00:00', NULL, NULL, 11, '2025-12-19 16:01:16', 1, 'Clase'),
(25, 51, 12, 3, 'Clase de Matemática - Marzo', '<p>Contenido correspondiente a la clase del <strong>1 de Marzo de 2025</strong>.</p>', '2025-03-01 08:00:00', NULL, NULL, 3, '2025-12-19 16:05:55', 1, 'Clase'),
(26, 51, 12, 3, 'Clase de Matemática - Abril', '<p>Contenido correspondiente a la clase del <strong>1 de Abril de 2025</strong>.</p>', '2025-04-01 08:00:00', NULL, NULL, 4, '2025-12-19 16:05:55', 1, 'Clase'),
(27, 51, 12, 3, 'Clase de Matemática - Mayo', '<p>Contenido correspondiente a la clase del <strong>1 de Mayo de 2025</strong>.</p>', '2025-05-01 08:00:00', NULL, NULL, 5, '2025-12-19 16:05:55', 1, 'Clase'),
(28, 51, 12, 3, 'Clase de Matemática - Junio', '<p>Contenido correspondiente a la clase del <strong>1 de Junio de 2025</strong>.</p>', '2025-06-01 08:00:00', NULL, NULL, 6, '2025-12-19 16:05:55', 1, 'Clase'),
(29, 51, 12, 3, 'Clase de Matemática - Julio', '<p>Contenido correspondiente a la clase del <strong>1 de Julio de 2025</strong>.</p>', '2025-07-01 08:00:00', NULL, NULL, 7, '2025-12-19 16:05:55', 1, 'Clase'),
(30, 51, 12, 3, 'Clase de Matemática - Agosto', '<p>Contenido correspondiente a la clase del <strong>1 de Agosto de 2025</strong>.</p>', '2025-08-01 08:00:00', NULL, NULL, 8, '2025-12-19 16:05:55', 1, 'Clase'),
(31, 51, 12, 3, 'Clase de Matemática - Septiembre', '<p>Contenido correspondiente a la clase del <strong>1 de Septiembre de 2025</strong>.</p>', '2025-09-01 08:00:00', NULL, NULL, 9, '2025-12-19 16:05:55', 1, 'Clase'),
(32, 51, 12, 3, 'Clase de Matemática - Octubre', '<p>Contenido correspondiente a la clase del <strong>1 de Octubre de 2025</strong>.</p>', '2025-10-01 08:00:00', NULL, NULL, 10, '2025-12-19 16:05:55', 1, 'Clase'),
(33, 51, 12, 3, 'Clase de Matemática - Noviembre', '<p>Contenido correspondiente a la clase del <strong>1 de Noviembre de 2025</strong>.</p>', '2025-11-01 08:00:00', NULL, NULL, 11, '2025-12-19 16:05:55', 1, 'Clase');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `materia_grado`
--

CREATE TABLE `materia_grado` (
  `id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `grado_id` int(11) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `materia_grado`
--

INSERT INTO `materia_grado` (`id`, `materia_id`, `grado_id`, `creado_en`) VALUES
(1, 1, 1, '2025-08-10 04:34:19'),
(2, 1, 2, '2025-08-10 04:34:19'),
(3, 2, 1, '2025-08-10 04:34:19'),
(4, 2, 2, '2025-08-10 04:34:19'),
(5, 3, 1, '2025-08-10 04:34:19'),
(6, 3, 2, '2025-08-10 04:34:19'),
(7, 4, 1, '2025-08-10 04:34:19'),
(8, 4, 2, '2025-08-10 04:34:19'),
(9, 5, 1, '2025-08-10 04:34:19'),
(10, 5, 2, '2025-08-10 04:34:19'),
(11, 6, 1, '2025-08-10 04:34:19'),
(12, 6, 2, '2025-08-10 04:34:19'),
(13, 7, 1, '2025-08-10 04:34:19'),
(14, 7, 2, '2025-08-10 04:34:19'),
(15, 8, 1, '2025-08-10 04:34:19'),
(16, 8, 2, '2025-08-10 04:34:19'),
(17, 9, 1, '2025-08-10 04:34:19'),
(18, 9, 2, '2025-08-10 04:34:19'),
(19, 10, 1, '2025-08-10 04:34:19'),
(20, 10, 2, '2025-08-10 04:34:19'),
(32, 11, 3, '2025-08-10 04:34:19'),
(33, 11, 4, '2025-08-10 04:34:19'),
(34, 12, 3, '2025-08-10 04:34:19'),
(35, 12, 4, '2025-08-10 04:34:19'),
(36, 13, 3, '2025-08-10 04:34:19'),
(37, 13, 4, '2025-08-10 04:34:19'),
(38, 14, 3, '2025-08-10 04:34:19'),
(39, 14, 4, '2025-08-10 04:34:19'),
(40, 15, 3, '2025-08-10 04:34:19'),
(41, 15, 4, '2025-08-10 04:34:19'),
(42, 16, 3, '2025-08-10 04:34:19'),
(43, 16, 4, '2025-08-10 04:34:19'),
(44, 17, 3, '2025-08-10 04:34:19'),
(45, 17, 4, '2025-08-10 04:34:19'),
(46, 18, 3, '2025-08-10 04:34:19'),
(47, 18, 4, '2025-08-10 04:34:19'),
(48, 19, 3, '2025-08-10 04:34:19'),
(49, 19, 4, '2025-08-10 04:34:19'),
(50, 20, 3, '2025-08-10 04:34:19'),
(51, 20, 4, '2025-08-10 04:34:19'),
(63, 21, 5, '2025-08-10 04:34:19'),
(64, 21, 6, '2025-08-10 04:34:19'),
(65, 22, 5, '2025-08-10 04:34:19'),
(66, 22, 6, '2025-08-10 04:34:19'),
(67, 23, 5, '2025-08-10 04:34:19'),
(68, 23, 6, '2025-08-10 04:34:19'),
(69, 24, 5, '2025-08-10 04:34:19'),
(70, 24, 6, '2025-08-10 04:34:19'),
(71, 25, 5, '2025-08-10 04:34:19'),
(72, 25, 6, '2025-08-10 04:34:19'),
(73, 26, 5, '2025-08-10 04:34:19'),
(74, 26, 6, '2025-08-10 04:34:19'),
(75, 27, 5, '2025-08-10 04:34:19'),
(76, 27, 6, '2025-08-10 04:34:19'),
(77, 28, 5, '2025-08-10 04:34:19'),
(78, 28, 6, '2025-08-10 04:34:19'),
(79, 29, 5, '2025-08-10 04:34:19'),
(80, 29, 6, '2025-08-10 04:34:19'),
(81, 30, 5, '2025-08-10 04:34:19'),
(82, 30, 6, '2025-08-10 04:34:19'),
(83, 31, 5, '2025-08-10 04:34:19'),
(84, 31, 6, '2025-08-10 04:34:19'),
(94, 32, 7, '2025-08-10 04:34:19'),
(95, 32, 8, '2025-08-10 04:34:19'),
(96, 33, 7, '2025-08-10 04:34:19'),
(97, 33, 8, '2025-08-10 04:34:19'),
(98, 34, 7, '2025-08-10 04:34:19'),
(99, 34, 8, '2025-08-10 04:34:19'),
(100, 35, 7, '2025-08-10 04:34:19'),
(101, 35, 8, '2025-08-10 04:34:19'),
(102, 36, 7, '2025-08-10 04:34:19'),
(103, 36, 8, '2025-08-10 04:34:19'),
(104, 37, 7, '2025-08-10 04:34:19'),
(105, 37, 8, '2025-08-10 04:34:19'),
(106, 38, 7, '2025-08-10 04:34:19'),
(107, 38, 8, '2025-08-10 04:34:19'),
(108, 39, 7, '2025-08-10 04:34:19'),
(109, 39, 8, '2025-08-10 04:34:19'),
(110, 40, 7, '2025-08-10 04:34:19'),
(111, 40, 8, '2025-08-10 04:34:19'),
(125, 41, 9, '2025-08-10 04:34:19'),
(126, 41, 10, '2025-08-10 04:34:19'),
(127, 42, 9, '2025-08-10 04:34:19'),
(128, 42, 10, '2025-08-10 04:34:19'),
(129, 43, 9, '2025-08-10 04:34:19'),
(130, 43, 10, '2025-08-10 04:34:19'),
(131, 44, 9, '2025-08-10 04:34:19'),
(132, 44, 10, '2025-08-10 04:34:19'),
(133, 45, 9, '2025-08-10 04:34:19'),
(134, 45, 10, '2025-08-10 04:34:19'),
(135, 46, 9, '2025-08-10 04:34:19'),
(136, 46, 10, '2025-08-10 04:34:19'),
(137, 47, 9, '2025-08-10 04:34:19'),
(138, 47, 10, '2025-08-10 04:34:19'),
(139, 48, 9, '2025-08-10 04:34:19'),
(140, 48, 10, '2025-08-10 04:34:19'),
(141, 49, 9, '2025-08-10 04:34:19'),
(142, 49, 10, '2025-08-10 04:34:19'),
(143, 50, 9, '2025-08-10 04:34:19'),
(144, 50, 10, '2025-08-10 04:34:19'),
(156, 51, 11, '2025-08-10 04:34:19'),
(157, 51, 12, '2025-08-10 04:34:19'),
(158, 52, 11, '2025-08-10 04:34:19'),
(159, 52, 12, '2025-08-10 04:34:19'),
(160, 53, 11, '2025-08-10 04:34:19'),
(161, 53, 12, '2025-08-10 04:34:19'),
(162, 54, 11, '2025-08-10 04:34:19'),
(163, 54, 12, '2025-08-10 04:34:19'),
(164, 55, 11, '2025-08-10 04:34:19'),
(165, 55, 12, '2025-08-10 04:34:19'),
(166, 56, 11, '2025-08-10 04:34:19'),
(167, 56, 12, '2025-08-10 04:34:19'),
(168, 57, 11, '2025-08-10 04:34:19'),
(169, 57, 12, '2025-08-10 04:34:19'),
(170, 58, 11, '2025-08-10 04:34:19'),
(171, 58, 12, '2025-08-10 04:34:19'),
(172, 59, 11, '2025-08-10 04:34:19'),
(173, 59, 12, '2025-08-10 04:34:19'),
(187, 70, 7, '2025-08-10 04:34:19'),
(188, 71, 7, '2025-08-10 04:34:19'),
(189, 72, 7, '2025-08-10 04:34:19'),
(190, 73, 9, '2025-08-10 04:34:19'),
(191, 74, 9, '2025-08-10 04:34:19'),
(192, 75, 9, '2025-08-10 04:34:19'),
(193, 76, 11, '2025-08-10 04:34:19'),
(194, 77, 11, '2025-08-10 04:34:19'),
(195, 78, 11, '2025-08-10 04:34:19'),
(202, 60, 8, '2025-08-10 04:34:19'),
(203, 61, 8, '2025-08-10 04:34:19'),
(204, 62, 8, '2025-08-10 04:34:19'),
(205, 63, 10, '2025-08-10 04:34:19'),
(206, 64, 10, '2025-08-10 04:34:19'),
(207, 65, 10, '2025-08-10 04:34:19'),
(208, 66, 12, '2025-08-10 04:34:19'),
(209, 67, 12, '2025-08-10 04:34:19'),
(210, 68, 12, '2025-08-10 04:34:19'),
(211, 69, 12, '2025-08-10 04:34:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `mensajes`
--

CREATE TABLE `mensajes` (
  `id` int(11) NOT NULL,
  `remitente_usuario_id` int(11) NOT NULL,
  `destinatario_usuario_id` int(11) NOT NULL,
  `mensaje` text NOT NULL,
  `leido` tinyint(1) NOT NULL DEFAULT 0,
  `timestamp` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `monitoreo_formulario`
--

CREATE TABLE `monitoreo_formulario` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `formulario_id` int(11) NOT NULL,
  `cambios_ventana_contador` int(11) DEFAULT 0,
  `ultima_actualizacion` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticias`
--

CREATE TABLE `noticias` (
  `id` int(11) NOT NULL,
  `titulo` varchar(255) NOT NULL,
  `contenido_html` text NOT NULL,
  `imagen_destacada` varchar(255) DEFAULT NULL COMMENT 'URL a una imagen principal o de portada',
  `autor_usuario_id` int(11) DEFAULT NULL,
  `estado` enum('publicado','borrador') NOT NULL DEFAULT 'publicado',
  `es_fijado` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 para mantenerla siempre arriba',
  `es_publica` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = Visible para todos, 0 = Visible solo para grados seleccionados',
  `fecha_publicacion` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `noticias`
--

INSERT INTO `noticias` (`id`, `titulo`, `contenido_html`, `imagen_destacada`, `autor_usuario_id`, `estado`, `es_fijado`, `es_publica`, `fecha_publicacion`) VALUES
(8, '¡Felices Fiestas! Un mensaje de agradecimiento y buenos deseos para toda nuestra comunidad estudiantil!', '<p><img src=\"data:image/jpeg;base64,/9j/4AAQSkZJRgABAQEBLAEsAAD/4QBWRXhpZgAATU0AKgAAAAgABAEaAAUAAAABAAAAPgEbAAUAAAABAAAARgEoAAMAAAABAAIAAAITAAMAAAABAAEAAAAAAAAAAAEsAAAAAQAAASwAAAAB/+0ALFBob3Rvc2hvcCAzLjAAOEJJTQQEAAAAAAAPHAFaAAMbJUccAQAAAgAEAP/hDIFodHRwOi8vbnMuYWRvYmUuY29tL3hhcC8xLjAvADw/eHBhY2tldCBiZWdpbj0n77u/JyBpZD0nVzVNME1wQ2VoaUh6cmVTek5UY3prYzlkJz8+Cjx4OnhtcG1ldGEgeG1sbnM6eD0nYWRvYmU6bnM6bWV0YS8nIHg6eG1wdGs9J0ltYWdlOjpFeGlmVG9vbCAxMC4xMCc+CjxyZGY6UkRGIHhtbG5zOnJkZj0naHR0cDovL3d3dy53My5vcmcvMTk5OS8wMi8yMi1yZGYtc3ludGF4LW5zIyc+CgogPHJkZjpEZXNjcmlwdGlvbiByZGY6YWJvdXQ9JycKICB4bWxuczp0aWZmPSdodHRwOi8vbnMuYWRvYmUuY29tL3RpZmYvMS4wLyc+CiAgPHRpZmY6UmVzb2x1dGlvblVuaXQ+MjwvdGlmZjpSZXNvbHV0aW9uVW5pdD4KICA8dGlmZjpYUmVzb2x1dGlvbj4zMDAvMTwvdGlmZjpYUmVzb2x1dGlvbj4KICA8dGlmZjpZUmVzb2x1dGlvbj4zMDAvMTwvdGlmZjpZUmVzb2x1dGlvbj4KIDwvcmRmOkRlc2NyaXB0aW9uPgoKIDxyZGY6RGVzY3JpcHRpb24gcmRmOmFib3V0PScnCiAgeG1sbnM6eG1wTU09J2h0dHA6Ly9ucy5hZG9iZS5jb20veGFwLzEuMC9tbS8nPgogIDx4bXBNTTpEb2N1bWVudElEPmFkb2JlOmRvY2lkOnN0b2NrOmM3ZDc4MDg3LWEyNTAtNDAyZC05YWJmLTNlMDczZDJiZTkzNjwveG1wTU06RG9jdW1lbnRJRD4KICA8eG1wTU06SW5zdGFuY2VJRD54bXAuaWlkOjBmZmQ2YjEzLTc0ZTItNDgzYi1iYjM3LTlkMDM3ZTY0MTUxNzwveG1wTU06SW5zdGFuY2VJRD4KIDwvcmRmOkRlc2NyaXB0aW9uPgo8L3JkZjpSREY+CjwveDp4bXBtZXRhPgogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAogICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgCiAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAKICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgICAgIAo8P3hwYWNrZXQgZW5kPSd3Jz8+/9sAQwAFAwQEBAMFBAQEBQUFBgcMCAcHBwcPCwsJDBEPEhIRDxERExYcFxMUGhURERghGBodHR8fHxMXIiQiHiQcHh8e/9sAQwEFBQUHBgcOCAgOHhQRFB4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4eHh4e/8AAEQgBaAJNAwERAAIRAQMRAf/EAB0AAQABBQEBAQAAAAAAAAAAAAAHAwQFBggCAQn/xABIEAABAwMBBAcFBQUIAgEDBQABAAIDBAURBgcSITETIkFRYXGBCBQykaEVQlKxwSNicoLR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\" alt=\"2Q==\"></p><p>Al cerrar este ciclo, queremos tomar un momento para decirles: <strong>Gracias</strong>. Gracias por su curiosidad, por sus horas de estudio y por la energía que traen a nuestras aulas cada día. Ustedes son el corazón de esta institución.</p><p>Sabemos que ha sido un año de grandes retos y mucho aprendizaje. Ahora, es tiempo de hacer una pausa, recargar energías y disfrutar con sus seres queridos.</p>', NULL, 8, 'publicado', 1, 1, '2025-12-19 15:23:26');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `noticia_visibilidad_grado`
--

CREATE TABLE `noticia_visibilidad_grado` (
  `id` int(11) NOT NULL,
  `noticia_id` int(11) NOT NULL,
  `grado_id` int(11) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pagos_mensuales`
--

CREATE TABLE `pagos_mensuales` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `anio` year(4) NOT NULL,
  `mes` varchar(20) NOT NULL,
  `estado` enum('pagado','no_pagado') NOT NULL DEFAULT 'no_pagado',
  `fecha_pago` datetime DEFAULT NULL,
  `registrado_por_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `pagos_mensuales`
--

INSERT INTO `pagos_mensuales` (`id`, `alumno_id`, `anio`, `mes`, `estado`, `fecha_pago`, `registrado_por_id`) VALUES
(12, 14, '2025', 'marzo', 'pagado', '2025-12-19 12:38:18', 26),
(13, 14, '2025', 'abril', 'pagado', '2025-12-19 12:38:18', 26),
(14, 14, '2025', 'mayo', 'pagado', '2025-12-19 12:38:18', 26),
(15, 14, '2025', 'junio', 'pagado', '2025-12-19 12:38:18', 26),
(16, 14, '2025', 'julio', 'pagado', '2025-12-19 12:38:18', 26),
(17, 14, '2025', 'agosto', 'pagado', '2025-12-19 12:38:18', 26),
(18, 14, '2025', 'septiembre', 'pagado', '2025-12-19 12:38:18', 26),
(19, 14, '2025', 'octubre', 'pagado', '2025-12-19 12:38:18', 26),
(20, 14, '2025', 'noviembre', 'pagado', '2025-12-19 12:38:18', 26),
(21, 5, '2025', 'marzo', 'pagado', '2025-12-19 12:38:18', 26),
(22, 5, '2025', 'abril', 'pagado', '2025-12-19 12:38:18', 26),
(23, 5, '2025', 'mayo', 'pagado', '2025-12-19 12:38:18', 26),
(24, 5, '2025', 'junio', 'pagado', '2025-12-19 12:38:18', 26),
(25, 5, '2025', 'julio', 'pagado', '2025-12-19 12:38:18', 26),
(26, 5, '2025', 'agosto', 'pagado', '2025-12-19 12:38:18', 26),
(27, 5, '2025', 'septiembre', 'pagado', '2025-12-19 12:38:18', 26),
(28, 5, '2025', 'octubre', 'pagado', '2025-12-19 12:38:18', 26),
(29, 5, '2025', 'noviembre', 'pagado', '2025-12-19 12:38:18', 26),
(30, 5, '2025', 'diciembre', 'pagado', '2025-12-19 12:38:18', 26),
(31, 16, '2025', 'marzo', 'pagado', '2025-12-19 12:38:18', 26),
(32, 16, '2025', 'abril', 'pagado', '2025-12-19 12:38:18', 26),
(33, 16, '2025', 'mayo', 'pagado', '2025-12-19 12:38:18', 26),
(34, 16, '2025', 'junio', 'pagado', '2025-12-19 12:38:18', 26),
(35, 16, '2025', 'julio', 'pagado', '2025-12-19 12:38:18', 26),
(36, 16, '2025', 'agosto', 'pagado', '2025-12-19 12:38:18', 26),
(37, 16, '2025', 'septiembre', 'pagado', '2025-12-19 12:38:18', 26),
(38, 16, '2025', 'octubre', 'pagado', '2025-12-19 12:38:18', 26),
(39, 6, '2025', 'marzo', 'pagado', '2025-12-19 12:38:18', 26),
(40, 6, '2025', 'abril', 'pagado', '2025-12-19 12:38:18', 26),
(41, 6, '2025', 'mayo', 'pagado', '2025-12-19 12:38:18', 26),
(42, 6, '2025', 'junio', 'pagado', '2025-12-19 12:38:18', 26),
(43, 6, '2025', 'julio', 'pagado', '2025-12-19 12:38:18', 26),
(44, 6, '2025', 'agosto', 'pagado', '2025-12-19 12:38:18', 26),
(45, 6, '2025', 'septiembre', 'pagado', '2025-12-19 12:38:18', 26),
(46, 6, '2025', 'octubre', 'pagado', '2025-12-19 12:38:18', 26),
(47, 6, '2025', 'noviembre', 'pagado', '2025-12-19 12:38:18', 26),
(48, 6, '2025', 'diciembre', 'pagado', '2025-12-19 12:38:18', 26),
(49, 8, '2025', 'marzo', 'pagado', '2025-12-19 12:38:18', 26),
(50, 8, '2025', 'abril', 'pagado', '2025-12-19 12:38:18', 26),
(51, 8, '2025', 'mayo', 'pagado', '2025-12-19 12:38:18', 26),
(52, 8, '2025', 'junio', 'pagado', '2025-12-19 12:38:18', 26),
(53, 8, '2025', 'julio', 'pagado', '2025-12-19 12:38:18', 26),
(54, 8, '2025', 'agosto', 'pagado', '2025-12-19 12:38:18', 26),
(55, 8, '2025', 'septiembre', 'pagado', '2025-12-19 12:38:18', 26),
(56, 8, '2025', 'octubre', 'pagado', '2025-12-19 12:38:18', 26),
(57, 8, '2025', 'noviembre', 'pagado', '2025-12-19 12:38:18', 26),
(58, 8, '2025', 'diciembre', 'pagado', '2025-12-19 12:38:18', 26),
(59, 9, '2025', 'marzo', 'pagado', '2025-12-19 12:38:18', 26),
(60, 9, '2025', 'abril', 'pagado', '2025-12-19 12:38:18', 26),
(61, 9, '2025', 'mayo', 'pagado', '2025-12-19 12:38:18', 26),
(62, 9, '2025', 'junio', 'pagado', '2025-12-19 12:38:18', 26),
(63, 9, '2025', 'julio', 'pagado', '2025-12-19 12:38:18', 26),
(64, 9, '2025', 'agosto', 'pagado', '2025-12-19 12:38:18', 26),
(65, 9, '2025', 'septiembre', 'pagado', '2025-12-19 12:38:18', 26),
(66, 9, '2025', 'octubre', 'no_pagado', '2025-12-19 12:39:30', 26),
(67, 9, '2025', 'noviembre', 'pagado', '2025-12-19 12:38:18', 26),
(68, 9, '2025', 'diciembre', 'pagado', '2025-12-19 12:38:18', 26),
(69, 16, '2025', 'noviembre', 'pagado', '2025-12-19 12:38:27', 26),
(70, 16, '2025', 'diciembre', 'pagado', '2025-12-19 12:38:27', 26),
(71, 10, '2025', 'marzo', 'pagado', '2025-12-19 12:38:27', 26),
(72, 10, '2025', 'abril', 'pagado', '2025-12-19 12:38:27', 26),
(73, 10, '2025', 'mayo', 'pagado', '2025-12-19 12:38:27', 26),
(74, 10, '2025', 'junio', 'pagado', '2025-12-19 12:38:27', 26),
(75, 10, '2025', 'julio', 'pagado', '2025-12-19 12:38:27', 26),
(76, 10, '2025', 'agosto', 'pagado', '2025-12-19 12:38:27', 26),
(77, 10, '2025', 'septiembre', 'pagado', '2025-12-19 12:38:27', 26),
(78, 10, '2025', 'octubre', 'pagado', '2025-12-19 12:38:27', 26),
(79, 7, '2025', 'marzo', 'pagado', '2025-12-19 12:39:00', 26),
(80, 7, '2025', 'abril', 'pagado', '2025-12-19 12:39:00', 26),
(81, 7, '2025', 'mayo', 'pagado', '2025-12-19 12:39:00', 26),
(82, 7, '2025', 'junio', 'pagado', '2025-12-19 12:39:00', 26),
(83, 7, '2025', 'julio', 'pagado', '2025-12-19 12:39:00', 26),
(84, 7, '2025', 'agosto', 'pagado', '2025-12-19 12:39:00', 26),
(85, 7, '2025', 'septiembre', 'pagado', '2025-12-19 12:39:00', 26),
(86, 7, '2025', 'octubre', 'pagado', '2025-12-19 12:39:00', 26),
(87, 7, '2025', 'noviembre', 'pagado', '2025-12-19 12:39:00', 26),
(88, 7, '2025', 'diciembre', 'pagado', '2025-12-19 12:39:00', 26),
(89, 4, '2025', 'marzo', 'pagado', '2025-12-19 12:39:00', 26),
(90, 4, '2025', 'abril', 'pagado', '2025-12-19 12:39:00', 26),
(91, 4, '2025', 'mayo', 'pagado', '2025-12-19 12:39:00', 26),
(92, 4, '2025', 'junio', 'pagado', '2025-12-19 12:39:00', 26),
(93, 4, '2025', 'julio', 'pagado', '2025-12-19 12:39:00', 26),
(94, 4, '2025', 'agosto', 'pagado', '2025-12-19 12:39:00', 26),
(95, 4, '2025', 'septiembre', 'pagado', '2025-12-19 12:39:00', 26),
(96, 4, '2025', 'octubre', 'pagado', '2025-12-19 12:39:00', 26),
(97, 4, '2025', 'noviembre', 'pagado', '2025-12-19 12:39:00', 26),
(98, 4, '2025', 'diciembre', 'pagado', '2025-12-19 12:39:00', 26),
(99, 11, '2025', 'marzo', 'pagado', '2025-12-19 12:39:00', 26),
(100, 11, '2025', 'abril', 'pagado', '2025-12-19 12:39:00', 26),
(101, 11, '2025', 'mayo', 'pagado', '2025-12-19 12:39:00', 26),
(102, 11, '2025', 'junio', 'pagado', '2025-12-19 12:39:00', 26),
(103, 11, '2025', 'julio', 'pagado', '2025-12-19 12:39:00', 26),
(104, 11, '2025', 'agosto', 'pagado', '2025-12-19 12:39:00', 26),
(105, 11, '2025', 'septiembre', 'pagado', '2025-12-19 12:39:00', 26),
(106, 11, '2025', 'octubre', 'pagado', '2025-12-19 12:39:00', 26),
(107, 11, '2025', 'noviembre', 'pagado', '2025-12-19 12:39:00', 26),
(108, 12, '2025', 'marzo', 'pagado', '2025-12-19 12:39:00', 26),
(109, 12, '2025', 'abril', 'pagado', '2025-12-19 12:39:00', 26),
(110, 12, '2025', 'mayo', 'pagado', '2025-12-19 12:39:00', 26),
(111, 12, '2025', 'junio', 'pagado', '2025-12-19 12:39:00', 26),
(112, 12, '2025', 'julio', 'pagado', '2025-12-19 12:39:00', 26),
(113, 12, '2025', 'agosto', 'pagado', '2025-12-19 12:39:00', 26),
(114, 12, '2025', 'septiembre', 'pagado', '2025-12-19 12:39:00', 26),
(115, 12, '2025', 'octubre', 'pagado', '2025-12-19 12:39:00', 26),
(116, 12, '2025', 'noviembre', 'pagado', '2025-12-19 12:39:00', 26),
(117, 12, '2025', 'diciembre', 'pagado', '2025-12-19 12:39:00', 26),
(118, 3, '2025', 'marzo', 'pagado', '2025-12-19 12:39:00', 26),
(119, 3, '2025', 'abril', 'pagado', '2025-12-19 12:39:00', 26),
(120, 3, '2025', 'mayo', 'pagado', '2025-12-19 12:39:00', 26),
(121, 3, '2025', 'junio', 'pagado', '2025-12-19 12:39:00', 26),
(122, 3, '2025', 'julio', 'pagado', '2025-12-19 12:39:00', 26),
(123, 3, '2025', 'agosto', 'pagado', '2025-12-19 12:39:00', 26),
(124, 3, '2025', 'septiembre', 'pagado', '2025-12-19 12:39:00', 26),
(125, 3, '2025', 'octubre', 'pagado', '2025-12-19 12:39:00', 26),
(126, 3, '2025', 'noviembre', 'pagado', '2025-12-19 12:39:00', 26),
(127, 3, '2025', 'diciembre', 'pagado', '2025-12-19 12:39:00', 26),
(128, 13, '2025', 'marzo', 'pagado', '2025-12-19 12:39:00', 26),
(129, 13, '2025', 'abril', 'pagado', '2025-12-19 12:39:00', 26),
(130, 13, '2025', 'mayo', 'pagado', '2025-12-19 12:39:00', 26),
(131, 13, '2025', 'junio', 'pagado', '2025-12-19 12:39:00', 26),
(132, 13, '2025', 'julio', 'pagado', '2025-12-19 12:39:00', 26),
(133, 13, '2025', 'agosto', 'pagado', '2025-12-19 12:39:00', 26),
(134, 13, '2025', 'septiembre', 'pagado', '2025-12-19 12:39:00', 26),
(135, 13, '2025', 'octubre', 'pagado', '2025-12-19 12:39:00', 26),
(137, 30, '2025', 'marzo', 'pagado', '2025-12-19 15:46:46', 26),
(138, 30, '2025', 'abril', 'pagado', '2025-12-19 15:46:46', 26),
(139, 30, '2025', 'mayo', 'pagado', '2025-12-19 15:46:46', 26),
(140, 30, '2025', 'junio', 'pagado', '2025-12-19 15:46:46', 26),
(141, 30, '2025', 'julio', 'pagado', '2025-12-19 15:46:46', 26),
(142, 30, '2025', 'agosto', 'pagado', '2025-12-19 15:46:46', 26),
(143, 30, '2025', 'septiembre', 'pagado', '2025-12-19 15:46:46', 26),
(144, 30, '2025', 'octubre', 'pagado', '2025-12-19 15:46:46', 26),
(145, 30, '2025', 'noviembre', 'pagado', '2025-12-19 15:46:46', 26),
(146, 30, '2025', 'diciembre', 'pagado', '2025-12-19 15:46:46', 26),
(147, 29, '2025', 'marzo', 'pagado', '2025-12-19 15:46:46', 26),
(148, 29, '2025', 'abril', 'pagado', '2025-12-19 15:46:46', 26),
(149, 29, '2025', 'mayo', 'pagado', '2025-12-19 15:46:46', 26),
(150, 29, '2025', 'junio', 'pagado', '2025-12-19 15:46:46', 26),
(151, 29, '2025', 'julio', 'pagado', '2025-12-19 15:46:46', 26),
(152, 29, '2025', 'agosto', 'pagado', '2025-12-19 15:46:46', 26),
(153, 29, '2025', 'septiembre', 'pagado', '2025-12-19 15:46:46', 26),
(154, 29, '2025', 'octubre', 'pagado', '2025-12-19 15:46:46', 26),
(155, 29, '2025', 'noviembre', 'pagado', '2025-12-19 15:46:46', 26),
(156, 29, '2025', 'diciembre', 'pagado', '2025-12-19 15:46:46', 26),
(157, 31, '2025', 'marzo', 'pagado', '2025-12-19 15:46:46', 26),
(158, 31, '2025', 'abril', 'pagado', '2025-12-19 15:46:46', 26),
(159, 31, '2025', 'mayo', 'pagado', '2025-12-19 15:46:46', 26),
(160, 31, '2025', 'junio', 'pagado', '2025-12-19 15:46:46', 26),
(161, 31, '2025', 'julio', 'pagado', '2025-12-19 15:46:46', 26),
(162, 31, '2025', 'agosto', 'pagado', '2025-12-19 15:46:46', 26),
(163, 31, '2025', 'septiembre', 'pagado', '2025-12-19 15:46:46', 26),
(164, 31, '2025', 'octubre', 'pagado', '2025-12-19 15:46:46', 26),
(165, 31, '2025', 'noviembre', 'pagado', '2025-12-19 15:46:46', 26),
(166, 31, '2025', 'diciembre', 'pagado', '2025-12-19 15:46:46', 26),
(167, 28, '2025', 'marzo', 'pagado', '2025-12-19 15:46:46', 26),
(168, 28, '2025', 'abril', 'pagado', '2025-12-19 15:46:46', 26),
(169, 28, '2025', 'mayo', 'pagado', '2025-12-19 15:46:46', 26),
(170, 28, '2025', 'junio', 'pagado', '2025-12-19 15:46:46', 26),
(171, 28, '2025', 'julio', 'pagado', '2025-12-19 15:46:46', 26),
(172, 28, '2025', 'agosto', 'pagado', '2025-12-19 15:46:46', 26),
(173, 28, '2025', 'septiembre', 'pagado', '2025-12-19 15:46:46', 26),
(174, 28, '2025', 'octubre', 'pagado', '2025-12-19 15:46:46', 26),
(175, 28, '2025', 'noviembre', 'pagado', '2025-12-19 15:46:46', 26),
(176, 28, '2025', 'diciembre', 'pagado', '2025-12-19 15:46:46', 26),
(177, 27, '2025', 'marzo', 'pagado', '2025-12-19 15:46:46', 26),
(178, 27, '2025', 'abril', 'pagado', '2025-12-19 15:46:46', 26),
(179, 27, '2025', 'mayo', 'pagado', '2025-12-19 15:46:46', 26),
(180, 27, '2025', 'junio', 'pagado', '2025-12-19 15:46:46', 26),
(181, 27, '2025', 'julio', 'pagado', '2025-12-19 15:46:46', 26),
(182, 27, '2025', 'agosto', 'pagado', '2025-12-19 15:46:46', 26),
(183, 27, '2025', 'septiembre', 'pagado', '2025-12-19 15:46:46', 26),
(184, 27, '2025', 'octubre', 'pagado', '2025-12-19 15:46:46', 26),
(185, 27, '2025', 'noviembre', 'pagado', '2025-12-19 15:46:46', 26),
(186, 27, '2025', 'diciembre', 'pagado', '2025-12-19 15:46:46', 26),
(187, 24, '2025', 'marzo', 'pagado', '2025-12-19 15:47:19', 26),
(188, 24, '2025', 'abril', 'pagado', '2025-12-19 15:47:19', 26),
(189, 24, '2025', 'mayo', 'pagado', '2025-12-19 15:47:19', 26),
(190, 24, '2025', 'junio', 'pagado', '2025-12-19 15:47:19', 26),
(191, 24, '2025', 'julio', 'pagado', '2025-12-19 15:47:19', 26),
(192, 24, '2025', 'agosto', 'pagado', '2025-12-19 15:47:19', 26),
(193, 24, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:19', 26),
(194, 24, '2025', 'octubre', 'pagado', '2025-12-19 15:47:19', 26),
(195, 24, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:19', 26),
(196, 24, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:19', 26),
(197, 22, '2025', 'marzo', 'pagado', '2025-12-19 15:47:19', 26),
(198, 22, '2025', 'abril', 'pagado', '2025-12-19 15:47:19', 26),
(199, 22, '2025', 'mayo', 'pagado', '2025-12-19 15:47:19', 26),
(200, 22, '2025', 'junio', 'pagado', '2025-12-19 15:47:19', 26),
(201, 22, '2025', 'julio', 'pagado', '2025-12-19 15:47:19', 26),
(202, 22, '2025', 'agosto', 'pagado', '2025-12-19 15:47:19', 26),
(203, 22, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:19', 26),
(204, 22, '2025', 'octubre', 'pagado', '2025-12-19 15:47:19', 26),
(205, 22, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:19', 26),
(206, 22, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:19', 26),
(207, 25, '2025', 'marzo', 'pagado', '2025-12-19 15:47:19', 26),
(208, 25, '2025', 'abril', 'pagado', '2025-12-19 15:47:19', 26),
(209, 25, '2025', 'mayo', 'pagado', '2025-12-19 15:47:19', 26),
(210, 25, '2025', 'junio', 'pagado', '2025-12-19 15:47:19', 26),
(211, 25, '2025', 'julio', 'pagado', '2025-12-19 15:47:19', 26),
(212, 25, '2025', 'agosto', 'pagado', '2025-12-19 15:47:19', 26),
(213, 25, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:19', 26),
(214, 25, '2025', 'octubre', 'pagado', '2025-12-19 15:47:19', 26),
(215, 25, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:19', 26),
(216, 25, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:19', 26),
(217, 23, '2025', 'marzo', 'pagado', '2025-12-19 15:47:19', 26),
(218, 23, '2025', 'abril', 'pagado', '2025-12-19 15:47:19', 26),
(219, 23, '2025', 'mayo', 'pagado', '2025-12-19 15:47:19', 26),
(220, 23, '2025', 'junio', 'pagado', '2025-12-19 15:47:19', 26),
(221, 23, '2025', 'julio', 'pagado', '2025-12-19 15:47:19', 26),
(222, 23, '2025', 'agosto', 'pagado', '2025-12-19 15:47:19', 26),
(223, 23, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:19', 26),
(224, 23, '2025', 'octubre', 'pagado', '2025-12-19 15:47:19', 26),
(225, 23, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:19', 26),
(226, 23, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:19', 26),
(227, 26, '2025', 'marzo', 'pagado', '2025-12-19 15:47:19', 26),
(228, 26, '2025', 'abril', 'pagado', '2025-12-19 15:47:19', 26),
(229, 26, '2025', 'mayo', 'pagado', '2025-12-19 15:47:19', 26),
(230, 26, '2025', 'junio', 'pagado', '2025-12-19 15:47:19', 26),
(231, 26, '2025', 'julio', 'pagado', '2025-12-19 15:47:19', 26),
(232, 26, '2025', 'agosto', 'pagado', '2025-12-19 15:47:19', 26),
(233, 26, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:19', 26),
(234, 26, '2025', 'octubre', 'pagado', '2025-12-19 15:47:19', 26),
(235, 26, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:19', 26),
(236, 26, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:19', 26),
(237, 36, '2025', 'marzo', 'pagado', '2025-12-19 15:47:59', 26),
(238, 36, '2025', 'abril', 'pagado', '2025-12-19 15:47:59', 26),
(239, 36, '2025', 'mayo', 'pagado', '2025-12-19 15:47:59', 26),
(240, 36, '2025', 'junio', 'pagado', '2025-12-19 15:47:59', 26),
(241, 36, '2025', 'julio', 'pagado', '2025-12-19 15:47:59', 26),
(242, 36, '2025', 'agosto', 'pagado', '2025-12-19 15:47:59', 26),
(243, 36, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:59', 26),
(244, 36, '2025', 'octubre', 'pagado', '2025-12-19 15:47:59', 26),
(245, 36, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:59', 26),
(246, 36, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:59', 26),
(247, 33, '2025', 'marzo', 'pagado', '2025-12-19 15:47:59', 26),
(248, 33, '2025', 'abril', 'pagado', '2025-12-19 15:47:59', 26),
(249, 33, '2025', 'mayo', 'pagado', '2025-12-19 15:47:59', 26),
(250, 33, '2025', 'junio', 'pagado', '2025-12-19 15:47:59', 26),
(251, 33, '2025', 'julio', 'pagado', '2025-12-19 15:47:59', 26),
(252, 33, '2025', 'agosto', 'pagado', '2025-12-19 15:47:59', 26),
(253, 33, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:59', 26),
(254, 33, '2025', 'octubre', 'pagado', '2025-12-19 15:47:59', 26),
(255, 33, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:59', 26),
(256, 33, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:59', 26),
(257, 32, '2025', 'marzo', 'pagado', '2025-12-19 15:47:59', 26),
(258, 32, '2025', 'abril', 'pagado', '2025-12-19 15:47:59', 26),
(259, 32, '2025', 'mayo', 'pagado', '2025-12-19 15:47:59', 26),
(260, 32, '2025', 'junio', 'pagado', '2025-12-19 15:47:59', 26),
(261, 32, '2025', 'julio', 'pagado', '2025-12-19 15:47:59', 26),
(262, 32, '2025', 'agosto', 'pagado', '2025-12-19 15:47:59', 26),
(263, 32, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:59', 26),
(264, 32, '2025', 'octubre', 'pagado', '2025-12-19 15:47:59', 26),
(265, 32, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:59', 26),
(266, 32, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:59', 26),
(267, 35, '2025', 'marzo', 'pagado', '2025-12-19 15:47:59', 26),
(268, 35, '2025', 'abril', 'pagado', '2025-12-19 15:47:59', 26),
(269, 35, '2025', 'mayo', 'pagado', '2025-12-19 15:47:59', 26),
(270, 35, '2025', 'junio', 'pagado', '2025-12-19 15:47:59', 26),
(271, 35, '2025', 'julio', 'pagado', '2025-12-19 15:47:59', 26),
(272, 35, '2025', 'agosto', 'pagado', '2025-12-19 15:47:59', 26),
(273, 35, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:59', 26),
(274, 35, '2025', 'octubre', 'pagado', '2025-12-19 15:47:59', 26),
(275, 35, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:59', 26),
(276, 35, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:59', 26),
(277, 34, '2025', 'marzo', 'pagado', '2025-12-19 15:47:59', 26),
(278, 34, '2025', 'abril', 'pagado', '2025-12-19 15:47:59', 26),
(279, 34, '2025', 'mayo', 'pagado', '2025-12-19 15:47:59', 26),
(280, 34, '2025', 'junio', 'pagado', '2025-12-19 15:47:59', 26),
(281, 34, '2025', 'julio', 'pagado', '2025-12-19 15:47:59', 26),
(282, 34, '2025', 'agosto', 'pagado', '2025-12-19 15:47:59', 26),
(283, 34, '2025', 'septiembre', 'pagado', '2025-12-19 15:47:59', 26),
(284, 34, '2025', 'octubre', 'pagado', '2025-12-19 15:47:59', 26),
(285, 34, '2025', 'noviembre', 'pagado', '2025-12-19 15:47:59', 26),
(286, 34, '2025', 'diciembre', 'pagado', '2025-12-19 15:47:59', 26),
(287, 39, '2025', 'marzo', 'pagado', '2025-12-19 15:48:44', 26),
(288, 39, '2025', 'abril', 'pagado', '2025-12-19 15:48:44', 26),
(289, 39, '2025', 'mayo', 'pagado', '2025-12-19 15:48:44', 26),
(290, 39, '2025', 'junio', 'pagado', '2025-12-19 15:48:44', 26),
(291, 39, '2025', 'julio', 'pagado', '2025-12-19 15:48:44', 26),
(292, 39, '2025', 'agosto', 'pagado', '2025-12-19 15:48:44', 26),
(293, 39, '2025', 'septiembre', 'pagado', '2025-12-19 15:48:44', 26),
(294, 39, '2025', 'octubre', 'pagado', '2025-12-19 15:48:44', 26),
(295, 39, '2025', 'noviembre', 'pagado', '2025-12-19 15:48:44', 26),
(296, 39, '2025', 'diciembre', 'pagado', '2025-12-19 15:48:44', 26),
(297, 37, '2025', 'marzo', 'pagado', '2025-12-19 15:48:44', 26),
(298, 37, '2025', 'abril', 'pagado', '2025-12-19 15:48:44', 26),
(299, 37, '2025', 'mayo', 'pagado', '2025-12-19 15:48:44', 26),
(300, 37, '2025', 'junio', 'pagado', '2025-12-19 15:48:44', 26),
(301, 37, '2025', 'julio', 'pagado', '2025-12-19 15:48:44', 26),
(302, 37, '2025', 'agosto', 'pagado', '2025-12-19 15:48:44', 26),
(303, 37, '2025', 'septiembre', 'pagado', '2025-12-19 15:48:44', 26),
(304, 37, '2025', 'octubre', 'pagado', '2025-12-19 15:48:44', 26),
(305, 37, '2025', 'noviembre', 'pagado', '2025-12-19 15:48:44', 26),
(306, 37, '2025', 'diciembre', 'pagado', '2025-12-19 15:48:44', 26),
(307, 40, '2025', 'marzo', 'pagado', '2025-12-19 15:48:44', 26),
(308, 40, '2025', 'abril', 'pagado', '2025-12-19 15:48:44', 26),
(309, 40, '2025', 'mayo', 'pagado', '2025-12-19 15:48:44', 26),
(310, 40, '2025', 'junio', 'pagado', '2025-12-19 15:48:44', 26),
(311, 40, '2025', 'julio', 'pagado', '2025-12-19 15:48:44', 26),
(312, 40, '2025', 'agosto', 'pagado', '2025-12-19 15:48:44', 26),
(313, 40, '2025', 'septiembre', 'pagado', '2025-12-19 15:48:44', 26),
(314, 40, '2025', 'octubre', 'pagado', '2025-12-19 15:48:44', 26),
(315, 40, '2025', 'noviembre', 'pagado', '2025-12-19 15:48:44', 26),
(316, 40, '2025', 'diciembre', 'pagado', '2025-12-19 15:48:44', 26),
(317, 38, '2025', 'marzo', 'pagado', '2025-12-19 15:48:44', 26),
(318, 38, '2025', 'abril', 'pagado', '2025-12-19 15:48:44', 26),
(319, 38, '2025', 'mayo', 'pagado', '2025-12-19 15:48:44', 26),
(320, 38, '2025', 'junio', 'pagado', '2025-12-19 15:48:44', 26),
(321, 38, '2025', 'julio', 'pagado', '2025-12-19 15:48:44', 26),
(322, 38, '2025', 'agosto', 'pagado', '2025-12-19 15:48:44', 26),
(323, 38, '2025', 'septiembre', 'pagado', '2025-12-19 15:48:44', 26),
(324, 38, '2025', 'octubre', 'pagado', '2025-12-19 15:48:44', 26),
(325, 38, '2025', 'noviembre', 'pagado', '2025-12-19 15:48:44', 26),
(326, 38, '2025', 'diciembre', 'pagado', '2025-12-19 15:48:44', 26),
(327, 41, '2025', 'marzo', 'pagado', '2025-12-19 15:48:44', 26),
(328, 41, '2025', 'abril', 'pagado', '2025-12-19 15:48:44', 26),
(329, 41, '2025', 'mayo', 'pagado', '2025-12-19 15:48:44', 26),
(330, 41, '2025', 'junio', 'pagado', '2025-12-19 15:48:44', 26),
(331, 41, '2025', 'julio', 'pagado', '2025-12-19 15:48:44', 26),
(332, 41, '2025', 'agosto', 'pagado', '2025-12-19 15:48:44', 26),
(333, 41, '2025', 'septiembre', 'pagado', '2025-12-19 15:48:44', 26),
(334, 41, '2025', 'octubre', 'pagado', '2025-12-19 15:48:44', 26),
(335, 41, '2025', 'noviembre', 'pagado', '2025-12-19 15:48:44', 26),
(336, 41, '2025', 'diciembre', 'pagado', '2025-12-19 15:48:44', 26),
(337, 44, '2025', 'marzo', 'pagado', '2025-12-19 15:49:17', 26),
(338, 44, '2025', 'abril', 'pagado', '2025-12-19 15:49:17', 26),
(339, 44, '2025', 'mayo', 'pagado', '2025-12-19 15:49:17', 26),
(340, 44, '2025', 'junio', 'pagado', '2025-12-19 15:49:17', 26),
(341, 44, '2025', 'julio', 'pagado', '2025-12-19 15:49:17', 26),
(342, 44, '2025', 'agosto', 'pagado', '2025-12-19 15:49:17', 26),
(343, 44, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:17', 26),
(344, 44, '2025', 'octubre', 'pagado', '2025-12-19 15:49:17', 26),
(345, 44, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:17', 26),
(346, 44, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:17', 26),
(347, 43, '2025', 'marzo', 'pagado', '2025-12-19 15:49:17', 26),
(348, 43, '2025', 'abril', 'pagado', '2025-12-19 15:49:17', 26),
(349, 43, '2025', 'mayo', 'pagado', '2025-12-19 15:49:17', 26),
(350, 43, '2025', 'junio', 'pagado', '2025-12-19 15:49:17', 26),
(351, 43, '2025', 'julio', 'pagado', '2025-12-19 15:49:17', 26),
(352, 43, '2025', 'agosto', 'pagado', '2025-12-19 15:49:17', 26),
(353, 43, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:17', 26),
(354, 43, '2025', 'octubre', 'pagado', '2025-12-19 15:49:17', 26),
(355, 43, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:17', 26),
(356, 43, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:17', 26),
(357, 45, '2025', 'marzo', 'pagado', '2025-12-19 15:49:17', 26),
(358, 45, '2025', 'abril', 'pagado', '2025-12-19 15:49:17', 26),
(359, 45, '2025', 'mayo', 'pagado', '2025-12-19 15:49:17', 26),
(360, 45, '2025', 'junio', 'pagado', '2025-12-19 15:49:17', 26),
(361, 45, '2025', 'julio', 'pagado', '2025-12-19 15:49:17', 26),
(362, 45, '2025', 'agosto', 'pagado', '2025-12-19 15:49:17', 26),
(363, 45, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:17', 26),
(364, 45, '2025', 'octubre', 'pagado', '2025-12-19 15:49:17', 26),
(365, 45, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:17', 26),
(366, 45, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:17', 26),
(367, 42, '2025', 'marzo', 'pagado', '2025-12-19 15:49:17', 26),
(368, 42, '2025', 'abril', 'pagado', '2025-12-19 15:49:17', 26),
(369, 42, '2025', 'mayo', 'pagado', '2025-12-19 15:49:17', 26),
(370, 42, '2025', 'junio', 'pagado', '2025-12-19 15:49:17', 26),
(371, 42, '2025', 'julio', 'pagado', '2025-12-19 15:49:17', 26),
(372, 42, '2025', 'agosto', 'pagado', '2025-12-19 15:49:17', 26),
(373, 42, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:17', 26),
(374, 42, '2025', 'octubre', 'pagado', '2025-12-19 15:49:17', 26),
(375, 42, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:17', 26),
(376, 42, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:17', 26),
(377, 46, '2025', 'marzo', 'pagado', '2025-12-19 15:49:17', 26),
(378, 46, '2025', 'abril', 'pagado', '2025-12-19 15:49:17', 26),
(379, 46, '2025', 'mayo', 'pagado', '2025-12-19 15:49:17', 26),
(380, 46, '2025', 'junio', 'pagado', '2025-12-19 15:49:17', 26),
(381, 46, '2025', 'julio', 'pagado', '2025-12-19 15:49:17', 26),
(382, 46, '2025', 'agosto', 'pagado', '2025-12-19 15:49:17', 26),
(383, 46, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:17', 26),
(384, 46, '2025', 'octubre', 'pagado', '2025-12-19 15:49:17', 26),
(385, 46, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:17', 26),
(386, 46, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:17', 26),
(387, 51, '2025', 'marzo', 'pagado', '2025-12-19 15:49:42', 26),
(388, 51, '2025', 'abril', 'pagado', '2025-12-19 15:49:42', 26),
(389, 51, '2025', 'mayo', 'pagado', '2025-12-19 15:49:42', 26),
(390, 51, '2025', 'junio', 'pagado', '2025-12-19 15:49:42', 26),
(391, 51, '2025', 'julio', 'pagado', '2025-12-19 15:49:42', 26),
(392, 51, '2025', 'agosto', 'pagado', '2025-12-19 15:49:42', 26),
(393, 51, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:42', 26),
(394, 51, '2025', 'octubre', 'pagado', '2025-12-19 15:49:42', 26),
(395, 51, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:42', 26),
(396, 51, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:42', 26),
(397, 47, '2025', 'marzo', 'pagado', '2025-12-19 15:49:42', 26),
(398, 47, '2025', 'abril', 'pagado', '2025-12-19 15:49:42', 26),
(399, 47, '2025', 'mayo', 'pagado', '2025-12-19 15:49:42', 26),
(400, 47, '2025', 'junio', 'pagado', '2025-12-19 15:49:42', 26),
(401, 47, '2025', 'julio', 'pagado', '2025-12-19 15:49:42', 26),
(402, 47, '2025', 'agosto', 'pagado', '2025-12-19 15:49:42', 26),
(403, 47, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:42', 26),
(404, 47, '2025', 'octubre', 'pagado', '2025-12-19 15:49:42', 26),
(405, 47, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:42', 26),
(406, 47, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:42', 26),
(407, 49, '2025', 'marzo', 'pagado', '2025-12-19 15:49:42', 26),
(408, 49, '2025', 'abril', 'pagado', '2025-12-19 15:49:42', 26),
(409, 49, '2025', 'mayo', 'pagado', '2025-12-19 15:49:42', 26),
(410, 49, '2025', 'junio', 'pagado', '2025-12-19 15:49:42', 26),
(411, 49, '2025', 'julio', 'pagado', '2025-12-19 15:49:42', 26),
(412, 49, '2025', 'agosto', 'pagado', '2025-12-19 15:49:42', 26),
(413, 49, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:42', 26),
(414, 49, '2025', 'octubre', 'pagado', '2025-12-19 15:49:42', 26),
(415, 49, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:42', 26),
(416, 49, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:42', 26),
(417, 50, '2025', 'marzo', 'pagado', '2025-12-19 15:49:42', 26),
(418, 50, '2025', 'abril', 'pagado', '2025-12-19 15:49:42', 26),
(419, 50, '2025', 'mayo', 'pagado', '2025-12-19 15:49:42', 26),
(420, 50, '2025', 'junio', 'pagado', '2025-12-19 15:49:42', 26),
(421, 50, '2025', 'julio', 'pagado', '2025-12-19 15:49:42', 26),
(422, 50, '2025', 'agosto', 'pagado', '2025-12-19 15:49:42', 26),
(423, 50, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:42', 26),
(424, 50, '2025', 'octubre', 'pagado', '2025-12-19 15:49:42', 26),
(425, 50, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:42', 26),
(426, 50, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:42', 26),
(427, 48, '2025', 'marzo', 'pagado', '2025-12-19 15:49:42', 26),
(428, 48, '2025', 'abril', 'pagado', '2025-12-19 15:49:42', 26),
(429, 48, '2025', 'mayo', 'pagado', '2025-12-19 15:49:42', 26),
(430, 48, '2025', 'junio', 'pagado', '2025-12-19 15:49:42', 26),
(431, 48, '2025', 'julio', 'pagado', '2025-12-19 15:49:42', 26),
(432, 48, '2025', 'agosto', 'pagado', '2025-12-19 15:49:42', 26),
(433, 48, '2025', 'septiembre', 'pagado', '2025-12-19 15:49:42', 26),
(434, 48, '2025', 'octubre', 'pagado', '2025-12-19 15:49:42', 26),
(435, 48, '2025', 'noviembre', 'pagado', '2025-12-19 15:49:42', 26),
(436, 48, '2025', 'diciembre', 'pagado', '2025-12-19 15:49:42', 26),
(437, 55, '2025', 'marzo', 'pagado', '2025-12-19 15:50:28', 26),
(438, 55, '2025', 'abril', 'pagado', '2025-12-19 15:50:28', 26),
(439, 55, '2025', 'mayo', 'pagado', '2025-12-19 15:50:28', 26),
(440, 55, '2025', 'junio', 'pagado', '2025-12-19 15:50:28', 26),
(441, 55, '2025', 'julio', 'pagado', '2025-12-19 15:50:28', 26),
(442, 55, '2025', 'agosto', 'pagado', '2025-12-19 15:50:28', 26),
(443, 55, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:28', 26),
(444, 55, '2025', 'octubre', 'pagado', '2025-12-19 15:50:28', 26),
(445, 55, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:28', 26),
(446, 55, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:28', 26),
(447, 54, '2025', 'marzo', 'pagado', '2025-12-19 15:50:28', 26),
(448, 54, '2025', 'abril', 'pagado', '2025-12-19 15:50:28', 26),
(449, 54, '2025', 'mayo', 'pagado', '2025-12-19 15:50:28', 26),
(450, 54, '2025', 'junio', 'pagado', '2025-12-19 15:50:28', 26),
(451, 54, '2025', 'julio', 'pagado', '2025-12-19 15:50:28', 26),
(452, 54, '2025', 'agosto', 'pagado', '2025-12-19 15:50:28', 26),
(453, 54, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:28', 26),
(454, 54, '2025', 'octubre', 'pagado', '2025-12-19 15:50:28', 26),
(455, 54, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:28', 26),
(456, 54, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:28', 26),
(457, 53, '2025', 'marzo', 'pagado', '2025-12-19 15:50:28', 26),
(458, 53, '2025', 'abril', 'pagado', '2025-12-19 15:50:28', 26),
(459, 53, '2025', 'mayo', 'pagado', '2025-12-19 15:50:28', 26),
(460, 53, '2025', 'junio', 'pagado', '2025-12-19 15:50:28', 26),
(461, 53, '2025', 'julio', 'pagado', '2025-12-19 15:50:28', 26),
(462, 53, '2025', 'agosto', 'pagado', '2025-12-19 15:50:28', 26),
(463, 53, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:28', 26),
(464, 53, '2025', 'octubre', 'pagado', '2025-12-19 15:50:28', 26),
(465, 53, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:28', 26),
(466, 53, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:28', 26),
(467, 56, '2025', 'marzo', 'pagado', '2025-12-19 15:50:28', 26),
(468, 56, '2025', 'abril', 'pagado', '2025-12-19 15:50:28', 26),
(469, 56, '2025', 'mayo', 'pagado', '2025-12-19 15:50:28', 26),
(470, 56, '2025', 'junio', 'pagado', '2025-12-19 15:50:28', 26),
(471, 56, '2025', 'julio', 'pagado', '2025-12-19 15:50:28', 26),
(472, 56, '2025', 'agosto', 'pagado', '2025-12-19 15:50:28', 26),
(473, 56, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:28', 26),
(474, 56, '2025', 'octubre', 'pagado', '2025-12-19 15:50:28', 26),
(475, 56, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:28', 26),
(476, 56, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:28', 26),
(477, 52, '2025', 'marzo', 'pagado', '2025-12-19 15:50:28', 26),
(478, 52, '2025', 'abril', 'pagado', '2025-12-19 15:50:28', 26),
(479, 52, '2025', 'mayo', 'pagado', '2025-12-19 15:50:28', 26),
(480, 52, '2025', 'junio', 'pagado', '2025-12-19 15:50:28', 26),
(481, 52, '2025', 'julio', 'pagado', '2025-12-19 15:50:28', 26),
(482, 52, '2025', 'agosto', 'pagado', '2025-12-19 15:50:28', 26),
(483, 52, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:28', 26),
(484, 52, '2025', 'octubre', 'pagado', '2025-12-19 15:50:28', 26),
(485, 52, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:28', 26),
(486, 52, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:28', 26),
(487, 58, '2025', 'marzo', 'pagado', '2025-12-19 15:50:57', 26),
(488, 58, '2025', 'abril', 'pagado', '2025-12-19 15:50:57', 26),
(489, 58, '2025', 'mayo', 'pagado', '2025-12-19 15:50:57', 26),
(490, 58, '2025', 'junio', 'pagado', '2025-12-19 15:50:57', 26),
(491, 58, '2025', 'julio', 'pagado', '2025-12-19 15:50:57', 26),
(492, 58, '2025', 'agosto', 'pagado', '2025-12-19 15:50:57', 26),
(493, 58, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:57', 26),
(494, 58, '2025', 'octubre', 'pagado', '2025-12-19 15:50:57', 26),
(495, 58, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:57', 26),
(496, 58, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:57', 26),
(497, 57, '2025', 'marzo', 'pagado', '2025-12-19 15:50:57', 26),
(498, 57, '2025', 'abril', 'pagado', '2025-12-19 15:50:57', 26),
(499, 57, '2025', 'mayo', 'pagado', '2025-12-19 15:50:57', 26),
(500, 57, '2025', 'junio', 'pagado', '2025-12-19 15:50:57', 26),
(501, 57, '2025', 'julio', 'pagado', '2025-12-19 15:50:57', 26),
(502, 57, '2025', 'agosto', 'pagado', '2025-12-19 15:50:57', 26),
(503, 57, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:57', 26),
(504, 57, '2025', 'octubre', 'pagado', '2025-12-19 15:50:57', 26),
(505, 57, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:57', 26),
(506, 57, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:57', 26),
(507, 61, '2025', 'marzo', 'pagado', '2025-12-19 15:50:57', 26),
(508, 61, '2025', 'abril', 'pagado', '2025-12-19 15:50:57', 26),
(509, 61, '2025', 'mayo', 'pagado', '2025-12-19 15:50:57', 26),
(510, 61, '2025', 'junio', 'pagado', '2025-12-19 15:50:57', 26),
(511, 61, '2025', 'julio', 'pagado', '2025-12-19 15:50:57', 26),
(512, 61, '2025', 'agosto', 'pagado', '2025-12-19 15:50:57', 26),
(513, 61, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:57', 26),
(514, 61, '2025', 'octubre', 'pagado', '2025-12-19 15:50:57', 26),
(515, 61, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:57', 26),
(516, 61, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:57', 26),
(517, 59, '2025', 'marzo', 'pagado', '2025-12-19 15:50:57', 26),
(518, 59, '2025', 'abril', 'pagado', '2025-12-19 15:50:57', 26),
(519, 59, '2025', 'mayo', 'pagado', '2025-12-19 15:50:57', 26),
(520, 59, '2025', 'junio', 'pagado', '2025-12-19 15:50:57', 26),
(521, 59, '2025', 'julio', 'pagado', '2025-12-19 15:50:57', 26),
(522, 59, '2025', 'agosto', 'pagado', '2025-12-19 15:50:57', 26),
(523, 59, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:57', 26),
(524, 59, '2025', 'octubre', 'pagado', '2025-12-19 15:50:57', 26),
(525, 59, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:57', 26),
(526, 59, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:57', 26),
(527, 60, '2025', 'marzo', 'pagado', '2025-12-19 15:50:57', 26),
(528, 60, '2025', 'abril', 'pagado', '2025-12-19 15:50:57', 26),
(529, 60, '2025', 'mayo', 'pagado', '2025-12-19 15:50:57', 26),
(530, 60, '2025', 'junio', 'pagado', '2025-12-19 15:50:57', 26),
(531, 60, '2025', 'julio', 'pagado', '2025-12-19 15:50:57', 26),
(532, 60, '2025', 'agosto', 'pagado', '2025-12-19 15:50:57', 26),
(533, 60, '2025', 'septiembre', 'pagado', '2025-12-19 15:50:57', 26),
(534, 60, '2025', 'octubre', 'pagado', '2025-12-19 15:50:57', 26),
(535, 60, '2025', 'noviembre', 'pagado', '2025-12-19 15:50:57', 26),
(536, 60, '2025', 'diciembre', 'pagado', '2025-12-19 15:50:57', 26),
(537, 65, '2025', 'marzo', 'pagado', '2025-12-19 15:51:32', 26),
(538, 65, '2025', 'abril', 'pagado', '2025-12-19 15:51:32', 26),
(539, 65, '2025', 'mayo', 'pagado', '2025-12-19 15:51:32', 26),
(540, 65, '2025', 'junio', 'pagado', '2025-12-19 15:51:32', 26),
(541, 65, '2025', 'julio', 'pagado', '2025-12-19 15:51:32', 26),
(542, 65, '2025', 'agosto', 'pagado', '2025-12-19 15:51:32', 26),
(543, 65, '2025', 'septiembre', 'pagado', '2025-12-19 15:51:32', 26),
(544, 65, '2025', 'octubre', 'pagado', '2025-12-19 15:51:32', 26),
(545, 65, '2025', 'noviembre', 'pagado', '2025-12-19 15:51:32', 26),
(546, 65, '2025', 'diciembre', 'pagado', '2025-12-19 15:51:32', 26),
(547, 62, '2025', 'marzo', 'pagado', '2025-12-19 15:51:32', 26),
(548, 62, '2025', 'abril', 'pagado', '2025-12-19 15:51:32', 26),
(549, 62, '2025', 'mayo', 'pagado', '2025-12-19 15:51:32', 26),
(550, 62, '2025', 'junio', 'pagado', '2025-12-19 15:51:32', 26),
(551, 62, '2025', 'julio', 'pagado', '2025-12-19 15:51:32', 26),
(552, 62, '2025', 'agosto', 'pagado', '2025-12-19 15:51:32', 26),
(553, 62, '2025', 'septiembre', 'pagado', '2025-12-19 15:51:32', 26),
(554, 62, '2025', 'octubre', 'pagado', '2025-12-19 15:51:32', 26),
(555, 62, '2025', 'noviembre', 'pagado', '2025-12-19 15:51:32', 26),
(556, 62, '2025', 'diciembre', 'pagado', '2025-12-19 15:51:32', 26),
(557, 64, '2025', 'marzo', 'pagado', '2025-12-19 15:51:32', 26),
(558, 64, '2025', 'abril', 'pagado', '2025-12-19 15:51:32', 26),
(559, 64, '2025', 'mayo', 'pagado', '2025-12-19 15:51:32', 26),
(560, 64, '2025', 'junio', 'pagado', '2025-12-19 15:51:32', 26),
(561, 64, '2025', 'julio', 'pagado', '2025-12-19 15:51:32', 26),
(562, 64, '2025', 'agosto', 'pagado', '2025-12-19 15:51:32', 26),
(563, 64, '2025', 'septiembre', 'pagado', '2025-12-19 15:51:32', 26),
(564, 64, '2025', 'octubre', 'pagado', '2025-12-19 15:51:32', 26),
(565, 64, '2025', 'noviembre', 'pagado', '2025-12-19 15:51:32', 26),
(566, 64, '2025', 'diciembre', 'pagado', '2025-12-19 15:51:32', 26),
(567, 66, '2025', 'marzo', 'pagado', '2025-12-19 15:51:32', 26),
(568, 66, '2025', 'abril', 'pagado', '2025-12-19 15:51:32', 26),
(569, 66, '2025', 'mayo', 'pagado', '2025-12-19 15:51:32', 26),
(570, 66, '2025', 'junio', 'pagado', '2025-12-19 15:51:32', 26),
(571, 66, '2025', 'julio', 'pagado', '2025-12-19 15:51:32', 26),
(572, 66, '2025', 'agosto', 'pagado', '2025-12-19 15:51:32', 26),
(573, 66, '2025', 'septiembre', 'pagado', '2025-12-19 15:51:32', 26),
(574, 66, '2025', 'octubre', 'pagado', '2025-12-19 15:51:32', 26),
(575, 66, '2025', 'noviembre', 'pagado', '2025-12-19 15:51:32', 26),
(576, 66, '2025', 'diciembre', 'pagado', '2025-12-19 15:51:32', 26),
(577, 63, '2025', 'marzo', 'pagado', '2025-12-19 15:51:32', 26),
(578, 63, '2025', 'abril', 'pagado', '2025-12-19 15:51:32', 26),
(579, 63, '2025', 'mayo', 'pagado', '2025-12-19 15:51:32', 26),
(580, 63, '2025', 'junio', 'pagado', '2025-12-19 15:51:32', 26),
(581, 63, '2025', 'julio', 'pagado', '2025-12-19 15:51:32', 26),
(582, 63, '2025', 'agosto', 'pagado', '2025-12-19 15:51:32', 26),
(583, 63, '2025', 'septiembre', 'pagado', '2025-12-19 15:51:32', 26),
(584, 63, '2025', 'octubre', 'pagado', '2025-12-19 15:51:32', 26),
(585, 63, '2025', 'noviembre', 'pagado', '2025-12-19 15:51:32', 26),
(586, 63, '2025', 'diciembre', 'pagado', '2025-12-19 15:51:32', 26),
(587, 68, '2025', 'marzo', 'pagado', '2025-12-19 15:52:01', 26),
(588, 68, '2025', 'abril', 'pagado', '2025-12-19 15:52:01', 26),
(589, 68, '2025', 'mayo', 'pagado', '2025-12-19 15:52:01', 26),
(590, 68, '2025', 'junio', 'pagado', '2025-12-19 15:52:01', 26),
(591, 68, '2025', 'julio', 'pagado', '2025-12-19 15:52:01', 26),
(592, 68, '2025', 'agosto', 'pagado', '2025-12-19 15:52:01', 26),
(593, 68, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:01', 26),
(594, 68, '2025', 'octubre', 'pagado', '2025-12-19 15:52:01', 26),
(595, 68, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:01', 26),
(596, 68, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:01', 26),
(597, 71, '2025', 'marzo', 'pagado', '2025-12-19 15:52:01', 26),
(598, 71, '2025', 'abril', 'pagado', '2025-12-19 15:52:01', 26),
(599, 71, '2025', 'mayo', 'pagado', '2025-12-19 15:52:01', 26),
(600, 71, '2025', 'junio', 'pagado', '2025-12-19 15:52:01', 26),
(601, 71, '2025', 'julio', 'pagado', '2025-12-19 15:52:01', 26),
(602, 71, '2025', 'agosto', 'pagado', '2025-12-19 15:52:01', 26),
(603, 71, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:01', 26),
(604, 71, '2025', 'octubre', 'pagado', '2025-12-19 15:52:01', 26),
(605, 71, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:01', 26),
(606, 71, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:01', 26),
(607, 69, '2025', 'marzo', 'pagado', '2025-12-19 15:52:01', 26),
(608, 69, '2025', 'abril', 'pagado', '2025-12-19 15:52:01', 26),
(609, 69, '2025', 'mayo', 'pagado', '2025-12-19 15:52:01', 26),
(610, 69, '2025', 'junio', 'pagado', '2025-12-19 15:52:01', 26),
(611, 69, '2025', 'julio', 'pagado', '2025-12-19 15:52:01', 26),
(612, 69, '2025', 'agosto', 'pagado', '2025-12-19 15:52:01', 26),
(613, 69, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:01', 26),
(614, 69, '2025', 'octubre', 'pagado', '2025-12-19 15:52:01', 26),
(615, 69, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:01', 26),
(616, 69, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:01', 26),
(617, 67, '2025', 'marzo', 'pagado', '2025-12-19 15:52:01', 26),
(618, 67, '2025', 'abril', 'pagado', '2025-12-19 15:52:01', 26),
(619, 67, '2025', 'mayo', 'pagado', '2025-12-19 15:52:01', 26),
(620, 67, '2025', 'junio', 'pagado', '2025-12-19 15:52:01', 26),
(621, 67, '2025', 'julio', 'pagado', '2025-12-19 15:52:01', 26),
(622, 67, '2025', 'agosto', 'pagado', '2025-12-19 15:52:01', 26),
(623, 67, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:01', 26),
(624, 67, '2025', 'octubre', 'pagado', '2025-12-19 15:52:01', 26),
(625, 67, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:01', 26),
(626, 67, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:01', 26),
(627, 70, '2025', 'marzo', 'pagado', '2025-12-19 15:52:01', 26),
(628, 70, '2025', 'abril', 'pagado', '2025-12-19 15:52:01', 26),
(629, 70, '2025', 'mayo', 'pagado', '2025-12-19 15:52:01', 26),
(630, 70, '2025', 'junio', 'pagado', '2025-12-19 15:52:01', 26),
(631, 70, '2025', 'julio', 'pagado', '2025-12-19 15:52:01', 26),
(632, 70, '2025', 'agosto', 'pagado', '2025-12-19 15:52:01', 26),
(633, 70, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:01', 26),
(634, 70, '2025', 'octubre', 'pagado', '2025-12-19 15:52:01', 26),
(635, 70, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:01', 26),
(636, 70, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:01', 26),
(637, 75, '2025', 'marzo', 'pagado', '2025-12-19 15:52:30', 26),
(638, 75, '2025', 'abril', 'pagado', '2025-12-19 15:52:30', 26),
(639, 75, '2025', 'mayo', 'pagado', '2025-12-19 15:52:30', 26),
(640, 75, '2025', 'junio', 'pagado', '2025-12-19 15:52:30', 26),
(641, 75, '2025', 'julio', 'pagado', '2025-12-19 15:52:30', 26),
(642, 75, '2025', 'agosto', 'pagado', '2025-12-19 15:52:30', 26),
(643, 75, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:30', 26),
(644, 75, '2025', 'octubre', 'pagado', '2025-12-19 15:52:30', 26),
(645, 75, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:30', 26),
(646, 75, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:30', 26),
(647, 73, '2025', 'marzo', 'pagado', '2025-12-19 15:52:30', 26),
(648, 73, '2025', 'abril', 'pagado', '2025-12-19 15:52:30', 26),
(649, 73, '2025', 'mayo', 'pagado', '2025-12-19 15:52:30', 26),
(650, 73, '2025', 'junio', 'pagado', '2025-12-19 15:52:30', 26),
(651, 73, '2025', 'julio', 'pagado', '2025-12-19 15:52:30', 26),
(652, 73, '2025', 'agosto', 'pagado', '2025-12-19 15:52:30', 26),
(653, 73, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:30', 26),
(654, 73, '2025', 'octubre', 'pagado', '2025-12-19 15:52:30', 26),
(655, 73, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:30', 26),
(656, 73, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:30', 26),
(657, 74, '2025', 'marzo', 'pagado', '2025-12-19 15:52:30', 26),
(658, 74, '2025', 'abril', 'pagado', '2025-12-19 15:52:30', 26),
(659, 74, '2025', 'mayo', 'pagado', '2025-12-19 15:52:30', 26),
(660, 74, '2025', 'junio', 'pagado', '2025-12-19 15:52:30', 26),
(661, 74, '2025', 'julio', 'pagado', '2025-12-19 15:52:30', 26),
(662, 74, '2025', 'agosto', 'pagado', '2025-12-19 15:52:30', 26),
(663, 74, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:30', 26),
(664, 74, '2025', 'octubre', 'pagado', '2025-12-19 15:52:30', 26),
(665, 74, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:30', 26),
(666, 74, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:30', 26),
(667, 76, '2025', 'marzo', 'pagado', '2025-12-19 15:52:30', 26),
(668, 76, '2025', 'abril', 'pagado', '2025-12-19 15:52:30', 26),
(669, 76, '2025', 'mayo', 'pagado', '2025-12-19 15:52:30', 26),
(670, 76, '2025', 'junio', 'pagado', '2025-12-19 15:52:30', 26),
(671, 76, '2025', 'julio', 'pagado', '2025-12-19 15:52:30', 26),
(672, 76, '2025', 'agosto', 'pagado', '2025-12-19 15:52:30', 26),
(673, 76, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:30', 26),
(674, 76, '2025', 'octubre', 'pagado', '2025-12-19 15:52:30', 26),
(675, 76, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:30', 26),
(676, 76, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:30', 26),
(677, 72, '2025', 'marzo', 'pagado', '2025-12-19 15:52:30', 26),
(678, 72, '2025', 'abril', 'pagado', '2025-12-19 15:52:30', 26),
(679, 72, '2025', 'mayo', 'pagado', '2025-12-19 15:52:30', 26),
(680, 72, '2025', 'junio', 'pagado', '2025-12-19 15:52:30', 26),
(681, 72, '2025', 'julio', 'pagado', '2025-12-19 15:52:30', 26),
(682, 72, '2025', 'agosto', 'pagado', '2025-12-19 15:52:30', 26),
(683, 72, '2025', 'septiembre', 'pagado', '2025-12-19 15:52:30', 26),
(684, 72, '2025', 'octubre', 'pagado', '2025-12-19 15:52:30', 26),
(685, 72, '2025', 'noviembre', 'pagado', '2025-12-19 15:52:30', 26),
(686, 72, '2025', 'diciembre', 'pagado', '2025-12-19 15:52:30', 26);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `personas_fisicas`
--

CREATE TABLE `personas_fisicas` (
  `id` int(11) NOT NULL,
  `dni` varchar(20) NOT NULL,
  `nombre` varchar(100) NOT NULL,
  `apellido` varchar(100) NOT NULL,
  `fecha_nacimiento` date NOT NULL,
  `direccion` varchar(255) DEFAULT NULL COMMENT 'Calle, número, piso, departamento',
  `localidad` varchar(100) DEFAULT NULL,
  `codigo_postal` varchar(10) DEFAULT NULL,
  `telefono` varchar(20) DEFAULT NULL,
  `email` varchar(100) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `personas_fisicas`
--

INSERT INTO `personas_fisicas` (`id`, `dni`, `nombre`, `apellido`, `fecha_nacimiento`, `direccion`, `localidad`, `codigo_postal`, `telefono`, `email`, `creado_en`, `actualizado_en`) VALUES
(19, '45690437', 'Ariel', 'Gonzalez', '2025-12-19', 'Publica A 3732', 'Córdoba', '5014', '3517414545', 'facuarielgonzalez@gmail.com', '2025-12-19 05:32:06', '2025-12-19 05:35:21'),
(20, '48100002', 'Tomás', 'Selle', '2007-05-20', 'Domicilio Tomás', 'Córdoba', '5000', '3510000001', 'tomaselle2@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(21, '48100004', 'Claudia Lorena', 'Rossi', '2007-02-28', 'Domicilio Claudia Lorena', 'Córdoba', '5000', '3510000003', 'claudialorenarossi82@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(22, '48100006', 'Joaquín', 'Herrera', '2008-01-15', 'Domicilio Joaquín', 'Córdoba', '5000', '3510000005', 'jherrera4389@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(23, '48100009', 'Ignacio', 'López Ponce', '2007-04-04', 'Domicilio Ignacio', 'Córdoba', '5000', '3510000008', 'Ignacio_lopez_ponce@hotmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(24, '48100010', 'Matías', 'Pereyra', '2007-12-24', 'Domicilio Matías', 'Córdoba', '5000', '3510000009', 'matyperyra2001@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(25, '48100011', 'Agustín', 'Moyano', '2007-07-07', 'Domicilio Agustín', 'Córdoba', '5000', '3510000010', 'agustixmo@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(26, '48100012', 'Blanca', 'Oliva', '2008-03-03', 'Domicilio Blanca', 'Córdoba', '5000', '3510000011', 'Blankioliva01@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(27, '48100013', 'Gabriel', 'Olivo', '2007-10-20', 'Domicilio Gabriel', 'Córdoba', '5000', '3510000012', 'olivvogabriel@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(28, '48100015', 'Diego', 'Sarapura', '2007-05-01', 'Domicilio Diego', 'Córdoba', '5000', '3510000014', 'diegosarapura@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(29, '48100016', 'Máximo', 'Sartori', '2007-01-22', 'Domicilio Máximo', 'Córdoba', '5000', '3510000015', 'maximosartori22@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(30, '48100017', 'Tobías', 'Tofalo', '2007-11-30', 'Domicilio Tobías', 'Córdoba', '5000', '3510000016', 'ttofalo@gmail.com', '2025-12-19 05:40:04', '2025-12-19 05:40:04'),
(31, '45246672', 'Juan', 'Avedano', '2004-06-21', 'Publica A 3732', 'Cordoba', '5014', '3517414545', 'Juanavedanoo@gmail.com', '2025-12-19 05:42:34', '2025-12-19 05:42:34'),
(32, '20000000', 'Patricio', 'Ferreyra', '1982-06-21', '', '', '', '3517414545', 'patricioferreyra84@gmail.com', '2025-12-19 05:45:17', '2025-12-19 13:30:58'),
(33, '43353536', 'Rodrigo', 'Gonzalez', '2000-06-24', 'Publica A 3732', 'Cordoba', '5014', '3517414545', 'rodrigogonzalezloza@gmail.com', '2025-12-19 05:49:09', '2025-12-19 05:49:09'),
(34, '45542382', 'Jabase', 'Guillermo', '1900-01-01', 'Publica A 3732', 'Cordoba', '5014', '3517414545', 'guillejabase@gmail.com', '2025-12-19 05:50:55', '2025-12-19 05:51:20'),
(36, '34156134', 'Pedro', 'Gonzalez', '2004-06-21', NULL, NULL, NULL, '3517414545', 'facuarielgonzalez@gmail.com', '2025-12-19 05:53:33', '2025-12-19 05:53:33'),
(37, '45161346', 'Ruibal', 'Agostina', '2004-06-21', NULL, NULL, NULL, '3517414545', 'agosruibal1410@gmail.com', '2025-12-19 05:54:02', '2025-12-19 05:54:02'),
(39, '48100008', 'Mara', 'Lloret', '2004-05-26', 'Publica A 3732', 'Cordoba', '5014', '3517414545', 'Maralloret4@gmail.com', '2025-12-19 06:09:39', '2025-12-19 06:09:39'),
(45, '47000001', 'Lucas', 'Gomez', '2012-03-10', 'Calle Falsa 123', 'Córdoba', '5000', '3511111111', 'lucas.gomez@mail.com', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(46, '47000002', 'Sofia', 'Martinez', '2011-05-15', 'Av. Colon 500', 'Córdoba', '5000', '3511111112', 'sofia.martinez@mail.com', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(47, '47000003', 'Mateo', 'Fernandez', '2010-08-20', 'Bv. Illia 300', 'Córdoba', '5000', '3511111113', 'mateo.fernandez@mail.com', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(48, '47000004', 'Valentina', 'Lopez', '2009-02-14', 'Maipú 100', 'Córdoba', '5000', '3511111114', 'valentina.lopez@mail.com', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(49, '47000005', 'Julian', 'Torres', '2008-11-05', 'San Juan 50', 'Córdoba', '5000', '3511111115', 'julian.torres@mail.com', '2025-12-19 13:15:15', '2025-12-19 13:15:15'),
(50, '47000006', 'Martina', 'Silva', '2012-04-12', 'Av. Patria 800', 'Córdoba', '5000', '3511111116', 'martina.silva@mail.com', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(51, '47000007', 'Nicolas', 'Rojas', '2012-01-30', 'Calle Jujuy 250', 'Córdoba', '5000', '3511111117', 'nicolas.rojas@mail.com', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(52, '47000008', 'Lucia', 'Benitez', '2012-07-22', 'San Martin 2200', 'Córdoba', '5000', '3511111118', 'lucia.benitez@mail.com', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(53, '47000009', 'Tomas', 'Acosta', '2012-05-05', 'Rondeau 55', 'Córdoba', '5000', '3511111119', 'tomas.acosta@mail.com', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(54, '47000010', 'Valentino', 'Medina', '2012-09-19', 'Chacabuco 890', 'Córdoba', '5000', '3511111120', 'valentino.medina@mail.com', '2025-12-19 13:16:07', '2025-12-19 13:16:07'),
(55, '47000011', 'Gonzalo', 'Perez', '2011-03-14', 'Belgrano 400', 'Córdoba', '5000', '3511111121', 'gonzalo.perez@mail.com', '2025-12-19 13:17:13', '2025-12-19 13:17:13'),
(56, '47000012', 'Micaela', 'Diaz', '2011-06-20', 'Lima 150', 'Córdoba', '5000', '3511111122', 'micaela.diaz@mail.com', '2025-12-19 13:17:13', '2025-12-19 13:17:13'),
(57, '47000013', 'Facundo', 'Soria', '2011-09-02', 'Colon 3300', 'Córdoba', '5000', '3511111123', 'facundo.soria@mail.com', '2025-12-19 13:17:13', '2025-12-19 13:17:13'),
(58, '47000014', 'Candela', 'Romero', '2011-11-15', 'Santa Fe 800', 'Córdoba', '5000', '3511111124', 'candela.romero@mail.com', '2025-12-19 13:17:14', '2025-12-19 13:17:14'),
(59, '47000015', 'Lautaro', 'Cabrera', '2011-01-25', '27 de Abril 600', 'Córdoba', '5000', '3511111125', 'lautaro.cabrera@mail.com', '2025-12-19 13:17:14', '2025-12-19 13:17:14'),
(60, '47000016', 'Thiago', 'Ruiz', '2011-02-10', 'San Martin 500', 'Córdoba', '5000', '3511111126', 'thiago.ruiz@mail.com', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(61, '47000017', 'Florencia', 'Sosa', '2011-04-22', 'Independencia 700', 'Córdoba', '5000', '3511111127', 'florencia.sosa@mail.com', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(62, '47000018', 'Bruno', 'Castro', '2011-08-05', 'Estrada 120', 'Córdoba', '5000', '3511111128', 'bruno.castro@mail.com', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(63, '47000019', 'Agustina', 'Silva', '2011-12-12', 'Pueyrredon 880', 'Córdoba', '5000', '3511111129', 'agustina.silva@mail.com', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(64, '47000020', 'Ramiro', 'Villalba', '2011-07-30', 'Obispo Trejo 200', 'Córdoba', '5000', '3511111130', 'ramiro.villalba@mail.com', '2025-12-19 13:18:03', '2025-12-19 13:18:03'),
(65, '47000021', 'Joaquin', 'Vargas', '2010-03-05', 'Av. Fuerza Aerea 1200', 'Córdoba', '5000', '3511111131', 'joaquin.vargas@mail.com', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(66, '47000022', 'Abril', 'Mendez', '2010-06-18', 'Rio Negro 450', 'Córdoba', '5000', '3511111132', 'abril.mendez@mail.com', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(67, '47000023', 'Emiliano', 'Guzman', '2010-09-23', 'Caseros 800', 'Córdoba', '5000', '3511111133', 'emiliano.guzman@mail.com', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(68, '47000024', 'Delfina', 'Paz', '2010-11-02', 'Duarte Quiros 1500', 'Córdoba', '5000', '3511111134', 'delfina.paz@mail.com', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(69, '47000025', 'Santiago', 'Vega', '2010-01-15', 'Santa Rosa 300', 'Córdoba', '5000', '3511111135', 'santiago.vega@mail.com', '2025-12-19 13:19:47', '2025-12-19 13:19:47'),
(70, '47000026', 'Julieta', 'Luna', '2010-02-14', 'Dean Funes 900', 'Córdoba', '5000', '3511111136', 'julieta.luna@mail.com', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(71, '47000027', 'Federico', 'Rios', '2010-05-22', 'San Jeronimo 400', 'Córdoba', '5000', '3511111137', 'federico.rios@mail.com', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(72, '47000028', 'Victoria', 'Molina', '2010-08-08', '25 de Mayo 1100', 'Córdoba', '5000', '3511111138', 'victoria.molina@mail.com', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(73, '47000029', 'Manuel', 'Ortiz', '2010-10-30', 'Alvear 350', 'Córdoba', '5000', '3511111139', 'manuel.ortiz@mail.com', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(74, '47000030', 'Catalina', 'Bravo', '2010-12-05', 'Rivadavia 700', 'Córdoba', '5000', '3511111140', 'catalina.bravo@mail.com', '2025-12-19 13:20:25', '2025-12-19 13:20:25'),
(75, '47000031', 'Camila', 'Toledo', '2009-03-12', '9 de Julio 850', 'Córdoba', '5000', '3511111141', 'camila.toledo@mail.com', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(76, '47000032', 'Lucas', 'Navarro', '2009-07-24', 'San Luis 400', 'Córdoba', '5000', '3511111142', 'lucas.navarro@mail.com', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(77, '47000033', 'Sofia', 'Ibarra', '2009-09-15', 'Entre Rios 200', 'Córdoba', '5000', '3511111143', 'sofia.ibarra@mail.com', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(78, '47000034', 'Matias', 'Coria', '2009-01-05', 'Buenos Aires 600', 'Córdoba', '5000', '3511111144', 'matias.coria@mail.com', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(79, '47000035', 'Valentina', 'Ponce', '2009-11-20', 'Corrientes 300', 'Córdoba', '5000', '3511111145', 'valentina.ponce@mail.com', '2025-12-19 13:23:35', '2025-12-19 13:23:35'),
(80, '47000036', 'Ignacio', 'Ferreira', '2009-02-18', '27 de Abril 900', 'Córdoba', '5000', '3511111146', 'ignacio.ferreira@mail.com', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(81, '47000037', 'Delfina', 'Aguilar', '2009-04-30', 'Colon 4500', 'Córdoba', '5000', '3511111147', 'delfina.aguilar@mail.com', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(82, '47000038', 'Bautista', 'Paredes', '2009-06-12', 'General Paz 300', 'Córdoba', '5000', '3511111148', 'bautista.paredes@mail.com', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(83, '47000039', 'Morena', 'Suarez', '2009-08-25', 'Velez Sarsfield 1200', 'Córdoba', '5000', '3511111149', 'morena.suarez@mail.com', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(84, '47000040', 'Simon', 'Miranda', '2009-10-08', 'Chacabuco 500', 'Córdoba', '5000', '3511111150', 'simon.miranda@mail.com', '2025-12-19 13:24:06', '2025-12-19 13:24:06'),
(85, '47000041', 'Milagros', 'Ferrer', '2008-03-25', 'Av. Colon 2300', 'Córdoba', '5000', '3511111151', 'milagros.ferrer@mail.com', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(86, '47000042', 'Esteban', 'Videla', '2008-06-14', '9 de Julio 150', 'Córdoba', '5000', '3511111152', 'esteban.videla@mail.com', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(87, '47000043', 'Luciana', 'Gallo', '2008-09-02', 'Santa Fe 1100', 'Córdoba', '5000', '3511111153', 'luciana.gallo@mail.com', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(88, '47000044', 'Franco', 'Bustos', '2008-12-10', 'Lima 800', 'Córdoba', '5000', '3511111154', 'franco.bustos@mail.com', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(89, '47000045', 'Malena', 'Peralta', '2008-01-20', 'Rioja 400', 'Córdoba', '5000', '3511111155', 'malena.peralta@mail.com', '2025-12-19 13:25:35', '2025-12-19 13:25:35'),
(90, '47000046', 'Lautaro', 'Nuñez', '2008-02-14', 'San Martin 2800', 'Córdoba', '5000', '3511111156', 'lautaro.nunez@mail.com', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(91, '47000047', 'Valentina', 'Flores', '2008-05-22', 'Independencia 1300', 'Córdoba', '5000', '3511111157', 'valentina.flores@mail.com', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(92, '47000048', 'Tomas', 'Ledesma', '2008-08-30', 'Chacabuco 900', 'Córdoba', '5000', '3511111158', 'tomas.ledesma@mail.com', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(93, '47000049', 'Candela', 'Ojeda', '2008-10-12', 'Maipú 200', 'Córdoba', '5000', '3511111159', 'candela.ojeda@mail.com', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(94, '47000050', 'Maximo', 'Guerrero', '2008-12-05', 'Colon 3100', 'Córdoba', '5000', '3511111160', 'maximo.guerrero@mail.com', '2025-12-19 13:26:14', '2025-12-19 13:26:14'),
(95, '47000051', 'Francisco', 'Vega', '2007-03-10', 'San Jeronimo 1200', 'Córdoba', '5000', '3511111161', 'francisco.vega@mail.com', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(96, '47000052', 'Abril', 'Correa', '2007-06-25', 'Rondeau 400', 'Córdoba', '5000', '3511111162', 'abril.correa@mail.com', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(97, '47000053', 'Santino', 'Moyano', '2007-09-14', 'Illia 600', 'Córdoba', '5000', '3511111163', 'santino.moyano@mail.com', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(98, '47000054', 'Guadalupe', 'Arce', '2007-12-02', 'Velez Sarsfield 800', 'Córdoba', '5000', '3511111164', 'guadalupe.arce@mail.com', '2025-12-19 13:26:59', '2025-12-19 13:26:59'),
(99, '47000055', 'Mateo', 'Quiroga', '2007-01-30', 'Chacabuco 200', 'Córdoba', '5000', '3511111165', 'mateo.quiroga@mail.com', '2025-12-19 13:26:59', '2025-12-19 13:26:59');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `preceptor_grado`
--

CREATE TABLE `preceptor_grado` (
  `id` int(11) NOT NULL,
  `preceptor_usuario_id` int(11) NOT NULL COMMENT 'FK to usuarios.id where rol_id is for preceptor',
  `grado_id` int(11) NOT NULL COMMENT 'FK to grados.id',
  `anio_lectivo` year(4) NOT NULL DEFAULT year(curdate()),
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `preceptor_grado`
--

INSERT INTO `preceptor_grado` (`id`, `preceptor_usuario_id`, `grado_id`, `anio_lectivo`, `creado_en`) VALUES
(54, 22, 12, '2025', '2025-12-19 05:49:36');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `pregunta_opciones`
--

CREATE TABLE `pregunta_opciones` (
  `id` int(11) NOT NULL,
  `pregunta_id` int(11) NOT NULL,
  `texto_opcion` text NOT NULL,
  `es_correcta` tinyint(1) NOT NULL DEFAULT 0 COMMENT '1 si es la respuesta correcta, 0 si no'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `pregunta_opciones`
--

INSERT INTO `pregunta_opciones` (`id`, `pregunta_id`, `texto_opcion`, `es_correcta`) VALUES
(107, 33, 'Hola', 1),
(108, 33, 'Hola r', 0);

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesores`
--

CREATE TABLE `profesores` (
  `id` int(11) NOT NULL,
  `usuario_id` int(11) NOT NULL,
  `persona_fisica_id` int(11) NOT NULL,
  `titulo` varchar(100) DEFAULT NULL,
  `fecha_ingreso` date DEFAULT NULL,
  `activo` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = activo, 0 = inactivo',
  `observaciones` text DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `profesores`
--

INSERT INTO `profesores` (`id`, `usuario_id`, `persona_fisica_id`, `titulo`, `fecha_ingreso`, `activo`, `observaciones`, `creado_en`, `actualizado_en`) VALUES
(3, 21, 32, 'Profesorado Universitario En Educación Física', '2025-12-19', 1, '', '2025-12-19 05:45:17', '2025-12-19 13:30:58');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesor_especialidad`
--

CREATE TABLE `profesor_especialidad` (
  `id` int(11) NOT NULL,
  `profesor_id` int(11) NOT NULL,
  `especialidad_id` int(11) NOT NULL,
  `es_principal` tinyint(1) DEFAULT 0 COMMENT '1 = especialidad principal, 0 = secundaria',
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `profesor_especialidad`
--

INSERT INTO `profesor_especialidad` (`id`, `profesor_id`, `especialidad_id`, `es_principal`, `creado_en`, `actualizado_en`) VALUES
(5, 3, 10, 1, '2025-12-19 13:30:58', '2025-12-19 13:30:58'),
(6, 3, 1, 0, '2025-12-19 13:30:58', '2025-12-19 13:30:58');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesor_materia`
--

CREATE TABLE `profesor_materia` (
  `id` int(11) NOT NULL,
  `profesor_id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `profesor_materia`
--

INSERT INTO `profesor_materia` (`id`, `profesor_id`, `materia_id`, `creado_en`) VALUES
(6, 3, 2, '2025-12-19 16:02:02'),
(7, 3, 67, '2025-12-19 16:02:02'),
(8, 3, 51, '2025-12-19 16:02:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `profesor_materia_grado`
--

CREATE TABLE `profesor_materia_grado` (
  `id` int(11) NOT NULL,
  `profesor_id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `grado_id` int(11) NOT NULL,
  `anio_lectivo` year(4) NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `profesor_materia_grado`
--

INSERT INTO `profesor_materia_grado` (`id`, `profesor_id`, `materia_id`, `grado_id`, `anio_lectivo`, `creado_en`, `actualizado_en`) VALUES
(6, 3, 2, 2, '2025', '2025-12-19 16:02:02', '2025-12-19 16:02:02'),
(7, 3, 67, 12, '2025', '2025-12-19 16:02:02', '2025-12-19 16:02:02'),
(8, 3, 51, 12, '2025', '2025-12-19 16:02:02', '2025-12-19 16:02:02');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `roles`
--

CREATE TABLE `roles` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL,
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `roles`
--

INSERT INTO `roles` (`id`, `nombre`, `descripcion`, `creado_en`, `actualizado_en`) VALUES
(1, 'admin', 'Administrador del sistema', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(2, 'alumno', 'Estudiante', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(3, 'profesor', 'Docente', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(4, 'preceptor', 'Preceptor', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(5, 'secretaria', 'Personal administrativo', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(6, 'tutor', 'Padre/Madre o responsable del alumno que puede ver información académica', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(7, 'director', 'Director de la institución, acceso a reportes y vistas generales', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(8, 'tesoreria', 'Personal de tesorería, encargado de gestionar pagos y cuotas', '2025-08-23 03:01:04', '2025-08-23 03:01:04');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `sanciones`
--

CREATE TABLE `sanciones` (
  `id` int(11) NOT NULL,
  `alumno_id` int(11) NOT NULL,
  `tipo` enum('Amonestación','Suspensión','Observación','Otro') NOT NULL,
  `fecha` date NOT NULL,
  `descripcion` text NOT NULL,
  `medidas` text DEFAULT NULL COMMENT 'Medidas tomadas',
  `fecha_resolucion` date DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tarea_entregas`
--

CREATE TABLE `tarea_entregas` (
  `id` int(11) NOT NULL,
  `contenido_id` int(11) NOT NULL COMMENT 'FK a materia_contenido donde tipo=Tarea',
  `alumno_id` int(11) NOT NULL,
  `ruta_archivo` text DEFAULT NULL,
  `comentario_alumno` text DEFAULT NULL,
  `fecha_entrega` timestamp NOT NULL DEFAULT current_timestamp(),
  `calificacion` decimal(4,2) DEFAULT NULL,
  `comentario_profesor` text DEFAULT NULL,
  `fecha_calificacion` datetime DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `temas_evaluacion`
--

CREATE TABLE `temas_evaluacion` (
  `id` int(11) NOT NULL,
  `materia_id` int(11) NOT NULL,
  `profesor_id` int(11) NOT NULL,
  `grado_id` int(11) NOT NULL,
  `evaluacion_id` tinyint(2) NOT NULL,
  `anio_lectivo` year(4) NOT NULL,
  `tipo_evaluacion_id` int(11) NOT NULL,
  `nombre_tema` varchar(255) NOT NULL,
  `descripcion` text DEFAULT NULL,
  `fecha_establecida` date NOT NULL,
  `fecha_evaluacion` date NOT NULL COMMENT 'Fecha en la que se realizará la evaluación',
  `fecha_inicio` date NOT NULL,
  `fecha_fin` date NOT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `temas_evaluacion`
--

INSERT INTO `temas_evaluacion` (`id`, `materia_id`, `profesor_id`, `grado_id`, `evaluacion_id`, `anio_lectivo`, `tipo_evaluacion_id`, `nombre_tema`, `descripcion`, `fecha_establecida`, `fecha_evaluacion`, `fecha_inicio`, `fecha_fin`, `creado_en`, `actualizado_en`) VALUES
(2, 51, 3, 12, 1, '2025', 1, 'Números Reales y Complejos', 'Evaluación sobre unidad 1', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(3, 51, 3, 12, 2, '2025', 1, 'Funciones Polinómicas', 'Evaluación sobre unidad 2', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(4, 51, 3, 12, 3, '2025', 1, 'Límites y Continuidad', 'Evaluación sobre unidad 3', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(5, 51, 3, 12, 4, '2025', 1, 'Derivadas', 'Evaluación sobre unidad 4', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(6, 51, 3, 12, 5, '2025', 1, 'Integrales', 'Evaluación sobre unidad 5', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(7, 51, 3, 12, 6, '2025', 1, 'Probabilidad y Estadística', 'Evaluación sobre unidad 6', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(8, 51, 3, 12, 7, '2025', 1, 'Geometría Analítica', 'Evaluación sobre unidad 7', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(9, 51, 3, 12, 8, '2025', 1, 'Trabajo Final Integrador', 'Evaluación final', '2025-12-19', '2025-12-19', '2025-12-19', '2025-12-26', '2025-12-19 16:18:56', '2025-12-19 16:18:56'),
(10, 52, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(11, 52, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(12, 52, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(13, 52, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(14, 52, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(15, 52, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(16, 52, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(17, 52, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Carga automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:26:40', '2025-12-19 16:26:40'),
(18, 53, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(19, 53, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(20, 53, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(21, 53, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(22, 53, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(23, 53, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(24, 53, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(25, 53, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:29:14', '2025-12-19 16:29:14'),
(26, 54, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(27, 54, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(28, 54, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(29, 54, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(30, 54, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(31, 54, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(32, 54, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(33, 54, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:05', '2025-12-19 16:33:05'),
(34, 55, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(35, 55, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(36, 55, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(37, 55, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(38, 55, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(39, 55, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(40, 55, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(41, 55, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:35', '2025-12-19 16:33:35'),
(42, 56, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(43, 56, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(44, 56, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(45, 56, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(46, 56, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(47, 56, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(48, 56, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(49, 56, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:33:51', '2025-12-19 16:33:51'),
(50, 57, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(51, 57, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(52, 57, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(53, 57, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(54, 57, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(55, 57, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(56, 57, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(57, 57, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:07', '2025-12-19 16:34:07'),
(58, 58, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(59, 58, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(60, 58, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(61, 58, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(62, 58, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(63, 58, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(64, 58, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(65, 58, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:11', '2025-12-19 16:34:11'),
(66, 59, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(67, 59, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(68, 59, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(69, 59, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(70, 59, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(71, 59, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(72, 59, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(73, 59, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:13', '2025-12-19 16:34:13'),
(74, 66, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(75, 66, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(76, 66, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(77, 66, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(78, 66, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(79, 66, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(80, 66, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(81, 66, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:28', '2025-12-19 16:34:28'),
(82, 67, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(83, 67, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(84, 67, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(85, 67, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(86, 67, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(87, 67, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(88, 67, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(89, 67, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:31', '2025-12-19 16:34:31'),
(90, 68, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(91, 68, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(92, 68, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(93, 68, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(94, 68, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(95, 68, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(96, 68, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(97, 68, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:47', '2025-12-19 16:34:47'),
(98, 69, 3, 12, 1, '2025', 1, 'Evaluación N° 1', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(99, 69, 3, 12, 2, '2025', 1, 'Evaluación N° 2', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(100, 69, 3, 12, 3, '2025', 1, 'Evaluación N° 3', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(101, 69, 3, 12, 4, '2025', 1, 'Evaluación N° 4', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(102, 69, 3, 12, 5, '2025', 1, 'Evaluación N° 5', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(103, 69, 3, 12, 6, '2025', 1, 'Evaluación N° 6', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(104, 69, 3, 12, 7, '2025', 1, 'Evaluación N° 7', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52'),
(105, 69, 3, 12, 8, '2025', 1, 'Evaluación N° 8', 'Automática', '2025-12-19', '2025-12-19', '2025-12-19', '2026-01-18', '2025-12-19 16:34:52', '2025-12-19 16:34:52');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `tipos_evaluacion`
--

CREATE TABLE `tipos_evaluacion` (
  `id` int(11) NOT NULL,
  `nombre` varchar(100) NOT NULL COMMENT 'Ej: Parcial 1, Trabajo Práctico, Examen Final',
  `descripcion` varchar(255) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `tipos_evaluacion`
--

INSERT INTO `tipos_evaluacion` (`id`, `nombre`, `descripcion`, `creado_en`) VALUES
(1, 'Evaluación escrita', 'Evaluación escrita del tema establecido', '2025-08-10 04:34:19'),
(2, 'Trabajo Práctico', 'Evaluación de trabajo práctico individual o grupal', '2025-08-10 04:34:19'),
(3, 'Exposición Oral', 'Evaluación de presentación oral', '2025-08-10 04:34:19'),
(4, 'Primer recuperatorio', 'Recuperatorio escrito de un tema', '2025-08-10 04:34:19'),
(5, 'Segundo recuperatorio', 'Recuperatorio escrito de un tema', '2025-08-10 04:34:19'),
(6, 'Examen Final', 'Evaluación final integradora de la materia', '2025-08-10 04:34:19');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `turnos`
--

CREATE TABLE `turnos` (
  `id` int(11) NOT NULL,
  `nombre` varchar(50) NOT NULL COMMENT 'Mañana o Tarde',
  `hora_inicio` time DEFAULT NULL,
  `hora_fin` time DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `turnos`
--

INSERT INTO `turnos` (`id`, `nombre`, `hora_inicio`, `hora_fin`, `creado_en`, `actualizado_en`) VALUES
(1, 'Mañana', '08:00:00', '12:00:00', '2025-08-10 04:34:18', '2025-08-10 04:34:18'),
(2, 'Tarde', '13:00:00', '17:00:00', '2025-08-10 04:34:18', '2025-08-10 04:34:18');

-- --------------------------------------------------------

--
-- Estructura de tabla para la tabla `usuarios`
--

CREATE TABLE `usuarios` (
  `id` int(11) NOT NULL,
  `usuario` varchar(20) NOT NULL COMMENT 'DNI de la persona',
  `password` varchar(255) NOT NULL,
  `rol_id` int(11) NOT NULL,
  `persona_fisica_id` int(11) DEFAULT NULL,
  `creado_en` timestamp NOT NULL DEFAULT current_timestamp(),
  `actualizado_en` timestamp NOT NULL DEFAULT current_timestamp() ON UPDATE current_timestamp(),
  `primer_login` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = primer login, 0 = no es primer login',
  `password_temporal` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = contraseña temporal, 0 = contraseña permanente',
  `activo` tinyint(1) NOT NULL DEFAULT 1 COMMENT '1 = cuenta activa, 0 = cuenta inactiva',
  `ultimo_acceso` datetime DEFAULT NULL COMMENT 'Fecha y hora del último acceso',
  `token_recuperacion` varchar(64) DEFAULT NULL COMMENT 'Token para recuperación de contraseña',
  `token_expiracion` datetime DEFAULT NULL COMMENT 'Fecha de expiración del token'
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;

--
-- Volcado de datos para la tabla `usuarios`
--

INSERT INTO `usuarios` (`id`, `usuario`, `password`, `rol_id`, `persona_fisica_id`, `creado_en`, `actualizado_en`, `primer_login`, `password_temporal`, `activo`, `ultimo_acceso`, `token_recuperacion`, `token_expiracion`) VALUES
(8, '45690437', '$2y$10$8LQY7aVBPBbswPyowoUduuddkmt97rkaj5yRW1gYyqKDyx2.ztwOe', 1, 19, '2025-12-19 05:32:06', '2025-12-19 05:33:38', 0, 0, 1, NULL, 'b4a013788ea2507fe6fb7c0149cbc82700aba7c62f5563c1bf2c4ff8238306f7', '2025-12-19 06:33:09'),
(9, '48100002', '$2y$10$i7e6BrYcsu1xyt.znJrOe.0o3JTtmq4pqGEWePMm0YnHzKb38Xwmu', 2, 20, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(10, '48100004', '$2y$10$wKAYN.Arox8A/2lx8PJTHubDlUHit.L7gT2cJLRfX7gob.Ut6WkXO', 2, 21, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(11, '48100006', '$2y$10$HWSUtASujynPyeVCiFOE2umZ67yW3e.prQRH3gVxRZ.VOUZbtrFUW', 2, 22, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(12, '48100009', '$2y$10$H607fRYP4MFzKXOxIfHLBuGciOabPsNl.aQQYq8yxJVhh0rzH1WrC', 2, 23, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(13, '48100010', '$2y$10$7CIw5haN0tXQx39vyQCbVunI7kIRm3ONnav1iuvBJ7YTNOcGbMtXC', 2, 24, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(14, '48100011', '$2y$10$es41gKxwB12c.t60ZqleQu1NIx.hXNIotSnpkqc3w3tTJEuieRkye', 2, 25, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(15, '48100012', '$2y$10$uiqBNz1QRQfYNR54rIY.V.HUpWms.NbdNt5Fdw5N6fq/n3tmNsCiO', 2, 26, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(16, '48100013', '$2y$10$SK2N4cJ0tquVQVvRvjfS7eeqmqlgpF3J.z.8EUTFUxcX3VdZB31Nm', 2, 27, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(17, '48100015', '$2y$10$Vrc2FpUjZot4d.U435hkF.SbvWO.Z7VN1UM4Om7pVBTsO.OCTB2QO', 2, 28, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(18, '48100016', '$2y$10$PVc3c2zEn4fFxSPHHZhUOeUP8TAlk2y1aOA1oJ5InS5ZuJXkiIwmi', 2, 29, '2025-12-19 05:40:04', '2025-12-19 05:40:04', 1, 1, 1, NULL, NULL, NULL),
(19, '48100017', '$2y$10$q8jso7fzRHYLAk74lASVeOhvG0kr8slbXoJF3/TpdZ9DQirncQClC', 2, 30, '2025-12-19 05:40:04', '2025-12-19 05:58:17', 0, 0, 1, NULL, NULL, NULL),
(20, '45246672', '$2y$10$HkmhzQHqjaiMPATiZBuwVupjuPRzhYWR2f82JyVRNkAJgxhSfLrYK', 2, 31, '2025-12-19 05:42:34', '2025-12-19 05:42:34', 1, 1, 1, NULL, NULL, NULL),
(21, '20000000', '$2y$10$OUCexKfx1kIj/lo.YSSHOe1QKALhHlH3KCvw99Cv22MUDlH6e71AK', 3, 32, '2025-12-19 05:45:17', '2025-12-19 05:59:27', 0, 0, 1, NULL, NULL, NULL),
(22, '43353536', '$2y$10$tLyZvGhrYCOhRkp8Ibu9weUNgRa2uiK.tK1pTdqnJDnWIwD5PTgZ6', 4, 33, '2025-12-19 05:49:09', '2025-12-19 06:10:38', 0, 0, 1, NULL, NULL, NULL),
(23, '45542382', '$2y$10$Rb.9qsurttXGGyOwN2mJ3.K8cyiM/5awTNsw8myIQBvDxp4LTrIz.', 6, 34, '2025-12-19 05:50:55', '2025-12-19 05:50:55', 0, 0, 1, NULL, NULL, NULL),
(25, '34156134', '$2y$10$pci9kpJBtrK1nA15Woll8.00sGf./zf7ckydBOwJl7cED9ho8R/1G', 7, 36, '2025-12-19 05:53:33', '2025-12-19 06:10:48', 0, 0, 1, NULL, NULL, NULL),
(26, '45161346', '$2y$10$ua7ASpO.WUYOWzn1C.fB5OkwMsPHVhMSMsk3ppOgLyC7zLbaQv8V.', 8, 37, '2025-12-19 05:54:02', '2025-12-19 06:10:58', 0, 0, 1, NULL, NULL, NULL),
(30, '48100008', '$2y$10$1w4CAeTvQo9/sZ.ptgJLvuq2ipn/62K5w3YAKOHgZuE1VWmI.ZtCW', 2, 39, '2025-12-19 06:09:39', '2025-12-19 06:10:10', 0, 0, 1, NULL, NULL, NULL),
(36, '47000001', '', 2, 45, '2025-12-19 13:15:15', '2025-12-19 13:15:15', 1, 1, 1, NULL, NULL, NULL),
(37, '47000002', '', 2, 46, '2025-12-19 13:15:15', '2025-12-19 13:15:15', 1, 1, 1, NULL, NULL, NULL),
(38, '47000003', '', 2, 47, '2025-12-19 13:15:15', '2025-12-19 13:15:15', 1, 1, 1, NULL, NULL, NULL),
(39, '47000004', '', 2, 48, '2025-12-19 13:15:15', '2025-12-19 13:15:15', 1, 1, 1, NULL, NULL, NULL),
(40, '47000005', '', 2, 49, '2025-12-19 13:15:15', '2025-12-19 13:15:15', 1, 1, 1, NULL, NULL, NULL),
(41, '47000006', '', 2, 50, '2025-12-19 13:16:07', '2025-12-19 13:16:07', 1, 1, 1, NULL, NULL, NULL),
(42, '47000007', '', 2, 51, '2025-12-19 13:16:07', '2025-12-19 13:16:07', 1, 1, 1, NULL, NULL, NULL),
(43, '47000008', '', 2, 52, '2025-12-19 13:16:07', '2025-12-19 13:16:07', 1, 1, 1, NULL, NULL, NULL),
(44, '47000009', '', 2, 53, '2025-12-19 13:16:07', '2025-12-19 13:16:07', 1, 1, 1, NULL, NULL, NULL),
(45, '47000010', '', 2, 54, '2025-12-19 13:16:07', '2025-12-19 13:16:07', 1, 1, 1, NULL, NULL, NULL),
(46, '47000011', '', 2, 55, '2025-12-19 13:17:13', '2025-12-19 13:17:13', 1, 1, 1, NULL, NULL, NULL),
(47, '47000012', '', 2, 56, '2025-12-19 13:17:13', '2025-12-19 13:17:13', 1, 1, 1, NULL, NULL, NULL),
(48, '47000013', '', 2, 57, '2025-12-19 13:17:13', '2025-12-19 13:17:13', 1, 1, 1, NULL, NULL, NULL),
(49, '47000014', '', 2, 58, '2025-12-19 13:17:13', '2025-12-19 13:17:14', 1, 1, 1, NULL, NULL, NULL),
(50, '47000015', '', 2, 59, '2025-12-19 13:17:14', '2025-12-19 13:17:14', 1, 1, 1, NULL, NULL, NULL),
(51, '47000016', '', 2, 60, '2025-12-19 13:18:03', '2025-12-19 13:18:03', 1, 1, 1, NULL, NULL, NULL),
(52, '47000017', '', 2, 61, '2025-12-19 13:18:03', '2025-12-19 13:18:03', 1, 1, 1, NULL, NULL, NULL),
(53, '47000018', '', 2, 62, '2025-12-19 13:18:03', '2025-12-19 13:18:03', 1, 1, 1, NULL, NULL, NULL),
(54, '47000019', '', 2, 63, '2025-12-19 13:18:03', '2025-12-19 13:18:03', 1, 1, 1, NULL, NULL, NULL),
(55, '47000020', '', 2, 64, '2025-12-19 13:18:03', '2025-12-19 13:18:03', 1, 1, 1, NULL, NULL, NULL),
(56, '47000021', '', 2, 65, '2025-12-19 13:19:47', '2025-12-19 13:19:47', 1, 1, 1, NULL, NULL, NULL),
(57, '47000022', '', 2, 66, '2025-12-19 13:19:47', '2025-12-19 13:19:47', 1, 1, 1, NULL, NULL, NULL),
(58, '47000023', '', 2, 67, '2025-12-19 13:19:47', '2025-12-19 13:19:47', 1, 1, 1, NULL, NULL, NULL),
(59, '47000024', '', 2, 68, '2025-12-19 13:19:47', '2025-12-19 13:19:47', 1, 1, 1, NULL, NULL, NULL),
(60, '47000025', '', 2, 69, '2025-12-19 13:19:47', '2025-12-19 13:19:47', 1, 1, 1, NULL, NULL, NULL),
(61, '47000026', '', 2, 70, '2025-12-19 13:20:25', '2025-12-19 13:20:25', 1, 1, 1, NULL, NULL, NULL),
(62, '47000027', '', 2, 71, '2025-12-19 13:20:25', '2025-12-19 13:20:25', 1, 1, 1, NULL, NULL, NULL),
(63, '47000028', '', 2, 72, '2025-12-19 13:20:25', '2025-12-19 13:20:25', 1, 1, 1, NULL, NULL, NULL),
(64, '47000029', '', 2, 73, '2025-12-19 13:20:25', '2025-12-19 13:20:25', 1, 1, 1, NULL, NULL, NULL),
(65, '47000030', '', 2, 74, '2025-12-19 13:20:25', '2025-12-19 13:20:25', 1, 1, 1, NULL, NULL, NULL),
(66, '47000031', '', 2, 75, '2025-12-19 13:23:35', '2025-12-19 13:23:35', 1, 1, 1, NULL, NULL, NULL),
(67, '47000032', '', 2, 76, '2025-12-19 13:23:35', '2025-12-19 13:23:35', 1, 1, 1, NULL, NULL, NULL),
(68, '47000033', '', 2, 77, '2025-12-19 13:23:35', '2025-12-19 13:23:35', 1, 1, 1, NULL, NULL, NULL),
(69, '47000034', '', 2, 78, '2025-12-19 13:23:35', '2025-12-19 13:23:35', 1, 1, 1, NULL, NULL, NULL),
(70, '47000035', '', 2, 79, '2025-12-19 13:23:35', '2025-12-19 13:23:35', 1, 1, 1, NULL, NULL, NULL),
(71, '47000036', '', 2, 80, '2025-12-19 13:24:06', '2025-12-19 13:24:06', 1, 1, 1, NULL, NULL, NULL),
(72, '47000037', '', 2, 81, '2025-12-19 13:24:06', '2025-12-19 13:24:06', 1, 1, 1, NULL, NULL, NULL),
(73, '47000038', '', 2, 82, '2025-12-19 13:24:06', '2025-12-19 13:24:06', 1, 1, 1, NULL, NULL, NULL),
(74, '47000039', '', 2, 83, '2025-12-19 13:24:06', '2025-12-19 13:24:06', 1, 1, 1, NULL, NULL, NULL),
(75, '47000040', '', 2, 84, '2025-12-19 13:24:06', '2025-12-19 13:24:06', 1, 1, 1, NULL, NULL, NULL),
(76, '47000041', '', 2, 85, '2025-12-19 13:25:35', '2025-12-19 13:25:35', 1, 1, 1, NULL, NULL, NULL),
(77, '47000042', '', 2, 86, '2025-12-19 13:25:35', '2025-12-19 13:25:35', 1, 1, 1, NULL, NULL, NULL),
(78, '47000043', '', 2, 87, '2025-12-19 13:25:35', '2025-12-19 13:25:35', 1, 1, 1, NULL, NULL, NULL),
(79, '47000044', '', 2, 88, '2025-12-19 13:25:35', '2025-12-19 13:25:35', 1, 1, 1, NULL, NULL, NULL),
(80, '47000045', '', 2, 89, '2025-12-19 13:25:35', '2025-12-19 13:25:35', 1, 1, 1, NULL, NULL, NULL),
(81, '47000046', '', 2, 90, '2025-12-19 13:26:14', '2025-12-19 13:26:14', 1, 1, 1, NULL, NULL, NULL),
(82, '47000047', '', 2, 91, '2025-12-19 13:26:14', '2025-12-19 13:26:14', 1, 1, 1, NULL, NULL, NULL),
(83, '47000048', '', 2, 92, '2025-12-19 13:26:14', '2025-12-19 13:26:14', 1, 1, 1, NULL, NULL, NULL),
(84, '47000049', '', 2, 93, '2025-12-19 13:26:14', '2025-12-19 13:26:14', 1, 1, 1, NULL, NULL, NULL),
(85, '47000050', '', 2, 94, '2025-12-19 13:26:14', '2025-12-19 13:26:14', 1, 1, 1, NULL, NULL, NULL),
(86, '47000051', '', 2, 95, '2025-12-19 13:26:59', '2025-12-19 13:26:59', 1, 1, 1, NULL, NULL, NULL),
(87, '47000052', '', 2, 96, '2025-12-19 13:26:59', '2025-12-19 13:26:59', 1, 1, 1, NULL, NULL, NULL),
(88, '47000053', '', 2, 97, '2025-12-19 13:26:59', '2025-12-19 13:26:59', 1, 1, 1, NULL, NULL, NULL),
(89, '47000054', '', 2, 98, '2025-12-19 13:26:59', '2025-12-19 13:26:59', 1, 1, 1, NULL, NULL, NULL),
(90, '47000055', '', 2, 99, '2025-12-19 13:26:59', '2025-12-19 13:26:59', 1, 1, 1, NULL, NULL, NULL);

-- --------------------------------------------------------

--
-- Estructura Stand-in para la vista `vista_materias_por_grado`
-- (Véase abajo para la vista actual)
--
CREATE TABLE `vista_materias_por_grado` (
`grado_id` int(11)
,`grado` varchar(50)
,`tipo_ciclo` enum('Básico','Orientado Economía','Orientado Turismo')
,`division` varchar(10)
,`turno` varchar(50)
,`materia_id` int(11)
,`materia` varchar(100)
,`descripcion` varchar(255)
,`horas_semanales` int(11)
,`especialidad` enum('Economía','Turismo','Común')
,`es_especialidad` varchar(2)
,`estado` varchar(8)
);

--
-- Índices para tablas volcadas
--

--
-- Indices de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `persona_fisica_id` (`persona_fisica_id`),
  ADD KEY `grado_id` (`grado_id`);

--
-- Indices de la tabla `alumno_respuestas`
--
ALTER TABLE `alumno_respuestas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `respuesta_opcion_unica` (`formulario_id`,`alumno_id`,`pregunta_id`,`opcion_seleccionada_id`),
  ADD KEY `alumno_id` (`alumno_id`),
  ADD KEY `pregunta_id` (`pregunta_id`),
  ADD KEY `opcion_seleccionada_id` (`opcion_seleccionada_id`);

--
-- Indices de la tabla `alumno_tutor`
--
ALTER TABLE `alumno_tutor`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alumno_id` (`alumno_id`),
  ADD KEY `tutor_id` (`tutor_id`);

--
-- Indices de la tabla `asistencias`
--
ALTER TABLE `asistencias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alumno_id` (`alumno_id`),
  ADD KEY `registrado_por` (`registrado_por`);

--
-- Indices de la tabla `asistencia_justificaciones`
--
ALTER TABLE `asistencia_justificaciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alumno_id` (`alumno_id`),
  ADD KEY `preceptor_usuario_id` (`preceptor_usuario_id`);

--
-- Indices de la tabla `calificaciones`
--
ALTER TABLE `calificaciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_calificacion_unica` (`alumno_id`,`tema_evaluacion_id`,`recuperatorio`),
  ADD KEY `tema_evaluacion_id` (`tema_evaluacion_id`);

--
-- Indices de la tabla `contenido_archivos`
--
ALTER TABLE `contenido_archivos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contenido_id` (`contenido_id`);

--
-- Indices de la tabla `contenido_enlaces`
--
ALTER TABLE `contenido_enlaces`
  ADD PRIMARY KEY (`id`),
  ADD KEY `contenido_id` (`contenido_id`);

--
-- Indices de la tabla `cuotas_mensuales`
--
ALTER TABLE `cuotas_mensuales`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uq_anio_mes` (`anio`,`mes`);

--
-- Indices de la tabla `divisiones`
--
ALTER TABLE `divisiones`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `egresos`
--
ALTER TABLE `egresos`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alumno_id` (`alumno_id`);

--
-- Indices de la tabla `especialidades`
--
ALTER TABLE `especialidades`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_nombre` (`nombre`);

--
-- Indices de la tabla `evaluaciones`
--
ALTER TABLE `evaluaciones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_numero_evaluacion` (`numero_evaluacion`);

--
-- Indices de la tabla `eventos`
--
ALTER TABLE `eventos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `formularios`
--
ALTER TABLE `formularios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `contenido_id_unique` (`contenido_id`),
  ADD KEY `idx_formularios_tema_evaluacion` (`tema_evaluacion_id`);

--
-- Indices de la tabla `formulario_entregas`
--
ALTER TABLE `formulario_entregas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `formulario_id` (`formulario_id`,`alumno_id`),
  ADD KEY `alumno_id` (`alumno_id`);

--
-- Indices de la tabla `formulario_preguntas`
--
ALTER TABLE `formulario_preguntas`
  ADD PRIMARY KEY (`id`),
  ADD KEY `formulario_id` (`formulario_id`);

--
-- Indices de la tabla `formulario_sesiones`
--
ALTER TABLE `formulario_sesiones`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `uk_form_alumno` (`formulario_id`,`alumno_id`),
  ADD KEY `alumno_id` (`alumno_id`);

--
-- Indices de la tabla `grados`
--
ALTER TABLE `grados`
  ADD PRIMARY KEY (`id`),
  ADD KEY `turno_id` (`turno_id`),
  ADD KEY `division_id` (`division_id`);

--
-- Indices de la tabla `horarios`
--
ALTER TABLE `horarios`
  ADD PRIMARY KEY (`id`),
  ADD KEY `profesor_materia_id` (`profesor_materia_id`),
  ADD KEY `grado_id` (`grado_id`);

--
-- Indices de la tabla `intentos_login`
--
ALTER TABLE `intentos_login`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_user` (`usuario`);

--
-- Indices de la tabla `materias`
--
ALTER TABLE `materias`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `materia_contenido`
--
ALTER TABLE `materia_contenido`
  ADD PRIMARY KEY (`id`),
  ADD KEY `materia_id` (`materia_id`),
  ADD KEY `grado_id` (`grado_id`),
  ADD KEY `profesor_id` (`profesor_id`);

--
-- Indices de la tabla `materia_grado`
--
ALTER TABLE `materia_grado`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_materia_grado` (`materia_id`,`grado_id`),
  ADD KEY `grado_id` (`grado_id`);

--
-- Indices de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  ADD PRIMARY KEY (`id`),
  ADD KEY `idx_remitente` (`remitente_usuario_id`),
  ADD KEY `idx_destinatario` (`destinatario_usuario_id`);

--
-- Indices de la tabla `monitoreo_formulario`
--
ALTER TABLE `monitoreo_formulario`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_alumno_formulario` (`alumno_id`,`formulario_id`),
  ADD KEY `formulario_id` (`formulario_id`);

--
-- Indices de la tabla `noticias`
--
ALTER TABLE `noticias`
  ADD PRIMARY KEY (`id`),
  ADD KEY `autor_usuario_id` (`autor_usuario_id`);

--
-- Indices de la tabla `noticia_visibilidad_grado`
--
ALTER TABLE `noticia_visibilidad_grado`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `visibilidad_unica` (`noticia_id`,`grado_id`),
  ADD KEY `grado_id` (`grado_id`);

--
-- Indices de la tabla `pagos_mensuales`
--
ALTER TABLE `pagos_mensuales`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `pago_unico` (`alumno_id`,`anio`,`mes`),
  ADD KEY `registrado_por_id` (`registrado_por_id`);

--
-- Indices de la tabla `personas_fisicas`
--
ALTER TABLE `personas_fisicas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `dni` (`dni`);

--
-- Indices de la tabla `preceptor_grado`
--
ALTER TABLE `preceptor_grado`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_preceptor_grado_anio` (`preceptor_usuario_id`,`grado_id`,`anio_lectivo`),
  ADD KEY `grado_id` (`grado_id`);

--
-- Indices de la tabla `pregunta_opciones`
--
ALTER TABLE `pregunta_opciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `pregunta_id` (`pregunta_id`);

--
-- Indices de la tabla `profesores`
--
ALTER TABLE `profesores`
  ADD PRIMARY KEY (`id`),
  ADD KEY `usuario_id` (`usuario_id`),
  ADD KEY `persona_fisica_id` (`persona_fisica_id`);

--
-- Indices de la tabla `profesor_especialidad`
--
ALTER TABLE `profesor_especialidad`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_profesor_especialidad` (`profesor_id`,`especialidad_id`),
  ADD KEY `especialidad_id` (`especialidad_id`);

--
-- Indices de la tabla `profesor_materia`
--
ALTER TABLE `profesor_materia`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_profesor_materia` (`profesor_id`,`materia_id`),
  ADD KEY `materia_id` (`materia_id`);

--
-- Indices de la tabla `profesor_materia_grado`
--
ALTER TABLE `profesor_materia_grado`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `unique_profesor_materia_grado_anio` (`profesor_id`,`materia_id`,`grado_id`,`anio_lectivo`),
  ADD KEY `materia_id` (`materia_id`),
  ADD KEY `grado_id` (`grado_id`);

--
-- Indices de la tabla `roles`
--
ALTER TABLE `roles`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `sanciones`
--
ALTER TABLE `sanciones`
  ADD PRIMARY KEY (`id`),
  ADD KEY `alumno_id` (`alumno_id`);

--
-- Indices de la tabla `tarea_entregas`
--
ALTER TABLE `tarea_entregas`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_entrega_unica` (`contenido_id`,`alumno_id`),
  ADD KEY `alumno_id` (`alumno_id`);

--
-- Indices de la tabla `temas_evaluacion`
--
ALTER TABLE `temas_evaluacion`
  ADD PRIMARY KEY (`id`),
  ADD KEY `materia_id` (`materia_id`),
  ADD KEY `evaluacion_id` (`evaluacion_id`),
  ADD KEY `profesor_id` (`profesor_id`),
  ADD KEY `grado_id` (`grado_id`),
  ADD KEY `tipo_evaluacion_id` (`tipo_evaluacion_id`);

--
-- Indices de la tabla `tipos_evaluacion`
--
ALTER TABLE `tipos_evaluacion`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `nombre_unico` (`nombre`);

--
-- Indices de la tabla `turnos`
--
ALTER TABLE `turnos`
  ADD PRIMARY KEY (`id`);

--
-- Indices de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  ADD PRIMARY KEY (`id`),
  ADD UNIQUE KEY `idx_usuario` (`usuario`),
  ADD KEY `rol_id` (`rol_id`),
  ADD KEY `persona_fisica_id` (`persona_fisica_id`);

--
-- AUTO_INCREMENT de las tablas volcadas
--

--
-- AUTO_INCREMENT de la tabla `alumnos`
--
ALTER TABLE `alumnos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=77;

--
-- AUTO_INCREMENT de la tabla `alumno_respuestas`
--
ALTER TABLE `alumno_respuestas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=15;

--
-- AUTO_INCREMENT de la tabla `alumno_tutor`
--
ALTER TABLE `alumno_tutor`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=10;

--
-- AUTO_INCREMENT de la tabla `asistencias`
--
ALTER TABLE `asistencias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `asistencia_justificaciones`
--
ALTER TABLE `asistencia_justificaciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `calificaciones`
--
ALTER TABLE `calificaciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=842;

--
-- AUTO_INCREMENT de la tabla `contenido_archivos`
--
ALTER TABLE `contenido_archivos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=2;

--
-- AUTO_INCREMENT de la tabla `contenido_enlaces`
--
ALTER TABLE `contenido_enlaces`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `cuotas_mensuales`
--
ALTER TABLE `cuotas_mensuales`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=31;

--
-- AUTO_INCREMENT de la tabla `divisiones`
--
ALTER TABLE `divisiones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `egresos`
--
ALTER TABLE `egresos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `especialidades`
--
ALTER TABLE `especialidades`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `evaluaciones`
--
ALTER TABLE `evaluaciones`
  MODIFY `id` tinyint(2) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `eventos`
--
ALTER TABLE `eventos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `formularios`
--
ALTER TABLE `formularios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `formulario_entregas`
--
ALTER TABLE `formulario_entregas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `formulario_preguntas`
--
ALTER TABLE `formulario_preguntas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `formulario_sesiones`
--
ALTER TABLE `formulario_sesiones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=92;

--
-- AUTO_INCREMENT de la tabla `grados`
--
ALTER TABLE `grados`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=13;

--
-- AUTO_INCREMENT de la tabla `horarios`
--
ALTER TABLE `horarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=113;

--
-- AUTO_INCREMENT de la tabla `intentos_login`
--
ALTER TABLE `intentos_login`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=18;

--
-- AUTO_INCREMENT de la tabla `materias`
--
ALTER TABLE `materias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=79;

--
-- AUTO_INCREMENT de la tabla `materia_contenido`
--
ALTER TABLE `materia_contenido`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=34;

--
-- AUTO_INCREMENT de la tabla `materia_grado`
--
ALTER TABLE `materia_grado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=212;

--
-- AUTO_INCREMENT de la tabla `mensajes`
--
ALTER TABLE `mensajes`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=27;

--
-- AUTO_INCREMENT de la tabla `monitoreo_formulario`
--
ALTER TABLE `monitoreo_formulario`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=56;

--
-- AUTO_INCREMENT de la tabla `noticias`
--
ALTER TABLE `noticias`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `noticia_visibilidad_grado`
--
ALTER TABLE `noticia_visibilidad_grado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `pagos_mensuales`
--
ALTER TABLE `pagos_mensuales`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=687;

--
-- AUTO_INCREMENT de la tabla `personas_fisicas`
--
ALTER TABLE `personas_fisicas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=100;

--
-- AUTO_INCREMENT de la tabla `preceptor_grado`
--
ALTER TABLE `preceptor_grado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=55;

--
-- AUTO_INCREMENT de la tabla `pregunta_opciones`
--
ALTER TABLE `pregunta_opciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=109;

--
-- AUTO_INCREMENT de la tabla `profesores`
--
ALTER TABLE `profesores`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=4;

--
-- AUTO_INCREMENT de la tabla `profesor_especialidad`
--
ALTER TABLE `profesor_especialidad`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `profesor_materia`
--
ALTER TABLE `profesor_materia`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `profesor_materia_grado`
--
ALTER TABLE `profesor_materia_grado`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `roles`
--
ALTER TABLE `roles`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=9;

--
-- AUTO_INCREMENT de la tabla `sanciones`
--
ALTER TABLE `sanciones`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `tarea_entregas`
--
ALTER TABLE `tarea_entregas`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT;

--
-- AUTO_INCREMENT de la tabla `temas_evaluacion`
--
ALTER TABLE `temas_evaluacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=106;

--
-- AUTO_INCREMENT de la tabla `tipos_evaluacion`
--
ALTER TABLE `tipos_evaluacion`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=7;

--
-- AUTO_INCREMENT de la tabla `turnos`
--
ALTER TABLE `turnos`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=3;

--
-- AUTO_INCREMENT de la tabla `usuarios`
--
ALTER TABLE `usuarios`
  MODIFY `id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=91;

-- --------------------------------------------------------

--
-- Estructura para la vista `vista_materias_por_grado`
--
DROP TABLE IF EXISTS `vista_materias_por_grado`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vista_materias_por_grado`  AS SELECT `g`.`id` AS `grado_id`, `g`.`nombre` AS `grado`, `g`.`tipo_ciclo` AS `tipo_ciclo`, `d`.`nombre` AS `division`, `t`.`nombre` AS `turno`, `m`.`id` AS `materia_id`, `m`.`nombre` AS `materia`, `m`.`descripcion` AS `descripcion`, `m`.`horas_semanales` AS `horas_semanales`, `m`.`especialidad` AS `especialidad`, CASE `m`.`es_especialidad` WHEN 1 THEN 'Sí' ELSE 'No' END AS `es_especialidad`, CASE `m`.`activa` WHEN 1 THEN 'Activa' ELSE 'Inactiva' END AS `estado` FROM ((((`materia_grado` `mg` join `materias` `m` on(`mg`.`materia_id` = `m`.`id`)) join `grados` `g` on(`mg`.`grado_id` = `g`.`id`)) join `divisiones` `d` on(`g`.`division_id` = `d`.`id`)) left join `turnos` `t` on(`g`.`turno_id` = `t`.`id`)) ORDER BY `g`.`nombre` ASC, `d`.`nombre` ASC, `m`.`es_especialidad` DESC, `m`.`nombre` ASC ;

--
-- Restricciones para tablas volcadas
--

--
-- Filtros para la tabla `alumnos`
--
ALTER TABLE `alumnos`
  ADD CONSTRAINT `alumnos_ibfk_1` FOREIGN KEY (`usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `alumnos_ibfk_2` FOREIGN KEY (`persona_fisica_id`) REFERENCES `personas_fisicas` (`id`),
  ADD CONSTRAINT `alumnos_ibfk_3` FOREIGN KEY (`grado_id`) REFERENCES `grados` (`id`);

--
-- Filtros para la tabla `alumno_respuestas`
--
ALTER TABLE `alumno_respuestas`
  ADD CONSTRAINT `alumno_respuestas_ibfk_1` FOREIGN KEY (`formulario_id`) REFERENCES `formularios` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `alumno_respuestas_ibfk_2` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `alumno_respuestas_ibfk_3` FOREIGN KEY (`pregunta_id`) REFERENCES `formulario_preguntas` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `alumno_respuestas_ibfk_4` FOREIGN KEY (`opcion_seleccionada_id`) REFERENCES `pregunta_opciones` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `alumno_tutor`
--
ALTER TABLE `alumno_tutor`
  ADD CONSTRAINT `alumno_tutor_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `alumno_tutor_ibfk_2` FOREIGN KEY (`tutor_id`) REFERENCES `usuarios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `asistencias`
--
ALTER TABLE `asistencias`
  ADD CONSTRAINT `asistencias_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `asistencias_ibfk_2` FOREIGN KEY (`registrado_por`) REFERENCES `usuarios` (`id`);

--
-- Filtros para la tabla `asistencia_justificaciones`
--
ALTER TABLE `asistencia_justificaciones`
  ADD CONSTRAINT `fk_justificacion_alumno` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `fk_justificacion_preceptor` FOREIGN KEY (`preceptor_usuario_id`) REFERENCES `usuarios` (`id`) ON DELETE SET NULL;

--
-- Filtros para la tabla `calificaciones`
--
ALTER TABLE `calificaciones`
  ADD CONSTRAINT `calificaciones_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `calificaciones_ibfk_2` FOREIGN KEY (`tema_evaluacion_id`) REFERENCES `temas_evaluacion` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `contenido_archivos`
--
ALTER TABLE `contenido_archivos`
  ADD CONSTRAINT `fk_archivo_contenido` FOREIGN KEY (`contenido_id`) REFERENCES `materia_contenido` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `contenido_enlaces`
--
ALTER TABLE `contenido_enlaces`
  ADD CONSTRAINT `contenido_enlaces_ibfk_1` FOREIGN KEY (`contenido_id`) REFERENCES `materia_contenido` (`id`);

--
-- Filtros para la tabla `egresos`
--
ALTER TABLE `egresos`
  ADD CONSTRAINT `egresos_ibfk_1` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `formularios`
--
ALTER TABLE `formularios`
  ADD CONSTRAINT `fk_formularios_tema_evaluacion` FOREIGN KEY (`tema_evaluacion_id`) REFERENCES `temas_evaluacion` (`id`) ON DELETE SET NULL ON UPDATE CASCADE,
  ADD CONSTRAINT `formularios_ibfk_1` FOREIGN KEY (`contenido_id`) REFERENCES `materia_contenido` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `formulario_entregas`
--
ALTER TABLE `formulario_entregas`
  ADD CONSTRAINT `formulario_entregas_ibfk_1` FOREIGN KEY (`formulario_id`) REFERENCES `formularios` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `formulario_entregas_ibfk_2` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `formulario_preguntas`
--
ALTER TABLE `formulario_preguntas`
  ADD CONSTRAINT `formulario_preguntas_ibfk_1` FOREIGN KEY (`formulario_id`) REFERENCES `formularios` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `formulario_sesiones`
--
ALTER TABLE `formulario_sesiones`
  ADD CONSTRAINT `formulario_sesiones_ibfk_1` FOREIGN KEY (`formulario_id`) REFERENCES `formularios` (`id`) ON DELETE CASCADE,
  ADD CONSTRAINT `formulario_sesiones_ibfk_2` FOREIGN KEY (`alumno_id`) REFERENCES `alumnos` (`id`) ON DELETE CASCADE;

--
-- Filtros para la tabla `grados`
--
ALTER TABLE `grados`
  ADD CONSTRAINT `grados_ibfk_1` FOREIGN KEY (`turno_id`) REFERENCES `turnos` (`id`),
  ADD CONSTRAINT `grados_ibfk_2` FOREIGN KEY (`division_id`) REFERENCES `divisiones` (`id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
