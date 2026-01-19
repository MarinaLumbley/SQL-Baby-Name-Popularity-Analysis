USE baby_names_db;

/* 
---------------------------------------------------------------------------
Query: Overall Most Popular Girl and Boy Names
Author: Marina
Purpose:
    - Determine the single most popular girl name and the single most 
      popular boy name across the entire dataset.
    - Popularity is measured by total births aggregated for each 
      (name, gender) combination.
    - Use DENSE_RANK to identify the top‑ranked name within each gender.

Logic Breakdown:
    1. CTE:
         • Groups records by Name and Gender.
         • Sums total births to compute overall popularity.
         • Applies DENSE_RANK partitioned by Gender so boys and girls 
           are ranked separately.
         • Rank 1 represents the most popular name for that gender.

    2. Final SELECT:
         • Filters to Popularity_rank = 1 to return only the top name 
           for each gender.

Notes:
    - DENSE_RANK ensures ties are handled without skipping rank values.
    - ORDER BY inside the CTE does not affect ranking logic but is 
      acceptable for readability.
---------------------------------------------------------------------------
*/
WITH CTE AS (Select Name, Gender, SUM(Births) As num_babies, dense_rank () OVER (partition by Gender order by SUM(births) DESC) as Popularity_rank 
				from names
				group by Name, Gender
				order by num_babies DESC)
Select * from CTE
where Popularity_rank = 1;

/* 
---------------------------------------------------------------------------
Query: Popularity Rank Changes Over Time for Most Popular Names
Purpose:
    - Track how the popularity of two specific names—Michael (boys) 
      and Jessica (girls)—has changed across all years in the dataset.
    - Popularity is measured using DENSE_RANK within each year, based on 
      total births for that name and gender.
    - This allows you to see whether each name rose, fell, or remained 
      stable in yearly rankings.

Logic Breakdown:
    1. First CTE (Male names):
         • Filters to male ("M") records only.
         • Aggregates total births per (name, year).
         • Assigns a popularity rank within each year using DENSE_RANK.
         • Final SELECT filters to the name "Michael" to show its 
           year‑by‑year ranking.

    2. Second CTE (Female names):
         • Same logic as above, but restricted to female ("F") records.
         • Final SELECT filters to the name "Jessica".

Notes:
    - DENSE_RANK avoids skipping rank numbers when ties occur.
    - ORDER BY inside the window function determines popularity 
      (more births → higher rank).
    - ORDER BY inside the CTE SELECT is optional for correctness and readability but 
      does not affect ranking logic.
---------------------------------------------------------------------------
*/
WITH CTE AS (Select Name, Year, SUM(Births) As num_babies, dense_rank () OVER (partition by Year order by SUM(births) DESC) as Popularity_rank 
				from names
				where Gender = "M"
                group by Name, Year 
				order by num_babies DESC)
Select * from CTE
where Name = "Michael";

WITH CTE AS (Select Name, Year, SUM(Births) As num_babies, dense_rank () OVER (partition by Year order by SUM(births) DESC) as Popularity_rank 
				from names
				where Gender = "F"
                group by Name, Year 
				order by num_babies DESC)
Select * from CTE
where Name = "Jessica";
    
/* 
---------------------------------------------------------------------------
Query: Biggest Jumps in Name Popularity (First Year → Last Year)
Purpose:
    - Identify which baby names experienced the largest change in popularity 
      between the earliest and latest years in the dataset.
    - Popularity is measured using DENSE_RANK within each year, based on total births.
    - Compare each name’s rank in the first year (1980) to its rank in the last year (2009).
    - Compute the difference in ranking to show how much a name rose or fell.

Logic Breakdown:
    1. CTE:
         • Aggregates total births per (name, year).
         • Assigns a popularity rank within each year using DENSE_RANK, 
           where rank 1 = most popular.

    2. CTE_TWO:
         • Filters the dataset to only the first and last years (1980 and 2009).
         • Uses LAG() to retrieve each name’s previous rank so the two years 
           can be compared.

    3. Final SELECT:
         • Calculates the difference between the two ranks:
               Diff_in_ranking = current_rank - previous_rank

Notes:
    - CAST() ensures numeric comparison rather than string comparison and allows negative values.
    - Filtering out NULL previous_rank removes names that appear in only one of the two years.
---------------------------------------------------------------------------
*/
WITH CTE AS (Select Name, Year, SUM(Births) As num_babies, dense_rank () OVER (partition by Year order by SUM(births) DESC) as Popularity_rank 
			 from names
			 group by Name, Year 
			 ),
	CTE_TWO AS (Select Name, Year, num_babies, Popularity_rank, LAG(Popularity_rank) OVER (partition by Name order by Year) as previous_rank 
				from CTE
				Where (Year = "1980" or Year = "2009")
                )
