DELIMITER //

DROP PROCEDURE IF EXISTS kecs;

CREATE PROCEDURE kecs
(
	IN username_ CHAR(20) CHARACTER SET ascii,
	IN t1 INT UNSIGNED,
	IN t2 INT UNSIGNED
)

BEGIN

	################
	## INITIALIZE ##
	################

	-- rename our input variable to avoid namespace collisions
	SET @author = username_;
	SET @t1 = t1;
	SET @t2 = t2;

	-- favour performance and concurrency over data consistency
	SET SESSION tx_isolation='READ-COMMITTED'; -- this version required for TokuDB
	START TRANSACTION;

	-- set our session's 'temporary' table name
	SET @comment_recu = CONCAT('comment_recu_s',connection_id());
	SET @comment_desc = CONCAT('comment_desc_s',connection_id());

	-- get the user's author_id
	SET @author_id = NULL;
	SELECT author_id INTO @author_id FROM author WHERE username = @author;

	#################
	## POST SEARCH ##
	#################

	#
	# Find roots for recursive descendant search 
	# ------------------------------------------ #

	-- create the table
	SET @sql = CONCAT(
	   'CREATE TABLE IF NOT EXISTS ',@comment_recu,' (
			comment_id BIGINT UNSIGNED NOT NULL,
			depth INT UNSIGNED NOT NULL,
			PRIMARY KEY (comment_id),'
			-- KEY (created_utc) USING BTREE,
		   'KEY (depth) USING BTREE
		) ENGINE=MEMORY'
	);
	PREPARE create_tbl FROM @sql;
	EXECUTE create_tbl;
	DEALLOCATE PREPARE create_tbl;

	-- find only author comments that aren't in their own submissions
	SET @depth = 0;
	SET @sql = CONCAT(
	   'INSERT INTO ',@comment_recu,'
		SELECT co.comment_id,@depth
		FROM comment co
		INNER JOIN submission su
		ON co.link_id = su.link_id
		WHERE co.author_id = @author_id
		AND su.author_id != @author_id'
	);
	PREPARE insert_next FROM @sql;
	EXECUTE insert_next;
	DEALLOCATE PREPARE insert_next;

	#
	# Recursive descendant search
	# --------------------------- #

	-- fetch descendants of comments found in previous iteration
	SET @sql = CONCAT(
	   'INSERT IGNORE INTO ',@comment_recu,'
		SELECT co.comment_id,(? + 1)
		FROM comment co
		INNER JOIN ',@comment_recu,' de
		ON  co.parent_id = de.comment_id
		WHERE de.depth = ?'
	);
	PREPARE insert_next FROM @sql;

	-- continue the recursion until there are no new descendants to find children of
	SET @sql = CONCAT('SELECT EXISTS (SELECT comment_id FROM ',@comment_recu,' WHERE depth = ?) INTO @new_descendants_exist');
	PREPARE new_descendants_query FROM @sql;

	-- perform the recursive search
	EXECUTE new_descendants_query USING @depth;
	WHILE @new_descendants_exist <> 0
	DO
		EXECUTE insert_next USING @depth,@depth;
		SET @depth = @depth + 1;

	EXECUTE new_descendants_query USING @depth;
	END WHILE;

	DEALLOCATE PREPARE insert_next;
	DEALLOCATE PREPARE new_descendants_query;


	#####################
	## COLLECT RESULTS ##
	#####################

	-- create the table
	SET @sql = CONCAT(
	   'CREATE TABLE ',@comment_desc,' (
		   ' -- post_id BIGINT UNSIGNED NOT NULL,
		   'is_self TINYINT UNSIGNED NOT NULL,
			score INT NOT NULL,
			KEY (is_self) USING BTREE
		) ENGINE=MEMORY
		SELECT a.is_self,a.score FROM
		(
		   
		   ' -- author submissions in search period
		   'SELECT
		   		1 AS is_self,
		   		su.score AS score
		   	FROM submission su
			WHERE su.author_id = @author_id
			AND su.created_utc >= @t1
			AND su.created_utc < @t2
			
			UNION ALL
		   
		   ' -- comments in user submissions in time period
		   'SELECT
				co.author_id=@author_id AS is_self,
				co.score AS score
			FROM comment co
			INNER JOIN submission su
			ON co.link_id = su.link_id
			WHERE su.author_id = @author_id
			AND co.created_utc >= @t1
			AND co.created_utc < @t2

			UNION ALL
		   ' -- comments in descendant search list in time period
		   'SELECT
				co.author_id=@author_id AS is_self,
				co.score AS score
			FROM comment co
			INNER JOIN ',@comment_recu,' de
			ON co.comment_id = de.comment_id
			WHERE co.created_utc >= @t1
			AND co.created_utc < @t2
			
		) a'
	);
	PREPARE create_tbl FROM @sql;
	EXECUTE create_tbl;
	DEALLOCATE PREPARE create_tbl;

	-- don't hold table for any longer than is necessary
	SET @sql = CONCAT('DROP TABLE IF EXISTS ',@comment_recu);
	PREPARE drop_tbl FROM @sql; EXECUTE drop_tbl; DEALLOCATE PREPARE drop_tbl;

	-- select final scores
	SET @sql = CONCAT('
		SELECT
			@author AS username,
			(SELECT coalesce(sum(score),0) FROM ',@comment_desc,') AS score,
			(SELECT coalesce(sum(score),0) FROM ',@comment_desc,' WHERE is_self = 1) AS score_self,
			(SELECT count(1) FROM ',@comment_desc,') AS count,
			(SELECT count(1) FROM ',@comment_desc,' WHERE is_self = 1) AS count_self'
	);
	PREPARE select_results FROM @sql;
	EXECUTE select_results;
	DEALLOCATE PREPARE select_results;

	SET @sql = CONCAT('DROP TABLE IF EXISTS ',@comment_desc);
	PREPARE drop_tbl FROM @sql; EXECUTE drop_tbl; DEALLOCATE PREPARE drop_tbl;

	COMMIT;

END//

DELIMITER ;