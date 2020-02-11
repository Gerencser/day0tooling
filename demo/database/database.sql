DROP DATABASE IF EXISTS demodb;
CREATE DATABASE demodb;
USE demodb;
CREATE TABLE date (
        id INT(11) NOT NULL AUTO_INCREMENT,
        date DATETIME NULL DEFAULT NULL,
        comment CHAR(150) NOT NULL DEFAULT '0',
        PRIMARY KEY (`id`)
);
GRANT ALL PRIVILEGES ON demodb.* TO 'demo_user'@'%' IDENTIFIED BY 'Password12';
