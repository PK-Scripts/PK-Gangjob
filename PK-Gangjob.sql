CREATE TABLE IF NOT EXISTS `pk_gangjob` (
  `gang` varchar(50) NOT NULL DEFAULT '[]',
  `stash` longtext DEFAULT '[]',
  `loadout` longtext DEFAULT '[]',
  `kluis` longtext DEFAULT NULL,
  `wapenkluis` longtext DEFAULT NULL,
  `kledingkast` longtext DEFAULT NULL,
  `kleding` longtext DEFAULT NULL,
  `garage` longtext DEFAULT NULL,
  PRIMARY KEY (`gang`)
) ENGINE=InnoDB DEFAULT CHARSET=latin1;