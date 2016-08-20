DELIMITER //

DROP PROCEDURE IF EXISTS kecs;

CREATE PROCEDURE kecs
(
	IN username CHAR(20) CHARACTER SET ascii,
	IN t1 INT UNSIGNED,
	IN t2 INT UNSIGNED
)

BEGIN

	################
	## INITIALIZE ##
	################

	-- rename our input variable to avoid namespace collisions
	SET @author = username;
	SET @t1 = t1;
	SET @t2 = t2;

	-- favour performance and concurrency over data consistency
	SET SESSION tx_isolation='READ-COMMITTED'; -- this version required for TokuDB
	START TRANSACTION;

	-- set our session's 'temporary' table name
	SET @descendant_comments = CONCAT('descendant_comments_s',connection_id());

	-- get the user's author_id
	SELECT id INTO @author_id FROM author WHERE username = @author;


	#################
	## POST SEARCH ##
	#################

	#
	# Find roots for recursive descendant search 
	# ------------------------------------------ #

	-- create the table
	SET @sql = CONCAT(
	   'CREATE TABLE IF NOT EXISTS ',@descendant_comments,' (
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
	   'INSERT INTO ',@descendant_comments,'
		SELECT co.comment_id,@depth
		FROM comments_meta co
		INNER JOIN submissions_meta su
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
	   'INSERT IGNORE INTO ',@descendant_comments,'
		SELECT co.comment_id,(? + 1)
		FROM comments_meta co
		INNER JOIN ',@descendant_comments,' de
		ON  co.parent_id = de.comment_id
		WHERE de.depth = ?'
	);
	PREPARE insert_next FROM @sql;

	-- continue the recursion until there are no new descendants to find children of
	SET @sql = CONCAT('SELECT EXISTS (SELECT comment_id FROM ',@descendant_comments,' WHERE depth = ?) INTO @new_descendants_exist');
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
	   'CREATE TABLE ',@result_posts,' (
		   ' -- post_id BIGINT UNSIGNED NOT NULL,
		   'is_self TINYINT UNSIGNED NOT NULL,
			score MEDIUMINT NOT NULL,
			KEY (is_self) USING BTREE
		) ENGINE=MEMORY
		SELECT a.is_self,a.score FROM
		(
		   
		   ' -- author submissions in search period
		   'SELECT
		   		1 AS is_self,
		   		su.score AS score
		   	FROM submissions_meta su
			WHERE su.author_id = @author_id
			AND su.created_utc >= @t1
			AND su.created_utc < @t2
			
			UNION ALL
		   
		   ' -- comments in user submissions in time period
		   'SELECT
				co.author_id=@author_id AS is_self,
				co.score AS score
			FROM comments_meta co
			INNER JOIN submissions_meta su
			ON co.link_id = su.link_id
			WHERE su.author_id = @author_id
			AND co.created_utc >= @t1
			AND co.created_utc < @t2

			UNION ALL
		   ' -- comments in descendant search list in time period
		   'SELECT
				co.author_id=@author_id AS is_self,
				co.score AS score
			FROM comments_meta co
			INNER JOIN ',@descendant_comments,' de
			ON co.comment_id = de.comment_id
			WHERE co.created_utc >= @t1
			AND co.created_utc < @t2
			
		) a'
	);
	PREPARE create_tbl FROM @sql;
	EXECUTE create_tbl;
	DEALLOCATE PREPARE create_tbl;

	-- select final scores
	SET @sql = CONCAT('
		SELECT
			@author,
			(SELECT coalesce(sum(score),0) FROM ',@result_posts,'),
			(SELECT coalesce(sum(score),0) FROM ',@result_posts,' WHERE is_self = 1),
			(SELECT count(1) FROM ',@result_posts,'),
			(SELECT count(1) FROM ',@result_posts,' WHERE is_self = 1)'
	);
	PREPARE select_results FROM @sql;
	EXECUTE select_results;
	DEALLOCATE PREPARE select_results;


	##################
	## DEINITIALIZE ##
	##################

	SET @sql = CONCAT('DROP TABLE IF EXISTS ',@descendant_comments);
	PREPARE drop_tbl FROM @sql; EXECUTE drop_tbl; DEALLOCATE PREPARE drop_tbl;
	SET @sql = CONCAT('DROP TABLE IF EXISTS ',@result_posts);
	PREPARE drop_tbl FROM @sql; EXECUTE drop_tbl; DEALLOCATE PREPARE drop_tbl;

	COMMIT;

END//

DELIMITER ;