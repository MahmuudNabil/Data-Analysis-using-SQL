SELECT * FROM olympics_history;
select * from olympics_history_noc_regions;

-- =========================================================================================
-- 1) How many olympics games have been held?
SELECT  COUNT(DISTINCT games) as games_count
FROM olympics_history;

-- =========================================================================================
-- 2)  List down all Olympics games held so far
SELECT DISTINCT year , season , city
FROM olympics_history;

-- =========================================================================================
-- 3. Mention the total no of nations who participated in each olympics game?
SELECT  games , Count(Distinct noc) as total_nations
FROM olympics_history
GROUP BY games;

-- =========================================================================================
-- 4. Which year saw the highest and lowest no of countries participating in olympics
SELECT MAX(games) as highest_countries, MIN(games) as lowest_countries
FROM olympics_history;

		-- another way 
WITH national_participate AS(
	SELECT Distinct games , Count(DISTINCT noc) as num_of_national_participated
	FROM olympics_history
	GROUP BY games 
)
SELECT games , num_of_national_participated
FROM national_participate
WHERE num_of_national_participated IN (
	      (SELECT MAX(num_of_national_participated) from national_participate),
	      (SELECT MIN(num_of_national_participated) from national_participate)
	)
	
-- =========================================================================================
-- 5. Which nation has participated in all of the olympic games

	-- first get total numbers of games
SELECT DISTINCT season
FROM olympics_history;

SELECT  COUNT(DISTINCT games) as total_num_games
FROM olympics_history
WHERE season = 'Summer'

	-- Nations that participate in all games
SELECT r.region , COUNT(Distinct o.games) 
FROM olympics_history AS o
JOIN olympics_history_noc_regions as r
ON o.noc = r.noc
GROUP BY r.region 
HAVING COUNT(Distinct o.games) = 51
-- =========================================================================================
-- 6. Identify the sport which was played in all summer olympics.
	-- FIRST get number of games in summer 
SELECT COUNT(DISTINCT games)
FROM olympics_history
WHERE season ='Summer';
	-- sports participate in all summer olympics 
SELECT sport , Count(DISTINCT games) as num_of_played
FROM olympics_history
GROUP BY sport
HAVING Count(DISTINCT games) = 29;

			---------------------------------- Another WAY ------------------------------
WITH t1 as (
			SELECT COUNT(DISTINCT games) as total_games 
	        FROM olympics_history 
	        WHERE season ='Summer') , 
	 t2 as (
	 		SELECT DISTINCT games , sport 
		    FROM olympics_history
		    WHERE season= 'Summer' 
	       ),
	 t3 as (
		 	SELECT sport , COUNT(games) num_of_games
		    FROM t2
		    GROUP BY sport 
	       ) 
SELECT * 
FROM t1 
JOIN t3
ON t1.total_games = t3.num_of_games
-- =========================================================================================
-- 7. Which Sports were just played only once in the olympics.
WITH sports_played AS (
			SELECT sport , Count(DISTINCT games) total_olympics_played_at
			FROM olympics_history
			GROUP BY  sport 
			Having Count(DISTINCT games) = 1
)

SELECT DISTINCT sp.sport ,sp.total_olympics_played_at, oh.games
FROM sports_played as sp
JOIN olympics_history as oh
ON sp.sport = oh.sport

-- =========================================================================================
--8. Fetch the total no of sports played in each olympic games.
SELECT games , COUNT(DISTINCT sport) as total_sport_played
FROM olympics_history
GROUP BY games
ORDER BY total_sport_played DESC
-- =========================================================================================							 
-- 9. Fetch oldest athletes to win a gold medal
	-- athletes who win gold medal
WITH athletes_win_gold AS (
	SELECT  MAX(age) AS oldest
	FROM olympics_history
	WHERE medal ='Gold' AND age != 'NA'
)
SELECT o.name , o.sex , o.age, o.team, o.games, o.city, o.sport , o.event , o.medal
FROM athletes_win_gold as g
JOIN olympics_history as o
ON  o.age= g.oldest
WHERE medal ='Gold' 
-- =========================================================================================
-- 10. Find the Ratio of male and female athletes participated in all olympic games.

WITH 
	participants_by_sex AS (
		
		SELECT CAST(SUM(CASE WHEN Sex  ='F' then 1 ELSE 0 END) AS float) AS female_participant ,
		       CAST(SUM(CASE WHEN Sex  ='M' THEN 1 ELSE 0 END)AS FLOAT) AS male_participant
		FROM olympics_history
	)
SELECT CONCAT(female_participant/female_participant , ':' , round(male_participant/female_participant) ,2) AS Ratio
FROM participants_by_sex

-- =========================================================================================
-- 11. Fetch the top 5 athletes who have won the most gold medals.

SELECT DISTINCT Name ,Team , COUNT(*) AS total_gold_medal
FROM olympics_history
WHERE Medal = 'Gold'
GROUP BY Name,Team
ORDER BY total_gold_medal DESC
LIMIT 5;

-- =========================================================================================
-- 12. Fetch the top 5 athletes who have won the most medals (gold/silver/bronze).
SELECT DISTINCT Name ,Team , COUNT(*) AS total_medals
FROM olympics_history
WHERE Medal = 'Gold' OR Medal = 'Silver' OR Medal = 'Bronze'
GROUP BY Name,Team
ORDER BY total_gold_medal DESC
LIMIT 5;
-- =========================================================================================
-- 13. Fetch the top 5 most successful countries in olympics. 
-- Success is defined by no of medals won.
SELECT DISTINCT r.Region , COUNT(*) AS total_medals 
FROM olympics_history AS o
JOIN olympics_history_noc_regions as r
ON o.noc = r.noc
WHERE Medal = 'Gold' OR Medal = 'Silver' OR Medal = 'Bronze'
GROUP BY r.Region
ORDER BY total_medals DESC
LIMIT 5
-- =========================================================================================
-- 14. List down total gold, silver and bronze medals won by each country.
SELECT DISTINCT r.Region ,
	   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END ) AS gold , 
       SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END ) AS Silver,
	   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END ) AS Bronze
