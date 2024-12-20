WITH parameters AS (
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
hrb AS (
    SELECT
        rb.id,
        rb.checkin_date,
        rb.checkout_date,
        rb.state,
        rb.partner_id,
        rp.name AS partner_name,
        rbl.room_id,
        hr.room_type_name AS room_type_id,
        hr.company_id,
        rc.name AS company_name
    FROM room_booking rb
    JOIN room_booking_line rbl ON rbl.booking_id = rb.id
    JOIN hotel_room hr ON rbl.room_id = hr.id
    JOIN res_company rc ON hr.company_id = rc.id
    LEFT JOIN res_partner rp ON rb.partner_id = rp.id
),
partner_dates AS (
    SELECT DISTINCT
        hrb.partner_id,
        hrb.partner_name,
        ds.report_date,
        rt.room_type_id,
        hrb.company_id,
        hrb.company_name
    FROM date_series ds
    CROSS JOIN room_types rt
    JOIN hrb ON hrb.room_type_id = rt.room_type_id
                 AND (
                     (hrb.checkin_date::date <= ds.report_date AND hrb.checkout_date::date > ds.report_date)
                     OR hrb.checkin_date::date = ds.report_date
                     OR hrb.checkout_date::date = ds.report_date
                 )
),
in_house AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        hrb.partner_id,
        hrb.partner_name,
        hrb.company_id,
        hrb.company_name,
        COUNT(DISTINCT hrb.id) AS in_house
    FROM date_series ds
    CROSS JOIN room_types rt
    JOIN hrb ON hrb.checkin_date::date <= ds.report_date
                  AND hrb.checkout_date::date > ds.report_date
                  AND hrb.state = 'check_in'
                  AND hrb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id, hrb.partner_id, hrb.partner_name, hrb.company_id, hrb.company_name
),
expected_arrivals AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        hrb.partner_id,
        hrb.partner_name,
        hrb.company_id,
        hrb.company_name,
        COUNT(DISTINCT hrb.id) AS expected_arrivals
    FROM date_series ds
    CROSS JOIN room_types rt
    JOIN hrb ON hrb.checkin_date::date = ds.report_date
                  AND hrb.state IN ('confirmed', 'block')
                  AND hrb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id, hrb.partner_id, hrb.partner_name, hrb.company_id, hrb.company_name
),
expected_departures AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        hrb.partner_id,
        hrb.partner_name,
        hrb.company_id,
        hrb.company_name,
        COUNT(DISTINCT hrb.id) AS expected_departures
    FROM date_series ds
    CROSS JOIN room_types rt
    JOIN hrb ON hrb.checkout_date::date = ds.report_date
                  AND hrb.state = 'check_in'
                  AND hrb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id, hrb.partner_id, hrb.partner_name, hrb.company_id, hrb.company_name
),
daily_data AS (
    SELECT
        pd.report_date,
        pd.room_type_id,
        pd.partner_id,
        pd.partner_name,
        pd.company_id,
        pd.company_name,
        COALESCE(ih.in_house, 0) AS in_house,
        COALESCE(ea.expected_arrivals, 0) AS expected_arrivals,
        COALESCE(ed.expected_departures, 0) AS expected_departures
    FROM partner_dates pd
    LEFT JOIN in_house ih ON pd.report_date = ih.report_date AND pd.room_type_id = ih.room_type_id AND pd.partner_id = ih.partner_id AND pd.company_id = ih.company_id
    LEFT JOIN expected_arrivals ea ON pd.report_date = ea.report_date AND pd.room_type_id = ea.room_type_id AND pd.partner_id = ea.partner_id AND pd.company_id = ea.company_id
    LEFT JOIN expected_departures ed ON pd.report_date = ed.report_date AND pd.room_type_id = ed.room_type_id AND pd.partner_id = ed.partner_id AND pd.company_id = ed.company_id
),
expected_in_house_data AS (
    SELECT
        dd.*,
        SUM(dd.expected_arrivals - dd.expected_departures) OVER (
            PARTITION BY dd.room_type_id, dd.partner_id, dd.company_id ORDER BY dd.report_date
            ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW
        ) + dd.in_house AS expected_in_house
    FROM daily_data dd
),
total_rooms AS (
    SELECT
        tr.report_date,
        rt.room_type_id,
        rt.room_type_name,
        hr.company_id,
        rc.name AS company_name,
        COUNT(hr.id) AS total_rooms
    FROM date_series tr
    CROSS JOIN room_types rt
    LEFT JOIN hotel_room hr ON hr.room_type_name = rt.room_type_id
    LEFT JOIN res_company rc ON hr.company_id = rc.id
    GROUP BY tr.report_date, rt.room_type_id, rt.room_type_name, hr.company_id, rc.name
),
out_of_order_rooms AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        hr.company_id,
        rc.name AS company_name,
        COUNT(DISTINCT ooom.room_number) AS out_of_order_count
    FROM date_series ds
    CROSS JOIN room_types rt
    LEFT JOIN out_of_order_management ooom ON ds.report_date BETWEEN ooom.from_date AND ooom.to_date
    LEFT JOIN hotel_room hr ON ooom.room_number = hr.id AND hr.room_type_name = rt.room_type_id
    LEFT JOIN res_company rc ON hr.company_id = rc.id
    GROUP BY ds.report_date, rt.room_type_id, hr.company_id, rc.name
),
available_rooms AS (
    SELECT
        tr.report_date,
        tr.room_type_id,
        tr.company_id,
        tr.company_name,
        tr.total_rooms - COALESCE(oor.out_of_order_count, 0) AS available_rooms
    FROM total_rooms tr
    LEFT JOIN out_of_order_rooms oor ON tr.report_date = oor.report_date AND tr.room_type_id = oor.room_type_id AND tr.company_id = oor.company_id
),
reserved AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        hrb.partner_id,
        hrb.partner_name,
        hrb.company_id,
        hrb.company_name,
        COUNT(DISTINCT hrb.id) AS reserved_count
    FROM date_series ds
    CROSS JOIN room_types rt
    JOIN hrb ON hrb.checkin_date::date > ds.report_date
                  AND hrb.state IN ('confirmed', 'block')
                  AND hrb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id, hrb.partner_id, hrb.partner_name, hrb.company_id, hrb.company_name
),
overbooked_count AS (
    SELECT
        ds.report_date,
        rt.room_type_id,
        hrb.partner_id,
        hrb.partner_name,
        hrb.company_id,
        hrb.company_name,
        COUNT(DISTINCT hrb.id) AS overbooked_count
    FROM date_series ds
    CROSS JOIN room_types rt
    JOIN hrb ON hrb.checkin_date::date <= ds.report_date
                  AND hrb.checkout_date::date > ds.report_date
                  AND hrb.state = 'waiting'
                  AND hrb.room_type_id = rt.room_type_id
    GROUP BY ds.report_date, rt.room_type_id, hrb.partner_id, hrb.partner_name, hrb.company_id, hrb.company_name
)
SELECT
    eih.company_id AS "Company ID",
    eih.company_name AS "Company Name",
    eih.report_date AS "Date",
    COALESCE(rt.room_type_name, 'Total') AS "Room Type",
    eih.partner_name AS "Partner Name",
    eih.partner_id AS "Partner ID",
    SUM(tr.total_rooms) AS "Total Rooms",
    SUM(ar.available_rooms) AS "Available Rooms",
    SUM(eih.in_house) AS "In House",
    SUM(eih.expected_arrivals) AS "Expected Arrivals",
    SUM(eih.expected_departures) AS "Expected Departures",
    SUM(eih.expected_in_house) AS "Expected In House",
    SUM(COALESCE(res.reserved_count, 0)) AS "Reserved",
    ROUND((SUM(eih.expected_in_house::numeric) / NULLIF(SUM(tr.total_rooms::numeric), 0)) * 100, 2) AS "Expected Occupied Rate (%)",
    SUM(COALESCE(oor.out_of_order_count, 0)) AS "Out of Order Count",
    SUM(COALESCE(obc.overbooked_count, 0)) AS "Overbooked Count",
    SUM(ar.available_rooms - eih.expected_in_house) AS "Free to Sell",
    CASE WHEN rt.room_type_name IS NULL THEN 1 ELSE 0 END AS sort_order
FROM expected_in_house_data eih
LEFT JOIN room_types rt ON eih.room_type_id = rt.room_type_id
LEFT JOIN total_rooms tr ON eih.report_date = tr.report_date AND eih.room_type_id = tr.room_type_id AND eih.company_id = tr.company_id
LEFT JOIN available_rooms ar ON eih.report_date = ar.report_date AND eih.room_type_id = ar.room_type_id AND eih.company_id = ar.company_id
LEFT JOIN reserved res ON eih.report_date = res.report_date AND eih.room_type_id = res.room_type_id AND eih.partner_id = res.partner_id AND eih.company_id = res.company_id
LEFT JOIN out_of_order_rooms oor ON eih.report_date = oor.report_date AND eih.room_type_id = oor.room_type_id AND eih.company_id = oor.company_id
LEFT JOIN overbooked_count obc ON eih.report_date = obc.report_date AND eih.room_type_id = obc.room_type_id AND eih.partner_id = obc.partner_id AND eih.company_id = obc.company_id
GROUP BY eih.company_id, eih.company_name, eih.report_date, rt.room_type_name, eih.partner_name, eih.partner_id, sort_order
ORDER BY eih.company_id, eih.report_date, sort_order, rt.room_type_name, eih.partner_name;