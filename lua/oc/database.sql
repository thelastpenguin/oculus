DROP TABLE IF EXISTS oc_servers;
DROP TABLE IF EXISTS oc_users;
DROP TABLE IF EXISTS oc_user_perms;
DROP TABLE IF EXISTS oc_user_vars;
DROP TABLE IF EXISTS oc_groups;
DROP TABLE IF EXISTS oc_group_perms;

# SERVERS LINKS UP SERVER IDENTIFIER
CREATE TABLE IF NOT EXISTS oc_servers (
	`sv_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`host_ip` VARCHAR(30) NOT NULL,
	`host_name` VARCHAR(255) NOT NULL,
	PRIMARY KEY(`sv_id`),
	UNIQUE(`host_ip`)
) ENGINE=InnoDB, AUTO_INCREMENT=128;


# USERS LINKS UP UID TO STEAMID
CREATE TABLE IF NOT EXISTS oc_users (
	`u_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`steamid` CHAR(30) NOT NULL,
	`displayName` CHAR(30) NOT NULL,
	PRIMARY KEY(`u_id`),
	UNIQUE(`steamid`)
) ENGINE=InnoDB, AUTO_INCREMENT=128;

# PERMISSIONS - THESE ARE GLOBAL UNLESS sv_id IS 0
CREATE TABLE IF NOT EXISTS oc_user_perms (
	`sv_id` INT UNSIGNED NOT NULL,
	`u_id` INT UNSIGNED NOT NULL,
	`perm` VARCHAR(255) NOT NULL,
	UNIQUE(`u_id`,`sv_id`, `perm`)
) ENGINE=InnoDB;

# GROUPS - THESE ARE GLOBAL
CREATE TABLE IF NOT EXISTS oc_groups (
	`g_id` INT UNSIGNED NOT NULL AUTO_INCREMENT,
	`g_inherits` INT UNSIGNED NOT NULL,
	`g_immunity` INT UNSIGNED NOT NULL,
	`group_name` VARCHAR(40) NOT NULL,
	`color` BIGINT NOT NULL,
	PRIMARY KEY(`g_id`)
) ENGINE=InnoDB, AUTO_INCREMENT=128;

# PERMISSIONS - THESE ARE PER-SERVER UNLESS sv_id IS 0
CREATE TABLE IF NOT EXISTS oc_group_perms (
	`g_id` INT UNSIGNED NOT NULL,
	`sv_id` INT UNSIGNED NOT NULL,
	`perm` VARCHAR(100) NOT NULL,
	UNIQUE(`g_id`,`sv_id`,`perm`)
) ENGINE=InnoDB;

# USER VARS
CREATE TABLE IF NOT EXISTS oc_user_vars (
	`sv_id` INT UNSIGNED NOT NULL,
	`u_id` INT UNSIGNED NOT NULL,
	`data` TEXT NOT NULL,
	UNIQUE(`sv_id`, `u_id`)
) ENGINE=InnoDB;

REPLACE INTO `oc_groups` (g_inherits,g_immunity,group_name,color) VALUES (0,0,'user',0);
REPLACE INTO `oc_groups` (g_inherits,g_immunity,group_name,color) VALUES (128,20,'admin',0);
REPLACE INTO `oc_groups` (g_inherits,g_immunity,group_name,color) VALUES (129,50,'superadmin',0);
REPLACE INTO `oc_groups` (g_inherits,g_immunity,group_name,color) VALUES (130,100,'owner',0);