FROM olympics_history AS o
JOIN olympics_history_noc_regions as r
ON o.noc = r.noc
GROUP BY r.Region
ORDER BY gold  DESC
-- =========================================================================================
-- 15. List down total gold, silver and bronze medals won by each country corresponding to each olympic games.
SELECT DISTINCT o.Games , r.Region ,
	   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END ) AS gold , 
       SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END ) AS Silver,
	   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END ) AS Bronze
FROM olympics_history AS o
JOIN olympics_history_noc_regions as r
ON o.noc = r.noc
GROUP BY o.Games , r.Region
ORDER BY o.Games  
-- =========================================================================================
-- 16. Identify which country won the most gold, most silver and most bronze medals in each olympic games.
WITH medals AS (
	SELECT o.Games , r.Region ,
		   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END ) AS gold , 
		   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END ) AS Silver,
		   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END ) AS Bronze
	FROM olympics_history AS o
	JOIN olympics_history_noc_regions as r
	ON o.noc = r.noc
	GROUP BY o.Games , r.Region 
	ORDER BY gold  DESC
)

SELECT DISTINCT games ,  CONCAT( FIRST_VALUE(Region) OVER(PARTITION BY games) , '-' , FIRST_VALUE(gold)OVER(PARTITION BY games ORDER BY gold DESC)  )as max_gold , 
						 CONCAT( FIRST_VALUE(Region) OVER(PARTITION BY games) , '-' ,  FIRST_VALUE(Silver)OVER(PARTITION BY games ORDER BY Silver DESC)  ) as max_Silver,
						 CONCAT( FIRST_VALUE(Region) OVER(PARTITION BY games) , '-' ,  FIRST_VALUE(Bronze)OVER(PARTITION BY games ORDER BY Bronze DESC)  )As max_Bronze
FROM medals
GROUP BY games ,Region,gold,Silver,Bronze
-- =========================================================================================
-- 17. Identify which country won the most gold, most silver, most bronze medals and the most medals in each olympic games.
WITH medals AS(
	SELECT  o.Games , r.Region ,
			   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END ) AS gold , 
			   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END ) AS Silver,
			   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END ) AS Bronze,
			   SUM(CASE WHEN o.Medal IN('Gold','Silver','Bronze') THEN 1 ELSE 0 END)AS total_medals
	FROM olympics_history AS o
	JOIN olympics_history_noc_regions as r
	ON o.noc = r.noc
	GROUP BY o.Games , r.Region
)

SELECT DISTINCT games ,
		CONCAT(FIRST_VALUE(Region) OVER(PARTITION BY games) ,'-', FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS max_gold,
		CONCAT(FIRST_VALUE(region) OVER(PARTITION BY games) ,'-', FIRST_VALUE(gold) OVER(PARTITION BY games ORDER BY gold DESC)) AS max_gold,
		CONCAT(FIRST_VALUE(region) OVER(PARTITION BY games) ,'-', FIRST_VALUE(Silver) OVER(PARTITION BY games ORDER BY Silver DESC)) AS max_Silver,						 
		CONCAT(FIRST_VALUE(region) OVER(PARTITION BY games) ,'-', FIRST_VALUE(total_medals) OVER(PARTITION BY games ORDER BY total_medals DESC)) AS max_total_medals
FROM medals
GROUP  BY Games, region, gold, silver, bronze, total_medals

-- =========================================================================================
-- 18. Which countries have never won gold medal but have won silver/bronze medals?
WITH medals AS (
	SELECT  r.Region ,
				   SUM(CASE WHEN o.Medal = 'Gold' THEN 1 ELSE 0 END ) AS gold , 
				   SUM(CASE WHEN o.Medal = 'Silver' THEN 1 ELSE 0 END ) AS Silver,
				   SUM(CASE WHEN o.Medal = 'Bronze' THEN 1 ELSE 0 END ) AS Bronze
	FROM olympics_history AS o
	JOIN olympics_history_noc_regions as r
	ON o.noc = r.noc 
	GROUP BY r.Region
)
SELECT DISTINCT Region , gold ,Silver , Bronze 
FROM medals
WHERE gold =0 AND 
     (Silver <> 0 OR Bronze <> 0)
GROUP BY Region , gold ,Silver , Bronze 
-- =========================================================================================
-- 19. In which Sport/event, India has won highest medals.
SELECT DISTINCT   o.sport , COUNT(o.medal) AS total_medals
FROM olympics_history AS o
JOIN olympics_history_noc_regions as r
ON o.noc = r.noc 
WHERE  r.Region ='India' AND o.medal != 'NA'
GROUP BY o.sport 
ORDER BY total_medals DESC
LIMIT 1

-- ===========================================================================================================
-- 20. Break down all olympic games where India won medal for Hockey and how many medals in each olympic games
SELECT  team , sport , games , 
	SUM(CASE WHEN medal IN('Gold' , 'Silver', 'Bronze') THEN 1 ELSE 0 END) AS total_medals
FROM olympics_history
WHERE team = 'India' 
AND sport ='Hockey'
GROUP BY team , sport ,games
ORDER BY total_medals DESC




