FreshMart Monthly Trading Performance Pack
Project Overview
This project develops a recurring Monthly Trading Performance Pack using MySQL and Excel. The objective is to provide management with a simplistic view of monthly trading performance, performance against target, year-to-date position, key trading drivers and store-level exceptions requiring attention.
Business Questions
The report was designed to answer:
•	How did FreshMart perform this month?
•	How did performance change compared with the previous month?
•	Did the business achieve its sales target?
•	How is the business performing year-to-date?
•	What trading movements accompanied the change in sales?
•	Which stores performed strongly or require management attention?
Approach
MySQL was used to prepare and validate monthly reporting datasets at company and store level.
The reporting layer included:
•	Net Sales
•	Customer Transactions
•	Units Sold
•	Average Transaction Value (ATV)
•	Units per Transaction (UPT)
•	Average Selling Price (ASP)
•	Month-on-Month Sales Growth
•	Sales Target Achievement
•	Variance to Target
•	Year-to-Date Sales and Target
Excel was then used to convert the reporting datasets into a recurring management pack.
Workbook Structure
Executive Summary
Provides the selected month's headline KPIs, previous-month comparison, target performance, YTD position, sales trend, store exceptions and management commentary.
Trading Performance
Shows monthly 2025 trading performance across Net Sales, Transactions, ATV, UPT, ASP and sales targets.
Store Performance
Provides a store-level scorecard using sales growth, target achievement, rankings and exception flags to identify stores requiring management attention.
Data
Contains the SQL reporting extracts used to populate the workbook.
Key Analytical Logic
Sales performance was assessed using a simple trading-driver structure:
Net Sales → Transactions × Average Transaction Value
Basket performance was further considered using:
Average Transaction Value = Units per Transaction × Average Selling Price
This helped distinguish whether monthly sales movements were associated with transaction volume, basket size, units purchased or average selling price.
Store performance was evaluated using both Month-on-Month movement and performance against target rather than relying on sales value alone.
Tools
•	MySQL
•	Microsoft Excel
Final Outcome
The completed workbook provides a concise monthly management reporting process.
