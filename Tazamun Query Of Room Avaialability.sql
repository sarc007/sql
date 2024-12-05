WITH RECURSIVE
parameters AS (
    SELECT
                    (SELECT MIN(checkin_date::date) FROM room_booking) AS from_date,
                    (SELECT MAX(checkout_date::date) FROM room_booking) AS to_date,
                    NULL::integer AS selected_room_type
            ),
date_series AS (
    SELECT generate_series(p.from_date, p.to_date, interval '1 day') AS report_date
    FROM parameters p
),
room_types AS (
    SELECT rt.id AS room_type_id,
           rt.room_type AS room_type_code, 
           rt.description AS room_type_name
    FROM room_type rt
),
-- Combine room_booking and room_booking_line to get room_id and room_type_id
hrb AS (
    SELECT
        rb.id,
        rb.checkin_date,
        rb.checkout_date,
        rb.state,
        rbl.room_id,
        hr.room_type_name as room_type_id
    FROM room_booking rb
    JOIN room_booking_line rbl ON rbl.booking_id = rb.id
    JOIN hotel_room hr ON rbl.room_id = hr.id
    WHERE COALESCE(rb.parent_booking_name, '') <> ''
),
total_rooms AS (
    SELECT
        tr.report_date,
        rt.room_type_id,
        rt.room_type_name,
        SUM(hi.total_room_count) AS total_rooms
    FROM date_series tr
    CROSS JOIN room_types rt
    LEFT JOIN hotel_inventory hi ON hi.room_type = rt.room_type_id
    GROUP BY GROUPING SETS ((tr.report_date, rt.room_type_id, rt.room_type_name), (tr.report_date))
),
overbooking_rooms AS (
    SELECT
        rt.room_type_id,
        SUM(hi.overbooking_rooms) AS overbooking_rooms
    FROM room_types rt
    LEFT JOIN hotel_inventory hi ON hi.room_type = rt.room_type_id
    GROUP BY rt.room_type_id
),
out_of_order_rooms AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        COUNT(DISTINCT ooom.room_number) AS out_of_order_count
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN out_of_order_management ooom ON ds.report_date BETWEEN ooom.from_date AND ooom.to_date
    LEFT JOIN hotel_room hr ON ooom.room_number = hr.id AND hr.room_type_name = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id
),
available_rooms AS (
    SELECT
        tr.report_date,
        tr.room_type_id,
        tr.total_rooms - COALESCE(oor.out_of_order_count, 0) AS available_rooms
    FROM total_rooms tr
    LEFT JOIN out_of_order_rooms oor ON tr.report_date = oor.report_date AND tr.room_type_id = oor.room_type_id
),
in_house AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        COUNT(DISTINCT rb.id) AS in_house
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN hrb rb ON rb.checkin_date::date <= ds.report_date
                      AND rb.checkout_date::date > ds.report_date
                      AND rb.state = 'check_in'
                      AND rb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id
),
expected_arrivals AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        COUNT(DISTINCT rb.id) AS expected_arrivals
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN hrb rb ON rb.checkin_date::date = ds.report_date
                      AND rb.state IN ('confirmed', 'block')
                      AND rb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id
),
expected_departures AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        COUNT(DISTINCT rb.id) AS expected_departures
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN hrb rb ON rb.checkout_date::date = ds.report_date
                      AND rb.state = 'check_in'
                      AND rb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id
),
dates_with_data AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        COALESCE(ih.in_house, 0) AS in_house,
        COALESCE(ea.expected_arrivals, 0) AS expected_arrivals,
        COALESCE(ed.expected_departures, 0) AS expected_departures
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN in_house ih ON ds.report_date = ih.report_date AND rt.room_type_id = ih.room_type_id
    LEFT JOIN expected_arrivals ea ON ds.report_date = ea.report_date AND rt.room_type_id = ea.room_type_id
    LEFT JOIN expected_departures ed ON ds.report_date = ed.report_date AND rt.room_type_id = ed.room_type_id
),
expected_in_house_recursive AS (
    SELECT
        dd.report_date,
        dd.room_type_id,
        dd.in_house,
        dd.expected_arrivals,
        dd.expected_departures,
        (dd.in_house + dd.expected_arrivals - dd.expected_departures) AS expected_in_house
    FROM dates_with_data dd
    WHERE dd.report_date = (SELECT MIN(report_date) FROM dates_with_data)

    UNION ALL

    SELECT
        dd.report_date,
        dd.room_type_id,
        eir.expected_in_house AS in_house,
        dd.expected_arrivals,
        dd.expected_departures,
        (eir.expected_in_house + dd.expected_arrivals - dd.expected_departures) AS expected_in_house
    FROM expected_in_house_recursive eir
    JOIN dates_with_data dd ON dd.report_date = eir.report_date + INTERVAL '1 day' AND dd.room_type_id = eir.room_type_id
),
reserved AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        COUNT(DISTINCT rb.id) AS reserved_count
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN hrb rb ON rb.checkin_date::date > ds.report_date
                      AND rb.state IN ('confirmed', 'block')
                      AND rb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id
),
overbooked_count AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        COUNT(DISTINCT rb.id) AS overbooked_count
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN hrb rb ON rb.checkin_date::date <= ds.report_date
                      AND rb.checkout_date::date > ds.report_date
                      AND rb.state = 'waiting'
                      AND rb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id
)
SELECT
    eir.report_date AS "Date",
    COALESCE(rt.room_type_name, 'Total') AS "Room Type",
    SUM(tr.total_rooms) AS "Total Rooms",
    SUM(ar.available_rooms) AS "Available Rooms",
    SUM(eir.in_house) AS "In House",
    SUM(eir.expected_arrivals) AS "Expected Arrivals",
    SUM(eir.expected_departures) AS "Expected Departures",
    SUM(eir.expected_in_house) AS "Expected In House",
    SUM(COALESCE(res.reserved_count, 0)) AS "Reserved",
    ROUND((SUM(eir.expected_in_house::numeric) / NULLIF(SUM(tr.total_rooms::numeric), 0)) * 100, 2) AS "Expected Occupied Rate (%)",
    SUM(COALESCE(oor.out_of_order_count, 0)) AS "Out of Order Count",
    SUM(COALESCE(obc.overbooked_count, 0)) AS "Overbooked Count",
    SUM(ar.available_rooms - eir.expected_in_house) AS "Free to Sell",
    CASE WHEN rt.room_type_name IS NULL THEN 1 ELSE 0 END AS sort_order -- Added for sorting
FROM expected_in_house_recursive eir
LEFT JOIN room_types rt ON eir.room_type_id = rt.room_type_id
LEFT JOIN total_rooms tr ON eir.report_date = tr.report_date AND eir.room_type_id = tr.room_type_id
LEFT JOIN available_rooms ar ON eir.report_date = ar.report_date AND eir.room_type_id = ar.room_type_id
LEFT JOIN reserved res ON eir.report_date = res.report_date AND eir.room_type_id = res.room_type_id
LEFT JOIN out_of_order_rooms oor ON eir.report_date = oor.report_date AND eir.room_type_id = oor.room_type_id
LEFT JOIN overbooked_count obc ON eir.report_date = obc.report_date AND eir.room_type_id = obc.room_type_id
GROUP BY GROUPING SETS ((eir.report_date, rt.room_type_name, sort_order), (eir.report_date, sort_order))
ORDER BY eir.report_date, sort_order, rt.room_type_name
