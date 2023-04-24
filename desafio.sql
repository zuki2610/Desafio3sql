CREATE DATABASE "desafio3-isabel-palacios-987";

CREATE TABLE usuarios(
    id SERIAL,
    email VARCHAR(50),
    nombre VARCHAR(15),
    apellido VARCHAR(15),
    rol VARCHAR(10)
);

INSERT INTO usuarios(
    email,
    nombre,
    apellido,
    rol)
VALUES ( 'zuki@gmail.com', 'administrador', 'adminApellido', 'admin' ),
       ( 'siri@gmail.com', 'usuario1', 'user1Apellido', 'user' ),
       ( 'jota@gmail.com', 'usuario2', 'user2Apellido', 'user' ),
       ( 'buby@gmail.com', 'usuario3', 'user3Apellido', 'user' ),
       ( 'flor@gmail.com', 'usuario4', 'user4Apellido', 'user' );


CREATE TABLE posts(
    id SERIAL,
    titulo VARCHAR,
    contenido TEXT,
    fecha_creacion TIMESTAMP,
    fecha_actualizacion TIMESTAMP,
    destacado BOOLEAN,
    usuario_id BIGINT
);

INSERT INTO posts(
    titulo,
    contenido,
    fecha_creacion,
    fecha_actualizacion,
    destacado,
    usuario_id)
VALUES ( 'Post uno admin', 'La vaca lola la vaca lola tiene cabeza y tiene cola y hace muuuuu', '2022-03-11     11:11:00'::timestamp, '2022-02-15 12:30:00'::timestamp, true, 1 ),
       ( 'Post dos admin', 'los pollitos dicen pio pio pio cuando tienen hambre cuando tienen frio', '2022-12-01 09:30:00'::timestamp, '2023-02-15 12:30:00'::timestamp, false, 1 ),
       ( 'Zukidurukeando', 'hola amigo, hola amigo, amigoooo', '2023-05-05 01:33:00'::timestamp, now(), true, 5 ),
       ( 'titiando', 'odio odio odio, odio, odio, firma, odio', '2022-09-22 22:30:00'::timestamp, '2022-12-15 12:30:00'::timestamp, false, 3 ),
       ( 'siriririri', 'nobody loves me', '2023-03-03 05:59:00'::timestamp, '2023-04-15 12:30:00'::timestamp, true, NULL );

CREATE TABLE comentarios(
    id SERIAL,
    contenido TEXT,
    fecha_creacion TIMESTAMP,
    usuario_id BIGINT,
    post_id BIGINT
);

INSERT INTO comentarios(
    contenido,
    fecha_creacion,
    usuario_id,
    post_id)
VALUES ( 'tomate, tomato','2012-02-11 10:30:00'::timestamp, 2, 1 ),
       ( 'potato, poteto','2016-05-22 08:09:00'::timestamp, 3, 1 ),
       ( 'peaches peaches peaches','2022-03-23 12:30:00'::timestamp, 1, 1 ),
       ( 'anda pasha bobo','2018-01-01 01:10:00'::timestamp, 2, 2 ),
       ( 'canserbero','2012-11-03 10:30:00'::timestamp, 1, 2 );

-- Cruza los datos de la tabla usuarios y posts mostrando las siguientes columnas. nombre e email del usuario junto al título y contenido del post.

SELECT u.nombre, u.email, p.titulo, p.contenido
FROM usuarios u
INNER JOIN posts p
ON u.id = p.usuario_id;

-- Muestra el id, título y contenido de los posts de los administradores. El administrador puede ser cualquier id y debe ser seleccionado dinámicamente.

SELECT p.id, p.titulo, p.contenido
FROM posts p
INNER JOIN usuarios users
ON p.usuario_id = users.id WHERE users.rol = 'admin';

-- Cuenta la cantidad de posts de cada usuario. La tabla resultante debe mostrar el id e email del usuario junto con la cantidad de posts de cada usuario.

SELECT u.id as usuario_id, u.email, COUNT(*) as cantidad_posts
FROM posts p
LEFT JOIN usuarios u
ON p.usuario_id = u.id
WHERE u.email <> ''
GROUP BY u.id, u.email ORDER BY cantidad_posts DESC;

-- Muestra el email del usuario que ha creado más posts. Aquí la tabla resultante tiene un único registro y muestra solo el email.

SELECT u.email FROM usuarios u INNER JOIN posts p
ON u.id = p.usuario_id GROUP BY u.email
HAVING COUNT(*) = (
    SELECT MAX(num_posts) FROM (
        SELECT COUNT(*) as num_posts
        FROM posts
        GROUP BY usuario_id
    ) as subquery
);

-- Muestra la fecha del último post de cada usuario.

SELECT u.nombre, MAX(p.fecha_creacion) ultimo_post
FROM usuarios u
INNER JOIN posts p
ON u.id = p.usuario_id
GROUP BY u.nombre ORDER BY ultimo_post DESC;

-- Muestra el título y contenido del post (artículo) con más comentarios.

SELECT p.titulo post_con_mas_comentarios, p.contenido FROM posts p LEFT JOIN comentarios c
ON p.id = c.post_id GROUP BY p.titulo, p.contenido
HAVING COUNT (*) = (
    SELECT MAX(num_comment) FROM (
        SELECT COUNT(*) as num_comment
        FROM comentarios
        GROUP BY post_id
    ) as subquery
);

-- Muestra en una tabla el título de cada post, el contenido de cada post y el contenido de cada comentario asociado a los posts mostrados, junto con el email del usuario que lo escribió. ****preguntar si es necesario mostrar los post que no tienen comentarios****

SELECT u1.email as autor_post, p.titulo as titulo_post, p.contenido as contenido_post, u2.email as autor_cometario, c.contenido as comentario
FROM posts p
LEFT JOIN comentarios c ON p.id = c.post_id
LEFT JOIN usuarios u1 ON p.usuario_id = u1.id
INNER JOIN usuarios u2 ON u2.id = c.usuario_id;

-- Muestra el contenido del último comentario de cada usuario.

-- me trae el ultimo comentario en general
-- SELECT c.contenido, u.nombre, c.fecha_creacion FROM comentarios c
-- INNER JOIN usuarios u ON u.id = c.usuario_id
-- WHERE c.fecha_creacion IN (SELECT MAX(c.fecha_creacion) FROM comentarios c);

SELECT u.nombre, c.contenido contenido_ultimo_comentario
FROM (
    SELECT usuario_id, MAX(fecha_creacion) AS fecha_ult_comentario
    FROM comentarios
    GROUP BY usuario_id
) AS ult_comentario
INNER JOIN comentarios c ON c.usuario_id = ult_comentario.usuario_id AND c.fecha_creacion = ult_comentario.fecha_ult_comentario
INNER JOIN usuarios u ON u.id = c.usuario_id;

-- Muestra los emails de los usuarios que no han escrito ningún comentario.
SELECT u.email as mail_usuarios_sin_comentarios
FROM usuarios u
LEFT JOIN comentarios c on u.id = c.usuario_id
GROUP BY u.email
HAVING COUNT(c.id) = 0;
