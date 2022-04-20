CREATE DATABASE IF NOT EXISTS `beenews`;
CREATE DATABASE IF NOT EXISTS `btree_node`;

GRANT ALL ON `beenews`.* TO 'hannes'@'%';
GRANT ALL ON `btree_node`.* TO 'hannes'@'%';