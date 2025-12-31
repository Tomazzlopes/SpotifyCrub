SET GLOBAL local_infile = 1;

-- Criação do schema 'spotify'.
create schema if not exists spotify;

-- Utilização do schema 'spotify'.
use spotify;

-- Criação da tabela album.
create table album(
	id_album varchar(255) not null,
	track_album_name varchar(255) not null,
	track_album_release_date date not null,

	primary key (id_album)
);

-- Criação da tabela subgenre.
create table subgenre(
	id_subgenre int not null auto_increment,
    playlist_subgenre varchar(255) not null,
    
    primary key (id_subgenre)
);

-- Criação da tabela genre.
create table genre(
	id_genre int not null auto_increment,
    playlist_genre varchar(255) not null,
    
    primary key (id_genre)
);

-- Criação da tabela track.
create table track(
	id_track varchar(255) not null,
	track_name varchar(255) not null,
	track_href varchar(255) not null,
    track_artist varchar(255) not null,
	duration_ms int not null,
	energy double not null,
	loudness double not null,
	`mode` int not null,
	`key` int not null,
	time_signature int not null,
	valence double not null,
	instrumentalness double not null,
	liveness double not null,
	speechiness double not null,
	tempo double not null,
	track_popularity int not null,
	id varchar(255) not null,
	type varchar(255) not null,
	acousticness double not null,
	danceability double not null,
	analysis_url varchar(255) not null,
	uri varchar(255) not null,
	album_id varchar(255) not null,

	primary key (id_track),
	foreign key (album_id) references album(id_album)
);

-- Criação da tabela playlist.
create table playlist(
	id_playlist varchar(255) not null,
	playlist_name varchar(255) not null,
	subgenre_id int not null,
	genre_id int not null,

	primary key (id_playlist),
	foreign key (subgenre_id) references subgenre(id_subgenre),
	foreign key (genre_id) references genre(id_genre)
);

-- Criação da tabela track_playlist.
create table track_playlist(
	id_track_playlist int not null auto_increment,
	playlist_id varchar(255) not null,
	track_id varchar(255) not null,

	primary key (id_track_playlist),
	foreign key (playlist_id) references playlist(id_playlist),
	foreign key (track_id) references track(id_track)
);

USE spotify;

-- =========================
-- STAGING (ordem exata do CSV)
-- =========================
DROP TABLE IF EXISTS staging_spotify;

CREATE TABLE staging_spotify (
    energy DOUBLE,
    tempo DOUBLE,
    danceability DOUBLE,
    playlist_genre VARCHAR(255),
    loudness DOUBLE,
    liveness DOUBLE,
    valence DOUBLE,
    track_artist VARCHAR(255),
    time_signature INT,
    speechiness DOUBLE,
    track_popularity INT,
    track_href VARCHAR(255),
    uri VARCHAR(255),
    track_album_name VARCHAR(255),
    playlist_name VARCHAR(255),
    analysis_url VARCHAR(255),
    track_id VARCHAR(255),
    track_name VARCHAR(255),
    track_album_release_date DATE,
    instrumentalness DOUBLE,
    track_album_id VARCHAR(255),
    `mode` INT,
    `key` INT,
    duration_ms INT,
    acousticness DOUBLE,
    id VARCHAR(255),
    playlist_subgenre VARCHAR(255),
    type VARCHAR(255),
    playlist_id VARCHAR(255),
    popularity_class VARCHAR(50)
);

-- =========================
-- LOAD DATA (SEM LOCAL)
-- =========================
LOAD DATA INFILE
'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/spotify_data_mysql_ready.csv'
INTO TABLE staging_spotify
CHARACTER SET utf8mb4
FIELDS TERMINATED BY ','
OPTIONALLY ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    energy,
    tempo,
    danceability,
    playlist_genre,
    loudness,
    liveness,
    valence,
    track_artist,
    time_signature,
    speechiness,
    track_popularity,
    track_href,
    uri,
    track_album_name,
    playlist_name,
    analysis_url,
    track_id,
    track_name,
    @release_date,
    instrumentalness,
    track_album_id,
    `mode`,
    `key`,
    duration_ms,
    acousticness,
    id,
    playlist_subgenre,
    type,
    playlist_id,
    popularity_class
)
SET track_album_release_date =
    CASE
        WHEN @release_date IS NULL OR @release_date = ''
            THEN NULL
        WHEN LENGTH(@release_date) = 4
            THEN STR_TO_DATE(CONCAT(@release_date, '-01-01'), '%Y-%m-%d')
        WHEN LENGTH(@release_date) = 7
            THEN STR_TO_DATE(CONCAT(@release_date, '-01'), '%Y-%m-%d')
        ELSE STR_TO_DATE(@release_date, '%Y-%m-%d')
    END;

-- =========================
-- ALBUM
-- =========================
INSERT IGNORE INTO album (id_album, track_album_name, track_album_release_date)
SELECT DISTINCT
    track_album_id,
    track_album_name,
    track_album_release_date
FROM staging_spotify;

-- =========================
-- GENRE
-- =========================
INSERT IGNORE INTO genre (playlist_genre)
SELECT DISTINCT playlist_genre
FROM staging_spotify;

-- =========================
-- SUBGENRE
-- =========================
INSERT IGNORE INTO subgenre (playlist_subgenre)
SELECT DISTINCT playlist_subgenre
FROM staging_spotify;

-- =========================
-- PLAYLIST
-- =========================
INSERT IGNORE INTO playlist (id_playlist, playlist_name, subgenre_id, genre_id)
SELECT DISTINCT
    s.playlist_id,
    s.playlist_name,
    sg.id_subgenre,
    g.id_genre
FROM staging_spotify s
JOIN subgenre sg ON sg.playlist_subgenre = s.playlist_subgenre
JOIN genre g ON g.playlist_genre = s.playlist_genre;

-- =========================
-- TRACK
-- =========================
INSERT IGNORE INTO track (
    id_track,
    track_name,
    track_href,
    track_artist,
    duration_ms,
    energy,
    loudness,
    `mode`,
    `key`,
    time_signature,
    valence,
    instrumentalness,
    liveness,
    speechiness,
    tempo,
    track_popularity,
    id,
    type,
    acousticness,
    danceability,
    analysis_url,
    uri,
    album_id
)
SELECT
    track_id,
    track_name,
    track_href,
    track_artist,
    duration_ms,
    energy,
    loudness,
    `mode`,
    `key`,
    time_signature,
    valence,
    instrumentalness,
    liveness,
    speechiness,
    tempo,
    track_popularity,
    id,
    type,
    acousticness,
    danceability,
    analysis_url,
    uri,
    track_album_id
FROM staging_spotify;

-- =========================
-- TRACK ↔ PLAYLIST
-- =========================
INSERT IGNORE INTO track_playlist (playlist_id, track_id)
SELECT DISTINCT
    playlist_id,
    track_id
FROM staging_spotify;

-- =========================
-- VERIFICAÇÃO
-- =========================
SELECT COUNT(*) FROM album;
SELECT COUNT(*) FROM genre;
SELECT COUNT(*) FROM subgenre;
SELECT COUNT(*) FROM playlist;
SELECT COUNT(*) FROM track;
SELECT COUNT(*) FROM track_playlist;

-- =========================
-- LIMPEZA (opcional)
-- =========================
DROP TABLE staging_spotify;