Select Name, Year, Popularity_rank, previous_rank, CAST(Popularity_rank as signed) - CAST(previous_rank as signed) as Diff_in_ranking 
from CTE_TWO
where previous_rank is not null
order by Diff_in_ranking;

/* 
---------------------------------------------------------------------------
Query: Top 3 Girl and Boy Names for Each Year
Purpose:
    - Identify the most popular baby names for every year in the dataset.
    - Separate rankings by gender so boys and girls are evaluated independently.
    - Aggregate total births for each (year, gender, name) combination.
    - Rank names within each year and gender using DENSE_RANK.
    - Return only the top 3 girl names and top 3 boy names per year.

Logic Breakdown:
    1. yearly_names CTE:
         • Groups records by Year, Gender, and Name.
         • Computes total births (num_babies) for each name in each year.

    2. Outer SELECT:
         • Applies DENSE_RANK partitioned by Year and Gender.
         • Orders by num_babies to determine popularity.

    3. Final filter:
         • popularity < 4 ensures only the top 3 names per gender per year.

Notes:
    - DENSE_RANK avoids skipping rank numbers when ties occur.
---------------------------------------------------------------------------
*/
Select * from 
	(WITH yearly_names AS (Select Year, Gender, Name, SUM(Births) as num_babies 
					  from names
					  group by Year, Gender, Name)
			Select Year, Gender, Name, num_babies, dense_rank () OVER (partition by Year, Gender Order By num_babies DESC) as popularity
			from yearly_names) as yearly_top3_names 
where popularity < 4;

/* 
---------------------------------------------------------------------------
Query: Top 3 Girl and Boy Names for Each Decade
Purpose:
    - Identify the most popular baby names by decade and gender.
    - Group all birth records into decade buckets using FLOOR(Year/10) * 10.
    - Aggregate total births for each (decade, gender, name) combination.
    - Rank names within each decade and gender using DENSE_RANK.
    - Return only the top 3 girl names and top 3 boy names per decade.

Logic Breakdown:
    1. decade_names CTE:
         • Converts each year into its decade (e.g., 1987 → 1980).
         • Groups by decade, gender, and name.
         • Computes total births (num_babies) for each group.

    2. Outer SELECT:
         • Applies DENSE_RANK partitioned by decade and gender.
         • Orders by num_babies to determine popularity.

    3. Final filter:
         • popularity < 4 ensures only the top 3 names per gender per decade.

Notes:
    - DENSE_RANK avoids skipping ranks when ties occur.
---------------------------------------------------------------------------
*/
Select * from 
	(WITH decade_names AS (Select Floor(Year/10) * 10 as Decade, Gender, Name, SUM(Births) as num_babies 
					  from names
					  group by Decade, Gender, Name)
			Select Decade, Gender, Name, num_babies, dense_rank () OVER (partition by Decade, Gender Order By num_babies DESC) as popularity
			from decade_names) as decade_top3_names 
where popularity < 4 ;

/* 
---------------------------------------------------------------------------
Query: Total Number of Babies Born in Each U.S. Region
Purpose:
    - Calculate total births across the six major U.S. regions.
    - Standardize region naming by converting "New England" → "New_England".
    - Ensure Michigan ("MI") is included in the Midwest region, 
      even if not present in the original regions table.
    - Join baby name records to their corresponding regions and 
      aggregate total births per region.

Logic Breakdown:
    1. Preliminary check:
         • SELECT DISTINCT(Region) FROM regions 
           verifies the six region labels present in the dataset.

    2. clean_regions CTE:
         • Normalizes region names.
         • Adds Michigan manually to the Midwest region.

    3. Final aggregation:
         • LEFT JOIN names → clean_regions on state.
         • SUM(births) grouped by clean_region gives total babies born 
           in each region.

Notes:
    - LEFT JOIN ensures all name records are counted even if a state 
      is missing from the regions table.
---------------------------------------------------------------------------
*/
Select distinct(Region) from regions;
WITH clean_regions AS  (Select State,
						CASE WHEN Region = "New England" THEN "New_England" ElSE Region END AS clean_region
						From regions
                        Union
                        Select "MI" AS State, "Midwest" AS Region)
                        
