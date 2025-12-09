-- view all tickets
SELECT * 
FROM tickets;


-- total number of tickets 
SELECT COUNT(*) AS total_tickets  
FROM tickets;


-- count issue types
SELECT issue_type, COUNT(*) AS issue_count
FROM tickets
GROUP BY issue_type
ORDER BY issue_count DESC;


-- count the issues for each specialist
SELECT assigned_to, COUNT(*) AS issue_count
FROM tickets
GROUP BY assigned_to
ORDER BY issue_count DESC;


-- count tickets by status
SELECT status, COUNT(*) AS ticket_count
FROM tickets
GROUP BY status
ORDER BY ticket_count DESC;


-- count tickets by priority
SELECT priority, COUNT(*) as priority_count
FROM tickets
GROUP BY priority
ORDER BY
	CASE priority
		WHEN 'Critical' THEN 1
		WHEN 'High' THEN 2
		WHEN 'Medium' THEN 3
		ELSE 4
	END;


-- find all opened tickets
SELECT 
    ticket_id,
    subject,
    priority,
    created_at,
    assigned_to
FROM tickets
WHERE status = 'Open';


-- find critical / high priority tickets
SELECT    
    ticket_id,
    subject,
    priority,
    created_at,
    assigned_to
FROM tickets
WHERE priority IN ('Critical', 'High')
ORDER BY 
    CASE priority
        WHEN 'Critical' THEN 1
        WHEN 'High' THEN 2
    END;


-- find tickets by issue type
SELECT 
    ticket_id,
    subject,
    priority,
    created_at,
    assigned_to
FROM tickets
WHERE issue_type = 'Application';


-- resolution time for closed tickets
SELECT 
    ticket_id,
    subject,
    created_at,
    resolved_at,
    DATEDIFF(HOUR, created_at, resolved_at) AS resolution_hours,
    DATEDIFF(DAY, created_at, resolved_at) AS resolution_days
FROM tickets
WHERE status = 'Closed' AND resolved_at IS NOT NULL;


-- calc average resolution time for closed cases based on priority
SELECT 
    priority, 
    AVG(DATEDIFF(DAY, created_at, resolved_at)) AS avg_resolution_days 
FROM tickets
GROUP BY priority
ORDER BY avg_resolution_days;


-- calc average resolution time for closed cases based on issue_type
SELECT 
    issue_type, 
    AVG(DATEDIFF(DAY, created_at, resolved_at)) AS avg_resolution_days 
FROM tickets
GROUP BY issue_type
ORDER BY avg_resolution_days;


-- group by multiple columns
SELECT
    priority,
    issue_type,
    COUNT(*) AS ticket_count,
    MIN(created_at) AS first_ticket,
    MAX(created_at) AS latest_ticket
FROM tickets
GROUP BY priority, issue_type
ORDER BY priority, ticket_count DESC;


-- percentage of resolved tickets (completion rate)
SELECT 
    COUNT(*) AS total_tickets,
    SUM(CASE WHEN resolved_at IS NOT NULL THEN 1 ELSE 0 END) AS resolved_tickets,
    ROUND(
        100.0 * SUM(CASE WHEN resolved_at IS NOT NULL THEN 1 ELSE 0 END) / COUNT(*), 
        2
    ) AS resolution_completion_rate_percent
FROM tickets;


-- date range of tickets
SELECT 
    MIN(created_at) AS oldest_ticket_date,
    MAX(created_at) AS newest_ticket_date,
    DATEDIFF(DAY, MIN(created_at), MAX(created_at)) AS date_range_days
FROM tickets;