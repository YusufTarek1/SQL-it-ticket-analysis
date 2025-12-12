use Tickets
select * from tickets;

-- calculate resolution time for all closed tickets
SELECT 
	ticket_id, 
	subject,
	priority,
	issue_type,
	created_at,
	resolved_at,
	DATEDIFF(DAY, created_at, resolved_at) AS resolution_days,
	DATEDIFF(HOUR, created_at, resolved_at) AS resolution_hours
FROM tickets
WHERE status = 'Closed' AND resolved_at IS NOT NULL
ORDER BY resolution_hours DESC;


-- average resolution time by priority
SELECT 
	priority,
	count(*) AS ticket_count,
	AVG(DATEDIFF(DAY, created_at, resolved_at)) AS avg_resolution_days,
	AVG(DATEDIFF(HOUR, created_at, resolved_at)) AS avg_resolution_hours,
	MIN(DATEDIFF(HOUR, created_at, resolved_at)) AS fastest_resolution_hours,
    MAX(DATEDIFF(HOUR, created_at, resolved_at)) AS slowest_resolution_hours
FROM tickets
WHERE status = 'Closed' AND resolved_at IS NOT NULL
GROUP BY priority
ORDER BY 
	CASE priority
		WHEN 'Critical' THEN 1
		WHEN 'High' THEN 2
		WHEN 'Medium' THEN 3
		ELSE 4
	END;


-- average resolution time by issue type
SELECT
    issue_type,
	priority,
    COUNT(*) AS ticket_count,
    AVG(DATEDIFF(HOUR, created_at, resolved_at)) AS avg_hours_to_resolve
FROM tickets
WHERE
    status = 'Closed'
    AND resolved_at IS NOT NULL
GROUP BY
    issue_type,
	priority
ORDER BY 
	issue_type,
	priority,
	ticket_count DESC;


-- current open tickets by age
SELECT 
    ticket_id,
    subject,
    priority,
    issue_type,
    created_at,
    assigned_to,
    DATEDIFF(HOUR, created_at, GETDATE()) AS hours_open,
    DATEDIFF(DAY, created_at, GETDATE()) AS days_open,
    CASE 
        WHEN DATEDIFF(DAY, created_at, GETDATE()) > 7 THEN 'Overdue (>7 days)'
        WHEN DATEDIFF(DAY, created_at, GETDATE()) > 3 THEN 'Aging (4-7 days)'
        ELSE 'Within SLA (<3 days)'
    END AS aging_status
FROM tickets
WHERE status IN ('Open', 'In Progress')
ORDER BY 
    CASE priority
        WHEN 'Critical' THEN 1 
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END,
    created_at;


-- open ticket summary by assignee
SELECT 
    assigned_to,
    COUNT(*) AS open_tickets_count,
    SUM(CASE WHEN priority = 'Critical' THEN 1 ELSE 0 END) AS critical_priority_open,
    SUM(CASE WHEN priority = 'High' THEN 1 ELSE 0 END) AS high_priority_open,
    SUM(CASE WHEN priority = 'Medium' THEN 1 ELSE 0 END) AS medium_priority_open,
    MIN(created_at) AS oldest_open_ticket,
    MAX(created_at) AS newest_open_ticket,
    ROUND(AVG(DATEDIFF(DAY, created_at, GETDATE())), 2) AS avg_days_open
FROM tickets
WHERE status IN ('Open', 'In Progress')
    AND assigned_to IS NOT NULL
GROUP BY assigned_to
ORDER BY open_tickets_count DESC;


-- current open  tickets by age 
SELECT 
    ticket_id,
    subject,
    priority,
    issue_type,
    created_at,
    assigned_to,
    DATEDIFF(HOUR, created_at, GETDATE()) AS hours_open,
    DATEDIFF(DAY, created_at, GETDATE()) AS days_open,
    CASE 
        WHEN DATEDIFF(DAY, created_at, GETDATE()) > 7 THEN 'Overdue (>7 days)'
        WHEN DATEDIFF(DAY, created_at, GETDATE()) > 3 THEN 'Aging (4-7 days)'
        ELSE 'Within SLA (<3 days)'
    END AS aging_status
FROM tickets
WHERE status IN ('Open', 'In Progress')
ORDER BY 
    CASE priority
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
        WHEN 'Medium' THEN 3
        ELSE 4
    END,
    created_at; 


-- open ticket summary by assignee
SELECT 
    assigned_to,
    COUNT(*) AS open_tickets_count,
    SUM(CASE WHEN priority = 'Critical' THEN 1 ELSE 0 END) AS critical_priority_open,
    SUM(CASE WHEN priority = 'High' THEN 1 ELSE 0 END) AS high_priority_open,
    MIN(created_at) AS oldest_open_ticket,
    MAX(created_at) AS newest_open_ticket,
    ROUND(AVG(DATEDIFF(DAY, created_at, GETDATE())), 2) AS avg_days_open
FROM tickets
WHERE status IN ('Open', 'In Progress')
    AND assigned_to IS NOT NULL
GROUP BY assigned_to
ORDER BY open_tickets_count DESC;
