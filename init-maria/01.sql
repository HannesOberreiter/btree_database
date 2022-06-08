CREATE DATABASE IF NOT EXISTS `beenews`;
CREATE DATABASE IF NOT EXISTS `btree_node`;
CREATE DATABASE IF NOT EXISTS `btree_node_test`;

GRANT ALL ON `beenews`.* TO 'hannes'@'%';
GRANT ALL ON `btree_node`.* TO 'hannes'@'%';
GRANT ALL ON `btree_node_test`.* TO 'hannes'@'%';
GRANT ALL PRIVILEGES ON *.* TO 'hannes'@'%';
GRANT SELECT,LOCK TABLES ON information_schema.* TO 'hannes'@'%';

FLUSH PRIVILEGES;