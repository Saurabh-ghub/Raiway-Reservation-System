--
-- NOTE:
--
-- File paths need to be edited. Search for $$PATH$$ and
-- replace it with the path to the directory containing
-- the extracted data files.
--
--
-- PostgreSQL database dump
--

-- Dumped from database version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)
-- Dumped by pg_dump version 12.9 (Ubuntu 12.9-0ubuntu0.20.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

DROP DATABASE railway_reservation;
--
-- Name: railway_reservation; Type: DATABASE; Schema: -; Owner: railway_admin
--

CREATE DATABASE railway_reservation WITH TEMPLATE = template0 ENCODING = 'UTF8' LC_COLLATE = 'en_IN' LC_CTYPE = 'en_IN';


ALTER DATABASE railway_reservation OWNER TO railway_admin;

\connect railway_reservation

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: book_ticket(integer, text, text, text, text, date, integer, text); Type: PROCEDURE; Schema: public; Owner: railway_admin
--

CREATE PROCEDURE public.book_ticket(_train_no integer, _source_station text, _destination_station text, _seat_type text, _passenger_name text, _date date, _age integer, _gender text)
    LANGUAGE plpgsql
    AS $$
declare _no_of_seats integer := 1;
temp integer; _departure_time time; _cost integer; _seat_no integer; _pnr integer;
begin
select check_availability(_train_no,_seat_type,_no_of_seats,_date,_source_station,_destination_station) into temp;
if temp = 1 then select source_departure_time from route where route.train_no = _train_no and route.source_station = _source_station and route.destination_station = _destination_station into _departure_time;
if _seat_type = 'AC' then select ac_price from route where route.train_no = _train_no and route.source_station = _source_station and route.destination_station = _destination_station into _cost;
select ac_seats_available from route where route.train_no = _train_no and route.source_station = _source_station and route.destination_station = _destination_station into _seat_no;                                 insert into ticket(train_no,source_departure_time,seat_type,date,passenger_name,source_station,destination_station,cost,seat_no) values
(_train_no,_departure_time,_seat_type,_date,_passenger_name,_source_station,_destination_station,_cost,_seat_no);
update route set ac_seats_available = ac_seats_available - 1 where route.train_no = _train_no and route.source_station = _source_station and route.destination_station = _destination_station;
elsif _seat_type = 'GN' then select gn_price from route where route.train_no = _train_no and route.source_station = _source_station and route.destination_station = _destination_station into _cost;
select gn_seats_available from route where route.train_no = _train_no and route.source_station = _source_station and route.destination_station = _destination_station into _seat_no; 
insert into ticket(train_no,source_departure_time,seat_type,date,passenger_name,source_station,destination_station,cost,seat_no) values
(_train_no,_departure_time,_seat_type,_date,_passenger_name,_source_station,_destination_station,_cost,_seat_no);
update route set gn_seats_available = gn_seats_available - 1 where route.train_no = _train_no and route.source_station = _source_station and route.destination_station = _destination_station;                       end if;
select pnr_no from ticket where ticket.seat_no = _seat_no into _pnr;
insert into passengers(name,age,gender,pnr_no,seat_type,seat_no) values (_passenger_name,_age,_gender,_pnr,_seat_type,_seat_no);
end if; commit;
end;
$$;


ALTER PROCEDURE public.book_ticket(_train_no integer, _source_station text, _destination_station text, _seat_type text, _passenger_name text, _date date, _age integer, _gender text) OWNER TO railway_admin;

--
-- Name: check_availability(integer, text, integer, date, text, text); Type: FUNCTION; Schema: public; Owner: railway_admin
--

CREATE FUNCTION public.check_availability(_train_no integer, _seat_type text, _seat_no integer, _date date, _source_station text, _destination_station text) RETURNS integer
    LANGUAGE plpgsql
    AS $$ declare count integer;
begin
if _seat_type = 'AC' then
select ac_seats_available from route where route.train_no = _train_no and route.date = _date and route.source_station = _source_station and route.destination_station = _destination_station
into count;
if count - _seat_no >= 0 then
return 1;
else
return 0;
end if;
end if;
if _seat_type = 'GN' then
select gn_seats_available from route where route.train_no = _train_no and route.date = _date and route.source_station = _source_station and route.destination_station = _destination_station
into count;
if count - _seat_no >= 0 then
return 1;
else
return 0;
end if;
end if;
end;
$$;


ALTER FUNCTION public.check_availability(_train_no integer, _seat_type text, _seat_no integer, _date date, _source_station text, _destination_station text) OWNER TO railway_admin;

--
-- Name: create_user(text, text, text, text, integer, text, text, text, text, text, integer); Type: PROCEDURE; Schema: public; Owner: railway_admin
--

CREATE PROCEDURE public.create_user(_user_id text, _password text, _first_name text, _last_name text, _age integer, _gender text, _mobile_no text, _email text, _city text, _state text, _pincode integer)
    LANGUAGE plpgsql
    AS $$
begin
execute format('create role %I login password %L',_user_id,_password);
execute format('grant all on passengers to %I',_user_id);
execute format('grant all on ticket to %I',_user_id);
execute format('grant all on users to %I',_user_id); execute format('grant select, update on route to %I',_user_id); execute format('grant select on station to %I',_user_id); execute format('grant select on status to %I',_user_id);  execute format('grant all privileges on all sequences in schema public to %I',_user_id);
insert into users(user_id,password,first_name,last_name,gender,age,email,mobile_no,city,state,pincode)
values (_user_id,_password,_first_name,_last_name,_gender,_age,_email,_mobile_no,_city,_state,_pincode);
commit;
end;
$$;


ALTER PROCEDURE public.create_user(_user_id text, _password text, _first_name text, _last_name text, _age integer, _gender text, _mobile_no text, _email text, _city text, _state text, _pincode integer) OWNER TO railway_admin;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: city; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.city (
    name text NOT NULL
);


ALTER TABLE public.city OWNER TO railway_admin;

--
-- Name: passengers; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.passengers (
    passenger_id integer NOT NULL,
    name text NOT NULL,
    age integer NOT NULL,
    gender text NOT NULL,
    pnr_no integer NOT NULL,
    seat_type text NOT NULL,
    seat_no integer NOT NULL,
    CONSTRAINT age_constraint CHECK ((age > 0)),
    CONSTRAINT gender_constraint CHECK (((gender = 'male'::text) OR (gender = 'female'::text) OR (gender = 'others'::text))),
    CONSTRAINT seat_type_constraint CHECK (((seat_type = 'AC'::text) OR (seat_type = 'GN'::text)))
);


ALTER TABLE public.passengers OWNER TO railway_admin;

--
-- Name: passengers_passenger_id_seq; Type: SEQUENCE; Schema: public; Owner: railway_admin
--

CREATE SEQUENCE public.passengers_passenger_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.passengers_passenger_id_seq OWNER TO railway_admin;

--
-- Name: passengers_passenger_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: railway_admin
--

ALTER SEQUENCE public.passengers_passenger_id_seq OWNED BY public.passengers.passenger_id;


--
-- Name: passengers_pnr_no_seq; Type: SEQUENCE; Schema: public; Owner: railway_admin
--

CREATE SEQUENCE public.passengers_pnr_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.passengers_pnr_no_seq OWNER TO railway_admin;

--
-- Name: passengers_pnr_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: railway_admin
--

ALTER SEQUENCE public.passengers_pnr_no_seq OWNED BY public.passengers.pnr_no;


--
-- Name: route; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.route (
    train_no integer NOT NULL,
    train_name text NOT NULL,
    source_station text NOT NULL,
    destination_station text NOT NULL,
    ac_seats_available integer NOT NULL,
    ac_price integer NOT NULL,
    gn_seats_available integer NOT NULL,
    gn_price integer NOT NULL,
    date date NOT NULL,
    source_departure_time time without time zone NOT NULL,
    destination_arrival_time time without time zone NOT NULL,
    CONSTRAINT price_constraint CHECK (((ac_price >= 0) AND (gn_price >= 0))),
    CONSTRAINT seats_constraint CHECK (((ac_seats_available >= 0) AND (gn_seats_available >= 0)))
);


ALTER TABLE public.route OWNER TO railway_admin;

--
-- Name: station; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.station (
    station_no integer NOT NULL,
    station_name text NOT NULL,
    train_no integer NOT NULL,
    arrival_time time without time zone,
    departure_time time without time zone
);


ALTER TABLE public.station OWNER TO railway_admin;

--
-- Name: station_station_no_seq; Type: SEQUENCE; Schema: public; Owner: railway_admin
--

CREATE SEQUENCE public.station_station_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.station_station_no_seq OWNER TO railway_admin;

--
-- Name: station_station_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: railway_admin
--

ALTER SEQUENCE public.station_station_no_seq OWNED BY public.station.station_no;


--
-- Name: station_train_no_seq; Type: SEQUENCE; Schema: public; Owner: railway_admin
--

CREATE SEQUENCE public.station_train_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.station_train_no_seq OWNER TO railway_admin;

--
-- Name: station_train_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: railway_admin
--

ALTER SEQUENCE public.station_train_no_seq OWNED BY public.station.train_no;


--
-- Name: status; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.status (
    train_no integer NOT NULL,
    station_no integer NOT NULL,
    arrival_time time without time zone,
    departure_time time without time zone,
    arrived boolean DEFAULT false,
    departed boolean DEFAULT false
);


ALTER TABLE public.status OWNER TO railway_admin;

--
-- Name: ticket; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.ticket (
    pnr_no integer NOT NULL,
    train_no integer NOT NULL,
    source_departure_time time without time zone NOT NULL,
    seat_type text NOT NULL,
    date date NOT NULL,
    passenger_name text NOT NULL,
    source_station text NOT NULL,
    destination_station text NOT NULL,
    cost integer NOT NULL,
    seat_no integer NOT NULL,
    CONSTRAINT seat_type_constraint CHECK (((seat_type = 'AC'::text) OR (seat_type = 'GN'::text))),
    CONSTRAINT ticket_cost_check CHECK ((cost > 0)),
    CONSTRAINT ticket_seat_no_check CHECK ((seat_no > 0))
);


ALTER TABLE public.ticket OWNER TO railway_admin;

--
-- Name: ticket_pnr_no_seq; Type: SEQUENCE; Schema: public; Owner: railway_admin
--

CREATE SEQUENCE public.ticket_pnr_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.ticket_pnr_no_seq OWNER TO railway_admin;

--
-- Name: ticket_pnr_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: railway_admin
--

ALTER SEQUENCE public.ticket_pnr_no_seq OWNED BY public.ticket.pnr_no;


--
-- Name: train; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.train (
    train_no integer NOT NULL,
    train_name text NOT NULL
);


ALTER TABLE public.train OWNER TO railway_admin;

--
-- Name: train_train_no_seq; Type: SEQUENCE; Schema: public; Owner: railway_admin
--

CREATE SEQUENCE public.train_train_no_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.train_train_no_seq OWNER TO railway_admin;

--
-- Name: train_train_no_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: railway_admin
--

ALTER SEQUENCE public.train_train_no_seq OWNED BY public.route.train_no;


--
-- Name: train_train_no_seq1; Type: SEQUENCE; Schema: public; Owner: railway_admin
--

CREATE SEQUENCE public.train_train_no_seq1
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


ALTER TABLE public.train_train_no_seq1 OWNER TO railway_admin;

--
-- Name: train_train_no_seq1; Type: SEQUENCE OWNED BY; Schema: public; Owner: railway_admin
--

ALTER SEQUENCE public.train_train_no_seq1 OWNED BY public.train.train_no;


--
-- Name: users; Type: TABLE; Schema: public; Owner: railway_admin
--

CREATE TABLE public.users (
    user_id text NOT NULL,
    password text NOT NULL,
    first_name text NOT NULL,
    last_name text NOT NULL,
    gender text NOT NULL,
    age integer NOT NULL,
    email text NOT NULL,
    mobile_no text NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    pincode integer NOT NULL,
    CONSTRAINT age_constraint CHECK ((age > 12)),
    CONSTRAINT email_constraint CHECK ((email ~ '[\w]+@[\w]+(\.[\w]+)+'::text)),
    CONSTRAINT gender_constraint CHECK (((gender = 'male'::text) OR (gender = 'female'::text) OR (gender = 'others'::text))),
    CONSTRAINT mobile_no_constraint CHECK ((mobile_no ~ '\d\d\d\d\d\d\d\d\d\d'::text)),
    CONSTRAINT password_constraint CHECK ((password ~ '\S\S\S\S\S\S\S\S+'::text)),
    CONSTRAINT user_id_constraint CHECK ((user_id ~ '\w\w\w\w+'::text))
);


ALTER TABLE public.users OWNER TO railway_admin;

--
-- Name: passengers passenger_id; Type: DEFAULT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.passengers ALTER COLUMN passenger_id SET DEFAULT nextval('public.passengers_passenger_id_seq'::regclass);


--
-- Name: passengers pnr_no; Type: DEFAULT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.passengers ALTER COLUMN pnr_no SET DEFAULT nextval('public.passengers_pnr_no_seq'::regclass);


--
-- Name: route train_no; Type: DEFAULT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.route ALTER COLUMN train_no SET DEFAULT nextval('public.train_train_no_seq'::regclass);


--
-- Name: station station_no; Type: DEFAULT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.station ALTER COLUMN station_no SET DEFAULT nextval('public.station_station_no_seq'::regclass);


--
-- Name: station train_no; Type: DEFAULT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.station ALTER COLUMN train_no SET DEFAULT nextval('public.station_train_no_seq'::regclass);


--
-- Name: ticket pnr_no; Type: DEFAULT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.ticket ALTER COLUMN pnr_no SET DEFAULT nextval('public.ticket_pnr_no_seq'::regclass);


--
-- Name: train train_no; Type: DEFAULT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.train ALTER COLUMN train_no SET DEFAULT nextval('public.train_train_no_seq1'::regclass);


--
-- Data for Name: city; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.city (name) FROM stdin;
\.
COPY public.city (name) FROM '$$PATH$$/3061.dat';

--
-- Data for Name: passengers; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.passengers (passenger_id, name, age, gender, pnr_no, seat_type, seat_no) FROM stdin;
\.
COPY public.passengers (passenger_id, name, age, gender, pnr_no, seat_type, seat_no) FROM '$$PATH$$/3065.dat';

--
-- Data for Name: route; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.route (train_no, train_name, source_station, destination_station, ac_seats_available, ac_price, gn_seats_available, gn_price, date, source_departure_time, destination_arrival_time) FROM stdin;
\.
COPY public.route (train_no, train_name, source_station, destination_station, ac_seats_available, ac_price, gn_seats_available, gn_price, date, source_departure_time, destination_arrival_time) FROM '$$PATH$$/3067.dat';

--
-- Data for Name: station; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.station (station_no, station_name, train_no, arrival_time, departure_time) FROM stdin;
\.
COPY public.station (station_no, station_name, train_no, arrival_time, departure_time) FROM '$$PATH$$/3070.dat';

--
-- Data for Name: status; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.status (train_no, station_no, arrival_time, departure_time, arrived, departed) FROM stdin;
\.
COPY public.status (train_no, station_no, arrival_time, departure_time, arrived, departed) FROM '$$PATH$$/3073.dat';

--
-- Data for Name: ticket; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.ticket (pnr_no, train_no, source_departure_time, seat_type, date, passenger_name, source_station, destination_station, cost, seat_no) FROM stdin;
\.
COPY public.ticket (pnr_no, train_no, source_departure_time, seat_type, date, passenger_name, source_station, destination_station, cost, seat_no) FROM '$$PATH$$/3072.dat';

--
-- Data for Name: train; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.train (train_no, train_name) FROM stdin;
\.
COPY public.train (train_no, train_name) FROM '$$PATH$$/3075.dat';

--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: railway_admin
--

COPY public.users (user_id, password, first_name, last_name, gender, age, email, mobile_no, city, state, pincode) FROM stdin;
\.
COPY public.users (user_id, password, first_name, last_name, gender, age, email, mobile_no, city, state, pincode) FROM '$$PATH$$/3062.dat';

--
-- Name: passengers_passenger_id_seq; Type: SEQUENCE SET; Schema: public; Owner: railway_admin
--

SELECT pg_catalog.setval('public.passengers_passenger_id_seq', 2, true);


--
-- Name: passengers_pnr_no_seq; Type: SEQUENCE SET; Schema: public; Owner: railway_admin
--

SELECT pg_catalog.setval('public.passengers_pnr_no_seq', 1, false);


--
-- Name: station_station_no_seq; Type: SEQUENCE SET; Schema: public; Owner: railway_admin
--

SELECT pg_catalog.setval('public.station_station_no_seq', 1, false);


--
-- Name: station_train_no_seq; Type: SEQUENCE SET; Schema: public; Owner: railway_admin
--

SELECT pg_catalog.setval('public.station_train_no_seq', 1, false);


--
-- Name: ticket_pnr_no_seq; Type: SEQUENCE SET; Schema: public; Owner: railway_admin
--

SELECT pg_catalog.setval('public.ticket_pnr_no_seq', 3, true);


--
-- Name: train_train_no_seq; Type: SEQUENCE SET; Schema: public; Owner: railway_admin
--

SELECT pg_catalog.setval('public.train_train_no_seq', 3, true);


--
-- Name: train_train_no_seq1; Type: SEQUENCE SET; Schema: public; Owner: railway_admin
--

SELECT pg_catalog.setval('public.train_train_no_seq1', 3, true);


--
-- Name: city city_name_key; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_name_key UNIQUE (name);


--
-- Name: city city_pkey; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.city
    ADD CONSTRAINT city_pkey PRIMARY KEY (name);


--
-- Name: passengers passengers_pkey; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT passengers_pkey PRIMARY KEY (passenger_id);


--
-- Name: station station_pkey; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.station
    ADD CONSTRAINT station_pkey PRIMARY KEY (station_no, train_no);


--
-- Name: status status_pkey; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT status_pkey PRIMARY KEY (train_no, station_no);


--
-- Name: ticket ticket_pkey; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT ticket_pkey PRIMARY KEY (pnr_no);


--
-- Name: route train_pkey; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.route
    ADD CONSTRAINT train_pkey PRIMARY KEY (train_no, source_station, destination_station);


--
-- Name: train train_pkey1; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.train
    ADD CONSTRAINT train_pkey1 PRIMARY KEY (train_no);


--
-- Name: train train_train_name_key; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.train
    ADD CONSTRAINT train_train_name_key UNIQUE (train_name);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_id);


