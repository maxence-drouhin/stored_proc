DELIMITER $$
CREATE PROCEDURE updatenamehash() 
  BEGIN
  DECLARE ezdbfile_name_trunk varchar(250);
  DECLARE ezdbfile_data_name_hash varchar(250);
  DECLARE ezdbfile_data_new_name_hash varchar(250);
  DECLARE ezdbfile_data_new_name_trunk varchar(250);
  DECLARE ezdbfile_name_hash varchar(250);
  DECLARE check_new_name_hash_exists INTEGER DEFAULT 0;
  DECLARE maxLoop INT;
  DECLARE counter INT;
  DECLARE vfinished INTEGER DEFAULT 0;
  
 
  
  DECLARE cur CURSOR FOR SELECT name_hash FROM ezdbfile;
  DECLARE CONTINUE HANDLER FOR NOT FOUND SET vfinished = 1;

  
  CREATE TEMPORARY TABLE `ezdbfile_data_new_name_hash` (
  `ezdbfile_name_trunk` varchar(250) COLLATE utf8_bin DEFAULT 'application/octet-stream',
  `ezdbfile_data_new_name_trunk` varchar(250) COLLATE utf8_bin DEFAULT 'application/octet-stream',
  `ezdbfile_data_new_name_hash` varchar(250) COLLATE utf8_bin DEFAULT 'application/octet-stream',
  `ezdbfile_data_old_name_hash` varchar(250) COLLATE utf8_bin DEFAULT 'application/octet-stream'
  );
  
	SET FOREIGN_KEY_CHECKS = 0;
	
	update ezdbfile
	set name = replace(name,'var/pam', 'var/nancy')
	WHERE scope = 'binaryfile';

	update ezdbfile
	set name_trunk = replace(name_trunk,'var/pam', 'var/nancy')
	WHERE scope = 'binaryfile';

	  
  
  OPEN cur; 
  SET counter = 1;
  updateNameHashLoop: LOOP
	FETCH cur INTO ezdbfile_name_hash;
    SELECT count(name_hash) FROM ezdbfile INTO maxLoop;	
	
	IF vfinished = 1 THEN
      LEAVE updateNameHashLoop;
	END IF;
	
    IF counter > maxLoop THEN
     LEAVE updateNameHashLoop;
    END IF;
	
	SELECT name_trunk FROM ezdbfile WHERE name_hash = ezdbfile_name_hash INTO ezdbfile_name_trunk;
	
    SELECT count(name_hash) FROM ezdbfile WHERE name_hash = md5(ezdbfile_name_trunk) INTO check_new_name_hash_exists;
	
	IF check_new_name_hash_exists = 0  THEN
	SET ezdbfile_data_new_name_trunk = replace(ezdbfile_name_trunk,'var/nancy', 'var/pam');
	INSERT INTO ezdbfile_data_new_name_hash VALUES ( ezdbfile_name_trunk, ezdbfile_data_new_name_trunk, md5(ezdbfile_name_trunk), md5(ezdbfile_data_new_name_trunk) );
	UPDATE ezdbfile_data SET name_hash = md5(ezdbfile_name_trunk) WHERE name_hash = md5(ezdbfile_data_new_name_trunk);
	UPDATE ezdbfile SET name_hash = md5(ezdbfile_name_trunk) WHERE name_hash = md5(ezdbfile_data_new_name_trunk);
	END IF;
  
  SET counter = counter + 1; 
  END LOOP updateNameHashLoop;

 CLOSE cur;
 SET FOREIGN_KEY_CHECKS = 1;
END
$$;