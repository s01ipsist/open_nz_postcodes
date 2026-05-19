--
-- PostgreSQL database dump
--

\restrict w9ZBru53VzDG8LEu7tghg54yqWhM2yyos2mCXKgqBQhgvj91RWlacD9WWSbtnge

-- Dumped from database version 18.1 (Debian 18.1-1.pgdg13+2)
-- Dumped by pg_dump version 18.1 (Debian 18.1-1.pgdg13+2)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: nz_addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nz_addresses (
    gid integer NOT NULL,
    address_id integer,
    road_id integer,
    full_addre character varying(10),
    full_road_ character varying(33),
    full_add_1 character varying(80),
    territoria character varying(30),
    unit character varying(5),
    address_nu integer,
    address__1 character varying(3),
    address__2 integer,
    road_name character varying(28),
    road_name_ character varying(13),
    road_nam_1 character varying(9),
    suburb_loc character varying(48),
    town_city character varying(48),
    is_land character varying(2),
    address_li character varying(8),
    full_roa_1 character varying(33),
    full_add_2 character varying(80),
    territor_1 character varying(30),
    road_nam_2 character varying(28),
    suburb_l_1 character varying(48),
    town_city_ character varying(48),
    geom public.geometry(Point,4326),
    postcode text
);


--
-- Name: nz_addresses_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nz_addresses_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nz_addresses_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nz_addresses_gid_seq OWNED BY public.nz_addresses.gid;


--
-- Name: nz_localities; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nz_localities (
    gid integer NOT NULL,
    id integer,
    name character varying(53),
    additional character varying(253),
    type character varying(17),
    major_name character varying(48),
    major_na_1 character varying(14),
    territoria character varying(126),
    population integer,
    name_ascii character varying(51),
    addition_1 character varying(253),
    major_na_2 character varying(48),
    territor_1 character varying(126),
    geom public.geometry(MultiPolygon,4326)
);


--
-- Name: nz_localities_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nz_localities_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nz_localities_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nz_localities_gid_seq OWNED BY public.nz_localities.gid;


--
-- Name: nz_meshblocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nz_meshblocks (
    gid integer NOT NULL,
    mb2026_v1_ character varying(7),
    landwater character varying(2),
    landwater_ character varying(12),
    land_area_ numeric,
    area_sq_km numeric,
    shape_leng numeric,
    geom public.geometry(MultiPolygon,4326),
    postcode text
);


--
-- Name: nz_meshblocks_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nz_meshblocks_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nz_meshblocks_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nz_meshblocks_gid_seq OWNED BY public.nz_meshblocks.gid;


--
-- Name: nz_roads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nz_roads (
    gid integer NOT NULL,
    road_id integer,
    full_road_ character varying(50),
    road_name_ character varying(50),
    road_nam_1 character varying(50),
    road_nam_2 character varying(13),
    road_nam_3 character varying(9),
    is_land character varying(2),
    full_roa_1 character varying(50),
    road_nam_4 character varying(50),
    road_nam_5 character varying(50),
    geom public.geometry(MultiLineString,4326),
    postcode text
);


--
-- Name: nz_roads_gid_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.nz_roads_gid_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: nz_roads_gid_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.nz_roads_gid_seq OWNED BY public.nz_roads.gid;


--
-- Name: nz_street_postcodes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.nz_street_postcodes (
    road_id integer,
    postcode text,
    name text,
    locality text,
    city text
);


--
-- Name: nz_addresses gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_addresses ALTER COLUMN gid SET DEFAULT nextval('public.nz_addresses_gid_seq'::regclass);


--
-- Name: nz_localities gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_localities ALTER COLUMN gid SET DEFAULT nextval('public.nz_localities_gid_seq'::regclass);


--
-- Name: nz_meshblocks gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_meshblocks ALTER COLUMN gid SET DEFAULT nextval('public.nz_meshblocks_gid_seq'::regclass);


--
-- Name: nz_roads gid; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_roads ALTER COLUMN gid SET DEFAULT nextval('public.nz_roads_gid_seq'::regclass);


--
-- Name: nz_addresses nz_addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_addresses
    ADD CONSTRAINT nz_addresses_pkey PRIMARY KEY (gid);


--
-- Name: nz_localities nz_localities_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_localities
    ADD CONSTRAINT nz_localities_pkey PRIMARY KEY (gid);


--
-- Name: nz_meshblocks nz_meshblocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_meshblocks
    ADD CONSTRAINT nz_meshblocks_pkey PRIMARY KEY (gid);


--
-- Name: nz_roads nz_roads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.nz_roads
    ADD CONSTRAINT nz_roads_pkey PRIMARY KEY (gid);


--
-- Name: nz_addresses_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nz_addresses_geom_idx ON public.nz_addresses USING gist (geom);


--
-- Name: nz_addresses_road_id_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nz_addresses_road_id_idx ON public.nz_addresses USING btree (road_id);


--
-- Name: nz_localities_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nz_localities_geom_idx ON public.nz_localities USING gist (geom);


--
-- Name: nz_meshblocks_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nz_meshblocks_geom_idx ON public.nz_meshblocks USING gist (geom);


--
-- Name: nz_roads_full_road_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nz_roads_full_road_idx ON public.nz_roads USING btree (full_road_);


--
-- Name: nz_roads_geom_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nz_roads_geom_idx ON public.nz_roads USING gist (geom);


--
-- Name: nz_street_postcodes_road_idx; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX nz_street_postcodes_road_idx ON public.nz_street_postcodes USING btree (road_id);


--
-- PostgreSQL database dump complete
--

\unrestrict w9ZBru53VzDG8LEu7tghg54yqWhM2yyos2mCXKgqBQhgvj91RWlacD9WWSbtnge