--
-- Name: users fk_city; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT fk_city FOREIGN KEY (city) REFERENCES public.city(name);


--
-- Name: route fk_destination_station; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.route
    ADD CONSTRAINT fk_destination_station FOREIGN KEY (destination_station) REFERENCES public.city(name);


--
-- Name: ticket fk_destination_station; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT fk_destination_station FOREIGN KEY (destination_station) REFERENCES public.city(name);


--
-- Name: passengers fk_key; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.passengers
    ADD CONSTRAINT fk_key FOREIGN KEY (pnr_no) REFERENCES public.ticket(pnr_no);


--
-- Name: status fk_key; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.status
    ADD CONSTRAINT fk_key FOREIGN KEY (train_no, station_no) REFERENCES public.station(train_no, station_no);


--
-- Name: route fk_source_station; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.route
    ADD CONSTRAINT fk_source_station FOREIGN KEY (source_station) REFERENCES public.city(name);


--
-- Name: ticket fk_source_station; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT fk_source_station FOREIGN KEY (source_station) REFERENCES public.city(name);


--
-- Name: station fk_station_name; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.station
    ADD CONSTRAINT fk_station_name FOREIGN KEY (station_name) REFERENCES public.city(name);


--
-- Name: route fk_train_name; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.route
    ADD CONSTRAINT fk_train_name FOREIGN KEY (train_name) REFERENCES public.train(train_name);


