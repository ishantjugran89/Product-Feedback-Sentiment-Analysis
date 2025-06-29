CREATE DATABASE Sentiment_Review;
USE Sentiment_Review;

CREATE TABLE reviews (
    Id INTEGER PRIMARY KEY,
    UserId TEXT,
    Score INTEGER,
    Summary TEXT,
    Text TEXT,
    Sentiment TEXT,
    Time BIGINT
);

SHOW VARIABLES LIKE 'secure_file_priv';   -- it will return the path where we can load our files
    
-- loading csv data to our table reviews
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/reviews.csv'
INTO TABLE reviews
FIELDS TERMINATED BY ',' 
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(Id, UserId, Score, Summary, Text, Sentiment, Time);


SELECT * FROM reviews LIMIT 5;		-- checking is data loaded

-- looking hexvalue of each column to find is data clean or not (it will help to find extra character like new line /n, /r)
SELECT DISTINCT HEX(Id), Id 
FROM reviews;

SELECT DISTINCT HEX(UserId), UserId 
FROM reviews;

SELECT DISTINCT HEX(Score), Score 
FROM reviews;

SELECT DISTINCT HEX(Summary), Summary 
FROM reviews;

SELECT DISTINCT HEX(Text), Text 
FROM reviews;

SELECT DISTINCT HEX(Sentiment), Sentiment 
FROM reviews;

SELECT DISTINCT HEX(Time), Time 
FROM reviews;

-- cleaning cloumns if required
-- Sentiment column required cleaning bqz it contains extra character newline, break /n, /r etc we can see no row is returing 
SELECT * 
FROM reviews 
WHERE Sentiment = "Positive";

-- cleaning sentiment column
UPDATE reviews
SET Sentiment = TRIM(REPLACE(REPLACE(Sentiment, '\r', ''), '\n', ''));

-- now checking all column is they returing values correctly
SELECT * 
FROM reviews 
WHERE Id = 898;

SELECT * 
FROM reviews 
WHERE UserId = "A21BT40VZCCYT4";

SELECT * 
FROM reviews 
WHERE Score = 1;

SELECT * 
FROM reviews 
WHERE Text = "If you are looking for the secret ingredient in Robitussin I believe I have found it.  I got this in addition to the Root Beer Extract I ordered (which was good) and made some cherry soda.  The flavor is very medicinal.";

SELECT * 
FROM reviews 
WHERE Summary = "Great!  Just as good as the expensive brands!";

SELECT * 
FROM reviews 
WHERE Sentiment = "Positive";
 
SELECT * 
FROM reviews 
WHERE Time = 1350777600;

 -- Performing SQL Aanlysis in reviews 
 
-- 1. Sentiment Distribution and exporting csv file using command line
SELECT Sentiment, COUNT(*) AS count
INTO OUTFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/sentiment_count.csv'
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
FROM reviews
GROUP BY Sentiment
ORDER BY count DESC;

-- 2. Most Common Negative Feedback (Low Scores)
SELECT Id, UserId, Score, Summary, Text
FROM reviews
WHERE Sentiment = 'Negative' AND Score <= 2
ORDER BY Score ASC
LIMIT 5;

-- 3. Most Positive Feedback (High Scores)
SELECT Id, UserId, Score, Summary, Text
FROM reviews
WHERE Sentiment = 'Positive' AND Score >= 4
ORDER BY Score DESC
LIMIT 5;

-- 4. Sample Neutral Reviews
SELECT Id, UserId, Score, Summary, Text
FROM reviews
WHERE Sentiment = 'Neutral'
LIMIT 5;

-- 5. Negative Reviews with 'refund' word
SELECT Id, UserId, Score, Summary, Text
FROM reviews
WHERE Sentiment = 'Negative' AND Text LIKE '%refund%'
LIMIT 5;

-- 6. Average Score by Sentiment
SELECT Sentiment, AVG(Score) AS avg_score, COUNT(*) AS review_count
FROM reviews
GROUP BY Sentiment;

-- 7. Top Reviewers by Number of Reviews
SELECT UserId, COUNT(*) AS review_count
FROM reviews
GROUP BY UserId
ORDER BY review_count DESC
LIMIT 5;

-- 8. Sentiment Trend Over Time Analysis
SELECT 
  DATE(FROM_UNIXTIME(Time)) AS ReviewDate,
  Sentiment,
  COUNT(*) AS ReviewCount
FROM reviews
GROUP BY ReviewDate, Sentiment
ORDER BY ReviewDate, Sentiment;

-- 9. Time-series summary (reviews per day and sentiment ratio):
SELECT 
  DATE(FROM_UNIXTIME(Time)) AS ReviewDate,
  COUNT(*) AS TotalReviews,
  ROUND(SUM(CASE WHEN Sentiment = 'Positive' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS PositivePct,
  ROUND(SUM(CASE WHEN Sentiment = 'Negative' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS NegativePct,
  ROUND(SUM(CASE WHEN Sentiment = 'Neutral' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS NeutralPct
FROM reviews
GROUP BY ReviewDate
ORDER BY ReviewDate;

