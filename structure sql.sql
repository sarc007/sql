CREATE TABLE IF NOT EXISTS public.hotel_room
(
    id integer NOT NULL DEFAULT nextval('hotel_room_id_seq'::regclass),
    block integer,
    user_sort integer,
    max_pax integer,
    rate_code integer,
    room_type_name integer,
    hotel_id integer,
    uom_id integer NOT NULL,
    floor_id integer,
    num_person integer NOT NULL,
    company_id integer NOT NULL,
    create_uid integer,
    write_uid integer,
    door_sign character varying COLLATE pg_catalog."default",
    connected_room character varying COLLATE pg_catalog."default",
    type_of_bed character varying COLLATE pg_catalog."default",
    type_of_bath character varying COLLATE pg_catalog."default",
    building character varying COLLATE pg_catalog."default",
    pending_repairs character varying COLLATE pg_catalog."default",
    section_hk character varying COLLATE pg_catalog."default",
    telephone_ext character varying COLLATE pg_catalog."default",
    disability_features character varying COLLATE pg_catalog."default",
    extra_features character varying COLLATE pg_catalog."default",
    rate_posting_item character varying COLLATE pg_catalog."default",
    status character varying COLLATE pg_catalog."default",
    room_type character varying COLLATE pg_catalog."default" NOT NULL,
    last_repairs date,
    name character varying COLLATE pg_catalog."default",
    description jsonb,
    room_description text COLLATE pg_catalog."default",
    notes text COLLATE pg_catalog."default",
    list_price numeric,
    suite boolean,
    obsolete boolean,
    no_smoking boolean,
    is_room_avail boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    fsm_location integer,
    checkin_date timestamp without time zone,
    checkout_date timestamp without time zone,
    housekeeping_status integer,
    maintenance_status integer,
    housekeeping_staff_status integer,
    CONSTRAINT hotel_room_pkey PRIMARY KEY (id),
    CONSTRAINT hotel_room_company_id_fkey FOREIGN KEY (company_id)
        REFERENCES public.res_company (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT hotel_room_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_floor_id_fkey FOREIGN KEY (floor_id)
        REFERENCES public.hotel_floor (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_fsm_location_fkey FOREIGN KEY (fsm_location)
        REFERENCES public.fsm_location (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_hotel_id_fkey FOREIGN KEY (hotel_id)
        REFERENCES public.hotel_hotel (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_housekeeping_staff_status_fkey FOREIGN KEY (housekeeping_staff_status)
        REFERENCES public.housekeeping_staff_status (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_housekeeping_status_fkey FOREIGN KEY (housekeeping_status)
        REFERENCES public.housekeeping_status (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_maintenance_status_fkey FOREIGN KEY (maintenance_status)
        REFERENCES public.maintenance_status (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_rate_code_fkey FOREIGN KEY (rate_code)
        REFERENCES public.rate_code (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_room_type_name_fkey FOREIGN KEY (room_type_name)
        REFERENCES public.room_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_room_uom_id_fkey FOREIGN KEY (uom_id)
        REFERENCES public.uom_uom (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT hotel_room_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

CREATE TABLE IF NOT EXISTS public.hotel_inventory
(
    id integer NOT NULL DEFAULT nextval('hotel_inventory_id_seq'::regclass),
    hotel_name integer,
    room_type integer,
    total_room_count integer,
    pax integer,
    age_threshold integer,
    web_allowed_reservations integer,
    overbooking_rooms integer,
    company_id integer,
    create_uid integer,
    write_uid integer,
    overbooking_allowed boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT hotel_inventory_pkey PRIMARY KEY (id),
    CONSTRAINT hotel_inventory_company_id_fkey FOREIGN KEY (company_id)
        REFERENCES public.res_company (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_inventory_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_inventory_room_type_fkey FOREIGN KEY (room_type)
        REFERENCES public.room_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT hotel_inventory_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

CREATE TABLE IF NOT EXISTS public.room_booking
(
    id integer NOT NULL DEFAULT nextval('room_booking_id_seq'::regclass),
    meal_pattern integer,
    group_booking_id integer,
    hotel_id integer,
    group_booking integer,
    agent integer,
    company_id integer,
    partner_id integer,
    duration integer,
    hotel_invoice_id integer,
    pricelist_id integer,
    account_move integer,
    nationality integer,
    source_of_business integer,
    market_segment integer,
    rate_code integer,
    vip_code integer,
    room_count integer,
    adult_count integer,
    child_count integer,
    total_people integer,
    rooms_to_add integer,
    create_uid integer,
    write_uid integer,
    name character varying COLLATE pg_catalog."default",
    hotel_policy character varying COLLATE pg_catalog."default",
    invoice_status character varying COLLATE pg_catalog."default",
    state character varying COLLATE pg_catalog."default",
    passport character varying COLLATE pg_catalog."default",
    id_number character varying COLLATE pg_catalog."default",
    payment_type character varying COLLATE pg_catalog."default",
    amount_untaxed numeric,
    amount_tax numeric,
    amount_total numeric,
    is_vip boolean,
    is_agent boolean,
    is_checkin boolean,
    maintenance_request_sent boolean,
    invoice_button_visible boolean,
    need_service boolean,
    need_fleet boolean,
    need_food boolean,
    need_event boolean,
    house_use boolean,
    is_customer_company boolean,
    vip boolean,
    show_vip_code boolean,
    complementary boolean,
    date_order timestamp without time zone NOT NULL,
    checkin_date timestamp without time zone NOT NULL,
    checkout_date timestamp without time zone NOT NULL,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    duration_visible double precision,
    parent_booking character varying COLLATE pg_catalog."default",
    parent_booking_name character varying COLLATE pg_catalog."default",
    room_type_name integer,
    is_button_clicked boolean,
    room_price double precision,
    meal_price double precision,
    hide_fields boolean,
    show_confirm_button boolean,
    show_cancel_button boolean,
    reference_contact integer,
    hotel_room_type integer,
    monday_pax_1 double precision,
    monday_pax_1_rb double precision,
    tuesday_pax_1_rb double precision,
    wednesday_pax_1_rb double precision,
    thursday_pax_1_rb double precision,
    friday_pax_1_rb double precision,
    saturday_pax_1_rb double precision,
    sunday_pax_1_rb double precision,
    monday_pax_2_rb double precision,
    monday_pax_3_rb double precision,
    monday_pax_4_rb double precision,
    monday_pax_5_rb double precision,
    monday_pax_6_rb double precision,
    tuesday_pax_2_rb double precision,
    tuesday_pax_3_rb double precision,
    tuesday_pax_4_rb double precision,
    tuesday_pax_5_rb double precision,
    tuesday_pax_6_rb double precision,
    wednesday_pax_2_rb double precision,
    wednesday_pax_3_rb double precision,
    wednesday_pax_4_rb double precision,
    wednesday_pax_5_rb double precision,
    wednesday_pax_6_rb double precision,
    thursday_pax_2_rb double precision,
    thursday_pax_3_rb double precision,
    thursday_pax_4_rb double precision,
    thursday_pax_5_rb double precision,
    thursday_pax_6_rb double precision,
    friday_pax_2_rb double precision,
    friday_pax_3_rb double precision,
    friday_pax_4_rb double precision,
    friday_pax_5_rb double precision,
    friday_pax_6_rb double precision,
    saturday_pax_2_rb double precision,
    saturday_pax_3_rb double precision,
    saturday_pax_4_rb double precision,
    saturday_pax_5_rb double precision,
    saturday_pax_6_rb double precision,
    sunday_pax_2_rb double precision,
    sunday_pax_3_rb double precision,
    sunday_pax_4_rb double precision,
    sunday_pax_5_rb double precision,
    sunday_pax_6_rb double precision,
    pax_1_rb double precision,
    pax_2_rb double precision,
    pax_3_rb double precision,
    pax_4_rb double precision,
    pax_5_rb double precision,
    pax_6_rb double precision,
    is_room_line_readonly boolean,
    no_show_ boolean,
    reservation_status_id integer,
    reservation_status_count_as character varying COLLATE pg_catalog."default",
    parent_booking_id integer,
    reference_contact_ character varying COLLATE pg_catalog."default",
    CONSTRAINT room_booking_pkey PRIMARY KEY (id),
    CONSTRAINT room_booking_agent_fkey FOREIGN KEY (agent)
        REFERENCES public.agent_agent (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_company_id_fkey FOREIGN KEY (company_id)
        REFERENCES public.res_company (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_group_booking_fkey FOREIGN KEY (group_booking)
        REFERENCES public.group_booking (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_group_booking_id_fkey FOREIGN KEY (group_booking_id)
        REFERENCES public.group_booking (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE CASCADE,
    CONSTRAINT room_booking_hotel_id_fkey FOREIGN KEY (hotel_id)
        REFERENCES public.hotel_hotel (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_hotel_invoice_id_fkey FOREIGN KEY (hotel_invoice_id)
        REFERENCES public.account_move (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_hotel_room_type_fkey FOREIGN KEY (hotel_room_type)
        REFERENCES public.room_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_market_segment_fkey FOREIGN KEY (market_segment)
        REFERENCES public.market_segment (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_meal_pattern_fkey FOREIGN KEY (meal_pattern)
        REFERENCES public.meal_pattern (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_nationality_fkey FOREIGN KEY (nationality)
        REFERENCES public.res_country (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_parent_booking_id_fkey FOREIGN KEY (parent_booking_id)
        REFERENCES public.room_booking (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_partner_id_fkey FOREIGN KEY (partner_id)
        REFERENCES public.res_partner (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_pricelist_id_fkey FOREIGN KEY (pricelist_id)
        REFERENCES public.product_pricelist (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_rate_code_fkey FOREIGN KEY (rate_code)
        REFERENCES public.rate_code (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_reference_contact_fkey FOREIGN KEY (reference_contact)
        REFERENCES public.res_partner (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_reservation_status_id_fkey FOREIGN KEY (reservation_status_id)
        REFERENCES public.reservation_status_code (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_room_type_name_fkey FOREIGN KEY (room_type_name)
        REFERENCES public.room_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_source_of_business_fkey FOREIGN KEY (source_of_business)
        REFERENCES public.source_business (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_vip_code_fkey FOREIGN KEY (vip_code)
        REFERENCES public.vip_code (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_booking_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)


CREATE TABLE IF NOT EXISTS public.housekeeping_management
(
    id integer NOT NULL DEFAULT nextval('housekeeping_management_id_seq'::regclass),
    room_type integer,
    changed_linen integer,
    changed_towels integer,
    pax integer,
    child integer,
    infant integer,
    create_uid integer,
    write_uid integer,
    room_number integer,
    floor_number character varying COLLATE pg_catalog."default",
    section_hk character varying COLLATE pg_catalog."default",
    block character varying COLLATE pg_catalog."default",
    building character varying COLLATE pg_catalog."default",
    room_status character varying COLLATE pg_catalog."default",
    reason character varying COLLATE pg_catalog."default",
    housekeeping_status character varying COLLATE pg_catalog."default",
    repair_ends_by date,
    pending_repairs text COLLATE pg_catalog."default",
    clean boolean,
    out_of_service boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    room_fsm_location integer,
    CONSTRAINT housekeeping_management_pkey PRIMARY KEY (id),
    CONSTRAINT housekeeping_management_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT housekeeping_management_room_fsm_location_fkey FOREIGN KEY (room_fsm_location)
        REFERENCES public.fsm_location (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT housekeeping_management_room_number_fkey FOREIGN KEY (room_number)
        REFERENCES public.room_number_store (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT housekeeping_management_room_type_fkey FOREIGN KEY (room_type)
        REFERENCES public.room_type (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT housekeeping_management_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)


CREATE TABLE IF NOT EXISTS public.out_of_order_management
(
    id integer NOT NULL DEFAULT nextval('out_of_order_management_id_seq'::regclass),
    create_uid integer,
    write_uid integer,
    room_number integer,
    out_of_order_code character varying COLLATE pg_catalog."default",
    authorization_code character varying COLLATE pg_catalog."default",
    from_date date NOT NULL,
    to_date date NOT NULL,
    comments text COLLATE pg_catalog."default",
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    room_fsm_location integer,
    CONSTRAINT out_of_order_management_pkey PRIMARY KEY (id),
    CONSTRAINT out_of_order_management_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT out_of_order_management_room_fsm_location_fkey FOREIGN KEY (room_fsm_location)
        REFERENCES public.fsm_location (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT out_of_order_management_room_number_fkey FOREIGN KEY (room_number)
        REFERENCES public.room_number_store (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT out_of_order_management_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

CREATE TABLE IF NOT EXISTS public.room_on_hold_code
(
    id integer NOT NULL DEFAULT nextval('room_on_hold_code_id_seq'::regclass),
    user_sort integer,
    create_uid integer,
    write_uid integer,
    code character varying COLLATE pg_catalog."default" NOT NULL,
    description character varying COLLATE pg_catalog."default" NOT NULL,
    abbreviation character varying COLLATE pg_catalog."default",
    arabic_description character varying COLLATE pg_catalog."default",
    arabic_abbreviation character varying COLLATE pg_catalog."default",
    obsolete boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT room_on_hold_code_pkey PRIMARY KEY (id),
    CONSTRAINT room_on_hold_code_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_on_hold_code_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)
CREATE TABLE IF NOT EXISTS public.room_type
(
    id integer NOT NULL DEFAULT nextval('room_type_id_seq'::regclass),
    user_sort integer,
    create_uid integer,
    write_uid integer,
    room_type character varying COLLATE pg_catalog."default" NOT NULL,
    description character varying COLLATE pg_catalog."default",
    abbreviation character varying COLLATE pg_catalog."default",
    generic_type character varying COLLATE pg_catalog."default",
    obsolete boolean,
    create_date timestamp without time zone,
    write_date timestamp without time zone,
    CONSTRAINT room_type_pkey PRIMARY KEY (id),
    CONSTRAINT room_type_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT room_type_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL
)

CREATE TABLE IF NOT EXISTS public.res_partner
(
    id integer NOT NULL DEFAULT nextval('res_partner_id_seq'::regclass),
    company_id integer,
    create_date timestamp without time zone,
    name character varying COLLATE pg_catalog."default",
    title integer,
    parent_id integer,
    user_id integer,
    state_id integer,
    country_id integer,
    industry_id integer,
    color integer,
    commercial_partner_id integer,
    create_uid integer,
    write_uid integer,
    complete_name character varying COLLATE pg_catalog."default",
    ref character varying COLLATE pg_catalog."default",
    lang character varying COLLATE pg_catalog."default",
    tz character varying COLLATE pg_catalog."default",
    vat character varying COLLATE pg_catalog."default",
    company_registry character varying COLLATE pg_catalog."default",
    website character varying COLLATE pg_catalog."default",
    function character varying COLLATE pg_catalog."default",
    type character varying COLLATE pg_catalog."default",
    street character varying COLLATE pg_catalog."default",
    street2 character varying COLLATE pg_catalog."default",
    zip character varying COLLATE pg_catalog."default",
    city character varying COLLATE pg_catalog."default",
    email character varying COLLATE pg_catalog."default",
    phone character varying COLLATE pg_catalog."default",
    mobile character varying COLLATE pg_catalog."default",
    commercial_company_name character varying COLLATE pg_catalog."default",
    company_name character varying COLLATE pg_catalog."default",
    date date,
    comment text COLLATE pg_catalog."default",
    partner_latitude numeric,
    partner_longitude numeric,
    active boolean,
    employee boolean,
    is_company boolean,
    partner_share boolean,
    write_date timestamp without time zone,
    message_bounce integer,
    email_normalized character varying COLLATE pg_catalog."default",
    signup_type character varying COLLATE pg_catalog."default",
    signup_expiration timestamp without time zone,
    signup_token character varying COLLATE pg_catalog."default",
    plan_to_change_car boolean,
    plan_to_change_bike boolean,
    partner_gid integer,
    additional_info character varying COLLATE pg_catalog."default",
    phone_sanitized character varying COLLATE pg_catalog."default",
    supplier_rank integer,
    customer_rank integer,
    invoice_warn character varying COLLATE pg_catalog."default",
    invoice_warn_msg text COLLATE pg_catalog."default",
    debit_limit numeric,
    last_time_entries_checked timestamp without time zone,
    ubl_cii_format character varying COLLATE pg_catalog."default",
    peppol_endpoint character varying COLLATE pg_catalog."default",
    peppol_eas character varying COLLATE pg_catalog."default",
    rate_code integer,
    source_of_business integer,
    nationality integer,
    is_vip boolean,
    date_localization date,
    service_location_id integer,
    fsm_location boolean,
    fsm_person boolean,
    buyer_id integer,
    purchase_warn character varying COLLATE pg_catalog."default",
    purchase_warn_msg text COLLATE pg_catalog."default",
    hashed_password character varying COLLATE pg_catalog."default",
    market_segments integer,
    meal_pattern integer,
    max_pax integer,
    CONSTRAINT res_partner_pkey PRIMARY KEY (id),
    CONSTRAINT res_partner_buyer_id_fkey FOREIGN KEY (buyer_id)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_commercial_partner_id_fkey FOREIGN KEY (commercial_partner_id)
        REFERENCES public.res_partner (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_company_id_fkey FOREIGN KEY (company_id)
        REFERENCES public.res_company (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_country_id_fkey FOREIGN KEY (country_id)
        REFERENCES public.res_country (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT res_partner_create_uid_fkey FOREIGN KEY (create_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_industry_id_fkey FOREIGN KEY (industry_id)
        REFERENCES public.res_partner_industry (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_market_segments_fkey FOREIGN KEY (market_segments)
        REFERENCES public.market_segment (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_meal_pattern_fkey FOREIGN KEY (meal_pattern)
        REFERENCES public.meal_pattern (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_nationality_fkey FOREIGN KEY (nationality)
        REFERENCES public.res_country (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_parent_id_fkey FOREIGN KEY (parent_id)
        REFERENCES public.res_partner (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_rate_code_fkey FOREIGN KEY (rate_code)
        REFERENCES public.rate_code (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_service_location_id_fkey FOREIGN KEY (service_location_id)
        REFERENCES public.fsm_location (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_source_of_business_fkey FOREIGN KEY (source_of_business)
        REFERENCES public.source_business (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_state_id_fkey FOREIGN KEY (state_id)
        REFERENCES public.res_country_state (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE RESTRICT,
    CONSTRAINT res_partner_title_fkey FOREIGN KEY (title)
        REFERENCES public.res_partner_title (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_user_id_fkey FOREIGN KEY (user_id)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_write_uid_fkey FOREIGN KEY (write_uid)
        REFERENCES public.res_users (id) MATCH SIMPLE
        ON UPDATE NO ACTION
        ON DELETE SET NULL,
    CONSTRAINT res_partner_check_name CHECK (type::text = 'contact'::text AND name IS NOT NULL OR type::text <> 'contact'::text)
)

--------------------------------------------------------------------------------
-- TODO write a query to get a daily basis report for the following
-- 1. Parameters:  from and to date, all rooms tyoes or selected room type. 
-- 2. Fields to show: Date, Total Rooms, Available, In House, Reserved (in confirmed or blocked status all the bookings are reserved ),
 --Expected Occupied is either by total rooms or available rooms,  out of order count, Over Booked count, expected occupied,  
-- 3. in the query use housekeeping management and maintenance manangement tables already in the system 
-- 4. remove dirty rooms from the query 
-- 5. in progress status does not exist in hotel management system
-- 6. out of service status is there  Not needed
-- 7. out of order has date 
-- 8. in house is the checkedin in the past and not yet checked out 
-- 9. expected in house = inhouse + expected arrive - expected departure
-- 10. in house numbers will come from if somebody's checked in till his reservation date 
-- 11. in house = expected in house of the previous day 
-- 12. expected occupied = in house / total rooms 
-- 13. expected occupied = in house / available rooms
-- 14. out of order count 
-- 15. overbooking (total inventory of rooms + allowed overbooking) = reserved - availble rooms 
-- 16. free to sell = available rooms - expected inhouse
-- 17. available rooms = total rooms - just the out of order - rooms on hold
-- 18. group by room type needs to be added