Select clean_region, SUM(Births) as num_babies
from names n left join clean_regions cr on n.State = cr.State
group by clean_region;

/* 
---------------------------------------------------------------------------
Query: Top 3 Girl and Boy Names Within Each U.S. Region
Purpose:
    - Identify the most popular baby names by region and gender.
    - Standardize region names (e.g., convert "New England" → "New_England").
    - Add Michigan ("MI") into the Midwest region manually.
    - Aggregate total births for each (region, gender, name) combination.
    - Rank names within each region and gender using DENSE_RANK.
    - Return only the top 3 girl names and top 3 boy names per region.

Logic Breakdown:
    1. clean_regions CTE:
         • Normalizes region labels.
         • Adds Michigan to the Midwest region.
    
    2. names_by_region CTE:
         • Joins baby name records to cleaned region data.
         • Computes total births per name within each region and gender.

    3. Final SELECT:
         • Applies DENSE_RANK partitioned by region and gender.
         • Filters to popularity < 4 → top 3 names for each gender in each region.

Notes:
    - DENSE_RANK ensures ties do not skip ranking numbers.
    - LEFT JOIN ensures all states in the names table are included if present.
---------------------------------------------------------------------------
*/
Select * from
(WITH names_by_region AS 
						(WITH clean_regions AS  (Select State,
											CASE WHEN Region = "New England" THEN "New_England" ElSE Region END AS clean_region
											From regions
											Union
											Select "MI" AS State, "Midwest" AS Region)
                        
						Select cr.clean_region, n.Gender, n.Name, SUM(Births) as num_babies
						from names n left join clean_regions cr on n.State = cr.State
						group by cr.clean_region, n.Gender, n.Name
                        )
Select clean_region, Gender, Name, dense_rank() OVER (partition by clean_region, gender order by num_babies DESC) as popularity
from names_by_region) AS region_popularity
where popularity < 4;

/* 
------------------------------------------------------------
Query: Shortest and Longest Baby Names + Their Popularity
Purpose:
    - Determine the shortest and longest name lengths in the dataset.
    - Identify example names with those lengths.
    - Calculate total popularity (sum of births) for all names 
      that match the shortest and longest lengths.

Logic:
    1. First query:
         • Sort all names by LENGTH(name) descending.
         • LIMIT 5 to inspect longest names.
         • Switching DESC → ASC reveals shortest names.

    2. Second query:
         • Filter names whose length is either 2 or 15.
         • Aggregate total births to measure popularity.
         • Sort by popularity to see which short/long names 
           were most common.
------------------------------------------------------------
*/
Select Name, length(Name)
from Names
order by length(Name) DESC	  -- then ASC in place of DESC to get answers 2 and 15
limit 5;                      

Select Name, length(Name) as name_length, SUM(births) as popularity
from Names
where length(Name) IN (2,15)
group by Name
order by popularity DESC;

/* 
------------------------------------------------------------
Query: State With Highest Percentage of the Name "Marina"
Purpose:
    - Calculate how common the name "Marina" is in each U.S. state.
    - Compute total births named "Marina" per state.
    - Compute total births (all names) per state.
    - Join the two aggregates and calculate the percentage:
          (total Marinas / total births) * 100
    - Return states ordered from highest to lowest percentage.

Notes:
    - Uses two CTEs:
         1. total_Marina  → total births for the name "Marina" by state
         2. total_births  → total births for all names by state
    - Final SELECT computes the percentage and sorts descending.
------------------------------------------------------------
*/
Select State, num_Marina / num_babies * 100 AS percentage_Marina from
(WITH total_Marina AS (Select state, SUM(Births) as num_Marina
						from Names
						where Name = "Marina"
						group by State),
	 total_births AS (Select State, SUM(Births) as num_babies
						from names
						group by State)
	Select tM.state, tM.num_Marina, total_births.num_babies from total_Marina tM
	Inner Join total_births on tM.State = total_births.State) AS final_table
Order by percentage_Marina DESC;
	















