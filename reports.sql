use Tickets
select * from tickets;

-- daily ticket summary report 
SELECT 
	CAST(created_at AS DATE) AS ticket_date,
	COUNT(*) AS tickets_created,
	SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) AS closed_tickets,
	SUM(CASE WHEN priority = 'Critical' THEN 1 ELSE 0 END) AS critical_priority_tickets,
	SUM(CASE WHEN priority = 'High' THEN 1 ELSE 0 END) AS high_priority_tickets,
    SUM(CASE WHEN priority = 'Medium' THEN 1 ELSE 0 END) AS medium_priority_tickets,
    SUM(CASE WHEN priority = 'Low' THEN 1 ELSE 0 END) AS low_priority_tickets
FROM tickets
GROUP BY CAST(created_at AS DATE)
ORDER BY ticket_date DESC;


-- weekly performance report
SELECT 
	YEAR(created_at) AS year,
	DATEPART(WEEK, created_at) AS week_number,
	MIN(CAST(created_at AS DATE)) AS week_start_date,
	COUNT(*) AS total_tickets,
	SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) AS tickets_closed,
	ROUND(SUM(CASE WHEN status = 'Closed' THEN 1 ELSE 0 END) * 100.0 / NULLIF(COUNT(*), 0),2) AS closure_rate_percentage
FROM tickets
GROUP BY DATEPART(YEAR, created_at), DATEPART(WEEK, created_at)
ORDER BY year DESC, week_number DESC;


-- monthly trend analysis
SELECT 
    FORMAT(created_at, 'yyyy-MM') AS month_year,
    COUNT(*) AS tickets_created,
    COUNT(DISTINCT assigned_to) AS unique_assignees,
    COUNT(DISTINCT issue_type) AS distinct_issue_types,
    ROUND(AVG(CASE WHEN status = 'Closed' 
              THEN DATEDIFF(HOUR, created_at, resolved_at) 
              ELSE NULL END), 2) AS avg_resolution_hours
FROM tickets
GROUP BY FORMAT(created_at, 'yyyy-MM')
ORDER BY month_year DESC;


-- simple SLA compliance check
-- Assuming: High = 8 hours, Medium = 24 hours, Low = 48 hours
SELECT
    ticket_id,
    subject,
    priority,
    status,
    created_at,
    resolved_at,
    DATEDIFF(HOUR, created_at, resolved_at) AS actual_hours,
    CASE 
        WHEN priority = 'Critical' THEN 4
        WHEN priority = 'High' THEN 8
        WHEN priority = 'Medium' THEN 24
        ELSE 48
    END AS sla_target_hours,
    CASE 
        WHEN(DATEDIFF(HOUR, created_at, resolved_at) <=
                CASE 
                    WHEN priority = 'Critical' THEN 4
                    WHEN priority = 'High' THEN 8
                    WHEN priority = 'Medium' THEN 24
                    ELSE 48
                END)
          THEN 'Within SLA'
        ELSE 'SLA Breach'
    END AS sla_status
FROM tickets
WHERE status = 'Closed' AND resolved_at IS NOT NULL
ORDER BY priority, actual_hours DESC;


-- overall SLA compliance percentage
WITH sla_data AS (
    SELECT 
        priority,
        CASE 
            WHEN DATEDIFF(HOUR, created_at, resolved_at) <= 
                CASE 
                    WHEN priority = 'Critical' THEN 4
                    WHEN priority = 'Medium' THEN 8
                    WHEN priority = 'Low' THEN 24
                    ELSE 48
                END THEN 1
            ELSE 0
        END AS within_sla
    FROM tickets
    WHERE status = 'Closed' 
        AND resolved_at IS NOT NULL
)
SELECT 
    COUNT(*) AS total_closed_tickets,
    SUM(within_sla) AS tickets_within_sla,
    COUNT(*) - SUM(within_sla) AS tickets_breaching_sla,
    ROUND(SUM(within_sla) * 100.0 / NULLIF(COUNT(*), 0), 2) AS sla_compliance_percentage
FROM sla_data;
