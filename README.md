Oculus Admin
============

MySQL based global admin mod for Garry's Mod.

Oculus employs an advanced permission node based system to implement an extensive permission frame work all stored with MySQL.
Users can configure permissions both specific to servers and global to all servers. In Oculus admin ranks are actually permissions assigned to players.

Commands
--------
Oculus admin implements a very simple and powerful command framework which makes it extremely easy to create new commands with a very small amount of code.


Installation
------------

1. Drag and Drop Oculus into your addons folder.
2. Install the lastest version of [pLib (click here)](https://github.com/thelastpenguin/pLib/)
3. For Database setup execute database.sql on your mysql server to initialize all necessary tables.
4. Make sure you properly configure the database settings in util/data_sv.lua (these will be moved to a more appropriate location eventually).