--
-- Name: route fk_train_no; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.route
    ADD CONSTRAINT fk_train_no FOREIGN KEY (train_no) REFERENCES public.train(train_no);


--
-- Name: station fk_train_no; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.station
    ADD CONSTRAINT fk_train_no FOREIGN KEY (train_no) REFERENCES public.train(train_no);


--
-- Name: ticket fk_train_no; Type: FK CONSTRAINT; Schema: public; Owner: railway_admin
--

ALTER TABLE ONLY public.ticket
    ADD CONSTRAINT fk_train_no FOREIGN KEY (train_no) REFERENCES public.train(train_no);


--
-- Name: TABLE passengers; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON TABLE public.passengers TO shubham124;
GRANT ALL ON TABLE public.passengers TO sam123;
GRANT ALL ON TABLE public.passengers TO timcook123;
GRANT ALL ON TABLE public.passengers TO david123;
GRANT SELECT ON TABLE public.passengers TO ticket_examiner;


--
-- Name: SEQUENCE passengers_passenger_id_seq; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON SEQUENCE public.passengers_passenger_id_seq TO timcook123;
GRANT ALL ON SEQUENCE public.passengers_passenger_id_seq TO david123;
GRANT ALL ON SEQUENCE public.passengers_passenger_id_seq TO station_master;


