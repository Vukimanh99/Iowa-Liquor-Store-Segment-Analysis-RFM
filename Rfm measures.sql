select * from [iowa sample]



-- Xác định ngày gần nhất mua hàng của mỗi khách hàng (R)
WITH LastPurchase AS (
    SELECT
        store_number,
        MAX(date) AS last_purchase_date
    FROM
        [iowa sample]
    GROUP BY
        store_number
)

SELECT
    store_number,
    DATEDIFF(day, last_purchase_date, '2022-01-31') AS recency
FROM
    LastPurchase

-- Tính Frequency (số lần mua hàng) (F)
SELECT
    store_number,
    COUNT(*) AS frequency
FROM
    [iowa sample]
GROUP BY
    store_number
-- Tính Monetary (tổng giá trị đặt hàng) (M)
SELECT
    store_number,
    ROUND(SUM(sale_dollars),3) AS monetary
FROM
    [iowa sample]
GROUP BY
    store_number


-- Tạo bảng measures từ các chỉ số
WITH RFM_numbers AS (
    SELECT
        store_number,
        MAX(date) AS Last_purchase_date,
        COUNT(*) AS Frequency,
        ROUND(SUM(sale_dollars), 3) AS Monetary
    FROM
        [iowa sample]
    GROUP BY
        store_number
),

Recency_Calculation AS (
    SELECT
        store_number,
        DATEDIFF(day, Last_purchase_date, '2022-01-31') AS Recency
    FROM
        RFM_numbers
)
SELECT
    rc.store_number,
    rc.Recency,
    r.Frequency,
    r.Monetary
INTO
    RFM_Measures
FROM
    Recency_Calculation rc
JOIN
    RFM_numbers r ON rc.store_number = r.store_number

  







-- Xay dung mo hinh RFM phan khuc khach hang
with A as(
    select store_number,
          invoice_and_item_number,
    
          [date],
          sale_dollars
from [Iowa Liquor])
--select* from A
, RFM_Base as(
    select store_number,
          datediff(day,Max([date]), GETDATE() ) as Recency_value,
          count(distinct [date] ) as Frequency_value,
          round(sum(sale_dollars),2) as Monetary_value
    from A
    group by store_number
)
--select * from  RFM_Base
,RFM_Score 
AS
(
  SELECT *,
    NTILE(5) OVER (ORDER BY Recency_Value DESC) as R_Score,
    NTILE(5) OVER (ORDER BY Frequency_Value ASC) as F_Score,
    NTILE(5) OVER (ORDER BY Monetary_Value ASC) as M_Score
  FROM RFM_Base
)
--SELECT * FROM RFM_Score
, RFM_Final
AS
(
SELECT *,
  Cast(CONCAT(R_Score, F_Score, M_Score) as int) as RFM_Overall
from RFM_Score)
SELECT a.* , b.segment 
FROM RFM_Final a join segment_scores b 
on a.RFM_Overall=b.scores


