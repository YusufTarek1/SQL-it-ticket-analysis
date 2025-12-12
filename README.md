# SQL-it-ticket-analysis

This repository contains a collection of SQL queries and a small synthetic dataset to analyze IT support tickets. It focuses on profiling the ticket dataset, computing SLA and operational metrics, and producing report queries for trends and agent performance.

**Contents**

- **`metrics.sql`**: Core metric queries (SLA, resolution times, counts by priority/issue, agent performance).
- **`data_profiling.sql`**: Data-quality and profiling queries to inspect distributions, nulls, and basic sanity checks.
- **`reports.sql`**: Report-style queries that combine metrics for dashboards or exportable reports.
- **`dataset/`**: Contains the synthetic `tickets.csv` dataset and dataset metadata (`DATA_README.md`).

**Dataset**

- File: `dataset/tickets.csv` (synthetic export; ~4500 rows).
- Export metadata: `dataset/DATA_README.md` (generated with Fabricate v3.5.0).
- Columns (CSV header):

	- `ticket_id`
	- `subject`
	- `description`
	- `priority`
	- `status`
	- `issue_type`
	- `created_at`
	- `resolved_at`
	- `assigned_to`

See `dataset/DATA_README.md` for provenance and row counts.

**Quick Start (SQL Server / T-SQL)**

These SQL files are authored for T-SQL (Microsoft SQL Server). The examples below show how to import the CSV into a SQL Server database and run the provided `.sql` files using `sqlcmd` or SQL Server Management Studio (SSMS).

1. Create a target database (if needed) and a `tickets` table matching the CSV columns. Example T-SQL schema you can adjust:

```sql
CREATE TABLE dbo.tickets (
	ticket_id INT PRIMARY KEY,
	subject NVARCHAR(512),
	description NVARCHAR(MAX),
	priority NVARCHAR(50),
	status NVARCHAR(50),
	issue_type NVARCHAR(100),
	created_at DATETIME2 NULL,
	resolved_at DATETIME2 NULL,
	assigned_to NVARCHAR(200)
);
```

2. Import `dataset/tickets.csv` into the `tickets` table. Options:

- Using BULK INSERT (run in SSMS or `sqlcmd` connected to the target DB):

```sql
BULK INSERT dbo.tickets
FROM 'D:\DataProjects\Github_SS\SQL-it-ticket-analysis\dataset\tickets.csv'
WITH (
	FIRSTROW = 2,
	FIELDTERMINATOR = ',',
	ROWTERMINATOR = '\n',
	CODEPAGE = '65001',
	TABLOCK
);
```

- Or use the "Import Flat File" wizard in SSMS or the Import Data wizard (OLE DB / Flat File source) to map and import the CSV.

3. Run the repository queries with `sqlcmd` (example):

```powershell
# run metrics.sql and save output
sqlcmd -S <server> -d <database> -i metrics.sql -o metrics_output.txt -W -s"," -u
```

Replace `<server>` and `<database>` with your SQL Server instance and database name. Alternatively open the `.sql` files in SSMS and execute them interactively.

Notes on compatibility and portability:

- These queries target T-SQL and may use functions like `DATEDIFF`, `ISNULL`, `CONVERT`, `TRY_CAST`, and other SQL Server features. They will not run unchanged on SQLite or some other engines.
- If you need to run the analysis on Postgres, SQLite, or MySQL, adapt date/time calculations and engine-specific functions. For example:
	- SQL Server T-SQL: `DATEDIFF(MINUTE, created_at, resolved_at)`
	- Postgres: `EXTRACT(EPOCH FROM (resolved_at - created_at)) / 60`
	- SQLite: `julianday(resolved_at) - julianday(created_at)` multiplied by `24*60`.
- Ensure `created_at` and `resolved_at` are imported as proper date/time types for accurate calculations.

**How the SQL files are organized**

- `data_profiling.sql`: Run this first if you want a quick health check of the dataset (null counts, unique values, basic distributions).
- `metrics.sql`: Contains focused metrics such as average time-to-resolve, SLA breach counts, backlog by priority, and agent-level KPIs.
- `reports.sql`: Higher-level, presentation-ready queries intended for exporting to CSV or using in BI tools.

**Examples & Tips**

- To get average resolution time (SQL snippet concept):

```sql
SELECT
	AVG(julianday(resolved_at) - julianday(created_at)) * 24 * 60 AS avg_resolution_minutes
FROM tickets
WHERE resolved_at IS NOT NULL;
```

- If your engine does not support `julianday()` (SQLite), adapt to `EXTRACT(EPOCH FROM (resolved_at - created_at))/60` for Postgres, or equivalent for your database.


**License & Contact**

This workspace contains synthetic data and example SQL for analysis. No sensitive data is included. For questions, contact the repository owner or open an issue.