--
-- Name: SEQUENCE passengers_pnr_no_seq; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON SEQUENCE public.passengers_pnr_no_seq TO timcook123;
GRANT ALL ON SEQUENCE public.passengers_pnr_no_seq TO david123;
GRANT ALL ON SEQUENCE public.passengers_pnr_no_seq TO station_master;


--
-- Name: TABLE route; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT SELECT ON TABLE public.route TO sam123;
GRANT SELECT ON TABLE public.route TO timcook123;
GRANT SELECT,UPDATE ON TABLE public.route TO david123;
GRANT ALL ON TABLE public.route TO station_master;


--
-- Name: TABLE station; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT SELECT ON TABLE public.station TO sam123;
GRANT SELECT ON TABLE public.station TO timcook123;
GRANT SELECT ON TABLE public.station TO david123;
GRANT ALL ON TABLE public.station TO station_master;


--
-- Name: SEQUENCE station_station_no_seq; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON SEQUENCE public.station_station_no_seq TO timcook123;
GRANT ALL ON SEQUENCE public.station_station_no_seq TO david123;
GRANT ALL ON SEQUENCE public.station_station_no_seq TO station_master;


--
-- Name: SEQUENCE station_train_no_seq; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON SEQUENCE public.station_train_no_seq TO timcook123;
GRANT ALL ON SEQUENCE public.station_train_no_seq TO david123;
GRANT ALL ON SEQUENCE public.station_train_no_seq TO station_master;


--
-- Name: TABLE status; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT SELECT ON TABLE public.status TO sam123;
GRANT SELECT ON TABLE public.status TO timcook123;
GRANT SELECT ON TABLE public.status TO david123;
GRANT ALL ON TABLE public.status TO station_master;


--
-- Name: TABLE ticket; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON TABLE public.ticket TO shubham124;
GRANT ALL ON TABLE public.ticket TO sam123;
GRANT ALL ON TABLE public.ticket TO timcook123;
GRANT ALL ON TABLE public.ticket TO david123;
GRANT SELECT ON TABLE public.ticket TO ticket_examiner;


--
-- Name: SEQUENCE ticket_pnr_no_seq; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON SEQUENCE public.ticket_pnr_no_seq TO timcook123;
GRANT ALL ON SEQUENCE public.ticket_pnr_no_seq TO david123;
GRANT ALL ON SEQUENCE public.ticket_pnr_no_seq TO station_master;


--
-- Name: TABLE train; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON TABLE public.train TO station_master;


--
-- Name: SEQUENCE train_train_no_seq; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON SEQUENCE public.train_train_no_seq TO timcook123;
GRANT ALL ON SEQUENCE public.train_train_no_seq TO david123;
GRANT ALL ON SEQUENCE public.train_train_no_seq TO station_master;


--
-- Name: SEQUENCE train_train_no_seq1; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON SEQUENCE public.train_train_no_seq1 TO timcook123;
GRANT ALL ON SEQUENCE public.train_train_no_seq1 TO david123;
GRANT ALL ON SEQUENCE public.train_train_no_seq1 TO station_master;


--
-- Name: TABLE users; Type: ACL; Schema: public; Owner: railway_admin
--

GRANT ALL ON TABLE public.users TO shubham124;
GRANT ALL ON TABLE public.users TO sam123;
GRANT ALL ON TABLE public.users TO timcook123;
GRANT ALL ON TABLE public.users TO david123;


--
-- PostgreSQL database dump complete
--

