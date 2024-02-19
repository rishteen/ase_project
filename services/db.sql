--
-- PostgreSQL database dump
--

-- Dumped from database version 16.1 (Debian 16.1-1.pgdg110+1)
-- Dumped by pg_dump version 16.1 (Debian 16.1-1.pgdg120+1)

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
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: root
--

CREATE SCHEMA tiger;


ALTER SCHEMA tiger OWNER TO root;

--
-- Name: tiger_data; Type: SCHEMA; Schema: -; Owner: root
--

CREATE SCHEMA tiger_data;


ALTER SCHEMA tiger_data OWNER TO root;

--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: root
--

CREATE SCHEMA topology;


ALTER SCHEMA topology OWNER TO root;

--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: root
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


--
-- Name: array_add(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.array_add("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT array_to_json(ARRAY(SELECT unnest(ARRAY(SELECT DISTINCT jsonb_array_elements("array")) || ARRAY(SELECT jsonb_array_elements("values")))))::jsonb; $$;


ALTER FUNCTION public.array_add("array" jsonb, "values" jsonb) OWNER TO root;

--
-- Name: array_add_unique(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.array_add_unique("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT array_to_json(ARRAY(SELECT DISTINCT unnest(ARRAY(SELECT DISTINCT jsonb_array_elements("array")) || ARRAY(SELECT DISTINCT jsonb_array_elements("values")))))::jsonb; $$;


ALTER FUNCTION public.array_add_unique("array" jsonb, "values" jsonb) OWNER TO root;

--
-- Name: array_contains(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.array_contains("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT RES.CNT >= 1 FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements("array") as elt WHERE elt IN (SELECT jsonb_array_elements("values"))) as RES; $$;


ALTER FUNCTION public.array_contains("array" jsonb, "values" jsonb) OWNER TO root;

--
-- Name: array_contains_all(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.array_contains_all("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT CASE WHEN 0 = jsonb_array_length("values") THEN true = false ELSE (SELECT RES.CNT = jsonb_array_length("values") FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements_text("array") as elt WHERE elt IN (SELECT jsonb_array_elements_text("values"))) as RES) END; $$;


ALTER FUNCTION public.array_contains_all("array" jsonb, "values" jsonb) OWNER TO root;

--
-- Name: array_contains_all_regex(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.array_contains_all_regex("array" jsonb, "values" jsonb) RETURNS boolean
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT CASE WHEN 0 = jsonb_array_length("values") THEN true = false ELSE (SELECT RES.CNT = jsonb_array_length("values") FROM (SELECT COUNT(*) as CNT FROM jsonb_array_elements_text("array") as elt WHERE elt LIKE ANY (SELECT jsonb_array_elements_text("values"))) as RES) END; $$;


ALTER FUNCTION public.array_contains_all_regex("array" jsonb, "values" jsonb) OWNER TO root;

--
-- Name: array_remove(jsonb, jsonb); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.array_remove("array" jsonb, "values" jsonb) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT array_to_json(ARRAY(SELECT * FROM jsonb_array_elements("array") as elt WHERE elt NOT IN (SELECT * FROM (SELECT jsonb_array_elements("values")) AS sub)))::jsonb; $$;


ALTER FUNCTION public.array_remove("array" jsonb, "values" jsonb) OWNER TO root;

--
-- Name: idempotency_delete_expired_records(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.idempotency_delete_expired_records() RETURNS void
    LANGUAGE plpgsql
    AS $$ BEGIN DELETE FROM "_Idempotency" WHERE expire < NOW() - INTERVAL '300 seconds'; END; $$;


ALTER FUNCTION public.idempotency_delete_expired_records() OWNER TO root;

--
-- Name: json_object_set_key(jsonb, text, anyelement); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) RETURNS jsonb
    LANGUAGE sql IMMUTABLE STRICT
    AS $$ SELECT concat('{', string_agg(to_json("key") || ':' || "value", ','), '}')::jsonb FROM (SELECT * FROM jsonb_each("json") WHERE key <> key_to_set UNION ALL SELECT key_to_set, to_json("value_to_set")::jsonb) AS fields $$;


ALTER FUNCTION public.json_object_set_key(json jsonb, key_to_set text, value_to_set anyelement) OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: Category; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."Category" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    description text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Category" OWNER TO root;

--
-- Name: Food; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."Food" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    price double precision,
    restaurant_id text,
    photo text,
    type_of_food text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Food" OWNER TO root;

--
-- Name: Restaurant; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."Restaurant" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    image text,
    url text,
    category_id text,
    latitude double precision,
    longitude double precision,
    phone text,
    facebook text,
    instagram text,
    whatsapp text,
    email text,
    web text,
    city text,
    district text,
    street text,
    avenue text,
    postal_code text,
    opening_time text,
    closing_time text,
    working_days text,
    deliver boolean,
    takeaway boolean,
    serving boolean,
    views_rate double precision,
    is_verified boolean,
    _rperm text[],
    _wperm text[],
    title text,
    restaurant_id text,
    file jsonb,
    geopoint public.geometry(Point,4326)
);


ALTER TABLE public."Restaurant" OWNER TO root;

--
-- Name: Score; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."Score" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    user_id text,
    restaurant_id text,
    employee_behave_score double precision,
    restaurant_cleanliness_score double precision,
    food_quality_score double precision,
    taste_of_food_score double precision,
    side_services_score double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."Score" OWNER TO root;

--
-- Name: _Audience; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_Audience" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    query text,
    "lastUsed" timestamp with time zone,
    "timesUsed" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Audience" OWNER TO root;

--
-- Name: _GlobalConfig; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_GlobalConfig" (
    "objectId" text NOT NULL,
    params jsonb,
    "masterKeyOnly" jsonb
);


ALTER TABLE public."_GlobalConfig" OWNER TO root;

--
-- Name: _GraphQLConfig; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_GraphQLConfig" (
    "objectId" text NOT NULL,
    config jsonb
);


ALTER TABLE public."_GraphQLConfig" OWNER TO root;

--
-- Name: _Hooks; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_Hooks" (
    "functionName" text,
    "className" text,
    "triggerName" text,
    url text
);


ALTER TABLE public."_Hooks" OWNER TO root;

--
-- Name: _Idempotency; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_Idempotency" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "reqId" text,
    expire timestamp with time zone,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Idempotency" OWNER TO root;

--
-- Name: _JobSchedule; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_JobSchedule" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "jobName" text,
    description text,
    params text,
    "startAfter" text,
    "daysOfWeek" jsonb,
    "timeOfDay" text,
    "lastRun" double precision,
    "repeatMinutes" double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_JobSchedule" OWNER TO root;

--
-- Name: _JobStatus; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_JobStatus" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "jobName" text,
    source text,
    status text,
    message text,
    params jsonb,
    "finishedAt" timestamp with time zone,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_JobStatus" OWNER TO root;

--
-- Name: _Join:roles:_Role; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_Join:roles:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:roles:_Role" OWNER TO root;

--
-- Name: _Join:users:_Role; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_Join:users:_Role" (
    "relatedId" character varying(120) NOT NULL,
    "owningId" character varying(120) NOT NULL
);


ALTER TABLE public."_Join:users:_Role" OWNER TO root;

--
-- Name: _PushStatus; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_PushStatus" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "pushTime" text,
    source text,
    query text,
    payload text,
    title text,
    expiry double precision,
    expiration_interval double precision,
    status text,
    "numSent" double precision,
    "numFailed" double precision,
    "pushHash" text,
    "errorMessage" jsonb,
    "sentPerType" jsonb,
    "failedPerType" jsonb,
    "sentPerUTCOffset" jsonb,
    "failedPerUTCOffset" jsonb,
    count double precision,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_PushStatus" OWNER TO root;

--
-- Name: _Role; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_Role" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    name text,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Role" OWNER TO root;

--
-- Name: _SCHEMA; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_SCHEMA" (
    "className" character varying(120) NOT NULL,
    schema jsonb,
    "isParseClass" boolean
);


ALTER TABLE public."_SCHEMA" OWNER TO root;

--
-- Name: _Session; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_Session" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    "user" text,
    "installationId" text,
    "sessionToken" text,
    "expiresAt" timestamp with time zone,
    "createdWith" jsonb,
    _rperm text[],
    _wperm text[]
);


ALTER TABLE public."_Session" OWNER TO root;

--
-- Name: _User; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public."_User" (
    "objectId" text NOT NULL,
    "createdAt" timestamp with time zone,
    "updatedAt" timestamp with time zone,
    username text,
    email text,
    "emailVerified" boolean,
    "authData" jsonb,
    _rperm text[],
    _wperm text[],
    _hashed_password text,
    _email_verify_token_expires_at timestamp with time zone,
    _email_verify_token text,
    _account_lockout_expires_at timestamp with time zone,
    _failed_login_count double precision,
    _perishable_token text,
    _perishable_token_expires_at timestamp with time zone,
    _password_changed_at timestamp with time zone,
    _password_history jsonb,
    firstname text,
    lastname text,
    is_restaurant_owner boolean,
    is_admin boolean,
    name text
);


ALTER TABLE public."_User" OWNER TO root;

--
-- Data for Name: Category; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."Category" ("objectId", "createdAt", "updatedAt", name, description, _rperm, _wperm) FROM stdin;
zzCG0AtaNp	2024-02-15 21:44:14.462+00	2024-02-15 21:44:14.462+00	irani	Delicious irani's food	\N	\N
lrNzJqVkzr	2024-02-15 21:44:28.011+00	2024-02-15 21:44:28.011+00	farangi	Delicious farangi's food	\N	\N
nD1aOPUIAF	2024-02-15 21:44:39.912+00	2024-02-15 21:44:39.912+00	fastfood	Delicious fastfood food	\N	\N
csFI7CCFvJ	2024-02-15 21:44:50.483+00	2024-02-15 21:44:50.483+00	sonati	Delicious sonati food	\N	\N
AtfPFy9XM4	2024-02-16 01:15:32.997+00	2024-02-16 01:15:32.997+00	sonati	Delicious sonati food	\N	\N
gGh1xqDuIB	2024-02-16 15:33:18.836+00	2024-02-16 15:33:18.836+00	Test Main Course	Test Main Coursecategory	\N	\N
JcizCGr5ZX	2024-02-16 21:56:31.359+00	2024-02-16 21:56:31.359+00	hello	hello	\N	\N
\.


--
-- Data for Name: Food; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."Food" ("objectId", "createdAt", "updatedAt", name, price, restaurant_id, photo, type_of_food, _rperm, _wperm) FROM stdin;
b0KuG8DwSJ	2024-02-15 23:23:45.653+00	2024-02-15 23:23:45.653+00	Tachin Morgh	838000	o4VD4BWwDt	\N	irani	\N	\N
VFuLaVTBny	2024-02-15 23:23:45.858+00	2024-02-15 23:23:45.858+00	Lubia Polo	915000	ThMuD3hYRQ	\N	irani	\N	\N
ssWCbWQMDZ	2024-02-15 23:23:46.064+00	2024-02-15 23:23:46.064+00	Khoresh-e Beh	603000	AgU9OLJkqz	\N	irani	\N	\N
BGyv8WaJeG	2024-02-15 23:23:46.268+00	2024-02-15 23:23:46.268+00	Khoresh-e Karafs-e Holu	651000	vwHi602n66	\N	sonati	\N	\N
HEXa0Q0pHd	2024-02-15 23:23:46.47+00	2024-02-15 23:23:46.47+00	Dizi Sara	869000	Gl96vGdYHM	\N	sonati	\N	\N
4268Ar6CXG	2024-02-15 23:23:46.675+00	2024-02-15 23:23:46.675+00	Khoresht-e Alu Esfenaj	272000	VK3vnSxIy8	\N	sonati	\N	\N
TiM90EnsqX	2024-02-15 23:23:46.88+00	2024-02-15 23:23:46.88+00	Khoresh-e Anar	23000	D0A6GLdsDM	\N	sonati	\N	\N
HgXgSUyDNy	2024-02-15 23:23:47.087+00	2024-02-15 23:23:47.087+00	Khoresh-e Kadoo	95000	LDrIH1vU8x	\N	sonati	\N	\N
HG4u0u8a5r	2024-02-15 23:23:47.291+00	2024-02-15 23:23:47.291+00	Nan-e Barbari	98000	m6g8u0QpTC	\N	irani	\N	\N
XbJQhuDaG6	2024-02-15 23:23:47.498+00	2024-02-15 23:23:47.498+00	Khoresh-e Karafs-e Holu	965000	Gl96vGdYHM	\N	sonati	\N	\N
d1051xhwdl	2024-02-15 23:23:47.778+00	2024-02-15 23:23:47.778+00	Moraba-ye Gerdoo	748000	j0dWqP2C2A	\N	irani	\N	\N
RdEM9oxVEk	2024-02-15 23:23:47.985+00	2024-02-15 23:23:47.985+00	Samanu	235000	IEqTHcohpJ	\N	sonati	\N	\N
NMit2i9zTN	2024-02-15 23:23:48.194+00	2024-02-15 23:23:48.194+00	Dizi Sara	313000	oABNR2FF6S	\N	irani	\N	\N
qylXPS7lF6	2024-02-15 23:23:48.404+00	2024-02-15 23:23:48.404+00	Khagineh Tabriz	36000	WBFeKac0OO	\N	sonati	\N	\N
OE9FgkDWVf	2024-02-15 23:23:48.608+00	2024-02-15 23:23:48.608+00	Khagineh Yazdi	949000	PF8w2gMAdi	\N	sonati	\N	\N
dZJfhWSUVO	2024-02-15 23:23:48.813+00	2024-02-15 23:23:48.813+00	Morgh-e Torsh	420000	fwLPZZ8YQa	\N	sonati	\N	\N
JAwLYHrPag	2024-02-15 23:23:49.012+00	2024-02-15 23:23:49.012+00	Tachin Morgh	262000	HXtEwLBC7f	\N	irani	\N	\N
Ct2wJfbQjo	2024-02-15 23:23:49.22+00	2024-02-15 23:23:49.22+00	Halva Shekari	568000	oABNR2FF6S	\N	sonati	\N	\N
oA4FKKKBYe	2024-02-15 23:23:49.426+00	2024-02-15 23:23:49.426+00	Mast-o-Khiar	359000	OQWu2bnHeC	\N	irani	\N	\N
DBmZXRn7Bz	2024-02-15 23:23:49.629+00	2024-02-15 23:23:49.629+00	Joojeh Kabab	972000	vwHi602n66	\N	irani	\N	\N
1IR9Q0yGUh	2024-02-15 23:23:49.836+00	2024-02-15 23:23:49.836+00	Gheimeh	434000	VK3vnSxIy8	\N	sonati	\N	\N
AhmG8xVb5i	2024-02-15 23:23:50.044+00	2024-02-15 23:23:50.044+00	Shami Kabab	811000	C7II8dYRPY	\N	sonati	\N	\N
XHKaOovNlO	2024-02-15 23:23:50.246+00	2024-02-15 23:23:50.246+00	Gheimeh	103000	uigc7bJBOJ	\N	sonati	\N	\N
ADCFjvu2E4	2024-02-15 23:23:50.453+00	2024-02-15 23:23:50.453+00	Ash-e Mast	201000	bQpy9LEJWn	\N	irani	\N	\N
f6qQsZjx97	2024-02-15 23:23:50.666+00	2024-02-15 23:23:50.666+00	Lubia Polo	640000	axyV0Fu7pm	\N	irani	\N	\N
45X3jG4Bn1	2024-02-15 23:23:50.859+00	2024-02-15 23:23:50.859+00	Halva Shekari	870000	qEQ9tmLyW9	\N	irani	\N	\N
1MqPb4rcdQ	2024-02-15 23:23:51.067+00	2024-02-15 23:23:51.067+00	Khagineh Tabriz	835000	jjVdtithcD	\N	sonati	\N	\N
pTaP6Ts95s	2024-02-15 23:23:51.287+00	2024-02-15 23:23:51.287+00	Khoresh-e Beh	737000	uABtFsJhJc	\N	irani	\N	\N
NHKjmNMlOt	2024-02-15 23:23:51.495+00	2024-02-15 23:23:51.495+00	Bastani Akbar Mashti	951000	RkhjIQJgou	\N	sonati	\N	\N
U45NQSFxVf	2024-02-15 23:23:51.704+00	2024-02-15 23:23:51.704+00	Tahdig	390000	XpUyRlB6FI	\N	irani	\N	\N
3Ft9rMdCVA	2024-02-15 23:23:51.977+00	2024-02-15 23:23:51.977+00	Khoresh-e Gandom	805000	cmxBcanww9	\N	sonati	\N	\N
OCYKsfx6ZW	2024-02-15 23:23:52.287+00	2024-02-15 23:23:52.287+00	Khagineh	717000	UDXF0qXvDY	\N	irani	\N	\N
jQw7mkUVa2	2024-02-15 23:23:52.592+00	2024-02-15 23:23:52.592+00	Ash-e Anar	94000	o90lhsZ7FK	\N	sonati	\N	\N
HdgTTULNDn	2024-02-15 23:23:52.897+00	2024-02-15 23:23:52.897+00	Mast-o-Khiar	617000	cTIjuPjyIa	\N	sonati	\N	\N
r8Uw3o9Cfz	2024-02-15 23:23:53.206+00	2024-02-15 23:23:53.206+00	Khoresh-e Loobia Sabz	820000	ThMuD3hYRQ	\N	irani	\N	\N
hHa26ekO04	2024-02-15 23:23:53.515+00	2024-02-15 23:23:53.515+00	Kalam Polo	121000	cmxBcanww9	\N	irani	\N	\N
rHdDrzCck4	2024-02-15 23:23:53.811+00	2024-02-15 23:23:53.811+00	Shami Kabab	972000	bQ0JOk10eL	\N	irani	\N	\N
pDxlKG9rkl	2024-02-15 23:23:54.127+00	2024-02-15 23:23:54.127+00	Fesenjan	863000	14jGmOAXcg	\N	irani	\N	\N
Kl6y40DJfb	2024-02-15 23:23:54.437+00	2024-02-15 23:23:54.437+00	Naz Khatoon	454000	RkhjIQJgou	\N	irani	\N	\N
vQmkEjo7XV	2024-02-15 23:23:54.752+00	2024-02-15 23:23:54.752+00	Shirin Yazdi	275000	XpUyRlB6FI	\N	irani	\N	\N
aDEV6OAlVW	2024-02-15 23:23:55.051+00	2024-02-15 23:23:55.051+00	Baghali Ghatogh	486000	fwLPZZ8YQa	\N	irani	\N	\N
jqO8TMCjNB	2024-02-15 23:23:55.353+00	2024-02-15 23:23:55.353+00	Khoresh-e Anar	670000	MQfxuw3ERg	\N	irani	\N	\N
VP8a1niJME	2024-02-15 23:23:55.666+00	2024-02-15 23:23:55.666+00	Ash-e Miveh	967000	P9sBFomftT	\N	sonati	\N	\N
fS2EU51RqC	2024-02-15 23:23:55.873+00	2024-02-15 23:23:55.873+00	Kalam Polo	968000	uigc7bJBOJ	\N	sonati	\N	\N
iXUbFJEWFK	2024-02-15 23:23:56.085+00	2024-02-15 23:23:56.085+00	Koloocheh	438000	cFtamPA0zH	\N	sonati	\N	\N
BvworkUzWv	2024-02-15 23:23:56.376+00	2024-02-15 23:23:56.376+00	Khoresh-e Loobia Sabz	221000	fxvABtKCPT	\N	irani	\N	\N
lkZ9rFdDem	2024-02-15 23:23:56.69+00	2024-02-15 23:23:56.69+00	Samanu	781000	e037qpAih3	\N	sonati	\N	\N
4CEBftpAqN	2024-02-15 23:23:56.995+00	2024-02-15 23:23:56.995+00	Khoresh-e Maast	288000	Oahm9sOn1y	\N	irani	\N	\N
iebUA8VgM2	2024-02-15 23:23:57.297+00	2024-02-15 23:23:57.297+00	Khoresht-e Karafs	389000	e037qpAih3	\N	irani	\N	\N
0p1PfWDicC	2024-02-15 23:23:57.612+00	2024-02-15 23:23:57.612+00	Kookoo Sibzamini	364000	IEqTHcohpJ	\N	irani	\N	\N
NIESiKyTcT	2024-02-15 23:23:57.825+00	2024-02-15 23:23:57.825+00	Khoresh-e Kardeh	228000	P9sBFomftT	\N	irani	\N	\N
6MQCYWTsCi	2024-02-15 23:23:58.124+00	2024-02-15 23:23:58.124+00	Halva	734000	u5FXeeOChJ	\N	irani	\N	\N
tleof48wvI	2024-02-15 23:23:58.329+00	2024-02-15 23:23:58.329+00	Mast-o-Khiar	58000	l1Bslv8T2k	\N	sonati	\N	\N
vwjGEZjT99	2024-02-15 23:23:58.618+00	2024-02-15 23:23:58.618+00	Kufteh Tabrizi	620000	IybX0eBoO3	\N	sonati	\N	\N
eL4ZfMyJk5	2024-02-15 23:23:58.826+00	2024-02-15 23:23:58.826+00	Haleem	412000	cwVEh0dqfm	\N	irani	\N	\N
EhzFhVYza1	2024-02-15 23:23:59.043+00	2024-02-15 23:23:59.043+00	Khagineh Tabriz	914000	JZOBDAh12a	\N	irani	\N	\N
FoLdwU2Sgg	2024-02-15 23:23:59.253+00	2024-02-15 23:23:59.253+00	Khoresh-e Karafs-e Holu	706000	PF8w2gMAdi	\N	irani	\N	\N
HGpLtTKCIE	2024-02-15 23:23:59.457+00	2024-02-15 23:23:59.457+00	Faloodeh	724000	MQfxuw3ERg	\N	irani	\N	\N
swR4a2ZjW5	2024-02-15 23:23:59.671+00	2024-02-15 23:23:59.671+00	Khagineh	100000	IEqTHcohpJ	\N	irani	\N	\N
zdkbNEitL1	2024-02-15 23:23:59.875+00	2024-02-15 23:23:59.875+00	Baghali Polo	697000	tCIEnLLcUc	\N	irani	\N	\N
QGtlCGQXVH	2024-02-15 23:24:00.078+00	2024-02-15 23:24:00.078+00	Moraba-ye Anar Daneh	524000	RBRcyltRSC	\N	sonati	\N	\N
CWeu6RldxZ	2024-02-15 23:24:00.282+00	2024-02-15 23:24:00.282+00	Khoresh-e Kardeh	51000	C7II8dYRPY	\N	sonati	\N	\N
K5IWaOGiL5	2024-02-15 23:24:00.49+00	2024-02-15 23:24:00.49+00	Khoresh-e Fesenjan	547000	LgJuu5ABe5	\N	sonati	\N	\N
anb0RgER6r	2024-02-15 23:23:00.437+00	2024-02-15 23:23:00.437+00	Khoresh-e Fesenjan	906000	jHqCpA1nWb	\N	irani	\N	\N
YcX00LIoWP	2024-02-15 23:23:00.643+00	2024-02-15 23:23:00.643+00	Tachin Morgh	433000	lxQA9rtSfY	\N	sonati	\N	\N
eCHDau1hC9	2024-02-15 23:23:00.853+00	2024-02-15 23:23:00.853+00	Baghali Ghatogh	407000	Pa0qBO2rzK	\N	sonati	\N	\N
ZSjhcHRmKB	2024-02-15 23:23:01.048+00	2024-02-15 23:23:01.048+00	Kookoo Sabzi	853000	WSTLlXDcKl	\N	sonati	\N	\N
9ya04KoAm9	2024-02-15 23:23:01.26+00	2024-02-15 23:23:01.26+00	Naz Khatoon	508000	uABtFsJhJc	\N	sonati	\N	\N
thCxp2PKat	2024-02-15 23:23:01.472+00	2024-02-15 23:23:01.472+00	Khoresh-e Morgh Ba Zireh	610000	RkhjIQJgou	\N	irani	\N	\N
BajCGabOPk	2024-02-15 23:23:01.678+00	2024-02-15 23:23:01.678+00	Khoresh-e Anar	945000	TpGyMZM9BG	\N	irani	\N	\N
KGgemQt23i	2024-02-15 23:23:01.88+00	2024-02-15 23:23:01.88+00	Khoresht-e Torsh	775000	yvUod6yLDt	\N	irani	\N	\N
ORXYguOinc	2024-02-15 23:23:02.094+00	2024-02-15 23:23:02.094+00	Khoresh-e Loobia Sabz	597000	Oahm9sOn1y	\N	irani	\N	\N
FN74YhbH4m	2024-02-15 23:23:02.305+00	2024-02-15 23:23:02.305+00	Khagineh Tabriz	857000	m6g8u0QpTC	\N	sonati	\N	\N
7aK2pWosVH	2024-02-15 23:23:02.52+00	2024-02-15 23:23:02.52+00	Khoresh-e Fesenjan	993000	IEqTHcohpJ	\N	sonati	\N	\N
d28V3UXYhv	2024-02-15 23:23:02.725+00	2024-02-15 23:23:02.725+00	Halva Shekari	46000	cmxBcanww9	\N	irani	\N	\N
3SecMM3afn	2024-02-15 23:23:02.934+00	2024-02-15 23:23:02.934+00	Khoresh-e Karafs-e Holu	794000	cmxBcanww9	\N	sonati	\N	\N
4zboFYW0mz	2024-02-15 23:23:03.145+00	2024-02-15 23:23:03.145+00	Khoresh Bademjan	352000	0TvWuLoLF5	\N	irani	\N	\N
jcqwYEkbgn	2024-02-15 23:23:03.353+00	2024-02-15 23:23:03.353+00	Gheimeh	279000	eEmewy7hPd	\N	sonati	\N	\N
GmseTb5sRx	2024-02-15 23:23:03.561+00	2024-02-15 23:23:03.561+00	Kalam Polo Mahicheh	222000	VK3vnSxIy8	\N	sonati	\N	\N
AI4WgPOjeo	2024-02-15 23:23:03.765+00	2024-02-15 23:23:03.765+00	Khoresh-e Fesenjan	293000	tCIEnLLcUc	\N	irani	\N	\N
wjIStAOkam	2024-02-15 23:23:04.056+00	2024-02-15 23:23:04.056+00	Nan-e Barbari	258000	ThMuD3hYRQ	\N	sonati	\N	\N
55ZxFU5hIA	2024-02-15 23:23:04.262+00	2024-02-15 23:23:04.262+00	Khoresh-e Gandom	102000	u5FXeeOChJ	\N	irani	\N	\N
cY1ACB4a4i	2024-02-15 23:23:04.469+00	2024-02-15 23:23:04.469+00	Gheimeh	729000	NY6RE1qgWu	\N	sonati	\N	\N
ZZn6OawsCm	2024-02-15 23:23:04.682+00	2024-02-15 23:23:04.682+00	Dizi	54000	LVYK4mLShP	\N	sonati	\N	\N
RAFibvmw42	2024-02-15 23:23:04.907+00	2024-02-15 23:23:04.907+00	Kalam Polo	323000	yvUod6yLDt	\N	sonati	\N	\N
Jk4TReKnHT	2024-02-15 23:23:05.101+00	2024-02-15 23:23:05.101+00	Moraba-ye Anar	904000	OQWu2bnHeC	\N	sonati	\N	\N
ghCeKS1PES	2024-02-15 23:23:05.306+00	2024-02-15 23:23:05.306+00	Dizi Tabrizi	868000	eEmewy7hPd	\N	irani	\N	\N
0LadH4yGDV	2024-02-15 23:23:05.507+00	2024-02-15 23:23:05.507+00	Kookoo Sabzi	929000	TCkiw6gTDz	\N	irani	\N	\N
9SGJf1hr8T	2024-02-15 23:23:05.71+00	2024-02-15 23:23:05.71+00	Morasa Polo	999000	cwVEh0dqfm	\N	irani	\N	\N
wZLQcyG0HC	2024-02-15 23:23:05.911+00	2024-02-15 23:23:05.911+00	Halim Bademjan	363000	o4VD4BWwDt	\N	sonati	\N	\N
cwYaibRJyV	2024-02-15 23:23:06.115+00	2024-02-15 23:23:06.115+00	Adas Polo	593000	eEmewy7hPd	\N	sonati	\N	\N
gF8tFeDo3Q	2024-02-15 23:23:06.32+00	2024-02-15 23:23:06.32+00	Kookoo Sibzamini	73000	Oahm9sOn1y	\N	sonati	\N	\N
BRnM4ZYSv6	2024-02-15 23:23:06.526+00	2024-02-15 23:23:06.526+00	Morasa Polo	490000	6Fo67rhTSP	\N	irani	\N	\N
ptGXKxhk9f	2024-02-15 23:23:06.726+00	2024-02-15 23:23:06.726+00	Tahdig	160000	HLIPwAqO2R	\N	sonati	\N	\N
BMhzPQ96De	2024-02-15 23:23:06.922+00	2024-02-15 23:23:06.922+00	Moraba-ye Anar Daneh	391000	VK3vnSxIy8	\N	irani	\N	\N
GUrvDH5BWp	2024-02-15 23:23:07.149+00	2024-02-15 23:23:07.149+00	Sheer Khurma	541000	0TvWuLoLF5	\N	sonati	\N	\N
AEJ6x4BycA	2024-02-15 23:23:07.36+00	2024-02-15 23:23:07.36+00	Moraba-ye Gerdoo	479000	vwHi602n66	\N	irani	\N	\N
mA8mqjogRV	2024-02-15 23:23:07.574+00	2024-02-15 23:23:07.574+00	Moraba-ye Anar	399000	CSvk1ycWXk	\N	irani	\N	\N
v8H0F9EXxt	2024-02-15 23:23:07.783+00	2024-02-15 23:23:07.783+00	Khoresh-e Kardeh	120000	BMLzFMvIT6	\N	irani	\N	\N
ZQYHwZTaE3	2024-02-15 23:23:07.985+00	2024-02-15 23:23:07.985+00	Khoresh-e Beh	309000	FYXEfIO1zF	\N	irani	\N	\N
jULgnq4Fgl	2024-02-15 23:23:08.187+00	2024-02-15 23:23:08.187+00	Bastani Sonnati	30000	WnUBBkiDjE	\N	irani	\N	\N
WaylCMI6K8	2024-02-15 23:23:08.391+00	2024-02-15 23:23:08.391+00	Dolma	94000	9GF3y7LmHV	\N	irani	\N	\N
l35eBKKY1Q	2024-02-15 23:23:08.594+00	2024-02-15 23:23:08.594+00	Ghormeh Sabzi	807000	lxQA9rtSfY	\N	sonati	\N	\N
APeOanW5Pd	2024-02-15 23:23:08.813+00	2024-02-15 23:23:08.813+00	Dolma	188000	TCkiw6gTDz	\N	irani	\N	\N
rj1Wxf8EWe	2024-02-15 23:23:09.017+00	2024-02-15 23:23:09.017+00	Baghali Polo ba Goosht	107000	eEmewy7hPd	\N	sonati	\N	\N
W8yp5gnTq5	2024-02-15 23:23:09.223+00	2024-02-15 23:23:09.223+00	Khoresht-e Gheimeh Sibzamini	530000	JLhF4VuByh	\N	sonati	\N	\N
LJY3wCtkKR	2024-02-15 23:23:09.434+00	2024-02-15 23:23:09.434+00	Khoresh Bademjan	529000	XSK814B37m	\N	irani	\N	\N
B42V8bsBPA	2024-02-15 23:23:09.653+00	2024-02-15 23:23:09.653+00	Baghali Polo ba Morgh	890000	G0uU7KQLEt	\N	sonati	\N	\N
ZaNnQQjrJk	2024-02-15 23:23:09.85+00	2024-02-15 23:23:09.85+00	Tachin Morgh	438000	C7II8dYRPY	\N	irani	\N	\N
ICFosfwr2L	2024-02-15 23:23:10.044+00	2024-02-15 23:23:10.044+00	Morasa Polo	733000	WSTLlXDcKl	\N	irani	\N	\N
a2PXmashH2	2024-02-15 23:23:10.241+00	2024-02-15 23:23:10.241+00	Khoresh-e Morgh Ba Zireh	947000	LDrIH1vU8x	\N	irani	\N	\N
lU39AuxRGj	2024-02-15 23:23:10.437+00	2024-02-15 23:23:10.437+00	Khoresh-e Fesenjan	61000	TCkiw6gTDz	\N	irani	\N	\N
bdHSFR78Lz	2024-02-15 23:23:10.638+00	2024-02-15 23:23:10.638+00	Faloodeh	975000	HLIPwAqO2R	\N	sonati	\N	\N
sJr3AeBoWf	2024-02-15 23:23:10.916+00	2024-02-15 23:23:10.916+00	Adas Polo	988000	LDrIH1vU8x	\N	sonati	\N	\N
KjCbYnFclK	2024-02-15 23:23:11.117+00	2024-02-15 23:23:11.117+00	Khagineh	805000	RkhjIQJgou	\N	sonati	\N	\N
KwYNFE4dWH	2024-02-15 23:23:11.323+00	2024-02-15 23:23:11.323+00	Dizi Sara	433000	TZsdmscJ2B	\N	irani	\N	\N
75O2NudkEz	2024-02-15 23:23:11.529+00	2024-02-15 23:23:11.529+00	Khoresht-e Gheimeh Sibzamini	885000	TpGyMZM9BG	\N	irani	\N	\N
zx8FfEgcDL	2024-02-15 23:23:11.739+00	2024-02-15 23:23:11.739+00	Ghormeh Sabzi	322000	Pa0qBO2rzK	\N	irani	\N	\N
y4aLZz07F3	2024-02-15 23:23:11.943+00	2024-02-15 23:23:11.943+00	Kookoo Sabzi	237000	cTIjuPjyIa	\N	irani	\N	\N
Iqf2ukSPDj	2024-02-15 23:23:12.138+00	2024-02-15 23:23:12.138+00	Morasa Polo	906000	oABNR2FF6S	\N	irani	\N	\N
ZOAjHorBGK	2024-02-15 23:23:12.34+00	2024-02-15 23:23:12.34+00	Bastani Sonnati	536000	ThMuD3hYRQ	\N	irani	\N	\N
T5BVoUPD9f	2024-02-15 23:23:12.55+00	2024-02-15 23:23:12.55+00	Sabzi Polo	715000	RBRcyltRSC	\N	irani	\N	\N
Dbx4TjkNAZ	2024-02-15 23:23:12.75+00	2024-02-15 23:23:12.75+00	Khoresh-e Maast	961000	IEqTHcohpJ	\N	irani	\N	\N
e6p1ejB0TQ	2024-02-15 23:23:12.953+00	2024-02-15 23:23:12.953+00	Ash-e Doogh	227000	cFtamPA0zH	\N	irani	\N	\N
9R6DZsMDqw	2024-02-15 23:23:13.157+00	2024-02-15 23:23:13.157+00	Samanu	990000	XwWwGnkXNj	\N	sonati	\N	\N
fkjH8ZgrPa	2024-02-15 23:23:13.359+00	2024-02-15 23:23:13.359+00	Joojeh Kabab	381000	ThMuD3hYRQ	\N	sonati	\N	\N
lxZuvq8fRJ	2024-02-15 23:23:13.563+00	2024-02-15 23:23:13.563+00	Moraba-ye Gerdoo	757000	m8hjjLVdPS	\N	sonati	\N	\N
ycB3UYdkxT	2024-02-15 23:23:13.77+00	2024-02-15 23:23:13.77+00	Khoresh-e Baamieh	296000	D0A6GLdsDM	\N	irani	\N	\N
jdxCdprCS6	2024-02-15 23:23:13.977+00	2024-02-15 23:23:13.977+00	Khoresht-e Gheymeh	52000	na5crB8ED1	\N	sonati	\N	\N
nRnw4UozYM	2024-02-15 23:23:14.191+00	2024-02-15 23:23:14.191+00	Gheimeh	205000	e037qpAih3	\N	irani	\N	\N
GfXlieBEzr	2024-02-15 23:23:14.395+00	2024-02-15 23:23:14.395+00	Khoresht-e Karafs	531000	JLhF4VuByh	\N	irani	\N	\N
jnF3WHyPr6	2024-02-15 23:23:14.589+00	2024-02-15 23:23:14.589+00	Mast-o-Khiar	797000	bi1IivsuUB	\N	irani	\N	\N
wnzAzNAn9F	2024-02-15 23:23:14.795+00	2024-02-15 23:23:14.795+00	Khoresh-e Chelo	99000	Gl96vGdYHM	\N	sonati	\N	\N
ReSmA8qduB	2024-02-15 23:23:14.988+00	2024-02-15 23:23:14.988+00	Khoresh-e Morgh Ba Zireh	817000	FJOTueDfs2	\N	irani	\N	\N
jq5AbqijDL	2024-02-15 23:23:15.19+00	2024-02-15 23:23:15.19+00	Khoresh-e Kardeh	157000	na5crB8ED1	\N	irani	\N	\N
2XC9LzMgyD	2024-02-15 23:23:15.394+00	2024-02-15 23:23:15.394+00	Samanu	260000	D0A6GLdsDM	\N	irani	\N	\N
IPHTGEWEzI	2024-02-15 23:23:15.585+00	2024-02-15 23:23:15.585+00	Gondi	815000	mMYg4cyd5R	\N	irani	\N	\N
G75ewHG3ot	2024-02-15 23:23:15.785+00	2024-02-15 23:23:15.785+00	Khoresh-e Loobia Sabz	628000	vwHi602n66	\N	irani	\N	\N
ZsudkpFRDG	2024-02-15 23:23:15.989+00	2024-02-15 23:23:15.989+00	Khoresh-e Baamieh	125000	cTIjuPjyIa	\N	sonati	\N	\N
dPof8IP3ug	2024-02-15 23:23:16.198+00	2024-02-15 23:23:16.198+00	Shirin Laboo	135000	LVYK4mLShP	\N	irani	\N	\N
ipIEx1B7zB	2024-02-15 23:23:16.407+00	2024-02-15 23:23:16.407+00	Samanu	906000	FJOTueDfs2	\N	irani	\N	\N
B4F2NuADk6	2024-02-15 23:23:16.611+00	2024-02-15 23:23:16.611+00	Halva Shekari	729000	XSK814B37m	\N	sonati	\N	\N
WTBSO5Oi95	2024-02-15 23:23:16.818+00	2024-02-15 23:23:16.818+00	Khoresht-e Gheimeh Sibzamini	396000	H40ivltLwZ	\N	irani	\N	\N
UXbT7oM40J	2024-02-15 23:23:17.02+00	2024-02-15 23:23:17.02+00	Moraba-ye Anar Daneh	93000	na5crB8ED1	\N	irani	\N	\N
Y4ZM5sgb7G	2024-02-15 23:23:17.222+00	2024-02-15 23:23:17.222+00	Sabzi Polo	220000	cmxBcanww9	\N	sonati	\N	\N
tiow3D8lCt	2024-02-15 23:23:17.425+00	2024-02-15 23:23:17.425+00	Haleem	806000	u5FXeeOChJ	\N	sonati	\N	\N
TMtUSoor5v	2024-02-15 23:23:17.629+00	2024-02-15 23:23:17.629+00	Kalam Polo	594000	rKyjwoEIRp	\N	irani	\N	\N
cUavaLIjRU	2024-02-15 23:23:17.832+00	2024-02-15 23:23:17.832+00	Khoresh-e Loobia Sabz	372000	H40ivltLwZ	\N	sonati	\N	\N
Uqanh92IaH	2024-02-15 23:23:18.035+00	2024-02-15 23:23:18.035+00	Khoresh-e Sabzi	91000	o90lhsZ7FK	\N	irani	\N	\N
h9gmR5DUGs	2024-02-15 23:23:18.23+00	2024-02-15 23:23:18.23+00	Tahchin	456000	LDrIH1vU8x	\N	sonati	\N	\N
26a8e3ZBK4	2024-02-15 23:23:18.482+00	2024-02-15 23:23:18.482+00	Ash-e Miveh	319000	fKTSJPdUi9	\N	irani	\N	\N
QPQvkSXvjP	2024-02-15 23:23:18.696+00	2024-02-15 23:23:18.696+00	Baghali Polo ba Goosht	84000	TpGyMZM9BG	\N	irani	\N	\N
GULTZjtAWM	2024-02-15 23:23:18.904+00	2024-02-15 23:23:18.904+00	Halim Bademjan	167000	ThMuD3hYRQ	\N	sonati	\N	\N
HENSqy6thF	2024-02-15 23:23:19.105+00	2024-02-15 23:23:19.105+00	Khoresh-e Nokhodchi	973000	NY6RE1qgWu	\N	irani	\N	\N
00ptmoFINE	2024-02-15 23:23:19.305+00	2024-02-15 23:23:19.305+00	Sirabi	217000	OQWu2bnHeC	\N	sonati	\N	\N
sL1Kj8BX6i	2024-02-15 23:23:19.498+00	2024-02-15 23:23:19.498+00	Halim Bademjan	544000	IEqTHcohpJ	\N	sonati	\N	\N
Pxvxq2BNSd	2024-02-15 23:23:19.698+00	2024-02-15 23:23:19.698+00	Salad Shirazi	343000	3P6kmNoY1F	\N	sonati	\N	\N
BjrmVIySDg	2024-02-15 23:23:19.905+00	2024-02-15 23:23:19.905+00	Shirin Adas	485000	RkhjIQJgou	\N	irani	\N	\N
xMJe1CbVBi	2024-02-15 23:23:20.109+00	2024-02-15 23:23:20.109+00	Shirin Polo	694000	lEPdiO1EDi	\N	irani	\N	\N
72B5CkLh2G	2024-02-15 23:23:20.315+00	2024-02-15 23:23:20.315+00	Torshe Tareh	549000	lxQA9rtSfY	\N	sonati	\N	\N
XLQ79yBTyC	2024-02-15 23:23:20.513+00	2024-02-15 23:23:20.513+00	Khoresh-e Maast	25000	qEQ9tmLyW9	\N	irani	\N	\N
wPagTqIaBw	2024-02-15 23:23:20.711+00	2024-02-15 23:23:20.711+00	Khagineh Gorgan	878000	l1Bslv8T2k	\N	sonati	\N	\N
32VLgETNM1	2024-02-15 23:23:20.905+00	2024-02-15 23:23:20.905+00	Baghali Polo ba Morgh	345000	CSvk1ycWXk	\N	sonati	\N	\N
rkuOfXjLWL	2024-02-15 23:23:21.109+00	2024-02-15 23:23:21.109+00	Khoresht-e Torsh	634000	HSEugQ3Ouj	\N	sonati	\N	\N
v0ATBQAogz	2024-02-15 23:23:21.31+00	2024-02-15 23:23:21.31+00	Dizi Tabrizi	380000	D0A6GLdsDM	\N	irani	\N	\N
AR8a5wLtZv	2024-02-15 23:23:21.515+00	2024-02-15 23:23:21.515+00	Halva Ardeh	153000	uigc7bJBOJ	\N	sonati	\N	\N
sbZgQtjyoQ	2024-02-15 23:23:21.722+00	2024-02-15 23:23:21.722+00	Joojeh Kabab	881000	Oahm9sOn1y	\N	irani	\N	\N
mB2nCnrKGk	2024-02-15 23:23:21.929+00	2024-02-15 23:23:21.929+00	Khoresht-e Torsh	140000	HXtEwLBC7f	\N	sonati	\N	\N
l9jnUGhWJG	2024-02-15 23:23:22.133+00	2024-02-15 23:23:22.133+00	Khoresh-e Loobia Sabz	76000	NY6RE1qgWu	\N	irani	\N	\N
dxJIyFDg07	2024-02-15 23:23:22.338+00	2024-02-15 23:23:22.338+00	Mast-o-Khiar	739000	D0A6GLdsDM	\N	sonati	\N	\N
tygtQrI8v4	2024-02-15 23:23:22.529+00	2024-02-15 23:23:22.529+00	Shirin Laboo	249000	tCIEnLLcUc	\N	sonati	\N	\N
g8oNeFF20Y	2024-02-15 23:23:22.731+00	2024-02-15 23:23:22.731+00	Khoresh-e Anar	39000	bi1IivsuUB	\N	irani	\N	\N
AO3xhBFcfV	2024-02-15 23:23:22.938+00	2024-02-15 23:23:22.938+00	Ashe Reshteh	219000	RkhjIQJgou	\N	irani	\N	\N
7ZfsoTjl5N	2024-02-15 23:23:23.147+00	2024-02-15 23:23:23.147+00	Torshe Tareh	394000	l1Bslv8T2k	\N	sonati	\N	\N
LK8DXUgKxo	2024-02-15 23:23:23.356+00	2024-02-15 23:23:23.356+00	Dizi Tabrizi	374000	bi1IivsuUB	\N	irani	\N	\N
wX9vKOFZMr	2024-02-15 23:23:23.561+00	2024-02-15 23:23:23.561+00	Kuku	876000	HLIPwAqO2R	\N	sonati	\N	\N
Xml9qRHVkL	2024-02-15 23:23:23.766+00	2024-02-15 23:23:23.766+00	Tahchin	503000	jjVdtithcD	\N	sonati	\N	\N
c3UyeA4tpj	2024-02-15 23:23:23.974+00	2024-02-15 23:23:23.974+00	Yatimcheh	906000	XwWwGnkXNj	\N	sonati	\N	\N
yYcARMGus5	2024-02-15 23:23:24.177+00	2024-02-15 23:23:24.177+00	Dolma	993000	6Fo67rhTSP	\N	irani	\N	\N
jrAs07YUSm	2024-02-15 23:23:24.38+00	2024-02-15 23:23:24.38+00	Kabab Koobideh	373000	na5crB8ED1	\N	irani	\N	\N
DR5Zvp9L0v	2024-02-15 23:23:24.584+00	2024-02-15 23:23:24.584+00	Khagineh	563000	Oahm9sOn1y	\N	sonati	\N	\N
hCPR61eMB3	2024-02-15 23:23:24.787+00	2024-02-15 23:23:24.787+00	Nan-e Barbari	525000	cFtamPA0zH	\N	sonati	\N	\N
rybYaGXT9I	2024-02-15 23:23:24.989+00	2024-02-15 23:23:24.989+00	Shirin Yazdi	971000	6KvFK8yy1q	\N	irani	\N	\N
ZG7PX7WiXD	2024-02-15 23:23:25.193+00	2024-02-15 23:23:25.193+00	Khoresh-e Mast	666000	u5FXeeOChJ	\N	irani	\N	\N
tVVwsguDAc	2024-02-15 23:23:25.393+00	2024-02-15 23:23:25.393+00	Mast-o-Khiar	812000	UDXF0qXvDY	\N	sonati	\N	\N
icnyVpX2nr	2024-02-15 23:23:25.585+00	2024-02-15 23:23:25.585+00	Kufteh Tabrizi	435000	E2hBZzDsjO	\N	sonati	\N	\N
VBSIoD4ARK	2024-02-15 23:24:00.697+00	2024-02-15 23:24:00.697+00	Salad Shirazi	852000	H40ivltLwZ	\N	sonati	\N	\N
s1zTqGwfWS	2024-02-15 23:24:00.903+00	2024-02-15 23:24:00.903+00	Gondi	71000	FJOTueDfs2	\N	sonati	\N	\N
4rufhrIB1W	2024-02-15 23:24:01.112+00	2024-02-15 23:24:01.112+00	Kookoo Sibzamini	272000	Pa0qBO2rzK	\N	sonati	\N	\N
so8OWfcZ7a	2024-02-15 23:24:01.323+00	2024-02-15 23:24:01.323+00	Kookoo Sabzi	734000	Oahm9sOn1y	\N	sonati	\N	\N
RrxnoGRasb	2024-02-15 23:24:01.526+00	2024-02-15 23:24:01.526+00	Ash-e Doogh	544000	lEPdiO1EDi	\N	irani	\N	\N
wVUGbHMp6e	2024-02-15 23:24:01.74+00	2024-02-15 23:24:01.74+00	Kufteh Tabrizi	104000	INeptnSdJC	\N	sonati	\N	\N
WXscW8R7zu	2024-02-15 23:24:01.951+00	2024-02-15 23:24:01.951+00	Salad Shirazi	819000	axyV0Fu7pm	\N	irani	\N	\N
tWzwgqDst5	2024-02-15 23:24:02.162+00	2024-02-15 23:24:02.162+00	Khoresh-e Sabzi	440000	lxQA9rtSfY	\N	sonati	\N	\N
7tB9j36ReH	2024-02-15 23:24:02.367+00	2024-02-15 23:24:02.367+00	Adas Polo	849000	9GF3y7LmHV	\N	sonati	\N	\N
OgyHXodhkp	2024-02-15 23:24:02.572+00	2024-02-15 23:24:02.572+00	Nan-e Barbari	129000	mMYg4cyd5R	\N	irani	\N	\N
Jkgfgv9mhJ	2024-02-15 23:24:02.788+00	2024-02-15 23:24:02.788+00	Lubia Polo	37000	l1Bslv8T2k	\N	sonati	\N	\N
2YdSAq7edY	2024-02-15 23:24:03.009+00	2024-02-15 23:24:03.009+00	Aloo Mosamma	784000	qP3EdIVzfB	\N	irani	\N	\N
UnzQ84kDCO	2024-02-15 23:24:03.205+00	2024-02-15 23:24:03.205+00	Khoresht-e Gheymeh	238000	oABNR2FF6S	\N	sonati	\N	\N
BDymfo0HAK	2024-02-15 23:24:03.398+00	2024-02-15 23:24:03.398+00	Samanu	355000	WnUBBkiDjE	\N	irani	\N	\N
boZDxv0sZ2	2024-02-15 23:24:03.596+00	2024-02-15 23:24:03.596+00	Khagineh	327000	e037qpAih3	\N	sonati	\N	\N
tTIRW7oXEV	2024-02-15 23:23:25.785+00	2024-02-15 23:23:25.785+00	Tahdig	237000	WSTLlXDcKl	\N	irani	\N	\N
eoITUSF3OF	2024-02-15 23:23:25.989+00	2024-02-15 23:23:25.989+00	Khoresh-e Baamieh	436000	UCFo58JaaD	\N	sonati	\N	\N
8fvC9Z7eYE	2024-02-15 23:23:26.195+00	2024-02-15 23:23:26.195+00	Moraba-ye Beh	10000	oABNR2FF6S	\N	irani	\N	\N
QBGRIpFACk	2024-02-15 23:23:26.403+00	2024-02-15 23:23:26.403+00	Dizi	710000	P9sBFomftT	\N	irani	\N	\N
kUaEv2ZcAX	2024-02-15 23:23:26.603+00	2024-02-15 23:23:26.603+00	Sholeh Zard	661000	u5FXeeOChJ	\N	irani	\N	\N
AntG0dGYrD	2024-02-15 23:23:26.809+00	2024-02-15 23:23:26.809+00	Khoresh-e Kardeh	382000	NBojpORh3G	\N	sonati	\N	\N
wNWAcAEovl	2024-02-15 23:23:27.015+00	2024-02-15 23:23:27.015+00	Khagineh	978000	IybX0eBoO3	\N	sonati	\N	\N
QrMa2MoavX	2024-02-15 23:23:27.217+00	2024-02-15 23:23:27.217+00	Lubia Polo	22000	JZOBDAh12a	\N	irani	\N	\N
ZLIsaYvdjS	2024-02-15 23:23:27.422+00	2024-02-15 23:23:27.422+00	Dizi Tabrizi	655000	y4RkaDbkec	\N	irani	\N	\N
RNsqmUxXFa	2024-02-15 23:23:27.629+00	2024-02-15 23:23:27.629+00	Sirabi	772000	tCIEnLLcUc	\N	irani	\N	\N
D88CKYwTeF	2024-02-15 23:23:27.833+00	2024-02-15 23:23:27.833+00	Salad Shirazi	74000	NY6RE1qgWu	\N	sonati	\N	\N
r9uQDKHRH3	2024-02-15 23:23:28.04+00	2024-02-15 23:23:28.04+00	Khoresh-e Anar	558000	CSvk1ycWXk	\N	sonati	\N	\N
pYzwgnCetd	2024-02-15 23:23:28.249+00	2024-02-15 23:23:28.249+00	Shirin Polo	871000	E2hBZzDsjO	\N	sonati	\N	\N
xB8HaXoN10	2024-02-15 23:23:28.456+00	2024-02-15 23:23:28.456+00	Khoresh-e Kadoo	947000	bQpy9LEJWn	\N	sonati	\N	\N
JcqvGFVZBK	2024-02-15 23:23:28.662+00	2024-02-15 23:23:28.662+00	Khoresh-e Havij ba Morgh	833000	P9sBFomftT	\N	irani	\N	\N
cQeuJ3fo5P	2024-02-15 23:23:28.865+00	2024-02-15 23:23:28.865+00	Khoresh-e Sabzi	302000	TpGyMZM9BG	\N	irani	\N	\N
1McKhNc4qV	2024-02-15 23:23:29.069+00	2024-02-15 23:23:29.069+00	Moraba-ye Anar Daneh	626000	6KvFK8yy1q	\N	irani	\N	\N
7o2RnYEhpm	2024-02-15 23:23:29.276+00	2024-02-15 23:23:29.276+00	Haleem	296000	qEQ9tmLyW9	\N	irani	\N	\N
nBF3vjC455	2024-02-15 23:23:29.489+00	2024-02-15 23:23:29.489+00	Moraba-ye Gerdoo	170000	WSTLlXDcKl	\N	irani	\N	\N
hpgiq0WpIH	2024-02-15 23:23:29.693+00	2024-02-15 23:23:29.693+00	Khoresh-e Sabzi	683000	IybX0eBoO3	\N	sonati	\N	\N
Da2lxpsjo6	2024-02-15 23:23:29.899+00	2024-02-15 23:23:29.899+00	Kuku	417000	cTIjuPjyIa	\N	irani	\N	\N
abkAkWaUKK	2024-02-15 23:23:30.108+00	2024-02-15 23:23:30.108+00	Nan-e Barbari	82000	na5crB8ED1	\N	irani	\N	\N
3YCE19Nove	2024-02-15 23:23:30.311+00	2024-02-15 23:23:30.311+00	Khoresh-e Havij ba Morgh	680000	AgU9OLJkqz	\N	sonati	\N	\N
uh8GXY1xsS	2024-02-15 23:23:30.514+00	2024-02-15 23:23:30.514+00	Khoresh-e Beh	229000	rT0UCBK1bE	\N	sonati	\N	\N
I1sAmxGB4n	2024-02-15 23:23:30.716+00	2024-02-15 23:23:30.716+00	Sheer Khurma	779000	bQ0JOk10eL	\N	irani	\N	\N
qA9sxPLd8l	2024-02-15 23:23:30.919+00	2024-02-15 23:23:30.919+00	Sabzi Polo	311000	l1Bslv8T2k	\N	irani	\N	\N
eG45YmiVxW	2024-02-15 23:23:31.127+00	2024-02-15 23:23:31.127+00	Morgh-e Torsh	351000	EmIUBFwx0Z	\N	irani	\N	\N
wrKIoQbd6w	2024-02-15 23:23:31.33+00	2024-02-15 23:23:31.33+00	Khoresh-e Anar	496000	fwLPZZ8YQa	\N	sonati	\N	\N
ANKypqZmDj	2024-02-15 23:23:31.533+00	2024-02-15 23:23:31.533+00	Khoresh-e Baamieh	416000	XwWwGnkXNj	\N	sonati	\N	\N
WyPpbVIidB	2024-02-15 23:23:31.806+00	2024-02-15 23:23:31.806+00	Dolma	293000	y4RkaDbkec	\N	irani	\N	\N
eYzTHfBCDA	2024-02-15 23:23:32.014+00	2024-02-15 23:23:32.014+00	Khoresh-e Gerdoo	988000	m8hjjLVdPS	\N	irani	\N	\N
fIzIPa8nc1	2024-02-15 23:23:32.217+00	2024-02-15 23:23:32.217+00	Faloodeh	831000	TCkiw6gTDz	\N	irani	\N	\N
zTEBM6pOCz	2024-02-15 23:23:32.42+00	2024-02-15 23:23:32.42+00	Baghali Polo	640000	8w7i8C3NnT	\N	sonati	\N	\N
DG1hUw9n1C	2024-02-15 23:23:32.624+00	2024-02-15 23:23:32.624+00	Khagineh Gorgan	962000	PF8w2gMAdi	\N	irani	\N	\N
LpgdzATrdE	2024-02-15 23:23:32.827+00	2024-02-15 23:23:32.827+00	Moraba-ye Anar	673000	LgJuu5ABe5	\N	sonati	\N	\N
FW3TD9tIu6	2024-02-15 23:23:33.03+00	2024-02-15 23:23:33.03+00	Faloodeh	538000	bi1IivsuUB	\N	sonati	\N	\N
EcHOtYrTiL	2024-02-15 23:23:33.235+00	2024-02-15 23:23:33.235+00	Khoresht-e Gheymeh	461000	m8hjjLVdPS	\N	irani	\N	\N
Drf1t1q4fG	2024-02-15 23:23:33.444+00	2024-02-15 23:23:33.444+00	Morgh-e Torsh	958000	Pja6n3yaWZ	\N	sonati	\N	\N
Q8bGN32MQL	2024-02-15 23:23:33.652+00	2024-02-15 23:23:33.652+00	Khoresh-e Karafs-e Holu	600000	CSvk1ycWXk	\N	sonati	\N	\N
uX0VzWk8xi	2024-02-15 23:23:33.954+00	2024-02-15 23:23:33.954+00	Torshe Tareh	510000	TZsdmscJ2B	\N	irani	\N	\N
vug4mxBjFJ	2024-02-15 23:23:34.157+00	2024-02-15 23:23:34.157+00	Khagineh Birjand	491000	TpGyMZM9BG	\N	sonati	\N	\N
gjQh5SDxjf	2024-02-15 23:23:34.361+00	2024-02-15 23:23:34.361+00	Ashe Reshteh	674000	JZOBDAh12a	\N	irani	\N	\N
AanRbjFcyS	2024-02-15 23:23:34.568+00	2024-02-15 23:23:34.568+00	Faloodeh	904000	e037qpAih3	\N	irani	\N	\N
IPoKFOUxgg	2024-02-15 23:23:34.775+00	2024-02-15 23:23:34.775+00	Adas Polo	359000	RBRcyltRSC	\N	sonati	\N	\N
K8sn60yNtc	2024-02-15 23:23:34.981+00	2024-02-15 23:23:34.981+00	Khoresh-e Anar	794000	LDrIH1vU8x	\N	irani	\N	\N
AfDxRZIJCo	2024-02-15 23:23:35.188+00	2024-02-15 23:23:35.188+00	Khoresh-e Gerdoo	879000	qZmnAnnPEb	\N	sonati	\N	\N
tAi0K3dlao	2024-02-15 23:23:35.391+00	2024-02-15 23:23:35.391+00	Samanu	557000	RBRcyltRSC	\N	irani	\N	\N
FubouUD2LU	2024-02-15 23:23:35.594+00	2024-02-15 23:23:35.594+00	Khoresh-e Beh	690000	mMYg4cyd5R	\N	irani	\N	\N
gfCDfGgVEF	2024-02-15 23:23:35.8+00	2024-02-15 23:23:35.8+00	Yatimcheh	164000	08liHW08uC	\N	sonati	\N	\N
gsA9xOp9wd	2024-02-15 23:23:36.005+00	2024-02-15 23:23:36.005+00	Kookoo Sabzi	775000	XSK814B37m	\N	sonati	\N	\N
A0PPY21iiI	2024-02-15 23:23:36.211+00	2024-02-15 23:23:36.211+00	Khoresht-e Torsh	592000	XpUyRlB6FI	\N	sonati	\N	\N
99rbs1jR2T	2024-02-15 23:23:36.416+00	2024-02-15 23:23:36.416+00	Mast-o-Khiar	794000	u5FXeeOChJ	\N	irani	\N	\N
SJgcZZFa1j	2024-02-15 23:23:36.625+00	2024-02-15 23:23:36.625+00	Ash-e Mast	853000	C7II8dYRPY	\N	irani	\N	\N
9E1JAZMno5	2024-02-15 23:23:36.834+00	2024-02-15 23:23:36.834+00	Khoresh-e Fesenjan	398000	m6g8u0QpTC	\N	sonati	\N	\N
PYuD8GPVYg	2024-02-15 23:23:37.037+00	2024-02-15 23:23:37.037+00	Khoresh-e Gerdoo	361000	RkhjIQJgou	\N	irani	\N	\N
CFAES3wkky	2024-02-15 23:23:37.24+00	2024-02-15 23:23:37.24+00	Tahdig	171000	uigc7bJBOJ	\N	irani	\N	\N
5tpu9otwVI	2024-02-15 23:23:37.446+00	2024-02-15 23:23:37.446+00	Haleem	581000	IybX0eBoO3	\N	irani	\N	\N
vXz8840ihZ	2024-02-15 23:23:37.65+00	2024-02-15 23:23:37.65+00	Khoresht-e Alu Esfenaj	825000	HXtEwLBC7f	\N	irani	\N	\N
APc6HcN6VF	2024-02-15 23:23:37.852+00	2024-02-15 23:23:37.852+00	Morasa Polo	708000	XwszrNEEEj	\N	irani	\N	\N
djm4HvByXd	2024-02-15 23:23:38.061+00	2024-02-15 23:23:38.061+00	Khoresht-e Gheimeh Sibzamini	551000	tCIEnLLcUc	\N	irani	\N	\N
Wq3kNVsn38	2024-02-15 23:23:38.262+00	2024-02-15 23:23:38.262+00	Gondi	551000	IybX0eBoO3	\N	irani	\N	\N
76jvd4zBQn	2024-02-15 23:23:38.464+00	2024-02-15 23:23:38.464+00	Koloocheh	629000	PF8w2gMAdi	\N	irani	\N	\N
dDJZV95irk	2024-02-15 23:23:38.67+00	2024-02-15 23:23:38.67+00	Dizi	518000	jjVdtithcD	\N	irani	\N	\N
rRhE5MPEKG	2024-02-15 23:23:38.871+00	2024-02-15 23:23:38.871+00	Khoresh-e Kardeh	513000	UDXF0qXvDY	\N	sonati	\N	\N
I0SMdOh0yA	2024-02-15 23:23:39.079+00	2024-02-15 23:23:39.079+00	Khoresh-e Maast	128000	WBFeKac0OO	\N	sonati	\N	\N
eyEUj3QDJw	2024-02-15 23:23:39.286+00	2024-02-15 23:23:39.286+00	Mast-o-Khiar	641000	JLhF4VuByh	\N	sonati	\N	\N
EvzeHp8QyW	2024-02-15 23:23:39.506+00	2024-02-15 23:23:39.506+00	Mast-o-Khiar	438000	E2hBZzDsjO	\N	sonati	\N	\N
vVmmgUMKV2	2024-02-15 23:23:39.715+00	2024-02-15 23:23:39.715+00	Halva	776000	jHqCpA1nWb	\N	irani	\N	\N
pW4T6HAdOv	2024-02-15 23:23:40.008+00	2024-02-15 23:23:40.008+00	Samanu	436000	fwLPZZ8YQa	\N	sonati	\N	\N
eeowM9LlZo	2024-02-15 23:23:40.401+00	2024-02-15 23:23:40.401+00	Ash-e Mast	967000	yvUod6yLDt	\N	irani	\N	\N
PQwsVTzUAh	2024-02-15 23:23:40.616+00	2024-02-15 23:23:40.616+00	Halva Ardeh	273000	LVYK4mLShP	\N	irani	\N	\N
422ORyxd5h	2024-02-15 23:23:40.809+00	2024-02-15 23:23:40.809+00	Ghormeh Sabzi	265000	u5FXeeOChJ	\N	irani	\N	\N
UTk5EZcOdC	2024-02-15 23:23:41.02+00	2024-02-15 23:23:41.02+00	Khoresht-e Torsh	299000	HSEugQ3Ouj	\N	irani	\N	\N
iqhqI55TQY	2024-02-15 23:23:41.233+00	2024-02-15 23:23:41.233+00	Moraba-ye Anar	552000	Pja6n3yaWZ	\N	sonati	\N	\N
85orE6sN0V	2024-02-15 23:23:41.452+00	2024-02-15 23:23:41.452+00	Kufteh Tabrizi	382000	Gl96vGdYHM	\N	sonati	\N	\N
o9sxT1NsEq	2024-02-15 23:23:41.655+00	2024-02-15 23:23:41.655+00	Khoresh-e Maast	856000	LgJuu5ABe5	\N	sonati	\N	\N
B8bI8EVggs	2024-02-15 23:23:41.851+00	2024-02-15 23:23:41.851+00	Shirin Polo	237000	yvUod6yLDt	\N	sonati	\N	\N
FnWHUiDBqQ	2024-02-15 23:23:42.06+00	2024-02-15 23:23:42.06+00	Khoresh-e Fesenjan	294000	89xRG1afNi	\N	sonati	\N	\N
aDkYXegvTX	2024-02-15 23:23:42.364+00	2024-02-15 23:23:42.364+00	Morgh-e Torsh	898000	Oahm9sOn1y	\N	irani	\N	\N
HHd2SGSCyu	2024-02-15 23:23:42.578+00	2024-02-15 23:23:42.578+00	Baghali Ghatogh	267000	mMYg4cyd5R	\N	irani	\N	\N
FtWyjdaVEd	2024-02-15 23:23:42.787+00	2024-02-15 23:23:42.787+00	Moraba-ye Gerdoo	751000	LDrIH1vU8x	\N	sonati	\N	\N
s5HBd9Gsxa	2024-02-15 23:23:42.986+00	2024-02-15 23:23:42.986+00	Shirin Adas	845000	HXtEwLBC7f	\N	irani	\N	\N
BuArS4INTG	2024-02-15 23:23:43.193+00	2024-02-15 23:23:43.193+00	Sabzi Polo	524000	JRi61dUphq	\N	irani	\N	\N
ehY5OiTeWV	2024-02-15 23:23:43.402+00	2024-02-15 23:23:43.402+00	Nan-e Barbari	323000	BMLzFMvIT6	\N	sonati	\N	\N
sRvri2ihxR	2024-02-15 23:23:43.609+00	2024-02-15 23:23:43.609+00	Khoresh-e Mast	936000	u5FXeeOChJ	\N	sonati	\N	\N
yzLbytYES5	2024-02-15 23:23:43.814+00	2024-02-15 23:23:43.814+00	Naz Khatoon	330000	0TvWuLoLF5	\N	sonati	\N	\N
Uvr5NUZIKm	2024-02-15 23:23:44.02+00	2024-02-15 23:23:44.02+00	Khoresh-e Mast	751000	rT0UCBK1bE	\N	sonati	\N	\N
68y67WN1Kv	2024-02-15 23:23:44.223+00	2024-02-15 23:23:44.223+00	Moraba-ye Anar	918000	o4VD4BWwDt	\N	sonati	\N	\N
iIS1RbCNJg	2024-02-15 23:23:44.429+00	2024-02-15 23:23:44.429+00	Kuku	480000	UDXF0qXvDY	\N	irani	\N	\N
n5BVORfKRF	2024-02-15 23:23:44.636+00	2024-02-15 23:23:44.636+00	Khoresh-e Sabzi	388000	JRi61dUphq	\N	irani	\N	\N
rEiIRkWAfv	2024-02-15 23:23:44.84+00	2024-02-15 23:23:44.84+00	Khoresh-e Anar	599000	XwszrNEEEj	\N	sonati	\N	\N
vjU68l3H7e	2024-02-15 23:23:45.041+00	2024-02-15 23:23:45.041+00	Abgoosht	519000	JLhF4VuByh	\N	sonati	\N	\N
OSeG2Hp56A	2024-02-15 23:23:45.247+00	2024-02-15 23:23:45.247+00	Sirabi	770000	cFtamPA0zH	\N	irani	\N	\N
jZ9IyzZjTH	2024-02-15 23:23:45.453+00	2024-02-15 23:23:45.453+00	Shirin Yazdi	74000	3P6kmNoY1F	\N	sonati	\N	\N
CvQEjgZnT0	2024-02-15 23:24:03.806+00	2024-02-15 23:24:03.806+00	Shirin Polo	804000	cFtamPA0zH	\N	irani	\N	\N
CACfigBGS9	2024-02-15 23:24:04.069+00	2024-02-15 23:24:04.069+00	Bastani Akbar Mashti	497000	INeptnSdJC	\N	sonati	\N	\N
HWkdglGTD6	2024-02-15 23:24:04.283+00	2024-02-15 23:24:04.283+00	Kookoo Sibzamini	496000	VK3vnSxIy8	\N	sonati	\N	\N
RnGm9MYrZL	2024-02-15 23:24:04.488+00	2024-02-15 23:24:04.488+00	Adas Polo	263000	rKyjwoEIRp	\N	irani	\N	\N
TKPzNIS1iV	2024-02-15 23:24:04.698+00	2024-02-15 23:24:04.698+00	Abgoosht	159000	fwLPZZ8YQa	\N	sonati	\N	\N
q8uNw7eiYl	2024-02-15 23:24:04.91+00	2024-02-15 23:24:04.91+00	Khoresht-e Alu Esfenaj	855000	FJOTueDfs2	\N	irani	\N	\N
2HBKYD62WN	2024-02-15 23:24:05.291+00	2024-02-15 23:24:05.291+00	Torshe Tareh	262000	cFtamPA0zH	\N	irani	\N	\N
mPqXcPKeNO	2024-02-15 23:24:05.498+00	2024-02-15 23:24:05.498+00	Moraba-ye Anar Daneh	574000	BMLzFMvIT6	\N	irani	\N	\N
N7rXKvE9Wo	2024-02-15 23:24:05.696+00	2024-02-15 23:24:05.696+00	Sholeh Zard	907000	UDXF0qXvDY	\N	sonati	\N	\N
44szlN8FUP	2024-02-15 23:24:05.9+00	2024-02-15 23:24:05.9+00	Khoresh-e Loobia Sabz	762000	o4VD4BWwDt	\N	irani	\N	\N
TSYTKQanHl	2024-02-15 23:24:06.109+00	2024-02-15 23:24:06.109+00	Sirabi	84000	FYXEfIO1zF	\N	sonati	\N	\N
h3Uag6ANVl	2024-02-15 23:24:06.314+00	2024-02-15 23:24:06.314+00	Mast-o-Khiar	22000	bQpy9LEJWn	\N	irani	\N	\N
v0n8JK1FEL	2024-02-15 23:24:06.518+00	2024-02-15 23:24:06.518+00	Ash-e Doogh	188000	m6g8u0QpTC	\N	irani	\N	\N
tpFElSnfp4	2024-02-15 23:24:06.72+00	2024-02-15 23:24:06.72+00	Lubia Polo	94000	rT0UCBK1bE	\N	sonati	\N	\N
C7DcbS6tU4	2024-02-15 23:24:06.92+00	2024-02-15 23:24:06.92+00	Khoresht-e Gheimeh Sibzamini	730000	P9sBFomftT	\N	sonati	\N	\N
IWCKeTWd7T	2024-02-15 23:24:07.122+00	2024-02-15 23:24:07.122+00	Kalam Polo	304000	cFtamPA0zH	\N	irani	\N	\N
vGNA3BFPhW	2024-02-15 23:24:07.385+00	2024-02-15 23:24:07.385+00	Khoresh-e Nokhodchi	103000	na5crB8ED1	\N	irani	\N	\N
rFxIcfqwjy	2024-02-15 23:24:07.644+00	2024-02-15 23:24:07.644+00	Khagineh Kashan	52000	fxvABtKCPT	\N	irani	\N	\N
s0tQS2nN7u	2024-02-15 23:24:07.847+00	2024-02-15 23:24:07.847+00	Lubia Polo	127000	C7II8dYRPY	\N	sonati	\N	\N
7eaHCYXyxn	2024-02-15 23:24:08.051+00	2024-02-15 23:24:08.051+00	Khoresh-e Nokhodchi	898000	rT0UCBK1bE	\N	sonati	\N	\N
f8PlLMbvFu	2024-02-15 23:24:08.252+00	2024-02-15 23:24:08.252+00	Khoresht-e Torsh	25000	TZsdmscJ2B	\N	sonati	\N	\N
Cm0R5rbvd6	2024-02-15 23:24:08.458+00	2024-02-15 23:24:08.458+00	Khoresh-e Baamieh	248000	j0dWqP2C2A	\N	irani	\N	\N
C2ra8MJg6F	2024-02-15 23:24:08.771+00	2024-02-15 23:24:08.771+00	Halva Ardeh	23000	C7II8dYRPY	\N	sonati	\N	\N
3GkZJXJHPP	2024-02-15 23:24:08.978+00	2024-02-15 23:24:08.978+00	Adas Polo	518000	M0tHrt1GgV	\N	sonati	\N	\N
vzNgAo0kKD	2024-02-15 23:24:09.189+00	2024-02-15 23:24:09.189+00	Ash-e Miveh	226000	l1Bslv8T2k	\N	sonati	\N	\N
F88hl26gSQ	2024-02-15 23:24:09.397+00	2024-02-15 23:24:09.397+00	Baghali Polo ba Goosht	83000	89xRG1afNi	\N	sonati	\N	\N
jWAh4AVPD5	2024-02-15 23:24:09.605+00	2024-02-15 23:24:09.605+00	Dizi Sara	995000	jjVdtithcD	\N	sonati	\N	\N
AEfFMXocuQ	2024-02-15 23:24:09.811+00	2024-02-15 23:24:09.811+00	Nan-e Barbari	177000	8w7i8C3NnT	\N	irani	\N	\N
n3TifcBod2	2024-02-15 23:24:10.02+00	2024-02-15 23:24:10.02+00	Ash-e Miveh	883000	rKyjwoEIRp	\N	irani	\N	\N
EgNLJpCqmD	2024-02-15 23:24:10.224+00	2024-02-15 23:24:10.224+00	Shirin Polo	470000	3u4B9V4l5K	\N	irani	\N	\N
Ql0ZqSRKbj	2024-02-15 23:24:10.43+00	2024-02-15 23:24:10.43+00	Adas Polo	297000	qP3EdIVzfB	\N	irani	\N	\N
XGDOBK835G	2024-02-15 23:24:10.625+00	2024-02-15 23:24:10.625+00	Khoresht-e Bamieh	779000	08liHW08uC	\N	sonati	\N	\N
VZ070YqB60	2024-02-15 23:24:10.826+00	2024-02-15 23:24:10.826+00	Khoresh-e Anar	521000	rT0UCBK1bE	\N	sonati	\N	\N
oJMftkYAzz	2024-02-15 23:24:11.033+00	2024-02-15 23:24:11.033+00	Ash-e Miveh	528000	JLhF4VuByh	\N	irani	\N	\N
AsECGtjJph	2024-02-15 23:24:11.236+00	2024-02-15 23:24:11.236+00	Mirza Ghasemi	560000	fxvABtKCPT	\N	sonati	\N	\N
oMLOjHoV6p	2024-02-15 23:24:11.441+00	2024-02-15 23:24:11.441+00	Khagineh Birjand	909000	6Fo67rhTSP	\N	sonati	\N	\N
0JRWlLWW6O	2024-02-15 23:24:11.643+00	2024-02-15 23:24:11.643+00	Khoresht-e Gheimeh Sibzamini	943000	IEqTHcohpJ	\N	sonati	\N	\N
fNgc5zRsvQ	2024-02-15 23:24:11.843+00	2024-02-15 23:24:11.843+00	Sholeh Zard	57000	VK3vnSxIy8	\N	sonati	\N	\N
nW85l9MTmj	2024-02-15 23:24:12.044+00	2024-02-15 23:24:12.044+00	Khoresh-e Kardeh	275000	jjVdtithcD	\N	irani	\N	\N
nvbdIAdQtf	2024-02-15 23:24:12.247+00	2024-02-15 23:24:12.247+00	Khoresht-e Bamieh	740000	JRi61dUphq	\N	irani	\N	\N
OJ4qBaCB6F	2024-02-15 23:24:12.456+00	2024-02-15 23:24:12.456+00	Moraba-ye Anar Daneh	417000	cFtamPA0zH	\N	irani	\N	\N
PET8K6jIjn	2024-02-15 23:24:12.66+00	2024-02-15 23:24:12.66+00	Joojeh Kabab	289000	u5FXeeOChJ	\N	irani	\N	\N
zxZovkqHEL	2024-02-15 23:24:12.864+00	2024-02-15 23:24:12.864+00	Halva Ardeh	773000	jHqCpA1nWb	\N	irani	\N	\N
RbOoci2ZRF	2024-02-15 23:24:13.069+00	2024-02-15 23:24:13.069+00	Morasa Polo	589000	rT0UCBK1bE	\N	irani	\N	\N
7CQ4mH9Lh4	2024-02-15 23:24:13.274+00	2024-02-15 23:24:13.274+00	Tachin Morgh	73000	6Fo67rhTSP	\N	sonati	\N	\N
fLFOocSfBR	2024-02-15 23:24:13.481+00	2024-02-15 23:24:13.481+00	Moraba-ye Anar	589000	OQWu2bnHeC	\N	sonati	\N	\N
Bv8RsQUM2k	2024-02-15 23:24:13.686+00	2024-02-15 23:24:13.686+00	Khoresh-e Maast	432000	fwLPZZ8YQa	\N	sonati	\N	\N
E7vBkZyrdp	2024-02-15 23:24:13.897+00	2024-02-15 23:24:13.897+00	Yatimcheh	700000	3u4B9V4l5K	\N	sonati	\N	\N
15yoqAqsdr	2024-02-15 23:24:14.198+00	2024-02-15 23:24:14.198+00	Sabzi Polo	173000	AgU9OLJkqz	\N	irani	\N	\N
0P49PQVRk3	2024-02-15 23:24:14.408+00	2024-02-15 23:24:14.408+00	Ash-e Miveh	502000	AgU9OLJkqz	\N	irani	\N	\N
NqKQCgyWAN	2024-02-15 23:24:14.609+00	2024-02-15 23:24:14.609+00	Khoresh-e Gandom	225000	cmxBcanww9	\N	sonati	\N	\N
5LTXZGcUhw	2024-02-15 23:24:14.811+00	2024-02-15 23:24:14.811+00	Khoresh-e Haleem	499000	H40ivltLwZ	\N	irani	\N	\N
IuQLtoGC82	2024-02-15 23:24:15.017+00	2024-02-15 23:24:15.017+00	Kufteh Tabrizi	83000	WSTLlXDcKl	\N	irani	\N	\N
oFVMp8k43e	2024-02-15 23:24:15.227+00	2024-02-15 23:24:15.227+00	Khoresh-e Karafs	460000	D0A6GLdsDM	\N	irani	\N	\N
6ezamLisaB	2024-02-15 23:24:15.435+00	2024-02-15 23:24:15.435+00	Baghali Polo	718000	tCIEnLLcUc	\N	irani	\N	\N
B0O4EjF7y3	2024-02-15 23:24:15.63+00	2024-02-15 23:24:15.63+00	Dizi Tabrizi	956000	TCkiw6gTDz	\N	sonati	\N	\N
a8BIIJrFEm	2024-02-15 23:24:15.83+00	2024-02-15 23:24:15.83+00	Moraba-ye Anar	845000	XwszrNEEEj	\N	sonati	\N	\N
WLpBTIRLA7	2024-02-15 23:24:16.032+00	2024-02-15 23:24:16.032+00	Sirabi	431000	cmxBcanww9	\N	irani	\N	\N
OvSd404CPZ	2024-02-15 23:24:16.234+00	2024-02-15 23:24:16.234+00	Ash-e Anar	451000	E2hBZzDsjO	\N	sonati	\N	\N
UAXP64AmIO	2024-02-15 23:24:16.438+00	2024-02-15 23:24:16.438+00	Dizi Tabrizi	13000	TCkiw6gTDz	\N	sonati	\N	\N
RqyVXCYDBb	2024-02-15 23:24:16.644+00	2024-02-15 23:24:16.644+00	Kookoo Sabzi	164000	RBRcyltRSC	\N	sonati	\N	\N
KDCAaJ0ZP3	2024-02-15 23:24:16.847+00	2024-02-15 23:24:16.847+00	Adas Polo	678000	HXtEwLBC7f	\N	sonati	\N	\N
nI4JTwHEt8	2024-02-15 23:24:17.053+00	2024-02-15 23:24:17.053+00	Khoresh-e Beh	497000	OQWu2bnHeC	\N	irani	\N	\N
b6v4SpPWFc	2024-02-15 23:24:17.256+00	2024-02-15 23:24:17.256+00	Khoresh-e Anar	570000	8w7i8C3NnT	\N	sonati	\N	\N
yv0Aw7o3zO	2024-02-15 23:24:17.46+00	2024-02-15 23:24:17.46+00	Khagineh Yazdi	248000	KCsJ4XR6Dn	\N	irani	\N	\N
0t0fKjtzT3	2024-02-15 23:24:17.668+00	2024-02-15 23:24:17.668+00	Khoresh-e Chelo	517000	u5FXeeOChJ	\N	sonati	\N	\N
tNMyALCG9h	2024-02-15 23:24:17.874+00	2024-02-15 23:24:17.874+00	Khoresh-e Maast	139000	mMYg4cyd5R	\N	irani	\N	\N
XGdIHhewFp	2024-02-15 23:24:18.076+00	2024-02-15 23:24:18.076+00	Khoresh-e Haleem	711000	oABNR2FF6S	\N	irani	\N	\N
YVDUHJsfJu	2024-02-15 23:24:18.282+00	2024-02-15 23:24:18.282+00	Koloocheh	800000	RBRcyltRSC	\N	sonati	\N	\N
CTpossRq0m	2024-02-15 23:24:18.488+00	2024-02-15 23:24:18.488+00	Halva	22000	ThMuD3hYRQ	\N	sonati	\N	\N
FUEcuGte7X	2024-02-15 23:24:18.691+00	2024-02-15 23:24:18.691+00	Ash-e Mast	995000	WBFeKac0OO	\N	sonati	\N	\N
7X6BGHsHVN	2024-02-15 23:24:18.903+00	2024-02-15 23:24:18.903+00	Khagineh Gorgan	830000	JLhF4VuByh	\N	sonati	\N	\N
5ynExzlMgl	2024-02-15 23:24:19.113+00	2024-02-15 23:24:19.113+00	Adas Polo	802000	CSvk1ycWXk	\N	irani	\N	\N
VCb0Hpyvak	2024-02-15 23:24:19.319+00	2024-02-15 23:24:19.319+00	Joojeh Kabab	281000	LVYK4mLShP	\N	sonati	\N	\N
wptGBwAH1C	2024-02-15 23:24:19.523+00	2024-02-15 23:24:19.523+00	Moraba-ye Beh	673000	C7II8dYRPY	\N	sonati	\N	\N
bW5ZClkdJT	2024-02-15 23:24:19.729+00	2024-02-15 23:24:19.729+00	Sirabi	297000	8w7i8C3NnT	\N	irani	\N	\N
pdgW8BNAcI	2024-02-15 23:24:19.933+00	2024-02-15 23:24:19.933+00	Moraba-ye Anar Daneh	304000	m6g8u0QpTC	\N	sonati	\N	\N
IITUopN2M4	2024-02-15 23:24:20.137+00	2024-02-15 23:24:20.137+00	Kookoo Sibzamini	717000	bi1IivsuUB	\N	irani	\N	\N
9FFJFd4ZKJ	2024-02-15 23:24:20.341+00	2024-02-15 23:24:20.341+00	Khoresh-e Chelo	390000	cwVEh0dqfm	\N	sonati	\N	\N
yHwFrpzSKV	2024-02-15 23:24:20.541+00	2024-02-15 23:24:20.541+00	Khoresh-e Maast	328000	qZmnAnnPEb	\N	sonati	\N	\N
OIx7hSkz5B	2024-02-15 23:24:20.741+00	2024-02-15 23:24:20.741+00	Abgoosht	918000	WHvlAGgj6c	\N	sonati	\N	\N
JZnEBommMx	2024-02-15 23:24:20.951+00	2024-02-15 23:24:20.951+00	Khoresh-e Nokhodchi	756000	tCIEnLLcUc	\N	irani	\N	\N
kUIMoNsg4g	2024-02-15 23:24:21.145+00	2024-02-15 23:24:21.145+00	Aloo Mosamma	682000	INeptnSdJC	\N	irani	\N	\N
5MbOGBscZV	2024-02-15 23:24:21.347+00	2024-02-15 23:24:21.347+00	Bastani Sonnati	376000	8w7i8C3NnT	\N	sonati	\N	\N
e4sLKYdDcE	2024-02-15 23:24:21.555+00	2024-02-15 23:24:21.555+00	Ash-e Miveh	222000	yvUod6yLDt	\N	sonati	\N	\N
VoQz3fFISj	2024-02-15 23:24:21.762+00	2024-02-15 23:24:21.762+00	Shirin Adas	569000	KCsJ4XR6Dn	\N	sonati	\N	\N
yixOBgqVPE	2024-02-15 23:24:21.969+00	2024-02-15 23:24:21.969+00	Tahchin	298000	9GF3y7LmHV	\N	sonati	\N	\N
YKvqOqWP3Q	2024-02-15 23:24:22.179+00	2024-02-15 23:24:22.179+00	Mast-o-Khiar	731000	LgJuu5ABe5	\N	sonati	\N	\N
SCNVe3Zzrm	2024-02-15 23:24:22.383+00	2024-02-15 23:24:22.383+00	Kuku	61000	cmxBcanww9	\N	irani	\N	\N
bK1SC8LNLN	2024-02-15 23:24:22.596+00	2024-02-15 23:24:22.596+00	Kuku	282000	fwLPZZ8YQa	\N	irani	\N	\N
I7mmY3P5Zb	2024-02-15 23:24:22.801+00	2024-02-15 23:24:22.801+00	Baghali Polo	463000	fKTSJPdUi9	\N	sonati	\N	\N
PxH1KpGwR1	2024-02-15 23:24:23.002+00	2024-02-15 23:24:23.002+00	Dolma	305000	OQWu2bnHeC	\N	irani	\N	\N
576tdlB8hv	2024-02-15 23:24:23.209+00	2024-02-15 23:24:23.209+00	Moraba-ye Gerdoo	775000	TCkiw6gTDz	\N	sonati	\N	\N
ddUipyTSAU	2024-02-15 23:24:23.413+00	2024-02-15 23:24:23.413+00	Faloodeh	102000	oABNR2FF6S	\N	irani	\N	\N
qppzBpGr2K	2024-02-15 23:24:23.618+00	2024-02-15 23:24:23.618+00	Yatimcheh	84000	RkhjIQJgou	\N	sonati	\N	\N
EjF4qFQlwz	2024-02-15 23:24:23.823+00	2024-02-15 23:24:23.823+00	Khoresh-e Maast	214000	E2hBZzDsjO	\N	irani	\N	\N
RGKvgugBXa	2024-02-15 23:24:24.137+00	2024-02-15 23:24:24.137+00	Kalam Polo	110000	VK3vnSxIy8	\N	sonati	\N	\N
4HPA24AeA1	2024-02-15 23:24:24.343+00	2024-02-15 23:24:24.343+00	Aloo Mosamma	457000	6Fo67rhTSP	\N	sonati	\N	\N
KPAUd1tCEi	2024-02-15 23:24:24.558+00	2024-02-15 23:24:24.558+00	Yatimcheh	385000	rT0UCBK1bE	\N	sonati	\N	\N
SCSF15Ag2T	2024-02-15 23:24:24.768+00	2024-02-15 23:24:24.768+00	Khagineh Yazdi	732000	vwHi602n66	\N	irani	\N	\N
9jFL7qEdXf	2024-02-15 23:24:24.973+00	2024-02-15 23:24:24.973+00	Khoresh-e Mast	232000	TCkiw6gTDz	\N	sonati	\N	\N
ducoskmQyw	2024-02-15 23:24:25.179+00	2024-02-15 23:24:25.179+00	Torshe Tareh	320000	cFtamPA0zH	\N	sonati	\N	\N
PJ3BphCo0D	2024-02-15 23:24:25.384+00	2024-02-15 23:24:25.384+00	Ash-e Miveh	918000	WSTLlXDcKl	\N	sonati	\N	\N
MwPOStWKsK	2024-02-15 23:24:25.581+00	2024-02-15 23:24:25.581+00	Shirin Laboo	616000	OQWu2bnHeC	\N	irani	\N	\N
pI3hjUwPBR	2024-02-15 23:24:25.78+00	2024-02-15 23:24:25.78+00	Halva Ardeh	557000	AgU9OLJkqz	\N	irani	\N	\N
MVucfaGMZj	2024-02-15 23:24:25.985+00	2024-02-15 23:24:25.985+00	Aloo Mosamma	938000	LDrIH1vU8x	\N	irani	\N	\N
skVVFH6Ojz	2024-02-15 23:24:26.186+00	2024-02-15 23:24:26.186+00	Dizi Tabrizi	742000	TCkiw6gTDz	\N	sonati	\N	\N
ED4gCslRE6	2024-02-15 23:24:26.385+00	2024-02-15 23:24:26.385+00	Mast-o-Khiar	856000	ThMuD3hYRQ	\N	irani	\N	\N
Pu70oGHo5r	2024-02-15 23:24:26.587+00	2024-02-15 23:24:26.587+00	Baghali Polo ba Morgh	662000	NY6RE1qgWu	\N	sonati	\N	\N
7W1tvTAj4q	2024-02-15 23:24:26.788+00	2024-02-15 23:24:26.788+00	Moraba-ye Anar Daneh	33000	TCkiw6gTDz	\N	sonati	\N	\N
rlI35q0ZKt	2024-02-15 23:24:26.998+00	2024-02-15 23:24:26.998+00	Kufteh Tabrizi	131000	RBRcyltRSC	\N	sonati	\N	\N
7DuFObtriU	2024-02-15 23:24:27.198+00	2024-02-15 23:24:27.198+00	Khoresht-e Alu Esfenaj	806000	LgJuu5ABe5	\N	sonati	\N	\N
eP0P6wMMes	2024-02-15 23:24:27.394+00	2024-02-15 23:24:27.394+00	Gheimeh	299000	0TvWuLoLF5	\N	irani	\N	\N
RR4WzZnU2H	2024-02-15 23:24:27.604+00	2024-02-15 23:24:27.604+00	Shirin Polo	894000	lxQA9rtSfY	\N	irani	\N	\N
tIWIr1ujAy	2024-02-15 23:24:27.809+00	2024-02-15 23:24:27.809+00	Ashe Reshteh	494000	TZsdmscJ2B	\N	sonati	\N	\N
oEEVmhmQit	2024-02-15 23:24:28.016+00	2024-02-15 23:24:28.016+00	Khoresh-e Anar	48000	HXtEwLBC7f	\N	irani	\N	\N
pRY8kZtX0h	2024-02-15 23:24:28.221+00	2024-02-15 23:24:28.221+00	Khoresh-e Loobia Sabz	409000	bi1IivsuUB	\N	sonati	\N	\N
TZUvPXQ820	2024-02-15 23:24:28.42+00	2024-02-15 23:24:28.42+00	Koloocheh	913000	jjVdtithcD	\N	sonati	\N	\N
6chNZU7XiR	2024-02-15 23:24:28.626+00	2024-02-15 23:24:28.626+00	Gondi	964000	0TvWuLoLF5	\N	irani	\N	\N
CzS9A405uQ	2024-02-15 23:24:28.827+00	2024-02-15 23:24:28.827+00	Nan-e Barbari	864000	WBFeKac0OO	\N	irani	\N	\N
ir97iVYlKT	2024-02-15 23:24:29.031+00	2024-02-15 23:24:29.031+00	Shirin Polo	611000	e037qpAih3	\N	sonati	\N	\N
BGbWNxheCE	2024-02-15 23:24:29.242+00	2024-02-15 23:24:29.242+00	Khoresh-e Gerdoo	377000	vwHi602n66	\N	sonati	\N	\N
wHhYA8b1mC	2024-02-15 23:24:29.458+00	2024-02-15 23:24:29.458+00	Sholeh Zard	64000	mMYg4cyd5R	\N	irani	\N	\N
rvJj5s02pR	2024-02-15 23:24:29.666+00	2024-02-15 23:24:29.666+00	Morasa Polo	415000	na5crB8ED1	\N	irani	\N	\N
zh7cGueoey	2024-02-15 23:24:29.869+00	2024-02-15 23:24:29.869+00	Moraba-ye Anar	989000	fKTSJPdUi9	\N	sonati	\N	\N
ljLevNyoCB	2024-02-15 23:24:30.071+00	2024-02-15 23:24:30.071+00	Khoresht-e Karafs	316000	3P6kmNoY1F	\N	sonati	\N	\N
TRf7WdWaGV	2024-02-15 23:24:30.29+00	2024-02-15 23:24:30.29+00	Sirabi	288000	bQpy9LEJWn	\N	sonati	\N	\N
Kf3ZgjFezx	2024-02-15 23:24:30.489+00	2024-02-15 23:24:30.489+00	Halva Shekari	153000	MQfxuw3ERg	\N	sonati	\N	\N
BaLA5JIrpR	2024-02-15 23:24:30.684+00	2024-02-15 23:24:30.684+00	Shami Kabab	722000	CSvk1ycWXk	\N	irani	\N	\N
UZSDNI2JS0	2024-02-15 23:24:30.88+00	2024-02-15 23:24:30.88+00	Kabab Koobideh	298000	PF8w2gMAdi	\N	irani	\N	\N
cYyBLodnHh	2024-02-15 23:24:31.086+00	2024-02-15 23:24:31.086+00	Khoresht-e Gheymeh	551000	axyV0Fu7pm	\N	sonati	\N	\N
3NZTvCmciS	2024-02-15 23:24:31.292+00	2024-02-15 23:24:31.292+00	Khoresh-e Morgh Ba Zireh	240000	BMLzFMvIT6	\N	sonati	\N	\N
7oJRjC5O6T	2024-02-15 23:24:31.514+00	2024-02-15 23:24:31.514+00	Shami Kabab	218000	rT0UCBK1bE	\N	sonati	\N	\N
mAvjhrqQYG	2024-02-15 23:24:31.718+00	2024-02-15 23:24:31.718+00	Khagineh Kashan	719000	OQWu2bnHeC	\N	irani	\N	\N
mZXNE1dlgD	2024-02-15 23:24:31.914+00	2024-02-15 23:24:31.914+00	Shirin Adas	19000	89xRG1afNi	\N	sonati	\N	\N
35gve9HA6w	2024-02-15 23:24:32.117+00	2024-02-15 23:24:32.117+00	Dolma	325000	cmxBcanww9	\N	irani	\N	\N
A63AEIaYRI	2024-02-15 23:24:32.322+00	2024-02-15 23:24:32.322+00	Khoresh-e Sabzi	858000	bQpy9LEJWn	\N	irani	\N	\N
wDKKRezt7v	2024-02-15 23:24:32.521+00	2024-02-15 23:24:32.521+00	Khoresh-e Karafs	705000	C7II8dYRPY	\N	irani	\N	\N
OtoE3zUWF6	2024-02-15 23:24:32.722+00	2024-02-15 23:24:32.722+00	Kufteh Tabrizi	601000	LDrIH1vU8x	\N	irani	\N	\N
0yDt1OBSMR	2024-02-15 23:24:32.922+00	2024-02-15 23:24:32.922+00	Tachin Morgh	267000	IybX0eBoO3	\N	irani	\N	\N
wNt6JqIXEq	2024-02-15 23:24:33.13+00	2024-02-15 23:24:33.13+00	Khoresh-e Sabzi	316000	IybX0eBoO3	\N	sonati	\N	\N
QDCdJYTYNf	2024-02-15 23:24:33.335+00	2024-02-15 23:24:33.335+00	Dizi Tabrizi	250000	e037qpAih3	\N	sonati	\N	\N
zivWfCLPtG	2024-02-15 23:24:33.543+00	2024-02-15 23:24:33.543+00	Tahchin	116000	qZmnAnnPEb	\N	irani	\N	\N
4AJO0kPF04	2024-02-15 23:24:33.754+00	2024-02-15 23:24:33.754+00	Khagineh Gorgan	891000	P9sBFomftT	\N	irani	\N	\N
Sx4tGdYjDj	2024-02-15 23:24:33.964+00	2024-02-15 23:24:33.964+00	Gheimeh	826000	WSTLlXDcKl	\N	sonati	\N	\N
AhFvxZzFeI	2024-02-15 23:24:34.174+00	2024-02-15 23:24:34.174+00	Ash-e Mast	822000	WHvlAGgj6c	\N	sonati	\N	\N
Ss0Wpurqqk	2024-02-15 23:24:34.381+00	2024-02-15 23:24:34.381+00	Khoresht-e Bamieh	465000	e037qpAih3	\N	irani	\N	\N
0rxvpJtCHi	2024-02-15 23:24:34.577+00	2024-02-15 23:24:34.577+00	Khoresh-e Mast	565000	6KvFK8yy1q	\N	sonati	\N	\N
a65MSYMQSK	2024-02-15 23:24:34.777+00	2024-02-15 23:24:34.777+00	Lubia Polo	362000	LVYK4mLShP	\N	irani	\N	\N
7mnfqZEeW7	2024-02-15 23:24:34.986+00	2024-02-15 23:24:34.986+00	Haleem	523000	tCIEnLLcUc	\N	sonati	\N	\N
mBWlCZb1fD	2024-02-15 23:24:35.191+00	2024-02-15 23:24:35.191+00	Moraba-ye Anar	844000	jjVdtithcD	\N	sonati	\N	\N
Ps5BqrZ1hH	2024-02-15 23:24:35.393+00	2024-02-15 23:24:35.393+00	Baghali Polo ba Goosht	486000	j0dWqP2C2A	\N	irani	\N	\N
qqDQ8u62eh	2024-02-15 23:24:35.7+00	2024-02-15 23:24:35.7+00	Kookoo Sibzamini	547000	08liHW08uC	\N	sonati	\N	\N
jHTCUF2ZRe	2024-02-15 23:24:35.902+00	2024-02-15 23:24:35.902+00	Khoresht-e Gheymeh	931000	uABtFsJhJc	\N	sonati	\N	\N
KUoAL7YN2D	2024-02-15 23:24:36.112+00	2024-02-15 23:24:36.112+00	Ash-e Miveh	70000	C7II8dYRPY	\N	irani	\N	\N
YI3RBQ4g5b	2024-02-15 23:24:36.316+00	2024-02-15 23:24:36.316+00	Khoresh-e Beh	853000	JZOBDAh12a	\N	irani	\N	\N
ZqwBO6KLlL	2024-02-15 23:24:36.522+00	2024-02-15 23:24:36.522+00	Moraba-ye Gerdoo	962000	cmxBcanww9	\N	sonati	\N	\N
dNg7Xo2coM	2024-02-15 23:24:36.739+00	2024-02-15 23:24:36.739+00	Kalam Polo Mahicheh	72000	6KvFK8yy1q	\N	irani	\N	\N
tTbJTVJ8Tn	2024-02-15 23:24:36.942+00	2024-02-15 23:24:36.942+00	Khoresh-e Beh	646000	na5crB8ED1	\N	sonati	\N	\N
n181qjiXhS	2024-02-15 23:24:37.142+00	2024-02-15 23:24:37.142+00	Abgoosht	84000	0TvWuLoLF5	\N	irani	\N	\N
M3VOgTcey7	2024-02-15 23:24:37.335+00	2024-02-15 23:24:37.335+00	Khoresht-e Gheimeh Sibzamini	470000	WBFeKac0OO	\N	sonati	\N	\N
lpvJDVJ6ZW	2024-02-15 23:24:37.536+00	2024-02-15 23:24:37.536+00	Dizi Sara	173000	XpUyRlB6FI	\N	sonati	\N	\N
Km3DRX0IGJ	2024-02-15 23:24:37.739+00	2024-02-15 23:24:37.739+00	Khoresh-e Sabzi	358000	XwWwGnkXNj	\N	sonati	\N	\N
SEu6yN9uF9	2024-02-15 23:24:37.94+00	2024-02-15 23:24:37.94+00	Torshe Tareh	813000	Gl96vGdYHM	\N	irani	\N	\N
qukVT5WMVm	2024-02-15 23:24:38.147+00	2024-02-15 23:24:38.147+00	Khoresht-e Bamieh	58000	AgU9OLJkqz	\N	sonati	\N	\N
nYT7rLozy4	2024-02-15 23:24:38.352+00	2024-02-15 23:24:38.352+00	Khoresh-e Beh	648000	NY6RE1qgWu	\N	sonati	\N	\N
3f26b2Gma0	2024-02-15 23:24:38.556+00	2024-02-15 23:24:38.556+00	Moraba-ye Anar	711000	HXtEwLBC7f	\N	irani	\N	\N
7xekcnCB10	2024-02-15 23:24:38.757+00	2024-02-15 23:24:38.757+00	Zereshk Polo	460000	UDXF0qXvDY	\N	sonati	\N	\N
PBpZdobdW4	2024-02-15 23:24:38.957+00	2024-02-15 23:24:38.957+00	Tahchin	673000	cmxBcanww9	\N	irani	\N	\N
kC0Qnuxk8T	2024-02-15 23:24:39.157+00	2024-02-15 23:24:39.157+00	Baghali Ghatogh	304000	o90lhsZ7FK	\N	sonati	\N	\N
DAyq27YnVL	2024-02-15 23:24:39.359+00	2024-02-15 23:24:39.359+00	Samanu	755000	LVYK4mLShP	\N	sonati	\N	\N
Bv9V9JdLg8	2024-02-15 23:24:39.558+00	2024-02-15 23:24:39.558+00	Khoresh-e Baamieh	680000	6Fo67rhTSP	\N	irani	\N	\N
gEHv11NQuP	2024-02-15 23:24:39.76+00	2024-02-15 23:24:39.76+00	Khoresht-e Gheymeh	809000	XpUyRlB6FI	\N	irani	\N	\N
YZAOGyLv7d	2024-02-15 23:24:39.957+00	2024-02-15 23:24:39.957+00	Nan-e Barbari	212000	IEqTHcohpJ	\N	sonati	\N	\N
D9hvUlmTmh	2024-02-15 23:24:40.152+00	2024-02-15 23:24:40.152+00	Bastani Akbar Mashti	105000	3u4B9V4l5K	\N	sonati	\N	\N
5stukLCfIC	2024-02-15 23:24:40.351+00	2024-02-15 23:24:40.351+00	Kufteh Tabrizi	872000	BMLzFMvIT6	\N	irani	\N	\N
Rl8ok21NAW	2024-02-15 23:24:40.545+00	2024-02-15 23:24:40.545+00	Khoresh-e Gerdoo	636000	HLIPwAqO2R	\N	sonati	\N	\N
okTfBNLbBQ	2024-02-15 23:24:40.741+00	2024-02-15 23:24:40.741+00	Khoresh-e Havij ba Morgh	945000	XSK814B37m	\N	irani	\N	\N
2wFScaQsrX	2024-02-15 23:24:40.937+00	2024-02-15 23:24:40.937+00	Khoresht-e Bamieh	82000	u5FXeeOChJ	\N	irani	\N	\N
XLxpRJgYKZ	2024-02-15 23:24:41.135+00	2024-02-15 23:24:41.135+00	Khoresh-e Gandom	464000	WHvlAGgj6c	\N	irani	\N	\N
TVPeFWSseP	2024-02-15 23:24:41.335+00	2024-02-15 23:24:41.335+00	Sheer Khurma	632000	y4RkaDbkec	\N	irani	\N	\N
3yDROMhnnR	2024-02-15 23:24:41.537+00	2024-02-15 23:24:41.537+00	Baghali Polo	897000	WHvlAGgj6c	\N	sonati	\N	\N
a2RoSnz59K	2024-02-15 23:24:41.733+00	2024-02-15 23:24:41.733+00	Dizi Sara	426000	axyV0Fu7pm	\N	irani	\N	\N
DWEHnJqKsC	2024-02-15 23:24:41.929+00	2024-02-15 23:24:41.929+00	Moraba-ye Anar Daneh	563000	cmxBcanww9	\N	sonati	\N	\N
BT95q9pQxc	2024-02-15 23:24:42.129+00	2024-02-15 23:24:42.129+00	Khoresh-e Mast	311000	oABNR2FF6S	\N	sonati	\N	\N
dI3XQM4jaT	2024-02-15 23:24:42.326+00	2024-02-15 23:24:42.326+00	Koloocheh	433000	bQ0JOk10eL	\N	irani	\N	\N
W62EpH77CQ	2024-02-15 23:24:42.524+00	2024-02-15 23:24:42.524+00	Khoresh-e Beh	903000	l1Bslv8T2k	\N	sonati	\N	\N
7FZR9ipmW7	2024-02-15 23:24:42.722+00	2024-02-15 23:24:42.722+00	Khagineh Gorgan	373000	P9sBFomftT	\N	sonati	\N	\N
jaq9lQ2U99	2024-02-15 23:24:42.92+00	2024-02-15 23:24:42.92+00	Moraba-ye Anar	580000	INeptnSdJC	\N	sonati	\N	\N
5jvONHLRUI	2024-02-15 23:24:43.117+00	2024-02-15 23:24:43.117+00	Khoresh-e Beh	347000	XpUyRlB6FI	\N	irani	\N	\N
idIJCYGfC2	2024-02-15 23:24:43.314+00	2024-02-15 23:24:43.314+00	Dolma	286000	BMLzFMvIT6	\N	sonati	\N	\N
3QFz00dJvs	2024-02-15 23:24:43.584+00	2024-02-15 23:24:43.584+00	Naz Khatoon	829000	D0A6GLdsDM	\N	irani	\N	\N
nsKyXAgUpa	2024-02-15 23:24:43.782+00	2024-02-15 23:24:43.782+00	Khoresh-e Anar	983000	AgU9OLJkqz	\N	sonati	\N	\N
RpEjQCvV37	2024-02-15 23:24:43.98+00	2024-02-15 23:24:43.98+00	Kookoo Sibzamini	226000	yvUod6yLDt	\N	sonati	\N	\N
KCc3uRVIvY	2024-02-15 23:24:44.302+00	2024-02-15 23:24:44.302+00	Aloo Mosamma	775000	JLhF4VuByh	\N	sonati	\N	\N
Kb1PWBzDR2	2024-02-15 23:24:44.499+00	2024-02-15 23:24:44.499+00	Baghali Polo	818000	KCsJ4XR6Dn	\N	sonati	\N	\N
81KE937Dpx	2024-02-15 23:24:44.699+00	2024-02-15 23:24:44.699+00	Sabzi Polo	778000	qZmnAnnPEb	\N	irani	\N	\N
Lyw2Je8JBK	2024-02-15 23:24:44.896+00	2024-02-15 23:24:44.896+00	Baghali Polo ba Goosht	404000	6KvFK8yy1q	\N	irani	\N	\N
bEDHpbP8E9	2024-02-15 23:24:45.099+00	2024-02-15 23:24:45.099+00	Khoresht-e Torsh	728000	HXtEwLBC7f	\N	sonati	\N	\N
xCrWFPWoKe	2024-02-15 23:24:45.293+00	2024-02-15 23:24:45.293+00	Nan-e Barbari	201000	Pja6n3yaWZ	\N	irani	\N	\N
DUgqL7fAxV	2024-02-15 23:24:45.488+00	2024-02-15 23:24:45.488+00	Khoresh-e Chelo	542000	bQpy9LEJWn	\N	irani	\N	\N
IXfhHzmgoh	2024-02-15 23:24:45.683+00	2024-02-15 23:24:45.683+00	Samanu	448000	qEQ9tmLyW9	\N	sonati	\N	\N
2eYqnDiZd1	2024-02-15 23:24:45.879+00	2024-02-15 23:24:45.879+00	Khoresh-e Sabzi	253000	y4RkaDbkec	\N	sonati	\N	\N
HOSxcsffkc	2024-02-15 23:24:46.077+00	2024-02-15 23:24:46.077+00	Yatimcheh	133000	XSK814B37m	\N	irani	\N	\N
hfIRoHKgOb	2024-02-15 23:24:46.276+00	2024-02-15 23:24:46.276+00	Kalam Polo	915000	UCFo58JaaD	\N	irani	\N	\N
GxzOWJMG5W	2024-02-15 23:24:46.471+00	2024-02-15 23:24:46.471+00	Faloodeh	438000	uigc7bJBOJ	\N	irani	\N	\N
Pf1BkDayU4	2024-02-15 23:24:46.667+00	2024-02-15 23:24:46.667+00	Khoresh-e Nokhodchi	296000	PF8w2gMAdi	\N	irani	\N	\N
SD66V1VghI	2024-02-15 23:24:46.864+00	2024-02-15 23:24:46.864+00	Yatimcheh	671000	m8hjjLVdPS	\N	sonati	\N	\N
vOxbYHqtov	2024-02-15 23:24:47.063+00	2024-02-15 23:24:47.063+00	Khoresh-e Karafs-e Holu	496000	bQ0JOk10eL	\N	sonati	\N	\N
JoO1EyMtxX	2024-02-15 23:24:47.261+00	2024-02-15 23:24:47.261+00	Fesenjan	284000	fKTSJPdUi9	\N	sonati	\N	\N
HINX6AHgDs	2024-02-15 23:24:47.577+00	2024-02-15 23:24:47.577+00	Khoresht-e Bamieh	68000	o90lhsZ7FK	\N	irani	\N	\N
wmzIFZicpg	2024-02-15 23:24:47.771+00	2024-02-15 23:24:47.771+00	Yatimcheh	985000	HSEugQ3Ouj	\N	sonati	\N	\N
A3U10OuHkf	2024-02-15 23:24:47.967+00	2024-02-15 23:24:47.967+00	Ash-e Mast	23000	lEPdiO1EDi	\N	sonati	\N	\N
hXzTFmioUG	2024-02-15 23:24:48.164+00	2024-02-15 23:24:48.164+00	Lubia Polo	728000	RBRcyltRSC	\N	sonati	\N	\N
l121swa4vv	2024-02-15 23:24:48.362+00	2024-02-15 23:24:48.362+00	Salad Shirazi	997000	uABtFsJhJc	\N	sonati	\N	\N
Svp2uWn5Mj	2024-02-15 23:24:48.561+00	2024-02-15 23:24:48.561+00	Baghali Ghatogh	309000	Oahm9sOn1y	\N	irani	\N	\N
qCLCbA7bVV	2024-02-15 23:24:48.759+00	2024-02-15 23:24:48.759+00	Kuku	292000	IEqTHcohpJ	\N	sonati	\N	\N
EWmZAcxYow	2024-02-15 23:24:48.955+00	2024-02-15 23:24:48.955+00	Khoresh-e Fesenjan	152000	y4RkaDbkec	\N	irani	\N	\N
Tdc3pUsqnU	2024-02-15 23:24:49.148+00	2024-02-15 23:24:49.148+00	Shirin Laboo	681000	TCkiw6gTDz	\N	irani	\N	\N
RVUSbGxVAa	2024-02-15 23:24:49.346+00	2024-02-15 23:24:49.346+00	Khoresh-e Mast	260000	RkhjIQJgou	\N	irani	\N	\N
er6RCwlonf	2024-02-15 23:24:49.542+00	2024-02-15 23:24:49.542+00	Khagineh Yazdi	260000	LgJuu5ABe5	\N	sonati	\N	\N
JoZQvjomiU	2024-02-15 23:24:49.737+00	2024-02-15 23:24:49.737+00	Khoresh-e Chelo	272000	XwszrNEEEj	\N	sonati	\N	\N
8zpwGBIM0G	2024-02-15 23:24:49.936+00	2024-02-15 23:24:49.936+00	Sabzi Polo	181000	JLhF4VuByh	\N	irani	\N	\N
hGfx7gL7ac	2024-02-15 23:24:50.134+00	2024-02-15 23:24:50.134+00	Ghormeh Sabzi	232000	PF8w2gMAdi	\N	sonati	\N	\N
8DTIGaeTqp	2024-02-15 23:24:50.333+00	2024-02-15 23:24:50.333+00	Fesenjan	539000	Oahm9sOn1y	\N	irani	\N	\N
4P9uqOB2RR	2024-02-15 23:24:50.53+00	2024-02-15 23:24:50.53+00	Khagineh	846000	ThMuD3hYRQ	\N	irani	\N	\N
TfIdREKKnY	2024-02-15 23:24:50.73+00	2024-02-15 23:24:50.73+00	Khoresh-e Karafs-e Holu	34000	3u4B9V4l5K	\N	irani	\N	\N
pkaDbVa8UY	2024-02-15 23:24:50.93+00	2024-02-15 23:24:50.93+00	Kuku	788000	FYXEfIO1zF	\N	sonati	\N	\N
WXVMxIn4ci	2024-02-15 23:24:51.129+00	2024-02-15 23:24:51.129+00	Shami Kabab	618000	lxQA9rtSfY	\N	sonati	\N	\N
yRFyNLP36u	2024-02-15 23:24:51.328+00	2024-02-15 23:24:51.328+00	Salad Shirazi	799000	bQpy9LEJWn	\N	irani	\N	\N
GBBqMZ0nvK	2024-02-15 23:24:51.535+00	2024-02-15 23:24:51.535+00	Khoresht-e Gheimeh Sibzamini	80000	qP3EdIVzfB	\N	sonati	\N	\N
QFXGamW9OK	2024-02-15 23:24:51.732+00	2024-02-15 23:24:51.732+00	Shami Kabab	157000	WHvlAGgj6c	\N	irani	\N	\N
KYuArGnEOY	2024-02-15 23:24:51.935+00	2024-02-15 23:24:51.935+00	Adas Polo	389000	WHvlAGgj6c	\N	irani	\N	\N
n0u3GKphk0	2024-02-15 23:24:52.137+00	2024-02-15 23:24:52.137+00	Khoresht-e Alu Esfenaj	879000	M0tHrt1GgV	\N	sonati	\N	\N
JaubcbzUEJ	2024-02-15 23:24:52.343+00	2024-02-15 23:24:52.343+00	Ash-e Mast	867000	6KvFK8yy1q	\N	sonati	\N	\N
1jW1pmwxVc	2024-02-15 23:24:52.548+00	2024-02-15 23:24:52.548+00	Khoresh-e Morgh Ba Zireh	255000	Pja6n3yaWZ	\N	sonati	\N	\N
4ElinL3kSN	2024-02-15 23:24:52.748+00	2024-02-15 23:24:52.748+00	Khoresh-e Karafs-e Holu	392000	cwVEh0dqfm	\N	sonati	\N	\N
bzcQdUAZ9z	2024-02-15 23:24:52.943+00	2024-02-15 23:24:52.943+00	Koloocheh	511000	PF8w2gMAdi	\N	sonati	\N	\N
wCahORqVSj	2024-02-15 23:24:53.143+00	2024-02-15 23:24:53.143+00	Khoresh-e Kardeh	625000	e037qpAih3	\N	irani	\N	\N
86WJ4jdbM1	2024-02-15 23:24:53.347+00	2024-02-15 23:24:53.347+00	Khagineh Yazdi	394000	jHqCpA1nWb	\N	sonati	\N	\N
8ml2vyRKj5	2024-02-15 23:24:53.546+00	2024-02-15 23:24:53.546+00	Khoresh-e Karafs	949000	0TvWuLoLF5	\N	irani	\N	\N
rpzv6er2W6	2024-02-15 23:24:53.741+00	2024-02-15 23:24:53.741+00	Bastani Sonnati	167000	qEQ9tmLyW9	\N	irani	\N	\N
zSYn0D1pPJ	2024-02-15 23:24:53.939+00	2024-02-15 23:24:53.939+00	Moraba-ye Anar	507000	D0A6GLdsDM	\N	sonati	\N	\N
HkQ87AAsC1	2024-02-15 23:24:54.135+00	2024-02-15 23:24:54.135+00	Khoresh-e Sabzi	691000	NY6RE1qgWu	\N	irani	\N	\N
nTCW0tVieK	2024-02-15 23:24:54.334+00	2024-02-15 23:24:54.334+00	Ash-e Doogh	489000	NBojpORh3G	\N	sonati	\N	\N
j2ggQTs3OA	2024-02-15 23:24:54.532+00	2024-02-15 23:24:54.532+00	Kabab Koobideh	548000	m6g8u0QpTC	\N	irani	\N	\N
PLSgZQdEyX	2024-02-15 23:24:54.731+00	2024-02-15 23:24:54.731+00	Zereshk Polo	607000	uABtFsJhJc	\N	irani	\N	\N
mT1WnyrY6D	2024-02-15 23:24:54.933+00	2024-02-15 23:24:54.933+00	Mirza Ghasemi	95000	u5FXeeOChJ	\N	sonati	\N	\N
EjalXp2wJ7	2024-02-15 23:24:55.133+00	2024-02-15 23:24:55.133+00	Khoresh-e Kardeh	437000	cFtamPA0zH	\N	sonati	\N	\N
asGmTIui15	2024-02-15 23:24:55.326+00	2024-02-15 23:24:55.326+00	Morasa Polo	185000	ThMuD3hYRQ	\N	irani	\N	\N
4oKaT1UAYf	2024-02-15 23:24:55.519+00	2024-02-15 23:24:55.519+00	Torshe Tareh	560000	HLIPwAqO2R	\N	sonati	\N	\N
GuHPsxthyV	2024-02-15 23:24:55.718+00	2024-02-15 23:24:55.718+00	Moraba-ye Gerdoo	80000	IybX0eBoO3	\N	sonati	\N	\N
X6H5VKZMH1	2024-02-15 23:24:55.917+00	2024-02-15 23:24:55.917+00	Khoresh-e Sabzi	905000	oABNR2FF6S	\N	irani	\N	\N
K4FlgOBJhg	2024-02-15 23:24:56.111+00	2024-02-15 23:24:56.111+00	Ash-e Mast	520000	bQ0JOk10eL	\N	irani	\N	\N
DpLrgM7yRK	2024-02-15 23:24:56.306+00	2024-02-15 23:24:56.306+00	Shirin Yazdi	915000	C7II8dYRPY	\N	irani	\N	\N
lJVUpu0nzH	2024-02-15 23:24:56.506+00	2024-02-15 23:24:56.506+00	Kuku	736000	RkhjIQJgou	\N	irani	\N	\N
d4C3fwakgG	2024-02-15 23:24:56.706+00	2024-02-15 23:24:56.706+00	Joojeh Kabab	633000	HLIPwAqO2R	\N	sonati	\N	\N
FigPUdKhr2	2024-02-15 23:24:56.904+00	2024-02-15 23:24:56.904+00	Khoresh-e Morgh Ba Zireh	537000	u5FXeeOChJ	\N	sonati	\N	\N
dqnJAJW1d2	2024-02-15 23:24:57.116+00	2024-02-15 23:24:57.116+00	Ash-e Mast	785000	14jGmOAXcg	\N	irani	\N	\N
rHF6JICfk1	2024-02-15 23:24:57.32+00	2024-02-15 23:24:57.32+00	Khagineh Yazdi	569000	WSTLlXDcKl	\N	irani	\N	\N
T9jPJjhBs6	2024-02-15 23:24:57.519+00	2024-02-15 23:24:57.519+00	Sirabi	857000	fwLPZZ8YQa	\N	sonati	\N	\N
1sCu5CxwBs	2024-02-15 23:24:57.716+00	2024-02-15 23:24:57.716+00	Ashe Reshteh	408000	l1Bslv8T2k	\N	irani	\N	\N
1s8CKbYBL6	2024-02-15 23:24:57.913+00	2024-02-15 23:24:57.913+00	Khoresh-e Havij ba Morgh	969000	m8hjjLVdPS	\N	sonati	\N	\N
3v1YgOmFgo	2024-02-15 23:24:58.111+00	2024-02-15 23:24:58.111+00	Kalam Polo Mahicheh	142000	PF8w2gMAdi	\N	irani	\N	\N
PJOAAf3r52	2024-02-15 23:24:58.311+00	2024-02-15 23:24:58.311+00	Mirza Ghasemi	32000	Pa0qBO2rzK	\N	sonati	\N	\N
cBktTCkxC2	2024-02-15 23:24:58.508+00	2024-02-15 23:24:58.508+00	Ash-e Anar	603000	LgJuu5ABe5	\N	sonati	\N	\N
i1sVgxZi0D	2024-02-15 23:24:58.704+00	2024-02-15 23:24:58.704+00	Ash-e Anar	767000	08liHW08uC	\N	sonati	\N	\N
dF6fVAOMGM	2024-02-15 23:24:58.902+00	2024-02-15 23:24:58.902+00	Khagineh Kashan	329000	HLIPwAqO2R	\N	irani	\N	\N
uf3YN3oieT	2024-02-15 23:24:59.104+00	2024-02-15 23:24:59.104+00	Khoresht-e Torsh	584000	INeptnSdJC	\N	sonati	\N	\N
5dGqRtwPq3	2024-02-15 23:24:59.301+00	2024-02-15 23:24:59.301+00	Tahchin	397000	uABtFsJhJc	\N	sonati	\N	\N
9DXQubvSEI	2024-02-15 23:24:59.499+00	2024-02-15 23:24:59.499+00	Khoresh-e Mast	274000	FJOTueDfs2	\N	irani	\N	\N
Lk0S2Hb2aT	2024-02-15 23:24:59.699+00	2024-02-15 23:24:59.699+00	Kufteh Tabrizi	373000	TCkiw6gTDz	\N	irani	\N	\N
LGBsgr8kOv	2024-02-15 23:24:59.898+00	2024-02-15 23:24:59.898+00	Khoresh-e Beh	314000	lxQA9rtSfY	\N	sonati	\N	\N
5rgMsmFJZA	2024-02-15 23:25:00.101+00	2024-02-15 23:25:00.101+00	Khoresh-e Fesenjan	971000	JRi61dUphq	\N	sonati	\N	\N
Gtwl69vXga	2024-02-15 23:25:00.299+00	2024-02-15 23:25:00.299+00	Salad Shirazi	828000	fxvABtKCPT	\N	sonati	\N	\N
1PaJhFox3f	2024-02-15 23:25:00.498+00	2024-02-15 23:25:00.498+00	Zereshk Polo	985000	LDrIH1vU8x	\N	irani	\N	\N
2VEtxuUYyo	2024-02-15 23:25:00.696+00	2024-02-15 23:25:00.696+00	Khoresh-e Maast	106000	axyV0Fu7pm	\N	irani	\N	\N
SzjCSxKo4t	2024-02-15 23:25:00.89+00	2024-02-15 23:25:00.89+00	Khoresh-e Gandom	223000	9GF3y7LmHV	\N	sonati	\N	\N
ztsrbkjcgM	2024-02-15 23:25:01.099+00	2024-02-15 23:25:01.099+00	Zereshk Polo	497000	WSTLlXDcKl	\N	sonati	\N	\N
lfZR6BCVr1	2024-02-15 23:25:01.296+00	2024-02-15 23:25:01.296+00	Khoresh-e Gandom	255000	WSTLlXDcKl	\N	irani	\N	\N
f1KlX9GiCN	2024-02-15 23:25:01.492+00	2024-02-15 23:25:01.492+00	Aloo Mosamma	16000	FYXEfIO1zF	\N	irani	\N	\N
6rE1bGI6SI	2024-02-15 23:25:01.689+00	2024-02-15 23:25:01.689+00	Khoresh-e Gandom	206000	XwszrNEEEj	\N	irani	\N	\N
GsCJ97XnKg	2024-02-15 23:25:01.886+00	2024-02-15 23:25:01.886+00	Mirza Ghasemi	813000	RkhjIQJgou	\N	sonati	\N	\N
FhVZK9mpfO	2024-02-15 23:25:02.082+00	2024-02-15 23:25:02.082+00	Khagineh Birjand	475000	14jGmOAXcg	\N	irani	\N	\N
yOgU8itLd0	2024-02-15 23:25:02.281+00	2024-02-15 23:25:02.281+00	Khoresh-e Haleem	606000	MQfxuw3ERg	\N	irani	\N	\N
dTbwKYxJlm	2024-02-15 23:25:02.479+00	2024-02-15 23:25:02.479+00	Baghali Polo ba Goosht	37000	D0A6GLdsDM	\N	sonati	\N	\N
UfL0qOllC3	2024-02-15 23:25:02.679+00	2024-02-15 23:25:02.679+00	Dizi	982000	lEPdiO1EDi	\N	irani	\N	\N
WNbuVhODLi	2024-02-15 23:25:02.875+00	2024-02-15 23:25:02.875+00	Khoresh Bademjan	399000	XwszrNEEEj	\N	irani	\N	\N
Jh1m8h775S	2024-02-15 23:25:03.075+00	2024-02-15 23:25:03.075+00	Khoresh-e Kadoo	743000	lEPdiO1EDi	\N	sonati	\N	\N
7Y2xtSVSnr	2024-02-15 23:25:03.349+00	2024-02-15 23:25:03.349+00	Bastani Akbar Mashti	441000	D0A6GLdsDM	\N	sonati	\N	\N
0yDP5a0fd3	2024-02-15 23:25:03.551+00	2024-02-15 23:25:03.551+00	Lubia Polo	316000	Oahm9sOn1y	\N	irani	\N	\N
A5dNMQKQ2t	2024-02-15 23:25:03.744+00	2024-02-15 23:25:03.744+00	Khoresh-e Beh	79000	NY6RE1qgWu	\N	sonati	\N	\N
btPhqW1IBW	2024-02-15 23:25:03.947+00	2024-02-15 23:25:03.947+00	Khoresh-e Gandom	799000	TZsdmscJ2B	\N	sonati	\N	\N
VS4tSyD1tC	2024-02-15 23:25:04.145+00	2024-02-15 23:25:04.145+00	Ashe Reshteh	504000	o4VD4BWwDt	\N	sonati	\N	\N
eBiHAjXHDV	2024-02-15 23:25:04.343+00	2024-02-15 23:25:04.343+00	Joojeh Kabab	570000	8w7i8C3NnT	\N	sonati	\N	\N
SHI7pGORVi	2024-02-15 23:25:04.543+00	2024-02-15 23:25:04.543+00	Ash-e Doogh	115000	HXtEwLBC7f	\N	sonati	\N	\N
3EBjd29kMA	2024-02-15 23:25:04.742+00	2024-02-15 23:25:04.742+00	Khoresh-e Beh	427000	JLhF4VuByh	\N	irani	\N	\N
yaKhDmssPD	2024-02-15 23:25:04.936+00	2024-02-15 23:25:04.936+00	Kookoo Sabzi	232000	qP3EdIVzfB	\N	sonati	\N	\N
6SscCSSR4I	2024-02-15 23:25:05.135+00	2024-02-15 23:25:05.135+00	Khoresh-e Morgh Ba Zireh	892000	m8hjjLVdPS	\N	sonati	\N	\N
KqCwjEMH1m	2024-02-15 23:25:05.332+00	2024-02-15 23:25:05.332+00	Khoresht-e Gheymeh	875000	o90lhsZ7FK	\N	sonati	\N	\N
C8b9oN0fGV	2024-02-15 23:25:05.529+00	2024-02-15 23:25:05.529+00	Gondi	342000	NY6RE1qgWu	\N	irani	\N	\N
5okAm75MJv	2024-02-15 23:25:05.725+00	2024-02-15 23:25:05.725+00	Kabab Koobideh	95000	qP3EdIVzfB	\N	sonati	\N	\N
uGpBTVtH6J	2024-02-15 23:25:05.921+00	2024-02-15 23:25:05.921+00	Morasa Polo	629000	WSTLlXDcKl	\N	sonati	\N	\N
0yxKrhPFi6	2024-02-15 23:25:06.125+00	2024-02-15 23:25:06.125+00	Tahdig	688000	ThMuD3hYRQ	\N	irani	\N	\N
Sq73p72PeQ	2024-02-15 23:25:06.321+00	2024-02-15 23:25:06.321+00	Khoresh-e Haleem	54000	MQfxuw3ERg	\N	irani	\N	\N
glQQhjQkxI	2024-02-15 23:25:06.519+00	2024-02-15 23:25:06.519+00	Khoresh-e Maast	539000	G0uU7KQLEt	\N	sonati	\N	\N
Oh2KfoiYzr	2024-02-15 23:25:06.726+00	2024-02-15 23:25:06.726+00	Faloodeh	678000	TZsdmscJ2B	\N	irani	\N	\N
FSYBh4c0MW	2024-02-15 23:25:06.923+00	2024-02-15 23:25:06.923+00	Sabzi Polo	635000	AgU9OLJkqz	\N	sonati	\N	\N
sl8MlbyuJZ	2024-02-15 23:25:07.116+00	2024-02-15 23:25:07.116+00	Khoresh-e Sabzi	32000	NY6RE1qgWu	\N	irani	\N	\N
v0lA7zHuwc	2024-02-15 23:25:07.446+00	2024-02-15 23:25:07.446+00	Khagineh Tabriz	55000	P9sBFomftT	\N	sonati	\N	\N
EFjCgdtWmQ	2024-02-15 23:25:07.645+00	2024-02-15 23:25:07.645+00	Baghali Ghatogh	950000	jHqCpA1nWb	\N	sonati	\N	\N
TXreFCo9XJ	2024-02-15 23:25:07.841+00	2024-02-15 23:25:07.841+00	Dizi Sara	42000	FYXEfIO1zF	\N	irani	\N	\N
ZHeiEwDz8u	2024-02-15 23:25:08.041+00	2024-02-15 23:25:08.041+00	Moraba-ye Beh	875000	qZmnAnnPEb	\N	irani	\N	\N
cGVUZMmooO	2024-02-15 23:25:08.239+00	2024-02-15 23:25:08.239+00	Kookoo Sabzi	369000	3u4B9V4l5K	\N	sonati	\N	\N
2Km5UZq2tp	2024-02-15 23:25:08.437+00	2024-02-15 23:25:08.437+00	Mast-o-Khiar	968000	l1Bslv8T2k	\N	irani	\N	\N
v5JUcmGb8N	2024-02-15 23:25:08.631+00	2024-02-15 23:25:08.631+00	Tachin Morgh	976000	uABtFsJhJc	\N	sonati	\N	\N
qop5nlmGPh	2024-02-15 23:25:08.823+00	2024-02-15 23:25:08.823+00	Torshe Tareh	155000	E2hBZzDsjO	\N	irani	\N	\N
6U4Z1zPZrh	2024-02-15 23:25:09.021+00	2024-02-15 23:25:09.021+00	Bastani Akbar Mashti	499000	WBFeKac0OO	\N	irani	\N	\N
1NNgiCHuzA	2024-02-15 23:25:09.216+00	2024-02-15 23:25:09.216+00	Khoresht-e Bamieh	244000	FJOTueDfs2	\N	sonati	\N	\N
sn1JO1ekpL	2024-02-15 23:25:09.415+00	2024-02-15 23:25:09.415+00	Bastani Akbar Mashti	825000	LgJuu5ABe5	\N	irani	\N	\N
eDfLjFYPXG	2024-02-15 23:25:09.608+00	2024-02-15 23:25:09.608+00	Abgoosht	863000	JRi61dUphq	\N	sonati	\N	\N
Cuv3d6m0yH	2024-02-15 23:25:09.801+00	2024-02-15 23:25:09.801+00	Tachin Morgh	375000	D0A6GLdsDM	\N	irani	\N	\N
azlYxKVcHq	2024-02-15 23:25:10.001+00	2024-02-15 23:25:10.001+00	Tahchin	642000	FYXEfIO1zF	\N	sonati	\N	\N
K5c1xayKL8	2024-02-15 23:25:10.2+00	2024-02-15 23:25:10.2+00	Adas Polo	644000	FJOTueDfs2	\N	sonati	\N	\N
Pz0Y9KClCB	2024-02-15 23:25:10.394+00	2024-02-15 23:25:10.394+00	Ash-e Anar	657000	lxQA9rtSfY	\N	irani	\N	\N
ATidliCDfD	2024-02-15 23:25:10.583+00	2024-02-15 23:25:10.583+00	Khoresh-e Havij ba Morgh	476000	e037qpAih3	\N	sonati	\N	\N
35b1UvwYMK	2024-02-15 23:25:10.775+00	2024-02-15 23:25:10.775+00	Khoresh-e Loobia Sabz	56000	E2hBZzDsjO	\N	sonati	\N	\N
HrpbXo8o57	2024-02-15 23:25:10.972+00	2024-02-15 23:25:10.972+00	Khoresh-e Beh	822000	WBFeKac0OO	\N	irani	\N	\N
AycFlxSwft	2024-02-15 23:25:11.232+00	2024-02-15 23:25:11.232+00	Khoresh-e Kardeh	454000	9GF3y7LmHV	\N	sonati	\N	\N
qji1uwMu3A	2024-02-15 23:25:11.424+00	2024-02-15 23:25:11.424+00	Tahchin	32000	na5crB8ED1	\N	irani	\N	\N
vFe69sFviN	2024-02-15 23:25:11.621+00	2024-02-15 23:25:11.621+00	Khoresht-e Alu Esfenaj	799000	m8hjjLVdPS	\N	irani	\N	\N
TsHDXi2Iko	2024-02-15 23:25:11.82+00	2024-02-15 23:25:11.82+00	Khoresh-e Sabzi	43000	3P6kmNoY1F	\N	sonati	\N	\N
t9If8Ligna	2024-02-15 23:25:12.019+00	2024-02-15 23:25:12.019+00	Dizi Sara	216000	l1Bslv8T2k	\N	irani	\N	\N
Cx2AwPrWIO	2024-02-15 23:25:12.219+00	2024-02-15 23:25:12.219+00	Khoresh-e Chelo	313000	cmxBcanww9	\N	sonati	\N	\N
IjNDO28cVz	2024-02-15 23:25:12.414+00	2024-02-15 23:25:12.414+00	Morgh-e Torsh	193000	bQpy9LEJWn	\N	sonati	\N	\N
kX4mGSahsz	2024-02-15 23:25:12.614+00	2024-02-15 23:25:12.614+00	Fesenjan	302000	Oahm9sOn1y	\N	irani	\N	\N
hF8vplQqSk	2024-02-15 23:25:12.812+00	2024-02-15 23:25:12.812+00	Khoresh-e Loobia Sabz	243000	Pja6n3yaWZ	\N	irani	\N	\N
xan8X0fVEt	2024-02-15 23:25:13.01+00	2024-02-15 23:25:13.01+00	Adas Polo	129000	LVYK4mLShP	\N	sonati	\N	\N
B2gDJvrwrC	2024-02-15 23:25:13.203+00	2024-02-15 23:25:13.203+00	Khoresh-e Haleem	141000	FYXEfIO1zF	\N	irani	\N	\N
7oM6zOmn0C	2024-02-15 23:25:13.398+00	2024-02-15 23:25:13.398+00	Khoresh-e Loobia Sabz	303000	fwLPZZ8YQa	\N	irani	\N	\N
hrfuKSYDsJ	2024-02-15 23:25:13.593+00	2024-02-15 23:25:13.593+00	Khoresh-e Fesenjan	951000	bQpy9LEJWn	\N	irani	\N	\N
bBAk7SrOXA	2024-02-15 23:25:13.796+00	2024-02-15 23:25:13.796+00	Nan-e Barbari	854000	LDrIH1vU8x	\N	irani	\N	\N
Yz2LI2RnIB	2024-02-15 23:25:13.995+00	2024-02-15 23:25:13.995+00	Fesenjan	970000	0TvWuLoLF5	\N	irani	\N	\N
wnIL4KzroE	2024-02-15 23:25:14.205+00	2024-02-15 23:25:14.205+00	Shirin Laboo	879000	Pa0qBO2rzK	\N	sonati	\N	\N
il5LtYDTFk	2024-02-15 23:25:14.401+00	2024-02-15 23:25:14.401+00	Khoresh-e Fesenjan	617000	RkhjIQJgou	\N	sonati	\N	\N
L3MMZ2B3IJ	2024-02-15 23:25:14.599+00	2024-02-15 23:25:14.599+00	Nan-e Barbari	534000	H40ivltLwZ	\N	irani	\N	\N
YYAK7k6Pu3	2024-02-15 23:25:14.803+00	2024-02-15 23:25:14.803+00	Bastani Sonnati	631000	uigc7bJBOJ	\N	irani	\N	\N
x03dUfkR3B	2024-02-15 23:25:15+00	2024-02-15 23:25:15+00	Khagineh	832000	Gl96vGdYHM	\N	sonati	\N	\N
BsWUyMnieP	2024-02-15 23:25:15.195+00	2024-02-15 23:25:15.195+00	Khagineh	130000	8w7i8C3NnT	\N	sonati	\N	\N
FXhQfvJ89c	2024-02-15 23:25:15.393+00	2024-02-15 23:25:15.393+00	Khagineh Tabriz	630000	AgU9OLJkqz	\N	irani	\N	\N
NxImp2ceHX	2024-02-15 23:25:15.585+00	2024-02-15 23:25:15.585+00	Kabab Koobideh	22000	OQWu2bnHeC	\N	sonati	\N	\N
kRe1jnrix3	2024-02-15 23:25:15.786+00	2024-02-15 23:25:15.786+00	Khoresh-e Loobia Sabz	456000	M0tHrt1GgV	\N	irani	\N	\N
VHSM5oLCqt	2024-02-15 23:25:15.984+00	2024-02-15 23:25:15.984+00	Ashe Reshteh	93000	14jGmOAXcg	\N	sonati	\N	\N
aBwXkW9Idm	2024-02-15 23:25:16.184+00	2024-02-15 23:25:16.184+00	Halim Bademjan	596000	IEqTHcohpJ	\N	irani	\N	\N
jyy0d9lwIF	2024-02-15 23:25:16.377+00	2024-02-15 23:25:16.377+00	Khoresh-e Baamieh	481000	cmxBcanww9	\N	sonati	\N	\N
hAwUY4lGoB	2024-02-15 23:25:16.574+00	2024-02-15 23:25:16.574+00	Khoresh-e Karafs-e Holu	58000	MQfxuw3ERg	\N	sonati	\N	\N
7SsmAwGIhX	2024-02-15 23:25:16.772+00	2024-02-15 23:25:16.772+00	Yatimcheh	30000	qEQ9tmLyW9	\N	irani	\N	\N
kHMc1jBcG0	2024-02-15 23:25:16.97+00	2024-02-15 23:25:16.97+00	Khoresht-e Torsh	610000	89xRG1afNi	\N	irani	\N	\N
lINiq6Jakr	2024-02-15 23:25:17.169+00	2024-02-15 23:25:17.169+00	Sirabi	738000	e037qpAih3	\N	irani	\N	\N
CDdIMBuQpy	2024-02-15 23:25:17.368+00	2024-02-15 23:25:17.368+00	Khoresh-e Nokhodchi	757000	6KvFK8yy1q	\N	sonati	\N	\N
acd22ZhQDp	2024-02-15 23:25:17.561+00	2024-02-15 23:25:17.561+00	Morgh-e Torsh	727000	e037qpAih3	\N	sonati	\N	\N
FRbluUjiOm	2024-02-15 23:25:17.765+00	2024-02-15 23:25:17.765+00	Morasa Polo	293000	P9sBFomftT	\N	sonati	\N	\N
oxEE7LvU2F	2024-02-15 23:25:17.961+00	2024-02-15 23:25:17.961+00	Dizi Sara	472000	6Fo67rhTSP	\N	sonati	\N	\N
LvAMQHGK11	2024-02-15 23:25:18.167+00	2024-02-15 23:25:18.167+00	Tahdig	164000	bQpy9LEJWn	\N	irani	\N	\N
F9j80VEW6e	2024-02-15 23:25:18.374+00	2024-02-15 23:25:18.374+00	Khoresh-e Karafs	863000	14jGmOAXcg	\N	sonati	\N	\N
ualSw46JCE	2024-02-15 23:25:18.575+00	2024-02-15 23:25:18.575+00	Ashe Reshteh	741000	na5crB8ED1	\N	sonati	\N	\N
HNduOUixhC	2024-02-15 23:25:18.775+00	2024-02-15 23:25:18.775+00	Moraba-ye Anar Daneh	430000	EmIUBFwx0Z	\N	irani	\N	\N
FhIHAgNqyP	2024-02-15 23:25:18.983+00	2024-02-15 23:25:18.983+00	Zereshk Polo	69000	3u4B9V4l5K	\N	sonati	\N	\N
ZAEkHIstXC	2024-02-15 23:25:19.183+00	2024-02-15 23:25:19.183+00	Khoresht-e Karafs	818000	8w7i8C3NnT	\N	sonati	\N	\N
SzLcEM2DH3	2024-02-15 23:25:19.39+00	2024-02-15 23:25:19.39+00	Khoresh Bademjan	505000	eEmewy7hPd	\N	sonati	\N	\N
1VARTniz75	2024-02-15 23:25:19.59+00	2024-02-15 23:25:19.59+00	Baghali Ghatogh	75000	IybX0eBoO3	\N	sonati	\N	\N
Pob67ZDCRB	2024-02-15 23:25:19.803+00	2024-02-15 23:25:19.803+00	Shami Kabab	102000	RBRcyltRSC	\N	irani	\N	\N
9p19fERKsH	2024-02-15 23:25:19.998+00	2024-02-15 23:25:19.998+00	Khoresht-e Karafs	159000	cFtamPA0zH	\N	sonati	\N	\N
0j530RZL1i	2024-02-15 23:25:20.194+00	2024-02-15 23:25:20.194+00	Khoresh-e Morgh Ba Zireh	576000	UCFo58JaaD	\N	irani	\N	\N
P2559X54SC	2024-02-15 23:25:20.397+00	2024-02-15 23:25:20.397+00	Shami Kabab	44000	D0A6GLdsDM	\N	irani	\N	\N
3e9DjGmoH2	2024-02-15 23:25:20.721+00	2024-02-15 23:25:20.721+00	Baghali Polo ba Goosht	149000	lxQA9rtSfY	\N	irani	\N	\N
vGO7oSzEgZ	2024-02-15 23:25:20.92+00	2024-02-15 23:25:20.92+00	Khoresh-e Loobia Sabz	726000	FJOTueDfs2	\N	sonati	\N	\N
4GYxFSzP1V	2024-02-15 23:25:21.126+00	2024-02-15 23:25:21.126+00	Halva	388000	C7II8dYRPY	\N	sonati	\N	\N
ce1HNf3Dkf	2024-02-15 23:25:21.323+00	2024-02-15 23:25:21.323+00	Kabab Koobideh	836000	Pja6n3yaWZ	\N	sonati	\N	\N
3cij67O4VE	2024-02-15 23:25:21.578+00	2024-02-15 23:25:21.578+00	Dizi	76000	MQfxuw3ERg	\N	sonati	\N	\N
NwvQ4gSKhD	2024-02-15 23:25:21.773+00	2024-02-15 23:25:21.773+00	Gheimeh	186000	H40ivltLwZ	\N	sonati	\N	\N
pRKOYPImyY	2024-02-15 23:25:21.968+00	2024-02-15 23:25:21.968+00	Shirin Adas	547000	FYXEfIO1zF	\N	irani	\N	\N
YeXYDQtv3v	2024-02-15 23:25:22.361+00	2024-02-15 23:25:22.361+00	Sheer Khurma	485000	o4VD4BWwDt	\N	sonati	\N	\N
ciuXURcOKq	2024-02-15 23:25:22.57+00	2024-02-15 23:25:22.57+00	Dizi Tabrizi	745000	WHvlAGgj6c	\N	sonati	\N	\N
JNKoX7ATm3	2024-02-15 23:25:22.774+00	2024-02-15 23:25:22.774+00	Bastani Sonnati	665000	bi1IivsuUB	\N	sonati	\N	\N
dxqYSn0MoB	2024-02-15 23:25:22.972+00	2024-02-15 23:25:22.972+00	Baghali Polo ba Morgh	212000	08liHW08uC	\N	sonati	\N	\N
xHP46Bj66f	2024-02-15 23:25:23.174+00	2024-02-15 23:25:23.174+00	Khoresh-e Sabzi	18000	axyV0Fu7pm	\N	irani	\N	\N
SSmNH5ovLb	2024-02-15 23:25:23.726+00	2024-02-15 23:25:23.726+00	Torshe Tareh	152000	mMYg4cyd5R	\N	irani	\N	\N
J8YDIiywZJ	2024-02-15 23:25:23.923+00	2024-02-15 23:25:23.923+00	Samanu	550000	eEmewy7hPd	\N	sonati	\N	\N
02BRy0e0Ns	2024-02-15 23:25:24.12+00	2024-02-15 23:25:24.12+00	Baghali Polo ba Goosht	815000	Oahm9sOn1y	\N	sonati	\N	\N
TPNc9EgkX5	2024-02-15 23:25:24.319+00	2024-02-15 23:25:24.319+00	Khoresh-e Beh	59000	bQpy9LEJWn	\N	irani	\N	\N
eMZbKgvs6T	2024-02-15 23:25:24.518+00	2024-02-15 23:25:24.518+00	Khoresht-e Karafs	715000	8w7i8C3NnT	\N	irani	\N	\N
rtgg0UriP5	2024-02-15 23:25:24.718+00	2024-02-15 23:25:24.718+00	Khoresht-e Bamieh	837000	RBRcyltRSC	\N	irani	\N	\N
uF8XKa6Kjh	2024-02-15 23:25:24.921+00	2024-02-15 23:25:24.921+00	Ghormeh Sabzi	29000	Pja6n3yaWZ	\N	sonati	\N	\N
o8dtf7SJdO	2024-02-15 23:25:25.127+00	2024-02-15 23:25:25.127+00	Khoresh-e Morgh Ba Zireh	264000	e037qpAih3	\N	sonati	\N	\N
686xXAEEC2	2024-02-15 23:25:25.328+00	2024-02-15 23:25:25.328+00	Ash-e Mast	358000	XwszrNEEEj	\N	sonati	\N	\N
np0CK9vddN	2024-02-15 23:25:25.566+00	2024-02-15 23:25:25.566+00	Khagineh Birjand	928000	cmxBcanww9	\N	sonati	\N	\N
mEYfzTKvXi	2024-02-15 23:25:25.771+00	2024-02-15 23:25:25.771+00	Faloodeh	145000	LDrIH1vU8x	\N	sonati	\N	\N
kObHOjqnla	2024-02-15 23:25:25.977+00	2024-02-15 23:25:25.977+00	Haleem	199000	LDrIH1vU8x	\N	irani	\N	\N
1nhrOalWM1	2024-02-15 23:25:26.173+00	2024-02-15 23:25:26.173+00	Ash-e Anar	916000	E2hBZzDsjO	\N	sonati	\N	\N
ggNqPU1i2d	2024-02-15 23:25:26.378+00	2024-02-15 23:25:26.378+00	Gondi	145000	Pa0qBO2rzK	\N	sonati	\N	\N
XNErOSO18M	2024-02-15 23:25:26.586+00	2024-02-15 23:25:26.586+00	Naz Khatoon	264000	jHqCpA1nWb	\N	irani	\N	\N
XosrtkibSR	2024-02-15 23:25:26.789+00	2024-02-15 23:25:26.789+00	Sheer Khurma	581000	jjVdtithcD	\N	irani	\N	\N
wB8GEOv7dF	2024-02-15 23:25:27.008+00	2024-02-15 23:25:27.008+00	Ghormeh Sabzi	804000	vwHi602n66	\N	irani	\N	\N
Zv4wrMKdDz	2024-02-15 23:25:27.206+00	2024-02-15 23:25:27.206+00	Moraba-ye Beh	895000	JRi61dUphq	\N	sonati	\N	\N
88LrGE2vjm	2024-02-15 23:25:27.408+00	2024-02-15 23:25:27.408+00	Khoresh-e Gandom	514000	D0A6GLdsDM	\N	irani	\N	\N
2pgSByE5c4	2024-02-15 23:25:27.615+00	2024-02-15 23:25:27.615+00	Halim Bademjan	192000	6KvFK8yy1q	\N	irani	\N	\N
HCmgOZKOLd	2024-02-15 23:25:27.807+00	2024-02-15 23:25:27.807+00	Baghali Polo ba Morgh	999000	mMYg4cyd5R	\N	sonati	\N	\N
gKJP1eisSc	2024-02-15 23:25:28.005+00	2024-02-15 23:25:28.005+00	Ash-e Mast	401000	JRi61dUphq	\N	sonati	\N	\N
tNwQGWDwZF	2024-02-15 23:25:28.199+00	2024-02-15 23:25:28.199+00	Shirin Polo	854000	LDrIH1vU8x	\N	irani	\N	\N
EjHnCd1owD	2024-02-15 23:25:28.415+00	2024-02-15 23:25:28.415+00	Moraba-ye Gerdoo	574000	WBFeKac0OO	\N	irani	\N	\N
r7qsof3wxo	2024-02-15 23:25:28.609+00	2024-02-15 23:25:28.609+00	Khoresht-e Bamieh	656000	fxvABtKCPT	\N	irani	\N	\N
gKwXPJwLbh	2024-02-15 23:25:28.808+00	2024-02-15 23:25:28.808+00	Shirin Adas	918000	m6g8u0QpTC	\N	sonati	\N	\N
thB75P5eHd	2024-02-15 23:25:29.023+00	2024-02-15 23:25:29.023+00	Khoresht-e Alu Esfenaj	387000	LDrIH1vU8x	\N	irani	\N	\N
srUMzPbRus	2024-02-15 23:25:29.222+00	2024-02-15 23:25:29.222+00	Kuku	988000	JLhF4VuByh	\N	irani	\N	\N
OBW1ImbFV4	2024-02-15 23:25:29.426+00	2024-02-15 23:25:29.426+00	Shirin Polo	131000	3u4B9V4l5K	\N	irani	\N	\N
hVvR31QnUQ	2024-02-15 23:25:29.629+00	2024-02-15 23:25:29.629+00	Bastani Akbar Mashti	300000	ThMuD3hYRQ	\N	irani	\N	\N
30hjmwA4LW	2024-02-15 23:25:29.83+00	2024-02-15 23:25:29.83+00	Kookoo Sabzi	962000	WBFeKac0OO	\N	irani	\N	\N
dTiJ4PjP5t	2024-02-15 23:25:30.239+00	2024-02-15 23:25:30.239+00	Gondi	812000	bQ0JOk10eL	\N	sonati	\N	\N
IrRJQP7Iol	2024-02-15 23:25:30.433+00	2024-02-15 23:25:30.433+00	Baghali Ghatogh	714000	qEQ9tmLyW9	\N	irani	\N	\N
IIvAr2D045	2024-02-15 23:25:30.632+00	2024-02-15 23:25:30.632+00	Khoresh-e Beh	227000	3u4B9V4l5K	\N	irani	\N	\N
PW12GBVOmL	2024-02-15 23:25:30.83+00	2024-02-15 23:25:30.83+00	Moraba-ye Beh	970000	jjVdtithcD	\N	irani	\N	\N
e1A3WCQcbF	2024-02-15 23:25:31.029+00	2024-02-15 23:25:31.029+00	Sholeh Zard	597000	6Fo67rhTSP	\N	irani	\N	\N
o7CRIUVCIA	2024-02-15 23:25:31.228+00	2024-02-15 23:25:31.228+00	Khoresht-e Gheymeh	819000	m8hjjLVdPS	\N	irani	\N	\N
ybF5up5Cx8	2024-02-15 23:25:31.425+00	2024-02-15 23:25:31.425+00	Khoresh Bademjan	253000	XwWwGnkXNj	\N	sonati	\N	\N
7n4lqvc6R8	2024-02-15 23:25:31.62+00	2024-02-15 23:25:31.62+00	Kookoo Sabzi	279000	qP3EdIVzfB	\N	irani	\N	\N
KZ5k2lJfne	2024-02-15 23:25:31.817+00	2024-02-15 23:25:31.817+00	Baghali Polo ba Morgh	801000	XSK814B37m	\N	irani	\N	\N
UskIGHT6Nv	2024-02-15 23:25:32.019+00	2024-02-15 23:25:32.019+00	Kuku	973000	3u4B9V4l5K	\N	sonati	\N	\N
wQkz82B5Dt	2024-02-15 23:25:32.221+00	2024-02-15 23:25:32.221+00	Khoresh-e Kardeh	422000	EmIUBFwx0Z	\N	sonati	\N	\N
LV3CHQuUxA	2024-02-15 23:25:32.421+00	2024-02-15 23:25:32.421+00	Kalam Polo Mahicheh	89000	m8hjjLVdPS	\N	irani	\N	\N
tjPbvzrKMa	2024-02-15 23:25:32.623+00	2024-02-15 23:25:32.623+00	Ash-e Anar	106000	PF8w2gMAdi	\N	irani	\N	\N
MfMuS4IkHN	2024-02-15 23:25:32.822+00	2024-02-15 23:25:32.822+00	Zereshk Polo	927000	u5FXeeOChJ	\N	sonati	\N	\N
vKzt5iEhF7	2024-02-15 23:25:33.022+00	2024-02-15 23:25:33.022+00	Kalam Polo	686000	D0A6GLdsDM	\N	sonati	\N	\N
u4czRGyKMX	2024-02-15 23:25:33.219+00	2024-02-15 23:25:33.219+00	Halim Bademjan	509000	jjVdtithcD	\N	sonati	\N	\N
w2AjbstDra	2024-02-15 23:25:33.415+00	2024-02-15 23:25:33.415+00	Moraba-ye Beh	294000	yvUod6yLDt	\N	irani	\N	\N
U3v1luPIV3	2024-02-15 23:25:33.615+00	2024-02-15 23:25:33.615+00	Khagineh Yazdi	428000	fKTSJPdUi9	\N	sonati	\N	\N
2ggqvElyof	2024-02-15 23:25:33.814+00	2024-02-15 23:25:33.814+00	Moraba-ye Beh	324000	CSvk1ycWXk	\N	irani	\N	\N
S4uA6nQKSn	2024-02-15 23:25:34.014+00	2024-02-15 23:25:34.014+00	Kabab Koobideh	160000	LgJuu5ABe5	\N	irani	\N	\N
xMlwjbtf2B	2024-02-15 23:25:34.219+00	2024-02-15 23:25:34.219+00	Gheimeh	510000	uigc7bJBOJ	\N	irani	\N	\N
RgXHiuYB40	2024-02-15 23:25:34.423+00	2024-02-15 23:25:34.423+00	Halva Shekari	954000	m6g8u0QpTC	\N	sonati	\N	\N
9BSCIhdWUY	2024-02-15 23:25:34.622+00	2024-02-15 23:25:34.622+00	Halim Bademjan	781000	8w7i8C3NnT	\N	sonati	\N	\N
LVtyC3DFEp	2024-02-15 23:25:34.819+00	2024-02-15 23:25:34.819+00	Aloo Mosamma	271000	ThMuD3hYRQ	\N	sonati	\N	\N
He25iM49m0	2024-02-15 23:25:35.023+00	2024-02-15 23:25:35.023+00	Khoresh-e Beh	764000	jjVdtithcD	\N	irani	\N	\N
lY14iVH9kr	2024-02-15 23:25:35.217+00	2024-02-15 23:25:35.217+00	Halva	638000	PF8w2gMAdi	\N	irani	\N	\N
Ov1DQ4efmH	2024-02-15 23:25:35.414+00	2024-02-15 23:25:35.414+00	Salad Shirazi	560000	fwLPZZ8YQa	\N	sonati	\N	\N
Vm12pXkkey	2024-02-15 23:25:35.61+00	2024-02-15 23:25:35.61+00	Baghali Ghatogh	836000	cmxBcanww9	\N	sonati	\N	\N
HdwRfTbAyb	2024-02-15 23:25:35.814+00	2024-02-15 23:25:35.814+00	Khoresh-e Mast	975000	LDrIH1vU8x	\N	sonati	\N	\N
wDmzSfclnQ	2024-02-15 23:25:36.014+00	2024-02-15 23:25:36.014+00	Khoresh-e Chelo	505000	o90lhsZ7FK	\N	sonati	\N	\N
PZGHkdAVUb	2024-02-15 23:25:36.213+00	2024-02-15 23:25:36.213+00	Ghormeh Sabzi	909000	CSvk1ycWXk	\N	sonati	\N	\N
dxkqfmCL1h	2024-02-15 23:25:36.409+00	2024-02-15 23:25:36.409+00	Khoresht-e Gheymeh	32000	WnUBBkiDjE	\N	sonati	\N	\N
VRdnOEQC6d	2024-02-15 23:25:36.599+00	2024-02-15 23:25:36.599+00	Torshe Tareh	108000	axyV0Fu7pm	\N	irani	\N	\N
2KdcTl5Uru	2024-02-15 23:25:36.798+00	2024-02-15 23:25:36.798+00	Koloocheh	816000	lEPdiO1EDi	\N	irani	\N	\N
B7SbrsQQ3v	2024-02-15 23:25:37.003+00	2024-02-15 23:25:37.003+00	Joojeh Kabab	643000	E2hBZzDsjO	\N	irani	\N	\N
RuVNOkbevm	2024-02-15 23:25:37.203+00	2024-02-15 23:25:37.203+00	Khoresh-e Karafs-e Holu	25000	NY6RE1qgWu	\N	irani	\N	\N
kuOz1z1CYG	2024-02-15 23:25:37.408+00	2024-02-15 23:25:37.408+00	Khoresh-e Kardeh	261000	l1Bslv8T2k	\N	sonati	\N	\N
qJ13BkSF5H	2024-02-15 23:25:37.61+00	2024-02-15 23:25:37.61+00	Gondi	904000	ThMuD3hYRQ	\N	sonati	\N	\N
unCUN2WIU9	2024-02-15 23:25:37.812+00	2024-02-15 23:25:37.812+00	Torshe Tareh	245000	H40ivltLwZ	\N	irani	\N	\N
3yprSgOau4	2024-02-15 23:25:38.015+00	2024-02-15 23:25:38.015+00	Koloocheh	129000	tCIEnLLcUc	\N	irani	\N	\N
wpDP937tgA	2024-02-15 23:25:38.221+00	2024-02-15 23:25:38.221+00	Khoresh-e Beh	694000	6KvFK8yy1q	\N	sonati	\N	\N
CA6K7kKLoA	2024-02-15 23:25:38.429+00	2024-02-15 23:25:38.429+00	Khoresht-e Bamieh	659000	XSK814B37m	\N	irani	\N	\N
bxeTmm3AD4	2024-02-15 23:25:38.622+00	2024-02-15 23:25:38.622+00	Khoresh-e Havij	95000	TCkiw6gTDz	\N	sonati	\N	\N
7emdJDytZB	2024-02-15 23:25:38.818+00	2024-02-15 23:25:38.818+00	Joojeh Kabab	244000	AgU9OLJkqz	\N	irani	\N	\N
ybPPEhqHcM	2024-02-15 23:25:39.022+00	2024-02-15 23:25:39.022+00	Dizi Tabrizi	957000	P9sBFomftT	\N	sonati	\N	\N
9yZ5vwPVG9	2024-02-15 23:25:39.221+00	2024-02-15 23:25:39.221+00	Khoresh-e Baamieh	278000	fxvABtKCPT	\N	sonati	\N	\N
Lnfrxq3M1G	2024-02-15 23:25:39.421+00	2024-02-15 23:25:39.421+00	Khoresh-e Haleem	903000	CSvk1ycWXk	\N	irani	\N	\N
JitRaN8zzA	2024-02-15 23:25:39.617+00	2024-02-15 23:25:39.617+00	Khoresht-e Gheymeh	277000	VK3vnSxIy8	\N	irani	\N	\N
thk7Jms2wS	2024-02-15 23:25:39.815+00	2024-02-15 23:25:39.815+00	Joojeh Kabab	445000	lxQA9rtSfY	\N	irani	\N	\N
2GHGvpz7EN	2024-02-15 23:25:40.017+00	2024-02-15 23:25:40.017+00	Moraba-ye Gerdoo	205000	fKTSJPdUi9	\N	sonati	\N	\N
dzYn2lYZK7	2024-02-15 23:25:40.219+00	2024-02-15 23:25:40.219+00	Faloodeh	563000	mMYg4cyd5R	\N	irani	\N	\N
uREsaGEueb	2024-02-15 23:25:40.423+00	2024-02-15 23:25:40.423+00	Khoresh-e Chelo	713000	M0tHrt1GgV	\N	irani	\N	\N
PN0gqgFVLs	2024-02-15 23:25:40.617+00	2024-02-15 23:25:40.617+00	Khoresh-e Gerdoo	12000	jHqCpA1nWb	\N	sonati	\N	\N
XW3XblWJiE	2024-02-15 23:25:40.816+00	2024-02-15 23:25:40.816+00	Khoresh-e Havij ba Morgh	566000	9GF3y7LmHV	\N	sonati	\N	\N
NEvJHDQFp6	2024-02-15 23:25:41.022+00	2024-02-15 23:25:41.022+00	Shirin Yazdi	782000	XwszrNEEEj	\N	sonati	\N	\N
vFz4eNf3h6	2024-02-15 23:25:41.218+00	2024-02-15 23:25:41.218+00	Moraba-ye Gerdoo	395000	IybX0eBoO3	\N	sonati	\N	\N
Uoki2cZgwY	2024-02-15 23:25:41.42+00	2024-02-15 23:25:41.42+00	Khoresh-e Havij ba Morgh	486000	l1Bslv8T2k	\N	irani	\N	\N
D9fS5e01qC	2024-02-15 23:25:41.621+00	2024-02-15 23:25:41.621+00	Shirin Adas	810000	LgJuu5ABe5	\N	sonati	\N	\N
4ay1ml5W6k	2024-02-15 23:25:41.829+00	2024-02-15 23:25:41.829+00	Khoresht-e Alu Esfenaj	493000	8w7i8C3NnT	\N	sonati	\N	\N
btOnd5nYDu	2024-02-15 23:25:42.043+00	2024-02-15 23:25:42.043+00	Khoresh-e Beh	230000	axyV0Fu7pm	\N	sonati	\N	\N
KD7BsBjDBJ	2024-02-15 23:25:42.256+00	2024-02-15 23:25:42.256+00	Khoresh-e Chelo	788000	mMYg4cyd5R	\N	irani	\N	\N
iywkBtCxEW	2024-02-15 23:25:42.458+00	2024-02-15 23:25:42.458+00	Ash-e Anar	718000	bQpy9LEJWn	\N	irani	\N	\N
NoZ5qk0GNF	2024-02-15 23:25:42.74+00	2024-02-15 23:25:42.74+00	Halva	335000	FJOTueDfs2	\N	sonati	\N	\N
pxIkJgJ9CX	2024-02-15 23:25:42.94+00	2024-02-15 23:25:42.94+00	Koloocheh	445000	JRi61dUphq	\N	irani	\N	\N
FF62LLYXZb	2024-02-15 23:25:43.141+00	2024-02-15 23:25:43.141+00	Ash-e Miveh	833000	3P6kmNoY1F	\N	sonati	\N	\N
bdg2CtMnQh	2024-02-15 23:25:43.342+00	2024-02-15 23:25:43.342+00	Khoresh-e Kardeh	817000	HXtEwLBC7f	\N	sonati	\N	\N
2FJ6ZScbD4	2024-02-15 23:25:43.544+00	2024-02-15 23:25:43.544+00	Khoresht-e Gheymeh	852000	bi1IivsuUB	\N	sonati	\N	\N
VTUZHZwm2q	2024-02-15 23:25:43.747+00	2024-02-15 23:25:43.747+00	Halim Bademjan	477000	WSTLlXDcKl	\N	sonati	\N	\N
luDdFuREmW	2024-02-15 23:25:43.943+00	2024-02-15 23:25:43.943+00	Dizi	154000	HSEugQ3Ouj	\N	irani	\N	\N
LYCpyXhSjD	2024-02-15 23:25:44.147+00	2024-02-15 23:25:44.147+00	Shami Kabab	755000	G0uU7KQLEt	\N	sonati	\N	\N
8GWkFjUH8T	2024-02-15 23:25:44.345+00	2024-02-15 23:25:44.345+00	Gondi	376000	cFtamPA0zH	\N	irani	\N	\N
Wwb5hviTjh	2024-02-15 23:25:44.535+00	2024-02-15 23:25:44.535+00	Khoresh-e Kardeh	856000	HSEugQ3Ouj	\N	sonati	\N	\N
udptRiC3fh	2024-02-15 23:25:44.731+00	2024-02-15 23:25:44.731+00	Baghali Polo ba Goosht	569000	08liHW08uC	\N	sonati	\N	\N
3zb1JuS6ZU	2024-02-15 23:25:44.928+00	2024-02-15 23:25:44.928+00	Khoresht-e Torsh	348000	3u4B9V4l5K	\N	irani	\N	\N
OEPDvUNeCP	2024-02-15 23:25:45.131+00	2024-02-15 23:25:45.131+00	Halva Shekari	813000	u5FXeeOChJ	\N	irani	\N	\N
SXZniuIFgE	2024-02-15 23:25:45.335+00	2024-02-15 23:25:45.335+00	Dizi Sara	212000	XpUyRlB6FI	\N	sonati	\N	\N
BLchHm3PXU	2024-02-15 23:25:45.542+00	2024-02-15 23:25:45.542+00	Haleem	253000	WBFeKac0OO	\N	irani	\N	\N
PVdU4fsDhp	2024-02-15 23:25:45.743+00	2024-02-15 23:25:45.743+00	Halva	59000	FYXEfIO1zF	\N	sonati	\N	\N
ZVWKiQuWN9	2024-02-15 23:25:45.948+00	2024-02-15 23:25:45.948+00	Kuku	283000	bQ0JOk10eL	\N	sonati	\N	\N
3OAAiILexe	2024-02-15 23:25:46.152+00	2024-02-15 23:25:46.152+00	Adas Polo	177000	IEqTHcohpJ	\N	irani	\N	\N
ss5vKvuLkv	2024-02-15 23:25:46.353+00	2024-02-15 23:25:46.353+00	Moraba-ye Beh	498000	Pja6n3yaWZ	\N	irani	\N	\N
SpzmhzBazr	2024-02-15 23:25:46.551+00	2024-02-15 23:25:46.551+00	Khoresh-e Nokhodchi	698000	HSEugQ3Ouj	\N	irani	\N	\N
GhjA51pbMA	2024-02-15 23:25:46.773+00	2024-02-15 23:25:46.773+00	Khoresht-e Bamieh	147000	HXtEwLBC7f	\N	sonati	\N	\N
uf8BlSyGbD	2024-02-15 23:25:46.987+00	2024-02-15 23:25:46.987+00	Kookoo Sibzamini	722000	y4RkaDbkec	\N	sonati	\N	\N
Y0G6mebyg5	2024-02-15 23:25:47.192+00	2024-02-15 23:25:47.192+00	Morasa Polo	832000	l1Bslv8T2k	\N	irani	\N	\N
BRvglXbHCv	2024-02-15 23:25:47.4+00	2024-02-15 23:25:47.4+00	Salad Shirazi	83000	rKyjwoEIRp	\N	sonati	\N	\N
BrVSOXdK6y	2024-02-15 23:25:47.608+00	2024-02-15 23:25:47.608+00	Adas Polo	65000	FYXEfIO1zF	\N	sonati	\N	\N
L50l6SEhHk	2024-02-15 23:25:47.808+00	2024-02-15 23:25:47.808+00	Gondi	938000	Pa0qBO2rzK	\N	sonati	\N	\N
luLi1djFiI	2024-02-15 23:25:48.016+00	2024-02-15 23:25:48.016+00	Shirin Laboo	24000	qP3EdIVzfB	\N	sonati	\N	\N
vBAxsV2w2M	2024-02-15 23:25:48.219+00	2024-02-15 23:25:48.219+00	Khoresh-e Mast	622000	XpUyRlB6FI	\N	sonati	\N	\N
IhesHTppPJ	2024-02-15 23:25:48.423+00	2024-02-15 23:25:48.423+00	Kalam Polo Mahicheh	570000	NY6RE1qgWu	\N	irani	\N	\N
uJMDfP2M16	2024-02-15 23:25:48.629+00	2024-02-15 23:25:48.629+00	Lubia Polo	722000	MQfxuw3ERg	\N	sonati	\N	\N
Mv7Qzb0I0S	2024-02-15 23:25:48.828+00	2024-02-15 23:25:48.828+00	Koloocheh	898000	NY6RE1qgWu	\N	irani	\N	\N
cR7jyorhnd	2024-02-15 23:25:49.031+00	2024-02-15 23:25:49.031+00	Kookoo Sibzamini	506000	j0dWqP2C2A	\N	sonati	\N	\N
r1XBcQbb4x	2024-02-15 23:25:49.236+00	2024-02-15 23:25:49.236+00	Dizi	678000	rKyjwoEIRp	\N	sonati	\N	\N
0LrUgsFL2g	2024-02-15 23:25:49.438+00	2024-02-15 23:25:49.438+00	Mirza Ghasemi	860000	89xRG1afNi	\N	sonati	\N	\N
E0PgNADztr	2024-02-15 23:25:49.638+00	2024-02-15 23:25:49.638+00	Lubia Polo	426000	3P6kmNoY1F	\N	irani	\N	\N
pJDmHGZsNr	2024-02-15 23:25:49.841+00	2024-02-15 23:25:49.841+00	Aloo Mosamma	15000	0TvWuLoLF5	\N	sonati	\N	\N
VRPUUsXgVW	2024-02-15 23:25:50.043+00	2024-02-15 23:25:50.043+00	Shami Kabab	79000	TZsdmscJ2B	\N	irani	\N	\N
1HOnvrJO16	2024-02-15 23:25:50.353+00	2024-02-15 23:25:50.353+00	Khoresht-e Gheymeh Nesar	448000	cFtamPA0zH	\N	irani	\N	\N
lKksRtLUvi	2024-02-15 23:25:50.545+00	2024-02-15 23:25:50.545+00	Shami Kabab	940000	P9sBFomftT	\N	irani	\N	\N
Cca7hU3cAA	2024-02-15 23:25:50.742+00	2024-02-15 23:25:50.742+00	Khoresh-e Sabzi	951000	H40ivltLwZ	\N	sonati	\N	\N
52N9EQjoob	2024-02-15 23:25:50.942+00	2024-02-15 23:25:50.942+00	Lubia Polo	970000	fKTSJPdUi9	\N	irani	\N	\N
FAvBREYPd5	2024-02-15 23:25:51.141+00	2024-02-15 23:25:51.141+00	Ash-e Miveh	310000	TpGyMZM9BG	\N	irani	\N	\N
tBbFpLtivR	2024-02-15 23:25:51.34+00	2024-02-15 23:25:51.34+00	Mirza Ghasemi	58000	IEqTHcohpJ	\N	irani	\N	\N
ckm5i0aRxS	2024-02-15 23:25:51.539+00	2024-02-15 23:25:51.539+00	Shirin Polo	222000	uigc7bJBOJ	\N	irani	\N	\N
TYpJSBO1H9	2024-02-15 23:25:51.74+00	2024-02-15 23:25:51.74+00	Tahchin	327000	XwszrNEEEj	\N	irani	\N	\N
dRidFzxbgc	2024-02-15 23:25:51.954+00	2024-02-15 23:25:51.954+00	Aloo Mosamma	457000	na5crB8ED1	\N	sonati	\N	\N
M8xIQtXPwx	2024-02-15 23:25:52.15+00	2024-02-15 23:25:52.15+00	Morgh-e Torsh	189000	oABNR2FF6S	\N	irani	\N	\N
GWQSjgt7Dy	2024-02-15 23:25:52.343+00	2024-02-15 23:25:52.343+00	Sirabi	964000	bi1IivsuUB	\N	irani	\N	\N
QGB21KetXb	2024-02-15 23:25:52.543+00	2024-02-15 23:25:52.543+00	Salad Shirazi	573000	fxvABtKCPT	\N	sonati	\N	\N
7aQzmRwpGh	2024-02-15 23:25:52.745+00	2024-02-15 23:25:52.745+00	Khoresh-e Baamieh	428000	mMYg4cyd5R	\N	sonati	\N	\N
Bv7Ff7CGVf	2024-02-15 23:25:52.944+00	2024-02-15 23:25:52.944+00	Tahdig	611000	HLIPwAqO2R	\N	sonati	\N	\N
hWjSGbRl1u	2024-02-15 23:25:53.149+00	2024-02-15 23:25:53.149+00	Mirza Ghasemi	626000	uigc7bJBOJ	\N	sonati	\N	\N
ISColj7vDJ	2024-02-15 23:25:53.349+00	2024-02-15 23:25:53.349+00	Khoresht-e Alu Esfenaj	217000	XwszrNEEEj	\N	irani	\N	\N
GzkFEuhzz6	2024-02-15 23:25:53.547+00	2024-02-15 23:25:53.547+00	Sholeh Zard	599000	fwLPZZ8YQa	\N	sonati	\N	\N
Bw01dWIV01	2024-02-15 23:25:53.745+00	2024-02-15 23:25:53.745+00	Khoresh-e Sabzi	553000	LgJuu5ABe5	\N	irani	\N	\N
e4NkU0sjkC	2024-02-15 23:25:53.945+00	2024-02-15 23:25:53.945+00	Khoresht-e Gheymeh Nesar	314000	XwWwGnkXNj	\N	sonati	\N	\N
5aZEIewoa2	2024-02-15 23:25:54.143+00	2024-02-15 23:25:54.143+00	Naz Khatoon	875000	m8hjjLVdPS	\N	sonati	\N	\N
Zl95bO7GLW	2024-02-15 23:25:54.341+00	2024-02-15 23:25:54.341+00	Khagineh Gorgan	108000	o90lhsZ7FK	\N	sonati	\N	\N
FJIxUQoC8i	2024-02-15 23:25:54.541+00	2024-02-15 23:25:54.541+00	Khoresh-e Mast	664000	vwHi602n66	\N	sonati	\N	\N
rKBCslrT36	2024-02-15 23:25:54.738+00	2024-02-15 23:25:54.738+00	Nan-e Barbari	66000	ThMuD3hYRQ	\N	irani	\N	\N
BatJDZ5zd2	2024-02-15 23:25:54.935+00	2024-02-15 23:25:54.935+00	Kuku	410000	P9sBFomftT	\N	irani	\N	\N
iXT6UXgLQg	2024-02-15 23:25:55.133+00	2024-02-15 23:25:55.133+00	Khoresht-e Gheymeh Nesar	862000	VK3vnSxIy8	\N	sonati	\N	\N
86Qw8S0Msi	2024-02-15 23:25:55.328+00	2024-02-15 23:25:55.328+00	Khoresh-e Havij ba Morgh	619000	uABtFsJhJc	\N	sonati	\N	\N
kooAfPGiit	2024-02-15 23:25:55.526+00	2024-02-15 23:25:55.526+00	Khoresh-e Haleem	320000	8w7i8C3NnT	\N	sonati	\N	\N
zFBj2dnLW8	2024-02-15 23:25:55.78+00	2024-02-15 23:25:55.78+00	Sholeh Zard	447000	8w7i8C3NnT	\N	irani	\N	\N
eWrLouogve	2024-02-15 23:25:55.979+00	2024-02-15 23:25:55.979+00	Sholeh Zard	943000	WBFeKac0OO	\N	sonati	\N	\N
GNAx5XStQt	2024-02-15 23:25:56.181+00	2024-02-15 23:25:56.181+00	Khoresh-e Havij	508000	m6g8u0QpTC	\N	irani	\N	\N
CPz9mOPXPD	2024-02-15 23:25:56.378+00	2024-02-15 23:25:56.378+00	Khoresht-e Gheymeh	391000	jjVdtithcD	\N	sonati	\N	\N
SlhnB6EE2d	2024-02-15 23:25:56.573+00	2024-02-15 23:25:56.573+00	Faloodeh	134000	Gl96vGdYHM	\N	irani	\N	\N
cd0K5lZt5W	2024-02-15 23:25:56.774+00	2024-02-15 23:25:56.774+00	Aloo Mosamma	289000	LVYK4mLShP	\N	sonati	\N	\N
fq6LLABdTH	2024-02-15 23:25:56.968+00	2024-02-15 23:25:56.968+00	Khagineh Yazdi	956000	ThMuD3hYRQ	\N	sonati	\N	\N
HYTNop8SmC	2024-02-15 23:25:57.314+00	2024-02-15 23:25:57.314+00	Morasa Polo	335000	oABNR2FF6S	\N	sonati	\N	\N
7yTEye5PLH	2024-02-15 23:25:57.509+00	2024-02-15 23:25:57.509+00	Baghali Polo ba Goosht	221000	o90lhsZ7FK	\N	irani	\N	\N
ZgNCHmgdrF	2024-02-15 23:25:57.709+00	2024-02-15 23:25:57.709+00	Shirin Adas	357000	WnUBBkiDjE	\N	sonati	\N	\N
iOqj4oCnad	2024-02-15 23:25:57.906+00	2024-02-15 23:25:57.906+00	Khoresh-e Mast	982000	tCIEnLLcUc	\N	irani	\N	\N
SW9nyjECrF	2024-02-15 23:25:58.11+00	2024-02-15 23:25:58.11+00	Nan-e Barbari	117000	9GF3y7LmHV	\N	sonati	\N	\N
V5YiVGoFAm	2024-02-15 23:25:58.31+00	2024-02-15 23:25:58.31+00	Khoresh-e Havij	335000	PF8w2gMAdi	\N	irani	\N	\N
UnPEHH6V0B	2024-02-15 23:25:58.505+00	2024-02-15 23:25:58.505+00	Khagineh Yazdi	815000	H40ivltLwZ	\N	irani	\N	\N
tJHCWqJIh6	2024-02-15 23:25:58.699+00	2024-02-15 23:25:58.699+00	Khoresh-e Anar	548000	UDXF0qXvDY	\N	irani	\N	\N
9FXdhNkQjs	2024-02-15 23:25:58.899+00	2024-02-15 23:25:58.899+00	Khoresh-e Havij	950000	jjVdtithcD	\N	irani	\N	\N
fW2ngfBWfn	2024-02-15 23:25:59.099+00	2024-02-15 23:25:59.099+00	Tahdig	690000	C7II8dYRPY	\N	sonati	\N	\N
PnsYMHGJv6	2024-02-15 23:25:59.297+00	2024-02-15 23:25:59.297+00	Torshe Tareh	275000	qEQ9tmLyW9	\N	sonati	\N	\N
MXBkzRkfxF	2024-02-15 23:25:59.494+00	2024-02-15 23:25:59.494+00	Khoresh-e Gandom	587000	mMYg4cyd5R	\N	irani	\N	\N
tmdTQ7URPG	2024-02-15 23:25:59.693+00	2024-02-15 23:25:59.693+00	Kalam Polo	778000	LgJuu5ABe5	\N	irani	\N	\N
OEBQCH86y0	2024-02-15 23:25:59.886+00	2024-02-15 23:25:59.886+00	Khoresh-e Fesenjan	747000	HSEugQ3Ouj	\N	sonati	\N	\N
jr151bPis5	2024-02-15 23:26:00.082+00	2024-02-15 23:26:00.082+00	Khoresh-e Baamieh	559000	D0A6GLdsDM	\N	sonati	\N	\N
13eQlMS0VR	2024-02-15 23:26:00.277+00	2024-02-15 23:26:00.277+00	Tachin Morgh	21000	jHqCpA1nWb	\N	sonati	\N	\N
QsHxwogehk	2024-02-15 23:26:00.474+00	2024-02-15 23:26:00.474+00	Kabab Koobideh	281000	u5FXeeOChJ	\N	sonati	\N	\N
DOi80EyvDS	2024-02-15 23:26:00.671+00	2024-02-15 23:26:00.671+00	Tachin Morgh	351000	cTIjuPjyIa	\N	irani	\N	\N
GVmwlxDzCo	2024-02-15 23:26:00.865+00	2024-02-15 23:26:00.865+00	Tahchin	577000	cmxBcanww9	\N	irani	\N	\N
ITXTKCLqpf	2024-02-15 23:26:01.105+00	2024-02-15 23:26:01.105+00	Aloo Mosamma	114000	LVYK4mLShP	\N	sonati	\N	\N
SjwjxdElUA	2024-02-15 23:26:01.3+00	2024-02-15 23:26:01.3+00	Khoresh-e Karafs	739000	RBRcyltRSC	\N	irani	\N	\N
SqYG0q3fPl	2024-02-15 23:26:01.5+00	2024-02-15 23:26:01.5+00	Shirin Polo	828000	XwszrNEEEj	\N	sonati	\N	\N
LRlRoH6HL3	2024-02-15 23:26:01.693+00	2024-02-15 23:26:01.693+00	Morasa Polo	842000	RkhjIQJgou	\N	irani	\N	\N
zz1d7HyjwL	2024-02-15 23:26:01.887+00	2024-02-15 23:26:01.887+00	Khoresh-e Karafs-e Holu	817000	HXtEwLBC7f	\N	sonati	\N	\N
YaffXmrRTR	2024-02-15 23:26:02.083+00	2024-02-15 23:26:02.083+00	Dizi	216000	Gl96vGdYHM	\N	sonati	\N	\N
at6nFAHpje	2024-02-15 23:26:02.28+00	2024-02-15 23:26:02.28+00	Moraba-ye Beh	665000	Oahm9sOn1y	\N	irani	\N	\N
R2OG9KA5kx	2024-02-15 23:26:02.476+00	2024-02-15 23:26:02.476+00	Sheer Khurma	727000	o4VD4BWwDt	\N	sonati	\N	\N
e5NLDj9vRV	2024-02-15 23:26:02.67+00	2024-02-15 23:26:02.67+00	Khoresh-e Baamieh	974000	LVYK4mLShP	\N	irani	\N	\N
D2cH5CQVTU	2024-02-15 23:26:02.864+00	2024-02-15 23:26:02.864+00	Faloodeh	188000	fKTSJPdUi9	\N	irani	\N	\N
5JcdPqfVsp	2024-02-15 23:26:03.062+00	2024-02-15 23:26:03.062+00	Mast-o-Khiar	430000	6Fo67rhTSP	\N	irani	\N	\N
gK411P5IUS	2024-02-15 23:26:03.258+00	2024-02-15 23:26:03.258+00	Baghali Polo ba Goosht	727000	u5FXeeOChJ	\N	sonati	\N	\N
yGGpMxDjXU	2024-02-15 23:26:03.454+00	2024-02-15 23:26:03.454+00	Khoresh-e Havij	902000	cmxBcanww9	\N	sonati	\N	\N
W2srvtHYJz	2024-02-15 23:26:03.651+00	2024-02-15 23:26:03.651+00	Tahdig	162000	qP3EdIVzfB	\N	irani	\N	\N
7pJbCB6rha	2024-02-15 23:26:03.85+00	2024-02-15 23:26:03.85+00	Khoresh-e Loobia Sabz	417000	l1Bslv8T2k	\N	sonati	\N	\N
xsHaUNZ2hc	2024-02-15 23:26:04.048+00	2024-02-15 23:26:04.048+00	Salad Shirazi	544000	o90lhsZ7FK	\N	sonati	\N	\N
vMXBhIC7jY	2024-02-15 23:26:04.245+00	2024-02-15 23:26:04.245+00	Moraba-ye Anar Daneh	390000	3u4B9V4l5K	\N	sonati	\N	\N
yT99dkyYvI	2024-02-15 23:26:04.448+00	2024-02-15 23:26:04.448+00	Abgoosht	129000	WBFeKac0OO	\N	irani	\N	\N
q5wspZQdSn	2024-02-15 23:26:04.646+00	2024-02-15 23:26:04.646+00	Kabab Koobideh	265000	3u4B9V4l5K	\N	sonati	\N	\N
DmwByGrHnP	2024-02-15 23:26:04.842+00	2024-02-15 23:26:04.842+00	Mast-o-Khiar	123000	qZmnAnnPEb	\N	irani	\N	\N
sfR2EY8pyT	2024-02-15 23:26:05.04+00	2024-02-15 23:26:05.04+00	Halva Ardeh	815000	TZsdmscJ2B	\N	sonati	\N	\N
flPmoi42W0	2024-02-15 23:26:05.235+00	2024-02-15 23:26:05.235+00	Yatimcheh	695000	XpUyRlB6FI	\N	sonati	\N	\N
hWi7RLrdRb	2024-02-15 23:26:05.432+00	2024-02-15 23:26:05.432+00	Nan-e Barbari	902000	HXtEwLBC7f	\N	sonati	\N	\N
Hh4poLGVSA	2024-02-15 23:26:05.628+00	2024-02-15 23:26:05.628+00	Khoresh-e Havij	704000	WBFeKac0OO	\N	sonati	\N	\N
H8bIYaXAhQ	2024-02-15 23:26:05.827+00	2024-02-15 23:26:05.827+00	Khoresh-e Karafs-e Holu	367000	89xRG1afNi	\N	sonati	\N	\N
0KcP0acCjl	2024-02-15 23:26:06.022+00	2024-02-15 23:26:06.022+00	Tahdig	746000	na5crB8ED1	\N	irani	\N	\N
3a1sO891Af	2024-02-15 23:26:06.219+00	2024-02-15 23:26:06.219+00	Khoresht-e Torsh	793000	rT0UCBK1bE	\N	sonati	\N	\N
dAyumZjJ10	2024-02-15 23:26:06.425+00	2024-02-15 23:26:06.425+00	Khoresh-e Anar	277000	TZsdmscJ2B	\N	sonati	\N	\N
mvUjX3aAFq	2024-02-15 23:26:06.622+00	2024-02-15 23:26:06.622+00	Yatimcheh	83000	bi1IivsuUB	\N	sonati	\N	\N
PeMRTzR4SK	2024-02-15 23:26:06.825+00	2024-02-15 23:26:06.825+00	Khoresht-e Gheymeh Nesar	605000	FYXEfIO1zF	\N	irani	\N	\N
AbhAkXT6rk	2024-02-15 23:26:07.024+00	2024-02-15 23:26:07.024+00	Moraba-ye Anar	307000	WnUBBkiDjE	\N	irani	\N	\N
74jmw6kiWU	2024-02-15 23:26:07.219+00	2024-02-15 23:26:07.219+00	Shirin Yazdi	573000	HXtEwLBC7f	\N	irani	\N	\N
V3wtfzpmui	2024-02-15 23:26:07.418+00	2024-02-15 23:26:07.418+00	Khagineh Birjand	282000	3u4B9V4l5K	\N	sonati	\N	\N
2ZBvRRRHLT	2024-02-15 23:26:07.613+00	2024-02-15 23:26:07.613+00	Khoresh-e Havij	691000	fxvABtKCPT	\N	irani	\N	\N
YddHnM1RvW	2024-02-15 23:26:07.807+00	2024-02-15 23:26:07.807+00	Faloodeh	731000	Oahm9sOn1y	\N	sonati	\N	\N
sG6v1AQB66	2024-02-15 23:26:08.009+00	2024-02-15 23:26:08.009+00	Khoresh-e Beh	643000	y4RkaDbkec	\N	sonati	\N	\N
JfEz6d1WIf	2024-02-15 23:26:08.203+00	2024-02-15 23:26:08.203+00	Khoresh-e Beh	776000	08liHW08uC	\N	sonati	\N	\N
iYaHVZzWpa	2024-02-15 23:26:08.402+00	2024-02-15 23:26:08.402+00	Khoresh-e Maast	903000	RBRcyltRSC	\N	irani	\N	\N
K64cGOaEBT	2024-02-15 23:26:08.602+00	2024-02-15 23:26:08.602+00	Fesenjan	245000	UCFo58JaaD	\N	sonati	\N	\N
0OxX0f7vjR	2024-02-15 23:26:08.798+00	2024-02-15 23:26:08.798+00	Adas Polo	575000	Pa0qBO2rzK	\N	irani	\N	\N
p58HLSEgWT	2024-02-15 23:26:08.996+00	2024-02-15 23:26:08.996+00	Khoresh-e Havij ba Morgh	228000	axyV0Fu7pm	\N	sonati	\N	\N
KcFjlPI7fh	2024-02-15 23:26:09.201+00	2024-02-15 23:26:09.201+00	Shirin Adas	369000	Pja6n3yaWZ	\N	irani	\N	\N
P0LBp95KFf	2024-02-15 23:26:09.4+00	2024-02-15 23:26:09.4+00	Samanu	704000	uigc7bJBOJ	\N	irani	\N	\N
2phuQSR1Jl	2024-02-15 23:26:09.599+00	2024-02-15 23:26:09.599+00	Samanu	184000	6Fo67rhTSP	\N	sonati	\N	\N
YnCIld8NmQ	2024-02-15 23:26:09.799+00	2024-02-15 23:26:09.799+00	Bastani Sonnati	703000	lxQA9rtSfY	\N	irani	\N	\N
wjejgGLnG8	2024-02-15 23:26:10.116+00	2024-02-15 23:26:10.116+00	Khoresh-e Maast	370000	PF8w2gMAdi	\N	sonati	\N	\N
DtDd77e7QB	2024-02-15 23:26:10.316+00	2024-02-15 23:26:10.316+00	Adas Polo	210000	axyV0Fu7pm	\N	irani	\N	\N
ZmlxN4bvdD	2024-02-15 23:26:10.508+00	2024-02-15 23:26:10.508+00	Khoresh-e Gandom	719000	08liHW08uC	\N	irani	\N	\N
BIDsf1f9mf	2024-02-15 23:26:10.718+00	2024-02-15 23:26:10.718+00	Joojeh Kabab	682000	D0A6GLdsDM	\N	sonati	\N	\N
ubqAZT5cNW	2024-02-15 23:26:10.917+00	2024-02-15 23:26:10.917+00	Khoresh-e Mast	79000	qP3EdIVzfB	\N	sonati	\N	\N
EhD3Dwy52k	2024-02-15 23:26:11.112+00	2024-02-15 23:26:11.112+00	Zereshk Polo	629000	vwHi602n66	\N	sonati	\N	\N
NbVjUi77nt	2024-02-15 23:26:11.308+00	2024-02-15 23:26:11.308+00	Sabzi Polo	157000	l1Bslv8T2k	\N	irani	\N	\N
nRD9R6H6sS	2024-02-15 23:26:11.505+00	2024-02-15 23:26:11.505+00	Moraba-ye Beh	35000	E2hBZzDsjO	\N	irani	\N	\N
MfYqWmage0	2024-02-15 23:26:11.751+00	2024-02-15 23:26:11.751+00	Ash-e Doogh	319000	vwHi602n66	\N	sonati	\N	\N
eEaHzG4llw	2024-02-15 23:26:11.946+00	2024-02-15 23:26:11.946+00	Lubia Polo	900000	RBRcyltRSC	\N	sonati	\N	\N
cyTBmM58iq	2024-02-15 23:26:12.142+00	2024-02-15 23:26:12.142+00	Halva Ardeh	471000	XwszrNEEEj	\N	sonati	\N	\N
FTYGGSiU3n	2024-02-15 23:26:12.336+00	2024-02-15 23:26:12.336+00	Tahdig	480000	89xRG1afNi	\N	irani	\N	\N
433j8hXDi8	2024-02-15 23:26:12.532+00	2024-02-15 23:26:12.532+00	Khoresht-e Gheimeh Sibzamini	764000	oABNR2FF6S	\N	sonati	\N	\N
wp36BFXDBB	2024-02-15 23:26:12.728+00	2024-02-15 23:26:12.728+00	Khoresh-e Beh	909000	yvUod6yLDt	\N	irani	\N	\N
MtRTWFhTRK	2024-02-15 23:26:12.927+00	2024-02-15 23:26:12.927+00	Khoresht-e Gheymeh Nesar	289000	lxQA9rtSfY	\N	irani	\N	\N
J1CofF0eDt	2024-02-15 23:26:13.126+00	2024-02-15 23:26:13.126+00	Khoresh-e Mast	113000	8w7i8C3NnT	\N	sonati	\N	\N
AbrA5P6l7o	2024-02-15 23:26:13.32+00	2024-02-15 23:26:13.32+00	Khoresh-e Kadoo	145000	AgU9OLJkqz	\N	sonati	\N	\N
voziYsHqGT	2024-02-15 23:26:13.516+00	2024-02-15 23:26:13.516+00	Dolma	240000	cmxBcanww9	\N	irani	\N	\N
LATdGLdjIs	2024-02-15 23:26:13.711+00	2024-02-15 23:26:13.711+00	Baghali Ghatogh	699000	INeptnSdJC	\N	irani	\N	\N
bdJRonaa3L	2024-02-15 23:26:13.909+00	2024-02-15 23:26:13.909+00	Mast-o-Khiar	551000	HLIPwAqO2R	\N	irani	\N	\N
gKB7jPHMH3	2024-02-15 23:26:14.11+00	2024-02-15 23:26:14.11+00	Naz Khatoon	604000	NY6RE1qgWu	\N	irani	\N	\N
SqWCVIBzjy	2024-02-15 23:26:14.311+00	2024-02-15 23:26:14.311+00	Khoresh-e Havij ba Morgh	784000	P9sBFomftT	\N	sonati	\N	\N
POPvnoYDYS	2024-02-15 23:26:14.508+00	2024-02-15 23:26:14.508+00	Khagineh Birjand	840000	0TvWuLoLF5	\N	sonati	\N	\N
8SQ7flvP6E	2024-02-15 23:26:14.721+00	2024-02-15 23:26:14.721+00	Khagineh Kashan	545000	6KvFK8yy1q	\N	sonati	\N	\N
YAGdzxPLBb	2024-02-15 23:26:14.917+00	2024-02-15 23:26:14.917+00	Khagineh Kashan	20000	e037qpAih3	\N	irani	\N	\N
r9x3AuMgjH	2024-02-15 23:26:15.115+00	2024-02-15 23:26:15.115+00	Dizi Sara	333000	WnUBBkiDjE	\N	irani	\N	\N
IrNm9L8q1R	2024-02-15 23:26:15.317+00	2024-02-15 23:26:15.317+00	Khoresh-e Kadoo	378000	o4VD4BWwDt	\N	irani	\N	\N
HSqW2fUwl2	2024-02-15 23:26:15.519+00	2024-02-15 23:26:15.519+00	Khoresht-e Bamieh	188000	G0uU7KQLEt	\N	irani	\N	\N
RB8XxqEHdb	2024-02-15 23:26:15.713+00	2024-02-15 23:26:15.713+00	Khoresh-e Loobia Sabz	599000	fxvABtKCPT	\N	irani	\N	\N
kw07f15vha	2024-02-15 23:26:15.912+00	2024-02-15 23:26:15.912+00	Sirabi	613000	NY6RE1qgWu	\N	sonati	\N	\N
IXGVzGiuUb	2024-02-15 23:26:16.109+00	2024-02-15 23:26:16.109+00	Khoresh-e Fesenjan	217000	HXtEwLBC7f	\N	sonati	\N	\N
IGG1HH8MZB	2024-02-15 23:26:16.303+00	2024-02-15 23:26:16.303+00	Zereshk Polo	338000	6Fo67rhTSP	\N	irani	\N	\N
qcQgKmYkHo	2024-02-15 23:26:16.5+00	2024-02-15 23:26:16.5+00	Mirza Ghasemi	202000	m8hjjLVdPS	\N	irani	\N	\N
tHFwhy7A0J	2024-02-15 23:26:16.695+00	2024-02-15 23:26:16.695+00	Ash-e Doogh	202000	LgJuu5ABe5	\N	irani	\N	\N
786xFH9yE1	2024-02-15 23:26:16.892+00	2024-02-15 23:26:16.892+00	Lubia Polo	97000	14jGmOAXcg	\N	irani	\N	\N
mGDaW2ujcW	2024-02-15 23:26:17.105+00	2024-02-15 23:26:17.105+00	Baghali Ghatogh	10000	E2hBZzDsjO	\N	sonati	\N	\N
jioOkkhIHb	2024-02-15 23:26:17.304+00	2024-02-15 23:26:17.304+00	Morasa Polo	536000	P9sBFomftT	\N	irani	\N	\N
L6sfZ7GJ88	2024-02-15 23:26:17.501+00	2024-02-15 23:26:17.501+00	Kuku	388000	P9sBFomftT	\N	sonati	\N	\N
c1kJKgAXH6	2024-02-15 23:26:17.702+00	2024-02-15 23:26:17.702+00	Khoresh-e Havij ba Morgh	245000	y4RkaDbkec	\N	irani	\N	\N
9H09H2sBMk	2024-02-15 23:26:17.9+00	2024-02-15 23:26:17.9+00	Khoresh-e Haleem	614000	9GF3y7LmHV	\N	irani	\N	\N
VDv8Mitvu3	2024-02-15 23:26:18.203+00	2024-02-15 23:26:18.203+00	Halva	34000	u5FXeeOChJ	\N	irani	\N	\N
swdfkSqrWU	2024-02-15 23:26:18.395+00	2024-02-15 23:26:18.395+00	Khoresht-e Bamieh	458000	fwLPZZ8YQa	\N	sonati	\N	\N
eK5mQuIsYY	2024-02-15 23:26:18.588+00	2024-02-15 23:26:18.588+00	Gheimeh	552000	XwszrNEEEj	\N	irani	\N	\N
GezwAVOmIk	2024-02-15 23:26:18.782+00	2024-02-15 23:26:18.782+00	Abgoosht	971000	LVYK4mLShP	\N	sonati	\N	\N
QerxvylAmX	2024-02-15 23:26:18.978+00	2024-02-15 23:26:18.978+00	Khoresht-e Bamieh	659000	eEmewy7hPd	\N	sonati	\N	\N
3EpXjv1RvE	2024-02-15 23:26:19.172+00	2024-02-15 23:26:19.172+00	Gheimeh	315000	9GF3y7LmHV	\N	sonati	\N	\N
sKyJEh0i3j	2024-02-15 23:26:19.369+00	2024-02-15 23:26:19.369+00	Khoresh-e Haleem	647000	LgJuu5ABe5	\N	irani	\N	\N
N4XRzZP25O	2024-02-15 23:26:19.562+00	2024-02-15 23:26:19.562+00	Khagineh	641000	ThMuD3hYRQ	\N	sonati	\N	\N
pGD9MKqjTB	2024-02-15 23:26:19.757+00	2024-02-15 23:26:19.757+00	Kookoo Sibzamini	635000	OQWu2bnHeC	\N	sonati	\N	\N
B4hbEwkJ19	2024-02-15 23:26:19.952+00	2024-02-15 23:26:19.952+00	Torshe Tareh	542000	6KvFK8yy1q	\N	irani	\N	\N
W4u56CqvbQ	2024-02-15 23:26:20.149+00	2024-02-15 23:26:20.149+00	Khoresh-e Kadoo	336000	uABtFsJhJc	\N	irani	\N	\N
nYtxHQ7D72	2024-02-15 23:26:20.345+00	2024-02-15 23:26:20.345+00	Mirza Ghasemi	211000	vwHi602n66	\N	irani	\N	\N
O6UOv7nwOz	2024-02-15 23:26:20.541+00	2024-02-15 23:26:20.541+00	Khoresh-e Karafs	21000	XSK814B37m	\N	sonati	\N	\N
qYCXyyiA3s	2024-02-15 23:26:20.737+00	2024-02-15 23:26:20.737+00	Yatimcheh	934000	ThMuD3hYRQ	\N	irani	\N	\N
JlfJ9JXZfH	2024-02-15 23:26:20.934+00	2024-02-15 23:26:20.934+00	Kookoo Sabzi	719000	C7II8dYRPY	\N	sonati	\N	\N
RKHJSLmBKB	2024-02-15 23:26:21.127+00	2024-02-15 23:26:21.127+00	Tachin Morgh	196000	mMYg4cyd5R	\N	irani	\N	\N
Hrwa42wLRq	2024-02-15 23:26:21.323+00	2024-02-15 23:26:21.323+00	Khoresh-e Kardeh	69000	OQWu2bnHeC	\N	irani	\N	\N
AOHL3zPYbm	2024-02-15 23:26:21.519+00	2024-02-15 23:26:21.519+00	Sholeh Zard	88000	Oahm9sOn1y	\N	irani	\N	\N
SYGTMOT5gX	2024-02-15 23:26:21.715+00	2024-02-15 23:26:21.715+00	Bastani Akbar Mashti	65000	PF8w2gMAdi	\N	irani	\N	\N
K0xQR80f2m	2024-02-15 23:26:21.913+00	2024-02-15 23:26:21.913+00	Dizi	816000	yvUod6yLDt	\N	sonati	\N	\N
8fSFQtCdyz	2024-02-15 23:26:22.113+00	2024-02-15 23:26:22.113+00	Kookoo Sabzi	983000	uigc7bJBOJ	\N	irani	\N	\N
m9NBSlTFCG	2024-02-15 23:26:22.361+00	2024-02-15 23:26:22.361+00	Khagineh Gorgan	12000	0TvWuLoLF5	\N	sonati	\N	\N
1ajlUkulI8	2024-02-15 23:26:22.555+00	2024-02-15 23:26:22.555+00	Khoresh-e Mast	214000	uABtFsJhJc	\N	irani	\N	\N
PGbo5OSwVD	2024-02-15 23:26:22.75+00	2024-02-15 23:26:22.75+00	Gheimeh	620000	o90lhsZ7FK	\N	irani	\N	\N
ds5cIqxqYE	2024-02-15 23:26:22.944+00	2024-02-15 23:26:22.944+00	Khoresh-e Baamieh	157000	6Fo67rhTSP	\N	sonati	\N	\N
7BCvMDVoRE	2024-02-15 23:26:23.14+00	2024-02-15 23:26:23.14+00	Halva Ardeh	659000	0TvWuLoLF5	\N	irani	\N	\N
7gGL6OA8Ul	2024-02-15 23:26:23.337+00	2024-02-15 23:26:23.337+00	Shirin Laboo	48000	C7II8dYRPY	\N	irani	\N	\N
KkWRh83M8B	2024-02-15 23:26:23.536+00	2024-02-15 23:26:23.536+00	Khoresh-e Maast	171000	HXtEwLBC7f	\N	irani	\N	\N
D38gzTxoZn	2024-02-15 23:26:23.734+00	2024-02-15 23:26:23.734+00	Khagineh	512000	o90lhsZ7FK	\N	irani	\N	\N
jASv8TNQGA	2024-02-15 23:26:23.93+00	2024-02-15 23:26:23.93+00	Khoresht-e Bamieh	451000	3P6kmNoY1F	\N	sonati	\N	\N
N21BEUDAyy	2024-02-15 23:26:24.129+00	2024-02-15 23:26:24.129+00	Khoresh-e Mast	855000	P9sBFomftT	\N	irani	\N	\N
L6mJdWMjko	2024-02-15 23:26:24.324+00	2024-02-15 23:26:24.324+00	Khoresht-e Gheymeh	880000	HLIPwAqO2R	\N	sonati	\N	\N
vAqdjE8OP0	2024-02-15 23:26:24.519+00	2024-02-15 23:26:24.519+00	Khoresh-e Kardeh	719000	G0uU7KQLEt	\N	irani	\N	\N
PAQQ6EFFeC	2024-02-15 23:26:24.72+00	2024-02-15 23:26:24.72+00	Baghali Ghatogh	661000	C7II8dYRPY	\N	sonati	\N	\N
vUNEtwlUqU	2024-02-15 23:26:24.919+00	2024-02-15 23:26:24.919+00	Abgoosht	886000	ThMuD3hYRQ	\N	sonati	\N	\N
Aws7m9E0U8	2024-02-15 23:26:25.166+00	2024-02-15 23:26:25.166+00	Ash-e Doogh	88000	rT0UCBK1bE	\N	sonati	\N	\N
k2ydIjwF0H	2024-02-15 23:26:25.362+00	2024-02-15 23:26:25.362+00	Shirin Yazdi	868000	WnUBBkiDjE	\N	irani	\N	\N
CBeL9otCWs	2024-02-15 23:26:25.558+00	2024-02-15 23:26:25.558+00	Abgoosht	268000	EmIUBFwx0Z	\N	sonati	\N	\N
XW0vRGyPEt	2024-02-15 23:26:25.754+00	2024-02-15 23:26:25.754+00	Dizi	597000	CSvk1ycWXk	\N	irani	\N	\N
pScDKtxGWc	2024-02-15 23:26:25.952+00	2024-02-15 23:26:25.952+00	Moraba-ye Gerdoo	757000	JZOBDAh12a	\N	sonati	\N	\N
BszjCS8t8l	2024-02-15 23:26:26.151+00	2024-02-15 23:26:26.151+00	Kufteh Tabrizi	432000	9GF3y7LmHV	\N	sonati	\N	\N
lbpHU8ofIp	2024-02-15 23:26:26.349+00	2024-02-15 23:26:26.349+00	Halva Shekari	954000	NBojpORh3G	\N	sonati	\N	\N
33hPHDJXln	2024-02-15 23:26:26.542+00	2024-02-15 23:26:26.542+00	Koloocheh	825000	3P6kmNoY1F	\N	sonati	\N	\N
th33Tzzot4	2024-02-15 23:26:26.745+00	2024-02-15 23:26:26.745+00	Khoresh-e Beh	377000	l1Bslv8T2k	\N	irani	\N	\N
aQtdpvqkZB	2024-02-15 23:26:26.95+00	2024-02-15 23:26:26.95+00	Tahchin	327000	UCFo58JaaD	\N	irani	\N	\N
ElLdEH8cM6	2024-02-15 23:26:27.152+00	2024-02-15 23:26:27.152+00	Khoresh-e Gerdoo	391000	WSTLlXDcKl	\N	irani	\N	\N
3dMqCXixzD	2024-02-15 23:26:27.352+00	2024-02-15 23:26:27.352+00	Khoresht-e Torsh	872000	6KvFK8yy1q	\N	sonati	\N	\N
rI64AIbNJV	2024-02-15 23:26:27.55+00	2024-02-15 23:26:27.55+00	Kufteh Tabrizi	965000	oABNR2FF6S	\N	sonati	\N	\N
9i35ATkxER	2024-02-15 23:26:27.759+00	2024-02-15 23:26:27.759+00	Sirabi	834000	WSTLlXDcKl	\N	sonati	\N	\N
EEpdOGxnEO	2024-02-15 23:26:27.957+00	2024-02-15 23:26:27.957+00	Ash-e Doogh	693000	3u4B9V4l5K	\N	irani	\N	\N
\.


--
-- Data for Name: Restaurant; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."Restaurant" ("objectId", "createdAt", "updatedAt", name, image, url, category_id, latitude, longitude, phone, facebook, instagram, whatsapp, email, web, city, district, street, avenue, postal_code, opening_time, closing_time, working_days, deliver, takeaway, serving, views_rate, is_verified, _rperm, _wperm, title, restaurant_id, file, geopoint) FROM stdin;
na5crB8ED1	2024-02-15 23:02:35.721+00	2024-02-15 23:02:35.721+00	Saffron Palace	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	nD1aOPUIAF	31.76293417493933	53.9077568930325	\N	Saffron Palace	Saffron Palace	Saffron Palace	Saffron Palace@gmail.com	www.Saffron Palace.com	Yazd	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	3.2221340080021244	t	\N	\N	\N	\N	\N	0101000020E61000008625BC6031F44A407B5D72A74FC33F40
E2hBZzDsjO	2024-02-15 23:02:32.265+00	2024-02-15 23:02:32.265+00	Persian Garden	\N	https://backend-webquality.liara.run/images/logo-qom.webp	nD1aOPUIAF	34.46807814786328	50.77993675643707	\N	Persian Garden	Persian Garden	Persian Garden	Persian Garden@gmail.com	www.Persian Garden.com	Qom	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	2.3093861226589474	t	\N	\N	\N	\N	\N	0101000020E61000003AECB6F7D4634940C48518FCE93B4140
WBFeKac0OO	2024-02-15 23:02:32.472+00	2024-02-15 23:02:32.472+00	Cozy Corner Cafe	\N	https://backend-webquality.liara.run/images/logo-qom.webp	lrNzJqVkzr	34.43320727357046	50.79615241089365	\N	Cozy Corner Cafe	Cozy Corner Cafe	Cozy Corner Cafe	Cozy Corner Cafe@gmail.com	www.Cozy Corner Cafe.com	Qom	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	7.896740422044715	t	\N	\N	\N	\N	\N	0101000020E6100000BBB57B52E8654940EE2F005673374140
9GF3y7LmHV	2024-02-15 23:02:32.676+00	2024-02-15 23:02:32.676+00	Rosewater Grill	\N	https://backend-webquality.liara.run/images/logo-qom.webp	zzCG0AtaNp	34.53924757444517	50.75699103333985	\N	Rosewater Grill	Rosewater Grill	Rosewater Grill	Rosewater Grill@gmail.com	www.Rosewater Grill.com	Qom	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	0.5425914183255975	t	\N	\N	\N	\N	\N	0101000020E6100000ABC70915E56049403C58841006454140
NY6RE1qgWu	2024-02-15 23:02:32.88+00	2024-02-15 23:02:32.88+00	Fanoos Restaurant	\N	https://backend-webquality.liara.run/images/logo-qom.webp	lrNzJqVkzr	34.50927173977802	50.79550697766326	\N	Fanoos Restaurant	Fanoos Restaurant	Fanoos Restaurant	Fanoos Restaurant@gmail.com	www.Fanoos Restaurant.com	Qom	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	0.1390112707104052	t	\N	\N	\N	\N	\N	0101000020E6100000D966322CD3654940D38FFDD02F414140
fKTSJPdUi9	2024-02-15 23:02:33.088+00	2024-02-15 23:02:33.088+00	Persian Star	\N	https://backend-webquality.liara.run/images/logo-qom.webp	lrNzJqVkzr	34.58384134859175	50.74569349487701	\N	Persian Star	Persian Star	Persian Star	Persian Star@gmail.com	www.Persian Star.com	Qom	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	8.16586551476072	t	\N	\N	\N	\N	\N	0101000020E610000019AB6AE2725F494086203550BB4A4140
WnUBBkiDjE	2024-02-15 23:02:33.354+00	2024-02-15 23:02:33.354+00	Persian Garden	\N	https://backend-webquality.liara.run/images/logo-qom.webp	lrNzJqVkzr	34.53309403806666	50.86032454281832	\N	Persian Garden	Persian Garden	Persian Garden	Persian Garden@gmail.com	www.Persian Garden.com	Qom	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	0.26812354303839214	t	\N	\N	\N	\N	\N	0101000020E6100000E8AC571D1F6E49402D98E96C3C444140
lEPdiO1EDi	2024-02-15 23:02:33.559+00	2024-02-15 23:02:33.559+00	Kabab Koobideh	\N	https://backend-webquality.liara.run/images/logo-qom.webp	nD1aOPUIAF	34.562485583995205	50.86299522160708	\N	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh@gmail.com	www.Kabab Koobideh.com	Qom	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	4.237314201312858	t	\N	\N	\N	\N	\N	0101000020E61000000EB49EA0766E49408DDD1187FF474140
HSEugQ3Ouj	2024-02-15 23:02:33.767+00	2024-02-15 23:02:33.767+00	Kabab Tabei	\N	https://backend-webquality.liara.run/images/logo-qom.webp	csFI7CCFvJ	34.550460339418095	50.84095974196774	\N	Kabab Tabei	Kabab Tabei	Kabab Tabei	Kabab Tabei@gmail.com	www.Kabab Tabei.com	Qom	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	0.6815064858386077	t	\N	\N	\N	\N	\N	0101000020E610000084809E91A46B4940DCC5017C75464140
wkI20hVv46	2024-02-15 23:02:16.201+00	2024-02-15 23:02:16.201+00	Kabab Tabei	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.616235581044506	51.632063724342885	\N	Kabab Tabei	Kabab Tabei	Kabab Tabei	Kabab Tabei@gmail.com	www.Kabab Tabei.com	Isfahan	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	1.4762768262212278	t	\N	\N	\N	\N	\N	0101000020E61000003485D076E7D04940DE9BB9CEE04E4040
axyV0Fu7pm	2024-02-15 23:02:35.931+00	2024-02-15 23:02:35.931+00	Kebab Khazana	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	zzCG0AtaNp	31.793493717446797	53.97081824536044	\N	Kebab Khazana	Kebab Khazana	Kebab Khazana	Kebab Khazana@gmail.com	www.Kebab Khazana.com	Yazd	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	4.942216485488721	t	\N	\N	\N	\N	\N	0101000020E61000007317B3C543FC4A40F5037E6722CB3F40
3u4B9V4l5K	2024-02-15 23:02:36.222+00	2024-02-15 23:02:36.222+00	Savory Spice	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	csFI7CCFvJ	31.726578041528917	54.04516625155826	\N	Savory Spice	Savory Spice	Savory Spice	Savory Spice@gmail.com	www.Savory Spice.com	Yazd	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	4.797462654535874	t	\N	\N	\N	\N	\N	0101000020E6100000AEA9FA01C8054B40C25BBE0401BA3F40
C7II8dYRPY	2024-02-15 23:02:26.148+00	2024-02-15 23:02:26.148+00	Iranian Kitchen	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.6513394778152	52.59543143360603	\N	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen@gmail.com	www.Iranian Kitchen.com	Shiraz	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	2.478519073027756	t	\N	\N	\N	\N	\N	0101000020E6100000952CE318374C4A405CCF1B2FBEA63D40
CSvk1ycWXk	2024-02-15 23:02:26.36+00	2024-02-15 23:02:26.36+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.604758061100934	52.60609973299057	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Shiraz	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	7.560344280842046	t	\N	\N	\N	\N	\N	0101000020E610000088A711AD944D4A40BF6B9E6CD19A3D40
6Fo67rhTSP	2024-02-15 23:02:26.57+00	2024-02-15 23:02:26.57+00	Kabab Barg	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.585501183933598	52.58530002538643	\N	Kabab Barg	Kabab Barg	Kabab Barg	Kabab Barg@gmail.com	www.Kabab Barg.com	Shiraz	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	1.911498947829755	t	\N	\N	\N	\N	\N	0101000020E6100000FCB0791CEB4A4A409BC3D467E3953D40
qEQ9tmLyW9	2024-02-15 23:02:30.19+00	2024-02-15 23:02:30.19+00	Shandiz Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	zzCG0AtaNp	36.49691713658599	53.13115990333675	\N	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant@gmail.com	www.Shandiz Restaurant.com	Sari	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	9.066146953021615	t	\N	\N	\N	\N	\N	0101000020E61000005EB003D9C9904A40BA3A11FB9A3F4240
14jGmOAXcg	2024-02-15 23:02:30.395+00	2024-02-15 23:02:30.395+00	Kabab Tabei	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.55375356321284	53.0504900124491	\N	Kabab Tabei	Kabab Tabei	Kabab Tabei	Kabab Tabei@gmail.com	www.Kabab Tabei.com	Sari	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	5.565754240407015	t	\N	\N	\N	\N	\N	0101000020E61000002C1FEC7476864A4074059265E1464240
EmIUBFwx0Z	2024-02-15 23:02:30.599+00	2024-02-15 23:02:30.599+00	Persian Flavor	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.49708137555983	53.12738869559291	\N	Persian Flavor	Persian Flavor	Persian Flavor	Persian Flavor@gmail.com	www.Persian Flavor.com	Sari	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	5.713793796074134	t	\N	\N	\N	\N	\N	0101000020E6100000D0B9D4454E904A4076BDCD5CA03F4240
LDrIH1vU8x	2024-02-15 23:02:30.804+00	2024-02-15 23:02:30.804+00	Saffron Hill	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	zzCG0AtaNp	36.550154232632394	53.04475749185612	\N	Saffron Hill	Saffron Hill	Saffron Hill	Saffron Hill@gmail.com	www.Saffron Hill.com	Sari	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	8.646508009713639	t	\N	\N	\N	\N	\N	0101000020E6100000F2E20D9DBA854A40C07432746B464240
VK3vnSxIy8	2024-02-15 23:02:31.01+00	2024-02-15 23:02:31.01+00	Darya Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	zzCG0AtaNp	36.58742808234427	53.08811756564563	\N	Darya Restaurant	Darya Restaurant	Darya Restaurant	Darya Restaurant@gmail.com	www.Darya Restaurant.com	Sari	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	2.8213730653288316	t	\N	\N	\N	\N	\N	0101000020E61000005853B76F478B4A40D735E9D7304B4240
fwLPZZ8YQa	2024-02-15 23:02:31.215+00	2024-02-15 23:02:31.215+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	zzCG0AtaNp	36.55290673839535	53.12563222922737	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	3.4856671534504713	t	\N	\N	\N	\N	\N	0101000020E610000075ED85B714904A40B292E3A5C5464240
mMYg4cyd5R	2024-02-15 23:02:31.419+00	2024-02-15 23:02:31.419+00	Yas Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.47941886594289	53.08102957117726	\N	Yas Restaurant	Yas Restaurant	Yas Restaurant	Yas Restaurant@gmail.com	www.Yas Restaurant.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	8.521171553047154	t	\N	\N	\N	\N	\N	0101000020E61000008D1B4F2D5F8A4A40B227EF985D3D4240
UDXF0qXvDY	2024-02-15 23:02:31.63+00	2024-02-15 23:02:31.63+00	Behesht Grill	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	csFI7CCFvJ	36.57174588664034	53.019786353481805	\N	Behesht Grill	Behesht Grill	Behesht Grill	Behesht Grill@gmail.com	www.Behesht Grill.com	Sari	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	3.634479752890243	t	\N	\N	\N	\N	\N	0101000020E6100000448EF65B88824A40145F1EF82E494240
UCFo58JaaD	2024-02-15 23:02:31.843+00	2024-02-15 23:02:31.843+00	Jooje Kabab	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.589963262037465	53.14440042460532	\N	Jooje Kabab	Jooje Kabab	Jooje Kabab	Jooje Kabab@gmail.com	www.Jooje Kabab.com	Sari	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	9.327752365044006	t	\N	\N	\N	\N	\N	0101000020E6100000AC9A8EB67B924A406D258AEA834B4240
cwVEh0dqfm	2024-02-15 23:02:32.059+00	2024-02-15 23:02:32.059+00	Koobideh King	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.57025252400282	53.000281716276454	\N	Koobideh King	Koobideh King	Koobideh King	Koobideh King@gmail.com	www.Koobideh King.com	Sari	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	6.4036834063532915	t	\N	\N	\N	\N	\N	0101000020E6100000D918353B09804A40DB86E208FE484240
08liHW08uC	2024-02-15 23:02:38.091+00	2024-02-15 23:02:38.091+00	The Spice Route	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.15466668989625	59.369380979003985	\N	The Spice Route	The Spice Route	The Spice Route	The Spice Route@gmail.com	www.The Spice Route.com	Mashhad	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	6.153949280435103	t	\N	\N	\N	\N	\N	0101000020E6100000154B3CE047AF4D4047713B1ECC134240
bQ0JOk10eL	2024-02-15 23:02:38.298+00	2024-02-15 23:02:38.298+00	Persian Garden	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.13033061314762	59.344867170063104	\N	Persian Garden	Persian Garden	Persian Garden	Persian Garden@gmail.com	www.Persian Garden.com	Mashhad	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	1.7410373880614127	t	\N	\N	\N	\N	\N	0101000020E61000004B71809B24AC4D407E916CACAE104240
WSTLlXDcKl	2024-02-15 23:02:38.497+00	2024-02-15 23:02:38.497+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.15369875785435	59.444699330730224	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Mashhad	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	8.658880580121016	t	\N	\N	\N	\N	\N	0101000020E61000000B055DE8EBB84D40CB35A166AC134240
cFtamPA0zH	2024-02-15 23:02:38.698+00	2024-02-15 23:02:38.698+00	Gol Koochik	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.213421756480706	59.494749229193104	\N	Gol Koochik	Gol Koochik	Gol Koochik	Gol Koochik@gmail.com	www.Gol Koochik.com	Mashhad	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	6.984436488939377	t	\N	\N	\N	\N	\N	0101000020E6100000848D57F153BF4D40752B7467511B4240
H40ivltLwZ	2024-02-15 23:02:38.904+00	2024-02-15 23:02:38.904+00	Caspian Seafood	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.15019477515736	59.34737512602641	\N	Caspian Seafood	Caspian Seafood	Caspian Seafood	Caspian Seafood@gmail.com	www.Caspian Seafood.com	Mashhad	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	8.033819234278512	t	\N	\N	\N	\N	\N	0101000020E610000018DDC2C976AC4D405CAA179539134240
vwHi602n66	2024-02-15 23:02:39.108+00	2024-02-15 23:02:39.108+00	Shirin Cafe	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.23381889610601	59.43574430450215	\N	Shirin Cafe	Shirin Cafe	Shirin Cafe	Shirin Cafe@gmail.com	www.Shirin Cafe.com	Mashhad	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	0.7275806334000068	t	\N	\N	\N	\N	\N	0101000020E6100000A4A02878C6B74D4027FB0FC7ED1D4240
y4RkaDbkec	2024-02-15 23:02:39.317+00	2024-02-15 23:02:39.317+00	Kababesh	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.209209704840326	59.338128725593506	\N	Kababesh	Kababesh	Kababesh	Kababesh@gmail.com	www.Kababesh.com	Mashhad	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	2.538661144234282	t	\N	\N	\N	\N	\N	0101000020E6100000922155CD47AB4D40C3253462C71A4240
rKyjwoEIRp	2024-02-15 23:02:36.431+00	2024-02-15 23:02:36.431+00	Chelo Kabab	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	lrNzJqVkzr	31.85455828787535	53.94327784854689	\N	Chelo Kabab	Chelo Kabab	Chelo Kabab	Chelo Kabab@gmail.com	www.Chelo Kabab.com	Yazd	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	6.291466593135684	t	\N	\N	\N	\N	\N	0101000020E61000006B461B54BDF84A404CF3FA54C4DA3F40
qFPgET1qWe	2024-02-15 23:02:17.492+00	2024-02-15 23:02:17.492+00	Rose Kabab	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	csFI7CCFvJ	32.6075580152942	51.754797465626176	\N	Rose Kabab	Rose Kabab	Rose Kabab	Rose Kabab@gmail.com	www.Rose Kabab.com	Isfahan	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	7.169264772245474	t	\N	\N	\N	\N	\N	0101000020E6100000EBFB0E349DE049403E0E0776C44D4040
jLOHByzRx2	2024-02-15 23:02:17.7+00	2024-02-15 23:02:17.7+00	Persian Pearl	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.67404017750378	51.7381643405413	\N	Persian Pearl	Persian Pearl	Persian Pearl	Persian Pearl@gmail.com	www.Persian Pearl.com	Isfahan	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	5.218148078355307	t	\N	\N	\N	\N	\N	0101000020E610000062D94A2B7CDE4940CD48D3F246564040
sRg50Os9o9	2024-02-15 23:02:17.901+00	2024-02-15 23:02:17.901+00	Crispy Crust Pizza	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.70126833031242	51.68059847797878	\N	Crispy Crust Pizza	Crispy Crust Pizza	Crispy Crust Pizza	Crispy Crust Pizza@gmail.com	www.Crispy Crust Pizza.com	Isfahan	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	9.448595272583649	t	\N	\N	\N	\N	\N	0101000020E61000002950D6D91DD74940C9342029C3594040
jSdR2GKV9u	2024-02-15 23:02:18.106+00	2024-02-15 23:02:18.106+00	Savory Spice	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.74309019638567	51.64501251920258	\N	Savory Spice	Savory Spice	Savory Spice	Savory Spice@gmail.com	www.Savory Spice.com	Isfahan	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	6.930413209140132	t	\N	\N	\N	\N	\N	0101000020E61000002ABE2DC58FD2494033BA5D941D5F4040
JahKddqA4M	2024-02-15 23:02:18.311+00	2024-02-15 23:02:18.311+00	Bam-e Tehran	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	nD1aOPUIAF	32.61131221802699	51.74294308671466	\N	Bam-e Tehran	Bam-e Tehran	Bam-e Tehran	Bam-e Tehran@gmail.com	www.Bam-e Tehran.com	Isfahan	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	3.7908134278004346	t	\N	\N	\N	\N	\N	0101000020E6100000481D52C218DF49401B09907A3F4E4040
icxsE8q9AL	2024-02-15 23:02:18.522+00	2024-02-15 23:02:18.522+00	Persian Plate	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.5805331710584	51.61714012626108	\N	Persian Plate	Persian Plate	Persian Plate	Persian Plate@gmail.com	www.Persian Plate.com	Isfahan	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	1.5883788721589687	t	\N	\N	\N	\N	\N	0101000020E61000009AAB9972FECE494031F833E94E4A4040
na4bTA6HOr	2024-02-15 23:02:18.721+00	2024-02-15 23:02:18.721+00	Café Paris	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.624559337159845	51.62416035479636	\N	Café Paris	Café Paris	Café Paris	Café Paris@gmail.com	www.Café Paris.com	Isfahan	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	1.892997800351366	t	\N	\N	\N	\N	\N	0101000020E6100000B2A78B7CE4CF4940A9C1738FF14F4040
QXyNidb9UE	2024-02-15 23:02:18.928+00	2024-02-15 23:02:18.928+00	Sushi Samurai	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	csFI7CCFvJ	32.734625300889824	51.724366679761644	\N	Sushi Samurai	Sushi Samurai	Sushi Samurai	Sushi Samurai@gmail.com	www.Sushi Samurai.com	Isfahan	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	1.697502516918159	t	\N	\N	\N	\N	\N	0101000020E6100000B6F11F0CB8DC49406711AD33085E4040
fOkcuKJwpu	2024-02-15 23:02:19.134+00	2024-02-15 23:02:19.134+00	Iranian Kitchen	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	nD1aOPUIAF	32.59376030915173	51.62556417288955	\N	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen@gmail.com	www.Iranian Kitchen.com	Isfahan	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	8.382751660263905	t	\N	\N	\N	\N	\N	0101000020E6100000110EA07C12D049401ABC7A56004C4040
j0dWqP2C2A	2024-02-15 23:02:39.526+00	2024-02-15 23:02:39.526+00	Tehran Kitchen	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.100472358479735	59.46961111067707	\N	Tehran Kitchen	Tehran Kitchen	Tehran Kitchen	Tehran Kitchen@gmail.com	www.Tehran Kitchen.com	Mashhad	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	9.95277930045245	t	\N	\N	\N	\N	\N	0101000020E61000001F1985371CBC4D4046E93A47DC0C4240
TCkiw6gTDz	2024-02-15 23:02:39.733+00	2024-02-15 23:02:39.733+00	Saffron Hill	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.22595731796521	59.469735992577625	\N	Saffron Hill	Saffron Hill	Saffron Hill	Saffron Hill@gmail.com	www.Saffron Hill.com	Mashhad	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	6.633326182361361	t	\N	\N	\N	\N	\N	0101000020E610000000F01A4F20BC4D40EA795D2BEC1C4240
cTIjuPjyIa	2024-02-15 23:02:39.938+00	2024-02-15 23:02:39.938+00	The Rusty Spoon	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.29251444095348	59.30055442741669	\N	The Rusty Spoon	The Rusty Spoon	The Rusty Spoon	The Rusty Spoon@gmail.com	www.The Rusty Spoon.com	Mashhad	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	1.9683158591587113	t	\N	\N	\N	\N	\N	0101000020E61000001B36469178A64D4060C0FA1C71254240
6KvFK8yy1q	2024-02-15 23:02:34.406+00	2024-02-15 23:02:34.406+00	Aladdin Restaurant	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	lrNzJqVkzr	31.742143340867404	54.043313836383966	\N	Aladdin Restaurant	Aladdin Restaurant	Aladdin Restaurant	Aladdin Restaurant@gmail.com	www.Aladdin Restaurant.com	Yazd	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	8.40028034608837	t	\N	\N	\N	\N	\N	0101000020E6100000E15DCB4E8B054B403DF8211BFDBD3F40
NJhHwfagz5	2024-02-15 23:02:19.334+00	2024-02-15 23:02:19.334+00	Shandiz Restaurant	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	csFI7CCFvJ	32.73142597060856	51.70334666018177	\N	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant@gmail.com	www.Shandiz Restaurant.com	Isfahan	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	5.8657635428506065	t	\N	\N	\N	\N	\N	0101000020E6100000A39D6B4307DA4940BB9ABF5D9F5D4040
pm2zaYlKvo	2024-02-15 23:02:19.538+00	2024-02-15 23:02:19.538+00	Chelo Kabab	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.58996685054088	51.66934761352252	\N	Chelo Kabab	Chelo Kabab	Chelo Kabab	Chelo Kabab@gmail.com	www.Chelo Kabab.com	Isfahan	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	9.581934687421342	t	\N	\N	\N	\N	\N	0101000020E610000010DEBE2EADD549400B66A408844B4040
YmchTuKOo3	2024-02-15 23:02:19.75+00	2024-02-15 23:02:19.75+00	Shabestan Kabab	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.58607919079388	51.628889085769536	\N	Shabestan Kabab	Shabestan Kabab	Shabestan Kabab	Shabestan Kabab@gmail.com	www.Shabestan Kabab.com	Isfahan	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	0.8143496279499152	t	\N	\N	\N	\N	\N	0101000020E6100000831804707FD04940B6A996A4044B4040
XQSKahk62I	2024-02-15 23:02:19.965+00	2024-02-15 23:02:19.965+00	Behrouz Restaurant	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.75118206325523	51.73365508885857	\N	Behrouz Restaurant	Behrouz Restaurant	Behrouz Restaurant	Behrouz Restaurant@gmail.com	www.Behrouz Restaurant.com	Isfahan	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	4.374392441230359	t	\N	\N	\N	\N	\N	0101000020E61000008498F268E8DD4940F282DDBB26604040
7cjorHy8Gk	2024-02-15 23:02:20.17+00	2024-02-15 23:02:20.17+00	Chelo Kabab	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.711762836951856	51.753937191642706	\N	Chelo Kabab	Chelo Kabab	Chelo Kabab	Chelo Kabab@gmail.com	www.Chelo Kabab.com	Isfahan	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	2.072164814356239	t	\N	\N	\N	\N	\N	0101000020E6100000F8AB8E0381E04940B39B6D0B1B5B4040
uKjiMkDt4h	2024-02-15 23:02:20.385+00	2024-02-15 23:02:20.385+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	nD1aOPUIAF	32.5636199144022	51.76146300506398	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Isfahan	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	8.980093938520406	t	\N	\N	\N	\N	\N	0101000020E61000008DEEA79E77E14940ABDD85B224484040
XwszrNEEEj	2024-02-15 23:02:34.616+00	2024-02-15 23:02:34.616+00	Yas Restaurant	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	zzCG0AtaNp	31.880133831839114	53.98713591975064	\N	Yas Restaurant	Yas Restaurant	Yas Restaurant	Yas Restaurant@gmail.com	www.Yas Restaurant.com	Yazd	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	5.053421797860835	t	\N	\N	\N	\N	\N	0101000020E6100000980446785AFE4A4027DA677350E13F40
XwWwGnkXNj	2024-02-15 23:02:34.818+00	2024-02-15 23:02:34.818+00	Gol Koochik	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	nD1aOPUIAF	31.768028250191634	53.92226645451057	\N	Gol Koochik	Gol Koochik	Gol Koochik	Gol Koochik@gmail.com	www.Gol Koochik.com	Yazd	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	2.0975707396501786	t	\N	\N	\N	\N	\N	0101000020E61000000F29C2D30CF64A4028FAD87F9DC43F40
jjVdtithcD	2024-02-15 23:02:35.024+00	2024-02-15 23:02:35.024+00	Yas Restaurant	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	zzCG0AtaNp	31.745158818539867	54.05341994457477	\N	Yas Restaurant	Yas Restaurant	Yas Restaurant	Yas Restaurant@gmail.com	www.Yas Restaurant.com	Yazd	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	9.643096094537473	t	\N	\N	\N	\N	\N	0101000020E61000008E73F976D6064B4069F473BAC2BE3F40
JLhF4VuByh	2024-02-15 23:02:35.226+00	2024-02-15 23:02:35.226+00	Mama Mia's Pizzeria	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	lrNzJqVkzr	31.7609152672192	53.96737370314989	\N	Mama Mia's Pizzeria	Mama Mia's Pizzeria	Mama Mia's Pizzeria	Mama Mia's Pizzeria@gmail.com	www.Mama Mia's Pizzeria.com	Yazd	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	0.36800396222064213	t	\N	\N	\N	\N	\N	0101000020E61000000405C9E6D2FB4A40CBBBCB57CBC23F40
bQpy9LEJWn	2024-02-15 23:02:35.51+00	2024-02-15 23:02:35.51+00	Café Paris	\N	https://backend-webquality.liara.run/images/logo-yazd.webp	csFI7CCFvJ	31.7299175313936	53.96963452007672	\N	Café Paris	Café Paris	Café Paris	Café Paris@gmail.com	www.Café Paris.com	Yazd	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	9.603318030122193	t	\N	\N	\N	\N	\N	0101000020E6100000AD66E4FB1CFC4A40D11C16E0DBBA3F40
WHvlAGgj6c	2024-02-15 23:02:33.98+00	2024-02-15 23:02:33.98+00	Caspian Seafood	\N	https://backend-webquality.liara.run/images/logo-qom.webp	nD1aOPUIAF	34.59589394764675	50.764478891461046	\N	Caspian Seafood	Caspian Seafood	Caspian Seafood	Caspian Seafood@gmail.com	www.Caspian Seafood.com	Qom	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	2.718195677419548	t	\N	\N	\N	\N	\N	0101000020E61000005DA7BE71DA6149407983BC40464C4140
yvUod6yLDt	2024-02-15 23:02:34.186+00	2024-02-15 23:02:34.186+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/logo-qom.webp	zzCG0AtaNp	34.443099167861625	50.75883827749033	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Qom	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	4.778722701094988	t	\N	\N	\N	\N	\N	0101000020E61000001063D89C21614940DD6C3979B7384140
OQWu2bnHeC	2024-02-15 23:02:05.209+00	2024-02-15 23:02:05.209+00	Crispy Crust Pizza	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.71955903914628	51.38796541021517	\N	Crispy Crust Pizza	Crispy Crust Pizza	Crispy Crust Pizza	Crispy Crust Pizza@gmail.com	www.Crispy Crust Pizza.com	Tehran	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	9.045511716534184	t	\N	\N	\N	\N	\N	0101000020E61000003C6DBED9A8B149405556B6821ADC4140
AgU9OLJkqz	2024-02-15 23:02:05.426+00	2024-02-15 23:02:05.426+00	Bella Italia	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.609925347111336	51.4203070138004	\N	Bella Italia	Bella Italia	Bella Italia	Bella Italia@gmail.com	www.Bella Italia.com	Tehran	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	0.6325428060261129	t	\N	\N	\N	\N	\N	0101000020E6100000AC46C79ECCB549401D6CA50812CE4140
uABtFsJhJc	2024-02-15 23:02:05.658+00	2024-02-15 23:02:05.658+00	Kebab Khazana	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.62825421450723	51.45358060624062	\N	Kebab Khazana	Kebab Khazana	Kebab Khazana	Kebab Khazana@gmail.com	www.Kebab Khazana.com	Tehran	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	5.591498058308828	t	\N	\N	\N	\N	\N	0101000020E6100000A0F3E6ED0EBA4940FD7054A26AD04140
eEmewy7hPd	2024-02-15 23:02:05.882+00	2024-02-15 23:02:05.882+00	Smoky BBQ Joint	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	csFI7CCFvJ	35.67223514360027	51.4378835658874	\N	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint@gmail.com	www.Smoky BBQ Joint.com	Tehran	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	4.213419365972335	t	\N	\N	\N	\N	\N	0101000020E61000009B7895910CB84940157E1ACD0BD64140
zWvgHKvAYk	2024-02-15 23:02:20.592+00	2024-02-15 23:02:20.592+00	Behesht Grill	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.57618541593656	51.62205136390046	\N	Behesht Grill	Behesht Grill	Behesht Grill	Behesht Grill@gmail.com	www.Behesht Grill.com	Isfahan	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	4.642345080457919	t	\N	\N	\N	\N	\N	0101000020E61000003D310C619FCF494099F09671C0494040
jIuSFQr5iG	2024-02-15 23:02:20.806+00	2024-02-15 23:02:20.806+00	The Hungry Hippo	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	nD1aOPUIAF	32.6887700402652	51.71650099502637	\N	The Hungry Hippo	The Hungry Hippo	The Hungry Hippo	The Hungry Hippo@gmail.com	www.The Hungry Hippo.com	Isfahan	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	4.405388332841964	t	\N	\N	\N	\N	\N	0101000020E61000004998FA4DB6DB4940AAB3DE9D29584040
5mZQfJ0xiY	2024-02-15 23:02:09.263+00	2024-02-15 23:02:09.263+00	Dizi Sara	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.601144178986466	51.45655093245549	\N	Dizi Sara	Dizi Sara	Dizi Sara	Dizi Sara@gmail.com	www.Dizi Sara.com	Tehran	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	2.7595876744495906	t	\N	\N	\N	\N	\N	0101000020E610000065EDCD4270BA4940BD76DE4AF2CC4140
BeeK5qqAEe	2024-02-15 23:02:06.092+00	2024-02-15 23:02:06.092+00	Joon Kabab	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.786864578604494	51.416378063446984	\N	Joon Kabab	Joon Kabab	Joon Kabab	Joon Kabab@gmail.com	www.Joon Kabab.com	Tehran	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	0.5221067814990188	t	\N	\N	\N	\N	\N	0101000020E610000068A35AE04BB549405ABE7FFAB7E44140
On2LYMb9A5	2024-02-15 23:02:06.304+00	2024-02-15 23:02:06.304+00	Kabab Barg	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.62192894920969	51.41982712924091	\N	Kabab Barg	Kabab Barg	Kabab Barg	Kabab Barg@gmail.com	www.Kabab Barg.com	Tehran	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	7.02304992447444	t	\N	\N	\N	\N	\N	0101000020E6100000190837E5BCB5494048A5285E9BCF4140
xn20jV5BL1	2024-02-15 23:02:06.519+00	2024-02-15 23:02:06.519+00	Ariana Restaurant	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	csFI7CCFvJ	35.69955100506385	51.294046205601916	\N	Ariana Restaurant	Ariana Restaurant	Ariana Restaurant	Ariana Restaurant@gmail.com	www.Ariana Restaurant.com	Tehran	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	7.002557906552955	t	\N	\N	\N	\N	\N	0101000020E61000005C495A4EA3A549400C5128E38AD94140
wCtAk7gvrq	2024-02-15 23:02:06.735+00	2024-02-15 23:02:06.735+00	Smoky BBQ Joint	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.68972357396185	51.46054516954746	\N	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint@gmail.com	www.Smoky BBQ Joint.com	Tehran	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	5.10288854997103	t	\N	\N	\N	\N	\N	0101000020E6100000C0C4E424F3BA494023B9B0DC48D84140
VRGbYiaz3t	2024-02-15 23:02:06.946+00	2024-02-15 23:02:06.946+00	Shahrzad Restaurant	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.596464856702305	51.36265281187524	\N	Shahrzad Restaurant	Shahrzad Restaurant	Shahrzad Restaurant	Shahrzad Restaurant@gmail.com	www.Shahrzad Restaurant.com	Tehran	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	2.960011691310449	t	\N	\N	\N	\N	\N	0101000020E61000003F6747686BAE4940F75FDEF558CC4140
RqOamyhEX6	2024-02-15 23:02:07.16+00	2024-02-15 23:02:07.16+00	Persian Oasis	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	csFI7CCFvJ	35.63805366068075	51.334052940854	\N	Persian Oasis	Persian Oasis	Persian Oasis	Persian Oasis@gmail.com	www.Persian Oasis.com	Tehran	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	1.6635912086735982	t	\N	\N	\N	\N	\N	0101000020E6100000DF0C2C3FC2AA4940C3DB0ABEABD14140
Ai4kGjRiEN	2024-02-15 23:02:07.376+00	2024-02-15 23:02:07.376+00	Jooje Kabab	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.6529589920241	51.35720617134508	\N	Jooje Kabab	Jooje Kabab	Jooje Kabab	Jooje Kabab@gmail.com	www.Jooje Kabab.com	Tehran	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	2.966347998194494	t	\N	\N	\N	\N	\N	0101000020E6100000A1ED8BEEB8AD4940B22F062994D34140
UH8hC8Yfr8	2024-02-15 23:02:07.587+00	2024-02-15 23:02:07.587+00	Persian Feast	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	zzCG0AtaNp	35.77235102064653	51.45538544699229	\N	Persian Feast	Persian Feast	Persian Feast	Persian Feast@gmail.com	www.Persian Feast.com	Tehran	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	4.372863177705877	t	\N	\N	\N	\N	\N	0101000020E6100000FFF300124ABA4940C35AF365DCE24140
67CwYf3eSk	2024-02-15 23:02:07.802+00	2024-02-15 23:02:07.802+00	Kebab Palace	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	zzCG0AtaNp	35.77733260496081	51.368872989003435	\N	Kebab Palace	Kebab Palace	Kebab Palace	Kebab Palace@gmail.com	www.Kebab Palace.com	Tehran	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	2.808908470106619	t	\N	\N	\N	\N	\N	0101000020E6100000E212E83A37AF4940E93582A27FE34140
TiK6WaZQJE	2024-02-15 23:02:08.015+00	2024-02-15 23:02:08.015+00	Persian Star	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.59812828206137	51.40767756502963	\N	Persian Star	Persian Star	Persian Star	Persian Star@gmail.com	www.Persian Star.com	Tehran	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	1.202311140442951	t	\N	\N	\N	\N	\N	0101000020E6100000BE8E48C72EB449401422B1778FCC4140
qe8ujGXHfL	2024-02-15 23:02:08.226+00	2024-02-15 23:02:08.226+00	Saraye Saadat	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	csFI7CCFvJ	35.787663819447026	51.32672031818795	\N	Saraye Saadat	Saraye Saadat	Saraye Saadat	Saraye Saadat@gmail.com	www.Saraye Saadat.com	Tehran	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	4.675717858260018	t	\N	\N	\N	\N	\N	0101000020E61000002AC7ACF8D1A949403B62042BD2E44140
x2m9xltoUG	2024-02-15 23:02:08.422+00	2024-02-15 23:02:08.422+00	Persian Grill	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	csFI7CCFvJ	35.726977289309175	51.34862246765608	\N	Persian Grill	Persian Grill	Persian Grill	Persian Grill@gmail.com	www.Persian Grill.com	Tehran	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	6.098349556598002	t	\N	\N	\N	\N	\N	0101000020E6100000E99D38A99FAC4940424281970DDD4140
mnjtyaC1fy	2024-02-15 23:02:08.627+00	2024-02-15 23:02:08.627+00	Behesht Grill	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	csFI7CCFvJ	35.61326264889859	51.39246219602389	\N	Behesht Grill	Behesht Grill	Behesht Grill	Behesht Grill@gmail.com	www.Behesht Grill.com	Tehran	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	9.146644821491591	t	\N	\N	\N	\N	\N	0101000020E6100000636B84333CB249405B70F6637FCE4140
hZjTwrIOEs	2024-02-15 23:02:08.841+00	2024-02-15 23:02:08.841+00	Taco Fiesta	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.71380028987335	51.30585577340286	\N	Taco Fiesta	Taco Fiesta	Taco Fiesta	Taco Fiesta@gmail.com	www.Taco Fiesta.com	Tehran	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	3.7596399745608533	t	\N	\N	\N	\N	\N	0101000020E61000006F07304826A74940D070D2CE5DDB4140
8CLw8InVaZ	2024-02-15 23:02:09.055+00	2024-02-15 23:02:09.055+00	Iranian Kitchen	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.71183973752263	51.438228316897245	\N	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen@gmail.com	www.Iranian Kitchen.com	Tehran	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	6.854299227510781	t	\N	\N	\N	\N	\N	0101000020E61000009DA090DD17B84940935384901DDB4140
OZodxadLMU	2024-02-15 23:02:09.473+00	2024-02-15 23:02:09.473+00	Kabab Bonanza	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	zzCG0AtaNp	35.63893590476814	51.34707233334975	\N	Kabab Bonanza	Kabab Bonanza	Kabab Bonanza	Kabab Bonanza@gmail.com	www.Kabab Bonanza.com	Tehran	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	8.751466188101269	t	\N	\N	\N	\N	\N	0101000020E6100000B38AC0DD6CAC4940139CD7A6C8D14140
2I0cDEL9rH	2024-02-15 23:02:09.692+00	2024-02-15 23:02:09.692+00	Behesht Grill	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.78859399652439	51.31132534919291	\N	Behesht Grill	Behesht Grill	Behesht Grill	Behesht Grill@gmail.com	www.Behesht Grill.com	Tehran	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	2.084773945585068	t	\N	\N	\N	\N	\N	0101000020E610000084995082D9A749407572E8A5F0E44140
5syeQbhrXS	2024-02-15 23:02:10.017+00	2024-02-15 23:02:10.017+00	Shirin Cafe	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.76822428909156	51.44263140300541	\N	Shirin Cafe	Shirin Cafe	Shirin Cafe	Shirin Cafe@gmail.com	www.Shirin Cafe.com	Tehran	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	2.9137146827696037	t	\N	\N	\N	\N	\N	0101000020E6100000A00B5425A8B8494010D26A2C55E24140
YQovFXDJYC	2024-02-15 23:02:21.013+00	2024-02-15 23:02:21.013+00	Parsian Delight	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.67899955157647	51.727787530842036	\N	Parsian Delight	Parsian Delight	Parsian Delight	Parsian Delight@gmail.com	www.Parsian Delight.com	Isfahan	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	7.875111308207428	t	\N	\N	\N	\N	\N	0101000020E61000009AB34D2428DD494082021275E9564040
V0zIR8Kn4d	2024-02-15 23:02:21.22+00	2024-02-15 23:02:21.22+00	Saraye Saadat	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	csFI7CCFvJ	32.733452286399704	51.64061691621623	\N	Saraye Saadat	Saraye Saadat	Saraye Saadat	Saraye Saadat@gmail.com	www.Saraye Saadat.com	Isfahan	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	1.9138401984409614	t	\N	\N	\N	\N	\N	0101000020E6100000E03430BCFFD14940AFA1B7C3E15D4040
9D2Nmfv7jd	2024-02-15 23:02:21.429+00	2024-02-15 23:02:21.429+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.597319762055875	51.598582402150655	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Isfahan	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	0.23438035086482234	t	\N	\N	\N	\N	\N	0101000020E61000005E9920599ECC49406AA455F9744C4040
WHwyQkc6WK	2024-02-15 23:02:21.642+00	2024-02-15 23:02:21.642+00	Parsian Delight	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.71326334454706	51.57070067673514	\N	Parsian Delight	Parsian Delight	Parsian Delight	Parsian Delight@gmail.com	www.Parsian Delight.com	Isfahan	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	5.642746611944	t	\N	\N	\N	\N	\N	0101000020E6100000F63043B80CC94940F22199364C5B4040
5KyVw2OgOs	2024-02-15 23:02:21.847+00	2024-02-15 23:02:21.847+00	Rosewater Grill	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.575035357256404	51.70266732347836	\N	Rosewater Grill	Rosewater Grill	Rosewater Grill	Rosewater Grill@gmail.com	www.Rosewater Grill.com	Isfahan	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	6.889710157934259	t	\N	\N	\N	\N	\N	0101000020E61000005927BB00F1D94940DFBA32C29A494040
G66rG83lgi	2024-02-15 23:02:22.498+00	2024-02-15 23:02:22.498+00	Persian Saffron	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.61640808025952	51.623914771567264	\N	Persian Saffron	Persian Saffron	Persian Saffron	Persian Saffron@gmail.com	www.Persian Saffron.com	Isfahan	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	4.551045987069548	t	\N	\N	\N	\N	\N	0101000020E6100000B5AF7170DCCF494036DAC075E64E4040
ClR0h6YIeG	2024-02-15 23:02:22.806+00	2024-02-15 23:02:22.806+00	Caspian Seafood	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.75013897036567	51.65148087503476	\N	Caspian Seafood	Caspian Seafood	Caspian Seafood	Caspian Seafood@gmail.com	www.Caspian Seafood.com	Isfahan	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	6.340667205033357	t	\N	\N	\N	\N	\N	0101000020E6100000331FAEB963D349407C96C48D04604040
MQfxuw3ERg	2024-02-15 23:02:26.787+00	2024-02-15 23:02:26.787+00	Cafe Nadia	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.672682297790253	52.5660880062326	\N	Cafe Nadia	Cafe Nadia	Cafe Nadia	Cafe Nadia@gmail.com	www.Cafe Nadia.com	Shiraz	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	4.629447989520592	t	\N	\N	\N	\N	\N	0101000020E6100000A3B6609275484A40769B35E834AC3D40
FJOTueDfs2	2024-02-15 23:02:27.001+00	2024-02-15 23:02:27.001+00	Dizi Sara	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.603908613943126	52.52426824440836	\N	Dizi Sara	Dizi Sara	Dizi Sara	Dizi Sara@gmail.com	www.Dizi Sara.com	Shiraz	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	0.9645312865621092	t	\N	\N	\N	\N	\N	0101000020E61000005A08CA381B434A408EA842C1999A3D40
bi1IivsuUB	2024-02-15 23:02:27.212+00	2024-02-15 23:02:27.212+00	Kebab Koobideh	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	nD1aOPUIAF	29.67042762240032	52.663964587394695	\N	Kebab Koobideh	Kebab Koobideh	Kebab Koobideh	Kebab Koobideh@gmail.com	www.Kebab Koobideh.com	Shiraz	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	5.342189820061504	t	\N	\N	\N	\N	\N	0101000020E6100000FB47A6CAFC544A405F8B0825A1AB3D40
HLIPwAqO2R	2024-02-15 23:02:27.418+00	2024-02-15 23:02:27.418+00	Shiraz Kabab	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	nD1aOPUIAF	29.536210021095194	52.554037858621186	\N	Shiraz Kabab	Shiraz Kabab	Shiraz Kabab	Shiraz Kabab@gmail.com	www.Shiraz Kabab.com	Shiraz	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	5.4404428284431265	t	\N	\N	\N	\N	\N	0101000020E61000000EC369B6EA464A402E64580F45893D40
Nc4HBGXDeG	2024-02-15 23:02:10.24+00	2024-02-15 23:02:10.24+00	Crispy Crust Pizza	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.664310883725925	51.31584938990754	\N	Crispy Crust Pizza	Crispy Crust Pizza	Crispy Crust Pizza	Crispy Crust Pizza@gmail.com	www.Crispy Crust Pizza.com	Tehran	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	2.3746883100371097	t	\N	\N	\N	\N	\N	0101000020E6100000A60EB8C06DA8494067FD972308D54140
by23hzjmp5	2024-02-15 23:02:10.525+00	2024-02-15 23:02:10.525+00	Saffron Lounge	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.67269215108692	51.38486658893452	\N	Saffron Lounge	Saffron Lounge	Saffron Lounge	Saffron Lounge@gmail.com	www.Saffron Lounge.com	Tehran	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	3.830384900616972	t	\N	\N	\N	\N	\N	0101000020E6100000FF65F24E43B14940DC98C2C61AD64140
3P6kmNoY1F	2024-02-15 23:02:27.63+00	2024-02-15 23:02:27.63+00	Shahrzad Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.66983779862319	52.62252166304409	\N	Shahrzad Restaurant	Shahrzad Restaurant	Shahrzad Restaurant	Shahrzad Restaurant@gmail.com	www.Shahrzad Restaurant.com	Shiraz	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	1.2048311419701085	t	\N	\N	\N	\N	\N	0101000020E6100000B7E933CAAE4F4A4013B66E7D7AAB3D40
G0uU7KQLEt	2024-02-15 23:02:27.837+00	2024-02-15 23:02:27.837+00	Yas Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.606331628731294	52.57974260113921	\N	Yas Restaurant	Yas Restaurant	Yas Restaurant	Yas Restaurant@gmail.com	www.Yas Restaurant.com	Shiraz	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	0.12363093363244815	t	\N	\N	\N	\N	\N	0101000020E6100000D5FE6B01354A4A406BEEB38C389B3D40
jHqCpA1nWb	2024-02-15 23:02:04.992+00	2024-02-15 23:02:04.992+00	Shirin Palace	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	csFI7CCFvJ	35.75608742712005	51.3488315477223	\N	Shirin Palace	Shirin Palace	Shirin Palace	Shirin Palace@gmail.com	www.Shirin Palace.com	Tehran	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	9.402640259472326	t	\N	\N	\N	\N	\N	0101000020E6100000E2A31C83A6AC4940DE320A79C7E04140
LVYK4mLShP	2024-02-15 23:02:28.056+00	2024-02-15 23:02:28.056+00	Parsian Delight	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.536312903056526	52.61424407381782	\N	Parsian Delight	Parsian Delight	Parsian Delight	Parsian Delight@gmail.com	www.Parsian Delight.com	Shiraz	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	8.373463933626255	t	\N	\N	\N	\N	\N	0101000020E61000009967C08C9F4E4A40F40C6BCD4B893D40
o90lhsZ7FK	2024-02-15 23:02:28.275+00	2024-02-15 23:02:28.275+00	Gol Koochik	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.678483098065097	52.60631129232671	\N	Gol Koochik	Gol Koochik	Gol Koochik	Gol Koochik@gmail.com	www.Gol Koochik.com	Shiraz	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	4.517742872606405	t	\N	\N	\N	\N	\N	0101000020E61000008EDEC19B9B4D4A400F147D11B1AD3D40
m6g8u0QpTC	2024-02-15 23:02:28.478+00	2024-02-15 23:02:28.478+00	Saffron House	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.690731361404428	52.565030742656575	\N	Saffron House	Saffron House	Saffron House	Saffron House@gmail.com	www.Saffron House.com	Shiraz	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	8.105793619690587	t	\N	\N	\N	\N	\N	0101000020E6100000E87868ED52484A40B78D3FC5D3B03D40
KpudflQKmS	2024-02-15 23:02:11.951+00	2024-02-15 23:02:11.951+00	Shandiz Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	csFI7CCFvJ	36.54724740796444	53.024343329212854	\N	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant@gmail.com	www.Shandiz Restaurant.com	Sari	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	5.256972441876748	t	\N	\N	\N	\N	\N	0101000020E6100000286CA5AE1D834A409703FC330C464240
0fFv9E7vGC	2024-02-15 23:02:12.261+00	2024-02-15 23:02:12.261+00	Cafe Nadia	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.56351599215248	52.97381095398138	\N	Cafe Nadia	Cafe Nadia	Cafe Nadia	Cafe Nadia@gmail.com	www.Cafe Nadia.com	Sari	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	4.3189900005139386	t	\N	\N	\N	\N	\N	0101000020E610000015EB5BD6A57C4A40B188C24A21484240
mg6sRbE7Pu	2024-02-15 23:02:12.475+00	2024-02-15 23:02:12.475+00	Iranian Kitchen	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	csFI7CCFvJ	36.52214046483619	53.09632578490699	\N	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen	Iranian Kitchen@gmail.com	www.Iranian Kitchen.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	9.942001244749257	t	\N	\N	\N	\N	\N	0101000020E6100000F1F73F67548C4A40E131AE7FD5424240
rk3Xq0IYQ1	2024-02-15 23:02:12.682+00	2024-02-15 23:02:12.682+00	Persian House	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	zzCG0AtaNp	36.4650161973867	53.12016327125371	\N	Persian House	Persian House	Persian House	Persian House@gmail.com	www.Persian House.com	Sari	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	3.095923596083978	t	\N	\N	\N	\N	\N	0101000020E6100000871B9482618F4A406EF197A6853B4240
GOabKBVupR	2024-02-15 23:02:12.881+00	2024-02-15 23:02:12.881+00	Salam Kabab	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	csFI7CCFvJ	36.59483954888647	53.11248523819225	\N	Salam Kabab	Salam Kabab	Salam Kabab	Salam Kabab@gmail.com	www.Salam Kabab.com	Sari	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	3.954098711658731	t	\N	\N	\N	\N	\N	0101000020E6100000C4A891EA658E4A40DA6ACCB3234C4240
wtAOcT9x32	2024-02-15 23:02:13.172+00	2024-02-15 23:02:13.172+00	Kebab Khazana	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.55973660347474	53.14908696747455	\N	Kebab Khazana	Kebab Khazana	Kebab Khazana	Kebab Khazana@gmail.com	www.Kebab Khazana.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	7.954765853849399	t	\N	\N	\N	\N	\N	0101000020E610000011C8204815934A402926F372A5474240
qAhMGrgSE6	2024-02-15 23:02:16.41+00	2024-02-15 23:02:16.41+00	Smoky BBQ Joint	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.720002126873915	51.71004497419866	\N	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint@gmail.com	www.Smoky BBQ Joint.com	Isfahan	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	5.770566597681793	t	\N	\N	\N	\N	\N	0101000020E6100000AB6FF3C0E2DA4940A9FC9907295C4040
bfHeApAfub	2024-02-15 23:02:16.609+00	2024-02-15 23:02:16.609+00	Persian Flavor	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.71453097198589	51.618443599262434	\N	Persian Flavor	Persian Flavor	Persian Flavor	Persian Flavor@gmail.com	www.Persian Flavor.com	Isfahan	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	3.380859381302823	t	\N	\N	\N	\N	\N	0101000020E610000058A0EC2829CF494049543AC0755B4040
ZMCao5XBmp	2024-02-15 23:02:16.813+00	2024-02-15 23:02:16.813+00	Persian Star	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.59005159493367	51.70507403212885	\N	Persian Star	Persian Star	Persian Star	Persian Star@gmail.com	www.Persian Star.com	Isfahan	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	2.966058101133169	t	\N	\N	\N	\N	\N	0101000020E61000004AA0AADD3FDA4940AC9887CF864B4040
XJwcmPr9YV	2024-02-15 23:02:17.015+00	2024-02-15 23:02:17.015+00	Cafe Nadia	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	lrNzJqVkzr	32.652839061132596	51.59325877647409	\N	Cafe Nadia	Cafe Nadia	Cafe Nadia	Cafe Nadia@gmail.com	www.Cafe Nadia.com	Isfahan	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	3.1045050943385655	t	\N	\N	\N	\N	\N	0101000020E6100000B68251E7EFCB4940D48EF83A90534040
fHqV1KxL4W	2024-02-15 23:02:17.279+00	2024-02-15 23:02:17.279+00	Kabab-e Tond	\N	https://backend-webquality.liara.run/images/logo-isfahan.webp	zzCG0AtaNp	32.62995523625215	51.696592880328495	\N	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond@gmail.com	www.Kabab-e Tond.com	Isfahan	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	3.9723150786945327	t	\N	\N	\N	\N	\N	0101000020E610000094D19BF429D94940CFD2885FA2504040
P9sBFomftT	2024-02-15 23:02:28.685+00	2024-02-15 23:02:28.685+00	Koobideh King	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.626489448011	52.58542442381022	\N	Koobideh King	Koobideh King	Koobideh King	Koobideh King@gmail.com	www.Koobideh King.com	Shiraz	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	7.14992618683066	t	\N	\N	\N	\N	\N	0101000020E6100000B3450130EF4A4A40107FCA9C61A03D40
M0tHrt1GgV	2024-02-15 23:02:28.911+00	2024-02-15 23:02:28.911+00	Shiraz Kabab	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.508850310281947	52.50963894474794	\N	Shiraz Kabab	Shiraz Kabab	Shiraz Kabab	Shiraz Kabab@gmail.com	www.Shiraz Kabab.com	Shiraz	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	5.965238992695088	t	\N	\N	\N	\N	\N	0101000020E6100000ED3A54D93B414A406D38910344823D40
m8hjjLVdPS	2024-02-15 23:02:29.131+00	2024-02-15 23:02:29.131+00	Salam Persian Kitchen	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.55531837665586	52.50635979110108	\N	Salam Persian Kitchen	Salam Persian Kitchen	Salam Persian Kitchen	Salam Persian Kitchen@gmail.com	www.Salam Persian Kitchen.com	Shiraz	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	2.9155311632749537	t	\N	\N	\N	\N	\N	0101000020E6100000EF64CB65D0404A40CF9A5A58298E3D40
o4VD4BWwDt	2024-02-15 23:02:29.347+00	2024-02-15 23:02:29.347+00	Bella Italia	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	nD1aOPUIAF	29.669902339686722	52.49508416103472	\N	Bella Italia	Bella Italia	Bella Italia	Bella Italia@gmail.com	www.Bella Italia.com	Shiraz	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	5.2198064339919625	t	\N	\N	\N	\N	\N	0101000020E6100000B334F4EA5E3F4A40E67740B87EAB3D40
RkhjIQJgou	2024-02-15 23:02:29.564+00	2024-02-15 23:02:29.564+00	Bam-e Tehran	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	nD1aOPUIAF	29.664390735259925	52.58470070350496	\N	Bam-e Tehran	Bam-e Tehran	Bam-e Tehran	Bam-e Tehran@gmail.com	www.Bam-e Tehran.com	Shiraz	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	1.159735476175403	t	\N	\N	\N	\N	\N	0101000020E610000041C0FF78D74A4A40EFB4DF8215AA3D40
Gl96vGdYHM	2024-02-15 23:02:29.78+00	2024-02-15 23:02:29.78+00	Gol Koochik	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.55146960997096	52.67438992951117	\N	Gol Koochik	Gol Koochik	Gol Koochik	Gol Koochik@gmail.com	www.Gol Koochik.com	Shiraz	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	5.209116707329027	t	\N	\N	\N	\N	\N	0101000020E61000004900C26852564A402B90C31C2D8D3D40
36OPqP4T0L	2024-02-17 01:04:47.013+00	2024-02-17 01:11:58.79+00	اصغر کبابی	\N	https://backend-webquality.liara.run/images/logo-irani.webp	nD1aOPUIAF	0	0	978698	asgharkababi	asgharkababi	2342342	kocoya5631@oprevolt.com		gorgan	009	09	90	0909	08:00	20:00	یکشنبه,دوشنبه,سه شنبه,شنبه	f	f	f	\N	\N	\N	\N	asgharkababi	\N	{}	0101000020E610000000000000000000000000000000000000
XSK814B37m	2024-02-15 23:02:29.985+00	2024-02-15 23:02:29.985+00	Alborz Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.579163737506985	52.56311263343288	\N	Alborz Restaurant	Alborz Restaurant	Alborz Restaurant	Alborz Restaurant@gmail.com	www.Alborz Restaurant.com	Shiraz	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	6.86698825211042	t	\N	\N	\N	\N	\N	0101000020E61000008247241314484A40239F1F1344943D40
3ZzlSWBzAR	2024-02-15 23:02:11.344+00	2024-02-15 23:02:11.344+00	Koobideh King	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	csFI7CCFvJ	36.553345584650785	52.99200829896055	\N	Koobideh King	Koobideh King	Koobideh King	Koobideh King@gmail.com	www.Koobideh King.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	4.559852644434539	t	\N	\N	\N	\N	\N	0101000020E6100000B5B2C020FA7E4A4006BB3207D4464240
hCSNk6fM3J	2024-02-15 23:02:11.645+00	2024-02-15 23:02:11.645+00	Persian Garden	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.533817031707976	53.00435878733121	\N	Persian Garden	Persian Garden	Persian Garden	Persian Garden@gmail.com	www.Persian Garden.com	Sari	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	7.487129222900926	t	\N	\N	\N	\N	\N	0101000020E6100000D68428D48E804A40E59DD21D54444240
ThMuD3hYRQ	2024-02-15 23:02:03.454+00	2024-02-15 23:02:03.454+00	Smoky BBQ Joint	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.755480678740234	51.29045217416442	\N	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint@gmail.com	www.Smoky BBQ Joint.com	Tehran	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	8.127134296557003	t	\N	\N	\N	\N	\N	0101000020E61000004D8B6E892DA549407FF94397B3E04140
dI7KhBJPBk	2024-02-15 23:02:13.396+00	2024-02-15 23:02:13.396+00	Zahr Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	zzCG0AtaNp	36.564988793328745	53.059112880697256	\N	Zahr Restaurant	Zahr Restaurant	Zahr Restaurant	Zahr Restaurant@gmail.com	www.Zahr Restaurant.com	Sari	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	4.716687499431793	t	\N	\N	\N	\N	\N	0101000020E6100000FCAEC80291874A400BFA828D51484240
CB5UQ5cYqR	2024-02-15 23:02:13.598+00	2024-02-15 23:02:13.598+00	Kabab Koobideh	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	zzCG0AtaNp	36.50385147725477	53.02247285179625	\N	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh@gmail.com	www.Kabab Koobideh.com	Sari	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	4.0629900915041395	t	\N	\N	\N	\N	\N	0101000020E6100000A2C1F163E0824A40DE6C88347E404240
oGjrhDFnuW	2024-02-15 23:02:13.805+00	2024-02-15 23:02:13.805+00	Dizi Sara	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.57576289183397	53.14523236148601	\N	Dizi Sara	Dizi Sara	Dizi Sara	Dizi Sara@gmail.com	www.Dizi Sara.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	9.7141971450266	t	\N	\N	\N	\N	\N	0101000020E61000009E7359F996924A40B1563399B2494240
u5FXeeOChJ	2024-02-15 23:02:25.3+00	2024-02-15 23:02:25.3+00	Saffron Bistro	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.60304464635916	52.63209813778922	\N	Saffron Bistro	Saffron Bistro	Saffron Bistro	Saffron Bistro@gmail.com	www.Saffron Bistro.com	Shiraz	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	0.29545801977589825	t	\N	\N	\N	\N	\N	0101000020E610000067D57E97E8504A40F6234A22619A3D40
oABNR2FF6S	2024-02-15 23:02:25.509+00	2024-02-15 23:02:25.509+00	Saffron House	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.635045084587308	52.55348289146652	\N	Saffron House	Saffron House	Saffron House	Saffron House@gmail.com	www.Saffron House.com	Shiraz	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	2.0938730999112587	t	\N	\N	\N	\N	\N	0101000020E610000043DF0287D8464A40BDC98D5092A23D40
qZmnAnnPEb	2024-02-15 23:02:25.718+00	2024-02-15 23:02:25.718+00	Saffron Lounge	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.572788396423107	52.61128242220605	\N	Saffron Lounge	Saffron Lounge	Saffron Lounge	Saffron Lounge@gmail.com	www.Saffron Lounge.com	Shiraz	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	7.764669816409819	t	\N	\N	\N	\N	\N	0101000020E610000051FF9D803E4E4A40602AA642A2923D40
89xRG1afNi	2024-02-15 23:02:25.928+00	2024-02-15 23:02:25.928+00	Saraye Saadat	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.557644900268848	52.4836685828131	\N	Saraye Saadat	Saraye Saadat	Saraye Saadat	Saraye Saadat@gmail.com	www.Saraye Saadat.com	Shiraz	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	0.32506642384223294	t	\N	\N	\N	\N	\N	0101000020E610000079A424DAE83D4A40966FF1D0C18E3D40
Zwmzdnknoh	2024-02-15 23:02:10.827+00	2024-02-15 23:02:10.827+00	Flavors of India	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.709453217996376	51.33576339032351	\N	Flavors of India	Flavors of India	Flavors of India	Flavors of India@gmail.com	www.Flavors of India.com	Tehran	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	1.036922749652276	t	\N	\N	\N	\N	\N	0101000020E61000001851764BFAAA49400FABF05CCFDA4140
f6nYAkE5Og	2024-02-15 23:02:11.133+00	2024-02-15 23:02:11.133+00	Shahrzad Restaurant	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	lrNzJqVkzr	35.63706337910544	51.40286834886225	\N	Shahrzad Restaurant	Shahrzad Restaurant	Shahrzad Restaurant	Shahrzad Restaurant@gmail.com	www.Shahrzad Restaurant.com	Tehran	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	3.313241720953115	t	\N	\N	\N	\N	\N	0101000020E61000007B7AA73091B349405A5EF54A8BD14140
lxQA9rtSfY	2024-02-15 23:02:40.149+00	2024-02-15 23:02:40.149+00	Café Paris	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.29029246580317	59.439320002835494	\N	Café Paris	Café Paris	Café Paris	Café Paris@gmail.com	www.Café Paris.com	Mashhad	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	7.708687280264108	t	\N	\N	\N	\N	\N	0101000020E61000001B544AA33BB84D402D73B34D28254240
TpGyMZM9BG	2024-02-15 23:02:40.355+00	2024-02-15 23:02:40.355+00	Dizi Sara	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.26440735017322	59.36024070626481	\N	Dizi Sara	Dizi Sara	Dizi Sara	Dizi Sara@gmail.com	www.Dizi Sara.com	Mashhad	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	2.0410573366865936	t	\N	\N	\N	\N	\N	0101000020E6100000330C125E1CAE4D4073E89C19D8214240
BMLzFMvIT6	2024-02-15 23:02:40.566+00	2024-02-15 23:02:40.566+00	Persian Garden	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.18388531794234	59.47429455518985	\N	Persian Garden	Persian Garden	Persian Garden	Persian Garden@gmail.com	www.Persian Garden.com	Mashhad	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	1.2856572510584585	t	\N	\N	\N	\N	\N	0101000020E61000000B9B19AFB5BC4D407263D98D89174240
qP3EdIVzfB	2024-02-15 23:02:40.777+00	2024-02-15 23:02:40.777+00	Kabab Koobideh	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.155388612400465	59.44255477939313	\N	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh@gmail.com	www.Kabab Koobideh.com	Mashhad	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	1.8204471862131233	t	\N	\N	\N	\N	\N	0101000020E61000004B1790A2A5B84D40253728C6E3134240
HXtEwLBC7f	2024-02-15 23:02:40.984+00	2024-02-15 23:02:40.984+00	La Casa de Tapas	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.12017148910695	59.41442684281966	\N	La Casa de Tapas	La Casa de Tapas	La Casa de Tapas	La Casa de Tapas@gmail.com	www.La Casa de Tapas.com	Mashhad	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	2.0473322604019994	t	\N	\N	\N	\N	\N	0101000020E61000005B3F54F00BB54D4020D083C7610F4240
e037qpAih3	2024-02-15 23:02:41.182+00	2024-02-15 23:02:41.182+00	Saffron Palace	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.196494770156825	59.46053231978478	\N	Saffron Palace	Saffron Palace	Saffron Palace	Saffron Palace@gmail.com	www.Saffron Palace.com	Mashhad	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	6.007447365617695	t	\N	\N	\N	\N	\N	0101000020E6100000031D1AB9F2BA4D404DD499BD26194240
NBojpORh3G	2024-02-15 23:02:41.388+00	2024-02-15 23:02:41.388+00	Dizi Sara	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.25551443251379	59.39583280425823	\N	Dizi Sara	Dizi Sara	Dizi Sara	Dizi Sara@gmail.com	www.Dizi Sara.com	Mashhad	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	3.305706349696169	t	\N	\N	\N	\N	\N	0101000020E61000008D7C3AA6AAB24D40C0A669B2B4204240
cmxBcanww9	2024-02-15 23:02:41.601+00	2024-02-15 23:02:41.601+00	Yas Restaurant	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.15366593189191	59.30172023942095	\N	Yas Restaurant	Yas Restaurant	Yas Restaurant	Yas Restaurant@gmail.com	www.Yas Restaurant.com	Mashhad	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	5.694730448463945	t	\N	\N	\N	\N	\N	0101000020E6100000596DD0C49EA64D4018FE4353AB134240
JZOBDAh12a	2024-02-15 23:02:41.805+00	2024-02-15 23:02:41.805+00	Saffron Lounge	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.14626149692211	59.30378069115414	\N	Saffron Lounge	Saffron Lounge	Saffron Lounge	Saffron Lounge@gmail.com	www.Saffron Lounge.com	Mashhad	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	0.33723020149798	t	\N	\N	\N	\N	\N	0101000020E6100000E7D42249E2A64D40E4F85CB2B8124240
JRi61dUphq	2024-02-15 23:02:42.014+00	2024-02-15 23:02:42.014+00	Shandiz Restaurant	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.26542690655166	59.422310645093845	\N	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant	Shandiz Restaurant@gmail.com	www.Shandiz Restaurant.com	Mashhad	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	3.827983301272735	t	\N	\N	\N	\N	\N	0101000020E610000022B774460EB64D40158F4582F9214240
Oahm9sOn1y	2024-02-15 23:02:42.221+00	2024-02-15 23:02:42.221+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.194470183059906	59.30344107425315	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Mashhad	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	1.0326581300339743	t	\N	\N	\N	\N	\N	0101000020E610000017173928D7A64D400C252266E4184240
XpUyRlB6FI	2024-02-15 23:02:36.632+00	2024-02-15 23:02:36.632+00	Pars Grill	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.2862698858194	59.32186437441252	\N	Pars Grill	Pars Grill	Pars Grill	Pars Grill@gmail.com	www.Pars Grill.com	Mashhad	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	1.0847169393956357	t	\N	\N	\N	\N	\N	0101000020E6100000B5EC10DA32A94D4045B6DA7DA4244240
PF8w2gMAdi	2024-02-15 23:02:36.838+00	2024-02-15 23:02:36.838+00	Kabab-e Tond	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.174800301803366	59.33168242992535	\N	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond@gmail.com	www.Kabab-e Tond.com	Mashhad	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	0.1638820184834322	t	\N	\N	\N	\N	\N	0101000020E6100000F697E29174AA4D40C7C935DB5F164240
rT0UCBK1bE	2024-02-15 23:02:37.045+00	2024-02-15 23:02:37.045+00	Parsian Grill	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.130106724686705	59.453499076399694	\N	Parsian Grill	Parsian Grill	Parsian Grill	Parsian Grill@gmail.com	www.Parsian Grill.com	Mashhad	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	8.1770624565781	t	\N	\N	\N	\N	\N	0101000020E610000092F3FA410CBA4D4071C24F56A7104240
IybX0eBoO3	2024-02-15 23:02:37.252+00	2024-02-15 23:02:37.252+00	Shamshiri Grill	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.18484911647435	59.41219945422625	\N	Shamshiri Grill	Shamshiri Grill	Shamshiri Grill	Shamshiri Grill@gmail.com	www.Shamshiri Grill.com	Mashhad	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	0.7698132267534041	t	\N	\N	\N	\N	\N	0101000020E610000057AAA3F3C2B44D40D6F9C622A9174240
Pja6n3yaWZ	2024-02-15 23:02:37.455+00	2024-02-15 23:02:37.455+00	Persian Bazaar	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.28618208572185	59.35206620090188	\N	Persian Bazaar	Persian Bazaar	Persian Bazaar	Persian Bazaar@gmail.com	www.Persian Bazaar.com	Mashhad	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	3.887284557057127	t	\N	\N	\N	\N	\N	0101000020E61000004573598110AD4D402E70559DA1244240
INeptnSdJC	2024-02-15 23:02:37.664+00	2024-02-15 23:02:37.664+00	Parsian Kitchen	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.1246374706522	59.469662109494806	\N	Parsian Kitchen	Parsian Kitchen	Parsian Kitchen	Parsian Kitchen@gmail.com	www.Parsian Kitchen.com	Mashhad	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	3.225253465395841	t	\N	\N	\N	\N	\N	0101000020E6100000AC3954E31DBC4D405827E21EF40F4240
IEqTHcohpJ	2024-02-15 23:02:37.88+00	2024-02-15 23:02:37.88+00	Kabab Tabei	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.231521137204375	59.32336020238546	\N	Kabab Tabei	Kabab Tabei	Kabab Tabei	Kabab Tabei@gmail.com	www.Kabab Tabei.com	Mashhad	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	1.88487131744415	t	\N	\N	\N	\N	\N	0101000020E61000006809FBDD63A94D401150107CA21D4240
uigc7bJBOJ	2024-02-15 23:02:04.778+00	2024-02-15 23:02:04.778+00	Smoky BBQ Joint	\N	https://backend-webquality.liara.run/images/logo-tehran.webp	nD1aOPUIAF	35.63840689440013	51.47141503308976	\N	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint	Smoky BBQ Joint@gmail.com	www.Smoky BBQ Joint.com	Tehran	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	4.018450223121186	t	\N	\N	\N	\N	\N	0101000020E61000004DFBEA5357BC4940A77E2E51B7D14140
RBRcyltRSC	2024-02-15 23:02:42.429+00	2024-02-15 23:02:42.429+00	Chelo Kabab	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.13164252902406	59.414860382854506	\N	Chelo Kabab	Chelo Kabab	Chelo Kabab	Chelo Kabab@gmail.com	www.Chelo Kabab.com	Mashhad	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	2.8422300777591625	t	\N	\N	\N	\N	\N	0101000020E6100000116220251AB54D40E67592A9D9104240
fxvABtKCPT	2024-02-15 23:02:42.636+00	2024-02-15 23:02:42.636+00	Bam-e Tehran	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.2402676622052	59.488151479849044	\N	Bam-e Tehran	Bam-e Tehran	Bam-e Tehran	Bam-e Tehran@gmail.com	www.Bam-e Tehran.com	Mashhad	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	2.2144841618330324	t	\N	\N	\N	\N	\N	0101000020E61000000BB968BF7BBE4D4096BA3B17C11E4240
tCIEnLLcUc	2024-02-15 23:02:42.843+00	2024-02-15 23:02:42.843+00	Tehran Delight	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	csFI7CCFvJ	36.29810672939512	59.364238729244455	\N	Tehran Delight	Tehran Delight	Tehran Delight	Tehran Delight@gmail.com	www.Tehran Delight.com	Mashhad	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	8.772838135920901	t	\N	\N	\N	\N	\N	0101000020E61000005105EB5F9FAE4D401BBC7E5C28264240
LgJuu5ABe5	2024-02-15 23:02:43.059+00	2024-02-15 23:02:43.059+00	Parsian Grill	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.2606735096819	59.34420926772681	\N	Parsian Grill	Parsian Grill	Parsian Grill	Parsian Grill@gmail.com	www.Parsian Grill.com	Mashhad	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	2.7656984157102493	t	\N	\N	\N	\N	\N	0101000020E6100000F2EE9D0C0FAC4D403782E3BF5D214240
8w7i8C3NnT	2024-02-15 23:02:43.274+00	2024-02-15 23:02:43.274+00	Persian Flavor	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	lrNzJqVkzr	36.104146550663835	59.386087469542325	\N	Persian Flavor	Persian Flavor	Persian Flavor	Persian Flavor@gmail.com	www.Persian Flavor.com	Mashhad	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	2.03929579336104	t	\N	\N	\N	\N	\N	0101000020E6100000338A6F506BB14D40D38B96AC540D4240
KCsJ4XR6Dn	2024-02-15 23:02:43.471+00	2024-02-15 23:02:43.471+00	Persian Bazaar	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.18059082684508	59.38524878602575	\N	Persian Bazaar	Persian Bazaar	Persian Bazaar	Persian Bazaar@gmail.com	www.Persian Bazaar.com	Mashhad	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	5.406179334070266	t	\N	\N	\N	\N	\N	0101000020E6100000F3660CD54FB14D40EDA0A7991D174240
l1Bslv8T2k	2024-02-15 23:02:43.68+00	2024-02-15 23:02:43.68+00	Shiraz Palace	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.21461984080474	59.355368050751075	\N	Shiraz Palace	Shiraz Palace	Shiraz Palace	Shiraz Palace@gmail.com	www.Shiraz Palace.com	Mashhad	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	8.23243189425051	t	\N	\N	\N	\N	\N	0101000020E6100000730246B37CAD4D401FAAB6A9781B4240
TZsdmscJ2B	2024-02-15 23:02:43.88+00	2024-02-15 23:02:43.88+00	Persian Bazaar	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.100427828925866	59.47131543243483	\N	Persian Bazaar	Persian Bazaar	Persian Bazaar	Persian Bazaar@gmail.com	www.Persian Bazaar.com	Mashhad	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	3.746174743321633	t	\N	\N	\N	\N	\N	0101000020E61000002F34681054BC4D40256CB0D1DA0C4240
FYXEfIO1zF	2024-02-15 23:02:44.085+00	2024-02-15 23:02:44.085+00	Parsian Palace	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.14531601294056	59.40045251599067	\N	Parsian Palace	Parsian Palace	Parsian Palace	Parsian Palace@gmail.com	www.Parsian Palace.com	Mashhad	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	1.8090467665919596	t	\N	\N	\N	\N	\N	0101000020E6100000F3E32D0742B34D40199511B799124240
D0A6GLdsDM	2024-02-15 23:02:44.293+00	2024-02-15 23:02:44.293+00	Persian Garden	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.17963308066763	59.350475026222696	\N	Persian Garden	Persian Garden	Persian Garden	Persian Garden@gmail.com	www.Persian Garden.com	Mashhad	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	8.154454514846199	t	\N	\N	\N	\N	\N	0101000020E61000007AD89B5DDCAC4D40A45F7F37FE164240
0TvWuLoLF5	2024-02-15 23:02:44.527+00	2024-02-15 23:02:44.527+00	The Spice Route	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	nD1aOPUIAF	36.25973026905682	59.440200011409544	\N	The Spice Route	The Spice Route	The Spice Route	The Spice Route@gmail.com	www.The Spice Route.com	Mashhad	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	8.904552768405997	t	\N	\N	\N	\N	\N	0101000020E6100000F659567958B84D40AEB069D73E214240
Pa0qBO2rzK	2024-02-15 23:02:44.747+00	2024-02-15 23:02:44.747+00	Pars Grill	\N	https://backend-webquality.liara.run/images/logo-mashad.webp	zzCG0AtaNp	36.2022383856005	59.39918124972396	\N	Pars Grill	Pars Grill	Pars Grill	Pars Grill@gmail.com	www.Pars Grill.com	Mashhad	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	2.429486750628884	t	\N	\N	\N	\N	\N	0101000020E6100000D35E065F18B34D4033138AF2E2194240
iDyXuatOEX	2024-02-15 23:02:23.013+00	2024-02-15 23:02:23.013+00	Pasta Paradise	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.646870408373072	52.63181409819261	\N	Pasta Paradise	Pasta Paradise	Pasta Paradise	Pasta Paradise@gmail.com	www.Pasta Paradise.com	Shiraz	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	2.6825946506035825	t	\N	\N	\N	\N	\N	0101000020E6100000CB71CC48DF504A4067B6904C99A53D40
wKnBs8EhFa	2024-02-15 23:02:23.219+00	2024-02-15 23:02:23.219+00	Farsi Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.57302207852088	52.63936054861715	\N	Farsi Restaurant	Farsi Restaurant	Farsi Restaurant	Farsi Restaurant@gmail.com	www.Farsi Restaurant.com	Shiraz	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	0.7979555148173634	t	\N	\N	\N	\N	\N	0101000020E6100000E6540391D6514A4014222F93B1923D40
YQ5kze6GzJ	2024-02-15 23:02:14.004+00	2024-02-15 23:02:14.004+00	Burger Barn	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	csFI7CCFvJ	36.53913594851937	52.98724974242234	\N	Burger Barn	Burger Barn	Burger Barn	Burger Barn@gmail.com	www.Burger Barn.com	Sari	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	2.8880704093764575	t	\N	\N	\N	\N	\N	0101000020E61000001D5816335E7E4A408C7E216802454240
AOyFkihK20	2024-02-15 23:02:14.304+00	2024-02-15 23:02:14.304+00	Cozy Corner Cafe	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	csFI7CCFvJ	36.537750239189826	53.13997935399662	\N	Cozy Corner Cafe	Cozy Corner Cafe	Cozy Corner Cafe	Cozy Corner Cafe@gmail.com	www.Cozy Corner Cafe.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	6.711146505716625	t	\N	\N	\N	\N	\N	0101000020E6100000EEC3EDD7EA914A40455EF5FFD4444240
bxLXaSLFL3	2024-02-15 23:02:14.616+00	2024-02-15 23:02:14.616+00	Chahar Bagh Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.49264858986345	53.03611489863084	\N	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant	Chahar Bagh Restaurant@gmail.com	www.Chahar Bagh Restaurant.com	Sari	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	3.6989688039536195	t	\N	\N	\N	\N	\N	0101000020E61000004842BA699F844A4028F1E61B0F3F4240
AwEx0UT94S	2024-02-15 23:02:14.829+00	2024-02-15 23:02:14.829+00	Shabestan Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.47264555605085	53.135925731855515	\N	Shabestan Restaurant	Shabestan Restaurant	Shabestan Restaurant	Shabestan Restaurant@gmail.com	www.Shabestan Restaurant.com	Sari	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	6.8661177393687645	t	\N	\N	\N	\N	\N	0101000020E61000008D80AE0366914A4048EB4AA67F3C4240
UGO89iiBjB	2024-02-15 23:02:15.128+00	2024-02-15 23:02:15.128+00	Kabab-e Tond	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.549776973483965	53.13708123790191	\N	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond@gmail.com	www.Kabab-e Tond.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	9.394162464599528	t	\N	\N	\N	\N	\N	0101000020E61000008AD7C4E08B914A408F9A84175F464240
jSKh0G3Rjz	2024-02-15 23:02:15.35+00	2024-02-15 23:02:15.35+00	Salam Restaurant	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.524442963802485	53.15355470160539	\N	Salam Restaurant	Salam Restaurant	Salam Restaurant	Salam Restaurant@gmail.com	www.Salam Restaurant.com	Sari	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	6.2967275526566	t	\N	\N	\N	\N	\N	0101000020E610000066C532AEA7934A40121371F220434240
Fy6R47HUvM	2024-02-15 23:02:15.562+00	2024-02-15 23:02:15.562+00	Sizzling Sizzlers	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.52604366768678	53.11069762464309	\N	Sizzling Sizzlers	Sizzling Sizzlers	Sizzling Sizzlers	Sizzling Sizzlers@gmail.com	www.Sizzling Sizzlers.com	Sari	\N	\N	\N	\N	8:00	22:00	all days	\N	\N	\N	4.546728842454925	t	\N	\N	\N	\N	\N	0101000020E610000021CBFA562B8E4A40C67D1E6655434240
FJ6tMuJePA	2024-02-15 23:02:15.774+00	2024-02-15 23:02:15.774+00	Saffron House	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	nD1aOPUIAF	36.59916158800788	53.07421114442664	\N	Saffron House	Saffron House	Saffron House	Saffron House@gmail.com	www.Saffron House.com	Sari	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	9.799259212479743	t	\N	\N	\N	\N	\N	0101000020E6100000D42733C07F894A40B3C1B053B14C4240
gpvLaYfY0c	2024-02-15 23:02:15.982+00	2024-02-15 23:02:15.982+00	Persian Plate	\N	https://backend-webquality.liara.run/images/1707751466076.jpg	lrNzJqVkzr	36.501532395300956	53.041253099036524	\N	Persian Plate	Persian Plate	Persian Plate	Persian Plate@gmail.com	www.Persian Plate.com	Sari	\N	\N	\N	\N	9:00	19:00	all days	\N	\N	\N	5.545117125423813	t	\N	\N	\N	\N	\N	0101000020E61000003A9C13C847854A40E0D9A93632404240
u3iwXbllsO	2024-02-15 23:02:23.419+00	2024-02-15 23:02:23.419+00	Persian Feast	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.639026818990555	52.66431866776157	\N	Persian Feast	Persian Feast	Persian Feast	Persian Feast@gmail.com	www.Persian Feast.com	Shiraz	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	4.193314858720001	t	\N	\N	\N	\N	\N	0101000020E61000004114E46408554A40D3D4F84297A33D40
1rzH9IbKOj	2024-02-15 23:02:23.625+00	2024-02-15 23:02:23.625+00	Cafe Nadia	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.590054567843723	52.61060728697725	\N	Cafe Nadia	Cafe Nadia	Cafe Nadia	Cafe Nadia@gmail.com	www.Cafe Nadia.com	Shiraz	\N	\N	\N	\N	9:00	22:00	all days	\N	\N	\N	1.6666800876054277	t	\N	\N	\N	\N	\N	0101000020E61000001F222C61284E4A4084BEEFD00D973D40
VTYsgodSUx	2024-02-15 23:02:23.83+00	2024-02-15 23:02:23.83+00	Behesht Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	nD1aOPUIAF	29.5211253951822	52.54737807546047	\N	Behesht Restaurant	Behesht Restaurant	Behesht Restaurant	Behesht Restaurant@gmail.com	www.Behesht Restaurant.com	Shiraz	\N	\N	\N	\N	10:00	18:00	all days	\N	\N	\N	0.6986663683852123	t	\N	\N	\N	\N	\N	0101000020E610000038531A7C10464A40316C517968853D40
Br07eYz8rq	2024-02-15 23:02:24.048+00	2024-02-15 23:02:24.048+00	Kabab-e Tond	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	nD1aOPUIAF	29.583482331709106	52.594053579679446	\N	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond	Kabab-e Tond@gmail.com	www.Kabab-e Tond.com	Shiraz	\N	\N	\N	\N	8:00	18:00	all days	\N	\N	\N	2.6170492292396808	t	\N	\N	\N	\N	\N	0101000020E6100000C1659CF2094C4A40047C1C195F953D40
DXWYJa27sP	2024-02-15 23:02:24.257+00	2024-02-15 23:02:24.257+00	Persian Grill	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.691343246279615	52.680173931610966	\N	Persian Grill	Persian Grill	Persian Grill	Persian Grill@gmail.com	www.Persian Grill.com	Shiraz	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	8.184526537406162	t	\N	\N	\N	\N	\N	0101000020E610000030EE7BF00F574A40D814F9DEFBB03D40
hSxS6xRNRz	2024-02-15 23:02:24.468+00	2024-02-15 23:02:24.468+00	Persian Feast	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	zzCG0AtaNp	29.619910929935788	52.64566507038285	\N	Persian Feast	Persian Feast	Persian Feast	Persian Feast@gmail.com	www.Persian Feast.com	Shiraz	\N	\N	\N	\N	9:00	18:00	all days	\N	\N	\N	6.906518454701464	t	\N	\N	\N	\N	\N	0101000020E610000060BB2C27A5524A40D581927BB29E3D40
jwIM2XsWKC	2024-02-15 23:02:24.676+00	2024-02-15 23:02:24.676+00	Aladdin Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	nD1aOPUIAF	29.604698511996947	52.59811806301475	\N	Aladdin Restaurant	Aladdin Restaurant	Aladdin Restaurant	Aladdin Restaurant@gmail.com	www.Aladdin Restaurant.com	Shiraz	\N	\N	\N	\N	10:00	22:00	all days	\N	\N	\N	1.9825304740275196	t	\N	\N	\N	\N	\N	0101000020E6100000CAE5F7218F4C4A407DF78C85CD9A3D40
NMRXuu7eNj	2024-02-15 23:02:24.883+00	2024-02-15 23:02:24.883+00	Ariana Restaurant	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	lrNzJqVkzr	29.657286658860308	52.62572566197358	\N	Ariana Restaurant	Ariana Restaurant	Ariana Restaurant	Ariana Restaurant@gmail.com	www.Ariana Restaurant.com	Shiraz	\N	\N	\N	\N	10:00	19:00	all days	\N	\N	\N	3.251311678635702	t	\N	\N	\N	\N	\N	0101000020E6100000E5384BC717504A40F2E63FF043A83D40
JG10xWHTEf	2024-02-15 23:02:25.092+00	2024-02-15 23:02:25.092+00	Kabab Koobideh	\N	https://backend-webquality.liara.run/images/logo-tabriz.webp	csFI7CCFvJ	29.515885842834102	52.60566556350588	\N	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh	Kabab Koobideh@gmail.com	www.Kabab Koobideh.com	Shiraz	\N	\N	\N	\N	8:00	19:00	all days	\N	\N	\N	3.983204274228902	t	\N	\N	\N	\N	\N	0101000020E61000001CC9FD72864D4A401E71371811843D40
\.


--
-- Data for Name: Score; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."Score" ("objectId", "createdAt", "updatedAt", user_id, restaurant_id, employee_behave_score, restaurant_cleanliness_score, food_quality_score, taste_of_food_score, side_services_score, _rperm, _wperm) FROM stdin;
MHHg8IkI4Z	2024-02-16 00:03:58.441+00	2024-02-16 00:03:58.441+00	mQXQWNqxg9	8w7i8C3NnT	0	0	0	1	3	\N	\N
3sFMF6wbOq	2024-02-16 00:03:58.652+00	2024-02-16 00:03:58.652+00	HRhGpJpmb5	LgJuu5ABe5	4	1	4	0	2	\N	\N
bfsv5GKEhk	2024-02-16 00:03:58.864+00	2024-02-16 00:03:58.864+00	1as6rMOzjQ	u5FXeeOChJ	0	0	2	2	4	\N	\N
BCkuiWSTzy	2024-02-16 00:03:59.08+00	2024-02-16 00:03:59.08+00	NjxsGlPeB4	KCsJ4XR6Dn	4	0	1	1	0	\N	\N
Ick3WcUjeF	2024-02-16 00:03:59.283+00	2024-02-16 00:03:59.283+00	opW2wQ2bZ8	cwVEh0dqfm	2	2	2	1	2	\N	\N
okKCV8RhGQ	2024-02-16 00:03:59.483+00	2024-02-16 00:03:59.483+00	opW2wQ2bZ8	LgJuu5ABe5	1	4	3	1	3	\N	\N
gl4NN0Up5t	2024-02-16 00:03:59.682+00	2024-02-16 00:03:59.682+00	opW2wQ2bZ8	jjVdtithcD	2	0	1	0	2	\N	\N
gvYSRaUohf	2024-02-16 00:03:59.882+00	2024-02-16 00:03:59.882+00	mAKp5BK7R1	8w7i8C3NnT	2	0	1	2	0	\N	\N
vIkAKXwbRG	2024-02-16 00:04:00.098+00	2024-02-16 00:04:00.098+00	adE9nQrDk3	9GF3y7LmHV	4	4	3	0	4	\N	\N
mwMwt3mARS	2024-02-16 00:04:00.307+00	2024-02-16 00:04:00.307+00	NjxsGlPeB4	CSvk1ycWXk	3	0	3	2	1	\N	\N
FHKaT88xHQ	2024-02-16 00:04:00.512+00	2024-02-16 00:04:00.512+00	ONgyydfVNz	D0A6GLdsDM	0	2	3	2	4	\N	\N
G5yPnPtyLA	2024-02-16 00:04:00.723+00	2024-02-16 00:04:00.723+00	VshUk7eBeK	m6g8u0QpTC	3	1	2	4	2	\N	\N
oFOSqdz051	2024-02-16 00:04:00.93+00	2024-02-16 00:04:00.93+00	ONgyydfVNz	LDrIH1vU8x	0	0	2	0	2	\N	\N
STEnhlYJjX	2024-02-16 00:04:01.204+00	2024-02-16 00:04:01.204+00	S6wz0lK0bf	qEQ9tmLyW9	0	4	4	2	2	\N	\N
JRAzPyp5nU	2024-02-16 00:04:01.411+00	2024-02-16 00:04:01.411+00	1as6rMOzjQ	E2hBZzDsjO	0	3	2	2	3	\N	\N
1ONCREdZXz	2024-02-16 00:04:01.611+00	2024-02-16 00:04:01.611+00	AsrLUQwxI9	6KvFK8yy1q	2	1	3	1	1	\N	\N
IdFArDxiFL	2024-02-16 00:04:01.912+00	2024-02-16 00:04:01.912+00	dEqAHvPMXA	FJOTueDfs2	3	0	0	1	3	\N	\N
uCvHmmDnsI	2024-02-16 00:04:02.137+00	2024-02-16 00:04:02.137+00	Otwj7uJwjr	TpGyMZM9BG	2	4	4	1	0	\N	\N
e2vzr4JnId	2024-02-16 00:04:02.389+00	2024-02-16 00:04:02.389+00	dZKm0wOhYa	bQpy9LEJWn	4	4	2	3	1	\N	\N
PeqD2lxy7p	2024-02-16 00:04:02.595+00	2024-02-16 00:04:02.595+00	WKpBp0c8F3	RBRcyltRSC	3	3	3	0	4	\N	\N
vsJ7RopwQn	2024-02-16 00:04:02.808+00	2024-02-16 00:04:02.808+00	adE9nQrDk3	0TvWuLoLF5	3	4	2	3	3	\N	\N
O4IqklPxjj	2024-02-16 00:04:03.006+00	2024-02-16 00:04:03.006+00	opW2wQ2bZ8	OQWu2bnHeC	3	0	3	1	1	\N	\N
ArL4onhtZM	2024-02-16 00:04:03.222+00	2024-02-16 00:04:03.222+00	SFAISec8QF	M0tHrt1GgV	3	4	4	3	3	\N	\N
hbSJ24ndxr	2024-02-16 00:04:03.443+00	2024-02-16 00:04:03.443+00	RWwLSzreG2	JZOBDAh12a	0	0	4	2	4	\N	\N
DLYRgfkD4g	2024-02-16 00:04:03.755+00	2024-02-16 00:04:03.755+00	R2CLtFh5jU	oABNR2FF6S	0	2	3	3	4	\N	\N
V6bUqVx82M	2024-02-16 00:04:03.954+00	2024-02-16 00:04:03.954+00	I5RzFRcQ7G	0TvWuLoLF5	0	1	4	0	0	\N	\N
9hPZb40z6n	2024-02-16 00:04:04.175+00	2024-02-16 00:04:04.175+00	sHiqaG4iqY	RBRcyltRSC	3	0	0	0	2	\N	\N
GIcke8GZXg	2024-02-16 00:04:04.374+00	2024-02-16 00:04:04.374+00	I5RzFRcQ7G	m6g8u0QpTC	1	1	3	3	1	\N	\N
rUREgFylEw	2024-02-16 00:04:04.582+00	2024-02-16 00:04:04.582+00	ONgyydfVNz	tCIEnLLcUc	1	0	2	3	4	\N	\N
hikEr0FwXR	2024-02-16 00:04:04.779+00	2024-02-16 00:04:04.779+00	sHiqaG4iqY	cmxBcanww9	4	0	2	2	2	\N	\N
71VQuA7Yzk	2024-02-16 00:04:04.977+00	2024-02-16 00:04:04.977+00	jqDYoPT45X	3u4B9V4l5K	3	4	1	4	4	\N	\N
4XeXZ6hEQw	2024-02-16 00:04:05.275+00	2024-02-16 00:04:05.275+00	jqDYoPT45X	Gl96vGdYHM	4	3	1	2	3	\N	\N
5S9rufKpod	2024-02-16 00:04:05.549+00	2024-02-16 00:04:05.549+00	9223vtvaBd	EmIUBFwx0Z	3	0	2	3	4	\N	\N
rh9iVW9u5V	2024-02-16 00:04:05.822+00	2024-02-16 00:04:05.822+00	iUlyHNFGpG	3u4B9V4l5K	0	4	2	0	4	\N	\N
HupEErpjx6	2024-02-16 00:04:06.073+00	2024-02-16 00:04:06.073+00	RWwLSzreG2	IEqTHcohpJ	3	3	1	0	2	\N	\N
OvXG4QZXjv	2024-02-16 00:04:06.336+00	2024-02-16 00:04:06.336+00	sy1HD51LXT	XSK814B37m	3	1	1	3	2	\N	\N
1JByfO1EuW	2024-02-16 00:04:06.611+00	2024-02-16 00:04:06.611+00	1as6rMOzjQ	M0tHrt1GgV	3	3	2	0	3	\N	\N
Lvwfi1a4e5	2024-02-16 00:04:07.033+00	2024-02-16 00:04:07.033+00	NjxsGlPeB4	na5crB8ED1	3	2	3	1	0	\N	\N
GmGMz5Tw3i	2024-02-16 00:04:07.342+00	2024-02-16 00:04:07.342+00	dEqAHvPMXA	0TvWuLoLF5	0	0	0	3	0	\N	\N
UwTVBD86y0	2024-02-16 00:04:07.674+00	2024-02-16 00:04:07.674+00	sHiqaG4iqY	qP3EdIVzfB	3	3	0	4	0	\N	\N
8hezW3LON5	2024-02-16 00:04:07.96+00	2024-02-16 00:04:07.96+00	jqDYoPT45X	HSEugQ3Ouj	2	4	3	0	0	\N	\N
kHZ2MrfB1d	2024-02-16 00:04:08.487+00	2024-02-16 00:04:08.487+00	NjxsGlPeB4	bQpy9LEJWn	4	3	1	1	0	\N	\N
Tf48vhkxFB	2024-02-16 00:04:08.784+00	2024-02-16 00:04:08.784+00	HtEtaHBVDN	INeptnSdJC	3	3	2	2	4	\N	\N
XR5qfzP7Dv	2024-02-16 00:04:08.983+00	2024-02-16 00:04:08.983+00	HRhGpJpmb5	08liHW08uC	1	0	3	3	3	\N	\N
KG0iw66yCK	2024-02-16 00:04:09.174+00	2024-02-16 00:04:09.174+00	5X202ssb0D	qEQ9tmLyW9	2	4	2	3	3	\N	\N
fKSDRVwyUa	2024-02-16 00:04:09.367+00	2024-02-16 00:04:09.367+00	RWwLSzreG2	08liHW08uC	4	0	3	1	4	\N	\N
vKraO8pU9Q	2024-02-16 00:04:09.558+00	2024-02-16 00:04:09.558+00	WKpBp0c8F3	Pja6n3yaWZ	4	0	4	1	4	\N	\N
fVgBdsgSYl	2024-02-16 00:04:09.754+00	2024-02-16 00:04:09.754+00	Otwj7uJwjr	tCIEnLLcUc	1	2	4	0	3	\N	\N
Jk9f4DJmeJ	2024-02-16 00:04:09.948+00	2024-02-16 00:04:09.948+00	5nv19u6KJ2	HXtEwLBC7f	0	3	1	4	4	\N	\N
ahz2UDjCU2	2024-02-16 00:04:10.142+00	2024-02-16 00:04:10.142+00	jqDYoPT45X	o4VD4BWwDt	2	3	4	2	2	\N	\N
STg6AzzOgV	2024-02-16 00:04:10.339+00	2024-02-16 00:04:10.339+00	HtEtaHBVDN	Pja6n3yaWZ	0	1	0	3	3	\N	\N
0FAHH3U212	2024-02-16 00:04:10.541+00	2024-02-16 00:04:10.541+00	SFAISec8QF	y4RkaDbkec	4	2	1	3	1	\N	\N
LCw3GkszTb	2024-02-16 00:04:10.745+00	2024-02-16 00:04:10.745+00	dZKm0wOhYa	WHvlAGgj6c	0	1	2	0	4	\N	\N
hRwAi608z5	2024-02-16 00:04:10.948+00	2024-02-16 00:04:10.948+00	S6wz0lK0bf	o90lhsZ7FK	1	4	1	2	0	\N	\N
B1x16lK0D3	2024-02-16 00:04:11.149+00	2024-02-16 00:04:11.149+00	WKpBp0c8F3	j0dWqP2C2A	0	2	3	4	3	\N	\N
VHHNGzBRUe	2024-02-16 00:04:11.349+00	2024-02-16 00:04:11.349+00	5nv19u6KJ2	rKyjwoEIRp	1	0	0	2	3	\N	\N
oAFJBJJY7r	2024-02-16 00:04:11.546+00	2024-02-16 00:04:11.546+00	ONgyydfVNz	WBFeKac0OO	1	4	1	4	4	\N	\N
VftRZVzw89	2024-02-16 00:04:11.747+00	2024-02-16 00:04:11.747+00	5X202ssb0D	oABNR2FF6S	2	0	1	4	1	\N	\N
ptWcxy5cdL	2024-02-16 00:04:11.953+00	2024-02-16 00:04:11.953+00	RWwLSzreG2	eEmewy7hPd	4	4	4	3	3	\N	\N
fTAhUqupsc	2024-02-16 00:04:12.157+00	2024-02-16 00:04:12.157+00	mAKp5BK7R1	cmxBcanww9	0	0	0	3	4	\N	\N
Yicw9WXHtT	2024-02-16 00:04:12.374+00	2024-02-16 00:04:12.374+00	5X202ssb0D	fKTSJPdUi9	3	0	4	3	3	\N	\N
7M1DlmoAqi	2024-02-16 00:04:12.585+00	2024-02-16 00:04:12.585+00	5X202ssb0D	cFtamPA0zH	1	4	3	1	1	\N	\N
WakBEAmlXG	2024-02-16 00:04:12.788+00	2024-02-16 00:04:12.788+00	adE9nQrDk3	TpGyMZM9BG	0	1	0	4	4	\N	\N
lqTOr8m9xi	2024-02-16 00:04:12.982+00	2024-02-16 00:04:12.982+00	sHiqaG4iqY	ThMuD3hYRQ	2	1	2	4	1	\N	\N
s2TGEtj305	2024-02-16 00:04:13.182+00	2024-02-16 00:04:13.182+00	iWxl9obi8w	KCsJ4XR6Dn	4	0	2	3	0	\N	\N
2D8mZ1wGnV	2024-02-16 00:04:13.593+00	2024-02-16 00:04:13.593+00	5nv19u6KJ2	D0A6GLdsDM	2	2	4	0	3	\N	\N
ToguQ4CCff	2024-02-16 00:04:14.099+00	2024-02-16 00:04:14.099+00	VshUk7eBeK	HXtEwLBC7f	3	1	4	2	1	\N	\N
p16nsEPxu0	2024-02-16 00:04:15.233+00	2024-02-16 00:04:15.233+00	SFAISec8QF	C7II8dYRPY	4	2	0	3	1	\N	\N
gk9apDp5rF	2024-02-16 00:04:15.436+00	2024-02-16 00:04:15.436+00	5X202ssb0D	vwHi602n66	1	2	0	4	2	\N	\N
NIKCZ5ATxC	2024-02-16 00:04:15.746+00	2024-02-16 00:04:15.746+00	sHiqaG4iqY	3P6kmNoY1F	1	0	2	3	1	\N	\N
XkBKBCktoX	2024-02-16 00:04:15.952+00	2024-02-16 00:04:15.952+00	dZKm0wOhYa	RkhjIQJgou	4	2	1	4	3	\N	\N
a1u7peMlH5	2024-02-16 00:04:16.15+00	2024-02-16 00:04:16.15+00	ONgyydfVNz	14jGmOAXcg	0	0	3	2	0	\N	\N
XvbGvRyuAv	2024-02-16 00:04:16.355+00	2024-02-16 00:04:16.355+00	1as6rMOzjQ	XwszrNEEEj	1	4	4	1	2	\N	\N
FfqEgOVuf3	2024-02-16 00:04:16.562+00	2024-02-16 00:04:16.562+00	mAKp5BK7R1	C7II8dYRPY	3	4	4	3	4	\N	\N
wqMEm6MuuV	2024-02-16 00:04:16.766+00	2024-02-16 00:04:16.766+00	ONgyydfVNz	fwLPZZ8YQa	3	1	1	3	1	\N	\N
YvoeAZc2PZ	2024-02-16 00:04:16.974+00	2024-02-16 00:04:16.974+00	mQXQWNqxg9	ThMuD3hYRQ	1	1	0	4	1	\N	\N
PKeOlFSoM8	2024-02-16 00:04:17.189+00	2024-02-16 00:04:17.189+00	AsrLUQwxI9	3P6kmNoY1F	1	4	0	2	0	\N	\N
kdD7ntEVKN	2024-02-16 00:04:17.384+00	2024-02-16 00:04:17.384+00	opW2wQ2bZ8	Pa0qBO2rzK	2	1	2	0	4	\N	\N
JqRCTrXjf6	2024-02-16 00:04:17.584+00	2024-02-16 00:04:17.584+00	Otwj7uJwjr	XSK814B37m	2	0	1	1	2	\N	\N
4zkgktPnrZ	2024-02-16 00:04:17.791+00	2024-02-16 00:04:17.791+00	SFAISec8QF	cwVEh0dqfm	1	0	3	4	3	\N	\N
YOFRe1F2I6	2024-02-16 00:04:18.001+00	2024-02-16 00:04:18.001+00	ONgyydfVNz	UCFo58JaaD	3	2	3	2	1	\N	\N
yFNFYfxlHF	2024-02-16 00:04:18.208+00	2024-02-16 00:04:18.208+00	mQXQWNqxg9	cwVEh0dqfm	2	0	4	3	2	\N	\N
985uyJPh7g	2024-02-16 00:04:18.43+00	2024-02-16 00:04:18.43+00	sHiqaG4iqY	3u4B9V4l5K	2	1	3	3	2	\N	\N
4S6UYihHcm	2024-02-16 00:04:18.637+00	2024-02-16 00:04:18.637+00	mAKp5BK7R1	oABNR2FF6S	2	3	3	3	4	\N	\N
dGIqB9RR8m	2024-02-16 00:04:18.843+00	2024-02-16 00:04:18.843+00	mAKp5BK7R1	9GF3y7LmHV	4	2	4	2	1	\N	\N
B8hOaEGjlx	2024-02-16 00:04:19.039+00	2024-02-16 00:04:19.039+00	HtEtaHBVDN	fKTSJPdUi9	2	1	4	3	4	\N	\N
TOyv0FUJQs	2024-02-16 00:04:19.248+00	2024-02-16 00:04:19.248+00	RWwLSzreG2	XpUyRlB6FI	2	0	0	2	1	\N	\N
lrJHGYku8H	2024-02-16 00:04:19.455+00	2024-02-16 00:04:19.455+00	HtEtaHBVDN	UCFo58JaaD	4	2	0	2	1	\N	\N
1gKYH3E9XH	2024-02-16 00:04:19.665+00	2024-02-16 00:04:19.665+00	NjxsGlPeB4	FYXEfIO1zF	2	0	2	1	0	\N	\N
I2wrD2KgMv	2024-02-16 00:04:19.872+00	2024-02-16 00:04:19.872+00	S6wz0lK0bf	yvUod6yLDt	4	1	2	3	1	\N	\N
8lQLbX7oEd	2024-02-16 00:04:20.077+00	2024-02-16 00:04:20.077+00	5nv19u6KJ2	j0dWqP2C2A	4	0	4	4	2	\N	\N
BoWynnqYdn	2024-02-16 00:04:20.394+00	2024-02-16 00:04:20.394+00	9223vtvaBd	XSK814B37m	0	1	4	3	0	\N	\N
yuD5kcB6f5	2024-02-16 00:04:21.068+00	2024-02-16 00:04:21.068+00	opW2wQ2bZ8	WSTLlXDcKl	3	4	2	4	3	\N	\N
nNbGfPYCMV	2024-02-16 00:04:21.686+00	2024-02-16 00:04:21.686+00	adE9nQrDk3	KCsJ4XR6Dn	1	2	0	4	0	\N	\N
wzhMIag5hO	2024-02-16 00:04:21.896+00	2024-02-16 00:04:21.896+00	5nv19u6KJ2	TpGyMZM9BG	1	1	0	2	0	\N	\N
IQfVy1Ow4g	2024-02-16 00:04:22.499+00	2024-02-16 00:04:22.499+00	SFAISec8QF	NY6RE1qgWu	1	0	4	2	0	\N	\N
V0vzsQEHmb	2024-02-16 00:04:23.113+00	2024-02-16 00:04:23.113+00	jqDYoPT45X	m8hjjLVdPS	1	4	1	3	4	\N	\N
n5AtZg5BNp	2024-02-16 00:04:23.324+00	2024-02-16 00:04:23.324+00	jqDYoPT45X	TZsdmscJ2B	1	4	3	0	0	\N	\N
O1sTmQIEB9	2024-02-16 00:04:23.531+00	2024-02-16 00:04:23.531+00	S6wz0lK0bf	FYXEfIO1zF	1	4	4	2	3	\N	\N
Mrj9PCHIIB	2024-02-16 00:04:23.741+00	2024-02-16 00:04:23.741+00	9223vtvaBd	axyV0Fu7pm	4	1	4	0	1	\N	\N
9lyl9Er6DF	2024-02-16 00:04:23.95+00	2024-02-16 00:04:23.95+00	I5RzFRcQ7G	IEqTHcohpJ	4	2	4	3	1	\N	\N
MgBtHa1SyZ	2024-02-16 00:04:24.161+00	2024-02-16 00:04:24.161+00	iUlyHNFGpG	Oahm9sOn1y	3	3	1	0	2	\N	\N
KJkxI3kWBj	2024-02-16 00:04:24.372+00	2024-02-16 00:04:24.372+00	mQXQWNqxg9	HXtEwLBC7f	2	0	0	0	1	\N	\N
KOpJbkI4bK	2024-02-16 00:04:24.583+00	2024-02-16 00:04:24.583+00	iWxl9obi8w	LVYK4mLShP	4	3	0	0	2	\N	\N
PGeUquGAhU	2024-02-16 00:04:24.794+00	2024-02-16 00:04:24.794+00	RWwLSzreG2	ThMuD3hYRQ	4	4	1	0	1	\N	\N
IVIecO2fvY	2024-02-16 00:04:25.005+00	2024-02-16 00:04:25.005+00	WKpBp0c8F3	NBojpORh3G	0	4	0	0	3	\N	\N
LDFLr0ZNma	2024-02-16 00:04:25.265+00	2024-02-16 00:04:25.265+00	S6wz0lK0bf	l1Bslv8T2k	0	4	4	2	2	\N	\N
qbadxznjZz	2024-02-16 00:04:25.475+00	2024-02-16 00:04:25.475+00	HRhGpJpmb5	fxvABtKCPT	3	0	2	4	2	\N	\N
9HGD2Fq7Bd	2024-02-16 00:04:25.687+00	2024-02-16 00:04:25.687+00	I5RzFRcQ7G	qP3EdIVzfB	4	3	4	4	0	\N	\N
2GiA2CjcIy	2024-02-16 00:04:26.291+00	2024-02-16 00:04:26.291+00	VshUk7eBeK	0TvWuLoLF5	1	4	1	3	2	\N	\N
Q8SvLXcCfA	2024-02-16 00:04:26.597+00	2024-02-16 00:04:26.597+00	Otwj7uJwjr	NY6RE1qgWu	2	1	0	1	2	\N	\N
UZvmJNDD1P	2024-02-16 00:04:27.005+00	2024-02-16 00:04:27.005+00	5X202ssb0D	INeptnSdJC	2	0	2	2	2	\N	\N
q6RAnD7lFu	2024-02-16 00:04:27.313+00	2024-02-16 00:04:27.313+00	sHiqaG4iqY	NY6RE1qgWu	0	4	0	0	4	\N	\N
F89U6rCuGI	2024-02-16 00:04:27.616+00	2024-02-16 00:04:27.616+00	S6wz0lK0bf	G0uU7KQLEt	0	1	0	4	3	\N	\N
sQV2EvAbbl	2024-02-16 00:04:27.927+00	2024-02-16 00:04:27.927+00	adE9nQrDk3	XwWwGnkXNj	3	3	1	4	0	\N	\N
E6XkmrYlBa	2024-02-16 00:04:28.233+00	2024-02-16 00:04:28.233+00	mQXQWNqxg9	LgJuu5ABe5	1	0	3	4	0	\N	\N
5DETBl0tjO	2024-02-16 00:04:28.562+00	2024-02-16 00:04:28.562+00	SFAISec8QF	rT0UCBK1bE	4	0	4	3	1	\N	\N
fwA9eRaQZk	2024-02-16 00:04:28.85+00	2024-02-16 00:04:28.85+00	opW2wQ2bZ8	m8hjjLVdPS	4	3	0	2	2	\N	\N
Edyi7psr7W	2024-02-16 00:04:29.157+00	2024-02-16 00:04:29.157+00	mAKp5BK7R1	NBojpORh3G	2	2	0	3	4	\N	\N
ZrC6ACT41C	2024-02-16 00:04:29.372+00	2024-02-16 00:04:29.372+00	mAKp5BK7R1	AgU9OLJkqz	2	2	2	4	4	\N	\N
8VWIGqmFrT	2024-02-16 00:04:29.67+00	2024-02-16 00:04:29.67+00	I5RzFRcQ7G	JRi61dUphq	3	1	0	1	0	\N	\N
PoVbrqm8OP	2024-02-16 00:04:29.976+00	2024-02-16 00:04:29.976+00	S6wz0lK0bf	JLhF4VuByh	1	0	2	0	4	\N	\N
sZQdCGB14D	2024-02-16 00:04:30.387+00	2024-02-16 00:04:30.387+00	AsrLUQwxI9	cTIjuPjyIa	3	3	0	0	1	\N	\N
VPsWOo2XkR	2024-02-16 00:04:30.606+00	2024-02-16 00:04:30.606+00	sHiqaG4iqY	cwVEh0dqfm	2	0	1	2	1	\N	\N
4H5ihq5CNi	2024-02-16 00:04:30.827+00	2024-02-16 00:04:30.827+00	sHiqaG4iqY	o90lhsZ7FK	0	1	0	4	0	\N	\N
JgzC3KEMtG	2024-02-16 00:04:31.096+00	2024-02-16 00:04:31.096+00	5X202ssb0D	cFtamPA0zH	3	0	0	4	0	\N	\N
ZKXSC4y4rA	2024-02-16 00:04:31.309+00	2024-02-16 00:04:31.309+00	5nv19u6KJ2	y4RkaDbkec	0	4	3	3	4	\N	\N
fnmx59EN0T	2024-02-16 00:04:31.531+00	2024-02-16 00:04:31.531+00	HtEtaHBVDN	cwVEh0dqfm	2	0	3	0	2	\N	\N
6dXPM53pGY	2024-02-16 00:04:31.745+00	2024-02-16 00:04:31.745+00	NjxsGlPeB4	rKyjwoEIRp	4	3	4	1	2	\N	\N
QZHLaWepd6	2024-02-16 00:04:31.959+00	2024-02-16 00:04:31.959+00	sHiqaG4iqY	LVYK4mLShP	2	1	2	3	4	\N	\N
rcrRG2umJ4	2024-02-16 00:04:32.174+00	2024-02-16 00:04:32.174+00	9223vtvaBd	WnUBBkiDjE	3	1	2	4	3	\N	\N
t7hp5hoF8s	2024-02-16 00:04:32.377+00	2024-02-16 00:04:32.377+00	5nv19u6KJ2	Pa0qBO2rzK	3	4	1	3	2	\N	\N
RyjfwfApxF	2024-02-16 00:04:32.587+00	2024-02-16 00:04:32.587+00	NjxsGlPeB4	INeptnSdJC	0	0	2	3	3	\N	\N
2QGZD8pq4E	2024-02-16 00:04:32.801+00	2024-02-16 00:04:32.801+00	sHiqaG4iqY	tCIEnLLcUc	1	0	0	2	3	\N	\N
7zpXITOq5y	2024-02-16 00:04:33.016+00	2024-02-16 00:04:33.016+00	dEqAHvPMXA	na5crB8ED1	4	4	4	0	0	\N	\N
4pLPVMMFYK	2024-02-16 00:04:33.238+00	2024-02-16 00:04:33.238+00	adE9nQrDk3	m6g8u0QpTC	0	2	0	2	4	\N	\N
h5GQpdG28r	2024-02-16 00:04:33.56+00	2024-02-16 00:04:33.56+00	mQXQWNqxg9	M0tHrt1GgV	3	1	0	0	4	\N	\N
RhkHhY5B6k	2024-02-16 00:04:33.772+00	2024-02-16 00:04:33.772+00	VshUk7eBeK	6KvFK8yy1q	3	0	3	3	3	\N	\N
u55muP5J0q	2024-02-16 00:04:33.982+00	2024-02-16 00:04:33.982+00	sHiqaG4iqY	LVYK4mLShP	3	2	0	2	2	\N	\N
2bOqyMuDLR	2024-02-16 00:04:34.192+00	2024-02-16 00:04:34.192+00	iUlyHNFGpG	9GF3y7LmHV	0	4	2	2	1	\N	\N
BVaaRi8nuZ	2024-02-16 00:04:34.583+00	2024-02-16 00:04:34.583+00	ONgyydfVNz	VK3vnSxIy8	3	0	3	4	1	\N	\N
TbDkpTpvBW	2024-02-16 00:04:34.89+00	2024-02-16 00:04:34.89+00	adE9nQrDk3	8w7i8C3NnT	0	0	3	4	4	\N	\N
yZQqFbuKp5	2024-02-16 00:04:35.198+00	2024-02-16 00:04:35.198+00	HtEtaHBVDN	uigc7bJBOJ	2	0	3	4	4	\N	\N
bxO94rwQYy	2024-02-16 00:04:35.507+00	2024-02-16 00:04:35.507+00	S6wz0lK0bf	HXtEwLBC7f	0	2	0	2	3	\N	\N
EaP2tNqS5Q	2024-02-16 00:04:35.815+00	2024-02-16 00:04:35.815+00	iWxl9obi8w	MQfxuw3ERg	0	0	4	4	1	\N	\N
dL9ZZ7TKKD	2024-02-16 00:04:36.035+00	2024-02-16 00:04:36.035+00	Otwj7uJwjr	na5crB8ED1	4	2	3	2	1	\N	\N
QZE8ppLKg1	2024-02-16 00:04:36.251+00	2024-02-16 00:04:36.251+00	5X202ssb0D	UCFo58JaaD	1	4	2	0	3	\N	\N
jKn0A3mv7y	2024-02-16 00:04:36.835+00	2024-02-16 00:04:36.835+00	RWwLSzreG2	6Fo67rhTSP	2	0	3	4	1	\N	\N
ti4caTfyhN	2024-02-16 00:04:37.095+00	2024-02-16 00:04:37.095+00	iUlyHNFGpG	e037qpAih3	3	1	3	0	0	\N	\N
1xSiEbWZwk	2024-02-16 00:04:37.307+00	2024-02-16 00:04:37.307+00	mQXQWNqxg9	WBFeKac0OO	2	0	4	2	0	\N	\N
QFJnAbreAg	2024-02-16 00:04:37.518+00	2024-02-16 00:04:37.518+00	S6wz0lK0bf	9GF3y7LmHV	0	1	2	0	0	\N	\N
KgAaZORuD8	2024-02-16 00:04:37.758+00	2024-02-16 00:04:37.758+00	5X202ssb0D	HXtEwLBC7f	1	0	4	4	3	\N	\N
e0f0zqD0LK	2024-02-16 00:04:37.967+00	2024-02-16 00:04:37.967+00	SFAISec8QF	o4VD4BWwDt	4	1	2	4	1	\N	\N
nCKwEg9Dhn	2024-02-16 00:04:38.176+00	2024-02-16 00:04:38.176+00	ONgyydfVNz	8w7i8C3NnT	4	0	0	4	2	\N	\N
Q7AtO3O9Li	2024-02-16 00:04:38.387+00	2024-02-16 00:04:38.387+00	9223vtvaBd	XwszrNEEEj	4	4	3	2	0	\N	\N
EaE0xQbY88	2024-02-16 00:04:38.6+00	2024-02-16 00:04:38.6+00	SFAISec8QF	o90lhsZ7FK	0	0	2	2	2	\N	\N
g5xaQZcrYS	2024-02-16 00:04:38.817+00	2024-02-16 00:04:38.817+00	5nv19u6KJ2	IybX0eBoO3	1	4	3	3	1	\N	\N
m0KnivAXFH	2024-02-16 00:04:39.025+00	2024-02-16 00:04:39.025+00	iUlyHNFGpG	H40ivltLwZ	0	2	2	3	3	\N	\N
s7m7wSTFiB	2024-02-16 00:04:39.23+00	2024-02-16 00:04:39.23+00	9223vtvaBd	TpGyMZM9BG	4	4	2	4	3	\N	\N
n6ub1Xj5bA	2024-02-16 00:04:39.44+00	2024-02-16 00:04:39.44+00	adE9nQrDk3	Gl96vGdYHM	1	1	2	0	4	\N	\N
d7j7tHLeJ9	2024-02-16 00:04:39.651+00	2024-02-16 00:04:39.651+00	iUlyHNFGpG	bQ0JOk10eL	0	0	3	4	3	\N	\N
ch7yo4nTxU	2024-02-16 00:04:39.86+00	2024-02-16 00:04:39.86+00	Otwj7uJwjr	m8hjjLVdPS	4	0	0	2	4	\N	\N
lKNqY3aWbA	2024-02-16 00:04:40.071+00	2024-02-16 00:04:40.071+00	mQXQWNqxg9	WnUBBkiDjE	3	0	3	0	3	\N	\N
pLHaKBoHif	2024-02-16 00:04:40.281+00	2024-02-16 00:04:40.281+00	S6wz0lK0bf	y4RkaDbkec	0	0	3	2	1	\N	\N
hBH0wGzjpV	2024-02-16 00:04:40.491+00	2024-02-16 00:04:40.491+00	9223vtvaBd	P9sBFomftT	3	3	1	2	4	\N	\N
JVVpY2ovjC	2024-02-16 00:04:40.706+00	2024-02-16 00:04:40.706+00	RWwLSzreG2	89xRG1afNi	1	3	2	2	3	\N	\N
0Edg8s8Xfj	2024-02-16 00:04:41.03+00	2024-02-16 00:04:41.03+00	iWxl9obi8w	l1Bslv8T2k	4	1	3	2	2	\N	\N
hrKkRw3Lbn	2024-02-16 00:04:41.341+00	2024-02-16 00:04:41.341+00	opW2wQ2bZ8	WnUBBkiDjE	0	2	2	4	2	\N	\N
BIqxJQpj9u	2024-02-16 00:04:41.643+00	2024-02-16 00:04:41.643+00	dZKm0wOhYa	XSK814B37m	1	0	0	1	0	\N	\N
ZpnUbFYMut	2024-02-16 00:04:42.059+00	2024-02-16 00:04:42.059+00	HRhGpJpmb5	eEmewy7hPd	4	4	2	2	2	\N	\N
70YlHFZh2r	2024-02-16 00:04:42.467+00	2024-02-16 00:04:42.467+00	HRhGpJpmb5	89xRG1afNi	2	2	3	0	4	\N	\N
YhJB9f41QG	2024-02-16 00:04:42.773+00	2024-02-16 00:04:42.773+00	mQXQWNqxg9	fKTSJPdUi9	2	1	1	1	4	\N	\N
G1YwZL3T3e	2024-02-16 00:04:42.984+00	2024-02-16 00:04:42.984+00	Otwj7uJwjr	MQfxuw3ERg	4	1	4	4	1	\N	\N
7P3XFJuN9P	2024-02-16 00:04:43.194+00	2024-02-16 00:04:43.194+00	sy1HD51LXT	cmxBcanww9	3	1	0	0	0	\N	\N
PUygqaCumE	2024-02-16 00:04:43.493+00	2024-02-16 00:04:43.493+00	I5RzFRcQ7G	WBFeKac0OO	3	3	3	3	2	\N	\N
QPsxTU12WY	2024-02-16 00:04:43.799+00	2024-02-16 00:04:43.799+00	mQXQWNqxg9	NY6RE1qgWu	2	4	3	3	1	\N	\N
6hZAUPdLZd	2024-02-16 00:04:44.412+00	2024-02-16 00:04:44.412+00	dZKm0wOhYa	XpUyRlB6FI	0	3	4	4	2	\N	\N
AFUOdHWwe1	2024-02-16 00:04:44.621+00	2024-02-16 00:04:44.621+00	SFAISec8QF	XwWwGnkXNj	1	1	2	0	2	\N	\N
G6sFzsg7FX	2024-02-16 00:04:44.924+00	2024-02-16 00:04:44.924+00	HRhGpJpmb5	CSvk1ycWXk	3	3	0	3	4	\N	\N
EnK0BZLaoa	2024-02-16 00:04:45.232+00	2024-02-16 00:04:45.232+00	HtEtaHBVDN	RBRcyltRSC	3	0	1	0	2	\N	\N
8RJkfAmRn8	2024-02-16 00:04:45.642+00	2024-02-16 00:04:45.642+00	I5RzFRcQ7G	uABtFsJhJc	3	0	3	3	2	\N	\N
22682n6Pzo	2024-02-16 00:04:45.855+00	2024-02-16 00:04:45.855+00	AsrLUQwxI9	Pa0qBO2rzK	0	0	0	4	2	\N	\N
XXQnV343UX	2024-02-16 00:04:46.155+00	2024-02-16 00:04:46.155+00	opW2wQ2bZ8	tCIEnLLcUc	0	0	1	1	1	\N	\N
GBYwnpkB9z	2024-02-16 00:04:46.461+00	2024-02-16 00:04:46.461+00	I5RzFRcQ7G	TZsdmscJ2B	3	1	2	3	4	\N	\N
I4a3aDx2Fb	2024-02-16 00:04:46.767+00	2024-02-16 00:04:46.767+00	HRhGpJpmb5	6Fo67rhTSP	3	2	4	0	3	\N	\N
cGcj1Vh1rb	2024-02-16 00:04:46.979+00	2024-02-16 00:04:46.979+00	mAKp5BK7R1	8w7i8C3NnT	3	2	4	4	0	\N	\N
GfdNnW6QMK	2024-02-16 00:04:47.194+00	2024-02-16 00:04:47.194+00	mQXQWNqxg9	lxQA9rtSfY	3	2	4	3	0	\N	\N
g4IyXSvMq3	2024-02-16 00:04:47.406+00	2024-02-16 00:04:47.406+00	iWxl9obi8w	M0tHrt1GgV	0	1	1	3	4	\N	\N
Pwt8sU2a3n	2024-02-16 00:04:47.615+00	2024-02-16 00:04:47.615+00	dZKm0wOhYa	E2hBZzDsjO	3	4	4	0	2	\N	\N
3WyXXXcVPb	2024-02-16 00:04:47.895+00	2024-02-16 00:04:47.895+00	dZKm0wOhYa	PF8w2gMAdi	1	0	1	4	0	\N	\N
TcIiezLaxL	2024-02-16 00:04:48.106+00	2024-02-16 00:04:48.106+00	Otwj7uJwjr	G0uU7KQLEt	3	3	0	4	4	\N	\N
PbnSruaw0q	2024-02-16 00:04:48.508+00	2024-02-16 00:04:48.508+00	Otwj7uJwjr	LgJuu5ABe5	0	2	3	3	3	\N	\N
9g2nTjigzO	2024-02-16 00:04:48.919+00	2024-02-16 00:04:48.919+00	HRhGpJpmb5	0TvWuLoLF5	1	4	3	3	0	\N	\N
rg9KbcWrG4	2024-02-16 00:04:49.431+00	2024-02-16 00:04:49.431+00	sHiqaG4iqY	AgU9OLJkqz	1	1	0	3	0	\N	\N
B6swcPMOYg	2024-02-16 00:04:50.045+00	2024-02-16 00:04:50.045+00	dEqAHvPMXA	AgU9OLJkqz	4	0	4	3	4	\N	\N
h0DAA2BmWt	2024-02-16 00:04:50.253+00	2024-02-16 00:04:50.253+00	SFAISec8QF	14jGmOAXcg	4	3	4	0	2	\N	\N
U34eeAAqsM	2024-02-16 00:04:50.556+00	2024-02-16 00:04:50.556+00	iWxl9obi8w	j0dWqP2C2A	0	1	2	2	2	\N	\N
RnlcIC9Ydd	2024-02-16 00:04:50.768+00	2024-02-16 00:04:50.768+00	sy1HD51LXT	tCIEnLLcUc	3	1	1	1	2	\N	\N
ZejgM2b1oA	2024-02-16 00:04:50.979+00	2024-02-16 00:04:50.979+00	adE9nQrDk3	o90lhsZ7FK	4	2	1	4	0	\N	\N
I8FDPLCma6	2024-02-16 00:04:51.187+00	2024-02-16 00:04:51.187+00	1as6rMOzjQ	lxQA9rtSfY	0	4	3	2	4	\N	\N
97OOkS0kiH	2024-02-16 00:04:51.395+00	2024-02-16 00:04:51.395+00	S6wz0lK0bf	3u4B9V4l5K	1	2	4	0	1	\N	\N
sjegt3vCWi	2024-02-16 00:04:52.092+00	2024-02-16 00:04:52.092+00	HtEtaHBVDN	o4VD4BWwDt	4	1	0	1	2	\N	\N
B6IIKuJ9xx	2024-02-16 00:04:52.708+00	2024-02-16 00:04:52.708+00	I5RzFRcQ7G	6Fo67rhTSP	2	3	1	3	1	\N	\N
iEhjBoqZuX	2024-02-16 00:04:52.915+00	2024-02-16 00:04:52.915+00	5X202ssb0D	o90lhsZ7FK	1	3	2	3	1	\N	\N
fG1MwqTWNc	2024-02-16 00:04:53.122+00	2024-02-16 00:04:53.122+00	sHiqaG4iqY	tCIEnLLcUc	3	3	3	4	3	\N	\N
vm4OGGL38o	2024-02-16 00:04:53.424+00	2024-02-16 00:04:53.424+00	AsrLUQwxI9	G0uU7KQLEt	1	4	2	0	1	\N	\N
JdklT9PRd7	2024-02-16 00:04:53.633+00	2024-02-16 00:04:53.633+00	S6wz0lK0bf	LDrIH1vU8x	3	1	3	4	1	\N	\N
8Q2hpTcZiG	2024-02-16 00:04:53.903+00	2024-02-16 00:04:53.903+00	R2CLtFh5jU	RBRcyltRSC	2	3	2	4	0	\N	\N
WugkgLIzi9	2024-02-16 00:04:54.242+00	2024-02-16 00:04:54.242+00	VshUk7eBeK	Gl96vGdYHM	0	0	4	4	3	\N	\N
ez2HrLAkAB	2024-02-16 00:04:54.855+00	2024-02-16 00:04:54.855+00	Otwj7uJwjr	TZsdmscJ2B	0	2	3	2	1	\N	\N
qloKVbRchw	2024-02-16 00:04:55.164+00	2024-02-16 00:04:55.164+00	SFAISec8QF	CSvk1ycWXk	4	1	3	4	4	\N	\N
T8AU8yeWiB	2024-02-16 00:04:55.471+00	2024-02-16 00:04:55.471+00	sy1HD51LXT	m6g8u0QpTC	2	3	2	4	4	\N	\N
pbCmXP5LBd	2024-02-16 00:04:56.187+00	2024-02-16 00:04:56.187+00	AsrLUQwxI9	e037qpAih3	2	4	3	4	1	\N	\N
lrEBJdWcww	2024-02-16 00:04:56.396+00	2024-02-16 00:04:56.396+00	sy1HD51LXT	XwszrNEEEj	3	3	4	1	1	\N	\N
vMNiGY9efr	2024-02-16 00:04:56.6+00	2024-02-16 00:04:56.6+00	mQXQWNqxg9	o90lhsZ7FK	1	0	0	2	3	\N	\N
rJNljk3hjt	2024-02-16 00:04:56.902+00	2024-02-16 00:04:56.902+00	Otwj7uJwjr	08liHW08uC	2	2	2	2	1	\N	\N
JlTKCYQqx0	2024-02-16 00:04:57.212+00	2024-02-16 00:04:57.212+00	sHiqaG4iqY	m8hjjLVdPS	4	1	4	2	1	\N	\N
ERRSn1JKUy	2024-02-16 00:04:57.628+00	2024-02-16 00:04:57.628+00	WKpBp0c8F3	XwszrNEEEj	4	0	4	4	0	\N	\N
7cFw7eWhVc	2024-02-16 00:04:58.03+00	2024-02-16 00:04:58.03+00	HRhGpJpmb5	TpGyMZM9BG	1	3	4	2	4	\N	\N
gTgtbP8tG0	2024-02-16 00:04:58.442+00	2024-02-16 00:04:58.442+00	RWwLSzreG2	G0uU7KQLEt	0	0	1	1	2	\N	\N
HaTY1WWlNL	2024-02-16 00:04:58.75+00	2024-02-16 00:04:58.75+00	dZKm0wOhYa	lEPdiO1EDi	2	3	3	3	1	\N	\N
V4h6Ilq3Zv	2024-02-16 00:04:59.053+00	2024-02-16 00:04:59.053+00	R2CLtFh5jU	bQpy9LEJWn	1	1	2	0	1	\N	\N
ejFVzhOFc9	2024-02-16 00:04:59.465+00	2024-02-16 00:04:59.465+00	sy1HD51LXT	Gl96vGdYHM	3	1	1	1	1	\N	\N
DARB9d9exp	2024-02-16 00:04:59.873+00	2024-02-16 00:04:59.873+00	Otwj7uJwjr	vwHi602n66	3	3	0	2	1	\N	\N
HaGLp1kX4h	2024-02-16 00:05:00.079+00	2024-02-16 00:05:00.079+00	SFAISec8QF	oABNR2FF6S	1	0	1	3	0	\N	\N
M9OAEmPBaM	2024-02-16 00:05:00.29+00	2024-02-16 00:05:00.29+00	sy1HD51LXT	FYXEfIO1zF	0	1	3	0	1	\N	\N
U2U9GsliZn	2024-02-16 00:05:00.5+00	2024-02-16 00:05:00.5+00	sy1HD51LXT	WSTLlXDcKl	4	2	2	2	3	\N	\N
2yXlAjojEJ	2024-02-16 00:05:00.707+00	2024-02-16 00:05:00.707+00	ONgyydfVNz	y4RkaDbkec	3	3	4	2	3	\N	\N
ZUqcf8QZRM	2024-02-16 00:05:00.914+00	2024-02-16 00:05:00.914+00	R2CLtFh5jU	lxQA9rtSfY	0	2	2	4	1	\N	\N
4X3WkrTHyc	2024-02-16 00:05:01.12+00	2024-02-16 00:05:01.12+00	HtEtaHBVDN	UDXF0qXvDY	3	4	2	0	4	\N	\N
Aafquybg34	2024-02-16 00:05:01.325+00	2024-02-16 00:05:01.325+00	S6wz0lK0bf	XSK814B37m	2	4	4	2	1	\N	\N
pNa0V62FXu	2024-02-16 00:05:01.535+00	2024-02-16 00:05:01.535+00	mQXQWNqxg9	e037qpAih3	1	3	3	2	0	\N	\N
Gv5MmgWZVh	2024-02-16 00:05:01.745+00	2024-02-16 00:05:01.745+00	R2CLtFh5jU	HXtEwLBC7f	2	3	4	0	2	\N	\N
6XZOGBiIuq	2024-02-16 00:05:02.025+00	2024-02-16 00:05:02.025+00	mAKp5BK7R1	e037qpAih3	2	0	1	3	3	\N	\N
5niWPEltqb	2024-02-16 00:05:02.231+00	2024-02-16 00:05:02.231+00	NjxsGlPeB4	bi1IivsuUB	4	1	0	3	3	\N	\N
F1GBIgcZL1	2024-02-16 00:05:02.537+00	2024-02-16 00:05:02.537+00	opW2wQ2bZ8	fKTSJPdUi9	2	0	1	2	1	\N	\N
XkJhl2vF5H	2024-02-16 00:05:03.15+00	2024-02-16 00:05:03.15+00	5X202ssb0D	l1Bslv8T2k	3	1	2	3	2	\N	\N
wLCCT2WpDA	2024-02-16 00:05:03.363+00	2024-02-16 00:05:03.363+00	5X202ssb0D	89xRG1afNi	2	4	2	2	2	\N	\N
SIcivO8P9a	2024-02-16 00:05:03.575+00	2024-02-16 00:05:03.575+00	dZKm0wOhYa	cmxBcanww9	3	4	4	2	3	\N	\N
FTx0HmNDxs	2024-02-16 00:05:03.869+00	2024-02-16 00:05:03.869+00	dZKm0wOhYa	EmIUBFwx0Z	2	0	0	0	1	\N	\N
pjM0K7uTuc	2024-02-16 00:05:04.176+00	2024-02-16 00:05:04.176+00	sy1HD51LXT	rKyjwoEIRp	2	4	3	4	4	\N	\N
tCYUxJh3cl	2024-02-16 00:05:04.387+00	2024-02-16 00:05:04.387+00	iUlyHNFGpG	WBFeKac0OO	4	1	3	4	4	\N	\N
TGMV1C3v56	2024-02-16 00:05:04.69+00	2024-02-16 00:05:04.69+00	adE9nQrDk3	G0uU7KQLEt	2	1	4	4	3	\N	\N
WXhkL4gMLb	2024-02-16 00:05:04.995+00	2024-02-16 00:05:04.995+00	5nv19u6KJ2	qEQ9tmLyW9	0	2	3	2	0	\N	\N
JrHR7wUIjV	2024-02-16 00:05:05.303+00	2024-02-16 00:05:05.303+00	AsrLUQwxI9	m8hjjLVdPS	1	2	4	3	2	\N	\N
3E6OpUxtL2	2024-02-16 00:05:05.511+00	2024-02-16 00:05:05.511+00	I5RzFRcQ7G	uABtFsJhJc	2	3	2	3	4	\N	\N
vWCsuv8HDg	2024-02-16 00:05:05.721+00	2024-02-16 00:05:05.721+00	AsrLUQwxI9	M0tHrt1GgV	2	4	3	2	4	\N	\N
6rxYmKMCqN	2024-02-16 00:05:05.936+00	2024-02-16 00:05:05.936+00	HRhGpJpmb5	fwLPZZ8YQa	3	3	3	3	4	\N	\N
WvFC0NcIQA	2024-02-16 00:05:06.143+00	2024-02-16 00:05:06.143+00	SFAISec8QF	JLhF4VuByh	1	4	1	2	1	\N	\N
G9C2ws0vXC	2024-02-16 00:05:06.35+00	2024-02-16 00:05:06.35+00	mAKp5BK7R1	P9sBFomftT	2	3	1	1	3	\N	\N
rdgqG1GfsY	2024-02-16 00:05:06.634+00	2024-02-16 00:05:06.634+00	S6wz0lK0bf	3P6kmNoY1F	1	2	0	4	0	\N	\N
IgqLmpED1Q	2024-02-16 00:05:06.943+00	2024-02-16 00:05:06.943+00	iWxl9obi8w	G0uU7KQLEt	1	4	4	2	1	\N	\N
fH5sQLPF0N	2024-02-16 00:05:07.151+00	2024-02-16 00:05:07.151+00	AsrLUQwxI9	H40ivltLwZ	3	2	2	3	2	\N	\N
NRijXMJOBo	2024-02-16 00:05:07.36+00	2024-02-16 00:05:07.36+00	I5RzFRcQ7G	eEmewy7hPd	2	0	2	2	3	\N	\N
cl01yvf3UU	2024-02-16 00:05:07.568+00	2024-02-16 00:05:07.568+00	sHiqaG4iqY	eEmewy7hPd	0	0	4	2	4	\N	\N
GyycrWZQuR	2024-02-16 00:05:08.168+00	2024-02-16 00:05:08.168+00	1as6rMOzjQ	C7II8dYRPY	0	2	2	4	1	\N	\N
QnUEVxsRnK	2024-02-16 00:05:08.377+00	2024-02-16 00:05:08.377+00	S6wz0lK0bf	BMLzFMvIT6	2	1	2	2	3	\N	\N
NqZeTZ1m5l	2024-02-16 00:05:08.59+00	2024-02-16 00:05:08.59+00	sy1HD51LXT	Oahm9sOn1y	0	3	4	2	3	\N	\N
VkVilqXbmm	2024-02-16 00:05:08.8+00	2024-02-16 00:05:08.8+00	5X202ssb0D	fxvABtKCPT	1	3	0	4	3	\N	\N
vBhxr993GS	2024-02-16 00:05:09.006+00	2024-02-16 00:05:09.006+00	HRhGpJpmb5	3u4B9V4l5K	3	3	0	1	1	\N	\N
K6b6gILqC1	2024-02-16 00:05:09.214+00	2024-02-16 00:05:09.214+00	opW2wQ2bZ8	3u4B9V4l5K	1	0	4	1	4	\N	\N
hBbD1V5CSQ	2024-02-16 00:05:09.424+00	2024-02-16 00:05:09.424+00	1as6rMOzjQ	NY6RE1qgWu	0	3	0	3	3	\N	\N
A1mDGGxHp4	2024-02-16 00:05:09.639+00	2024-02-16 00:05:09.639+00	iUlyHNFGpG	6Fo67rhTSP	1	4	0	3	2	\N	\N
Qr5FN43Ud3	2024-02-16 00:05:09.851+00	2024-02-16 00:05:09.851+00	I5RzFRcQ7G	IybX0eBoO3	2	3	3	4	4	\N	\N
fr94jfQFwJ	2024-02-16 00:05:10.114+00	2024-02-16 00:05:10.114+00	RWwLSzreG2	D0A6GLdsDM	3	4	4	4	0	\N	\N
oNeoctJBlw	2024-02-16 00:05:10.319+00	2024-02-16 00:05:10.319+00	iWxl9obi8w	XwszrNEEEj	3	3	2	4	3	\N	\N
78sXcYNcIo	2024-02-16 00:05:10.522+00	2024-02-16 00:05:10.522+00	Otwj7uJwjr	BMLzFMvIT6	0	1	3	4	1	\N	\N
3e1tVz54As	2024-02-16 00:05:10.724+00	2024-02-16 00:05:10.724+00	sy1HD51LXT	M0tHrt1GgV	3	1	3	2	1	\N	\N
UznrL47vGr	2024-02-16 00:05:10.932+00	2024-02-16 00:05:10.932+00	5nv19u6KJ2	lEPdiO1EDi	3	2	3	3	1	\N	\N
hTuI9H13EP	2024-02-16 00:05:11.139+00	2024-02-16 00:05:11.139+00	I5RzFRcQ7G	JRi61dUphq	3	2	1	3	2	\N	\N
aDX0sMFvsY	2024-02-16 00:05:11.347+00	2024-02-16 00:05:11.347+00	I5RzFRcQ7G	0TvWuLoLF5	4	2	2	1	3	\N	\N
l2SVkUOBuD	2024-02-16 00:05:11.555+00	2024-02-16 00:05:11.555+00	RWwLSzreG2	o90lhsZ7FK	3	2	1	3	2	\N	\N
h8M5UWXA79	2024-02-16 00:05:11.765+00	2024-02-16 00:05:11.765+00	Otwj7uJwjr	AgU9OLJkqz	0	4	1	2	2	\N	\N
S0duofnBWs	2024-02-16 00:05:11.972+00	2024-02-16 00:05:11.972+00	NjxsGlPeB4	WnUBBkiDjE	4	3	3	1	2	\N	\N
lWNKD0RhxW	2024-02-16 00:05:12.18+00	2024-02-16 00:05:12.18+00	NjxsGlPeB4	fwLPZZ8YQa	1	1	3	0	0	\N	\N
PnqMhzEvhA	2024-02-16 00:05:12.39+00	2024-02-16 00:05:12.39+00	WKpBp0c8F3	C7II8dYRPY	3	4	3	4	3	\N	\N
qFOcfMm0UZ	2024-02-16 00:05:12.599+00	2024-02-16 00:05:12.599+00	R2CLtFh5jU	PF8w2gMAdi	4	4	0	3	0	\N	\N
1PxMNoxmmg	2024-02-16 00:05:12.81+00	2024-02-16 00:05:12.81+00	R2CLtFh5jU	WSTLlXDcKl	3	1	1	0	1	\N	\N
TC0oailoKL	2024-02-16 00:05:13.084+00	2024-02-16 00:05:13.084+00	S6wz0lK0bf	rT0UCBK1bE	3	4	4	2	1	\N	\N
NFuJM1hmGt	2024-02-16 00:05:13.393+00	2024-02-16 00:05:13.393+00	WKpBp0c8F3	mMYg4cyd5R	1	1	4	1	2	\N	\N
Pi3LFp3TWy	2024-02-16 00:05:13.604+00	2024-02-16 00:05:13.604+00	opW2wQ2bZ8	TpGyMZM9BG	3	1	3	4	3	\N	\N
JNDdbvNo6Q	2024-02-16 00:05:13.813+00	2024-02-16 00:05:13.813+00	sy1HD51LXT	FYXEfIO1zF	2	3	2	3	4	\N	\N
KBT4NPV3B4	2024-02-16 00:05:14.022+00	2024-02-16 00:05:14.022+00	NjxsGlPeB4	cwVEh0dqfm	4	4	1	1	2	\N	\N
96HBlnAIWV	2024-02-16 00:05:14.234+00	2024-02-16 00:05:14.234+00	5nv19u6KJ2	LDrIH1vU8x	2	2	1	3	3	\N	\N
e6Z0fBCzWq	2024-02-16 00:05:14.445+00	2024-02-16 00:05:14.445+00	opW2wQ2bZ8	cmxBcanww9	2	3	2	0	3	\N	\N
YDVBZDIrBW	2024-02-16 00:05:14.656+00	2024-02-16 00:05:14.656+00	NjxsGlPeB4	UCFo58JaaD	4	2	0	3	1	\N	\N
MHKXQ1OXvK	2024-02-16 00:05:14.928+00	2024-02-16 00:05:14.928+00	HtEtaHBVDN	FYXEfIO1zF	4	0	2	4	4	\N	\N
i4LniVyOD8	2024-02-16 00:05:15.14+00	2024-02-16 00:05:15.14+00	HtEtaHBVDN	JRi61dUphq	4	0	3	0	4	\N	\N
Rj1EwmVhFX	2024-02-16 00:05:15.349+00	2024-02-16 00:05:15.349+00	HRhGpJpmb5	HSEugQ3Ouj	1	1	4	1	0	\N	\N
NBdCTlug6o	2024-02-16 00:05:15.557+00	2024-02-16 00:05:15.557+00	RWwLSzreG2	uigc7bJBOJ	2	0	1	4	4	\N	\N
xKUtoKCHkq	2024-02-16 00:05:15.851+00	2024-02-16 00:05:15.851+00	dEqAHvPMXA	FYXEfIO1zF	2	4	1	3	1	\N	\N
yuGBPkBaDY	2024-02-16 00:05:16.156+00	2024-02-16 00:05:16.156+00	5X202ssb0D	Pja6n3yaWZ	0	1	0	4	1	\N	\N
gtc7DLCJww	2024-02-16 00:05:16.372+00	2024-02-16 00:05:16.372+00	SFAISec8QF	qZmnAnnPEb	2	1	0	2	0	\N	\N
mt4sOTX1Iq	2024-02-16 00:05:16.582+00	2024-02-16 00:05:16.582+00	opW2wQ2bZ8	m6g8u0QpTC	1	4	4	4	2	\N	\N
aeGwV6zSKR	2024-02-16 00:05:16.789+00	2024-02-16 00:05:16.789+00	5nv19u6KJ2	RBRcyltRSC	2	3	1	4	2	\N	\N
GcriyJvXW9	2024-02-16 00:05:16.998+00	2024-02-16 00:05:16.998+00	RWwLSzreG2	3P6kmNoY1F	2	1	4	0	3	\N	\N
zmUGOqINcL	2024-02-16 00:05:17.208+00	2024-02-16 00:05:17.208+00	mAKp5BK7R1	IEqTHcohpJ	4	3	1	0	3	\N	\N
rkw6E58gRh	2024-02-16 00:05:17.421+00	2024-02-16 00:05:17.421+00	SFAISec8QF	Oahm9sOn1y	3	2	4	0	4	\N	\N
kfRPipGf4S	2024-02-16 00:05:17.633+00	2024-02-16 00:05:17.633+00	iWxl9obi8w	tCIEnLLcUc	1	3	0	0	2	\N	\N
wl5aFu5K0t	2024-02-16 00:05:17.899+00	2024-02-16 00:05:17.899+00	9223vtvaBd	Pja6n3yaWZ	1	4	0	2	4	\N	\N
imhka7a5wf	2024-02-16 00:05:18.109+00	2024-02-16 00:05:18.109+00	WKpBp0c8F3	XSK814B37m	1	1	4	4	2	\N	\N
to7NjDJepR	2024-02-16 00:05:18.32+00	2024-02-16 00:05:18.32+00	HRhGpJpmb5	vwHi602n66	0	1	3	4	4	\N	\N
zm8iIrvGlM	2024-02-16 00:05:18.53+00	2024-02-16 00:05:18.53+00	R2CLtFh5jU	OQWu2bnHeC	0	3	1	4	1	\N	\N
7MUuSdiHG2	2024-02-16 00:05:18.823+00	2024-02-16 00:05:18.823+00	dZKm0wOhYa	PF8w2gMAdi	2	1	0	1	1	\N	\N
zEugJME9Cx	2024-02-16 00:05:19.035+00	2024-02-16 00:05:19.035+00	mAKp5BK7R1	NBojpORh3G	1	0	1	1	2	\N	\N
N6GDDVuEba	2024-02-16 00:05:19.637+00	2024-02-16 00:05:19.637+00	ONgyydfVNz	qEQ9tmLyW9	3	2	0	3	1	\N	\N
WxfmQ1BE6l	2024-02-16 00:05:19.946+00	2024-02-16 00:05:19.946+00	sy1HD51LXT	rT0UCBK1bE	0	2	1	4	1	\N	\N
rQFh8pQqWC	2024-02-16 00:05:20.154+00	2024-02-16 00:05:20.154+00	R2CLtFh5jU	m6g8u0QpTC	2	4	0	0	2	\N	\N
25p8xQ443A	2024-02-16 00:05:20.363+00	2024-02-16 00:05:20.363+00	iWxl9obi8w	lxQA9rtSfY	0	0	4	3	3	\N	\N
Y6maJAy5JS	2024-02-16 00:05:20.572+00	2024-02-16 00:05:20.572+00	HtEtaHBVDN	JZOBDAh12a	3	0	1	0	1	\N	\N
EZ9d84Gfp2	2024-02-16 00:05:20.868+00	2024-02-16 00:05:20.868+00	5X202ssb0D	qP3EdIVzfB	1	4	0	2	1	\N	\N
R6WyJVaYKA	2024-02-16 00:05:21.07+00	2024-02-16 00:05:21.07+00	mAKp5BK7R1	RBRcyltRSC	2	3	3	2	2	\N	\N
Kkn58yaxup	2024-02-16 00:05:21.275+00	2024-02-16 00:05:21.275+00	5X202ssb0D	fwLPZZ8YQa	1	0	1	0	2	\N	\N
45Zw58jadW	2024-02-16 00:05:21.487+00	2024-02-16 00:05:21.487+00	1as6rMOzjQ	E2hBZzDsjO	1	0	2	2	4	\N	\N
bH2VAYmdqm	2024-02-16 00:05:22.096+00	2024-02-16 00:05:22.096+00	NjxsGlPeB4	na5crB8ED1	2	2	4	0	2	\N	\N
7iiP0SQKC2	2024-02-16 00:05:22.707+00	2024-02-16 00:05:22.707+00	SFAISec8QF	qP3EdIVzfB	3	1	3	3	3	\N	\N
JFtv3Gwt32	2024-02-16 00:05:23.321+00	2024-02-16 00:05:23.321+00	dZKm0wOhYa	jHqCpA1nWb	2	1	4	4	0	\N	\N
NmksaMFz4A	2024-02-16 00:05:23.938+00	2024-02-16 00:05:23.938+00	adE9nQrDk3	6Fo67rhTSP	1	2	1	0	0	\N	\N
Jzs1NXY1d8	2024-02-16 00:05:24.148+00	2024-02-16 00:05:24.148+00	SFAISec8QF	C7II8dYRPY	4	4	0	1	1	\N	\N
hYLUnsqvwH	2024-02-16 00:05:24.448+00	2024-02-16 00:05:24.448+00	1as6rMOzjQ	XwWwGnkXNj	3	3	3	4	2	\N	\N
O6AJYaeNsF	2024-02-16 00:05:24.652+00	2024-02-16 00:05:24.652+00	RWwLSzreG2	FJOTueDfs2	0	2	0	3	1	\N	\N
oNncCmnm6Q	2024-02-16 00:05:24.86+00	2024-02-16 00:05:24.86+00	mAKp5BK7R1	qZmnAnnPEb	0	2	3	0	1	\N	\N
kCi0qMfVzs	2024-02-16 00:05:25.069+00	2024-02-16 00:05:25.069+00	adE9nQrDk3	cTIjuPjyIa	3	1	2	4	0	\N	\N
DnqpjbzXkP	2024-02-16 00:05:25.281+00	2024-02-16 00:05:25.281+00	dEqAHvPMXA	H40ivltLwZ	1	0	3	1	1	\N	\N
cygzRGkRzW	2024-02-16 00:05:25.489+00	2024-02-16 00:05:25.489+00	R2CLtFh5jU	TpGyMZM9BG	4	1	0	0	1	\N	\N
ZJnEegicrv	2024-02-16 00:05:25.701+00	2024-02-16 00:05:25.701+00	Otwj7uJwjr	IybX0eBoO3	3	4	2	3	3	\N	\N
6GM6AnBOQr	2024-02-16 00:05:25.911+00	2024-02-16 00:05:25.911+00	dEqAHvPMXA	RBRcyltRSC	2	3	4	0	0	\N	\N
5G4qbgPFiL	2024-02-16 00:05:26.119+00	2024-02-16 00:05:26.119+00	SFAISec8QF	XwWwGnkXNj	1	3	2	1	4	\N	\N
kwDomp0nGl	2024-02-16 00:05:26.328+00	2024-02-16 00:05:26.328+00	dEqAHvPMXA	bi1IivsuUB	2	1	4	1	3	\N	\N
gnGrM1RcFk	2024-02-16 00:05:26.602+00	2024-02-16 00:05:26.602+00	adE9nQrDk3	0TvWuLoLF5	0	0	1	0	4	\N	\N
f8F3PmLkn9	2024-02-16 00:05:26.812+00	2024-02-16 00:05:26.812+00	I5RzFRcQ7G	C7II8dYRPY	1	2	4	3	1	\N	\N
P8sLaaBIL2	2024-02-16 00:05:27.026+00	2024-02-16 00:05:27.026+00	VshUk7eBeK	LDrIH1vU8x	1	0	1	4	0	\N	\N
DVWUkA0bow	2024-02-16 00:05:27.238+00	2024-02-16 00:05:27.238+00	iWxl9obi8w	FYXEfIO1zF	4	2	0	3	4	\N	\N
soLTXcyYFu	2024-02-16 00:05:27.455+00	2024-02-16 00:05:27.455+00	Otwj7uJwjr	qP3EdIVzfB	4	2	2	0	2	\N	\N
hwiOirsOcX	2024-02-16 00:05:27.665+00	2024-02-16 00:05:27.665+00	HtEtaHBVDN	PF8w2gMAdi	4	3	4	4	3	\N	\N
9f8Ydl8QGV	2024-02-16 00:05:27.878+00	2024-02-16 00:05:27.878+00	1as6rMOzjQ	mMYg4cyd5R	1	0	2	0	4	\N	\N
8Sk2oMEdaJ	2024-02-16 00:05:28.093+00	2024-02-16 00:05:28.093+00	9223vtvaBd	G0uU7KQLEt	3	3	1	1	0	\N	\N
cyrxbODe8O	2024-02-16 00:05:28.502+00	2024-02-16 00:05:28.502+00	WKpBp0c8F3	8w7i8C3NnT	1	0	2	1	2	\N	\N
mgBVl0UpDr	2024-02-16 00:05:28.714+00	2024-02-16 00:05:28.714+00	I5RzFRcQ7G	j0dWqP2C2A	0	0	3	0	2	\N	\N
OCOaFoh4z7	2024-02-16 00:05:28.924+00	2024-02-16 00:05:28.924+00	R2CLtFh5jU	C7II8dYRPY	4	0	4	4	3	\N	\N
aBQB8JBcF1	2024-02-16 00:05:29.133+00	2024-02-16 00:05:29.133+00	jqDYoPT45X	LgJuu5ABe5	4	2	1	4	0	\N	\N
L1w0cIorwG	2024-02-16 00:05:29.338+00	2024-02-16 00:05:29.338+00	NjxsGlPeB4	LgJuu5ABe5	1	0	4	2	4	\N	\N
EhXdbc2T11	2024-02-16 00:05:29.542+00	2024-02-16 00:05:29.542+00	VshUk7eBeK	cwVEh0dqfm	3	2	1	3	3	\N	\N
NKh1U9cZnn	2024-02-16 00:05:29.754+00	2024-02-16 00:05:29.754+00	9223vtvaBd	HXtEwLBC7f	3	2	3	4	2	\N	\N
D0v2AImiEE	2024-02-16 00:05:29.96+00	2024-02-16 00:05:29.96+00	S6wz0lK0bf	cFtamPA0zH	2	1	2	0	0	\N	\N
W65oidmHu6	2024-02-16 00:05:30.16+00	2024-02-16 00:05:30.16+00	9223vtvaBd	3P6kmNoY1F	0	3	0	0	3	\N	\N
JvL4Qb1ytx	2024-02-16 00:05:30.36+00	2024-02-16 00:05:30.36+00	VshUk7eBeK	XwWwGnkXNj	1	0	0	3	1	\N	\N
AAgNohluRo	2024-02-16 00:05:30.568+00	2024-02-16 00:05:30.568+00	AsrLUQwxI9	jjVdtithcD	2	2	0	4	3	\N	\N
2gbDQMQKDK	2024-02-16 00:05:30.781+00	2024-02-16 00:05:30.781+00	RWwLSzreG2	vwHi602n66	2	4	3	4	0	\N	\N
YBZ4EsDbu5	2024-02-16 00:05:30.995+00	2024-02-16 00:05:30.995+00	mQXQWNqxg9	IybX0eBoO3	3	0	1	3	4	\N	\N
3qwrbPGtWB	2024-02-16 00:05:31.204+00	2024-02-16 00:05:31.204+00	Otwj7uJwjr	E2hBZzDsjO	2	3	3	1	4	\N	\N
GU0kNmkLLY	2024-02-16 00:05:31.522+00	2024-02-16 00:05:31.522+00	HtEtaHBVDN	3u4B9V4l5K	4	4	0	1	2	\N	\N
73LaHFym38	2024-02-16 00:05:32.13+00	2024-02-16 00:05:32.13+00	R2CLtFh5jU	LgJuu5ABe5	1	2	0	3	2	\N	\N
lCkdByOyaa	2024-02-16 00:05:32.339+00	2024-02-16 00:05:32.339+00	S6wz0lK0bf	HSEugQ3Ouj	1	1	3	1	2	\N	\N
f5tcfI2Eco	2024-02-16 00:05:32.949+00	2024-02-16 00:05:32.949+00	I5RzFRcQ7G	3u4B9V4l5K	0	2	4	4	3	\N	\N
gXpIFhAYgz	2024-02-16 00:05:33.158+00	2024-02-16 00:05:33.158+00	5nv19u6KJ2	JZOBDAh12a	2	1	1	3	0	\N	\N
QVFK49ODIs	2024-02-16 00:05:33.368+00	2024-02-16 00:05:33.368+00	5nv19u6KJ2	LDrIH1vU8x	2	1	2	4	1	\N	\N
WcNKMiuqGz	2024-02-16 00:05:33.973+00	2024-02-16 00:05:33.973+00	mQXQWNqxg9	jjVdtithcD	0	4	2	2	3	\N	\N
7IYhLWIKOz	2024-02-16 00:05:34.226+00	2024-02-16 00:05:34.226+00	Otwj7uJwjr	axyV0Fu7pm	4	0	3	0	4	\N	\N
CqYAsQML1E	2024-02-16 00:05:34.437+00	2024-02-16 00:05:34.437+00	RWwLSzreG2	XwWwGnkXNj	0	2	1	1	3	\N	\N
6MyB2klG8g	2024-02-16 00:05:34.65+00	2024-02-16 00:05:34.65+00	Otwj7uJwjr	u5FXeeOChJ	0	3	2	0	2	\N	\N
7MXNvzH6lf	2024-02-16 00:05:34.863+00	2024-02-16 00:05:34.863+00	1as6rMOzjQ	14jGmOAXcg	1	4	3	1	0	\N	\N
Vi8YL2l5mW	2024-02-16 00:05:35.51+00	2024-02-16 00:05:35.51+00	sy1HD51LXT	XwszrNEEEj	0	4	4	1	4	\N	\N
rgFK8zwJLy	2024-02-16 00:05:35.816+00	2024-02-16 00:05:35.816+00	dEqAHvPMXA	BMLzFMvIT6	1	1	4	3	4	\N	\N
v3gT0gKgPy	2024-02-16 00:05:36.122+00	2024-02-16 00:05:36.122+00	VshUk7eBeK	HXtEwLBC7f	2	4	0	0	0	\N	\N
RLPQ7ckUS4	2024-02-16 00:05:36.328+00	2024-02-16 00:05:36.328+00	sy1HD51LXT	o4VD4BWwDt	4	0	4	1	2	\N	\N
N4pUv2DEY1	2024-02-16 00:05:36.539+00	2024-02-16 00:05:36.539+00	mAKp5BK7R1	TpGyMZM9BG	0	0	0	3	4	\N	\N
wpG8ApQ397	2024-02-16 00:05:36.841+00	2024-02-16 00:05:36.841+00	dZKm0wOhYa	RkhjIQJgou	4	4	2	1	1	\N	\N
6mmiS6b62B	2024-02-16 00:05:37.05+00	2024-02-16 00:05:37.05+00	SFAISec8QF	cwVEh0dqfm	0	1	2	3	2	\N	\N
aXKmkXlsVa	2024-02-16 00:05:37.261+00	2024-02-16 00:05:37.261+00	ONgyydfVNz	3u4B9V4l5K	0	3	3	3	3	\N	\N
W8vU6nytoF	2024-02-16 00:05:37.471+00	2024-02-16 00:05:37.471+00	VshUk7eBeK	fwLPZZ8YQa	0	2	0	4	0	\N	\N
hZkRZWOO9b	2024-02-16 00:05:37.762+00	2024-02-16 00:05:37.762+00	jqDYoPT45X	08liHW08uC	4	0	2	1	3	\N	\N
chKSlrXcz0	2024-02-16 00:05:37.971+00	2024-02-16 00:05:37.971+00	AsrLUQwxI9	JRi61dUphq	3	1	0	2	3	\N	\N
wsGEsFGyAD	2024-02-16 00:05:38.183+00	2024-02-16 00:05:38.183+00	VshUk7eBeK	EmIUBFwx0Z	1	0	2	1	2	\N	\N
FY4y56s1q0	2024-02-16 00:05:38.39+00	2024-02-16 00:05:38.39+00	SFAISec8QF	cwVEh0dqfm	1	3	1	4	1	\N	\N
wTAGW6cRqj	2024-02-16 00:05:38.595+00	2024-02-16 00:05:38.595+00	9223vtvaBd	0TvWuLoLF5	2	1	0	4	3	\N	\N
Va5ldtGYYL	2024-02-16 00:05:38.804+00	2024-02-16 00:05:38.804+00	iWxl9obi8w	P9sBFomftT	4	2	3	3	1	\N	\N
AWTHKRRHe3	2024-02-16 00:05:39.013+00	2024-02-16 00:05:39.013+00	jqDYoPT45X	WHvlAGgj6c	2	0	1	3	4	\N	\N
9ub4engsrQ	2024-02-16 00:05:39.605+00	2024-02-16 00:05:39.605+00	9223vtvaBd	jjVdtithcD	4	4	4	1	2	\N	\N
AQbeBHpeM1	2024-02-16 00:05:39.811+00	2024-02-16 00:05:39.811+00	jqDYoPT45X	08liHW08uC	1	0	0	4	1	\N	\N
vfK7cVFDa0	2024-02-16 00:05:40.02+00	2024-02-16 00:05:40.02+00	I5RzFRcQ7G	INeptnSdJC	0	2	2	4	1	\N	\N
S2WXiHcB2s	2024-02-16 00:05:40.232+00	2024-02-16 00:05:40.232+00	5nv19u6KJ2	TZsdmscJ2B	0	1	0	4	2	\N	\N
oO7Is3b3LI	2024-02-16 00:05:40.53+00	2024-02-16 00:05:40.53+00	sy1HD51LXT	XwszrNEEEj	2	2	3	3	0	\N	\N
qRf1w0m9Q6	2024-02-16 00:05:40.744+00	2024-02-16 00:05:40.744+00	opW2wQ2bZ8	l1Bslv8T2k	4	0	2	0	3	\N	\N
mBN3HitYQE	2024-02-16 00:05:40.953+00	2024-02-16 00:05:40.953+00	5nv19u6KJ2	m6g8u0QpTC	1	0	0	4	1	\N	\N
0UNlESypIi	2024-02-16 00:05:41.195+00	2024-02-16 00:05:41.195+00	9223vtvaBd	y4RkaDbkec	2	3	0	1	0	\N	\N
9D4fjdoYex	2024-02-16 00:05:41.731+00	2024-02-16 00:05:41.731+00	HtEtaHBVDN	WHvlAGgj6c	4	0	3	1	3	\N	\N
E2DMit4PnG	2024-02-16 00:05:41.941+00	2024-02-16 00:05:41.941+00	mAKp5BK7R1	oABNR2FF6S	1	0	0	3	3	\N	\N
8xU8F9E4u7	2024-02-16 00:05:42.148+00	2024-02-16 00:05:42.148+00	NjxsGlPeB4	oABNR2FF6S	1	2	1	4	2	\N	\N
2Yrdnp2k2C	2024-02-16 00:05:42.357+00	2024-02-16 00:05:42.357+00	WKpBp0c8F3	WnUBBkiDjE	2	3	2	3	3	\N	\N
0425qdoQBB	2024-02-16 00:05:42.571+00	2024-02-16 00:05:42.571+00	mQXQWNqxg9	BMLzFMvIT6	0	0	3	3	0	\N	\N
ilGL10QWxp	2024-02-16 00:05:42.885+00	2024-02-16 00:05:42.885+00	9223vtvaBd	0TvWuLoLF5	0	1	3	4	3	\N	\N
tdANqfdMpW	2024-02-16 00:05:43.099+00	2024-02-16 00:05:43.099+00	opW2wQ2bZ8	vwHi602n66	1	4	3	4	3	\N	\N
B6ZaReh0sz	2024-02-16 00:05:43.394+00	2024-02-16 00:05:43.394+00	AsrLUQwxI9	FYXEfIO1zF	4	4	0	4	3	\N	\N
Ap04PEJ3yM	2024-02-16 00:05:44.008+00	2024-02-16 00:05:44.008+00	sy1HD51LXT	D0A6GLdsDM	0	4	4	3	0	\N	\N
09UytByme8	2024-02-16 00:05:44.218+00	2024-02-16 00:05:44.218+00	AsrLUQwxI9	jjVdtithcD	4	0	2	2	4	\N	\N
3d8Hml1AQB	2024-02-16 00:05:44.427+00	2024-02-16 00:05:44.427+00	sy1HD51LXT	6KvFK8yy1q	3	1	2	4	2	\N	\N
TbDuePPj4T	2024-02-16 00:05:44.726+00	2024-02-16 00:05:44.726+00	HRhGpJpmb5	LDrIH1vU8x	0	3	3	1	4	\N	\N
X8r55D1jfv	2024-02-16 00:05:45.033+00	2024-02-16 00:05:45.033+00	5nv19u6KJ2	lEPdiO1EDi	1	0	2	4	4	\N	\N
1qbRBiDAMY	2024-02-16 00:05:45.244+00	2024-02-16 00:05:45.244+00	dZKm0wOhYa	na5crB8ED1	4	4	1	0	4	\N	\N
KZL07MZ7hb	2024-02-16 00:05:45.458+00	2024-02-16 00:05:45.458+00	Otwj7uJwjr	na5crB8ED1	1	4	3	0	4	\N	\N
GnGRdhcF6e	2024-02-16 00:05:45.663+00	2024-02-16 00:05:45.663+00	I5RzFRcQ7G	yvUod6yLDt	3	2	3	4	3	\N	\N
3p1kvCKLOg	2024-02-16 00:05:45.875+00	2024-02-16 00:05:45.875+00	NjxsGlPeB4	vwHi602n66	4	2	1	2	1	\N	\N
4FFChMh6Aw	2024-02-16 00:05:46.078+00	2024-02-16 00:05:46.078+00	jqDYoPT45X	uigc7bJBOJ	2	0	1	1	3	\N	\N
aR9FnaU2yl	2024-02-16 00:05:46.672+00	2024-02-16 00:05:46.672+00	9223vtvaBd	yvUod6yLDt	4	3	2	4	4	\N	\N
q9mrvPvYdB	2024-02-16 00:05:46.88+00	2024-02-16 00:05:46.88+00	HRhGpJpmb5	TCkiw6gTDz	0	3	4	4	0	\N	\N
zl8iIvPKP6	2024-02-16 00:05:47.087+00	2024-02-16 00:05:47.087+00	SFAISec8QF	PF8w2gMAdi	3	3	1	0	2	\N	\N
jmQQT2Zzyc	2024-02-16 00:05:47.389+00	2024-02-16 00:05:47.389+00	ONgyydfVNz	j0dWqP2C2A	2	0	4	4	2	\N	\N
mEpSlAIHmy	2024-02-16 00:05:47.598+00	2024-02-16 00:05:47.598+00	Otwj7uJwjr	9GF3y7LmHV	0	1	2	3	1	\N	\N
F0huZtk2Xb	2024-02-16 00:05:47.808+00	2024-02-16 00:05:47.808+00	sy1HD51LXT	oABNR2FF6S	2	2	4	2	0	\N	\N
SLJzRyf1xI	2024-02-16 00:05:48.018+00	2024-02-16 00:05:48.018+00	dZKm0wOhYa	Pa0qBO2rzK	4	4	0	1	0	\N	\N
8wAYXnPCtL	2024-02-16 00:05:48.615+00	2024-02-16 00:05:48.615+00	5nv19u6KJ2	JLhF4VuByh	2	4	4	0	2	\N	\N
gKgetTIUbP	2024-02-16 00:05:48.929+00	2024-02-16 00:05:48.929+00	jqDYoPT45X	ThMuD3hYRQ	3	1	2	4	3	\N	\N
MwflGJMo28	2024-02-16 00:05:49.23+00	2024-02-16 00:05:49.23+00	VshUk7eBeK	WBFeKac0OO	1	3	0	2	3	\N	\N
VgPsgdCMMh	2024-02-16 00:05:49.437+00	2024-02-16 00:05:49.437+00	Otwj7uJwjr	NY6RE1qgWu	0	2	0	3	4	\N	\N
HbH4wb6nE3	2024-02-16 00:05:49.641+00	2024-02-16 00:05:49.641+00	WKpBp0c8F3	HLIPwAqO2R	2	3	4	1	2	\N	\N
JfgGmqk1vR	2024-02-16 00:05:49.856+00	2024-02-16 00:05:49.856+00	HtEtaHBVDN	mMYg4cyd5R	3	3	0	3	0	\N	\N
fcs97XZ7Tz	2024-02-16 00:05:50.069+00	2024-02-16 00:05:50.069+00	RWwLSzreG2	qP3EdIVzfB	4	3	0	2	4	\N	\N
gp6aJwCNJm	2024-02-16 00:05:50.361+00	2024-02-16 00:05:50.361+00	RWwLSzreG2	HXtEwLBC7f	0	1	4	1	4	\N	\N
FyfHQzTsKz	2024-02-16 00:05:50.574+00	2024-02-16 00:05:50.574+00	iWxl9obi8w	mMYg4cyd5R	0	1	1	0	0	\N	\N
mZxPWspepL	2024-02-16 00:05:50.789+00	2024-02-16 00:05:50.789+00	adE9nQrDk3	cTIjuPjyIa	3	0	3	0	0	\N	\N
D2cNrhMOCK	2024-02-16 00:05:51.486+00	2024-02-16 00:05:51.486+00	S6wz0lK0bf	NY6RE1qgWu	3	1	0	0	2	\N	\N
NhuXwqFj3l	2024-02-16 00:05:51.695+00	2024-02-16 00:05:51.695+00	SFAISec8QF	FJOTueDfs2	1	2	0	3	0	\N	\N
q0OxFghQbU	2024-02-16 00:05:51.996+00	2024-02-16 00:05:51.996+00	opW2wQ2bZ8	fKTSJPdUi9	3	0	0	1	4	\N	\N
q5LOtvUzRm	2024-02-16 00:05:52.614+00	2024-02-16 00:05:52.614+00	HRhGpJpmb5	jHqCpA1nWb	3	0	3	4	4	\N	\N
JFPz2t0gX1	2024-02-16 00:05:52.824+00	2024-02-16 00:05:52.824+00	VshUk7eBeK	JLhF4VuByh	3	3	1	0	0	\N	\N
4uGzyaWGam	2024-02-16 00:05:53.034+00	2024-02-16 00:05:53.034+00	1as6rMOzjQ	89xRG1afNi	1	1	3	2	0	\N	\N
hfxuGSw1Go	2024-02-16 00:05:53.319+00	2024-02-16 00:05:53.319+00	HRhGpJpmb5	PF8w2gMAdi	4	4	1	4	1	\N	\N
zGzH0Pn5Hf	2024-02-16 00:05:53.634+00	2024-02-16 00:05:53.634+00	9223vtvaBd	0TvWuLoLF5	1	3	1	0	1	\N	\N
eyFEWp52xF	2024-02-16 00:05:53.843+00	2024-02-16 00:05:53.843+00	HtEtaHBVDN	UDXF0qXvDY	4	2	4	4	1	\N	\N
itDiQOBi3x	2024-02-16 00:05:54.059+00	2024-02-16 00:05:54.059+00	sHiqaG4iqY	HXtEwLBC7f	3	4	3	1	1	\N	\N
x7zOC44FGo	2024-02-16 00:05:54.352+00	2024-02-16 00:05:54.352+00	NjxsGlPeB4	M0tHrt1GgV	2	0	2	1	1	\N	\N
7UdWWOX5Wt	2024-02-16 00:05:54.562+00	2024-02-16 00:05:54.562+00	S6wz0lK0bf	AgU9OLJkqz	2	1	4	1	2	\N	\N
NFhHT5kF9Q	2024-02-16 00:05:54.772+00	2024-02-16 00:05:54.772+00	AsrLUQwxI9	cmxBcanww9	2	2	3	0	3	\N	\N
2FUPXjhwu7	2024-02-16 00:05:54.981+00	2024-02-16 00:05:54.981+00	AsrLUQwxI9	axyV0Fu7pm	2	0	3	2	2	\N	\N
F8buvMYyGK	2024-02-16 00:05:55.19+00	2024-02-16 00:05:55.19+00	iUlyHNFGpG	OQWu2bnHeC	0	3	4	3	2	\N	\N
vEbuKaQjUu	2024-02-16 00:05:55.402+00	2024-02-16 00:05:55.402+00	sy1HD51LXT	WBFeKac0OO	1	4	2	1	4	\N	\N
AmGofJNBWZ	2024-02-16 00:05:55.615+00	2024-02-16 00:05:55.615+00	AsrLUQwxI9	OQWu2bnHeC	1	4	3	3	1	\N	\N
c6c7q5HO4G	2024-02-16 00:05:55.824+00	2024-02-16 00:05:55.824+00	dEqAHvPMXA	qEQ9tmLyW9	2	2	2	2	1	\N	\N
mJBbGd1CbA	2024-02-16 00:05:56.085+00	2024-02-16 00:05:56.085+00	I5RzFRcQ7G	e037qpAih3	2	2	2	1	1	\N	\N
WhaAGMSy5y	2024-02-16 00:05:56.295+00	2024-02-16 00:05:56.295+00	RWwLSzreG2	rT0UCBK1bE	2	4	2	3	3	\N	\N
lI7p0Rl0nF	2024-02-16 00:05:56.507+00	2024-02-16 00:05:56.507+00	adE9nQrDk3	uigc7bJBOJ	2	2	3	0	4	\N	\N
3cOuE2ZAvq	2024-02-16 00:05:56.721+00	2024-02-16 00:05:56.721+00	dEqAHvPMXA	HSEugQ3Ouj	0	4	0	3	3	\N	\N
gDQwsgRm0B	2024-02-16 00:05:56.929+00	2024-02-16 00:05:56.929+00	sHiqaG4iqY	TCkiw6gTDz	1	4	3	4	0	\N	\N
Zv6cd3PthU	2024-02-16 00:05:57.141+00	2024-02-16 00:05:57.141+00	9223vtvaBd	e037qpAih3	4	1	1	2	4	\N	\N
ZGRgX8Lffc	2024-02-16 00:05:57.352+00	2024-02-16 00:05:57.352+00	I5RzFRcQ7G	JLhF4VuByh	3	1	4	0	1	\N	\N
OKeXgGxzAo	2024-02-16 00:05:57.56+00	2024-02-16 00:05:57.56+00	AsrLUQwxI9	bQ0JOk10eL	2	4	0	2	2	\N	\N
p5yOsTHO6o	2024-02-16 00:05:57.772+00	2024-02-16 00:05:57.772+00	mAKp5BK7R1	D0A6GLdsDM	3	3	1	3	0	\N	\N
gs5WNe7RDx	2024-02-16 00:05:58.041+00	2024-02-16 00:05:58.041+00	9223vtvaBd	fwLPZZ8YQa	4	4	1	4	1	\N	\N
McKyieLz1r	2024-02-16 00:05:58.258+00	2024-02-16 00:05:58.258+00	iUlyHNFGpG	XwszrNEEEj	3	1	0	3	1	\N	\N
cd7qUtI25C	2024-02-16 00:05:58.476+00	2024-02-16 00:05:58.476+00	VshUk7eBeK	C7II8dYRPY	2	1	0	2	2	\N	\N
J0hGzpGaFp	2024-02-16 00:05:58.789+00	2024-02-16 00:05:58.789+00	WKpBp0c8F3	XwszrNEEEj	1	1	2	2	4	\N	\N
Nj3CnVstaH	2024-02-16 00:05:59.004+00	2024-02-16 00:05:59.004+00	ONgyydfVNz	08liHW08uC	0	1	0	4	0	\N	\N
2WmI8XnPHR	2024-02-16 00:05:59.206+00	2024-02-16 00:05:59.206+00	5nv19u6KJ2	cmxBcanww9	2	1	1	4	0	\N	\N
H81IyUIoIx	2024-02-16 00:05:59.464+00	2024-02-16 00:05:59.464+00	1as6rMOzjQ	bQ0JOk10eL	4	1	0	0	2	\N	\N
aiwcEnNLoF	2024-02-16 00:05:59.782+00	2024-02-16 00:05:59.782+00	mAKp5BK7R1	OQWu2bnHeC	3	2	1	2	3	\N	\N
F1BDar75QA	2024-02-16 00:05:59.997+00	2024-02-16 00:05:59.997+00	S6wz0lK0bf	FYXEfIO1zF	0	0	1	2	0	\N	\N
hOu1BqibkN	2024-02-16 00:06:00.218+00	2024-02-16 00:06:00.218+00	R2CLtFh5jU	l1Bslv8T2k	1	3	1	1	0	\N	\N
Jp4BM6S0Wc	2024-02-16 00:06:00.432+00	2024-02-16 00:06:00.432+00	WKpBp0c8F3	WSTLlXDcKl	2	0	4	2	0	\N	\N
sRT3GIPQne	2024-02-16 00:06:00.648+00	2024-02-16 00:06:00.648+00	mQXQWNqxg9	lEPdiO1EDi	2	3	1	4	2	\N	\N
zaK7VNaDRw	2024-02-16 00:06:00.864+00	2024-02-16 00:06:00.864+00	5X202ssb0D	ThMuD3hYRQ	1	2	2	1	1	\N	\N
ekn3yO6JjG	2024-02-16 00:06:01.519+00	2024-02-16 00:06:01.519+00	iUlyHNFGpG	0TvWuLoLF5	3	4	3	1	2	\N	\N
imewilGNK0	2024-02-16 00:06:01.825+00	2024-02-16 00:06:01.825+00	mQXQWNqxg9	FJOTueDfs2	2	1	4	3	1	\N	\N
TKuj5CGZng	2024-02-16 00:06:02.036+00	2024-02-16 00:06:02.036+00	ONgyydfVNz	6KvFK8yy1q	2	2	1	4	4	\N	\N
KcWsjxbYbs	2024-02-16 00:06:02.25+00	2024-02-16 00:06:02.25+00	RWwLSzreG2	XSK814B37m	1	2	4	2	1	\N	\N
JAq6k69Bqg	2024-02-16 00:06:02.541+00	2024-02-16 00:06:02.541+00	ONgyydfVNz	mMYg4cyd5R	1	3	1	1	4	\N	\N
i8dyz44tzA	2024-02-16 00:06:02.751+00	2024-02-16 00:06:02.751+00	sy1HD51LXT	y4RkaDbkec	1	1	4	2	2	\N	\N
IWuMN6npmK	2024-02-16 00:06:02.966+00	2024-02-16 00:06:02.966+00	AsrLUQwxI9	yvUod6yLDt	3	3	4	0	2	\N	\N
WWYbgAwa2w	2024-02-16 00:06:03.212+00	2024-02-16 00:06:03.212+00	SFAISec8QF	HSEugQ3Ouj	3	3	0	0	2	\N	\N
NBDGl5GXAA	2024-02-16 00:06:03.416+00	2024-02-16 00:06:03.416+00	RWwLSzreG2	HSEugQ3Ouj	3	1	4	0	0	\N	\N
atBebXuhVG	2024-02-16 00:06:03.662+00	2024-02-16 00:06:03.662+00	Otwj7uJwjr	CSvk1ycWXk	0	1	0	4	0	\N	\N
05GBHgNIxn	2024-02-16 00:06:03.869+00	2024-02-16 00:06:03.869+00	adE9nQrDk3	oABNR2FF6S	3	1	3	2	1	\N	\N
JgKExHbylV	2024-02-16 00:06:04.072+00	2024-02-16 00:06:04.072+00	I5RzFRcQ7G	Pja6n3yaWZ	3	0	0	2	2	\N	\N
kBtvqNxxKu	2024-02-16 00:06:04.284+00	2024-02-16 00:06:04.284+00	1as6rMOzjQ	OQWu2bnHeC	2	3	1	0	1	\N	\N
nBU6Li1mdo	2024-02-16 00:06:04.492+00	2024-02-16 00:06:04.492+00	ONgyydfVNz	E2hBZzDsjO	3	2	3	4	4	\N	\N
K3emayqF02	2024-02-16 00:06:04.7+00	2024-02-16 00:06:04.7+00	iWxl9obi8w	LVYK4mLShP	1	4	0	0	0	\N	\N
pM4prUo7wn	2024-02-16 00:06:04.998+00	2024-02-16 00:06:04.998+00	1as6rMOzjQ	UCFo58JaaD	0	0	4	0	4	\N	\N
xyHh7gyrR0	2024-02-16 00:06:05.196+00	2024-02-16 00:06:05.196+00	1as6rMOzjQ	o4VD4BWwDt	1	1	0	1	0	\N	\N
LoLWnwHsXX	2024-02-16 00:06:05.395+00	2024-02-16 00:06:05.395+00	SFAISec8QF	BMLzFMvIT6	4	0	4	3	3	\N	\N
TSa0hg4Ck6	2024-02-16 00:06:05.599+00	2024-02-16 00:06:05.599+00	I5RzFRcQ7G	y4RkaDbkec	3	4	0	4	1	\N	\N
vARFQJi2CW	2024-02-16 00:06:05.801+00	2024-02-16 00:06:05.801+00	sy1HD51LXT	AgU9OLJkqz	2	3	0	0	2	\N	\N
wSASG8yNmb	2024-02-16 00:06:06.011+00	2024-02-16 00:06:06.011+00	dZKm0wOhYa	KCsJ4XR6Dn	3	2	1	3	3	\N	\N
GRuRMapi9P	2024-02-16 00:06:06.292+00	2024-02-16 00:06:06.292+00	sHiqaG4iqY	C7II8dYRPY	4	3	4	1	3	\N	\N
nAxwFAlFFu	2024-02-16 00:06:06.494+00	2024-02-16 00:06:06.494+00	dEqAHvPMXA	mMYg4cyd5R	4	4	2	1	3	\N	\N
d94ZxU5OSz	2024-02-16 00:06:06.704+00	2024-02-16 00:06:06.704+00	RWwLSzreG2	9GF3y7LmHV	4	4	1	4	3	\N	\N
yJH6DUI11j	2024-02-16 00:06:06.912+00	2024-02-16 00:06:06.912+00	opW2wQ2bZ8	l1Bslv8T2k	0	2	1	3	3	\N	\N
KxNiJXLUe0	2024-02-16 00:06:07.339+00	2024-02-16 00:06:07.339+00	AsrLUQwxI9	IEqTHcohpJ	2	4	1	0	0	\N	\N
9PAAVIBomx	2024-02-16 00:06:07.679+00	2024-02-16 00:06:07.679+00	iUlyHNFGpG	C7II8dYRPY	0	4	1	1	0	\N	\N
mX30zpXSgg	2024-02-16 00:06:07.881+00	2024-02-16 00:06:07.881+00	adE9nQrDk3	RkhjIQJgou	3	0	2	4	3	\N	\N
pNZpoeCvTI	2024-02-16 00:06:08.089+00	2024-02-16 00:06:08.089+00	dEqAHvPMXA	6KvFK8yy1q	2	1	2	4	3	\N	\N
bqvwEwYnSw	2024-02-16 00:06:08.288+00	2024-02-16 00:06:08.288+00	5nv19u6KJ2	mMYg4cyd5R	4	4	0	0	1	\N	\N
e6gUc8WIs5	2024-02-16 00:06:08.492+00	2024-02-16 00:06:08.492+00	SFAISec8QF	XpUyRlB6FI	0	1	2	4	0	\N	\N
9DGXuKoATZ	2024-02-16 00:06:08.7+00	2024-02-16 00:06:08.7+00	iWxl9obi8w	INeptnSdJC	4	4	2	3	4	\N	\N
sw2syuvCPL	2024-02-16 00:06:08.911+00	2024-02-16 00:06:08.911+00	Otwj7uJwjr	UDXF0qXvDY	1	3	0	2	4	\N	\N
DMGGVIGtec	2024-02-16 00:06:09.124+00	2024-02-16 00:06:09.124+00	dZKm0wOhYa	RBRcyltRSC	2	1	0	4	3	\N	\N
hjij96K4ZX	2024-02-16 00:06:09.338+00	2024-02-16 00:06:09.338+00	I5RzFRcQ7G	WBFeKac0OO	2	0	3	0	4	\N	\N
NhfAB4TYMr	2024-02-16 00:06:09.543+00	2024-02-16 00:06:09.543+00	HtEtaHBVDN	lEPdiO1EDi	2	3	0	1	1	\N	\N
FGjQAYYle3	2024-02-16 00:06:09.753+00	2024-02-16 00:06:09.753+00	adE9nQrDk3	OQWu2bnHeC	0	1	3	2	2	\N	\N
4Q0b86zV0R	2024-02-16 00:06:09.966+00	2024-02-16 00:06:09.966+00	dEqAHvPMXA	jHqCpA1nWb	2	4	3	1	2	\N	\N
zzrZkWj6A4	2024-02-16 00:06:10.224+00	2024-02-16 00:06:10.224+00	ONgyydfVNz	yvUod6yLDt	0	2	0	3	2	\N	\N
9XU1SbK1XK	2024-02-16 00:06:10.432+00	2024-02-16 00:06:10.432+00	5X202ssb0D	cmxBcanww9	2	0	4	2	3	\N	\N
ZvqefQ7rQx	2024-02-16 00:06:10.64+00	2024-02-16 00:06:10.64+00	HRhGpJpmb5	OQWu2bnHeC	0	1	0	1	1	\N	\N
EdBVAQ5Z2h	2024-02-16 00:06:10.85+00	2024-02-16 00:06:10.85+00	SFAISec8QF	Gl96vGdYHM	4	4	3	0	2	\N	\N
jgkr7M1471	2024-02-16 00:06:11.139+00	2024-02-16 00:06:11.139+00	SFAISec8QF	bi1IivsuUB	1	4	1	4	4	\N	\N
YKqKqUWy3H	2024-02-16 00:06:11.347+00	2024-02-16 00:06:11.347+00	adE9nQrDk3	6KvFK8yy1q	3	2	1	2	3	\N	\N
oCDYGUoqLQ	2024-02-16 00:06:11.657+00	2024-02-16 00:06:11.657+00	iUlyHNFGpG	D0A6GLdsDM	2	2	2	0	2	\N	\N
y0eKcjIUoR	2024-02-16 00:06:11.862+00	2024-02-16 00:06:11.862+00	SFAISec8QF	uigc7bJBOJ	2	0	1	4	0	\N	\N
bFJZSEezLZ	2024-02-16 00:06:12.066+00	2024-02-16 00:06:12.066+00	5nv19u6KJ2	qP3EdIVzfB	3	2	0	4	2	\N	\N
aTyIobHcVz	2024-02-16 00:06:12.274+00	2024-02-16 00:06:12.274+00	WKpBp0c8F3	CSvk1ycWXk	4	0	2	1	1	\N	\N
eGcASfv6kP	2024-02-16 00:06:12.487+00	2024-02-16 00:06:12.487+00	iWxl9obi8w	j0dWqP2C2A	0	3	4	3	1	\N	\N
QdsQO2GaZ1	2024-02-16 00:06:12.701+00	2024-02-16 00:06:12.701+00	mQXQWNqxg9	o4VD4BWwDt	4	1	3	3	0	\N	\N
jiCdelFiab	2024-02-16 00:06:12.915+00	2024-02-16 00:06:12.915+00	jqDYoPT45X	o4VD4BWwDt	0	4	3	4	0	\N	\N
6GvsIEl2ub	2024-02-16 00:06:13.129+00	2024-02-16 00:06:13.129+00	mAKp5BK7R1	08liHW08uC	3	3	4	3	3	\N	\N
p98zItxPiq	2024-02-16 00:06:13.345+00	2024-02-16 00:06:13.345+00	S6wz0lK0bf	P9sBFomftT	4	2	0	1	2	\N	\N
DtddVDKGuy	2024-02-16 00:06:13.56+00	2024-02-16 00:06:13.56+00	S6wz0lK0bf	C7II8dYRPY	0	1	1	4	0	\N	\N
rG0FOO4M4b	2024-02-16 00:06:13.8+00	2024-02-16 00:06:13.8+00	AsrLUQwxI9	o4VD4BWwDt	1	4	3	3	4	\N	\N
wtotEZM6JQ	2024-02-16 00:06:14.013+00	2024-02-16 00:06:14.013+00	I5RzFRcQ7G	Pa0qBO2rzK	1	2	2	4	1	\N	\N
IxMoBjtHZA	2024-02-16 00:06:14.229+00	2024-02-16 00:06:14.229+00	dEqAHvPMXA	qZmnAnnPEb	2	3	0	4	2	\N	\N
FOdQHxAAJo	2024-02-16 00:06:14.443+00	2024-02-16 00:06:14.443+00	R2CLtFh5jU	FJOTueDfs2	0	1	0	0	3	\N	\N
sSLqLBOVb3	2024-02-16 00:06:14.656+00	2024-02-16 00:06:14.656+00	sy1HD51LXT	LgJuu5ABe5	0	4	3	3	2	\N	\N
s0GcnQOk7D	2024-02-16 00:06:14.873+00	2024-02-16 00:06:14.873+00	opW2wQ2bZ8	AgU9OLJkqz	1	3	1	0	2	\N	\N
AacEzBGPOm	2024-02-16 00:06:15.141+00	2024-02-16 00:06:15.141+00	9223vtvaBd	WBFeKac0OO	1	3	0	4	4	\N	\N
M34EsEzWrN	2024-02-16 00:06:15.358+00	2024-02-16 00:06:15.358+00	WKpBp0c8F3	PF8w2gMAdi	0	1	2	2	0	\N	\N
UO4BUt30Ot	2024-02-16 00:06:15.569+00	2024-02-16 00:06:15.569+00	ONgyydfVNz	XpUyRlB6FI	2	4	4	3	1	\N	\N
y0d6a8VaDo	2024-02-16 00:06:15.779+00	2024-02-16 00:06:15.779+00	9223vtvaBd	LVYK4mLShP	0	3	2	3	4	\N	\N
83jwfO4cwx	2024-02-16 00:06:15.995+00	2024-02-16 00:06:15.995+00	5X202ssb0D	JRi61dUphq	2	1	0	0	2	\N	\N
G9hBGYKgXI	2024-02-16 00:06:16.205+00	2024-02-16 00:06:16.205+00	VshUk7eBeK	vwHi602n66	0	3	3	3	0	\N	\N
TOIB93UFdZ	2024-02-16 00:06:16.434+00	2024-02-16 00:06:16.434+00	Otwj7uJwjr	E2hBZzDsjO	1	3	3	3	2	\N	\N
0Xvhzqrs0i	2024-02-16 00:06:17.088+00	2024-02-16 00:06:17.088+00	adE9nQrDk3	BMLzFMvIT6	4	4	0	1	2	\N	\N
Fgb16dnQ0a	2024-02-16 00:06:17.307+00	2024-02-16 00:06:17.307+00	Otwj7uJwjr	ThMuD3hYRQ	1	4	0	1	4	\N	\N
WYSg3OJPvv	2024-02-16 00:06:17.529+00	2024-02-16 00:06:17.529+00	HRhGpJpmb5	cmxBcanww9	0	0	0	4	2	\N	\N
PoGFRHZ3T1	2024-02-16 00:06:17.747+00	2024-02-16 00:06:17.747+00	R2CLtFh5jU	LDrIH1vU8x	3	1	1	4	3	\N	\N
VjODn2krpS	2024-02-16 00:06:18.008+00	2024-02-16 00:06:18.008+00	9223vtvaBd	o4VD4BWwDt	4	0	4	3	0	\N	\N
HhIBIZcO2L	2024-02-16 00:06:18.518+00	2024-02-16 00:06:18.518+00	5X202ssb0D	HXtEwLBC7f	4	2	3	3	0	\N	\N
jzkLi8apn8	2024-02-16 00:06:18.824+00	2024-02-16 00:06:18.824+00	AsrLUQwxI9	JLhF4VuByh	1	4	2	3	0	\N	\N
oW6bDfM8uV	2024-02-16 00:06:19.037+00	2024-02-16 00:06:19.037+00	HtEtaHBVDN	MQfxuw3ERg	1	3	1	2	4	\N	\N
OlIZ4FZgEZ	2024-02-16 00:06:19.25+00	2024-02-16 00:06:19.25+00	9223vtvaBd	yvUod6yLDt	1	2	0	0	0	\N	\N
nVHJaQBY2H	2024-02-16 00:06:19.463+00	2024-02-16 00:06:19.463+00	Otwj7uJwjr	vwHi602n66	3	1	2	1	2	\N	\N
63rVFpsSta	2024-02-16 00:06:19.675+00	2024-02-16 00:06:19.675+00	AsrLUQwxI9	bi1IivsuUB	3	2	4	2	4	\N	\N
Ku6N0uB1VG	2024-02-16 00:06:19.887+00	2024-02-16 00:06:19.887+00	dEqAHvPMXA	lxQA9rtSfY	2	2	1	0	3	\N	\N
yRFZMxg2qS	2024-02-16 00:06:20.157+00	2024-02-16 00:06:20.157+00	NjxsGlPeB4	G0uU7KQLEt	1	3	0	2	3	\N	\N
aEBm3VHjUY	2024-02-16 00:06:20.371+00	2024-02-16 00:06:20.371+00	iUlyHNFGpG	IybX0eBoO3	4	3	1	0	3	\N	\N
6nBX3PvqqB	2024-02-16 00:06:20.875+00	2024-02-16 00:06:20.875+00	dEqAHvPMXA	mMYg4cyd5R	4	2	1	0	0	\N	\N
VPBBodz3BY	2024-02-16 00:06:21.075+00	2024-02-16 00:06:21.075+00	AsrLUQwxI9	cmxBcanww9	3	1	4	4	4	\N	\N
OlDYWc8TS1	2024-02-16 00:06:21.28+00	2024-02-16 00:06:21.28+00	R2CLtFh5jU	RkhjIQJgou	4	0	4	2	1	\N	\N
ZK751DRP82	2024-02-16 00:06:21.491+00	2024-02-16 00:06:21.491+00	9223vtvaBd	JRi61dUphq	0	2	4	4	0	\N	\N
WhUnLFG7GD	2024-02-16 00:06:21.703+00	2024-02-16 00:06:21.703+00	dEqAHvPMXA	G0uU7KQLEt	3	4	2	3	0	\N	\N
UWt5p86Sls	2024-02-16 00:06:21.936+00	2024-02-16 00:06:21.936+00	NjxsGlPeB4	Pja6n3yaWZ	0	2	4	1	4	\N	\N
pmHVIMFCUd	2024-02-16 00:06:22.164+00	2024-02-16 00:06:22.164+00	sHiqaG4iqY	m6g8u0QpTC	0	1	0	2	3	\N	\N
HFpdJv0iGJ	2024-02-16 00:06:22.373+00	2024-02-16 00:06:22.373+00	iWxl9obi8w	JRi61dUphq	2	4	1	2	2	\N	\N
U3WtSwfv67	2024-02-16 00:06:22.586+00	2024-02-16 00:06:22.586+00	R2CLtFh5jU	NY6RE1qgWu	1	0	2	2	3	\N	\N
0DB2lB6q3c	2024-02-16 00:06:22.798+00	2024-02-16 00:06:22.798+00	HRhGpJpmb5	rKyjwoEIRp	4	0	1	3	2	\N	\N
YWSgQW3LPb	2024-02-16 00:06:23.127+00	2024-02-16 00:06:23.127+00	I5RzFRcQ7G	XwszrNEEEj	0	3	4	2	1	\N	\N
ZE8dNDuae8	2024-02-16 00:06:23.344+00	2024-02-16 00:06:23.344+00	opW2wQ2bZ8	vwHi602n66	2	0	3	0	1	\N	\N
pQFlmbeljn	2024-02-16 00:06:23.559+00	2024-02-16 00:06:23.559+00	opW2wQ2bZ8	vwHi602n66	3	2	2	0	3	\N	\N
5TsT13MMCG	2024-02-16 00:06:23.772+00	2024-02-16 00:06:23.772+00	opW2wQ2bZ8	08liHW08uC	1	2	4	0	4	\N	\N
Uj1t3UlRCB	2024-02-16 00:06:23.983+00	2024-02-16 00:06:23.983+00	opW2wQ2bZ8	JZOBDAh12a	2	1	0	0	2	\N	\N
1sxW0njqLR	2024-02-16 00:06:24.196+00	2024-02-16 00:06:24.196+00	ONgyydfVNz	OQWu2bnHeC	2	3	3	3	4	\N	\N
fBzsbFikuL	2024-02-16 00:06:24.398+00	2024-02-16 00:06:24.398+00	SFAISec8QF	cmxBcanww9	4	1	0	0	2	\N	\N
kkkNihZmat	2024-02-16 00:06:24.608+00	2024-02-16 00:06:24.608+00	HRhGpJpmb5	JLhF4VuByh	1	0	1	0	0	\N	\N
Z4S149nHjx	2024-02-16 00:06:24.819+00	2024-02-16 00:06:24.819+00	dZKm0wOhYa	RkhjIQJgou	4	1	1	3	1	\N	\N
5iG8bS8IqN	2024-02-16 00:06:25.029+00	2024-02-16 00:06:25.029+00	S6wz0lK0bf	LgJuu5ABe5	2	4	2	2	3	\N	\N
9TPW5O6FCE	2024-02-16 00:06:25.691+00	2024-02-16 00:06:25.691+00	Otwj7uJwjr	H40ivltLwZ	1	4	4	4	4	\N	\N
8ZIlijGDjH	2024-02-16 00:06:25.994+00	2024-02-16 00:06:25.994+00	HRhGpJpmb5	3u4B9V4l5K	2	1	1	2	3	\N	\N
Uo7yiX7XHB	2024-02-16 00:06:26.203+00	2024-02-16 00:06:26.203+00	5nv19u6KJ2	l1Bslv8T2k	1	0	3	2	4	\N	\N
OJVc8mB9Nf	2024-02-16 00:06:26.411+00	2024-02-16 00:06:26.411+00	iUlyHNFGpG	OQWu2bnHeC	3	2	0	0	2	\N	\N
FmH0uoazpE	2024-02-16 00:06:26.626+00	2024-02-16 00:06:26.626+00	jqDYoPT45X	o90lhsZ7FK	4	3	4	2	1	\N	\N
1eUYGWdDK7	2024-02-16 00:06:26.838+00	2024-02-16 00:06:26.838+00	HRhGpJpmb5	y4RkaDbkec	0	1	4	1	0	\N	\N
7cmBqPqD4Z	2024-02-16 00:06:27.054+00	2024-02-16 00:06:27.054+00	NjxsGlPeB4	l1Bslv8T2k	3	3	2	1	1	\N	\N
xVk56zGprY	2024-02-16 00:06:27.267+00	2024-02-16 00:06:27.267+00	dZKm0wOhYa	JZOBDAh12a	3	1	1	0	3	\N	\N
KQVOJsCC49	2024-02-16 00:06:27.481+00	2024-02-16 00:06:27.481+00	dZKm0wOhYa	XpUyRlB6FI	0	4	4	0	0	\N	\N
sF9njYoPA8	2024-02-16 00:06:27.695+00	2024-02-16 00:06:27.695+00	S6wz0lK0bf	fxvABtKCPT	0	3	0	3	0	\N	\N
yGig6LXOAT	2024-02-16 00:06:27.909+00	2024-02-16 00:06:27.909+00	WKpBp0c8F3	KCsJ4XR6Dn	4	2	1	4	0	\N	\N
vR1ZmgSoUt	2024-02-16 00:06:28.552+00	2024-02-16 00:06:28.552+00	RWwLSzreG2	u5FXeeOChJ	4	1	3	1	2	\N	\N
kKTUKHIuxU	2024-02-16 00:06:28.759+00	2024-02-16 00:06:28.759+00	Otwj7uJwjr	LDrIH1vU8x	4	4	0	2	3	\N	\N
v7E2DUEZiJ	2024-02-16 00:06:28.967+00	2024-02-16 00:06:28.967+00	jqDYoPT45X	BMLzFMvIT6	2	3	3	2	4	\N	\N
tBdZwQht3L	2024-02-16 00:06:29.176+00	2024-02-16 00:06:29.176+00	AsrLUQwxI9	IEqTHcohpJ	1	2	3	0	0	\N	\N
51IchaEPlP	2024-02-16 00:06:29.385+00	2024-02-16 00:06:29.385+00	adE9nQrDk3	fxvABtKCPT	4	4	1	4	3	\N	\N
hw9cERDbvy	2024-02-16 00:06:29.598+00	2024-02-16 00:06:29.598+00	1as6rMOzjQ	fKTSJPdUi9	3	0	4	2	3	\N	\N
rBRPu4Ay3g	2024-02-16 00:06:29.884+00	2024-02-16 00:06:29.884+00	dEqAHvPMXA	OQWu2bnHeC	2	0	2	3	1	\N	\N
PVKQFERzE3	2024-02-16 00:06:30.096+00	2024-02-16 00:06:30.096+00	5X202ssb0D	WnUBBkiDjE	0	3	3	1	0	\N	\N
i6uUvKeHR3	2024-02-16 00:06:30.311+00	2024-02-16 00:06:30.311+00	SFAISec8QF	rT0UCBK1bE	4	2	2	4	2	\N	\N
3J1zHsDkxk	2024-02-16 00:06:30.524+00	2024-02-16 00:06:30.524+00	NjxsGlPeB4	AgU9OLJkqz	4	4	0	4	0	\N	\N
M5A4BH82lp	2024-02-16 00:06:31.051+00	2024-02-16 00:06:31.051+00	9223vtvaBd	WBFeKac0OO	3	1	1	2	3	\N	\N
GMSKiNY3Rc	2024-02-16 00:06:31.262+00	2024-02-16 00:06:31.262+00	9223vtvaBd	D0A6GLdsDM	1	3	0	3	2	\N	\N
4PrVLFAbhg	2024-02-16 00:06:31.691+00	2024-02-16 00:06:31.691+00	WKpBp0c8F3	na5crB8ED1	3	3	3	4	1	\N	\N
qE4UiObns5	2024-02-16 00:06:31.901+00	2024-02-16 00:06:31.901+00	iUlyHNFGpG	LVYK4mLShP	2	3	2	0	3	\N	\N
cr9NMrsVoP	2024-02-16 00:06:32.108+00	2024-02-16 00:06:32.108+00	I5RzFRcQ7G	HSEugQ3Ouj	2	2	2	4	2	\N	\N
52KyeZ1VNq	2024-02-16 00:06:32.315+00	2024-02-16 00:06:32.315+00	S6wz0lK0bf	lEPdiO1EDi	2	1	3	3	3	\N	\N
o8GtC7cT9I	2024-02-16 00:06:32.526+00	2024-02-16 00:06:32.526+00	WKpBp0c8F3	yvUod6yLDt	3	1	3	4	2	\N	\N
8AGF0iFIUO	2024-02-16 00:06:32.74+00	2024-02-16 00:06:32.74+00	HRhGpJpmb5	8w7i8C3NnT	0	1	3	3	1	\N	\N
bVYkCw0rLt	2024-02-16 00:06:33.06+00	2024-02-16 00:06:33.06+00	5nv19u6KJ2	BMLzFMvIT6	2	3	2	4	4	\N	\N
2ulhhdE5Ci	2024-02-16 00:06:33.367+00	2024-02-16 00:06:33.367+00	NjxsGlPeB4	rKyjwoEIRp	1	1	1	1	4	\N	\N
GlDfAKlSGC	2024-02-16 00:06:33.579+00	2024-02-16 00:06:33.579+00	sHiqaG4iqY	UCFo58JaaD	2	0	1	1	4	\N	\N
YVsl9T13NH	2024-02-16 00:06:33.791+00	2024-02-16 00:06:33.791+00	HRhGpJpmb5	NY6RE1qgWu	2	0	4	1	1	\N	\N
AOCxkgIDIh	2024-02-16 00:06:34.006+00	2024-02-16 00:06:34.006+00	AsrLUQwxI9	m8hjjLVdPS	0	3	1	4	2	\N	\N
LgI5xNdqyl	2024-02-16 00:06:34.695+00	2024-02-16 00:06:34.695+00	mQXQWNqxg9	MQfxuw3ERg	1	0	0	1	4	\N	\N
ME8hvFMmZj	2024-02-16 00:06:34.902+00	2024-02-16 00:06:34.902+00	mQXQWNqxg9	bQ0JOk10eL	0	0	0	4	3	\N	\N
OOZ8wWKOxA	2024-02-16 00:06:35.11+00	2024-02-16 00:06:35.11+00	mAKp5BK7R1	TCkiw6gTDz	4	1	2	4	1	\N	\N
XhBu5ZeF3j	2024-02-16 00:06:35.324+00	2024-02-16 00:06:35.324+00	SFAISec8QF	UCFo58JaaD	0	4	0	0	4	\N	\N
6cTWhlWm75	2024-02-16 00:06:35.618+00	2024-02-16 00:06:35.618+00	1as6rMOzjQ	KCsJ4XR6Dn	1	0	3	4	4	\N	\N
7LV0yiJ53t	2024-02-16 00:06:35.827+00	2024-02-16 00:06:35.827+00	1as6rMOzjQ	3u4B9V4l5K	2	1	1	1	2	\N	\N
6ABHcG8pEN	2024-02-16 00:06:36.123+00	2024-02-16 00:06:36.123+00	sHiqaG4iqY	jHqCpA1nWb	2	2	2	1	1	\N	\N
fB1D8ES5B1	2024-02-16 00:06:36.341+00	2024-02-16 00:06:36.341+00	dZKm0wOhYa	axyV0Fu7pm	2	4	3	2	0	\N	\N
lK2Lt93UFV	2024-02-16 00:06:36.551+00	2024-02-16 00:06:36.551+00	NjxsGlPeB4	cFtamPA0zH	3	0	1	3	4	\N	\N
eBNfUf3kBC	2024-02-16 00:06:36.764+00	2024-02-16 00:06:36.764+00	HtEtaHBVDN	KCsJ4XR6Dn	4	3	3	3	4	\N	\N
A5QoCjuj9G	2024-02-16 00:06:36.977+00	2024-02-16 00:06:36.977+00	NjxsGlPeB4	u5FXeeOChJ	2	4	4	3	3	\N	\N
KDEDIXSuEw	2024-02-16 00:06:37.196+00	2024-02-16 00:06:37.196+00	S6wz0lK0bf	lEPdiO1EDi	1	2	1	2	3	\N	\N
Ta6SnhCdGu	2024-02-16 00:06:37.738+00	2024-02-16 00:06:37.738+00	VshUk7eBeK	m8hjjLVdPS	3	4	0	1	0	\N	\N
rVtSiBpZP1	2024-02-16 00:06:37.95+00	2024-02-16 00:06:37.95+00	SFAISec8QF	HSEugQ3Ouj	1	4	2	3	1	\N	\N
0W9troBOTa	2024-02-16 00:06:38.16+00	2024-02-16 00:06:38.16+00	iWxl9obi8w	6KvFK8yy1q	1	1	2	0	4	\N	\N
fjTZ05LAe2	2024-02-16 00:06:38.373+00	2024-02-16 00:06:38.373+00	dZKm0wOhYa	14jGmOAXcg	4	3	2	0	4	\N	\N
NxGhuxUxxX	2024-02-16 00:06:38.582+00	2024-02-16 00:06:38.582+00	mQXQWNqxg9	INeptnSdJC	1	3	3	2	4	\N	\N
FCimyNGFy4	2024-02-16 00:06:38.93+00	2024-02-16 00:06:38.93+00	1as6rMOzjQ	o90lhsZ7FK	3	1	0	1	3	\N	\N
8L6oJF0YLd	2024-02-16 00:06:39.144+00	2024-02-16 00:06:39.144+00	HRhGpJpmb5	UCFo58JaaD	1	1	1	1	0	\N	\N
ROl04OcFK0	2024-02-16 00:06:39.357+00	2024-02-16 00:06:39.357+00	I5RzFRcQ7G	m6g8u0QpTC	2	3	4	1	1	\N	\N
vf2PDRDgIf	2024-02-16 00:06:39.57+00	2024-02-16 00:06:39.57+00	5X202ssb0D	RkhjIQJgou	1	2	3	2	2	\N	\N
vjVMdCr5gF	2024-02-16 00:06:39.78+00	2024-02-16 00:06:39.78+00	mAKp5BK7R1	HLIPwAqO2R	3	2	4	4	1	\N	\N
CY320Bvnvr	2024-02-16 00:06:39.992+00	2024-02-16 00:06:39.992+00	AsrLUQwxI9	oABNR2FF6S	2	1	3	2	4	\N	\N
eS7WuL4Oal	2024-02-16 00:06:40.204+00	2024-02-16 00:06:40.204+00	iWxl9obi8w	LgJuu5ABe5	0	4	2	2	0	\N	\N
92WH78JNYC	2024-02-16 00:06:40.84+00	2024-02-16 00:06:40.84+00	iUlyHNFGpG	INeptnSdJC	0	1	2	3	3	\N	\N
nME9udQnu4	2024-02-16 00:06:41.146+00	2024-02-16 00:06:41.146+00	ONgyydfVNz	UDXF0qXvDY	0	1	2	4	1	\N	\N
ouU7rxDeXm	2024-02-16 00:06:41.762+00	2024-02-16 00:06:41.762+00	dZKm0wOhYa	fxvABtKCPT	2	3	0	3	4	\N	\N
N0ExlQ1bfh	2024-02-16 00:06:41.969+00	2024-02-16 00:06:41.969+00	Otwj7uJwjr	JLhF4VuByh	1	4	0	4	2	\N	\N
FNNdMz95Mu	2024-02-16 00:06:42.178+00	2024-02-16 00:06:42.178+00	opW2wQ2bZ8	tCIEnLLcUc	2	3	1	0	0	\N	\N
ayO6PTBgOa	2024-02-16 00:06:42.479+00	2024-02-16 00:06:42.479+00	HRhGpJpmb5	m6g8u0QpTC	2	0	1	0	2	\N	\N
SNs4n6apK6	2024-02-16 00:06:42.694+00	2024-02-16 00:06:42.694+00	AsrLUQwxI9	6KvFK8yy1q	4	2	2	4	2	\N	\N
O2CC9HAhoP	2024-02-16 00:06:42.903+00	2024-02-16 00:06:42.903+00	AsrLUQwxI9	XwWwGnkXNj	0	0	2	0	4	\N	\N
bIBHXnxYvG	2024-02-16 00:06:43.114+00	2024-02-16 00:06:43.114+00	adE9nQrDk3	XwWwGnkXNj	4	3	4	4	3	\N	\N
R6EA75THdc	2024-02-16 00:06:43.324+00	2024-02-16 00:06:43.324+00	VshUk7eBeK	IybX0eBoO3	4	0	0	2	1	\N	\N
Ie8bFJ5ezi	2024-02-16 00:06:43.605+00	2024-02-16 00:06:43.605+00	S6wz0lK0bf	OQWu2bnHeC	1	4	0	2	4	\N	\N
1uP7P54JFx	2024-02-16 00:06:43.815+00	2024-02-16 00:06:43.815+00	1as6rMOzjQ	tCIEnLLcUc	1	0	3	4	2	\N	\N
JJePcolnhZ	2024-02-16 00:06:44.03+00	2024-02-16 00:06:44.03+00	I5RzFRcQ7G	cTIjuPjyIa	4	1	0	3	2	\N	\N
bAEE9jTeub	2024-02-16 00:06:44.324+00	2024-02-16 00:06:44.324+00	jqDYoPT45X	cmxBcanww9	1	1	0	1	0	\N	\N
HEOHfIPHgG	2024-02-16 00:06:44.536+00	2024-02-16 00:06:44.536+00	mAKp5BK7R1	M0tHrt1GgV	2	2	2	2	1	\N	\N
wJBk3LrLvf	2024-02-16 00:06:44.821+00	2024-02-16 00:06:44.821+00	adE9nQrDk3	uABtFsJhJc	0	1	3	3	2	\N	\N
TdKw5GqZuX	2024-02-16 00:06:45.035+00	2024-02-16 00:06:45.035+00	sHiqaG4iqY	HSEugQ3Ouj	3	0	2	1	1	\N	\N
R8lCFLwQUc	2024-02-16 00:06:45.25+00	2024-02-16 00:06:45.25+00	dZKm0wOhYa	JRi61dUphq	0	4	1	0	0	\N	\N
HWCih0vemw	2024-02-16 00:06:45.857+00	2024-02-16 00:06:45.857+00	iWxl9obi8w	XwWwGnkXNj	2	2	3	3	0	\N	\N
KkQeFhH906	2024-02-16 00:06:46.059+00	2024-02-16 00:06:46.059+00	I5RzFRcQ7G	rKyjwoEIRp	4	3	0	1	0	\N	\N
E5DtrIBM91	2024-02-16 00:06:46.265+00	2024-02-16 00:06:46.265+00	RWwLSzreG2	JLhF4VuByh	0	4	3	4	2	\N	\N
dfqNZ7iCPx	2024-02-16 00:06:46.48+00	2024-02-16 00:06:46.48+00	1as6rMOzjQ	XwWwGnkXNj	2	2	1	2	3	\N	\N
gWY5fiMk04	2024-02-16 00:06:46.694+00	2024-02-16 00:06:46.694+00	HRhGpJpmb5	Pja6n3yaWZ	3	2	1	1	4	\N	\N
XF6n43nHRB	2024-02-16 00:06:46.986+00	2024-02-16 00:06:46.986+00	mAKp5BK7R1	Gl96vGdYHM	3	2	4	0	1	\N	\N
jQNBZeoX9Y	2024-02-16 00:06:47.199+00	2024-02-16 00:06:47.199+00	ONgyydfVNz	bi1IivsuUB	4	3	0	3	3	\N	\N
xLQQfJtZ2K	2024-02-16 00:06:47.411+00	2024-02-16 00:06:47.411+00	VshUk7eBeK	UDXF0qXvDY	2	0	4	1	2	\N	\N
12kDCVuNOb	2024-02-16 00:06:47.622+00	2024-02-16 00:06:47.622+00	S6wz0lK0bf	lxQA9rtSfY	0	2	0	0	3	\N	\N
kHXK3hZewe	2024-02-16 00:06:47.833+00	2024-02-16 00:06:47.833+00	I5RzFRcQ7G	lxQA9rtSfY	1	3	1	0	1	\N	\N
GC12GaTqcZ	2024-02-16 00:06:48.045+00	2024-02-16 00:06:48.045+00	R2CLtFh5jU	E2hBZzDsjO	2	0	2	0	0	\N	\N
V38PWlL8PJ	2024-02-16 00:06:48.262+00	2024-02-16 00:06:48.262+00	sy1HD51LXT	LVYK4mLShP	3	2	0	3	0	\N	\N
yRkq6M2adW	2024-02-16 00:06:48.522+00	2024-02-16 00:06:48.522+00	SFAISec8QF	HSEugQ3Ouj	0	4	4	4	3	\N	\N
4rLCgctBVj	2024-02-16 00:06:48.828+00	2024-02-16 00:06:48.828+00	NjxsGlPeB4	na5crB8ED1	3	4	0	3	1	\N	\N
FvFYpsFyM5	2024-02-16 00:06:49.04+00	2024-02-16 00:06:49.04+00	iUlyHNFGpG	fwLPZZ8YQa	1	1	2	0	0	\N	\N
FjW5X4TVIh	2024-02-16 00:06:49.25+00	2024-02-16 00:06:49.25+00	R2CLtFh5jU	lxQA9rtSfY	3	1	3	4	2	\N	\N
8V7wgDH2Gi	2024-02-16 00:06:49.459+00	2024-02-16 00:06:49.459+00	HtEtaHBVDN	eEmewy7hPd	1	4	1	4	4	\N	\N
QMwmmRrMYO	2024-02-16 00:06:49.668+00	2024-02-16 00:06:49.668+00	dZKm0wOhYa	3u4B9V4l5K	1	3	0	0	1	\N	\N
8suGMsuBcS	2024-02-16 00:06:49.952+00	2024-02-16 00:06:49.952+00	sy1HD51LXT	cFtamPA0zH	0	1	2	3	1	\N	\N
bX7KoPWoHQ	2024-02-16 00:06:50.159+00	2024-02-16 00:06:50.159+00	WKpBp0c8F3	OQWu2bnHeC	2	2	3	4	0	\N	\N
0ryEVjTT3e	2024-02-16 00:06:50.371+00	2024-02-16 00:06:50.371+00	sHiqaG4iqY	WHvlAGgj6c	4	2	3	2	4	\N	\N
aCaBHVufgK	2024-02-16 00:06:50.674+00	2024-02-16 00:06:50.674+00	I5RzFRcQ7G	lxQA9rtSfY	3	1	0	3	1	\N	\N
P3i5VW1fGl	2024-02-16 00:06:50.979+00	2024-02-16 00:06:50.979+00	S6wz0lK0bf	j0dWqP2C2A	0	3	3	0	0	\N	\N
2tOrcKmOvB	2024-02-16 00:06:51.287+00	2024-02-16 00:06:51.287+00	9223vtvaBd	o4VD4BWwDt	0	2	4	1	1	\N	\N
JSj4fxIjE3	2024-02-16 00:06:51.5+00	2024-02-16 00:06:51.5+00	RWwLSzreG2	VK3vnSxIy8	0	1	0	1	4	\N	\N
2zvEJ9KVZA	2024-02-16 00:06:51.716+00	2024-02-16 00:06:51.716+00	Otwj7uJwjr	axyV0Fu7pm	2	4	4	4	3	\N	\N
ZShgaXAt87	2024-02-16 00:06:51.928+00	2024-02-16 00:06:51.928+00	RWwLSzreG2	0TvWuLoLF5	4	1	0	2	0	\N	\N
LvLi40k1tR	2024-02-16 00:06:52.143+00	2024-02-16 00:06:52.143+00	HtEtaHBVDN	qZmnAnnPEb	2	0	0	0	2	\N	\N
34hUUHJqND	2024-02-16 00:06:52.353+00	2024-02-16 00:06:52.353+00	mAKp5BK7R1	AgU9OLJkqz	4	3	2	3	3	\N	\N
19vZMZcKiW	2024-02-16 00:06:52.568+00	2024-02-16 00:06:52.568+00	sy1HD51LXT	ThMuD3hYRQ	1	1	1	1	1	\N	\N
0UOSnWG2TL	2024-02-16 00:06:52.783+00	2024-02-16 00:06:52.783+00	S6wz0lK0bf	OQWu2bnHeC	1	1	2	1	2	\N	\N
7MrUm3oEd1	2024-02-16 00:06:52.997+00	2024-02-16 00:06:52.997+00	WKpBp0c8F3	14jGmOAXcg	4	2	4	2	1	\N	\N
BCyRxjBmY7	2024-02-16 00:06:53.232+00	2024-02-16 00:06:53.232+00	adE9nQrDk3	m6g8u0QpTC	4	0	2	4	0	\N	\N
34QQtaU8mL	2024-02-16 00:06:53.748+00	2024-02-16 00:06:53.748+00	RWwLSzreG2	jHqCpA1nWb	4	1	1	4	4	\N	\N
5ws62MGbjp	2024-02-16 00:06:54.05+00	2024-02-16 00:06:54.05+00	VshUk7eBeK	UDXF0qXvDY	0	1	4	0	4	\N	\N
VFD8RCSUFp	2024-02-16 00:06:54.258+00	2024-02-16 00:06:54.258+00	HtEtaHBVDN	BMLzFMvIT6	2	0	2	3	2	\N	\N
2nALWEU5qi	2024-02-16 00:06:54.468+00	2024-02-16 00:06:54.468+00	iWxl9obi8w	D0A6GLdsDM	1	2	0	4	2	\N	\N
C2vzFoQ7VA	2024-02-16 00:06:54.672+00	2024-02-16 00:06:54.672+00	dZKm0wOhYa	NY6RE1qgWu	3	0	4	0	4	\N	\N
cBYTdQ4I0M	2024-02-16 00:06:54.884+00	2024-02-16 00:06:54.884+00	sy1HD51LXT	rT0UCBK1bE	3	2	1	2	2	\N	\N
xvaLqWbbF0	2024-02-16 00:06:55.099+00	2024-02-16 00:06:55.099+00	ONgyydfVNz	HLIPwAqO2R	2	2	3	2	3	\N	\N
BHkoCyn9hg	2024-02-16 00:06:55.312+00	2024-02-16 00:06:55.312+00	NjxsGlPeB4	PF8w2gMAdi	1	0	3	1	4	\N	\N
nkRYzHnAKY	2024-02-16 00:06:55.524+00	2024-02-16 00:06:55.524+00	mQXQWNqxg9	MQfxuw3ERg	4	1	3	3	0	\N	\N
KHtY0LcuEC	2024-02-16 00:06:55.736+00	2024-02-16 00:06:55.736+00	5X202ssb0D	6KvFK8yy1q	0	2	3	4	1	\N	\N
QtXf7u9G69	2024-02-16 00:06:55.952+00	2024-02-16 00:06:55.952+00	opW2wQ2bZ8	8w7i8C3NnT	3	2	2	2	2	\N	\N
dsaxFk56mK	2024-02-16 00:06:56.161+00	2024-02-16 00:06:56.161+00	5X202ssb0D	lEPdiO1EDi	4	0	3	4	1	\N	\N
i75xwwgyzW	2024-02-16 00:06:56.373+00	2024-02-16 00:06:56.373+00	sy1HD51LXT	BMLzFMvIT6	1	0	4	0	1	\N	\N
Qygx9gNLx4	2024-02-16 00:06:56.613+00	2024-02-16 00:06:56.613+00	jqDYoPT45X	UDXF0qXvDY	0	4	2	3	4	\N	\N
XugCDd3Znd	2024-02-16 00:06:56.827+00	2024-02-16 00:06:56.827+00	HRhGpJpmb5	TCkiw6gTDz	4	3	3	0	3	\N	\N
el604doZ1y	2024-02-16 00:06:57.041+00	2024-02-16 00:06:57.041+00	iUlyHNFGpG	PF8w2gMAdi	0	1	4	0	2	\N	\N
nQcqBUq8JG	2024-02-16 00:06:57.256+00	2024-02-16 00:06:57.256+00	R2CLtFh5jU	XpUyRlB6FI	0	3	3	3	0	\N	\N
5FAPIyZ4zu	2024-02-16 00:06:57.533+00	2024-02-16 00:06:57.533+00	5X202ssb0D	WHvlAGgj6c	2	0	4	1	2	\N	\N
zwFJJwa8XA	2024-02-16 00:06:57.839+00	2024-02-16 00:06:57.839+00	SFAISec8QF	LgJuu5ABe5	0	0	3	0	0	\N	\N
blFOGiXkDZ	2024-02-16 00:06:58.146+00	2024-02-16 00:06:58.146+00	sHiqaG4iqY	vwHi602n66	3	2	1	0	1	\N	\N
Iysf9Znvpb	2024-02-16 00:06:58.355+00	2024-02-16 00:06:58.355+00	iWxl9obi8w	WnUBBkiDjE	2	4	3	3	2	\N	\N
VDzVzFnDmL	2024-02-16 00:06:58.565+00	2024-02-16 00:06:58.565+00	RWwLSzreG2	LDrIH1vU8x	0	4	0	2	1	\N	\N
bGSOjMwGlZ	2024-02-16 00:06:58.776+00	2024-02-16 00:06:58.776+00	HRhGpJpmb5	MQfxuw3ERg	3	1	0	3	3	\N	\N
OzP19dnYGR	2024-02-16 00:06:58.987+00	2024-02-16 00:06:58.987+00	opW2wQ2bZ8	lEPdiO1EDi	3	3	4	1	2	\N	\N
BfAueMCL84	2024-02-16 00:06:59.199+00	2024-02-16 00:06:59.199+00	jqDYoPT45X	jHqCpA1nWb	2	2	4	1	3	\N	\N
2FFOqMdYzy	2024-02-16 00:06:59.479+00	2024-02-16 00:06:59.479+00	WKpBp0c8F3	WBFeKac0OO	3	4	2	3	0	\N	\N
ImsZBYIvHY	2024-02-16 00:06:59.69+00	2024-02-16 00:06:59.69+00	RWwLSzreG2	89xRG1afNi	3	0	0	2	1	\N	\N
7QoTFIFM9z	2024-02-16 00:06:59.903+00	2024-02-16 00:06:59.903+00	dZKm0wOhYa	uABtFsJhJc	2	1	0	1	1	\N	\N
QMAq7MfQOH	2024-02-16 00:07:00.117+00	2024-02-16 00:07:00.117+00	S6wz0lK0bf	FJOTueDfs2	4	0	4	0	2	\N	\N
I6YqXlvkbH	2024-02-16 00:07:00.401+00	2024-02-16 00:07:00.401+00	R2CLtFh5jU	AgU9OLJkqz	1	1	4	2	4	\N	\N
0UrgLufEzQ	2024-02-16 00:07:00.618+00	2024-02-16 00:07:00.618+00	VshUk7eBeK	3u4B9V4l5K	3	0	2	4	3	\N	\N
MqBJ8pPr0A	2024-02-16 00:07:00.829+00	2024-02-16 00:07:00.829+00	adE9nQrDk3	WnUBBkiDjE	4	0	1	4	0	\N	\N
1U9tMVjfeD	2024-02-16 00:07:01.037+00	2024-02-16 00:07:01.037+00	Otwj7uJwjr	E2hBZzDsjO	1	1	0	1	1	\N	\N
AwqgGuacNS	2024-02-16 00:07:01.322+00	2024-02-16 00:07:01.322+00	I5RzFRcQ7G	na5crB8ED1	1	0	1	1	0	\N	\N
8jPT792Xbs	2024-02-16 00:07:01.536+00	2024-02-16 00:07:01.536+00	sHiqaG4iqY	RkhjIQJgou	0	0	4	4	4	\N	\N
DcaeAWttQQ	2024-02-16 00:07:01.747+00	2024-02-16 00:07:01.747+00	mAKp5BK7R1	Pja6n3yaWZ	1	2	3	3	1	\N	\N
fuoV1sDftX	2024-02-16 00:07:01.961+00	2024-02-16 00:07:01.961+00	dEqAHvPMXA	6KvFK8yy1q	2	4	4	0	2	\N	\N
dpuuBYtJQX	2024-02-16 00:07:02.244+00	2024-02-16 00:07:02.244+00	Otwj7uJwjr	fxvABtKCPT	1	1	1	0	2	\N	\N
Sf8Dognpcz	2024-02-16 00:07:02.457+00	2024-02-16 00:07:02.457+00	sHiqaG4iqY	y4RkaDbkec	3	0	2	4	4	\N	\N
15E2r8siPh	2024-02-16 00:07:02.856+00	2024-02-16 00:07:02.856+00	opW2wQ2bZ8	NY6RE1qgWu	0	0	0	1	4	\N	\N
vpXjZOGTyw	2024-02-16 00:07:03.065+00	2024-02-16 00:07:03.065+00	iWxl9obi8w	CSvk1ycWXk	0	4	0	4	3	\N	\N
jeJmmtUKOP	2024-02-16 00:07:03.273+00	2024-02-16 00:07:03.273+00	iUlyHNFGpG	XwszrNEEEj	0	1	3	4	1	\N	\N
A1YyvdcEV3	2024-02-16 00:07:03.573+00	2024-02-16 00:07:03.573+00	5X202ssb0D	bQ0JOk10eL	1	3	1	0	1	\N	\N
4IsbijVHGG	2024-02-16 00:07:04.183+00	2024-02-16 00:07:04.183+00	sy1HD51LXT	IybX0eBoO3	0	3	3	0	1	\N	\N
j9fWkHHCPg	2024-02-16 00:07:04.392+00	2024-02-16 00:07:04.392+00	HtEtaHBVDN	axyV0Fu7pm	2	4	3	1	1	\N	\N
48zxQvrrBo	2024-02-16 00:07:04.698+00	2024-02-16 00:07:04.698+00	5nv19u6KJ2	0TvWuLoLF5	4	0	3	3	3	\N	\N
hhuF5lEtUH	2024-02-16 00:07:04.908+00	2024-02-16 00:07:04.908+00	adE9nQrDk3	m6g8u0QpTC	4	0	4	4	2	\N	\N
bVykIgBZHX	2024-02-16 00:07:05.207+00	2024-02-16 00:07:05.207+00	AsrLUQwxI9	vwHi602n66	2	4	3	4	0	\N	\N
gIh6tCxEDH	2024-02-16 00:07:05.519+00	2024-02-16 00:07:05.519+00	S6wz0lK0bf	HLIPwAqO2R	2	0	0	2	1	\N	\N
hEo6Bv3N8n	2024-02-16 00:07:05.729+00	2024-02-16 00:07:05.729+00	HRhGpJpmb5	IEqTHcohpJ	3	0	3	1	2	\N	\N
C0pbgDt0XV	2024-02-16 00:07:05.939+00	2024-02-16 00:07:05.939+00	ONgyydfVNz	qP3EdIVzfB	1	3	1	4	3	\N	\N
hVfxGT32zs	2024-02-16 00:07:06.235+00	2024-02-16 00:07:06.235+00	9223vtvaBd	PF8w2gMAdi	1	4	1	3	2	\N	\N
qd25e0mBHA	2024-02-16 00:07:06.459+00	2024-02-16 00:07:06.459+00	1as6rMOzjQ	EmIUBFwx0Z	0	4	4	2	0	\N	\N
EeAhcZiNXR	2024-02-16 00:07:06.679+00	2024-02-16 00:07:06.679+00	HRhGpJpmb5	uigc7bJBOJ	0	4	4	2	3	\N	\N
BK2SjxJ5G7	2024-02-16 00:07:06.888+00	2024-02-16 00:07:06.888+00	I5RzFRcQ7G	uigc7bJBOJ	3	1	2	4	1	\N	\N
lzDC1gjTAU	2024-02-16 00:07:07.159+00	2024-02-16 00:07:07.159+00	ONgyydfVNz	o4VD4BWwDt	3	1	2	3	3	\N	\N
4YhcMppIol	2024-02-16 00:07:07.371+00	2024-02-16 00:07:07.371+00	VshUk7eBeK	XwszrNEEEj	1	2	2	1	1	\N	\N
oBkeWVCDHL	2024-02-16 00:07:07.672+00	2024-02-16 00:07:07.672+00	opW2wQ2bZ8	VK3vnSxIy8	3	4	4	2	4	\N	\N
87Ppl5XGBf	2024-02-16 00:07:07.882+00	2024-02-16 00:07:07.882+00	HtEtaHBVDN	BMLzFMvIT6	3	3	4	1	2	\N	\N
7ENTJrLWR9	2024-02-16 00:07:08.096+00	2024-02-16 00:07:08.096+00	jqDYoPT45X	TCkiw6gTDz	3	0	4	0	3	\N	\N
v25NDFUGDw	2024-02-16 00:07:08.685+00	2024-02-16 00:07:08.685+00	SFAISec8QF	mMYg4cyd5R	4	0	1	1	2	\N	\N
JXzkDSAWuB	2024-02-16 00:07:09.307+00	2024-02-16 00:07:09.307+00	Otwj7uJwjr	M0tHrt1GgV	0	1	0	4	4	\N	\N
Ft2TCJ3y8U	2024-02-16 00:07:09.611+00	2024-02-16 00:07:09.611+00	NjxsGlPeB4	Pja6n3yaWZ	1	1	2	4	1	\N	\N
GmX3TY8C46	2024-02-16 00:07:09.816+00	2024-02-16 00:07:09.816+00	HRhGpJpmb5	JLhF4VuByh	1	1	3	0	1	\N	\N
VJDEN0Q5TC	2024-02-16 00:07:10.024+00	2024-02-16 00:07:10.024+00	adE9nQrDk3	VK3vnSxIy8	4	2	4	2	1	\N	\N
P7Ej2deBEM	2024-02-16 00:07:10.232+00	2024-02-16 00:07:10.232+00	mAKp5BK7R1	l1Bslv8T2k	2	3	2	4	3	\N	\N
q02cDWvTFq	2024-02-16 00:07:10.843+00	2024-02-16 00:07:10.843+00	S6wz0lK0bf	P9sBFomftT	2	0	2	0	2	\N	\N
G6YW9GdqsP	2024-02-16 00:07:11.149+00	2024-02-16 00:07:11.149+00	HtEtaHBVDN	LDrIH1vU8x	1	4	2	3	0	\N	\N
fRMaHV4z4p	2024-02-16 00:07:11.595+00	2024-02-16 00:07:11.595+00	HtEtaHBVDN	D0A6GLdsDM	2	1	2	4	3	\N	\N
FcM9AnUYZe	2024-02-16 00:07:11.804+00	2024-02-16 00:07:11.804+00	R2CLtFh5jU	LgJuu5ABe5	0	3	3	2	1	\N	\N
mr6RQUBBbC	2024-02-16 00:07:12.073+00	2024-02-16 00:07:12.073+00	dZKm0wOhYa	lEPdiO1EDi	2	2	1	0	1	\N	\N
vKxWA4wX9t	2024-02-16 00:07:12.285+00	2024-02-16 00:07:12.285+00	WKpBp0c8F3	8w7i8C3NnT	4	3	4	1	1	\N	\N
9tqAuiTkIE	2024-02-16 00:07:12.496+00	2024-02-16 00:07:12.496+00	adE9nQrDk3	UDXF0qXvDY	0	0	0	1	4	\N	\N
x2GOHwq8uS	2024-02-16 00:07:12.79+00	2024-02-16 00:07:12.79+00	1as6rMOzjQ	Oahm9sOn1y	2	4	4	3	3	\N	\N
6N7AH0N9cS	2024-02-16 00:07:12.999+00	2024-02-16 00:07:12.999+00	Otwj7uJwjr	9GF3y7LmHV	0	2	4	3	1	\N	\N
IqJ3OONoWz	2024-02-16 00:07:13.212+00	2024-02-16 00:07:13.212+00	dZKm0wOhYa	jHqCpA1nWb	1	4	1	4	2	\N	\N
AMfg6BWrfl	2024-02-16 00:07:13.424+00	2024-02-16 00:07:13.424+00	I5RzFRcQ7G	HXtEwLBC7f	1	2	3	2	1	\N	\N
OVmlRcE1bs	2024-02-16 00:07:13.64+00	2024-02-16 00:07:13.64+00	S6wz0lK0bf	WBFeKac0OO	2	3	0	3	4	\N	\N
TaNeDKgdeH	2024-02-16 00:07:13.851+00	2024-02-16 00:07:13.851+00	5nv19u6KJ2	qEQ9tmLyW9	0	3	0	3	4	\N	\N
tRnsOugfDd	2024-02-16 00:07:14.062+00	2024-02-16 00:07:14.062+00	iWxl9obi8w	LVYK4mLShP	4	3	1	2	3	\N	\N
IooQ9oQDji	2024-02-16 00:07:14.326+00	2024-02-16 00:07:14.326+00	1as6rMOzjQ	o90lhsZ7FK	0	4	1	0	0	\N	\N
hqKQLBwxtm	2024-02-16 00:07:14.537+00	2024-02-16 00:07:14.537+00	WKpBp0c8F3	HSEugQ3Ouj	0	3	3	1	0	\N	\N
vkgb09zXb2	2024-02-16 00:07:14.748+00	2024-02-16 00:07:14.748+00	1as6rMOzjQ	cFtamPA0zH	1	0	0	2	1	\N	\N
95HFITpNMs	2024-02-16 00:07:14.965+00	2024-02-16 00:07:14.965+00	HRhGpJpmb5	WBFeKac0OO	4	2	2	1	4	\N	\N
WiGAJgwJId	2024-02-16 00:07:15.177+00	2024-02-16 00:07:15.177+00	jqDYoPT45X	bQpy9LEJWn	0	2	2	4	3	\N	\N
uGehXj0n8e	2024-02-16 00:07:15.759+00	2024-02-16 00:07:15.759+00	mAKp5BK7R1	eEmewy7hPd	1	3	4	2	4	\N	\N
48Q8fWK9la	2024-02-16 00:07:15.972+00	2024-02-16 00:07:15.972+00	5X202ssb0D	08liHW08uC	1	3	2	3	2	\N	\N
oo2wMBTIRc	2024-02-16 00:07:16.182+00	2024-02-16 00:07:16.182+00	mQXQWNqxg9	lxQA9rtSfY	2	3	1	4	1	\N	\N
1HrUMVFlBo	2024-02-16 00:07:16.396+00	2024-02-16 00:07:16.396+00	AsrLUQwxI9	FJOTueDfs2	2	3	0	2	0	\N	\N
5bbJ1EGSzM	2024-02-16 00:07:16.985+00	2024-02-16 00:07:16.985+00	dZKm0wOhYa	IEqTHcohpJ	3	3	1	4	0	\N	\N
GDy2bVlnPn	2024-02-16 00:07:17.192+00	2024-02-16 00:07:17.192+00	HRhGpJpmb5	tCIEnLLcUc	3	2	1	2	0	\N	\N
NHXFJ7oHH4	2024-02-16 00:07:17.401+00	2024-02-16 00:07:17.401+00	WKpBp0c8F3	JLhF4VuByh	4	0	3	1	0	\N	\N
UefSDeQGVv	2024-02-16 00:07:17.609+00	2024-02-16 00:07:17.609+00	sy1HD51LXT	u5FXeeOChJ	4	3	2	4	4	\N	\N
PbTpQFWNZd	2024-02-16 00:07:17.909+00	2024-02-16 00:07:17.909+00	sHiqaG4iqY	uigc7bJBOJ	3	2	4	3	4	\N	\N
1zVvOOOvYB	2024-02-16 00:07:18.215+00	2024-02-16 00:07:18.215+00	5X202ssb0D	UDXF0qXvDY	2	1	0	2	2	\N	\N
5Qqv5gmu9i	2024-02-16 00:07:18.423+00	2024-02-16 00:07:18.423+00	mQXQWNqxg9	Pja6n3yaWZ	2	0	4	3	4	\N	\N
1EV1rVsCAa	2024-02-16 00:07:18.634+00	2024-02-16 00:07:18.634+00	dEqAHvPMXA	cmxBcanww9	2	4	4	2	2	\N	\N
WOrdtd0gXm	2024-02-16 00:07:18.847+00	2024-02-16 00:07:18.847+00	I5RzFRcQ7G	bQpy9LEJWn	2	2	2	2	1	\N	\N
q8hheBLEl2	2024-02-16 00:07:19.064+00	2024-02-16 00:07:19.064+00	HtEtaHBVDN	3P6kmNoY1F	2	3	1	4	4	\N	\N
Z32H7FqzYm	2024-02-16 00:07:19.281+00	2024-02-16 00:07:19.281+00	9223vtvaBd	uigc7bJBOJ	0	1	2	4	3	\N	\N
UJqZAFLZig	2024-02-16 00:07:19.956+00	2024-02-16 00:07:19.956+00	RWwLSzreG2	EmIUBFwx0Z	2	1	0	4	1	\N	\N
3ZfQG8xSGM	2024-02-16 00:07:20.168+00	2024-02-16 00:07:20.168+00	ONgyydfVNz	NBojpORh3G	4	4	1	2	3	\N	\N
jLvdf9x8Mc	2024-02-16 00:07:20.38+00	2024-02-16 00:07:20.38+00	AsrLUQwxI9	WnUBBkiDjE	4	0	3	4	3	\N	\N
OTIhsrLvwd	2024-02-16 00:07:20.592+00	2024-02-16 00:07:20.592+00	dZKm0wOhYa	cwVEh0dqfm	3	4	3	3	4	\N	\N
7G3sDaaP19	2024-02-16 00:07:20.803+00	2024-02-16 00:07:20.803+00	jqDYoPT45X	rKyjwoEIRp	2	3	2	1	3	\N	\N
uNmBY0V52a	2024-02-16 00:07:21.075+00	2024-02-16 00:07:21.075+00	AsrLUQwxI9	JZOBDAh12a	3	3	1	4	2	\N	\N
vMgQzzRuq4	2024-02-16 00:07:21.28+00	2024-02-16 00:07:21.28+00	dZKm0wOhYa	6Fo67rhTSP	3	2	0	3	1	\N	\N
Qrx0lRRWgQ	2024-02-16 00:07:21.494+00	2024-02-16 00:07:21.494+00	I5RzFRcQ7G	WBFeKac0OO	4	1	4	0	1	\N	\N
C1JyfP1iUy	2024-02-16 00:07:21.803+00	2024-02-16 00:07:21.803+00	WKpBp0c8F3	yvUod6yLDt	3	3	4	3	4	\N	\N
SrfV79KO6T	2024-02-16 00:07:22.013+00	2024-02-16 00:07:22.013+00	sy1HD51LXT	FJOTueDfs2	3	1	4	0	3	\N	\N
2r0onITR2n	2024-02-16 00:07:22.224+00	2024-02-16 00:07:22.224+00	R2CLtFh5jU	axyV0Fu7pm	0	4	3	4	0	\N	\N
fW4AcWmAoj	2024-02-16 00:07:22.435+00	2024-02-16 00:07:22.435+00	sHiqaG4iqY	lEPdiO1EDi	2	1	4	2	4	\N	\N
EUoDD9MQ1t	2024-02-16 00:07:22.723+00	2024-02-16 00:07:22.723+00	I5RzFRcQ7G	08liHW08uC	0	1	0	2	0	\N	\N
4X1sLjSeaB	2024-02-16 00:07:22.935+00	2024-02-16 00:07:22.935+00	ONgyydfVNz	axyV0Fu7pm	4	1	2	2	3	\N	\N
Gk8u0afFoK	2024-02-16 00:07:23.145+00	2024-02-16 00:07:23.145+00	mQXQWNqxg9	Gl96vGdYHM	4	1	1	3	1	\N	\N
JXfB4hfVBy	2024-02-16 00:07:23.357+00	2024-02-16 00:07:23.357+00	sy1HD51LXT	XwszrNEEEj	2	2	2	1	1	\N	\N
JAKkdk9n7H	2024-02-16 00:07:23.571+00	2024-02-16 00:07:23.571+00	ONgyydfVNz	C7II8dYRPY	1	3	1	2	0	\N	\N
fCeGbZQjaw	2024-02-16 00:07:23.787+00	2024-02-16 00:07:23.787+00	R2CLtFh5jU	cwVEh0dqfm	2	3	0	2	4	\N	\N
2eSFCZCAb1	2024-02-16 00:07:24.362+00	2024-02-16 00:07:24.362+00	Otwj7uJwjr	FYXEfIO1zF	2	0	0	3	1	\N	\N
Jz8zrXWGM4	2024-02-16 00:07:24.572+00	2024-02-16 00:07:24.572+00	VshUk7eBeK	C7II8dYRPY	3	1	4	2	4	\N	\N
nbQdOj7xBd	2024-02-16 00:07:24.779+00	2024-02-16 00:07:24.779+00	mQXQWNqxg9	OQWu2bnHeC	3	1	3	0	1	\N	\N
gPk7edS1r5	2024-02-16 00:07:24.992+00	2024-02-16 00:07:24.992+00	ONgyydfVNz	fKTSJPdUi9	3	2	3	4	0	\N	\N
dEM1LSVwUv	2024-02-16 00:07:25.2+00	2024-02-16 00:07:25.2+00	5X202ssb0D	HXtEwLBC7f	4	3	0	4	1	\N	\N
T46LPYw4HK	2024-02-16 00:07:25.488+00	2024-02-16 00:07:25.488+00	dZKm0wOhYa	PF8w2gMAdi	1	1	3	1	3	\N	\N
HvN9uXoxw2	2024-02-16 00:07:25.702+00	2024-02-16 00:07:25.702+00	ONgyydfVNz	qP3EdIVzfB	2	0	1	0	1	\N	\N
VjfuqDzym3	2024-02-16 00:07:25.915+00	2024-02-16 00:07:25.915+00	R2CLtFh5jU	RBRcyltRSC	3	4	4	4	0	\N	\N
euH5hFjYs3	2024-02-16 00:07:26.122+00	2024-02-16 00:07:26.122+00	SFAISec8QF	UCFo58JaaD	0	2	2	1	1	\N	\N
zsLEl6xnRq	2024-02-16 00:07:26.41+00	2024-02-16 00:07:26.41+00	ONgyydfVNz	14jGmOAXcg	1	2	4	3	0	\N	\N
HBVA7Lj1vP	2024-02-16 00:07:26.622+00	2024-02-16 00:07:26.622+00	iUlyHNFGpG	jjVdtithcD	4	0	0	4	0	\N	\N
muQMZSCs2C	2024-02-16 00:07:26.832+00	2024-02-16 00:07:26.832+00	NjxsGlPeB4	PF8w2gMAdi	2	4	3	3	3	\N	\N
S4Y5H2HCOW	2024-02-16 00:07:27.048+00	2024-02-16 00:07:27.048+00	NjxsGlPeB4	u5FXeeOChJ	2	4	1	4	1	\N	\N
jXyHHoOYCo	2024-02-16 00:07:27.261+00	2024-02-16 00:07:27.261+00	5nv19u6KJ2	MQfxuw3ERg	3	4	2	2	0	\N	\N
iq9olRa6Vy	2024-02-16 00:07:27.535+00	2024-02-16 00:07:27.535+00	5nv19u6KJ2	Gl96vGdYHM	1	3	0	3	0	\N	\N
h4c3lLtaGB	2024-02-16 00:07:27.746+00	2024-02-16 00:07:27.746+00	opW2wQ2bZ8	rT0UCBK1bE	4	4	0	1	2	\N	\N
eATVxHn5SQ	2024-02-16 00:07:28.048+00	2024-02-16 00:07:28.048+00	I5RzFRcQ7G	RkhjIQJgou	4	2	1	0	3	\N	\N
MC8xdctOxY	2024-02-16 00:07:28.356+00	2024-02-16 00:07:28.356+00	HtEtaHBVDN	lEPdiO1EDi	1	1	1	4	4	\N	\N
uLp8smCUtq	2024-02-16 00:07:28.565+00	2024-02-16 00:07:28.565+00	AsrLUQwxI9	cTIjuPjyIa	1	4	0	4	1	\N	\N
oKyqEpy4Yd	2024-02-16 00:07:28.773+00	2024-02-16 00:07:28.773+00	Otwj7uJwjr	o90lhsZ7FK	4	3	4	1	0	\N	\N
FD7AdHhqvM	2024-02-16 00:07:29.374+00	2024-02-16 00:07:29.374+00	VshUk7eBeK	AgU9OLJkqz	4	0	0	1	3	\N	\N
NDJe9p5PXA	2024-02-16 00:07:29.579+00	2024-02-16 00:07:29.579+00	5nv19u6KJ2	TpGyMZM9BG	3	4	2	2	1	\N	\N
okolz2lOGT	2024-02-16 00:07:29.787+00	2024-02-16 00:07:29.787+00	jqDYoPT45X	HSEugQ3Ouj	0	0	0	4	3	\N	\N
CxbbPacDHg	2024-02-16 00:07:30.093+00	2024-02-16 00:07:30.093+00	I5RzFRcQ7G	3u4B9V4l5K	0	3	4	4	4	\N	\N
YEXxY36Gk2	2024-02-16 00:07:30.4+00	2024-02-16 00:07:30.4+00	R2CLtFh5jU	6KvFK8yy1q	2	0	3	2	2	\N	\N
zzV8I2m4Rt	2024-02-16 00:07:30.608+00	2024-02-16 00:07:30.608+00	HtEtaHBVDN	Gl96vGdYHM	2	0	4	2	2	\N	\N
MLDcl7UOXD	2024-02-16 00:07:30.817+00	2024-02-16 00:07:30.817+00	5nv19u6KJ2	l1Bslv8T2k	3	2	4	4	1	\N	\N
Yv0GxRkyKO	2024-02-16 00:07:31.027+00	2024-02-16 00:07:31.027+00	dZKm0wOhYa	P9sBFomftT	4	1	4	3	0	\N	\N
DIQpQ1CPFI	2024-02-16 00:07:31.237+00	2024-02-16 00:07:31.237+00	SFAISec8QF	MQfxuw3ERg	3	0	4	1	2	\N	\N
uFtEVF0MjB	2024-02-16 00:07:31.449+00	2024-02-16 00:07:31.449+00	mQXQWNqxg9	ThMuD3hYRQ	0	4	4	1	2	\N	\N
hSjzHuREUJ	2024-02-16 00:07:31.658+00	2024-02-16 00:07:31.658+00	VshUk7eBeK	XwWwGnkXNj	4	2	4	1	4	\N	\N
UI6UNXLYuG	2024-02-16 00:07:31.869+00	2024-02-16 00:07:31.869+00	9223vtvaBd	oABNR2FF6S	4	3	3	4	1	\N	\N
LEzD6hlsCs	2024-02-16 00:07:32.446+00	2024-02-16 00:07:32.446+00	SFAISec8QF	bQ0JOk10eL	1	2	2	1	4	\N	\N
VQyzrBqo0C	2024-02-16 00:07:32.755+00	2024-02-16 00:07:32.755+00	dEqAHvPMXA	cwVEh0dqfm	0	4	3	1	3	\N	\N
dUUURIL1fb	2024-02-16 00:07:33.064+00	2024-02-16 00:07:33.064+00	SFAISec8QF	m8hjjLVdPS	1	0	0	4	3	\N	\N
JeFyxgYTCM	2024-02-16 00:07:33.372+00	2024-02-16 00:07:33.372+00	iUlyHNFGpG	Pja6n3yaWZ	0	3	4	0	3	\N	\N
JGWVQLqz5k	2024-02-16 00:07:33.581+00	2024-02-16 00:07:33.581+00	mAKp5BK7R1	LDrIH1vU8x	0	2	0	0	4	\N	\N
ICM0mXYAAO	2024-02-16 00:07:33.789+00	2024-02-16 00:07:33.789+00	dEqAHvPMXA	uABtFsJhJc	1	4	1	4	1	\N	\N
0MGHXpafxk	2024-02-16 00:07:33.994+00	2024-02-16 00:07:33.994+00	dZKm0wOhYa	cmxBcanww9	2	0	0	0	4	\N	\N
OSHyEifUaq	2024-02-16 00:07:34.204+00	2024-02-16 00:07:34.204+00	jqDYoPT45X	6Fo67rhTSP	0	1	1	1	4	\N	\N
bXC12oLoOA	2024-02-16 00:07:34.416+00	2024-02-16 00:07:34.416+00	dEqAHvPMXA	KCsJ4XR6Dn	1	3	1	4	4	\N	\N
pKY9nDCJq8	2024-02-16 00:07:34.628+00	2024-02-16 00:07:34.628+00	NjxsGlPeB4	FJOTueDfs2	0	1	3	3	0	\N	\N
GIhvAgLD8c	2024-02-16 00:07:34.839+00	2024-02-16 00:07:34.839+00	HtEtaHBVDN	INeptnSdJC	3	0	3	3	2	\N	\N
Ltjkl6AFgF	2024-02-16 00:07:35.111+00	2024-02-16 00:07:35.111+00	HtEtaHBVDN	H40ivltLwZ	3	4	2	0	4	\N	\N
MUFZCfTJTm	2024-02-16 00:07:35.417+00	2024-02-16 00:07:35.417+00	dZKm0wOhYa	MQfxuw3ERg	3	0	3	4	0	\N	\N
zFPTkPHdNZ	2024-02-16 00:07:35.626+00	2024-02-16 00:07:35.626+00	jqDYoPT45X	Pa0qBO2rzK	4	0	3	1	0	\N	\N
NcnDPRGP0S	2024-02-16 00:07:35.931+00	2024-02-16 00:07:35.931+00	mQXQWNqxg9	UCFo58JaaD	2	4	0	3	1	\N	\N
L5zb0iiSt6	2024-02-16 00:07:36.544+00	2024-02-16 00:07:36.544+00	5nv19u6KJ2	cmxBcanww9	0	1	4	1	3	\N	\N
1vjsbpqUo8	2024-02-16 00:07:36.757+00	2024-02-16 00:07:36.757+00	5nv19u6KJ2	jjVdtithcD	0	0	4	1	2	\N	\N
rtoVSFoKj8	2024-02-16 00:07:36.964+00	2024-02-16 00:07:36.964+00	dZKm0wOhYa	IEqTHcohpJ	4	1	3	3	0	\N	\N
jRPKHnCVGl	2024-02-16 00:07:37.169+00	2024-02-16 00:07:37.169+00	5nv19u6KJ2	6Fo67rhTSP	1	2	4	0	0	\N	\N
i3nEQ7Glvc	2024-02-16 00:07:37.379+00	2024-02-16 00:07:37.379+00	sy1HD51LXT	JLhF4VuByh	3	0	4	2	4	\N	\N
VRYc5ORgaJ	2024-02-16 00:07:37.594+00	2024-02-16 00:07:37.594+00	9223vtvaBd	Oahm9sOn1y	1	3	3	4	2	\N	\N
QYIp2iaAyF	2024-02-16 00:07:37.808+00	2024-02-16 00:07:37.808+00	RWwLSzreG2	fwLPZZ8YQa	2	2	4	2	2	\N	\N
0mAPkGAXnA	2024-02-16 00:07:38.021+00	2024-02-16 00:07:38.021+00	sHiqaG4iqY	m6g8u0QpTC	1	0	2	2	4	\N	\N
jf4t6KNAQY	2024-02-16 00:07:38.237+00	2024-02-16 00:07:38.237+00	1as6rMOzjQ	eEmewy7hPd	2	0	2	1	4	\N	\N
1BYC4GNErX	2024-02-16 00:07:38.447+00	2024-02-16 00:07:38.447+00	VshUk7eBeK	Pa0qBO2rzK	3	3	0	1	4	\N	\N
xzA0rElmSy	2024-02-16 00:07:38.699+00	2024-02-16 00:07:38.699+00	WKpBp0c8F3	vwHi602n66	3	1	0	2	4	\N	\N
9bFBpQxLhV	2024-02-16 00:07:38.909+00	2024-02-16 00:07:38.909+00	jqDYoPT45X	HLIPwAqO2R	0	1	3	2	0	\N	\N
t387bHCUlv	2024-02-16 00:07:39.123+00	2024-02-16 00:07:39.123+00	Otwj7uJwjr	tCIEnLLcUc	1	4	4	4	1	\N	\N
aqRFWWFuHg	2024-02-16 00:07:39.335+00	2024-02-16 00:07:39.335+00	dZKm0wOhYa	OQWu2bnHeC	0	2	2	3	4	\N	\N
cIL9hQmosn	2024-02-16 00:07:39.618+00	2024-02-16 00:07:39.618+00	dZKm0wOhYa	m6g8u0QpTC	3	4	3	0	1	\N	\N
NyO4nSKsId	2024-02-16 00:07:39.831+00	2024-02-16 00:07:39.831+00	RWwLSzreG2	vwHi602n66	0	4	2	0	0	\N	\N
fBER3Im48A	2024-02-16 00:07:40.131+00	2024-02-16 00:07:40.131+00	VshUk7eBeK	Oahm9sOn1y	0	4	1	2	4	\N	\N
caK45zk7sl	2024-02-16 00:07:40.436+00	2024-02-16 00:07:40.436+00	5X202ssb0D	LVYK4mLShP	2	0	1	3	1	\N	\N
p3DKQZYOnr	2024-02-16 00:07:40.645+00	2024-02-16 00:07:40.645+00	dZKm0wOhYa	D0A6GLdsDM	1	1	3	3	0	\N	\N
Do5AMRC62F	2024-02-16 00:07:40.855+00	2024-02-16 00:07:40.855+00	RWwLSzreG2	HSEugQ3Ouj	3	2	3	4	4	\N	\N
W5ATqKtx4G	2024-02-16 00:07:41.059+00	2024-02-16 00:07:41.059+00	jqDYoPT45X	D0A6GLdsDM	2	4	1	4	3	\N	\N
z9EAWrxSaU	2024-02-16 00:07:41.358+00	2024-02-16 00:07:41.358+00	NjxsGlPeB4	WSTLlXDcKl	2	0	0	3	3	\N	\N
vqo5JV1bhK	2024-02-16 00:07:41.573+00	2024-02-16 00:07:41.573+00	NjxsGlPeB4	UCFo58JaaD	1	4	2	4	0	\N	\N
VnZ5EO7BuJ	2024-02-16 00:07:41.793+00	2024-02-16 00:07:41.793+00	RWwLSzreG2	Oahm9sOn1y	4	0	0	1	2	\N	\N
iAGUmUeMI9	2024-02-16 00:07:42.011+00	2024-02-16 00:07:42.011+00	HtEtaHBVDN	eEmewy7hPd	3	1	1	1	4	\N	\N
PMwNVVCpz3	2024-02-16 00:07:42.224+00	2024-02-16 00:07:42.224+00	HtEtaHBVDN	Gl96vGdYHM	2	3	3	2	4	\N	\N
GsoX0G4Fhb	2024-02-16 00:07:42.429+00	2024-02-16 00:07:42.429+00	Otwj7uJwjr	fKTSJPdUi9	0	2	4	0	4	\N	\N
2sLxmdgJSU	2024-02-16 00:07:42.64+00	2024-02-16 00:07:42.64+00	HtEtaHBVDN	m6g8u0QpTC	1	1	4	1	1	\N	\N
ZggOY6v6eP	2024-02-16 00:07:42.853+00	2024-02-16 00:07:42.853+00	HRhGpJpmb5	TZsdmscJ2B	3	2	0	4	1	\N	\N
0Azfdt1Xtn	2024-02-16 00:07:43.068+00	2024-02-16 00:07:43.068+00	NjxsGlPeB4	bQ0JOk10eL	4	1	0	1	4	\N	\N
EKDPWDgbd3	2024-02-16 00:07:43.285+00	2024-02-16 00:07:43.285+00	dEqAHvPMXA	LVYK4mLShP	2	3	1	1	1	\N	\N
OfeuzjBhiY	2024-02-16 00:07:43.914+00	2024-02-16 00:07:43.914+00	mAKp5BK7R1	KCsJ4XR6Dn	0	4	2	0	2	\N	\N
66xBI5ObqE	2024-02-16 00:07:44.225+00	2024-02-16 00:07:44.225+00	Otwj7uJwjr	WSTLlXDcKl	1	0	3	0	0	\N	\N
N1WDf6ryrV	2024-02-16 00:07:44.436+00	2024-02-16 00:07:44.436+00	iWxl9obi8w	MQfxuw3ERg	0	4	2	4	4	\N	\N
tQez2MgUY1	2024-02-16 00:07:44.736+00	2024-02-16 00:07:44.736+00	S6wz0lK0bf	RkhjIQJgou	3	4	0	4	0	\N	\N
42n1V0uGc9	2024-02-16 00:07:44.95+00	2024-02-16 00:07:44.95+00	HRhGpJpmb5	08liHW08uC	3	0	4	0	0	\N	\N
Qmy2YEnclb	2024-02-16 00:07:45.163+00	2024-02-16 00:07:45.163+00	RWwLSzreG2	jjVdtithcD	3	0	4	4	4	\N	\N
lG23c80F2F	2024-02-16 00:07:45.376+00	2024-02-16 00:07:45.376+00	S6wz0lK0bf	IEqTHcohpJ	4	0	4	0	4	\N	\N
MCmCOGMbEi	2024-02-16 00:07:45.589+00	2024-02-16 00:07:45.589+00	opW2wQ2bZ8	VK3vnSxIy8	4	4	1	1	2	\N	\N
u9BU3UR30x	2024-02-16 00:07:45.801+00	2024-02-16 00:07:45.801+00	WKpBp0c8F3	EmIUBFwx0Z	1	0	0	2	2	\N	\N
DFPdwTR76u	2024-02-16 00:07:46.016+00	2024-02-16 00:07:46.016+00	dEqAHvPMXA	WBFeKac0OO	1	4	0	1	1	\N	\N
3zaPos4goi	2024-02-16 00:07:46.231+00	2024-02-16 00:07:46.231+00	R2CLtFh5jU	j0dWqP2C2A	3	3	4	3	1	\N	\N
A4d0r6KhQQ	2024-02-16 00:07:46.448+00	2024-02-16 00:07:46.448+00	5X202ssb0D	Oahm9sOn1y	0	3	4	0	2	\N	\N
bV7wBqRe6d	2024-02-16 00:07:46.662+00	2024-02-16 00:07:46.662+00	HtEtaHBVDN	JZOBDAh12a	0	4	3	1	2	\N	\N
FffDukZAEa	2024-02-16 00:07:46.993+00	2024-02-16 00:07:46.993+00	sy1HD51LXT	RkhjIQJgou	0	1	2	4	1	\N	\N
Ey4C2bIypR	2024-02-16 00:07:47.204+00	2024-02-16 00:07:47.204+00	I5RzFRcQ7G	cmxBcanww9	0	1	1	4	3	\N	\N
MfX6CKYeNW	2024-02-16 00:07:47.418+00	2024-02-16 00:07:47.418+00	WKpBp0c8F3	qEQ9tmLyW9	1	0	2	2	4	\N	\N
qRJJQMmFBN	2024-02-16 00:07:48.015+00	2024-02-16 00:07:48.015+00	1as6rMOzjQ	RBRcyltRSC	4	3	0	1	4	\N	\N
iO21055pKP	2024-02-16 00:07:48.229+00	2024-02-16 00:07:48.229+00	dEqAHvPMXA	CSvk1ycWXk	1	1	4	1	3	\N	\N
kvocYMJ0cL	2024-02-16 00:07:48.441+00	2024-02-16 00:07:48.441+00	HRhGpJpmb5	JZOBDAh12a	0	0	4	0	0	\N	\N
iB4fNaSgLf	2024-02-16 00:07:48.658+00	2024-02-16 00:07:48.658+00	dEqAHvPMXA	Pa0qBO2rzK	4	0	3	1	1	\N	\N
ZQPkhjWExy	2024-02-16 00:07:48.876+00	2024-02-16 00:07:48.876+00	adE9nQrDk3	H40ivltLwZ	4	3	4	2	0	\N	\N
vbefOgVsET	2024-02-16 00:07:49.142+00	2024-02-16 00:07:49.142+00	mAKp5BK7R1	P9sBFomftT	2	4	4	2	4	\N	\N
OCScbXa6RM	2024-02-16 00:07:49.354+00	2024-02-16 00:07:49.354+00	dZKm0wOhYa	TZsdmscJ2B	4	1	2	2	1	\N	\N
kY9XvRXbGk	2024-02-16 00:07:49.568+00	2024-02-16 00:07:49.568+00	RWwLSzreG2	cmxBcanww9	1	1	2	4	4	\N	\N
CoeZ8RKAsk	2024-02-16 00:07:49.78+00	2024-02-16 00:07:49.78+00	R2CLtFh5jU	OQWu2bnHeC	2	4	1	3	2	\N	\N
UuZfj8R4yR	2024-02-16 00:07:49.994+00	2024-02-16 00:07:49.994+00	ONgyydfVNz	UDXF0qXvDY	0	0	0	3	3	\N	\N
LEa1TVVGTZ	2024-02-16 00:07:50.209+00	2024-02-16 00:07:50.209+00	adE9nQrDk3	mMYg4cyd5R	1	3	4	1	1	\N	\N
5F9GgSrmhp	2024-02-16 00:07:50.476+00	2024-02-16 00:07:50.476+00	I5RzFRcQ7G	cFtamPA0zH	2	0	1	1	3	\N	\N
WefZFTvPZy	2024-02-16 00:07:51.08+00	2024-02-16 00:07:51.08+00	sHiqaG4iqY	uABtFsJhJc	1	1	1	1	2	\N	\N
wWvbKDC9ou	2024-02-16 00:07:51.295+00	2024-02-16 00:07:51.295+00	dEqAHvPMXA	jHqCpA1nWb	4	2	4	0	3	\N	\N
NNnSu8aAg6	2024-02-16 00:07:51.51+00	2024-02-16 00:07:51.51+00	5X202ssb0D	qEQ9tmLyW9	1	4	0	4	2	\N	\N
PFcIxuu0gr	2024-02-16 00:07:51.722+00	2024-02-16 00:07:51.722+00	5X202ssb0D	bQ0JOk10eL	1	2	1	1	2	\N	\N
KwsQ6g6jGa	2024-02-16 00:07:51.936+00	2024-02-16 00:07:51.936+00	jqDYoPT45X	IybX0eBoO3	4	2	3	0	0	\N	\N
kCJALDtYrj	2024-02-16 00:07:52.151+00	2024-02-16 00:07:52.151+00	HtEtaHBVDN	Oahm9sOn1y	3	4	0	4	2	\N	\N
kldMxH91XI	2024-02-16 00:07:52.369+00	2024-02-16 00:07:52.369+00	dEqAHvPMXA	XwszrNEEEj	2	3	4	4	0	\N	\N
tdVyetVbKM	2024-02-16 00:07:52.589+00	2024-02-16 00:07:52.589+00	AsrLUQwxI9	UDXF0qXvDY	0	0	1	4	1	\N	\N
vbVWT3SLGt	2024-02-16 00:07:52.806+00	2024-02-16 00:07:52.806+00	5X202ssb0D	NBojpORh3G	3	2	1	4	3	\N	\N
ZxiuLGE2an	2024-02-16 00:07:53.018+00	2024-02-16 00:07:53.018+00	iUlyHNFGpG	HXtEwLBC7f	0	2	0	0	0	\N	\N
7tR1chZXZN	2024-02-16 00:07:53.231+00	2024-02-16 00:07:53.231+00	5nv19u6KJ2	D0A6GLdsDM	1	3	0	3	0	\N	\N
GliPj1nqr8	2024-02-16 00:07:53.442+00	2024-02-16 00:07:53.442+00	1as6rMOzjQ	m8hjjLVdPS	4	0	0	1	2	\N	\N
pIoWvRWRJk	2024-02-16 00:07:53.658+00	2024-02-16 00:07:53.658+00	NjxsGlPeB4	UDXF0qXvDY	4	4	4	4	4	\N	\N
D7S5R4CRQm	2024-02-16 00:07:53.873+00	2024-02-16 00:07:53.873+00	iWxl9obi8w	Pja6n3yaWZ	4	3	1	1	2	\N	\N
4YROsDJA8v	2024-02-16 00:07:54.09+00	2024-02-16 00:07:54.09+00	9223vtvaBd	TZsdmscJ2B	0	1	2	0	1	\N	\N
qA1PSe3eQL	2024-02-16 00:07:54.305+00	2024-02-16 00:07:54.305+00	ONgyydfVNz	tCIEnLLcUc	2	0	2	3	4	\N	\N
yvLfqIsUDw	2024-02-16 00:07:54.569+00	2024-02-16 00:07:54.569+00	mQXQWNqxg9	3P6kmNoY1F	1	1	0	0	2	\N	\N
Grmig2zT90	2024-02-16 00:07:54.878+00	2024-02-16 00:07:54.878+00	mQXQWNqxg9	XwWwGnkXNj	3	3	4	4	3	\N	\N
Ee2IuG64r4	2024-02-16 00:07:55.182+00	2024-02-16 00:07:55.182+00	9223vtvaBd	u5FXeeOChJ	2	1	3	0	0	\N	\N
WrfbPkQObn	2024-02-16 00:07:55.489+00	2024-02-16 00:07:55.489+00	sy1HD51LXT	fxvABtKCPT	1	4	4	2	4	\N	\N
sjgvRPJ64H	2024-02-16 00:07:55.796+00	2024-02-16 00:07:55.796+00	dZKm0wOhYa	WnUBBkiDjE	1	0	0	1	3	\N	\N
G000u5lT1J	2024-02-16 00:07:56.096+00	2024-02-16 00:07:56.096+00	S6wz0lK0bf	BMLzFMvIT6	4	3	3	3	0	\N	\N
G2b7MshUjd	2024-02-16 00:07:56.413+00	2024-02-16 00:07:56.413+00	jqDYoPT45X	vwHi602n66	4	3	2	3	4	\N	\N
q7JnWHBLoR	2024-02-16 00:07:56.719+00	2024-02-16 00:07:56.719+00	WKpBp0c8F3	AgU9OLJkqz	3	0	3	2	1	\N	\N
cAD72thCTE	2024-02-16 00:07:56.928+00	2024-02-16 00:07:56.928+00	adE9nQrDk3	0TvWuLoLF5	3	1	2	4	0	\N	\N
mf5etfxjWg	2024-02-16 00:07:57.229+00	2024-02-16 00:07:57.229+00	iWxl9obi8w	XwWwGnkXNj	2	4	3	3	1	\N	\N
QqUn3Rk6JK	2024-02-16 00:07:57.536+00	2024-02-16 00:07:57.536+00	NjxsGlPeB4	AgU9OLJkqz	2	0	2	2	4	\N	\N
NSjDLjEk5e	2024-02-16 00:07:57.747+00	2024-02-16 00:07:57.747+00	NjxsGlPeB4	KCsJ4XR6Dn	1	4	3	0	4	\N	\N
3is6AooBGd	2024-02-16 00:07:58.051+00	2024-02-16 00:07:58.051+00	ONgyydfVNz	WBFeKac0OO	1	2	3	4	1	\N	\N
ipwF5lwgkO	2024-02-16 00:07:58.358+00	2024-02-16 00:07:58.358+00	opW2wQ2bZ8	HXtEwLBC7f	3	1	0	4	2	\N	\N
izFKgCApk2	2024-02-16 00:07:58.57+00	2024-02-16 00:07:58.57+00	I5RzFRcQ7G	3u4B9V4l5K	1	1	2	4	0	\N	\N
YOuPA1LFoe	2024-02-16 00:07:58.785+00	2024-02-16 00:07:58.785+00	opW2wQ2bZ8	cTIjuPjyIa	4	0	3	3	1	\N	\N
sqxCgySeDQ	2024-02-16 00:07:59+00	2024-02-16 00:07:59+00	mQXQWNqxg9	KCsJ4XR6Dn	0	0	1	0	2	\N	\N
LvZBYtg6AF	2024-02-16 00:07:59.213+00	2024-02-16 00:07:59.213+00	I5RzFRcQ7G	M0tHrt1GgV	2	0	2	3	1	\N	\N
3dDXXnPmIu	2024-02-16 00:07:59.425+00	2024-02-16 00:07:59.425+00	jqDYoPT45X	INeptnSdJC	1	0	2	4	2	\N	\N
qDXCQOIegM	2024-02-16 00:07:59.638+00	2024-02-16 00:07:59.638+00	sy1HD51LXT	D0A6GLdsDM	2	3	1	0	2	\N	\N
TrViuriwdR	2024-02-16 00:07:59.854+00	2024-02-16 00:07:59.854+00	sHiqaG4iqY	M0tHrt1GgV	0	0	4	4	0	\N	\N
nUmNa94kHa	2024-02-16 00:08:00.098+00	2024-02-16 00:08:00.098+00	opW2wQ2bZ8	JLhF4VuByh	4	4	0	3	4	\N	\N
UWiI2SoHdN	2024-02-16 00:08:00.406+00	2024-02-16 00:08:00.406+00	RWwLSzreG2	j0dWqP2C2A	3	3	1	1	4	\N	\N
QPktEL6CZb	2024-02-16 00:08:00.619+00	2024-02-16 00:08:00.619+00	SFAISec8QF	XpUyRlB6FI	1	4	3	2	1	\N	\N
fUQvxty6xj	2024-02-16 00:08:00.831+00	2024-02-16 00:08:00.831+00	dZKm0wOhYa	E2hBZzDsjO	4	3	0	3	4	\N	\N
T8GDsoDkVP	2024-02-16 00:08:01.044+00	2024-02-16 00:08:01.044+00	jqDYoPT45X	qP3EdIVzfB	2	3	3	0	2	\N	\N
RLyKVAZ105	2024-02-16 00:08:01.327+00	2024-02-16 00:08:01.327+00	VshUk7eBeK	WHvlAGgj6c	3	0	0	2	1	\N	\N
WfltXVDOsQ	2024-02-16 00:08:01.54+00	2024-02-16 00:08:01.54+00	iWxl9obi8w	fKTSJPdUi9	0	1	3	1	2	\N	\N
WYgl8KQirx	2024-02-16 00:08:01.753+00	2024-02-16 00:08:01.753+00	5nv19u6KJ2	axyV0Fu7pm	4	1	0	3	2	\N	\N
fOAB8sVcwR	2024-02-16 00:08:01.968+00	2024-02-16 00:08:01.968+00	opW2wQ2bZ8	eEmewy7hPd	4	3	0	0	4	\N	\N
z4AKGznwlE	2024-02-16 00:08:02.183+00	2024-02-16 00:08:02.183+00	Otwj7uJwjr	uABtFsJhJc	2	2	3	0	0	\N	\N
LlT9B30tLE	2024-02-16 00:08:02.397+00	2024-02-16 00:08:02.397+00	1as6rMOzjQ	cmxBcanww9	2	4	0	0	4	\N	\N
KERVpaU49j	2024-02-16 00:08:02.659+00	2024-02-16 00:08:02.659+00	HRhGpJpmb5	LDrIH1vU8x	4	2	3	4	2	\N	\N
vERsg7zHEu	2024-02-16 00:08:02.964+00	2024-02-16 00:08:02.964+00	opW2wQ2bZ8	3u4B9V4l5K	0	3	3	2	0	\N	\N
yBtlFh3oW0	2024-02-16 00:08:03.176+00	2024-02-16 00:08:03.176+00	5nv19u6KJ2	8w7i8C3NnT	2	4	3	4	1	\N	\N
yJqiVLqSIf	2024-02-16 00:08:03.388+00	2024-02-16 00:08:03.388+00	VshUk7eBeK	MQfxuw3ERg	3	1	1	4	2	\N	\N
fxKLwP6CRS	2024-02-16 00:08:03.6+00	2024-02-16 00:08:03.6+00	9223vtvaBd	LVYK4mLShP	3	3	1	2	2	\N	\N
RFmoDmjGUJ	2024-02-16 00:08:03.888+00	2024-02-16 00:08:03.888+00	R2CLtFh5jU	Oahm9sOn1y	1	4	4	1	1	\N	\N
TLTwJnJa2f	2024-02-16 00:08:04.102+00	2024-02-16 00:08:04.102+00	Otwj7uJwjr	FJOTueDfs2	2	3	1	4	0	\N	\N
wfj8Hx35sz	2024-02-16 00:08:04.315+00	2024-02-16 00:08:04.315+00	sHiqaG4iqY	C7II8dYRPY	2	4	3	2	4	\N	\N
qgr3FdtlTF	2024-02-16 00:08:04.604+00	2024-02-16 00:08:04.604+00	iUlyHNFGpG	JLhF4VuByh	3	3	2	3	2	\N	\N
5jrKd9o0h8	2024-02-16 00:08:05.216+00	2024-02-16 00:08:05.216+00	sy1HD51LXT	NY6RE1qgWu	1	3	3	4	4	\N	\N
eq7G20k521	2024-02-16 00:08:05.425+00	2024-02-16 00:08:05.425+00	mQXQWNqxg9	jjVdtithcD	2	2	1	2	0	\N	\N
6VFp31Maci	2024-02-16 00:08:05.636+00	2024-02-16 00:08:05.636+00	sHiqaG4iqY	HXtEwLBC7f	0	2	1	0	1	\N	\N
GLPivFfbnM	2024-02-16 00:08:05.844+00	2024-02-16 00:08:05.844+00	jqDYoPT45X	NY6RE1qgWu	0	0	1	2	4	\N	\N
jRUD1qNfKr	2024-02-16 00:08:06.133+00	2024-02-16 00:08:06.133+00	WKpBp0c8F3	ThMuD3hYRQ	2	0	2	3	1	\N	\N
RS6CADW05X	2024-02-16 00:08:06.341+00	2024-02-16 00:08:06.341+00	I5RzFRcQ7G	IEqTHcohpJ	1	4	1	3	2	\N	\N
4K3iuIjGDp	2024-02-16 00:08:06.554+00	2024-02-16 00:08:06.554+00	iWxl9obi8w	NBojpORh3G	3	1	1	3	3	\N	\N
Dw2kRkGOE0	2024-02-16 00:08:06.766+00	2024-02-16 00:08:06.766+00	VshUk7eBeK	UCFo58JaaD	3	4	1	1	0	\N	\N
mhwHcam0cz	2024-02-16 00:08:06.979+00	2024-02-16 00:08:06.979+00	sy1HD51LXT	H40ivltLwZ	0	0	2	1	1	\N	\N
BEpJSpnw2O	2024-02-16 00:08:07.206+00	2024-02-16 00:08:07.206+00	dEqAHvPMXA	INeptnSdJC	0	3	2	4	4	\N	\N
BTrDrnlWgZ	2024-02-16 00:08:07.418+00	2024-02-16 00:08:07.418+00	jqDYoPT45X	bi1IivsuUB	2	3	0	0	4	\N	\N
3d3QCqw8p4	2024-02-16 00:08:07.621+00	2024-02-16 00:08:07.621+00	I5RzFRcQ7G	o4VD4BWwDt	2	2	1	3	4	\N	\N
0XOgsZbRjh	2024-02-16 00:08:07.83+00	2024-02-16 00:08:07.83+00	sHiqaG4iqY	6KvFK8yy1q	4	1	0	3	1	\N	\N
a3kN77Bqu8	2024-02-16 00:08:08.087+00	2024-02-16 00:08:08.087+00	9223vtvaBd	LDrIH1vU8x	3	2	2	3	3	\N	\N
p4tbVz7ZHs	2024-02-16 00:08:08.3+00	2024-02-16 00:08:08.3+00	NjxsGlPeB4	FJOTueDfs2	0	0	4	1	3	\N	\N
5WG0oKo5bA	2024-02-16 00:08:08.904+00	2024-02-16 00:08:08.904+00	dZKm0wOhYa	fwLPZZ8YQa	1	1	2	1	1	\N	\N
RQeVsBVXuA	2024-02-16 00:08:09.118+00	2024-02-16 00:08:09.118+00	I5RzFRcQ7G	Gl96vGdYHM	2	1	4	4	4	\N	\N
ZAF547nnLc	2024-02-16 00:08:09.416+00	2024-02-16 00:08:09.416+00	jqDYoPT45X	mMYg4cyd5R	3	3	4	3	4	\N	\N
ZtvDTfkbPo	2024-02-16 00:08:09.628+00	2024-02-16 00:08:09.628+00	mQXQWNqxg9	FJOTueDfs2	4	3	2	2	0	\N	\N
phYi8JykQk	2024-02-16 00:08:09.838+00	2024-02-16 00:08:09.838+00	VshUk7eBeK	HXtEwLBC7f	4	0	2	0	3	\N	\N
gVHWXupRFj	2024-02-16 00:08:10.133+00	2024-02-16 00:08:10.133+00	Otwj7uJwjr	lxQA9rtSfY	0	0	3	1	1	\N	\N
8jL4pcCYyg	2024-02-16 00:08:10.586+00	2024-02-16 00:08:10.586+00	ONgyydfVNz	HLIPwAqO2R	4	1	3	0	2	\N	\N
mRmGTbuMey	2024-02-16 00:08:10.795+00	2024-02-16 00:08:10.795+00	9223vtvaBd	Oahm9sOn1y	4	0	0	1	0	\N	\N
bSbTPcz4My	2024-02-16 00:08:11.027+00	2024-02-16 00:08:11.027+00	sHiqaG4iqY	UCFo58JaaD	3	0	3	1	0	\N	\N
IswIfK7xjx	2024-02-16 00:08:11.238+00	2024-02-16 00:08:11.238+00	mQXQWNqxg9	qZmnAnnPEb	1	1	0	3	3	\N	\N
SW9iaw2hFU	2024-02-16 00:08:11.872+00	2024-02-16 00:08:11.872+00	WKpBp0c8F3	H40ivltLwZ	4	3	2	3	4	\N	\N
CNVycqHvb8	2024-02-16 00:08:12.085+00	2024-02-16 00:08:12.085+00	iUlyHNFGpG	cFtamPA0zH	1	3	0	1	0	\N	\N
bolPwN7l6w	2024-02-16 00:08:12.384+00	2024-02-16 00:08:12.384+00	NjxsGlPeB4	Pja6n3yaWZ	0	1	3	3	2	\N	\N
6HbSkXJQiw	2024-02-16 00:08:12.596+00	2024-02-16 00:08:12.596+00	sHiqaG4iqY	cFtamPA0zH	1	3	0	4	3	\N	\N
FseLWLo8uE	2024-02-16 00:08:12.807+00	2024-02-16 00:08:12.807+00	1as6rMOzjQ	lEPdiO1EDi	1	4	1	0	2	\N	\N
90jdQdSex5	2024-02-16 00:08:13.011+00	2024-02-16 00:08:13.011+00	jqDYoPT45X	tCIEnLLcUc	1	0	2	4	0	\N	\N
NfwNlgEWue	2024-02-16 00:08:13.218+00	2024-02-16 00:08:13.218+00	1as6rMOzjQ	XwszrNEEEj	2	2	1	0	4	\N	\N
epZMd8B67I	2024-02-16 00:08:13.428+00	2024-02-16 00:08:13.428+00	I5RzFRcQ7G	PF8w2gMAdi	1	0	4	2	3	\N	\N
wUvATyiKI1	2024-02-16 00:08:13.718+00	2024-02-16 00:08:13.718+00	NjxsGlPeB4	IybX0eBoO3	1	4	0	0	1	\N	\N
oCC47EnxJf	2024-02-16 00:08:13.934+00	2024-02-16 00:08:13.934+00	SFAISec8QF	89xRG1afNi	3	0	0	2	3	\N	\N
gWdpCqnO67	2024-02-16 00:08:14.227+00	2024-02-16 00:08:14.227+00	I5RzFRcQ7G	o90lhsZ7FK	2	1	0	4	3	\N	\N
kus1kzOnxl	2024-02-16 00:08:14.439+00	2024-02-16 00:08:14.439+00	WKpBp0c8F3	lEPdiO1EDi	1	3	0	2	1	\N	\N
PuRQhqBO9h	2024-02-16 00:08:14.741+00	2024-02-16 00:08:14.741+00	iWxl9obi8w	UDXF0qXvDY	3	4	0	1	4	\N	\N
Xm1MEQkkVT	2024-02-16 00:08:15.048+00	2024-02-16 00:08:15.048+00	iUlyHNFGpG	rKyjwoEIRp	3	1	2	2	4	\N	\N
TkEgo9tNYv	2024-02-16 00:08:15.261+00	2024-02-16 00:08:15.261+00	iUlyHNFGpG	l1Bslv8T2k	1	4	0	4	3	\N	\N
wiuDhNCFE6	2024-02-16 00:08:15.474+00	2024-02-16 00:08:15.474+00	VshUk7eBeK	HLIPwAqO2R	2	3	3	0	3	\N	\N
bmVrrawBca	2024-02-16 00:08:15.687+00	2024-02-16 00:08:15.687+00	sHiqaG4iqY	OQWu2bnHeC	2	2	1	4	2	\N	\N
CjQGJJ8RLW	2024-02-16 00:08:15.9+00	2024-02-16 00:08:15.9+00	5X202ssb0D	KCsJ4XR6Dn	0	2	0	1	4	\N	\N
l6maRzUwvg	2024-02-16 00:08:16.17+00	2024-02-16 00:08:16.17+00	HtEtaHBVDN	89xRG1afNi	0	2	0	2	4	\N	\N
UgCkqUbcAb	2024-02-16 00:08:16.481+00	2024-02-16 00:08:16.481+00	1as6rMOzjQ	WSTLlXDcKl	2	4	4	1	0	\N	\N
B5s6AMnm92	2024-02-16 00:08:16.696+00	2024-02-16 00:08:16.696+00	Otwj7uJwjr	mMYg4cyd5R	4	2	4	2	2	\N	\N
FJOYcYrnzr	2024-02-16 00:08:16.907+00	2024-02-16 00:08:16.907+00	iUlyHNFGpG	WBFeKac0OO	3	2	3	1	1	\N	\N
0yDaQNChyr	2024-02-16 00:08:17.197+00	2024-02-16 00:08:17.197+00	opW2wQ2bZ8	cTIjuPjyIa	1	2	3	3	4	\N	\N
Ktt4R26vw1	2024-02-16 00:08:17.504+00	2024-02-16 00:08:17.504+00	VshUk7eBeK	INeptnSdJC	0	3	0	4	1	\N	\N
f2w6SevS2F	2024-02-16 00:08:17.812+00	2024-02-16 00:08:17.812+00	HRhGpJpmb5	9GF3y7LmHV	2	4	0	1	4	\N	\N
CgmiwHhtkQ	2024-02-16 00:08:18.425+00	2024-02-16 00:08:18.425+00	9223vtvaBd	HXtEwLBC7f	2	4	1	4	3	\N	\N
9lrOy0C7nD	2024-02-16 00:08:18.732+00	2024-02-16 00:08:18.732+00	dZKm0wOhYa	BMLzFMvIT6	2	2	0	3	1	\N	\N
n8ZYWeQwH5	2024-02-16 00:08:19.039+00	2024-02-16 00:08:19.039+00	sHiqaG4iqY	HLIPwAqO2R	1	1	2	4	2	\N	\N
l8cTc45g95	2024-02-16 00:08:19.344+00	2024-02-16 00:08:19.344+00	VshUk7eBeK	OQWu2bnHeC	4	3	4	4	1	\N	\N
dnzkXcPGHY	2024-02-16 00:08:19.96+00	2024-02-16 00:08:19.96+00	RWwLSzreG2	jHqCpA1nWb	4	3	3	3	2	\N	\N
EZp8PaoTbK	2024-02-16 00:08:20.169+00	2024-02-16 00:08:20.169+00	Otwj7uJwjr	XwszrNEEEj	3	4	0	2	3	\N	\N
WSUFwDOWoG	2024-02-16 00:08:20.473+00	2024-02-16 00:08:20.473+00	5X202ssb0D	HSEugQ3Ouj	2	0	1	2	0	\N	\N
m8vybptzSQ	2024-02-16 00:08:20.686+00	2024-02-16 00:08:20.686+00	VshUk7eBeK	cFtamPA0zH	1	3	1	3	1	\N	\N
0ieUnCwSCb	2024-02-16 00:08:20.894+00	2024-02-16 00:08:20.894+00	WKpBp0c8F3	mMYg4cyd5R	4	4	1	1	3	\N	\N
RtFwZB4lS8	2024-02-16 00:08:21.095+00	2024-02-16 00:08:21.095+00	ONgyydfVNz	D0A6GLdsDM	4	3	4	3	0	\N	\N
DsjsaOCATG	2024-02-16 00:08:21.395+00	2024-02-16 00:08:21.395+00	sy1HD51LXT	XpUyRlB6FI	4	1	2	4	3	\N	\N
6CkntPGyHI	2024-02-16 00:08:22.008+00	2024-02-16 00:08:22.008+00	1as6rMOzjQ	oABNR2FF6S	4	3	4	3	1	\N	\N
3n9h3ZmKAr	2024-02-16 00:08:22.316+00	2024-02-16 00:08:22.316+00	HtEtaHBVDN	BMLzFMvIT6	2	4	2	4	0	\N	\N
7RCTnOZmX4	2024-02-16 00:08:23.032+00	2024-02-16 00:08:23.032+00	HtEtaHBVDN	mMYg4cyd5R	1	3	3	0	0	\N	\N
DHy8hW0pxa	2024-02-16 00:08:23.339+00	2024-02-16 00:08:23.339+00	NjxsGlPeB4	yvUod6yLDt	4	4	3	4	4	\N	\N
wsGMBhIr4l	2024-02-16 00:08:23.549+00	2024-02-16 00:08:23.549+00	adE9nQrDk3	rKyjwoEIRp	2	1	2	3	2	\N	\N
wwnOH6Zz4e	2024-02-16 00:08:23.759+00	2024-02-16 00:08:23.759+00	sy1HD51LXT	Pja6n3yaWZ	3	4	4	0	3	\N	\N
YlddnCnvgD	2024-02-16 00:08:23.971+00	2024-02-16 00:08:23.971+00	HtEtaHBVDN	AgU9OLJkqz	3	0	0	1	0	\N	\N
aGMS0qyJuB	2024-02-16 00:08:24.185+00	2024-02-16 00:08:24.185+00	5X202ssb0D	cwVEh0dqfm	0	4	2	0	0	\N	\N
uNtPx0Y14i	2024-02-16 00:08:24.4+00	2024-02-16 00:08:24.4+00	WKpBp0c8F3	9GF3y7LmHV	4	3	4	0	3	\N	\N
9RAJGoXpAT	2024-02-16 00:08:24.979+00	2024-02-16 00:08:24.979+00	iWxl9obi8w	WSTLlXDcKl	0	1	4	2	3	\N	\N
RZKxhFoYu9	2024-02-16 00:08:25.285+00	2024-02-16 00:08:25.285+00	adE9nQrDk3	o4VD4BWwDt	0	2	3	3	4	\N	\N
uQ2n54YjBZ	2024-02-16 00:08:25.495+00	2024-02-16 00:08:25.495+00	NjxsGlPeB4	KCsJ4XR6Dn	3	2	0	3	0	\N	\N
f9QDK2xtNb	2024-02-16 00:08:25.705+00	2024-02-16 00:08:25.705+00	NjxsGlPeB4	NBojpORh3G	1	3	3	0	4	\N	\N
oHp8TyLrCF	2024-02-16 00:08:25.916+00	2024-02-16 00:08:25.916+00	sHiqaG4iqY	FJOTueDfs2	2	4	1	4	2	\N	\N
yy4pu4rtoK	2024-02-16 00:08:26.511+00	2024-02-16 00:08:26.511+00	iWxl9obi8w	ThMuD3hYRQ	1	1	1	1	0	\N	\N
Y7zr5SSFfF	2024-02-16 00:08:26.718+00	2024-02-16 00:08:26.718+00	sHiqaG4iqY	LDrIH1vU8x	1	1	3	4	3	\N	\N
BGiQYnwpsw	2024-02-16 00:08:26.928+00	2024-02-16 00:08:26.928+00	9223vtvaBd	eEmewy7hPd	4	3	1	0	0	\N	\N
zMk1Ydg6Ip	2024-02-16 00:08:27.14+00	2024-02-16 00:08:27.14+00	WKpBp0c8F3	OQWu2bnHeC	3	4	4	1	2	\N	\N
Tm8VGqdGss	2024-02-16 00:08:27.436+00	2024-02-16 00:08:27.436+00	adE9nQrDk3	fKTSJPdUi9	1	1	1	4	4	\N	\N
l6RDabAA8C	2024-02-16 00:08:27.744+00	2024-02-16 00:08:27.744+00	sHiqaG4iqY	FYXEfIO1zF	3	3	1	1	1	\N	\N
UDVxXZnjvR	2024-02-16 00:08:28.052+00	2024-02-16 00:08:28.052+00	dEqAHvPMXA	JLhF4VuByh	2	2	1	0	3	\N	\N
QvqhGMyLJn	2024-02-16 00:08:28.263+00	2024-02-16 00:08:28.263+00	5X202ssb0D	FJOTueDfs2	2	1	4	4	2	\N	\N
QIvYK4g3T1	2024-02-16 00:08:28.473+00	2024-02-16 00:08:28.473+00	AsrLUQwxI9	j0dWqP2C2A	4	0	3	4	3	\N	\N
e28lXAXhtT	2024-02-16 00:08:28.684+00	2024-02-16 00:08:28.684+00	HtEtaHBVDN	y4RkaDbkec	3	0	3	4	1	\N	\N
ClIsehChZN	2024-02-16 00:08:28.896+00	2024-02-16 00:08:28.896+00	1as6rMOzjQ	3P6kmNoY1F	4	1	0	2	0	\N	\N
BXuE4MR8ob	2024-02-16 00:08:29.111+00	2024-02-16 00:08:29.111+00	adE9nQrDk3	RBRcyltRSC	0	4	2	4	4	\N	\N
KIAIyWRejw	2024-02-16 00:08:29.325+00	2024-02-16 00:08:29.325+00	R2CLtFh5jU	bi1IivsuUB	3	2	1	4	2	\N	\N
qgkCgT5wGA	2024-02-16 00:08:29.59+00	2024-02-16 00:08:29.59+00	5X202ssb0D	FJOTueDfs2	3	2	0	1	2	\N	\N
Jv1kUkGuuT	2024-02-16 00:08:29.803+00	2024-02-16 00:08:29.803+00	HtEtaHBVDN	LDrIH1vU8x	1	3	2	2	4	\N	\N
8xBHOWFbmX	2024-02-16 00:08:30.404+00	2024-02-16 00:08:30.404+00	Otwj7uJwjr	TCkiw6gTDz	2	2	1	4	1	\N	\N
4lEo1ZrnEE	2024-02-16 00:08:30.612+00	2024-02-16 00:08:30.612+00	HtEtaHBVDN	ThMuD3hYRQ	2	0	4	2	3	\N	\N
h1kgTBb9yf	2024-02-16 00:08:30.821+00	2024-02-16 00:08:30.821+00	jqDYoPT45X	uABtFsJhJc	0	0	2	0	0	\N	\N
g0jJHwstXo	2024-02-16 00:08:31.032+00	2024-02-16 00:08:31.032+00	iUlyHNFGpG	m6g8u0QpTC	4	3	3	2	0	\N	\N
YUL1cu7SkA	2024-02-16 00:08:31.245+00	2024-02-16 00:08:31.245+00	opW2wQ2bZ8	jjVdtithcD	3	4	0	1	1	\N	\N
Oll7zeUFPw	2024-02-16 00:08:31.458+00	2024-02-16 00:08:31.458+00	S6wz0lK0bf	JZOBDAh12a	0	2	1	2	0	\N	\N
jdxYm6t0bG	2024-02-16 00:08:32.046+00	2024-02-16 00:08:32.046+00	S6wz0lK0bf	C7II8dYRPY	3	1	1	3	3	\N	\N
Wa8OjSzBUn	2024-02-16 00:08:32.658+00	2024-02-16 00:08:32.658+00	9223vtvaBd	HLIPwAqO2R	0	2	0	2	3	\N	\N
zWiIUn4xLV	2024-02-16 00:08:32.964+00	2024-02-16 00:08:32.964+00	Otwj7uJwjr	TZsdmscJ2B	0	3	3	2	3	\N	\N
9Hb42Tc5qG	2024-02-16 00:08:33.58+00	2024-02-16 00:08:33.58+00	5X202ssb0D	AgU9OLJkqz	4	1	3	0	2	\N	\N
bAQMHC8g8v	2024-02-16 00:08:34.193+00	2024-02-16 00:08:34.193+00	I5RzFRcQ7G	RBRcyltRSC	0	4	4	4	3	\N	\N
xbRRxi2Rbj	2024-02-16 00:08:34.403+00	2024-02-16 00:08:34.403+00	dEqAHvPMXA	JRi61dUphq	4	0	0	3	3	\N	\N
WVCtyjeKYC	2024-02-16 00:08:34.61+00	2024-02-16 00:08:34.61+00	5nv19u6KJ2	WBFeKac0OO	2	3	3	4	1	\N	\N
hCjb1AZyBL	2024-02-16 00:08:34.821+00	2024-02-16 00:08:34.821+00	dZKm0wOhYa	TCkiw6gTDz	3	4	3	3	1	\N	\N
Y3mNy7q7Q5	2024-02-16 00:08:35.03+00	2024-02-16 00:08:35.03+00	iUlyHNFGpG	oABNR2FF6S	1	4	3	1	3	\N	\N
CEdDlPsFxD	2024-02-16 00:08:35.239+00	2024-02-16 00:08:35.239+00	I5RzFRcQ7G	OQWu2bnHeC	2	3	0	4	0	\N	\N
6IlxXF5N7T	2024-02-16 00:08:35.831+00	2024-02-16 00:08:35.831+00	Otwj7uJwjr	fxvABtKCPT	2	0	1	4	0	\N	\N
GEB1OWVESv	2024-02-16 00:08:36.038+00	2024-02-16 00:08:36.038+00	ONgyydfVNz	cmxBcanww9	2	2	0	0	0	\N	\N
UeSIiAfgjy	2024-02-16 00:08:36.247+00	2024-02-16 00:08:36.247+00	R2CLtFh5jU	NBojpORh3G	3	0	3	1	2	\N	\N
dTGYigw9E5	2024-02-16 00:08:36.55+00	2024-02-16 00:08:36.55+00	HtEtaHBVDN	tCIEnLLcUc	3	0	3	4	4	\N	\N
LLs9htopR5	2024-02-16 00:08:36.762+00	2024-02-16 00:08:36.762+00	AsrLUQwxI9	na5crB8ED1	3	0	3	1	2	\N	\N
VUvECyC6vI	2024-02-16 00:08:36.971+00	2024-02-16 00:08:36.971+00	5nv19u6KJ2	LgJuu5ABe5	2	4	2	2	1	\N	\N
ADdXO7jCqb	2024-02-16 00:08:37.181+00	2024-02-16 00:08:37.181+00	HRhGpJpmb5	BMLzFMvIT6	3	1	2	1	3	\N	\N
9W5lvo7dOO	2024-02-16 00:08:37.407+00	2024-02-16 00:08:37.407+00	9223vtvaBd	LgJuu5ABe5	2	0	4	2	1	\N	\N
2C15wHNs5G	2024-02-16 00:08:37.726+00	2024-02-16 00:08:37.726+00	adE9nQrDk3	TpGyMZM9BG	3	3	1	2	4	\N	\N
jU2oUBq3fy	2024-02-16 00:08:37.94+00	2024-02-16 00:08:37.94+00	1as6rMOzjQ	axyV0Fu7pm	3	1	3	3	0	\N	\N
OjAXK6dXRE	2024-02-16 00:08:38.153+00	2024-02-16 00:08:38.153+00	iWxl9obi8w	TCkiw6gTDz	4	2	4	4	1	\N	\N
l8AyiwzD40	2024-02-16 00:08:38.395+00	2024-02-16 00:08:38.395+00	SFAISec8QF	o4VD4BWwDt	2	1	3	1	3	\N	\N
DCkxHCpI0t	2024-02-16 00:08:38.608+00	2024-02-16 00:08:38.608+00	VshUk7eBeK	E2hBZzDsjO	3	4	2	2	4	\N	\N
iAZdC6HlP6	2024-02-16 00:08:38.907+00	2024-02-16 00:08:38.907+00	I5RzFRcQ7G	m8hjjLVdPS	0	4	4	4	0	\N	\N
hWVvfN0dSQ	2024-02-16 00:08:39.119+00	2024-02-16 00:08:39.119+00	sHiqaG4iqY	0TvWuLoLF5	4	4	2	1	2	\N	\N
iumHdMAkaW	2024-02-16 00:08:39.724+00	2024-02-16 00:08:39.724+00	RWwLSzreG2	cFtamPA0zH	3	1	1	3	0	\N	\N
P9hUn4Aghm	2024-02-16 00:08:39.936+00	2024-02-16 00:08:39.936+00	HRhGpJpmb5	o4VD4BWwDt	2	0	3	3	1	\N	\N
KmyOxHGmI8	2024-02-16 00:08:40.147+00	2024-02-16 00:08:40.147+00	1as6rMOzjQ	bi1IivsuUB	1	4	0	4	1	\N	\N
RTp1tl5wVv	2024-02-16 00:08:40.364+00	2024-02-16 00:08:40.364+00	I5RzFRcQ7G	qEQ9tmLyW9	2	1	3	2	1	\N	\N
H1tePZhPCK	2024-02-16 00:08:40.58+00	2024-02-16 00:08:40.58+00	ONgyydfVNz	Pa0qBO2rzK	3	2	0	0	4	\N	\N
tgvc5XoAol	2024-02-16 00:08:40.853+00	2024-02-16 00:08:40.853+00	sHiqaG4iqY	m8hjjLVdPS	1	3	2	0	1	\N	\N
Mg1Wds0b11	2024-02-16 00:08:41.062+00	2024-02-16 00:08:41.062+00	adE9nQrDk3	axyV0Fu7pm	4	3	1	1	0	\N	\N
i8y1FOEnuy	2024-02-16 00:08:41.365+00	2024-02-16 00:08:41.365+00	adE9nQrDk3	e037qpAih3	2	1	3	4	0	\N	\N
Jns8fWKmPa	2024-02-16 00:08:41.583+00	2024-02-16 00:08:41.583+00	AsrLUQwxI9	fKTSJPdUi9	1	4	0	3	2	\N	\N
XctUaMCcSv	2024-02-16 00:08:41.796+00	2024-02-16 00:08:41.796+00	jqDYoPT45X	uigc7bJBOJ	1	1	4	1	2	\N	\N
wXnLCG5GK2	2024-02-16 00:08:42.006+00	2024-02-16 00:08:42.006+00	sHiqaG4iqY	Pa0qBO2rzK	2	4	0	3	1	\N	\N
GCGZuOhE7A	2024-02-16 00:08:42.218+00	2024-02-16 00:08:42.218+00	dZKm0wOhYa	FYXEfIO1zF	2	1	3	4	1	\N	\N
f6fAUzJDt4	2024-02-16 00:08:42.431+00	2024-02-16 00:08:42.431+00	iUlyHNFGpG	NY6RE1qgWu	2	1	4	3	1	\N	\N
s1dsEbzJbV	2024-02-16 00:08:42.644+00	2024-02-16 00:08:42.644+00	NjxsGlPeB4	j0dWqP2C2A	0	3	3	3	0	\N	\N
Cq55SnXr9H	2024-02-16 00:08:42.858+00	2024-02-16 00:08:42.858+00	I5RzFRcQ7G	qP3EdIVzfB	0	4	3	4	3	\N	\N
nuTL5i5Xyb	2024-02-16 00:08:43.07+00	2024-02-16 00:08:43.07+00	R2CLtFh5jU	jjVdtithcD	2	4	3	4	1	\N	\N
87ayRMWbAC	2024-02-16 00:08:43.285+00	2024-02-16 00:08:43.285+00	jqDYoPT45X	m6g8u0QpTC	0	0	4	4	4	\N	\N
aqWwBsK7PE	2024-02-16 00:08:43.498+00	2024-02-16 00:08:43.498+00	R2CLtFh5jU	WSTLlXDcKl	3	3	4	0	1	\N	\N
V2H2AH3wjk	2024-02-16 00:08:43.711+00	2024-02-16 00:08:43.711+00	I5RzFRcQ7G	AgU9OLJkqz	4	3	3	2	3	\N	\N
Qd7fWDMznU	2024-02-16 00:08:43.925+00	2024-02-16 00:08:43.925+00	dEqAHvPMXA	JLhF4VuByh	0	2	3	4	0	\N	\N
XVaSHq2FYa	2024-02-16 00:08:44.232+00	2024-02-16 00:08:44.232+00	5nv19u6KJ2	Oahm9sOn1y	0	2	3	4	0	\N	\N
fAYttFRVQP	2024-02-16 00:08:44.446+00	2024-02-16 00:08:44.446+00	VshUk7eBeK	uigc7bJBOJ	1	0	1	3	4	\N	\N
VZ6P3fqSuE	2024-02-16 00:08:44.659+00	2024-02-16 00:08:44.659+00	Otwj7uJwjr	bi1IivsuUB	1	1	3	3	2	\N	\N
OFbQmkY8sc	2024-02-16 00:08:44.871+00	2024-02-16 00:08:44.871+00	Otwj7uJwjr	08liHW08uC	1	2	4	3	3	\N	\N
RvaNEfuzKO	2024-02-16 00:08:45.153+00	2024-02-16 00:08:45.153+00	iWxl9obi8w	JLhF4VuByh	1	1	3	3	3	\N	\N
SDvDl0By0k	2024-02-16 00:08:45.367+00	2024-02-16 00:08:45.367+00	R2CLtFh5jU	lxQA9rtSfY	4	0	1	0	0	\N	\N
tEFqTNX3Wv	2024-02-16 00:08:45.581+00	2024-02-16 00:08:45.581+00	sHiqaG4iqY	TpGyMZM9BG	2	2	1	3	2	\N	\N
7jNzysuQ6N	2024-02-16 00:08:45.871+00	2024-02-16 00:08:45.871+00	sy1HD51LXT	M0tHrt1GgV	1	0	4	3	4	\N	\N
bz84H6GA6J	2024-02-16 00:08:46.177+00	2024-02-16 00:08:46.177+00	I5RzFRcQ7G	cmxBcanww9	3	0	0	3	4	\N	\N
2cZx2EKbiT	2024-02-16 00:08:46.39+00	2024-02-16 00:08:46.39+00	RWwLSzreG2	8w7i8C3NnT	3	2	2	2	2	\N	\N
AU7GizbSqK	2024-02-16 00:08:46.602+00	2024-02-16 00:08:46.602+00	iWxl9obi8w	rKyjwoEIRp	4	2	2	0	1	\N	\N
Eo1BfFO7tE	2024-02-16 00:08:46.815+00	2024-02-16 00:08:46.815+00	VshUk7eBeK	eEmewy7hPd	4	0	1	3	1	\N	\N
Bhxdg7e9fL	2024-02-16 00:08:47.407+00	2024-02-16 00:08:47.407+00	iWxl9obi8w	JLhF4VuByh	2	4	4	4	4	\N	\N
miGJpl7uCn	2024-02-16 00:08:47.713+00	2024-02-16 00:08:47.713+00	SFAISec8QF	OQWu2bnHeC	3	4	2	2	0	\N	\N
pwUo8UGgmk	2024-02-16 00:08:48.018+00	2024-02-16 00:08:48.018+00	ONgyydfVNz	3u4B9V4l5K	0	3	3	1	2	\N	\N
HHZoE9CiJB	2024-02-16 00:08:48.228+00	2024-02-16 00:08:48.228+00	5X202ssb0D	89xRG1afNi	1	0	2	4	4	\N	\N
kDHqySOGf6	2024-02-16 00:08:48.441+00	2024-02-16 00:08:48.441+00	opW2wQ2bZ8	jjVdtithcD	1	3	3	2	0	\N	\N
0qZDduVhTM	2024-02-16 00:08:49.043+00	2024-02-16 00:08:49.043+00	HRhGpJpmb5	tCIEnLLcUc	4	4	4	4	4	\N	\N
vjyB3hEK3D	2024-02-16 00:08:49.348+00	2024-02-16 00:08:49.348+00	I5RzFRcQ7G	XpUyRlB6FI	0	0	2	0	4	\N	\N
8e68MGrzu7	2024-02-16 00:08:49.688+00	2024-02-16 00:08:49.688+00	NjxsGlPeB4	Gl96vGdYHM	4	1	0	3	1	\N	\N
4RydA3kuvB	2024-02-16 00:08:49.964+00	2024-02-16 00:08:49.964+00	RWwLSzreG2	WnUBBkiDjE	1	2	3	4	2	\N	\N
L6nnxcJEJ8	2024-02-16 00:08:50.273+00	2024-02-16 00:08:50.273+00	SFAISec8QF	lEPdiO1EDi	3	2	0	1	3	\N	\N
6obEyrDXTb	2024-02-16 00:08:50.488+00	2024-02-16 00:08:50.488+00	WKpBp0c8F3	cTIjuPjyIa	2	2	0	0	1	\N	\N
0sJ2qn8rHB	2024-02-16 00:08:50.786+00	2024-02-16 00:08:50.786+00	NjxsGlPeB4	RkhjIQJgou	0	2	4	2	4	\N	\N
GliIgnQXkm	2024-02-16 00:08:51.001+00	2024-02-16 00:08:51.001+00	9223vtvaBd	KCsJ4XR6Dn	4	3	3	4	0	\N	\N
6oW0qkFbhq	2024-02-16 00:08:51.296+00	2024-02-16 00:08:51.296+00	Otwj7uJwjr	XwWwGnkXNj	1	3	1	0	3	\N	\N
D1TCr2tnes	2024-02-16 00:08:51.508+00	2024-02-16 00:08:51.508+00	dZKm0wOhYa	oABNR2FF6S	0	0	1	2	1	\N	\N
eMEupJ3SYD	2024-02-16 00:08:51.723+00	2024-02-16 00:08:51.723+00	VshUk7eBeK	m8hjjLVdPS	2	0	1	1	0	\N	\N
LIFyEGHikN	2024-02-16 00:08:51.933+00	2024-02-16 00:08:51.933+00	HtEtaHBVDN	ThMuD3hYRQ	2	0	3	1	1	\N	\N
ghxnpL3ERC	2024-02-16 00:08:52.144+00	2024-02-16 00:08:52.144+00	SFAISec8QF	FYXEfIO1zF	2	4	0	0	2	\N	\N
zum4YsEZgr	2024-02-16 00:08:52.356+00	2024-02-16 00:08:52.356+00	iUlyHNFGpG	Gl96vGdYHM	0	3	4	2	1	\N	\N
x4ctVQUQ6o	2024-02-16 00:08:52.568+00	2024-02-16 00:08:52.568+00	ONgyydfVNz	HLIPwAqO2R	4	2	3	3	3	\N	\N
fL9b8qH336	2024-02-16 00:08:52.783+00	2024-02-16 00:08:52.783+00	9223vtvaBd	XwszrNEEEj	3	3	3	3	0	\N	\N
HFAWa74DrI	2024-02-16 00:08:52.997+00	2024-02-16 00:08:52.997+00	HtEtaHBVDN	Oahm9sOn1y	2	4	2	3	3	\N	\N
HApbvtoGSq	2024-02-16 00:08:53.243+00	2024-02-16 00:08:53.243+00	opW2wQ2bZ8	3u4B9V4l5K	0	3	4	1	3	\N	\N
0MD8m97xaF	2024-02-16 00:08:53.456+00	2024-02-16 00:08:53.456+00	NjxsGlPeB4	EmIUBFwx0Z	4	4	1	4	0	\N	\N
EsBv8eJfqb	2024-02-16 00:08:53.673+00	2024-02-16 00:08:53.673+00	ONgyydfVNz	eEmewy7hPd	0	0	2	0	1	\N	\N
DdmIOSvhsN	2024-02-16 00:08:53.891+00	2024-02-16 00:08:53.891+00	5X202ssb0D	WBFeKac0OO	0	4	2	4	2	\N	\N
LSQ2pOhsSg	2024-02-16 00:08:54.164+00	2024-02-16 00:08:54.164+00	jqDYoPT45X	8w7i8C3NnT	4	3	1	3	3	\N	\N
KmJdVLRLPt	2024-02-16 00:08:54.378+00	2024-02-16 00:08:54.378+00	NjxsGlPeB4	08liHW08uC	1	2	3	1	4	\N	\N
83XwNZlbJT	2024-02-16 00:08:54.591+00	2024-02-16 00:08:54.591+00	sy1HD51LXT	BMLzFMvIT6	3	2	2	3	0	\N	\N
QMdGYvbbVl	2024-02-16 00:08:54.802+00	2024-02-16 00:08:54.802+00	1as6rMOzjQ	XSK814B37m	4	1	3	2	3	\N	\N
DVgcoEYbxT	2024-02-16 00:08:55.018+00	2024-02-16 00:08:55.018+00	SFAISec8QF	l1Bslv8T2k	0	3	0	3	1	\N	\N
uvuRexB8Cq	2024-02-16 00:08:55.597+00	2024-02-16 00:08:55.597+00	Otwj7uJwjr	y4RkaDbkec	4	3	3	0	1	\N	\N
2lt5Csqcgi	2024-02-16 00:08:55.808+00	2024-02-16 00:08:55.808+00	opW2wQ2bZ8	Gl96vGdYHM	0	2	0	1	1	\N	\N
D3z4TmKjZA	2024-02-16 00:08:56.101+00	2024-02-16 00:08:56.101+00	sHiqaG4iqY	D0A6GLdsDM	3	0	0	0	2	\N	\N
02Krt0pozO	2024-02-16 00:08:56.721+00	2024-02-16 00:08:56.721+00	AsrLUQwxI9	TpGyMZM9BG	1	2	3	1	4	\N	\N
ID691qvinv	2024-02-16 00:08:56.932+00	2024-02-16 00:08:56.932+00	adE9nQrDk3	Gl96vGdYHM	3	3	0	2	0	\N	\N
k6FtqOrAbY	2024-02-16 00:08:57.234+00	2024-02-16 00:08:57.234+00	opW2wQ2bZ8	RBRcyltRSC	2	3	4	3	1	\N	\N
F3ET9WDIoY	2024-02-16 00:08:57.443+00	2024-02-16 00:08:57.443+00	5X202ssb0D	WnUBBkiDjE	3	4	3	3	3	\N	\N
UrmtURq2N8	2024-02-16 00:08:57.748+00	2024-02-16 00:08:57.748+00	iUlyHNFGpG	WHvlAGgj6c	1	3	3	1	0	\N	\N
yIO716koxN	2024-02-16 00:08:57.959+00	2024-02-16 00:08:57.959+00	adE9nQrDk3	NBojpORh3G	3	2	2	4	3	\N	\N
TTL0edapdt	2024-02-16 00:08:58.168+00	2024-02-16 00:08:58.168+00	dZKm0wOhYa	UCFo58JaaD	2	3	0	0	0	\N	\N
fLO8Xl35sE	2024-02-16 00:08:58.381+00	2024-02-16 00:08:58.381+00	iUlyHNFGpG	jjVdtithcD	1	2	0	2	0	\N	\N
hwwWNMXaQF	2024-02-16 00:08:58.595+00	2024-02-16 00:08:58.595+00	HRhGpJpmb5	HXtEwLBC7f	0	4	0	1	1	\N	\N
7ClMoGtKIw	2024-02-16 00:08:58.807+00	2024-02-16 00:08:58.807+00	5X202ssb0D	bi1IivsuUB	1	0	0	3	4	\N	\N
Juid7nL4T7	2024-02-16 00:08:59.386+00	2024-02-16 00:08:59.386+00	5X202ssb0D	qEQ9tmLyW9	2	1	3	0	0	\N	\N
uyw3MKUuWs	2024-02-16 00:08:59.597+00	2024-02-16 00:08:59.597+00	1as6rMOzjQ	Oahm9sOn1y	2	2	1	4	1	\N	\N
tGPTR4ItLM	2024-02-16 00:08:59.897+00	2024-02-16 00:08:59.897+00	sHiqaG4iqY	XwszrNEEEj	1	4	4	3	0	\N	\N
2oIUovUXeC	2024-02-16 00:09:00.11+00	2024-02-16 00:09:00.11+00	I5RzFRcQ7G	WSTLlXDcKl	0	3	0	3	2	\N	\N
0wztPuSRTW	2024-02-16 00:09:00.409+00	2024-02-16 00:09:00.409+00	WKpBp0c8F3	bQ0JOk10eL	1	4	1	2	0	\N	\N
DG4TaWLO6V	2024-02-16 00:09:00.715+00	2024-02-16 00:09:00.715+00	adE9nQrDk3	VK3vnSxIy8	2	0	4	1	2	\N	\N
iae72qevCu	2024-02-16 00:09:00.928+00	2024-02-16 00:09:00.928+00	WKpBp0c8F3	BMLzFMvIT6	0	0	4	0	3	\N	\N
OrElKCKnIp	2024-02-16 00:09:01.134+00	2024-02-16 00:09:01.134+00	mAKp5BK7R1	MQfxuw3ERg	2	3	2	1	3	\N	\N
A2HETHn5FC	2024-02-16 00:09:01.342+00	2024-02-16 00:09:01.342+00	R2CLtFh5jU	OQWu2bnHeC	4	2	0	4	0	\N	\N
sDmHlAvEIh	2024-02-16 00:09:01.554+00	2024-02-16 00:09:01.554+00	mQXQWNqxg9	IybX0eBoO3	0	2	0	0	4	\N	\N
8AnIikyUTl	2024-02-16 00:09:01.769+00	2024-02-16 00:09:01.769+00	mAKp5BK7R1	jjVdtithcD	3	1	3	4	1	\N	\N
joLi0dKbjP	2024-02-16 00:09:02.049+00	2024-02-16 00:09:02.049+00	ONgyydfVNz	PF8w2gMAdi	3	2	4	3	3	\N	\N
RhApmsdz8T	2024-02-16 00:09:02.357+00	2024-02-16 00:09:02.357+00	AsrLUQwxI9	WSTLlXDcKl	3	2	1	0	1	\N	\N
3mvYJutd8B	2024-02-16 00:09:02.97+00	2024-02-16 00:09:02.97+00	ONgyydfVNz	fKTSJPdUi9	1	2	4	1	3	\N	\N
5k7QOpDosM	2024-02-16 00:09:03.181+00	2024-02-16 00:09:03.181+00	I5RzFRcQ7G	WSTLlXDcKl	2	2	3	3	1	\N	\N
CpbiICCgIJ	2024-02-16 00:09:03.394+00	2024-02-16 00:09:03.394+00	WKpBp0c8F3	UDXF0qXvDY	3	1	1	1	2	\N	\N
CFANZB6xyH	2024-02-16 00:09:03.993+00	2024-02-16 00:09:03.993+00	I5RzFRcQ7G	y4RkaDbkec	4	0	0	1	4	\N	\N
S1RPS2WOrP	2024-02-16 00:09:04.203+00	2024-02-16 00:09:04.203+00	RWwLSzreG2	HXtEwLBC7f	1	2	2	0	3	\N	\N
1hvZCpsHFs	2024-02-16 00:09:04.506+00	2024-02-16 00:09:04.506+00	S6wz0lK0bf	uigc7bJBOJ	4	4	4	4	4	\N	\N
3AJYNfcRVM	2024-02-16 00:09:04.716+00	2024-02-16 00:09:04.716+00	sy1HD51LXT	MQfxuw3ERg	1	2	0	2	2	\N	\N
jmN6fi40Wi	2024-02-16 00:09:05.016+00	2024-02-16 00:09:05.016+00	sy1HD51LXT	JLhF4VuByh	0	4	2	4	3	\N	\N
49Bi1Jv7BG	2024-02-16 00:09:05.585+00	2024-02-16 00:09:05.585+00	iUlyHNFGpG	KCsJ4XR6Dn	4	2	1	1	1	\N	\N
BNi8zMhq5j	2024-02-16 00:09:05.8+00	2024-02-16 00:09:05.8+00	9223vtvaBd	TCkiw6gTDz	3	1	0	0	3	\N	\N
47Bt6c6jVa	2024-02-16 00:09:06.041+00	2024-02-16 00:09:06.041+00	adE9nQrDk3	UCFo58JaaD	1	4	0	0	0	\N	\N
Im70BiaSTd	2024-02-16 00:09:06.248+00	2024-02-16 00:09:06.248+00	5X202ssb0D	FJOTueDfs2	0	1	1	4	0	\N	\N
PgYFgk6HLx	2024-02-16 00:09:06.459+00	2024-02-16 00:09:06.459+00	HRhGpJpmb5	cFtamPA0zH	1	4	2	1	0	\N	\N
SS6xr7u42Y	2024-02-16 00:09:06.758+00	2024-02-16 00:09:06.758+00	mAKp5BK7R1	EmIUBFwx0Z	1	3	1	4	3	\N	\N
4CqBZ72eL7	2024-02-16 00:09:07.064+00	2024-02-16 00:09:07.064+00	mQXQWNqxg9	3u4B9V4l5K	0	0	1	2	2	\N	\N
H06L82pyN7	2024-02-16 00:09:07.273+00	2024-02-16 00:09:07.273+00	R2CLtFh5jU	RBRcyltRSC	2	1	2	0	3	\N	\N
qDavikJlzB	2024-02-16 00:09:07.484+00	2024-02-16 00:09:07.484+00	iWxl9obi8w	FYXEfIO1zF	3	1	2	3	1	\N	\N
Dt07TxdRGw	2024-02-16 00:09:07.695+00	2024-02-16 00:09:07.695+00	opW2wQ2bZ8	UDXF0qXvDY	4	4	4	0	4	\N	\N
Myz4t7NwOF	2024-02-16 00:09:07.907+00	2024-02-16 00:09:07.907+00	RWwLSzreG2	M0tHrt1GgV	0	3	3	0	2	\N	\N
hoGH0Nh5ye	2024-02-16 00:09:08.112+00	2024-02-16 00:09:08.112+00	dEqAHvPMXA	E2hBZzDsjO	4	0	1	3	0	\N	\N
fPxceb3geT	2024-02-16 00:09:08.32+00	2024-02-16 00:09:08.32+00	S6wz0lK0bf	yvUod6yLDt	2	1	2	2	0	\N	\N
iLO1mgB2RN	2024-02-16 00:09:08.533+00	2024-02-16 00:09:08.533+00	mAKp5BK7R1	yvUod6yLDt	2	1	2	2	1	\N	\N
RVOHM19ygL	2024-02-16 00:09:09.012+00	2024-02-16 00:09:09.012+00	5X202ssb0D	oABNR2FF6S	4	1	3	1	1	\N	\N
MDdrg8PujE	2024-02-16 00:09:09.222+00	2024-02-16 00:09:09.222+00	9223vtvaBd	jjVdtithcD	4	2	0	2	0	\N	\N
XGDK1Cp1QR	2024-02-16 00:09:09.431+00	2024-02-16 00:09:09.431+00	sy1HD51LXT	C7II8dYRPY	3	2	1	4	0	\N	\N
QiyMKag7BP	2024-02-16 00:09:09.64+00	2024-02-16 00:09:09.64+00	9223vtvaBd	fKTSJPdUi9	3	2	4	1	3	\N	\N
SVYamvLQpl	2024-02-16 00:09:09.85+00	2024-02-16 00:09:09.85+00	HRhGpJpmb5	RBRcyltRSC	3	1	4	3	1	\N	\N
PlLXAR1aY8	2024-02-16 00:09:10.138+00	2024-02-16 00:09:10.138+00	5nv19u6KJ2	cTIjuPjyIa	3	2	0	4	1	\N	\N
BODlk9x1yJ	2024-02-16 00:09:10.345+00	2024-02-16 00:09:10.345+00	opW2wQ2bZ8	o90lhsZ7FK	3	3	1	0	4	\N	\N
zA3fO1foT2	2024-02-16 00:09:10.558+00	2024-02-16 00:09:10.558+00	9223vtvaBd	IybX0eBoO3	0	1	2	1	2	\N	\N
2mJDnK0ruQ	2024-02-16 00:09:10.767+00	2024-02-16 00:09:10.767+00	mQXQWNqxg9	bi1IivsuUB	3	0	3	3	2	\N	\N
i7OrUvEF91	2024-02-16 00:09:10.979+00	2024-02-16 00:09:10.979+00	5X202ssb0D	3u4B9V4l5K	0	3	2	1	2	\N	\N
j8wLl8LBWD	2024-02-16 00:09:11.265+00	2024-02-16 00:09:11.265+00	jqDYoPT45X	eEmewy7hPd	0	2	3	4	1	\N	\N
PUDLSgfRoP	2024-02-16 00:09:11.594+00	2024-02-16 00:09:11.594+00	S6wz0lK0bf	bi1IivsuUB	2	3	0	3	0	\N	\N
u3FiETIqSs	2024-02-16 00:09:12.286+00	2024-02-16 00:09:12.286+00	9223vtvaBd	UCFo58JaaD	3	3	0	3	1	\N	\N
TUuMyFZAEU	2024-02-16 00:09:12.593+00	2024-02-16 00:09:12.593+00	sy1HD51LXT	oABNR2FF6S	3	0	4	1	1	\N	\N
g5ZXyOU8Si	2024-02-16 00:09:12.802+00	2024-02-16 00:09:12.802+00	R2CLtFh5jU	JLhF4VuByh	0	1	0	1	3	\N	\N
XZbWitvdXw	2024-02-16 00:09:13.009+00	2024-02-16 00:09:13.009+00	ONgyydfVNz	e037qpAih3	3	4	4	4	1	\N	\N
R6J1rJEDYE	2024-02-16 00:09:13.218+00	2024-02-16 00:09:13.218+00	5nv19u6KJ2	0TvWuLoLF5	1	0	3	0	2	\N	\N
ak3lwl3lmB	2024-02-16 00:09:13.427+00	2024-02-16 00:09:13.427+00	dEqAHvPMXA	lEPdiO1EDi	0	1	1	0	0	\N	\N
UVyNKx7ZIG	2024-02-16 00:09:13.635+00	2024-02-16 00:09:13.635+00	adE9nQrDk3	NBojpORh3G	4	2	3	1	1	\N	\N
rTmCA41FNl	2024-02-16 00:09:13.927+00	2024-02-16 00:09:13.927+00	sy1HD51LXT	jHqCpA1nWb	2	4	4	2	0	\N	\N
M2DXoHZcLa	2024-02-16 00:09:14.234+00	2024-02-16 00:09:14.234+00	jqDYoPT45X	qZmnAnnPEb	2	1	3	3	3	\N	\N
SiMLyibnrm	2024-02-16 00:09:14.445+00	2024-02-16 00:09:14.445+00	HRhGpJpmb5	6Fo67rhTSP	1	0	0	1	1	\N	\N
w4ApOuwuj2	2024-02-16 00:09:14.655+00	2024-02-16 00:09:14.655+00	5X202ssb0D	TpGyMZM9BG	1	3	0	0	2	\N	\N
tCFFUvLHo8	2024-02-16 00:09:14.868+00	2024-02-16 00:09:14.868+00	dEqAHvPMXA	CSvk1ycWXk	2	2	1	0	4	\N	\N
NLnaMx3bdW	2024-02-16 00:09:15.157+00	2024-02-16 00:09:15.157+00	Otwj7uJwjr	o90lhsZ7FK	0	4	3	1	1	\N	\N
wneEcedyj3	2024-02-16 00:09:15.368+00	2024-02-16 00:09:15.368+00	mAKp5BK7R1	na5crB8ED1	3	3	1	2	4	\N	\N
qXV51gFLbN	2024-02-16 00:09:15.58+00	2024-02-16 00:09:15.58+00	WKpBp0c8F3	mMYg4cyd5R	3	3	2	1	2	\N	\N
Fz7AlGLAA8	2024-02-16 00:09:15.793+00	2024-02-16 00:09:15.793+00	9223vtvaBd	Pa0qBO2rzK	4	4	4	3	4	\N	\N
54nzwlLVfy	2024-02-16 00:09:16.07+00	2024-02-16 00:09:16.07+00	AsrLUQwxI9	qP3EdIVzfB	1	1	1	0	0	\N	\N
KRfuULpnTl	2024-02-16 00:09:16.385+00	2024-02-16 00:09:16.385+00	HRhGpJpmb5	na5crB8ED1	4	4	0	4	3	\N	\N
hpUVCHffJg	2024-02-16 00:09:17+00	2024-02-16 00:09:17+00	Otwj7uJwjr	axyV0Fu7pm	2	0	2	4	1	\N	\N
vrU2wLcz7k	2024-02-16 00:09:17.305+00	2024-02-16 00:09:17.305+00	iUlyHNFGpG	rKyjwoEIRp	1	1	2	0	3	\N	\N
GhV4HNluNW	2024-02-16 00:09:17.517+00	2024-02-16 00:09:17.517+00	mAKp5BK7R1	RkhjIQJgou	2	0	0	2	0	\N	\N
dKkIFVmlVM	2024-02-16 00:09:17.726+00	2024-02-16 00:09:17.726+00	ONgyydfVNz	cmxBcanww9	3	3	4	4	0	\N	\N
B6Jjc3O3lt	2024-02-16 00:09:18.324+00	2024-02-16 00:09:18.324+00	9223vtvaBd	WHvlAGgj6c	1	3	2	2	4	\N	\N
YTrfokesCU	2024-02-16 00:09:18.531+00	2024-02-16 00:09:18.531+00	ONgyydfVNz	cFtamPA0zH	2	2	2	2	4	\N	\N
hXqCGg61Bo	2024-02-16 00:09:18.739+00	2024-02-16 00:09:18.739+00	SFAISec8QF	RBRcyltRSC	2	1	3	4	3	\N	\N
uVDLfxFPOQ	2024-02-16 00:09:19.047+00	2024-02-16 00:09:19.047+00	R2CLtFh5jU	l1Bslv8T2k	2	1	4	0	0	\N	\N
lpRKj3qNGF	2024-02-16 00:09:19.258+00	2024-02-16 00:09:19.258+00	RWwLSzreG2	bQ0JOk10eL	3	1	4	1	0	\N	\N
5lIplS2ZPi	2024-02-16 00:09:19.468+00	2024-02-16 00:09:19.468+00	RWwLSzreG2	qEQ9tmLyW9	3	3	2	2	0	\N	\N
HwvxEmyR7V	2024-02-16 00:09:19.68+00	2024-02-16 00:09:19.68+00	HRhGpJpmb5	8w7i8C3NnT	4	0	2	0	0	\N	\N
LSrBnnwv2E	2024-02-16 00:09:19.892+00	2024-02-16 00:09:19.892+00	mAKp5BK7R1	qZmnAnnPEb	3	0	3	3	3	\N	\N
QTHlZzi2Ic	2024-02-16 00:09:20.174+00	2024-02-16 00:09:20.174+00	adE9nQrDk3	m6g8u0QpTC	4	4	4	0	1	\N	\N
kjjcifmEAk	2024-02-16 00:09:20.784+00	2024-02-16 00:09:20.784+00	mAKp5BK7R1	cwVEh0dqfm	1	0	1	3	3	\N	\N
uwWLiNq9HC	2024-02-16 00:09:21.086+00	2024-02-16 00:09:21.086+00	HtEtaHBVDN	14jGmOAXcg	1	0	2	4	3	\N	\N
VBNo8KdQ5U	2024-02-16 00:09:21.296+00	2024-02-16 00:09:21.296+00	RWwLSzreG2	ThMuD3hYRQ	4	1	0	0	4	\N	\N
hkbxfMijgt	2024-02-16 00:09:21.508+00	2024-02-16 00:09:21.508+00	adE9nQrDk3	o90lhsZ7FK	4	4	1	3	4	\N	\N
LZK1uvOROb	2024-02-16 00:09:22.111+00	2024-02-16 00:09:22.111+00	mAKp5BK7R1	WnUBBkiDjE	0	2	3	0	0	\N	\N
lp5PbDo9Ka	2024-02-16 00:09:22.319+00	2024-02-16 00:09:22.319+00	iWxl9obi8w	axyV0Fu7pm	3	4	2	1	1	\N	\N
qFSgqUxBeZ	2024-02-16 00:09:22.935+00	2024-02-16 00:09:22.935+00	RWwLSzreG2	OQWu2bnHeC	1	3	0	3	2	\N	\N
S3nSfnsonm	2024-02-16 00:09:23.243+00	2024-02-16 00:09:23.243+00	sy1HD51LXT	qZmnAnnPEb	1	0	2	3	3	\N	\N
EOH9wP8uMp	2024-02-16 00:09:23.452+00	2024-02-16 00:09:23.452+00	ONgyydfVNz	14jGmOAXcg	1	3	2	0	2	\N	\N
1qQZm6DaB6	2024-02-16 00:09:23.661+00	2024-02-16 00:09:23.661+00	HRhGpJpmb5	C7II8dYRPY	3	4	1	1	0	\N	\N
VtobTDMUD5	2024-02-16 00:09:23.873+00	2024-02-16 00:09:23.873+00	9223vtvaBd	HXtEwLBC7f	4	3	2	3	4	\N	\N
KcgGto7GDU	2024-02-16 00:09:24.167+00	2024-02-16 00:09:24.167+00	opW2wQ2bZ8	HLIPwAqO2R	1	2	2	1	2	\N	\N
F1XqyazdDV	2024-02-16 00:09:24.379+00	2024-02-16 00:09:24.379+00	9223vtvaBd	XpUyRlB6FI	1	3	0	4	2	\N	\N
z1CCBHCO0i	2024-02-16 00:09:24.588+00	2024-02-16 00:09:24.588+00	dZKm0wOhYa	XSK814B37m	2	0	1	4	0	\N	\N
aYbapTKXCg	2024-02-16 00:09:24.799+00	2024-02-16 00:09:24.799+00	opW2wQ2bZ8	eEmewy7hPd	3	4	1	0	4	\N	\N
nqAGGaOk2k	2024-02-16 00:09:25.011+00	2024-02-16 00:09:25.011+00	dZKm0wOhYa	WSTLlXDcKl	1	2	2	3	2	\N	\N
95hE7N244g	2024-02-16 00:09:25.221+00	2024-02-16 00:09:25.221+00	ONgyydfVNz	bQ0JOk10eL	2	1	0	4	1	\N	\N
BHJ5HabwgN	2024-02-16 00:09:25.431+00	2024-02-16 00:09:25.431+00	dEqAHvPMXA	rKyjwoEIRp	0	2	4	0	0	\N	\N
Yn3Ant6fRL	2024-02-16 00:09:25.644+00	2024-02-16 00:09:25.644+00	iWxl9obi8w	AgU9OLJkqz	2	0	1	3	1	\N	\N
zDjC866wnn	2024-02-16 00:09:25.907+00	2024-02-16 00:09:25.907+00	opW2wQ2bZ8	u5FXeeOChJ	1	3	1	0	3	\N	\N
6Yw5KK8zIz	2024-02-16 00:09:26.112+00	2024-02-16 00:09:26.112+00	SFAISec8QF	vwHi602n66	0	0	0	2	0	\N	\N
CSgX8Z6t5d	2024-02-16 00:09:26.321+00	2024-02-16 00:09:26.321+00	9223vtvaBd	vwHi602n66	2	1	3	1	2	\N	\N
tSk6kv9eKi	2024-02-16 00:09:26.531+00	2024-02-16 00:09:26.531+00	1as6rMOzjQ	lxQA9rtSfY	2	0	2	3	3	\N	\N
T9QYirNgxT	2024-02-16 00:09:26.743+00	2024-02-16 00:09:26.743+00	iWxl9obi8w	y4RkaDbkec	4	3	3	4	1	\N	\N
2bJEnvjmxR	2024-02-16 00:09:27.035+00	2024-02-16 00:09:27.035+00	dEqAHvPMXA	o4VD4BWwDt	1	4	4	2	3	\N	\N
u3LgHh32r4	2024-02-16 00:09:27.645+00	2024-02-16 00:09:27.645+00	iUlyHNFGpG	G0uU7KQLEt	3	0	1	3	0	\N	\N
KH2ELHCBpJ	2024-02-16 00:09:28.261+00	2024-02-16 00:09:28.261+00	9223vtvaBd	FJOTueDfs2	2	4	0	0	3	\N	\N
XhZ1USjOhA	2024-02-16 00:09:28.472+00	2024-02-16 00:09:28.472+00	sHiqaG4iqY	HXtEwLBC7f	2	4	4	1	3	\N	\N
qUalZuMWHD	2024-02-16 00:09:28.683+00	2024-02-16 00:09:28.683+00	iUlyHNFGpG	CSvk1ycWXk	3	2	4	0	1	\N	\N
j3g09zRoOx	2024-02-16 00:09:29.078+00	2024-02-16 00:09:29.078+00	NjxsGlPeB4	HLIPwAqO2R	2	1	0	1	0	\N	\N
53vfcAsHSF	2024-02-16 00:09:29.286+00	2024-02-16 00:09:29.286+00	AsrLUQwxI9	TZsdmscJ2B	3	1	2	1	2	\N	\N
76baVWv9dH	2024-02-16 00:09:29.593+00	2024-02-16 00:09:29.593+00	WKpBp0c8F3	uigc7bJBOJ	0	1	1	0	4	\N	\N
T6yy0CNEfI	2024-02-16 00:09:29.804+00	2024-02-16 00:09:29.804+00	HRhGpJpmb5	89xRG1afNi	1	0	2	1	1	\N	\N
BfiNrguSCc	2024-02-16 00:09:30.012+00	2024-02-16 00:09:30.012+00	SFAISec8QF	OQWu2bnHeC	3	4	3	1	4	\N	\N
IdInMZGvag	2024-02-16 00:09:30.22+00	2024-02-16 00:09:30.22+00	WKpBp0c8F3	WSTLlXDcKl	2	3	2	0	0	\N	\N
lHfmYJ9a02	2024-02-16 00:09:30.427+00	2024-02-16 00:09:30.427+00	VshUk7eBeK	uigc7bJBOJ	2	1	4	3	3	\N	\N
7rTnseDB8F	2024-02-16 00:09:30.636+00	2024-02-16 00:09:30.636+00	1as6rMOzjQ	G0uU7KQLEt	0	2	0	3	0	\N	\N
s0FGpJoHbU	2024-02-16 00:09:30.846+00	2024-02-16 00:09:30.846+00	5X202ssb0D	cwVEh0dqfm	4	1	1	2	1	\N	\N
NSjOMz2RUG	2024-02-16 00:09:31.121+00	2024-02-16 00:09:31.121+00	RWwLSzreG2	8w7i8C3NnT	3	4	2	2	1	\N	\N
FdRfJyeCIA	2024-02-16 00:09:31.342+00	2024-02-16 00:09:31.342+00	jqDYoPT45X	E2hBZzDsjO	2	1	4	2	4	\N	\N
raewsRk8Lg	2024-02-16 00:09:31.553+00	2024-02-16 00:09:31.553+00	sy1HD51LXT	0TvWuLoLF5	2	0	0	2	1	\N	\N
4Fljya2QpT	2024-02-16 00:09:31.763+00	2024-02-16 00:09:31.763+00	sy1HD51LXT	y4RkaDbkec	3	4	2	2	0	\N	\N
T7J8OJP8AI	2024-02-16 00:09:31.973+00	2024-02-16 00:09:31.973+00	opW2wQ2bZ8	08liHW08uC	1	2	0	3	1	\N	\N
PrkXlpCSlC	2024-02-16 00:09:32.186+00	2024-02-16 00:09:32.186+00	dZKm0wOhYa	TCkiw6gTDz	3	4	4	3	1	\N	\N
HDHChxhrhv	2024-02-16 00:09:32.462+00	2024-02-16 00:09:32.462+00	mQXQWNqxg9	6KvFK8yy1q	3	2	3	2	4	\N	\N
uLtttFoJMP	2024-02-16 00:09:33.076+00	2024-02-16 00:09:33.076+00	jqDYoPT45X	C7II8dYRPY	0	0	3	2	4	\N	\N
uAM01UN92E	2024-02-16 00:09:33.381+00	2024-02-16 00:09:33.381+00	SFAISec8QF	bQ0JOk10eL	4	2	0	2	2	\N	\N
w5VEf6UKIB	2024-02-16 00:09:33.592+00	2024-02-16 00:09:33.592+00	RWwLSzreG2	JRi61dUphq	4	3	3	2	1	\N	\N
j7YQwcBTAj	2024-02-16 00:09:33.804+00	2024-02-16 00:09:33.804+00	NjxsGlPeB4	IEqTHcohpJ	0	4	0	3	4	\N	\N
8dfksGBHZo	2024-02-16 00:09:34.014+00	2024-02-16 00:09:34.014+00	dZKm0wOhYa	cFtamPA0zH	0	3	1	2	3	\N	\N
3bbAzJoe7s	2024-02-16 00:09:34.224+00	2024-02-16 00:09:34.224+00	dEqAHvPMXA	cmxBcanww9	1	3	1	2	2	\N	\N
n2r2c7XFya	2024-02-16 00:09:34.433+00	2024-02-16 00:09:34.433+00	iWxl9obi8w	l1Bslv8T2k	2	4	4	4	2	\N	\N
bFEC7V1GRY	2024-02-16 00:09:34.646+00	2024-02-16 00:09:34.646+00	1as6rMOzjQ	rKyjwoEIRp	1	4	2	0	0	\N	\N
xAx3EG5xcj	2024-02-16 00:09:34.863+00	2024-02-16 00:09:34.863+00	SFAISec8QF	m6g8u0QpTC	1	4	3	1	1	\N	\N
7l9QSjUXmK	2024-02-16 00:09:35.076+00	2024-02-16 00:09:35.076+00	RWwLSzreG2	jjVdtithcD	1	4	0	3	3	\N	\N
sDs22VLTnC	2024-02-16 00:09:35.287+00	2024-02-16 00:09:35.287+00	NjxsGlPeB4	89xRG1afNi	1	4	2	4	1	\N	\N
6dfNBDCDvd	2024-02-16 00:09:35.496+00	2024-02-16 00:09:35.496+00	RWwLSzreG2	XwszrNEEEj	3	1	3	4	3	\N	\N
g62GgLFZgv	2024-02-16 00:09:35.707+00	2024-02-16 00:09:35.707+00	I5RzFRcQ7G	m6g8u0QpTC	0	0	0	2	2	\N	\N
Efx41lLp45	2024-02-16 00:09:35.918+00	2024-02-16 00:09:35.918+00	Otwj7uJwjr	WSTLlXDcKl	2	0	2	4	4	\N	\N
ZqlcwMbLDT	2024-02-16 00:09:36.122+00	2024-02-16 00:09:36.122+00	HRhGpJpmb5	C7II8dYRPY	3	1	0	0	2	\N	\N
IoWPo7tAe5	2024-02-16 00:09:36.353+00	2024-02-16 00:09:36.353+00	NjxsGlPeB4	3u4B9V4l5K	1	4	4	4	2	\N	\N
QRpC5QiXmZ	2024-02-16 00:09:36.564+00	2024-02-16 00:09:36.564+00	NjxsGlPeB4	jHqCpA1nWb	3	4	0	2	3	\N	\N
U4M1gWQnj6	2024-02-16 00:09:36.773+00	2024-02-16 00:09:36.773+00	dEqAHvPMXA	lxQA9rtSfY	1	0	3	0	2	\N	\N
Rwbp5QMkTG	2024-02-16 00:09:36.984+00	2024-02-16 00:09:36.984+00	iUlyHNFGpG	UDXF0qXvDY	3	0	2	1	2	\N	\N
xFIWCiqDGL	2024-02-16 00:09:37.195+00	2024-02-16 00:09:37.195+00	mQXQWNqxg9	MQfxuw3ERg	1	0	3	2	1	\N	\N
jamWkdhFnk	2024-02-16 00:09:37.408+00	2024-02-16 00:09:37.408+00	iUlyHNFGpG	KCsJ4XR6Dn	2	3	1	3	3	\N	\N
FfPmx0YNdp	2024-02-16 00:09:37.624+00	2024-02-16 00:09:37.624+00	Otwj7uJwjr	HXtEwLBC7f	3	1	2	2	0	\N	\N
8KnzDkSKU9	2024-02-16 00:09:37.835+00	2024-02-16 00:09:37.835+00	I5RzFRcQ7G	M0tHrt1GgV	1	1	1	3	1	\N	\N
n98UjopnHd	2024-02-16 00:09:38.049+00	2024-02-16 00:09:38.049+00	dZKm0wOhYa	TCkiw6gTDz	1	4	0	0	1	\N	\N
b1G1Yoj19C	2024-02-16 00:09:38.271+00	2024-02-16 00:09:38.271+00	adE9nQrDk3	bQpy9LEJWn	4	1	2	2	1	\N	\N
JFo3asu5yO	2024-02-16 00:09:38.507+00	2024-02-16 00:09:38.507+00	VshUk7eBeK	WSTLlXDcKl	3	1	0	0	2	\N	\N
lDtcoNUq4J	2024-02-16 00:09:38.731+00	2024-02-16 00:09:38.731+00	ONgyydfVNz	qP3EdIVzfB	3	4	1	3	4	\N	\N
1k5akb7CEG	2024-02-16 00:09:38.938+00	2024-02-16 00:09:38.938+00	VshUk7eBeK	UDXF0qXvDY	0	2	4	0	0	\N	\N
CuVvzCgZXL	2024-02-16 00:09:39.154+00	2024-02-16 00:09:39.154+00	mAKp5BK7R1	LgJuu5ABe5	1	0	1	0	1	\N	\N
p79SoR6yMI	2024-02-16 00:09:39.529+00	2024-02-16 00:09:39.529+00	adE9nQrDk3	lEPdiO1EDi	0	1	0	1	4	\N	\N
ky96T9kCKF	2024-02-16 00:09:40.138+00	2024-02-16 00:09:40.138+00	HRhGpJpmb5	8w7i8C3NnT	3	3	0	0	4	\N	\N
7sCYknNOAl	2024-02-16 00:09:40.35+00	2024-02-16 00:09:40.35+00	mAKp5BK7R1	XwWwGnkXNj	2	2	1	0	4	\N	\N
og3psY0SKk	2024-02-16 00:09:40.563+00	2024-02-16 00:09:40.563+00	dZKm0wOhYa	bi1IivsuUB	4	1	2	3	2	\N	\N
FjMyKqHCnG	2024-02-16 00:09:40.773+00	2024-02-16 00:09:40.773+00	opW2wQ2bZ8	PF8w2gMAdi	1	0	3	0	1	\N	\N
uvmte1wRrl	2024-02-16 00:09:40.98+00	2024-02-16 00:09:40.98+00	ONgyydfVNz	XwszrNEEEj	0	0	0	3	2	\N	\N
jq4Cx07U3y	2024-02-16 00:09:41.187+00	2024-02-16 00:09:41.187+00	WKpBp0c8F3	Oahm9sOn1y	2	2	3	4	0	\N	\N
SGxWDeqFMz	2024-02-16 00:09:41.397+00	2024-02-16 00:09:41.397+00	iUlyHNFGpG	PF8w2gMAdi	0	1	0	1	0	\N	\N
FWocZKTnPZ	2024-02-16 00:09:41.607+00	2024-02-16 00:09:41.607+00	dZKm0wOhYa	TpGyMZM9BG	4	1	2	4	3	\N	\N
uTIzSSGcpC	2024-02-16 00:09:41.883+00	2024-02-16 00:09:41.883+00	dEqAHvPMXA	RBRcyltRSC	4	0	0	0	2	\N	\N
gCasJXMFyK	2024-02-16 00:09:42.496+00	2024-02-16 00:09:42.496+00	AsrLUQwxI9	C7II8dYRPY	3	1	3	2	4	\N	\N
WnNVE87wsj	2024-02-16 00:09:42.706+00	2024-02-16 00:09:42.706+00	adE9nQrDk3	JRi61dUphq	0	0	1	1	1	\N	\N
zGP9QcRWQj	2024-02-16 00:09:42.916+00	2024-02-16 00:09:42.916+00	NjxsGlPeB4	jHqCpA1nWb	3	3	2	2	4	\N	\N
ofEv7ommMQ	2024-02-16 00:09:43.126+00	2024-02-16 00:09:43.126+00	HRhGpJpmb5	BMLzFMvIT6	2	0	0	3	0	\N	\N
Z7r1ooJd31	2024-02-16 00:09:43.416+00	2024-02-16 00:09:43.416+00	S6wz0lK0bf	uigc7bJBOJ	0	2	2	2	3	\N	\N
wm2ejr3mhf	2024-02-16 00:09:43.727+00	2024-02-16 00:09:43.727+00	SFAISec8QF	jHqCpA1nWb	2	1	4	1	3	\N	\N
CsjD3F3bZ0	2024-02-16 00:09:43.938+00	2024-02-16 00:09:43.938+00	sHiqaG4iqY	CSvk1ycWXk	1	3	4	2	4	\N	\N
pdCemC1a1h	2024-02-16 00:09:44.238+00	2024-02-16 00:09:44.238+00	dEqAHvPMXA	m6g8u0QpTC	2	1	2	2	1	\N	\N
M4NofPhpk3	2024-02-16 00:09:44.45+00	2024-02-16 00:09:44.45+00	iUlyHNFGpG	Pa0qBO2rzK	1	4	0	4	2	\N	\N
JSZ4SdCq8y	2024-02-16 00:09:44.663+00	2024-02-16 00:09:44.663+00	ONgyydfVNz	BMLzFMvIT6	2	4	4	4	4	\N	\N
7JtVVIHjzg	2024-02-16 00:09:44.879+00	2024-02-16 00:09:44.879+00	iUlyHNFGpG	HXtEwLBC7f	3	2	4	2	4	\N	\N
4gOM9yYs5v	2024-02-16 00:09:45.096+00	2024-02-16 00:09:45.096+00	mAKp5BK7R1	XwszrNEEEj	0	1	3	1	3	\N	\N
3iCyrFNEH3	2024-02-16 00:09:45.363+00	2024-02-16 00:09:45.363+00	sy1HD51LXT	na5crB8ED1	2	1	3	1	4	\N	\N
zEyDO4iAkk	2024-02-16 00:09:45.671+00	2024-02-16 00:09:45.671+00	opW2wQ2bZ8	XSK814B37m	1	3	3	0	2	\N	\N
yW2MvwTS3X	2024-02-16 00:09:45.882+00	2024-02-16 00:09:45.882+00	sHiqaG4iqY	eEmewy7hPd	2	4	2	0	4	\N	\N
yEJHcEnBbi	2024-02-16 00:09:46.088+00	2024-02-16 00:09:46.088+00	dZKm0wOhYa	LVYK4mLShP	4	4	3	3	3	\N	\N
UbbNp2OneG	2024-02-16 00:09:46.548+00	2024-02-16 00:09:46.548+00	HRhGpJpmb5	o4VD4BWwDt	1	4	2	3	1	\N	\N
p6mB5i3QkH	2024-02-16 00:09:46.76+00	2024-02-16 00:09:46.76+00	mQXQWNqxg9	cFtamPA0zH	0	1	4	4	1	\N	\N
M7Mtt0Hvoa	2024-02-16 00:09:46.967+00	2024-02-16 00:09:46.967+00	5X202ssb0D	UCFo58JaaD	4	2	4	3	1	\N	\N
HdPo6TAhg1	2024-02-16 00:09:47.208+00	2024-02-16 00:09:47.208+00	WKpBp0c8F3	VK3vnSxIy8	0	4	4	2	0	\N	\N
FWdjEQ0sTh	2024-02-16 00:09:47.515+00	2024-02-16 00:09:47.515+00	mAKp5BK7R1	P9sBFomftT	3	3	1	4	2	\N	\N
DpqypfDiXA	2024-02-16 00:09:48.228+00	2024-02-16 00:09:48.228+00	I5RzFRcQ7G	eEmewy7hPd	3	4	4	1	4	\N	\N
N2dA9RZU6P	2024-02-16 00:09:48.439+00	2024-02-16 00:09:48.439+00	R2CLtFh5jU	M0tHrt1GgV	0	1	0	4	1	\N	\N
yiIkwDq7Uh	2024-02-16 00:09:48.742+00	2024-02-16 00:09:48.742+00	AsrLUQwxI9	INeptnSdJC	4	4	4	4	1	\N	\N
LxPDXrz44I	2024-02-16 00:09:49.048+00	2024-02-16 00:09:49.048+00	AsrLUQwxI9	WBFeKac0OO	2	4	2	4	0	\N	\N
2kc74QD8BS	2024-02-16 00:09:49.355+00	2024-02-16 00:09:49.355+00	SFAISec8QF	HSEugQ3Ouj	0	2	4	4	2	\N	\N
i9hkG66geR	2024-02-16 00:09:49.663+00	2024-02-16 00:09:49.663+00	RWwLSzreG2	G0uU7KQLEt	4	1	1	3	0	\N	\N
EDdkpNX6Nn	2024-02-16 00:09:50.375+00	2024-02-16 00:09:50.375+00	WKpBp0c8F3	uABtFsJhJc	4	1	2	2	0	\N	\N
EryZ1qpS5r	2024-02-16 00:09:50.583+00	2024-02-16 00:09:50.583+00	sHiqaG4iqY	u5FXeeOChJ	2	0	1	0	2	\N	\N
glIenjKpAr	2024-02-16 00:09:50.789+00	2024-02-16 00:09:50.789+00	dZKm0wOhYa	OQWu2bnHeC	3	4	0	2	2	\N	\N
Sc8YC6Jvyr	2024-02-16 00:09:51.402+00	2024-02-16 00:09:51.402+00	HRhGpJpmb5	HSEugQ3Ouj	2	1	3	4	1	\N	\N
tkYK2U6Z1j	2024-02-16 00:09:51.608+00	2024-02-16 00:09:51.608+00	HRhGpJpmb5	y4RkaDbkec	3	0	3	4	4	\N	\N
YToHiAEOBi	2024-02-16 00:09:51.914+00	2024-02-16 00:09:51.914+00	5X202ssb0D	na5crB8ED1	1	2	0	3	1	\N	\N
oKz2U6pCRY	2024-02-16 00:09:52.121+00	2024-02-16 00:09:52.121+00	opW2wQ2bZ8	TpGyMZM9BG	4	0	4	3	2	\N	\N
gc6UFRAjXf	2024-02-16 00:09:52.329+00	2024-02-16 00:09:52.329+00	sy1HD51LXT	BMLzFMvIT6	1	4	2	0	3	\N	\N
fhhBhPDCDN	2024-02-16 00:09:52.537+00	2024-02-16 00:09:52.537+00	Otwj7uJwjr	6Fo67rhTSP	0	1	2	0	2	\N	\N
xOvS6FnqiX	2024-02-16 00:09:52.745+00	2024-02-16 00:09:52.745+00	ONgyydfVNz	JRi61dUphq	1	4	0	3	1	\N	\N
9rwjy7QheN	2024-02-16 00:09:52.957+00	2024-02-16 00:09:52.957+00	iWxl9obi8w	UDXF0qXvDY	1	0	4	4	1	\N	\N
GCI9USDBSZ	2024-02-16 00:09:53.247+00	2024-02-16 00:09:53.247+00	AsrLUQwxI9	j0dWqP2C2A	1	1	1	2	4	\N	\N
WIOfUIJeEk	2024-02-16 00:09:53.458+00	2024-02-16 00:09:53.458+00	SFAISec8QF	m8hjjLVdPS	3	4	3	1	2	\N	\N
5gi7FK6uc6	2024-02-16 00:09:53.668+00	2024-02-16 00:09:53.668+00	NjxsGlPeB4	RkhjIQJgou	3	4	1	3	3	\N	\N
gEvkenOt0w	2024-02-16 00:09:53.877+00	2024-02-16 00:09:53.877+00	HtEtaHBVDN	HSEugQ3Ouj	4	2	3	2	2	\N	\N
BoFksHrPHS	2024-02-16 00:09:54.085+00	2024-02-16 00:09:54.085+00	AsrLUQwxI9	14jGmOAXcg	1	3	4	2	2	\N	\N
R2HOveRKL8	2024-02-16 00:09:54.296+00	2024-02-16 00:09:54.296+00	ONgyydfVNz	BMLzFMvIT6	1	4	3	1	0	\N	\N
C9KsEFoXZs	2024-02-16 00:09:54.508+00	2024-02-16 00:09:54.508+00	ONgyydfVNz	yvUod6yLDt	3	4	2	4	3	\N	\N
3vzFINA6bg	2024-02-16 00:09:54.721+00	2024-02-16 00:09:54.721+00	iWxl9obi8w	INeptnSdJC	0	4	4	3	1	\N	\N
NeINDeIezq	2024-02-16 00:09:54.989+00	2024-02-16 00:09:54.989+00	SFAISec8QF	WHvlAGgj6c	4	4	2	0	3	\N	\N
8acSf5O1ft	2024-02-16 00:09:55.296+00	2024-02-16 00:09:55.296+00	S6wz0lK0bf	Pa0qBO2rzK	0	1	1	1	4	\N	\N
lzuQFuKXko	2024-02-16 00:09:55.507+00	2024-02-16 00:09:55.507+00	opW2wQ2bZ8	TZsdmscJ2B	3	2	3	3	0	\N	\N
ri8IWAMPQv	2024-02-16 00:09:55.717+00	2024-02-16 00:09:55.717+00	RWwLSzreG2	HSEugQ3Ouj	1	2	3	0	1	\N	\N
E5bTFVFfMD	2024-02-16 00:09:55.928+00	2024-02-16 00:09:55.928+00	mQXQWNqxg9	eEmewy7hPd	0	4	2	2	0	\N	\N
Qwr1PSyFPs	2024-02-16 00:09:56.141+00	2024-02-16 00:09:56.141+00	VshUk7eBeK	bQpy9LEJWn	2	0	1	1	3	\N	\N
Bf9gspsNtg	2024-02-16 00:09:56.352+00	2024-02-16 00:09:56.352+00	HtEtaHBVDN	l1Bslv8T2k	2	1	3	4	0	\N	\N
imY6ND6U4t	2024-02-16 00:09:56.563+00	2024-02-16 00:09:56.563+00	S6wz0lK0bf	lxQA9rtSfY	4	2	0	3	1	\N	\N
xTBb9lYLG6	2024-02-16 00:09:56.774+00	2024-02-16 00:09:56.774+00	adE9nQrDk3	NY6RE1qgWu	1	2	3	3	2	\N	\N
ZIlUneOvi9	2024-02-16 00:09:56.987+00	2024-02-16 00:09:56.987+00	S6wz0lK0bf	OQWu2bnHeC	1	1	0	0	2	\N	\N
K4BdH7Gl4q	2024-02-16 00:09:57.242+00	2024-02-16 00:09:57.242+00	sy1HD51LXT	Pa0qBO2rzK	0	0	0	2	1	\N	\N
WTq0HN4Lok	2024-02-16 00:09:57.452+00	2024-02-16 00:09:57.452+00	sy1HD51LXT	vwHi602n66	3	3	2	0	2	\N	\N
OusTe1cGyW	2024-02-16 00:09:57.669+00	2024-02-16 00:09:57.669+00	RWwLSzreG2	rKyjwoEIRp	0	4	2	1	3	\N	\N
vyfLIne2v6	2024-02-16 00:09:57.88+00	2024-02-16 00:09:57.88+00	VshUk7eBeK	TCkiw6gTDz	2	3	4	1	1	\N	\N
LyMTbyntxS	2024-02-16 00:09:58.164+00	2024-02-16 00:09:58.164+00	AsrLUQwxI9	Oahm9sOn1y	2	3	4	1	2	\N	\N
dCBRM59xPM	2024-02-16 00:09:58.375+00	2024-02-16 00:09:58.375+00	iUlyHNFGpG	bi1IivsuUB	2	2	0	2	0	\N	\N
NbS1WG7yYB	2024-02-16 00:09:58.586+00	2024-02-16 00:09:58.586+00	dZKm0wOhYa	JRi61dUphq	4	4	2	2	3	\N	\N
eCKg1GNpOQ	2024-02-16 00:09:58.801+00	2024-02-16 00:09:58.801+00	sy1HD51LXT	0TvWuLoLF5	3	4	2	1	2	\N	\N
lJMwyHqROr	2024-02-16 00:09:59.013+00	2024-02-16 00:09:59.013+00	sHiqaG4iqY	TpGyMZM9BG	1	0	3	4	2	\N	\N
IJEyPy9zGF	2024-02-16 00:09:59.224+00	2024-02-16 00:09:59.224+00	HRhGpJpmb5	TZsdmscJ2B	1	3	4	2	4	\N	\N
LudWUiov5R	2024-02-16 00:09:59.436+00	2024-02-16 00:09:59.436+00	I5RzFRcQ7G	bi1IivsuUB	3	1	3	2	0	\N	\N
Y8qVZQA6J6	2024-02-16 00:09:59.651+00	2024-02-16 00:09:59.651+00	sHiqaG4iqY	TCkiw6gTDz	4	1	2	2	1	\N	\N
rywEZ4klDQ	2024-02-16 00:09:59.904+00	2024-02-16 00:09:59.904+00	9223vtvaBd	TpGyMZM9BG	0	1	4	1	0	\N	\N
M0Yw3qLi6z	2024-02-16 00:10:00.212+00	2024-02-16 00:10:00.212+00	I5RzFRcQ7G	JZOBDAh12a	0	2	0	3	2	\N	\N
mVEiEaqDQ9	2024-02-16 00:10:00.519+00	2024-02-16 00:10:00.519+00	1as6rMOzjQ	VK3vnSxIy8	2	4	1	0	0	\N	\N
7V1ci1SAMO	2024-02-16 00:10:00.733+00	2024-02-16 00:10:00.733+00	1as6rMOzjQ	3P6kmNoY1F	4	1	2	0	4	\N	\N
Ut1aRg41Za	2024-02-16 00:10:00.947+00	2024-02-16 00:10:00.947+00	RWwLSzreG2	RBRcyltRSC	2	0	0	0	3	\N	\N
ZR13aB6OBN	2024-02-16 00:10:01.153+00	2024-02-16 00:10:01.153+00	RWwLSzreG2	IybX0eBoO3	0	1	3	2	3	\N	\N
JtNEqG2KsK	2024-02-16 00:10:01.366+00	2024-02-16 00:10:01.366+00	1as6rMOzjQ	m6g8u0QpTC	2	1	4	1	0	\N	\N
Ty0sUXRNan	2024-02-16 00:10:01.576+00	2024-02-16 00:10:01.576+00	ONgyydfVNz	LVYK4mLShP	4	2	3	3	3	\N	\N
aAhAIBoCPd	2024-02-16 00:10:01.785+00	2024-02-16 00:10:01.785+00	dZKm0wOhYa	WBFeKac0OO	1	1	1	2	1	\N	\N
eLwA9zqfIY	2024-02-16 00:10:01.996+00	2024-02-16 00:10:01.996+00	mAKp5BK7R1	na5crB8ED1	1	2	3	0	0	\N	\N
MgTu6XVyzc	2024-02-16 00:10:02.259+00	2024-02-16 00:10:02.259+00	opW2wQ2bZ8	6Fo67rhTSP	4	4	0	1	4	\N	\N
sOZoBnQApt	2024-02-16 00:10:02.47+00	2024-02-16 00:10:02.47+00	mQXQWNqxg9	H40ivltLwZ	2	0	3	3	2	\N	\N
BJeXojJFIm	2024-02-16 00:10:02.683+00	2024-02-16 00:10:02.683+00	SFAISec8QF	jHqCpA1nWb	4	3	4	3	4	\N	\N
JQSwxM3jyS	2024-02-16 00:10:02.978+00	2024-02-16 00:10:02.978+00	mQXQWNqxg9	6Fo67rhTSP	2	1	2	0	1	\N	\N
1haHU21jpR	2024-02-16 00:10:03.19+00	2024-02-16 00:10:03.19+00	iUlyHNFGpG	8w7i8C3NnT	4	4	2	1	4	\N	\N
fQqN5Kpp9Z	2024-02-16 00:10:03.411+00	2024-02-16 00:10:03.411+00	mQXQWNqxg9	C7II8dYRPY	0	0	2	1	4	\N	\N
6OmjCqXa5X	2024-02-16 00:10:03.623+00	2024-02-16 00:10:03.623+00	adE9nQrDk3	y4RkaDbkec	1	2	4	2	3	\N	\N
ByEFrFAnMS	2024-02-16 00:10:03.84+00	2024-02-16 00:10:03.84+00	5X202ssb0D	14jGmOAXcg	4	3	4	1	2	\N	\N
MjHL2ajyxr	2024-02-16 00:10:04.103+00	2024-02-16 00:10:04.103+00	S6wz0lK0bf	6KvFK8yy1q	2	0	4	3	2	\N	\N
Cv3Bac3Bgx	2024-02-16 00:10:04.316+00	2024-02-16 00:10:04.316+00	S6wz0lK0bf	jHqCpA1nWb	1	4	0	4	0	\N	\N
PY5bcU0x01	2024-02-16 00:10:04.529+00	2024-02-16 00:10:04.529+00	ONgyydfVNz	u5FXeeOChJ	1	2	1	0	1	\N	\N
9aOx6yILjL	2024-02-16 00:10:04.741+00	2024-02-16 00:10:04.741+00	mAKp5BK7R1	XwszrNEEEj	0	1	3	2	2	\N	\N
gBm29TKvLS	2024-02-16 00:10:05.027+00	2024-02-16 00:10:05.027+00	adE9nQrDk3	6Fo67rhTSP	0	3	3	4	4	\N	\N
AdjXIME2cO	2024-02-16 00:10:05.237+00	2024-02-16 00:10:05.237+00	5X202ssb0D	lxQA9rtSfY	2	3	2	1	3	\N	\N
lEgmPFcgVX	2024-02-16 00:10:05.449+00	2024-02-16 00:10:05.449+00	dEqAHvPMXA	bQpy9LEJWn	1	3	3	2	2	\N	\N
k8tPdSrH0G	2024-02-16 00:10:05.664+00	2024-02-16 00:10:05.664+00	sy1HD51LXT	cmxBcanww9	3	4	0	0	4	\N	\N
F8rKTbeVE0	2024-02-16 00:10:05.879+00	2024-02-16 00:10:05.879+00	SFAISec8QF	TZsdmscJ2B	2	2	0	2	2	\N	\N
BkIIXYYzs6	2024-02-16 00:10:06.143+00	2024-02-16 00:10:06.143+00	1as6rMOzjQ	l1Bslv8T2k	0	2	4	2	4	\N	\N
eSLCHA0YlQ	2024-02-16 00:10:06.353+00	2024-02-16 00:10:06.353+00	R2CLtFh5jU	Pa0qBO2rzK	0	4	2	4	0	\N	\N
W7OH3kxWkG	2024-02-16 00:10:06.663+00	2024-02-16 00:10:06.663+00	NjxsGlPeB4	o90lhsZ7FK	3	1	4	3	2	\N	\N
NKiodMIH0v	2024-02-16 00:10:06.877+00	2024-02-16 00:10:06.877+00	S6wz0lK0bf	H40ivltLwZ	2	3	3	2	2	\N	\N
G7aRISwFm5	2024-02-16 00:10:07.09+00	2024-02-16 00:10:07.09+00	dZKm0wOhYa	IybX0eBoO3	1	0	3	0	3	\N	\N
9U1TZTjl8G	2024-02-16 00:10:07.305+00	2024-02-16 00:10:07.305+00	HRhGpJpmb5	cmxBcanww9	4	3	2	1	3	\N	\N
cR0r1nwPJO	2024-02-16 00:10:07.519+00	2024-02-16 00:10:07.519+00	9223vtvaBd	OQWu2bnHeC	0	4	1	1	2	\N	\N
K5qV7maU1Q	2024-02-16 00:10:07.731+00	2024-02-16 00:10:07.731+00	5X202ssb0D	C7II8dYRPY	0	2	0	1	0	\N	\N
pvNUVZ5SkD	2024-02-16 00:10:07.994+00	2024-02-16 00:10:07.994+00	adE9nQrDk3	oABNR2FF6S	4	0	4	2	2	\N	\N
cMxs24niFj	2024-02-16 00:10:08.302+00	2024-02-16 00:10:08.302+00	R2CLtFh5jU	KCsJ4XR6Dn	3	4	3	1	4	\N	\N
3OhWVKJkrQ	2024-02-16 00:10:08.608+00	2024-02-16 00:10:08.608+00	Otwj7uJwjr	yvUod6yLDt	3	1	3	4	4	\N	\N
Y4swp8SNCm	2024-02-16 00:10:08.818+00	2024-02-16 00:10:08.818+00	HtEtaHBVDN	6KvFK8yy1q	2	1	1	3	3	\N	\N
bYZcBtYSMo	2024-02-16 00:10:09.022+00	2024-02-16 00:10:09.022+00	RWwLSzreG2	IEqTHcohpJ	0	3	3	4	1	\N	\N
QZCAUrrZ9c	2024-02-16 00:10:09.227+00	2024-02-16 00:10:09.227+00	1as6rMOzjQ	Gl96vGdYHM	0	3	4	3	4	\N	\N
gO1ypSM6F4	2024-02-16 00:10:09.436+00	2024-02-16 00:10:09.436+00	AsrLUQwxI9	axyV0Fu7pm	2	4	3	4	2	\N	\N
DshkNqhXZ7	2024-02-16 00:10:09.649+00	2024-02-16 00:10:09.649+00	5X202ssb0D	qZmnAnnPEb	2	2	2	0	1	\N	\N
cIBlDb2qjt	2024-02-16 00:10:09.864+00	2024-02-16 00:10:09.864+00	I5RzFRcQ7G	IybX0eBoO3	1	3	3	4	3	\N	\N
RiuKtBBLTq	2024-02-16 00:10:10.145+00	2024-02-16 00:10:10.145+00	iWxl9obi8w	JLhF4VuByh	3	3	0	1	4	\N	\N
xKYXDdx40u	2024-02-16 00:10:10.359+00	2024-02-16 00:10:10.359+00	mQXQWNqxg9	LVYK4mLShP	0	1	2	1	0	\N	\N
n1z5nZqunv	2024-02-16 00:10:10.649+00	2024-02-16 00:10:10.649+00	dEqAHvPMXA	WHvlAGgj6c	2	1	0	4	4	\N	\N
jElq2YsMPl	2024-02-16 00:10:10.861+00	2024-02-16 00:10:10.861+00	S6wz0lK0bf	fKTSJPdUi9	0	1	3	4	4	\N	\N
64asmfqOYv	2024-02-16 00:10:11.071+00	2024-02-16 00:10:11.071+00	WKpBp0c8F3	HXtEwLBC7f	3	0	3	0	1	\N	\N
VkMTkSiANJ	2024-02-16 00:10:11.28+00	2024-02-16 00:10:11.28+00	jqDYoPT45X	08liHW08uC	1	2	2	2	1	\N	\N
To0uVf8rrV	2024-02-16 00:10:11.491+00	2024-02-16 00:10:11.491+00	RWwLSzreG2	JRi61dUphq	3	3	2	3	1	\N	\N
jsDh2oxdIX	2024-02-16 00:10:11.702+00	2024-02-16 00:10:11.702+00	mQXQWNqxg9	XSK814B37m	4	4	4	1	3	\N	\N
Q3phjPJcZ8	2024-02-16 00:10:11.988+00	2024-02-16 00:10:11.988+00	VshUk7eBeK	eEmewy7hPd	1	1	4	4	1	\N	\N
CbYHd2fx4W	2024-02-16 00:10:12.294+00	2024-02-16 00:10:12.294+00	NjxsGlPeB4	jHqCpA1nWb	3	1	2	3	4	\N	\N
FlazJn0IaU	2024-02-16 00:10:12.507+00	2024-02-16 00:10:12.507+00	adE9nQrDk3	TZsdmscJ2B	1	0	3	2	2	\N	\N
UlBiYkcYs6	2024-02-16 00:10:12.717+00	2024-02-16 00:10:12.717+00	RWwLSzreG2	TpGyMZM9BG	3	4	1	0	3	\N	\N
YN756RrFpY	2024-02-16 00:10:12.929+00	2024-02-16 00:10:12.929+00	sy1HD51LXT	TZsdmscJ2B	3	3	3	0	4	\N	\N
UY0MDiqCRn	2024-02-16 00:10:13.143+00	2024-02-16 00:10:13.143+00	9223vtvaBd	JRi61dUphq	1	4	1	1	2	\N	\N
I4y1xFUrPr	2024-02-16 00:10:13.356+00	2024-02-16 00:10:13.356+00	sHiqaG4iqY	rKyjwoEIRp	2	2	1	0	3	\N	\N
AY5k5yrs5u	2024-02-16 00:10:13.626+00	2024-02-16 00:10:13.626+00	WKpBp0c8F3	0TvWuLoLF5	1	0	2	0	2	\N	\N
Xm6aA9EeBR	2024-02-16 00:10:13.837+00	2024-02-16 00:10:13.837+00	5X202ssb0D	MQfxuw3ERg	4	0	0	0	1	\N	\N
xFWGhYQdnk	2024-02-16 00:10:14.137+00	2024-02-16 00:10:14.137+00	S6wz0lK0bf	TpGyMZM9BG	1	2	3	3	2	\N	\N
fj0bV5DCxX	2024-02-16 00:10:14.446+00	2024-02-16 00:10:14.446+00	9223vtvaBd	14jGmOAXcg	4	3	0	4	0	\N	\N
T6Yz6kqJcQ	2024-02-16 00:10:15.057+00	2024-02-16 00:10:15.057+00	dEqAHvPMXA	u5FXeeOChJ	1	0	1	1	3	\N	\N
5Jm1ajQ2IG	2024-02-16 00:10:15.364+00	2024-02-16 00:10:15.364+00	HtEtaHBVDN	14jGmOAXcg	0	3	1	4	0	\N	\N
bdkdC7JQ4F	2024-02-16 00:10:15.573+00	2024-02-16 00:10:15.573+00	sy1HD51LXT	TCkiw6gTDz	0	3	1	4	2	\N	\N
H4gZ8JDcBg	2024-02-16 00:10:15.78+00	2024-02-16 00:10:15.78+00	ONgyydfVNz	CSvk1ycWXk	0	4	1	3	3	\N	\N
vQIl7sr1at	2024-02-16 00:10:15.993+00	2024-02-16 00:10:15.993+00	mQXQWNqxg9	08liHW08uC	1	3	0	3	2	\N	\N
NRL24uWiN1	2024-02-16 00:10:16.205+00	2024-02-16 00:10:16.205+00	9223vtvaBd	JRi61dUphq	4	1	1	2	3	\N	\N
kUa2rXfHVT	2024-02-16 00:10:16.412+00	2024-02-16 00:10:16.412+00	WKpBp0c8F3	uigc7bJBOJ	1	0	0	0	0	\N	\N
wnSzyE8jEw	2024-02-16 00:10:16.697+00	2024-02-16 00:10:16.697+00	jqDYoPT45X	NBojpORh3G	4	4	2	1	4	\N	\N
NI7RCTuN4s	2024-02-16 00:10:16.907+00	2024-02-16 00:10:16.907+00	HtEtaHBVDN	FYXEfIO1zF	3	0	0	0	0	\N	\N
VkejCYilwB	2024-02-16 00:10:17.115+00	2024-02-16 00:10:17.115+00	ONgyydfVNz	m6g8u0QpTC	4	4	4	0	2	\N	\N
4XJl30jI7A	2024-02-16 00:10:17.414+00	2024-02-16 00:10:17.414+00	sHiqaG4iqY	rT0UCBK1bE	4	0	3	3	3	\N	\N
ME0ZCiSc2d	2024-02-16 00:10:17.719+00	2024-02-16 00:10:17.719+00	sy1HD51LXT	UDXF0qXvDY	3	0	1	3	3	\N	\N
T8Y630XnRM	2024-02-16 00:10:17.926+00	2024-02-16 00:10:17.926+00	5X202ssb0D	jHqCpA1nWb	0	2	2	2	3	\N	\N
IYEGnLT4hd	2024-02-16 00:10:18.231+00	2024-02-16 00:10:18.231+00	5X202ssb0D	lxQA9rtSfY	0	2	3	2	0	\N	\N
hgKLOpewNe	2024-02-16 00:10:18.441+00	2024-02-16 00:10:18.441+00	adE9nQrDk3	fwLPZZ8YQa	3	2	3	3	1	\N	\N
RuQg7PYub3	2024-02-16 00:10:18.653+00	2024-02-16 00:10:18.653+00	adE9nQrDk3	JRi61dUphq	3	1	4	0	0	\N	\N
210CCgxh6u	2024-02-16 00:10:18.862+00	2024-02-16 00:10:18.862+00	jqDYoPT45X	HSEugQ3Ouj	3	4	3	4	2	\N	\N
02NWJUNGIO	2024-02-16 00:10:19.154+00	2024-02-16 00:10:19.154+00	HRhGpJpmb5	8w7i8C3NnT	2	4	4	1	2	\N	\N
QGgyHrIIfi	2024-02-16 00:10:19.463+00	2024-02-16 00:10:19.463+00	iUlyHNFGpG	qZmnAnnPEb	4	0	0	1	1	\N	\N
8oKz00EghF	2024-02-16 00:10:19.677+00	2024-02-16 00:10:19.677+00	R2CLtFh5jU	TpGyMZM9BG	4	0	2	2	4	\N	\N
LP8bzkVxez	2024-02-16 00:10:20.278+00	2024-02-16 00:10:20.278+00	dEqAHvPMXA	bQpy9LEJWn	3	1	0	4	3	\N	\N
cOLH8OoGfo	2024-02-16 00:10:20.49+00	2024-02-16 00:10:20.49+00	HRhGpJpmb5	08liHW08uC	2	2	2	2	4	\N	\N
ZQr6XEGFCr	2024-02-16 00:10:20.704+00	2024-02-16 00:10:20.704+00	iWxl9obi8w	l1Bslv8T2k	2	0	1	4	4	\N	\N
jSqBY3SAgJ	2024-02-16 00:10:20.996+00	2024-02-16 00:10:20.996+00	WKpBp0c8F3	LVYK4mLShP	4	1	0	0	3	\N	\N
qA1M8OAmbJ	2024-02-16 00:10:21.205+00	2024-02-16 00:10:21.205+00	sy1HD51LXT	tCIEnLLcUc	4	3	3	0	3	\N	\N
gZ641bpDmJ	2024-02-16 00:10:21.419+00	2024-02-16 00:10:21.419+00	Otwj7uJwjr	ThMuD3hYRQ	3	4	4	4	0	\N	\N
k967Sc75Bw	2024-02-16 00:10:21.715+00	2024-02-16 00:10:21.715+00	opW2wQ2bZ8	RBRcyltRSC	2	1	3	0	4	\N	\N
kNG4ezci2M	2024-02-16 00:10:22.327+00	2024-02-16 00:10:22.327+00	HtEtaHBVDN	D0A6GLdsDM	1	2	1	2	0	\N	\N
S3aCeaJlzO	2024-02-16 00:10:22.636+00	2024-02-16 00:10:22.636+00	RWwLSzreG2	vwHi602n66	0	0	4	4	0	\N	\N
SCUZhuVj4J	2024-02-16 00:10:22.942+00	2024-02-16 00:10:22.942+00	mAKp5BK7R1	m6g8u0QpTC	4	1	1	0	4	\N	\N
qGyoJe3ly0	2024-02-16 00:10:23.151+00	2024-02-16 00:10:23.151+00	iUlyHNFGpG	vwHi602n66	0	0	0	0	2	\N	\N
7ypf17Ityw	2024-02-16 00:10:23.455+00	2024-02-16 00:10:23.455+00	WKpBp0c8F3	8w7i8C3NnT	2	3	1	0	1	\N	\N
y3Kn8XqiWs	2024-02-16 00:10:23.763+00	2024-02-16 00:10:23.763+00	iUlyHNFGpG	MQfxuw3ERg	1	0	4	3	3	\N	\N
hl2Na5Mt04	2024-02-16 00:10:23.978+00	2024-02-16 00:10:23.978+00	VshUk7eBeK	OQWu2bnHeC	4	2	0	4	3	\N	\N
qIBPIKxAsf	2024-02-16 00:10:24.276+00	2024-02-16 00:10:24.276+00	R2CLtFh5jU	C7II8dYRPY	1	4	3	0	2	\N	\N
PGYaSOOLMi	2024-02-16 00:10:24.487+00	2024-02-16 00:10:24.487+00	WKpBp0c8F3	JRi61dUphq	0	4	1	1	2	\N	\N
o34hzC0Y0O	2024-02-16 00:10:24.7+00	2024-02-16 00:10:24.7+00	AsrLUQwxI9	EmIUBFwx0Z	0	1	0	0	4	\N	\N
NYQoyp1zea	2024-02-16 00:10:24.911+00	2024-02-16 00:10:24.911+00	ONgyydfVNz	C7II8dYRPY	0	3	2	3	2	\N	\N
DalyYdePTG	2024-02-16 00:10:25.125+00	2024-02-16 00:10:25.125+00	HRhGpJpmb5	qP3EdIVzfB	2	1	3	4	2	\N	\N
EpgsDKtNuc	2024-02-16 00:10:25.339+00	2024-02-16 00:10:25.339+00	5nv19u6KJ2	TZsdmscJ2B	4	0	1	1	3	\N	\N
eNdBJuJl7r	2024-02-16 00:10:25.553+00	2024-02-16 00:10:25.553+00	opW2wQ2bZ8	BMLzFMvIT6	0	3	0	0	2	\N	\N
HZayJiVCtV	2024-02-16 00:10:26.219+00	2024-02-16 00:10:26.219+00	ONgyydfVNz	fxvABtKCPT	0	2	0	3	4	\N	\N
wFdfxNcr9l	2024-02-16 00:10:26.427+00	2024-02-16 00:10:26.427+00	jqDYoPT45X	6KvFK8yy1q	2	3	3	0	2	\N	\N
08NmmhVo4r	2024-02-16 00:10:26.635+00	2024-02-16 00:10:26.635+00	dEqAHvPMXA	VK3vnSxIy8	4	1	1	4	4	\N	\N
a7Fp2EDPst	2024-02-16 00:10:26.844+00	2024-02-16 00:10:26.844+00	1as6rMOzjQ	lEPdiO1EDi	1	2	3	3	2	\N	\N
U9rAac9TCU	2024-02-16 00:10:27.14+00	2024-02-16 00:10:27.14+00	I5RzFRcQ7G	fKTSJPdUi9	4	4	0	3	0	\N	\N
iTQmrEi3BA	2024-02-16 00:10:27.351+00	2024-02-16 00:10:27.351+00	5X202ssb0D	IybX0eBoO3	4	1	4	2	1	\N	\N
bsHanXuCi4	2024-02-16 00:10:27.654+00	2024-02-16 00:10:27.654+00	adE9nQrDk3	o4VD4BWwDt	3	1	1	0	0	\N	\N
gdwRBb9FT1	2024-02-16 00:10:27.855+00	2024-02-16 00:10:27.855+00	9223vtvaBd	NY6RE1qgWu	3	4	0	4	3	\N	\N
Aca2nLWIum	2024-02-16 00:10:28.065+00	2024-02-16 00:10:28.065+00	adE9nQrDk3	LVYK4mLShP	1	4	3	4	2	\N	\N
KmET6VGLb8	2024-02-16 00:10:28.269+00	2024-02-16 00:10:28.269+00	SFAISec8QF	HLIPwAqO2R	1	0	0	1	4	\N	\N
myggwMvMbR	2024-02-16 00:10:28.477+00	2024-02-16 00:10:28.477+00	dZKm0wOhYa	XSK814B37m	0	3	2	3	4	\N	\N
8cWIZ8ax1v	2024-02-16 00:10:29.082+00	2024-02-16 00:10:29.082+00	sHiqaG4iqY	yvUod6yLDt	2	3	1	2	1	\N	\N
CvC8ecKROF	2024-02-16 00:10:29.29+00	2024-02-16 00:10:29.29+00	5X202ssb0D	E2hBZzDsjO	4	1	4	2	0	\N	\N
sxKc4cqK7C	2024-02-16 00:10:29.901+00	2024-02-16 00:10:29.901+00	sy1HD51LXT	o4VD4BWwDt	0	4	3	0	2	\N	\N
8dTaX28P0z	2024-02-16 00:10:30.108+00	2024-02-16 00:10:30.108+00	1as6rMOzjQ	oABNR2FF6S	1	2	4	2	3	\N	\N
tpvmXJtnOf	2024-02-16 00:10:30.415+00	2024-02-16 00:10:30.415+00	dEqAHvPMXA	0TvWuLoLF5	4	2	2	1	3	\N	\N
HFkAILksHa	2024-02-16 00:10:30.621+00	2024-02-16 00:10:30.621+00	I5RzFRcQ7G	PF8w2gMAdi	2	4	3	3	2	\N	\N
sKbWODaVdk	2024-02-16 00:10:30.828+00	2024-02-16 00:10:30.828+00	jqDYoPT45X	cFtamPA0zH	2	4	1	0	1	\N	\N
85DVP9fGHT	2024-02-16 00:10:31.03+00	2024-02-16 00:10:31.03+00	VshUk7eBeK	WnUBBkiDjE	4	2	1	1	4	\N	\N
GV2x6bJhj2	2024-02-16 00:10:31.227+00	2024-02-16 00:10:31.227+00	I5RzFRcQ7G	C7II8dYRPY	1	0	1	2	2	\N	\N
2fOyyhIA7L	2024-02-16 00:10:31.432+00	2024-02-16 00:10:31.432+00	mQXQWNqxg9	uABtFsJhJc	1	2	1	1	1	\N	\N
4TR1DdkF6q	2024-02-16 00:10:31.638+00	2024-02-16 00:10:31.638+00	RWwLSzreG2	LVYK4mLShP	1	2	2	4	1	\N	\N
PCzrmt5ThF	2024-02-16 00:10:31.845+00	2024-02-16 00:10:31.845+00	HtEtaHBVDN	LVYK4mLShP	4	4	1	2	3	\N	\N
CB50SjQkKG	2024-02-16 00:10:32.158+00	2024-02-16 00:10:32.158+00	ONgyydfVNz	y4RkaDbkec	3	0	2	4	4	\N	\N
8n8VhsCRJt	2024-02-16 00:10:32.466+00	2024-02-16 00:10:32.466+00	opW2wQ2bZ8	C7II8dYRPY	1	0	3	1	0	\N	\N
sHqLkOA0j0	2024-02-16 00:10:32.679+00	2024-02-16 00:10:32.679+00	sy1HD51LXT	INeptnSdJC	4	4	3	3	2	\N	\N
5cxp5tZZN9	2024-02-16 00:10:32.976+00	2024-02-16 00:10:32.976+00	SFAISec8QF	rT0UCBK1bE	3	1	2	3	2	\N	\N
wroEDRBjBr	2024-02-16 00:10:33.186+00	2024-02-16 00:10:33.186+00	9223vtvaBd	EmIUBFwx0Z	1	2	4	1	0	\N	\N
JB6BouG7Qb	2024-02-16 00:10:33.489+00	2024-02-16 00:10:33.489+00	dZKm0wOhYa	rKyjwoEIRp	0	0	1	4	3	\N	\N
T8bEbCe7UX	2024-02-16 00:10:33.7+00	2024-02-16 00:10:33.7+00	Otwj7uJwjr	na5crB8ED1	0	1	4	1	1	\N	\N
iNGCColQHJ	2024-02-16 00:10:33.91+00	2024-02-16 00:10:33.91+00	HRhGpJpmb5	C7II8dYRPY	0	2	4	0	4	\N	\N
OD67Zr0QmG	2024-02-16 00:10:34.121+00	2024-02-16 00:10:34.121+00	sHiqaG4iqY	14jGmOAXcg	1	4	3	2	2	\N	\N
Lct2KyEB9F	2024-02-16 00:10:34.332+00	2024-02-16 00:10:34.332+00	SFAISec8QF	qZmnAnnPEb	2	1	1	3	3	\N	\N
G7oRY2bFfW	2024-02-16 00:10:34.544+00	2024-02-16 00:10:34.544+00	ONgyydfVNz	C7II8dYRPY	1	0	1	0	3	\N	\N
MTMqcLKapm	2024-02-16 00:10:34.757+00	2024-02-16 00:10:34.757+00	AsrLUQwxI9	mMYg4cyd5R	0	1	4	4	2	\N	\N
BnP57EHeHp	2024-02-16 00:10:35.029+00	2024-02-16 00:10:35.029+00	RWwLSzreG2	PF8w2gMAdi	4	0	3	2	2	\N	\N
E0eyj0WlSt	2024-02-16 00:10:35.334+00	2024-02-16 00:10:35.334+00	SFAISec8QF	fwLPZZ8YQa	0	1	3	1	0	\N	\N
HCjjzQZWgZ	2024-02-16 00:10:35.545+00	2024-02-16 00:10:35.545+00	jqDYoPT45X	BMLzFMvIT6	3	3	0	3	2	\N	\N
r0IXOzVQdz	2024-02-16 00:10:35.757+00	2024-02-16 00:10:35.757+00	SFAISec8QF	G0uU7KQLEt	3	1	1	2	3	\N	\N
pHjvkHK1YQ	2024-02-16 00:10:36.355+00	2024-02-16 00:10:36.355+00	sHiqaG4iqY	fxvABtKCPT	0	2	4	2	2	\N	\N
CqJDx7pgxB	2024-02-16 00:10:36.566+00	2024-02-16 00:10:36.566+00	opW2wQ2bZ8	3u4B9V4l5K	1	2	3	0	0	\N	\N
SQydKELcsR	2024-02-16 00:10:36.773+00	2024-02-16 00:10:36.773+00	WKpBp0c8F3	lEPdiO1EDi	1	0	3	1	4	\N	\N
agALaAUA2D	2024-02-16 00:10:37.075+00	2024-02-16 00:10:37.075+00	sHiqaG4iqY	qP3EdIVzfB	4	3	0	1	2	\N	\N
nirim8lriB	2024-02-16 00:10:37.288+00	2024-02-16 00:10:37.288+00	ONgyydfVNz	KCsJ4XR6Dn	3	3	0	4	3	\N	\N
OkuwUSFIKt	2024-02-16 00:10:37.501+00	2024-02-16 00:10:37.501+00	dZKm0wOhYa	H40ivltLwZ	1	4	4	0	1	\N	\N
BIG7cgDjh7	2024-02-16 00:10:37.712+00	2024-02-16 00:10:37.712+00	5nv19u6KJ2	JLhF4VuByh	2	2	3	1	3	\N	\N
u1GmSS37Cu	2024-02-16 00:10:37.921+00	2024-02-16 00:10:37.921+00	RWwLSzreG2	JRi61dUphq	3	4	4	0	4	\N	\N
UkNzk8dftE	2024-02-16 00:10:38.134+00	2024-02-16 00:10:38.134+00	HtEtaHBVDN	XwszrNEEEj	1	4	3	4	2	\N	\N
MuwJ70F2h7	2024-02-16 00:10:38.348+00	2024-02-16 00:10:38.348+00	I5RzFRcQ7G	WBFeKac0OO	1	3	3	3	1	\N	\N
VrGt9g7EpH	2024-02-16 00:10:38.611+00	2024-02-16 00:10:38.611+00	9223vtvaBd	RkhjIQJgou	0	3	0	2	0	\N	\N
ljrHWZOoMx	2024-02-16 00:10:38.919+00	2024-02-16 00:10:38.919+00	WKpBp0c8F3	TZsdmscJ2B	1	0	3	1	3	\N	\N
wHtkJClMr5	2024-02-16 00:10:39.153+00	2024-02-16 00:10:39.153+00	NjxsGlPeB4	Pa0qBO2rzK	3	2	2	4	1	\N	\N
JNCO6kECdR	2024-02-16 00:10:39.422+00	2024-02-16 00:10:39.422+00	dZKm0wOhYa	cTIjuPjyIa	3	4	4	4	0	\N	\N
8fRbR2wDaO	2024-02-16 00:10:39.632+00	2024-02-16 00:10:39.632+00	AsrLUQwxI9	XSK814B37m	1	0	0	3	1	\N	\N
SUSuzHVCGQ	2024-02-16 00:10:39.842+00	2024-02-16 00:10:39.842+00	iWxl9obi8w	yvUod6yLDt	4	1	0	4	1	\N	\N
jE6EPdYZJ7	2024-02-16 00:10:40.147+00	2024-02-16 00:10:40.147+00	mAKp5BK7R1	VK3vnSxIy8	3	0	2	2	1	\N	\N
9Pyi3lXQvK	2024-02-16 00:10:40.758+00	2024-02-16 00:10:40.758+00	RWwLSzreG2	fwLPZZ8YQa	0	3	0	3	1	\N	\N
DnjADMQjfo	2024-02-16 00:10:40.969+00	2024-02-16 00:10:40.969+00	9223vtvaBd	cmxBcanww9	2	2	4	0	4	\N	\N
qKiHn7w6lz	2024-02-16 00:10:41.177+00	2024-02-16 00:10:41.177+00	WKpBp0c8F3	na5crB8ED1	0	2	2	0	0	\N	\N
uLBuPWeYLL	2024-02-16 00:10:41.385+00	2024-02-16 00:10:41.385+00	iWxl9obi8w	MQfxuw3ERg	2	4	0	3	1	\N	\N
2nt2OWKe6u	2024-02-16 00:10:41.989+00	2024-02-16 00:10:41.989+00	sHiqaG4iqY	NY6RE1qgWu	0	1	2	2	0	\N	\N
SE4N8cYdds	2024-02-16 00:10:42.196+00	2024-02-16 00:10:42.196+00	adE9nQrDk3	BMLzFMvIT6	1	4	2	0	4	\N	\N
ApJABgnHDC	2024-02-16 00:10:42.805+00	2024-02-16 00:10:42.805+00	iUlyHNFGpG	8w7i8C3NnT	4	4	0	0	0	\N	\N
wuWe4bYndj	2024-02-16 00:10:43.109+00	2024-02-16 00:10:43.109+00	HRhGpJpmb5	OQWu2bnHeC	0	1	0	0	4	\N	\N
uZ7VEvxe9u	2024-02-16 00:10:43.316+00	2024-02-16 00:10:43.316+00	mAKp5BK7R1	bQpy9LEJWn	1	1	3	0	0	\N	\N
EuFKgOTuiB	2024-02-16 00:10:43.529+00	2024-02-16 00:10:43.529+00	S6wz0lK0bf	D0A6GLdsDM	3	4	1	3	3	\N	\N
dq53l8ep8E	2024-02-16 00:10:43.738+00	2024-02-16 00:10:43.738+00	ONgyydfVNz	fKTSJPdUi9	3	4	1	2	2	\N	\N
Aqc9m3Psc7	2024-02-16 00:10:44.036+00	2024-02-16 00:10:44.036+00	dZKm0wOhYa	qEQ9tmLyW9	2	4	4	0	4	\N	\N
1DpXeDA0G8	2024-02-16 00:10:44.245+00	2024-02-16 00:10:44.245+00	sy1HD51LXT	HLIPwAqO2R	3	0	2	3	4	\N	\N
o7Fq6enaPd	2024-02-16 00:10:44.548+00	2024-02-16 00:10:44.548+00	9223vtvaBd	6Fo67rhTSP	2	4	1	2	3	\N	\N
7FmXtxv0jm	2024-02-16 00:10:44.759+00	2024-02-16 00:10:44.759+00	mAKp5BK7R1	u5FXeeOChJ	4	0	3	1	0	\N	\N
ll7Y6VgTDH	2024-02-16 00:10:44.969+00	2024-02-16 00:10:44.969+00	dZKm0wOhYa	WnUBBkiDjE	0	3	1	3	1	\N	\N
30YbwIzIEW	2024-02-16 00:10:45.18+00	2024-02-16 00:10:45.18+00	R2CLtFh5jU	XSK814B37m	3	2	4	1	4	\N	\N
a0OurkqaEi	2024-02-16 00:10:45.471+00	2024-02-16 00:10:45.471+00	HRhGpJpmb5	o90lhsZ7FK	1	3	3	2	3	\N	\N
jGzkx2CFA1	2024-02-16 00:10:45.683+00	2024-02-16 00:10:45.683+00	RWwLSzreG2	IybX0eBoO3	1	2	0	3	4	\N	\N
HUxSEVOmuM	2024-02-16 00:10:45.896+00	2024-02-16 00:10:45.896+00	S6wz0lK0bf	CSvk1ycWXk	2	2	0	2	3	\N	\N
bZpVxYxM9I	2024-02-16 00:10:46.099+00	2024-02-16 00:10:46.099+00	dZKm0wOhYa	WHvlAGgj6c	2	2	0	3	3	\N	\N
EPtd7MRrUO	2024-02-16 00:10:46.698+00	2024-02-16 00:10:46.698+00	1as6rMOzjQ	l1Bslv8T2k	0	3	1	3	1	\N	\N
QxJmTkwQql	2024-02-16 00:10:46.908+00	2024-02-16 00:10:46.908+00	9223vtvaBd	TpGyMZM9BG	2	2	4	1	3	\N	\N
9JpC9p3KJN	2024-02-16 00:10:47.21+00	2024-02-16 00:10:47.21+00	sy1HD51LXT	89xRG1afNi	0	3	1	1	1	\N	\N
8PwCrzsRcb	2024-02-16 00:10:47.824+00	2024-02-16 00:10:47.824+00	sy1HD51LXT	C7II8dYRPY	3	1	3	0	4	\N	\N
XtiQOdKhSc	2024-02-16 00:10:48.436+00	2024-02-16 00:10:48.436+00	HtEtaHBVDN	vwHi602n66	2	3	3	3	0	\N	\N
Yd2WahRxOb	2024-02-16 00:10:48.643+00	2024-02-16 00:10:48.643+00	5X202ssb0D	bQ0JOk10eL	4	1	2	4	1	\N	\N
jPnkSfz9GL	2024-02-16 00:10:48.854+00	2024-02-16 00:10:48.854+00	opW2wQ2bZ8	FJOTueDfs2	0	4	1	0	3	\N	\N
4FRsQHoM0W	2024-02-16 00:10:49.157+00	2024-02-16 00:10:49.157+00	iWxl9obi8w	P9sBFomftT	3	3	1	0	4	\N	\N
gEzJZhWT77	2024-02-16 00:10:49.46+00	2024-02-16 00:10:49.46+00	iWxl9obi8w	3P6kmNoY1F	2	3	3	1	2	\N	\N
D4LVxIwzUG	2024-02-16 00:10:49.661+00	2024-02-16 00:10:49.661+00	sy1HD51LXT	y4RkaDbkec	1	0	3	3	1	\N	\N
ihPUfXqpNl	2024-02-16 00:10:50.282+00	2024-02-16 00:10:50.282+00	iWxl9obi8w	ThMuD3hYRQ	3	3	4	1	3	\N	\N
oWQyOhNFVt	2024-02-16 00:10:50.895+00	2024-02-16 00:10:50.895+00	WKpBp0c8F3	LVYK4mLShP	2	2	3	1	3	\N	\N
BQiBjCUgzH	2024-02-16 00:10:51.507+00	2024-02-16 00:10:51.507+00	9223vtvaBd	lEPdiO1EDi	2	0	4	0	3	\N	\N
hcsk2mLDZd	2024-02-16 00:10:51.818+00	2024-02-16 00:10:51.818+00	dZKm0wOhYa	vwHi602n66	3	0	3	3	1	\N	\N
KZB9XSe4pL	2024-02-16 00:10:52.027+00	2024-02-16 00:10:52.027+00	sy1HD51LXT	jjVdtithcD	2	0	3	4	4	\N	\N
EMTVtkzT4c	2024-02-16 00:10:52.235+00	2024-02-16 00:10:52.235+00	jqDYoPT45X	qEQ9tmLyW9	1	2	0	4	1	\N	\N
XkX9FDk8wG	2024-02-16 00:10:52.439+00	2024-02-16 00:10:52.439+00	9223vtvaBd	lEPdiO1EDi	2	4	4	3	3	\N	\N
YzZw2opsdu	2024-02-16 00:10:52.739+00	2024-02-16 00:10:52.739+00	HRhGpJpmb5	RkhjIQJgou	0	0	1	3	2	\N	\N
QrpSP9yTEW	2024-02-16 00:10:52.947+00	2024-02-16 00:10:52.947+00	NjxsGlPeB4	jHqCpA1nWb	3	4	0	3	1	\N	\N
2E3Uhp5zuz	2024-02-16 00:10:53.252+00	2024-02-16 00:10:53.252+00	ONgyydfVNz	axyV0Fu7pm	1	4	3	3	1	\N	\N
2SiyNgdGCh	2024-02-16 00:10:53.864+00	2024-02-16 00:10:53.864+00	WKpBp0c8F3	IEqTHcohpJ	4	0	4	2	4	\N	\N
1InFiJcq3r	2024-02-16 00:10:54.478+00	2024-02-16 00:10:54.478+00	mQXQWNqxg9	yvUod6yLDt	0	4	3	2	2	\N	\N
IJ2V4OiBhS	2024-02-16 00:10:54.686+00	2024-02-16 00:10:54.686+00	1as6rMOzjQ	LgJuu5ABe5	0	1	4	4	4	\N	\N
J9IyEDBXrb	2024-02-16 00:10:54.991+00	2024-02-16 00:10:54.991+00	AsrLUQwxI9	Pja6n3yaWZ	4	4	1	3	4	\N	\N
ZdI7nYS6mH	2024-02-16 00:10:55.197+00	2024-02-16 00:10:55.197+00	ONgyydfVNz	RBRcyltRSC	2	1	3	1	2	\N	\N
TgmkSXPy09	2024-02-16 00:10:55.402+00	2024-02-16 00:10:55.402+00	SFAISec8QF	EmIUBFwx0Z	3	2	2	3	4	\N	\N
VAsYO4V7Fr	2024-02-16 00:10:55.609+00	2024-02-16 00:10:55.609+00	5nv19u6KJ2	M0tHrt1GgV	3	0	4	2	0	\N	\N
B2swr9gBgj	2024-02-16 00:10:55.815+00	2024-02-16 00:10:55.815+00	jqDYoPT45X	INeptnSdJC	1	2	3	3	2	\N	\N
emEE50A1xH	2024-02-16 00:10:56.026+00	2024-02-16 00:10:56.026+00	sy1HD51LXT	9GF3y7LmHV	4	4	4	1	2	\N	\N
splSW7HnpX	2024-02-16 00:10:56.232+00	2024-02-16 00:10:56.232+00	iWxl9obi8w	LgJuu5ABe5	2	3	3	1	2	\N	\N
8GgjivxAp8	2024-02-16 00:10:56.438+00	2024-02-16 00:10:56.438+00	AsrLUQwxI9	C7II8dYRPY	3	2	4	0	2	\N	\N
hXBhuXX6rV	2024-02-16 00:10:56.65+00	2024-02-16 00:10:56.65+00	iWxl9obi8w	NBojpORh3G	2	1	3	2	1	\N	\N
8Ptrp7NT9Y	2024-02-16 00:10:57.244+00	2024-02-16 00:10:57.244+00	I5RzFRcQ7G	NY6RE1qgWu	2	1	2	4	4	\N	\N
H3RXvp63uH	2024-02-16 00:10:57.552+00	2024-02-16 00:10:57.552+00	NjxsGlPeB4	RkhjIQJgou	2	1	2	4	4	\N	\N
xWD75XFqOr	2024-02-16 00:10:57.76+00	2024-02-16 00:10:57.76+00	adE9nQrDk3	08liHW08uC	1	0	0	3	2	\N	\N
8fAzpQHm47	2024-02-16 00:10:57.968+00	2024-02-16 00:10:57.968+00	VshUk7eBeK	bi1IivsuUB	1	1	1	3	1	\N	\N
iUS7utXEvx	2024-02-16 00:10:58.269+00	2024-02-16 00:10:58.269+00	iWxl9obi8w	XpUyRlB6FI	4	0	1	4	0	\N	\N
3WqiZnzHIB	2024-02-16 00:10:58.481+00	2024-02-16 00:10:58.481+00	jqDYoPT45X	NY6RE1qgWu	2	3	0	4	4	\N	\N
B0g3gZq4ov	2024-02-16 00:10:58.69+00	2024-02-16 00:10:58.69+00	mQXQWNqxg9	JLhF4VuByh	3	1	3	2	3	\N	\N
0Dy27AajBA	2024-02-16 00:10:58.9+00	2024-02-16 00:10:58.9+00	mQXQWNqxg9	l1Bslv8T2k	4	3	3	0	4	\N	\N
t8zDMUH04I	2024-02-16 00:10:59.191+00	2024-02-16 00:10:59.191+00	sy1HD51LXT	TCkiw6gTDz	3	1	3	4	1	\N	\N
O3jmlA53Ge	2024-02-16 00:10:59.5+00	2024-02-16 00:10:59.5+00	ONgyydfVNz	rT0UCBK1bE	0	2	2	1	2	\N	\N
kXQeWODC9I	2024-02-16 00:10:59.804+00	2024-02-16 00:10:59.804+00	adE9nQrDk3	NBojpORh3G	2	2	4	3	2	\N	\N
ZBXPpPFgmx	2024-02-16 00:11:00.015+00	2024-02-16 00:11:00.015+00	sHiqaG4iqY	rT0UCBK1bE	4	2	3	0	0	\N	\N
yiEyrDaR4B	2024-02-16 00:11:00.228+00	2024-02-16 00:11:00.228+00	AsrLUQwxI9	na5crB8ED1	4	0	1	0	0	\N	\N
qxZGGBIhQv	2024-02-16 00:11:00.441+00	2024-02-16 00:11:00.441+00	sHiqaG4iqY	PF8w2gMAdi	3	3	1	2	0	\N	\N
eQJ2AgeCOa	2024-02-16 00:11:00.653+00	2024-02-16 00:11:00.653+00	sHiqaG4iqY	6KvFK8yy1q	2	0	2	0	4	\N	\N
qRYMJWsC9Z	2024-02-16 00:11:00.932+00	2024-02-16 00:11:00.932+00	5nv19u6KJ2	j0dWqP2C2A	2	0	0	1	4	\N	\N
Chc7usgJQG	2024-02-16 00:11:01.24+00	2024-02-16 00:11:01.24+00	S6wz0lK0bf	bQpy9LEJWn	4	3	4	1	4	\N	\N
Ka3AYjHlEI	2024-02-16 00:11:01.449+00	2024-02-16 00:11:01.449+00	S6wz0lK0bf	EmIUBFwx0Z	3	4	1	0	4	\N	\N
bNDMhPdfI4	2024-02-16 00:11:01.751+00	2024-02-16 00:11:01.751+00	WKpBp0c8F3	fKTSJPdUi9	3	4	2	3	1	\N	\N
2imkziNenA	2024-02-16 00:11:01.959+00	2024-02-16 00:11:01.959+00	1as6rMOzjQ	H40ivltLwZ	2	3	2	1	4	\N	\N
t4Eq75SZTH	2024-02-16 00:11:02.168+00	2024-02-16 00:11:02.168+00	5X202ssb0D	BMLzFMvIT6	4	3	2	0	2	\N	\N
zeib2hIBui	2024-02-16 00:11:02.467+00	2024-02-16 00:11:02.467+00	5nv19u6KJ2	fwLPZZ8YQa	4	3	4	0	1	\N	\N
Kca1eXF3cF	2024-02-16 00:11:02.679+00	2024-02-16 00:11:02.679+00	HtEtaHBVDN	bi1IivsuUB	1	3	2	0	3	\N	\N
zzTZW4eJ2A	2024-02-16 00:11:02.981+00	2024-02-16 00:11:02.981+00	iUlyHNFGpG	m6g8u0QpTC	3	4	0	0	3	\N	\N
FDVRTcrGbi	2024-02-16 00:11:03.192+00	2024-02-16 00:11:03.192+00	Otwj7uJwjr	PF8w2gMAdi	0	2	2	4	4	\N	\N
TOjvB8NBRK	2024-02-16 00:11:03.402+00	2024-02-16 00:11:03.402+00	NjxsGlPeB4	HSEugQ3Ouj	0	4	0	2	0	\N	\N
5Rjt21bGFB	2024-02-16 00:11:03.699+00	2024-02-16 00:11:03.699+00	WKpBp0c8F3	NBojpORh3G	4	1	2	0	2	\N	\N
D8e43qaPVD	2024-02-16 00:11:03.911+00	2024-02-16 00:11:03.911+00	AsrLUQwxI9	l1Bslv8T2k	0	1	1	1	0	\N	\N
CWDFbXLXhb	2024-02-16 00:11:04.358+00	2024-02-16 00:11:04.358+00	SFAISec8QF	NY6RE1qgWu	0	2	2	3	1	\N	\N
QNF7Y7rZnZ	2024-02-16 00:11:04.569+00	2024-02-16 00:11:04.569+00	R2CLtFh5jU	8w7i8C3NnT	1	3	4	0	3	\N	\N
rTdsXBYU6Q	2024-02-16 00:11:05.332+00	2024-02-16 00:11:05.332+00	5nv19u6KJ2	e037qpAih3	3	4	2	3	2	\N	\N
H0LL3eVwnZ	2024-02-16 00:11:05.539+00	2024-02-16 00:11:05.539+00	dEqAHvPMXA	bi1IivsuUB	4	2	2	1	3	\N	\N
M3h9GYZeNJ	2024-02-16 00:11:05.751+00	2024-02-16 00:11:05.751+00	9223vtvaBd	Oahm9sOn1y	1	4	1	2	1	\N	\N
OA9nFXpg6S	2024-02-16 00:11:05.963+00	2024-02-16 00:11:05.963+00	dZKm0wOhYa	6KvFK8yy1q	4	3	1	0	4	\N	\N
GDjnuQUyfC	2024-02-16 00:11:06.17+00	2024-02-16 00:11:06.17+00	dZKm0wOhYa	OQWu2bnHeC	1	1	1	2	0	\N	\N
Jutnfao8K5	2024-02-16 00:11:06.372+00	2024-02-16 00:11:06.372+00	mQXQWNqxg9	C7II8dYRPY	3	0	1	3	0	\N	\N
XNB9nxzKRa	2024-02-16 00:11:06.666+00	2024-02-16 00:11:06.666+00	jqDYoPT45X	WHvlAGgj6c	4	2	3	1	3	\N	\N
K6H5lneCGM	2024-02-16 00:11:06.875+00	2024-02-16 00:11:06.875+00	jqDYoPT45X	tCIEnLLcUc	4	0	4	4	2	\N	\N
1RevYafflA	2024-02-16 00:11:07.083+00	2024-02-16 00:11:07.083+00	5X202ssb0D	IEqTHcohpJ	3	2	2	2	1	\N	\N
OBYiplw6VU	2024-02-16 00:11:07.294+00	2024-02-16 00:11:07.294+00	mAKp5BK7R1	0TvWuLoLF5	2	0	2	2	4	\N	\N
CYpt8cgBsM	2024-02-16 00:11:07.506+00	2024-02-16 00:11:07.506+00	5X202ssb0D	E2hBZzDsjO	2	0	3	4	3	\N	\N
gqAeFtnZS3	2024-02-16 00:11:07.722+00	2024-02-16 00:11:07.722+00	ONgyydfVNz	XpUyRlB6FI	1	4	0	0	2	\N	\N
dBe9cD5cfz	2024-02-16 00:11:07.939+00	2024-02-16 00:11:07.939+00	sy1HD51LXT	rT0UCBK1bE	0	3	0	4	1	\N	\N
nGTriFxiGF	2024-02-16 00:11:08.153+00	2024-02-16 00:11:08.153+00	WKpBp0c8F3	MQfxuw3ERg	2	1	1	2	0	\N	\N
6qxfwhluCZ	2024-02-16 00:11:08.815+00	2024-02-16 00:11:08.815+00	mAKp5BK7R1	VK3vnSxIy8	1	4	1	1	2	\N	\N
uhhvcjVGTA	2024-02-16 00:11:09.025+00	2024-02-16 00:11:09.025+00	dEqAHvPMXA	XpUyRlB6FI	0	3	1	2	3	\N	\N
sydH0x0Vww	2024-02-16 00:11:09.235+00	2024-02-16 00:11:09.235+00	S6wz0lK0bf	ThMuD3hYRQ	0	1	2	0	2	\N	\N
Ir8PdlY1bX	2024-02-16 00:11:09.443+00	2024-02-16 00:11:09.443+00	adE9nQrDk3	lEPdiO1EDi	0	1	2	3	1	\N	\N
FZMRBvJtY7	2024-02-16 00:11:09.793+00	2024-02-16 00:11:09.793+00	opW2wQ2bZ8	H40ivltLwZ	0	4	4	0	2	\N	\N
Q2ksL1tMOx	2024-02-16 00:11:09.994+00	2024-02-16 00:11:09.994+00	9223vtvaBd	BMLzFMvIT6	0	4	4	2	1	\N	\N
eH9ZyeY0EG	2024-02-16 00:11:10.202+00	2024-02-16 00:11:10.202+00	HRhGpJpmb5	vwHi602n66	0	1	4	0	3	\N	\N
sGAAvjjK3G	2024-02-16 00:11:10.414+00	2024-02-16 00:11:10.414+00	RWwLSzreG2	rKyjwoEIRp	4	4	4	3	4	\N	\N
n14IEKH3LG	2024-02-16 00:11:10.631+00	2024-02-16 00:11:10.631+00	HRhGpJpmb5	E2hBZzDsjO	2	4	1	0	1	\N	\N
wccymUnf1t	2024-02-16 00:11:11.273+00	2024-02-16 00:11:11.273+00	I5RzFRcQ7G	m8hjjLVdPS	4	2	3	4	1	\N	\N
HMDeRWFCH3	2024-02-16 00:11:11.483+00	2024-02-16 00:11:11.483+00	AsrLUQwxI9	bi1IivsuUB	0	3	4	0	3	\N	\N
LFWCqqqs8n	2024-02-16 00:11:11.692+00	2024-02-16 00:11:11.692+00	R2CLtFh5jU	qP3EdIVzfB	2	1	3	4	0	\N	\N
o7oKuUYHuH	2024-02-16 00:11:11.902+00	2024-02-16 00:11:11.902+00	9223vtvaBd	yvUod6yLDt	3	0	1	1	1	\N	\N
vfuqjCrAPz	2024-02-16 00:11:12.114+00	2024-02-16 00:11:12.114+00	RWwLSzreG2	eEmewy7hPd	4	2	0	3	0	\N	\N
0CevAfJ6zX	2024-02-16 00:11:12.4+00	2024-02-16 00:11:12.4+00	HtEtaHBVDN	EmIUBFwx0Z	3	0	4	4	3	\N	\N
FjFingqXqk	2024-02-16 00:11:12.608+00	2024-02-16 00:11:12.608+00	dZKm0wOhYa	o90lhsZ7FK	1	2	1	2	4	\N	\N
5esxidaZBX	2024-02-16 00:11:12.817+00	2024-02-16 00:11:12.817+00	HtEtaHBVDN	fwLPZZ8YQa	0	3	2	3	2	\N	\N
DIaPq2Cd5Q	2024-02-16 00:11:13.032+00	2024-02-16 00:11:13.032+00	iWxl9obi8w	INeptnSdJC	3	2	1	2	1	\N	\N
IBLwKBEEfA	2024-02-16 00:11:13.323+00	2024-02-16 00:11:13.323+00	HRhGpJpmb5	9GF3y7LmHV	0	4	0	4	4	\N	\N
kf6bUEK799	2024-02-16 00:11:13.537+00	2024-02-16 00:11:13.537+00	HRhGpJpmb5	jHqCpA1nWb	4	4	1	2	4	\N	\N
LUsicmvHrJ	2024-02-16 00:11:13.752+00	2024-02-16 00:11:13.752+00	VshUk7eBeK	3u4B9V4l5K	1	4	4	4	1	\N	\N
BVXYBaP5P3	2024-02-16 00:11:13.965+00	2024-02-16 00:11:13.965+00	WKpBp0c8F3	axyV0Fu7pm	3	1	0	3	4	\N	\N
4Y3HlzM7RT	2024-02-16 00:11:14.245+00	2024-02-16 00:11:14.245+00	mAKp5BK7R1	RBRcyltRSC	0	3	2	1	0	\N	\N
g8QWb7zT5g	2024-02-16 00:11:14.453+00	2024-02-16 00:11:14.453+00	R2CLtFh5jU	LgJuu5ABe5	4	3	2	2	4	\N	\N
Ft1EbjeDlA	2024-02-16 00:11:14.667+00	2024-02-16 00:11:14.667+00	sHiqaG4iqY	MQfxuw3ERg	3	4	0	1	0	\N	\N
ckbirjJ6VR	2024-02-16 00:11:14.962+00	2024-02-16 00:11:14.962+00	R2CLtFh5jU	WHvlAGgj6c	2	4	2	1	1	\N	\N
sVYyE1p3at	2024-02-16 00:11:15.572+00	2024-02-16 00:11:15.572+00	5X202ssb0D	lEPdiO1EDi	3	4	2	2	3	\N	\N
MY1EQcs9VE	2024-02-16 00:11:15.777+00	2024-02-16 00:11:15.777+00	VshUk7eBeK	Oahm9sOn1y	2	3	1	1	1	\N	\N
mCXWIQRBgq	2024-02-16 00:11:16.393+00	2024-02-16 00:11:16.393+00	5X202ssb0D	fxvABtKCPT	2	1	3	1	2	\N	\N
crMi7KwzFT	2024-02-16 00:11:16.699+00	2024-02-16 00:11:16.699+00	opW2wQ2bZ8	3u4B9V4l5K	1	2	3	3	4	\N	\N
ygt39L0P8O	2024-02-16 00:11:17.007+00	2024-02-16 00:11:17.007+00	opW2wQ2bZ8	89xRG1afNi	4	2	3	3	3	\N	\N
c0bUZkLdCe	2024-02-16 00:11:17.621+00	2024-02-16 00:11:17.621+00	HtEtaHBVDN	TCkiw6gTDz	2	0	4	2	0	\N	\N
ySJ6kkcAVJ	2024-02-16 00:11:17.93+00	2024-02-16 00:11:17.93+00	VshUk7eBeK	XwszrNEEEj	3	1	3	3	4	\N	\N
yGo45jQDbS	2024-02-16 00:11:18.142+00	2024-02-16 00:11:18.142+00	R2CLtFh5jU	l1Bslv8T2k	0	2	4	2	3	\N	\N
ISAtW6j98i	2024-02-16 00:11:18.749+00	2024-02-16 00:11:18.749+00	dZKm0wOhYa	UCFo58JaaD	0	3	0	0	4	\N	\N
GenxL4zuoU	2024-02-16 00:11:19.055+00	2024-02-16 00:11:19.055+00	iUlyHNFGpG	UCFo58JaaD	2	2	2	0	3	\N	\N
ql7KLa51p2	2024-02-16 00:11:20.08+00	2024-02-16 00:11:20.08+00	AsrLUQwxI9	u5FXeeOChJ	4	0	4	1	2	\N	\N
2YctgkU4bv	2024-02-16 00:11:20.315+00	2024-02-16 00:11:20.315+00	SFAISec8QF	JLhF4VuByh	4	2	4	1	0	\N	\N
UFG95ZxtCl	2024-02-16 00:11:20.521+00	2024-02-16 00:11:20.521+00	mAKp5BK7R1	8w7i8C3NnT	3	0	2	1	3	\N	\N
Cp4cF3xPQq	2024-02-16 00:11:20.728+00	2024-02-16 00:11:20.728+00	I5RzFRcQ7G	fxvABtKCPT	2	3	2	0	1	\N	\N
EU583npA77	2024-02-16 00:11:20.937+00	2024-02-16 00:11:20.937+00	mAKp5BK7R1	14jGmOAXcg	2	0	2	3	3	\N	\N
SBnQGnI7ht	2024-02-16 00:11:21.144+00	2024-02-16 00:11:21.144+00	9223vtvaBd	EmIUBFwx0Z	3	0	0	0	0	\N	\N
NvfbqdHd7F	2024-02-16 00:11:21.352+00	2024-02-16 00:11:21.352+00	NjxsGlPeB4	lxQA9rtSfY	4	1	2	1	0	\N	\N
aKQtWg7AQk	2024-02-16 00:11:21.562+00	2024-02-16 00:11:21.562+00	ONgyydfVNz	89xRG1afNi	0	2	3	0	4	\N	\N
kAqS3jlWoN	2024-02-16 00:11:21.82+00	2024-02-16 00:11:21.82+00	VshUk7eBeK	bQpy9LEJWn	4	0	4	3	1	\N	\N
3RzN62bx5d	2024-02-16 00:11:22.127+00	2024-02-16 00:11:22.127+00	VshUk7eBeK	cFtamPA0zH	3	2	0	3	0	\N	\N
BtU6jGFDwX	2024-02-16 00:11:22.337+00	2024-02-16 00:11:22.337+00	dEqAHvPMXA	ThMuD3hYRQ	4	2	1	0	4	\N	\N
heWBWgVkbN	2024-02-16 00:11:22.549+00	2024-02-16 00:11:22.549+00	ONgyydfVNz	TpGyMZM9BG	1	1	2	3	1	\N	\N
MZzzCVObUI	2024-02-16 00:11:22.845+00	2024-02-16 00:11:22.845+00	sHiqaG4iqY	LVYK4mLShP	1	0	2	4	4	\N	\N
UWxIcK9lmS	2024-02-16 00:11:23.154+00	2024-02-16 00:11:23.154+00	WKpBp0c8F3	NY6RE1qgWu	4	1	3	0	4	\N	\N
3ZAQ2yCeHQ	2024-02-16 00:11:23.459+00	2024-02-16 00:11:23.459+00	HRhGpJpmb5	IEqTHcohpJ	4	4	3	3	3	\N	\N
sT2kLuVAEy	2024-02-16 00:11:23.97+00	2024-02-16 00:11:23.97+00	R2CLtFh5jU	G0uU7KQLEt	1	3	3	2	3	\N	\N
1aAa3g2jZq	2024-02-16 00:11:24.432+00	2024-02-16 00:11:24.432+00	ONgyydfVNz	HSEugQ3Ouj	0	4	3	2	2	\N	\N
VmXNi6mqSr	2024-02-16 00:11:24.641+00	2024-02-16 00:11:24.641+00	SFAISec8QF	Pja6n3yaWZ	1	2	0	0	0	\N	\N
2qhqyeGSST	2024-02-16 00:11:24.847+00	2024-02-16 00:11:24.847+00	opW2wQ2bZ8	0TvWuLoLF5	2	2	0	3	3	\N	\N
AkyZfwVBOb	2024-02-16 00:11:25.71+00	2024-02-16 00:11:25.71+00	S6wz0lK0bf	yvUod6yLDt	0	4	4	4	2	\N	\N
E1mjQGhFtl	2024-02-16 00:11:25.92+00	2024-02-16 00:11:25.92+00	SFAISec8QF	bi1IivsuUB	1	4	1	4	4	\N	\N
tzgOHnesaH	2024-02-16 00:11:26.223+00	2024-02-16 00:11:26.223+00	sHiqaG4iqY	y4RkaDbkec	3	2	4	1	0	\N	\N
tNj0gPtENk	2024-02-16 00:11:26.428+00	2024-02-16 00:11:26.428+00	dZKm0wOhYa	na5crB8ED1	4	1	2	2	3	\N	\N
L86rIDb4vP	2024-02-16 00:11:26.633+00	2024-02-16 00:11:26.633+00	1as6rMOzjQ	axyV0Fu7pm	4	4	4	1	3	\N	\N
j1kTv0r6xK	2024-02-16 00:11:26.841+00	2024-02-16 00:11:26.841+00	opW2wQ2bZ8	o90lhsZ7FK	4	3	4	4	4	\N	\N
6bJGt1aaHl	2024-02-16 00:11:27.144+00	2024-02-16 00:11:27.144+00	sy1HD51LXT	PF8w2gMAdi	4	2	2	2	4	\N	\N
ftfcBzsaDb	2024-02-16 00:11:27.453+00	2024-02-16 00:11:27.453+00	I5RzFRcQ7G	LDrIH1vU8x	2	2	1	4	1	\N	\N
q1TRL6Hgcl	2024-02-16 00:11:27.759+00	2024-02-16 00:11:27.759+00	mAKp5BK7R1	FYXEfIO1zF	4	0	1	4	3	\N	\N
uNaKEw57Rf	2024-02-16 00:11:27.969+00	2024-02-16 00:11:27.969+00	sy1HD51LXT	fKTSJPdUi9	2	1	0	3	3	\N	\N
cxGkhIP7c7	2024-02-16 00:11:28.178+00	2024-02-16 00:11:28.178+00	HtEtaHBVDN	0TvWuLoLF5	3	0	1	4	4	\N	\N
uwNg9lBQYI	2024-02-16 00:11:28.477+00	2024-02-16 00:11:28.477+00	5X202ssb0D	qP3EdIVzfB	1	3	2	1	0	\N	\N
6JJBhrTNew	2024-02-16 00:11:28.684+00	2024-02-16 00:11:28.684+00	I5RzFRcQ7G	Pa0qBO2rzK	3	1	2	0	0	\N	\N
X6XfsGgzaN	2024-02-16 00:11:28.897+00	2024-02-16 00:11:28.897+00	I5RzFRcQ7G	XSK814B37m	1	4	4	2	4	\N	\N
wJTWJUBnUQ	2024-02-16 00:11:29.195+00	2024-02-16 00:11:29.195+00	9223vtvaBd	AgU9OLJkqz	4	2	3	3	3	\N	\N
KpI7bguD1I	2024-02-16 00:11:29.403+00	2024-02-16 00:11:29.403+00	S6wz0lK0bf	LVYK4mLShP	3	4	1	1	2	\N	\N
43i4za64CB	2024-02-16 00:11:29.614+00	2024-02-16 00:11:29.614+00	WKpBp0c8F3	m6g8u0QpTC	4	1	0	4	1	\N	\N
j7hlAEoBNl	2024-02-16 00:11:29.912+00	2024-02-16 00:11:29.912+00	opW2wQ2bZ8	8w7i8C3NnT	4	2	1	0	1	\N	\N
M3kIhasuJX	2024-02-16 00:11:30.127+00	2024-02-16 00:11:30.127+00	mAKp5BK7R1	oABNR2FF6S	2	0	0	1	0	\N	\N
ZBnAiPPusu	2024-02-16 00:11:30.424+00	2024-02-16 00:11:30.424+00	mQXQWNqxg9	89xRG1afNi	0	0	0	2	3	\N	\N
I1wQhJUXHf	2024-02-16 00:11:30.733+00	2024-02-16 00:11:30.733+00	WKpBp0c8F3	JZOBDAh12a	1	0	2	0	1	\N	\N
CZGcAooHrJ	2024-02-16 00:11:31.446+00	2024-02-16 00:11:31.446+00	1as6rMOzjQ	CSvk1ycWXk	4	3	3	4	2	\N	\N
GpAeSEtg8E	2024-02-16 00:11:31.659+00	2024-02-16 00:11:31.659+00	SFAISec8QF	o90lhsZ7FK	2	3	3	4	0	\N	\N
kCOC7CvlTx	2024-02-16 00:11:31.868+00	2024-02-16 00:11:31.868+00	sy1HD51LXT	TZsdmscJ2B	0	0	4	3	3	\N	\N
gkHqQ8qyAV	2024-02-16 00:11:32.076+00	2024-02-16 00:11:32.076+00	iWxl9obi8w	Pa0qBO2rzK	1	1	1	4	4	\N	\N
MDZH68k3HU	2024-02-16 00:11:32.284+00	2024-02-16 00:11:32.284+00	iWxl9obi8w	VK3vnSxIy8	0	0	0	4	4	\N	\N
EvbTxDlvDl	2024-02-16 00:11:32.494+00	2024-02-16 00:11:32.494+00	RWwLSzreG2	HSEugQ3Ouj	3	4	0	4	0	\N	\N
vIJJOvfepN	2024-02-16 00:11:32.706+00	2024-02-16 00:11:32.706+00	RWwLSzreG2	axyV0Fu7pm	2	2	2	3	1	\N	\N
RrhsGKVqpq	2024-02-16 00:11:32.919+00	2024-02-16 00:11:32.919+00	dZKm0wOhYa	E2hBZzDsjO	3	3	0	0	0	\N	\N
hZyTcByt3K	2024-02-16 00:11:33.131+00	2024-02-16 00:11:33.131+00	Otwj7uJwjr	m6g8u0QpTC	3	4	1	2	3	\N	\N
BrFQSUnhXa	2024-02-16 00:11:33.394+00	2024-02-16 00:11:33.394+00	WKpBp0c8F3	JZOBDAh12a	2	2	4	1	3	\N	\N
hI9ttTTKCn	2024-02-16 00:11:33.7+00	2024-02-16 00:11:33.7+00	RWwLSzreG2	IEqTHcohpJ	1	3	0	3	0	\N	\N
K97nHnAxbQ	2024-02-16 00:11:33.91+00	2024-02-16 00:11:33.91+00	NjxsGlPeB4	0TvWuLoLF5	1	4	1	1	0	\N	\N
fmmHCUFe27	2024-02-16 00:11:34.121+00	2024-02-16 00:11:34.121+00	jqDYoPT45X	tCIEnLLcUc	3	2	4	0	0	\N	\N
jEiFuCoyLA	2024-02-16 00:11:34.333+00	2024-02-16 00:11:34.333+00	1as6rMOzjQ	6Fo67rhTSP	2	0	2	2	4	\N	\N
obz9z6gXcE	2024-02-16 00:11:34.547+00	2024-02-16 00:11:34.547+00	NjxsGlPeB4	XSK814B37m	4	2	0	0	1	\N	\N
DHUMWB97OH	2024-02-16 00:11:34.829+00	2024-02-16 00:11:34.829+00	ONgyydfVNz	j0dWqP2C2A	3	3	4	4	3	\N	\N
JBX0qQc7NZ	2024-02-16 00:11:35.439+00	2024-02-16 00:11:35.439+00	mAKp5BK7R1	eEmewy7hPd	2	3	4	0	0	\N	\N
3njr4bgTqJ	2024-02-16 00:11:35.748+00	2024-02-16 00:11:35.748+00	AsrLUQwxI9	ThMuD3hYRQ	4	0	0	2	1	\N	\N
9vKk9hHZYj	2024-02-16 00:11:35.959+00	2024-02-16 00:11:35.959+00	mQXQWNqxg9	XpUyRlB6FI	1	1	2	1	3	\N	\N
qKqvxNZh4O	2024-02-16 00:11:36.164+00	2024-02-16 00:11:36.164+00	Otwj7uJwjr	HSEugQ3Ouj	3	2	1	1	0	\N	\N
DoiQ8ZkJb4	2024-02-16 00:11:36.37+00	2024-02-16 00:11:36.37+00	SFAISec8QF	89xRG1afNi	2	2	2	4	2	\N	\N
ejCF3KSTMQ	2024-02-16 00:11:36.579+00	2024-02-16 00:11:36.579+00	SFAISec8QF	bi1IivsuUB	0	4	0	1	0	\N	\N
ODC3cq1hxV	2024-02-16 00:11:36.872+00	2024-02-16 00:11:36.872+00	mAKp5BK7R1	Pja6n3yaWZ	0	0	4	2	2	\N	\N
No7gE7ey2q	2024-02-16 00:11:37.487+00	2024-02-16 00:11:37.487+00	1as6rMOzjQ	PF8w2gMAdi	0	1	0	1	0	\N	\N
wxdMtPEE0e	2024-02-16 00:11:37.696+00	2024-02-16 00:11:37.696+00	5X202ssb0D	CSvk1ycWXk	0	2	0	1	0	\N	\N
bOAZOb0Akr	2024-02-16 00:11:37.906+00	2024-02-16 00:11:37.906+00	VshUk7eBeK	FYXEfIO1zF	4	4	0	0	2	\N	\N
wKxQUvHBUe	2024-02-16 00:11:38.204+00	2024-02-16 00:11:38.204+00	RWwLSzreG2	qEQ9tmLyW9	3	4	0	3	1	\N	\N
bxs6vJjzEM	2024-02-16 00:11:38.417+00	2024-02-16 00:11:38.417+00	AsrLUQwxI9	CSvk1ycWXk	3	1	4	0	1	\N	\N
uNl0UHSJJB	2024-02-16 00:11:38.628+00	2024-02-16 00:11:38.628+00	SFAISec8QF	XSK814B37m	2	1	2	2	3	\N	\N
NQqYS4rpLF	2024-02-16 00:11:38.837+00	2024-02-16 00:11:38.837+00	dEqAHvPMXA	j0dWqP2C2A	2	2	0	0	4	\N	\N
yv8le135CE	2024-02-16 00:11:39.05+00	2024-02-16 00:11:39.05+00	5X202ssb0D	TCkiw6gTDz	4	2	3	3	2	\N	\N
2EchXHq82q	2024-02-16 00:11:39.261+00	2024-02-16 00:11:39.261+00	S6wz0lK0bf	JLhF4VuByh	0	1	4	3	1	\N	\N
pA7kHGqjs3	2024-02-16 00:11:39.475+00	2024-02-16 00:11:39.475+00	5X202ssb0D	o90lhsZ7FK	1	3	2	1	1	\N	\N
E17vIjbkmY	2024-02-16 00:11:40.143+00	2024-02-16 00:11:40.143+00	VshUk7eBeK	e037qpAih3	4	4	3	1	4	\N	\N
wN8W0tQlY3	2024-02-16 00:11:40.349+00	2024-02-16 00:11:40.349+00	AsrLUQwxI9	Pa0qBO2rzK	4	1	0	2	4	\N	\N
Af3buo3kcQ	2024-02-16 00:11:40.557+00	2024-02-16 00:11:40.557+00	5X202ssb0D	HSEugQ3Ouj	2	0	1	3	0	\N	\N
cVF5CUxSlF	2024-02-16 00:11:40.763+00	2024-02-16 00:11:40.763+00	9223vtvaBd	axyV0Fu7pm	2	2	0	3	0	\N	\N
w1bOu8sMy0	2024-02-16 00:11:41.071+00	2024-02-16 00:11:41.071+00	S6wz0lK0bf	WnUBBkiDjE	0	3	1	3	1	\N	\N
nNIqmEoJCt	2024-02-16 00:11:41.28+00	2024-02-16 00:11:41.28+00	S6wz0lK0bf	WBFeKac0OO	4	3	2	3	4	\N	\N
PUfF5BpMSR	2024-02-16 00:11:41.729+00	2024-02-16 00:11:41.729+00	mAKp5BK7R1	6Fo67rhTSP	1	4	3	4	2	\N	\N
XCpjvGy2ov	2024-02-16 00:11:41.936+00	2024-02-16 00:11:41.936+00	iUlyHNFGpG	14jGmOAXcg	0	3	1	4	1	\N	\N
F4JjBHupz6	2024-02-16 00:11:42.709+00	2024-02-16 00:11:42.709+00	opW2wQ2bZ8	LgJuu5ABe5	1	2	3	0	1	\N	\N
w4On6lt2Oa	2024-02-16 00:11:42.919+00	2024-02-16 00:11:42.919+00	R2CLtFh5jU	FYXEfIO1zF	4	0	4	0	4	\N	\N
WHRniiXaDE	2024-02-16 00:11:43.124+00	2024-02-16 00:11:43.124+00	dZKm0wOhYa	j0dWqP2C2A	0	3	4	3	0	\N	\N
P9m4qwD8wT	2024-02-16 00:11:43.425+00	2024-02-16 00:11:43.425+00	SFAISec8QF	D0A6GLdsDM	3	2	2	4	2	\N	\N
nlQ6UCsuBG	2024-02-16 00:11:43.634+00	2024-02-16 00:11:43.634+00	Otwj7uJwjr	EmIUBFwx0Z	0	1	1	3	3	\N	\N
PJIQ1QsyNE	2024-02-16 00:11:43.839+00	2024-02-16 00:11:43.839+00	ONgyydfVNz	89xRG1afNi	2	4	0	0	2	\N	\N
TgzMeA4Ffc	2024-02-16 00:11:44.049+00	2024-02-16 00:11:44.049+00	RWwLSzreG2	HXtEwLBC7f	4	3	1	3	3	\N	\N
cFDSqBlDqC	2024-02-16 00:11:44.255+00	2024-02-16 00:11:44.255+00	VshUk7eBeK	LgJuu5ABe5	4	3	0	2	1	\N	\N
fibs5ElQbD	2024-02-16 00:11:44.465+00	2024-02-16 00:11:44.465+00	adE9nQrDk3	axyV0Fu7pm	2	3	0	1	3	\N	\N
xEcA1wHlWf	2024-02-16 00:11:44.758+00	2024-02-16 00:11:44.758+00	adE9nQrDk3	lxQA9rtSfY	4	2	4	0	1	\N	\N
8T4J5HTUkI	2024-02-16 00:11:44.968+00	2024-02-16 00:11:44.968+00	iUlyHNFGpG	LVYK4mLShP	0	3	1	3	0	\N	\N
Cr1e86FTlj	2024-02-16 00:11:45.176+00	2024-02-16 00:11:45.176+00	ONgyydfVNz	HXtEwLBC7f	2	3	3	0	1	\N	\N
3zDBNy1pvL	2024-02-16 00:11:45.384+00	2024-02-16 00:11:45.384+00	iWxl9obi8w	BMLzFMvIT6	1	1	1	1	1	\N	\N
e1YMQ28tym	2024-02-16 00:11:45.594+00	2024-02-16 00:11:45.594+00	opW2wQ2bZ8	89xRG1afNi	1	3	4	3	0	\N	\N
MhrYUAMPA0	2024-02-16 00:11:45.807+00	2024-02-16 00:11:45.807+00	AsrLUQwxI9	FJOTueDfs2	1	1	3	4	3	\N	\N
oFietbi9RB	2024-02-16 00:11:46.019+00	2024-02-16 00:11:46.019+00	R2CLtFh5jU	3u4B9V4l5K	4	4	1	1	2	\N	\N
35zL0MIfBM	2024-02-16 00:11:46.232+00	2024-02-16 00:11:46.232+00	RWwLSzreG2	o4VD4BWwDt	1	3	4	4	0	\N	\N
6SnP5zzjR9	2024-02-16 00:11:46.443+00	2024-02-16 00:11:46.443+00	iWxl9obi8w	na5crB8ED1	3	0	4	2	0	\N	\N
mpXxbsFtYJ	2024-02-16 00:11:46.908+00	2024-02-16 00:11:46.908+00	1as6rMOzjQ	LVYK4mLShP	4	4	4	0	1	\N	\N
aTJbsVvU8I	2024-02-16 00:11:47.124+00	2024-02-16 00:11:47.124+00	WKpBp0c8F3	cwVEh0dqfm	3	4	0	1	3	\N	\N
0QBwWB8Wvj	2024-02-16 00:11:47.333+00	2024-02-16 00:11:47.333+00	S6wz0lK0bf	TCkiw6gTDz	4	4	4	4	4	\N	\N
puRxZQUXHG	2024-02-16 00:11:47.626+00	2024-02-16 00:11:47.626+00	RWwLSzreG2	jHqCpA1nWb	1	4	3	1	4	\N	\N
CdqS3PfpsP	2024-02-16 00:11:47.834+00	2024-02-16 00:11:47.834+00	NjxsGlPeB4	XpUyRlB6FI	2	2	1	3	4	\N	\N
bF7IY7Nm6x	2024-02-16 00:11:48.139+00	2024-02-16 00:11:48.139+00	5nv19u6KJ2	3P6kmNoY1F	2	3	4	2	2	\N	\N
nRTENX3pU4	2024-02-16 00:11:48.349+00	2024-02-16 00:11:48.349+00	sy1HD51LXT	MQfxuw3ERg	3	1	1	3	4	\N	\N
9i690Bi9E9	2024-02-16 00:11:48.559+00	2024-02-16 00:11:48.559+00	R2CLtFh5jU	Gl96vGdYHM	3	2	0	4	4	\N	\N
xy3gbRWbV9	2024-02-16 00:11:48.856+00	2024-02-16 00:11:48.856+00	sy1HD51LXT	LDrIH1vU8x	4	2	1	1	1	\N	\N
1SVv1vDueL	2024-02-16 00:11:49.066+00	2024-02-16 00:11:49.066+00	ONgyydfVNz	qP3EdIVzfB	1	4	2	3	1	\N	\N
VU24B1BX9w	2024-02-16 00:11:49.277+00	2024-02-16 00:11:49.277+00	sy1HD51LXT	JRi61dUphq	0	3	3	4	3	\N	\N
tLYR6O3U4W	2024-02-16 00:11:49.491+00	2024-02-16 00:11:49.491+00	sy1HD51LXT	WBFeKac0OO	1	2	0	2	0	\N	\N
KxfLi12i7q	2024-02-16 00:11:49.702+00	2024-02-16 00:11:49.702+00	5X202ssb0D	axyV0Fu7pm	3	3	4	3	4	\N	\N
463c0iv7AK	2024-02-16 00:11:49.914+00	2024-02-16 00:11:49.914+00	adE9nQrDk3	VK3vnSxIy8	1	4	3	2	3	\N	\N
QwBXuCGkU7	2024-02-16 00:11:50.127+00	2024-02-16 00:11:50.127+00	sy1HD51LXT	Gl96vGdYHM	3	1	2	0	0	\N	\N
uH7SG87weU	2024-02-16 00:11:50.342+00	2024-02-16 00:11:50.342+00	HRhGpJpmb5	TCkiw6gTDz	2	4	2	3	1	\N	\N
AVGXGPcGs1	2024-02-16 00:11:50.6+00	2024-02-16 00:11:50.6+00	adE9nQrDk3	XSK814B37m	3	4	3	3	2	\N	\N
ehBJ9nLRxF	2024-02-16 00:11:50.815+00	2024-02-16 00:11:50.815+00	sy1HD51LXT	TpGyMZM9BG	0	4	2	3	1	\N	\N
fBQhluHRzL	2024-02-16 00:11:51.029+00	2024-02-16 00:11:51.029+00	R2CLtFh5jU	l1Bslv8T2k	2	3	3	1	0	\N	\N
Xar2fpBw17	2024-02-16 00:11:51.314+00	2024-02-16 00:11:51.314+00	iUlyHNFGpG	CSvk1ycWXk	0	0	1	4	3	\N	\N
kPXoW8AaaQ	2024-02-16 00:11:51.526+00	2024-02-16 00:11:51.526+00	dZKm0wOhYa	qP3EdIVzfB	0	1	1	3	0	\N	\N
bf6mAdSKWY	2024-02-16 00:11:51.826+00	2024-02-16 00:11:51.826+00	9223vtvaBd	FYXEfIO1zF	2	1	1	4	3	\N	\N
U5xqsVMEC6	2024-02-16 00:11:52.036+00	2024-02-16 00:11:52.036+00	NjxsGlPeB4	lEPdiO1EDi	3	0	3	4	4	\N	\N
PoxEySk69D	2024-02-16 00:11:52.251+00	2024-02-16 00:11:52.251+00	dZKm0wOhYa	Gl96vGdYHM	3	0	0	1	3	\N	\N
SMiYyhwMHY	2024-02-16 00:11:52.543+00	2024-02-16 00:11:52.543+00	5nv19u6KJ2	TpGyMZM9BG	4	0	1	0	0	\N	\N
IIQZNNhbIN	2024-02-16 00:11:52.751+00	2024-02-16 00:11:52.751+00	sHiqaG4iqY	jHqCpA1nWb	0	0	2	0	2	\N	\N
bCRQdYOenf	2024-02-16 00:11:52.96+00	2024-02-16 00:11:52.96+00	NjxsGlPeB4	XwWwGnkXNj	0	3	0	0	0	\N	\N
1fWQEgo6Ej	2024-02-16 00:11:53.168+00	2024-02-16 00:11:53.168+00	adE9nQrDk3	j0dWqP2C2A	4	0	0	0	4	\N	\N
c8aP3dSpnQ	2024-02-16 00:11:53.464+00	2024-02-16 00:11:53.464+00	ONgyydfVNz	XwWwGnkXNj	4	0	3	3	0	\N	\N
sFJOodiBe3	2024-02-16 00:11:54.077+00	2024-02-16 00:11:54.077+00	R2CLtFh5jU	Oahm9sOn1y	4	1	2	4	3	\N	\N
FfR2HbxBH0	2024-02-16 00:11:54.286+00	2024-02-16 00:11:54.286+00	iWxl9obi8w	VK3vnSxIy8	4	3	4	1	4	\N	\N
MHFr64xEzg	2024-02-16 00:11:54.493+00	2024-02-16 00:11:54.493+00	R2CLtFh5jU	cTIjuPjyIa	0	3	2	4	0	\N	\N
o39aVaeCra	2024-02-16 00:11:54.702+00	2024-02-16 00:11:54.702+00	opW2wQ2bZ8	HXtEwLBC7f	4	0	3	4	1	\N	\N
5LB5gSKckH	2024-02-16 00:11:54.918+00	2024-02-16 00:11:54.918+00	jqDYoPT45X	rKyjwoEIRp	3	0	3	4	2	\N	\N
1J9PHsiloa	2024-02-16 00:11:55.133+00	2024-02-16 00:11:55.133+00	sy1HD51LXT	j0dWqP2C2A	3	4	2	3	3	\N	\N
sAyTtQDBmt	2024-02-16 00:11:55.345+00	2024-02-16 00:11:55.345+00	9223vtvaBd	rT0UCBK1bE	0	4	0	2	3	\N	\N
MyZljgE7VT	2024-02-16 00:11:55.56+00	2024-02-16 00:11:55.56+00	AsrLUQwxI9	UDXF0qXvDY	3	0	2	1	1	\N	\N
J7onbOEJYp	2024-02-16 00:11:55.778+00	2024-02-16 00:11:55.778+00	5nv19u6KJ2	RBRcyltRSC	1	1	4	0	1	\N	\N
DMRymzh2b2	2024-02-16 00:11:56.025+00	2024-02-16 00:11:56.025+00	iWxl9obi8w	cTIjuPjyIa	3	1	4	1	0	\N	\N
vXLOaY36qD	2024-02-16 00:11:56.235+00	2024-02-16 00:11:56.235+00	Otwj7uJwjr	j0dWqP2C2A	4	4	2	0	2	\N	\N
vOHYVKh9HS	2024-02-16 00:11:56.535+00	2024-02-16 00:11:56.535+00	R2CLtFh5jU	TCkiw6gTDz	3	3	4	4	0	\N	\N
MCcuaMOAF1	2024-02-16 00:11:56.748+00	2024-02-16 00:11:56.748+00	mAKp5BK7R1	XpUyRlB6FI	1	1	4	4	2	\N	\N
0GKuxhEWcq	2024-02-16 00:11:56.959+00	2024-02-16 00:11:56.959+00	iUlyHNFGpG	u5FXeeOChJ	3	0	4	0	0	\N	\N
6oZIXzDTwJ	2024-02-16 00:11:57.169+00	2024-02-16 00:11:57.169+00	iWxl9obi8w	j0dWqP2C2A	1	0	1	1	0	\N	\N
d56RJESH1G	2024-02-16 00:11:57.457+00	2024-02-16 00:11:57.457+00	mQXQWNqxg9	WBFeKac0OO	2	0	4	4	3	\N	\N
cUDOACKnTl	2024-02-16 00:11:57.67+00	2024-02-16 00:11:57.67+00	sy1HD51LXT	WHvlAGgj6c	3	2	3	1	1	\N	\N
tORR7fBXch	2024-02-16 00:11:57.969+00	2024-02-16 00:11:57.969+00	SFAISec8QF	oABNR2FF6S	1	1	3	3	0	\N	\N
naWFn8gKHN	2024-02-16 00:11:58.182+00	2024-02-16 00:11:58.182+00	sHiqaG4iqY	XwszrNEEEj	3	1	4	4	3	\N	\N
O8XLMPntvl	2024-02-16 00:11:58.484+00	2024-02-16 00:11:58.484+00	iWxl9obi8w	D0A6GLdsDM	1	4	1	4	1	\N	\N
5BkwKGlphP	2024-02-16 00:11:58.697+00	2024-02-16 00:11:58.697+00	VshUk7eBeK	EmIUBFwx0Z	4	1	4	0	0	\N	\N
mM2kBiHZDv	2024-02-16 00:11:58.912+00	2024-02-16 00:11:58.912+00	iWxl9obi8w	EmIUBFwx0Z	4	3	0	2	0	\N	\N
CURcqDKCmE	2024-02-16 00:11:59.124+00	2024-02-16 00:11:59.124+00	S6wz0lK0bf	CSvk1ycWXk	1	3	1	3	4	\N	\N
0vOFg3JQ4r	2024-02-16 00:11:59.335+00	2024-02-16 00:11:59.335+00	NjxsGlPeB4	TCkiw6gTDz	4	4	2	1	2	\N	\N
LTPyLz5eY0	2024-02-16 00:11:59.551+00	2024-02-16 00:11:59.551+00	mAKp5BK7R1	RkhjIQJgou	4	3	3	1	2	\N	\N
fFal7f5rWL	2024-02-16 00:11:59.767+00	2024-02-16 00:11:59.767+00	I5RzFRcQ7G	ThMuD3hYRQ	2	4	3	1	1	\N	\N
aBBuzJHSXO	2024-02-16 00:11:59.981+00	2024-02-16 00:11:59.981+00	iWxl9obi8w	Gl96vGdYHM	3	4	0	4	2	\N	\N
mDXM7hCscE	2024-02-16 00:12:00.192+00	2024-02-16 00:12:00.192+00	iUlyHNFGpG	TZsdmscJ2B	0	4	1	0	3	\N	\N
zmomLFqdlC	2024-02-16 00:12:00.427+00	2024-02-16 00:12:00.427+00	I5RzFRcQ7G	fwLPZZ8YQa	1	3	3	0	0	\N	\N
eG7JG2OCuk	2024-02-16 00:12:00.735+00	2024-02-16 00:12:00.735+00	VshUk7eBeK	tCIEnLLcUc	2	1	0	2	1	\N	\N
fERqqly9JQ	2024-02-16 00:12:01.043+00	2024-02-16 00:12:01.043+00	I5RzFRcQ7G	JLhF4VuByh	3	2	0	3	0	\N	\N
PpriVlKmxI	2024-02-16 00:12:01.349+00	2024-02-16 00:12:01.349+00	mAKp5BK7R1	Pja6n3yaWZ	1	0	1	0	2	\N	\N
gxuqF64Fox	2024-02-16 00:12:01.654+00	2024-02-16 00:12:01.654+00	I5RzFRcQ7G	y4RkaDbkec	1	4	4	4	0	\N	\N
JMWDxs5dQr	2024-02-16 00:12:01.961+00	2024-02-16 00:12:01.961+00	ONgyydfVNz	Pja6n3yaWZ	1	4	2	3	1	\N	\N
kz56xqFmBL	2024-02-16 00:12:02.268+00	2024-02-16 00:12:02.268+00	iUlyHNFGpG	eEmewy7hPd	1	2	1	4	3	\N	\N
LGUeaZDjO7	2024-02-16 00:12:02.484+00	2024-02-16 00:12:02.484+00	adE9nQrDk3	P9sBFomftT	3	3	4	4	4	\N	\N
3iR98GnE2q	2024-02-16 00:12:02.782+00	2024-02-16 00:12:02.782+00	SFAISec8QF	qZmnAnnPEb	1	2	3	4	3	\N	\N
nvxFPVfOM1	2024-02-16 00:12:02.994+00	2024-02-16 00:12:02.994+00	ONgyydfVNz	m6g8u0QpTC	0	2	3	1	0	\N	\N
IubPe5CFiD	2024-02-16 00:12:03.201+00	2024-02-16 00:12:03.201+00	5X202ssb0D	bQpy9LEJWn	1	3	4	1	4	\N	\N
pDxYqOFoo8	2024-02-16 00:12:03.414+00	2024-02-16 00:12:03.414+00	AsrLUQwxI9	IybX0eBoO3	1	0	1	2	0	\N	\N
FU9iHpzAA6	2024-02-16 00:12:03.628+00	2024-02-16 00:12:03.628+00	mQXQWNqxg9	JRi61dUphq	3	1	3	0	3	\N	\N
RBGtHe3zbF	2024-02-16 00:12:04.215+00	2024-02-16 00:12:04.215+00	9223vtvaBd	RkhjIQJgou	0	1	3	4	3	\N	\N
EJthYtJTip	2024-02-16 00:12:04.521+00	2024-02-16 00:12:04.521+00	dEqAHvPMXA	EmIUBFwx0Z	0	1	4	1	4	\N	\N
BZjcALXaIV	2024-02-16 00:12:04.73+00	2024-02-16 00:12:04.73+00	R2CLtFh5jU	E2hBZzDsjO	1	3	1	2	4	\N	\N
ZwXkf5f2ez	2024-02-16 00:12:04.938+00	2024-02-16 00:12:04.938+00	sHiqaG4iqY	6Fo67rhTSP	4	3	1	0	3	\N	\N
Ci8GsCgq70	2024-02-16 00:12:05.545+00	2024-02-16 00:12:05.545+00	dZKm0wOhYa	3u4B9V4l5K	4	3	2	4	3	\N	\N
IDbAPZWVmL	2024-02-16 00:12:05.792+00	2024-02-16 00:12:05.792+00	5nv19u6KJ2	0TvWuLoLF5	3	2	2	1	4	\N	\N
QlKA9bf2tB	2024-02-16 00:12:06.003+00	2024-02-16 00:12:06.003+00	SFAISec8QF	bi1IivsuUB	1	4	1	4	3	\N	\N
6PfwxVOf4o	2024-02-16 00:12:06.221+00	2024-02-16 00:12:06.221+00	sy1HD51LXT	PF8w2gMAdi	1	4	1	3	4	\N	\N
zHGV8TIB78	2024-02-16 00:12:06.466+00	2024-02-16 00:12:06.466+00	5nv19u6KJ2	RBRcyltRSC	3	0	3	2	2	\N	\N
hZR90Yfve1	2024-02-16 00:12:06.675+00	2024-02-16 00:12:06.675+00	HtEtaHBVDN	IEqTHcohpJ	3	3	1	1	2	\N	\N
bvb4Kzcr6i	2024-02-16 00:12:06.885+00	2024-02-16 00:12:06.885+00	9223vtvaBd	6KvFK8yy1q	4	1	2	0	0	\N	\N
sRtAjSDZHv	2024-02-16 00:12:07.098+00	2024-02-16 00:12:07.098+00	I5RzFRcQ7G	bi1IivsuUB	0	2	1	1	1	\N	\N
PuLpifSG83	2024-02-16 00:12:07.31+00	2024-02-16 00:12:07.31+00	mAKp5BK7R1	rT0UCBK1bE	4	4	3	3	0	\N	\N
duNdO5Akel	2024-02-16 00:12:07.595+00	2024-02-16 00:12:07.595+00	dEqAHvPMXA	yvUod6yLDt	2	3	0	4	4	\N	\N
OhhtFfdQD6	2024-02-16 00:12:07.808+00	2024-02-16 00:12:07.808+00	RWwLSzreG2	cFtamPA0zH	1	2	4	4	3	\N	\N
UewlEhW3C8	2024-02-16 00:12:08.019+00	2024-02-16 00:12:08.019+00	WKpBp0c8F3	oABNR2FF6S	0	0	3	1	1	\N	\N
EkcS4eGSG8	2024-02-16 00:12:08.23+00	2024-02-16 00:12:08.23+00	R2CLtFh5jU	NBojpORh3G	0	4	3	1	1	\N	\N
hKOK1CloD9	2024-02-16 00:12:08.516+00	2024-02-16 00:12:08.516+00	Otwj7uJwjr	jHqCpA1nWb	0	3	0	1	3	\N	\N
CFJxIJ6iiY	2024-02-16 00:12:08.727+00	2024-02-16 00:12:08.727+00	1as6rMOzjQ	cFtamPA0zH	4	4	2	0	0	\N	\N
Fjqeo3iSNH	2024-02-16 00:12:08.937+00	2024-02-16 00:12:08.937+00	sy1HD51LXT	HLIPwAqO2R	2	4	0	0	3	\N	\N
ZYG1mdUgAF	2024-02-16 00:12:09.148+00	2024-02-16 00:12:09.148+00	dEqAHvPMXA	MQfxuw3ERg	4	3	4	0	4	\N	\N
jdnmH3GCeB	2024-02-16 00:12:09.437+00	2024-02-16 00:12:09.437+00	RWwLSzreG2	XwWwGnkXNj	3	1	0	0	3	\N	\N
cUOGCrGVx1	2024-02-16 00:12:09.745+00	2024-02-16 00:12:09.745+00	WKpBp0c8F3	y4RkaDbkec	1	2	3	1	3	\N	\N
bSzc0YlirY	2024-02-16 00:12:09.956+00	2024-02-16 00:12:09.956+00	dZKm0wOhYa	uigc7bJBOJ	0	2	1	1	3	\N	\N
jnSJJzslOF	2024-02-16 00:12:10.167+00	2024-02-16 00:12:10.167+00	9223vtvaBd	RkhjIQJgou	2	1	2	3	1	\N	\N
krbKHzuJ6H	2024-02-16 00:12:10.377+00	2024-02-16 00:12:10.377+00	R2CLtFh5jU	uigc7bJBOJ	0	4	0	4	4	\N	\N
QNXhTVopO9	2024-02-16 00:12:10.581+00	2024-02-16 00:12:10.581+00	dZKm0wOhYa	qP3EdIVzfB	2	4	2	0	4	\N	\N
AiE4vpsaHp	2024-02-16 00:12:10.783+00	2024-02-16 00:12:10.783+00	iUlyHNFGpG	WnUBBkiDjE	0	0	4	1	4	\N	\N
JnJxW6SR1E	2024-02-16 00:12:10.992+00	2024-02-16 00:12:10.992+00	iWxl9obi8w	FYXEfIO1zF	3	3	1	2	0	\N	\N
LLmsRCSpNJ	2024-02-16 00:12:11.209+00	2024-02-16 00:12:11.209+00	SFAISec8QF	XSK814B37m	0	2	2	2	1	\N	\N
UCdlssL4a8	2024-02-16 00:12:11.434+00	2024-02-16 00:12:11.434+00	5nv19u6KJ2	tCIEnLLcUc	4	4	3	1	0	\N	\N
lmOn0AHc1v	2024-02-16 00:12:11.692+00	2024-02-16 00:12:11.692+00	NjxsGlPeB4	HLIPwAqO2R	2	0	1	0	1	\N	\N
BdLzLGqzCk	2024-02-16 00:12:11.902+00	2024-02-16 00:12:11.902+00	dEqAHvPMXA	3P6kmNoY1F	3	1	3	3	2	\N	\N
IjOY7Rkk8Q	2024-02-16 00:12:12.115+00	2024-02-16 00:12:12.115+00	VshUk7eBeK	cwVEh0dqfm	1	4	2	2	0	\N	\N
UD7Q1qi9en	2024-02-16 00:12:12.328+00	2024-02-16 00:12:12.328+00	AsrLUQwxI9	MQfxuw3ERg	2	0	0	2	2	\N	\N
MxCRiY77Ct	2024-02-16 00:12:12.537+00	2024-02-16 00:12:12.537+00	NjxsGlPeB4	qEQ9tmLyW9	0	3	4	0	2	\N	\N
lDZaZo4Ug1	2024-02-16 00:12:12.75+00	2024-02-16 00:12:12.75+00	R2CLtFh5jU	IybX0eBoO3	4	2	1	1	3	\N	\N
PObtZFobAR	2024-02-16 00:12:12.959+00	2024-02-16 00:12:12.959+00	5nv19u6KJ2	JLhF4VuByh	1	0	1	1	4	\N	\N
6EOTt0vIyA	2024-02-16 00:12:13.174+00	2024-02-16 00:12:13.174+00	jqDYoPT45X	M0tHrt1GgV	0	2	4	0	1	\N	\N
suu7tYJmD4	2024-02-16 00:12:13.387+00	2024-02-16 00:12:13.387+00	R2CLtFh5jU	VK3vnSxIy8	2	2	1	3	0	\N	\N
qNFe56kiZu	2024-02-16 00:12:13.636+00	2024-02-16 00:12:13.636+00	RWwLSzreG2	IEqTHcohpJ	0	1	0	4	1	\N	\N
upDc7bsU5K	2024-02-16 00:12:13.846+00	2024-02-16 00:12:13.846+00	mQXQWNqxg9	yvUod6yLDt	4	2	1	0	0	\N	\N
jSErii23dr	2024-02-16 00:12:14.058+00	2024-02-16 00:12:14.058+00	I5RzFRcQ7G	na5crB8ED1	2	0	1	0	2	\N	\N
vDMkdHkKzT	2024-02-16 00:12:14.354+00	2024-02-16 00:12:14.354+00	5nv19u6KJ2	XwszrNEEEj	3	1	4	2	2	\N	\N
ewGnijfghw	2024-02-16 00:12:14.569+00	2024-02-16 00:12:14.569+00	NjxsGlPeB4	M0tHrt1GgV	3	3	2	0	1	\N	\N
piiLIYWivY	2024-02-16 00:12:14.866+00	2024-02-16 00:12:14.866+00	dEqAHvPMXA	XwWwGnkXNj	1	0	0	2	1	\N	\N
3t1D4t8Ejt	2024-02-16 00:12:15.078+00	2024-02-16 00:12:15.078+00	HtEtaHBVDN	qZmnAnnPEb	1	0	1	1	2	\N	\N
I8TAvpWAqc	2024-02-16 00:12:15.29+00	2024-02-16 00:12:15.29+00	HtEtaHBVDN	vwHi602n66	4	1	2	3	0	\N	\N
vXRtqo2fdH	2024-02-16 00:12:15.583+00	2024-02-16 00:12:15.583+00	dZKm0wOhYa	NY6RE1qgWu	1	2	2	1	3	\N	\N
xZUPWa2eMU	2024-02-16 00:12:15.889+00	2024-02-16 00:12:15.889+00	AsrLUQwxI9	lEPdiO1EDi	1	1	4	2	1	\N	\N
QNtPkh9Xod	2024-02-16 00:12:16.093+00	2024-02-16 00:12:16.093+00	sHiqaG4iqY	Pa0qBO2rzK	2	1	0	1	4	\N	\N
hFVIMuZTGG	2024-02-16 00:12:16.708+00	2024-02-16 00:12:16.708+00	VshUk7eBeK	y4RkaDbkec	3	0	4	2	2	\N	\N
6IBIrny1mR	2024-02-16 00:12:16.916+00	2024-02-16 00:12:16.916+00	adE9nQrDk3	E2hBZzDsjO	0	1	2	0	4	\N	\N
tSCgTw8NLD	2024-02-16 00:12:17.125+00	2024-02-16 00:12:17.125+00	opW2wQ2bZ8	qZmnAnnPEb	3	1	3	0	3	\N	\N
1yAGoH80VV	2024-02-16 00:12:17.338+00	2024-02-16 00:12:17.338+00	HRhGpJpmb5	XwszrNEEEj	0	2	0	1	4	\N	\N
SkmRqARoET	2024-02-16 00:12:17.546+00	2024-02-16 00:12:17.546+00	5X202ssb0D	fwLPZZ8YQa	4	4	2	0	3	\N	\N
h2cXyy1TFB	2024-02-16 00:12:17.754+00	2024-02-16 00:12:17.754+00	1as6rMOzjQ	RBRcyltRSC	0	2	1	3	3	\N	\N
cgU9kk7SBI	2024-02-16 00:12:17.962+00	2024-02-16 00:12:17.962+00	iWxl9obi8w	UCFo58JaaD	2	4	1	4	1	\N	\N
OVO8LwyPqZ	2024-02-16 00:12:18.174+00	2024-02-16 00:12:18.174+00	R2CLtFh5jU	cTIjuPjyIa	3	4	0	2	2	\N	\N
6IGUHhwZdD	2024-02-16 00:12:18.449+00	2024-02-16 00:12:18.449+00	Otwj7uJwjr	fKTSJPdUi9	4	3	3	1	4	\N	\N
KZ9kh1Ap2Q	2024-02-16 00:12:18.659+00	2024-02-16 00:12:18.659+00	NjxsGlPeB4	Gl96vGdYHM	2	0	4	0	1	\N	\N
5Zm0yUCE2n	2024-02-16 00:12:18.875+00	2024-02-16 00:12:18.875+00	mQXQWNqxg9	NY6RE1qgWu	1	0	3	4	4	\N	\N
vtzuK0UfGU	2024-02-16 00:12:19.086+00	2024-02-16 00:12:19.086+00	HRhGpJpmb5	9GF3y7LmHV	0	1	4	2	4	\N	\N
wFEX3lClMT	2024-02-16 00:12:19.373+00	2024-02-16 00:12:19.373+00	Otwj7uJwjr	XwWwGnkXNj	2	2	1	2	3	\N	\N
fGq0pbkO4H	2024-02-16 00:12:19.587+00	2024-02-16 00:12:19.587+00	sHiqaG4iqY	WSTLlXDcKl	2	2	1	3	3	\N	\N
floRvuCgF1	2024-02-16 00:12:19.882+00	2024-02-16 00:12:19.882+00	NjxsGlPeB4	vwHi602n66	3	1	2	4	4	\N	\N
W7zebTZNpp	2024-02-16 00:12:20.094+00	2024-02-16 00:12:20.094+00	sHiqaG4iqY	JZOBDAh12a	2	4	1	1	1	\N	\N
LQIHHZtU7D	2024-02-16 00:12:20.305+00	2024-02-16 00:12:20.305+00	S6wz0lK0bf	axyV0Fu7pm	4	4	1	1	3	\N	\N
3O9OCnQyfl	2024-02-16 00:12:20.904+00	2024-02-16 00:12:20.904+00	AsrLUQwxI9	HSEugQ3Ouj	3	3	2	0	1	\N	\N
dzF0bL3v19	2024-02-16 00:12:21.212+00	2024-02-16 00:12:21.212+00	I5RzFRcQ7G	fxvABtKCPT	0	2	0	0	3	\N	\N
dteqVU3xgc	2024-02-16 00:12:21.522+00	2024-02-16 00:12:21.522+00	R2CLtFh5jU	lEPdiO1EDi	1	2	2	2	3	\N	\N
GJtgTKDmmr	2024-02-16 00:12:22.127+00	2024-02-16 00:12:22.127+00	adE9nQrDk3	yvUod6yLDt	4	1	4	1	2	\N	\N
gF6Gp131AB	2024-02-16 00:12:22.336+00	2024-02-16 00:12:22.336+00	iUlyHNFGpG	o90lhsZ7FK	4	3	4	2	0	\N	\N
9h2IrfV67P	2024-02-16 00:12:22.544+00	2024-02-16 00:12:22.544+00	5nv19u6KJ2	Pja6n3yaWZ	0	3	4	4	0	\N	\N
juDDproDBH	2024-02-16 00:12:22.747+00	2024-02-16 00:12:22.747+00	AsrLUQwxI9	uigc7bJBOJ	2	4	2	2	3	\N	\N
AmzdBM0Wwr	2024-02-16 00:12:23.054+00	2024-02-16 00:12:23.054+00	1as6rMOzjQ	XpUyRlB6FI	1	3	1	4	3	\N	\N
GPeBiE9msR	2024-02-16 00:12:23.362+00	2024-02-16 00:12:23.362+00	R2CLtFh5jU	E2hBZzDsjO	1	2	3	3	0	\N	\N
uXfGgzlcOk	2024-02-16 00:12:23.571+00	2024-02-16 00:12:23.571+00	HRhGpJpmb5	E2hBZzDsjO	3	1	3	3	0	\N	\N
o1ZN1TOljO	2024-02-16 00:12:23.778+00	2024-02-16 00:12:23.778+00	AsrLUQwxI9	LVYK4mLShP	3	4	2	1	2	\N	\N
IfmMo9qu8w	2024-02-16 00:12:23.986+00	2024-02-16 00:12:23.986+00	9223vtvaBd	uABtFsJhJc	3	2	3	4	2	\N	\N
JOv7XUldoW	2024-02-16 00:12:24.197+00	2024-02-16 00:12:24.197+00	9223vtvaBd	MQfxuw3ERg	4	1	2	3	0	\N	\N
9T8zOHBODJ	2024-02-16 00:12:24.489+00	2024-02-16 00:12:24.489+00	iUlyHNFGpG	o4VD4BWwDt	1	4	4	4	0	\N	\N
9FEPLbcfyi	2024-02-16 00:12:24.697+00	2024-02-16 00:12:24.697+00	opW2wQ2bZ8	M0tHrt1GgV	4	2	4	3	4	\N	\N
p5DfpKzXzN	2024-02-16 00:12:24.909+00	2024-02-16 00:12:24.909+00	VshUk7eBeK	fxvABtKCPT	1	1	4	3	1	\N	\N
Rn5Xl5zAMx	2024-02-16 00:12:25.117+00	2024-02-16 00:12:25.117+00	S6wz0lK0bf	WBFeKac0OO	4	4	2	1	4	\N	\N
LWgOE5JLuO	2024-02-16 00:12:25.327+00	2024-02-16 00:12:25.327+00	9223vtvaBd	cFtamPA0zH	4	4	4	2	2	\N	\N
Ajrv0YQvV3	2024-02-16 00:12:25.618+00	2024-02-16 00:12:25.618+00	1as6rMOzjQ	fxvABtKCPT	2	0	3	4	4	\N	\N
7dUN6AFRrl	2024-02-16 00:12:25.832+00	2024-02-16 00:12:25.832+00	HRhGpJpmb5	jHqCpA1nWb	1	2	1	4	3	\N	\N
NzE0MaWkAv	2024-02-16 00:12:26.279+00	2024-02-16 00:12:26.279+00	mAKp5BK7R1	VK3vnSxIy8	4	4	1	3	1	\N	\N
C2Il2j3ZFH	2024-02-16 00:12:26.729+00	2024-02-16 00:12:26.729+00	sHiqaG4iqY	yvUod6yLDt	1	0	2	2	0	\N	\N
AuH78CVxCq	2024-02-16 00:12:26.938+00	2024-02-16 00:12:26.938+00	opW2wQ2bZ8	MQfxuw3ERg	3	1	1	1	2	\N	\N
6G3XqlicQL	2024-02-16 00:12:27.149+00	2024-02-16 00:12:27.149+00	5nv19u6KJ2	RBRcyltRSC	4	4	3	4	3	\N	\N
3rf3vZuDss	2024-02-16 00:12:27.355+00	2024-02-16 00:12:27.355+00	VshUk7eBeK	VK3vnSxIy8	0	0	1	3	1	\N	\N
rAQJixwhyi	2024-02-16 00:12:27.968+00	2024-02-16 00:12:27.968+00	5X202ssb0D	IEqTHcohpJ	1	0	3	4	2	\N	\N
iA7xcqTthb	2024-02-16 00:12:28.174+00	2024-02-16 00:12:28.174+00	SFAISec8QF	FYXEfIO1zF	2	2	3	3	2	\N	\N
6KC3uDk9Hb	2024-02-16 00:12:28.382+00	2024-02-16 00:12:28.382+00	HtEtaHBVDN	LVYK4mLShP	3	3	0	1	2	\N	\N
6zq90ztN4a	2024-02-16 00:12:28.591+00	2024-02-16 00:12:28.591+00	iWxl9obi8w	RBRcyltRSC	4	4	4	3	1	\N	\N
jKHrCDyO9x	2024-02-16 00:12:28.799+00	2024-02-16 00:12:28.799+00	S6wz0lK0bf	u5FXeeOChJ	4	1	2	4	2	\N	\N
B49mDAi7Rp	2024-02-16 00:12:29.009+00	2024-02-16 00:12:29.009+00	iUlyHNFGpG	E2hBZzDsjO	0	3	3	4	4	\N	\N
ncm0pJhA6N	2024-02-16 00:12:29.302+00	2024-02-16 00:12:29.302+00	sHiqaG4iqY	y4RkaDbkec	0	2	4	4	4	\N	\N
eMS0hUHnyZ	2024-02-16 00:12:29.51+00	2024-02-16 00:12:29.51+00	1as6rMOzjQ	oABNR2FF6S	1	1	2	1	3	\N	\N
RNQGaztUe7	2024-02-16 00:12:29.716+00	2024-02-16 00:12:29.716+00	Otwj7uJwjr	G0uU7KQLEt	0	0	0	4	3	\N	\N
FO7EQ3l7O1	2024-02-16 00:12:29.923+00	2024-02-16 00:12:29.923+00	I5RzFRcQ7G	IybX0eBoO3	2	1	2	0	2	\N	\N
OSXHqoYLhG	2024-02-16 00:12:30.132+00	2024-02-16 00:12:30.132+00	R2CLtFh5jU	KCsJ4XR6Dn	3	3	4	4	1	\N	\N
gezaFQ6Xtp	2024-02-16 00:12:30.345+00	2024-02-16 00:12:30.345+00	jqDYoPT45X	EmIUBFwx0Z	3	4	0	1	2	\N	\N
MAd6uf2xv3	2024-02-16 00:12:30.939+00	2024-02-16 00:12:30.939+00	RWwLSzreG2	qEQ9tmLyW9	2	2	4	3	2	\N	\N
Qzk4EyoPI3	2024-02-16 00:12:31.138+00	2024-02-16 00:12:31.138+00	S6wz0lK0bf	8w7i8C3NnT	2	1	0	4	0	\N	\N
klwOwtefX3	2024-02-16 00:12:31.343+00	2024-02-16 00:12:31.343+00	SFAISec8QF	IybX0eBoO3	1	4	2	0	1	\N	\N
YeFg88lrdH	2024-02-16 00:12:31.552+00	2024-02-16 00:12:31.552+00	HtEtaHBVDN	JRi61dUphq	3	2	2	1	4	\N	\N
WZTByPjSeu	2024-02-16 00:12:31.765+00	2024-02-16 00:12:31.765+00	sHiqaG4iqY	HSEugQ3Ouj	3	1	4	1	0	\N	\N
f9OLSAhTz2	2024-02-16 00:12:32.275+00	2024-02-16 00:12:32.275+00	9223vtvaBd	WnUBBkiDjE	0	4	2	0	3	\N	\N
u1KYRHnl5T	2024-02-16 00:12:32.483+00	2024-02-16 00:12:32.483+00	opW2wQ2bZ8	H40ivltLwZ	4	0	2	1	0	\N	\N
KQbCtCg4ed	2024-02-16 00:12:32.781+00	2024-02-16 00:12:32.781+00	jqDYoPT45X	KCsJ4XR6Dn	1	4	0	4	4	\N	\N
elQBsxdWIG	2024-02-16 00:12:33.09+00	2024-02-16 00:12:33.09+00	dEqAHvPMXA	LgJuu5ABe5	2	0	3	4	4	\N	\N
Ai66yeJ6HY	2024-02-16 00:12:33.397+00	2024-02-16 00:12:33.397+00	5nv19u6KJ2	3P6kmNoY1F	0	3	3	3	2	\N	\N
EfQMugJZ09	2024-02-16 00:12:33.603+00	2024-02-16 00:12:33.603+00	opW2wQ2bZ8	6KvFK8yy1q	2	1	4	3	0	\N	\N
dhobRzZDux	2024-02-16 00:12:33.81+00	2024-02-16 00:12:33.81+00	5nv19u6KJ2	bi1IivsuUB	3	3	4	0	2	\N	\N
tshw1h28TH	2024-02-16 00:12:34.021+00	2024-02-16 00:12:34.021+00	sHiqaG4iqY	UCFo58JaaD	1	1	2	2	0	\N	\N
glzMZCyNyi	2024-02-16 00:12:34.319+00	2024-02-16 00:12:34.319+00	I5RzFRcQ7G	LVYK4mLShP	4	0	4	2	2	\N	\N
RR2iOfhcth	2024-02-16 00:12:34.529+00	2024-02-16 00:12:34.529+00	HtEtaHBVDN	VK3vnSxIy8	4	2	1	2	3	\N	\N
it9qSTmvEE	2024-02-16 00:12:34.742+00	2024-02-16 00:12:34.742+00	RWwLSzreG2	89xRG1afNi	0	4	2	4	1	\N	\N
NDgtACSIDg	2024-02-16 00:12:34.955+00	2024-02-16 00:12:34.955+00	1as6rMOzjQ	AgU9OLJkqz	2	0	2	3	3	\N	\N
jyH9ImUPJZ	2024-02-16 00:12:35.162+00	2024-02-16 00:12:35.162+00	iWxl9obi8w	rKyjwoEIRp	2	0	0	1	2	\N	\N
pETCGJrqAC	2024-02-16 00:12:35.373+00	2024-02-16 00:12:35.373+00	dEqAHvPMXA	JRi61dUphq	1	4	2	3	2	\N	\N
KiXxIAlote	2024-02-16 00:12:35.586+00	2024-02-16 00:12:35.586+00	dZKm0wOhYa	Oahm9sOn1y	4	2	4	0	3	\N	\N
BSChdJSKCh	2024-02-16 00:12:35.856+00	2024-02-16 00:12:35.856+00	adE9nQrDk3	FJOTueDfs2	4	2	1	1	4	\N	\N
sK4GEeRGi3	2024-02-16 00:12:36.067+00	2024-02-16 00:12:36.067+00	adE9nQrDk3	bQpy9LEJWn	0	4	4	1	2	\N	\N
ceUCXLMQdZ	2024-02-16 00:12:36.28+00	2024-02-16 00:12:36.28+00	AsrLUQwxI9	l1Bslv8T2k	3	2	1	0	2	\N	\N
EY6Mw6vK3E	2024-02-16 00:12:36.574+00	2024-02-16 00:12:36.574+00	mQXQWNqxg9	FJOTueDfs2	3	3	3	0	1	\N	\N
n0SCLMTGI5	2024-02-16 00:12:36.784+00	2024-02-16 00:12:36.784+00	dEqAHvPMXA	eEmewy7hPd	4	0	4	2	2	\N	\N
5ZpILPjSAw	2024-02-16 00:12:37.085+00	2024-02-16 00:12:37.085+00	5nv19u6KJ2	WBFeKac0OO	2	1	0	2	0	\N	\N
4xYVSBImwe	2024-02-16 00:12:37.297+00	2024-02-16 00:12:37.297+00	dEqAHvPMXA	fxvABtKCPT	3	4	4	3	1	\N	\N
DtP3pgJjTa	2024-02-16 00:12:37.508+00	2024-02-16 00:12:37.508+00	mAKp5BK7R1	FYXEfIO1zF	4	2	2	0	3	\N	\N
gKlsnLsP3F	2024-02-16 00:12:37.72+00	2024-02-16 00:12:37.72+00	sy1HD51LXT	RBRcyltRSC	2	3	1	3	2	\N	\N
GjAaXHLtZT	2024-02-16 00:12:38.007+00	2024-02-16 00:12:38.007+00	5nv19u6KJ2	o4VD4BWwDt	0	4	3	3	4	\N	\N
HCtADDKEFO	2024-02-16 00:12:38.219+00	2024-02-16 00:12:38.219+00	sy1HD51LXT	P9sBFomftT	4	3	3	2	3	\N	\N
Vyur0JFfR0	2024-02-16 00:12:38.43+00	2024-02-16 00:12:38.43+00	HRhGpJpmb5	IEqTHcohpJ	4	0	0	3	3	\N	\N
tebiGRTDQA	2024-02-16 00:12:38.644+00	2024-02-16 00:12:38.644+00	iWxl9obi8w	qP3EdIVzfB	0	3	4	4	4	\N	\N
qCFxpIEKEs	2024-02-16 00:12:38.929+00	2024-02-16 00:12:38.929+00	jqDYoPT45X	XpUyRlB6FI	1	2	2	2	0	\N	\N
jLWgArH4EL	2024-02-16 00:12:39.14+00	2024-02-16 00:12:39.14+00	AsrLUQwxI9	XSK814B37m	3	2	0	4	1	\N	\N
A4tyO0DHNn	2024-02-16 00:12:39.442+00	2024-02-16 00:12:39.442+00	RWwLSzreG2	HSEugQ3Ouj	1	4	4	4	3	\N	\N
9t9ACZry0y	2024-02-16 00:12:40.054+00	2024-02-16 00:12:40.054+00	HRhGpJpmb5	IybX0eBoO3	3	3	0	1	4	\N	\N
96Tu8eAd5p	2024-02-16 00:12:40.263+00	2024-02-16 00:12:40.263+00	VshUk7eBeK	fxvABtKCPT	3	0	1	0	0	\N	\N
BaqfT5pYwf	2024-02-16 00:12:40.469+00	2024-02-16 00:12:40.469+00	sy1HD51LXT	HSEugQ3Ouj	1	1	3	3	3	\N	\N
JLac959fqB	2024-02-16 00:12:40.675+00	2024-02-16 00:12:40.675+00	5nv19u6KJ2	OQWu2bnHeC	4	2	3	0	4	\N	\N
KisFgOlCP0	2024-02-16 00:12:40.881+00	2024-02-16 00:12:40.881+00	5X202ssb0D	WHvlAGgj6c	3	3	1	4	0	\N	\N
Cs7Vzrg5lS	2024-02-16 00:12:41.085+00	2024-02-16 00:12:41.085+00	1as6rMOzjQ	uABtFsJhJc	0	1	2	3	3	\N	\N
mwWOlDcqXg	2024-02-16 00:12:41.389+00	2024-02-16 00:12:41.389+00	dEqAHvPMXA	6Fo67rhTSP	2	4	4	3	3	\N	\N
EnEMzZmwyW	2024-02-16 00:12:41.602+00	2024-02-16 00:12:41.602+00	1as6rMOzjQ	ThMuD3hYRQ	4	3	4	4	2	\N	\N
4lZVp9Nr1f	2024-02-16 00:12:41.817+00	2024-02-16 00:12:41.817+00	dEqAHvPMXA	CSvk1ycWXk	4	2	1	4	1	\N	\N
YxsGcCAAXZ	2024-02-16 00:12:42.025+00	2024-02-16 00:12:42.025+00	9223vtvaBd	WHvlAGgj6c	0	2	4	3	1	\N	\N
SSTC3oFXLr	2024-02-16 00:12:42.238+00	2024-02-16 00:12:42.238+00	RWwLSzreG2	vwHi602n66	1	0	0	3	4	\N	\N
wzIkV0eMSz	2024-02-16 00:12:42.451+00	2024-02-16 00:12:42.451+00	jqDYoPT45X	G0uU7KQLEt	0	2	0	4	0	\N	\N
8syrvW2RjC	2024-02-16 00:12:42.661+00	2024-02-16 00:12:42.661+00	WKpBp0c8F3	INeptnSdJC	3	4	2	1	0	\N	\N
IAJ9GSzuVp	2024-02-16 00:12:43.024+00	2024-02-16 00:12:43.024+00	sHiqaG4iqY	WBFeKac0OO	4	4	2	1	0	\N	\N
VBmwZAG9WB	2024-02-16 00:12:43.234+00	2024-02-16 00:12:43.234+00	5nv19u6KJ2	l1Bslv8T2k	0	2	2	1	3	\N	\N
Y2pJrWUnMd	2024-02-16 00:12:43.536+00	2024-02-16 00:12:43.536+00	jqDYoPT45X	AgU9OLJkqz	4	3	1	1	2	\N	\N
Y8p1konRbJ	2024-02-16 00:12:43.745+00	2024-02-16 00:12:43.745+00	VshUk7eBeK	E2hBZzDsjO	4	0	4	2	0	\N	\N
FFfTLUdsJv	2024-02-16 00:12:43.954+00	2024-02-16 00:12:43.954+00	NjxsGlPeB4	axyV0Fu7pm	1	0	1	0	3	\N	\N
2lYJkHbqCA	2024-02-16 00:12:44.254+00	2024-02-16 00:12:44.254+00	HRhGpJpmb5	u5FXeeOChJ	4	1	1	1	0	\N	\N
n5aW3CLoGX	2024-02-16 00:12:44.466+00	2024-02-16 00:12:44.466+00	ONgyydfVNz	NY6RE1qgWu	2	3	1	0	1	\N	\N
Fx1yl5jllM	2024-02-16 00:12:44.678+00	2024-02-16 00:12:44.678+00	dZKm0wOhYa	BMLzFMvIT6	0	4	0	4	2	\N	\N
mJTKk5rayh	2024-02-16 00:12:44.89+00	2024-02-16 00:12:44.89+00	iWxl9obi8w	WHvlAGgj6c	1	0	4	2	2	\N	\N
yhLBGTXFph	2024-02-16 00:12:45.48+00	2024-02-16 00:12:45.48+00	mQXQWNqxg9	C7II8dYRPY	3	2	0	0	1	\N	\N
H8LSFOloGP	2024-02-16 00:12:45.688+00	2024-02-16 00:12:45.688+00	ONgyydfVNz	14jGmOAXcg	3	4	4	2	4	\N	\N
d1AcPd8AqR	2024-02-16 00:12:45.895+00	2024-02-16 00:12:45.895+00	VshUk7eBeK	KCsJ4XR6Dn	2	1	4	3	1	\N	\N
6Jn3d0C3Eb	2024-02-16 00:12:46.098+00	2024-02-16 00:12:46.098+00	RWwLSzreG2	IybX0eBoO3	1	2	1	2	4	\N	\N
GlGc4vTT5w	2024-02-16 00:12:46.403+00	2024-02-16 00:12:46.403+00	mQXQWNqxg9	JLhF4VuByh	2	1	3	3	1	\N	\N
N7LSwgIMvd	2024-02-16 00:12:46.614+00	2024-02-16 00:12:46.614+00	5nv19u6KJ2	HLIPwAqO2R	1	4	1	1	1	\N	\N
wDFlybU50f	2024-02-16 00:12:46.824+00	2024-02-16 00:12:46.824+00	SFAISec8QF	0TvWuLoLF5	1	2	4	4	2	\N	\N
zPvgEbKDhy	2024-02-16 00:12:47.033+00	2024-02-16 00:12:47.033+00	NjxsGlPeB4	3P6kmNoY1F	2	0	3	0	1	\N	\N
vzV8PeXV5R	2024-02-16 00:12:47.245+00	2024-02-16 00:12:47.245+00	iWxl9obi8w	E2hBZzDsjO	0	3	2	3	3	\N	\N
jZs5FqNyPo	2024-02-16 00:12:47.459+00	2024-02-16 00:12:47.459+00	sy1HD51LXT	TpGyMZM9BG	3	3	2	4	3	\N	\N
bZhkGW09LV	2024-02-16 00:12:47.669+00	2024-02-16 00:12:47.669+00	jqDYoPT45X	HSEugQ3Ouj	4	1	1	1	2	\N	\N
uw7U39mwgl	2024-02-16 00:12:48.247+00	2024-02-16 00:12:48.247+00	SFAISec8QF	e037qpAih3	3	4	4	1	4	\N	\N
Bi6qec9WCE	2024-02-16 00:12:48.455+00	2024-02-16 00:12:48.455+00	5nv19u6KJ2	C7II8dYRPY	2	1	1	0	4	\N	\N
s7FLBO2nYi	2024-02-16 00:12:48.662+00	2024-02-16 00:12:48.662+00	VshUk7eBeK	H40ivltLwZ	1	4	0	4	1	\N	\N
wVxdOkb2pC	2024-02-16 00:12:49.266+00	2024-02-16 00:12:49.266+00	5X202ssb0D	NBojpORh3G	3	2	0	1	4	\N	\N
gppTCuNUdf	2024-02-16 00:12:49.474+00	2024-02-16 00:12:49.474+00	AsrLUQwxI9	8w7i8C3NnT	3	0	3	3	2	\N	\N
L1F2261MK7	2024-02-16 00:12:49.681+00	2024-02-16 00:12:49.681+00	WKpBp0c8F3	TCkiw6gTDz	4	3	2	2	2	\N	\N
IiYZv1bN9U	2024-02-16 00:12:49.886+00	2024-02-16 00:12:49.886+00	VshUk7eBeK	WnUBBkiDjE	4	0	4	0	4	\N	\N
ViHoA5PcQO	2024-02-16 00:12:50.094+00	2024-02-16 00:12:50.094+00	mQXQWNqxg9	rT0UCBK1bE	4	4	2	2	1	\N	\N
pykPBbABUE	2024-02-16 00:12:50.303+00	2024-02-16 00:12:50.303+00	AsrLUQwxI9	VK3vnSxIy8	1	2	4	2	4	\N	\N
TEyzODHgKM	2024-02-16 00:12:50.511+00	2024-02-16 00:12:50.511+00	mAKp5BK7R1	H40ivltLwZ	4	3	4	4	0	\N	\N
5DigTNVaos	2024-02-16 00:12:50.802+00	2024-02-16 00:12:50.802+00	Otwj7uJwjr	bQpy9LEJWn	0	4	1	2	3	\N	\N
4AvxdoF9Gh	2024-02-16 00:12:51.007+00	2024-02-16 00:12:51.007+00	dEqAHvPMXA	0TvWuLoLF5	0	1	3	0	4	\N	\N
8w5in7HDWd	2024-02-16 00:12:51.42+00	2024-02-16 00:12:51.42+00	sHiqaG4iqY	qP3EdIVzfB	2	0	0	1	2	\N	\N
qiqE5gEDof	2024-02-16 00:12:51.726+00	2024-02-16 00:12:51.726+00	5nv19u6KJ2	o4VD4BWwDt	0	2	2	1	3	\N	\N
whAnBW2nbP	2024-02-16 00:12:51.936+00	2024-02-16 00:12:51.936+00	R2CLtFh5jU	HXtEwLBC7f	0	3	0	1	2	\N	\N
3NZHgPqBZV	2024-02-16 00:12:52.239+00	2024-02-16 00:12:52.239+00	jqDYoPT45X	qEQ9tmLyW9	4	4	1	1	2	\N	\N
Wir1rQQ4oU	2024-02-16 00:12:52.45+00	2024-02-16 00:12:52.45+00	sy1HD51LXT	JZOBDAh12a	2	3	2	2	2	\N	\N
CWo1usVWGu	2024-02-16 00:12:52.657+00	2024-02-16 00:12:52.657+00	adE9nQrDk3	MQfxuw3ERg	2	4	4	0	0	\N	\N
nfs4cHMd8N	2024-02-16 00:12:52.866+00	2024-02-16 00:12:52.866+00	5nv19u6KJ2	JRi61dUphq	1	4	4	1	2	\N	\N
REutbhcsRH	2024-02-16 00:12:53.075+00	2024-02-16 00:12:53.075+00	Otwj7uJwjr	cmxBcanww9	2	2	0	0	3	\N	\N
hgPvfwegi6	2024-02-16 00:12:53.287+00	2024-02-16 00:12:53.287+00	dZKm0wOhYa	y4RkaDbkec	0	2	4	3	1	\N	\N
JUpcB3C5Ly	2024-02-16 00:12:53.503+00	2024-02-16 00:12:53.503+00	5X202ssb0D	WSTLlXDcKl	3	0	1	2	0	\N	\N
aV2bCyyrHS	2024-02-16 00:12:53.776+00	2024-02-16 00:12:53.776+00	WKpBp0c8F3	cmxBcanww9	3	3	4	2	4	\N	\N
c4sdc5cHuN	2024-02-16 00:12:54.083+00	2024-02-16 00:12:54.083+00	sHiqaG4iqY	y4RkaDbkec	3	4	0	1	4	\N	\N
m9hK64Fqew	2024-02-16 00:12:54.695+00	2024-02-16 00:12:54.695+00	I5RzFRcQ7G	cTIjuPjyIa	2	3	1	2	0	\N	\N
ndaGxG4IEX	2024-02-16 00:12:55.309+00	2024-02-16 00:12:55.309+00	Otwj7uJwjr	l1Bslv8T2k	4	0	3	0	0	\N	\N
26jGNI44nU	2024-02-16 00:12:55.515+00	2024-02-16 00:12:55.515+00	NjxsGlPeB4	FJOTueDfs2	4	2	4	4	4	\N	\N
psPqtF4Nlv	2024-02-16 00:12:55.722+00	2024-02-16 00:12:55.722+00	HtEtaHBVDN	VK3vnSxIy8	1	1	2	2	1	\N	\N
1fpDyELa6r	2024-02-16 00:12:55.93+00	2024-02-16 00:12:55.93+00	9223vtvaBd	CSvk1ycWXk	3	0	0	2	3	\N	\N
OiZCg6WXWq	2024-02-16 00:12:56.135+00	2024-02-16 00:12:56.135+00	HRhGpJpmb5	PF8w2gMAdi	2	0	3	3	1	\N	\N
Iv77LAEKhI	2024-02-16 00:12:56.342+00	2024-02-16 00:12:56.342+00	HRhGpJpmb5	P9sBFomftT	1	0	1	3	0	\N	\N
Aw1rDINECo	2024-02-16 00:12:56.641+00	2024-02-16 00:12:56.641+00	1as6rMOzjQ	TZsdmscJ2B	3	1	4	1	0	\N	\N
fpUzBMynBk	2024-02-16 00:12:56.846+00	2024-02-16 00:12:56.846+00	5X202ssb0D	fxvABtKCPT	1	2	1	1	0	\N	\N
oOyhwkyHFD	2024-02-16 00:12:57.152+00	2024-02-16 00:12:57.152+00	SFAISec8QF	PF8w2gMAdi	0	1	4	3	3	\N	\N
TJVy9APqeO	2024-02-16 00:12:57.764+00	2024-02-16 00:12:57.764+00	dZKm0wOhYa	IybX0eBoO3	4	3	4	3	2	\N	\N
JXT5dwON21	2024-02-16 00:12:57.97+00	2024-02-16 00:12:57.97+00	sHiqaG4iqY	TZsdmscJ2B	0	4	1	3	1	\N	\N
AjbYVqBcm8	2024-02-16 00:12:58.276+00	2024-02-16 00:12:58.276+00	sy1HD51LXT	LDrIH1vU8x	3	1	0	3	2	\N	\N
4gtitpS9XC	2024-02-16 00:12:58.482+00	2024-02-16 00:12:58.482+00	WKpBp0c8F3	HSEugQ3Ouj	0	3	0	2	3	\N	\N
yacnEJIYMi	2024-02-16 00:12:59.098+00	2024-02-16 00:12:59.098+00	adE9nQrDk3	m8hjjLVdPS	4	2	2	2	0	\N	\N
BPA19twCBr	2024-02-16 00:12:59.708+00	2024-02-16 00:12:59.708+00	1as6rMOzjQ	WSTLlXDcKl	3	4	3	3	3	\N	\N
eATkhdy7Jd	2024-02-16 00:13:00.02+00	2024-02-16 00:13:00.02+00	5nv19u6KJ2	qZmnAnnPEb	3	2	1	3	3	\N	\N
spSZScMZEM	2024-02-16 00:13:00.327+00	2024-02-16 00:13:00.327+00	S6wz0lK0bf	l1Bslv8T2k	2	1	3	4	3	\N	\N
W5WjwyHAjD	2024-02-16 00:13:00.634+00	2024-02-16 00:13:00.634+00	ONgyydfVNz	3P6kmNoY1F	2	4	0	0	0	\N	\N
DEy0LQBUQC	2024-02-16 00:13:00.941+00	2024-02-16 00:13:00.941+00	RWwLSzreG2	8w7i8C3NnT	2	0	2	0	3	\N	\N
24LiXxxB0E	2024-02-16 00:13:01.141+00	2024-02-16 00:13:01.141+00	iWxl9obi8w	UCFo58JaaD	2	1	2	0	0	\N	\N
k9ccrbKjy8	2024-02-16 00:13:01.344+00	2024-02-16 00:13:01.344+00	SFAISec8QF	o4VD4BWwDt	4	4	2	1	0	\N	\N
rl6lBM2t3v	2024-02-16 00:13:01.554+00	2024-02-16 00:13:01.554+00	dEqAHvPMXA	rKyjwoEIRp	4	2	3	3	3	\N	\N
vzcaigKK7j	2024-02-16 00:13:01.764+00	2024-02-16 00:13:01.764+00	SFAISec8QF	HXtEwLBC7f	2	1	3	2	1	\N	\N
wBLgBeB1Sq	2024-02-16 00:13:01.98+00	2024-02-16 00:13:01.98+00	AsrLUQwxI9	WSTLlXDcKl	3	4	2	0	1	\N	\N
LUVphwMyWI	2024-02-16 00:13:02.188+00	2024-02-16 00:13:02.188+00	S6wz0lK0bf	EmIUBFwx0Z	2	1	3	2	2	\N	\N
CaKzBt1JZf	2024-02-16 00:13:02.39+00	2024-02-16 00:13:02.39+00	RWwLSzreG2	Pa0qBO2rzK	1	4	4	3	4	\N	\N
uY8F9te6RX	2024-02-16 00:13:02.599+00	2024-02-16 00:13:02.599+00	VshUk7eBeK	l1Bslv8T2k	2	1	1	4	0	\N	\N
nqAjxcykDJ	2024-02-16 00:13:02.888+00	2024-02-16 00:13:02.888+00	iWxl9obi8w	9GF3y7LmHV	4	0	1	1	2	\N	\N
3yNW5OaisF	2024-02-16 00:13:03.096+00	2024-02-16 00:13:03.096+00	opW2wQ2bZ8	E2hBZzDsjO	0	1	1	0	2	\N	\N
QBcyFSmmez	2024-02-16 00:13:03.307+00	2024-02-16 00:13:03.307+00	sHiqaG4iqY	P9sBFomftT	1	1	2	2	4	\N	\N
XAp6SYR2Nb	2024-02-16 00:13:03.606+00	2024-02-16 00:13:03.606+00	NjxsGlPeB4	LDrIH1vU8x	3	3	1	4	1	\N	\N
LVgMYyg27b	2024-02-16 00:13:03.914+00	2024-02-16 00:13:03.914+00	5X202ssb0D	Pja6n3yaWZ	1	3	0	4	0	\N	\N
HvYr5m1NW8	2024-02-16 00:13:04.124+00	2024-02-16 00:13:04.124+00	dZKm0wOhYa	eEmewy7hPd	0	2	4	1	3	\N	\N
OxPnLns2UN	2024-02-16 00:13:04.336+00	2024-02-16 00:13:04.336+00	opW2wQ2bZ8	08liHW08uC	3	4	3	0	2	\N	\N
UeFdyjfIjk	2024-02-16 00:13:04.546+00	2024-02-16 00:13:04.546+00	mAKp5BK7R1	Pa0qBO2rzK	1	2	0	1	2	\N	\N
tcUJCGDglV	2024-02-16 00:13:05.14+00	2024-02-16 00:13:05.14+00	mAKp5BK7R1	o90lhsZ7FK	1	1	0	1	4	\N	\N
Pc9Ffl0D47	2024-02-16 00:13:05.448+00	2024-02-16 00:13:05.448+00	sy1HD51LXT	bQ0JOk10eL	0	2	0	2	4	\N	\N
WEsgsv4LVN	2024-02-16 00:13:05.655+00	2024-02-16 00:13:05.655+00	Otwj7uJwjr	jjVdtithcD	3	2	3	0	2	\N	\N
7gzbmUCLnW	2024-02-16 00:13:05.86+00	2024-02-16 00:13:05.86+00	HRhGpJpmb5	14jGmOAXcg	4	4	4	4	4	\N	\N
fM1r8sE2pJ	2024-02-16 00:13:06.161+00	2024-02-16 00:13:06.161+00	HRhGpJpmb5	lEPdiO1EDi	3	1	2	0	4	\N	\N
MD9kf3IIzx	2024-02-16 00:13:06.778+00	2024-02-16 00:13:06.778+00	HRhGpJpmb5	HSEugQ3Ouj	1	0	3	3	0	\N	\N
P0c0eUrrB0	2024-02-16 00:13:06.986+00	2024-02-16 00:13:06.986+00	Otwj7uJwjr	cFtamPA0zH	2	4	2	0	4	\N	\N
GLFM5UqNQD	2024-02-16 00:13:07.192+00	2024-02-16 00:13:07.192+00	RWwLSzreG2	axyV0Fu7pm	3	0	0	4	1	\N	\N
C1U4KqzmHY	2024-02-16 00:13:07.397+00	2024-02-16 00:13:07.397+00	Otwj7uJwjr	rT0UCBK1bE	2	0	1	3	2	\N	\N
c6QvDZYKuB	2024-02-16 00:13:07.7+00	2024-02-16 00:13:07.7+00	NjxsGlPeB4	o90lhsZ7FK	1	4	4	3	2	\N	\N
q3OvaAo9M2	2024-02-16 00:13:08.009+00	2024-02-16 00:13:08.009+00	9223vtvaBd	Pa0qBO2rzK	3	2	3	3	3	\N	\N
jUGTjosxAL	2024-02-16 00:13:08.315+00	2024-02-16 00:13:08.315+00	sHiqaG4iqY	oABNR2FF6S	0	2	2	3	0	\N	\N
7O7juX8tcl	2024-02-16 00:13:08.521+00	2024-02-16 00:13:08.521+00	HtEtaHBVDN	fwLPZZ8YQa	3	0	3	4	2	\N	\N
uQjCNh7BJP	2024-02-16 00:13:08.729+00	2024-02-16 00:13:08.729+00	sy1HD51LXT	bQpy9LEJWn	1	1	0	2	1	\N	\N
tfNCWbeXpX	2024-02-16 00:13:08.938+00	2024-02-16 00:13:08.938+00	adE9nQrDk3	o90lhsZ7FK	4	2	3	2	1	\N	\N
JI1b6uCX8k	2024-02-16 00:13:09.154+00	2024-02-16 00:13:09.154+00	R2CLtFh5jU	RkhjIQJgou	2	3	0	0	2	\N	\N
GV36bAWD5b	2024-02-16 00:13:09.748+00	2024-02-16 00:13:09.748+00	Otwj7uJwjr	TpGyMZM9BG	2	1	4	4	4	\N	\N
reEygjJ6nO	2024-02-16 00:13:09.954+00	2024-02-16 00:13:09.954+00	HtEtaHBVDN	6Fo67rhTSP	3	1	2	0	4	\N	\N
rT1jxEppOR	2024-02-16 00:13:10.162+00	2024-02-16 00:13:10.162+00	iUlyHNFGpG	HSEugQ3Ouj	4	4	1	3	3	\N	\N
qQtIRzHnBB	2024-02-16 00:13:10.369+00	2024-02-16 00:13:10.369+00	iWxl9obi8w	JZOBDAh12a	1	1	3	1	3	\N	\N
xKpDiFE0QN	2024-02-16 00:13:10.578+00	2024-02-16 00:13:10.578+00	R2CLtFh5jU	HLIPwAqO2R	4	4	1	1	1	\N	\N
LECuqozhlM	2024-02-16 00:13:11.175+00	2024-02-16 00:13:11.175+00	RWwLSzreG2	6Fo67rhTSP	2	3	1	4	3	\N	\N
Y3ljTsHYwI	2024-02-16 00:13:11.38+00	2024-02-16 00:13:11.38+00	iWxl9obi8w	H40ivltLwZ	1	3	1	1	3	\N	\N
YGRuH9ta2f	2024-02-16 00:13:11.586+00	2024-02-16 00:13:11.586+00	AsrLUQwxI9	na5crB8ED1	3	1	2	0	4	\N	\N
7zwCBXoObg	2024-02-16 00:13:11.794+00	2024-02-16 00:13:11.794+00	R2CLtFh5jU	8w7i8C3NnT	2	1	2	2	2	\N	\N
KkNh5uWXo1	2024-02-16 00:13:12.104+00	2024-02-16 00:13:12.104+00	jqDYoPT45X	cwVEh0dqfm	0	3	0	1	2	\N	\N
E9ikBiGHFZ	2024-02-16 00:13:12.313+00	2024-02-16 00:13:12.313+00	1as6rMOzjQ	TZsdmscJ2B	1	4	2	4	1	\N	\N
bRW1e5LqKl	2024-02-16 00:13:12.522+00	2024-02-16 00:13:12.522+00	9223vtvaBd	NBojpORh3G	0	3	0	4	1	\N	\N
2eVkDQ75R0	2024-02-16 00:13:12.731+00	2024-02-16 00:13:12.731+00	NjxsGlPeB4	Pa0qBO2rzK	3	1	3	0	4	\N	\N
qY6HHD6hOG	2024-02-16 00:13:12.94+00	2024-02-16 00:13:12.94+00	sHiqaG4iqY	89xRG1afNi	2	1	4	2	0	\N	\N
9lN7YLfjb8	2024-02-16 00:13:13.153+00	2024-02-16 00:13:13.153+00	ONgyydfVNz	G0uU7KQLEt	0	4	4	2	1	\N	\N
yUA0bqXAJH	2024-02-16 00:13:13.369+00	2024-02-16 00:13:13.369+00	1as6rMOzjQ	C7II8dYRPY	1	2	3	0	2	\N	\N
oo6WzzpFAA	2024-02-16 00:13:13.601+00	2024-02-16 00:13:13.601+00	SFAISec8QF	P9sBFomftT	1	3	2	0	1	\N	\N
reAJth9krM	2024-02-16 00:13:13.814+00	2024-02-16 00:13:13.814+00	adE9nQrDk3	Pa0qBO2rzK	0	1	4	3	2	\N	\N
nN7fd5cI8W	2024-02-16 00:13:14.027+00	2024-02-16 00:13:14.027+00	VshUk7eBeK	na5crB8ED1	3	2	0	2	4	\N	\N
SkogeurjrI	2024-02-16 00:13:14.241+00	2024-02-16 00:13:14.241+00	1as6rMOzjQ	XwszrNEEEj	0	1	1	2	2	\N	\N
KgGSYG3vDw	2024-02-16 00:13:14.452+00	2024-02-16 00:13:14.452+00	AsrLUQwxI9	UDXF0qXvDY	1	1	4	2	4	\N	\N
C0rWefxbnD	2024-02-16 00:13:14.663+00	2024-02-16 00:13:14.663+00	S6wz0lK0bf	TpGyMZM9BG	0	1	4	2	2	\N	\N
kWTtMEBbx4	2024-02-16 00:13:14.875+00	2024-02-16 00:13:14.875+00	sy1HD51LXT	TZsdmscJ2B	3	0	0	2	0	\N	\N
k8pGQMjUsK	2024-02-16 00:13:15.092+00	2024-02-16 00:13:15.092+00	sy1HD51LXT	TZsdmscJ2B	1	1	3	3	1	\N	\N
fW88BvxXJL	2024-02-16 00:13:15.302+00	2024-02-16 00:13:15.302+00	SFAISec8QF	o90lhsZ7FK	4	4	0	0	1	\N	\N
KR5ieC7h3q	2024-02-16 00:13:15.513+00	2024-02-16 00:13:15.513+00	SFAISec8QF	na5crB8ED1	4	1	0	2	2	\N	\N
dTs83GDigU	2024-02-16 00:13:15.724+00	2024-02-16 00:13:15.724+00	mQXQWNqxg9	89xRG1afNi	1	1	1	3	3	\N	\N
565174dRuC	2024-02-16 00:13:15.937+00	2024-02-16 00:13:15.937+00	opW2wQ2bZ8	UDXF0qXvDY	3	2	4	1	2	\N	\N
j9wB4AAgi5	2024-02-16 00:13:16.141+00	2024-02-16 00:13:16.141+00	ONgyydfVNz	PF8w2gMAdi	4	1	1	4	1	\N	\N
f4w9eENcxS	2024-02-16 00:13:16.355+00	2024-02-16 00:13:16.355+00	dZKm0wOhYa	qP3EdIVzfB	2	1	1	1	4	\N	\N
8PwrGm50RH	2024-02-16 00:13:16.564+00	2024-02-16 00:13:16.564+00	sHiqaG4iqY	rKyjwoEIRp	2	2	0	2	4	\N	\N
Cao7upj1R5	2024-02-16 00:13:16.816+00	2024-02-16 00:13:16.816+00	WKpBp0c8F3	HLIPwAqO2R	2	2	2	0	4	\N	\N
W1D9B0nKg7	2024-02-16 00:13:17.125+00	2024-02-16 00:13:17.125+00	iUlyHNFGpG	08liHW08uC	1	0	2	2	0	\N	\N
cmAm3VuSFU	2024-02-16 00:13:17.338+00	2024-02-16 00:13:17.338+00	HRhGpJpmb5	uigc7bJBOJ	4	2	0	3	3	\N	\N
ELMsdY1t25	2024-02-16 00:13:17.55+00	2024-02-16 00:13:17.55+00	WKpBp0c8F3	WHvlAGgj6c	0	2	3	0	1	\N	\N
YrJNL59yGr	2024-02-16 00:13:17.841+00	2024-02-16 00:13:17.841+00	VshUk7eBeK	u5FXeeOChJ	2	2	1	4	0	\N	\N
FZqQg3BTLn	2024-02-16 00:13:18.147+00	2024-02-16 00:13:18.147+00	5X202ssb0D	VK3vnSxIy8	0	2	0	2	1	\N	\N
MY6NuDO2OC	2024-02-16 00:13:18.759+00	2024-02-16 00:13:18.759+00	sy1HD51LXT	AgU9OLJkqz	4	3	2	1	3	\N	\N
2y0bd6uPnS	2024-02-16 00:13:18.969+00	2024-02-16 00:13:18.969+00	5X202ssb0D	HXtEwLBC7f	0	2	3	0	2	\N	\N
ZmtbDwQH3F	2024-02-16 00:13:19.27+00	2024-02-16 00:13:19.27+00	adE9nQrDk3	rT0UCBK1bE	3	3	3	3	1	\N	\N
2tOjgW2Ksx	2024-02-16 00:13:19.883+00	2024-02-16 00:13:19.883+00	iUlyHNFGpG	TZsdmscJ2B	3	1	2	0	0	\N	\N
jVc6glLFeR	2024-02-16 00:13:20.089+00	2024-02-16 00:13:20.089+00	iUlyHNFGpG	MQfxuw3ERg	3	1	3	0	3	\N	\N
VCaoq1pJCB	2024-02-16 00:13:20.294+00	2024-02-16 00:13:20.294+00	S6wz0lK0bf	HXtEwLBC7f	0	2	2	2	0	\N	\N
TDyur4D4vw	2024-02-16 00:13:20.507+00	2024-02-16 00:13:20.507+00	VshUk7eBeK	bQ0JOk10eL	0	3	2	2	3	\N	\N
WGryuVIbUH	2024-02-16 00:13:20.716+00	2024-02-16 00:13:20.716+00	AsrLUQwxI9	UDXF0qXvDY	2	4	1	2	1	\N	\N
T2HYCN2qem	2024-02-16 00:13:20.938+00	2024-02-16 00:13:20.938+00	iWxl9obi8w	TpGyMZM9BG	1	4	1	0	3	\N	\N
7cDJzXf4Ih	2024-02-16 00:13:21.142+00	2024-02-16 00:13:21.142+00	dZKm0wOhYa	89xRG1afNi	0	2	3	3	4	\N	\N
WcrPsEYYuH	2024-02-16 00:13:21.35+00	2024-02-16 00:13:21.35+00	5nv19u6KJ2	9GF3y7LmHV	2	3	1	4	3	\N	\N
DLGcEHKZRP	2024-02-16 00:13:21.555+00	2024-02-16 00:13:21.555+00	sy1HD51LXT	3P6kmNoY1F	1	3	4	4	1	\N	\N
zDgAEEFoXD	2024-02-16 00:13:21.762+00	2024-02-16 00:13:21.762+00	WKpBp0c8F3	NBojpORh3G	3	2	3	3	0	\N	\N
oGCPgvMMzE	2024-02-16 00:13:21.963+00	2024-02-16 00:13:21.963+00	dEqAHvPMXA	P9sBFomftT	4	0	0	2	1	\N	\N
3G8YCMEVDo	2024-02-16 00:13:22.163+00	2024-02-16 00:13:22.163+00	5X202ssb0D	6Fo67rhTSP	3	1	4	4	3	\N	\N
p1gtjtTH8J	2024-02-16 00:13:22.525+00	2024-02-16 00:13:22.525+00	opW2wQ2bZ8	y4RkaDbkec	1	3	4	4	1	\N	\N
KZlGweCwQP	2024-02-16 00:13:22.736+00	2024-02-16 00:13:22.736+00	ONgyydfVNz	NY6RE1qgWu	3	3	2	2	0	\N	\N
IWJziMGGMv	2024-02-16 00:13:22.942+00	2024-02-16 00:13:22.942+00	opW2wQ2bZ8	HXtEwLBC7f	0	2	0	2	0	\N	\N
zFG4MRlgha	2024-02-16 00:13:23.148+00	2024-02-16 00:13:23.148+00	SFAISec8QF	3u4B9V4l5K	0	1	1	1	0	\N	\N
vUBY0Dyv91	2024-02-16 00:13:23.421+00	2024-02-16 00:13:23.421+00	NjxsGlPeB4	TZsdmscJ2B	4	4	2	2	1	\N	\N
Ci1dyZO4qU	2024-02-16 00:13:23.633+00	2024-02-16 00:13:23.633+00	opW2wQ2bZ8	UDXF0qXvDY	2	3	0	3	4	\N	\N
erDnrzHsPe	2024-02-16 00:13:23.889+00	2024-02-16 00:13:23.889+00	iWxl9obi8w	CSvk1ycWXk	3	1	0	0	4	\N	\N
MQpFCbov9e	2024-02-16 00:13:24.43+00	2024-02-16 00:13:24.43+00	sHiqaG4iqY	j0dWqP2C2A	3	0	1	2	4	\N	\N
jqgwctExwm	2024-02-16 00:13:24.632+00	2024-02-16 00:13:24.632+00	HRhGpJpmb5	JLhF4VuByh	0	2	4	3	0	\N	\N
5XlLmrOoDq	2024-02-16 00:13:24.851+00	2024-02-16 00:13:24.851+00	mAKp5BK7R1	XwszrNEEEj	2	2	2	4	2	\N	\N
mxBa4WEDO0	2024-02-16 00:13:25.054+00	2024-02-16 00:13:25.054+00	sy1HD51LXT	EmIUBFwx0Z	2	1	3	0	1	\N	\N
idr2bHJzyK	2024-02-16 00:13:25.265+00	2024-02-16 00:13:25.265+00	adE9nQrDk3	jjVdtithcD	3	2	4	2	4	\N	\N
9ez7G6hqkK	2024-02-16 00:13:25.499+00	2024-02-16 00:13:25.499+00	mAKp5BK7R1	Pa0qBO2rzK	3	0	4	2	2	\N	\N
rEyYwCj2nt	2024-02-16 00:13:25.706+00	2024-02-16 00:13:25.706+00	VshUk7eBeK	XpUyRlB6FI	2	3	4	3	1	\N	\N
9VBz0t6Ol6	2024-02-16 00:13:25.91+00	2024-02-16 00:13:25.91+00	5X202ssb0D	JRi61dUphq	2	1	2	0	1	\N	\N
FqDCac0sYO	2024-02-16 00:13:26.115+00	2024-02-16 00:13:26.115+00	adE9nQrDk3	cwVEh0dqfm	1	3	2	3	4	\N	\N
MPuRXXhFr8	2024-02-16 00:13:26.322+00	2024-02-16 00:13:26.322+00	sHiqaG4iqY	MQfxuw3ERg	0	4	3	1	2	\N	\N
iRwbExabP2	2024-02-16 00:13:26.528+00	2024-02-16 00:13:26.528+00	iUlyHNFGpG	UDXF0qXvDY	0	4	1	1	1	\N	\N
PzbCJBgsBl	2024-02-16 00:13:26.737+00	2024-02-16 00:13:26.737+00	I5RzFRcQ7G	14jGmOAXcg	1	1	0	1	2	\N	\N
5DEreOZhL7	2024-02-16 00:13:27.056+00	2024-02-16 00:13:27.056+00	I5RzFRcQ7G	INeptnSdJC	4	0	0	3	1	\N	\N
8tZf8vpOLU	2024-02-16 00:13:27.266+00	2024-02-16 00:13:27.266+00	AsrLUQwxI9	bQ0JOk10eL	2	4	0	1	1	\N	\N
Bv7pE6aGI4	2024-02-16 00:13:27.477+00	2024-02-16 00:13:27.477+00	S6wz0lK0bf	XwWwGnkXNj	2	2	0	1	3	\N	\N
mEUGn2zVNu	2024-02-16 00:13:27.683+00	2024-02-16 00:13:27.683+00	S6wz0lK0bf	lxQA9rtSfY	0	1	2	1	1	\N	\N
e53yqL7lV3	2024-02-16 00:13:27.893+00	2024-02-16 00:13:27.893+00	iWxl9obi8w	WBFeKac0OO	1	3	0	3	2	\N	\N
l4VRLFCUzi	2024-02-16 00:13:28.111+00	2024-02-16 00:13:28.111+00	RWwLSzreG2	FYXEfIO1zF	3	3	4	0	2	\N	\N
InMP6MM9ep	2024-02-16 00:13:28.325+00	2024-02-16 00:13:28.325+00	iUlyHNFGpG	fxvABtKCPT	4	4	4	1	0	\N	\N
GhaME5cGF8	2024-02-16 00:13:28.592+00	2024-02-16 00:13:28.592+00	HRhGpJpmb5	fwLPZZ8YQa	0	0	2	0	2	\N	\N
aHDWP0mMS3	2024-02-16 00:13:28.803+00	2024-02-16 00:13:28.803+00	adE9nQrDk3	uABtFsJhJc	1	1	3	3	2	\N	\N
d84e72Su5E	2024-02-16 00:13:29.406+00	2024-02-16 00:13:29.406+00	SFAISec8QF	M0tHrt1GgV	1	3	2	3	0	\N	\N
ERnHGt67kg	2024-02-16 00:13:29.616+00	2024-02-16 00:13:29.616+00	ONgyydfVNz	PF8w2gMAdi	1	1	3	2	4	\N	\N
Jki280k3v2	2024-02-16 00:13:29.829+00	2024-02-16 00:13:29.829+00	jqDYoPT45X	LVYK4mLShP	1	2	4	4	1	\N	\N
uYCIbgmmLJ	2024-02-16 00:13:30.04+00	2024-02-16 00:13:30.04+00	opW2wQ2bZ8	E2hBZzDsjO	2	1	1	1	1	\N	\N
EnaybATMdx	2024-02-16 00:13:30.331+00	2024-02-16 00:13:30.331+00	HtEtaHBVDN	o4VD4BWwDt	3	1	2	4	1	\N	\N
SQfPEg4tMp	2024-02-16 00:13:30.542+00	2024-02-16 00:13:30.542+00	R2CLtFh5jU	KCsJ4XR6Dn	3	0	3	0	3	\N	\N
hYDhlNFwDi	2024-02-16 00:13:30.749+00	2024-02-16 00:13:30.749+00	jqDYoPT45X	AgU9OLJkqz	2	4	2	4	4	\N	\N
jIIzD9PnQF	2024-02-16 00:13:30.957+00	2024-02-16 00:13:30.957+00	HtEtaHBVDN	fxvABtKCPT	0	4	3	2	4	\N	\N
rsqKQUUCLf	2024-02-16 00:13:31.164+00	2024-02-16 00:13:31.164+00	I5RzFRcQ7G	m6g8u0QpTC	1	2	1	2	4	\N	\N
2BHBp8XRHI	2024-02-16 00:13:31.375+00	2024-02-16 00:13:31.375+00	HtEtaHBVDN	qEQ9tmLyW9	0	1	1	4	0	\N	\N
FRNRU6oxaN	2024-02-16 00:13:31.586+00	2024-02-16 00:13:31.586+00	sy1HD51LXT	3P6kmNoY1F	3	1	3	3	4	\N	\N
0C6pX9aa3p	2024-02-16 00:13:31.798+00	2024-02-16 00:13:31.798+00	HtEtaHBVDN	Pa0qBO2rzK	0	0	1	4	3	\N	\N
X6Etu15Gxf	2024-02-16 00:13:32.073+00	2024-02-16 00:13:32.073+00	sHiqaG4iqY	bQpy9LEJWn	3	4	1	2	1	\N	\N
Hfx8POLVBr	2024-02-16 00:13:32.285+00	2024-02-16 00:13:32.285+00	sy1HD51LXT	MQfxuw3ERg	4	4	4	1	2	\N	\N
MQBuQJb2Eq	2024-02-16 00:13:32.497+00	2024-02-16 00:13:32.497+00	VshUk7eBeK	UDXF0qXvDY	4	4	2	0	0	\N	\N
f8g6J0YjtA	2024-02-16 00:13:32.709+00	2024-02-16 00:13:32.709+00	jqDYoPT45X	08liHW08uC	3	4	3	1	3	\N	\N
1wGrEGuBJK	2024-02-16 00:13:32.921+00	2024-02-16 00:13:32.921+00	sy1HD51LXT	u5FXeeOChJ	0	2	1	3	1	\N	\N
S0CgkH5ypb	2024-02-16 00:13:33.132+00	2024-02-16 00:13:33.132+00	WKpBp0c8F3	y4RkaDbkec	2	0	3	1	4	\N	\N
HtkNfBtLhI	2024-02-16 00:13:33.346+00	2024-02-16 00:13:33.346+00	I5RzFRcQ7G	uABtFsJhJc	4	1	4	3	2	\N	\N
6vHsAKsBFm	2024-02-16 00:13:33.561+00	2024-02-16 00:13:33.561+00	HtEtaHBVDN	yvUod6yLDt	1	4	0	2	3	\N	\N
l5E4MtpazC	2024-02-16 00:13:33.776+00	2024-02-16 00:13:33.776+00	R2CLtFh5jU	CSvk1ycWXk	0	4	4	3	1	\N	\N
PC8YxcTuVW	2024-02-16 00:13:33.991+00	2024-02-16 00:13:33.991+00	HRhGpJpmb5	NY6RE1qgWu	3	4	4	1	0	\N	\N
98Cn5zJmFA	2024-02-16 00:13:34.205+00	2024-02-16 00:13:34.205+00	HtEtaHBVDN	j0dWqP2C2A	2	0	3	0	4	\N	\N
OpQY2AUN8w	2024-02-16 00:13:34.532+00	2024-02-16 00:13:34.532+00	sHiqaG4iqY	lxQA9rtSfY	3	0	0	2	3	\N	\N
vcVPwDqXGJ	2024-02-16 00:13:34.744+00	2024-02-16 00:13:34.744+00	iUlyHNFGpG	TCkiw6gTDz	2	2	4	0	1	\N	\N
tb8t2H7D07	2024-02-16 00:13:34.96+00	2024-02-16 00:13:34.96+00	9223vtvaBd	WSTLlXDcKl	2	1	2	2	2	\N	\N
Wu16tEAoN3	2024-02-16 00:13:35.246+00	2024-02-16 00:13:35.246+00	I5RzFRcQ7G	MQfxuw3ERg	1	4	3	2	4	\N	\N
v4Q9NjWgYY	2024-02-16 00:13:35.863+00	2024-02-16 00:13:35.863+00	sy1HD51LXT	MQfxuw3ERg	2	0	1	3	1	\N	\N
Caoh350c2G	2024-02-16 00:13:36.162+00	2024-02-16 00:13:36.162+00	HtEtaHBVDN	3u4B9V4l5K	3	3	0	1	4	\N	\N
H8GSAHDiSm	2024-02-16 00:13:36.477+00	2024-02-16 00:13:36.477+00	Otwj7uJwjr	RkhjIQJgou	4	4	0	1	2	\N	\N
aMue4KYDaX	2024-02-16 00:13:36.689+00	2024-02-16 00:13:36.689+00	mAKp5BK7R1	axyV0Fu7pm	0	0	4	1	3	\N	\N
NzIEV2uAiU	2024-02-16 00:13:36.903+00	2024-02-16 00:13:36.903+00	sHiqaG4iqY	bQ0JOk10eL	4	4	4	3	0	\N	\N
somT7FATY0	2024-02-16 00:13:37.194+00	2024-02-16 00:13:37.194+00	RWwLSzreG2	IEqTHcohpJ	1	4	1	1	4	\N	\N
ODZy9g6aiH	2024-02-16 00:13:37.407+00	2024-02-16 00:13:37.407+00	R2CLtFh5jU	C7II8dYRPY	1	1	4	1	1	\N	\N
BCBI5XclB8	2024-02-16 00:13:37.618+00	2024-02-16 00:13:37.618+00	R2CLtFh5jU	rKyjwoEIRp	0	3	4	1	4	\N	\N
Bs5b6P01b2	2024-02-16 00:13:37.829+00	2024-02-16 00:13:37.829+00	mQXQWNqxg9	jHqCpA1nWb	2	1	0	1	4	\N	\N
jIH085KFK5	2024-02-16 00:13:38.114+00	2024-02-16 00:13:38.114+00	5X202ssb0D	XSK814B37m	3	1	0	3	1	\N	\N
Y9EwtwQje5	2024-02-16 00:13:38.423+00	2024-02-16 00:13:38.423+00	R2CLtFh5jU	HLIPwAqO2R	2	2	1	0	3	\N	\N
CaMVRFX3KN	2024-02-16 00:13:38.635+00	2024-02-16 00:13:38.635+00	9223vtvaBd	fKTSJPdUi9	2	1	1	2	1	\N	\N
E7OcXtdbPC	2024-02-16 00:13:38.935+00	2024-02-16 00:13:38.935+00	ONgyydfVNz	WBFeKac0OO	3	2	1	3	3	\N	\N
mkJqycYWX1	2024-02-16 00:13:39.148+00	2024-02-16 00:13:39.148+00	5nv19u6KJ2	JRi61dUphq	4	1	2	0	1	\N	\N
bvmtIp1n6B	2024-02-16 00:13:39.362+00	2024-02-16 00:13:39.362+00	AsrLUQwxI9	oABNR2FF6S	0	1	0	3	2	\N	\N
2P7O2aC5UV	2024-02-16 00:13:39.958+00	2024-02-16 00:13:39.958+00	dEqAHvPMXA	WnUBBkiDjE	2	2	4	4	1	\N	\N
YGD20agqoW	2024-02-16 00:13:40.17+00	2024-02-16 00:13:40.17+00	sy1HD51LXT	PF8w2gMAdi	2	0	3	0	0	\N	\N
yiFeJIydXe	2024-02-16 00:13:40.38+00	2024-02-16 00:13:40.38+00	SFAISec8QF	uigc7bJBOJ	1	1	1	3	3	\N	\N
NcqpAdXVfd	2024-02-16 00:13:40.982+00	2024-02-16 00:13:40.982+00	mQXQWNqxg9	XSK814B37m	2	4	3	1	3	\N	\N
Eu9NpNucEO	2024-02-16 00:13:41.188+00	2024-02-16 00:13:41.188+00	SFAISec8QF	rT0UCBK1bE	2	4	4	3	0	\N	\N
9XyC6OmZQG	2024-02-16 00:13:41.395+00	2024-02-16 00:13:41.395+00	5nv19u6KJ2	RkhjIQJgou	1	2	0	2	4	\N	\N
d4ZAgpGVsB	2024-02-16 00:13:41.602+00	2024-02-16 00:13:41.602+00	5nv19u6KJ2	y4RkaDbkec	4	2	1	2	3	\N	\N
PFeJmJX7q4	2024-02-16 00:13:41.813+00	2024-02-16 00:13:41.813+00	NjxsGlPeB4	TZsdmscJ2B	1	1	4	3	0	\N	\N
npqAIyF852	2024-02-16 00:13:42.024+00	2024-02-16 00:13:42.024+00	S6wz0lK0bf	MQfxuw3ERg	1	1	4	4	1	\N	\N
Yv9XKVegf5	2024-02-16 00:13:42.234+00	2024-02-16 00:13:42.234+00	mAKp5BK7R1	TZsdmscJ2B	3	1	0	0	4	\N	\N
n9aFDkVvIP	2024-02-16 00:13:42.441+00	2024-02-16 00:13:42.441+00	AsrLUQwxI9	Gl96vGdYHM	2	2	3	0	0	\N	\N
U71Y7njZtt	2024-02-16 00:13:42.652+00	2024-02-16 00:13:42.652+00	AsrLUQwxI9	j0dWqP2C2A	4	4	2	1	0	\N	\N
SgGSvRYwyr	2024-02-16 00:13:42.866+00	2024-02-16 00:13:42.866+00	mAKp5BK7R1	Gl96vGdYHM	4	4	0	4	4	\N	\N
nc1WqwBG5N	2024-02-16 00:13:43.132+00	2024-02-16 00:13:43.132+00	WKpBp0c8F3	fxvABtKCPT	3	2	3	4	2	\N	\N
G14IuWkB4k	2024-02-16 00:13:43.743+00	2024-02-16 00:13:43.743+00	I5RzFRcQ7G	WnUBBkiDjE	1	2	3	1	1	\N	\N
dHGcKX59IE	2024-02-16 00:13:44.051+00	2024-02-16 00:13:44.051+00	dZKm0wOhYa	UDXF0qXvDY	4	3	1	2	2	\N	\N
viuLYA1fHz	2024-02-16 00:13:44.358+00	2024-02-16 00:13:44.358+00	HtEtaHBVDN	LVYK4mLShP	4	3	1	1	1	\N	\N
V0KjjIAovO	2024-02-16 00:13:44.569+00	2024-02-16 00:13:44.569+00	sy1HD51LXT	ThMuD3hYRQ	1	3	1	3	3	\N	\N
EJBx4S3TX8	2024-02-16 00:13:44.776+00	2024-02-16 00:13:44.776+00	I5RzFRcQ7G	8w7i8C3NnT	2	2	0	1	0	\N	\N
04tFwKUEcp	2024-02-16 00:13:45.383+00	2024-02-16 00:13:45.383+00	I5RzFRcQ7G	WSTLlXDcKl	1	1	0	0	1	\N	\N
mDhnwSHbP3	2024-02-16 00:13:45.994+00	2024-02-16 00:13:45.994+00	9223vtvaBd	89xRG1afNi	3	0	1	0	4	\N	\N
vqWso76Ao5	2024-02-16 00:13:46.202+00	2024-02-16 00:13:46.202+00	AsrLUQwxI9	fKTSJPdUi9	2	2	1	2	0	\N	\N
7ujlXoMUQk	2024-02-16 00:13:46.411+00	2024-02-16 00:13:46.411+00	sHiqaG4iqY	cwVEh0dqfm	0	0	2	1	2	\N	\N
Q9uaB9CmYe	2024-02-16 00:13:46.713+00	2024-02-16 00:13:46.713+00	I5RzFRcQ7G	m6g8u0QpTC	3	4	0	4	3	\N	\N
0N6W8EyWXA	2024-02-16 00:13:47.27+00	2024-02-16 00:13:47.27+00	R2CLtFh5jU	JZOBDAh12a	4	3	4	4	4	\N	\N
gU8DdZtyIy	2024-02-16 00:13:47.479+00	2024-02-16 00:13:47.479+00	dZKm0wOhYa	Pja6n3yaWZ	4	0	2	3	0	\N	\N
rHxN4EpUr7	2024-02-16 00:13:47.738+00	2024-02-16 00:13:47.738+00	iWxl9obi8w	qP3EdIVzfB	4	3	1	0	2	\N	\N
lk3cvt0iUw	2024-02-16 00:13:48.046+00	2024-02-16 00:13:48.046+00	ONgyydfVNz	rKyjwoEIRp	3	3	4	2	0	\N	\N
EJo8vyFgFV	2024-02-16 00:13:48.255+00	2024-02-16 00:13:48.255+00	VshUk7eBeK	j0dWqP2C2A	4	0	2	4	3	\N	\N
t8BR7SjhSE	2024-02-16 00:13:48.464+00	2024-02-16 00:13:48.464+00	I5RzFRcQ7G	axyV0Fu7pm	3	1	0	1	1	\N	\N
wzXmjbOCr7	2024-02-16 00:13:48.762+00	2024-02-16 00:13:48.762+00	ONgyydfVNz	fwLPZZ8YQa	1	1	3	2	4	\N	\N
70XEMbmFNf	2024-02-16 00:13:48.974+00	2024-02-16 00:13:48.974+00	opW2wQ2bZ8	cTIjuPjyIa	1	4	1	2	3	\N	\N
0dABaGyMQI	2024-02-16 00:13:49.187+00	2024-02-16 00:13:49.187+00	VshUk7eBeK	rKyjwoEIRp	4	2	3	4	3	\N	\N
OTFn8hHqfN	2024-02-16 00:13:49.399+00	2024-02-16 00:13:49.399+00	1as6rMOzjQ	qEQ9tmLyW9	3	2	3	1	4	\N	\N
nFlVfhfmMJ	2024-02-16 00:13:49.686+00	2024-02-16 00:13:49.686+00	5X202ssb0D	RkhjIQJgou	2	3	2	0	3	\N	\N
sovBjA8KNR	2024-02-16 00:13:49.9+00	2024-02-16 00:13:49.9+00	dZKm0wOhYa	j0dWqP2C2A	0	3	3	1	4	\N	\N
sK9ZocLZIf	2024-02-16 00:13:50.198+00	2024-02-16 00:13:50.198+00	jqDYoPT45X	o4VD4BWwDt	0	1	0	2	2	\N	\N
YaDP8Z5hrT	2024-02-16 00:13:50.809+00	2024-02-16 00:13:50.809+00	1as6rMOzjQ	m8hjjLVdPS	1	0	2	3	1	\N	\N
8Rf47JkPCa	2024-02-16 00:13:51.111+00	2024-02-16 00:13:51.111+00	AsrLUQwxI9	y4RkaDbkec	4	4	1	3	4	\N	\N
lfvJxnrpEY	2024-02-16 00:13:51.321+00	2024-02-16 00:13:51.321+00	S6wz0lK0bf	bQpy9LEJWn	4	0	2	1	4	\N	\N
Ayd1ZN4VwO	2024-02-16 00:13:51.628+00	2024-02-16 00:13:51.628+00	dEqAHvPMXA	UCFo58JaaD	4	2	4	1	3	\N	\N
tzWmuueMZu	2024-02-16 00:13:52.242+00	2024-02-16 00:13:52.242+00	RWwLSzreG2	qP3EdIVzfB	2	3	2	3	3	\N	\N
WesQXQsYAk	2024-02-16 00:13:52.449+00	2024-02-16 00:13:52.449+00	dZKm0wOhYa	IybX0eBoO3	2	4	3	4	3	\N	\N
bFiwAzmw2u	2024-02-16 00:13:52.658+00	2024-02-16 00:13:52.658+00	HRhGpJpmb5	MQfxuw3ERg	4	1	1	1	2	\N	\N
SHX4bqDH2u	2024-02-16 00:13:52.867+00	2024-02-16 00:13:52.867+00	iWxl9obi8w	NY6RE1qgWu	0	4	0	3	0	\N	\N
O5G0Hl6Ftg	2024-02-16 00:13:53.268+00	2024-02-16 00:13:53.268+00	RWwLSzreG2	cFtamPA0zH	2	3	1	4	3	\N	\N
fCzZMu8DFf	2024-02-16 00:13:53.478+00	2024-02-16 00:13:53.478+00	9223vtvaBd	u5FXeeOChJ	3	0	1	4	0	\N	\N
WPOO1Ea7FW	2024-02-16 00:13:53.689+00	2024-02-16 00:13:53.689+00	Otwj7uJwjr	RkhjIQJgou	0	1	3	0	4	\N	\N
6T0kEIbpb4	2024-02-16 00:13:53.902+00	2024-02-16 00:13:53.902+00	WKpBp0c8F3	D0A6GLdsDM	4	1	3	1	3	\N	\N
ZNOroeWGDi	2024-02-16 00:13:54.597+00	2024-02-16 00:13:54.597+00	I5RzFRcQ7G	AgU9OLJkqz	2	2	0	3	2	\N	\N
9cHhDQub2F	2024-02-16 00:13:54.806+00	2024-02-16 00:13:54.806+00	opW2wQ2bZ8	uigc7bJBOJ	4	4	0	2	0	\N	\N
IbrT77194h	2024-02-16 00:13:55.42+00	2024-02-16 00:13:55.42+00	iWxl9obi8w	l1Bslv8T2k	0	3	2	2	2	\N	\N
GqiQMB3ynP	2024-02-16 00:13:56.035+00	2024-02-16 00:13:56.035+00	NjxsGlPeB4	qP3EdIVzfB	1	0	0	0	3	\N	\N
HjDnUtO8aw	2024-02-16 00:13:56.245+00	2024-02-16 00:13:56.245+00	WKpBp0c8F3	3u4B9V4l5K	4	0	2	4	2	\N	\N
S2mviLWOuT	2024-02-16 00:13:56.555+00	2024-02-16 00:13:56.555+00	1as6rMOzjQ	D0A6GLdsDM	0	4	2	0	2	\N	\N
Gfq1YPxmf0	2024-02-16 00:13:56.765+00	2024-02-16 00:13:56.765+00	RWwLSzreG2	LDrIH1vU8x	3	4	3	0	2	\N	\N
SYHMgCR4H5	2024-02-16 00:13:56.974+00	2024-02-16 00:13:56.974+00	5nv19u6KJ2	OQWu2bnHeC	0	1	2	4	4	\N	\N
d0ucKEy4j4	2024-02-16 00:13:57.182+00	2024-02-16 00:13:57.182+00	iWxl9obi8w	WBFeKac0OO	3	2	4	3	2	\N	\N
8PELDpvC4r	2024-02-16 00:13:57.467+00	2024-02-16 00:13:57.467+00	S6wz0lK0bf	XpUyRlB6FI	2	3	4	4	4	\N	\N
ZNbjK5G5Fi	2024-02-16 00:13:57.678+00	2024-02-16 00:13:57.678+00	iWxl9obi8w	tCIEnLLcUc	0	2	3	3	2	\N	\N
SqWd9nHsIF	2024-02-16 00:13:58.287+00	2024-02-16 00:13:58.287+00	mQXQWNqxg9	M0tHrt1GgV	2	1	1	3	4	\N	\N
ZsY4u4srTJ	2024-02-16 00:13:58.592+00	2024-02-16 00:13:58.592+00	5X202ssb0D	H40ivltLwZ	3	4	4	3	0	\N	\N
tuYZV9j48X	2024-02-16 00:13:58.803+00	2024-02-16 00:13:58.803+00	9223vtvaBd	j0dWqP2C2A	3	3	4	0	4	\N	\N
dKP5PctD5y	2024-02-16 00:13:59.105+00	2024-02-16 00:13:59.105+00	5X202ssb0D	8w7i8C3NnT	3	1	2	0	2	\N	\N
bixN3RlkB8	2024-02-16 00:13:59.718+00	2024-02-16 00:13:59.718+00	S6wz0lK0bf	m6g8u0QpTC	0	4	4	1	0	\N	\N
AcntFYBokd	2024-02-16 00:14:00.145+00	2024-02-16 00:14:00.145+00	dEqAHvPMXA	UDXF0qXvDY	2	1	4	2	1	\N	\N
RZnSiQvryh	2024-02-16 00:14:00.352+00	2024-02-16 00:14:00.352+00	HRhGpJpmb5	6KvFK8yy1q	0	2	0	0	1	\N	\N
fR4oEChzKD	2024-02-16 00:14:00.562+00	2024-02-16 00:14:00.562+00	dEqAHvPMXA	y4RkaDbkec	0	1	1	2	0	\N	\N
EGLcJB3kNs	2024-02-16 00:14:00.769+00	2024-02-16 00:14:00.769+00	sHiqaG4iqY	JZOBDAh12a	1	1	3	3	3	\N	\N
GRTflhTlHM	2024-02-16 00:14:01.05+00	2024-02-16 00:14:01.05+00	NjxsGlPeB4	Pa0qBO2rzK	4	0	0	2	2	\N	\N
pytJujTUiB	2024-02-16 00:14:01.766+00	2024-02-16 00:14:01.766+00	iWxl9obi8w	cwVEh0dqfm	0	3	4	3	3	\N	\N
uPBOqVmmo9	2024-02-16 00:14:01.974+00	2024-02-16 00:14:01.974+00	NjxsGlPeB4	LgJuu5ABe5	1	1	0	0	1	\N	\N
mp8mncM8SH	2024-02-16 00:14:02.687+00	2024-02-16 00:14:02.687+00	iWxl9obi8w	uABtFsJhJc	3	3	4	3	3	\N	\N
XQ4XYIsFYr	2024-02-16 00:14:03.404+00	2024-02-16 00:14:03.404+00	sy1HD51LXT	JRi61dUphq	3	2	2	4	1	\N	\N
BSW3C5c6VF	2024-02-16 00:14:03.61+00	2024-02-16 00:14:03.61+00	iUlyHNFGpG	LgJuu5ABe5	4	0	4	3	4	\N	\N
q2FwMt9ULr	2024-02-16 00:14:03.819+00	2024-02-16 00:14:03.819+00	mQXQWNqxg9	BMLzFMvIT6	2	0	1	0	1	\N	\N
NxYgEizbIZ	2024-02-16 00:14:04.027+00	2024-02-16 00:14:04.027+00	I5RzFRcQ7G	INeptnSdJC	1	1	4	3	1	\N	\N
sGDBhFebGB	2024-02-16 00:14:04.238+00	2024-02-16 00:14:04.238+00	Otwj7uJwjr	cFtamPA0zH	2	2	2	0	0	\N	\N
UcJWyFCHuy	2024-02-16 00:14:04.447+00	2024-02-16 00:14:04.447+00	jqDYoPT45X	G0uU7KQLEt	4	0	0	3	3	\N	\N
rd7DXIKnAH	2024-02-16 00:14:04.654+00	2024-02-16 00:14:04.654+00	HtEtaHBVDN	XSK814B37m	2	0	2	3	0	\N	\N
jH22BysEJq	2024-02-16 00:14:05.249+00	2024-02-16 00:14:05.249+00	jqDYoPT45X	JLhF4VuByh	4	4	2	3	0	\N	\N
nhBR0e3oE0	2024-02-16 00:14:05.457+00	2024-02-16 00:14:05.457+00	HRhGpJpmb5	lxQA9rtSfY	3	0	1	0	1	\N	\N
yGQNBdPazC	2024-02-16 00:14:05.664+00	2024-02-16 00:14:05.664+00	RWwLSzreG2	IybX0eBoO3	0	4	4	3	1	\N	\N
wBOkxiHieM	2024-02-16 00:14:05.873+00	2024-02-16 00:14:05.873+00	Otwj7uJwjr	HSEugQ3Ouj	1	3	4	1	2	\N	\N
MpWmPcwYSt	2024-02-16 00:14:06.166+00	2024-02-16 00:14:06.166+00	iWxl9obi8w	KCsJ4XR6Dn	1	0	0	0	0	\N	\N
HF2xdoiytE	2024-02-16 00:14:06.376+00	2024-02-16 00:14:06.376+00	AsrLUQwxI9	0TvWuLoLF5	0	2	4	3	0	\N	\N
HBzCCv7IKD	2024-02-16 00:14:06.99+00	2024-02-16 00:14:06.99+00	iUlyHNFGpG	EmIUBFwx0Z	0	2	4	1	4	\N	\N
r6iPg78jfQ	2024-02-16 00:14:07.201+00	2024-02-16 00:14:07.201+00	iWxl9obi8w	ThMuD3hYRQ	3	3	3	3	2	\N	\N
FrHpfM9pwN	2024-02-16 00:14:07.41+00	2024-02-16 00:14:07.41+00	9223vtvaBd	WSTLlXDcKl	0	2	0	1	0	\N	\N
JQhLPcdI2k	2024-02-16 00:14:08.014+00	2024-02-16 00:14:08.014+00	9223vtvaBd	NBojpORh3G	4	0	3	0	1	\N	\N
hY4wD9BGTt	2024-02-16 00:14:08.228+00	2024-02-16 00:14:08.228+00	AsrLUQwxI9	Pa0qBO2rzK	0	1	2	4	0	\N	\N
4qvVfzQ9cz	2024-02-16 00:14:08.831+00	2024-02-16 00:14:08.831+00	WKpBp0c8F3	C7II8dYRPY	1	4	0	3	3	\N	\N
QVEpgjyuLs	2024-02-16 00:14:09.139+00	2024-02-16 00:14:09.139+00	WKpBp0c8F3	XpUyRlB6FI	2	1	4	3	3	\N	\N
aTVJzZfi01	2024-02-16 00:14:09.347+00	2024-02-16 00:14:09.347+00	dZKm0wOhYa	LVYK4mLShP	4	1	0	2	3	\N	\N
ARkkiFHeqs	2024-02-16 00:14:09.555+00	2024-02-16 00:14:09.555+00	S6wz0lK0bf	jHqCpA1nWb	3	3	0	1	1	\N	\N
W5taQL45St	2024-02-16 00:14:09.764+00	2024-02-16 00:14:09.764+00	jqDYoPT45X	JZOBDAh12a	4	1	3	0	3	\N	\N
XXIB1UVyjI	2024-02-16 00:14:10.367+00	2024-02-16 00:14:10.367+00	iUlyHNFGpG	OQWu2bnHeC	4	4	2	1	0	\N	\N
iz2jOe0iSh	2024-02-16 00:14:10.982+00	2024-02-16 00:14:10.982+00	HtEtaHBVDN	rT0UCBK1bE	1	3	3	0	3	\N	\N
SAjsyJoq11	2024-02-16 00:14:11.596+00	2024-02-16 00:14:11.596+00	opW2wQ2bZ8	qP3EdIVzfB	1	3	1	3	1	\N	\N
cqfQEDoNee	2024-02-16 00:14:11.903+00	2024-02-16 00:14:11.903+00	NjxsGlPeB4	JRi61dUphq	0	3	4	0	1	\N	\N
MzqaSBEy8v	2024-02-16 00:14:12.517+00	2024-02-16 00:14:12.517+00	WKpBp0c8F3	FYXEfIO1zF	0	1	3	0	1	\N	\N
rZe6igrmSs	2024-02-16 00:14:12.763+00	2024-02-16 00:14:12.763+00	jqDYoPT45X	qZmnAnnPEb	4	0	3	0	4	\N	\N
cvA23jtl0L	2024-02-16 00:14:13.03+00	2024-02-16 00:14:13.03+00	HRhGpJpmb5	vwHi602n66	2	2	4	3	4	\N	\N
YZ56lafaTD	2024-02-16 00:14:13.336+00	2024-02-16 00:14:13.336+00	mAKp5BK7R1	e037qpAih3	0	2	4	4	0	\N	\N
65a6Fj5wfQ	2024-02-16 00:14:13.541+00	2024-02-16 00:14:13.541+00	5X202ssb0D	IEqTHcohpJ	1	4	1	3	2	\N	\N
pqC5dgBKFG	2024-02-16 00:14:14.155+00	2024-02-16 00:14:14.155+00	sHiqaG4iqY	HXtEwLBC7f	3	2	4	4	4	\N	\N
Ka39YSPvrg	2024-02-16 00:14:14.771+00	2024-02-16 00:14:14.771+00	S6wz0lK0bf	14jGmOAXcg	4	3	2	4	4	\N	\N
2KDy1GdIQt	2024-02-16 00:14:14.976+00	2024-02-16 00:14:14.976+00	1as6rMOzjQ	8w7i8C3NnT	2	0	3	3	0	\N	\N
8G4ALdp2DK	2024-02-16 00:14:15.185+00	2024-02-16 00:14:15.185+00	mAKp5BK7R1	D0A6GLdsDM	0	4	1	3	0	\N	\N
urhERMi9h0	2024-02-16 00:14:15.394+00	2024-02-16 00:14:15.394+00	ONgyydfVNz	cmxBcanww9	3	2	2	1	3	\N	\N
ZPo8jb6njY	2024-02-16 00:14:15.605+00	2024-02-16 00:14:15.605+00	R2CLtFh5jU	JLhF4VuByh	2	2	3	4	4	\N	\N
qfmh4iLDlW	2024-02-16 00:14:15.896+00	2024-02-16 00:14:15.896+00	I5RzFRcQ7G	qEQ9tmLyW9	4	4	4	4	2	\N	\N
YVSvcMmRbq	2024-02-16 00:14:16.098+00	2024-02-16 00:14:16.098+00	AsrLUQwxI9	fKTSJPdUi9	0	1	3	2	3	\N	\N
KciZQB3Zx1	2024-02-16 00:14:16.307+00	2024-02-16 00:14:16.307+00	adE9nQrDk3	LDrIH1vU8x	2	3	2	0	4	\N	\N
BeGTg41mxY	2024-02-16 00:14:16.616+00	2024-02-16 00:14:16.616+00	S6wz0lK0bf	Gl96vGdYHM	4	0	3	2	4	\N	\N
x7LjCURuIf	2024-02-16 00:14:16.827+00	2024-02-16 00:14:16.827+00	sy1HD51LXT	AgU9OLJkqz	4	1	3	3	2	\N	\N
xrg4jdSc4W	2024-02-16 00:14:17.04+00	2024-02-16 00:14:17.04+00	Otwj7uJwjr	AgU9OLJkqz	1	2	3	3	4	\N	\N
gf9Rs7rJ9z	2024-02-16 00:14:17.249+00	2024-02-16 00:14:17.249+00	AsrLUQwxI9	XwszrNEEEj	4	1	2	2	3	\N	\N
a95vaun8Wr	2024-02-16 00:14:17.46+00	2024-02-16 00:14:17.46+00	iWxl9obi8w	ThMuD3hYRQ	1	0	2	1	2	\N	\N
CFLVar3x0m	2024-02-16 00:14:17.743+00	2024-02-16 00:14:17.743+00	dZKm0wOhYa	3P6kmNoY1F	1	0	1	0	3	\N	\N
zdy3PIvv5v	2024-02-16 00:14:18.05+00	2024-02-16 00:14:18.05+00	1as6rMOzjQ	BMLzFMvIT6	3	2	1	1	4	\N	\N
pJuQzCeEC4	2024-02-16 00:14:18.357+00	2024-02-16 00:14:18.357+00	I5RzFRcQ7G	INeptnSdJC	2	0	1	3	2	\N	\N
q1kPsqkaDJ	2024-02-16 00:14:18.567+00	2024-02-16 00:14:18.567+00	jqDYoPT45X	XwWwGnkXNj	0	2	1	0	3	\N	\N
bj8MgvMNhk	2024-02-16 00:14:18.778+00	2024-02-16 00:14:18.778+00	VshUk7eBeK	G0uU7KQLEt	3	0	1	2	4	\N	\N
LUPDhp5vfE	2024-02-16 00:14:18.992+00	2024-02-16 00:14:18.992+00	RWwLSzreG2	qEQ9tmLyW9	3	4	4	0	0	\N	\N
DvvD0IN699	2024-02-16 00:14:19.206+00	2024-02-16 00:14:19.206+00	HtEtaHBVDN	JZOBDAh12a	4	3	1	0	3	\N	\N
mxoC9FoA6y	2024-02-16 00:14:19.891+00	2024-02-16 00:14:19.891+00	RWwLSzreG2	WBFeKac0OO	1	0	0	0	3	\N	\N
LzfUTgJlMO	2024-02-16 00:14:20.096+00	2024-02-16 00:14:20.096+00	adE9nQrDk3	KCsJ4XR6Dn	3	3	1	4	0	\N	\N
aFtwN4APfj	2024-02-16 00:14:20.403+00	2024-02-16 00:14:20.403+00	sy1HD51LXT	fxvABtKCPT	1	3	0	0	3	\N	\N
SmAdHpxwn5	2024-02-16 00:14:20.609+00	2024-02-16 00:14:20.609+00	jqDYoPT45X	TZsdmscJ2B	4	1	4	3	1	\N	\N
zFylny1rB0	2024-02-16 00:14:20.817+00	2024-02-16 00:14:20.817+00	dEqAHvPMXA	m6g8u0QpTC	0	1	2	3	2	\N	\N
QYcyMVOPot	2024-02-16 00:14:21.023+00	2024-02-16 00:14:21.023+00	5nv19u6KJ2	KCsJ4XR6Dn	3	1	1	1	2	\N	\N
M1qnTDlUnt	2024-02-16 00:14:21.255+00	2024-02-16 00:14:21.255+00	NjxsGlPeB4	cFtamPA0zH	2	3	1	3	0	\N	\N
YnVDlHlhHx	2024-02-16 00:14:21.523+00	2024-02-16 00:14:21.523+00	mQXQWNqxg9	m8hjjLVdPS	1	0	2	2	2	\N	\N
q1sAxWUq9k	2024-02-16 00:14:21.734+00	2024-02-16 00:14:21.734+00	R2CLtFh5jU	AgU9OLJkqz	4	1	2	4	2	\N	\N
3FmvZUevR9	2024-02-16 00:14:22.042+00	2024-02-16 00:14:22.042+00	SFAISec8QF	yvUod6yLDt	3	0	3	4	2	\N	\N
IvVBf8XmcX	2024-02-16 00:14:22.254+00	2024-02-16 00:14:22.254+00	HtEtaHBVDN	JRi61dUphq	0	2	4	3	4	\N	\N
9wW1lXo8lB	2024-02-16 00:14:22.464+00	2024-02-16 00:14:22.464+00	1as6rMOzjQ	6KvFK8yy1q	3	3	3	3	2	\N	\N
JyJXlOGhM3	2024-02-16 00:14:22.674+00	2024-02-16 00:14:22.674+00	S6wz0lK0bf	jHqCpA1nWb	2	3	2	3	3	\N	\N
rMyMUxyDLf	2024-02-16 00:14:22.886+00	2024-02-16 00:14:22.886+00	5nv19u6KJ2	oABNR2FF6S	1	2	0	0	4	\N	\N
SVIFH8uuDx	2024-02-16 00:14:23.096+00	2024-02-16 00:14:23.096+00	I5RzFRcQ7G	FJOTueDfs2	4	0	3	1	0	\N	\N
wJ1qVioUMW	2024-02-16 00:14:23.375+00	2024-02-16 00:14:23.375+00	WKpBp0c8F3	u5FXeeOChJ	1	2	0	4	1	\N	\N
WBocMB0jqw	2024-02-16 00:14:23.588+00	2024-02-16 00:14:23.588+00	dEqAHvPMXA	6Fo67rhTSP	4	3	4	0	3	\N	\N
lpKtPRMi4f	2024-02-16 00:14:23.801+00	2024-02-16 00:14:23.801+00	RWwLSzreG2	C7II8dYRPY	0	0	1	2	4	\N	\N
1JcPRqgTs9	2024-02-16 00:14:24.091+00	2024-02-16 00:14:24.091+00	iUlyHNFGpG	AgU9OLJkqz	2	0	0	0	0	\N	\N
7k52cuPgUJ	2024-02-16 00:14:24.302+00	2024-02-16 00:14:24.302+00	iWxl9obi8w	INeptnSdJC	3	4	3	3	0	\N	\N
f7s7yGrElk	2024-02-16 00:14:24.603+00	2024-02-16 00:14:24.603+00	Otwj7uJwjr	0TvWuLoLF5	3	4	3	0	0	\N	\N
k2Fucw10HX	2024-02-16 00:14:24.911+00	2024-02-16 00:14:24.911+00	R2CLtFh5jU	Oahm9sOn1y	3	2	3	0	1	\N	\N
FnsPVzRwsj	2024-02-16 00:14:25.221+00	2024-02-16 00:14:25.221+00	9223vtvaBd	08liHW08uC	3	4	4	1	2	\N	\N
TFjK0ecNLa	2024-02-16 00:14:25.432+00	2024-02-16 00:14:25.432+00	iUlyHNFGpG	cFtamPA0zH	0	4	1	3	0	\N	\N
CGfy5BqKYN	2024-02-16 00:14:25.646+00	2024-02-16 00:14:25.646+00	sHiqaG4iqY	u5FXeeOChJ	2	1	1	3	1	\N	\N
9xCzqYySBB	2024-02-16 00:14:25.929+00	2024-02-16 00:14:25.929+00	5nv19u6KJ2	y4RkaDbkec	3	4	4	2	4	\N	\N
hizYnbzdJi	2024-02-16 00:14:26.242+00	2024-02-16 00:14:26.242+00	AsrLUQwxI9	RBRcyltRSC	3	3	1	0	1	\N	\N
uOAE6u9pKv	2024-02-16 00:14:26.55+00	2024-02-16 00:14:26.55+00	I5RzFRcQ7G	NY6RE1qgWu	1	2	1	4	1	\N	\N
ubIvKmq0g5	2024-02-16 00:14:26.762+00	2024-02-16 00:14:26.762+00	HRhGpJpmb5	XwszrNEEEj	2	0	1	1	1	\N	\N
6uv8cuEUTI	2024-02-16 00:14:27.075+00	2024-02-16 00:14:27.075+00	dZKm0wOhYa	WSTLlXDcKl	0	3	1	2	3	\N	\N
ssWlpEEDj0	2024-02-16 00:14:27.286+00	2024-02-16 00:14:27.286+00	sHiqaG4iqY	BMLzFMvIT6	4	1	1	2	0	\N	\N
JK6EOrvGjN	2024-02-16 00:14:27.496+00	2024-02-16 00:14:27.496+00	5nv19u6KJ2	vwHi602n66	0	1	0	2	1	\N	\N
zu83W5jGv5	2024-02-16 00:14:27.71+00	2024-02-16 00:14:27.71+00	5X202ssb0D	jjVdtithcD	3	4	3	4	0	\N	\N
sylK7W6KDQ	2024-02-16 00:14:27.923+00	2024-02-16 00:14:27.923+00	WKpBp0c8F3	eEmewy7hPd	0	1	0	0	3	\N	\N
nEbRzpzXAp	2024-02-16 00:14:28.135+00	2024-02-16 00:14:28.135+00	I5RzFRcQ7G	jjVdtithcD	2	4	2	2	2	\N	\N
CMY2ocWVje	2024-02-16 00:14:28.346+00	2024-02-16 00:14:28.346+00	mQXQWNqxg9	fxvABtKCPT	4	4	4	4	1	\N	\N
gC5oqjAK1t	2024-02-16 00:14:28.559+00	2024-02-16 00:14:28.559+00	SFAISec8QF	o4VD4BWwDt	4	1	1	2	2	\N	\N
slf2Oya0TY	2024-02-16 00:14:28.803+00	2024-02-16 00:14:28.803+00	adE9nQrDk3	JZOBDAh12a	3	4	3	1	1	\N	\N
nINMBmebvB	2024-02-16 00:14:29.109+00	2024-02-16 00:14:29.109+00	ONgyydfVNz	UCFo58JaaD	3	4	0	2	3	\N	\N
HEIqG5rg5s	2024-02-16 00:14:29.319+00	2024-02-16 00:14:29.319+00	sHiqaG4iqY	KCsJ4XR6Dn	3	4	0	3	4	\N	\N
eU4ojAGOW4	2024-02-16 00:14:29.926+00	2024-02-16 00:14:29.926+00	1as6rMOzjQ	NBojpORh3G	3	2	1	3	4	\N	\N
7nWMjAWvCv	2024-02-16 00:14:30.136+00	2024-02-16 00:14:30.136+00	mQXQWNqxg9	LDrIH1vU8x	4	3	0	4	1	\N	\N
kFGDosrFUS	2024-02-16 00:14:30.744+00	2024-02-16 00:14:30.744+00	VshUk7eBeK	VK3vnSxIy8	2	3	0	2	1	\N	\N
BPEW8XmPaP	2024-02-16 00:14:30.956+00	2024-02-16 00:14:30.956+00	ONgyydfVNz	G0uU7KQLEt	1	1	1	0	0	\N	\N
pieOdhd659	2024-02-16 00:14:31.564+00	2024-02-16 00:14:31.564+00	iWxl9obi8w	bi1IivsuUB	4	4	2	4	4	\N	\N
Jgnxjidfzp	2024-02-16 00:14:31.773+00	2024-02-16 00:14:31.773+00	WKpBp0c8F3	lxQA9rtSfY	0	2	0	4	1	\N	\N
qXPDdA8kQV	2024-02-16 00:14:31.981+00	2024-02-16 00:14:31.981+00	R2CLtFh5jU	RBRcyltRSC	1	0	1	2	0	\N	\N
9EqtoZOnwH	2024-02-16 00:14:32.188+00	2024-02-16 00:14:32.188+00	adE9nQrDk3	yvUod6yLDt	1	2	0	0	1	\N	\N
rJnatWxNbz	2024-02-16 00:14:32.397+00	2024-02-16 00:14:32.397+00	iUlyHNFGpG	qP3EdIVzfB	4	2	2	4	2	\N	\N
hhEkfcXkLS	2024-02-16 00:14:32.607+00	2024-02-16 00:14:32.607+00	sHiqaG4iqY	cwVEh0dqfm	1	1	3	2	0	\N	\N
MA2J2qASlX	2024-02-16 00:14:32.815+00	2024-02-16 00:14:32.815+00	5nv19u6KJ2	LDrIH1vU8x	1	4	4	4	3	\N	\N
9sKqglRwQ6	2024-02-16 00:14:33.024+00	2024-02-16 00:14:33.024+00	R2CLtFh5jU	tCIEnLLcUc	3	0	2	3	4	\N	\N
HNadCG3lB5	2024-02-16 00:14:33.236+00	2024-02-16 00:14:33.236+00	1as6rMOzjQ	M0tHrt1GgV	3	1	1	2	0	\N	\N
G7EWcfCLUR	2024-02-16 00:14:33.818+00	2024-02-16 00:14:33.818+00	dEqAHvPMXA	14jGmOAXcg	4	2	2	3	1	\N	\N
8FARmWBiLO	2024-02-16 00:14:34.026+00	2024-02-16 00:14:34.026+00	adE9nQrDk3	TpGyMZM9BG	2	0	2	4	4	\N	\N
DCDSgpkn4q	2024-02-16 00:14:34.234+00	2024-02-16 00:14:34.234+00	jqDYoPT45X	6Fo67rhTSP	1	1	3	0	2	\N	\N
ztu7ry0JX4	2024-02-16 00:14:34.536+00	2024-02-16 00:14:34.536+00	S6wz0lK0bf	TZsdmscJ2B	3	0	4	4	4	\N	\N
qmZL1aZcHC	2024-02-16 00:14:34.745+00	2024-02-16 00:14:34.745+00	HtEtaHBVDN	CSvk1ycWXk	0	1	3	1	4	\N	\N
pALwBBFiEZ	2024-02-16 00:14:34.953+00	2024-02-16 00:14:34.953+00	adE9nQrDk3	bQpy9LEJWn	1	3	3	2	4	\N	\N
kzG8pTkXmG	2024-02-16 00:14:35.163+00	2024-02-16 00:14:35.163+00	WKpBp0c8F3	u5FXeeOChJ	0	2	0	1	0	\N	\N
ZGEga6umum	2024-02-16 00:14:35.375+00	2024-02-16 00:14:35.375+00	R2CLtFh5jU	bQpy9LEJWn	4	3	0	1	1	\N	\N
L6u3FST1cm	2024-02-16 00:14:35.663+00	2024-02-16 00:14:35.663+00	Otwj7uJwjr	WSTLlXDcKl	0	0	0	1	1	\N	\N
B07eARgBqU	2024-02-16 00:14:35.875+00	2024-02-16 00:14:35.875+00	NjxsGlPeB4	JRi61dUphq	0	1	0	3	4	\N	\N
5VjplywERi	2024-02-16 00:14:36.084+00	2024-02-16 00:14:36.084+00	jqDYoPT45X	6Fo67rhTSP	1	3	4	2	0	\N	\N
zpb2QTF8km	2024-02-16 00:14:36.379+00	2024-02-16 00:14:36.379+00	dZKm0wOhYa	mMYg4cyd5R	3	0	3	2	2	\N	\N
ABG1XC5MSt	2024-02-16 00:14:36.992+00	2024-02-16 00:14:36.992+00	SFAISec8QF	6KvFK8yy1q	1	3	0	3	4	\N	\N
FSCCwooRA8	2024-02-16 00:14:37.2+00	2024-02-16 00:14:37.2+00	opW2wQ2bZ8	HLIPwAqO2R	3	4	1	4	3	\N	\N
4tMVIqatbc	2024-02-16 00:14:37.409+00	2024-02-16 00:14:37.409+00	WKpBp0c8F3	PF8w2gMAdi	4	0	1	2	1	\N	\N
KMZ3kCcKbk	2024-02-16 00:14:37.616+00	2024-02-16 00:14:37.616+00	iWxl9obi8w	3u4B9V4l5K	0	1	1	2	0	\N	\N
OLj5RTmygt	2024-02-16 00:14:37.823+00	2024-02-16 00:14:37.823+00	mAKp5BK7R1	3u4B9V4l5K	2	3	0	4	1	\N	\N
aPTeF7x6QQ	2024-02-16 00:14:38.033+00	2024-02-16 00:14:38.033+00	mAKp5BK7R1	qP3EdIVzfB	0	3	1	0	2	\N	\N
n8n415uCBt	2024-02-16 00:14:38.243+00	2024-02-16 00:14:38.243+00	Otwj7uJwjr	o4VD4BWwDt	1	0	2	1	1	\N	\N
GyFYfreTI4	2024-02-16 00:14:38.525+00	2024-02-16 00:14:38.525+00	VshUk7eBeK	08liHW08uC	1	4	0	4	0	\N	\N
XYEteaWiLl	2024-02-16 00:14:38.734+00	2024-02-16 00:14:38.734+00	Otwj7uJwjr	KCsJ4XR6Dn	2	3	1	1	0	\N	\N
96ID6lpOqw	2024-02-16 00:14:39.044+00	2024-02-16 00:14:39.044+00	5X202ssb0D	bQ0JOk10eL	3	4	2	0	3	\N	\N
0plfKNccPA	2024-02-16 00:14:39.35+00	2024-02-16 00:14:39.35+00	HtEtaHBVDN	Gl96vGdYHM	4	1	3	3	2	\N	\N
I2Jk63VwO9	2024-02-16 00:14:39.96+00	2024-02-16 00:14:39.96+00	Otwj7uJwjr	D0A6GLdsDM	2	1	3	3	3	\N	\N
63ANkUo5Gv	2024-02-16 00:14:40.575+00	2024-02-16 00:14:40.575+00	sHiqaG4iqY	NBojpORh3G	0	4	2	3	3	\N	\N
WEA5w659KJ	2024-02-16 00:14:41.188+00	2024-02-16 00:14:41.188+00	5nv19u6KJ2	tCIEnLLcUc	1	1	3	2	2	\N	\N
WoPAj6xUaf	2024-02-16 00:14:41.392+00	2024-02-16 00:14:41.392+00	mAKp5BK7R1	lxQA9rtSfY	1	0	0	2	1	\N	\N
XwGn06mVie	2024-02-16 00:14:41.6+00	2024-02-16 00:14:41.6+00	NjxsGlPeB4	9GF3y7LmHV	1	2	1	1	4	\N	\N
cCBMCJeX3Y	2024-02-16 00:14:41.813+00	2024-02-16 00:14:41.813+00	sHiqaG4iqY	o4VD4BWwDt	1	3	0	2	1	\N	\N
WrVMLy9aUG	2024-02-16 00:14:42.021+00	2024-02-16 00:14:42.021+00	iWxl9obi8w	bi1IivsuUB	3	0	1	3	4	\N	\N
AeMPeXmG2W	2024-02-16 00:14:42.228+00	2024-02-16 00:14:42.228+00	S6wz0lK0bf	8w7i8C3NnT	2	2	4	3	0	\N	\N
ZtLHlpVH47	2024-02-16 00:14:42.436+00	2024-02-16 00:14:42.436+00	VshUk7eBeK	HSEugQ3Ouj	0	4	3	4	0	\N	\N
POlqRVQOQr	2024-02-16 00:14:42.644+00	2024-02-16 00:14:42.644+00	Otwj7uJwjr	E2hBZzDsjO	1	4	1	2	4	\N	\N
q9hfnujQIu	2024-02-16 00:14:42.854+00	2024-02-16 00:14:42.854+00	mQXQWNqxg9	HSEugQ3Ouj	2	1	4	3	2	\N	\N
3gvuWGU2e9	2024-02-16 00:14:43.437+00	2024-02-16 00:14:43.437+00	S6wz0lK0bf	6KvFK8yy1q	3	0	2	1	1	\N	\N
JCy8OIpIJC	2024-02-16 00:14:44.055+00	2024-02-16 00:14:44.055+00	S6wz0lK0bf	o4VD4BWwDt	3	4	4	4	4	\N	\N
4EEYrEdCtI	2024-02-16 00:14:44.26+00	2024-02-16 00:14:44.26+00	Otwj7uJwjr	WBFeKac0OO	2	0	0	2	0	\N	\N
mSgGHkqG7D	2024-02-16 00:14:44.875+00	2024-02-16 00:14:44.875+00	NjxsGlPeB4	qZmnAnnPEb	3	3	2	2	1	\N	\N
87Cs8lVeq3	2024-02-16 00:14:45.087+00	2024-02-16 00:14:45.087+00	NjxsGlPeB4	14jGmOAXcg	3	3	0	0	2	\N	\N
mjXnPY4lag	2024-02-16 00:14:45.295+00	2024-02-16 00:14:45.295+00	RWwLSzreG2	JLhF4VuByh	1	2	4	1	1	\N	\N
FdFwRlBJgL	2024-02-16 00:14:45.503+00	2024-02-16 00:14:45.503+00	HRhGpJpmb5	UCFo58JaaD	3	1	3	0	2	\N	\N
jm3tXqenAY	2024-02-16 00:14:45.799+00	2024-02-16 00:14:45.799+00	sHiqaG4iqY	bi1IivsuUB	4	3	0	2	2	\N	\N
5PqH2XZCIQ	2024-02-16 00:14:46.102+00	2024-02-16 00:14:46.102+00	jqDYoPT45X	qEQ9tmLyW9	1	3	0	0	3	\N	\N
qNKrOpR5yc	2024-02-16 00:14:46.308+00	2024-02-16 00:14:46.308+00	iWxl9obi8w	XwWwGnkXNj	0	4	1	4	1	\N	\N
vgwW4KFCw2	2024-02-16 00:14:46.924+00	2024-02-16 00:14:46.924+00	dZKm0wOhYa	mMYg4cyd5R	4	2	0	1	0	\N	\N
N1zaHWGd1t	2024-02-16 00:14:47.186+00	2024-02-16 00:14:47.186+00	RWwLSzreG2	14jGmOAXcg	0	2	2	4	1	\N	\N
8Gv1cjcQjH	2024-02-16 00:14:47.395+00	2024-02-16 00:14:47.395+00	HtEtaHBVDN	3P6kmNoY1F	4	3	4	4	4	\N	\N
r4vxSarMdr	2024-02-16 00:14:47.743+00	2024-02-16 00:14:47.743+00	mQXQWNqxg9	MQfxuw3ERg	0	1	3	0	4	\N	\N
dR2HE6Sz4C	2024-02-16 00:14:47.947+00	2024-02-16 00:14:47.947+00	jqDYoPT45X	H40ivltLwZ	3	1	1	3	2	\N	\N
krknD60tOd	2024-02-16 00:14:48.562+00	2024-02-16 00:14:48.562+00	1as6rMOzjQ	rT0UCBK1bE	0	1	3	4	0	\N	\N
fIRIGDfPAd	2024-02-16 00:14:48.869+00	2024-02-16 00:14:48.869+00	mAKp5BK7R1	fwLPZZ8YQa	2	3	0	3	2	\N	\N
xQBAnV44Tq	2024-02-16 00:14:49.177+00	2024-02-16 00:14:49.177+00	HRhGpJpmb5	cwVEh0dqfm	4	4	4	0	1	\N	\N
ZFIri3cyFD	2024-02-16 00:14:49.385+00	2024-02-16 00:14:49.385+00	dZKm0wOhYa	na5crB8ED1	2	1	1	0	3	\N	\N
OhRorbvUAY	2024-02-16 00:14:49.689+00	2024-02-16 00:14:49.689+00	I5RzFRcQ7G	TZsdmscJ2B	0	1	2	0	4	\N	\N
2yRpVUS2aH	2024-02-16 00:14:49.901+00	2024-02-16 00:14:49.901+00	dEqAHvPMXA	HSEugQ3Ouj	1	2	0	3	4	\N	\N
uxRUbZBKRc	2024-02-16 00:14:50.11+00	2024-02-16 00:14:50.11+00	jqDYoPT45X	3u4B9V4l5K	2	1	4	2	1	\N	\N
WJhZbO8jma	2024-02-16 00:14:50.407+00	2024-02-16 00:14:50.407+00	iUlyHNFGpG	XSK814B37m	2	4	1	0	1	\N	\N
QZ5fcr8DKP	2024-02-16 00:14:50.62+00	2024-02-16 00:14:50.62+00	dEqAHvPMXA	RkhjIQJgou	0	3	2	4	2	\N	\N
o9Yc3xAaeV	2024-02-16 00:14:50.829+00	2024-02-16 00:14:50.829+00	I5RzFRcQ7G	JZOBDAh12a	2	0	4	1	0	\N	\N
QeS4r47TOP	2024-02-16 00:14:51.117+00	2024-02-16 00:14:51.117+00	sHiqaG4iqY	UDXF0qXvDY	4	0	4	4	0	\N	\N
q8WqpIGJjE	2024-02-16 00:14:51.736+00	2024-02-16 00:14:51.736+00	iWxl9obi8w	EmIUBFwx0Z	2	1	0	2	2	\N	\N
1boIsOObOb	2024-02-16 00:14:51.942+00	2024-02-16 00:14:51.942+00	mAKp5BK7R1	P9sBFomftT	4	2	4	1	4	\N	\N
Jl2EqgrUn1	2024-02-16 00:14:52.148+00	2024-02-16 00:14:52.148+00	iUlyHNFGpG	HSEugQ3Ouj	3	4	3	1	1	\N	\N
N3bFNcDhJv	2024-02-16 00:14:52.357+00	2024-02-16 00:14:52.357+00	ONgyydfVNz	uABtFsJhJc	0	4	2	0	4	\N	\N
d6vbHBa8aD	2024-02-16 00:14:52.566+00	2024-02-16 00:14:52.566+00	jqDYoPT45X	fwLPZZ8YQa	4	2	2	3	3	\N	\N
6ZSAA0LEQv	2024-02-16 00:14:52.774+00	2024-02-16 00:14:52.774+00	dEqAHvPMXA	HSEugQ3Ouj	4	3	0	2	4	\N	\N
Dk46anCAL6	2024-02-16 00:14:52.983+00	2024-02-16 00:14:52.983+00	5X202ssb0D	MQfxuw3ERg	3	0	2	3	1	\N	\N
dZQH5mr5ho	2024-02-16 00:14:53.196+00	2024-02-16 00:14:53.196+00	HRhGpJpmb5	ThMuD3hYRQ	0	0	2	0	4	\N	\N
BXdx0ZTclO	2024-02-16 00:14:53.785+00	2024-02-16 00:14:53.785+00	SFAISec8QF	89xRG1afNi	0	4	4	2	3	\N	\N
7fqoSuJed4	2024-02-16 00:14:53.994+00	2024-02-16 00:14:53.994+00	1as6rMOzjQ	qP3EdIVzfB	1	3	2	3	2	\N	\N
PuFJO23gbi	2024-02-16 00:14:54.298+00	2024-02-16 00:14:54.298+00	RWwLSzreG2	C7II8dYRPY	1	3	4	4	3	\N	\N
qcf9C1NEUY	2024-02-16 00:14:54.506+00	2024-02-16 00:14:54.506+00	adE9nQrDk3	TpGyMZM9BG	4	3	4	4	2	\N	\N
p0HEGqY4Xw	2024-02-16 00:14:54.718+00	2024-02-16 00:14:54.718+00	S6wz0lK0bf	fwLPZZ8YQa	3	2	2	0	1	\N	\N
Bpm1ciskBy	2024-02-16 00:14:54.928+00	2024-02-16 00:14:54.928+00	sy1HD51LXT	y4RkaDbkec	0	0	2	2	2	\N	\N
HYNV7vv2Zp	2024-02-16 00:14:55.221+00	2024-02-16 00:14:55.221+00	AsrLUQwxI9	89xRG1afNi	1	3	0	1	0	\N	\N
XjvaElLAtB	2024-02-16 00:14:55.83+00	2024-02-16 00:14:55.83+00	Otwj7uJwjr	cTIjuPjyIa	1	2	2	3	1	\N	\N
VT7MMsvhA7	2024-02-16 00:14:56.14+00	2024-02-16 00:14:56.14+00	dEqAHvPMXA	08liHW08uC	0	4	1	0	3	\N	\N
RlI8BussNS	2024-02-16 00:14:56.346+00	2024-02-16 00:14:56.346+00	NjxsGlPeB4	Gl96vGdYHM	2	4	4	3	1	\N	\N
zlhK6EQmAk	2024-02-16 00:14:56.55+00	2024-02-16 00:14:56.55+00	HRhGpJpmb5	rKyjwoEIRp	2	0	4	1	2	\N	\N
ogVSu51iWx	2024-02-16 00:14:56.756+00	2024-02-16 00:14:56.756+00	dZKm0wOhYa	vwHi602n66	4	4	4	3	0	\N	\N
gDUe3rvMMa	2024-02-16 00:14:57.063+00	2024-02-16 00:14:57.063+00	WKpBp0c8F3	rT0UCBK1bE	2	4	3	2	3	\N	\N
bOde7jtI4Z	2024-02-16 00:14:57.646+00	2024-02-16 00:14:57.646+00	1as6rMOzjQ	EmIUBFwx0Z	1	3	4	1	2	\N	\N
QORr8UA88k	2024-02-16 00:14:57.854+00	2024-02-16 00:14:57.854+00	5X202ssb0D	jjVdtithcD	1	2	0	3	1	\N	\N
IQwztiHZl3	2024-02-16 00:14:58.087+00	2024-02-16 00:14:58.087+00	HtEtaHBVDN	rKyjwoEIRp	3	1	4	3	3	\N	\N
QE2qCGSfQM	2024-02-16 00:14:58.299+00	2024-02-16 00:14:58.299+00	5X202ssb0D	MQfxuw3ERg	1	4	0	3	3	\N	\N
cjxxhCvSqT	2024-02-16 00:14:58.598+00	2024-02-16 00:14:58.598+00	sHiqaG4iqY	e037qpAih3	1	0	4	2	3	\N	\N
l6vlEOmVyh	2024-02-16 00:14:58.905+00	2024-02-16 00:14:58.905+00	iWxl9obi8w	XpUyRlB6FI	2	2	0	2	3	\N	\N
BCu9Oy1Slq	2024-02-16 00:14:59.213+00	2024-02-16 00:14:59.213+00	SFAISec8QF	BMLzFMvIT6	0	3	3	0	4	\N	\N
KiEjZnX6es	2024-02-16 00:14:59.423+00	2024-02-16 00:14:59.423+00	I5RzFRcQ7G	PF8w2gMAdi	2	3	1	1	2	\N	\N
DtTWFNbEjk	2024-02-16 00:14:59.634+00	2024-02-16 00:14:59.634+00	sHiqaG4iqY	vwHi602n66	4	3	4	2	0	\N	\N
kC5SEjaT8e	2024-02-16 00:14:59.839+00	2024-02-16 00:14:59.839+00	5nv19u6KJ2	VK3vnSxIy8	0	1	1	1	3	\N	\N
QUSYkwJiyt	2024-02-16 00:15:00.135+00	2024-02-16 00:15:00.135+00	dEqAHvPMXA	CSvk1ycWXk	3	0	0	2	2	\N	\N
WBZaVT7yet	2024-02-16 00:15:00.344+00	2024-02-16 00:15:00.344+00	I5RzFRcQ7G	WSTLlXDcKl	4	4	4	4	0	\N	\N
qlvtajHHdp	2024-02-16 00:15:00.556+00	2024-02-16 00:15:00.556+00	mQXQWNqxg9	NBojpORh3G	1	2	3	4	1	\N	\N
JYWrMxoFpj	2024-02-16 00:15:00.853+00	2024-02-16 00:15:00.853+00	dZKm0wOhYa	HSEugQ3Ouj	3	2	4	2	1	\N	\N
oo8vCCCQLR	2024-02-16 00:15:01.152+00	2024-02-16 00:15:01.152+00	dEqAHvPMXA	bQpy9LEJWn	0	4	0	2	0	\N	\N
jbtPo5LYXl	2024-02-16 00:15:01.363+00	2024-02-16 00:15:01.363+00	1as6rMOzjQ	Oahm9sOn1y	3	3	2	3	3	\N	\N
0DoCQ1IwLB	2024-02-16 00:15:01.571+00	2024-02-16 00:15:01.571+00	NjxsGlPeB4	TCkiw6gTDz	3	0	4	2	3	\N	\N
zBE2E1Kz64	2024-02-16 00:15:01.872+00	2024-02-16 00:15:01.872+00	jqDYoPT45X	fwLPZZ8YQa	4	3	3	2	2	\N	\N
l1aAuVQDLI	2024-02-16 00:15:02.082+00	2024-02-16 00:15:02.082+00	dEqAHvPMXA	m6g8u0QpTC	3	2	0	1	1	\N	\N
d5JqsKGlZs	2024-02-16 00:15:02.293+00	2024-02-16 00:15:02.293+00	I5RzFRcQ7G	XwWwGnkXNj	3	4	1	1	1	\N	\N
hIj5Kd6iAv	2024-02-16 00:15:02.593+00	2024-02-16 00:15:02.593+00	dEqAHvPMXA	e037qpAih3	0	3	4	4	0	\N	\N
6WZxcTjjHR	2024-02-16 00:15:02.802+00	2024-02-16 00:15:02.802+00	mQXQWNqxg9	Pa0qBO2rzK	0	1	4	3	4	\N	\N
wpCryls3E1	2024-02-16 00:15:03.01+00	2024-02-16 00:15:03.01+00	1as6rMOzjQ	o4VD4BWwDt	1	0	4	1	1	\N	\N
bBOHEiLNq9	2024-02-16 00:15:03.311+00	2024-02-16 00:15:03.311+00	adE9nQrDk3	o4VD4BWwDt	3	0	2	2	2	\N	\N
H5g0ULno7Q	2024-02-16 00:15:03.52+00	2024-02-16 00:15:03.52+00	sy1HD51LXT	8w7i8C3NnT	1	2	0	4	4	\N	\N
5WsRU8GRRk	2024-02-16 00:15:03.73+00	2024-02-16 00:15:03.73+00	dZKm0wOhYa	cTIjuPjyIa	0	1	4	4	2	\N	\N
bl6G3bSmsL	2024-02-16 00:15:04.027+00	2024-02-16 00:15:04.027+00	NjxsGlPeB4	cmxBcanww9	0	1	2	2	2	\N	\N
w4ifijsYcc	2024-02-16 00:15:04.237+00	2024-02-16 00:15:04.237+00	sHiqaG4iqY	UDXF0qXvDY	0	3	0	3	3	\N	\N
bTTYK6OlVD	2024-02-16 00:15:04.447+00	2024-02-16 00:15:04.447+00	iUlyHNFGpG	FJOTueDfs2	4	4	1	3	2	\N	\N
W0F5d44Nrv	2024-02-16 00:15:04.745+00	2024-02-16 00:15:04.745+00	iWxl9obi8w	OQWu2bnHeC	1	0	1	3	0	\N	\N
vsDjxNlrPZ	2024-02-16 00:15:05.051+00	2024-02-16 00:15:05.051+00	sHiqaG4iqY	HLIPwAqO2R	0	3	0	2	1	\N	\N
zmoVCdhFDK	2024-02-16 00:15:05.261+00	2024-02-16 00:15:05.261+00	SFAISec8QF	08liHW08uC	3	3	0	4	4	\N	\N
wrEh1pG4hm	2024-02-16 00:15:05.472+00	2024-02-16 00:15:05.472+00	sy1HD51LXT	Oahm9sOn1y	1	0	2	4	2	\N	\N
NYKnnKlqE4	2024-02-16 00:15:05.685+00	2024-02-16 00:15:05.685+00	sHiqaG4iqY	tCIEnLLcUc	1	0	3	4	0	\N	\N
oQc2t9dREA	2024-02-16 00:15:05.897+00	2024-02-16 00:15:05.897+00	RWwLSzreG2	cFtamPA0zH	3	2	1	1	4	\N	\N
hbZWk9ZNGe	2024-02-16 00:15:06.102+00	2024-02-16 00:15:06.102+00	5X202ssb0D	3P6kmNoY1F	3	1	2	1	4	\N	\N
iA1Ignkx1J	2024-02-16 00:15:06.318+00	2024-02-16 00:15:06.318+00	NjxsGlPeB4	j0dWqP2C2A	3	1	1	4	2	\N	\N
BAz1IzMENK	2024-02-16 00:15:06.528+00	2024-02-16 00:15:06.528+00	mAKp5BK7R1	yvUod6yLDt	4	4	4	4	4	\N	\N
7valJjASKc	2024-02-16 00:15:06.741+00	2024-02-16 00:15:06.741+00	adE9nQrDk3	JZOBDAh12a	1	0	4	1	3	\N	\N
HbYQtpnkip	2024-02-16 00:15:06.953+00	2024-02-16 00:15:06.953+00	HtEtaHBVDN	9GF3y7LmHV	1	4	0	0	2	\N	\N
JJ2VKEDfdF	2024-02-16 00:15:07.167+00	2024-02-16 00:15:07.167+00	5X202ssb0D	08liHW08uC	0	4	2	0	2	\N	\N
arT9W9ruGr	2024-02-16 00:15:07.378+00	2024-02-16 00:15:07.378+00	ONgyydfVNz	cwVEh0dqfm	2	0	1	2	0	\N	\N
dWAWzT0RfP	2024-02-16 00:15:07.588+00	2024-02-16 00:15:07.588+00	WKpBp0c8F3	bi1IivsuUB	1	0	4	1	0	\N	\N
s0sE5O9rEN	2024-02-16 00:15:07.802+00	2024-02-16 00:15:07.802+00	adE9nQrDk3	oABNR2FF6S	1	2	3	0	3	\N	\N
3E6XPJKOtq	2024-02-16 00:15:08.015+00	2024-02-16 00:15:08.015+00	jqDYoPT45X	fxvABtKCPT	3	1	0	3	3	\N	\N
ypa3U7CJyD	2024-02-16 00:15:08.228+00	2024-02-16 00:15:08.228+00	sy1HD51LXT	6Fo67rhTSP	0	2	3	1	3	\N	\N
zI19knsjfD	2024-02-16 00:15:08.443+00	2024-02-16 00:15:08.443+00	iUlyHNFGpG	j0dWqP2C2A	0	2	0	4	2	\N	\N
lQwQTga6Ha	2024-02-16 00:15:08.652+00	2024-02-16 00:15:08.652+00	1as6rMOzjQ	mMYg4cyd5R	4	2	3	3	3	\N	\N
NNfYZB5AHh	2024-02-16 00:15:08.866+00	2024-02-16 00:15:08.866+00	I5RzFRcQ7G	8w7i8C3NnT	4	0	1	2	0	\N	\N
jIfNZMt7Dh	2024-02-16 00:15:09.148+00	2024-02-16 00:15:09.148+00	5X202ssb0D	HXtEwLBC7f	2	3	4	2	4	\N	\N
bXHM9AqTdJ	2024-02-16 00:15:09.356+00	2024-02-16 00:15:09.356+00	5nv19u6KJ2	6Fo67rhTSP	3	4	1	4	3	\N	\N
DNB0o69Fy4	2024-02-16 00:15:09.566+00	2024-02-16 00:15:09.566+00	HtEtaHBVDN	axyV0Fu7pm	0	3	2	3	0	\N	\N
SgRoGu0xdL	2024-02-16 00:15:09.776+00	2024-02-16 00:15:09.776+00	VshUk7eBeK	CSvk1ycWXk	0	1	1	0	3	\N	\N
YvjcWYIbOQ	2024-02-16 00:15:09.988+00	2024-02-16 00:15:09.988+00	5nv19u6KJ2	NY6RE1qgWu	4	4	1	1	4	\N	\N
EHSJOyF0h9	2024-02-16 00:15:10.201+00	2024-02-16 00:15:10.201+00	iUlyHNFGpG	IEqTHcohpJ	4	4	2	2	3	\N	\N
HKBa215RDI	2024-02-16 00:15:10.413+00	2024-02-16 00:15:10.413+00	5X202ssb0D	KCsJ4XR6Dn	0	2	0	2	4	\N	\N
89elRUPTCj	2024-02-16 00:15:10.627+00	2024-02-16 00:15:10.627+00	adE9nQrDk3	u5FXeeOChJ	2	3	1	3	1	\N	\N
EhKS85o0op	2024-02-16 00:15:10.838+00	2024-02-16 00:15:10.838+00	AsrLUQwxI9	o90lhsZ7FK	2	0	3	1	0	\N	\N
ByxahT7cYg	2024-02-16 00:15:11.091+00	2024-02-16 00:15:11.091+00	HtEtaHBVDN	G0uU7KQLEt	1	2	3	1	3	\N	\N
jIH11ErTiO	2024-02-16 00:15:11.301+00	2024-02-16 00:15:11.301+00	sy1HD51LXT	uABtFsJhJc	1	2	3	2	1	\N	\N
sVRkKRihQ9	2024-02-16 00:15:11.514+00	2024-02-16 00:15:11.514+00	WKpBp0c8F3	08liHW08uC	3	3	0	4	4	\N	\N
toGgQpIIVO	2024-02-16 00:15:12.117+00	2024-02-16 00:15:12.117+00	S6wz0lK0bf	TCkiw6gTDz	2	2	0	0	3	\N	\N
zFAIXgO35I	2024-02-16 00:15:12.334+00	2024-02-16 00:15:12.334+00	NjxsGlPeB4	cwVEh0dqfm	4	3	0	2	0	\N	\N
oqncnflpw6	2024-02-16 00:15:12.541+00	2024-02-16 00:15:12.541+00	VshUk7eBeK	WHvlAGgj6c	1	2	2	3	0	\N	\N
UZYCpGDcpu	2024-02-16 00:15:12.748+00	2024-02-16 00:15:12.748+00	Otwj7uJwjr	BMLzFMvIT6	0	4	0	1	2	\N	\N
fLFJGMDbFC	2024-02-16 00:15:12.957+00	2024-02-16 00:15:12.957+00	dZKm0wOhYa	rT0UCBK1bE	1	3	0	4	0	\N	\N
vVIoNVdCZ7	2024-02-16 00:15:13.244+00	2024-02-16 00:15:13.244+00	opW2wQ2bZ8	AgU9OLJkqz	1	0	1	0	1	\N	\N
HKN8BWvdU9	2024-02-16 00:15:13.456+00	2024-02-16 00:15:13.456+00	NjxsGlPeB4	WSTLlXDcKl	4	3	3	3	4	\N	\N
Qpb3Ef11gu	2024-02-16 00:15:13.668+00	2024-02-16 00:15:13.668+00	RWwLSzreG2	M0tHrt1GgV	3	4	2	4	2	\N	\N
fHfHVcXiXH	2024-02-16 00:15:13.879+00	2024-02-16 00:15:13.879+00	HRhGpJpmb5	rKyjwoEIRp	2	1	4	0	2	\N	\N
5IwgnwnYmy	2024-02-16 00:15:14.091+00	2024-02-16 00:15:14.091+00	HRhGpJpmb5	HXtEwLBC7f	2	1	1	0	4	\N	\N
NFHjZzhA7Z	2024-02-16 00:15:14.3+00	2024-02-16 00:15:14.3+00	RWwLSzreG2	qP3EdIVzfB	3	0	3	1	2	\N	\N
xPzQFE7wj1	2024-02-16 00:15:14.513+00	2024-02-16 00:15:14.513+00	jqDYoPT45X	UCFo58JaaD	1	3	4	0	3	\N	\N
eAjtVVvF0M	2024-02-16 00:15:14.723+00	2024-02-16 00:15:14.723+00	NjxsGlPeB4	XwWwGnkXNj	4	0	4	1	2	\N	\N
XNuAKpGIXa	2024-02-16 00:15:14.935+00	2024-02-16 00:15:14.935+00	ONgyydfVNz	vwHi602n66	1	0	0	4	1	\N	\N
foHBLw7I6B	2024-02-16 00:15:15.147+00	2024-02-16 00:15:15.147+00	5X202ssb0D	6KvFK8yy1q	3	2	0	3	4	\N	\N
5ZJA3znNzt	2024-02-16 00:15:15.36+00	2024-02-16 00:15:15.36+00	opW2wQ2bZ8	WnUBBkiDjE	1	3	3	0	1	\N	\N
EfVPS3yvFi	2024-02-16 00:15:15.6+00	2024-02-16 00:15:15.6+00	R2CLtFh5jU	UCFo58JaaD	4	1	2	0	4	\N	\N
WWXKA7sOBh	2024-02-16 00:15:15.812+00	2024-02-16 00:15:15.812+00	sy1HD51LXT	cFtamPA0zH	3	1	2	4	2	\N	\N
ogxgW7jNsC	2024-02-16 00:15:16.02+00	2024-02-16 00:15:16.02+00	iWxl9obi8w	UCFo58JaaD	0	0	2	4	4	\N	\N
WhAE8AmEyJ	2024-02-16 00:15:16.232+00	2024-02-16 00:15:16.232+00	R2CLtFh5jU	fwLPZZ8YQa	0	1	0	4	2	\N	\N
a34cB4EKBw	2024-02-16 00:15:16.449+00	2024-02-16 00:15:16.449+00	I5RzFRcQ7G	M0tHrt1GgV	1	2	1	0	1	\N	\N
BJmk9zM1la	2024-02-16 00:15:16.724+00	2024-02-16 00:15:16.724+00	sHiqaG4iqY	y4RkaDbkec	3	3	4	3	4	\N	\N
24CnKdQ9Rk	2024-02-16 00:15:16.934+00	2024-02-16 00:15:16.934+00	dEqAHvPMXA	TCkiw6gTDz	4	2	4	0	3	\N	\N
gAY9IVkapV	2024-02-16 00:15:17.143+00	2024-02-16 00:15:17.143+00	R2CLtFh5jU	TZsdmscJ2B	1	1	0	2	0	\N	\N
dKrUUWBlVu	2024-02-16 00:15:17.357+00	2024-02-16 00:15:17.357+00	sHiqaG4iqY	vwHi602n66	2	1	4	2	3	\N	\N
dcPwzjacRI	2024-02-16 00:15:17.568+00	2024-02-16 00:15:17.568+00	ONgyydfVNz	P9sBFomftT	2	4	4	0	2	\N	\N
r6BoIrpdRG	2024-02-16 00:15:17.78+00	2024-02-16 00:15:17.78+00	WKpBp0c8F3	cTIjuPjyIa	1	3	3	4	0	\N	\N
qbC5B8GMdT	2024-02-16 00:15:17.99+00	2024-02-16 00:15:17.99+00	adE9nQrDk3	KCsJ4XR6Dn	1	2	3	4	2	\N	\N
a8sX6VF6EF	2024-02-16 00:15:18.2+00	2024-02-16 00:15:18.2+00	1as6rMOzjQ	fxvABtKCPT	3	1	0	2	0	\N	\N
PHCjIp1XOW	2024-02-16 00:15:18.411+00	2024-02-16 00:15:18.411+00	dZKm0wOhYa	uigc7bJBOJ	1	3	0	2	4	\N	\N
ZnLHpFaKcP	2024-02-16 00:15:18.672+00	2024-02-16 00:15:18.672+00	HRhGpJpmb5	Gl96vGdYHM	0	0	3	1	3	\N	\N
2IoEdm2L5u	2024-02-16 00:15:19.282+00	2024-02-16 00:15:19.282+00	9223vtvaBd	AgU9OLJkqz	1	2	1	1	4	\N	\N
CdaJqwowg8	2024-02-16 00:15:19.492+00	2024-02-16 00:15:19.492+00	dZKm0wOhYa	G0uU7KQLEt	2	2	2	1	3	\N	\N
Lx6wpYjkDo	2024-02-16 00:15:19.7+00	2024-02-16 00:15:19.7+00	5X202ssb0D	qZmnAnnPEb	4	4	0	2	2	\N	\N
kxs5Ov9lwG	2024-02-16 00:15:19.912+00	2024-02-16 00:15:19.912+00	jqDYoPT45X	Oahm9sOn1y	3	3	0	2	3	\N	\N
OBu7CYl3D1	2024-02-16 00:15:20.122+00	2024-02-16 00:15:20.122+00	5X202ssb0D	E2hBZzDsjO	4	0	1	2	1	\N	\N
Ub4JzkQzoZ	2024-02-16 00:15:20.33+00	2024-02-16 00:15:20.33+00	9223vtvaBd	FJOTueDfs2	1	1	2	4	2	\N	\N
oAo1mzWqT5	2024-02-16 00:15:20.615+00	2024-02-16 00:15:20.615+00	dZKm0wOhYa	Pa0qBO2rzK	1	3	0	0	1	\N	\N
nFAJb5Arlk	2024-02-16 00:15:21.229+00	2024-02-16 00:15:21.229+00	5X202ssb0D	ThMuD3hYRQ	2	3	0	4	2	\N	\N
YljGLRJGov	2024-02-16 00:15:21.439+00	2024-02-16 00:15:21.439+00	R2CLtFh5jU	E2hBZzDsjO	3	1	2	0	1	\N	\N
rc6zC9ppVJ	2024-02-16 00:15:21.649+00	2024-02-16 00:15:21.649+00	WKpBp0c8F3	bi1IivsuUB	4	0	3	2	3	\N	\N
UUomwisG1w	2024-02-16 00:15:21.858+00	2024-02-16 00:15:21.858+00	iWxl9obi8w	D0A6GLdsDM	0	3	3	0	1	\N	\N
DAkl16Ruqs	2024-02-16 00:15:22.073+00	2024-02-16 00:15:22.073+00	jqDYoPT45X	89xRG1afNi	3	0	4	2	4	\N	\N
m5ycuiVDe0	2024-02-16 00:15:22.663+00	2024-02-16 00:15:22.663+00	Otwj7uJwjr	Gl96vGdYHM	2	0	0	3	1	\N	\N
qBRtc45N10	2024-02-16 00:15:22.969+00	2024-02-16 00:15:22.969+00	SFAISec8QF	j0dWqP2C2A	3	0	4	2	2	\N	\N
tANATbzvTm	2024-02-16 00:15:23.177+00	2024-02-16 00:15:23.177+00	jqDYoPT45X	o90lhsZ7FK	3	3	3	0	4	\N	\N
am5gsNNg2x	2024-02-16 00:15:23.384+00	2024-02-16 00:15:23.384+00	dZKm0wOhYa	AgU9OLJkqz	3	4	4	2	3	\N	\N
IFBqLnhzw3	2024-02-16 00:15:23.588+00	2024-02-16 00:15:23.588+00	AsrLUQwxI9	KCsJ4XR6Dn	3	0	4	2	3	\N	\N
j6jVFGeojh	2024-02-16 00:15:23.795+00	2024-02-16 00:15:23.795+00	adE9nQrDk3	e037qpAih3	1	4	0	2	0	\N	\N
ixwlZoUehL	2024-02-16 00:15:24+00	2024-02-16 00:15:24+00	jqDYoPT45X	RkhjIQJgou	1	0	0	3	4	\N	\N
r5gmpKUos5	2024-02-16 00:15:24.205+00	2024-02-16 00:15:24.205+00	Otwj7uJwjr	lxQA9rtSfY	2	0	3	1	3	\N	\N
SmcaJQpZyu	2024-02-16 00:15:24.505+00	2024-02-16 00:15:24.505+00	1as6rMOzjQ	D0A6GLdsDM	4	3	0	1	0	\N	\N
IYbU7WgyKN	2024-02-16 00:15:24.715+00	2024-02-16 00:15:24.715+00	HtEtaHBVDN	G0uU7KQLEt	4	3	4	2	3	\N	\N
f4loUzlfhL	2024-02-16 00:15:24.923+00	2024-02-16 00:15:24.923+00	1as6rMOzjQ	JRi61dUphq	2	0	2	4	0	\N	\N
QYf7nLWOgX	2024-02-16 00:15:25.133+00	2024-02-16 00:15:25.133+00	iWxl9obi8w	TpGyMZM9BG	0	1	1	1	4	\N	\N
qWeb5RgJ5D	2024-02-16 00:15:25.342+00	2024-02-16 00:15:25.342+00	iUlyHNFGpG	o90lhsZ7FK	3	0	1	2	2	\N	\N
FSKxzbKKNE	2024-02-16 00:15:25.556+00	2024-02-16 00:15:25.556+00	NjxsGlPeB4	TZsdmscJ2B	1	3	0	4	3	\N	\N
PaTKZJMKbP	2024-02-16 00:15:25.77+00	2024-02-16 00:15:25.77+00	mQXQWNqxg9	bQpy9LEJWn	1	3	2	2	0	\N	\N
kqseT2GBAA	2024-02-16 00:15:25.98+00	2024-02-16 00:15:25.98+00	WKpBp0c8F3	XwszrNEEEj	2	3	2	3	1	\N	\N
DAFkvQjeuh	2024-02-16 00:15:26.245+00	2024-02-16 00:15:26.245+00	VshUk7eBeK	0TvWuLoLF5	1	0	3	1	4	\N	\N
nis96oOux9	2024-02-16 00:15:26.452+00	2024-02-16 00:15:26.452+00	I5RzFRcQ7G	Pja6n3yaWZ	3	2	2	3	3	\N	\N
syFTwSzb4h	2024-02-16 00:15:26.662+00	2024-02-16 00:15:26.662+00	sHiqaG4iqY	cFtamPA0zH	4	4	2	3	1	\N	\N
TlUw0zxKVM	2024-02-16 00:15:26.872+00	2024-02-16 00:15:26.872+00	VshUk7eBeK	cwVEh0dqfm	3	4	0	1	0	\N	\N
vrfVP2GkZG	2024-02-16 00:15:27.081+00	2024-02-16 00:15:27.081+00	mAKp5BK7R1	INeptnSdJC	4	3	1	2	4	\N	\N
hDbedfLOD5	2024-02-16 00:15:27.294+00	2024-02-16 00:15:27.294+00	iWxl9obi8w	EmIUBFwx0Z	3	1	4	3	2	\N	\N
n13tVtzD2J	2024-02-16 00:15:27.508+00	2024-02-16 00:15:27.508+00	5nv19u6KJ2	Pa0qBO2rzK	0	0	4	1	3	\N	\N
sWf1wXnR0n	2024-02-16 00:15:27.733+00	2024-02-16 00:15:27.733+00	mQXQWNqxg9	H40ivltLwZ	1	3	1	2	2	\N	\N
FZyzDFkuFh	2024-02-16 00:15:27.937+00	2024-02-16 00:15:27.937+00	9223vtvaBd	08liHW08uC	2	3	1	0	0	\N	\N
zNH6230DHN	2024-02-16 00:15:28.14+00	2024-02-16 00:15:28.14+00	opW2wQ2bZ8	o90lhsZ7FK	1	4	0	4	3	\N	\N
AckkBZHb4i	2024-02-16 00:15:28.361+00	2024-02-16 00:15:28.361+00	5nv19u6KJ2	qEQ9tmLyW9	1	1	3	3	3	\N	\N
XD4knBEluD	2024-02-16 00:15:28.576+00	2024-02-16 00:15:28.576+00	adE9nQrDk3	HLIPwAqO2R	4	0	3	2	1	\N	\N
ikXFD9fM8O	2024-02-16 00:15:28.801+00	2024-02-16 00:15:28.801+00	HRhGpJpmb5	8w7i8C3NnT	0	4	2	4	2	\N	\N
kn2tXugdNv	2024-02-16 00:15:29.011+00	2024-02-16 00:15:29.011+00	sy1HD51LXT	m8hjjLVdPS	2	2	4	4	3	\N	\N
mxiXV2Mpo9	2024-02-16 00:15:29.224+00	2024-02-16 00:15:29.224+00	adE9nQrDk3	WnUBBkiDjE	0	1	3	1	3	\N	\N
M7rjYaRFvg	2024-02-16 00:15:29.43+00	2024-02-16 00:15:29.43+00	dEqAHvPMXA	lxQA9rtSfY	0	0	0	4	0	\N	\N
am02HFxD3H	2024-02-16 00:15:29.63+00	2024-02-16 00:15:29.63+00	S6wz0lK0bf	UDXF0qXvDY	0	2	0	3	2	\N	\N
rDLmofgWEq	2024-02-16 00:15:29.828+00	2024-02-16 00:15:29.828+00	iWxl9obi8w	lxQA9rtSfY	3	1	2	1	1	\N	\N
3nQfvtPsRz	2024-02-16 00:15:30.025+00	2024-02-16 00:15:30.025+00	dZKm0wOhYa	cmxBcanww9	4	0	3	4	4	\N	\N
vw7kx5AC8Y	2024-02-16 00:15:30.248+00	2024-02-16 00:15:30.248+00	jqDYoPT45X	3u4B9V4l5K	3	0	3	0	1	\N	\N
XIvHaBseTp	2024-02-16 00:15:30.461+00	2024-02-16 00:15:30.461+00	9223vtvaBd	EmIUBFwx0Z	4	3	3	0	3	\N	\N
0ulFdUMWgB	2024-02-16 00:15:30.756+00	2024-02-16 00:15:30.756+00	I5RzFRcQ7G	jHqCpA1nWb	4	2	0	4	1	\N	\N
4AHQ2hduMC	2024-02-16 00:15:30.957+00	2024-02-16 00:15:30.957+00	sy1HD51LXT	BMLzFMvIT6	3	1	1	4	2	\N	\N
1T58WaRpoj	2024-02-16 00:15:31.166+00	2024-02-16 00:15:31.166+00	opW2wQ2bZ8	TCkiw6gTDz	3	3	3	3	3	\N	\N
2ifYGS2ThS	2024-02-16 00:15:31.379+00	2024-02-16 00:15:31.379+00	dZKm0wOhYa	08liHW08uC	3	4	0	0	3	\N	\N
nueniNDMsT	2024-02-16 00:15:31.59+00	2024-02-16 00:15:31.59+00	mQXQWNqxg9	e037qpAih3	0	3	0	4	2	\N	\N
mGFQjMmAEn	2024-02-16 00:15:31.801+00	2024-02-16 00:15:31.801+00	RWwLSzreG2	y4RkaDbkec	0	0	4	4	0	\N	\N
95NGEtDzCy	2024-02-16 00:15:32.013+00	2024-02-16 00:15:32.013+00	1as6rMOzjQ	G0uU7KQLEt	3	0	1	4	4	\N	\N
Qg7owMCghc	2024-02-16 00:15:32.225+00	2024-02-16 00:15:32.225+00	R2CLtFh5jU	HSEugQ3Ouj	2	4	3	0	2	\N	\N
EWTmMRlH5y	2024-02-16 00:15:32.435+00	2024-02-16 00:15:32.435+00	1as6rMOzjQ	lxQA9rtSfY	0	4	2	1	2	\N	\N
OeiOV5wJBq	2024-02-16 00:15:32.647+00	2024-02-16 00:15:32.647+00	jqDYoPT45X	fKTSJPdUi9	4	0	3	2	4	\N	\N
yMTu0Ufs4Z	2024-02-16 00:15:32.905+00	2024-02-16 00:15:32.905+00	dZKm0wOhYa	NBojpORh3G	2	0	4	1	4	\N	\N
bic5yn9Dl3	2024-02-16 00:15:33.117+00	2024-02-16 00:15:33.117+00	5nv19u6KJ2	WBFeKac0OO	3	1	1	3	2	\N	\N
fO8bjnMc2S	2024-02-16 00:15:33.328+00	2024-02-16 00:15:33.328+00	jqDYoPT45X	Oahm9sOn1y	4	1	1	1	3	\N	\N
PzqviDeubB	2024-02-16 00:15:33.539+00	2024-02-16 00:15:33.539+00	sy1HD51LXT	Gl96vGdYHM	1	3	1	3	0	\N	\N
UyikdXNLjM	2024-02-16 00:15:33.751+00	2024-02-16 00:15:33.751+00	1as6rMOzjQ	G0uU7KQLEt	2	0	0	3	3	\N	\N
45lFRz0qyN	2024-02-16 00:15:33.964+00	2024-02-16 00:15:33.964+00	SFAISec8QF	14jGmOAXcg	3	1	3	3	2	\N	\N
fNYcd8zJ2k	2024-02-16 00:15:34.177+00	2024-02-16 00:15:34.177+00	sHiqaG4iqY	cwVEh0dqfm	1	2	4	0	3	\N	\N
K4JbyEgimo	2024-02-16 00:15:34.393+00	2024-02-16 00:15:34.393+00	dEqAHvPMXA	lEPdiO1EDi	2	1	0	0	3	\N	\N
geibGDZ0i0	2024-02-16 00:15:34.606+00	2024-02-16 00:15:34.606+00	S6wz0lK0bf	eEmewy7hPd	4	2	0	0	4	\N	\N
MBGmuNGaZP	2024-02-16 00:15:34.85+00	2024-02-16 00:15:34.85+00	9223vtvaBd	mMYg4cyd5R	4	4	1	2	3	\N	\N
vLCalczpVk	2024-02-16 00:15:35.062+00	2024-02-16 00:15:35.062+00	RWwLSzreG2	bi1IivsuUB	4	4	3	4	3	\N	\N
gt99kpH9dE	2024-02-16 00:15:35.273+00	2024-02-16 00:15:35.273+00	HRhGpJpmb5	IybX0eBoO3	2	3	2	2	2	\N	\N
Y6cEOZiF2G	2024-02-16 00:15:35.481+00	2024-02-16 00:15:35.481+00	opW2wQ2bZ8	JLhF4VuByh	3	2	0	3	0	\N	\N
OpaH1nFm8w	2024-02-16 00:15:35.691+00	2024-02-16 00:15:35.691+00	sy1HD51LXT	FYXEfIO1zF	0	2	4	0	1	\N	\N
albHl8dT7C	2024-02-16 00:15:35.902+00	2024-02-16 00:15:35.902+00	9223vtvaBd	ThMuD3hYRQ	2	0	1	2	0	\N	\N
L8Oe8Ahld0	2024-02-16 00:15:36.108+00	2024-02-16 00:15:36.108+00	RWwLSzreG2	3P6kmNoY1F	0	4	3	3	0	\N	\N
zbfqAq2qBu	2024-02-16 00:15:36.386+00	2024-02-16 00:15:36.386+00	5nv19u6KJ2	rKyjwoEIRp	1	0	3	4	4	\N	\N
14NE8LRrnQ	2024-02-16 00:15:36.694+00	2024-02-16 00:15:36.694+00	1as6rMOzjQ	m6g8u0QpTC	2	1	0	2	0	\N	\N
NZyB9u6XpV	2024-02-16 00:15:36.998+00	2024-02-16 00:15:36.998+00	jqDYoPT45X	eEmewy7hPd	4	3	2	4	0	\N	\N
B4Gf9aCwLe	2024-02-16 00:15:37.208+00	2024-02-16 00:15:37.208+00	iUlyHNFGpG	jHqCpA1nWb	2	0	4	3	1	\N	\N
t4sJDtIHhS	2024-02-16 00:15:37.51+00	2024-02-16 00:15:37.51+00	dZKm0wOhYa	14jGmOAXcg	1	1	2	1	1	\N	\N
ZXROhRfCzj	2024-02-16 00:15:37.819+00	2024-02-16 00:15:37.819+00	1as6rMOzjQ	89xRG1afNi	3	3	1	0	1	\N	\N
6rHhJ3eRkG	2024-02-16 00:15:38.432+00	2024-02-16 00:15:38.432+00	9223vtvaBd	jjVdtithcD	4	1	2	2	2	\N	\N
RA75B2KDRM	2024-02-16 00:15:38.642+00	2024-02-16 00:15:38.642+00	opW2wQ2bZ8	WHvlAGgj6c	0	3	2	1	2	\N	\N
F8PEGnsqVj	2024-02-16 00:15:38.851+00	2024-02-16 00:15:38.851+00	mAKp5BK7R1	JZOBDAh12a	3	2	2	4	3	\N	\N
l0hHreGa28	2024-02-16 00:15:39.069+00	2024-02-16 00:15:39.069+00	NjxsGlPeB4	cmxBcanww9	2	0	3	1	2	\N	\N
czo6eD2Ogf	2024-02-16 00:15:39.283+00	2024-02-16 00:15:39.283+00	adE9nQrDk3	tCIEnLLcUc	4	1	1	0	2	\N	\N
go5c9yHBau	2024-02-16 00:15:39.862+00	2024-02-16 00:15:39.862+00	AsrLUQwxI9	jjVdtithcD	1	2	3	4	0	\N	\N
QaXQeQJyBZ	2024-02-16 00:15:40.068+00	2024-02-16 00:15:40.068+00	dZKm0wOhYa	cwVEh0dqfm	4	1	0	4	0	\N	\N
3MG5eOBEXH	2024-02-16 00:15:40.275+00	2024-02-16 00:15:40.275+00	adE9nQrDk3	eEmewy7hPd	4	2	3	3	4	\N	\N
aRPYxvDD4m	2024-02-16 00:15:40.582+00	2024-02-16 00:15:40.582+00	HtEtaHBVDN	VK3vnSxIy8	3	4	1	3	0	\N	\N
G3sd73pJ69	2024-02-16 00:15:40.793+00	2024-02-16 00:15:40.793+00	opW2wQ2bZ8	fxvABtKCPT	0	2	2	3	2	\N	\N
RrcwWD9pH9	2024-02-16 00:15:41.008+00	2024-02-16 00:15:41.008+00	mQXQWNqxg9	lEPdiO1EDi	3	1	0	1	4	\N	\N
tt5hXT7mnq	2024-02-16 00:15:41.221+00	2024-02-16 00:15:41.221+00	AsrLUQwxI9	Pja6n3yaWZ	3	2	1	1	0	\N	\N
WdsjxVRwS3	2024-02-16 00:15:41.505+00	2024-02-16 00:15:41.505+00	HRhGpJpmb5	j0dWqP2C2A	4	1	3	4	0	\N	\N
ZXiaoaPwc5	2024-02-16 00:15:41.718+00	2024-02-16 00:15:41.718+00	S6wz0lK0bf	OQWu2bnHeC	2	3	3	3	2	\N	\N
5KrASCr3g6	2024-02-16 00:15:41.928+00	2024-02-16 00:15:41.928+00	Otwj7uJwjr	u5FXeeOChJ	3	4	1	1	3	\N	\N
JazWMChf1q	2024-02-16 00:15:42.139+00	2024-02-16 00:15:42.139+00	5nv19u6KJ2	FJOTueDfs2	0	4	1	4	4	\N	\N
rHHh4MVqzf	2024-02-16 00:15:42.427+00	2024-02-16 00:15:42.427+00	1as6rMOzjQ	lEPdiO1EDi	4	0	2	0	0	\N	\N
VZ1Esk15FH	2024-02-16 00:15:42.635+00	2024-02-16 00:15:42.635+00	NjxsGlPeB4	8w7i8C3NnT	4	2	3	3	2	\N	\N
MJj44qcQxB	2024-02-16 00:15:42.845+00	2024-02-16 00:15:42.845+00	dEqAHvPMXA	JZOBDAh12a	3	4	3	1	1	\N	\N
KEvNY5O59h	2024-02-16 00:15:43.057+00	2024-02-16 00:15:43.057+00	R2CLtFh5jU	UCFo58JaaD	2	4	4	0	4	\N	\N
jMMhqSlI7K	2024-02-16 00:15:43.266+00	2024-02-16 00:15:43.266+00	dZKm0wOhYa	Pja6n3yaWZ	3	0	0	1	2	\N	\N
sExhJOPN5M	2024-02-16 00:15:43.476+00	2024-02-16 00:15:43.476+00	R2CLtFh5jU	XSK814B37m	0	3	1	4	2	\N	\N
cBZ2PiyowK	2024-02-16 00:15:43.688+00	2024-02-16 00:15:43.688+00	RWwLSzreG2	VK3vnSxIy8	4	0	2	3	1	\N	\N
tDMC2T1may	2024-02-16 00:15:43.9+00	2024-02-16 00:15:43.9+00	1as6rMOzjQ	axyV0Fu7pm	2	2	4	3	0	\N	\N
AC9o5HghCs	2024-02-16 00:15:44.113+00	2024-02-16 00:15:44.113+00	VshUk7eBeK	eEmewy7hPd	3	2	1	2	3	\N	\N
pMbMs4rSfi	2024-02-16 00:15:44.372+00	2024-02-16 00:15:44.372+00	SFAISec8QF	lxQA9rtSfY	1	3	2	4	3	\N	\N
xoO3ryEooH	2024-02-16 00:15:44.583+00	2024-02-16 00:15:44.583+00	9223vtvaBd	FYXEfIO1zF	4	4	1	4	2	\N	\N
1twzFyCHda	2024-02-16 00:15:44.796+00	2024-02-16 00:15:44.796+00	dZKm0wOhYa	LgJuu5ABe5	2	1	3	3	3	\N	\N
WiPs30W4Ig	2024-02-16 00:15:45.008+00	2024-02-16 00:15:45.008+00	5X202ssb0D	jHqCpA1nWb	1	3	0	0	3	\N	\N
k9INMShe6D	2024-02-16 00:15:45.217+00	2024-02-16 00:15:45.217+00	dZKm0wOhYa	NBojpORh3G	2	3	3	2	0	\N	\N
e4MhCZXrHD	2024-02-16 00:15:45.804+00	2024-02-16 00:15:45.804+00	SFAISec8QF	HXtEwLBC7f	2	3	4	1	1	\N	\N
lOlHDQb4gN	2024-02-16 00:15:46.014+00	2024-02-16 00:15:46.014+00	1as6rMOzjQ	NY6RE1qgWu	3	3	2	2	4	\N	\N
qw3DGB4scQ	2024-02-16 00:15:46.419+00	2024-02-16 00:15:46.419+00	RWwLSzreG2	XwWwGnkXNj	3	1	2	4	1	\N	\N
m5iLaPa9UZ	2024-02-16 00:15:46.629+00	2024-02-16 00:15:46.629+00	AsrLUQwxI9	Oahm9sOn1y	0	0	4	4	0	\N	\N
9LV6qADRBo	2024-02-16 00:15:46.832+00	2024-02-16 00:15:46.832+00	NjxsGlPeB4	08liHW08uC	2	2	4	4	4	\N	\N
3UlOn1NvHp	2024-02-16 00:15:47.136+00	2024-02-16 00:15:47.136+00	sHiqaG4iqY	NBojpORh3G	1	2	3	0	3	\N	\N
cfg57svCSX	2024-02-16 00:15:47.345+00	2024-02-16 00:15:47.345+00	S6wz0lK0bf	oABNR2FF6S	1	0	3	0	0	\N	\N
AWVU3ZQai8	2024-02-16 00:15:47.558+00	2024-02-16 00:15:47.558+00	5X202ssb0D	M0tHrt1GgV	1	3	0	1	2	\N	\N
HyuYszsoEa	2024-02-16 00:15:47.77+00	2024-02-16 00:15:47.77+00	sHiqaG4iqY	LVYK4mLShP	0	1	1	4	0	\N	\N
3avMmO2Ufl	2024-02-16 00:15:47.998+00	2024-02-16 00:15:47.998+00	Otwj7uJwjr	89xRG1afNi	3	2	3	4	3	\N	\N
tIKP07uh7Y	2024-02-16 00:15:48.264+00	2024-02-16 00:15:48.264+00	1as6rMOzjQ	6Fo67rhTSP	2	0	3	1	1	\N	\N
bg3LaWAuUG	2024-02-16 00:15:48.477+00	2024-02-16 00:15:48.477+00	HRhGpJpmb5	VK3vnSxIy8	1	1	3	2	4	\N	\N
89q9Bbvjfh	2024-02-16 00:15:48.689+00	2024-02-16 00:15:48.689+00	I5RzFRcQ7G	BMLzFMvIT6	1	0	0	3	1	\N	\N
9YAJg6AyeT	2024-02-16 00:15:48.903+00	2024-02-16 00:15:48.903+00	I5RzFRcQ7G	rKyjwoEIRp	3	4	0	3	0	\N	\N
r7voFbCKTA	2024-02-16 00:15:49.117+00	2024-02-16 00:15:49.117+00	5nv19u6KJ2	yvUod6yLDt	3	4	3	1	2	\N	\N
PVAimJMqT2	2024-02-16 00:15:49.331+00	2024-02-16 00:15:49.331+00	9223vtvaBd	EmIUBFwx0Z	4	0	1	2	0	\N	\N
42c4XM3D0m	2024-02-16 00:15:49.542+00	2024-02-16 00:15:49.542+00	dZKm0wOhYa	rT0UCBK1bE	2	3	1	3	3	\N	\N
tWuuHef5ps	2024-02-16 00:15:49.8+00	2024-02-16 00:15:49.8+00	iWxl9obi8w	TZsdmscJ2B	3	2	0	4	2	\N	\N
3HBGmbMRCr	2024-02-16 00:15:50.107+00	2024-02-16 00:15:50.107+00	1as6rMOzjQ	Oahm9sOn1y	0	0	2	3	0	\N	\N
iya3Mfl7vH	2024-02-16 00:15:50.42+00	2024-02-16 00:15:50.42+00	9223vtvaBd	XwszrNEEEj	0	3	1	0	4	\N	\N
43190u52pm	2024-02-16 00:15:50.631+00	2024-02-16 00:15:50.631+00	ONgyydfVNz	uABtFsJhJc	1	1	4	4	1	\N	\N
B8d16pBNUf	2024-02-16 00:15:50.839+00	2024-02-16 00:15:50.839+00	S6wz0lK0bf	Oahm9sOn1y	1	1	2	3	3	\N	\N
UfBi8hw3Ch	2024-02-16 00:15:51.123+00	2024-02-16 00:15:51.123+00	I5RzFRcQ7G	cTIjuPjyIa	2	3	0	4	1	\N	\N
k0uMmQ10yn	2024-02-16 00:15:51.335+00	2024-02-16 00:15:51.335+00	SFAISec8QF	u5FXeeOChJ	0	1	2	0	4	\N	\N
ImCW5Hzk2A	2024-02-16 00:15:51.55+00	2024-02-16 00:15:51.55+00	iWxl9obi8w	bQpy9LEJWn	3	4	2	2	2	\N	\N
Q1LC1CXfCE	2024-02-16 00:15:51.766+00	2024-02-16 00:15:51.766+00	RWwLSzreG2	M0tHrt1GgV	1	2	1	2	0	\N	\N
UChCrrZ3Vv	2024-02-16 00:15:51.975+00	2024-02-16 00:15:51.975+00	WKpBp0c8F3	cTIjuPjyIa	3	0	2	2	2	\N	\N
Zs4rjYWPqS	2024-02-16 00:15:52.187+00	2024-02-16 00:15:52.187+00	ONgyydfVNz	mMYg4cyd5R	2	3	4	3	0	\N	\N
wRMhSwjvor	2024-02-16 00:15:52.399+00	2024-02-16 00:15:52.399+00	5X202ssb0D	lEPdiO1EDi	4	2	3	4	3	\N	\N
hxhMQYddMN	2024-02-16 00:15:52.612+00	2024-02-16 00:15:52.612+00	mAKp5BK7R1	oABNR2FF6S	4	0	1	0	2	\N	\N
9ucDgyYUJ9	2024-02-16 00:15:52.871+00	2024-02-16 00:15:52.871+00	I5RzFRcQ7G	MQfxuw3ERg	0	1	2	4	4	\N	\N
H6Y9e9J2Xr	2024-02-16 00:15:53.481+00	2024-02-16 00:15:53.481+00	1as6rMOzjQ	e037qpAih3	3	2	1	0	3	\N	\N
nSCXrOgvwp	2024-02-16 00:15:53.687+00	2024-02-16 00:15:53.687+00	dZKm0wOhYa	G0uU7KQLEt	1	1	2	4	0	\N	\N
CdCQoIPpoX	2024-02-16 00:15:54.297+00	2024-02-16 00:15:54.297+00	sy1HD51LXT	jHqCpA1nWb	3	3	1	4	3	\N	\N
0ZuhuYTlBJ	2024-02-16 00:15:54.609+00	2024-02-16 00:15:54.609+00	HtEtaHBVDN	Oahm9sOn1y	0	0	0	1	1	\N	\N
8gjKT1gDzt	2024-02-16 00:15:54.918+00	2024-02-16 00:15:54.918+00	5nv19u6KJ2	y4RkaDbkec	2	4	4	4	3	\N	\N
KfOWr5JVRd	2024-02-16 00:15:55.128+00	2024-02-16 00:15:55.128+00	1as6rMOzjQ	qP3EdIVzfB	0	2	0	2	1	\N	\N
yb09YxKsfc	2024-02-16 00:15:55.43+00	2024-02-16 00:15:55.43+00	mAKp5BK7R1	PF8w2gMAdi	3	1	0	0	4	\N	\N
GSnI19jwO4	2024-02-16 00:15:55.637+00	2024-02-16 00:15:55.637+00	iUlyHNFGpG	ThMuD3hYRQ	2	1	3	4	1	\N	\N
mhflqOHB7D	2024-02-16 00:15:55.847+00	2024-02-16 00:15:55.847+00	AsrLUQwxI9	cFtamPA0zH	3	3	1	3	3	\N	\N
SNjc6T0HMI	2024-02-16 00:15:56.059+00	2024-02-16 00:15:56.059+00	AsrLUQwxI9	6KvFK8yy1q	2	0	2	3	4	\N	\N
9aVa88ux5r	2024-02-16 00:15:56.269+00	2024-02-16 00:15:56.269+00	Otwj7uJwjr	bQ0JOk10eL	1	1	3	1	2	\N	\N
RIkcDcHAUf	2024-02-16 00:15:56.479+00	2024-02-16 00:15:56.479+00	NjxsGlPeB4	jjVdtithcD	2	4	0	4	4	\N	\N
xIKkmY0zLp	2024-02-16 00:15:56.691+00	2024-02-16 00:15:56.691+00	opW2wQ2bZ8	bi1IivsuUB	3	3	4	2	4	\N	\N
cCpOsajkD1	2024-02-16 00:15:56.907+00	2024-02-16 00:15:56.907+00	mAKp5BK7R1	6Fo67rhTSP	2	3	4	2	4	\N	\N
FpmUaTN8Vg	2024-02-16 00:15:57.125+00	2024-02-16 00:15:57.125+00	iWxl9obi8w	IEqTHcohpJ	0	4	2	0	3	\N	\N
OswWc2zKyd	2024-02-16 00:15:57.335+00	2024-02-16 00:15:57.335+00	adE9nQrDk3	RkhjIQJgou	4	1	2	4	1	\N	\N
2eMWfflzDG	2024-02-16 00:15:57.548+00	2024-02-16 00:15:57.548+00	iUlyHNFGpG	fxvABtKCPT	1	0	2	0	4	\N	\N
ONVJnyH5tX	2024-02-16 00:15:57.786+00	2024-02-16 00:15:57.786+00	opW2wQ2bZ8	y4RkaDbkec	3	3	4	1	0	\N	\N
XzSmjOy7AM	2024-02-16 00:15:58.093+00	2024-02-16 00:15:58.093+00	jqDYoPT45X	bi1IivsuUB	0	4	0	3	1	\N	\N
qTw1XNbIgm	2024-02-16 00:15:58.47+00	2024-02-16 00:15:58.47+00	iUlyHNFGpG	WHvlAGgj6c	0	2	2	4	1	\N	\N
EZuFAvRf3H	2024-02-16 00:15:58.679+00	2024-02-16 00:15:58.679+00	VshUk7eBeK	fKTSJPdUi9	4	3	1	0	2	\N	\N
6ZRDNGYHMN	2024-02-16 00:15:58.912+00	2024-02-16 00:15:58.912+00	5X202ssb0D	6KvFK8yy1q	0	4	0	2	3	\N	\N
sFwHjpElDK	2024-02-16 00:15:59.124+00	2024-02-16 00:15:59.124+00	mQXQWNqxg9	m6g8u0QpTC	2	1	0	1	0	\N	\N
vF30Gpx7fR	2024-02-16 00:15:59.335+00	2024-02-16 00:15:59.335+00	mAKp5BK7R1	FJOTueDfs2	4	1	4	4	3	\N	\N
TIQkshPkpl	2024-02-16 00:15:59.547+00	2024-02-16 00:15:59.547+00	ONgyydfVNz	mMYg4cyd5R	2	4	1	3	4	\N	\N
0pDXA4fHBg	2024-02-16 00:15:59.834+00	2024-02-16 00:15:59.834+00	sHiqaG4iqY	UDXF0qXvDY	3	3	1	1	1	\N	\N
QXG8ocqeqo	2024-02-16 00:16:00.142+00	2024-02-16 00:16:00.142+00	NjxsGlPeB4	08liHW08uC	1	4	4	4	1	\N	\N
1UiFStxpMG	2024-02-16 00:16:00.354+00	2024-02-16 00:16:00.354+00	ONgyydfVNz	Gl96vGdYHM	4	1	1	1	1	\N	\N
WrSgMhwnCC	2024-02-16 00:16:00.958+00	2024-02-16 00:16:00.958+00	RWwLSzreG2	P9sBFomftT	4	2	0	0	4	\N	\N
v3zuCjCIdE	2024-02-16 00:16:01.162+00	2024-02-16 00:16:01.162+00	sy1HD51LXT	VK3vnSxIy8	2	2	0	4	0	\N	\N
cfXzyoGRFT	2024-02-16 00:16:01.37+00	2024-02-16 00:16:01.37+00	AsrLUQwxI9	6KvFK8yy1q	0	1	2	2	0	\N	\N
c7VU88CD09	2024-02-16 00:16:01.982+00	2024-02-16 00:16:01.982+00	iUlyHNFGpG	LgJuu5ABe5	3	3	0	0	1	\N	\N
PWkZ2O87eR	2024-02-16 00:16:02.187+00	2024-02-16 00:16:02.187+00	dZKm0wOhYa	uABtFsJhJc	2	0	4	0	4	\N	\N
HEcD22dQVV	2024-02-16 00:16:02.494+00	2024-02-16 00:16:02.494+00	1as6rMOzjQ	08liHW08uC	1	3	2	4	4	\N	\N
D9orINjOvF	2024-02-16 00:16:02.699+00	2024-02-16 00:16:02.699+00	ONgyydfVNz	IEqTHcohpJ	1	1	1	2	2	\N	\N
Urxfqnr4xz	2024-02-16 00:16:02.91+00	2024-02-16 00:16:02.91+00	mAKp5BK7R1	OQWu2bnHeC	0	4	1	1	2	\N	\N
l8DTfUzrol	2024-02-16 00:16:03.119+00	2024-02-16 00:16:03.119+00	VshUk7eBeK	MQfxuw3ERg	2	1	0	3	0	\N	\N
7PiPF4QD6w	2024-02-16 00:16:03.33+00	2024-02-16 00:16:03.33+00	RWwLSzreG2	TZsdmscJ2B	3	3	3	1	2	\N	\N
xlsGVNgZBF	2024-02-16 00:16:03.928+00	2024-02-16 00:16:03.928+00	I5RzFRcQ7G	cmxBcanww9	3	1	2	1	1	\N	\N
eY7XjaCND5	2024-02-16 00:16:04.138+00	2024-02-16 00:16:04.138+00	AsrLUQwxI9	FJOTueDfs2	3	1	1	3	0	\N	\N
E5490LAU5m	2024-02-16 00:16:04.357+00	2024-02-16 00:16:04.357+00	5nv19u6KJ2	KCsJ4XR6Dn	0	0	0	0	0	\N	\N
DmFLHsaJwj	2024-02-16 00:16:04.563+00	2024-02-16 00:16:04.563+00	iUlyHNFGpG	FJOTueDfs2	3	0	2	2	1	\N	\N
eIlHL2b65G	2024-02-16 00:16:04.771+00	2024-02-16 00:16:04.771+00	ONgyydfVNz	lEPdiO1EDi	2	1	4	1	1	\N	\N
JVpgGxns6W	2024-02-16 00:16:04.978+00	2024-02-16 00:16:04.978+00	dEqAHvPMXA	VK3vnSxIy8	0	4	1	1	1	\N	\N
hoGEqzSK8W	2024-02-16 00:16:05.19+00	2024-02-16 00:16:05.19+00	opW2wQ2bZ8	e037qpAih3	4	2	3	2	1	\N	\N
edNvbvHr6y	2024-02-16 00:16:05.404+00	2024-02-16 00:16:05.404+00	R2CLtFh5jU	cmxBcanww9	4	0	2	4	2	\N	\N
NoKF6jnNJk	2024-02-16 00:16:05.641+00	2024-02-16 00:16:05.641+00	SFAISec8QF	l1Bslv8T2k	3	2	2	0	3	\N	\N
ZatEfSX48R	2024-02-16 00:16:05.852+00	2024-02-16 00:16:05.852+00	RWwLSzreG2	WSTLlXDcKl	2	1	0	1	0	\N	\N
eR17pK7MGU	2024-02-16 00:16:06.062+00	2024-02-16 00:16:06.062+00	mAKp5BK7R1	C7II8dYRPY	1	4	0	4	4	\N	\N
FTv0R9yOC7	2024-02-16 00:16:06.273+00	2024-02-16 00:16:06.273+00	1as6rMOzjQ	IybX0eBoO3	2	4	3	0	4	\N	\N
WoU9SPtUE9	2024-02-16 00:16:06.592+00	2024-02-16 00:16:06.592+00	SFAISec8QF	6Fo67rhTSP	0	4	1	2	0	\N	\N
QzbECfbR71	2024-02-16 00:16:06.803+00	2024-02-16 00:16:06.803+00	RWwLSzreG2	bQ0JOk10eL	0	0	1	1	0	\N	\N
oR4zzXAxI9	2024-02-16 00:16:07.105+00	2024-02-16 00:16:07.105+00	AsrLUQwxI9	M0tHrt1GgV	1	3	2	0	3	\N	\N
QLMCZVxAMp	2024-02-16 00:16:07.318+00	2024-02-16 00:16:07.318+00	mQXQWNqxg9	E2hBZzDsjO	4	2	3	1	2	\N	\N
OZpdnew6dD	2024-02-16 00:16:07.921+00	2024-02-16 00:16:07.921+00	9223vtvaBd	0TvWuLoLF5	2	0	3	1	4	\N	\N
WFGU1pKC87	2024-02-16 00:16:08.128+00	2024-02-16 00:16:08.128+00	RWwLSzreG2	VK3vnSxIy8	4	1	2	0	0	\N	\N
cU89aZ7FPh	2024-02-16 00:16:08.336+00	2024-02-16 00:16:08.336+00	HRhGpJpmb5	IEqTHcohpJ	3	1	4	2	3	\N	\N
2PWbYVZljB	2024-02-16 00:16:08.544+00	2024-02-16 00:16:08.544+00	5X202ssb0D	qEQ9tmLyW9	0	0	2	4	1	\N	\N
PnTPsjoeqY	2024-02-16 00:16:08.754+00	2024-02-16 00:16:08.754+00	RWwLSzreG2	bi1IivsuUB	0	4	2	0	0	\N	\N
P9UxdAgvAb	2024-02-16 00:16:09.052+00	2024-02-16 00:16:09.052+00	sy1HD51LXT	uABtFsJhJc	1	3	4	3	4	\N	\N
lodOyXXwRT	2024-02-16 00:16:09.262+00	2024-02-16 00:16:09.262+00	1as6rMOzjQ	m8hjjLVdPS	2	3	0	3	0	\N	\N
SyG1EFMvUd	2024-02-16 00:16:09.474+00	2024-02-16 00:16:09.474+00	SFAISec8QF	bQ0JOk10eL	4	3	2	4	2	\N	\N
2VyqAXggcl	2024-02-16 00:16:09.685+00	2024-02-16 00:16:09.685+00	opW2wQ2bZ8	08liHW08uC	0	4	3	2	1	\N	\N
jtVNfXgNXC	2024-02-16 00:16:09.943+00	2024-02-16 00:16:09.943+00	SFAISec8QF	XSK814B37m	0	4	0	1	2	\N	\N
198z56tqBu	2024-02-16 00:16:10.159+00	2024-02-16 00:16:10.159+00	dZKm0wOhYa	HSEugQ3Ouj	2	2	2	2	0	\N	\N
oRfH744kP4	2024-02-16 00:16:10.791+00	2024-02-16 00:16:10.791+00	iWxl9obi8w	fxvABtKCPT	0	3	2	4	2	\N	\N
lgNVILGzIE	2024-02-16 00:16:10.999+00	2024-02-16 00:16:10.999+00	SFAISec8QF	l1Bslv8T2k	3	3	2	4	4	\N	\N
RIIKYkyTdm	2024-02-16 00:16:11.206+00	2024-02-16 00:16:11.206+00	I5RzFRcQ7G	oABNR2FF6S	4	2	0	4	1	\N	\N
Nb8tDHh3IQ	2024-02-16 00:16:11.729+00	2024-02-16 00:16:11.729+00	VshUk7eBeK	m6g8u0QpTC	0	1	3	4	2	\N	\N
n4ubUhl979	2024-02-16 00:16:11.937+00	2024-02-16 00:16:11.937+00	5X202ssb0D	vwHi602n66	0	3	1	4	1	\N	\N
XonF22ok15	2024-02-16 00:16:12.222+00	2024-02-16 00:16:12.222+00	5nv19u6KJ2	0TvWuLoLF5	2	0	0	0	4	\N	\N
doZt9pnAAi	2024-02-16 00:16:12.429+00	2024-02-16 00:16:12.429+00	I5RzFRcQ7G	XwWwGnkXNj	1	1	2	4	3	\N	\N
PuDcFL6NgB	2024-02-16 00:16:12.638+00	2024-02-16 00:16:12.638+00	RWwLSzreG2	y4RkaDbkec	2	3	2	3	2	\N	\N
8gXGDubzKz	2024-02-16 00:16:12.846+00	2024-02-16 00:16:12.846+00	dZKm0wOhYa	oABNR2FF6S	3	2	2	1	1	\N	\N
zZIDDAatLJ	2024-02-16 00:16:13.054+00	2024-02-16 00:16:13.054+00	jqDYoPT45X	JLhF4VuByh	1	2	1	4	2	\N	\N
pgco1h9rte	2024-02-16 00:16:13.261+00	2024-02-16 00:16:13.261+00	sy1HD51LXT	OQWu2bnHeC	3	3	1	3	1	\N	\N
5IxCtbhzbH	2024-02-16 00:16:13.471+00	2024-02-16 00:16:13.471+00	RWwLSzreG2	eEmewy7hPd	2	0	4	0	3	\N	\N
ufV81Afi72	2024-02-16 00:16:14.168+00	2024-02-16 00:16:14.168+00	HtEtaHBVDN	M0tHrt1GgV	0	3	2	4	2	\N	\N
YsWFqKJGCs	2024-02-16 00:16:14.476+00	2024-02-16 00:16:14.476+00	jqDYoPT45X	HXtEwLBC7f	4	0	3	1	3	\N	\N
doYWCSrZRQ	2024-02-16 00:16:14.686+00	2024-02-16 00:16:14.686+00	I5RzFRcQ7G	TZsdmscJ2B	1	1	3	2	0	\N	\N
iqbuI4dX8Z	2024-02-16 00:16:14.896+00	2024-02-16 00:16:14.896+00	adE9nQrDk3	NBojpORh3G	4	3	1	3	4	\N	\N
9P6JHCUcOh	2024-02-16 00:16:15.598+00	2024-02-16 00:16:15.598+00	jqDYoPT45X	M0tHrt1GgV	4	0	4	2	4	\N	\N
DXvzhD8Jq0	2024-02-16 00:16:15.803+00	2024-02-16 00:16:15.803+00	SFAISec8QF	6Fo67rhTSP	1	2	4	1	3	\N	\N
1F3EBhhyZn	2024-02-16 00:16:16.01+00	2024-02-16 00:16:16.01+00	VshUk7eBeK	6Fo67rhTSP	4	1	1	3	4	\N	\N
CF17Vn5TGp	2024-02-16 00:16:16.623+00	2024-02-16 00:16:16.623+00	S6wz0lK0bf	uABtFsJhJc	4	1	2	2	4	\N	\N
LUoJHdd61z	2024-02-16 00:16:16.831+00	2024-02-16 00:16:16.831+00	dEqAHvPMXA	LVYK4mLShP	1	0	0	3	2	\N	\N
tBHquVcFjt	2024-02-16 00:16:17.043+00	2024-02-16 00:16:17.043+00	S6wz0lK0bf	rKyjwoEIRp	1	0	1	1	2	\N	\N
q88D46gexe	2024-02-16 00:16:17.342+00	2024-02-16 00:16:17.342+00	I5RzFRcQ7G	ThMuD3hYRQ	2	0	1	1	1	\N	\N
Xt2MBmqLsW	2024-02-16 00:16:17.649+00	2024-02-16 00:16:17.649+00	iUlyHNFGpG	AgU9OLJkqz	0	2	4	4	1	\N	\N
M1SZKCgU0C	2024-02-16 00:16:17.864+00	2024-02-16 00:16:17.864+00	Otwj7uJwjr	cFtamPA0zH	2	1	0	4	3	\N	\N
vuSh6JCeDY	2024-02-16 00:16:18.163+00	2024-02-16 00:16:18.163+00	5X202ssb0D	j0dWqP2C2A	1	1	3	0	4	\N	\N
9ehNojqFsb	2024-02-16 00:16:18.47+00	2024-02-16 00:16:18.47+00	Otwj7uJwjr	XwszrNEEEj	2	2	0	3	2	\N	\N
BC4HmY1tZB	2024-02-16 00:16:18.676+00	2024-02-16 00:16:18.676+00	Otwj7uJwjr	uigc7bJBOJ	2	3	3	0	1	\N	\N
XlZNHVgmVn	2024-02-16 00:16:18.886+00	2024-02-16 00:16:18.886+00	iUlyHNFGpG	0TvWuLoLF5	1	0	3	4	1	\N	\N
MoV5bUF9h5	2024-02-16 00:16:19.344+00	2024-02-16 00:16:19.344+00	1as6rMOzjQ	JRi61dUphq	1	4	2	3	3	\N	\N
2cfEKzmMOk	2024-02-16 00:16:19.554+00	2024-02-16 00:16:19.554+00	S6wz0lK0bf	u5FXeeOChJ	1	0	0	3	0	\N	\N
cfxiteiuMc	2024-02-16 00:16:19.76+00	2024-02-16 00:16:19.76+00	VshUk7eBeK	MQfxuw3ERg	3	1	0	2	2	\N	\N
w6TItSIHB7	2024-02-16 00:16:19.97+00	2024-02-16 00:16:19.97+00	Otwj7uJwjr	uABtFsJhJc	2	4	4	0	1	\N	\N
m54c8Y2gEv	2024-02-16 00:16:20.211+00	2024-02-16 00:16:20.211+00	opW2wQ2bZ8	rT0UCBK1bE	1	3	0	4	0	\N	\N
oXWU0mDkFq	2024-02-16 00:16:20.517+00	2024-02-16 00:16:20.517+00	sHiqaG4iqY	PF8w2gMAdi	1	3	2	2	4	\N	\N
1AKhNDaCap	2024-02-16 00:16:20.824+00	2024-02-16 00:16:20.824+00	VshUk7eBeK	OQWu2bnHeC	1	1	0	2	0	\N	\N
yQN5H9SdlT	2024-02-16 00:16:21.125+00	2024-02-16 00:16:21.125+00	sHiqaG4iqY	XSK814B37m	4	4	3	0	3	\N	\N
JgckQhxEqd	2024-02-16 00:16:21.328+00	2024-02-16 00:16:21.328+00	AsrLUQwxI9	E2hBZzDsjO	1	2	1	4	2	\N	\N
qrISvYXoSV	2024-02-16 00:16:21.534+00	2024-02-16 00:16:21.534+00	mQXQWNqxg9	WnUBBkiDjE	2	4	3	0	4	\N	\N
RRHpKRbeWi	2024-02-16 00:16:21.741+00	2024-02-16 00:16:21.741+00	NjxsGlPeB4	l1Bslv8T2k	3	0	3	1	1	\N	\N
z8PrxLuu12	2024-02-16 00:16:21.95+00	2024-02-16 00:16:21.95+00	RWwLSzreG2	VK3vnSxIy8	0	0	2	4	0	\N	\N
vD2xQ2xn2z	2024-02-16 00:16:22.16+00	2024-02-16 00:16:22.16+00	SFAISec8QF	uABtFsJhJc	3	0	0	0	3	\N	\N
QIqBjv02b9	2024-02-16 00:16:22.369+00	2024-02-16 00:16:22.369+00	5nv19u6KJ2	AgU9OLJkqz	1	4	3	0	1	\N	\N
cQxRWnvIDT	2024-02-16 00:16:22.577+00	2024-02-16 00:16:22.577+00	5nv19u6KJ2	ThMuD3hYRQ	2	2	3	0	1	\N	\N
P8NaXz1k6U	2024-02-16 00:16:22.789+00	2024-02-16 00:16:22.789+00	mQXQWNqxg9	BMLzFMvIT6	0	1	4	3	0	\N	\N
Gh3xOThPI3	2024-02-16 00:16:23.001+00	2024-02-16 00:16:23.001+00	opW2wQ2bZ8	o4VD4BWwDt	1	3	3	3	3	\N	\N
t4FCuuABGD	2024-02-16 00:16:23.211+00	2024-02-16 00:16:23.211+00	WKpBp0c8F3	Pja6n3yaWZ	2	0	4	1	3	\N	\N
ZG1HHvuBWa	2024-02-16 00:16:23.425+00	2024-02-16 00:16:23.425+00	iWxl9obi8w	UCFo58JaaD	2	4	1	3	2	\N	\N
2iOuDdV8HX	2024-02-16 00:16:23.637+00	2024-02-16 00:16:23.637+00	HtEtaHBVDN	vwHi602n66	3	4	3	3	4	\N	\N
pXnfSbwJU4	2024-02-16 00:16:23.898+00	2024-02-16 00:16:23.898+00	5X202ssb0D	UDXF0qXvDY	0	4	3	1	3	\N	\N
dySDp09GXU	2024-02-16 00:16:24.107+00	2024-02-16 00:16:24.107+00	jqDYoPT45X	EmIUBFwx0Z	0	1	4	2	0	\N	\N
ZN9rxjFNk4	2024-02-16 00:16:24.318+00	2024-02-16 00:16:24.318+00	SFAISec8QF	uABtFsJhJc	0	3	2	4	4	\N	\N
SAYDm2h9XZ	2024-02-16 00:16:24.531+00	2024-02-16 00:16:24.531+00	AsrLUQwxI9	TpGyMZM9BG	0	3	3	1	4	\N	\N
PRgd1DVvS4	2024-02-16 00:16:25.123+00	2024-02-16 00:16:25.123+00	mAKp5BK7R1	H40ivltLwZ	3	4	1	1	4	\N	\N
m2cvzmizTG	2024-02-16 00:16:25.33+00	2024-02-16 00:16:25.33+00	HtEtaHBVDN	jHqCpA1nWb	3	0	2	0	2	\N	\N
5glNSWrjbC	2024-02-16 00:16:25.54+00	2024-02-16 00:16:25.54+00	R2CLtFh5jU	o90lhsZ7FK	3	2	1	1	1	\N	\N
qpo6k3tlRp	2024-02-16 00:16:25.742+00	2024-02-16 00:16:25.742+00	ONgyydfVNz	3u4B9V4l5K	2	2	1	0	1	\N	\N
g6o6T560yi	2024-02-16 00:16:26.047+00	2024-02-16 00:16:26.047+00	AsrLUQwxI9	yvUod6yLDt	4	3	1	4	3	\N	\N
mCga7yOyUx	2024-02-16 00:16:26.354+00	2024-02-16 00:16:26.354+00	sHiqaG4iqY	AgU9OLJkqz	4	4	3	3	3	\N	\N
nPQBwMEPeQ	2024-02-16 00:16:26.562+00	2024-02-16 00:16:26.562+00	mAKp5BK7R1	jHqCpA1nWb	4	0	0	4	1	\N	\N
isVubw6Qnf	2024-02-16 00:16:26.766+00	2024-02-16 00:16:26.766+00	5nv19u6KJ2	cwVEh0dqfm	4	4	0	4	2	\N	\N
24Dwgxm0yI	2024-02-16 00:16:26.975+00	2024-02-16 00:16:26.975+00	mQXQWNqxg9	bQpy9LEJWn	2	3	4	4	4	\N	\N
bJqW5WP0vS	2024-02-16 00:16:27.276+00	2024-02-16 00:16:27.276+00	R2CLtFh5jU	ThMuD3hYRQ	4	0	4	2	2	\N	\N
jw1WGnP00a	2024-02-16 00:16:27.582+00	2024-02-16 00:16:27.582+00	iWxl9obi8w	IybX0eBoO3	4	3	3	4	3	\N	\N
XmCXWN8L89	2024-02-16 00:16:27.89+00	2024-02-16 00:16:27.89+00	RWwLSzreG2	j0dWqP2C2A	2	2	0	1	0	\N	\N
DW3M09uFPF	2024-02-16 00:16:28.096+00	2024-02-16 00:16:28.096+00	HtEtaHBVDN	uigc7bJBOJ	4	2	4	2	0	\N	\N
mQDEknGGQz	2024-02-16 00:16:28.306+00	2024-02-16 00:16:28.306+00	iWxl9obi8w	PF8w2gMAdi	1	1	2	2	2	\N	\N
6ZUT8F2ZY0	2024-02-16 00:16:28.513+00	2024-02-16 00:16:28.513+00	mQXQWNqxg9	08liHW08uC	0	3	3	3	4	\N	\N
3chXFBCAzv	2024-02-16 00:16:28.721+00	2024-02-16 00:16:28.721+00	AsrLUQwxI9	JZOBDAh12a	0	3	0	0	3	\N	\N
LXwTkqUEek	2024-02-16 00:16:28.929+00	2024-02-16 00:16:28.929+00	jqDYoPT45X	e037qpAih3	2	3	2	3	1	\N	\N
O33yT1oew9	2024-02-16 00:16:29.131+00	2024-02-16 00:16:29.131+00	HRhGpJpmb5	uABtFsJhJc	3	1	3	2	4	\N	\N
XDzbaK5gSY	2024-02-16 00:16:29.34+00	2024-02-16 00:16:29.34+00	jqDYoPT45X	BMLzFMvIT6	2	1	4	3	1	\N	\N
abd1t3cdtZ	2024-02-16 00:16:29.632+00	2024-02-16 00:16:29.632+00	opW2wQ2bZ8	AgU9OLJkqz	4	1	4	4	4	\N	\N
ozb1dWlAwo	2024-02-16 00:16:29.939+00	2024-02-16 00:16:29.939+00	R2CLtFh5jU	OQWu2bnHeC	3	4	2	0	0	\N	\N
ns8hpdM2RR	2024-02-16 00:16:30.149+00	2024-02-16 00:16:30.149+00	S6wz0lK0bf	08liHW08uC	0	1	0	4	3	\N	\N
KM0JmcWGEO	2024-02-16 00:16:30.363+00	2024-02-16 00:16:30.363+00	I5RzFRcQ7G	JRi61dUphq	2	3	2	0	3	\N	\N
tNzbJVb7l8	2024-02-16 00:16:30.578+00	2024-02-16 00:16:30.578+00	S6wz0lK0bf	jHqCpA1nWb	4	3	3	3	1	\N	\N
mLD9PqItYG	2024-02-16 00:16:30.791+00	2024-02-16 00:16:30.791+00	S6wz0lK0bf	NBojpORh3G	2	0	3	0	3	\N	\N
HlK41SRPGt	2024-02-16 00:16:31.003+00	2024-02-16 00:16:31.003+00	1as6rMOzjQ	TZsdmscJ2B	0	2	0	2	0	\N	\N
FGLe3uDBLi	2024-02-16 00:16:31.577+00	2024-02-16 00:16:31.577+00	NjxsGlPeB4	ThMuD3hYRQ	3	2	2	3	4	\N	\N
1dExPYPKSr	2024-02-16 00:16:31.79+00	2024-02-16 00:16:31.79+00	I5RzFRcQ7G	XSK814B37m	1	0	2	2	2	\N	\N
Gvf9SFJkEe	2024-02-16 00:16:32.09+00	2024-02-16 00:16:32.09+00	WKpBp0c8F3	LVYK4mLShP	2	4	2	0	0	\N	\N
N92Cqm9y50	2024-02-16 00:16:32.304+00	2024-02-16 00:16:32.304+00	5nv19u6KJ2	fxvABtKCPT	2	4	3	0	3	\N	\N
AisJ9KZ2qR	2024-02-16 00:16:32.602+00	2024-02-16 00:16:32.602+00	I5RzFRcQ7G	BMLzFMvIT6	4	3	0	3	4	\N	\N
OqpRcXdWO2	2024-02-16 00:16:32.811+00	2024-02-16 00:16:32.811+00	mAKp5BK7R1	LDrIH1vU8x	2	4	2	3	2	\N	\N
AXuxP3qEql	2024-02-16 00:16:33.022+00	2024-02-16 00:16:33.022+00	SFAISec8QF	D0A6GLdsDM	1	4	1	2	0	\N	\N
LXPqBGeQHc	2024-02-16 00:16:33.232+00	2024-02-16 00:16:33.232+00	Otwj7uJwjr	m8hjjLVdPS	3	0	0	1	3	\N	\N
FzZtHP8VHE	2024-02-16 00:16:33.444+00	2024-02-16 00:16:33.444+00	SFAISec8QF	LgJuu5ABe5	4	4	0	1	1	\N	\N
zIjkkZly2A	2024-02-16 00:16:33.654+00	2024-02-16 00:16:33.654+00	iWxl9obi8w	XwWwGnkXNj	4	2	4	1	4	\N	\N
hvCbC0f9Cq	2024-02-16 00:16:33.864+00	2024-02-16 00:16:33.864+00	HRhGpJpmb5	Pa0qBO2rzK	4	1	0	2	1	\N	\N
15Ea1Fu8kw	2024-02-16 00:16:34.075+00	2024-02-16 00:16:34.075+00	iWxl9obi8w	cFtamPA0zH	3	3	0	1	0	\N	\N
FcwH5ehLmn	2024-02-16 00:16:34.286+00	2024-02-16 00:16:34.286+00	VshUk7eBeK	0TvWuLoLF5	0	1	4	2	3	\N	\N
TzUYy8Im4D	2024-02-16 00:16:34.865+00	2024-02-16 00:16:34.865+00	dZKm0wOhYa	cTIjuPjyIa	1	0	1	2	2	\N	\N
mv89KEJWmv	2024-02-16 00:16:35.072+00	2024-02-16 00:16:35.072+00	sHiqaG4iqY	cFtamPA0zH	0	2	1	2	0	\N	\N
RNQPAjSCHa	2024-02-16 00:16:35.279+00	2024-02-16 00:16:35.279+00	adE9nQrDk3	qZmnAnnPEb	3	3	3	4	2	\N	\N
7I87HkJ7P0	2024-02-16 00:16:35.571+00	2024-02-16 00:16:35.571+00	dEqAHvPMXA	Gl96vGdYHM	4	1	1	1	4	\N	\N
eAfDBa5U1G	2024-02-16 00:16:35.78+00	2024-02-16 00:16:35.78+00	1as6rMOzjQ	NBojpORh3G	0	1	3	4	0	\N	\N
86s5puGvIA	2024-02-16 00:16:35.988+00	2024-02-16 00:16:35.988+00	mAKp5BK7R1	WHvlAGgj6c	4	2	3	3	1	\N	\N
L4jBGFkqqr	2024-02-16 00:16:36.289+00	2024-02-16 00:16:36.289+00	jqDYoPT45X	OQWu2bnHeC	4	1	3	3	2	\N	\N
CUNDUn08V0	2024-02-16 00:16:36.597+00	2024-02-16 00:16:36.597+00	S6wz0lK0bf	14jGmOAXcg	1	3	0	3	3	\N	\N
rYQAfwUBRl	2024-02-16 00:16:36.807+00	2024-02-16 00:16:36.807+00	S6wz0lK0bf	LVYK4mLShP	4	3	2	0	3	\N	\N
OhICgrsABt	2024-02-16 00:16:37.106+00	2024-02-16 00:16:37.106+00	HtEtaHBVDN	LVYK4mLShP	0	4	1	3	0	\N	\N
6MBAzlKkVv	2024-02-16 00:16:37.317+00	2024-02-16 00:16:37.317+00	dEqAHvPMXA	P9sBFomftT	2	0	1	3	3	\N	\N
k54DrHIlvm	2024-02-16 00:16:37.525+00	2024-02-16 00:16:37.525+00	iWxl9obi8w	LVYK4mLShP	2	0	4	0	1	\N	\N
46uPEncr9w	2024-02-16 00:16:37.823+00	2024-02-16 00:16:37.823+00	jqDYoPT45X	FJOTueDfs2	4	4	0	4	4	\N	\N
uIf283zqc4	2024-02-16 00:16:38.132+00	2024-02-16 00:16:38.132+00	dZKm0wOhYa	LDrIH1vU8x	1	1	0	0	3	\N	\N
qMmXBbWBu4	2024-02-16 00:16:38.342+00	2024-02-16 00:16:38.342+00	5nv19u6KJ2	mMYg4cyd5R	2	0	1	0	1	\N	\N
VtjfXM4HwY	2024-02-16 00:16:38.551+00	2024-02-16 00:16:38.551+00	Otwj7uJwjr	IybX0eBoO3	2	4	4	0	3	\N	\N
aknB4sVGte	2024-02-16 00:16:38.763+00	2024-02-16 00:16:38.763+00	sy1HD51LXT	XwszrNEEEj	2	2	4	3	4	\N	\N
2asEum5v4e	2024-02-16 00:16:38.978+00	2024-02-16 00:16:38.978+00	jqDYoPT45X	cFtamPA0zH	2	3	3	3	0	\N	\N
0k4JZke0Qi	2024-02-16 00:16:39.192+00	2024-02-16 00:16:39.192+00	dEqAHvPMXA	na5crB8ED1	2	0	3	1	4	\N	\N
5PGlQMSdOJ	2024-02-16 00:16:39.463+00	2024-02-16 00:16:39.463+00	sy1HD51LXT	HSEugQ3Ouj	4	1	0	4	1	\N	\N
sZNP4Zij6F	2024-02-16 00:16:39.674+00	2024-02-16 00:16:39.674+00	5X202ssb0D	o4VD4BWwDt	4	4	3	4	2	\N	\N
EWIaYNw4V5	2024-02-16 00:16:39.974+00	2024-02-16 00:16:39.974+00	NjxsGlPeB4	jjVdtithcD	0	3	3	4	4	\N	\N
O30hYVdxB6	2024-02-16 00:16:40.282+00	2024-02-16 00:16:40.282+00	R2CLtFh5jU	bQ0JOk10eL	3	2	4	3	3	\N	\N
vYxBLQmG4k	2024-02-16 00:16:40.493+00	2024-02-16 00:16:40.493+00	HtEtaHBVDN	OQWu2bnHeC	4	1	3	0	0	\N	\N
rD5JVBaFQS	2024-02-16 00:16:40.703+00	2024-02-16 00:16:40.703+00	dEqAHvPMXA	TZsdmscJ2B	1	4	0	0	0	\N	\N
YMiALETbSQ	2024-02-16 00:16:40.913+00	2024-02-16 00:16:40.913+00	HtEtaHBVDN	u5FXeeOChJ	0	0	1	4	3	\N	\N
pB30nH4bgq	2024-02-16 00:16:41.116+00	2024-02-16 00:16:41.116+00	iWxl9obi8w	qZmnAnnPEb	1	3	4	0	3	\N	\N
NkuDfnfA9g	2024-02-16 00:16:41.324+00	2024-02-16 00:16:41.324+00	dZKm0wOhYa	LgJuu5ABe5	4	4	2	4	2	\N	\N
4zCqEihn96	2024-02-16 00:16:41.535+00	2024-02-16 00:16:41.535+00	iWxl9obi8w	TpGyMZM9BG	0	3	2	2	1	\N	\N
dWHfWMcSaT	2024-02-16 00:16:41.743+00	2024-02-16 00:16:41.743+00	SFAISec8QF	uigc7bJBOJ	0	2	4	3	2	\N	\N
9bysguF3U8	2024-02-16 00:16:41.951+00	2024-02-16 00:16:41.951+00	Otwj7uJwjr	yvUod6yLDt	2	2	0	0	0	\N	\N
PVqKO7JAzX	2024-02-16 00:16:42.16+00	2024-02-16 00:16:42.16+00	sy1HD51LXT	cFtamPA0zH	4	0	3	3	0	\N	\N
MM1mWEELQI	2024-02-16 00:16:42.373+00	2024-02-16 00:16:42.373+00	AsrLUQwxI9	AgU9OLJkqz	0	0	4	3	3	\N	\N
7vfARhDLtq	2024-02-16 00:16:42.638+00	2024-02-16 00:16:42.638+00	S6wz0lK0bf	EmIUBFwx0Z	0	3	1	4	0	\N	\N
ihg06rZJFa	2024-02-16 00:16:42.945+00	2024-02-16 00:16:42.945+00	RWwLSzreG2	cFtamPA0zH	3	2	1	3	0	\N	\N
FhgJdaGtyd	2024-02-16 00:16:43.162+00	2024-02-16 00:16:43.162+00	S6wz0lK0bf	FJOTueDfs2	2	4	1	3	0	\N	\N
ecQB9ze0rq	2024-02-16 00:16:43.371+00	2024-02-16 00:16:43.371+00	dEqAHvPMXA	eEmewy7hPd	1	0	1	3	1	\N	\N
S2m4FxY8QX	2024-02-16 00:16:43.581+00	2024-02-16 00:16:43.581+00	5X202ssb0D	j0dWqP2C2A	4	4	1	4	0	\N	\N
M2BuoU9tS8	2024-02-16 00:16:43.792+00	2024-02-16 00:16:43.792+00	9223vtvaBd	RBRcyltRSC	1	0	4	2	4	\N	\N
AsnvRzuqFG	2024-02-16 00:16:44.074+00	2024-02-16 00:16:44.074+00	iWxl9obi8w	AgU9OLJkqz	3	3	4	0	3	\N	\N
12DT1Bskcr	2024-02-16 00:16:44.289+00	2024-02-16 00:16:44.289+00	9223vtvaBd	qZmnAnnPEb	1	3	0	4	0	\N	\N
xH8ewgZzY7	2024-02-16 00:16:44.583+00	2024-02-16 00:16:44.583+00	adE9nQrDk3	cFtamPA0zH	2	2	0	2	3	\N	\N
kZf7JVwH5X	2024-02-16 00:16:44.891+00	2024-02-16 00:16:44.891+00	S6wz0lK0bf	y4RkaDbkec	0	2	2	3	0	\N	\N
lxhGVZHrts	2024-02-16 00:16:45.503+00	2024-02-16 00:16:45.503+00	AsrLUQwxI9	3u4B9V4l5K	4	3	2	0	4	\N	\N
n7CDAM216M	2024-02-16 00:16:45.714+00	2024-02-16 00:16:45.714+00	5nv19u6KJ2	LgJuu5ABe5	3	3	2	0	4	\N	\N
6Ea7gqI3yK	2024-02-16 00:16:45.926+00	2024-02-16 00:16:45.926+00	SFAISec8QF	08liHW08uC	0	2	3	2	3	\N	\N
vLAVIHz1sh	2024-02-16 00:16:46.131+00	2024-02-16 00:16:46.131+00	AsrLUQwxI9	PF8w2gMAdi	2	3	2	2	4	\N	\N
SkiHGsWgd9	2024-02-16 00:16:46.34+00	2024-02-16 00:16:46.34+00	9223vtvaBd	NY6RE1qgWu	1	3	1	3	4	\N	\N
ccS3jZARx3	2024-02-16 00:16:46.631+00	2024-02-16 00:16:46.631+00	AsrLUQwxI9	3u4B9V4l5K	1	3	1	0	1	\N	\N
3FDQJIIIG9	2024-02-16 00:16:46.842+00	2024-02-16 00:16:46.842+00	HRhGpJpmb5	rKyjwoEIRp	0	2	0	1	4	\N	\N
XoqitNwdF3	2024-02-16 00:16:47.145+00	2024-02-16 00:16:47.145+00	I5RzFRcQ7G	6KvFK8yy1q	3	4	0	4	1	\N	\N
uJ532GpBDn	2024-02-16 00:16:47.355+00	2024-02-16 00:16:47.355+00	WKpBp0c8F3	qEQ9tmLyW9	3	1	2	4	1	\N	\N
WjWFfi7e8A	2024-02-16 00:16:47.564+00	2024-02-16 00:16:47.564+00	I5RzFRcQ7G	y4RkaDbkec	3	3	1	1	3	\N	\N
1Nve6xqB0A	2024-02-16 00:16:47.776+00	2024-02-16 00:16:47.776+00	iWxl9obi8w	cTIjuPjyIa	4	2	0	1	0	\N	\N
IaOvCC61vs	2024-02-16 00:16:47.987+00	2024-02-16 00:16:47.987+00	sHiqaG4iqY	MQfxuw3ERg	2	3	1	0	3	\N	\N
uQoSIbXJiJ	2024-02-16 00:16:48.2+00	2024-02-16 00:16:48.2+00	I5RzFRcQ7G	3P6kmNoY1F	3	2	2	3	1	\N	\N
r47kBSONIY	2024-02-16 00:16:48.409+00	2024-02-16 00:16:48.409+00	S6wz0lK0bf	qZmnAnnPEb	4	3	2	0	0	\N	\N
pjnAvTx0DA	2024-02-16 00:16:48.62+00	2024-02-16 00:16:48.62+00	ONgyydfVNz	LDrIH1vU8x	3	2	0	4	1	\N	\N
SroAD3CEFh	2024-02-16 00:16:48.886+00	2024-02-16 00:16:48.886+00	5nv19u6KJ2	WHvlAGgj6c	0	4	0	2	3	\N	\N
sSswBCEVww	2024-02-16 00:16:49.097+00	2024-02-16 00:16:49.097+00	dEqAHvPMXA	FJOTueDfs2	2	1	2	4	2	\N	\N
TE6PLtJWDW	2024-02-16 00:16:49.31+00	2024-02-16 00:16:49.31+00	dEqAHvPMXA	3u4B9V4l5K	1	4	2	2	4	\N	\N
GzWiTETRNu	2024-02-16 00:16:49.519+00	2024-02-16 00:16:49.519+00	AsrLUQwxI9	RkhjIQJgou	1	1	2	3	3	\N	\N
E2Q9Axjll2	2024-02-16 00:16:49.806+00	2024-02-16 00:16:49.806+00	jqDYoPT45X	NBojpORh3G	1	0	4	0	1	\N	\N
NfDy1SNycR	2024-02-16 00:16:50.115+00	2024-02-16 00:16:50.115+00	adE9nQrDk3	lEPdiO1EDi	2	0	4	3	2	\N	\N
I041CnWFl9	2024-02-16 00:16:50.42+00	2024-02-16 00:16:50.42+00	5X202ssb0D	M0tHrt1GgV	1	2	3	1	2	\N	\N
OZHogstVDF	2024-02-16 00:16:50.623+00	2024-02-16 00:16:50.623+00	SFAISec8QF	qZmnAnnPEb	1	0	0	4	3	\N	\N
oKtAMffSbE	2024-02-16 00:16:50.934+00	2024-02-16 00:16:50.934+00	1as6rMOzjQ	RBRcyltRSC	1	4	0	3	3	\N	\N
ElIrLYLuki	2024-02-16 00:16:51.348+00	2024-02-16 00:16:51.348+00	opW2wQ2bZ8	89xRG1afNi	4	0	2	4	4	\N	\N
P6bxpyD6R6	2024-02-16 00:16:51.552+00	2024-02-16 00:16:51.552+00	mAKp5BK7R1	Oahm9sOn1y	2	0	4	3	3	\N	\N
zY4WQ59sXG	2024-02-16 00:16:51.759+00	2024-02-16 00:16:51.759+00	dEqAHvPMXA	mMYg4cyd5R	2	4	1	3	4	\N	\N
kMftRMd590	2024-02-16 00:16:52.058+00	2024-02-16 00:16:52.058+00	jqDYoPT45X	INeptnSdJC	0	1	1	0	0	\N	\N
9cGUuxvpvU	2024-02-16 00:16:52.269+00	2024-02-16 00:16:52.269+00	opW2wQ2bZ8	IybX0eBoO3	4	1	4	3	3	\N	\N
KXS6xM3nue	2024-02-16 00:16:52.572+00	2024-02-16 00:16:52.572+00	5X202ssb0D	l1Bslv8T2k	0	1	2	1	0	\N	\N
5Ge1VfbxXc	2024-02-16 00:16:52.779+00	2024-02-16 00:16:52.779+00	iUlyHNFGpG	XwWwGnkXNj	3	1	0	0	3	\N	\N
PZWhuzDLF2	2024-02-16 00:16:52.989+00	2024-02-16 00:16:52.989+00	iUlyHNFGpG	cmxBcanww9	4	4	3	4	3	\N	\N
yWDSfALfaK	2024-02-16 00:16:53.199+00	2024-02-16 00:16:53.199+00	adE9nQrDk3	y4RkaDbkec	1	0	2	0	3	\N	\N
LUETmuupfs	2024-02-16 00:16:53.407+00	2024-02-16 00:16:53.407+00	jqDYoPT45X	bi1IivsuUB	0	3	4	1	2	\N	\N
V3v7tAhr3n	2024-02-16 00:16:53.617+00	2024-02-16 00:16:53.617+00	I5RzFRcQ7G	WnUBBkiDjE	0	1	4	0	4	\N	\N
EXQYoBimnG	2024-02-16 00:16:53.827+00	2024-02-16 00:16:53.827+00	AsrLUQwxI9	cFtamPA0zH	3	2	2	4	0	\N	\N
8VXIjUTA5C	2024-02-16 00:16:54.037+00	2024-02-16 00:16:54.037+00	iUlyHNFGpG	fxvABtKCPT	4	3	1	2	1	\N	\N
Wx6wfGaA8l	2024-02-16 00:16:54.722+00	2024-02-16 00:16:54.722+00	sy1HD51LXT	INeptnSdJC	2	1	3	0	4	\N	\N
jA5RPLIikQ	2024-02-16 00:16:54.932+00	2024-02-16 00:16:54.932+00	1as6rMOzjQ	LDrIH1vU8x	1	0	1	4	1	\N	\N
7qAE0MJ3iO	2024-02-16 00:16:55.141+00	2024-02-16 00:16:55.141+00	5X202ssb0D	E2hBZzDsjO	2	3	0	4	4	\N	\N
l7scoP2pvs	2024-02-16 00:16:55.438+00	2024-02-16 00:16:55.438+00	S6wz0lK0bf	Pa0qBO2rzK	3	1	1	2	4	\N	\N
0UDnQeiyBU	2024-02-16 00:16:55.745+00	2024-02-16 00:16:55.745+00	HtEtaHBVDN	3u4B9V4l5K	1	4	3	4	2	\N	\N
Zr2FTkDIHG	2024-02-16 00:16:55.955+00	2024-02-16 00:16:55.955+00	mQXQWNqxg9	eEmewy7hPd	4	3	4	2	1	\N	\N
hqjXjxOuLv	2024-02-16 00:16:56.158+00	2024-02-16 00:16:56.158+00	VshUk7eBeK	M0tHrt1GgV	0	1	0	0	0	\N	\N
YLeb7Pi2Q5	2024-02-16 00:16:56.369+00	2024-02-16 00:16:56.369+00	NjxsGlPeB4	fKTSJPdUi9	3	0	4	0	2	\N	\N
On2b0q1Gjk	2024-02-16 00:16:56.582+00	2024-02-16 00:16:56.582+00	HtEtaHBVDN	y4RkaDbkec	3	0	0	3	2	\N	\N
HfVKLh1GEr	2024-02-16 00:16:56.794+00	2024-02-16 00:16:56.794+00	sHiqaG4iqY	C7II8dYRPY	4	0	3	3	0	\N	\N
YM2kVoBOgG	2024-02-16 00:16:57.003+00	2024-02-16 00:16:57.003+00	S6wz0lK0bf	WnUBBkiDjE	0	1	3	3	0	\N	\N
VxpidEpZtG	2024-02-16 00:16:57.215+00	2024-02-16 00:16:57.215+00	SFAISec8QF	fxvABtKCPT	0	1	4	0	2	\N	\N
YE32hkq9kM	2024-02-16 00:16:57.428+00	2024-02-16 00:16:57.428+00	I5RzFRcQ7G	oABNR2FF6S	4	4	1	2	0	\N	\N
dnEhmSq1ll	2024-02-16 00:16:58.101+00	2024-02-16 00:16:58.101+00	HRhGpJpmb5	H40ivltLwZ	3	1	0	0	2	\N	\N
CrAnhoCy4P	2024-02-16 00:16:58.715+00	2024-02-16 00:16:58.715+00	I5RzFRcQ7G	LDrIH1vU8x	0	4	1	1	3	\N	\N
WcIgNWhbrP	2024-02-16 00:16:59.207+00	2024-02-16 00:16:59.207+00	ONgyydfVNz	NBojpORh3G	2	0	1	3	2	\N	\N
G0G7WDBNEJ	2024-02-16 00:16:59.424+00	2024-02-16 00:16:59.424+00	WKpBp0c8F3	H40ivltLwZ	3	0	0	0	0	\N	\N
1z8Ld16lnD	2024-02-16 00:16:59.636+00	2024-02-16 00:16:59.636+00	RWwLSzreG2	Pja6n3yaWZ	4	4	4	0	0	\N	\N
S8eZWvDex8	2024-02-16 00:16:59.841+00	2024-02-16 00:16:59.841+00	sHiqaG4iqY	TCkiw6gTDz	4	3	2	1	4	\N	\N
WPI029OefF	2024-02-16 00:17:00.152+00	2024-02-16 00:17:00.152+00	NjxsGlPeB4	m8hjjLVdPS	2	4	3	2	1	\N	\N
qC6n0KTz3E	2024-02-16 00:17:00.361+00	2024-02-16 00:17:00.361+00	5X202ssb0D	XwszrNEEEj	4	2	0	4	3	\N	\N
4EimDgAiCs	2024-02-16 00:17:00.576+00	2024-02-16 00:17:00.576+00	AsrLUQwxI9	P9sBFomftT	0	1	4	0	0	\N	\N
rcTH6cqUuf	2024-02-16 00:17:00.867+00	2024-02-16 00:17:00.867+00	dZKm0wOhYa	FJOTueDfs2	4	2	4	1	1	\N	\N
EErTyCzZal	2024-02-16 00:17:01.079+00	2024-02-16 00:17:01.079+00	R2CLtFh5jU	14jGmOAXcg	3	1	0	4	0	\N	\N
hLtVbr98dz	2024-02-16 00:17:01.381+00	2024-02-16 00:17:01.381+00	ONgyydfVNz	jjVdtithcD	0	2	2	0	0	\N	\N
zu6dvx0ApW	2024-02-16 00:17:01.594+00	2024-02-16 00:17:01.594+00	S6wz0lK0bf	HXtEwLBC7f	3	3	2	2	4	\N	\N
5TNL7erq2C	2024-02-16 00:17:01.805+00	2024-02-16 00:17:01.805+00	mAKp5BK7R1	LDrIH1vU8x	4	4	2	2	0	\N	\N
auHnz3eyT1	2024-02-16 00:17:02.016+00	2024-02-16 00:17:02.016+00	1as6rMOzjQ	qZmnAnnPEb	2	2	3	2	4	\N	\N
gk7MrncXmH	2024-02-16 00:17:02.226+00	2024-02-16 00:17:02.226+00	VshUk7eBeK	AgU9OLJkqz	3	1	4	4	2	\N	\N
uMNANeepC2	2024-02-16 00:17:02.437+00	2024-02-16 00:17:02.437+00	HRhGpJpmb5	RkhjIQJgou	1	4	1	0	4	\N	\N
Ed7NGBBagC	2024-02-16 00:17:02.651+00	2024-02-16 00:17:02.651+00	WKpBp0c8F3	m8hjjLVdPS	1	4	0	2	0	\N	\N
PqfVi4AiHL	2024-02-16 00:17:02.862+00	2024-02-16 00:17:02.862+00	sHiqaG4iqY	bQpy9LEJWn	4	2	1	0	1	\N	\N
3qhpKDxL30	2024-02-16 00:17:03.073+00	2024-02-16 00:17:03.073+00	RWwLSzreG2	UDXF0qXvDY	1	4	4	1	3	\N	\N
80qhrxWB9l	2024-02-16 00:17:03.285+00	2024-02-16 00:17:03.285+00	S6wz0lK0bf	fxvABtKCPT	3	2	0	4	3	\N	\N
U5rcBHZ01V	2024-02-16 00:17:03.53+00	2024-02-16 00:17:03.53+00	dZKm0wOhYa	WHvlAGgj6c	4	2	2	1	1	\N	\N
HFex7Fvlqa	2024-02-16 00:17:04.14+00	2024-02-16 00:17:04.14+00	iWxl9obi8w	WBFeKac0OO	0	3	3	1	4	\N	\N
QIIuKUH6AR	2024-02-16 00:17:04.345+00	2024-02-16 00:17:04.345+00	adE9nQrDk3	3u4B9V4l5K	1	4	0	3	3	\N	\N
Mv6UX2q2lW	2024-02-16 00:17:04.557+00	2024-02-16 00:17:04.557+00	NjxsGlPeB4	j0dWqP2C2A	0	3	2	4	0	\N	\N
b5CV4vlogt	2024-02-16 00:17:04.765+00	2024-02-16 00:17:04.765+00	Otwj7uJwjr	cwVEh0dqfm	3	0	4	2	0	\N	\N
50jDYd1k1I	2024-02-16 00:17:04.971+00	2024-02-16 00:17:04.971+00	dEqAHvPMXA	RkhjIQJgou	1	2	2	0	3	\N	\N
X9AP5YsK6E	2024-02-16 00:17:05.18+00	2024-02-16 00:17:05.18+00	5X202ssb0D	VK3vnSxIy8	4	0	3	4	2	\N	\N
2J19ovu60z	2024-02-16 00:17:05.388+00	2024-02-16 00:17:05.388+00	VshUk7eBeK	Oahm9sOn1y	1	0	0	3	1	\N	\N
OU89CSyRfl	2024-02-16 00:17:05.6+00	2024-02-16 00:17:05.6+00	AsrLUQwxI9	INeptnSdJC	0	4	4	1	0	\N	\N
YyCkhaTKMZ	2024-02-16 00:17:05.815+00	2024-02-16 00:17:05.815+00	R2CLtFh5jU	AgU9OLJkqz	2	1	4	0	0	\N	\N
aYWUETegAD	2024-02-16 00:17:06.025+00	2024-02-16 00:17:06.025+00	WKpBp0c8F3	mMYg4cyd5R	4	2	2	4	4	\N	\N
Ro6USX97EI	2024-02-16 00:17:06.233+00	2024-02-16 00:17:06.233+00	iUlyHNFGpG	m6g8u0QpTC	4	2	3	3	0	\N	\N
QS3kC1HuAV	2024-02-16 00:17:06.446+00	2024-02-16 00:17:06.446+00	mQXQWNqxg9	j0dWqP2C2A	0	4	2	2	3	\N	\N
8WpnKKsmX8	2024-02-16 00:17:06.705+00	2024-02-16 00:17:06.705+00	sy1HD51LXT	INeptnSdJC	2	3	4	1	3	\N	\N
YurjHQnByk	2024-02-16 00:17:07.012+00	2024-02-16 00:17:07.012+00	R2CLtFh5jU	VK3vnSxIy8	1	1	4	2	1	\N	\N
tCl0QsDWFX	2024-02-16 00:17:07.221+00	2024-02-16 00:17:07.221+00	opW2wQ2bZ8	TZsdmscJ2B	0	2	3	2	2	\N	\N
vR3JeWdDRp	2024-02-16 00:17:07.43+00	2024-02-16 00:17:07.43+00	RWwLSzreG2	HLIPwAqO2R	2	1	3	2	1	\N	\N
OGnF6jIuR2	2024-02-16 00:17:07.641+00	2024-02-16 00:17:07.641+00	S6wz0lK0bf	lEPdiO1EDi	4	3	0	3	1	\N	\N
kiPlN13Psj	2024-02-16 00:17:07.851+00	2024-02-16 00:17:07.851+00	iUlyHNFGpG	IybX0eBoO3	2	1	0	1	2	\N	\N
Ap1alMcPxy	2024-02-16 00:17:08.064+00	2024-02-16 00:17:08.064+00	AsrLUQwxI9	JZOBDAh12a	3	3	1	0	0	\N	\N
zYzntkkhtS	2024-02-16 00:17:08.343+00	2024-02-16 00:17:08.343+00	5nv19u6KJ2	3P6kmNoY1F	2	3	4	1	3	\N	\N
6XnDXt4J4s	2024-02-16 00:17:08.651+00	2024-02-16 00:17:08.651+00	WKpBp0c8F3	bi1IivsuUB	2	2	2	2	2	\N	\N
yfBfCmtzj0	2024-02-16 00:17:08.864+00	2024-02-16 00:17:08.864+00	sy1HD51LXT	Oahm9sOn1y	3	2	0	2	0	\N	\N
tCtnpuJX0V	2024-02-16 00:17:09.074+00	2024-02-16 00:17:09.074+00	5X202ssb0D	EmIUBFwx0Z	0	0	2	0	2	\N	\N
7qw8HMSq42	2024-02-16 00:17:09.283+00	2024-02-16 00:17:09.283+00	RWwLSzreG2	P9sBFomftT	2	1	1	4	2	\N	\N
5gBdxumyJ7	2024-02-16 00:17:09.491+00	2024-02-16 00:17:09.491+00	9223vtvaBd	Pja6n3yaWZ	3	1	2	2	2	\N	\N
QnzLcwzPY8	2024-02-16 00:17:09.701+00	2024-02-16 00:17:09.701+00	ONgyydfVNz	axyV0Fu7pm	1	3	2	3	2	\N	\N
XbSLTME7KD	2024-02-16 00:17:09.914+00	2024-02-16 00:17:09.914+00	NjxsGlPeB4	TCkiw6gTDz	1	2	3	3	3	\N	\N
fhg8wHISeS	2024-02-16 00:17:10.493+00	2024-02-16 00:17:10.493+00	mQXQWNqxg9	qP3EdIVzfB	1	2	1	1	4	\N	\N
M1j9VrCNNG	2024-02-16 00:17:10.699+00	2024-02-16 00:17:10.699+00	HtEtaHBVDN	3u4B9V4l5K	3	4	1	4	4	\N	\N
ZzYEDMM4iJ	2024-02-16 00:17:11.007+00	2024-02-16 00:17:11.007+00	VshUk7eBeK	EmIUBFwx0Z	0	4	4	1	4	\N	\N
4fsHleXJEJ	2024-02-16 00:17:11.598+00	2024-02-16 00:17:11.598+00	VshUk7eBeK	UDXF0qXvDY	0	4	3	0	4	\N	\N
51BUytc07a	2024-02-16 00:17:12.233+00	2024-02-16 00:17:12.233+00	opW2wQ2bZ8	qEQ9tmLyW9	4	0	4	1	2	\N	\N
qNcWjV5sC3	2024-02-16 00:17:12.538+00	2024-02-16 00:17:12.538+00	opW2wQ2bZ8	VK3vnSxIy8	1	0	2	4	2	\N	\N
KfkBU1D738	2024-02-16 00:17:12.745+00	2024-02-16 00:17:12.745+00	iUlyHNFGpG	EmIUBFwx0Z	4	4	0	1	2	\N	\N
VJv646HG4E	2024-02-16 00:17:12.948+00	2024-02-16 00:17:12.948+00	9223vtvaBd	qZmnAnnPEb	0	4	1	0	2	\N	\N
IMZPqiUjjq	2024-02-16 00:17:13.154+00	2024-02-16 00:17:13.154+00	R2CLtFh5jU	HXtEwLBC7f	1	1	1	0	0	\N	\N
1GbAazY2EO	2024-02-16 00:17:13.601+00	2024-02-16 00:17:13.601+00	iWxl9obi8w	08liHW08uC	4	2	0	1	1	\N	\N
avxForhr2u	2024-02-16 00:17:13.809+00	2024-02-16 00:17:13.809+00	mQXQWNqxg9	yvUod6yLDt	2	2	4	1	0	\N	\N
VioQZSYxfe	2024-02-16 00:17:14.588+00	2024-02-16 00:17:14.588+00	5nv19u6KJ2	Gl96vGdYHM	3	1	1	3	4	\N	\N
5RY40I8G27	2024-02-16 00:17:14.896+00	2024-02-16 00:17:14.896+00	opW2wQ2bZ8	3u4B9V4l5K	1	4	2	3	1	\N	\N
tFKPVBMV7Q	2024-02-16 00:17:15.203+00	2024-02-16 00:17:15.203+00	dEqAHvPMXA	UDXF0qXvDY	0	4	3	4	2	\N	\N
S8N3SFHJh9	2024-02-16 00:17:15.409+00	2024-02-16 00:17:15.409+00	R2CLtFh5jU	89xRG1afNi	4	2	2	0	1	\N	\N
LIyEBv3LnD	2024-02-16 00:17:15.619+00	2024-02-16 00:17:15.619+00	WKpBp0c8F3	mMYg4cyd5R	3	1	1	4	4	\N	\N
XgGGdFCfbK	2024-02-16 00:17:15.921+00	2024-02-16 00:17:15.921+00	WKpBp0c8F3	qZmnAnnPEb	4	2	0	4	1	\N	\N
qmeEkEjhlI	2024-02-16 00:17:16.123+00	2024-02-16 00:17:16.123+00	sHiqaG4iqY	HSEugQ3Ouj	1	0	0	4	3	\N	\N
8nmYbEc1Gb	2024-02-16 00:17:16.329+00	2024-02-16 00:17:16.329+00	5X202ssb0D	na5crB8ED1	2	0	4	0	0	\N	\N
Ce3pERtyfU	2024-02-16 00:17:16.637+00	2024-02-16 00:17:16.637+00	5nv19u6KJ2	NY6RE1qgWu	4	1	4	1	1	\N	\N
VATbhZaGrx	2024-02-16 00:17:16.847+00	2024-02-16 00:17:16.847+00	R2CLtFh5jU	08liHW08uC	0	1	2	4	4	\N	\N
B6vi6xsNiW	2024-02-16 00:17:17.15+00	2024-02-16 00:17:17.15+00	AsrLUQwxI9	0TvWuLoLF5	4	2	2	0	0	\N	\N
qYtnk21IXI	2024-02-16 00:17:17.359+00	2024-02-16 00:17:17.359+00	iWxl9obi8w	o4VD4BWwDt	1	4	0	1	0	\N	\N
vSD70N6obB	2024-02-16 00:17:17.57+00	2024-02-16 00:17:17.57+00	S6wz0lK0bf	XSK814B37m	3	4	3	2	1	\N	\N
qiRdu7aeGR	2024-02-16 00:17:17.869+00	2024-02-16 00:17:17.869+00	Otwj7uJwjr	LDrIH1vU8x	0	4	2	2	1	\N	\N
avFkbeNYfG	2024-02-16 00:17:18.078+00	2024-02-16 00:17:18.078+00	mAKp5BK7R1	BMLzFMvIT6	4	1	4	0	1	\N	\N
BnZrI7dgf3	2024-02-16 00:17:18.285+00	2024-02-16 00:17:18.285+00	RWwLSzreG2	WHvlAGgj6c	0	4	4	0	1	\N	\N
HBwluOuYeV	2024-02-16 00:17:18.493+00	2024-02-16 00:17:18.493+00	NjxsGlPeB4	TCkiw6gTDz	1	1	1	0	0	\N	\N
iZ6nQhREhl	2024-02-16 00:17:18.702+00	2024-02-16 00:17:18.702+00	5X202ssb0D	WBFeKac0OO	2	0	1	0	3	\N	\N
VF3blxYujQ	2024-02-16 00:17:18.914+00	2024-02-16 00:17:18.914+00	VshUk7eBeK	bi1IivsuUB	2	1	3	2	4	\N	\N
QMkH7Xlivj	2024-02-16 00:17:19.125+00	2024-02-16 00:17:19.125+00	iUlyHNFGpG	bQ0JOk10eL	0	0	1	4	0	\N	\N
O0IpWwKYTt	2024-02-16 00:17:19.406+00	2024-02-16 00:17:19.406+00	jqDYoPT45X	OQWu2bnHeC	4	0	2	3	2	\N	\N
zr44yMa3mU	2024-02-16 00:17:19.616+00	2024-02-16 00:17:19.616+00	1as6rMOzjQ	6KvFK8yy1q	0	3	0	3	3	\N	\N
kBEitiDhxP	2024-02-16 00:17:19.826+00	2024-02-16 00:17:19.826+00	AsrLUQwxI9	qEQ9tmLyW9	0	3	3	3	3	\N	\N
W0uAt0gwgN	2024-02-16 00:17:20.121+00	2024-02-16 00:17:20.121+00	I5RzFRcQ7G	tCIEnLLcUc	4	1	0	0	3	\N	\N
Xcad04V0HM	2024-02-16 00:17:20.33+00	2024-02-16 00:17:20.33+00	mAKp5BK7R1	qP3EdIVzfB	1	4	2	0	3	\N	\N
1n97wqJ2C4	2024-02-16 00:17:20.537+00	2024-02-16 00:17:20.537+00	jqDYoPT45X	WnUBBkiDjE	3	1	0	3	0	\N	\N
ZhBNaIhHUY	2024-02-16 00:17:20.744+00	2024-02-16 00:17:20.744+00	adE9nQrDk3	3u4B9V4l5K	4	2	2	3	0	\N	\N
jgHTpG2Bn9	2024-02-16 00:17:20.956+00	2024-02-16 00:17:20.956+00	5nv19u6KJ2	BMLzFMvIT6	2	1	2	3	1	\N	\N
7ulS2cyAXp	2024-02-16 00:17:21.248+00	2024-02-16 00:17:21.248+00	R2CLtFh5jU	qP3EdIVzfB	2	2	4	4	2	\N	\N
rASHMNKrif	2024-02-16 00:17:21.555+00	2024-02-16 00:17:21.555+00	sHiqaG4iqY	08liHW08uC	1	3	2	1	1	\N	\N
8fVdC4WHHC	2024-02-16 00:17:21.862+00	2024-02-16 00:17:21.862+00	RWwLSzreG2	IybX0eBoO3	4	1	2	3	3	\N	\N
1sUjtKmD9M	2024-02-16 00:17:22.071+00	2024-02-16 00:17:22.071+00	sy1HD51LXT	H40ivltLwZ	0	2	2	2	2	\N	\N
xpCGz5VXnO	2024-02-16 00:17:22.28+00	2024-02-16 00:17:22.28+00	mAKp5BK7R1	IybX0eBoO3	1	0	3	0	3	\N	\N
NTKxM1b9zl	2024-02-16 00:17:22.491+00	2024-02-16 00:17:22.491+00	I5RzFRcQ7G	Oahm9sOn1y	1	2	4	1	1	\N	\N
XjRhJzGZkZ	2024-02-16 00:17:22.784+00	2024-02-16 00:17:22.784+00	dZKm0wOhYa	EmIUBFwx0Z	4	1	2	0	0	\N	\N
wE4kdYmbXd	2024-02-16 00:17:22.993+00	2024-02-16 00:17:22.993+00	VshUk7eBeK	XpUyRlB6FI	4	2	3	4	2	\N	\N
mATvtXXaYy	2024-02-16 00:17:23.202+00	2024-02-16 00:17:23.202+00	mQXQWNqxg9	bQ0JOk10eL	2	3	0	3	1	\N	\N
bGo3xBeVCz	2024-02-16 00:17:23.41+00	2024-02-16 00:17:23.41+00	1as6rMOzjQ	oABNR2FF6S	4	4	0	3	0	\N	\N
3CODH2w3zn	2024-02-16 00:17:23.621+00	2024-02-16 00:17:23.621+00	9223vtvaBd	tCIEnLLcUc	4	3	2	0	2	\N	\N
RDIvSGXx1H	2024-02-16 00:17:23.832+00	2024-02-16 00:17:23.832+00	SFAISec8QF	u5FXeeOChJ	1	3	0	3	0	\N	\N
TyHivgDXqr	2024-02-16 00:17:24.046+00	2024-02-16 00:17:24.046+00	1as6rMOzjQ	9GF3y7LmHV	0	1	4	0	0	\N	\N
B4L4lD2nJj	2024-02-16 00:17:24.257+00	2024-02-16 00:17:24.257+00	mAKp5BK7R1	uigc7bJBOJ	4	4	0	1	3	\N	\N
tajCc0gqbd	2024-02-16 00:17:24.468+00	2024-02-16 00:17:24.468+00	adE9nQrDk3	u5FXeeOChJ	3	1	1	4	0	\N	\N
qso4OKoiwx	2024-02-16 00:17:24.68+00	2024-02-16 00:17:24.68+00	5X202ssb0D	axyV0Fu7pm	2	2	3	2	3	\N	\N
worpAQGLzH	2024-02-16 00:17:24.898+00	2024-02-16 00:17:24.898+00	adE9nQrDk3	bQpy9LEJWn	1	0	2	3	0	\N	\N
xBu0XYBq5x	2024-02-16 00:17:25.11+00	2024-02-16 00:17:25.11+00	dZKm0wOhYa	INeptnSdJC	0	3	3	1	1	\N	\N
uZHnFLiYIB	2024-02-16 00:17:25.32+00	2024-02-16 00:17:25.32+00	dZKm0wOhYa	89xRG1afNi	3	4	4	3	0	\N	\N
60SqaSYWje	2024-02-16 00:17:25.536+00	2024-02-16 00:17:25.536+00	5X202ssb0D	e037qpAih3	2	1	1	3	3	\N	\N
LOaveHNFT4	2024-02-16 00:17:25.755+00	2024-02-16 00:17:25.755+00	jqDYoPT45X	JRi61dUphq	3	4	1	1	3	\N	\N
Op5dLNFC7r	2024-02-16 00:17:25.964+00	2024-02-16 00:17:25.964+00	S6wz0lK0bf	m8hjjLVdPS	4	0	4	4	3	\N	\N
CSWPFVLErF	2024-02-16 00:17:26.165+00	2024-02-16 00:17:26.165+00	iUlyHNFGpG	IEqTHcohpJ	3	4	4	1	3	\N	\N
qCytvEvYox	2024-02-16 00:17:26.371+00	2024-02-16 00:17:26.371+00	5nv19u6KJ2	m6g8u0QpTC	3	3	4	0	3	\N	\N
6ULGAuimyO	2024-02-16 00:17:26.583+00	2024-02-16 00:17:26.583+00	iWxl9obi8w	3u4B9V4l5K	0	3	4	3	3	\N	\N
wSQEfVv3fT	2024-02-16 00:17:26.795+00	2024-02-16 00:17:26.795+00	opW2wQ2bZ8	WHvlAGgj6c	2	1	3	4	1	\N	\N
x5gQCdwkWY	2024-02-16 00:17:27.394+00	2024-02-16 00:17:27.394+00	dEqAHvPMXA	PF8w2gMAdi	1	0	2	4	1	\N	\N
ql1VsU4MqA	2024-02-16 00:17:27.602+00	2024-02-16 00:17:27.602+00	iUlyHNFGpG	MQfxuw3ERg	1	4	3	1	0	\N	\N
HJeSpnFtNk	2024-02-16 00:17:27.808+00	2024-02-16 00:17:27.808+00	1as6rMOzjQ	WBFeKac0OO	1	1	4	3	4	\N	\N
354b97i508	2024-02-16 00:17:28.016+00	2024-02-16 00:17:28.016+00	dEqAHvPMXA	cwVEh0dqfm	3	1	4	3	2	\N	\N
Y01h4arhOn	2024-02-16 00:17:28.314+00	2024-02-16 00:17:28.314+00	opW2wQ2bZ8	cwVEh0dqfm	0	2	0	0	4	\N	\N
iRweNpsdKC	2024-02-16 00:17:28.526+00	2024-02-16 00:17:28.526+00	dZKm0wOhYa	uigc7bJBOJ	0	3	0	1	4	\N	\N
OSH9O899UJ	2024-02-16 00:17:28.738+00	2024-02-16 00:17:28.738+00	I5RzFRcQ7G	Pja6n3yaWZ	0	0	1	4	0	\N	\N
I6c3Ffaibk	2024-02-16 00:17:28.95+00	2024-02-16 00:17:28.95+00	9223vtvaBd	mMYg4cyd5R	0	0	3	3	3	\N	\N
dDQrcRcc6T	2024-02-16 00:17:29.236+00	2024-02-16 00:17:29.236+00	dEqAHvPMXA	IEqTHcohpJ	0	4	0	3	2	\N	\N
pIyCmUFyOW	2024-02-16 00:17:29.45+00	2024-02-16 00:17:29.45+00	9223vtvaBd	bQpy9LEJWn	3	1	3	1	3	\N	\N
m10SfN6jZ4	2024-02-16 00:17:29.664+00	2024-02-16 00:17:29.664+00	5nv19u6KJ2	KCsJ4XR6Dn	3	0	1	3	0	\N	\N
EDoWC0jowC	2024-02-16 00:17:29.875+00	2024-02-16 00:17:29.875+00	1as6rMOzjQ	jHqCpA1nWb	1	4	2	1	1	\N	\N
S6HAs2WeFv	2024-02-16 00:17:30.085+00	2024-02-16 00:17:30.085+00	5nv19u6KJ2	bi1IivsuUB	4	4	1	2	3	\N	\N
zXZW2bWqZE	2024-02-16 00:17:30.295+00	2024-02-16 00:17:30.295+00	sHiqaG4iqY	u5FXeeOChJ	4	1	2	3	3	\N	\N
K27sq8yQDW	2024-02-16 00:17:30.505+00	2024-02-16 00:17:30.505+00	sHiqaG4iqY	Gl96vGdYHM	3	1	4	1	4	\N	\N
OknpZxHkOP	2024-02-16 00:17:30.715+00	2024-02-16 00:17:30.715+00	NjxsGlPeB4	ThMuD3hYRQ	2	1	4	3	3	\N	\N
NvDGfybqMt	2024-02-16 00:17:31.387+00	2024-02-16 00:17:31.387+00	dEqAHvPMXA	WBFeKac0OO	2	2	4	1	4	\N	\N
SHADC3QS3q	2024-02-16 00:17:31.594+00	2024-02-16 00:17:31.594+00	R2CLtFh5jU	LDrIH1vU8x	4	1	3	2	1	\N	\N
h8Ew0zxBsC	2024-02-16 00:17:31.897+00	2024-02-16 00:17:31.897+00	5X202ssb0D	fwLPZZ8YQa	2	4	2	0	1	\N	\N
d5qtLQecdQ	2024-02-16 00:17:32.104+00	2024-02-16 00:17:32.104+00	VshUk7eBeK	3u4B9V4l5K	4	2	1	0	0	\N	\N
Qqt4BchHwD	2024-02-16 00:17:32.307+00	2024-02-16 00:17:32.307+00	SFAISec8QF	Pa0qBO2rzK	4	3	2	2	0	\N	\N
YFpMxRs7Jr	2024-02-16 00:17:32.516+00	2024-02-16 00:17:32.516+00	sHiqaG4iqY	cTIjuPjyIa	3	0	4	2	4	\N	\N
f0xdgJyDMj	2024-02-16 00:17:32.725+00	2024-02-16 00:17:32.725+00	NjxsGlPeB4	j0dWqP2C2A	0	1	2	3	2	\N	\N
1v3yEIs5AG	2024-02-16 00:17:32.934+00	2024-02-16 00:17:32.934+00	mAKp5BK7R1	uigc7bJBOJ	4	0	4	1	2	\N	\N
fvfxVuufF1	2024-02-16 00:17:33.229+00	2024-02-16 00:17:33.229+00	1as6rMOzjQ	G0uU7KQLEt	1	4	2	2	4	\N	\N
YS3YHWDPtP	2024-02-16 00:17:33.44+00	2024-02-16 00:17:33.44+00	HtEtaHBVDN	BMLzFMvIT6	0	2	4	1	0	\N	\N
o9hUBec5Zd	2024-02-16 00:17:33.649+00	2024-02-16 00:17:33.649+00	sy1HD51LXT	IEqTHcohpJ	3	2	3	2	2	\N	\N
FWpufscHtv	2024-02-16 00:17:33.856+00	2024-02-16 00:17:33.856+00	1as6rMOzjQ	o90lhsZ7FK	1	2	2	0	3	\N	\N
57us7xpq3g	2024-02-16 00:17:34.152+00	2024-02-16 00:17:34.152+00	ONgyydfVNz	lEPdiO1EDi	2	4	4	3	1	\N	\N
n50pMGHwaQ	2024-02-16 00:17:34.364+00	2024-02-16 00:17:34.364+00	S6wz0lK0bf	WnUBBkiDjE	4	0	1	2	1	\N	\N
d76dcbnlds	2024-02-16 00:17:34.573+00	2024-02-16 00:17:34.573+00	opW2wQ2bZ8	Oahm9sOn1y	4	2	3	3	4	\N	\N
VNoyNpaRZQ	2024-02-16 00:17:34.781+00	2024-02-16 00:17:34.781+00	adE9nQrDk3	NY6RE1qgWu	2	4	1	2	2	\N	\N
ObhT2n0MLS	2024-02-16 00:17:34.991+00	2024-02-16 00:17:34.991+00	RWwLSzreG2	FYXEfIO1zF	0	0	3	2	0	\N	\N
o2u4VrbTMg	2024-02-16 00:17:35.201+00	2024-02-16 00:17:35.201+00	WKpBp0c8F3	JZOBDAh12a	1	2	1	1	3	\N	\N
xiy5rmdgb9	2024-02-16 00:17:35.483+00	2024-02-16 00:17:35.483+00	Otwj7uJwjr	vwHi602n66	3	0	2	3	3	\N	\N
UBh9kto06i	2024-02-16 00:17:35.693+00	2024-02-16 00:17:35.693+00	RWwLSzreG2	y4RkaDbkec	2	2	1	1	0	\N	\N
zgxhnoXMg7	2024-02-16 00:17:35.903+00	2024-02-16 00:17:35.903+00	Otwj7uJwjr	axyV0Fu7pm	2	2	1	1	0	\N	\N
uOHivSyZ8F	2024-02-16 00:17:36.107+00	2024-02-16 00:17:36.107+00	mQXQWNqxg9	89xRG1afNi	3	3	4	4	2	\N	\N
NAVOHi988i	2024-02-16 00:17:36.316+00	2024-02-16 00:17:36.316+00	sy1HD51LXT	lEPdiO1EDi	2	1	0	0	1	\N	\N
oqNHqaKiQk	2024-02-16 00:17:36.526+00	2024-02-16 00:17:36.526+00	I5RzFRcQ7G	HLIPwAqO2R	0	0	1	2	0	\N	\N
b89pu5kURR	2024-02-16 00:17:36.739+00	2024-02-16 00:17:36.739+00	HtEtaHBVDN	rT0UCBK1bE	2	3	2	3	2	\N	\N
6f6nxi2ILG	2024-02-16 00:17:36.95+00	2024-02-16 00:17:36.95+00	jqDYoPT45X	ThMuD3hYRQ	1	1	1	3	1	\N	\N
WqF5OMP5A7	2024-02-16 00:17:37.164+00	2024-02-16 00:17:37.164+00	mAKp5BK7R1	cTIjuPjyIa	3	4	4	2	4	\N	\N
CpiO5N2t7v	2024-02-16 00:17:37.429+00	2024-02-16 00:17:37.429+00	WKpBp0c8F3	TpGyMZM9BG	4	3	3	2	0	\N	\N
xKFc83MKBH	2024-02-16 00:17:37.736+00	2024-02-16 00:17:37.736+00	5nv19u6KJ2	TCkiw6gTDz	1	3	2	3	1	\N	\N
tb9NdXdWrC	2024-02-16 00:17:37.95+00	2024-02-16 00:17:37.95+00	AsrLUQwxI9	JZOBDAh12a	0	2	1	2	4	\N	\N
VtIkuYGBau	2024-02-16 00:17:38.164+00	2024-02-16 00:17:38.164+00	sy1HD51LXT	9GF3y7LmHV	1	0	2	3	1	\N	\N
KuLUSHRJRq	2024-02-16 00:17:38.453+00	2024-02-16 00:17:38.453+00	ONgyydfVNz	bQpy9LEJWn	4	0	1	2	0	\N	\N
bMs0ijyVDf	2024-02-16 00:17:38.762+00	2024-02-16 00:17:38.762+00	opW2wQ2bZ8	KCsJ4XR6Dn	2	4	4	1	2	\N	\N
nhQUgJrfEi	2024-02-16 00:17:38.97+00	2024-02-16 00:17:38.97+00	iWxl9obi8w	oABNR2FF6S	2	3	2	1	4	\N	\N
YIRsjBhZug	2024-02-16 00:17:39.18+00	2024-02-16 00:17:39.18+00	HtEtaHBVDN	6KvFK8yy1q	1	4	0	2	4	\N	\N
okJe7zBTDK	2024-02-16 00:17:39.39+00	2024-02-16 00:17:39.39+00	VshUk7eBeK	BMLzFMvIT6	0	4	4	2	3	\N	\N
WWzxKn4a8f	2024-02-16 00:17:39.601+00	2024-02-16 00:17:39.601+00	9223vtvaBd	bQpy9LEJWn	0	0	3	0	1	\N	\N
iWU7mUPOw3	2024-02-16 00:17:39.815+00	2024-02-16 00:17:39.815+00	I5RzFRcQ7G	G0uU7KQLEt	0	4	0	4	3	\N	\N
GgPu4yV4YT	2024-02-16 00:17:40.4+00	2024-02-16 00:17:40.4+00	sy1HD51LXT	6KvFK8yy1q	1	1	3	4	3	\N	\N
22ZyRkENgv	2024-02-16 00:17:40.609+00	2024-02-16 00:17:40.609+00	HtEtaHBVDN	Pja6n3yaWZ	1	1	2	4	4	\N	\N
erBK6w7zVg	2024-02-16 00:17:40.818+00	2024-02-16 00:17:40.818+00	HRhGpJpmb5	IEqTHcohpJ	4	1	0	1	4	\N	\N
MdikL3krFW	2024-02-16 00:17:41.112+00	2024-02-16 00:17:41.112+00	jqDYoPT45X	Pja6n3yaWZ	4	0	3	1	4	\N	\N
kcAGhs07iI	2024-02-16 00:17:41.322+00	2024-02-16 00:17:41.322+00	S6wz0lK0bf	bi1IivsuUB	0	0	4	4	2	\N	\N
byvaXuZgR2	2024-02-16 00:17:41.629+00	2024-02-16 00:17:41.629+00	sHiqaG4iqY	TZsdmscJ2B	2	4	2	3	2	\N	\N
EqONwfiumL	2024-02-16 00:17:41.843+00	2024-02-16 00:17:41.843+00	Otwj7uJwjr	XSK814B37m	0	3	1	4	2	\N	\N
vKBfsRQsEt	2024-02-16 00:17:42.055+00	2024-02-16 00:17:42.055+00	5nv19u6KJ2	G0uU7KQLEt	1	1	3	4	3	\N	\N
0bvEVxKQOF	2024-02-16 00:17:42.264+00	2024-02-16 00:17:42.264+00	HRhGpJpmb5	HLIPwAqO2R	2	3	0	4	3	\N	\N
pcyl4nBabT	2024-02-16 00:17:42.551+00	2024-02-16 00:17:42.551+00	AsrLUQwxI9	8w7i8C3NnT	1	1	4	2	3	\N	\N
tFGQYTjtOE	2024-02-16 00:17:42.761+00	2024-02-16 00:17:42.761+00	1as6rMOzjQ	RBRcyltRSC	4	4	1	3	2	\N	\N
xfu0w6JO3O	2024-02-16 00:17:42.969+00	2024-02-16 00:17:42.969+00	adE9nQrDk3	MQfxuw3ERg	4	0	2	3	3	\N	\N
0x3ETTN7ju	2024-02-16 00:17:43.179+00	2024-02-16 00:17:43.179+00	S6wz0lK0bf	3u4B9V4l5K	3	1	3	4	1	\N	\N
MfD66wP4hH	2024-02-16 00:17:43.389+00	2024-02-16 00:17:43.389+00	sHiqaG4iqY	LgJuu5ABe5	3	1	1	3	2	\N	\N
LMqGDrmcgN	2024-02-16 00:17:43.6+00	2024-02-16 00:17:43.6+00	S6wz0lK0bf	rKyjwoEIRp	0	0	2	0	0	\N	\N
pLB6HHlwwA	2024-02-16 00:17:43.811+00	2024-02-16 00:17:43.811+00	WKpBp0c8F3	uABtFsJhJc	3	3	0	2	3	\N	\N
cmQHex08qt	2024-02-16 00:17:44.086+00	2024-02-16 00:17:44.086+00	R2CLtFh5jU	Oahm9sOn1y	1	4	3	1	0	\N	\N
PwVh57bcyC	2024-02-16 00:17:44.298+00	2024-02-16 00:17:44.298+00	S6wz0lK0bf	UDXF0qXvDY	3	2	2	0	2	\N	\N
CBJKF12Dy9	2024-02-16 00:17:44.509+00	2024-02-16 00:17:44.509+00	S6wz0lK0bf	CSvk1ycWXk	1	1	3	4	4	\N	\N
xH0Q9nntim	2024-02-16 00:17:44.803+00	2024-02-16 00:17:44.803+00	SFAISec8QF	IEqTHcohpJ	1	2	0	4	1	\N	\N
eQ2TsBEOo6	2024-02-16 00:17:45.012+00	2024-02-16 00:17:45.012+00	SFAISec8QF	tCIEnLLcUc	0	2	3	1	4	\N	\N
uqIeZkLrFR	2024-02-16 00:17:45.315+00	2024-02-16 00:17:45.315+00	sHiqaG4iqY	eEmewy7hPd	4	2	2	2	4	\N	\N
DZcH1nS0Cg	2024-02-16 00:17:45.523+00	2024-02-16 00:17:45.523+00	opW2wQ2bZ8	eEmewy7hPd	4	1	2	1	0	\N	\N
U8egnTzh6V	2024-02-16 00:17:45.828+00	2024-02-16 00:17:45.828+00	sy1HD51LXT	u5FXeeOChJ	4	2	1	2	4	\N	\N
ftjwNNGdAf	2024-02-16 00:17:46.038+00	2024-02-16 00:17:46.038+00	5X202ssb0D	bi1IivsuUB	3	1	4	2	2	\N	\N
z0C3qW1Wsz	2024-02-16 00:17:46.248+00	2024-02-16 00:17:46.248+00	mQXQWNqxg9	m6g8u0QpTC	2	3	3	0	1	\N	\N
d6fWu2D2Qv	2024-02-16 00:17:46.458+00	2024-02-16 00:17:46.458+00	5X202ssb0D	JZOBDAh12a	4	3	0	0	0	\N	\N
S270PPucKh	2024-02-16 00:17:46.67+00	2024-02-16 00:17:46.67+00	adE9nQrDk3	WHvlAGgj6c	3	4	0	0	4	\N	\N
EkUTX2iWSO	2024-02-16 00:17:46.88+00	2024-02-16 00:17:46.88+00	jqDYoPT45X	VK3vnSxIy8	3	4	2	1	0	\N	\N
kF0CkN8WDv	2024-02-16 00:17:47.092+00	2024-02-16 00:17:47.092+00	mQXQWNqxg9	D0A6GLdsDM	3	0	1	4	2	\N	\N
as99RTuoEt	2024-02-16 00:17:47.364+00	2024-02-16 00:17:47.364+00	R2CLtFh5jU	IybX0eBoO3	0	4	1	4	3	\N	\N
K1zobeRCqW	2024-02-16 00:17:47.672+00	2024-02-16 00:17:47.672+00	sHiqaG4iqY	HLIPwAqO2R	3	2	0	2	3	\N	\N
GNNJMLRFmN	2024-02-16 00:17:47.978+00	2024-02-16 00:17:47.978+00	S6wz0lK0bf	XpUyRlB6FI	1	4	4	1	0	\N	\N
Jqe6aoj6uI	2024-02-16 00:17:48.196+00	2024-02-16 00:17:48.196+00	HRhGpJpmb5	XwWwGnkXNj	0	1	3	1	0	\N	\N
1AeqZ4P9mp	2024-02-16 00:17:48.405+00	2024-02-16 00:17:48.405+00	sy1HD51LXT	VK3vnSxIy8	2	3	1	2	3	\N	\N
N91ownzdB9	2024-02-16 00:17:48.614+00	2024-02-16 00:17:48.614+00	NjxsGlPeB4	NY6RE1qgWu	2	0	4	4	1	\N	\N
OyKzEqeUO8	2024-02-16 00:17:48.815+00	2024-02-16 00:17:48.815+00	dZKm0wOhYa	XpUyRlB6FI	0	1	3	4	0	\N	\N
t5Yq4EuOVC	2024-02-16 00:17:49.021+00	2024-02-16 00:17:49.021+00	VshUk7eBeK	E2hBZzDsjO	3	4	3	0	3	\N	\N
trylWKElzz	2024-02-16 00:17:49.233+00	2024-02-16 00:17:49.233+00	5nv19u6KJ2	oABNR2FF6S	3	3	2	4	0	\N	\N
BqgpiPSUMG	2024-02-16 00:17:49.444+00	2024-02-16 00:17:49.444+00	sy1HD51LXT	axyV0Fu7pm	0	4	0	4	1	\N	\N
KDW3Ammc8l	2024-02-16 00:17:49.653+00	2024-02-16 00:17:49.653+00	mQXQWNqxg9	H40ivltLwZ	3	4	4	1	4	\N	\N
l9caJEGYeC	2024-02-16 00:17:49.866+00	2024-02-16 00:17:49.866+00	opW2wQ2bZ8	JZOBDAh12a	3	1	0	3	4	\N	\N
E11W6Mn8fg	2024-02-16 00:17:50.13+00	2024-02-16 00:17:50.13+00	RWwLSzreG2	qP3EdIVzfB	0	4	4	2	3	\N	\N
rXdazRJRNo	2024-02-16 00:17:50.34+00	2024-02-16 00:17:50.34+00	5X202ssb0D	XwWwGnkXNj	3	1	4	3	4	\N	\N
gs9ifEJDOh	2024-02-16 00:17:50.554+00	2024-02-16 00:17:50.554+00	5nv19u6KJ2	JZOBDAh12a	0	2	4	0	3	\N	\N
qmGxanRHcO	2024-02-16 00:17:50.766+00	2024-02-16 00:17:50.766+00	VshUk7eBeK	TZsdmscJ2B	0	3	0	3	3	\N	\N
HfzHfXPqGs	2024-02-16 00:17:50.979+00	2024-02-16 00:17:50.979+00	5X202ssb0D	bQpy9LEJWn	4	2	2	1	4	\N	\N
W1mIocAms7	2024-02-16 00:17:51.181+00	2024-02-16 00:17:51.181+00	I5RzFRcQ7G	XwWwGnkXNj	0	0	1	2	4	\N	\N
X4C73MXtCB	2024-02-16 00:17:51.388+00	2024-02-16 00:17:51.388+00	mAKp5BK7R1	EmIUBFwx0Z	2	2	0	2	4	\N	\N
Ddh7xeJwT8	2024-02-16 00:17:51.601+00	2024-02-16 00:17:51.601+00	Otwj7uJwjr	uigc7bJBOJ	3	2	2	4	0	\N	\N
tRepiFIO3C	2024-02-16 00:17:51.813+00	2024-02-16 00:17:51.813+00	NjxsGlPeB4	jHqCpA1nWb	0	1	0	3	1	\N	\N
vYJh7pppZ1	2024-02-16 00:17:52.027+00	2024-02-16 00:17:52.027+00	opW2wQ2bZ8	INeptnSdJC	1	3	4	1	4	\N	\N
apYRGTNuyW	2024-02-16 00:17:52.242+00	2024-02-16 00:17:52.242+00	ONgyydfVNz	8w7i8C3NnT	4	4	3	3	2	\N	\N
RR3EKiZbCp	2024-02-16 00:17:52.485+00	2024-02-16 00:17:52.485+00	HRhGpJpmb5	INeptnSdJC	4	1	0	2	2	\N	\N
rGUeduSQWr	2024-02-16 00:17:52.699+00	2024-02-16 00:17:52.699+00	iUlyHNFGpG	OQWu2bnHeC	2	4	2	2	0	\N	\N
LDnUffJWCy	2024-02-16 00:17:52.996+00	2024-02-16 00:17:52.996+00	NjxsGlPeB4	14jGmOAXcg	4	2	0	0	1	\N	\N
305nUHyXOI	2024-02-16 00:17:53.208+00	2024-02-16 00:17:53.208+00	iWxl9obi8w	rT0UCBK1bE	4	3	2	4	3	\N	\N
0PJGfEL83w	2024-02-16 00:17:53.416+00	2024-02-16 00:17:53.416+00	sHiqaG4iqY	XSK814B37m	4	2	2	0	3	\N	\N
k4MWn8zHYt	2024-02-16 00:17:53.625+00	2024-02-16 00:17:53.625+00	adE9nQrDk3	fKTSJPdUi9	4	3	0	0	3	\N	\N
8DjCRedtLq	2024-02-16 00:17:53.839+00	2024-02-16 00:17:53.839+00	ONgyydfVNz	HXtEwLBC7f	1	3	3	1	1	\N	\N
f6IOo2P1ae	2024-02-16 00:17:54.123+00	2024-02-16 00:17:54.123+00	sy1HD51LXT	AgU9OLJkqz	1	1	2	3	2	\N	\N
kiD5dOt2AE	2024-02-16 00:17:54.735+00	2024-02-16 00:17:54.735+00	mQXQWNqxg9	FJOTueDfs2	1	1	2	1	3	\N	\N
LfuyJe6HM6	2024-02-16 00:17:55.041+00	2024-02-16 00:17:55.041+00	S6wz0lK0bf	e037qpAih3	2	0	0	1	4	\N	\N
3Ql3e55l2h	2024-02-16 00:17:55.246+00	2024-02-16 00:17:55.246+00	Otwj7uJwjr	cmxBcanww9	4	0	0	0	4	\N	\N
GPNPyNiYDw	2024-02-16 00:17:55.449+00	2024-02-16 00:17:55.449+00	HRhGpJpmb5	UCFo58JaaD	2	0	3	0	0	\N	\N
1nmKKzMq9m	2024-02-16 00:17:55.655+00	2024-02-16 00:17:55.655+00	jqDYoPT45X	LDrIH1vU8x	3	2	4	0	0	\N	\N
IMHfmfvowe	2024-02-16 00:17:55.861+00	2024-02-16 00:17:55.861+00	5nv19u6KJ2	XwWwGnkXNj	3	4	1	1	4	\N	\N
2Eez3gG1aL	2024-02-16 00:17:56.068+00	2024-02-16 00:17:56.068+00	sy1HD51LXT	JRi61dUphq	3	0	2	2	3	\N	\N
c4bVU5OrC6	2024-02-16 00:17:56.371+00	2024-02-16 00:17:56.371+00	AsrLUQwxI9	qP3EdIVzfB	1	4	0	1	2	\N	\N
hZWEmjQZLD	2024-02-16 00:17:56.579+00	2024-02-16 00:17:56.579+00	iUlyHNFGpG	cFtamPA0zH	3	3	4	3	0	\N	\N
sufMjzeZm8	2024-02-16 00:17:56.788+00	2024-02-16 00:17:56.788+00	9223vtvaBd	e037qpAih3	2	1	3	0	3	\N	\N
4Z1t7WtaFd	2024-02-16 00:17:57.092+00	2024-02-16 00:17:57.092+00	5nv19u6KJ2	WSTLlXDcKl	4	3	0	3	0	\N	\N
nqfwQrj4WY	2024-02-16 00:17:57.305+00	2024-02-16 00:17:57.305+00	HtEtaHBVDN	VK3vnSxIy8	0	4	4	4	3	\N	\N
EBoNvBz22N	2024-02-16 00:17:57.518+00	2024-02-16 00:17:57.518+00	VshUk7eBeK	AgU9OLJkqz	4	4	0	4	1	\N	\N
ZcVhtmcfPG	2024-02-16 00:17:57.809+00	2024-02-16 00:17:57.809+00	1as6rMOzjQ	EmIUBFwx0Z	3	1	1	3	4	\N	\N
mEuEFVlOnE	2024-02-16 00:17:58.117+00	2024-02-16 00:17:58.117+00	sy1HD51LXT	cTIjuPjyIa	4	4	2	1	1	\N	\N
Ly7lhurETc	2024-02-16 00:17:58.424+00	2024-02-16 00:17:58.424+00	WKpBp0c8F3	WBFeKac0OO	1	3	2	1	0	\N	\N
Cb73mKyIZy	2024-02-16 00:17:58.731+00	2024-02-16 00:17:58.731+00	mQXQWNqxg9	m8hjjLVdPS	1	2	4	3	1	\N	\N
PFlXKDsBTO	2024-02-16 00:17:58.94+00	2024-02-16 00:17:58.94+00	opW2wQ2bZ8	o90lhsZ7FK	1	3	2	2	3	\N	\N
7Wnlh1ZGUc	2024-02-16 00:17:59.153+00	2024-02-16 00:17:59.153+00	5X202ssb0D	Pja6n3yaWZ	4	1	1	1	3	\N	\N
12MerLZVoy	2024-02-16 00:17:59.753+00	2024-02-16 00:17:59.753+00	Otwj7uJwjr	6Fo67rhTSP	3	3	2	3	3	\N	\N
pyGwmLjmhK	2024-02-16 00:17:59.959+00	2024-02-16 00:17:59.959+00	I5RzFRcQ7G	axyV0Fu7pm	2	4	3	4	0	\N	\N
SIsH1LLTt1	2024-02-16 00:18:00.16+00	2024-02-16 00:18:00.16+00	dEqAHvPMXA	cwVEh0dqfm	3	4	3	4	0	\N	\N
F7ptlzsv4L	2024-02-16 00:18:00.367+00	2024-02-16 00:18:00.367+00	adE9nQrDk3	C7II8dYRPY	4	2	4	3	0	\N	\N
3Om7mWn4JR	2024-02-16 00:18:00.579+00	2024-02-16 00:18:00.579+00	R2CLtFh5jU	yvUod6yLDt	4	4	0	2	3	\N	\N
P09xQ3xdMa	2024-02-16 00:18:00.789+00	2024-02-16 00:18:00.789+00	sHiqaG4iqY	bQ0JOk10eL	1	2	2	4	2	\N	\N
EvtnHD3B1v	2024-02-16 00:18:01.001+00	2024-02-16 00:18:01.001+00	SFAISec8QF	LgJuu5ABe5	4	1	4	0	3	\N	\N
x9TduvCuo7	2024-02-16 00:18:01.597+00	2024-02-16 00:18:01.597+00	adE9nQrDk3	MQfxuw3ERg	0	1	4	1	0	\N	\N
kQBfbUFAFK	2024-02-16 00:18:01.806+00	2024-02-16 00:18:01.806+00	Otwj7uJwjr	EmIUBFwx0Z	4	4	4	3	1	\N	\N
9YmRqGFDHf	2024-02-16 00:18:02.012+00	2024-02-16 00:18:02.012+00	RWwLSzreG2	lEPdiO1EDi	2	4	4	2	1	\N	\N
qbmQ29uULH	2024-02-16 00:18:02.221+00	2024-02-16 00:18:02.221+00	WKpBp0c8F3	IEqTHcohpJ	2	3	0	1	2	\N	\N
FblfisIeiQ	2024-02-16 00:18:02.431+00	2024-02-16 00:18:02.431+00	1as6rMOzjQ	MQfxuw3ERg	3	0	3	1	2	\N	\N
66qc2C9RGC	2024-02-16 00:18:02.639+00	2024-02-16 00:18:02.639+00	5X202ssb0D	Gl96vGdYHM	2	2	2	3	4	\N	\N
aCX1HDGy3B	2024-02-16 00:18:02.849+00	2024-02-16 00:18:02.849+00	jqDYoPT45X	3P6kmNoY1F	1	2	2	2	0	\N	\N
2wNF6MG6vE	2024-02-16 00:18:03.135+00	2024-02-16 00:18:03.135+00	iUlyHNFGpG	MQfxuw3ERg	0	1	3	2	0	\N	\N
1J3YEJaAic	2024-02-16 00:18:03.442+00	2024-02-16 00:18:03.442+00	sy1HD51LXT	uigc7bJBOJ	1	3	4	1	3	\N	\N
NMc7xN8flk	2024-02-16 00:18:03.652+00	2024-02-16 00:18:03.652+00	VshUk7eBeK	WHvlAGgj6c	4	0	3	4	3	\N	\N
nT3zbUlB5L	2024-02-16 00:18:03.864+00	2024-02-16 00:18:03.864+00	adE9nQrDk3	u5FXeeOChJ	1	3	1	2	0	\N	\N
HTP4y8ObjK	2024-02-16 00:18:04.159+00	2024-02-16 00:18:04.159+00	HtEtaHBVDN	XpUyRlB6FI	1	4	2	3	0	\N	\N
fmOe0HjitU	2024-02-16 00:18:04.374+00	2024-02-16 00:18:04.374+00	sy1HD51LXT	3u4B9V4l5K	2	0	1	4	3	\N	\N
n4RCvVh6c3	2024-02-16 00:18:04.587+00	2024-02-16 00:18:04.587+00	Otwj7uJwjr	PF8w2gMAdi	0	3	2	0	4	\N	\N
RvHUi8VDdJ	2024-02-16 00:18:04.805+00	2024-02-16 00:18:04.805+00	HtEtaHBVDN	JLhF4VuByh	3	3	4	4	3	\N	\N
59B2K3HW9l	2024-02-16 00:18:05.021+00	2024-02-16 00:18:05.021+00	HtEtaHBVDN	08liHW08uC	4	2	1	0	0	\N	\N
cfd5yHHQPS	2024-02-16 00:18:05.23+00	2024-02-16 00:18:05.23+00	VshUk7eBeK	Oahm9sOn1y	1	2	3	2	2	\N	\N
OFYUfIBjAJ	2024-02-16 00:18:05.44+00	2024-02-16 00:18:05.44+00	iWxl9obi8w	fxvABtKCPT	4	4	0	1	1	\N	\N
2SKt5AJLsK	2024-02-16 00:18:05.647+00	2024-02-16 00:18:05.647+00	I5RzFRcQ7G	XSK814B37m	2	3	3	1	4	\N	\N
3MeheMdtvz	2024-02-16 00:18:05.862+00	2024-02-16 00:18:05.862+00	dZKm0wOhYa	o4VD4BWwDt	2	3	0	3	3	\N	\N
vo0n0cT0Dp	2024-02-16 00:18:06.078+00	2024-02-16 00:18:06.078+00	opW2wQ2bZ8	m8hjjLVdPS	4	2	1	2	1	\N	\N
27bVRF3l5C	2024-02-16 00:18:06.291+00	2024-02-16 00:18:06.291+00	R2CLtFh5jU	rKyjwoEIRp	1	1	2	3	1	\N	\N
dM3BBrmepc	2024-02-16 00:18:06.502+00	2024-02-16 00:18:06.502+00	R2CLtFh5jU	IybX0eBoO3	3	0	0	0	1	\N	\N
IjmXA89Hup	2024-02-16 00:18:06.713+00	2024-02-16 00:18:06.713+00	mAKp5BK7R1	m6g8u0QpTC	3	3	1	3	3	\N	\N
IrkLCEE4Q2	2024-02-16 00:18:06.924+00	2024-02-16 00:18:06.924+00	adE9nQrDk3	JLhF4VuByh	4	1	0	4	3	\N	\N
QDYc6YsWwo	2024-02-16 00:18:07.137+00	2024-02-16 00:18:07.137+00	RWwLSzreG2	rT0UCBK1bE	1	1	4	0	0	\N	\N
iumLJFVm4O	2024-02-16 00:18:07.347+00	2024-02-16 00:18:07.347+00	dEqAHvPMXA	m8hjjLVdPS	2	2	1	2	0	\N	\N
nJ9GUHriCP	2024-02-16 00:18:07.641+00	2024-02-16 00:18:07.641+00	WKpBp0c8F3	fKTSJPdUi9	1	2	0	2	4	\N	\N
Wfcea8uBHa	2024-02-16 00:18:07.948+00	2024-02-16 00:18:07.948+00	iWxl9obi8w	lEPdiO1EDi	1	4	3	0	4	\N	\N
8Ez1qVrwQ2	2024-02-16 00:18:08.255+00	2024-02-16 00:18:08.255+00	ONgyydfVNz	cwVEh0dqfm	2	1	2	4	2	\N	\N
53ccATcqdp	2024-02-16 00:18:08.465+00	2024-02-16 00:18:08.465+00	SFAISec8QF	IEqTHcohpJ	3	2	4	3	2	\N	\N
YNEHsrbVd3	2024-02-16 00:18:08.677+00	2024-02-16 00:18:08.677+00	5X202ssb0D	rT0UCBK1bE	2	3	0	1	2	\N	\N
5eH2ZKGoCH	2024-02-16 00:18:08.973+00	2024-02-16 00:18:08.973+00	mQXQWNqxg9	UCFo58JaaD	4	0	1	2	0	\N	\N
7lnQjqssjl	2024-02-16 00:18:09.184+00	2024-02-16 00:18:09.184+00	VshUk7eBeK	jjVdtithcD	1	3	4	1	1	\N	\N
8LIn94vQWZ	2024-02-16 00:18:09.391+00	2024-02-16 00:18:09.391+00	5nv19u6KJ2	o4VD4BWwDt	0	2	1	3	4	\N	\N
iGTZcM5cD8	2024-02-16 00:18:09.598+00	2024-02-16 00:18:09.598+00	R2CLtFh5jU	PF8w2gMAdi	3	0	3	0	4	\N	\N
bPUN5fgAcK	2024-02-16 00:18:09.805+00	2024-02-16 00:18:09.805+00	dZKm0wOhYa	m8hjjLVdPS	4	1	0	4	3	\N	\N
PYTb4G0wbf	2024-02-16 00:18:10.015+00	2024-02-16 00:18:10.015+00	mQXQWNqxg9	8w7i8C3NnT	4	3	4	1	0	\N	\N
NihzH55zfR	2024-02-16 00:18:10.302+00	2024-02-16 00:18:10.302+00	HtEtaHBVDN	RkhjIQJgou	3	4	4	1	3	\N	\N
Wo0U1EATzM	2024-02-16 00:18:10.515+00	2024-02-16 00:18:10.515+00	jqDYoPT45X	JRi61dUphq	4	0	3	3	1	\N	\N
xpXJnTXkxf	2024-02-16 00:18:10.727+00	2024-02-16 00:18:10.727+00	NjxsGlPeB4	LgJuu5ABe5	4	1	3	0	3	\N	\N
UB5CWRPEpf	2024-02-16 00:18:10.939+00	2024-02-16 00:18:10.939+00	VshUk7eBeK	C7II8dYRPY	4	4	1	0	4	\N	\N
bpIdkhAVEN	2024-02-16 00:18:11.53+00	2024-02-16 00:18:11.53+00	VshUk7eBeK	yvUod6yLDt	2	4	3	4	0	\N	\N
GwbqprpLph	2024-02-16 00:18:11.838+00	2024-02-16 00:18:11.838+00	5X202ssb0D	l1Bslv8T2k	0	2	2	3	1	\N	\N
QGyA1LNBl3	2024-02-16 00:18:12.147+00	2024-02-16 00:18:12.147+00	WKpBp0c8F3	UCFo58JaaD	0	1	3	4	4	\N	\N
DvKgH0TRjT	2024-02-16 00:18:12.76+00	2024-02-16 00:18:12.76+00	ONgyydfVNz	NBojpORh3G	3	3	0	0	1	\N	\N
tuR4nIZoYb	2024-02-16 00:18:13.061+00	2024-02-16 00:18:13.061+00	HRhGpJpmb5	fKTSJPdUi9	3	3	1	2	3	\N	\N
kNGI6WRzO4	2024-02-16 00:18:13.264+00	2024-02-16 00:18:13.264+00	RWwLSzreG2	XpUyRlB6FI	4	1	1	2	2	\N	\N
cqwfG9heCX	2024-02-16 00:18:13.477+00	2024-02-16 00:18:13.477+00	R2CLtFh5jU	rT0UCBK1bE	0	4	1	2	1	\N	\N
G1KcsQyLBz	2024-02-16 00:18:13.686+00	2024-02-16 00:18:13.686+00	SFAISec8QF	0TvWuLoLF5	0	4	4	0	2	\N	\N
M6KQWrhQeG	2024-02-16 00:18:13.895+00	2024-02-16 00:18:13.895+00	9223vtvaBd	PF8w2gMAdi	0	4	4	3	0	\N	\N
inAQlGMCeA	2024-02-16 00:18:14.102+00	2024-02-16 00:18:14.102+00	HtEtaHBVDN	axyV0Fu7pm	1	3	3	2	3	\N	\N
5A2uXcjV2e	2024-02-16 00:18:14.314+00	2024-02-16 00:18:14.314+00	NjxsGlPeB4	8w7i8C3NnT	4	0	4	2	3	\N	\N
NVk4GjOubk	2024-02-16 00:18:14.522+00	2024-02-16 00:18:14.522+00	sy1HD51LXT	o4VD4BWwDt	3	4	0	4	0	\N	\N
l7lp0yjH7k	2024-02-16 00:18:14.732+00	2024-02-16 00:18:14.732+00	5nv19u6KJ2	JRi61dUphq	0	4	3	2	0	\N	\N
Nokt3eNREh	2024-02-16 00:18:15.016+00	2024-02-16 00:18:15.016+00	ONgyydfVNz	Pja6n3yaWZ	4	3	0	1	4	\N	\N
KNv8HDoVab	2024-02-16 00:18:15.226+00	2024-02-16 00:18:15.226+00	iUlyHNFGpG	9GF3y7LmHV	1	1	2	1	3	\N	\N
p4khthaDE6	2024-02-16 00:18:15.44+00	2024-02-16 00:18:15.44+00	ONgyydfVNz	fxvABtKCPT	4	1	3	0	3	\N	\N
Uj1sbvvbnk	2024-02-16 00:18:16.036+00	2024-02-16 00:18:16.036+00	Otwj7uJwjr	bQ0JOk10eL	3	4	2	1	4	\N	\N
91E82fd8Bo	2024-02-16 00:18:16.344+00	2024-02-16 00:18:16.344+00	SFAISec8QF	XSK814B37m	0	4	4	2	2	\N	\N
W2Hr3gKdST	2024-02-16 00:18:16.652+00	2024-02-16 00:18:16.652+00	sHiqaG4iqY	Oahm9sOn1y	2	2	2	4	2	\N	\N
ztFHKYkf3N	2024-02-16 00:18:16.86+00	2024-02-16 00:18:16.86+00	mAKp5BK7R1	UDXF0qXvDY	2	2	4	0	3	\N	\N
dxsl6YNt81	2024-02-16 00:18:17.163+00	2024-02-16 00:18:17.163+00	HRhGpJpmb5	EmIUBFwx0Z	0	0	3	1	4	\N	\N
VMSj4kgOa9	2024-02-16 00:18:17.375+00	2024-02-16 00:18:17.375+00	dZKm0wOhYa	WnUBBkiDjE	1	1	4	2	4	\N	\N
eahbZEYh5l	2024-02-16 00:18:17.586+00	2024-02-16 00:18:17.586+00	dEqAHvPMXA	HLIPwAqO2R	4	3	3	1	1	\N	\N
469uECCYmj	2024-02-16 00:18:17.882+00	2024-02-16 00:18:17.882+00	sy1HD51LXT	cTIjuPjyIa	3	1	4	0	4	\N	\N
lfwsjWpScb	2024-02-16 00:18:18.096+00	2024-02-16 00:18:18.096+00	5nv19u6KJ2	l1Bslv8T2k	4	4	3	1	0	\N	\N
uHAykDpEAP	2024-02-16 00:18:18.699+00	2024-02-16 00:18:18.699+00	mAKp5BK7R1	Pa0qBO2rzK	2	0	0	0	0	\N	\N
5ymlNdyV8h	2024-02-16 00:18:18.913+00	2024-02-16 00:18:18.913+00	AsrLUQwxI9	0TvWuLoLF5	2	1	2	1	1	\N	\N
xE60OVRN5U	2024-02-16 00:18:19.212+00	2024-02-16 00:18:19.212+00	HtEtaHBVDN	CSvk1ycWXk	2	0	1	0	4	\N	\N
Ix9cBA8WOx	2024-02-16 00:18:19.824+00	2024-02-16 00:18:19.824+00	RWwLSzreG2	jHqCpA1nWb	3	3	2	0	4	\N	\N
m9AdUnGW89	2024-02-16 00:18:20.03+00	2024-02-16 00:18:20.03+00	5nv19u6KJ2	lEPdiO1EDi	1	3	4	3	2	\N	\N
BTgAJZT0ox	2024-02-16 00:18:20.644+00	2024-02-16 00:18:20.644+00	NjxsGlPeB4	0TvWuLoLF5	4	3	4	2	4	\N	\N
ujKo7mOXyW	2024-02-16 00:18:20.85+00	2024-02-16 00:18:20.85+00	Otwj7uJwjr	XpUyRlB6FI	0	2	4	3	3	\N	\N
oL76H7s6KJ	2024-02-16 00:18:21.151+00	2024-02-16 00:18:21.151+00	ONgyydfVNz	P9sBFomftT	4	1	3	0	2	\N	\N
0uXrDmZ9E4	2024-02-16 00:18:21.36+00	2024-02-16 00:18:21.36+00	dZKm0wOhYa	qZmnAnnPEb	2	1	1	4	1	\N	\N
h3p2y7OOOz	2024-02-16 00:18:21.569+00	2024-02-16 00:18:21.569+00	iUlyHNFGpG	HXtEwLBC7f	3	0	0	3	2	\N	\N
ZjrCFHSCcZ	2024-02-16 00:18:21.776+00	2024-02-16 00:18:21.776+00	9223vtvaBd	lEPdiO1EDi	2	0	4	1	2	\N	\N
C47f7vQp4c	2024-02-16 00:18:21.981+00	2024-02-16 00:18:21.981+00	RWwLSzreG2	FYXEfIO1zF	3	1	2	3	0	\N	\N
e1iarNCp7p	2024-02-16 00:18:22.187+00	2024-02-16 00:18:22.187+00	RWwLSzreG2	8w7i8C3NnT	2	1	4	2	2	\N	\N
06QFAInId3	2024-02-16 00:18:22.397+00	2024-02-16 00:18:22.397+00	5nv19u6KJ2	RkhjIQJgou	3	1	2	0	4	\N	\N
2wIMHNLm5z	2024-02-16 00:18:22.605+00	2024-02-16 00:18:22.605+00	HRhGpJpmb5	TCkiw6gTDz	4	1	1	3	3	\N	\N
DPHbtXHytV	2024-02-16 00:18:22.815+00	2024-02-16 00:18:22.815+00	Otwj7uJwjr	E2hBZzDsjO	0	3	0	3	2	\N	\N
WlPvDdcLXx	2024-02-16 00:18:23.106+00	2024-02-16 00:18:23.106+00	AsrLUQwxI9	CSvk1ycWXk	2	4	0	2	0	\N	\N
WpaBcWYDI8	2024-02-16 00:18:23.315+00	2024-02-16 00:18:23.315+00	opW2wQ2bZ8	EmIUBFwx0Z	3	4	3	4	1	\N	\N
dQcEYbYAv1	2024-02-16 00:18:23.617+00	2024-02-16 00:18:23.617+00	5nv19u6KJ2	yvUod6yLDt	2	4	3	0	2	\N	\N
A6giyLiG5U	2024-02-16 00:18:24.229+00	2024-02-16 00:18:24.229+00	5nv19u6KJ2	rKyjwoEIRp	4	1	0	2	3	\N	\N
3YbQLgBUvL	2024-02-16 00:18:24.433+00	2024-02-16 00:18:24.433+00	S6wz0lK0bf	jjVdtithcD	4	1	2	0	4	\N	\N
u4B6wHGTjZ	2024-02-16 00:18:24.639+00	2024-02-16 00:18:24.639+00	RWwLSzreG2	XSK814B37m	2	0	3	3	4	\N	\N
E6tCKt7lgw	2024-02-16 00:18:24.845+00	2024-02-16 00:18:24.845+00	9223vtvaBd	HXtEwLBC7f	3	0	3	4	1	\N	\N
2XiFt3KCSr	2024-02-16 00:18:25.154+00	2024-02-16 00:18:25.154+00	S6wz0lK0bf	WBFeKac0OO	3	0	0	3	1	\N	\N
32IGnYWIJ2	2024-02-16 00:18:25.361+00	2024-02-16 00:18:25.361+00	AsrLUQwxI9	3P6kmNoY1F	3	2	2	4	2	\N	\N
y5FCNMbpGn	2024-02-16 00:18:25.572+00	2024-02-16 00:18:25.572+00	S6wz0lK0bf	fKTSJPdUi9	1	1	1	0	1	\N	\N
yJ4sOjDAAR	2024-02-16 00:18:25.782+00	2024-02-16 00:18:25.782+00	5X202ssb0D	JZOBDAh12a	3	3	0	0	4	\N	\N
NQ1loekIBY	2024-02-16 00:18:25.992+00	2024-02-16 00:18:25.992+00	iUlyHNFGpG	3u4B9V4l5K	4	4	3	1	1	\N	\N
yDtLjCY6tG	2024-02-16 00:18:26.196+00	2024-02-16 00:18:26.196+00	mAKp5BK7R1	H40ivltLwZ	4	0	0	2	4	\N	\N
VRBct81OSg	2024-02-16 00:18:26.404+00	2024-02-16 00:18:26.404+00	sy1HD51LXT	JRi61dUphq	1	3	3	4	2	\N	\N
eFRi3LgEEm	2024-02-16 00:18:26.69+00	2024-02-16 00:18:26.69+00	5X202ssb0D	JLhF4VuByh	3	2	4	0	0	\N	\N
DNvXDPxG7I	2024-02-16 00:18:26.899+00	2024-02-16 00:18:26.899+00	mQXQWNqxg9	jjVdtithcD	0	3	4	0	3	\N	\N
EwsV749oOD	2024-02-16 00:18:27.109+00	2024-02-16 00:18:27.109+00	mAKp5BK7R1	Gl96vGdYHM	3	3	1	1	0	\N	\N
ClpouaDnS5	2024-02-16 00:18:27.32+00	2024-02-16 00:18:27.32+00	sHiqaG4iqY	9GF3y7LmHV	2	3	1	1	2	\N	\N
RqS77YMOpq	2024-02-16 00:18:27.532+00	2024-02-16 00:18:27.532+00	9223vtvaBd	MQfxuw3ERg	3	0	2	2	2	\N	\N
69Y6UiYcHW	2024-02-16 00:18:27.816+00	2024-02-16 00:18:27.816+00	HRhGpJpmb5	Oahm9sOn1y	2	0	1	3	0	\N	\N
62k9QVvCSa	2024-02-16 00:18:28.43+00	2024-02-16 00:18:28.43+00	Otwj7uJwjr	8w7i8C3NnT	1	4	2	1	2	\N	\N
ZZvfHojCQL	2024-02-16 00:18:29.043+00	2024-02-16 00:18:29.043+00	RWwLSzreG2	cTIjuPjyIa	2	2	1	0	3	\N	\N
qvTokmHwo6	2024-02-16 00:18:29.349+00	2024-02-16 00:18:29.349+00	mQXQWNqxg9	XpUyRlB6FI	4	4	2	2	3	\N	\N
4jE4e3j9Pi	2024-02-16 00:18:29.964+00	2024-02-16 00:18:29.964+00	mAKp5BK7R1	IEqTHcohpJ	3	4	1	2	2	\N	\N
qQxvKCKpqC	2024-02-16 00:18:30.17+00	2024-02-16 00:18:30.17+00	opW2wQ2bZ8	rKyjwoEIRp	2	2	0	0	2	\N	\N
WCUmdl7Kxk	2024-02-16 00:18:30.373+00	2024-02-16 00:18:30.373+00	sy1HD51LXT	Pa0qBO2rzK	1	4	4	0	4	\N	\N
5HbEQoiwgA	2024-02-16 00:18:30.585+00	2024-02-16 00:18:30.585+00	WKpBp0c8F3	rKyjwoEIRp	3	3	3	2	2	\N	\N
HTbmyMqXY1	2024-02-16 00:18:30.824+00	2024-02-16 00:18:30.824+00	WKpBp0c8F3	y4RkaDbkec	0	0	2	1	3	\N	\N
SFg3ixXPAE	2024-02-16 00:18:31.032+00	2024-02-16 00:18:31.032+00	sy1HD51LXT	WSTLlXDcKl	0	0	4	4	1	\N	\N
QNLwZkQqLg	2024-02-16 00:18:31.242+00	2024-02-16 00:18:31.242+00	5nv19u6KJ2	cmxBcanww9	1	4	2	0	0	\N	\N
gdEx6fzaMh	2024-02-16 00:18:31.45+00	2024-02-16 00:18:31.45+00	iUlyHNFGpG	VK3vnSxIy8	3	4	3	2	0	\N	\N
UW7m77bcI7	2024-02-16 00:18:31.661+00	2024-02-16 00:18:31.661+00	dZKm0wOhYa	8w7i8C3NnT	0	4	4	3	4	\N	\N
COY8SerpdN	2024-02-16 00:18:31.871+00	2024-02-16 00:18:31.871+00	iUlyHNFGpG	vwHi602n66	0	0	0	3	4	\N	\N
ZOnSYYZfa6	2024-02-16 00:18:32.424+00	2024-02-16 00:18:32.424+00	dZKm0wOhYa	JLhF4VuByh	2	1	2	1	0	\N	\N
gMIB63VTmL	2024-02-16 00:18:32.632+00	2024-02-16 00:18:32.632+00	I5RzFRcQ7G	rT0UCBK1bE	0	0	3	2	4	\N	\N
uUFaKYhTih	2024-02-16 00:18:32.839+00	2024-02-16 00:18:32.839+00	HtEtaHBVDN	RkhjIQJgou	2	1	0	2	2	\N	\N
oEIso4EvNP	2024-02-16 00:18:33.14+00	2024-02-16 00:18:33.14+00	dZKm0wOhYa	08liHW08uC	3	0	3	2	0	\N	\N
a7WqowUCIQ	2024-02-16 00:18:33.346+00	2024-02-16 00:18:33.346+00	1as6rMOzjQ	TCkiw6gTDz	4	4	3	3	1	\N	\N
2lPSMKt7pN	2024-02-16 00:18:33.556+00	2024-02-16 00:18:33.556+00	AsrLUQwxI9	H40ivltLwZ	3	1	0	2	0	\N	\N
Bf5kXktoTJ	2024-02-16 00:18:33.763+00	2024-02-16 00:18:33.763+00	iUlyHNFGpG	3P6kmNoY1F	2	0	2	2	3	\N	\N
Vd8AR6sC5A	2024-02-16 00:18:33.97+00	2024-02-16 00:18:33.97+00	5nv19u6KJ2	NBojpORh3G	1	1	4	2	3	\N	\N
bbGrzV0XPo	2024-02-16 00:18:34.18+00	2024-02-16 00:18:34.18+00	5X202ssb0D	fxvABtKCPT	2	4	2	1	2	\N	\N
R6vTyZkTy8	2024-02-16 00:18:34.39+00	2024-02-16 00:18:34.39+00	I5RzFRcQ7G	rKyjwoEIRp	3	2	2	3	2	\N	\N
AhwcMf9kdh	2024-02-16 00:18:34.602+00	2024-02-16 00:18:34.602+00	opW2wQ2bZ8	u5FXeeOChJ	3	1	0	2	3	\N	\N
We644LFzxI	2024-02-16 00:18:35.185+00	2024-02-16 00:18:35.185+00	NjxsGlPeB4	89xRG1afNi	3	3	1	0	3	\N	\N
XwbBv9VuVk	2024-02-16 00:18:35.495+00	2024-02-16 00:18:35.495+00	NjxsGlPeB4	JLhF4VuByh	4	0	0	1	3	\N	\N
iIdsC8U0Yb	2024-02-16 00:18:35.703+00	2024-02-16 00:18:35.703+00	I5RzFRcQ7G	INeptnSdJC	3	1	2	2	0	\N	\N
8oLJ9WAgIg	2024-02-16 00:18:35.912+00	2024-02-16 00:18:35.912+00	R2CLtFh5jU	o90lhsZ7FK	0	4	0	2	0	\N	\N
qx5j7rqoXP	2024-02-16 00:18:36.114+00	2024-02-16 00:18:36.114+00	mAKp5BK7R1	BMLzFMvIT6	4	4	1	3	3	\N	\N
8p9plbozDa	2024-02-16 00:18:36.321+00	2024-02-16 00:18:36.321+00	9223vtvaBd	IEqTHcohpJ	4	1	1	4	1	\N	\N
yi2scTV18G	2024-02-16 00:18:36.53+00	2024-02-16 00:18:36.53+00	mAKp5BK7R1	JZOBDAh12a	1	3	3	0	4	\N	\N
bqKlSjswMz	2024-02-16 00:18:36.743+00	2024-02-16 00:18:36.743+00	iWxl9obi8w	XpUyRlB6FI	4	2	2	0	3	\N	\N
yaAw0GW37X	2024-02-16 00:18:37.033+00	2024-02-16 00:18:37.033+00	AsrLUQwxI9	TCkiw6gTDz	2	3	4	0	2	\N	\N
gV34jShFdB	2024-02-16 00:18:37.244+00	2024-02-16 00:18:37.244+00	opW2wQ2bZ8	UCFo58JaaD	2	3	0	3	4	\N	\N
gu3YCDcarw	2024-02-16 00:18:37.454+00	2024-02-16 00:18:37.454+00	5nv19u6KJ2	uigc7bJBOJ	0	1	0	3	3	\N	\N
Cuw0gM4m9l	2024-02-16 00:18:37.663+00	2024-02-16 00:18:37.663+00	sHiqaG4iqY	JZOBDAh12a	1	1	0	3	2	\N	\N
OY6JRKEn3r	2024-02-16 00:18:38.262+00	2024-02-16 00:18:38.262+00	mQXQWNqxg9	FJOTueDfs2	2	4	3	1	2	\N	\N
G2MHvtm1ed	2024-02-16 00:18:38.468+00	2024-02-16 00:18:38.468+00	mAKp5BK7R1	LgJuu5ABe5	2	0	3	2	4	\N	\N
RMibB22pET	2024-02-16 00:18:38.678+00	2024-02-16 00:18:38.678+00	Otwj7uJwjr	XwWwGnkXNj	0	1	0	4	2	\N	\N
ByzVNxHPzi	2024-02-16 00:18:39.282+00	2024-02-16 00:18:39.282+00	I5RzFRcQ7G	yvUod6yLDt	1	2	3	2	1	\N	\N
cAqHRpPBra	2024-02-16 00:18:39.591+00	2024-02-16 00:18:39.591+00	sy1HD51LXT	cTIjuPjyIa	3	1	4	1	3	\N	\N
qRCsoV7oxD	2024-02-16 00:18:40.924+00	2024-02-16 00:18:40.924+00	9223vtvaBd	CSvk1ycWXk	3	1	1	3	3	\N	\N
RrOWE9LCnV	2024-02-16 00:18:41.228+00	2024-02-16 00:18:41.228+00	S6wz0lK0bf	JRi61dUphq	1	4	1	3	2	\N	\N
cDOzKrPdom	2024-02-16 00:18:41.537+00	2024-02-16 00:18:41.537+00	5nv19u6KJ2	TCkiw6gTDz	1	2	1	4	3	\N	\N
Y4uodzWls9	2024-02-16 00:18:41.742+00	2024-02-16 00:18:41.742+00	ONgyydfVNz	WnUBBkiDjE	2	2	1	3	0	\N	\N
CnaIWrCC7R	2024-02-16 00:18:41.952+00	2024-02-16 00:18:41.952+00	HRhGpJpmb5	G0uU7KQLEt	2	4	2	0	3	\N	\N
qHCxy7RylM	2024-02-16 00:18:42.162+00	2024-02-16 00:18:42.162+00	Otwj7uJwjr	XwszrNEEEj	2	0	3	3	4	\N	\N
vzrdxGCZ78	2024-02-16 00:18:42.458+00	2024-02-16 00:18:42.458+00	AsrLUQwxI9	j0dWqP2C2A	1	4	3	1	1	\N	\N
6hwxXGQYBv	2024-02-16 00:18:43.075+00	2024-02-16 00:18:43.075+00	RWwLSzreG2	jjVdtithcD	4	4	1	4	0	\N	\N
CoEOqZPDAD	2024-02-16 00:18:43.48+00	2024-02-16 00:18:43.48+00	adE9nQrDk3	D0A6GLdsDM	4	3	4	0	4	\N	\N
R3NsbbXQA0	2024-02-16 00:18:43.686+00	2024-02-16 00:18:43.686+00	1as6rMOzjQ	UCFo58JaaD	4	3	0	1	2	\N	\N
18idN0TbYh	2024-02-16 00:18:43.995+00	2024-02-16 00:18:43.995+00	S6wz0lK0bf	uABtFsJhJc	1	2	4	3	3	\N	\N
uBzZ9HQrWr	2024-02-16 00:18:44.609+00	2024-02-16 00:18:44.609+00	dEqAHvPMXA	FJOTueDfs2	4	1	4	1	0	\N	\N
OdC5eV5J8b	2024-02-16 00:18:44.82+00	2024-02-16 00:18:44.82+00	VshUk7eBeK	yvUod6yLDt	4	1	2	1	3	\N	\N
H1LQiTn7sS	2024-02-16 00:18:45.124+00	2024-02-16 00:18:45.124+00	ONgyydfVNz	RBRcyltRSC	0	3	3	0	1	\N	\N
xhHoHCehpW	2024-02-16 00:18:45.336+00	2024-02-16 00:18:45.336+00	opW2wQ2bZ8	m8hjjLVdPS	4	2	3	1	4	\N	\N
NZzly4n1mZ	2024-02-16 00:18:45.543+00	2024-02-16 00:18:45.543+00	iUlyHNFGpG	89xRG1afNi	3	2	4	0	3	\N	\N
F0msM6RY6T	2024-02-16 00:18:45.75+00	2024-02-16 00:18:45.75+00	Otwj7uJwjr	6Fo67rhTSP	0	3	2	0	4	\N	\N
rVrvr2ZxTB	2024-02-16 00:18:46.044+00	2024-02-16 00:18:46.044+00	WKpBp0c8F3	VK3vnSxIy8	3	4	1	2	3	\N	\N
fRH1jIil0M	2024-02-16 00:18:46.254+00	2024-02-16 00:18:46.254+00	mAKp5BK7R1	NBojpORh3G	3	0	4	4	0	\N	\N
zVRydFWvrx	2024-02-16 00:18:46.463+00	2024-02-16 00:18:46.463+00	Otwj7uJwjr	bQpy9LEJWn	1	1	4	2	1	\N	\N
AG7FMEO4Cq	2024-02-16 00:18:46.673+00	2024-02-16 00:18:46.673+00	mAKp5BK7R1	bi1IivsuUB	2	0	3	4	4	\N	\N
NgrNoaxXy8	2024-02-16 00:18:46.884+00	2024-02-16 00:18:46.884+00	sy1HD51LXT	BMLzFMvIT6	1	4	1	3	2	\N	\N
MSJPAYEUhb	2024-02-16 00:18:47.171+00	2024-02-16 00:18:47.171+00	adE9nQrDk3	6Fo67rhTSP	0	4	0	0	1	\N	\N
j0wVEfcy9j	2024-02-16 00:18:47.479+00	2024-02-16 00:18:47.479+00	S6wz0lK0bf	TCkiw6gTDz	3	1	3	1	2	\N	\N
WphF0LT2wr	2024-02-16 00:18:47.786+00	2024-02-16 00:18:47.786+00	AsrLUQwxI9	tCIEnLLcUc	4	2	4	0	2	\N	\N
ze2wFpx967	2024-02-16 00:18:47.998+00	2024-02-16 00:18:47.998+00	opW2wQ2bZ8	yvUod6yLDt	0	3	4	3	1	\N	\N
WeYBePrK8Y	2024-02-16 00:18:48.209+00	2024-02-16 00:18:48.209+00	adE9nQrDk3	UCFo58JaaD	1	4	3	2	2	\N	\N
RoLowMrQHm	2024-02-16 00:18:48.504+00	2024-02-16 00:18:48.504+00	HRhGpJpmb5	IybX0eBoO3	3	1	0	3	1	\N	\N
2bCXHbtlib	2024-02-16 00:18:49.117+00	2024-02-16 00:18:49.117+00	adE9nQrDk3	LVYK4mLShP	2	3	4	2	0	\N	\N
0LvhY9oErF	2024-02-16 00:18:49.423+00	2024-02-16 00:18:49.423+00	RWwLSzreG2	6Fo67rhTSP	2	0	1	3	1	\N	\N
Zr02KcBgw1	2024-02-16 00:18:49.633+00	2024-02-16 00:18:49.633+00	WKpBp0c8F3	Oahm9sOn1y	3	4	3	0	0	\N	\N
414SmpyDah	2024-02-16 00:18:49.839+00	2024-02-16 00:18:49.839+00	dZKm0wOhYa	OQWu2bnHeC	3	0	4	0	1	\N	\N
UR8xaIW7no	2024-02-16 00:18:50.142+00	2024-02-16 00:18:50.142+00	VshUk7eBeK	qZmnAnnPEb	0	1	1	2	2	\N	\N
IHbulgbkPb	2024-02-16 00:18:50.351+00	2024-02-16 00:18:50.351+00	HRhGpJpmb5	08liHW08uC	1	4	1	0	1	\N	\N
vGHg1LtKUt	2024-02-16 00:18:50.561+00	2024-02-16 00:18:50.561+00	iUlyHNFGpG	NY6RE1qgWu	1	2	0	4	2	\N	\N
mrly3UqN6k	2024-02-16 00:18:50.773+00	2024-02-16 00:18:50.773+00	adE9nQrDk3	6Fo67rhTSP	2	2	0	0	3	\N	\N
iTJgALfc5u	2024-02-16 00:18:51.066+00	2024-02-16 00:18:51.066+00	9223vtvaBd	TpGyMZM9BG	4	4	1	1	2	\N	\N
JtCfJ7lTPZ	2024-02-16 00:18:51.369+00	2024-02-16 00:18:51.369+00	sy1HD51LXT	lEPdiO1EDi	1	1	2	3	3	\N	\N
iNqM2dgchL	2024-02-16 00:18:51.983+00	2024-02-16 00:18:51.983+00	SFAISec8QF	uigc7bJBOJ	1	2	1	0	3	\N	\N
rDhk7Mq3GP	2024-02-16 00:18:52.192+00	2024-02-16 00:18:52.192+00	AsrLUQwxI9	LVYK4mLShP	4	4	0	2	2	\N	\N
IuMQgHX7vJ	2024-02-16 00:18:52.4+00	2024-02-16 00:18:52.4+00	AsrLUQwxI9	RBRcyltRSC	0	2	3	4	4	\N	\N
kkkTGPIPCX	2024-02-16 00:18:52.608+00	2024-02-16 00:18:52.608+00	WKpBp0c8F3	NY6RE1qgWu	4	1	2	4	2	\N	\N
eQOZb9KuD7	2024-02-16 00:18:52.816+00	2024-02-16 00:18:52.816+00	I5RzFRcQ7G	tCIEnLLcUc	3	0	0	1	0	\N	\N
5e3K0FxGe3	2024-02-16 00:18:53.025+00	2024-02-16 00:18:53.025+00	AsrLUQwxI9	na5crB8ED1	0	1	4	0	3	\N	\N
Un7kfEiKyk	2024-02-16 00:18:53.316+00	2024-02-16 00:18:53.316+00	jqDYoPT45X	m6g8u0QpTC	1	3	3	1	1	\N	\N
upeH9ZF2El	2024-02-16 00:18:53.622+00	2024-02-16 00:18:53.622+00	5X202ssb0D	axyV0Fu7pm	3	1	2	3	2	\N	\N
NL05JcrMLF	2024-02-16 00:18:53.928+00	2024-02-16 00:18:53.928+00	RWwLSzreG2	INeptnSdJC	0	0	2	4	2	\N	\N
jzCTSkcJCP	2024-02-16 00:18:54.544+00	2024-02-16 00:18:54.544+00	mAKp5BK7R1	Pa0qBO2rzK	0	0	4	3	1	\N	\N
UEW3Oz0dC5	2024-02-16 00:18:54.752+00	2024-02-16 00:18:54.752+00	adE9nQrDk3	RBRcyltRSC	3	2	1	3	0	\N	\N
QC0MAUDFcZ	2024-02-16 00:18:55.362+00	2024-02-16 00:18:55.362+00	Otwj7uJwjr	JZOBDAh12a	2	0	3	0	4	\N	\N
IamqEOFtxU	2024-02-16 00:18:55.976+00	2024-02-16 00:18:55.976+00	jqDYoPT45X	HLIPwAqO2R	4	4	0	4	3	\N	\N
x4fH7YE1pf	2024-02-16 00:18:56.177+00	2024-02-16 00:18:56.177+00	I5RzFRcQ7G	qP3EdIVzfB	4	2	3	3	2	\N	\N
s9CDxvT4IE	2024-02-16 00:18:56.385+00	2024-02-16 00:18:56.385+00	AsrLUQwxI9	mMYg4cyd5R	4	0	3	0	0	\N	\N
hmUgEoJe6N	2024-02-16 00:18:56.694+00	2024-02-16 00:18:56.694+00	S6wz0lK0bf	UDXF0qXvDY	2	3	1	1	1	\N	\N
LONU4TXn05	2024-02-16 00:18:56.901+00	2024-02-16 00:18:56.901+00	mQXQWNqxg9	INeptnSdJC	4	1	1	3	3	\N	\N
9Cnvxh7wC6	2024-02-16 00:18:57.512+00	2024-02-16 00:18:57.512+00	iWxl9obi8w	FJOTueDfs2	0	1	2	4	4	\N	\N
VGbDCFz5XG	2024-02-16 00:18:57.717+00	2024-02-16 00:18:57.717+00	5X202ssb0D	fKTSJPdUi9	4	4	0	1	1	\N	\N
M3zMrhhR25	2024-02-16 00:18:57.928+00	2024-02-16 00:18:57.928+00	jqDYoPT45X	TpGyMZM9BG	0	2	1	4	4	\N	\N
3uxFM4uwiJ	2024-02-16 00:18:58.136+00	2024-02-16 00:18:58.136+00	sy1HD51LXT	3u4B9V4l5K	4	0	2	4	3	\N	\N
zijVhvxRtR	2024-02-16 00:18:58.344+00	2024-02-16 00:18:58.344+00	I5RzFRcQ7G	D0A6GLdsDM	1	0	4	0	3	\N	\N
9KixBunmYJ	2024-02-16 00:18:58.641+00	2024-02-16 00:18:58.641+00	dEqAHvPMXA	m6g8u0QpTC	1	3	0	0	1	\N	\N
sLztDsbv8j	2024-02-16 00:18:58.948+00	2024-02-16 00:18:58.948+00	S6wz0lK0bf	o90lhsZ7FK	0	2	4	0	0	\N	\N
SZnFLOFjni	2024-02-16 00:18:59.157+00	2024-02-16 00:18:59.157+00	adE9nQrDk3	Oahm9sOn1y	1	0	1	4	1	\N	\N
FDJVI4oA2t	2024-02-16 00:18:59.364+00	2024-02-16 00:18:59.364+00	mQXQWNqxg9	D0A6GLdsDM	1	4	2	2	3	\N	\N
38GmC0Z22V	2024-02-16 00:18:59.573+00	2024-02-16 00:18:59.573+00	sHiqaG4iqY	uABtFsJhJc	2	4	1	2	2	\N	\N
IZ4BrnCUvU	2024-02-16 00:18:59.785+00	2024-02-16 00:18:59.785+00	SFAISec8QF	XwszrNEEEj	2	1	2	1	0	\N	\N
R7gWJ1QkaH	2024-02-16 00:19:00.383+00	2024-02-16 00:19:00.383+00	Otwj7uJwjr	XwszrNEEEj	1	4	3	3	0	\N	\N
yqPT91oKNU	2024-02-16 00:19:00.591+00	2024-02-16 00:19:00.591+00	mAKp5BK7R1	MQfxuw3ERg	0	3	1	2	4	\N	\N
nBM9qNkivC	2024-02-16 00:19:00.828+00	2024-02-16 00:19:00.828+00	5nv19u6KJ2	rKyjwoEIRp	0	4	4	1	1	\N	\N
CGx0cyrGmi	2024-02-16 00:19:01.038+00	2024-02-16 00:19:01.038+00	9223vtvaBd	cwVEh0dqfm	2	2	3	0	4	\N	\N
fDj9proTyl	2024-02-16 00:19:01.249+00	2024-02-16 00:19:01.249+00	HRhGpJpmb5	IybX0eBoO3	3	1	4	2	4	\N	\N
xeHAGWrR62	2024-02-16 00:19:01.46+00	2024-02-16 00:19:01.46+00	S6wz0lK0bf	NY6RE1qgWu	1	0	4	3	2	\N	\N
aVLNj40lV0	2024-02-16 00:19:01.717+00	2024-02-16 00:19:01.717+00	1as6rMOzjQ	bQpy9LEJWn	1	1	4	4	1	\N	\N
PrnHI6JWu7	2024-02-16 00:19:02.022+00	2024-02-16 00:19:02.022+00	ONgyydfVNz	cwVEh0dqfm	2	3	2	0	0	\N	\N
CyVdJYANQU	2024-02-16 00:19:02.232+00	2024-02-16 00:19:02.232+00	iUlyHNFGpG	JRi61dUphq	0	2	3	3	4	\N	\N
bH75jNlqNw	2024-02-16 00:19:02.45+00	2024-02-16 00:19:02.45+00	I5RzFRcQ7G	axyV0Fu7pm	0	2	4	4	1	\N	\N
xerkZqi0BA	2024-02-16 00:19:02.739+00	2024-02-16 00:19:02.739+00	5X202ssb0D	14jGmOAXcg	4	3	3	0	1	\N	\N
MQd6vCTEC8	2024-02-16 00:19:02.952+00	2024-02-16 00:19:02.952+00	AsrLUQwxI9	AgU9OLJkqz	1	1	1	1	1	\N	\N
bROIbL6k2L	2024-02-16 00:19:03.251+00	2024-02-16 00:19:03.251+00	opW2wQ2bZ8	EmIUBFwx0Z	3	1	4	1	4	\N	\N
YTpu0IB6mt	2024-02-16 00:19:03.461+00	2024-02-16 00:19:03.461+00	jqDYoPT45X	INeptnSdJC	2	3	1	0	0	\N	\N
s8OEwQ4MLW	2024-02-16 00:19:03.67+00	2024-02-16 00:19:03.67+00	S6wz0lK0bf	C7II8dYRPY	4	3	1	4	2	\N	\N
fbFlAHYF67	2024-02-16 00:19:03.969+00	2024-02-16 00:19:03.969+00	dEqAHvPMXA	jjVdtithcD	1	1	2	1	2	\N	\N
rgex0HDV6d	2024-02-16 00:19:04.179+00	2024-02-16 00:19:04.179+00	mAKp5BK7R1	lEPdiO1EDi	0	2	1	3	1	\N	\N
lYLHjxlMbk	2024-02-16 00:19:04.39+00	2024-02-16 00:19:04.39+00	ONgyydfVNz	Oahm9sOn1y	1	0	2	3	1	\N	\N
vyrFlBAzG0	2024-02-16 00:19:04.684+00	2024-02-16 00:19:04.684+00	S6wz0lK0bf	14jGmOAXcg	0	3	4	3	1	\N	\N
zdkppRhN2a	2024-02-16 00:19:04.897+00	2024-02-16 00:19:04.897+00	RWwLSzreG2	jjVdtithcD	3	3	1	2	1	\N	\N
wzvf3OGveV	2024-02-16 00:19:05.111+00	2024-02-16 00:19:05.111+00	1as6rMOzjQ	9GF3y7LmHV	1	0	1	3	0	\N	\N
POQAe8WFSQ	2024-02-16 00:19:05.324+00	2024-02-16 00:19:05.324+00	I5RzFRcQ7G	AgU9OLJkqz	0	4	2	3	2	\N	\N
YrqkOaKz5t	2024-02-16 00:19:05.534+00	2024-02-16 00:19:05.534+00	HtEtaHBVDN	FJOTueDfs2	4	4	2	1	1	\N	\N
WzQTd1ffXw	2024-02-16 00:19:05.746+00	2024-02-16 00:19:05.746+00	SFAISec8QF	08liHW08uC	3	2	3	0	0	\N	\N
8mZGCXBGzT	2024-02-16 00:19:05.957+00	2024-02-16 00:19:05.957+00	HRhGpJpmb5	fKTSJPdUi9	0	4	4	0	1	\N	\N
4dm2e6mrIq	2024-02-16 00:19:06.16+00	2024-02-16 00:19:06.16+00	jqDYoPT45X	JZOBDAh12a	4	0	0	3	4	\N	\N
1oYEXBqjY8	2024-02-16 00:19:06.425+00	2024-02-16 00:19:06.425+00	opW2wQ2bZ8	UDXF0qXvDY	3	3	4	1	1	\N	\N
M33Q7VRf8l	2024-02-16 00:19:06.639+00	2024-02-16 00:19:06.639+00	WKpBp0c8F3	08liHW08uC	2	4	2	1	3	\N	\N
rXIBUnbOAo	2024-02-16 00:19:06.937+00	2024-02-16 00:19:06.937+00	R2CLtFh5jU	cTIjuPjyIa	0	0	3	3	2	\N	\N
zTXWjUCFPb	2024-02-16 00:19:07.555+00	2024-02-16 00:19:07.555+00	ONgyydfVNz	IEqTHcohpJ	1	0	0	0	4	\N	\N
YjeJ0BBReM	2024-02-16 00:19:08.164+00	2024-02-16 00:19:08.164+00	jqDYoPT45X	fwLPZZ8YQa	2	1	1	0	2	\N	\N
asnjnRJUfG	2024-02-16 00:19:08.369+00	2024-02-16 00:19:08.369+00	dZKm0wOhYa	WSTLlXDcKl	3	0	4	4	0	\N	\N
2Sam0yND8r	2024-02-16 00:19:08.68+00	2024-02-16 00:19:08.68+00	SFAISec8QF	cTIjuPjyIa	4	3	2	3	1	\N	\N
HUXNk2ePum	2024-02-16 00:19:08.89+00	2024-02-16 00:19:08.89+00	ONgyydfVNz	o4VD4BWwDt	4	3	3	0	4	\N	\N
cHnYs6uSwt	2024-02-16 00:19:09.103+00	2024-02-16 00:19:09.103+00	VshUk7eBeK	bi1IivsuUB	0	2	0	2	0	\N	\N
QwKFLKmJQc	2024-02-16 00:19:09.311+00	2024-02-16 00:19:09.311+00	RWwLSzreG2	H40ivltLwZ	3	3	4	1	1	\N	\N
MEbPF5bUNU	2024-02-16 00:19:09.518+00	2024-02-16 00:19:09.518+00	VshUk7eBeK	3P6kmNoY1F	3	4	3	3	4	\N	\N
mumF1vMS26	2024-02-16 00:19:09.726+00	2024-02-16 00:19:09.726+00	mQXQWNqxg9	uigc7bJBOJ	3	2	0	1	3	\N	\N
At0jABgFgm	2024-02-16 00:19:10.008+00	2024-02-16 00:19:10.008+00	iWxl9obi8w	FJOTueDfs2	4	0	3	0	4	\N	\N
p9dM86NeT7	2024-02-16 00:19:10.418+00	2024-02-16 00:19:10.418+00	NjxsGlPeB4	fwLPZZ8YQa	3	4	3	3	2	\N	\N
k9eeWU4fOz	2024-02-16 00:19:10.627+00	2024-02-16 00:19:10.627+00	RWwLSzreG2	G0uU7KQLEt	3	3	1	3	4	\N	\N
2dwNaprias	2024-02-16 00:19:10.839+00	2024-02-16 00:19:10.839+00	dZKm0wOhYa	FJOTueDfs2	0	3	2	1	1	\N	\N
bnOlkEu3q6	2024-02-16 00:19:11.049+00	2024-02-16 00:19:11.049+00	sHiqaG4iqY	lxQA9rtSfY	1	2	4	4	3	\N	\N
IzA1TM7HDk	2024-02-16 00:19:11.255+00	2024-02-16 00:19:11.255+00	mQXQWNqxg9	mMYg4cyd5R	4	0	2	3	0	\N	\N
atUczXcA7y	2024-02-16 00:19:11.462+00	2024-02-16 00:19:11.462+00	adE9nQrDk3	m6g8u0QpTC	1	1	0	2	2	\N	\N
6R63fX1hcl	2024-02-16 00:19:11.672+00	2024-02-16 00:19:11.672+00	adE9nQrDk3	BMLzFMvIT6	1	4	2	0	4	\N	\N
nsQBAHgq89	2024-02-16 00:19:11.888+00	2024-02-16 00:19:11.888+00	sHiqaG4iqY	LgJuu5ABe5	3	4	3	0	4	\N	\N
fjf1C0WnfQ	2024-02-16 00:19:12.092+00	2024-02-16 00:19:12.092+00	I5RzFRcQ7G	HLIPwAqO2R	0	0	2	0	2	\N	\N
21y7umLlwE	2024-02-16 00:19:12.298+00	2024-02-16 00:19:12.298+00	S6wz0lK0bf	o90lhsZ7FK	2	2	1	0	2	\N	\N
qCKxqWJCg1	2024-02-16 00:19:12.505+00	2024-02-16 00:19:12.505+00	I5RzFRcQ7G	NY6RE1qgWu	3	0	3	1	0	\N	\N
FySDeyUU5v	2024-02-16 00:19:12.716+00	2024-02-16 00:19:12.716+00	5nv19u6KJ2	qP3EdIVzfB	4	0	3	3	3	\N	\N
Opn7YqWyv7	2024-02-16 00:19:12.98+00	2024-02-16 00:19:12.98+00	NjxsGlPeB4	XpUyRlB6FI	4	3	1	1	4	\N	\N
ktXYsIm5rW	2024-02-16 00:19:13.288+00	2024-02-16 00:19:13.288+00	iUlyHNFGpG	o90lhsZ7FK	1	2	4	4	3	\N	\N
7lWlDHCnwy	2024-02-16 00:19:13.498+00	2024-02-16 00:19:13.498+00	mQXQWNqxg9	14jGmOAXcg	3	2	3	4	0	\N	\N
4aeQn4MiI7	2024-02-16 00:19:13.71+00	2024-02-16 00:19:13.71+00	dZKm0wOhYa	IEqTHcohpJ	4	3	3	1	4	\N	\N
n967GtE56h	2024-02-16 00:19:14.003+00	2024-02-16 00:19:14.003+00	9223vtvaBd	LDrIH1vU8x	1	1	3	2	4	\N	\N
robKJC8fl5	2024-02-16 00:19:14.311+00	2024-02-16 00:19:14.311+00	adE9nQrDk3	Pa0qBO2rzK	2	3	1	1	2	\N	\N
JtnLxfeXMe	2024-02-16 00:19:14.52+00	2024-02-16 00:19:14.52+00	opW2wQ2bZ8	IEqTHcohpJ	2	1	2	3	2	\N	\N
tLPL4ipaP8	2024-02-16 00:19:14.732+00	2024-02-16 00:19:14.732+00	jqDYoPT45X	rT0UCBK1bE	3	4	2	1	4	\N	\N
yKMt5AcDNU	2024-02-16 00:19:14.943+00	2024-02-16 00:19:14.943+00	1as6rMOzjQ	qZmnAnnPEb	2	4	0	0	1	\N	\N
A3g4avFTmk	2024-02-16 00:19:15.151+00	2024-02-16 00:19:15.151+00	iUlyHNFGpG	cFtamPA0zH	4	3	4	1	4	\N	\N
aEpIvh5VMf	2024-02-16 00:19:15.363+00	2024-02-16 00:19:15.363+00	1as6rMOzjQ	rKyjwoEIRp	2	4	3	4	2	\N	\N
3bJZNYQV13	2024-02-16 00:19:15.573+00	2024-02-16 00:19:15.573+00	I5RzFRcQ7G	u5FXeeOChJ	3	1	3	2	3	\N	\N
TZzpWjv6bD	2024-02-16 00:19:15.783+00	2024-02-16 00:19:15.783+00	AsrLUQwxI9	TpGyMZM9BG	1	1	4	0	3	\N	\N
Skw5xnbHO1	2024-02-16 00:19:15.992+00	2024-02-16 00:19:15.992+00	iWxl9obi8w	RkhjIQJgou	4	0	1	0	4	\N	\N
mTcEjDTtaD	2024-02-16 00:19:16.258+00	2024-02-16 00:19:16.258+00	sy1HD51LXT	E2hBZzDsjO	4	4	3	1	3	\N	\N
75obUggvKV	2024-02-16 00:19:16.47+00	2024-02-16 00:19:16.47+00	dZKm0wOhYa	uABtFsJhJc	2	2	0	4	2	\N	\N
rAqptp9G4f	2024-02-16 00:19:17.078+00	2024-02-16 00:19:17.078+00	SFAISec8QF	LVYK4mLShP	4	2	3	4	3	\N	\N
icvD0ICZC4	2024-02-16 00:19:17.286+00	2024-02-16 00:19:17.286+00	HtEtaHBVDN	FJOTueDfs2	2	4	1	0	4	\N	\N
59HHQZ40Vp	2024-02-16 00:19:17.586+00	2024-02-16 00:19:17.586+00	HtEtaHBVDN	89xRG1afNi	3	2	2	3	3	\N	\N
X3hWDCt5hp	2024-02-16 00:19:17.793+00	2024-02-16 00:19:17.793+00	I5RzFRcQ7G	BMLzFMvIT6	1	4	2	0	0	\N	\N
kWSdNkFv5P	2024-02-16 00:19:18.004+00	2024-02-16 00:19:18.004+00	iWxl9obi8w	E2hBZzDsjO	0	3	2	4	3	\N	\N
NMwLdwEiRI	2024-02-16 00:19:18.214+00	2024-02-16 00:19:18.214+00	5X202ssb0D	rT0UCBK1bE	1	4	4	0	0	\N	\N
OQ1FBre7Ww	2024-02-16 00:19:18.512+00	2024-02-16 00:19:18.512+00	mQXQWNqxg9	P9sBFomftT	2	0	1	3	3	\N	\N
d3se2yxPQ1	2024-02-16 00:19:18.819+00	2024-02-16 00:19:18.819+00	iWxl9obi8w	e037qpAih3	1	0	2	1	4	\N	\N
SiMDDr40jZ	2024-02-16 00:19:19.029+00	2024-02-16 00:19:19.029+00	dEqAHvPMXA	cmxBcanww9	0	3	1	4	2	\N	\N
mIyzoyyJ0c	2024-02-16 00:19:19.237+00	2024-02-16 00:19:19.237+00	NjxsGlPeB4	mMYg4cyd5R	1	2	3	2	3	\N	\N
dj84co8uWc	2024-02-16 00:19:19.445+00	2024-02-16 00:19:19.445+00	mQXQWNqxg9	89xRG1afNi	4	3	4	4	4	\N	\N
9Fk3olAHbi	2024-02-16 00:19:19.656+00	2024-02-16 00:19:19.656+00	HRhGpJpmb5	IybX0eBoO3	4	2	2	3	4	\N	\N
Ez7EfZtNPK	2024-02-16 00:19:19.866+00	2024-02-16 00:19:19.866+00	AsrLUQwxI9	KCsJ4XR6Dn	3	0	4	0	3	\N	\N
WJ8HXCDtPY	2024-02-16 00:19:20.149+00	2024-02-16 00:19:20.149+00	VshUk7eBeK	na5crB8ED1	3	1	2	3	2	\N	\N
hASuEm6jSF	2024-02-16 00:19:20.456+00	2024-02-16 00:19:20.456+00	mQXQWNqxg9	o90lhsZ7FK	1	0	1	0	0	\N	\N
YWB0FQ8wZe	2024-02-16 00:19:20.667+00	2024-02-16 00:19:20.667+00	1as6rMOzjQ	LDrIH1vU8x	1	3	2	2	3	\N	\N
l9LE5udYdy	2024-02-16 00:19:20.879+00	2024-02-16 00:19:20.879+00	jqDYoPT45X	LVYK4mLShP	4	3	3	2	3	\N	\N
uKkmlC5XqY	2024-02-16 00:19:21.089+00	2024-02-16 00:19:21.089+00	1as6rMOzjQ	bi1IivsuUB	2	0	1	4	0	\N	\N
rXyrg8o1kA	2024-02-16 00:19:21.303+00	2024-02-16 00:19:21.303+00	adE9nQrDk3	uABtFsJhJc	3	0	4	3	1	\N	\N
AQJTOpmcGG	2024-02-16 00:19:21.512+00	2024-02-16 00:19:21.512+00	sy1HD51LXT	HXtEwLBC7f	4	0	0	3	2	\N	\N
GFJCFWEv5U	2024-02-16 00:19:21.726+00	2024-02-16 00:19:21.726+00	R2CLtFh5jU	XwWwGnkXNj	2	0	1	2	4	\N	\N
SNXMthxiZL	2024-02-16 00:19:21.94+00	2024-02-16 00:19:21.94+00	iWxl9obi8w	Oahm9sOn1y	3	3	4	4	0	\N	\N
EyMGHqf9TC	2024-02-16 00:19:22.152+00	2024-02-16 00:19:22.152+00	adE9nQrDk3	14jGmOAXcg	1	1	3	3	3	\N	\N
h6jMmC3Bqv	2024-02-16 00:19:22.364+00	2024-02-16 00:19:22.364+00	opW2wQ2bZ8	XwszrNEEEj	1	1	3	2	4	\N	\N
SinGr0Ghdy	2024-02-16 00:19:22.571+00	2024-02-16 00:19:22.571+00	sy1HD51LXT	0TvWuLoLF5	1	4	4	4	4	\N	\N
1wzRfWxEaw	2024-02-16 00:19:23.218+00	2024-02-16 00:19:23.218+00	SFAISec8QF	y4RkaDbkec	4	2	3	2	2	\N	\N
yC4IQUnhHq	2024-02-16 00:19:23.528+00	2024-02-16 00:19:23.528+00	HtEtaHBVDN	tCIEnLLcUc	1	0	4	3	1	\N	\N
jIihITmZVh	2024-02-16 00:19:23.74+00	2024-02-16 00:19:23.74+00	NjxsGlPeB4	INeptnSdJC	1	3	1	2	4	\N	\N
R78nlCwd2J	2024-02-16 00:19:23.946+00	2024-02-16 00:19:23.946+00	Otwj7uJwjr	o4VD4BWwDt	0	4	2	2	4	\N	\N
xFhOGiZIhC	2024-02-16 00:19:24.246+00	2024-02-16 00:19:24.246+00	mAKp5BK7R1	0TvWuLoLF5	1	4	4	0	4	\N	\N
r8sC3Fny7X	2024-02-16 00:19:24.457+00	2024-02-16 00:19:24.457+00	AsrLUQwxI9	IEqTHcohpJ	2	2	1	0	0	\N	\N
JbMmmAvtSC	2024-02-16 00:19:24.757+00	2024-02-16 00:19:24.757+00	1as6rMOzjQ	yvUod6yLDt	3	4	3	0	3	\N	\N
PWTAnR8VgC	2024-02-16 00:19:24.968+00	2024-02-16 00:19:24.968+00	S6wz0lK0bf	tCIEnLLcUc	3	0	4	1	0	\N	\N
FGxysHpHPf	2024-02-16 00:19:25.18+00	2024-02-16 00:19:25.18+00	1as6rMOzjQ	C7II8dYRPY	1	3	0	3	3	\N	\N
Fnrew1EKxN	2024-02-16 00:19:25.392+00	2024-02-16 00:19:25.392+00	Otwj7uJwjr	BMLzFMvIT6	2	4	0	4	4	\N	\N
ZEfJNgvDkK	2024-02-16 00:19:25.983+00	2024-02-16 00:19:25.983+00	sHiqaG4iqY	Gl96vGdYHM	0	1	4	1	2	\N	\N
xTz0fpyIdR	2024-02-16 00:19:26.181+00	2024-02-16 00:19:26.181+00	sHiqaG4iqY	TZsdmscJ2B	1	0	2	4	4	\N	\N
yB0bVzf6rI	2024-02-16 00:19:26.385+00	2024-02-16 00:19:26.385+00	Otwj7uJwjr	qZmnAnnPEb	3	4	1	0	2	\N	\N
ELzpxtl9eY	2024-02-16 00:19:26.698+00	2024-02-16 00:19:26.698+00	SFAISec8QF	yvUod6yLDt	3	3	3	0	1	\N	\N
ZfxaG9T0af	2024-02-16 00:19:26.905+00	2024-02-16 00:19:26.905+00	sy1HD51LXT	UDXF0qXvDY	1	2	4	2	1	\N	\N
cg7diKxAk0	2024-02-16 00:19:27.116+00	2024-02-16 00:19:27.116+00	HtEtaHBVDN	m6g8u0QpTC	3	2	3	4	1	\N	\N
OslQJ6LPqT	2024-02-16 00:19:27.326+00	2024-02-16 00:19:27.326+00	ONgyydfVNz	l1Bslv8T2k	4	0	4	2	0	\N	\N
s4bB9uE4mp	2024-02-16 00:19:27.54+00	2024-02-16 00:19:27.54+00	sHiqaG4iqY	6Fo67rhTSP	4	2	3	3	1	\N	\N
gWx2MoY9Ll	2024-02-16 00:19:28.137+00	2024-02-16 00:19:28.137+00	sHiqaG4iqY	EmIUBFwx0Z	3	4	4	4	4	\N	\N
qkOBNdMqn5	2024-02-16 00:19:28.346+00	2024-02-16 00:19:28.346+00	ONgyydfVNz	JRi61dUphq	0	4	0	0	3	\N	\N
0lJ25P9ccp	2024-02-16 00:19:28.558+00	2024-02-16 00:19:28.558+00	WKpBp0c8F3	VK3vnSxIy8	0	2	3	3	2	\N	\N
5BD9vTWvvt	2024-02-16 00:19:28.855+00	2024-02-16 00:19:28.855+00	NjxsGlPeB4	m6g8u0QpTC	0	4	1	3	1	\N	\N
GRfMzzpNfe	2024-02-16 00:19:29.069+00	2024-02-16 00:19:29.069+00	NjxsGlPeB4	6Fo67rhTSP	1	4	4	0	2	\N	\N
hJybu6UN4f	2024-02-16 00:19:29.281+00	2024-02-16 00:19:29.281+00	iUlyHNFGpG	RBRcyltRSC	4	1	4	0	1	\N	\N
b7nay2yHIC	2024-02-16 00:19:29.495+00	2024-02-16 00:19:29.495+00	mQXQWNqxg9	qP3EdIVzfB	1	0	2	1	3	\N	\N
tK4DRIOY97	2024-02-16 00:19:29.716+00	2024-02-16 00:19:29.716+00	S6wz0lK0bf	rT0UCBK1bE	3	0	1	4	3	\N	\N
BMuvSLCnvK	2024-02-16 00:19:29.981+00	2024-02-16 00:19:29.981+00	mQXQWNqxg9	TpGyMZM9BG	1	3	3	3	1	\N	\N
QfJnBfVf77	2024-02-16 00:19:30.488+00	2024-02-16 00:19:30.488+00	I5RzFRcQ7G	cmxBcanww9	3	3	2	2	0	\N	\N
tEcbioWp0u	2024-02-16 00:19:30.695+00	2024-02-16 00:19:30.695+00	S6wz0lK0bf	eEmewy7hPd	1	1	3	1	3	\N	\N
BPsA2gI3dQ	2024-02-16 00:19:30.904+00	2024-02-16 00:19:30.904+00	SFAISec8QF	o4VD4BWwDt	1	1	3	3	3	\N	\N
q0LZHYVFAh	2024-02-16 00:19:31.215+00	2024-02-16 00:19:31.215+00	S6wz0lK0bf	HLIPwAqO2R	2	1	3	2	4	\N	\N
IYqoNSEdYX	2024-02-16 00:19:31.447+00	2024-02-16 00:19:31.447+00	VshUk7eBeK	E2hBZzDsjO	0	4	3	3	3	\N	\N
5f95jhmKhV	2024-02-16 00:19:31.657+00	2024-02-16 00:19:31.657+00	jqDYoPT45X	AgU9OLJkqz	2	2	2	3	0	\N	\N
Tzvd10a5yb	2024-02-16 00:19:31.869+00	2024-02-16 00:19:31.869+00	adE9nQrDk3	MQfxuw3ERg	3	3	0	0	1	\N	\N
APxT3kqGOf	2024-02-16 00:19:32.082+00	2024-02-16 00:19:32.082+00	sHiqaG4iqY	IybX0eBoO3	3	4	3	4	0	\N	\N
oIUaHqbDxr	2024-02-16 00:19:32.294+00	2024-02-16 00:19:32.294+00	HtEtaHBVDN	l1Bslv8T2k	3	1	4	4	0	\N	\N
2ceugz8Ay0	2024-02-16 00:19:32.506+00	2024-02-16 00:19:32.506+00	iUlyHNFGpG	rKyjwoEIRp	0	4	3	3	2	\N	\N
f3zhBLWWam	2024-02-16 00:19:32.719+00	2024-02-16 00:19:32.719+00	1as6rMOzjQ	MQfxuw3ERg	4	2	0	3	3	\N	\N
nS463Hvazw	2024-02-16 00:19:32.932+00	2024-02-16 00:19:32.932+00	R2CLtFh5jU	y4RkaDbkec	4	2	1	3	2	\N	\N
EjjdT8ACcf	2024-02-16 00:19:33.148+00	2024-02-16 00:19:33.148+00	HtEtaHBVDN	Oahm9sOn1y	4	3	0	3	3	\N	\N
FvGgEsH0fB	2024-02-16 00:19:33.359+00	2024-02-16 00:19:33.359+00	Otwj7uJwjr	HLIPwAqO2R	0	3	4	3	4	\N	\N
XwTuOuGKUF	2024-02-16 00:19:33.571+00	2024-02-16 00:19:33.571+00	dEqAHvPMXA	e037qpAih3	2	0	4	1	0	\N	\N
9CLrdEur6Z	2024-02-16 00:19:33.78+00	2024-02-16 00:19:33.78+00	SFAISec8QF	HXtEwLBC7f	1	0	4	1	3	\N	\N
EUJ8ENGNF8	2024-02-16 00:19:33.99+00	2024-02-16 00:19:33.99+00	iWxl9obi8w	m8hjjLVdPS	4	2	1	0	3	\N	\N
STRLjPiEhs	2024-02-16 00:19:34.2+00	2024-02-16 00:19:34.2+00	WKpBp0c8F3	jjVdtithcD	3	1	3	0	3	\N	\N
idyALAYNCn	2024-02-16 00:19:34.413+00	2024-02-16 00:19:34.413+00	Otwj7uJwjr	C7II8dYRPY	0	4	1	4	1	\N	\N
Qq4BstYlRh	2024-02-16 00:19:34.624+00	2024-02-16 00:19:34.624+00	5nv19u6KJ2	Oahm9sOn1y	1	1	3	3	4	\N	\N
aCpBoBkhmB	2024-02-16 00:19:34.837+00	2024-02-16 00:19:34.837+00	sHiqaG4iqY	ThMuD3hYRQ	3	3	1	3	0	\N	\N
vlbCxHpre0	2024-02-16 00:19:35.049+00	2024-02-16 00:19:35.049+00	mAKp5BK7R1	JZOBDAh12a	2	1	1	0	3	\N	\N
go0ASXpwHL	2024-02-16 00:19:35.261+00	2024-02-16 00:19:35.261+00	dZKm0wOhYa	cmxBcanww9	4	3	2	2	2	\N	\N
q6d5GKpJOh	2024-02-16 00:19:35.473+00	2024-02-16 00:19:35.473+00	5nv19u6KJ2	UCFo58JaaD	4	4	4	3	3	\N	\N
oB2HEVKFes	2024-02-16 00:19:36.116+00	2024-02-16 00:19:36.116+00	adE9nQrDk3	MQfxuw3ERg	3	0	4	4	2	\N	\N
BwRBA1KuIM	2024-02-16 00:19:36.328+00	2024-02-16 00:19:36.328+00	ONgyydfVNz	uigc7bJBOJ	3	3	3	3	1	\N	\N
ChD0eUnRIC	2024-02-16 00:19:36.943+00	2024-02-16 00:19:36.943+00	R2CLtFh5jU	3u4B9V4l5K	4	3	3	0	4	\N	\N
YhellZCItH	2024-02-16 00:19:37.152+00	2024-02-16 00:19:37.152+00	adE9nQrDk3	Oahm9sOn1y	3	0	3	0	0	\N	\N
BsDQc4OHob	2024-02-16 00:19:37.455+00	2024-02-16 00:19:37.455+00	HRhGpJpmb5	FJOTueDfs2	0	3	2	4	4	\N	\N
r3dY09xf3j	2024-02-16 00:19:37.665+00	2024-02-16 00:19:37.665+00	5nv19u6KJ2	NBojpORh3G	3	3	3	0	4	\N	\N
LNTJrScbGN	2024-02-16 00:19:37.874+00	2024-02-16 00:19:37.874+00	R2CLtFh5jU	INeptnSdJC	1	4	0	1	2	\N	\N
CvS55dfU8n	2024-02-16 00:19:38.082+00	2024-02-16 00:19:38.082+00	S6wz0lK0bf	FYXEfIO1zF	4	2	1	4	4	\N	\N
GYcAKcMyDq	2024-02-16 00:19:38.294+00	2024-02-16 00:19:38.294+00	9223vtvaBd	cmxBcanww9	3	4	2	4	1	\N	\N
xGBYEcym2v	2024-02-16 00:19:38.508+00	2024-02-16 00:19:38.508+00	HtEtaHBVDN	Pja6n3yaWZ	1	4	1	3	0	\N	\N
jQLeIDzGwq	2024-02-16 00:19:38.718+00	2024-02-16 00:19:38.718+00	jqDYoPT45X	UDXF0qXvDY	3	2	1	0	4	\N	\N
73g8trsZUH	2024-02-16 00:19:38.929+00	2024-02-16 00:19:38.929+00	HRhGpJpmb5	JLhF4VuByh	0	0	1	3	4	\N	\N
qM7ngtD4b7	2024-02-16 00:19:39.144+00	2024-02-16 00:19:39.144+00	Otwj7uJwjr	rT0UCBK1bE	2	2	3	1	3	\N	\N
xrGtUN2WsH	2024-02-16 00:19:39.356+00	2024-02-16 00:19:39.356+00	VshUk7eBeK	RBRcyltRSC	1	1	2	4	0	\N	\N
sxKsozHsGK	2024-02-16 00:19:39.609+00	2024-02-16 00:19:39.609+00	iWxl9obi8w	INeptnSdJC	4	3	0	1	4	\N	\N
PBpVAlGXej	2024-02-16 00:19:39.819+00	2024-02-16 00:19:39.819+00	sy1HD51LXT	j0dWqP2C2A	0	4	2	0	2	\N	\N
XGqbdtOpvD	2024-02-16 00:19:40.029+00	2024-02-16 00:19:40.029+00	Otwj7uJwjr	bi1IivsuUB	4	4	2	4	4	\N	\N
AYlStBRBgd	2024-02-16 00:19:40.239+00	2024-02-16 00:19:40.239+00	Otwj7uJwjr	3u4B9V4l5K	4	4	3	2	3	\N	\N
gW4a1WuTdL	2024-02-16 00:19:40.448+00	2024-02-16 00:19:40.448+00	HRhGpJpmb5	OQWu2bnHeC	3	4	3	4	4	\N	\N
hhExRhxA3K	2024-02-16 00:19:40.661+00	2024-02-16 00:19:40.661+00	HRhGpJpmb5	8w7i8C3NnT	0	2	0	3	1	\N	\N
qhLUMVSeyJ	2024-02-16 00:19:40.873+00	2024-02-16 00:19:40.873+00	I5RzFRcQ7G	RkhjIQJgou	1	2	3	0	3	\N	\N
puAGdHqLJe	2024-02-16 00:19:41.089+00	2024-02-16 00:19:41.089+00	mQXQWNqxg9	cFtamPA0zH	2	4	0	0	0	\N	\N
5Q17b7v7Mk	2024-02-16 00:19:41.302+00	2024-02-16 00:19:41.302+00	R2CLtFh5jU	AgU9OLJkqz	1	4	3	4	1	\N	\N
ujgolz87NQ	2024-02-16 00:19:41.957+00	2024-02-16 00:19:41.957+00	RWwLSzreG2	axyV0Fu7pm	1	1	1	4	4	\N	\N
z4axIOgz6E	2024-02-16 00:19:42.157+00	2024-02-16 00:19:42.157+00	adE9nQrDk3	Pa0qBO2rzK	3	3	2	3	2	\N	\N
Yh2t5ke8t6	2024-02-16 00:19:42.365+00	2024-02-16 00:19:42.365+00	opW2wQ2bZ8	jHqCpA1nWb	2	1	2	0	4	\N	\N
hxCF1XQQwk	2024-02-16 00:19:42.582+00	2024-02-16 00:19:42.582+00	1as6rMOzjQ	JLhF4VuByh	4	0	0	1	0	\N	\N
Gzm9k59kVz	2024-02-16 00:19:43.189+00	2024-02-16 00:19:43.189+00	AsrLUQwxI9	LDrIH1vU8x	4	1	1	0	1	\N	\N
msOruYqJfy	2024-02-16 00:19:43.4+00	2024-02-16 00:19:43.4+00	iWxl9obi8w	XwszrNEEEj	0	3	3	2	1	\N	\N
Xo5Y03HBDh	2024-02-16 00:19:43.606+00	2024-02-16 00:19:43.606+00	sy1HD51LXT	XSK814B37m	2	3	0	3	3	\N	\N
X6CmNb7ETm	2024-02-16 00:19:43.816+00	2024-02-16 00:19:43.816+00	SFAISec8QF	HXtEwLBC7f	0	3	1	3	3	\N	\N
z5b4a7ZFGU	2024-02-16 00:19:44.024+00	2024-02-16 00:19:44.024+00	dZKm0wOhYa	mMYg4cyd5R	0	2	3	0	3	\N	\N
AcJwr6rraB	2024-02-16 00:19:44.234+00	2024-02-16 00:19:44.234+00	SFAISec8QF	y4RkaDbkec	2	1	4	4	0	\N	\N
s4ej5fjG8B	2024-02-16 00:19:44.444+00	2024-02-16 00:19:44.444+00	AsrLUQwxI9	9GF3y7LmHV	4	1	2	3	3	\N	\N
u3UQyMvDyd	2024-02-16 00:19:44.659+00	2024-02-16 00:19:44.659+00	iWxl9obi8w	TpGyMZM9BG	1	4	0	3	2	\N	\N
fJACJItNQX	2024-02-16 00:19:44.934+00	2024-02-16 00:19:44.934+00	5X202ssb0D	Gl96vGdYHM	3	1	0	4	4	\N	\N
DEdGpXZhz0	2024-02-16 00:19:45.146+00	2024-02-16 00:19:45.146+00	9223vtvaBd	jHqCpA1nWb	3	3	0	3	3	\N	\N
q1MoANzMko	2024-02-16 00:19:45.358+00	2024-02-16 00:19:45.358+00	VshUk7eBeK	RkhjIQJgou	4	4	4	0	3	\N	\N
mln7VKRLzg	2024-02-16 00:19:45.571+00	2024-02-16 00:19:45.571+00	RWwLSzreG2	H40ivltLwZ	1	0	4	4	4	\N	\N
rc10DhIWFa	2024-02-16 00:19:45.784+00	2024-02-16 00:19:45.784+00	RWwLSzreG2	fwLPZZ8YQa	1	4	3	1	2	\N	\N
uULzHa4kt5	2024-02-16 00:19:46.059+00	2024-02-16 00:19:46.059+00	Otwj7uJwjr	6KvFK8yy1q	3	2	1	4	2	\N	\N
8zXdLU4Cy0	2024-02-16 00:19:46.366+00	2024-02-16 00:19:46.366+00	dEqAHvPMXA	6Fo67rhTSP	1	0	4	4	4	\N	\N
ljhjn7lGTM	2024-02-16 00:19:46.674+00	2024-02-16 00:19:46.674+00	sHiqaG4iqY	Gl96vGdYHM	2	2	2	1	1	\N	\N
o2eJv5LHWh	2024-02-16 00:19:46.886+00	2024-02-16 00:19:46.886+00	iUlyHNFGpG	bQ0JOk10eL	2	3	0	0	2	\N	\N
VCIRf0M6jg	2024-02-16 00:19:47.099+00	2024-02-16 00:19:47.099+00	mQXQWNqxg9	oABNR2FF6S	0	4	0	4	0	\N	\N
dsL9AahgCY	2024-02-16 00:19:47.311+00	2024-02-16 00:19:47.311+00	AsrLUQwxI9	WBFeKac0OO	1	0	1	0	3	\N	\N
jkfmtfDGDu	2024-02-16 00:19:47.522+00	2024-02-16 00:19:47.522+00	opW2wQ2bZ8	TCkiw6gTDz	1	0	1	2	0	\N	\N
IfMaSXvkj6	2024-02-16 00:19:48.107+00	2024-02-16 00:19:48.107+00	sHiqaG4iqY	INeptnSdJC	1	3	0	0	4	\N	\N
SzDf0CPLFv	2024-02-16 00:19:48.318+00	2024-02-16 00:19:48.318+00	5nv19u6KJ2	tCIEnLLcUc	4	4	4	3	4	\N	\N
ohRCA1BCrM	2024-02-16 00:19:48.535+00	2024-02-16 00:19:48.535+00	jqDYoPT45X	M0tHrt1GgV	4	1	4	4	2	\N	\N
DDBXeml1qA	2024-02-16 00:19:48.748+00	2024-02-16 00:19:48.748+00	R2CLtFh5jU	KCsJ4XR6Dn	4	4	2	3	1	\N	\N
KUC30ZkD88	2024-02-16 00:19:48.958+00	2024-02-16 00:19:48.958+00	9223vtvaBd	VK3vnSxIy8	4	0	4	0	4	\N	\N
TFyvBAuBJK	2024-02-16 00:19:49.234+00	2024-02-16 00:19:49.234+00	opW2wQ2bZ8	o90lhsZ7FK	0	1	1	1	0	\N	\N
crJf5BEApL	2024-02-16 00:19:49.542+00	2024-02-16 00:19:49.542+00	HRhGpJpmb5	cmxBcanww9	4	0	2	2	2	\N	\N
OQyLRGbH5B	2024-02-16 00:19:49.752+00	2024-02-16 00:19:49.752+00	Otwj7uJwjr	cFtamPA0zH	1	4	0	2	1	\N	\N
WhRpsNlRFk	2024-02-16 00:19:49.962+00	2024-02-16 00:19:49.962+00	5nv19u6KJ2	u5FXeeOChJ	3	2	0	3	4	\N	\N
F3BAqsQzX6	2024-02-16 00:19:50.174+00	2024-02-16 00:19:50.174+00	1as6rMOzjQ	uABtFsJhJc	3	0	4	3	0	\N	\N
ycC7cB8969	2024-02-16 00:19:50.463+00	2024-02-16 00:19:50.463+00	ONgyydfVNz	D0A6GLdsDM	1	1	1	1	0	\N	\N
JmbYK4pM1L	2024-02-16 00:19:50.676+00	2024-02-16 00:19:50.676+00	WKpBp0c8F3	H40ivltLwZ	0	1	1	1	0	\N	\N
MxLe8WrVE2	2024-02-16 00:19:50.888+00	2024-02-16 00:19:50.888+00	SFAISec8QF	JRi61dUphq	1	2	3	4	4	\N	\N
ogM1lqzPLA	2024-02-16 00:19:51.1+00	2024-02-16 00:19:51.1+00	R2CLtFh5jU	HSEugQ3Ouj	2	3	0	2	3	\N	\N
G3B5f4Dnq2	2024-02-16 00:19:51.693+00	2024-02-16 00:19:51.693+00	dEqAHvPMXA	08liHW08uC	1	1	4	2	3	\N	\N
9fTpzVTMY8	2024-02-16 00:19:51.9+00	2024-02-16 00:19:51.9+00	WKpBp0c8F3	qP3EdIVzfB	4	1	1	0	3	\N	\N
FIOs2dGDeC	2024-02-16 00:19:52.106+00	2024-02-16 00:19:52.106+00	NjxsGlPeB4	M0tHrt1GgV	2	3	0	0	3	\N	\N
tdzPgsyHwg	2024-02-16 00:19:52.315+00	2024-02-16 00:19:52.315+00	WKpBp0c8F3	HXtEwLBC7f	0	1	2	0	4	\N	\N
GcPWaiCKKU	2024-02-16 00:19:52.526+00	2024-02-16 00:19:52.526+00	I5RzFRcQ7G	Gl96vGdYHM	0	3	3	0	3	\N	\N
Liy8Y1tSgi	2024-02-16 00:19:52.735+00	2024-02-16 00:19:52.735+00	R2CLtFh5jU	uigc7bJBOJ	2	1	4	2	1	\N	\N
AL3JCiK9h3	2024-02-16 00:19:52.947+00	2024-02-16 00:19:52.947+00	dZKm0wOhYa	m6g8u0QpTC	2	1	0	2	1	\N	\N
NCuwAWB6Yd	2024-02-16 00:19:53.162+00	2024-02-16 00:19:53.162+00	jqDYoPT45X	BMLzFMvIT6	2	3	3	2	4	\N	\N
i5K66E9EoW	2024-02-16 00:19:53.432+00	2024-02-16 00:19:53.432+00	dEqAHvPMXA	eEmewy7hPd	3	4	4	4	1	\N	\N
3J5YVQAjE1	2024-02-16 00:19:53.647+00	2024-02-16 00:19:53.647+00	mQXQWNqxg9	NY6RE1qgWu	2	4	0	1	4	\N	\N
3lsfQPWIey	2024-02-16 00:19:53.863+00	2024-02-16 00:19:53.863+00	VshUk7eBeK	rKyjwoEIRp	1	3	4	1	1	\N	\N
iTX7vNZvHZ	2024-02-16 00:19:54.15+00	2024-02-16 00:19:54.15+00	sHiqaG4iqY	G0uU7KQLEt	1	3	0	3	0	\N	\N
8VFJvMmnEh	2024-02-16 00:19:54.364+00	2024-02-16 00:19:54.364+00	SFAISec8QF	XwszrNEEEj	4	1	2	1	4	\N	\N
dcAHHCn1iv	2024-02-16 00:19:54.576+00	2024-02-16 00:19:54.576+00	iUlyHNFGpG	rT0UCBK1bE	0	1	3	2	1	\N	\N
M6cpWh4J7z	2024-02-16 00:19:54.867+00	2024-02-16 00:19:54.867+00	RWwLSzreG2	m6g8u0QpTC	2	1	1	2	3	\N	\N
Jd4CpSCFjf	2024-02-16 00:19:55.079+00	2024-02-16 00:19:55.079+00	AsrLUQwxI9	qP3EdIVzfB	1	2	1	2	3	\N	\N
jtuQureE0o	2024-02-16 00:19:55.289+00	2024-02-16 00:19:55.289+00	opW2wQ2bZ8	uigc7bJBOJ	0	0	2	2	3	\N	\N
mE1Ik2gEkS	2024-02-16 00:19:55.502+00	2024-02-16 00:19:55.502+00	sHiqaG4iqY	FYXEfIO1zF	0	3	2	3	2	\N	\N
cdpfcPIjiB	2024-02-16 00:19:55.717+00	2024-02-16 00:19:55.717+00	NjxsGlPeB4	axyV0Fu7pm	4	0	3	3	3	\N	\N
oogzQuMDph	2024-02-16 00:19:55.933+00	2024-02-16 00:19:55.933+00	HtEtaHBVDN	XSK814B37m	1	1	1	1	0	\N	\N
0Zyv0y6lYa	2024-02-16 00:19:56.607+00	2024-02-16 00:19:56.607+00	1as6rMOzjQ	AgU9OLJkqz	4	4	3	0	4	\N	\N
iHMj8yEPww	2024-02-16 00:19:56.809+00	2024-02-16 00:19:56.809+00	adE9nQrDk3	CSvk1ycWXk	2	0	2	4	2	\N	\N
NvBvy137k1	2024-02-16 00:19:57.015+00	2024-02-16 00:19:57.015+00	sy1HD51LXT	CSvk1ycWXk	2	0	0	1	4	\N	\N
aztGn4FkFR	2024-02-16 00:19:57.224+00	2024-02-16 00:19:57.224+00	9223vtvaBd	uigc7bJBOJ	2	4	0	3	3	\N	\N
CA8SgIdc0p	2024-02-16 00:19:57.43+00	2024-02-16 00:19:57.43+00	sHiqaG4iqY	axyV0Fu7pm	0	1	0	1	4	\N	\N
c8Mx765u3G	2024-02-16 00:19:57.643+00	2024-02-16 00:19:57.643+00	mQXQWNqxg9	rT0UCBK1bE	1	3	2	1	2	\N	\N
xoUmahBJJa	2024-02-16 00:19:57.939+00	2024-02-16 00:19:57.939+00	sy1HD51LXT	o90lhsZ7FK	0	1	1	0	4	\N	\N
XppP9ujFOt	2024-02-16 00:19:58.15+00	2024-02-16 00:19:58.15+00	I5RzFRcQ7G	XSK814B37m	4	1	4	4	4	\N	\N
202cvD9m3E	2024-02-16 00:19:58.36+00	2024-02-16 00:19:58.36+00	iWxl9obi8w	TpGyMZM9BG	2	0	4	4	0	\N	\N
EEl9eCq4QU	2024-02-16 00:19:58.656+00	2024-02-16 00:19:58.656+00	iUlyHNFGpG	yvUod6yLDt	4	2	4	1	1	\N	\N
F9L7XGs2vX	2024-02-16 00:19:58.963+00	2024-02-16 00:19:58.963+00	mQXQWNqxg9	Gl96vGdYHM	4	0	4	3	0	\N	\N
wyrbJ29HeR	2024-02-16 00:19:59.173+00	2024-02-16 00:19:59.173+00	HRhGpJpmb5	HLIPwAqO2R	0	4	1	2	4	\N	\N
TAbOlWjsgO	2024-02-16 00:19:59.393+00	2024-02-16 00:19:59.393+00	sy1HD51LXT	jHqCpA1nWb	3	0	3	3	3	\N	\N
q4lT70GOs7	2024-02-16 00:19:59.603+00	2024-02-16 00:19:59.603+00	iWxl9obi8w	LVYK4mLShP	4	1	1	1	1	\N	\N
cDePd4Lk9I	2024-02-16 00:19:59.813+00	2024-02-16 00:19:59.813+00	iWxl9obi8w	NBojpORh3G	4	3	4	2	0	\N	\N
qvrYeeeyBD	2024-02-16 00:20:00.09+00	2024-02-16 00:20:00.09+00	sy1HD51LXT	eEmewy7hPd	3	3	4	0	4	\N	\N
d4cmOCnOKQ	2024-02-16 00:20:00.305+00	2024-02-16 00:20:00.305+00	opW2wQ2bZ8	HLIPwAqO2R	3	1	4	4	0	\N	\N
G927m0S5ce	2024-02-16 00:20:00.602+00	2024-02-16 00:20:00.602+00	ONgyydfVNz	IybX0eBoO3	4	1	3	0	4	\N	\N
yeJkRTBHGY	2024-02-16 00:20:01.217+00	2024-02-16 00:20:01.217+00	I5RzFRcQ7G	M0tHrt1GgV	2	3	1	4	2	\N	\N
ea7DVtn5TO	2024-02-16 00:20:01.429+00	2024-02-16 00:20:01.429+00	HtEtaHBVDN	o90lhsZ7FK	4	4	2	2	1	\N	\N
xKHpiJ5leF	2024-02-16 00:20:01.635+00	2024-02-16 00:20:01.635+00	jqDYoPT45X	G0uU7KQLEt	4	3	1	3	2	\N	\N
21DmJW2KaZ	2024-02-16 00:20:01.84+00	2024-02-16 00:20:01.84+00	sy1HD51LXT	08liHW08uC	3	4	4	2	1	\N	\N
xcxGh2V8Ge	2024-02-16 00:20:02.44+00	2024-02-16 00:20:02.44+00	VshUk7eBeK	LVYK4mLShP	4	0	4	3	3	\N	\N
4IaVBXGxuu	2024-02-16 00:20:02.646+00	2024-02-16 00:20:02.646+00	adE9nQrDk3	IybX0eBoO3	1	4	4	1	0	\N	\N
Cy8sLIzOnK	2024-02-16 00:20:02.857+00	2024-02-16 00:20:02.857+00	adE9nQrDk3	AgU9OLJkqz	4	1	3	1	1	\N	\N
KZNB4RezXJ	2024-02-16 00:20:03.158+00	2024-02-16 00:20:03.158+00	S6wz0lK0bf	WHvlAGgj6c	4	4	3	4	2	\N	\N
zmiEB3p0Bo	2024-02-16 00:20:03.774+00	2024-02-16 00:20:03.774+00	mQXQWNqxg9	qEQ9tmLyW9	1	0	4	1	2	\N	\N
HPHSe2HNXc	2024-02-16 00:20:04.386+00	2024-02-16 00:20:04.386+00	R2CLtFh5jU	fxvABtKCPT	0	0	2	1	3	\N	\N
TUEyvolbVl	2024-02-16 00:20:04.59+00	2024-02-16 00:20:04.59+00	NjxsGlPeB4	LDrIH1vU8x	4	2	3	2	3	\N	\N
e2BemdBEj9	2024-02-16 00:20:04.797+00	2024-02-16 00:20:04.797+00	mQXQWNqxg9	6Fo67rhTSP	2	3	3	0	2	\N	\N
BLDMdVrukO	2024-02-16 00:20:05.008+00	2024-02-16 00:20:05.008+00	R2CLtFh5jU	MQfxuw3ERg	4	0	4	0	4	\N	\N
GcOHebcstL	2024-02-16 00:20:05.217+00	2024-02-16 00:20:05.217+00	5X202ssb0D	HXtEwLBC7f	1	1	3	2	0	\N	\N
bog2m9MJP5	2024-02-16 00:20:05.515+00	2024-02-16 00:20:05.515+00	dZKm0wOhYa	HLIPwAqO2R	0	0	3	0	1	\N	\N
vgVFyiU1MZ	2024-02-16 00:20:05.726+00	2024-02-16 00:20:05.726+00	adE9nQrDk3	6Fo67rhTSP	3	2	2	2	4	\N	\N
2OyuSQZEz7	2024-02-16 00:20:05.933+00	2024-02-16 00:20:05.933+00	adE9nQrDk3	RkhjIQJgou	2	1	2	1	3	\N	\N
6wiSpbAp3r	2024-02-16 00:20:06.136+00	2024-02-16 00:20:06.136+00	WKpBp0c8F3	Gl96vGdYHM	3	1	1	2	3	\N	\N
MyQyXGuPGQ	2024-02-16 00:20:06.343+00	2024-02-16 00:20:06.343+00	sy1HD51LXT	VK3vnSxIy8	3	0	4	0	1	\N	\N
6tD3glGUKE	2024-02-16 00:20:06.553+00	2024-02-16 00:20:06.553+00	sHiqaG4iqY	XwszrNEEEj	1	4	1	0	3	\N	\N
dmj5m3IaMM	2024-02-16 00:20:06.765+00	2024-02-16 00:20:06.765+00	SFAISec8QF	14jGmOAXcg	3	3	0	0	2	\N	\N
Y8WgCRg7cA	2024-02-16 00:20:06.976+00	2024-02-16 00:20:06.976+00	SFAISec8QF	bQpy9LEJWn	1	3	2	3	2	\N	\N
8uXVq6BQqB	2024-02-16 00:20:07.185+00	2024-02-16 00:20:07.185+00	NjxsGlPeB4	cmxBcanww9	4	2	0	1	3	\N	\N
OXZa7JkWtZ	2024-02-16 00:20:07.395+00	2024-02-16 00:20:07.395+00	ONgyydfVNz	fxvABtKCPT	1	4	0	0	0	\N	\N
heDAQrDgGX	2024-02-16 00:20:07.611+00	2024-02-16 00:20:07.611+00	NjxsGlPeB4	JRi61dUphq	1	2	3	3	2	\N	\N
GPfiBL6fr2	2024-02-16 00:20:07.824+00	2024-02-16 00:20:07.824+00	HtEtaHBVDN	TCkiw6gTDz	4	1	1	3	4	\N	\N
ZEmQD1MZMP	2024-02-16 00:20:08.48+00	2024-02-16 00:20:08.48+00	mAKp5BK7R1	vwHi602n66	1	1	3	4	4	\N	\N
fZjG1ZIhVt	2024-02-16 00:20:08.689+00	2024-02-16 00:20:08.689+00	iUlyHNFGpG	89xRG1afNi	2	2	4	0	0	\N	\N
vBZi66lQvR	2024-02-16 00:20:08.903+00	2024-02-16 00:20:08.903+00	HRhGpJpmb5	C7II8dYRPY	1	0	2	3	0	\N	\N
qpftg4ULo5	2024-02-16 00:20:09.114+00	2024-02-16 00:20:09.114+00	mAKp5BK7R1	6Fo67rhTSP	4	2	1	0	1	\N	\N
5BCpOHT7iM	2024-02-16 00:20:09.329+00	2024-02-16 00:20:09.329+00	I5RzFRcQ7G	j0dWqP2C2A	3	1	1	1	1	\N	\N
FNABZULDFD	2024-02-16 00:20:09.545+00	2024-02-16 00:20:09.545+00	dEqAHvPMXA	JRi61dUphq	1	4	1	0	3	\N	\N
YoQbGOpbZP	2024-02-16 00:20:09.82+00	2024-02-16 00:20:09.82+00	dZKm0wOhYa	XpUyRlB6FI	2	4	4	0	4	\N	\N
iN98KHJBCj	2024-02-16 00:20:10.037+00	2024-02-16 00:20:10.037+00	sHiqaG4iqY	XpUyRlB6FI	3	2	2	4	0	\N	\N
sDh23utBCT	2024-02-16 00:20:10.247+00	2024-02-16 00:20:10.247+00	NjxsGlPeB4	m6g8u0QpTC	1	2	0	2	4	\N	\N
jlWWcCzG8I	2024-02-16 00:20:10.456+00	2024-02-16 00:20:10.456+00	sHiqaG4iqY	jHqCpA1nWb	3	4	2	3	4	\N	\N
OpxsMBkPnm	2024-02-16 00:20:10.661+00	2024-02-16 00:20:10.661+00	SFAISec8QF	HSEugQ3Ouj	4	0	0	4	1	\N	\N
CsRexGixyp	2024-02-16 00:20:10.874+00	2024-02-16 00:20:10.874+00	HtEtaHBVDN	rKyjwoEIRp	1	1	4	1	1	\N	\N
oAKRZhuOFp	2024-02-16 00:20:11.454+00	2024-02-16 00:20:11.454+00	jqDYoPT45X	e037qpAih3	1	1	1	4	0	\N	\N
pTsVsAXfu0	2024-02-16 00:20:11.662+00	2024-02-16 00:20:11.662+00	5X202ssb0D	E2hBZzDsjO	3	3	1	0	1	\N	\N
6sIdmg6M0V	2024-02-16 00:20:11.873+00	2024-02-16 00:20:11.873+00	R2CLtFh5jU	WHvlAGgj6c	1	3	0	4	0	\N	\N
lqU2yNXTZ7	2024-02-16 00:20:12.172+00	2024-02-16 00:20:12.172+00	opW2wQ2bZ8	l1Bslv8T2k	1	3	0	3	4	\N	\N
USnEyhRCaM	2024-02-16 00:20:12.385+00	2024-02-16 00:20:12.385+00	iUlyHNFGpG	m8hjjLVdPS	2	3	2	2	0	\N	\N
1sJrJmvaR3	2024-02-16 00:20:12.595+00	2024-02-16 00:20:12.595+00	AsrLUQwxI9	TpGyMZM9BG	0	4	2	1	3	\N	\N
3aDpA7UrZ0	2024-02-16 00:20:12.809+00	2024-02-16 00:20:12.809+00	mAKp5BK7R1	MQfxuw3ERg	3	0	0	4	3	\N	\N
9bMtdZvLAV	2024-02-16 00:20:13.023+00	2024-02-16 00:20:13.023+00	HtEtaHBVDN	TpGyMZM9BG	2	1	0	3	4	\N	\N
L4wz2Otmfk	2024-02-16 00:20:13.233+00	2024-02-16 00:20:13.233+00	R2CLtFh5jU	vwHi602n66	0	4	1	0	3	\N	\N
1VHEOjrZiH	2024-02-16 00:20:13.443+00	2024-02-16 00:20:13.443+00	sHiqaG4iqY	fxvABtKCPT	1	0	1	3	3	\N	\N
SWA0eBk1e0	2024-02-16 00:20:13.654+00	2024-02-16 00:20:13.654+00	NjxsGlPeB4	IEqTHcohpJ	2	1	1	0	3	\N	\N
GeukZA9r5E	2024-02-16 00:20:13.865+00	2024-02-16 00:20:13.865+00	R2CLtFh5jU	0TvWuLoLF5	1	3	1	4	0	\N	\N
7jUvsHkFhS	2024-02-16 00:20:14.12+00	2024-02-16 00:20:14.12+00	Otwj7uJwjr	yvUod6yLDt	4	3	0	3	4	\N	\N
BoJIEnBcTN	2024-02-16 00:20:14.428+00	2024-02-16 00:20:14.428+00	HtEtaHBVDN	Gl96vGdYHM	3	3	1	1	0	\N	\N
ECf49mBDxD	2024-02-16 00:20:14.641+00	2024-02-16 00:20:14.641+00	R2CLtFh5jU	ThMuD3hYRQ	2	2	4	1	4	\N	\N
WhLl6shmFx	2024-02-16 00:20:14.851+00	2024-02-16 00:20:14.851+00	ONgyydfVNz	H40ivltLwZ	0	4	4	1	0	\N	\N
mU01hbEXZE	2024-02-16 00:20:15.065+00	2024-02-16 00:20:15.065+00	AsrLUQwxI9	NBojpORh3G	1	1	3	2	3	\N	\N
6ggD8dYoxg	2024-02-16 00:20:15.278+00	2024-02-16 00:20:15.278+00	SFAISec8QF	NY6RE1qgWu	2	4	3	0	4	\N	\N
KpHzIbObDu	2024-02-16 00:20:15.553+00	2024-02-16 00:20:15.553+00	5X202ssb0D	qZmnAnnPEb	1	4	1	3	4	\N	\N
BdPs69XVdh	2024-02-16 00:20:15.861+00	2024-02-16 00:20:15.861+00	RWwLSzreG2	o90lhsZ7FK	4	2	2	3	0	\N	\N
h4O17xzsJS	2024-02-16 00:20:16.159+00	2024-02-16 00:20:16.159+00	HtEtaHBVDN	LVYK4mLShP	1	4	1	4	0	\N	\N
rYJ9pLLjR3	2024-02-16 00:20:16.371+00	2024-02-16 00:20:16.371+00	mAKp5BK7R1	08liHW08uC	0	1	1	0	0	\N	\N
fuiRmDR5cz	2024-02-16 00:20:16.68+00	2024-02-16 00:20:16.68+00	I5RzFRcQ7G	NBojpORh3G	3	0	3	0	0	\N	\N
9krBuGrq9n	2024-02-16 00:20:16.99+00	2024-02-16 00:20:16.99+00	adE9nQrDk3	Pa0qBO2rzK	4	1	2	2	3	\N	\N
OV38ttfeQB	2024-02-16 00:20:17.2+00	2024-02-16 00:20:17.2+00	HRhGpJpmb5	M0tHrt1GgV	1	0	3	4	1	\N	\N
RfLZfIOk5r	2024-02-16 00:20:17.409+00	2024-02-16 00:20:17.409+00	9223vtvaBd	LVYK4mLShP	2	2	0	2	2	\N	\N
Wh6wceVO7A	2024-02-16 00:20:17.621+00	2024-02-16 00:20:17.621+00	1as6rMOzjQ	bi1IivsuUB	0	4	4	1	3	\N	\N
Ot9VcGeLky	2024-02-16 00:20:17.835+00	2024-02-16 00:20:17.835+00	1as6rMOzjQ	HXtEwLBC7f	3	4	4	0	3	\N	\N
2Xo7Et5A05	2024-02-16 00:20:18.048+00	2024-02-16 00:20:18.048+00	ONgyydfVNz	89xRG1afNi	2	1	2	2	0	\N	\N
0Ha015mTnl	2024-02-16 00:20:18.728+00	2024-02-16 00:20:18.728+00	HtEtaHBVDN	j0dWqP2C2A	0	1	0	0	0	\N	\N
jR8pvrlVII	2024-02-16 00:20:18.937+00	2024-02-16 00:20:18.937+00	mAKp5BK7R1	qP3EdIVzfB	4	0	0	2	0	\N	\N
MbhjRO0fGc	2024-02-16 00:20:19.147+00	2024-02-16 00:20:19.147+00	dZKm0wOhYa	P9sBFomftT	1	3	3	1	3	\N	\N
cabM4PkeOZ	2024-02-16 00:20:19.359+00	2024-02-16 00:20:19.359+00	adE9nQrDk3	M0tHrt1GgV	0	1	0	2	3	\N	\N
f35M6d0xEs	2024-02-16 00:20:19.569+00	2024-02-16 00:20:19.569+00	mQXQWNqxg9	o4VD4BWwDt	4	2	0	1	3	\N	\N
2PNPk3rDTT	2024-02-16 00:20:19.778+00	2024-02-16 00:20:19.778+00	HRhGpJpmb5	lEPdiO1EDi	4	2	2	2	3	\N	\N
bq4YSpAVYU	2024-02-16 00:20:20.061+00	2024-02-16 00:20:20.061+00	SFAISec8QF	bQ0JOk10eL	2	0	3	2	2	\N	\N
gW0bQ4gFLs	2024-02-16 00:20:20.271+00	2024-02-16 00:20:20.271+00	mAKp5BK7R1	cTIjuPjyIa	3	0	2	2	4	\N	\N
fq6nlKAhIw	2024-02-16 00:20:20.572+00	2024-02-16 00:20:20.572+00	1as6rMOzjQ	uigc7bJBOJ	3	2	0	2	0	\N	\N
rvuiNyj5CM	2024-02-16 00:20:20.783+00	2024-02-16 00:20:20.783+00	S6wz0lK0bf	o4VD4BWwDt	1	3	4	3	4	\N	\N
AEnkQKHLSa	2024-02-16 00:20:20.999+00	2024-02-16 00:20:20.999+00	mAKp5BK7R1	Pja6n3yaWZ	1	0	1	4	2	\N	\N
c3lm2K026f	2024-02-16 00:20:21.205+00	2024-02-16 00:20:21.205+00	sHiqaG4iqY	3u4B9V4l5K	3	4	0	4	3	\N	\N
1nBxuN43vY	2024-02-16 00:20:21.415+00	2024-02-16 00:20:21.415+00	sHiqaG4iqY	y4RkaDbkec	2	1	2	3	2	\N	\N
s0XittU4cN	2024-02-16 00:20:21.628+00	2024-02-16 00:20:21.628+00	dEqAHvPMXA	cTIjuPjyIa	2	2	1	4	4	\N	\N
AlELe8hapn	2024-02-16 00:20:21.903+00	2024-02-16 00:20:21.903+00	SFAISec8QF	tCIEnLLcUc	0	0	4	0	0	\N	\N
Q46MlFRmQv	2024-02-16 00:20:22.516+00	2024-02-16 00:20:22.516+00	5nv19u6KJ2	rT0UCBK1bE	4	3	4	0	1	\N	\N
vwVUQXbqBe	2024-02-16 00:20:22.724+00	2024-02-16 00:20:22.724+00	adE9nQrDk3	6Fo67rhTSP	3	3	2	2	4	\N	\N
exCTyrS4Vp	2024-02-16 00:20:22.931+00	2024-02-16 00:20:22.931+00	mQXQWNqxg9	tCIEnLLcUc	4	0	2	0	4	\N	\N
jyxuBPDFQp	2024-02-16 00:20:23.138+00	2024-02-16 00:20:23.138+00	WKpBp0c8F3	bi1IivsuUB	2	2	2	3	2	\N	\N
fhpM4VpaaV	2024-02-16 00:20:23.348+00	2024-02-16 00:20:23.348+00	5nv19u6KJ2	TCkiw6gTDz	3	3	3	0	1	\N	\N
Ooh5LObsfk	2024-02-16 00:20:23.557+00	2024-02-16 00:20:23.557+00	dZKm0wOhYa	JLhF4VuByh	3	3	3	2	2	\N	\N
F67S7zAc6P	2024-02-16 00:20:24.153+00	2024-02-16 00:20:24.153+00	RWwLSzreG2	m6g8u0QpTC	2	2	1	3	0	\N	\N
O1u55RohOR	2024-02-16 00:20:24.36+00	2024-02-16 00:20:24.36+00	Otwj7uJwjr	OQWu2bnHeC	1	4	2	0	2	\N	\N
orYhOTc2u4	2024-02-16 00:20:24.572+00	2024-02-16 00:20:24.572+00	adE9nQrDk3	9GF3y7LmHV	1	3	0	2	1	\N	\N
kpgaUdIcYR	2024-02-16 00:20:24.782+00	2024-02-16 00:20:24.782+00	sHiqaG4iqY	9GF3y7LmHV	2	0	0	0	0	\N	\N
aWEEnyGDqp	2024-02-16 00:20:25.077+00	2024-02-16 00:20:25.077+00	iUlyHNFGpG	oABNR2FF6S	4	1	0	4	0	\N	\N
XzgHWgA05S	2024-02-16 00:20:25.289+00	2024-02-16 00:20:25.289+00	opW2wQ2bZ8	axyV0Fu7pm	1	2	1	4	4	\N	\N
LdeW2Mdhxq	2024-02-16 00:20:25.692+00	2024-02-16 00:20:25.692+00	S6wz0lK0bf	fKTSJPdUi9	4	3	1	1	3	\N	\N
RBUmx7q9FP	2024-02-16 00:20:25.907+00	2024-02-16 00:20:25.907+00	VshUk7eBeK	XSK814B37m	1	1	2	4	2	\N	\N
XJstbiYBil	2024-02-16 00:20:26.118+00	2024-02-16 00:20:26.118+00	Otwj7uJwjr	oABNR2FF6S	0	0	0	0	0	\N	\N
8aqH5fQvzd	2024-02-16 00:20:26.329+00	2024-02-16 00:20:26.329+00	opW2wQ2bZ8	JLhF4VuByh	1	3	1	0	0	\N	\N
XEEIKGi1VZ	2024-02-16 00:20:26.613+00	2024-02-16 00:20:26.613+00	SFAISec8QF	RBRcyltRSC	1	3	0	2	2	\N	\N
O2GgrGrUn4	2024-02-16 00:20:26.92+00	2024-02-16 00:20:26.92+00	WKpBp0c8F3	cFtamPA0zH	4	0	2	4	3	\N	\N
5fbFeRXwKA	2024-02-16 00:20:27.23+00	2024-02-16 00:20:27.23+00	mQXQWNqxg9	tCIEnLLcUc	1	0	4	0	3	\N	\N
jBT1ijnAKW	2024-02-16 00:20:27.837+00	2024-02-16 00:20:27.837+00	5nv19u6KJ2	LVYK4mLShP	1	3	2	0	1	\N	\N
CcVrY3dWCa	2024-02-16 00:20:28.039+00	2024-02-16 00:20:28.039+00	VshUk7eBeK	o90lhsZ7FK	2	2	0	4	1	\N	\N
r12HTAbP79	2024-02-16 00:20:28.245+00	2024-02-16 00:20:28.245+00	5X202ssb0D	o90lhsZ7FK	3	4	3	2	4	\N	\N
UzdzbOIiSm	2024-02-16 00:20:28.455+00	2024-02-16 00:20:28.455+00	opW2wQ2bZ8	UDXF0qXvDY	3	3	4	4	3	\N	\N
7kLW6ZKTNT	2024-02-16 00:20:28.666+00	2024-02-16 00:20:28.666+00	9223vtvaBd	mMYg4cyd5R	0	4	2	1	3	\N	\N
AHdwbbozRL	2024-02-16 00:20:28.878+00	2024-02-16 00:20:28.878+00	S6wz0lK0bf	fwLPZZ8YQa	4	4	3	3	1	\N	\N
iHYlgZSgbL	2024-02-16 00:20:29.174+00	2024-02-16 00:20:29.174+00	adE9nQrDk3	Pja6n3yaWZ	3	0	0	2	1	\N	\N
gO0SSjBNiw	2024-02-16 00:20:29.482+00	2024-02-16 00:20:29.482+00	WKpBp0c8F3	Pja6n3yaWZ	0	2	1	2	1	\N	\N
n3ZWZqwn8i	2024-02-16 00:20:29.786+00	2024-02-16 00:20:29.786+00	adE9nQrDk3	89xRG1afNi	3	0	1	3	2	\N	\N
BPrJb3Xajj	2024-02-16 00:20:29.987+00	2024-02-16 00:20:29.987+00	1as6rMOzjQ	jjVdtithcD	4	4	0	2	3	\N	\N
0Nit4IApgl	2024-02-16 00:20:30.187+00	2024-02-16 00:20:30.187+00	mAKp5BK7R1	WnUBBkiDjE	0	3	2	2	2	\N	\N
x6d3wb23zw	2024-02-16 00:20:30.392+00	2024-02-16 00:20:30.392+00	9223vtvaBd	qEQ9tmLyW9	0	0	0	4	2	\N	\N
rINmTzaCyn	2024-02-16 00:20:30.607+00	2024-02-16 00:20:30.607+00	sHiqaG4iqY	TpGyMZM9BG	2	2	4	1	3	\N	\N
M9S825jAe5	2024-02-16 00:20:30.915+00	2024-02-16 00:20:30.915+00	Otwj7uJwjr	CSvk1ycWXk	4	3	4	0	2	\N	\N
47akSR0ORJ	2024-02-16 00:20:31.215+00	2024-02-16 00:20:31.215+00	HRhGpJpmb5	XwWwGnkXNj	3	3	2	2	4	\N	\N
fTODhECCiz	2024-02-16 00:20:31.847+00	2024-02-16 00:20:31.847+00	AsrLUQwxI9	l1Bslv8T2k	2	3	2	0	0	\N	\N
RlqEyJpjiK	2024-02-16 00:20:32.059+00	2024-02-16 00:20:32.059+00	ONgyydfVNz	LDrIH1vU8x	1	0	1	4	4	\N	\N
CPtU5tGdo4	2024-02-16 00:20:32.266+00	2024-02-16 00:20:32.266+00	sHiqaG4iqY	rKyjwoEIRp	0	1	2	2	4	\N	\N
7lgIeRijR0	2024-02-16 00:20:32.553+00	2024-02-16 00:20:32.553+00	5X202ssb0D	qEQ9tmLyW9	4	2	1	2	1	\N	\N
AvbQVSp7EC	2024-02-16 00:20:32.762+00	2024-02-16 00:20:32.762+00	opW2wQ2bZ8	UCFo58JaaD	2	2	0	3	3	\N	\N
DFeECeNcz3	2024-02-16 00:20:33.066+00	2024-02-16 00:20:33.066+00	dZKm0wOhYa	E2hBZzDsjO	0	3	4	2	0	\N	\N
tNb2ZCzBS9	2024-02-16 00:20:33.279+00	2024-02-16 00:20:33.279+00	HtEtaHBVDN	JLhF4VuByh	0	4	1	3	0	\N	\N
5WpemBQBtw	2024-02-16 00:20:33.811+00	2024-02-16 00:20:33.811+00	mQXQWNqxg9	IybX0eBoO3	4	4	0	2	4	\N	\N
r7j5LeeOzQ	2024-02-16 00:20:34.021+00	2024-02-16 00:20:34.021+00	NjxsGlPeB4	IybX0eBoO3	2	4	1	4	2	\N	\N
GT053BRUVN	2024-02-16 00:20:34.292+00	2024-02-16 00:20:34.292+00	opW2wQ2bZ8	EmIUBFwx0Z	3	1	4	3	0	\N	\N
SxrsFNS43G	2024-02-16 00:20:34.502+00	2024-02-16 00:20:34.502+00	5X202ssb0D	BMLzFMvIT6	0	1	0	2	2	\N	\N
kYBoFyg3eB	2024-02-16 00:20:35.314+00	2024-02-16 00:20:35.314+00	dZKm0wOhYa	8w7i8C3NnT	1	4	4	4	2	\N	\N
aRw3XRwaQD	2024-02-16 00:20:35.519+00	2024-02-16 00:20:35.519+00	sy1HD51LXT	e037qpAih3	1	2	2	3	3	\N	\N
AOcT775xc0	2024-02-16 00:20:35.724+00	2024-02-16 00:20:35.724+00	I5RzFRcQ7G	P9sBFomftT	3	4	4	3	3	\N	\N
c1JGoVnPpk	2024-02-16 00:20:35.931+00	2024-02-16 00:20:35.931+00	dEqAHvPMXA	E2hBZzDsjO	0	0	0	0	3	\N	\N
5VjKeyF6C6	2024-02-16 00:20:36.647+00	2024-02-16 00:20:36.647+00	opW2wQ2bZ8	RBRcyltRSC	4	3	1	4	1	\N	\N
cUqbgt6SrK	2024-02-16 00:20:37.363+00	2024-02-16 00:20:37.363+00	opW2wQ2bZ8	XwszrNEEEj	2	3	2	2	3	\N	\N
EDM9rNNDwo	2024-02-16 00:20:38.078+00	2024-02-16 00:20:38.078+00	VshUk7eBeK	WSTLlXDcKl	3	2	0	1	3	\N	\N
NWABgGoAHI	2024-02-16 00:20:38.282+00	2024-02-16 00:20:38.282+00	I5RzFRcQ7G	RBRcyltRSC	0	3	1	4	0	\N	\N
p8zH9zA0aP	2024-02-16 00:20:38.696+00	2024-02-16 00:20:38.696+00	SFAISec8QF	XpUyRlB6FI	1	1	0	0	2	\N	\N
9gPUGHfgmX	2024-02-16 00:20:39.001+00	2024-02-16 00:20:39.001+00	AsrLUQwxI9	Pa0qBO2rzK	1	0	1	2	0	\N	\N
vOWylicdIE	2024-02-16 00:20:39.207+00	2024-02-16 00:20:39.207+00	S6wz0lK0bf	P9sBFomftT	2	3	1	4	2	\N	\N
vFKtPuQyJY	2024-02-16 00:20:39.418+00	2024-02-16 00:20:39.418+00	1as6rMOzjQ	axyV0Fu7pm	1	4	4	1	2	\N	\N
FI39vX1Nyd	2024-02-16 00:20:39.625+00	2024-02-16 00:20:39.625+00	Otwj7uJwjr	LVYK4mLShP	3	2	3	4	1	\N	\N
ksL4YMHAo7	2024-02-16 00:20:39.829+00	2024-02-16 00:20:39.829+00	adE9nQrDk3	eEmewy7hPd	1	1	1	2	3	\N	\N
vznTQAzuFf	2024-02-16 00:20:40.033+00	2024-02-16 00:20:40.033+00	iUlyHNFGpG	axyV0Fu7pm	0	4	0	3	4	\N	\N
AjCivCu9bP	2024-02-16 00:20:40.241+00	2024-02-16 00:20:40.241+00	1as6rMOzjQ	vwHi602n66	1	3	1	3	2	\N	\N
ajwMVZxfV9	2024-02-16 00:20:40.448+00	2024-02-16 00:20:40.448+00	adE9nQrDk3	14jGmOAXcg	4	3	3	2	3	\N	\N
VDrzsZE5HI	2024-02-16 00:20:40.744+00	2024-02-16 00:20:40.744+00	AsrLUQwxI9	tCIEnLLcUc	3	0	2	2	2	\N	\N
FDXjhdgAAt	2024-02-16 00:20:40.953+00	2024-02-16 00:20:40.953+00	WKpBp0c8F3	XwWwGnkXNj	3	4	2	2	4	\N	\N
9ox7bEX1zR	2024-02-16 00:20:41.256+00	2024-02-16 00:20:41.256+00	HRhGpJpmb5	mMYg4cyd5R	3	1	3	3	3	\N	\N
F3k9mFEjWG	2024-02-16 00:20:41.462+00	2024-02-16 00:20:41.462+00	Otwj7uJwjr	KCsJ4XR6Dn	0	0	4	2	0	\N	\N
EwtQ2UrTrV	2024-02-16 00:20:41.679+00	2024-02-16 00:20:41.679+00	iWxl9obi8w	l1Bslv8T2k	1	2	4	3	3	\N	\N
X1xrtH89zc	2024-02-16 00:20:41.895+00	2024-02-16 00:20:41.895+00	opW2wQ2bZ8	y4RkaDbkec	3	1	2	3	0	\N	\N
XbaI1fIlv9	2024-02-16 00:20:42.106+00	2024-02-16 00:20:42.106+00	opW2wQ2bZ8	6KvFK8yy1q	3	4	4	2	3	\N	\N
QoBfslGaHK	2024-02-16 00:20:42.319+00	2024-02-16 00:20:42.319+00	iUlyHNFGpG	M0tHrt1GgV	0	0	4	0	0	\N	\N
3qsI7M0s2S	2024-02-16 00:20:42.53+00	2024-02-16 00:20:42.53+00	sy1HD51LXT	XSK814B37m	1	0	3	0	1	\N	\N
oiGewStqUQ	2024-02-16 00:20:43.199+00	2024-02-16 00:20:43.199+00	WKpBp0c8F3	u5FXeeOChJ	2	2	2	1	1	\N	\N
Ba6bLFWQHC	2024-02-16 00:20:43.407+00	2024-02-16 00:20:43.407+00	adE9nQrDk3	WSTLlXDcKl	3	4	0	2	3	\N	\N
ebrbq44DcF	2024-02-16 00:20:43.618+00	2024-02-16 00:20:43.618+00	WKpBp0c8F3	u5FXeeOChJ	4	1	3	1	4	\N	\N
thaiOBBvEB	2024-02-16 00:20:43.824+00	2024-02-16 00:20:43.824+00	SFAISec8QF	MQfxuw3ERg	0	1	2	1	4	\N	\N
GY9e6ZadAO	2024-02-16 00:20:44.029+00	2024-02-16 00:20:44.029+00	ONgyydfVNz	qZmnAnnPEb	2	4	1	1	3	\N	\N
8GkYiCZZTA	2024-02-16 00:20:44.235+00	2024-02-16 00:20:44.235+00	sy1HD51LXT	Oahm9sOn1y	4	4	0	0	2	\N	\N
vnUCLCc7Hz	2024-02-16 00:20:44.441+00	2024-02-16 00:20:44.441+00	HtEtaHBVDN	14jGmOAXcg	1	2	0	3	3	\N	\N
u2RMehfAq3	2024-02-16 00:20:44.647+00	2024-02-16 00:20:44.647+00	Otwj7uJwjr	RBRcyltRSC	0	0	3	2	3	\N	\N
wJRTkAeEk5	2024-02-16 00:20:44.857+00	2024-02-16 00:20:44.857+00	dEqAHvPMXA	jjVdtithcD	2	1	0	1	0	\N	\N
uHQj1wdDKS	2024-02-16 00:20:45.453+00	2024-02-16 00:20:45.453+00	dZKm0wOhYa	89xRG1afNi	2	4	4	2	0	\N	\N
i0CdYSF9yn	2024-02-16 00:20:45.656+00	2024-02-16 00:20:45.656+00	I5RzFRcQ7G	qP3EdIVzfB	3	2	0	4	4	\N	\N
h1tw8HwHkE	2024-02-16 00:20:45.861+00	2024-02-16 00:20:45.861+00	HRhGpJpmb5	qP3EdIVzfB	2	3	2	0	3	\N	\N
baC2CZDRFA	2024-02-16 00:20:46.072+00	2024-02-16 00:20:46.072+00	WKpBp0c8F3	14jGmOAXcg	1	2	4	3	4	\N	\N
hYhumXYYUr	2024-02-16 00:20:46.684+00	2024-02-16 00:20:46.684+00	opW2wQ2bZ8	uABtFsJhJc	1	0	1	1	3	\N	\N
B9vf5MiHSZ	2024-02-16 00:20:46.892+00	2024-02-16 00:20:46.892+00	Otwj7uJwjr	JRi61dUphq	2	4	1	3	1	\N	\N
imTSEFMvAp	2024-02-16 00:20:47.099+00	2024-02-16 00:20:47.099+00	R2CLtFh5jU	3u4B9V4l5K	1	2	0	1	2	\N	\N
yWMzqnRwye	2024-02-16 00:20:47.4+00	2024-02-16 00:20:47.4+00	S6wz0lK0bf	6KvFK8yy1q	2	3	4	0	2	\N	\N
3j6NtqvXx7	2024-02-16 00:20:47.708+00	2024-02-16 00:20:47.708+00	1as6rMOzjQ	MQfxuw3ERg	4	3	3	4	0	\N	\N
jgiBVWphFH	2024-02-16 00:20:47.917+00	2024-02-16 00:20:47.917+00	adE9nQrDk3	cTIjuPjyIa	0	0	3	3	1	\N	\N
gjkXpKcaDf	2024-02-16 00:20:48.123+00	2024-02-16 00:20:48.123+00	WKpBp0c8F3	uABtFsJhJc	3	4	2	4	4	\N	\N
l7F29qH4kv	2024-02-16 00:20:48.426+00	2024-02-16 00:20:48.426+00	1as6rMOzjQ	3u4B9V4l5K	1	3	1	3	0	\N	\N
HeG3iU3DfD	2024-02-16 00:20:48.691+00	2024-02-16 00:20:48.691+00	5X202ssb0D	C7II8dYRPY	0	2	2	3	1	\N	\N
o7TuXl3zFd	2024-02-16 00:20:48.904+00	2024-02-16 00:20:48.904+00	jqDYoPT45X	OQWu2bnHeC	3	1	0	3	0	\N	\N
yEIv5WUDd0	2024-02-16 00:20:49.118+00	2024-02-16 00:20:49.118+00	dEqAHvPMXA	na5crB8ED1	4	2	1	2	3	\N	\N
D5XXNpdkaW	2024-02-16 00:20:49.327+00	2024-02-16 00:20:49.327+00	WKpBp0c8F3	axyV0Fu7pm	3	1	2	0	3	\N	\N
djnzVlc8Kk	2024-02-16 00:20:49.542+00	2024-02-16 00:20:49.542+00	iWxl9obi8w	Oahm9sOn1y	1	3	2	4	0	\N	\N
T49lFwIQvv	2024-02-16 00:20:50.165+00	2024-02-16 00:20:50.165+00	RWwLSzreG2	na5crB8ED1	1	2	0	2	2	\N	\N
5EvYazUCu6	2024-02-16 00:20:50.473+00	2024-02-16 00:20:50.473+00	VshUk7eBeK	D0A6GLdsDM	1	0	0	2	0	\N	\N
bWjhhQv85B	2024-02-16 00:20:50.688+00	2024-02-16 00:20:50.688+00	mQXQWNqxg9	rKyjwoEIRp	0	4	0	4	0	\N	\N
AMXAwB4vGk	2024-02-16 00:20:50.985+00	2024-02-16 00:20:50.985+00	dEqAHvPMXA	TZsdmscJ2B	2	2	4	3	0	\N	\N
NDh9bnoCCv	2024-02-16 00:20:51.19+00	2024-02-16 00:20:51.19+00	HtEtaHBVDN	y4RkaDbkec	4	4	2	1	3	\N	\N
xVGDeMmHnI	2024-02-16 00:20:51.399+00	2024-02-16 00:20:51.399+00	5nv19u6KJ2	FJOTueDfs2	3	1	4	2	2	\N	\N
mGj2wliVjI	2024-02-16 00:20:51.607+00	2024-02-16 00:20:51.607+00	opW2wQ2bZ8	KCsJ4XR6Dn	2	4	1	1	1	\N	\N
8EMSdxtQOS	2024-02-16 00:20:51.816+00	2024-02-16 00:20:51.816+00	iUlyHNFGpG	89xRG1afNi	2	2	3	4	2	\N	\N
OZeHXh3hMw	2024-02-16 00:20:52.418+00	2024-02-16 00:20:52.418+00	dEqAHvPMXA	D0A6GLdsDM	0	0	1	4	2	\N	\N
2AEH7KYKID	2024-02-16 00:20:52.622+00	2024-02-16 00:20:52.622+00	1as6rMOzjQ	tCIEnLLcUc	0	2	3	4	3	\N	\N
1YQ3Z5XDKU	2024-02-16 00:20:52.829+00	2024-02-16 00:20:52.829+00	5nv19u6KJ2	NBojpORh3G	3	0	4	0	4	\N	\N
m4bUoYx7zd	2024-02-16 00:20:53.038+00	2024-02-16 00:20:53.038+00	NjxsGlPeB4	PF8w2gMAdi	3	3	0	0	2	\N	\N
vLdSHJEPmj	2024-02-16 00:20:53.246+00	2024-02-16 00:20:53.246+00	sHiqaG4iqY	IEqTHcohpJ	1	2	3	4	0	\N	\N
Kk6yXE6nRn	2024-02-16 00:20:53.85+00	2024-02-16 00:20:53.85+00	AsrLUQwxI9	rKyjwoEIRp	1	4	4	1	3	\N	\N
VHatez54IS	2024-02-16 00:20:54.054+00	2024-02-16 00:20:54.054+00	iWxl9obi8w	H40ivltLwZ	4	2	0	2	2	\N	\N
55My2kqffC	2024-02-16 00:20:54.262+00	2024-02-16 00:20:54.262+00	mAKp5BK7R1	tCIEnLLcUc	0	4	2	1	1	\N	\N
mA9uBaClSN	2024-02-16 00:20:54.471+00	2024-02-16 00:20:54.471+00	dZKm0wOhYa	qEQ9tmLyW9	2	0	2	2	1	\N	\N
DnpLlIzy0W	2024-02-16 00:20:54.774+00	2024-02-16 00:20:54.774+00	1as6rMOzjQ	FYXEfIO1zF	4	3	1	1	3	\N	\N
NhaaGcDtqw	2024-02-16 00:20:55.082+00	2024-02-16 00:20:55.082+00	adE9nQrDk3	INeptnSdJC	3	0	2	3	4	\N	\N
nDlYXyAvep	2024-02-16 00:20:55.29+00	2024-02-16 00:20:55.29+00	dEqAHvPMXA	cmxBcanww9	2	1	1	1	3	\N	\N
iPSEDlD1RP	2024-02-16 00:20:55.497+00	2024-02-16 00:20:55.497+00	sHiqaG4iqY	JRi61dUphq	3	0	2	3	4	\N	\N
Xn2mYI3Ukc	2024-02-16 00:20:55.707+00	2024-02-16 00:20:55.707+00	R2CLtFh5jU	na5crB8ED1	2	0	2	4	2	\N	\N
cyA0vwdIyT	2024-02-16 00:20:55.91+00	2024-02-16 00:20:55.91+00	ONgyydfVNz	cmxBcanww9	1	2	2	3	2	\N	\N
xD9Ohvuc34	2024-02-16 00:20:56.119+00	2024-02-16 00:20:56.119+00	ONgyydfVNz	Gl96vGdYHM	0	2	4	1	0	\N	\N
lHJjOWiJqg	2024-02-16 00:20:56.722+00	2024-02-16 00:20:56.722+00	VshUk7eBeK	OQWu2bnHeC	4	1	0	2	1	\N	\N
rr9oBJw3cG	2024-02-16 00:20:56.93+00	2024-02-16 00:20:56.93+00	dEqAHvPMXA	INeptnSdJC	3	2	1	3	0	\N	\N
li4GVRwMWV	2024-02-16 00:20:57.141+00	2024-02-16 00:20:57.141+00	sHiqaG4iqY	XpUyRlB6FI	1	2	4	4	0	\N	\N
ar6moEZPfK	2024-02-16 00:20:57.348+00	2024-02-16 00:20:57.348+00	mAKp5BK7R1	WBFeKac0OO	2	3	1	0	4	\N	\N
jIoQvn46ki	2024-02-16 00:20:57.558+00	2024-02-16 00:20:57.558+00	dEqAHvPMXA	E2hBZzDsjO	1	3	4	0	2	\N	\N
LQD4ZyQ5ER	2024-02-16 00:20:57.768+00	2024-02-16 00:20:57.768+00	iWxl9obi8w	Pja6n3yaWZ	1	0	1	4	1	\N	\N
eb26EEAmZv	2024-02-16 00:20:58.052+00	2024-02-16 00:20:58.052+00	5nv19u6KJ2	6KvFK8yy1q	4	2	1	2	0	\N	\N
FKNtUo1k1n	2024-02-16 00:20:58.263+00	2024-02-16 00:20:58.263+00	S6wz0lK0bf	bQ0JOk10eL	3	4	1	3	2	\N	\N
4rGl3DZnrd	2024-02-16 00:20:58.473+00	2024-02-16 00:20:58.473+00	SFAISec8QF	JLhF4VuByh	3	4	1	4	3	\N	\N
VgertZoESO	2024-02-16 00:20:58.686+00	2024-02-16 00:20:58.686+00	iUlyHNFGpG	IybX0eBoO3	0	0	0	2	2	\N	\N
6OFvU42HXr	2024-02-16 00:20:58.899+00	2024-02-16 00:20:58.899+00	9223vtvaBd	jjVdtithcD	2	3	0	4	0	\N	\N
AE0vKVeCt2	2024-02-16 00:20:59.481+00	2024-02-16 00:20:59.481+00	mAKp5BK7R1	UDXF0qXvDY	4	2	3	4	0	\N	\N
xk6plUQOV6	2024-02-16 00:20:59.687+00	2024-02-16 00:20:59.687+00	HRhGpJpmb5	jjVdtithcD	2	2	2	4	2	\N	\N
HrTlJVcKEq	2024-02-16 00:20:59.894+00	2024-02-16 00:20:59.894+00	WKpBp0c8F3	9GF3y7LmHV	2	1	3	2	0	\N	\N
kUr28EnHpS	2024-02-16 00:21:00.509+00	2024-02-16 00:21:00.509+00	adE9nQrDk3	bQpy9LEJWn	4	4	2	2	3	\N	\N
og4j3J2wxh	2024-02-16 00:21:00.815+00	2024-02-16 00:21:00.815+00	sy1HD51LXT	uigc7bJBOJ	0	2	4	2	1	\N	\N
jLwnDPg5zp	2024-02-16 00:21:01.021+00	2024-02-16 00:21:01.021+00	WKpBp0c8F3	fxvABtKCPT	4	1	2	0	0	\N	\N
WC99bPhivI	2024-02-16 00:21:01.228+00	2024-02-16 00:21:01.228+00	S6wz0lK0bf	TZsdmscJ2B	4	0	0	1	2	\N	\N
DTNFPjYbDy	2024-02-16 00:21:01.435+00	2024-02-16 00:21:01.435+00	HtEtaHBVDN	D0A6GLdsDM	2	1	3	0	4	\N	\N
1fw8FUyqDA	2024-02-16 00:21:01.641+00	2024-02-16 00:21:01.641+00	RWwLSzreG2	XwWwGnkXNj	0	3	1	4	0	\N	\N
bfP174J7Hh	2024-02-16 00:21:01.847+00	2024-02-16 00:21:01.847+00	9223vtvaBd	NY6RE1qgWu	1	0	3	4	1	\N	\N
uDHCwfHiDn	2024-02-16 00:21:02.056+00	2024-02-16 00:21:02.056+00	5X202ssb0D	IybX0eBoO3	0	0	0	1	2	\N	\N
mz3PXSKt0v	2024-02-16 00:21:02.258+00	2024-02-16 00:21:02.258+00	ONgyydfVNz	o4VD4BWwDt	4	0	3	2	1	\N	\N
qzrNK312mw	2024-02-16 00:21:02.46+00	2024-02-16 00:21:02.46+00	9223vtvaBd	oABNR2FF6S	0	0	1	3	0	\N	\N
47CiCIAXYS	2024-02-16 00:21:03.066+00	2024-02-16 00:21:03.066+00	ONgyydfVNz	E2hBZzDsjO	4	3	1	1	4	\N	\N
CvA3NpDiW2	2024-02-16 00:21:03.276+00	2024-02-16 00:21:03.276+00	dZKm0wOhYa	JRi61dUphq	0	3	3	2	4	\N	\N
JBWW4DAA4Y	2024-02-16 00:21:03.487+00	2024-02-16 00:21:03.487+00	WKpBp0c8F3	TpGyMZM9BG	4	3	3	4	1	\N	\N
vFXu9NMkjs	2024-02-16 00:21:03.697+00	2024-02-16 00:21:03.697+00	S6wz0lK0bf	HXtEwLBC7f	4	0	4	1	2	\N	\N
tHPdpSffEx	2024-02-16 00:21:03.907+00	2024-02-16 00:21:03.907+00	5nv19u6KJ2	IEqTHcohpJ	2	4	4	3	3	\N	\N
4ioEA0a2M9	2024-02-16 00:21:04.116+00	2024-02-16 00:21:04.116+00	iUlyHNFGpG	e037qpAih3	1	1	2	0	0	\N	\N
MZBSmoT3OB	2024-02-16 00:21:04.323+00	2024-02-16 00:21:04.323+00	5X202ssb0D	o4VD4BWwDt	1	3	0	3	0	\N	\N
APXAkrH36n	2024-02-16 00:21:04.533+00	2024-02-16 00:21:04.533+00	dZKm0wOhYa	IybX0eBoO3	4	0	2	2	4	\N	\N
OiCvk50ZpA	2024-02-16 00:21:04.747+00	2024-02-16 00:21:04.747+00	adE9nQrDk3	yvUod6yLDt	2	0	2	4	2	\N	\N
CfBSrgqoxk	2024-02-16 00:21:05.017+00	2024-02-16 00:21:05.017+00	jqDYoPT45X	vwHi602n66	2	3	1	3	2	\N	\N
8ixAgEneru	2024-02-16 00:21:05.227+00	2024-02-16 00:21:05.227+00	iUlyHNFGpG	UCFo58JaaD	2	2	2	1	0	\N	\N
O9q1sMMVKE	2024-02-16 00:21:05.436+00	2024-02-16 00:21:05.436+00	Otwj7uJwjr	cwVEh0dqfm	3	3	1	4	2	\N	\N
QNsVzmI0iz	2024-02-16 00:21:05.648+00	2024-02-16 00:21:05.648+00	sy1HD51LXT	m8hjjLVdPS	4	4	1	3	3	\N	\N
SPIhKGt211	2024-02-16 00:21:05.871+00	2024-02-16 00:21:05.871+00	5X202ssb0D	fxvABtKCPT	1	3	3	4	1	\N	\N
F77uO7ybbS	2024-02-16 00:21:06.137+00	2024-02-16 00:21:06.137+00	opW2wQ2bZ8	IybX0eBoO3	1	1	0	0	0	\N	\N
ZAHeAXKZqz	2024-02-16 00:21:06.35+00	2024-02-16 00:21:06.35+00	WKpBp0c8F3	0TvWuLoLF5	1	0	1	2	1	\N	\N
QUz5Y33qBm	2024-02-16 00:21:06.561+00	2024-02-16 00:21:06.561+00	S6wz0lK0bf	e037qpAih3	3	1	0	4	0	\N	\N
TY08XCAzDZ	2024-02-16 00:21:06.773+00	2024-02-16 00:21:06.773+00	iUlyHNFGpG	fxvABtKCPT	0	4	0	4	2	\N	\N
J0yp04uLL6	2024-02-16 00:21:06.982+00	2024-02-16 00:21:06.982+00	WKpBp0c8F3	INeptnSdJC	0	2	2	1	2	\N	\N
i54j4m2aFI	2024-02-16 00:21:07.195+00	2024-02-16 00:21:07.195+00	ONgyydfVNz	cwVEh0dqfm	2	0	3	3	3	\N	\N
TEdw6VvdWn	2024-02-16 00:21:07.407+00	2024-02-16 00:21:07.407+00	opW2wQ2bZ8	u5FXeeOChJ	1	0	2	3	1	\N	\N
t5wZNBcD6e	2024-02-16 00:21:07.617+00	2024-02-16 00:21:07.617+00	5nv19u6KJ2	m6g8u0QpTC	3	2	3	4	3	\N	\N
P44Hh7EoQc	2024-02-16 00:21:07.829+00	2024-02-16 00:21:07.829+00	VshUk7eBeK	3u4B9V4l5K	2	0	0	2	4	\N	\N
xPeJMdb0ZF	2024-02-16 00:21:08.042+00	2024-02-16 00:21:08.042+00	HRhGpJpmb5	qZmnAnnPEb	2	3	2	3	3	\N	\N
M24AZPCmle	2024-02-16 00:21:08.254+00	2024-02-16 00:21:08.254+00	VshUk7eBeK	vwHi602n66	0	3	1	2	0	\N	\N
Gnu0WXP5XA	2024-02-16 00:21:08.91+00	2024-02-16 00:21:08.91+00	1as6rMOzjQ	KCsJ4XR6Dn	1	0	2	0	2	\N	\N
sHsp5VCsw4	2024-02-16 00:21:09.121+00	2024-02-16 00:21:09.121+00	mQXQWNqxg9	j0dWqP2C2A	0	4	4	0	3	\N	\N
nuEMonDrpM	2024-02-16 00:21:09.332+00	2024-02-16 00:21:09.332+00	WKpBp0c8F3	uigc7bJBOJ	0	1	0	2	1	\N	\N
CHXLA22A2p	2024-02-16 00:21:09.624+00	2024-02-16 00:21:09.624+00	sHiqaG4iqY	FJOTueDfs2	3	3	2	3	3	\N	\N
GL4dttt2KG	2024-02-16 00:21:09.835+00	2024-02-16 00:21:09.835+00	AsrLUQwxI9	LgJuu5ABe5	0	2	2	1	4	\N	\N
GrDfhBbjq3	2024-02-16 00:21:10.046+00	2024-02-16 00:21:10.046+00	5nv19u6KJ2	uABtFsJhJc	2	2	3	4	4	\N	\N
88FiCtHqta	2024-02-16 00:21:10.257+00	2024-02-16 00:21:10.257+00	mAKp5BK7R1	qZmnAnnPEb	4	2	4	1	2	\N	\N
JSDQwOB5Pw	2024-02-16 00:21:10.469+00	2024-02-16 00:21:10.469+00	dEqAHvPMXA	TCkiw6gTDz	3	1	1	1	1	\N	\N
P1TdXwV5I6	2024-02-16 00:21:10.752+00	2024-02-16 00:21:10.752+00	mQXQWNqxg9	qEQ9tmLyW9	4	2	3	4	2	\N	\N
DNHSMM05Ht	2024-02-16 00:21:10.964+00	2024-02-16 00:21:10.964+00	opW2wQ2bZ8	bi1IivsuUB	0	3	1	3	3	\N	\N
oT3ZDdsBnn	2024-02-16 00:21:11.169+00	2024-02-16 00:21:11.169+00	Otwj7uJwjr	JRi61dUphq	0	3	1	4	0	\N	\N
SIFer2Q7YU	2024-02-16 00:21:11.375+00	2024-02-16 00:21:11.375+00	5X202ssb0D	E2hBZzDsjO	1	0	1	4	4	\N	\N
as8TZIabwI	2024-02-16 00:21:11.583+00	2024-02-16 00:21:11.583+00	5nv19u6KJ2	fwLPZZ8YQa	3	1	1	2	4	\N	\N
uUCEekoB2K	2024-02-16 00:21:11.794+00	2024-02-16 00:21:11.794+00	HtEtaHBVDN	bi1IivsuUB	0	1	2	4	2	\N	\N
wo5tW6cXZD	2024-02-16 00:21:12.391+00	2024-02-16 00:21:12.391+00	WKpBp0c8F3	LVYK4mLShP	0	2	3	2	3	\N	\N
PPvqAChu30	2024-02-16 00:21:12.605+00	2024-02-16 00:21:12.605+00	5X202ssb0D	XpUyRlB6FI	2	2	0	0	1	\N	\N
qgbHzx3N5J	2024-02-16 00:21:12.901+00	2024-02-16 00:21:12.901+00	HtEtaHBVDN	cTIjuPjyIa	4	0	4	2	1	\N	\N
n20kz5k9DU	2024-02-16 00:21:13.111+00	2024-02-16 00:21:13.111+00	5nv19u6KJ2	H40ivltLwZ	0	1	4	3	2	\N	\N
HzgF5zsIOI	2024-02-16 00:21:13.319+00	2024-02-16 00:21:13.319+00	NjxsGlPeB4	CSvk1ycWXk	0	3	1	4	4	\N	\N
CmoVokAiIi	2024-02-16 00:21:13.527+00	2024-02-16 00:21:13.527+00	opW2wQ2bZ8	e037qpAih3	1	4	1	2	1	\N	\N
YwSXdLsa0T	2024-02-16 00:21:13.739+00	2024-02-16 00:21:13.739+00	adE9nQrDk3	G0uU7KQLEt	0	3	1	2	0	\N	\N
4bab9QNoRt	2024-02-16 00:21:13.954+00	2024-02-16 00:21:13.954+00	iWxl9obi8w	08liHW08uC	2	2	3	1	3	\N	\N
efwo4X1cMG	2024-02-16 00:21:14.234+00	2024-02-16 00:21:14.234+00	SFAISec8QF	axyV0Fu7pm	0	0	1	4	2	\N	\N
abNYvXTapo	2024-02-16 00:21:14.444+00	2024-02-16 00:21:14.444+00	5nv19u6KJ2	TCkiw6gTDz	0	2	3	2	1	\N	\N
yHrfp7SY6q	2024-02-16 00:21:14.655+00	2024-02-16 00:21:14.655+00	SFAISec8QF	FYXEfIO1zF	2	2	1	4	0	\N	\N
jeke3aFUV9	2024-02-16 00:21:14.867+00	2024-02-16 00:21:14.867+00	opW2wQ2bZ8	tCIEnLLcUc	1	4	2	1	2	\N	\N
eF7DIYCDVf	2024-02-16 00:21:15.155+00	2024-02-16 00:21:15.155+00	1as6rMOzjQ	Pja6n3yaWZ	1	4	3	4	2	\N	\N
ewCFeSFViB	2024-02-16 00:21:15.365+00	2024-02-16 00:21:15.365+00	5X202ssb0D	l1Bslv8T2k	4	1	1	4	1	\N	\N
soJovKRJB7	2024-02-16 00:21:15.574+00	2024-02-16 00:21:15.574+00	sHiqaG4iqY	XSK814B37m	2	2	0	3	2	\N	\N
bVf2HFSW9T	2024-02-16 00:21:15.786+00	2024-02-16 00:21:15.786+00	RWwLSzreG2	lxQA9rtSfY	4	1	0	4	1	\N	\N
YXo6E3uiPk	2024-02-16 00:21:16.384+00	2024-02-16 00:21:16.384+00	R2CLtFh5jU	ThMuD3hYRQ	4	1	3	3	1	\N	\N
PHTELmaT2a	2024-02-16 00:21:16.69+00	2024-02-16 00:21:16.69+00	SFAISec8QF	rT0UCBK1bE	3	3	1	0	4	\N	\N
VxuHtQ97CU	2024-02-16 00:21:17.301+00	2024-02-16 00:21:17.301+00	sHiqaG4iqY	Oahm9sOn1y	3	4	4	0	3	\N	\N
Fuxl5e8HYz	2024-02-16 00:21:17.505+00	2024-02-16 00:21:17.505+00	WKpBp0c8F3	8w7i8C3NnT	1	3	3	0	3	\N	\N
eLa9E3ETQy	2024-02-16 00:21:17.711+00	2024-02-16 00:21:17.711+00	VshUk7eBeK	e037qpAih3	1	0	2	4	4	\N	\N
I9foKpHqjH	2024-02-16 00:21:17.918+00	2024-02-16 00:21:17.918+00	NjxsGlPeB4	HXtEwLBC7f	2	1	3	4	0	\N	\N
27Ao1GNy6z	2024-02-16 00:21:18.224+00	2024-02-16 00:21:18.224+00	jqDYoPT45X	fKTSJPdUi9	1	2	2	2	4	\N	\N
ISBfAbJrzH	2024-02-16 00:21:18.431+00	2024-02-16 00:21:18.431+00	mQXQWNqxg9	qEQ9tmLyW9	0	0	2	4	1	\N	\N
FeeKFan9LZ	2024-02-16 00:21:18.642+00	2024-02-16 00:21:18.642+00	iWxl9obi8w	HLIPwAqO2R	0	2	4	3	0	\N	\N
RoC6x3nYlF	2024-02-16 00:21:18.851+00	2024-02-16 00:21:18.851+00	WKpBp0c8F3	WSTLlXDcKl	0	1	2	0	1	\N	\N
BB3fmhbYnV	2024-02-16 00:21:19.062+00	2024-02-16 00:21:19.062+00	R2CLtFh5jU	VK3vnSxIy8	4	4	2	0	1	\N	\N
pFX35mkwGm	2024-02-16 00:21:19.353+00	2024-02-16 00:21:19.353+00	ONgyydfVNz	08liHW08uC	3	1	4	1	2	\N	\N
GcNpJKXkdn	2024-02-16 00:21:19.563+00	2024-02-16 00:21:19.563+00	R2CLtFh5jU	l1Bslv8T2k	4	4	4	3	4	\N	\N
SuJMoZ5yKa	2024-02-16 00:21:19.771+00	2024-02-16 00:21:19.771+00	iWxl9obi8w	uigc7bJBOJ	4	2	4	1	3	\N	\N
HgVWNq8OvY	2024-02-16 00:21:19.986+00	2024-02-16 00:21:19.986+00	1as6rMOzjQ	WHvlAGgj6c	0	1	0	3	1	\N	\N
aDuTTJVSHF	2024-02-16 00:21:20.198+00	2024-02-16 00:21:20.198+00	jqDYoPT45X	EmIUBFwx0Z	0	2	2	2	1	\N	\N
seoCLkqGjN	2024-02-16 00:21:20.408+00	2024-02-16 00:21:20.408+00	sy1HD51LXT	rT0UCBK1bE	3	1	2	0	1	\N	\N
AxlLNDv2C8	2024-02-16 00:21:20.692+00	2024-02-16 00:21:20.692+00	opW2wQ2bZ8	jHqCpA1nWb	0	2	4	0	0	\N	\N
tGnGxoPAE3	2024-02-16 00:21:21.299+00	2024-02-16 00:21:21.299+00	I5RzFRcQ7G	6Fo67rhTSP	2	1	4	1	0	\N	\N
xnGrxUyK9J	2024-02-16 00:21:21.507+00	2024-02-16 00:21:21.507+00	R2CLtFh5jU	D0A6GLdsDM	0	3	0	4	4	\N	\N
YaN7mLgkMr	2024-02-16 00:21:21.713+00	2024-02-16 00:21:21.713+00	I5RzFRcQ7G	JZOBDAh12a	3	2	0	1	3	\N	\N
ejiiBSoTJm	2024-02-16 00:21:21.923+00	2024-02-16 00:21:21.923+00	NjxsGlPeB4	vwHi602n66	0	3	3	2	4	\N	\N
y1AZZPRRGM	2024-02-16 00:21:22.129+00	2024-02-16 00:21:22.129+00	I5RzFRcQ7G	m8hjjLVdPS	0	2	3	4	2	\N	\N
G43vG78ZG8	2024-02-16 00:21:22.35+00	2024-02-16 00:21:22.35+00	NjxsGlPeB4	XpUyRlB6FI	4	3	4	1	2	\N	\N
QRoq0rlbYu	2024-02-16 00:21:22.561+00	2024-02-16 00:21:22.561+00	ONgyydfVNz	Oahm9sOn1y	1	4	2	3	2	\N	\N
qFVtGsa3J6	2024-02-16 00:21:22.777+00	2024-02-16 00:21:22.777+00	AsrLUQwxI9	JRi61dUphq	1	4	4	2	2	\N	\N
yDYH5ByhsV	2024-02-16 00:21:22.985+00	2024-02-16 00:21:22.985+00	AsrLUQwxI9	o90lhsZ7FK	2	0	1	3	3	\N	\N
K8ZBEAE4tp	2024-02-16 00:21:23.203+00	2024-02-16 00:21:23.203+00	opW2wQ2bZ8	uigc7bJBOJ	4	1	3	4	0	\N	\N
5jEKP9Bsly	2024-02-16 00:21:23.418+00	2024-02-16 00:21:23.418+00	SFAISec8QF	o4VD4BWwDt	0	1	1	3	1	\N	\N
mHMWZUv7HF	2024-02-16 00:21:23.636+00	2024-02-16 00:21:23.636+00	5X202ssb0D	uigc7bJBOJ	0	4	2	1	0	\N	\N
6tlXHgk28F	2024-02-16 00:21:23.964+00	2024-02-16 00:21:23.964+00	HtEtaHBVDN	KCsJ4XR6Dn	3	4	3	0	0	\N	\N
90kdQK79HX	2024-02-16 00:21:24.176+00	2024-02-16 00:21:24.176+00	dZKm0wOhYa	D0A6GLdsDM	1	4	1	4	2	\N	\N
5Q8egaLJk3	2024-02-16 00:21:24.477+00	2024-02-16 00:21:24.477+00	RWwLSzreG2	WnUBBkiDjE	2	4	0	3	2	\N	\N
dgHh7m62sx	2024-02-16 00:21:24.786+00	2024-02-16 00:21:24.786+00	iUlyHNFGpG	Oahm9sOn1y	0	2	3	1	4	\N	\N
APCtXapS7L	2024-02-16 00:21:25.091+00	2024-02-16 00:21:25.091+00	S6wz0lK0bf	D0A6GLdsDM	3	4	3	1	2	\N	\N
6s8yALqY39	2024-02-16 00:21:25.303+00	2024-02-16 00:21:25.303+00	RWwLSzreG2	XwWwGnkXNj	4	0	3	2	3	\N	\N
7RfPeB6jz4	2024-02-16 00:21:25.516+00	2024-02-16 00:21:25.516+00	Otwj7uJwjr	u5FXeeOChJ	3	0	3	0	1	\N	\N
Q9wCkFfHzm	2024-02-16 00:21:25.807+00	2024-02-16 00:21:25.807+00	VshUk7eBeK	E2hBZzDsjO	0	1	2	3	0	\N	\N
O5qNLn18ay	2024-02-16 00:21:26.034+00	2024-02-16 00:21:26.034+00	iWxl9obi8w	M0tHrt1GgV	3	1	3	0	1	\N	\N
7MrVCGGEje	2024-02-16 00:21:26.32+00	2024-02-16 00:21:26.32+00	HtEtaHBVDN	TZsdmscJ2B	3	3	2	3	1	\N	\N
GS9hfqO6jx	2024-02-16 00:21:26.533+00	2024-02-16 00:21:26.533+00	dZKm0wOhYa	XwszrNEEEj	4	1	4	3	0	\N	\N
GCtoRijgmC	2024-02-16 00:21:26.749+00	2024-02-16 00:21:26.749+00	5X202ssb0D	bQpy9LEJWn	4	3	0	1	4	\N	\N
JjizZgJQpb	2024-02-16 00:21:26.96+00	2024-02-16 00:21:26.96+00	HtEtaHBVDN	fxvABtKCPT	0	2	4	0	1	\N	\N
pxcpjkTYLT	2024-02-16 00:21:27.24+00	2024-02-16 00:21:27.24+00	HtEtaHBVDN	3P6kmNoY1F	3	2	0	4	0	\N	\N
MZBCglHxrF	2024-02-16 00:21:27.452+00	2024-02-16 00:21:27.452+00	sy1HD51LXT	axyV0Fu7pm	3	1	4	3	4	\N	\N
aPplVAADyo	2024-02-16 00:21:28.021+00	2024-02-16 00:21:28.021+00	9223vtvaBd	LDrIH1vU8x	3	4	0	1	1	\N	\N
nDyvZc0jsW	2024-02-16 00:21:28.673+00	2024-02-16 00:21:28.673+00	adE9nQrDk3	CSvk1ycWXk	3	1	2	4	4	\N	\N
A8YZG805IB	2024-02-16 00:21:28.885+00	2024-02-16 00:21:28.885+00	HtEtaHBVDN	0TvWuLoLF5	1	3	3	3	1	\N	\N
OGZIO9xHMj	2024-02-16 00:21:29.098+00	2024-02-16 00:21:29.098+00	sHiqaG4iqY	na5crB8ED1	4	2	3	2	4	\N	\N
64gcGOmmOZ	2024-02-16 00:21:29.311+00	2024-02-16 00:21:29.311+00	5X202ssb0D	JRi61dUphq	0	0	1	3	0	\N	\N
Bmk5CnLCwG	2024-02-16 00:21:29.524+00	2024-02-16 00:21:29.524+00	Otwj7uJwjr	PF8w2gMAdi	3	4	4	0	4	\N	\N
vITF8caRti	2024-02-16 00:21:29.736+00	2024-02-16 00:21:29.736+00	5X202ssb0D	6KvFK8yy1q	2	1	3	4	1	\N	\N
xQxzYE0nOa	2024-02-16 00:21:29.948+00	2024-02-16 00:21:29.948+00	adE9nQrDk3	OQWu2bnHeC	4	0	0	3	4	\N	\N
GGHzLuRNdj	2024-02-16 00:21:30.517+00	2024-02-16 00:21:30.517+00	dZKm0wOhYa	0TvWuLoLF5	4	2	2	3	2	\N	\N
Bmp2dLcwow	2024-02-16 00:21:30.727+00	2024-02-16 00:21:30.727+00	NjxsGlPeB4	XwszrNEEEj	2	3	3	3	2	\N	\N
fFyfz3mM8l	2024-02-16 00:21:30.931+00	2024-02-16 00:21:30.931+00	RWwLSzreG2	y4RkaDbkec	3	3	2	2	1	\N	\N
CnXrqEvwnC	2024-02-16 00:21:31.339+00	2024-02-16 00:21:31.339+00	NjxsGlPeB4	XwszrNEEEj	3	1	1	0	2	\N	\N
tSIN8cWA8Z	2024-02-16 00:21:31.644+00	2024-02-16 00:21:31.644+00	R2CLtFh5jU	OQWu2bnHeC	3	0	0	3	4	\N	\N
ZXFOpaiMER	2024-02-16 00:21:31.857+00	2024-02-16 00:21:31.857+00	dZKm0wOhYa	o4VD4BWwDt	1	2	1	1	4	\N	\N
YGfPFNFRIJ	2024-02-16 00:21:32.078+00	2024-02-16 00:21:32.078+00	9223vtvaBd	08liHW08uC	2	4	4	1	4	\N	\N
xaeGzipty9	2024-02-16 00:21:32.281+00	2024-02-16 00:21:32.281+00	dEqAHvPMXA	JLhF4VuByh	0	4	1	4	0	\N	\N
LmOKZjT0U1	2024-02-16 00:21:32.557+00	2024-02-16 00:21:32.557+00	RWwLSzreG2	cTIjuPjyIa	2	2	0	4	1	\N	\N
Qg5LZzd3OS	2024-02-16 00:21:32.771+00	2024-02-16 00:21:32.771+00	AsrLUQwxI9	G0uU7KQLEt	0	1	2	0	3	\N	\N
COP7DqS0RD	2024-02-16 00:21:32.983+00	2024-02-16 00:21:32.983+00	9223vtvaBd	IEqTHcohpJ	0	0	0	2	0	\N	\N
Kwz10fA7KI	2024-02-16 00:21:33.195+00	2024-02-16 00:21:33.195+00	ONgyydfVNz	WHvlAGgj6c	3	2	0	1	4	\N	\N
r8i1RjvOtR	2024-02-16 00:21:33.407+00	2024-02-16 00:21:33.407+00	sHiqaG4iqY	AgU9OLJkqz	2	0	1	3	4	\N	\N
uIDB0MzTUT	2024-02-16 00:21:33.616+00	2024-02-16 00:21:33.616+00	S6wz0lK0bf	OQWu2bnHeC	4	3	1	4	4	\N	\N
cXAK3DDfnw	2024-02-16 00:21:33.844+00	2024-02-16 00:21:33.844+00	Otwj7uJwjr	cmxBcanww9	2	4	2	2	4	\N	\N
FeWbM0Zr08	2024-02-16 00:21:34.053+00	2024-02-16 00:21:34.053+00	HRhGpJpmb5	cTIjuPjyIa	3	2	0	1	2	\N	\N
k4RZE0jyV3	2024-02-16 00:21:34.254+00	2024-02-16 00:21:34.254+00	mQXQWNqxg9	LVYK4mLShP	4	1	3	0	0	\N	\N
v9OqwSgNoa	2024-02-16 00:21:34.503+00	2024-02-16 00:21:34.503+00	dZKm0wOhYa	Oahm9sOn1y	1	4	0	3	4	\N	\N
W40PS5tNBz	2024-02-16 00:21:34.704+00	2024-02-16 00:21:34.704+00	AsrLUQwxI9	8w7i8C3NnT	3	1	4	2	4	\N	\N
OhGx21e35H	2024-02-16 00:21:34.915+00	2024-02-16 00:21:34.915+00	sy1HD51LXT	WHvlAGgj6c	0	2	3	0	1	\N	\N
m5WcwKqkLl	2024-02-16 00:21:35.123+00	2024-02-16 00:21:35.123+00	sHiqaG4iqY	rT0UCBK1bE	3	3	4	0	1	\N	\N
P105S9ctlu	2024-02-16 00:21:35.403+00	2024-02-16 00:21:35.403+00	1as6rMOzjQ	D0A6GLdsDM	4	4	2	0	1	\N	\N
CVLoJWiBmL	2024-02-16 00:21:35.615+00	2024-02-16 00:21:35.615+00	I5RzFRcQ7G	Gl96vGdYHM	1	0	1	1	0	\N	\N
C93Da1XBcC	2024-02-16 00:21:35.889+00	2024-02-16 00:21:35.889+00	I5RzFRcQ7G	JLhF4VuByh	2	2	2	4	1	\N	\N
rrSRhltU9E	2024-02-16 00:21:36.142+00	2024-02-16 00:21:36.142+00	iWxl9obi8w	jHqCpA1nWb	1	3	2	1	2	\N	\N
nfKDEOYTqZ	2024-02-16 00:21:36.349+00	2024-02-16 00:21:36.349+00	HtEtaHBVDN	AgU9OLJkqz	1	1	0	1	3	\N	\N
WBiPO8POhC	2024-02-16 00:21:36.557+00	2024-02-16 00:21:36.557+00	1as6rMOzjQ	tCIEnLLcUc	2	1	1	3	0	\N	\N
FuoZTDqBkK	2024-02-16 00:21:36.864+00	2024-02-16 00:21:36.864+00	VshUk7eBeK	o4VD4BWwDt	3	1	1	0	0	\N	\N
L5fvyzWMRX	2024-02-16 00:21:37.076+00	2024-02-16 00:21:37.076+00	Otwj7uJwjr	Pa0qBO2rzK	3	4	4	2	2	\N	\N
Sa6cyBg8BJ	2024-02-16 00:21:37.283+00	2024-02-16 00:21:37.283+00	opW2wQ2bZ8	RBRcyltRSC	4	4	2	4	2	\N	\N
o7L4rqeewB	2024-02-16 00:21:37.49+00	2024-02-16 00:21:37.49+00	adE9nQrDk3	cmxBcanww9	2	4	3	4	4	\N	\N
jv2nYe79rD	2024-02-16 00:21:37.695+00	2024-02-16 00:21:37.695+00	5X202ssb0D	na5crB8ED1	4	3	3	0	2	\N	\N
PfOhCH4OQE	2024-02-16 00:21:37.99+00	2024-02-16 00:21:37.99+00	5nv19u6KJ2	NBojpORh3G	1	4	3	4	4	\N	\N
rUQAq4SEWj	2024-02-16 00:21:38.195+00	2024-02-16 00:21:38.195+00	AsrLUQwxI9	BMLzFMvIT6	3	4	2	3	2	\N	\N
HWIaCl1QJt	2024-02-16 00:21:38.405+00	2024-02-16 00:21:38.405+00	opW2wQ2bZ8	E2hBZzDsjO	4	3	3	4	1	\N	\N
ZCHxKf5DQz	2024-02-16 00:21:38.927+00	2024-02-16 00:21:38.927+00	VshUk7eBeK	Oahm9sOn1y	2	1	2	4	4	\N	\N
aB1ST2Lqrr	2024-02-16 00:21:39.725+00	2024-02-16 00:21:39.725+00	AsrLUQwxI9	VK3vnSxIy8	4	1	0	1	1	\N	\N
314ZiAsY4S	2024-02-16 00:21:40.651+00	2024-02-16 00:21:40.651+00	ONgyydfVNz	BMLzFMvIT6	2	2	0	2	0	\N	\N
B8JkPwb3mq	2024-02-16 00:21:40.856+00	2024-02-16 00:21:40.856+00	Otwj7uJwjr	o90lhsZ7FK	1	1	0	2	3	\N	\N
XUHvLQERMJ	2024-02-16 00:21:41.06+00	2024-02-16 00:21:41.06+00	jqDYoPT45X	u5FXeeOChJ	3	2	0	4	2	\N	\N
iWXROn56pp	2024-02-16 00:21:41.368+00	2024-02-16 00:21:41.368+00	dEqAHvPMXA	UCFo58JaaD	1	0	1	2	3	\N	\N
5pIEjEvrMc	2024-02-16 00:21:41.577+00	2024-02-16 00:21:41.577+00	1as6rMOzjQ	NBojpORh3G	0	0	0	0	2	\N	\N
twSGT5ouw5	2024-02-16 00:21:41.881+00	2024-02-16 00:21:41.881+00	RWwLSzreG2	WnUBBkiDjE	0	3	0	2	4	\N	\N
CTRVsNwiiQ	2024-02-16 00:21:42.091+00	2024-02-16 00:21:42.091+00	9223vtvaBd	RBRcyltRSC	3	1	2	4	0	\N	\N
nBJ2Lo11hW	2024-02-16 00:21:42.392+00	2024-02-16 00:21:42.392+00	1as6rMOzjQ	o90lhsZ7FK	4	0	4	4	4	\N	\N
1oHikQnRCT	2024-02-16 00:21:42.695+00	2024-02-16 00:21:42.695+00	ONgyydfVNz	fxvABtKCPT	4	2	3	1	0	\N	\N
gpG6psa5Wf	2024-02-16 00:21:42.898+00	2024-02-16 00:21:42.898+00	5nv19u6KJ2	HLIPwAqO2R	3	2	0	3	4	\N	\N
g59CS7qzGh	2024-02-16 00:21:43.101+00	2024-02-16 00:21:43.101+00	R2CLtFh5jU	E2hBZzDsjO	0	2	4	3	2	\N	\N
wHKjpzj49u	2024-02-16 00:21:43.417+00	2024-02-16 00:21:43.417+00	jqDYoPT45X	89xRG1afNi	2	0	1	3	1	\N	\N
nIKIeqJoWN	2024-02-16 00:21:43.635+00	2024-02-16 00:21:43.635+00	mQXQWNqxg9	E2hBZzDsjO	0	2	3	4	1	\N	\N
ZGWXc5nIWf	2024-02-16 00:21:43.843+00	2024-02-16 00:21:43.843+00	RWwLSzreG2	cwVEh0dqfm	3	1	3	4	2	\N	\N
OAEyY5aZpD	2024-02-16 00:21:44.051+00	2024-02-16 00:21:44.051+00	mAKp5BK7R1	lxQA9rtSfY	4	2	1	1	0	\N	\N
rkPEI2UIqr	2024-02-16 00:21:44.259+00	2024-02-16 00:21:44.259+00	R2CLtFh5jU	HLIPwAqO2R	2	2	2	4	1	\N	\N
DL28UMgitC	2024-02-16 00:21:44.464+00	2024-02-16 00:21:44.464+00	NjxsGlPeB4	HSEugQ3Ouj	2	0	3	1	2	\N	\N
fODcRDNnjx	2024-02-16 00:21:44.67+00	2024-02-16 00:21:44.67+00	SFAISec8QF	FJOTueDfs2	1	1	3	3	0	\N	\N
rYfUOrvrXw	2024-02-16 00:21:44.876+00	2024-02-16 00:21:44.876+00	AsrLUQwxI9	IEqTHcohpJ	1	4	3	4	4	\N	\N
R6GHpoYED5	2024-02-16 00:21:45.157+00	2024-02-16 00:21:45.157+00	sy1HD51LXT	VK3vnSxIy8	4	2	1	2	3	\N	\N
CLhHPfDbe8	2024-02-16 00:21:45.364+00	2024-02-16 00:21:45.364+00	adE9nQrDk3	6KvFK8yy1q	4	4	0	1	0	\N	\N
M7YmUCpgrH	2024-02-16 00:21:45.67+00	2024-02-16 00:21:45.67+00	SFAISec8QF	MQfxuw3ERg	0	0	1	3	4	\N	\N
n4VsrA3XRL	2024-02-16 00:21:45.875+00	2024-02-16 00:21:45.875+00	RWwLSzreG2	0TvWuLoLF5	1	3	2	1	2	\N	\N
J8BfqQMASj	2024-02-16 00:21:46.183+00	2024-02-16 00:21:46.183+00	RWwLSzreG2	0TvWuLoLF5	4	0	4	1	2	\N	\N
vP3OfJs9Dl	2024-02-16 00:21:46.797+00	2024-02-16 00:21:46.797+00	iUlyHNFGpG	0TvWuLoLF5	4	4	0	1	1	\N	\N
N4MeEHkHYc	2024-02-16 00:21:47.002+00	2024-02-16 00:21:47.002+00	iWxl9obi8w	14jGmOAXcg	3	4	0	2	2	\N	\N
3gmXgprDgx	2024-02-16 00:21:47.213+00	2024-02-16 00:21:47.213+00	mQXQWNqxg9	8w7i8C3NnT	1	0	2	1	2	\N	\N
x4H3ITf4MT	2024-02-16 00:21:47.819+00	2024-02-16 00:21:47.819+00	5X202ssb0D	cFtamPA0zH	0	4	2	4	0	\N	\N
HFNX4NJ6Zi	2024-02-16 00:21:48.024+00	2024-02-16 00:21:48.024+00	RWwLSzreG2	yvUod6yLDt	0	4	3	1	2	\N	\N
00N6hwZbrG	2024-02-16 00:21:48.231+00	2024-02-16 00:21:48.231+00	AsrLUQwxI9	TCkiw6gTDz	4	3	1	3	0	\N	\N
6yvFM51xDe	2024-02-16 00:21:48.843+00	2024-02-16 00:21:48.843+00	sHiqaG4iqY	qEQ9tmLyW9	2	0	0	4	0	\N	\N
8PMOkbBcQV	2024-02-16 00:21:49.058+00	2024-02-16 00:21:49.058+00	WKpBp0c8F3	TCkiw6gTDz	3	3	3	4	2	\N	\N
0lujaBEP4h	2024-02-16 00:21:49.356+00	2024-02-16 00:21:49.356+00	opW2wQ2bZ8	WSTLlXDcKl	3	3	3	0	3	\N	\N
ZcKG2msQIz	2024-02-16 00:21:49.561+00	2024-02-16 00:21:49.561+00	S6wz0lK0bf	KCsJ4XR6Dn	2	3	2	2	3	\N	\N
YgoGQWQXYP	2024-02-16 00:21:49.764+00	2024-02-16 00:21:49.764+00	HRhGpJpmb5	Pa0qBO2rzK	0	0	3	0	3	\N	\N
PrZ0XtRZxl	2024-02-16 00:21:49.971+00	2024-02-16 00:21:49.971+00	SFAISec8QF	BMLzFMvIT6	0	1	4	0	0	\N	\N
q05yGDgMsV	2024-02-16 00:21:50.176+00	2024-02-16 00:21:50.176+00	S6wz0lK0bf	WBFeKac0OO	2	3	2	3	3	\N	\N
Zi6Q0t52AY	2024-02-16 00:21:50.379+00	2024-02-16 00:21:50.379+00	5X202ssb0D	BMLzFMvIT6	3	2	1	4	0	\N	\N
yYtM9aK6sV	2024-02-16 00:21:50.59+00	2024-02-16 00:21:50.59+00	dEqAHvPMXA	rKyjwoEIRp	3	2	0	2	2	\N	\N
iPLNFiRGyG	2024-02-16 00:21:50.796+00	2024-02-16 00:21:50.796+00	dEqAHvPMXA	JZOBDAh12a	1	1	4	4	4	\N	\N
RnaIE2QbBO	2024-02-16 00:21:51.093+00	2024-02-16 00:21:51.093+00	dEqAHvPMXA	m8hjjLVdPS	0	1	2	1	1	\N	\N
DioSZDdEdL	2024-02-16 00:21:51.294+00	2024-02-16 00:21:51.294+00	1as6rMOzjQ	rT0UCBK1bE	2	4	4	3	4	\N	\N
6T54z0lJku	2024-02-16 00:21:51.499+00	2024-02-16 00:21:51.499+00	S6wz0lK0bf	LgJuu5ABe5	0	2	4	0	3	\N	\N
l1ymLDjsBv	2024-02-16 00:21:51.703+00	2024-02-16 00:21:51.703+00	HtEtaHBVDN	EmIUBFwx0Z	4	3	4	4	1	\N	\N
j64R5pB1yZ	2024-02-16 00:21:51.907+00	2024-02-16 00:21:51.907+00	jqDYoPT45X	rKyjwoEIRp	2	4	0	4	3	\N	\N
M3329hncRN	2024-02-16 00:21:52.111+00	2024-02-16 00:21:52.111+00	5X202ssb0D	TCkiw6gTDz	4	0	0	3	1	\N	\N
xBdHIIPUCR	2024-02-16 00:21:52.317+00	2024-02-16 00:21:52.317+00	jqDYoPT45X	TZsdmscJ2B	3	0	1	4	3	\N	\N
kDLsoESTHs	2024-02-16 00:21:52.522+00	2024-02-16 00:21:52.522+00	sy1HD51LXT	G0uU7KQLEt	4	2	2	1	0	\N	\N
y0SkVC5cMk	2024-02-16 00:21:52.729+00	2024-02-16 00:21:52.729+00	jqDYoPT45X	bi1IivsuUB	3	4	0	3	1	\N	\N
C4QlfNNjJz	2024-02-16 00:21:52.938+00	2024-02-16 00:21:52.938+00	ONgyydfVNz	WnUBBkiDjE	0	2	4	1	0	\N	\N
gtkstjjAZz	2024-02-16 00:21:53.145+00	2024-02-16 00:21:53.145+00	NjxsGlPeB4	WHvlAGgj6c	1	1	3	0	0	\N	\N
oE1iDQ0yNg	2024-02-16 00:21:53.348+00	2024-02-16 00:21:53.348+00	iWxl9obi8w	P9sBFomftT	4	1	3	3	2	\N	\N
rnZIQsSOBm	2024-02-16 00:21:53.552+00	2024-02-16 00:21:53.552+00	1as6rMOzjQ	XwszrNEEEj	2	3	0	3	2	\N	\N
oCghZRJzVX	2024-02-16 00:21:54.169+00	2024-02-16 00:21:54.169+00	R2CLtFh5jU	XpUyRlB6FI	0	0	4	2	4	\N	\N
kR6WWyqsct	2024-02-16 00:21:54.378+00	2024-02-16 00:21:54.378+00	dZKm0wOhYa	BMLzFMvIT6	1	4	0	1	1	\N	\N
oWThTEbZpD	2024-02-16 00:21:54.586+00	2024-02-16 00:21:54.586+00	9223vtvaBd	JRi61dUphq	3	1	0	3	3	\N	\N
qUA30khNA2	2024-02-16 00:21:54.792+00	2024-02-16 00:21:54.792+00	AsrLUQwxI9	RBRcyltRSC	0	1	1	3	3	\N	\N
CAoNWEooMq	2024-02-16 00:21:54.997+00	2024-02-16 00:21:54.997+00	I5RzFRcQ7G	lEPdiO1EDi	2	3	1	2	0	\N	\N
wuXdYwsJWV	2024-02-16 00:21:55.202+00	2024-02-16 00:21:55.202+00	sy1HD51LXT	Pa0qBO2rzK	4	4	0	1	2	\N	\N
jvAtwE6EE6	2024-02-16 00:21:55.406+00	2024-02-16 00:21:55.406+00	VshUk7eBeK	M0tHrt1GgV	1	3	4	2	1	\N	\N
A5jmpV6Awq	2024-02-16 00:21:55.612+00	2024-02-16 00:21:55.612+00	NjxsGlPeB4	cmxBcanww9	2	1	3	1	0	\N	\N
PPl21khIzL	2024-02-16 00:21:55.818+00	2024-02-16 00:21:55.818+00	HtEtaHBVDN	o90lhsZ7FK	2	4	4	2	2	\N	\N
l8AxaQSZ9a	2024-02-16 00:21:56.027+00	2024-02-16 00:21:56.027+00	VshUk7eBeK	HXtEwLBC7f	3	4	2	1	1	\N	\N
SGDUi06PNb	2024-02-16 00:21:56.237+00	2024-02-16 00:21:56.237+00	iWxl9obi8w	cmxBcanww9	2	2	1	0	1	\N	\N
r2TxgghbYn	2024-02-16 00:21:56.446+00	2024-02-16 00:21:56.446+00	dZKm0wOhYa	M0tHrt1GgV	3	1	0	0	3	\N	\N
KDFo8g4Jjq	2024-02-16 00:21:56.652+00	2024-02-16 00:21:56.652+00	Otwj7uJwjr	Gl96vGdYHM	1	1	4	0	3	\N	\N
A1XeafybhG	2024-02-16 00:21:56.854+00	2024-02-16 00:21:56.854+00	9223vtvaBd	cFtamPA0zH	1	2	3	1	1	\N	\N
PQtE71Pbuv	2024-02-16 00:21:57.057+00	2024-02-16 00:21:57.057+00	HRhGpJpmb5	NBojpORh3G	1	0	0	0	0	\N	\N
hN1ZwECNlH	2024-02-16 00:21:57.261+00	2024-02-16 00:21:57.261+00	VshUk7eBeK	JZOBDAh12a	1	0	3	4	3	\N	\N
k6cdqjBfZX	2024-02-16 00:21:57.855+00	2024-02-16 00:21:57.855+00	WKpBp0c8F3	89xRG1afNi	2	0	4	0	2	\N	\N
X95u34CpFh	2024-02-16 00:21:58.163+00	2024-02-16 00:21:58.163+00	dEqAHvPMXA	NY6RE1qgWu	4	4	4	3	2	\N	\N
qtQ2iqdG2U	2024-02-16 00:21:58.367+00	2024-02-16 00:21:58.367+00	iUlyHNFGpG	TpGyMZM9BG	2	1	0	2	4	\N	\N
dOHzcUnm5q	2024-02-16 00:21:58.571+00	2024-02-16 00:21:58.571+00	AsrLUQwxI9	RkhjIQJgou	0	1	1	3	1	\N	\N
FOCT3NPtMf	2024-02-16 00:21:58.778+00	2024-02-16 00:21:58.778+00	dZKm0wOhYa	WBFeKac0OO	1	0	0	0	1	\N	\N
Xl3xXjFwJP	2024-02-16 00:21:58.984+00	2024-02-16 00:21:58.984+00	ONgyydfVNz	WSTLlXDcKl	4	3	0	2	2	\N	\N
v8K5Io8KW0	2024-02-16 00:21:59.289+00	2024-02-16 00:21:59.289+00	9223vtvaBd	P9sBFomftT	0	0	0	3	3	\N	\N
x4wyYbFx6O	2024-02-16 00:21:59.495+00	2024-02-16 00:21:59.495+00	S6wz0lK0bf	LgJuu5ABe5	3	2	3	0	1	\N	\N
1OdY5jlrc3	2024-02-16 00:21:59.699+00	2024-02-16 00:21:59.699+00	mAKp5BK7R1	M0tHrt1GgV	1	2	3	2	3	\N	\N
mKcRtC53tT	2024-02-16 00:21:59.903+00	2024-02-16 00:21:59.903+00	sy1HD51LXT	m6g8u0QpTC	0	1	2	1	2	\N	\N
UcZThjTAzz	2024-02-16 00:22:00.107+00	2024-02-16 00:22:00.107+00	sy1HD51LXT	JZOBDAh12a	4	1	0	1	1	\N	\N
W5fpSLWTCj	2024-02-16 00:22:00.312+00	2024-02-16 00:22:00.312+00	AsrLUQwxI9	XSK814B37m	2	0	0	2	2	\N	\N
eE7TC2G1k4	2024-02-16 00:22:00.52+00	2024-02-16 00:22:00.52+00	ONgyydfVNz	eEmewy7hPd	0	2	2	1	4	\N	\N
ceQBSxyvu2	2024-02-16 00:22:01.129+00	2024-02-16 00:22:01.129+00	dEqAHvPMXA	FYXEfIO1zF	0	3	0	0	1	\N	\N
3zWP3XkVT8	2024-02-16 00:22:01.336+00	2024-02-16 00:22:01.336+00	dZKm0wOhYa	oABNR2FF6S	0	4	4	0	1	\N	\N
5V06BzFK0x	2024-02-16 00:22:01.951+00	2024-02-16 00:22:01.951+00	AsrLUQwxI9	XSK814B37m	1	1	4	1	2	\N	\N
kDlDSTnoDo	2024-02-16 00:22:02.155+00	2024-02-16 00:22:02.155+00	sHiqaG4iqY	cTIjuPjyIa	0	1	2	0	4	\N	\N
qpH4uAzkoN	2024-02-16 00:22:02.359+00	2024-02-16 00:22:02.359+00	9223vtvaBd	JLhF4VuByh	3	3	2	3	2	\N	\N
bsiHc8qDxc	2024-02-16 00:22:02.564+00	2024-02-16 00:22:02.564+00	S6wz0lK0bf	9GF3y7LmHV	3	4	3	0	0	\N	\N
ff8zxaajY2	2024-02-16 00:22:02.769+00	2024-02-16 00:22:02.769+00	dEqAHvPMXA	0TvWuLoLF5	4	1	1	4	3	\N	\N
yU51xQgtGC	2024-02-16 00:22:02.969+00	2024-02-16 00:22:02.969+00	VshUk7eBeK	VK3vnSxIy8	1	2	1	4	4	\N	\N
edzMoYoMeK	2024-02-16 00:22:03.175+00	2024-02-16 00:22:03.175+00	opW2wQ2bZ8	e037qpAih3	0	3	1	1	4	\N	\N
x6yCULU5Mc	2024-02-16 00:22:03.38+00	2024-02-16 00:22:03.38+00	opW2wQ2bZ8	3P6kmNoY1F	4	4	2	0	4	\N	\N
gNNWP39Wu5	2024-02-16 00:22:03.59+00	2024-02-16 00:22:03.59+00	mAKp5BK7R1	uABtFsJhJc	4	2	3	3	2	\N	\N
xpjBALAjuz	2024-02-16 00:22:03.798+00	2024-02-16 00:22:03.798+00	Otwj7uJwjr	axyV0Fu7pm	4	1	4	2	4	\N	\N
5sDVM6iAuj	2024-02-16 00:22:04.006+00	2024-02-16 00:22:04.006+00	R2CLtFh5jU	LDrIH1vU8x	0	4	2	4	3	\N	\N
Ny4qdv25kJ	2024-02-16 00:22:04.211+00	2024-02-16 00:22:04.211+00	dEqAHvPMXA	JZOBDAh12a	1	4	2	0	2	\N	\N
b6sQsRPffn	2024-02-16 00:22:04.418+00	2024-02-16 00:22:04.418+00	opW2wQ2bZ8	y4RkaDbkec	0	0	0	4	4	\N	\N
zNFfa8NKxn	2024-02-16 00:22:05.024+00	2024-02-16 00:22:05.024+00	5nv19u6KJ2	JZOBDAh12a	0	1	2	4	0	\N	\N
WBH1i8CNPE	2024-02-16 00:22:05.226+00	2024-02-16 00:22:05.226+00	opW2wQ2bZ8	y4RkaDbkec	1	1	2	3	4	\N	\N
pWmFjPMuWt	2024-02-16 00:22:05.431+00	2024-02-16 00:22:05.431+00	NjxsGlPeB4	UCFo58JaaD	1	0	4	0	3	\N	\N
Ez0LqYvovL	2024-02-16 00:22:05.637+00	2024-02-16 00:22:05.637+00	SFAISec8QF	axyV0Fu7pm	1	1	1	3	0	\N	\N
g7pWxnfQSj	2024-02-16 00:22:05.854+00	2024-02-16 00:22:05.854+00	5nv19u6KJ2	RBRcyltRSC	3	3	1	0	1	\N	\N
C7wfWu0PVP	2024-02-16 00:22:06.063+00	2024-02-16 00:22:06.063+00	9223vtvaBd	tCIEnLLcUc	1	3	2	4	2	\N	\N
4bCtMbsutK	2024-02-16 00:22:06.266+00	2024-02-16 00:22:06.266+00	R2CLtFh5jU	fwLPZZ8YQa	3	0	1	4	0	\N	\N
PdTV0RCsTu	2024-02-16 00:22:06.47+00	2024-02-16 00:22:06.47+00	dZKm0wOhYa	HSEugQ3Ouj	1	4	3	0	1	\N	\N
MedbDz0Pov	2024-02-16 00:22:06.674+00	2024-02-16 00:22:06.674+00	1as6rMOzjQ	HSEugQ3Ouj	2	1	0	2	1	\N	\N
YGC59EwTel	2024-02-16 00:22:06.878+00	2024-02-16 00:22:06.878+00	Otwj7uJwjr	LgJuu5ABe5	2	4	2	4	3	\N	\N
JyxMq1up3U	2024-02-16 00:22:07.175+00	2024-02-16 00:22:07.175+00	sHiqaG4iqY	o4VD4BWwDt	4	3	0	4	3	\N	\N
ZygCW7iBOw	2024-02-16 00:22:07.382+00	2024-02-16 00:22:07.382+00	HtEtaHBVDN	qEQ9tmLyW9	0	3	4	0	4	\N	\N
NSKnnxHF4B	2024-02-16 00:22:07.585+00	2024-02-16 00:22:07.585+00	Otwj7uJwjr	fxvABtKCPT	0	3	1	0	1	\N	\N
Jy62H82i8n	2024-02-16 00:22:07.788+00	2024-02-16 00:22:07.788+00	RWwLSzreG2	INeptnSdJC	1	1	3	0	1	\N	\N
XekdwXG0w9	2024-02-16 00:22:08.2+00	2024-02-16 00:22:08.2+00	5nv19u6KJ2	WSTLlXDcKl	0	4	2	0	1	\N	\N
386ees3GzK	2024-02-16 00:22:08.813+00	2024-02-16 00:22:08.813+00	HRhGpJpmb5	HLIPwAqO2R	2	1	0	2	3	\N	\N
jhmkldEVDr	2024-02-16 00:22:09.02+00	2024-02-16 00:22:09.02+00	HRhGpJpmb5	HSEugQ3Ouj	4	4	1	1	2	\N	\N
7ZZEREV79U	2024-02-16 00:22:09.226+00	2024-02-16 00:22:09.226+00	iWxl9obi8w	eEmewy7hPd	3	0	0	2	2	\N	\N
nEVBYvDNiH	2024-02-16 00:22:09.837+00	2024-02-16 00:22:09.837+00	adE9nQrDk3	cFtamPA0zH	1	4	2	2	1	\N	\N
52nr6Uihkb	2024-02-16 00:22:10.042+00	2024-02-16 00:22:10.042+00	adE9nQrDk3	y4RkaDbkec	4	2	4	4	0	\N	\N
D868xem9At	2024-02-16 00:22:10.35+00	2024-02-16 00:22:10.35+00	WKpBp0c8F3	RkhjIQJgou	3	1	3	3	0	\N	\N
Bfap4ayr2k	2024-02-16 00:22:10.558+00	2024-02-16 00:22:10.558+00	dEqAHvPMXA	qEQ9tmLyW9	3	2	0	2	3	\N	\N
Sl8NHEr4QG	2024-02-16 00:22:10.763+00	2024-02-16 00:22:10.763+00	AsrLUQwxI9	RBRcyltRSC	3	1	0	2	1	\N	\N
PI3mWRaSjB	2024-02-16 00:22:11.066+00	2024-02-16 00:22:11.066+00	mAKp5BK7R1	qZmnAnnPEb	1	0	3	1	3	\N	\N
wDwBGlthCb	2024-02-16 00:22:11.27+00	2024-02-16 00:22:11.27+00	adE9nQrDk3	l1Bslv8T2k	2	0	4	1	4	\N	\N
P1yzfdsgmK	2024-02-16 00:22:11.476+00	2024-02-16 00:22:11.476+00	1as6rMOzjQ	6KvFK8yy1q	0	1	4	1	2	\N	\N
Q76dnSHOVN	2024-02-16 00:22:11.681+00	2024-02-16 00:22:11.681+00	I5RzFRcQ7G	qP3EdIVzfB	3	3	2	1	0	\N	\N
MZFhHOzfwz	2024-02-16 00:22:11.885+00	2024-02-16 00:22:11.885+00	RWwLSzreG2	OQWu2bnHeC	4	3	2	2	1	\N	\N
KB7hetmqYr	2024-02-16 00:22:12.091+00	2024-02-16 00:22:12.091+00	RWwLSzreG2	oABNR2FF6S	2	2	2	1	1	\N	\N
WH9UF1zjEP	2024-02-16 00:22:12.301+00	2024-02-16 00:22:12.301+00	NjxsGlPeB4	TZsdmscJ2B	2	0	4	1	1	\N	\N
MmFultbAzz	2024-02-16 00:22:12.909+00	2024-02-16 00:22:12.909+00	Otwj7uJwjr	uigc7bJBOJ	2	0	4	1	1	\N	\N
RaNQZ7Czl5	2024-02-16 00:22:13.115+00	2024-02-16 00:22:13.115+00	iUlyHNFGpG	rKyjwoEIRp	0	0	2	3	2	\N	\N
sEqn2Uuqwu	2024-02-16 00:22:13.318+00	2024-02-16 00:22:13.318+00	VshUk7eBeK	KCsJ4XR6Dn	0	3	2	3	1	\N	\N
TjtoqSKTKP	2024-02-16 00:22:13.522+00	2024-02-16 00:22:13.522+00	iWxl9obi8w	cTIjuPjyIa	2	4	1	1	4	\N	\N
VdGVIxHJZ8	2024-02-16 00:22:13.726+00	2024-02-16 00:22:13.726+00	NjxsGlPeB4	FJOTueDfs2	0	3	0	3	4	\N	\N
tJJCPoVag5	2024-02-16 00:22:13.931+00	2024-02-16 00:22:13.931+00	NjxsGlPeB4	UCFo58JaaD	2	1	3	0	4	\N	\N
wb3EK9MFLr	2024-02-16 00:22:14.136+00	2024-02-16 00:22:14.136+00	dEqAHvPMXA	Pja6n3yaWZ	2	0	2	1	4	\N	\N
ASDi3yWsIB	2024-02-16 00:22:14.446+00	2024-02-16 00:22:14.446+00	adE9nQrDk3	bi1IivsuUB	4	3	2	1	3	\N	\N
ei5u9spJYI	2024-02-16 00:22:15.061+00	2024-02-16 00:22:15.061+00	5nv19u6KJ2	y4RkaDbkec	2	1	3	4	2	\N	\N
zEJCAvCMYs	2024-02-16 00:22:15.264+00	2024-02-16 00:22:15.264+00	RWwLSzreG2	AgU9OLJkqz	2	2	4	1	3	\N	\N
W2DaIXWViO	2024-02-16 00:22:15.467+00	2024-02-16 00:22:15.467+00	adE9nQrDk3	qP3EdIVzfB	4	3	3	1	2	\N	\N
eJ1EicfMFa	2024-02-16 00:22:15.672+00	2024-02-16 00:22:15.672+00	AsrLUQwxI9	JLhF4VuByh	1	3	1	4	0	\N	\N
d61yhJF8Wn	2024-02-16 00:22:15.879+00	2024-02-16 00:22:15.879+00	5nv19u6KJ2	H40ivltLwZ	0	1	1	4	3	\N	\N
Mygl6C7dJV	2024-02-16 00:22:16.185+00	2024-02-16 00:22:16.185+00	WKpBp0c8F3	na5crB8ED1	0	1	3	4	0	\N	\N
MqHsSfUMJm	2024-02-16 00:22:16.39+00	2024-02-16 00:22:16.39+00	SFAISec8QF	FYXEfIO1zF	1	2	1	4	1	\N	\N
eam5dhc6VZ	2024-02-16 00:22:16.596+00	2024-02-16 00:22:16.596+00	iWxl9obi8w	RkhjIQJgou	0	0	3	4	2	\N	\N
byRjHlTqUV	2024-02-16 00:22:16.802+00	2024-02-16 00:22:16.802+00	1as6rMOzjQ	Pa0qBO2rzK	0	4	3	3	2	\N	\N
wJ3lfXtSdw	2024-02-16 00:22:17.108+00	2024-02-16 00:22:17.108+00	AsrLUQwxI9	NY6RE1qgWu	2	2	0	2	1	\N	\N
NMwdzY57BC	2024-02-16 00:22:17.317+00	2024-02-16 00:22:17.317+00	5X202ssb0D	9GF3y7LmHV	1	0	0	3	3	\N	\N
OEi1cZU8Pf	2024-02-16 00:22:17.523+00	2024-02-16 00:22:17.523+00	sy1HD51LXT	IEqTHcohpJ	3	2	0	3	1	\N	\N
S1pFKkWOYJ	2024-02-16 00:22:17.727+00	2024-02-16 00:22:17.727+00	RWwLSzreG2	Pja6n3yaWZ	4	2	2	0	4	\N	\N
n4AS2Dylvc	2024-02-16 00:22:17.932+00	2024-02-16 00:22:17.932+00	mQXQWNqxg9	WBFeKac0OO	4	4	1	1	4	\N	\N
V5K1xlfxZ4	2024-02-16 00:22:18.137+00	2024-02-16 00:22:18.137+00	AsrLUQwxI9	FYXEfIO1zF	0	0	3	1	0	\N	\N
RwHT0R0bAl	2024-02-16 00:22:18.44+00	2024-02-16 00:22:18.44+00	S6wz0lK0bf	CSvk1ycWXk	3	2	0	2	2	\N	\N
hXwxku1AFE	2024-02-16 00:22:18.642+00	2024-02-16 00:22:18.642+00	VshUk7eBeK	NBojpORh3G	2	3	4	1	3	\N	\N
A5bza8qL1l	2024-02-16 00:22:18.849+00	2024-02-16 00:22:18.849+00	5nv19u6KJ2	uABtFsJhJc	3	1	2	4	3	\N	\N
4dDxtHq8pv	2024-02-16 00:22:19.059+00	2024-02-16 00:22:19.059+00	NjxsGlPeB4	C7II8dYRPY	4	3	1	3	1	\N	\N
G31fqitbqX	2024-02-16 00:22:19.362+00	2024-02-16 00:22:19.362+00	HtEtaHBVDN	WBFeKac0OO	4	2	4	0	0	\N	\N
xYeBhcDCHu	2024-02-16 00:22:19.566+00	2024-02-16 00:22:19.566+00	mAKp5BK7R1	Oahm9sOn1y	0	2	1	0	4	\N	\N
DY6BAR0blg	2024-02-16 00:22:19.772+00	2024-02-16 00:22:19.772+00	SFAISec8QF	rKyjwoEIRp	1	4	3	1	0	\N	\N
Hw3gfFxfpK	2024-02-16 00:22:20.385+00	2024-02-16 00:22:20.385+00	mQXQWNqxg9	LDrIH1vU8x	1	2	4	1	3	\N	\N
ABplvDZrip	2024-02-16 00:22:20.588+00	2024-02-16 00:22:20.588+00	WKpBp0c8F3	LVYK4mLShP	2	4	2	4	4	\N	\N
XMIjVmWYLL	2024-02-16 00:22:20.795+00	2024-02-16 00:22:20.795+00	5nv19u6KJ2	WBFeKac0OO	2	0	2	1	3	\N	\N
7HSeApJNhL	2024-02-16 00:22:21.098+00	2024-02-16 00:22:21.098+00	WKpBp0c8F3	fxvABtKCPT	2	4	3	1	2	\N	\N
jseRLuSUAG	2024-02-16 00:22:21.41+00	2024-02-16 00:22:21.41+00	jqDYoPT45X	Gl96vGdYHM	3	2	3	3	3	\N	\N
x7cKpBn4vM	2024-02-16 00:22:22.024+00	2024-02-16 00:22:22.024+00	RWwLSzreG2	KCsJ4XR6Dn	4	2	3	2	0	\N	\N
XSVdPbCrGW	2024-02-16 00:22:22.23+00	2024-02-16 00:22:22.23+00	S6wz0lK0bf	o4VD4BWwDt	1	3	0	2	4	\N	\N
oKo8qC11Pu	2024-02-16 00:22:22.434+00	2024-02-16 00:22:22.434+00	AsrLUQwxI9	JRi61dUphq	2	0	2	3	0	\N	\N
dON8plPD0f	2024-02-16 00:22:22.637+00	2024-02-16 00:22:22.637+00	5nv19u6KJ2	uigc7bJBOJ	3	1	2	0	0	\N	\N
Q1SH23pDZW	2024-02-16 00:22:22.841+00	2024-02-16 00:22:22.841+00	sHiqaG4iqY	tCIEnLLcUc	4	1	1	3	4	\N	\N
jlBDBXGGnE	2024-02-16 00:22:23.151+00	2024-02-16 00:22:23.151+00	1as6rMOzjQ	e037qpAih3	0	0	3	4	3	\N	\N
cixUSYgMeG	2024-02-16 00:22:23.355+00	2024-02-16 00:22:23.355+00	Otwj7uJwjr	tCIEnLLcUc	4	2	1	4	2	\N	\N
IiocFjLXsk	2024-02-16 00:22:23.559+00	2024-02-16 00:22:23.559+00	AsrLUQwxI9	XwWwGnkXNj	1	4	1	3	0	\N	\N
Gp0f5Kf7tb	2024-02-16 00:22:23.766+00	2024-02-16 00:22:23.766+00	S6wz0lK0bf	yvUod6yLDt	1	1	0	2	2	\N	\N
RnCsqKJANa	2024-02-16 00:22:23.971+00	2024-02-16 00:22:23.971+00	5nv19u6KJ2	89xRG1afNi	4	1	2	3	2	\N	\N
zc8Nu6DAVA	2024-02-16 00:22:24.174+00	2024-02-16 00:22:24.174+00	AsrLUQwxI9	XpUyRlB6FI	2	2	3	1	4	\N	\N
yf3jtOLVsU	2024-02-16 00:22:24.789+00	2024-02-16 00:22:24.789+00	9223vtvaBd	WnUBBkiDjE	4	3	2	1	0	\N	\N
ff7bFThl1v	2024-02-16 00:22:24.996+00	2024-02-16 00:22:24.996+00	HtEtaHBVDN	UCFo58JaaD	3	0	0	4	0	\N	\N
LYz02t7Ekd	2024-02-16 00:22:25.301+00	2024-02-16 00:22:25.301+00	iUlyHNFGpG	Pa0qBO2rzK	3	3	2	2	1	\N	\N
maFlBWDpLx	2024-02-16 00:22:25.916+00	2024-02-16 00:22:25.916+00	SFAISec8QF	JZOBDAh12a	1	2	4	3	0	\N	\N
RyvPp9mGOq	2024-02-16 00:22:26.121+00	2024-02-16 00:22:26.121+00	SFAISec8QF	tCIEnLLcUc	3	1	4	0	3	\N	\N
xHcMc2INRm	2024-02-16 00:22:26.428+00	2024-02-16 00:22:26.428+00	SFAISec8QF	o4VD4BWwDt	0	1	4	4	2	\N	\N
ZS0JjX9TAP	2024-02-16 00:22:26.64+00	2024-02-16 00:22:26.64+00	5nv19u6KJ2	KCsJ4XR6Dn	4	1	0	1	0	\N	\N
FWCWbs6E4J	2024-02-16 00:22:26.848+00	2024-02-16 00:22:26.848+00	R2CLtFh5jU	FJOTueDfs2	2	0	3	1	1	\N	\N
eweYI1Futi	2024-02-16 00:22:27.144+00	2024-02-16 00:22:27.144+00	jqDYoPT45X	uABtFsJhJc	0	3	1	4	4	\N	\N
FIIihN5MZa	2024-02-16 00:22:27.349+00	2024-02-16 00:22:27.349+00	NjxsGlPeB4	HSEugQ3Ouj	3	3	2	1	4	\N	\N
lQb0UJlT21	2024-02-16 00:22:27.555+00	2024-02-16 00:22:27.555+00	opW2wQ2bZ8	Pja6n3yaWZ	2	0	0	0	3	\N	\N
CFVmKWcq1G	2024-02-16 00:22:27.982+00	2024-02-16 00:22:27.982+00	AsrLUQwxI9	jHqCpA1nWb	0	3	0	2	2	\N	\N
wBcPwQkFlE	2024-02-16 00:22:28.185+00	2024-02-16 00:22:28.185+00	R2CLtFh5jU	KCsJ4XR6Dn	0	4	2	2	1	\N	\N
2HkPFjClnf	2024-02-16 00:22:28.391+00	2024-02-16 00:22:28.391+00	5X202ssb0D	D0A6GLdsDM	1	2	2	1	0	\N	\N
KHkYSonIDZ	2024-02-16 00:22:28.596+00	2024-02-16 00:22:28.596+00	dZKm0wOhYa	VK3vnSxIy8	3	2	1	4	4	\N	\N
u8Ojhxwnqf	2024-02-16 00:22:28.885+00	2024-02-16 00:22:28.885+00	sy1HD51LXT	IEqTHcohpJ	3	3	4	0	0	\N	\N
QliJMCh3dv	2024-02-16 00:22:29.094+00	2024-02-16 00:22:29.094+00	I5RzFRcQ7G	C7II8dYRPY	0	1	0	4	4	\N	\N
okqFvqH5Fb	2024-02-16 00:22:29.302+00	2024-02-16 00:22:29.302+00	I5RzFRcQ7G	qEQ9tmLyW9	3	4	0	4	3	\N	\N
0JIh23GVDQ	2024-02-16 00:22:29.603+00	2024-02-16 00:22:29.603+00	iUlyHNFGpG	m8hjjLVdPS	4	4	1	2	0	\N	\N
93QpHytj47	2024-02-16 00:22:29.909+00	2024-02-16 00:22:29.909+00	sHiqaG4iqY	JRi61dUphq	3	1	2	1	1	\N	\N
FM03fksfAo	2024-02-16 00:22:30.118+00	2024-02-16 00:22:30.118+00	opW2wQ2bZ8	H40ivltLwZ	3	0	0	1	3	\N	\N
AnEfE3CyjP	2024-02-16 00:22:30.324+00	2024-02-16 00:22:30.324+00	R2CLtFh5jU	RBRcyltRSC	4	2	0	4	2	\N	\N
0bIghWRvvq	2024-02-16 00:22:30.528+00	2024-02-16 00:22:30.528+00	jqDYoPT45X	lxQA9rtSfY	1	2	3	1	2	\N	\N
phIlT0N1dJ	2024-02-16 00:22:30.733+00	2024-02-16 00:22:30.733+00	sy1HD51LXT	JZOBDAh12a	4	3	1	2	0	\N	\N
wgtOSSf02q	2024-02-16 00:22:30.939+00	2024-02-16 00:22:30.939+00	SFAISec8QF	RkhjIQJgou	3	2	0	3	1	\N	\N
vsG0Fe6XwG	2024-02-16 00:22:31.241+00	2024-02-16 00:22:31.241+00	HtEtaHBVDN	XwszrNEEEj	0	1	2	2	0	\N	\N
P39sD5MQeK	2024-02-16 00:22:31.547+00	2024-02-16 00:22:31.547+00	HtEtaHBVDN	eEmewy7hPd	1	2	4	4	2	\N	\N
eZvqO0oKgn	2024-02-16 00:22:31.855+00	2024-02-16 00:22:31.855+00	NjxsGlPeB4	lEPdiO1EDi	4	0	1	1	0	\N	\N
1DCJ2AHBaE	2024-02-16 00:22:32.062+00	2024-02-16 00:22:32.062+00	ONgyydfVNz	HXtEwLBC7f	1	1	4	3	4	\N	\N
0Yv6kmKiUR	2024-02-16 00:22:32.676+00	2024-02-16 00:22:32.676+00	5nv19u6KJ2	P9sBFomftT	2	1	1	2	0	\N	\N
jV8OgzMWlR	2024-02-16 00:22:32.981+00	2024-02-16 00:22:32.981+00	ONgyydfVNz	3P6kmNoY1F	2	3	0	3	4	\N	\N
SIMCLSROmx	2024-02-16 00:22:33.193+00	2024-02-16 00:22:33.193+00	dZKm0wOhYa	G0uU7KQLEt	4	4	4	1	1	\N	\N
ZAGzOox9Tk	2024-02-16 00:22:33.401+00	2024-02-16 00:22:33.401+00	sHiqaG4iqY	NBojpORh3G	2	3	4	1	0	\N	\N
QX0s2lgwEn	2024-02-16 00:22:33.608+00	2024-02-16 00:22:33.608+00	Otwj7uJwjr	oABNR2FF6S	1	2	1	2	0	\N	\N
gDsg9xEJoE	2024-02-16 00:22:33.815+00	2024-02-16 00:22:33.815+00	iUlyHNFGpG	cmxBcanww9	2	3	1	1	3	\N	\N
st1PTkYAfS	2024-02-16 00:22:34.022+00	2024-02-16 00:22:34.022+00	mQXQWNqxg9	o4VD4BWwDt	0	4	0	0	0	\N	\N
c8JMAK7RqN	2024-02-16 00:22:34.415+00	2024-02-16 00:22:34.415+00	sy1HD51LXT	G0uU7KQLEt	2	3	3	3	1	\N	\N
BCrgJVWqns	2024-02-16 00:22:34.722+00	2024-02-16 00:22:34.722+00	WKpBp0c8F3	jjVdtithcD	0	0	0	4	1	\N	\N
rAswGxAkRG	2024-02-16 00:22:34.928+00	2024-02-16 00:22:34.928+00	9223vtvaBd	jjVdtithcD	2	3	0	3	4	\N	\N
oa6uKUAcNe	2024-02-16 00:22:35.133+00	2024-02-16 00:22:35.133+00	opW2wQ2bZ8	C7II8dYRPY	4	4	0	4	2	\N	\N
2XQUNE8xHc	2024-02-16 00:22:35.338+00	2024-02-16 00:22:35.338+00	dEqAHvPMXA	3u4B9V4l5K	0	2	3	4	0	\N	\N
MKDxSmeLTo	2024-02-16 00:22:35.543+00	2024-02-16 00:22:35.543+00	9223vtvaBd	y4RkaDbkec	3	3	0	0	0	\N	\N
XR3761e9rT	2024-02-16 00:22:36.152+00	2024-02-16 00:22:36.152+00	adE9nQrDk3	6Fo67rhTSP	0	2	1	2	1	\N	\N
BoVaBLf2VG	2024-02-16 00:22:36.356+00	2024-02-16 00:22:36.356+00	RWwLSzreG2	WnUBBkiDjE	4	4	0	4	4	\N	\N
bqU9Cyd06e	2024-02-16 00:22:36.563+00	2024-02-16 00:22:36.563+00	5X202ssb0D	Oahm9sOn1y	1	2	0	3	4	\N	\N
1aPNDrF2U9	2024-02-16 00:22:36.767+00	2024-02-16 00:22:36.767+00	NjxsGlPeB4	Pa0qBO2rzK	4	0	4	0	0	\N	\N
jCrOHlCq8K	2024-02-16 00:22:36.977+00	2024-02-16 00:22:36.977+00	dEqAHvPMXA	LVYK4mLShP	0	4	0	0	0	\N	\N
vAYcNqGc5k	2024-02-16 00:22:37.183+00	2024-02-16 00:22:37.183+00	sHiqaG4iqY	CSvk1ycWXk	3	2	2	4	3	\N	\N
GzBlBNGYoH	2024-02-16 00:22:37.391+00	2024-02-16 00:22:37.391+00	jqDYoPT45X	UDXF0qXvDY	2	0	3	4	0	\N	\N
IiK24GRNoh	2024-02-16 00:22:37.601+00	2024-02-16 00:22:37.601+00	5X202ssb0D	Gl96vGdYHM	2	3	3	1	1	\N	\N
AbdyoDksjE	2024-02-16 00:22:37.898+00	2024-02-16 00:22:37.898+00	R2CLtFh5jU	3P6kmNoY1F	1	3	3	3	3	\N	\N
GUusHvdKih	2024-02-16 00:22:38.335+00	2024-02-16 00:22:38.335+00	mQXQWNqxg9	j0dWqP2C2A	0	2	4	4	2	\N	\N
EDMZ2l1vxH	2024-02-16 00:22:38.542+00	2024-02-16 00:22:38.542+00	mAKp5BK7R1	fKTSJPdUi9	3	1	4	4	1	\N	\N
SHtGC6TUFm	2024-02-16 00:22:38.749+00	2024-02-16 00:22:38.749+00	NjxsGlPeB4	8w7i8C3NnT	4	3	1	1	1	\N	\N
tMrbqJ9Z92	2024-02-16 00:22:38.956+00	2024-02-16 00:22:38.956+00	iUlyHNFGpG	u5FXeeOChJ	4	2	0	1	3	\N	\N
N5xXXCIguo	2024-02-16 00:22:39.229+00	2024-02-16 00:22:39.229+00	mQXQWNqxg9	NBojpORh3G	2	1	0	2	2	\N	\N
CWThDHFGiC	2024-02-16 00:22:39.536+00	2024-02-16 00:22:39.536+00	R2CLtFh5jU	bQ0JOk10eL	3	0	2	1	1	\N	\N
qLfdVbiMK1	2024-02-16 00:22:39.74+00	2024-02-16 00:22:39.74+00	adE9nQrDk3	C7II8dYRPY	0	0	4	3	1	\N	\N
8Elvx4fNEt	2024-02-16 00:22:40.048+00	2024-02-16 00:22:40.048+00	dEqAHvPMXA	rT0UCBK1bE	4	4	1	3	2	\N	\N
RIFVIFEFxF	2024-02-16 00:22:40.253+00	2024-02-16 00:22:40.253+00	sHiqaG4iqY	BMLzFMvIT6	1	1	1	1	0	\N	\N
XaiXO9buD1	2024-02-16 00:22:40.56+00	2024-02-16 00:22:40.56+00	dEqAHvPMXA	na5crB8ED1	3	2	0	4	4	\N	\N
nZq3KV1UrF	2024-02-16 00:22:40.768+00	2024-02-16 00:22:40.768+00	opW2wQ2bZ8	lEPdiO1EDi	4	3	3	0	4	\N	\N
YatqO0Mxxx	2024-02-16 00:22:40.975+00	2024-02-16 00:22:40.975+00	RWwLSzreG2	E2hBZzDsjO	2	4	1	1	3	\N	\N
7NOO4Bb12F	2024-02-16 00:22:41.177+00	2024-02-16 00:22:41.177+00	dEqAHvPMXA	cFtamPA0zH	3	0	3	1	0	\N	\N
dZ4DswRtDO	2024-02-16 00:22:41.382+00	2024-02-16 00:22:41.382+00	sy1HD51LXT	IEqTHcohpJ	0	4	1	2	2	\N	\N
F5FBT8STry	2024-02-16 00:22:41.993+00	2024-02-16 00:22:41.993+00	S6wz0lK0bf	JLhF4VuByh	4	2	4	3	4	\N	\N
TACjjIyoa4	2024-02-16 00:22:42.302+00	2024-02-16 00:22:42.302+00	5X202ssb0D	bQ0JOk10eL	4	1	2	2	0	\N	\N
jq7ptB6laa	2024-02-16 00:22:42.511+00	2024-02-16 00:22:42.511+00	9223vtvaBd	Pa0qBO2rzK	3	4	2	2	3	\N	\N
OXSVC3mhAF	2024-02-16 00:22:42.813+00	2024-02-16 00:22:42.813+00	RWwLSzreG2	rT0UCBK1bE	0	1	3	4	3	\N	\N
5XmA7Zog7Y	2024-02-16 00:22:43.426+00	2024-02-16 00:22:43.426+00	ONgyydfVNz	na5crB8ED1	4	2	3	4	1	\N	\N
ZGFz1QhBOY	2024-02-16 00:22:43.633+00	2024-02-16 00:22:43.633+00	I5RzFRcQ7G	LgJuu5ABe5	2	0	2	2	2	\N	\N
KGoFIGbCZn	2024-02-16 00:22:44.246+00	2024-02-16 00:22:44.246+00	NjxsGlPeB4	fKTSJPdUi9	2	4	0	2	0	\N	\N
RDbFSs9nam	2024-02-16 00:22:44.452+00	2024-02-16 00:22:44.452+00	WKpBp0c8F3	M0tHrt1GgV	1	0	1	1	1	\N	\N
uFryfwHaEU	2024-02-16 00:22:45.066+00	2024-02-16 00:22:45.066+00	1as6rMOzjQ	uigc7bJBOJ	4	2	1	3	4	\N	\N
YLytu7u7KB	2024-02-16 00:22:45.271+00	2024-02-16 00:22:45.271+00	RWwLSzreG2	cTIjuPjyIa	3	4	3	0	0	\N	\N
HkG2YDaBKO	2024-02-16 00:22:45.477+00	2024-02-16 00:22:45.477+00	Otwj7uJwjr	m8hjjLVdPS	2	0	1	4	1	\N	\N
0oBTAR1Ram	2024-02-16 00:22:46.09+00	2024-02-16 00:22:46.09+00	5nv19u6KJ2	UDXF0qXvDY	2	1	4	0	1	\N	\N
ludY7uIn76	2024-02-16 00:22:46.397+00	2024-02-16 00:22:46.397+00	WKpBp0c8F3	na5crB8ED1	4	1	0	3	2	\N	\N
MrF6ImLyb6	2024-02-16 00:22:46.608+00	2024-02-16 00:22:46.608+00	iUlyHNFGpG	cmxBcanww9	3	2	0	3	2	\N	\N
mdWqG4M3ab	2024-02-16 00:22:46.815+00	2024-02-16 00:22:46.815+00	5nv19u6KJ2	Pa0qBO2rzK	4	4	2	1	2	\N	\N
2RTS4i8BKM	2024-02-16 00:22:47.024+00	2024-02-16 00:22:47.024+00	5nv19u6KJ2	AgU9OLJkqz	2	1	0	0	4	\N	\N
qu24BposKm	2024-02-16 00:22:47.231+00	2024-02-16 00:22:47.231+00	HRhGpJpmb5	qP3EdIVzfB	2	0	0	1	1	\N	\N
c83hxc5iWs	2024-02-16 00:22:47.439+00	2024-02-16 00:22:47.439+00	sHiqaG4iqY	VK3vnSxIy8	4	2	3	3	2	\N	\N
tVaaSsTyJZ	2024-02-16 00:22:47.728+00	2024-02-16 00:22:47.728+00	9223vtvaBd	WBFeKac0OO	1	2	2	0	2	\N	\N
BiXWOBU3u9	2024-02-16 00:22:47.933+00	2024-02-16 00:22:47.933+00	HRhGpJpmb5	uABtFsJhJc	3	2	0	1	2	\N	\N
5S0BPElFRZ	2024-02-16 00:22:48.139+00	2024-02-16 00:22:48.139+00	adE9nQrDk3	Oahm9sOn1y	3	4	4	3	4	\N	\N
Wft3q0gQlV	2024-02-16 00:22:48.447+00	2024-02-16 00:22:48.447+00	9223vtvaBd	D0A6GLdsDM	4	0	4	1	2	\N	\N
Nq6RYtkpLx	2024-02-16 00:22:48.856+00	2024-02-16 00:22:48.856+00	mQXQWNqxg9	bi1IivsuUB	0	4	4	2	2	\N	\N
lU7fKuLH1z	2024-02-16 00:22:49.276+00	2024-02-16 00:22:49.276+00	iUlyHNFGpG	MQfxuw3ERg	1	4	1	2	1	\N	\N
sxqfpDsru9	2024-02-16 00:22:49.879+00	2024-02-16 00:22:49.879+00	Otwj7uJwjr	j0dWqP2C2A	3	0	4	2	4	\N	\N
kCovsxYkGo	2024-02-16 00:22:50.596+00	2024-02-16 00:22:50.596+00	dEqAHvPMXA	WHvlAGgj6c	3	4	3	0	2	\N	\N
69tPHDACBc	2024-02-16 00:22:51.109+00	2024-02-16 00:22:51.109+00	iUlyHNFGpG	XwWwGnkXNj	3	2	1	2	3	\N	\N
YTLEs7E9mh	2024-02-16 00:22:51.721+00	2024-02-16 00:22:51.721+00	5nv19u6KJ2	fKTSJPdUi9	0	1	0	2	0	\N	\N
EvZL1AedC9	2024-02-16 00:22:52.029+00	2024-02-16 00:22:52.029+00	9223vtvaBd	tCIEnLLcUc	4	1	2	2	3	\N	\N
SlIZF1oB9N	2024-02-16 00:22:52.745+00	2024-02-16 00:22:52.745+00	opW2wQ2bZ8	P9sBFomftT	0	0	3	4	2	\N	\N
Z5VVXTSGQ8	2024-02-16 00:22:53.258+00	2024-02-16 00:22:53.258+00	jqDYoPT45X	e037qpAih3	4	0	1	1	4	\N	\N
KZeobO5CwS	2024-02-16 00:22:53.975+00	2024-02-16 00:22:53.975+00	NjxsGlPeB4	fKTSJPdUi9	4	4	1	0	1	\N	\N
LINsT0rzhc	2024-02-16 00:22:54.589+00	2024-02-16 00:22:54.589+00	opW2wQ2bZ8	OQWu2bnHeC	3	3	4	2	4	\N	\N
xThByNRIpR	2024-02-16 00:22:55.203+00	2024-02-16 00:22:55.203+00	sy1HD51LXT	WSTLlXDcKl	1	0	4	1	1	\N	\N
3zh1cJ4T87	2024-02-16 00:22:55.409+00	2024-02-16 00:22:55.409+00	dEqAHvPMXA	bQpy9LEJWn	2	3	4	2	1	\N	\N
mSfD4S1sNx	2024-02-16 00:22:55.615+00	2024-02-16 00:22:55.615+00	AsrLUQwxI9	D0A6GLdsDM	3	0	3	2	2	\N	\N
UF42ENRV0c	2024-02-16 00:22:56.228+00	2024-02-16 00:22:56.228+00	ONgyydfVNz	fxvABtKCPT	4	4	1	2	0	\N	\N
ZBhQsSeL9u	2024-02-16 00:22:56.434+00	2024-02-16 00:22:56.434+00	1as6rMOzjQ	TpGyMZM9BG	1	2	1	1	0	\N	\N
Ci2CrlhiTX	2024-02-16 00:22:56.637+00	2024-02-16 00:22:56.637+00	adE9nQrDk3	M0tHrt1GgV	4	3	4	3	4	\N	\N
uZ2lnQc0fG	2024-02-16 00:22:56.842+00	2024-02-16 00:22:56.842+00	R2CLtFh5jU	bQpy9LEJWn	0	3	0	1	0	\N	\N
fx9h2Tqflm	2024-02-16 00:22:57.048+00	2024-02-16 00:22:57.048+00	VshUk7eBeK	bi1IivsuUB	0	1	2	1	3	\N	\N
DLEx4S40tI	2024-02-16 00:22:57.253+00	2024-02-16 00:22:57.253+00	AsrLUQwxI9	na5crB8ED1	3	1	1	0	0	\N	\N
5ZilABPP4R	2024-02-16 00:22:57.56+00	2024-02-16 00:22:57.56+00	RWwLSzreG2	bQ0JOk10eL	1	2	1	3	4	\N	\N
a2OAxqLb6b	2024-02-16 00:22:57.766+00	2024-02-16 00:22:57.766+00	HRhGpJpmb5	BMLzFMvIT6	0	3	3	1	1	\N	\N
ZO0B3AoLGp	2024-02-16 00:22:57.975+00	2024-02-16 00:22:57.975+00	VshUk7eBeK	cTIjuPjyIa	0	3	0	0	4	\N	\N
P0SYbf2sqa	2024-02-16 00:22:58.182+00	2024-02-16 00:22:58.182+00	VshUk7eBeK	o4VD4BWwDt	1	2	3	3	0	\N	\N
bm9HHGtYjG	2024-02-16 00:22:58.387+00	2024-02-16 00:22:58.387+00	mAKp5BK7R1	l1Bslv8T2k	3	0	1	2	3	\N	\N
4H2WxRuvWH	2024-02-16 00:22:58.591+00	2024-02-16 00:22:58.591+00	WKpBp0c8F3	rT0UCBK1bE	0	0	0	3	4	\N	\N
FvF4z7Cjqh	2024-02-16 00:22:58.795+00	2024-02-16 00:22:58.795+00	iWxl9obi8w	cTIjuPjyIa	4	4	2	4	1	\N	\N
sk7DCoQZ9j	2024-02-16 00:22:59.001+00	2024-02-16 00:22:59.001+00	S6wz0lK0bf	l1Bslv8T2k	4	3	2	1	0	\N	\N
DdPEKUQwEv	2024-02-16 00:22:59.208+00	2024-02-16 00:22:59.208+00	iUlyHNFGpG	UCFo58JaaD	2	3	3	2	2	\N	\N
PZOfWkFDZH	2024-02-16 00:22:59.413+00	2024-02-16 00:22:59.413+00	ONgyydfVNz	RBRcyltRSC	4	3	4	0	4	\N	\N
UffNJn9uGL	2024-02-16 00:22:59.618+00	2024-02-16 00:22:59.618+00	opW2wQ2bZ8	o4VD4BWwDt	1	1	1	3	2	\N	\N
YkpCNBxBQt	2024-02-16 00:22:59.823+00	2024-02-16 00:22:59.823+00	VshUk7eBeK	08liHW08uC	2	0	4	4	1	\N	\N
CIw4HIIvm7	2024-02-16 00:23:00.029+00	2024-02-16 00:23:00.029+00	Otwj7uJwjr	UCFo58JaaD	0	0	4	1	2	\N	\N
hlbvEJfTNH	2024-02-16 00:23:00.632+00	2024-02-16 00:23:00.632+00	adE9nQrDk3	Oahm9sOn1y	3	4	3	1	1	\N	\N
eKAqZHlYSP	2024-02-16 00:23:00.836+00	2024-02-16 00:23:00.836+00	Otwj7uJwjr	rT0UCBK1bE	2	2	3	2	2	\N	\N
KZJaX96TjX	2024-02-16 00:23:01.041+00	2024-02-16 00:23:01.041+00	jqDYoPT45X	3P6kmNoY1F	3	2	0	4	2	\N	\N
OPKulleqRE	2024-02-16 00:23:01.349+00	2024-02-16 00:23:01.349+00	R2CLtFh5jU	JZOBDAh12a	2	1	4	1	3	\N	\N
bf13FeJ2AG	2024-02-16 00:23:01.556+00	2024-02-16 00:23:01.556+00	iWxl9obi8w	RBRcyltRSC	3	2	4	1	2	\N	\N
ZPW3Ucao73	2024-02-16 00:23:01.764+00	2024-02-16 00:23:01.764+00	dZKm0wOhYa	XpUyRlB6FI	3	1	4	0	1	\N	\N
kXrCCcM9Us	2024-02-16 00:23:02.372+00	2024-02-16 00:23:02.372+00	VshUk7eBeK	M0tHrt1GgV	4	3	1	0	4	\N	\N
NoI0j3MgEn	2024-02-16 00:23:02.575+00	2024-02-16 00:23:02.575+00	HRhGpJpmb5	6KvFK8yy1q	2	0	2	3	4	\N	\N
8HTxSOeebe	2024-02-16 00:23:02.781+00	2024-02-16 00:23:02.781+00	Otwj7uJwjr	Pja6n3yaWZ	0	3	0	3	1	\N	\N
gCjmCIKMIe	2024-02-16 00:23:02.987+00	2024-02-16 00:23:02.987+00	VshUk7eBeK	Oahm9sOn1y	0	0	3	0	1	\N	\N
rAlDQdhwNr	2024-02-16 00:23:03.193+00	2024-02-16 00:23:03.193+00	I5RzFRcQ7G	na5crB8ED1	1	1	1	2	1	\N	\N
htAo5JcCb0	2024-02-16 00:23:03.503+00	2024-02-16 00:23:03.503+00	S6wz0lK0bf	WSTLlXDcKl	2	3	0	2	2	\N	\N
i9jwXCyzug	2024-02-16 00:23:03.715+00	2024-02-16 00:23:03.715+00	ONgyydfVNz	3u4B9V4l5K	0	0	4	1	0	\N	\N
AOvvBsV9Oy	2024-02-16 00:23:03.918+00	2024-02-16 00:23:03.918+00	iWxl9obi8w	Oahm9sOn1y	3	2	3	3	0	\N	\N
ZvriXyD6Af	2024-02-16 00:23:04.122+00	2024-02-16 00:23:04.122+00	sHiqaG4iqY	XwszrNEEEj	1	1	0	2	0	\N	\N
PiNQ6zz2Kd	2024-02-16 00:23:04.327+00	2024-02-16 00:23:04.327+00	iWxl9obi8w	l1Bslv8T2k	0	1	4	0	2	\N	\N
OHdH8IRfdx	2024-02-16 00:23:04.626+00	2024-02-16 00:23:04.626+00	dZKm0wOhYa	cwVEh0dqfm	4	1	0	3	4	\N	\N
Redw3OGykm	2024-02-16 00:23:04.831+00	2024-02-16 00:23:04.831+00	AsrLUQwxI9	NY6RE1qgWu	4	3	1	3	4	\N	\N
QpFbGVRFE8	2024-02-16 00:23:05.138+00	2024-02-16 00:23:05.138+00	iWxl9obi8w	14jGmOAXcg	4	1	3	0	0	\N	\N
bUeZgTNIJw	2024-02-16 00:23:05.344+00	2024-02-16 00:23:05.344+00	mQXQWNqxg9	qEQ9tmLyW9	2	4	4	1	4	\N	\N
Gorj8OtQoE	2024-02-16 00:23:05.654+00	2024-02-16 00:23:05.654+00	ONgyydfVNz	PF8w2gMAdi	0	4	4	2	3	\N	\N
q3VMUpBcU7	2024-02-16 00:23:05.868+00	2024-02-16 00:23:05.868+00	RWwLSzreG2	fwLPZZ8YQa	3	0	1	0	3	\N	\N
FWbY9PLMRM	2024-02-16 00:23:06.074+00	2024-02-16 00:23:06.074+00	RWwLSzreG2	OQWu2bnHeC	2	0	2	1	3	\N	\N
IlIGQ8tFd9	2024-02-16 00:23:06.279+00	2024-02-16 00:23:06.279+00	SFAISec8QF	IybX0eBoO3	0	2	2	2	0	\N	\N
pbGaeLcMBT	2024-02-16 00:23:06.482+00	2024-02-16 00:23:06.482+00	sHiqaG4iqY	yvUod6yLDt	4	2	1	0	2	\N	\N
09IQU9TS73	2024-02-16 00:23:06.682+00	2024-02-16 00:23:06.682+00	sHiqaG4iqY	XwszrNEEEj	3	2	3	2	1	\N	\N
zHkAjUggAe	2024-02-16 00:23:06.888+00	2024-02-16 00:23:06.888+00	WKpBp0c8F3	XpUyRlB6FI	1	4	2	2	3	\N	\N
0xaCN6KNEb	2024-02-16 00:23:07.186+00	2024-02-16 00:23:07.186+00	iUlyHNFGpG	uABtFsJhJc	4	2	2	1	1	\N	\N
0kzHlYKPsQ	2024-02-16 00:23:07.493+00	2024-02-16 00:23:07.493+00	VshUk7eBeK	cmxBcanww9	4	0	0	4	1	\N	\N
pUANZFivDq	2024-02-16 00:23:07.696+00	2024-02-16 00:23:07.696+00	mAKp5BK7R1	bQpy9LEJWn	2	4	2	2	1	\N	\N
GKwdFuYLUI	2024-02-16 00:23:07.9+00	2024-02-16 00:23:07.9+00	AsrLUQwxI9	VK3vnSxIy8	4	2	3	2	3	\N	\N
7gxsPRCB77	2024-02-16 00:23:08.106+00	2024-02-16 00:23:08.106+00	NjxsGlPeB4	o90lhsZ7FK	3	4	3	3	3	\N	\N
Kyl6JJqmsh	2024-02-16 00:23:08.311+00	2024-02-16 00:23:08.311+00	VshUk7eBeK	CSvk1ycWXk	0	4	0	1	4	\N	\N
nyNW0vp6Ww	2024-02-16 00:23:08.927+00	2024-02-16 00:23:08.927+00	5nv19u6KJ2	IybX0eBoO3	2	0	0	1	1	\N	\N
jW3ac23R1B	2024-02-16 00:23:09.131+00	2024-02-16 00:23:09.131+00	HtEtaHBVDN	RBRcyltRSC	1	0	0	2	0	\N	\N
CyVSyqFq8L	2024-02-16 00:23:09.745+00	2024-02-16 00:23:09.745+00	dEqAHvPMXA	UDXF0qXvDY	0	4	1	2	3	\N	\N
0womYZ3yDd	2024-02-16 00:23:10.053+00	2024-02-16 00:23:10.053+00	sy1HD51LXT	UDXF0qXvDY	0	1	2	1	3	\N	\N
kQmRIpTX4Q	2024-02-16 00:23:10.257+00	2024-02-16 00:23:10.257+00	ONgyydfVNz	VK3vnSxIy8	0	3	2	1	3	\N	\N
eWx1IqxYOK	2024-02-16 00:23:10.461+00	2024-02-16 00:23:10.461+00	5nv19u6KJ2	MQfxuw3ERg	1	4	4	1	0	\N	\N
DRdtt64VUk	2024-02-16 00:23:10.663+00	2024-02-16 00:23:10.663+00	RWwLSzreG2	LgJuu5ABe5	1	2	0	1	1	\N	\N
g8txldCqcu	2024-02-16 00:23:10.871+00	2024-02-16 00:23:10.871+00	AsrLUQwxI9	D0A6GLdsDM	0	0	3	4	3	\N	\N
2janktsHPC	2024-02-16 00:23:11.176+00	2024-02-16 00:23:11.176+00	VshUk7eBeK	6KvFK8yy1q	0	1	2	1	1	\N	\N
eMpmGFz6SH	2024-02-16 00:23:11.384+00	2024-02-16 00:23:11.384+00	dEqAHvPMXA	uigc7bJBOJ	4	0	0	0	1	\N	\N
jDPfNUkP04	2024-02-16 00:23:11.59+00	2024-02-16 00:23:11.59+00	sy1HD51LXT	j0dWqP2C2A	2	4	0	2	0	\N	\N
lECE6rfA4A	2024-02-16 00:23:11.796+00	2024-02-16 00:23:11.796+00	adE9nQrDk3	o4VD4BWwDt	1	2	2	4	2	\N	\N
dWWCh3W9uV	2024-02-16 00:23:12.002+00	2024-02-16 00:23:12.002+00	5X202ssb0D	JLhF4VuByh	3	0	4	0	1	\N	\N
aZIscAxn6Z	2024-02-16 00:23:12.209+00	2024-02-16 00:23:12.209+00	mAKp5BK7R1	XwWwGnkXNj	1	1	4	0	0	\N	\N
nTv08Xi4Af	2024-02-16 00:23:12.601+00	2024-02-16 00:23:12.601+00	AsrLUQwxI9	uigc7bJBOJ	0	3	4	4	1	\N	\N
kiPwEi8oYB	2024-02-16 00:23:12.806+00	2024-02-16 00:23:12.806+00	dEqAHvPMXA	u5FXeeOChJ	4	1	3	3	1	\N	\N
JLU0nGZC2L	2024-02-16 00:23:13.012+00	2024-02-16 00:23:13.012+00	SFAISec8QF	JZOBDAh12a	1	3	4	3	2	\N	\N
XnPpXonKt8	2024-02-16 00:23:13.217+00	2024-02-16 00:23:13.217+00	mAKp5BK7R1	WBFeKac0OO	3	4	4	0	1	\N	\N
j6W1HDZXGP	2024-02-16 00:23:13.601+00	2024-02-16 00:23:13.601+00	opW2wQ2bZ8	WBFeKac0OO	4	1	4	1	1	\N	\N
PlMxfqKzCw	2024-02-16 00:23:13.845+00	2024-02-16 00:23:13.845+00	sy1HD51LXT	PF8w2gMAdi	2	3	1	4	1	\N	\N
VNMfsJzwbv	2024-02-16 00:23:14.56+00	2024-02-16 00:23:14.56+00	5nv19u6KJ2	qEQ9tmLyW9	2	4	2	4	0	\N	\N
IcyheB299E	2024-02-16 00:23:14.866+00	2024-02-16 00:23:14.866+00	Otwj7uJwjr	ThMuD3hYRQ	4	2	2	2	0	\N	\N
9uMRG84WEz	2024-02-16 00:23:15.174+00	2024-02-16 00:23:15.174+00	S6wz0lK0bf	qEQ9tmLyW9	1	3	4	4	1	\N	\N
QGgBIwYUO3	2024-02-16 00:23:15.379+00	2024-02-16 00:23:15.379+00	AsrLUQwxI9	fwLPZZ8YQa	2	1	1	4	4	\N	\N
ihPDmSZ1Ts	2024-02-16 00:23:15.585+00	2024-02-16 00:23:15.585+00	I5RzFRcQ7G	XwszrNEEEj	1	4	2	4	4	\N	\N
gIX0gAHEta	2024-02-16 00:23:15.792+00	2024-02-16 00:23:15.792+00	mAKp5BK7R1	WHvlAGgj6c	0	0	4	0	0	\N	\N
9jBwKKGEK4	2024-02-16 00:23:15.995+00	2024-02-16 00:23:15.995+00	sy1HD51LXT	RkhjIQJgou	2	3	4	2	4	\N	\N
7X2RAq75Sy	2024-02-16 00:23:16.197+00	2024-02-16 00:23:16.197+00	jqDYoPT45X	u5FXeeOChJ	0	3	2	1	1	\N	\N
67xBnILTE3	2024-02-16 00:23:16.4+00	2024-02-16 00:23:16.4+00	NjxsGlPeB4	LDrIH1vU8x	1	4	1	4	0	\N	\N
9QuRBvdQQE	2024-02-16 00:23:16.605+00	2024-02-16 00:23:16.605+00	HtEtaHBVDN	G0uU7KQLEt	3	3	0	2	2	\N	\N
uiiaXL64DM	2024-02-16 00:23:16.81+00	2024-02-16 00:23:16.81+00	Otwj7uJwjr	axyV0Fu7pm	2	4	2	2	4	\N	\N
ah6p2tbD0C	2024-02-16 00:23:17.123+00	2024-02-16 00:23:17.123+00	NjxsGlPeB4	LVYK4mLShP	0	4	0	3	3	\N	\N
Fc4Bzobene	2024-02-16 00:23:17.733+00	2024-02-16 00:23:17.733+00	SFAISec8QF	bQ0JOk10eL	1	1	4	0	0	\N	\N
BrT3BhMEer	2024-02-16 00:23:17.937+00	2024-02-16 00:23:17.937+00	WKpBp0c8F3	rKyjwoEIRp	3	2	2	3	2	\N	\N
Zxe3w5Qytd	2024-02-16 00:23:18.145+00	2024-02-16 00:23:18.145+00	5X202ssb0D	3u4B9V4l5K	2	2	2	4	2	\N	\N
FYxhvOq7pV	2024-02-16 00:23:18.352+00	2024-02-16 00:23:18.352+00	HtEtaHBVDN	fwLPZZ8YQa	1	2	4	0	0	\N	\N
xTI4CejhKs	2024-02-16 00:23:18.558+00	2024-02-16 00:23:18.558+00	NjxsGlPeB4	rT0UCBK1bE	4	0	0	1	0	\N	\N
f9CRaoxfVc	2024-02-16 00:23:18.763+00	2024-02-16 00:23:18.763+00	dEqAHvPMXA	ThMuD3hYRQ	1	4	2	2	2	\N	\N
RnxZLos5Um	2024-02-16 00:23:19.065+00	2024-02-16 00:23:19.065+00	ONgyydfVNz	JLhF4VuByh	0	0	1	3	3	\N	\N
7sRoL8GUXJ	2024-02-16 00:23:19.268+00	2024-02-16 00:23:19.268+00	adE9nQrDk3	rT0UCBK1bE	4	2	4	1	1	\N	\N
m9VnOiwhyv	2024-02-16 00:23:19.577+00	2024-02-16 00:23:19.577+00	iUlyHNFGpG	AgU9OLJkqz	3	1	0	4	4	\N	\N
4emmyrI3Gc	2024-02-16 00:23:20.191+00	2024-02-16 00:23:20.191+00	dEqAHvPMXA	tCIEnLLcUc	0	3	0	1	4	\N	\N
s4wHAl1JQ6	2024-02-16 00:23:21.011+00	2024-02-16 00:23:21.011+00	jqDYoPT45X	G0uU7KQLEt	3	4	0	1	0	\N	\N
eDzRTwA8QD	2024-02-16 00:23:21.421+00	2024-02-16 00:23:21.421+00	SFAISec8QF	NBojpORh3G	4	2	1	2	2	\N	\N
kmULZvpGh0	2024-02-16 00:23:21.627+00	2024-02-16 00:23:21.627+00	S6wz0lK0bf	HSEugQ3Ouj	2	2	0	2	4	\N	\N
13cKlsDI77	2024-02-16 00:23:21.932+00	2024-02-16 00:23:21.932+00	9223vtvaBd	jjVdtithcD	2	2	2	4	0	\N	\N
b9oXXGkHeF	2024-02-16 00:23:22.242+00	2024-02-16 00:23:22.242+00	I5RzFRcQ7G	MQfxuw3ERg	1	1	4	1	0	\N	\N
ARhY8CHRCs	2024-02-16 00:23:22.854+00	2024-02-16 00:23:22.854+00	Otwj7uJwjr	H40ivltLwZ	3	2	0	4	2	\N	\N
4oUPziAYIa	2024-02-16 00:23:23.058+00	2024-02-16 00:23:23.058+00	9223vtvaBd	RkhjIQJgou	0	0	0	0	1	\N	\N
xOsFwOmrYh	2024-02-16 00:23:23.261+00	2024-02-16 00:23:23.261+00	iWxl9obi8w	08liHW08uC	4	1	0	3	0	\N	\N
pCSY4sS6J5	2024-02-16 00:23:23.468+00	2024-02-16 00:23:23.468+00	NjxsGlPeB4	XpUyRlB6FI	3	2	2	1	3	\N	\N
mzsofp8OI1	2024-02-16 00:23:24.082+00	2024-02-16 00:23:24.082+00	RWwLSzreG2	l1Bslv8T2k	4	4	0	1	3	\N	\N
wTvdXlIIkY	2024-02-16 00:23:24.288+00	2024-02-16 00:23:24.288+00	ONgyydfVNz	WHvlAGgj6c	2	2	1	1	0	\N	\N
UqdwyN8Ixc	2024-02-16 00:23:24.494+00	2024-02-16 00:23:24.494+00	VshUk7eBeK	cFtamPA0zH	0	3	3	1	3	\N	\N
Ed920we9lq	2024-02-16 00:23:24.695+00	2024-02-16 00:23:24.695+00	opW2wQ2bZ8	89xRG1afNi	2	2	4	4	4	\N	\N
5VB2bHLdcN	2024-02-16 00:23:24.9+00	2024-02-16 00:23:24.9+00	R2CLtFh5jU	8w7i8C3NnT	0	1	3	4	3	\N	\N
SFA7n9RocS	2024-02-16 00:23:25.106+00	2024-02-16 00:23:25.106+00	VshUk7eBeK	6Fo67rhTSP	0	4	4	3	1	\N	\N
c3mku29Las	2024-02-16 00:23:25.327+00	2024-02-16 00:23:25.327+00	dEqAHvPMXA	AgU9OLJkqz	3	0	3	4	4	\N	\N
hhBohCYIS7	2024-02-16 00:23:25.533+00	2024-02-16 00:23:25.533+00	iWxl9obi8w	UCFo58JaaD	3	0	3	2	1	\N	\N
IVd1nLYLua	2024-02-16 00:23:25.825+00	2024-02-16 00:23:25.825+00	5X202ssb0D	P9sBFomftT	2	1	4	1	3	\N	\N
bx6IwPNwlJ	2024-02-16 00:23:26.032+00	2024-02-16 00:23:26.032+00	NjxsGlPeB4	JLhF4VuByh	0	2	0	0	4	\N	\N
e34qxsYknT	2024-02-16 00:23:26.541+00	2024-02-16 00:23:26.541+00	HRhGpJpmb5	JLhF4VuByh	3	2	1	2	4	\N	\N
UUTdrGxa0v	2024-02-16 00:23:26.756+00	2024-02-16 00:23:26.756+00	sy1HD51LXT	UCFo58JaaD	0	3	1	0	3	\N	\N
M6bxUltJJb	2024-02-16 00:23:26.96+00	2024-02-16 00:23:26.96+00	Otwj7uJwjr	08liHW08uC	0	4	3	1	2	\N	\N
rDHd3gJQOv	2024-02-16 00:23:27.165+00	2024-02-16 00:23:27.165+00	iWxl9obi8w	P9sBFomftT	4	1	2	2	3	\N	\N
6jI8y9O6hv	2024-02-16 00:23:27.462+00	2024-02-16 00:23:27.462+00	ONgyydfVNz	m8hjjLVdPS	0	3	0	4	1	\N	\N
KnaT8wA4ff	2024-02-16 00:23:27.666+00	2024-02-16 00:23:27.666+00	5X202ssb0D	14jGmOAXcg	1	0	4	3	2	\N	\N
Odgpg7FoZY	2024-02-16 00:23:27.873+00	2024-02-16 00:23:27.873+00	HRhGpJpmb5	lxQA9rtSfY	2	2	0	1	4	\N	\N
BXkEDscy73	2024-02-16 00:23:28.179+00	2024-02-16 00:23:28.179+00	jqDYoPT45X	LVYK4mLShP	1	3	0	2	0	\N	\N
PATeOX75XS	2024-02-16 00:23:28.794+00	2024-02-16 00:23:28.794+00	S6wz0lK0bf	mMYg4cyd5R	1	2	0	1	0	\N	\N
laEQHRm2Cs	2024-02-16 00:23:28.999+00	2024-02-16 00:23:28.999+00	VshUk7eBeK	fxvABtKCPT	2	1	4	0	4	\N	\N
TGBBiWgCS2	2024-02-16 00:23:29.306+00	2024-02-16 00:23:29.306+00	opW2wQ2bZ8	bQ0JOk10eL	1	2	4	4	4	\N	\N
QmmefvkXZb	2024-02-16 00:23:29.508+00	2024-02-16 00:23:29.508+00	sy1HD51LXT	EmIUBFwx0Z	2	3	1	4	2	\N	\N
hwU2Dzyfvy	2024-02-16 00:23:29.818+00	2024-02-16 00:23:29.818+00	RWwLSzreG2	G0uU7KQLEt	3	1	1	3	1	\N	\N
JzHrJcvlsD	2024-02-16 00:23:30.024+00	2024-02-16 00:23:30.024+00	mAKp5BK7R1	D0A6GLdsDM	3	2	2	3	0	\N	\N
q2A1j1UX1y	2024-02-16 00:23:30.329+00	2024-02-16 00:23:30.329+00	dEqAHvPMXA	P9sBFomftT	4	1	1	4	1	\N	\N
UeFelWLMIK	2024-02-16 00:23:30.943+00	2024-02-16 00:23:30.943+00	dEqAHvPMXA	Gl96vGdYHM	2	4	3	4	4	\N	\N
M080BU3eww	2024-02-16 00:23:31.559+00	2024-02-16 00:23:31.559+00	VshUk7eBeK	P9sBFomftT	4	1	0	0	4	\N	\N
cAEotbZZ9j	2024-02-16 00:23:31.767+00	2024-02-16 00:23:31.767+00	HRhGpJpmb5	rKyjwoEIRp	1	1	3	1	2	\N	\N
d1A097oEuY	2024-02-16 00:23:31.973+00	2024-02-16 00:23:31.973+00	R2CLtFh5jU	EmIUBFwx0Z	0	4	3	4	4	\N	\N
JutoEyOFmj	2024-02-16 00:23:32.175+00	2024-02-16 00:23:32.175+00	sHiqaG4iqY	HSEugQ3Ouj	1	1	4	4	3	\N	\N
kxoLNgp3Zc	2024-02-16 00:23:32.38+00	2024-02-16 00:23:32.38+00	dZKm0wOhYa	mMYg4cyd5R	3	3	2	0	1	\N	\N
omlC7CDjCD	2024-02-16 00:23:32.992+00	2024-02-16 00:23:32.992+00	mAKp5BK7R1	E2hBZzDsjO	0	2	1	0	3	\N	\N
TFvstGSxDL	2024-02-16 00:23:33.196+00	2024-02-16 00:23:33.196+00	sHiqaG4iqY	cwVEh0dqfm	0	0	4	3	1	\N	\N
1kKt8XCfuH	2024-02-16 00:23:33.4+00	2024-02-16 00:23:33.4+00	HRhGpJpmb5	PF8w2gMAdi	2	4	3	3	3	\N	\N
Iy7IUoqLLu	2024-02-16 00:23:33.606+00	2024-02-16 00:23:33.606+00	9223vtvaBd	6KvFK8yy1q	3	3	3	4	2	\N	\N
0CQQsdHjc1	2024-02-16 00:23:33.818+00	2024-02-16 00:23:33.818+00	WKpBp0c8F3	na5crB8ED1	4	4	3	2	4	\N	\N
YdotaN7rSb	2024-02-16 00:23:34.121+00	2024-02-16 00:23:34.121+00	sHiqaG4iqY	JLhF4VuByh	0	3	2	3	3	\N	\N
eIap1EJ7vY	2024-02-16 00:23:34.333+00	2024-02-16 00:23:34.333+00	HtEtaHBVDN	WBFeKac0OO	3	0	0	4	1	\N	\N
3UaIA82GVd	2024-02-16 00:23:34.539+00	2024-02-16 00:23:34.539+00	Otwj7uJwjr	C7II8dYRPY	0	2	2	0	0	\N	\N
R4VeoO6uYh	2024-02-16 00:23:34.747+00	2024-02-16 00:23:34.747+00	RWwLSzreG2	XwszrNEEEj	4	3	0	2	4	\N	\N
oATmOcRsq6	2024-02-16 00:23:34.952+00	2024-02-16 00:23:34.952+00	NjxsGlPeB4	HSEugQ3Ouj	4	4	2	4	3	\N	\N
c2QNzNtoDf	2024-02-16 00:23:35.156+00	2024-02-16 00:23:35.156+00	mQXQWNqxg9	qEQ9tmLyW9	1	4	4	0	0	\N	\N
0CM5nbIAdq	2024-02-16 00:23:35.757+00	2024-02-16 00:23:35.757+00	mQXQWNqxg9	KCsJ4XR6Dn	1	2	4	0	0	\N	\N
TuDNhONIvt	2024-02-16 00:23:35.961+00	2024-02-16 00:23:35.961+00	jqDYoPT45X	3u4B9V4l5K	3	1	2	0	3	\N	\N
Hv7drT6umA	2024-02-16 00:23:36.164+00	2024-02-16 00:23:36.164+00	sHiqaG4iqY	oABNR2FF6S	3	0	4	2	2	\N	\N
5fTepEJylO	2024-02-16 00:23:36.483+00	2024-02-16 00:23:36.483+00	I5RzFRcQ7G	XpUyRlB6FI	2	4	2	3	3	\N	\N
QAf23NK8Q7	2024-02-16 00:23:36.729+00	2024-02-16 00:23:36.729+00	dZKm0wOhYa	uABtFsJhJc	2	2	2	3	0	\N	\N
FO4bAu8UGx	2024-02-16 00:23:37.089+00	2024-02-16 00:23:37.089+00	iWxl9obi8w	eEmewy7hPd	0	2	4	1	1	\N	\N
BkLrYpyICp	2024-02-16 00:23:37.295+00	2024-02-16 00:23:37.295+00	HtEtaHBVDN	PF8w2gMAdi	0	0	0	2	4	\N	\N
V4WEq1YvCB	2024-02-16 00:23:37.601+00	2024-02-16 00:23:37.601+00	AsrLUQwxI9	89xRG1afNi	3	0	1	0	3	\N	\N
MCWAHmzHki	2024-02-16 00:23:38.215+00	2024-02-16 00:23:38.215+00	mQXQWNqxg9	M0tHrt1GgV	1	0	0	0	4	\N	\N
tVueIOMZB7	2024-02-16 00:23:38.829+00	2024-02-16 00:23:38.829+00	5nv19u6KJ2	XSK814B37m	2	2	0	2	1	\N	\N
MEx1m1506Q	2024-02-16 00:23:39.137+00	2024-02-16 00:23:39.137+00	ONgyydfVNz	cTIjuPjyIa	1	0	0	4	4	\N	\N
B5F1gAUN1f	2024-02-16 00:23:39.546+00	2024-02-16 00:23:39.546+00	WKpBp0c8F3	uigc7bJBOJ	1	0	0	2	0	\N	\N
OQPMFF1zFy	2024-02-16 00:23:40.168+00	2024-02-16 00:23:40.168+00	opW2wQ2bZ8	qZmnAnnPEb	2	1	3	0	3	\N	\N
jZf1t0YB59	2024-02-16 00:23:40.571+00	2024-02-16 00:23:40.571+00	iUlyHNFGpG	TCkiw6gTDz	4	0	2	2	0	\N	\N
kS0XJ6TAf8	2024-02-16 00:23:40.983+00	2024-02-16 00:23:40.983+00	RWwLSzreG2	INeptnSdJC	0	4	3	0	2	\N	\N
5gLzmLtdTh	2024-02-16 00:23:41.288+00	2024-02-16 00:23:41.288+00	opW2wQ2bZ8	Pa0qBO2rzK	1	4	2	3	3	\N	\N
sdEbXfO8ky	2024-02-16 00:23:41.595+00	2024-02-16 00:23:41.595+00	mQXQWNqxg9	8w7i8C3NnT	2	0	0	1	1	\N	\N
zO3yOHcdyV	2024-02-16 00:23:41.803+00	2024-02-16 00:23:41.803+00	sHiqaG4iqY	bQpy9LEJWn	4	1	2	0	0	\N	\N
x3AWbea4lp	2024-02-16 00:23:42.107+00	2024-02-16 00:23:42.107+00	5nv19u6KJ2	bQ0JOk10eL	3	0	2	4	0	\N	\N
NTvMzvtCas	2024-02-16 00:23:42.414+00	2024-02-16 00:23:42.414+00	iWxl9obi8w	o90lhsZ7FK	3	3	2	0	1	\N	\N
OU8uGLWWK5	2024-02-16 00:23:42.72+00	2024-02-16 00:23:42.72+00	HRhGpJpmb5	cFtamPA0zH	4	0	4	2	1	\N	\N
3FMik1hpFa	2024-02-16 00:23:43.131+00	2024-02-16 00:23:43.131+00	WKpBp0c8F3	cTIjuPjyIa	4	3	4	1	0	\N	\N
Xuk0LG1Mkz	2024-02-16 00:23:43.439+00	2024-02-16 00:23:43.439+00	jqDYoPT45X	Oahm9sOn1y	1	0	2	2	4	\N	\N
fqhi1fGEoB	2024-02-16 00:23:43.745+00	2024-02-16 00:23:43.745+00	R2CLtFh5jU	cTIjuPjyIa	0	4	2	1	0	\N	\N
BFNJ52u4WB	2024-02-16 00:23:44.257+00	2024-02-16 00:23:44.257+00	VshUk7eBeK	AgU9OLJkqz	1	0	1	4	4	\N	\N
moPhKr1a0R	2024-02-16 00:23:44.771+00	2024-02-16 00:23:44.771+00	WKpBp0c8F3	bQpy9LEJWn	3	3	3	1	3	\N	\N
5JZwBKEXwW	2024-02-16 00:23:45.074+00	2024-02-16 00:23:45.074+00	S6wz0lK0bf	bi1IivsuUB	4	4	3	4	3	\N	\N
qR6ugOyx4U	2024-02-16 00:23:45.384+00	2024-02-16 00:23:45.384+00	R2CLtFh5jU	D0A6GLdsDM	0	1	1	0	4	\N	\N
2GbojkkJG8	2024-02-16 00:23:45.686+00	2024-02-16 00:23:45.686+00	NjxsGlPeB4	Oahm9sOn1y	3	0	0	1	1	\N	\N
tLagac9THa	2024-02-16 00:23:45.998+00	2024-02-16 00:23:45.998+00	Otwj7uJwjr	Oahm9sOn1y	1	4	0	4	4	\N	\N
XDhdVnqglb	2024-02-16 00:23:46.306+00	2024-02-16 00:23:46.306+00	5X202ssb0D	o90lhsZ7FK	2	4	2	3	4	\N	\N
XgAkauZjwk	2024-02-16 00:23:46.61+00	2024-02-16 00:23:46.61+00	jqDYoPT45X	uABtFsJhJc	0	1	0	1	1	\N	\N
Dw2PA5IlbY	2024-02-16 00:23:46.818+00	2024-02-16 00:23:46.818+00	opW2wQ2bZ8	E2hBZzDsjO	1	2	0	1	0	\N	\N
QQl9bupiru	2024-02-16 00:23:47.031+00	2024-02-16 00:23:47.031+00	I5RzFRcQ7G	u5FXeeOChJ	0	0	3	0	2	\N	\N
EmTB6l7OKm	2024-02-16 00:23:47.237+00	2024-02-16 00:23:47.237+00	S6wz0lK0bf	IEqTHcohpJ	3	1	0	2	2	\N	\N
qFdLpYHspE	2024-02-16 00:23:47.536+00	2024-02-16 00:23:47.536+00	S6wz0lK0bf	na5crB8ED1	1	1	4	4	1	\N	\N
Zhml9KZSAy	2024-02-16 00:23:47.756+00	2024-02-16 00:23:47.756+00	Otwj7uJwjr	HSEugQ3Ouj	1	2	1	1	0	\N	\N
Ngd5llKb4u	2024-02-16 00:23:48.046+00	2024-02-16 00:23:48.046+00	SFAISec8QF	PF8w2gMAdi	0	1	4	0	1	\N	\N
pCjYdD8MHm	2024-02-16 00:23:48.355+00	2024-02-16 00:23:48.355+00	adE9nQrDk3	89xRG1afNi	2	2	3	0	1	\N	\N
wHU5s7GEzS	2024-02-16 00:23:48.661+00	2024-02-16 00:23:48.661+00	ONgyydfVNz	o90lhsZ7FK	4	0	4	0	1	\N	\N
wECsLWosBj	2024-02-16 00:23:48.968+00	2024-02-16 00:23:48.968+00	Otwj7uJwjr	LVYK4mLShP	3	1	1	4	2	\N	\N
CCw0WXH8pY	2024-02-16 00:23:49.273+00	2024-02-16 00:23:49.273+00	RWwLSzreG2	cTIjuPjyIa	0	0	1	0	3	\N	\N
cDQbZOeE3F	2024-02-16 00:23:49.482+00	2024-02-16 00:23:49.482+00	R2CLtFh5jU	l1Bslv8T2k	4	1	4	2	1	\N	\N
z3kQ1l0mae	2024-02-16 00:23:49.787+00	2024-02-16 00:23:49.787+00	dEqAHvPMXA	C7II8dYRPY	2	2	4	4	0	\N	\N
euM8TDJWYz	2024-02-16 00:23:50.094+00	2024-02-16 00:23:50.094+00	9223vtvaBd	Pa0qBO2rzK	1	1	0	4	2	\N	\N
crDPUHPmMV	2024-02-16 00:23:50.401+00	2024-02-16 00:23:50.401+00	5nv19u6KJ2	P9sBFomftT	0	3	0	0	1	\N	\N
t6biWKmQow	2024-02-16 00:23:51.114+00	2024-02-16 00:23:51.114+00	I5RzFRcQ7G	9GF3y7LmHV	0	1	4	3	0	\N	\N
HREoWCaSty	2024-02-16 00:23:51.322+00	2024-02-16 00:23:51.322+00	HtEtaHBVDN	na5crB8ED1	2	2	3	2	2	\N	\N
cqRICdzhKp	2024-02-16 00:23:51.63+00	2024-02-16 00:23:51.63+00	HtEtaHBVDN	M0tHrt1GgV	4	3	0	1	1	\N	\N
7YKf7u3CPW	2024-02-16 00:23:51.834+00	2024-02-16 00:23:51.834+00	ONgyydfVNz	j0dWqP2C2A	4	1	3	3	2	\N	\N
bHXpAXBCHv	2024-02-16 00:23:52.141+00	2024-02-16 00:23:52.141+00	iUlyHNFGpG	0TvWuLoLF5	3	0	1	4	0	\N	\N
6xLP8CYkDB	2024-02-16 00:23:52.552+00	2024-02-16 00:23:52.552+00	R2CLtFh5jU	HSEugQ3Ouj	1	4	1	2	1	\N	\N
8R1KcJuA60	2024-02-16 00:23:52.859+00	2024-02-16 00:23:52.859+00	NjxsGlPeB4	cFtamPA0zH	2	1	1	0	3	\N	\N
CQU1ZRxIzV	2024-02-16 00:23:53.23+00	2024-02-16 00:23:53.23+00	adE9nQrDk3	Oahm9sOn1y	0	3	4	2	4	\N	\N
1uccTCrmho	2024-02-16 00:23:53.883+00	2024-02-16 00:23:53.883+00	dZKm0wOhYa	oABNR2FF6S	3	2	4	4	2	\N	\N
h7HxGlxBIs	2024-02-16 00:23:54.191+00	2024-02-16 00:23:54.191+00	sy1HD51LXT	IEqTHcohpJ	2	1	2	1	3	\N	\N
xrQXAEBZwZ	2024-02-16 00:23:54.399+00	2024-02-16 00:23:54.399+00	5nv19u6KJ2	8w7i8C3NnT	0	1	2	2	1	\N	\N
R1wRIdaJGA	2024-02-16 00:23:54.705+00	2024-02-16 00:23:54.705+00	opW2wQ2bZ8	cwVEh0dqfm	4	3	3	4	1	\N	\N
ehUGSuIuYF	2024-02-16 00:23:54.911+00	2024-02-16 00:23:54.911+00	ONgyydfVNz	Gl96vGdYHM	0	2	3	4	1	\N	\N
VKLloBOloi	2024-02-16 00:23:55.522+00	2024-02-16 00:23:55.522+00	HtEtaHBVDN	6KvFK8yy1q	4	0	2	1	0	\N	\N
kh1FxIDgWU	2024-02-16 00:23:55.83+00	2024-02-16 00:23:55.83+00	RWwLSzreG2	m8hjjLVdPS	4	3	1	0	3	\N	\N
LM5GAIxEzn	2024-02-16 00:23:56.444+00	2024-02-16 00:23:56.444+00	5nv19u6KJ2	6Fo67rhTSP	1	0	2	4	2	\N	\N
9dqDoZmXiz	2024-02-16 00:23:56.648+00	2024-02-16 00:23:56.648+00	Otwj7uJwjr	Oahm9sOn1y	0	2	2	0	3	\N	\N
jLiN3sMS3d	2024-02-16 00:23:56.863+00	2024-02-16 00:23:56.863+00	dEqAHvPMXA	XwWwGnkXNj	3	3	3	3	2	\N	\N
TNwekSaMjZ	2024-02-16 00:23:57.467+00	2024-02-16 00:23:57.467+00	sy1HD51LXT	fKTSJPdUi9	1	3	4	4	1	\N	\N
nGVJf7HRqf	2024-02-16 00:23:57.672+00	2024-02-16 00:23:57.672+00	jqDYoPT45X	RkhjIQJgou	2	2	1	3	3	\N	\N
TU9Cv7IJi3	2024-02-16 00:23:57.979+00	2024-02-16 00:23:57.979+00	jqDYoPT45X	Pja6n3yaWZ	3	2	2	2	0	\N	\N
T47sx3DDyd	2024-02-16 00:23:58.182+00	2024-02-16 00:23:58.182+00	sy1HD51LXT	m8hjjLVdPS	4	2	3	2	2	\N	\N
egdgil0HiX	2024-02-16 00:23:58.8+00	2024-02-16 00:23:58.8+00	mQXQWNqxg9	rKyjwoEIRp	1	2	3	1	2	\N	\N
rj4sSkcA1b	2024-02-16 00:23:59.005+00	2024-02-16 00:23:59.005+00	sHiqaG4iqY	fKTSJPdUi9	4	1	3	1	3	\N	\N
cZ1NQMviWF	2024-02-16 00:23:59.209+00	2024-02-16 00:23:59.209+00	iUlyHNFGpG	rT0UCBK1bE	4	4	4	3	1	\N	\N
mTgDjwCeMs	2024-02-16 00:23:59.823+00	2024-02-16 00:23:59.823+00	jqDYoPT45X	m6g8u0QpTC	2	2	4	4	2	\N	\N
515IhfQhaO	2024-02-16 00:24:00.027+00	2024-02-16 00:24:00.027+00	SFAISec8QF	m6g8u0QpTC	3	2	3	0	2	\N	\N
nO0pPfoZsI	2024-02-16 00:24:00.234+00	2024-02-16 00:24:00.234+00	opW2wQ2bZ8	jjVdtithcD	1	0	0	4	2	\N	\N
EDIrD6e4Tg	2024-02-16 00:24:00.44+00	2024-02-16 00:24:00.44+00	mAKp5BK7R1	VK3vnSxIy8	1	4	2	4	3	\N	\N
kVanaMQmxs	2024-02-16 00:24:00.647+00	2024-02-16 00:24:00.647+00	NjxsGlPeB4	Pja6n3yaWZ	1	4	2	1	1	\N	\N
1pUO63tGEG	2024-02-16 00:24:00.949+00	2024-02-16 00:24:00.949+00	mQXQWNqxg9	RkhjIQJgou	4	1	2	2	2	\N	\N
kBIteQCXlN	2024-02-16 00:24:01.149+00	2024-02-16 00:24:01.149+00	5nv19u6KJ2	uigc7bJBOJ	4	0	2	4	4	\N	\N
YKEBFzUwMb	2024-02-16 00:24:01.352+00	2024-02-16 00:24:01.352+00	jqDYoPT45X	UCFo58JaaD	1	1	4	2	1	\N	\N
H4WFudJI4N	2024-02-16 00:24:01.559+00	2024-02-16 00:24:01.559+00	AsrLUQwxI9	3P6kmNoY1F	4	2	2	4	4	\N	\N
Z4mCS2Z6BC	2024-02-16 00:24:02.174+00	2024-02-16 00:24:02.174+00	R2CLtFh5jU	Gl96vGdYHM	2	4	3	1	2	\N	\N
mGtxIA6bon	2024-02-16 00:24:02.791+00	2024-02-16 00:24:02.791+00	1as6rMOzjQ	XpUyRlB6FI	4	4	0	4	3	\N	\N
Nb8cAMYCNK	2024-02-16 00:24:02.995+00	2024-02-16 00:24:02.995+00	mAKp5BK7R1	WHvlAGgj6c	1	3	1	3	1	\N	\N
kl2n4lEBwF	2024-02-16 00:24:03.2+00	2024-02-16 00:24:03.2+00	5X202ssb0D	fKTSJPdUi9	3	3	3	3	3	\N	\N
agasI3fFEY	2024-02-16 00:24:03.404+00	2024-02-16 00:24:03.404+00	sHiqaG4iqY	M0tHrt1GgV	0	2	3	3	0	\N	\N
Y1sqyUZoBg	2024-02-16 00:24:03.607+00	2024-02-16 00:24:03.607+00	dZKm0wOhYa	Oahm9sOn1y	3	0	2	1	3	\N	\N
0dCNBdyC9B	2024-02-16 00:24:03.816+00	2024-02-16 00:24:03.816+00	dEqAHvPMXA	RBRcyltRSC	1	1	2	4	3	\N	\N
SeTn8G7mAm	2024-02-16 00:24:04.024+00	2024-02-16 00:24:04.024+00	RWwLSzreG2	e037qpAih3	2	1	3	3	1	\N	\N
4Q8xalWbcE	2024-02-16 00:24:04.23+00	2024-02-16 00:24:04.23+00	ONgyydfVNz	ThMuD3hYRQ	1	1	4	0	4	\N	\N
j9wn4w8HcO	2024-02-16 00:24:04.434+00	2024-02-16 00:24:04.434+00	mAKp5BK7R1	OQWu2bnHeC	0	1	2	1	3	\N	\N
sRWwG0bFXc	2024-02-16 00:24:04.64+00	2024-02-16 00:24:04.64+00	HtEtaHBVDN	l1Bslv8T2k	0	1	1	2	1	\N	\N
uXQ1VleIfL	2024-02-16 00:24:04.848+00	2024-02-16 00:24:04.848+00	Otwj7uJwjr	o4VD4BWwDt	1	0	0	3	4	\N	\N
aPC1zRDHn0	2024-02-16 00:24:05.052+00	2024-02-16 00:24:05.052+00	sHiqaG4iqY	M0tHrt1GgV	4	3	0	3	3	\N	\N
UGcdUMhyyg	2024-02-16 00:24:05.259+00	2024-02-16 00:24:05.259+00	sHiqaG4iqY	bQpy9LEJWn	0	2	4	0	1	\N	\N
lbKrucYauE	2024-02-16 00:24:05.557+00	2024-02-16 00:24:05.557+00	mAKp5BK7R1	Pja6n3yaWZ	2	4	1	1	1	\N	\N
38dimG4jBu	2024-02-16 00:24:05.763+00	2024-02-16 00:24:05.763+00	SFAISec8QF	lEPdiO1EDi	2	2	1	2	4	\N	\N
7twVsJEcsc	2024-02-16 00:24:05.967+00	2024-02-16 00:24:05.967+00	ONgyydfVNz	na5crB8ED1	1	4	2	1	1	\N	\N
Ra0rY7nH16	2024-02-16 00:24:06.169+00	2024-02-16 00:24:06.169+00	VshUk7eBeK	RBRcyltRSC	1	1	4	3	3	\N	\N
1sq7NVmsCb	2024-02-16 00:24:06.375+00	2024-02-16 00:24:06.375+00	WKpBp0c8F3	H40ivltLwZ	2	2	3	1	1	\N	\N
adf5aCDCzO	2024-02-16 00:24:06.58+00	2024-02-16 00:24:06.58+00	I5RzFRcQ7G	o4VD4BWwDt	0	0	3	2	0	\N	\N
QSvNpiywHv	2024-02-16 00:24:07.194+00	2024-02-16 00:24:07.194+00	VshUk7eBeK	LgJuu5ABe5	2	2	0	0	3	\N	\N
GOnJVLA2qT	2024-02-16 00:24:07.823+00	2024-02-16 00:24:07.823+00	WKpBp0c8F3	j0dWqP2C2A	0	0	0	1	3	\N	\N
XRrjVlMBZW	2024-02-16 00:24:08.425+00	2024-02-16 00:24:08.425+00	iUlyHNFGpG	JZOBDAh12a	1	3	0	1	0	\N	\N
u8cWib5hzI	2024-02-16 00:24:08.735+00	2024-02-16 00:24:08.735+00	jqDYoPT45X	0TvWuLoLF5	0	3	2	0	3	\N	\N
r446vBcwZm	2024-02-16 00:24:08.942+00	2024-02-16 00:24:08.942+00	1as6rMOzjQ	WnUBBkiDjE	3	1	0	2	2	\N	\N
8HdKerrXor	2024-02-16 00:24:09.147+00	2024-02-16 00:24:09.147+00	NjxsGlPeB4	IEqTHcohpJ	1	0	1	0	1	\N	\N
M1o61B7Uik	2024-02-16 00:24:09.449+00	2024-02-16 00:24:09.449+00	VshUk7eBeK	IEqTHcohpJ	4	2	4	1	2	\N	\N
YmBixIV6is	2024-02-16 00:24:09.651+00	2024-02-16 00:24:09.651+00	SFAISec8QF	14jGmOAXcg	1	1	0	0	3	\N	\N
I6zrWFWSyv	2024-02-16 00:24:09.857+00	2024-02-16 00:24:09.857+00	sy1HD51LXT	8w7i8C3NnT	3	4	3	4	0	\N	\N
p14DvHq4LK	2024-02-16 00:24:10.065+00	2024-02-16 00:24:10.065+00	iWxl9obi8w	NY6RE1qgWu	2	2	4	4	1	\N	\N
b0ixUQRjPY	2024-02-16 00:24:10.372+00	2024-02-16 00:24:10.372+00	mQXQWNqxg9	WSTLlXDcKl	3	2	2	1	3	\N	\N
gnEvc7YaLF	2024-02-16 00:24:10.576+00	2024-02-16 00:24:10.576+00	1as6rMOzjQ	FYXEfIO1zF	2	0	4	1	0	\N	\N
XbWp252LMc	2024-02-16 00:24:10.884+00	2024-02-16 00:24:10.884+00	SFAISec8QF	6KvFK8yy1q	3	3	2	1	1	\N	\N
6hayBaSrxx	2024-02-16 00:24:11.498+00	2024-02-16 00:24:11.498+00	iUlyHNFGpG	RkhjIQJgou	1	3	1	1	2	\N	\N
2OOzcLicQg	2024-02-16 00:24:11.703+00	2024-02-16 00:24:11.703+00	dZKm0wOhYa	6Fo67rhTSP	0	0	1	3	3	\N	\N
AArtxIAYSF	2024-02-16 00:24:11.906+00	2024-02-16 00:24:11.906+00	jqDYoPT45X	na5crB8ED1	1	1	3	1	1	\N	\N
uO9DNSHrch	2024-02-16 00:24:12.109+00	2024-02-16 00:24:12.109+00	S6wz0lK0bf	Oahm9sOn1y	0	3	3	2	3	\N	\N
A6Yr9jAEzc	2024-02-16 00:24:12.315+00	2024-02-16 00:24:12.315+00	NjxsGlPeB4	fKTSJPdUi9	3	3	3	1	3	\N	\N
rwDOrXf7Kl	2024-02-16 00:24:12.93+00	2024-02-16 00:24:12.93+00	1as6rMOzjQ	j0dWqP2C2A	4	0	3	3	1	\N	\N
uILlWKpdZu	2024-02-16 00:24:13.24+00	2024-02-16 00:24:13.24+00	Otwj7uJwjr	Gl96vGdYHM	3	3	4	4	3	\N	\N
VQsaHVAuYJ	2024-02-16 00:24:13.446+00	2024-02-16 00:24:13.446+00	dEqAHvPMXA	fxvABtKCPT	4	1	0	0	2	\N	\N
AVeyWK4Yeu	2024-02-16 00:24:13.75+00	2024-02-16 00:24:13.75+00	dEqAHvPMXA	bQ0JOk10eL	1	4	1	4	4	\N	\N
IKC7BS8vNG	2024-02-16 00:24:13.956+00	2024-02-16 00:24:13.956+00	5nv19u6KJ2	uigc7bJBOJ	1	0	3	2	4	\N	\N
AbOix713QH	2024-02-16 00:24:14.165+00	2024-02-16 00:24:14.165+00	5X202ssb0D	UDXF0qXvDY	0	4	3	2	2	\N	\N
VF86svNGfe	2024-02-16 00:24:14.369+00	2024-02-16 00:24:14.369+00	R2CLtFh5jU	FJOTueDfs2	0	0	0	2	0	\N	\N
0nNyDizrEP	2024-02-16 00:24:14.571+00	2024-02-16 00:24:14.571+00	dZKm0wOhYa	FJOTueDfs2	4	0	4	3	2	\N	\N
C8ddNETaO4	2024-02-16 00:24:14.775+00	2024-02-16 00:24:14.775+00	iUlyHNFGpG	qP3EdIVzfB	4	2	1	4	1	\N	\N
qH7dJ6E7SC	2024-02-16 00:24:14.978+00	2024-02-16 00:24:14.978+00	5X202ssb0D	RkhjIQJgou	1	1	1	4	1	\N	\N
LwaKAm3ZdE	2024-02-16 00:24:15.184+00	2024-02-16 00:24:15.184+00	9223vtvaBd	o4VD4BWwDt	4	0	1	4	1	\N	\N
7Dza7aHTs0	2024-02-16 00:24:15.392+00	2024-02-16 00:24:15.392+00	iWxl9obi8w	WSTLlXDcKl	2	1	0	4	2	\N	\N
cKcBuJBQKu	2024-02-16 00:24:15.595+00	2024-02-16 00:24:15.595+00	I5RzFRcQ7G	o4VD4BWwDt	0	4	0	1	3	\N	\N
FmjlumXtbw	2024-02-16 00:24:15.8+00	2024-02-16 00:24:15.8+00	HRhGpJpmb5	XSK814B37m	2	3	1	2	2	\N	\N
jknlbQ9tii	2024-02-16 00:24:16.01+00	2024-02-16 00:24:16.01+00	S6wz0lK0bf	M0tHrt1GgV	2	2	2	4	4	\N	\N
9eoMODarYR	2024-02-16 00:24:16.617+00	2024-02-16 00:24:16.617+00	iWxl9obi8w	oABNR2FF6S	3	4	4	1	2	\N	\N
aZ0sDBemwp	2024-02-16 00:24:16.924+00	2024-02-16 00:24:16.924+00	I5RzFRcQ7G	JRi61dUphq	2	1	2	1	3	\N	\N
sghUyZXYC1	2024-02-16 00:24:17.539+00	2024-02-16 00:24:17.539+00	9223vtvaBd	TCkiw6gTDz	0	3	2	0	2	\N	\N
mdOQo8fPAy	2024-02-16 00:24:17.745+00	2024-02-16 00:24:17.745+00	9223vtvaBd	IEqTHcohpJ	3	3	0	3	2	\N	\N
1TGaSqDSoK	2024-02-16 00:24:18.358+00	2024-02-16 00:24:18.358+00	HtEtaHBVDN	3u4B9V4l5K	4	3	1	4	0	\N	\N
ipvUC1rgEd	2024-02-16 00:24:18.661+00	2024-02-16 00:24:18.661+00	NjxsGlPeB4	IybX0eBoO3	4	0	0	1	2	\N	\N
TnIOtb8yBq	2024-02-16 00:24:18.867+00	2024-02-16 00:24:18.867+00	S6wz0lK0bf	M0tHrt1GgV	4	3	0	4	0	\N	\N
ujV1wqP35m	2024-02-16 00:24:19.072+00	2024-02-16 00:24:19.072+00	dZKm0wOhYa	m6g8u0QpTC	2	0	2	4	4	\N	\N
JNHVFQ8WeB	2024-02-16 00:24:19.383+00	2024-02-16 00:24:19.383+00	WKpBp0c8F3	tCIEnLLcUc	4	0	4	1	1	\N	\N
uRO7GqMyrA	2024-02-16 00:24:19.588+00	2024-02-16 00:24:19.588+00	9223vtvaBd	89xRG1afNi	1	2	2	4	3	\N	\N
BubYziBcpL	2024-02-16 00:24:19.796+00	2024-02-16 00:24:19.796+00	sHiqaG4iqY	oABNR2FF6S	1	0	3	0	4	\N	\N
tb8w2OBgpL	2024-02-16 00:24:20.406+00	2024-02-16 00:24:20.406+00	mQXQWNqxg9	qZmnAnnPEb	0	1	0	0	2	\N	\N
VbxUiYYvcP	2024-02-16 00:24:20.612+00	2024-02-16 00:24:20.612+00	iWxl9obi8w	HSEugQ3Ouj	0	2	0	4	3	\N	\N
s7Yx9RUOSR	2024-02-16 00:24:20.815+00	2024-02-16 00:24:20.815+00	SFAISec8QF	tCIEnLLcUc	2	0	3	2	4	\N	\N
NwSmwBwD76	2024-02-16 00:24:21.021+00	2024-02-16 00:24:21.021+00	AsrLUQwxI9	XSK814B37m	4	3	1	2	4	\N	\N
C3VimTXxdR	2024-02-16 00:24:21.328+00	2024-02-16 00:24:21.328+00	sHiqaG4iqY	yvUod6yLDt	2	3	1	2	2	\N	\N
5KEM8XqHlN	2024-02-16 00:24:21.533+00	2024-02-16 00:24:21.533+00	mAKp5BK7R1	IEqTHcohpJ	2	1	3	0	3	\N	\N
nZJo9DCghu	2024-02-16 00:24:21.841+00	2024-02-16 00:24:21.841+00	9223vtvaBd	cmxBcanww9	0	0	0	1	1	\N	\N
gLOAgxDUfJ	2024-02-16 00:24:22.048+00	2024-02-16 00:24:22.048+00	WKpBp0c8F3	Pa0qBO2rzK	3	1	4	1	3	\N	\N
hy7fBRWq8s	2024-02-16 00:24:22.251+00	2024-02-16 00:24:22.251+00	opW2wQ2bZ8	qEQ9tmLyW9	2	0	0	0	2	\N	\N
NWtbsFktOa	2024-02-16 00:24:22.456+00	2024-02-16 00:24:22.456+00	adE9nQrDk3	UDXF0qXvDY	1	2	4	3	1	\N	\N
859wkxl2og	2024-02-16 00:24:22.667+00	2024-02-16 00:24:22.667+00	dZKm0wOhYa	Oahm9sOn1y	2	3	1	0	0	\N	\N
eJDjplRadP	2024-02-16 00:24:22.875+00	2024-02-16 00:24:22.875+00	Otwj7uJwjr	lEPdiO1EDi	4	2	4	2	3	\N	\N
PeWYP3v1HZ	2024-02-16 00:24:23.172+00	2024-02-16 00:24:23.172+00	NjxsGlPeB4	uABtFsJhJc	1	0	4	4	2	\N	\N
njPQtCERYH	2024-02-16 00:24:23.376+00	2024-02-16 00:24:23.376+00	ONgyydfVNz	tCIEnLLcUc	2	2	0	1	4	\N	\N
Q0lynOZb7E	2024-02-16 00:24:23.58+00	2024-02-16 00:24:23.58+00	Otwj7uJwjr	08liHW08uC	4	3	4	0	4	\N	\N
wpuxmbo1G0	2024-02-16 00:24:23.785+00	2024-02-16 00:24:23.785+00	iUlyHNFGpG	bQpy9LEJWn	2	2	1	2	3	\N	\N
iBFlUUpS5p	2024-02-16 00:24:23.991+00	2024-02-16 00:24:23.991+00	NjxsGlPeB4	bQ0JOk10eL	3	1	4	3	0	\N	\N
viaRrcY1lc	2024-02-16 00:24:24.195+00	2024-02-16 00:24:24.195+00	NjxsGlPeB4	HSEugQ3Ouj	1	2	4	4	2	\N	\N
AFKHXcsNnw	2024-02-16 00:24:24.401+00	2024-02-16 00:24:24.401+00	dZKm0wOhYa	fKTSJPdUi9	1	3	0	2	2	\N	\N
Zm1q2gtwWC	2024-02-16 00:24:24.708+00	2024-02-16 00:24:24.708+00	sy1HD51LXT	IybX0eBoO3	1	2	2	2	1	\N	\N
IOvii2pQrt	2024-02-16 00:24:24.911+00	2024-02-16 00:24:24.911+00	AsrLUQwxI9	l1Bslv8T2k	3	1	2	4	0	\N	\N
BjiYlDxjnG	2024-02-16 00:24:25.116+00	2024-02-16 00:24:25.116+00	5nv19u6KJ2	G0uU7KQLEt	4	2	0	3	2	\N	\N
LbCZ42BCha	2024-02-16 00:24:25.322+00	2024-02-16 00:24:25.322+00	Otwj7uJwjr	NY6RE1qgWu	2	4	2	1	0	\N	\N
lPvzDBM4JU	2024-02-16 00:24:25.531+00	2024-02-16 00:24:25.531+00	SFAISec8QF	M0tHrt1GgV	4	0	0	0	2	\N	\N
Mhre2N9EYJ	2024-02-16 00:24:25.834+00	2024-02-16 00:24:25.834+00	dZKm0wOhYa	NY6RE1qgWu	4	1	0	1	4	\N	\N
HclakYXbuX	2024-02-16 00:24:26.038+00	2024-02-16 00:24:26.038+00	mQXQWNqxg9	lEPdiO1EDi	0	4	3	3	1	\N	\N
eB2yqrWkoP	2024-02-16 00:24:26.242+00	2024-02-16 00:24:26.242+00	5X202ssb0D	3u4B9V4l5K	3	1	0	2	1	\N	\N
zAY1e2JMm2	2024-02-16 00:24:26.447+00	2024-02-16 00:24:26.447+00	dEqAHvPMXA	Gl96vGdYHM	0	3	4	4	3	\N	\N
osaklMJ731	2024-02-16 00:24:26.757+00	2024-02-16 00:24:26.757+00	R2CLtFh5jU	LDrIH1vU8x	3	4	1	1	4	\N	\N
NwvvFGGU0T	2024-02-16 00:24:26.961+00	2024-02-16 00:24:26.961+00	sHiqaG4iqY	o4VD4BWwDt	3	3	0	2	3	\N	\N
hGQUanQgBN	2024-02-16 00:24:27.268+00	2024-02-16 00:24:27.268+00	mQXQWNqxg9	Pja6n3yaWZ	0	3	0	3	2	\N	\N
IjQMPnAGMf	2024-02-16 00:24:27.474+00	2024-02-16 00:24:27.474+00	dZKm0wOhYa	6Fo67rhTSP	1	3	4	3	3	\N	\N
wcSDHxUG1j	2024-02-16 00:24:27.684+00	2024-02-16 00:24:27.684+00	5X202ssb0D	fwLPZZ8YQa	0	4	2	3	0	\N	\N
q8Q6XGasTL	2024-02-16 00:24:27.89+00	2024-02-16 00:24:27.89+00	jqDYoPT45X	o90lhsZ7FK	4	0	2	2	2	\N	\N
kDYKtsVVqz	2024-02-16 00:24:28.193+00	2024-02-16 00:24:28.193+00	mQXQWNqxg9	Gl96vGdYHM	3	3	3	0	1	\N	\N
pcdtsliFFh	2024-02-16 00:24:28.403+00	2024-02-16 00:24:28.403+00	S6wz0lK0bf	rT0UCBK1bE	3	0	0	2	2	\N	\N
SSx0HOoU7r	2024-02-16 00:24:28.608+00	2024-02-16 00:24:28.608+00	mAKp5BK7R1	CSvk1ycWXk	3	2	3	4	1	\N	\N
xZEW5XDLO9	2024-02-16 00:24:28.818+00	2024-02-16 00:24:28.818+00	Otwj7uJwjr	3u4B9V4l5K	2	0	2	4	0	\N	\N
5d3041lAf7	2024-02-16 00:24:29.214+00	2024-02-16 00:24:29.214+00	5nv19u6KJ2	RkhjIQJgou	1	1	0	2	3	\N	\N
ezrChsDwd8	2024-02-16 00:24:29.417+00	2024-02-16 00:24:29.417+00	R2CLtFh5jU	0TvWuLoLF5	1	3	0	3	1	\N	\N
ESvrDBwwRc	2024-02-16 00:24:29.622+00	2024-02-16 00:24:29.622+00	R2CLtFh5jU	eEmewy7hPd	4	3	0	4	1	\N	\N
TsqukwmbCu	2024-02-16 00:24:29.825+00	2024-02-16 00:24:29.825+00	5nv19u6KJ2	VK3vnSxIy8	4	1	3	3	1	\N	\N
0UbAcMfiqW	2024-02-16 00:24:30.03+00	2024-02-16 00:24:30.03+00	RWwLSzreG2	LVYK4mLShP	4	4	1	2	2	\N	\N
0gcJIoCDC3	2024-02-16 00:24:30.235+00	2024-02-16 00:24:30.235+00	opW2wQ2bZ8	uigc7bJBOJ	0	3	1	0	4	\N	\N
tqdhjEUKpB	2024-02-16 00:24:30.44+00	2024-02-16 00:24:30.44+00	iUlyHNFGpG	CSvk1ycWXk	1	1	0	0	1	\N	\N
salas7tnvF	2024-02-16 00:24:30.645+00	2024-02-16 00:24:30.645+00	SFAISec8QF	TCkiw6gTDz	1	4	1	2	2	\N	\N
c2XO1mcpQe	2024-02-16 00:24:30.849+00	2024-02-16 00:24:30.849+00	mQXQWNqxg9	Pja6n3yaWZ	1	2	2	3	4	\N	\N
SNk8ORMFNd	2024-02-16 00:24:31.055+00	2024-02-16 00:24:31.055+00	9223vtvaBd	14jGmOAXcg	2	4	0	4	1	\N	\N
PPFaB2v5yT	2024-02-16 00:24:31.258+00	2024-02-16 00:24:31.258+00	mAKp5BK7R1	8w7i8C3NnT	4	0	4	3	1	\N	\N
b1D3EVR4Gz	2024-02-16 00:24:31.876+00	2024-02-16 00:24:31.876+00	sy1HD51LXT	Pa0qBO2rzK	4	0	2	4	4	\N	\N
HkIIrapkib	2024-02-16 00:24:32.18+00	2024-02-16 00:24:32.18+00	iUlyHNFGpG	3P6kmNoY1F	2	3	2	4	3	\N	\N
XEvqUAWedk	2024-02-16 00:24:32.491+00	2024-02-16 00:24:32.491+00	adE9nQrDk3	oABNR2FF6S	4	4	0	3	3	\N	\N
eCLHKpx2Hc	2024-02-16 00:24:32.798+00	2024-02-16 00:24:32.798+00	adE9nQrDk3	FYXEfIO1zF	3	1	0	3	4	\N	\N
Ji6A7rFK0K	2024-02-16 00:24:33.025+00	2024-02-16 00:24:33.025+00	VshUk7eBeK	WBFeKac0OO	0	4	1	0	1	\N	\N
GFlBOr72Jy	2024-02-16 00:24:33.23+00	2024-02-16 00:24:33.23+00	RWwLSzreG2	0TvWuLoLF5	2	0	2	3	0	\N	\N
LTRQZ2X6Nv	2024-02-16 00:24:33.438+00	2024-02-16 00:24:33.438+00	AsrLUQwxI9	3P6kmNoY1F	1	0	0	3	2	\N	\N
gfqMfoFB38	2024-02-16 00:24:33.644+00	2024-02-16 00:24:33.644+00	1as6rMOzjQ	INeptnSdJC	2	2	3	3	4	\N	\N
S5ucT3UQAe	2024-02-16 00:24:33.848+00	2024-02-16 00:24:33.848+00	adE9nQrDk3	AgU9OLJkqz	4	0	3	1	2	\N	\N
970b1hcWFC	2024-02-16 00:24:34.058+00	2024-02-16 00:24:34.058+00	Otwj7uJwjr	89xRG1afNi	0	2	3	0	2	\N	\N
XrjapeYi7F	2024-02-16 00:24:34.334+00	2024-02-16 00:24:34.334+00	iUlyHNFGpG	RkhjIQJgou	0	1	0	2	2	\N	\N
aIL0EmUOHR	2024-02-16 00:24:34.542+00	2024-02-16 00:24:34.542+00	jqDYoPT45X	FJOTueDfs2	1	2	2	4	2	\N	\N
24nNuCPNEH	2024-02-16 00:24:34.748+00	2024-02-16 00:24:34.748+00	jqDYoPT45X	XwWwGnkXNj	0	2	3	3	4	\N	\N
dGczP8KYLH	2024-02-16 00:24:34.955+00	2024-02-16 00:24:34.955+00	HRhGpJpmb5	INeptnSdJC	2	1	2	1	2	\N	\N
asKKblWV4B	2024-02-16 00:24:35.256+00	2024-02-16 00:24:35.256+00	VshUk7eBeK	cwVEh0dqfm	4	0	4	0	2	\N	\N
hhOBHDUOqm	2024-02-16 00:24:35.461+00	2024-02-16 00:24:35.461+00	9223vtvaBd	IybX0eBoO3	4	4	3	3	3	\N	\N
UeRnxK1Ut7	2024-02-16 00:24:35.664+00	2024-02-16 00:24:35.664+00	Otwj7uJwjr	TpGyMZM9BG	3	1	1	1	3	\N	\N
llZ9ilIuMy	2024-02-16 00:24:35.87+00	2024-02-16 00:24:35.87+00	S6wz0lK0bf	WnUBBkiDjE	4	4	0	0	2	\N	\N
OGmOV87DI0	2024-02-16 00:24:36.174+00	2024-02-16 00:24:36.174+00	dEqAHvPMXA	HSEugQ3Ouj	3	2	3	2	2	\N	\N
IFaiphN3hL	2024-02-16 00:24:36.484+00	2024-02-16 00:24:36.484+00	NjxsGlPeB4	VK3vnSxIy8	0	4	2	3	3	\N	\N
ssbkI0h5Jn	2024-02-16 00:24:36.791+00	2024-02-16 00:24:36.791+00	I5RzFRcQ7G	jHqCpA1nWb	0	1	1	1	0	\N	\N
8m1nbgpFZs	2024-02-16 00:24:36.997+00	2024-02-16 00:24:36.997+00	R2CLtFh5jU	Gl96vGdYHM	2	3	0	2	2	\N	\N
5izNGiJgX0	2024-02-16 00:24:37.204+00	2024-02-16 00:24:37.204+00	AsrLUQwxI9	mMYg4cyd5R	1	3	3	2	4	\N	\N
9snwfpC0pw	2024-02-16 00:24:37.412+00	2024-02-16 00:24:37.412+00	adE9nQrDk3	RkhjIQJgou	1	1	2	4	0	\N	\N
ivzMOxP0kg	2024-02-16 00:24:37.619+00	2024-02-16 00:24:37.619+00	WKpBp0c8F3	bQ0JOk10eL	4	2	4	4	0	\N	\N
bn7sA1jiLn	2024-02-16 00:24:37.918+00	2024-02-16 00:24:37.918+00	5nv19u6KJ2	tCIEnLLcUc	3	1	2	0	3	\N	\N
LIlN6olXfn	2024-02-16 00:24:38.532+00	2024-02-16 00:24:38.532+00	NjxsGlPeB4	cmxBcanww9	2	2	2	1	0	\N	\N
ixXZIaHn3I	2024-02-16 00:24:39.147+00	2024-02-16 00:24:39.147+00	I5RzFRcQ7G	axyV0Fu7pm	4	2	4	3	4	\N	\N
2yrSfKa2on	2024-02-16 00:24:39.456+00	2024-02-16 00:24:39.456+00	ONgyydfVNz	XwszrNEEEj	3	0	1	1	1	\N	\N
nIcvc4nnpa	2024-02-16 00:24:39.659+00	2024-02-16 00:24:39.659+00	R2CLtFh5jU	jjVdtithcD	0	2	1	0	3	\N	\N
CiCZCeQEFT	2024-02-16 00:24:39.866+00	2024-02-16 00:24:39.866+00	NjxsGlPeB4	XpUyRlB6FI	2	4	2	3	3	\N	\N
v6NYklSMoo	2024-02-16 00:24:40.068+00	2024-02-16 00:24:40.068+00	HRhGpJpmb5	uigc7bJBOJ	4	1	0	3	0	\N	\N
dZLFKwe5Qx	2024-02-16 00:24:40.376+00	2024-02-16 00:24:40.376+00	5nv19u6KJ2	m8hjjLVdPS	2	4	3	3	1	\N	\N
VX5oAP48jH	2024-02-16 00:24:41.093+00	2024-02-16 00:24:41.093+00	5X202ssb0D	IEqTHcohpJ	3	1	4	1	4	\N	\N
0F4R3F2wnT	2024-02-16 00:24:41.402+00	2024-02-16 00:24:41.402+00	RWwLSzreG2	jHqCpA1nWb	3	1	1	3	3	\N	\N
PFVoPwTyGD	2024-02-16 00:24:41.605+00	2024-02-16 00:24:41.605+00	WKpBp0c8F3	Pja6n3yaWZ	0	4	4	3	2	\N	\N
1nuvwfBTXI	2024-02-16 00:24:41.809+00	2024-02-16 00:24:41.809+00	S6wz0lK0bf	eEmewy7hPd	3	3	0	2	0	\N	\N
vN3VnqXG4b	2024-02-16 00:24:42.012+00	2024-02-16 00:24:42.012+00	1as6rMOzjQ	JRi61dUphq	3	3	3	2	2	\N	\N
PB45zR8Pl9	2024-02-16 00:24:42.22+00	2024-02-16 00:24:42.22+00	9223vtvaBd	vwHi602n66	1	4	2	1	0	\N	\N
IMjKNxo3j8	2024-02-16 00:24:42.423+00	2024-02-16 00:24:42.423+00	Otwj7uJwjr	y4RkaDbkec	0	4	3	1	0	\N	\N
R50oWQPOzP	2024-02-16 00:24:42.626+00	2024-02-16 00:24:42.626+00	sy1HD51LXT	CSvk1ycWXk	3	2	2	4	3	\N	\N
EmEnEtxSm0	2024-02-16 00:24:42.831+00	2024-02-16 00:24:42.831+00	dEqAHvPMXA	WHvlAGgj6c	2	2	3	0	2	\N	\N
BwpTPZjATc	2024-02-16 00:24:43.036+00	2024-02-16 00:24:43.036+00	sHiqaG4iqY	NBojpORh3G	3	4	3	2	2	\N	\N
6HsBhMj9Xz	2024-02-16 00:24:43.24+00	2024-02-16 00:24:43.24+00	dEqAHvPMXA	m6g8u0QpTC	3	1	3	2	2	\N	\N
I4mWjJbTNC	2024-02-16 00:24:43.442+00	2024-02-16 00:24:43.442+00	R2CLtFh5jU	6Fo67rhTSP	2	0	2	4	4	\N	\N
S0tFxLCwaW	2024-02-16 00:24:43.646+00	2024-02-16 00:24:43.646+00	adE9nQrDk3	XwszrNEEEj	1	4	1	1	2	\N	\N
EdeZ4zuLs5	2024-02-16 00:24:43.852+00	2024-02-16 00:24:43.852+00	sHiqaG4iqY	j0dWqP2C2A	1	0	2	3	1	\N	\N
EeGYBNA6Wq	2024-02-16 00:24:44.057+00	2024-02-16 00:24:44.057+00	5nv19u6KJ2	LDrIH1vU8x	1	1	2	0	0	\N	\N
qQJMycVa7q	2024-02-16 00:24:44.267+00	2024-02-16 00:24:44.267+00	mQXQWNqxg9	qEQ9tmLyW9	3	1	1	0	0	\N	\N
aCItDDAFjP	2024-02-16 00:24:44.476+00	2024-02-16 00:24:44.476+00	VshUk7eBeK	9GF3y7LmHV	3	4	2	1	0	\N	\N
VD7s9nnFhV	2024-02-16 00:24:44.779+00	2024-02-16 00:24:44.779+00	HRhGpJpmb5	o90lhsZ7FK	2	1	3	4	4	\N	\N
41gg5jTMdP	2024-02-16 00:24:45.087+00	2024-02-16 00:24:45.087+00	5X202ssb0D	eEmewy7hPd	3	0	4	4	3	\N	\N
wsljOCckIm	2024-02-16 00:24:45.294+00	2024-02-16 00:24:45.294+00	I5RzFRcQ7G	bi1IivsuUB	3	1	1	0	0	\N	\N
n9sZfhsVwJ	2024-02-16 00:24:45.5+00	2024-02-16 00:24:45.5+00	jqDYoPT45X	Pja6n3yaWZ	1	0	0	4	3	\N	\N
e096QjwAL5	2024-02-16 00:24:45.7+00	2024-02-16 00:24:45.7+00	ONgyydfVNz	D0A6GLdsDM	2	3	4	2	0	\N	\N
AxOEcA1qIE	2024-02-16 00:24:45.904+00	2024-02-16 00:24:45.904+00	VshUk7eBeK	XwWwGnkXNj	1	0	0	4	0	\N	\N
NAZ4fJFHXh	2024-02-16 00:24:46.212+00	2024-02-16 00:24:46.212+00	HRhGpJpmb5	D0A6GLdsDM	2	1	3	3	0	\N	\N
mYOdfGzCUz	2024-02-16 00:24:46.418+00	2024-02-16 00:24:46.418+00	HtEtaHBVDN	LVYK4mLShP	0	4	2	1	0	\N	\N
VQv3tZHkjV	2024-02-16 00:24:46.731+00	2024-02-16 00:24:46.731+00	RWwLSzreG2	G0uU7KQLEt	3	3	3	3	0	\N	\N
KP4g86XmED	2024-02-16 00:24:46.937+00	2024-02-16 00:24:46.937+00	VshUk7eBeK	BMLzFMvIT6	2	0	3	1	3	\N	\N
9yCX6bAQk2	2024-02-16 00:24:47.544+00	2024-02-16 00:24:47.544+00	WKpBp0c8F3	Pa0qBO2rzK	0	3	4	4	0	\N	\N
cJkkf05gxB	2024-02-16 00:24:47.853+00	2024-02-16 00:24:47.853+00	ONgyydfVNz	qEQ9tmLyW9	1	0	2	4	4	\N	\N
5IHZ9AN1ZF	2024-02-16 00:24:48.057+00	2024-02-16 00:24:48.057+00	WKpBp0c8F3	bQpy9LEJWn	2	2	4	3	2	\N	\N
UXC7gRhvMi	2024-02-16 00:24:48.266+00	2024-02-16 00:24:48.266+00	HtEtaHBVDN	jjVdtithcD	3	4	2	2	0	\N	\N
hOIAHl78Xl	2024-02-16 00:24:48.472+00	2024-02-16 00:24:48.472+00	mAKp5BK7R1	u5FXeeOChJ	2	3	4	4	2	\N	\N
UgBbysioZy	2024-02-16 00:24:48.773+00	2024-02-16 00:24:48.773+00	1as6rMOzjQ	mMYg4cyd5R	1	3	3	2	3	\N	\N
0LrH3ZVxCB	2024-02-16 00:24:48.977+00	2024-02-16 00:24:48.977+00	HtEtaHBVDN	qEQ9tmLyW9	3	1	1	1	0	\N	\N
2Kd02j4u8k	2024-02-16 00:24:49.452+00	2024-02-16 00:24:49.452+00	dEqAHvPMXA	WSTLlXDcKl	1	1	1	2	2	\N	\N
gVRRp35wcI	2024-02-16 00:24:49.658+00	2024-02-16 00:24:49.658+00	jqDYoPT45X	D0A6GLdsDM	1	0	1	0	4	\N	\N
a14NxQZ5vY	2024-02-16 00:24:49.862+00	2024-02-16 00:24:49.862+00	dEqAHvPMXA	jjVdtithcD	4	0	4	1	2	\N	\N
EBtsiqgrOF	2024-02-16 00:24:50.066+00	2024-02-16 00:24:50.066+00	HRhGpJpmb5	cTIjuPjyIa	1	3	4	3	4	\N	\N
WE16enGTNN	2024-02-16 00:24:50.27+00	2024-02-16 00:24:50.27+00	iWxl9obi8w	qEQ9tmLyW9	4	1	1	0	0	\N	\N
VvOtwj5cN0	2024-02-16 00:24:50.616+00	2024-02-16 00:24:50.616+00	R2CLtFh5jU	Gl96vGdYHM	4	1	4	2	3	\N	\N
qbnVbX2nZv	2024-02-16 00:24:50.819+00	2024-02-16 00:24:50.819+00	dEqAHvPMXA	VK3vnSxIy8	1	4	3	1	0	\N	\N
sxnI5PGmGq	2024-02-16 00:24:51.339+00	2024-02-16 00:24:51.339+00	SFAISec8QF	FYXEfIO1zF	1	2	3	3	1	\N	\N
BDpx20KeAa	2024-02-16 00:24:51.544+00	2024-02-16 00:24:51.544+00	HtEtaHBVDN	y4RkaDbkec	0	2	2	0	1	\N	\N
axYSjH9UqM	2024-02-16 00:24:51.845+00	2024-02-16 00:24:51.845+00	mAKp5BK7R1	XwszrNEEEj	4	0	3	4	2	\N	\N
0UYdmVPS6f	2024-02-16 00:24:52.153+00	2024-02-16 00:24:52.153+00	dZKm0wOhYa	IybX0eBoO3	4	4	4	1	3	\N	\N
6XBwaZJTqM	2024-02-16 00:24:52.727+00	2024-02-16 00:24:52.727+00	Otwj7uJwjr	0TvWuLoLF5	2	2	1	3	2	\N	\N
U8kvnxvXpG	2024-02-16 00:24:52.934+00	2024-02-16 00:24:52.934+00	adE9nQrDk3	vwHi602n66	4	3	0	0	0	\N	\N
bHgYYnv8yF	2024-02-16 00:24:53.147+00	2024-02-16 00:24:53.147+00	NjxsGlPeB4	jHqCpA1nWb	4	2	4	4	2	\N	\N
sPeiylnypk	2024-02-16 00:24:53.381+00	2024-02-16 00:24:53.381+00	HRhGpJpmb5	UCFo58JaaD	2	3	3	0	4	\N	\N
7Mv9CtHjht	2024-02-16 00:24:53.587+00	2024-02-16 00:24:53.587+00	RWwLSzreG2	o90lhsZ7FK	0	2	0	2	1	\N	\N
ByotiFfPOv	2024-02-16 00:24:53.793+00	2024-02-16 00:24:53.793+00	HtEtaHBVDN	IEqTHcohpJ	4	2	2	4	1	\N	\N
4BZsocbnkJ	2024-02-16 00:24:53.999+00	2024-02-16 00:24:53.999+00	VshUk7eBeK	NBojpORh3G	1	1	2	0	3	\N	\N
YHRGgXb1pA	2024-02-16 00:24:54.815+00	2024-02-16 00:24:54.815+00	mAKp5BK7R1	FYXEfIO1zF	3	0	0	2	1	\N	\N
gtZKUSEL1y	2024-02-16 00:24:55.225+00	2024-02-16 00:24:55.225+00	1as6rMOzjQ	cTIjuPjyIa	0	1	0	4	0	\N	\N
cH9C9lQbzD	2024-02-16 00:24:55.434+00	2024-02-16 00:24:55.434+00	RWwLSzreG2	qZmnAnnPEb	0	4	2	4	2	\N	\N
FjTpFhiKbD	2024-02-16 00:24:55.737+00	2024-02-16 00:24:55.737+00	iUlyHNFGpG	bQpy9LEJWn	2	2	3	0	1	\N	\N
MD3HCNhPEe	2024-02-16 00:24:55.941+00	2024-02-16 00:24:55.941+00	VshUk7eBeK	WSTLlXDcKl	2	2	1	1	1	\N	\N
ij146xaHD9	2024-02-16 00:24:56.247+00	2024-02-16 00:24:56.247+00	dZKm0wOhYa	axyV0Fu7pm	3	0	2	0	1	\N	\N
FSIKbu6uiL	2024-02-16 00:24:56.556+00	2024-02-16 00:24:56.556+00	mQXQWNqxg9	OQWu2bnHeC	3	1	4	3	0	\N	\N
qzFgaNdOAF	2024-02-16 00:24:57.068+00	2024-02-16 00:24:57.068+00	HRhGpJpmb5	rKyjwoEIRp	3	1	2	2	3	\N	\N
gBp8Er5OhD	2024-02-16 00:24:57.376+00	2024-02-16 00:24:57.376+00	I5RzFRcQ7G	3u4B9V4l5K	0	4	0	1	1	\N	\N
p1r6ohGZoA	2024-02-16 00:24:57.586+00	2024-02-16 00:24:57.586+00	VshUk7eBeK	Oahm9sOn1y	1	4	3	4	3	\N	\N
LA9Uz568eO	2024-02-16 00:24:57.887+00	2024-02-16 00:24:57.887+00	Otwj7uJwjr	AgU9OLJkqz	0	3	3	3	3	\N	\N
SRMCIpubwn	2024-02-16 00:24:58.195+00	2024-02-16 00:24:58.195+00	NjxsGlPeB4	e037qpAih3	1	1	2	2	4	\N	\N
C2YlBRl1Kx	2024-02-16 00:24:58.404+00	2024-02-16 00:24:58.404+00	HRhGpJpmb5	vwHi602n66	3	0	4	0	3	\N	\N
xNEKHNx9em	2024-02-16 00:24:58.611+00	2024-02-16 00:24:58.611+00	I5RzFRcQ7G	HXtEwLBC7f	2	4	2	2	0	\N	\N
S3f88lDMmw	2024-02-16 00:24:58.82+00	2024-02-16 00:24:58.82+00	WKpBp0c8F3	H40ivltLwZ	3	1	3	1	1	\N	\N
WYQEjfBrsp	2024-02-16 00:24:59.025+00	2024-02-16 00:24:59.025+00	sHiqaG4iqY	Gl96vGdYHM	2	3	3	3	4	\N	\N
Lh2T0KIO19	2024-02-16 00:24:59.232+00	2024-02-16 00:24:59.232+00	WKpBp0c8F3	uigc7bJBOJ	1	2	1	3	1	\N	\N
P9rVtCxmMO	2024-02-16 00:24:59.526+00	2024-02-16 00:24:59.526+00	ONgyydfVNz	ThMuD3hYRQ	4	3	1	4	1	\N	\N
IJRqZvlcAv	2024-02-16 00:24:59.732+00	2024-02-16 00:24:59.732+00	iUlyHNFGpG	D0A6GLdsDM	2	4	0	3	3	\N	\N
1KmKfCOEp9	2024-02-16 00:25:00.038+00	2024-02-16 00:25:00.038+00	adE9nQrDk3	rKyjwoEIRp	0	1	1	0	2	\N	\N
B1dwaMm2WO	2024-02-16 00:25:00.242+00	2024-02-16 00:25:00.242+00	jqDYoPT45X	rKyjwoEIRp	1	2	1	4	2	\N	\N
98Gx6OjX5n	2024-02-16 00:25:00.448+00	2024-02-16 00:25:00.448+00	RWwLSzreG2	bQ0JOk10eL	3	1	3	4	3	\N	\N
3aWvZ9DbuL	2024-02-16 00:25:00.653+00	2024-02-16 00:25:00.653+00	I5RzFRcQ7G	WBFeKac0OO	2	1	0	3	0	\N	\N
ZAgAJlL2dK	2024-02-16 00:25:00.859+00	2024-02-16 00:25:00.859+00	HtEtaHBVDN	OQWu2bnHeC	0	3	2	2	0	\N	\N
jZo5mDh9y1	2024-02-16 00:25:01.471+00	2024-02-16 00:25:01.471+00	5nv19u6KJ2	TCkiw6gTDz	2	3	2	0	1	\N	\N
xExoJ35J2F	2024-02-16 00:25:01.778+00	2024-02-16 00:25:01.778+00	5nv19u6KJ2	lEPdiO1EDi	2	1	4	0	1	\N	\N
KFEZXSZpjB	2024-02-16 00:25:02.087+00	2024-02-16 00:25:02.087+00	RWwLSzreG2	uABtFsJhJc	1	3	2	0	3	\N	\N
PA9J32VzzP	2024-02-16 00:25:02.696+00	2024-02-16 00:25:02.696+00	sHiqaG4iqY	VK3vnSxIy8	1	4	2	3	3	\N	\N
VN8q6bAzPc	2024-02-16 00:25:03.112+00	2024-02-16 00:25:03.112+00	iUlyHNFGpG	XwszrNEEEj	2	2	1	1	2	\N	\N
39WnF6W1gC	2024-02-16 00:25:03.314+00	2024-02-16 00:25:03.314+00	S6wz0lK0bf	u5FXeeOChJ	1	3	1	4	0	\N	\N
lO5h3HCnbg	2024-02-16 00:25:03.517+00	2024-02-16 00:25:03.517+00	S6wz0lK0bf	vwHi602n66	4	1	0	3	2	\N	\N
Po8biyo8dJ	2024-02-16 00:25:03.723+00	2024-02-16 00:25:03.723+00	SFAISec8QF	Pa0qBO2rzK	3	4	4	1	2	\N	\N
ZUghWrUU5g	2024-02-16 00:25:03.929+00	2024-02-16 00:25:03.929+00	AsrLUQwxI9	Oahm9sOn1y	4	0	1	4	4	\N	\N
scaj7yVojU	2024-02-16 00:25:04.137+00	2024-02-16 00:25:04.137+00	WKpBp0c8F3	qEQ9tmLyW9	0	1	4	4	1	\N	\N
J9GNgikBts	2024-02-16 00:25:04.341+00	2024-02-16 00:25:04.341+00	adE9nQrDk3	CSvk1ycWXk	2	4	0	3	2	\N	\N
VHo7zVnQh6	2024-02-16 00:25:04.647+00	2024-02-16 00:25:04.647+00	5X202ssb0D	fwLPZZ8YQa	1	1	1	3	2	\N	\N
aFrVVbV0Ru	2024-02-16 00:25:04.851+00	2024-02-16 00:25:04.851+00	NjxsGlPeB4	m6g8u0QpTC	1	4	2	4	0	\N	\N
k5Jbzf8ip7	2024-02-16 00:25:05.056+00	2024-02-16 00:25:05.056+00	5X202ssb0D	NBojpORh3G	2	4	3	0	2	\N	\N
aZ3U6UvPXo	2024-02-16 00:25:05.259+00	2024-02-16 00:25:05.259+00	iWxl9obi8w	fwLPZZ8YQa	1	1	4	1	1	\N	\N
CGQVWAI4Fs	2024-02-16 00:25:05.464+00	2024-02-16 00:25:05.464+00	SFAISec8QF	fwLPZZ8YQa	0	4	3	0	4	\N	\N
UHgpoM64qO	2024-02-16 00:25:05.683+00	2024-02-16 00:25:05.683+00	mAKp5BK7R1	WSTLlXDcKl	2	2	4	4	4	\N	\N
H1frxWTyeb	2024-02-16 00:25:05.889+00	2024-02-16 00:25:05.889+00	Otwj7uJwjr	ThMuD3hYRQ	1	3	2	1	0	\N	\N
G3nPtboiCj	2024-02-16 00:25:06.179+00	2024-02-16 00:25:06.179+00	NjxsGlPeB4	HXtEwLBC7f	0	4	3	3	1	\N	\N
W59Uy0kqM0	2024-02-16 00:25:06.386+00	2024-02-16 00:25:06.386+00	sHiqaG4iqY	ThMuD3hYRQ	2	2	1	0	2	\N	\N
tPU03ZxUUb	2024-02-16 00:25:06.594+00	2024-02-16 00:25:06.594+00	SFAISec8QF	cTIjuPjyIa	0	2	2	4	4	\N	\N
TzVKGXWBp2	2024-02-16 00:25:07.204+00	2024-02-16 00:25:07.204+00	iWxl9obi8w	PF8w2gMAdi	1	3	1	2	2	\N	\N
QjCGhoGANe	2024-02-16 00:25:07.408+00	2024-02-16 00:25:07.408+00	ONgyydfVNz	RkhjIQJgou	2	0	4	2	1	\N	\N
XD6ILcMLxn	2024-02-16 00:25:07.613+00	2024-02-16 00:25:07.613+00	mAKp5BK7R1	E2hBZzDsjO	2	1	3	4	1	\N	\N
tGQb733aKa	2024-02-16 00:25:07.818+00	2024-02-16 00:25:07.818+00	sHiqaG4iqY	rKyjwoEIRp	3	3	0	3	4	\N	\N
aqjQSuTMjL	2024-02-16 00:25:08.332+00	2024-02-16 00:25:08.332+00	sHiqaG4iqY	fxvABtKCPT	2	3	0	2	1	\N	\N
8DaUDF5FGy	2024-02-16 00:25:09.459+00	2024-02-16 00:25:09.459+00	5nv19u6KJ2	JRi61dUphq	3	1	0	0	2	\N	\N
hj6UVfFG9V	2024-02-16 00:25:09.667+00	2024-02-16 00:25:09.667+00	mQXQWNqxg9	m8hjjLVdPS	3	2	4	2	3	\N	\N
P3Ht9k4ZZv	2024-02-16 00:25:09.871+00	2024-02-16 00:25:09.871+00	SFAISec8QF	G0uU7KQLEt	2	0	2	2	0	\N	\N
10xznRJ5uu	2024-02-16 00:25:10.081+00	2024-02-16 00:25:10.081+00	opW2wQ2bZ8	HXtEwLBC7f	2	2	3	1	4	\N	\N
UPb8KnKgXF	2024-02-16 00:25:10.287+00	2024-02-16 00:25:10.287+00	adE9nQrDk3	tCIEnLLcUc	3	3	0	0	3	\N	\N
6x9o5195Cs	2024-02-16 00:25:10.493+00	2024-02-16 00:25:10.493+00	sy1HD51LXT	lxQA9rtSfY	4	2	4	1	4	\N	\N
WqZgWSiXbN	2024-02-16 00:25:10.701+00	2024-02-16 00:25:10.701+00	ONgyydfVNz	H40ivltLwZ	1	1	0	2	1	\N	\N
q4fURWMaMw	2024-02-16 00:25:10.905+00	2024-02-16 00:25:10.905+00	Otwj7uJwjr	e037qpAih3	2	0	4	2	4	\N	\N
GCfrMECOHD	2024-02-16 00:25:11.198+00	2024-02-16 00:25:11.198+00	AsrLUQwxI9	HLIPwAqO2R	3	1	2	0	3	\N	\N
1XVZjMBTiq	2024-02-16 00:25:11.507+00	2024-02-16 00:25:11.507+00	R2CLtFh5jU	0TvWuLoLF5	4	2	1	0	2	\N	\N
ohuqtG4u2h	2024-02-16 00:25:12.121+00	2024-02-16 00:25:12.121+00	sHiqaG4iqY	jHqCpA1nWb	3	2	4	0	1	\N	\N
uBpCQNLtb4	2024-02-16 00:25:12.324+00	2024-02-16 00:25:12.324+00	VshUk7eBeK	cwVEh0dqfm	4	0	4	2	4	\N	\N
9Yz8RL3o23	2024-02-16 00:25:12.53+00	2024-02-16 00:25:12.53+00	SFAISec8QF	fxvABtKCPT	3	3	0	2	4	\N	\N
2rdJD9BfEh	2024-02-16 00:25:12.737+00	2024-02-16 00:25:12.737+00	mAKp5BK7R1	Oahm9sOn1y	0	3	4	2	3	\N	\N
yJ8cmWSTXG	2024-02-16 00:25:13.043+00	2024-02-16 00:25:13.043+00	sy1HD51LXT	H40ivltLwZ	0	1	1	2	1	\N	\N
0NoJzWYeJ1	2024-02-16 00:25:13.245+00	2024-02-16 00:25:13.245+00	S6wz0lK0bf	08liHW08uC	1	1	4	1	0	\N	\N
ePunF62amE	2024-02-16 00:25:13.451+00	2024-02-16 00:25:13.451+00	R2CLtFh5jU	BMLzFMvIT6	3	3	0	1	0	\N	\N
yfiGfbaFNE	2024-02-16 00:25:13.657+00	2024-02-16 00:25:13.657+00	dZKm0wOhYa	TpGyMZM9BG	2	0	4	2	0	\N	\N
c25cr4SZDB	2024-02-16 00:25:13.862+00	2024-02-16 00:25:13.862+00	RWwLSzreG2	IEqTHcohpJ	2	4	3	1	0	\N	\N
kk2VZyl8FW	2024-02-16 00:25:14.17+00	2024-02-16 00:25:14.17+00	VshUk7eBeK	P9sBFomftT	0	3	2	0	4	\N	\N
S22kQ9JR9C	2024-02-16 00:25:14.887+00	2024-02-16 00:25:14.887+00	dZKm0wOhYa	6Fo67rhTSP	4	1	1	0	2	\N	\N
vBsx8gaaq9	2024-02-16 00:25:15.705+00	2024-02-16 00:25:15.705+00	adE9nQrDk3	cmxBcanww9	3	2	2	1	2	\N	\N
lRt4iQCNVX	2024-02-16 00:25:16.218+00	2024-02-16 00:25:16.218+00	mAKp5BK7R1	G0uU7KQLEt	1	3	1	0	4	\N	\N
KYhGq5kuYV	2024-02-16 00:25:16.42+00	2024-02-16 00:25:16.42+00	5nv19u6KJ2	rKyjwoEIRp	1	2	2	0	4	\N	\N
bLqVk8oTFA	2024-02-16 00:25:16.731+00	2024-02-16 00:25:16.731+00	adE9nQrDk3	cFtamPA0zH	1	3	4	2	3	\N	\N
37aDJp0Qp4	2024-02-16 00:25:16.938+00	2024-02-16 00:25:16.938+00	ONgyydfVNz	o4VD4BWwDt	0	0	0	4	1	\N	\N
bQnFuwUDGz	2024-02-16 00:25:17.139+00	2024-02-16 00:25:17.139+00	mQXQWNqxg9	o4VD4BWwDt	4	1	4	0	0	\N	\N
a0N1rbIQ6G	2024-02-16 00:25:17.345+00	2024-02-16 00:25:17.345+00	adE9nQrDk3	fxvABtKCPT	4	3	2	3	1	\N	\N
xXK0ZsHe3J	2024-02-16 00:25:17.549+00	2024-02-16 00:25:17.549+00	R2CLtFh5jU	yvUod6yLDt	3	3	3	1	0	\N	\N
wRyoquPRC2	2024-02-16 00:25:17.755+00	2024-02-16 00:25:17.755+00	mAKp5BK7R1	JZOBDAh12a	1	4	2	2	1	\N	\N
erKsX4fhYH	2024-02-16 00:25:17.958+00	2024-02-16 00:25:17.958+00	jqDYoPT45X	ThMuD3hYRQ	2	3	0	2	4	\N	\N
3eED1IIuhk	2024-02-16 00:25:18.572+00	2024-02-16 00:25:18.572+00	S6wz0lK0bf	89xRG1afNi	3	4	1	1	1	\N	\N
ztmYKq7lTH	2024-02-16 00:25:18.881+00	2024-02-16 00:25:18.881+00	opW2wQ2bZ8	XSK814B37m	2	0	1	4	0	\N	\N
mtT9J0oEKp	2024-02-16 00:25:19.186+00	2024-02-16 00:25:19.186+00	HtEtaHBVDN	IEqTHcohpJ	3	1	0	0	4	\N	\N
tKmqJwc252	2024-02-16 00:25:19.494+00	2024-02-16 00:25:19.494+00	dZKm0wOhYa	WBFeKac0OO	0	1	4	0	3	\N	\N
6UyBqSXlMS	2024-02-16 00:25:20.108+00	2024-02-16 00:25:20.108+00	Otwj7uJwjr	14jGmOAXcg	4	1	3	0	4	\N	\N
CuisEsr1u5	2024-02-16 00:25:20.416+00	2024-02-16 00:25:20.416+00	R2CLtFh5jU	JRi61dUphq	3	4	4	2	1	\N	\N
G6hlcDKAyw	2024-02-16 00:25:20.784+00	2024-02-16 00:25:20.784+00	mQXQWNqxg9	TCkiw6gTDz	1	1	3	3	1	\N	\N
FuQZQgUiDA	2024-02-16 00:25:21.646+00	2024-02-16 00:25:21.646+00	HRhGpJpmb5	IEqTHcohpJ	3	4	3	3	4	\N	\N
J20JqQx7Dw	2024-02-16 00:25:21.952+00	2024-02-16 00:25:21.952+00	HRhGpJpmb5	LVYK4mLShP	3	2	2	4	4	\N	\N
NKXd0C9yPa	2024-02-16 00:25:22.156+00	2024-02-16 00:25:22.156+00	iUlyHNFGpG	tCIEnLLcUc	4	4	4	2	4	\N	\N
CPokcc4aqv	2024-02-16 00:25:22.36+00	2024-02-16 00:25:22.36+00	mAKp5BK7R1	XSK814B37m	2	4	0	2	4	\N	\N
rT9Sa79jg9	2024-02-16 00:25:22.566+00	2024-02-16 00:25:22.566+00	sy1HD51LXT	UDXF0qXvDY	1	3	2	2	2	\N	\N
M7bB5MoByG	2024-02-16 00:25:22.775+00	2024-02-16 00:25:22.775+00	5nv19u6KJ2	mMYg4cyd5R	0	1	0	2	1	\N	\N
IEorB3lhQu	2024-02-16 00:25:22.981+00	2024-02-16 00:25:22.981+00	RWwLSzreG2	fwLPZZ8YQa	3	0	4	0	3	\N	\N
h52khqqROV	2024-02-16 00:25:23.185+00	2024-02-16 00:25:23.185+00	9223vtvaBd	9GF3y7LmHV	0	0	4	2	4	\N	\N
JPlmtL9Ilr	2024-02-16 00:25:23.39+00	2024-02-16 00:25:23.39+00	HRhGpJpmb5	TpGyMZM9BG	1	2	0	4	3	\N	\N
pHdB7T4DHU	2024-02-16 00:25:23.592+00	2024-02-16 00:25:23.592+00	mQXQWNqxg9	JLhF4VuByh	1	4	0	1	4	\N	\N
U5svGfz2WC	2024-02-16 00:25:23.794+00	2024-02-16 00:25:23.794+00	sy1HD51LXT	H40ivltLwZ	0	2	1	4	1	\N	\N
PqaP4FAcnR	2024-02-16 00:25:24.104+00	2024-02-16 00:25:24.104+00	WKpBp0c8F3	IybX0eBoO3	1	1	2	2	1	\N	\N
cVPWjy7ZrW	2024-02-16 00:25:24.306+00	2024-02-16 00:25:24.306+00	9223vtvaBd	lEPdiO1EDi	2	1	4	3	1	\N	\N
q1bybKhZuP	2024-02-16 00:25:24.615+00	2024-02-16 00:25:24.615+00	SFAISec8QF	uigc7bJBOJ	0	2	4	1	0	\N	\N
Xuf94bU6Sz	2024-02-16 00:25:25.226+00	2024-02-16 00:25:25.226+00	I5RzFRcQ7G	WSTLlXDcKl	4	1	0	3	4	\N	\N
CmeaXfSvRd	2024-02-16 00:25:25.43+00	2024-02-16 00:25:25.43+00	S6wz0lK0bf	qP3EdIVzfB	1	1	0	0	1	\N	\N
SjVTbf4pau	2024-02-16 00:25:25.632+00	2024-02-16 00:25:25.632+00	jqDYoPT45X	OQWu2bnHeC	2	4	3	4	3	\N	\N
OjtUFpmAHI	2024-02-16 00:25:25.837+00	2024-02-16 00:25:25.837+00	5X202ssb0D	jjVdtithcD	0	3	2	0	4	\N	\N
NAsePxoV8v	2024-02-16 00:25:26.046+00	2024-02-16 00:25:26.046+00	R2CLtFh5jU	14jGmOAXcg	0	1	0	1	1	\N	\N
QCu6tYvidP	2024-02-16 00:25:26.765+00	2024-02-16 00:25:26.765+00	9223vtvaBd	NY6RE1qgWu	2	4	2	4	2	\N	\N
KdThQFGrXv	2024-02-16 00:25:28.098+00	2024-02-16 00:25:28.098+00	Otwj7uJwjr	fKTSJPdUi9	3	0	4	2	0	\N	\N
bVWan08Z7Y	2024-02-16 00:25:28.305+00	2024-02-16 00:25:28.305+00	mAKp5BK7R1	CSvk1ycWXk	4	2	0	1	3	\N	\N
CdDZaTFI0w	2024-02-16 00:25:28.51+00	2024-02-16 00:25:28.51+00	sy1HD51LXT	qZmnAnnPEb	0	3	4	2	3	\N	\N
XnqzTbMXkm	2024-02-16 00:25:28.713+00	2024-02-16 00:25:28.713+00	sy1HD51LXT	bQpy9LEJWn	0	1	0	4	4	\N	\N
oofAnezHOs	2024-02-16 00:25:29.019+00	2024-02-16 00:25:29.019+00	HRhGpJpmb5	uABtFsJhJc	3	2	0	4	0	\N	\N
vG796Puz0y	2024-02-16 00:25:29.325+00	2024-02-16 00:25:29.325+00	dEqAHvPMXA	cmxBcanww9	0	3	1	4	1	\N	\N
FRwf7JWg2Y	2024-02-16 00:25:29.528+00	2024-02-16 00:25:29.528+00	iWxl9obi8w	lxQA9rtSfY	4	0	0	0	1	\N	\N
RDuf3wqX7c	2024-02-16 00:25:29.733+00	2024-02-16 00:25:29.733+00	HRhGpJpmb5	G0uU7KQLEt	4	2	4	2	3	\N	\N
RvYD3wE0lK	2024-02-16 00:25:29.939+00	2024-02-16 00:25:29.939+00	mQXQWNqxg9	AgU9OLJkqz	1	2	0	2	0	\N	\N
Zx9hCyWZW6	2024-02-16 00:25:30.145+00	2024-02-16 00:25:30.145+00	SFAISec8QF	o90lhsZ7FK	3	4	4	4	4	\N	\N
v8x1cBpfWz	2024-02-16 00:25:30.351+00	2024-02-16 00:25:30.351+00	5X202ssb0D	BMLzFMvIT6	2	4	2	4	2	\N	\N
k8FJJFHYoB	2024-02-16 00:25:30.965+00	2024-02-16 00:25:30.965+00	sy1HD51LXT	l1Bslv8T2k	4	4	0	1	2	\N	\N
OfcopSmXHG	2024-02-16 00:25:31.17+00	2024-02-16 00:25:31.17+00	5nv19u6KJ2	9GF3y7LmHV	0	0	0	0	2	\N	\N
s6Rb0GuBNw	2024-02-16 00:25:31.476+00	2024-02-16 00:25:31.476+00	mAKp5BK7R1	3u4B9V4l5K	3	0	1	4	4	\N	\N
yweXIAG0ji	2024-02-16 00:25:31.783+00	2024-02-16 00:25:31.783+00	Otwj7uJwjr	oABNR2FF6S	0	1	0	1	4	\N	\N
BEwlvB8BuZ	2024-02-16 00:25:32.089+00	2024-02-16 00:25:32.089+00	opW2wQ2bZ8	lxQA9rtSfY	4	1	2	3	3	\N	\N
EagaWGdXqS	2024-02-16 00:25:32.293+00	2024-02-16 00:25:32.293+00	VshUk7eBeK	o4VD4BWwDt	0	4	3	0	1	\N	\N
xo0ddoMY69	2024-02-16 00:25:32.498+00	2024-02-16 00:25:32.498+00	dEqAHvPMXA	eEmewy7hPd	1	3	4	4	4	\N	\N
I4wPNNQT1q	2024-02-16 00:25:32.807+00	2024-02-16 00:25:32.807+00	dEqAHvPMXA	jjVdtithcD	1	4	4	2	3	\N	\N
ORuRCg7vTM	2024-02-16 00:25:33.217+00	2024-02-16 00:25:33.217+00	opW2wQ2bZ8	14jGmOAXcg	0	3	3	4	1	\N	\N
hFofNLWbOt	2024-02-16 00:25:34.036+00	2024-02-16 00:25:34.036+00	sy1HD51LXT	MQfxuw3ERg	4	0	2	4	1	\N	\N
QJy5jYmUFj	2024-02-16 00:25:34.446+00	2024-02-16 00:25:34.446+00	HtEtaHBVDN	UCFo58JaaD	1	3	1	3	0	\N	\N
8olBO1C73F	2024-02-16 00:25:34.651+00	2024-02-16 00:25:34.651+00	sHiqaG4iqY	m8hjjLVdPS	1	0	1	2	1	\N	\N
TUX66bmsR2	2024-02-16 00:25:34.857+00	2024-02-16 00:25:34.857+00	sy1HD51LXT	HLIPwAqO2R	0	4	2	2	0	\N	\N
obQjOtIF2X	2024-02-16 00:25:35.063+00	2024-02-16 00:25:35.063+00	dZKm0wOhYa	m6g8u0QpTC	0	2	0	4	1	\N	\N
KdL5glFPDz	2024-02-16 00:25:35.317+00	2024-02-16 00:25:35.317+00	Otwj7uJwjr	XpUyRlB6FI	3	3	0	3	4	\N	\N
oBAVhsFrPF	2024-02-16 00:25:35.519+00	2024-02-16 00:25:35.519+00	adE9nQrDk3	Pja6n3yaWZ	2	2	1	1	0	\N	\N
QcK9vgAbTM	2024-02-16 00:25:35.726+00	2024-02-16 00:25:35.726+00	WKpBp0c8F3	WnUBBkiDjE	3	4	4	1	4	\N	\N
EDZVoQaUxH	2024-02-16 00:25:35.931+00	2024-02-16 00:25:35.931+00	dEqAHvPMXA	WnUBBkiDjE	1	0	3	3	3	\N	\N
MkuAnTAV5G	2024-02-16 00:25:36.184+00	2024-02-16 00:25:36.184+00	mAKp5BK7R1	RkhjIQJgou	2	3	4	4	1	\N	\N
j0lGoQ9HAA	2024-02-16 00:25:36.389+00	2024-02-16 00:25:36.389+00	iUlyHNFGpG	rKyjwoEIRp	1	0	0	2	2	\N	\N
ocE3C8XiHy	2024-02-16 00:25:36.595+00	2024-02-16 00:25:36.595+00	1as6rMOzjQ	9GF3y7LmHV	3	3	2	1	4	\N	\N
hDHzI8Atsx	2024-02-16 00:25:36.799+00	2024-02-16 00:25:36.799+00	ONgyydfVNz	UCFo58JaaD	4	1	1	4	4	\N	\N
9374kPbqTY	2024-02-16 00:25:37.008+00	2024-02-16 00:25:37.008+00	sHiqaG4iqY	WBFeKac0OO	2	0	1	0	4	\N	\N
iTIYbeIQqt	2024-02-16 00:25:37.215+00	2024-02-16 00:25:37.215+00	jqDYoPT45X	NY6RE1qgWu	1	2	2	2	2	\N	\N
mWfaEziJEs	2024-02-16 00:25:37.425+00	2024-02-16 00:25:37.425+00	WKpBp0c8F3	lEPdiO1EDi	3	4	2	1	1	\N	\N
uQcTYVKEvJ	2024-02-16 00:25:37.715+00	2024-02-16 00:25:37.715+00	mAKp5BK7R1	OQWu2bnHeC	0	0	1	0	4	\N	\N
0lz01AaifC	2024-02-16 00:25:37.927+00	2024-02-16 00:25:37.927+00	iUlyHNFGpG	TZsdmscJ2B	0	2	3	1	1	\N	\N
sksMY9sZJS	2024-02-16 00:25:38.142+00	2024-02-16 00:25:38.142+00	HRhGpJpmb5	6Fo67rhTSP	3	1	3	1	2	\N	\N
DLJ6sn8RCG	2024-02-16 00:25:38.44+00	2024-02-16 00:25:38.44+00	opW2wQ2bZ8	TZsdmscJ2B	4	3	0	3	4	\N	\N
mbuz3QdpmV	2024-02-16 00:25:38.748+00	2024-02-16 00:25:38.748+00	sy1HD51LXT	LgJuu5ABe5	4	2	0	0	2	\N	\N
QL7fPzlBwE	2024-02-16 00:25:39.054+00	2024-02-16 00:25:39.054+00	S6wz0lK0bf	mMYg4cyd5R	0	2	1	2	4	\N	\N
P27lDRASBJ	2024-02-16 00:25:39.464+00	2024-02-16 00:25:39.464+00	1as6rMOzjQ	LgJuu5ABe5	3	1	1	0	4	\N	\N
WSCD4vDhCe	2024-02-16 00:25:39.771+00	2024-02-16 00:25:39.771+00	jqDYoPT45X	vwHi602n66	0	4	2	4	3	\N	\N
FFjNkagVyi	2024-02-16 00:25:40.18+00	2024-02-16 00:25:40.18+00	jqDYoPT45X	JLhF4VuByh	0	2	4	2	2	\N	\N
tdKscLTNH7	2024-02-16 00:25:40.689+00	2024-02-16 00:25:40.689+00	I5RzFRcQ7G	9GF3y7LmHV	3	3	2	4	4	\N	\N
GY8Do6lSrl	2024-02-16 00:25:41.103+00	2024-02-16 00:25:41.103+00	HtEtaHBVDN	LgJuu5ABe5	0	2	1	3	1	\N	\N
ld1eVXuPZB	2024-02-16 00:25:41.306+00	2024-02-16 00:25:41.306+00	AsrLUQwxI9	TZsdmscJ2B	0	0	2	1	2	\N	\N
kyzlc8T2Ob	2024-02-16 00:25:41.512+00	2024-02-16 00:25:41.512+00	R2CLtFh5jU	rT0UCBK1bE	4	1	3	2	3	\N	\N
OIGWib5vBK	2024-02-16 00:25:41.819+00	2024-02-16 00:25:41.819+00	adE9nQrDk3	AgU9OLJkqz	0	1	0	4	4	\N	\N
teePbyQ3Kw	2024-02-16 00:25:42.126+00	2024-02-16 00:25:42.126+00	SFAISec8QF	WnUBBkiDjE	0	3	1	3	3	\N	\N
3wJRznz0aG	2024-02-16 00:25:42.333+00	2024-02-16 00:25:42.333+00	mAKp5BK7R1	08liHW08uC	0	4	3	1	0	\N	\N
dM6EYey9Zu	2024-02-16 00:25:42.535+00	2024-02-16 00:25:42.535+00	NjxsGlPeB4	m6g8u0QpTC	4	4	3	4	4	\N	\N
6EN2DVhn5E	2024-02-16 00:25:42.748+00	2024-02-16 00:25:42.748+00	R2CLtFh5jU	cwVEh0dqfm	3	4	3	2	1	\N	\N
uqiY12hlGx	2024-02-16 00:25:43.048+00	2024-02-16 00:25:43.048+00	5X202ssb0D	m8hjjLVdPS	0	4	1	3	1	\N	\N
X7UlaTBmit	2024-02-16 00:25:43.254+00	2024-02-16 00:25:43.254+00	jqDYoPT45X	rT0UCBK1bE	1	4	3	4	0	\N	\N
bNj8H1zvUp	2024-02-16 00:25:43.463+00	2024-02-16 00:25:43.463+00	ONgyydfVNz	jjVdtithcD	0	1	2	2	1	\N	\N
ANdHhYLpcF	2024-02-16 00:25:44.072+00	2024-02-16 00:25:44.072+00	mQXQWNqxg9	AgU9OLJkqz	1	3	3	2	4	\N	\N
mY2C2leN3R	2024-02-16 00:25:44.276+00	2024-02-16 00:25:44.276+00	iWxl9obi8w	yvUod6yLDt	4	1	0	4	3	\N	\N
4MRtZJAvvF	2024-02-16 00:25:44.482+00	2024-02-16 00:25:44.482+00	opW2wQ2bZ8	l1Bslv8T2k	0	0	0	3	3	\N	\N
CcR2C1kyMg	2024-02-16 00:25:44.789+00	2024-02-16 00:25:44.789+00	iUlyHNFGpG	m8hjjLVdPS	0	3	0	3	2	\N	\N
DO3jGkwg9U	2024-02-16 00:25:44.995+00	2024-02-16 00:25:44.995+00	SFAISec8QF	INeptnSdJC	2	3	0	1	3	\N	\N
MklgRVROGX	2024-02-16 00:25:45.198+00	2024-02-16 00:25:45.198+00	Otwj7uJwjr	D0A6GLdsDM	3	0	2	0	1	\N	\N
A7tGoFyNE5	2024-02-16 00:25:45.405+00	2024-02-16 00:25:45.405+00	AsrLUQwxI9	fxvABtKCPT	3	1	2	3	1	\N	\N
WF9pdI0ivI	2024-02-16 00:25:45.612+00	2024-02-16 00:25:45.612+00	adE9nQrDk3	MQfxuw3ERg	4	4	2	2	4	\N	\N
UIieiYKZ2M	2024-02-16 00:25:45.916+00	2024-02-16 00:25:45.916+00	dEqAHvPMXA	0TvWuLoLF5	2	4	3	0	4	\N	\N
RKZIBMP2Oc	2024-02-16 00:25:46.116+00	2024-02-16 00:25:46.116+00	RWwLSzreG2	RkhjIQJgou	3	4	0	2	4	\N	\N
JIKokiadQY	2024-02-16 00:25:46.323+00	2024-02-16 00:25:46.323+00	iUlyHNFGpG	LDrIH1vU8x	4	2	4	4	2	\N	\N
fNX56DtbQE	2024-02-16 00:25:46.528+00	2024-02-16 00:25:46.528+00	mQXQWNqxg9	rT0UCBK1bE	2	0	3	2	3	\N	\N
CoB9ExkfPf	2024-02-16 00:25:47.144+00	2024-02-16 00:25:47.144+00	sy1HD51LXT	D0A6GLdsDM	1	4	3	1	4	\N	\N
7GAeF9yh7q	2024-02-16 00:25:47.349+00	2024-02-16 00:25:47.349+00	NjxsGlPeB4	3P6kmNoY1F	0	1	2	4	1	\N	\N
8PwHhACMvS	2024-02-16 00:25:47.554+00	2024-02-16 00:25:47.554+00	iUlyHNFGpG	WnUBBkiDjE	3	3	3	1	3	\N	\N
o8ScZqgQUl	2024-02-16 00:25:47.759+00	2024-02-16 00:25:47.759+00	opW2wQ2bZ8	14jGmOAXcg	3	1	2	3	1	\N	\N
LXDn9lEQjq	2024-02-16 00:25:48.043+00	2024-02-16 00:25:48.043+00	sy1HD51LXT	lEPdiO1EDi	1	3	3	2	3	\N	\N
QW1XkXH1o0	2024-02-16 00:25:48.248+00	2024-02-16 00:25:48.248+00	ONgyydfVNz	6Fo67rhTSP	4	1	4	3	4	\N	\N
rwAkym3zmg	2024-02-16 00:25:48.885+00	2024-02-16 00:25:48.885+00	RWwLSzreG2	LgJuu5ABe5	4	3	4	0	1	\N	\N
gEm29NHQ8a	2024-02-16 00:25:49.09+00	2024-02-16 00:25:49.09+00	SFAISec8QF	l1Bslv8T2k	4	2	4	2	4	\N	\N
2SPhfHg816	2024-02-16 00:25:49.398+00	2024-02-16 00:25:49.398+00	1as6rMOzjQ	na5crB8ED1	0	3	2	2	4	\N	\N
jjafKF4p5v	2024-02-16 00:25:49.603+00	2024-02-16 00:25:49.603+00	VshUk7eBeK	6Fo67rhTSP	4	2	0	3	4	\N	\N
Jnmi4GRhEo	2024-02-16 00:25:49.807+00	2024-02-16 00:25:49.807+00	sy1HD51LXT	Gl96vGdYHM	1	4	4	1	2	\N	\N
ndUWHSg9qH	2024-02-16 00:25:50.114+00	2024-02-16 00:25:50.114+00	1as6rMOzjQ	CSvk1ycWXk	1	1	2	1	3	\N	\N
FZsyxKHoAl	2024-02-16 00:25:50.321+00	2024-02-16 00:25:50.321+00	5nv19u6KJ2	oABNR2FF6S	4	2	3	4	3	\N	\N
PbO5lgTvDE	2024-02-16 00:25:50.528+00	2024-02-16 00:25:50.528+00	opW2wQ2bZ8	XSK814B37m	1	0	1	0	3	\N	\N
MHykK8CWbl	2024-02-16 00:25:51.134+00	2024-02-16 00:25:51.134+00	5nv19u6KJ2	EmIUBFwx0Z	2	2	0	1	3	\N	\N
gZIXzMcDoE	2024-02-16 00:25:51.446+00	2024-02-16 00:25:51.446+00	sy1HD51LXT	9GF3y7LmHV	3	3	2	0	4	\N	\N
CUsFjWWEtw	2024-02-16 00:25:52.061+00	2024-02-16 00:25:52.061+00	adE9nQrDk3	JLhF4VuByh	2	3	4	1	4	\N	\N
6KrFthBCxN	2024-02-16 00:25:52.676+00	2024-02-16 00:25:52.676+00	1as6rMOzjQ	tCIEnLLcUc	4	2	1	4	3	\N	\N
ekPgOf05pc	2024-02-16 00:25:52.887+00	2024-02-16 00:25:52.887+00	5nv19u6KJ2	ThMuD3hYRQ	4	0	4	3	2	\N	\N
BXhSXBIHLv	2024-02-16 00:25:53.186+00	2024-02-16 00:25:53.186+00	HtEtaHBVDN	y4RkaDbkec	3	4	2	1	0	\N	\N
OQA3nLQAr2	2024-02-16 00:25:53.394+00	2024-02-16 00:25:53.394+00	mQXQWNqxg9	cFtamPA0zH	1	4	3	3	3	\N	\N
NhcJXH4L2G	2024-02-16 00:25:53.601+00	2024-02-16 00:25:53.601+00	HRhGpJpmb5	JZOBDAh12a	1	1	3	1	3	\N	\N
dn9jnjktze	2024-02-16 00:25:53.807+00	2024-02-16 00:25:53.807+00	HtEtaHBVDN	bQpy9LEJWn	2	0	0	3	3	\N	\N
GLiBTUcn1u	2024-02-16 00:25:54.013+00	2024-02-16 00:25:54.013+00	NjxsGlPeB4	89xRG1afNi	4	4	0	1	3	\N	\N
MCCTPHv4tV	2024-02-16 00:25:54.219+00	2024-02-16 00:25:54.219+00	opW2wQ2bZ8	bi1IivsuUB	3	4	4	2	1	\N	\N
bLrsmEiRGo	2024-02-16 00:25:54.828+00	2024-02-16 00:25:54.828+00	HtEtaHBVDN	WBFeKac0OO	2	0	4	0	1	\N	\N
onLzjCk9aD	2024-02-16 00:25:55.132+00	2024-02-16 00:25:55.132+00	dZKm0wOhYa	WHvlAGgj6c	0	0	3	4	0	\N	\N
vqI3jeGeSq	2024-02-16 00:25:55.441+00	2024-02-16 00:25:55.441+00	WKpBp0c8F3	NBojpORh3G	4	4	2	3	4	\N	\N
g9QE7agaL3	2024-02-16 00:25:55.65+00	2024-02-16 00:25:55.65+00	Otwj7uJwjr	KCsJ4XR6Dn	0	1	2	2	3	\N	\N
EnpgsEckSG	2024-02-16 00:25:55.951+00	2024-02-16 00:25:55.951+00	AsrLUQwxI9	HXtEwLBC7f	2	4	2	0	2	\N	\N
Dja5urq1HX	2024-02-16 00:25:56.151+00	2024-02-16 00:25:56.151+00	Otwj7uJwjr	tCIEnLLcUc	4	4	3	1	1	\N	\N
rbOyeTzrJ4	2024-02-16 00:25:56.353+00	2024-02-16 00:25:56.353+00	5X202ssb0D	mMYg4cyd5R	1	2	3	1	3	\N	\N
M1Zr5WjHaV	2024-02-16 00:25:56.668+00	2024-02-16 00:25:56.668+00	Otwj7uJwjr	u5FXeeOChJ	1	1	2	4	4	\N	\N
bGsSRAvcDF	2024-02-16 00:25:56.871+00	2024-02-16 00:25:56.871+00	mAKp5BK7R1	XpUyRlB6FI	1	1	2	4	2	\N	\N
u6WP4B8CqL	2024-02-16 00:25:57.179+00	2024-02-16 00:25:57.179+00	jqDYoPT45X	XwszrNEEEj	2	3	2	3	0	\N	\N
y1kdOR92Tw	2024-02-16 00:25:57.382+00	2024-02-16 00:25:57.382+00	I5RzFRcQ7G	UDXF0qXvDY	0	0	2	4	4	\N	\N
QVugIknwu0	2024-02-16 00:25:57.587+00	2024-02-16 00:25:57.587+00	5X202ssb0D	Oahm9sOn1y	0	1	4	0	0	\N	\N
SqqxWuf9LX	2024-02-16 00:25:57.788+00	2024-02-16 00:25:57.788+00	SFAISec8QF	m8hjjLVdPS	1	3	4	0	3	\N	\N
KrtRTZWY1F	2024-02-16 00:25:57.999+00	2024-02-16 00:25:57.999+00	HtEtaHBVDN	vwHi602n66	2	3	0	2	3	\N	\N
imwKDRLOiy	2024-02-16 00:25:58.206+00	2024-02-16 00:25:58.206+00	iUlyHNFGpG	CSvk1ycWXk	0	3	1	3	3	\N	\N
J492yehrcn	2024-02-16 00:25:58.412+00	2024-02-16 00:25:58.412+00	iWxl9obi8w	ThMuD3hYRQ	0	1	2	0	1	\N	\N
Bse3xfTaSv	2024-02-16 00:25:58.716+00	2024-02-16 00:25:58.716+00	HRhGpJpmb5	UDXF0qXvDY	2	0	3	1	1	\N	\N
NwKvXEaOsN	2024-02-16 00:25:58.919+00	2024-02-16 00:25:58.919+00	WKpBp0c8F3	MQfxuw3ERg	2	0	4	3	1	\N	\N
NRagHPhey7	2024-02-16 00:25:59.125+00	2024-02-16 00:25:59.125+00	Otwj7uJwjr	WBFeKac0OO	4	2	3	3	0	\N	\N
HYfwb5Hjve	2024-02-16 00:25:59.332+00	2024-02-16 00:25:59.332+00	ONgyydfVNz	VK3vnSxIy8	1	0	4	4	3	\N	\N
18NQ7UD50j	2024-02-16 00:25:59.542+00	2024-02-16 00:25:59.542+00	5X202ssb0D	6Fo67rhTSP	0	3	3	1	3	\N	\N
hMHBA4n2Ej	2024-02-16 00:25:59.746+00	2024-02-16 00:25:59.746+00	WKpBp0c8F3	RkhjIQJgou	2	4	4	3	3	\N	\N
fXMdJMWDRq	2024-02-16 00:26:00.354+00	2024-02-16 00:26:00.354+00	sHiqaG4iqY	XwWwGnkXNj	1	3	2	3	4	\N	\N
iMqrKHrM2f	2024-02-16 00:26:00.557+00	2024-02-16 00:26:00.557+00	RWwLSzreG2	Oahm9sOn1y	1	4	1	1	1	\N	\N
qaXTaSxPhO	2024-02-16 00:26:00.764+00	2024-02-16 00:26:00.764+00	sHiqaG4iqY	axyV0Fu7pm	2	4	0	1	3	\N	\N
MXTGpr17nF	2024-02-16 00:26:01.378+00	2024-02-16 00:26:01.378+00	I5RzFRcQ7G	m8hjjLVdPS	1	4	4	0	2	\N	\N
rbvnRfAge1	2024-02-16 00:26:01.682+00	2024-02-16 00:26:01.682+00	I5RzFRcQ7G	WSTLlXDcKl	3	1	0	0	2	\N	\N
vSSBFPjxR8	2024-02-16 00:26:01.883+00	2024-02-16 00:26:01.883+00	HRhGpJpmb5	89xRG1afNi	0	0	1	3	0	\N	\N
iIqsm3lexD	2024-02-16 00:26:02.197+00	2024-02-16 00:26:02.197+00	5X202ssb0D	yvUod6yLDt	3	3	2	0	2	\N	\N
NEFJC3OMXo	2024-02-16 00:26:02.4+00	2024-02-16 00:26:02.4+00	5nv19u6KJ2	E2hBZzDsjO	3	0	4	3	1	\N	\N
AsgBxJoA8B	2024-02-16 00:26:02.607+00	2024-02-16 00:26:02.607+00	1as6rMOzjQ	BMLzFMvIT6	1	2	4	0	4	\N	\N
K26ExizU4T	2024-02-16 00:26:02.812+00	2024-02-16 00:26:02.812+00	S6wz0lK0bf	89xRG1afNi	2	2	3	4	0	\N	\N
cAUppHPovI	2024-02-16 00:26:03.017+00	2024-02-16 00:26:03.017+00	RWwLSzreG2	LDrIH1vU8x	1	4	4	0	1	\N	\N
vAfzPq3mYT	2024-02-16 00:26:03.221+00	2024-02-16 00:26:03.221+00	RWwLSzreG2	UCFo58JaaD	2	1	4	2	0	\N	\N
UjYGtihfxE	2024-02-16 00:26:03.529+00	2024-02-16 00:26:03.529+00	9223vtvaBd	P9sBFomftT	3	0	1	0	1	\N	\N
DlnZeP9qT8	2024-02-16 00:26:03.734+00	2024-02-16 00:26:03.734+00	ONgyydfVNz	9GF3y7LmHV	3	2	0	4	2	\N	\N
bfFQOUphZq	2024-02-16 00:26:03.939+00	2024-02-16 00:26:03.939+00	RWwLSzreG2	NBojpORh3G	4	3	3	4	3	\N	\N
KO6qrU2jrU	2024-02-16 00:26:04.142+00	2024-02-16 00:26:04.142+00	adE9nQrDk3	mMYg4cyd5R	0	1	3	3	4	\N	\N
ykBRlfdwWj	2024-02-16 00:26:04.348+00	2024-02-16 00:26:04.348+00	RWwLSzreG2	lEPdiO1EDi	3	3	0	1	4	\N	\N
JauGlvU6jn	2024-02-16 00:26:04.558+00	2024-02-16 00:26:04.558+00	VshUk7eBeK	AgU9OLJkqz	0	4	3	0	2	\N	\N
yA6FBum6Oj	2024-02-16 00:26:04.766+00	2024-02-16 00:26:04.766+00	opW2wQ2bZ8	XwWwGnkXNj	1	4	3	1	4	\N	\N
MquXXDKvxn	2024-02-16 00:26:04.971+00	2024-02-16 00:26:04.971+00	NjxsGlPeB4	3P6kmNoY1F	1	1	3	3	4	\N	\N
c8g7aote6X	2024-02-16 00:26:05.179+00	2024-02-16 00:26:05.179+00	dEqAHvPMXA	D0A6GLdsDM	2	3	1	0	2	\N	\N
416kxp1gCM	2024-02-16 00:26:05.384+00	2024-02-16 00:26:05.384+00	Otwj7uJwjr	yvUod6yLDt	2	3	2	3	0	\N	\N
lKyYKKyTeG	2024-02-16 00:26:05.584+00	2024-02-16 00:26:05.584+00	5X202ssb0D	HLIPwAqO2R	4	1	0	3	1	\N	\N
8zG4gnV5kX	2024-02-16 00:26:05.792+00	2024-02-16 00:26:05.792+00	1as6rMOzjQ	M0tHrt1GgV	4	4	3	4	0	\N	\N
eKd85hqVYE	2024-02-16 00:26:06.004+00	2024-02-16 00:26:06.004+00	jqDYoPT45X	oABNR2FF6S	1	2	4	1	1	\N	\N
JHGpakmDGI	2024-02-16 00:26:06.205+00	2024-02-16 00:26:06.205+00	adE9nQrDk3	TCkiw6gTDz	2	1	3	4	4	\N	\N
VABlNCXeDV	2024-02-16 00:26:06.411+00	2024-02-16 00:26:06.411+00	5X202ssb0D	WHvlAGgj6c	2	0	0	3	2	\N	\N
ENYS1tiSE0	2024-02-16 00:26:06.616+00	2024-02-16 00:26:06.616+00	mAKp5BK7R1	3u4B9V4l5K	4	4	3	2	4	\N	\N
tXhHiPaaHu	2024-02-16 00:26:06.822+00	2024-02-16 00:26:06.822+00	HRhGpJpmb5	FYXEfIO1zF	1	3	4	4	4	\N	\N
4K2UHl8sSC	2024-02-16 00:26:07.159+00	2024-02-16 00:26:07.159+00	NjxsGlPeB4	89xRG1afNi	0	3	3	2	2	\N	\N
T6ksMWH2GQ	2024-02-16 00:26:07.362+00	2024-02-16 00:26:07.362+00	mQXQWNqxg9	8w7i8C3NnT	0	4	3	2	1	\N	\N
IUHBVcVDzu	2024-02-16 00:26:07.566+00	2024-02-16 00:26:07.566+00	R2CLtFh5jU	yvUod6yLDt	1	4	1	4	4	\N	\N
Do4nHtbiXe	2024-02-16 00:26:07.771+00	2024-02-16 00:26:07.771+00	5nv19u6KJ2	qEQ9tmLyW9	1	2	0	4	2	\N	\N
2R3MSrF9Hb	2024-02-16 00:26:08.444+00	2024-02-16 00:26:08.444+00	NjxsGlPeB4	l1Bslv8T2k	4	4	1	4	2	\N	\N
vpaFuzJgNq	2024-02-16 00:26:08.648+00	2024-02-16 00:26:08.648+00	1as6rMOzjQ	3u4B9V4l5K	3	1	2	1	2	\N	\N
bETrYJ8UXT	2024-02-16 00:26:08.852+00	2024-02-16 00:26:08.852+00	dEqAHvPMXA	HXtEwLBC7f	1	0	2	2	0	\N	\N
TUl7T1YEhI	2024-02-16 00:26:09.161+00	2024-02-16 00:26:09.161+00	HRhGpJpmb5	8w7i8C3NnT	1	2	0	2	3	\N	\N
pkpPO88ikF	2024-02-16 00:26:09.366+00	2024-02-16 00:26:09.366+00	sHiqaG4iqY	KCsJ4XR6Dn	0	0	2	3	0	\N	\N
GjFzslNTNU	2024-02-16 00:26:09.577+00	2024-02-16 00:26:09.577+00	5X202ssb0D	tCIEnLLcUc	4	1	4	1	4	\N	\N
QszPeROjfL	2024-02-16 00:26:09.783+00	2024-02-16 00:26:09.783+00	R2CLtFh5jU	8w7i8C3NnT	3	3	4	4	3	\N	\N
MbTOFlbpjY	2024-02-16 00:26:09.991+00	2024-02-16 00:26:09.991+00	5nv19u6KJ2	HSEugQ3Ouj	4	2	0	2	0	\N	\N
FGxOuAcAGc	2024-02-16 00:26:10.288+00	2024-02-16 00:26:10.288+00	ONgyydfVNz	TpGyMZM9BG	0	0	2	3	0	\N	\N
VMaOAnCKV9	2024-02-16 00:26:10.491+00	2024-02-16 00:26:10.491+00	adE9nQrDk3	CSvk1ycWXk	2	2	0	1	4	\N	\N
\.


--
-- Data for Name: _Audience; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_Audience" ("objectId", "createdAt", "updatedAt", name, query, "lastUsed", "timesUsed", _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _GlobalConfig; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_GlobalConfig" ("objectId", params, "masterKeyOnly") FROM stdin;
\.


--
-- Data for Name: _GraphQLConfig; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_GraphQLConfig" ("objectId", config) FROM stdin;
\.


--
-- Data for Name: _Hooks; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_Hooks" ("functionName", "className", "triggerName", url) FROM stdin;
\.


--
-- Data for Name: _Idempotency; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_Idempotency" ("objectId", "createdAt", "updatedAt", "reqId", expire, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _JobSchedule; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_JobSchedule" ("objectId", "createdAt", "updatedAt", "jobName", description, params, "startAfter", "daysOfWeek", "timeOfDay", "lastRun", "repeatMinutes", _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _JobStatus; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_JobStatus" ("objectId", "createdAt", "updatedAt", "jobName", source, status, message, params, "finishedAt", _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _Join:roles:_Role; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_Join:roles:_Role" ("relatedId", "owningId") FROM stdin;
\.


--
-- Data for Name: _Join:users:_Role; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_Join:users:_Role" ("relatedId", "owningId") FROM stdin;
\.


--
-- Data for Name: _PushStatus; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_PushStatus" ("objectId", "createdAt", "updatedAt", "pushTime", source, query, payload, title, expiry, expiration_interval, status, "numSent", "numFailed", "pushHash", "errorMessage", "sentPerType", "failedPerType", "sentPerUTCOffset", "failedPerUTCOffset", count, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _Role; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_Role" ("objectId", "createdAt", "updatedAt", name, _rperm, _wperm) FROM stdin;
\.


--
-- Data for Name: _SCHEMA; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_SCHEMA" ("className", schema, "isParseClass") FROM stdin;
Score	{"fields": {"_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "user_id": {"type": "Pointer", "targetClass": "_User"}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "restaurant_id": {"type": "Pointer", "targetClass": "Restaurant"}, "food_quality_score": {"type": "Number"}, "side_services_score": {"type": "Number"}, "taste_of_food_score": {"type": "Number"}, "employee_behave_score": {"type": "Number"}, "restaurant_cleanliness_score": {"type": "Number"}}, "indexes": {"_id_": {"_id": 1}}, "className": "Score", "classLevelPermissions": {"get": {"requiresAuthentication": true}, "find": {"requiresAuthentication": true}, "count": {"requiresAuthentication": true}, "create": {"requiresAuthentication": true}, "delete": {"requiresAuthentication": true}, "update": {"requiresAuthentication": true}, "addField": {}}}	t
_Role	{"fields": {"name": {"type": "String"}, "roles": {"type": "Relation", "targetClass": "_Role"}, "users": {"type": "Relation", "targetClass": "_User"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "indexes": {"_id_": {"_id": 1}}, "className": "_Role", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "count": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {}, "protectedFields": {"*": []}}}	t
_Session	{"fields": {"user": {"type": "Pointer", "targetClass": "_User"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "expiresAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "createdWith": {"type": "Object"}, "sessionToken": {"type": "String"}, "installationId": {"type": "String"}}, "indexes": {"_id_": {"_id": 1}}, "className": "_Session", "classLevelPermissions": {"get": {"*": true}, "find": {"*": true}, "count": {"*": true}, "create": {"*": true}, "delete": {"*": true}, "update": {"*": true}, "addField": {}, "protectedFields": {"*": []}}}	t
Food	{"fields": {"name": {"type": "String"}, "photo": {"type": "File"}, "price": {"type": "Number"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "type_of_food": {"type": "String"}, "restaurant_id": {"type": "Pointer", "targetClass": "Restaurant"}}, "indexes": {"_id_": {"_id": 1}}, "className": "Food", "classLevelPermissions": {"get": {"requiresAuthentication": true}, "find": {"requiresAuthentication": true}, "count": {"requiresAuthentication": true}, "create": {"requiresAuthentication": true}, "delete": {"requiresAuthentication": true}, "update": {"requiresAuthentication": true}, "addField": {}}}	t
Category	{"fields": {"name": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}, "description": {"type": "String"}}, "indexes": {"_id_": {"_id": 1}}, "className": "Category", "classLevelPermissions": {"get": {"requiresAuthentication": true}, "find": {"requiresAuthentication": true}, "count": {"requiresAuthentication": true}, "create": {"requiresAuthentication": true}, "delete": {"requiresAuthentication": true}, "update": {"requiresAuthentication": true}, "addField": {}}}	t
_User	{"fields": {"name": {"type": "String"}, "email": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "authData": {"type": "Object"}, "is_admin": {"type": "Boolean"}, "lastname": {"type": "String", "required": true}, "objectId": {"type": "String"}, "username": {"type": "String"}, "createdAt": {"type": "Date"}, "firstname": {"type": "String", "required": true}, "updatedAt": {"type": "Date"}, "emailVerified": {"type": "Boolean"}, "_hashed_password": {"type": "String"}, "is_restaurant_owner": {"type": "Boolean"}}, "indexes": {"_id_": {"_id": 1}}, "className": "_User", "classLevelPermissions": {"get": {"requiresAuthentication": true}, "find": {"requiresAuthentication": true}, "count": {"requiresAuthentication": true}, "create": {"requiresAuthentication": true}, "delete": {"requiresAuthentication": true}, "update": {"requiresAuthentication": true}, "addField": {}}}	t
image	{"fields": {"name": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "objectId": {"type": "String"}, "createdAt": {"type": "Date"}, "updatedAt": {"type": "Date"}}, "className": "image"}	t
Restaurant	{"fields": {"url": {"type": "String"}, "web": {"type": "String"}, "city": {"type": "String"}, "file": {"type": "Object"}, "name": {"type": "String"}, "email": {"type": "String"}, "image": {"type": "String"}, "phone": {"type": "String"}, "title": {"type": "String"}, "_rperm": {"type": "Array", "contents": {"type": "String"}}, "_wperm": {"type": "Array", "contents": {"type": "String"}}, "avenue": {"type": "String"}, "street": {"type": "String"}, "deliver": {"type": "Boolean"}, "serving": {"type": "Boolean"}, "district": {"type": "String"}, "facebook": {"type": "String"}, "latitude": {"type": "Number"}, "objectId": {"type": "String"}, "takeaway": {"type": "Boolean"}, "whatsapp": {"type": "String"}, "createdAt": {"type": "Date"}, "instagram": {"type": "String"}, "longitude": {"type": "Number"}, "updatedAt": {"type": "Date"}, "views_rate": {"type": "Number"}, "category_id": {"type": "Pointer", "targetClass": "Category"}, "is_verified": {"type": "Boolean"}, "postal_code": {"type": "String"}, "closing_time": {"type": "String"}, "opening_time": {"type": "String"}, "working_days": {"type": "String"}, "restaurant_id": {"type": "Pointer", "targetClass": "Category"}}, "indexes": {"_id_": {"_id": 1}}, "className": "Restaurant", "classLevelPermissions": {"get": {"requiresAuthentication": true}, "find": {"requiresAuthentication": true}, "count": {"requiresAuthentication": true}, "create": {"requiresAuthentication": true}, "delete": {"requiresAuthentication": true}, "update": {"requiresAuthentication": true}, "addField": {}}}	t
\.


--
-- Data for Name: _Session; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_Session" ("objectId", "createdAt", "updatedAt", "user", "installationId", "sessionToken", "expiresAt", "createdWith", _rperm, _wperm) FROM stdin;
lhNGo6wz10	2024-02-15 23:37:12.706+00	2024-02-15 23:37:12.706+00	PZU8MGZBSu	\N	r:bd7f90310dd0d89345555b7fbdf6189f	2025-02-14 23:37:12.705+00	{"action": "signup", "authProvider": "password"}	\N	\N
akREC5pkED	2024-02-15 23:37:13.595+00	2024-02-15 23:37:13.595+00	tDqZkssIPn	\N	r:9a18348756ecbe60a9886c09bb0234fc	2025-02-14 23:37:13.595+00	{"action": "signup", "authProvider": "password"}	\N	\N
btBR48W8UD	2024-02-15 23:37:14.422+00	2024-02-15 23:37:14.422+00	D6RShAUuJh	\N	r:c0e8d74d70d61f1893da4e2421786911	2025-02-14 23:37:14.422+00	{"action": "signup", "authProvider": "password"}	\N	\N
paECkCAUli	2024-02-15 23:37:15.277+00	2024-02-15 23:37:15.277+00	WIBRYx5Fgz	\N	r:341c8e734fba3b4d3b58174cd85d32e9	2025-02-14 23:37:15.277+00	{"action": "signup", "authProvider": "password"}	\N	\N
FpkE9SMJFY	2024-02-15 23:37:16.133+00	2024-02-15 23:37:16.133+00	ayknKzJtEy	\N	r:62afb1850d3e3f71af4ad4fb5e5f0403	2025-02-14 23:37:16.132+00	{"action": "signup", "authProvider": "password"}	\N	\N
5HNSlqRDyu	2024-02-15 23:37:16.971+00	2024-02-15 23:37:16.971+00	Y84X9Ojgs1	\N	r:3243b5a2b5252842bbc9f05dde5c1173	2025-02-14 23:37:16.971+00	{"action": "signup", "authProvider": "password"}	\N	\N
4EewPeOTVK	2024-02-15 23:37:23.152+00	2024-02-15 23:37:23.152+00	FmRAQO7hmZ	\N	r:b00c4cd1daca42cda3bca00aa29a0c58	2025-02-14 23:37:23.152+00	{"action": "signup", "authProvider": "password"}	\N	\N
BgBo5qWUOn	2024-02-15 23:37:25.351+00	2024-02-15 23:37:25.351+00	WKW8jnYqhx	\N	r:86f0bf1e185dc8f76c9db203e887a911	2025-02-14 23:37:25.351+00	{"action": "signup", "authProvider": "password"}	\N	\N
o1OZzrEQPe	2024-02-15 23:37:26.291+00	2024-02-15 23:37:26.291+00	F4jIGBQK0X	\N	r:d53f73d30c75d8341e633c510cb31e1b	2025-02-14 23:37:26.29+00	{"action": "signup", "authProvider": "password"}	\N	\N
skwxFnqeqI	2024-02-15 23:37:27.161+00	2024-02-15 23:37:27.161+00	O7EGuR5DRA	\N	r:041e2209aac1cb6f385e39229aca8d42	2025-02-14 23:37:27.161+00	{"action": "signup", "authProvider": "password"}	\N	\N
ysPbEjPAJX	2024-02-15 23:37:27.991+00	2024-02-15 23:37:27.991+00	tPCZtNvgUy	\N	r:95579d79a3f1c27f77cb488c70352713	2025-02-14 23:37:27.991+00	{"action": "signup", "authProvider": "password"}	\N	\N
nrQ4AdHThL	2024-02-15 23:37:28.813+00	2024-02-15 23:37:28.813+00	5X202ssb0D	\N	r:515c3d62f51d2d226367b8fb8807d86b	2025-02-14 23:37:28.813+00	{"action": "signup", "authProvider": "password"}	\N	\N
lqH6ao3jUC	2024-02-15 23:37:29.655+00	2024-02-15 23:37:29.655+00	ONgyydfVNz	\N	r:17a0562f0b3005f24b8bb4ca625dd23a	2025-02-14 23:37:29.654+00	{"action": "signup", "authProvider": "password"}	\N	\N
TDKBhhvITZ	2024-02-15 23:37:30.471+00	2024-02-15 23:37:30.471+00	adE9nQrDk3	\N	r:d5c0a796a147c6c60f38d54bdc9fb232	2025-02-14 23:37:30.471+00	{"action": "signup", "authProvider": "password"}	\N	\N
DWsvrcVtEU	2024-02-15 23:37:31.275+00	2024-02-15 23:37:31.275+00	I5RzFRcQ7G	\N	r:4286f6bbc248878cac2bface9fd8ef58	2025-02-14 23:37:31.275+00	{"action": "signup", "authProvider": "password"}	\N	\N
tJHDBfdC01	2024-02-15 23:37:32.107+00	2024-02-15 23:37:32.107+00	sHiqaG4iqY	\N	r:59b599ab7eed1020aecb689c5e5acb98	2025-02-14 23:37:32.107+00	{"action": "signup", "authProvider": "password"}	\N	\N
qkFTSIA31o	2024-02-15 23:37:32.976+00	2024-02-15 23:37:32.976+00	sy1HD51LXT	\N	r:4f62a98a1ce7e7a24f442ebf712a7282	2025-02-14 23:37:32.976+00	{"action": "signup", "authProvider": "password"}	\N	\N
FLooCAFkqP	2024-02-15 23:37:33.865+00	2024-02-15 23:37:33.865+00	jqDYoPT45X	\N	r:64871bfcd4b2d007e1e3e43bca7ff603	2025-02-14 23:37:33.865+00	{"action": "signup", "authProvider": "password"}	\N	\N
3RPMGVBPqX	2024-02-15 23:37:34.727+00	2024-02-15 23:37:34.727+00	WKpBp0c8F3	\N	r:54210759d097904f2ed38636e3ad53be	2025-02-14 23:37:34.727+00	{"action": "signup", "authProvider": "password"}	\N	\N
qjSVXvOY7L	2024-02-15 23:37:35.606+00	2024-02-15 23:37:35.606+00	R2CLtFh5jU	\N	r:e82987093372066ad06aca69861d4fa9	2025-02-14 23:37:35.606+00	{"action": "signup", "authProvider": "password"}	\N	\N
X9lI1SAKJ0	2024-02-15 23:37:36.535+00	2024-02-15 23:37:36.535+00	RWwLSzreG2	\N	r:49fa323e077ebe9361a9759aa03d6061	2025-02-14 23:37:36.535+00	{"action": "signup", "authProvider": "password"}	\N	\N
Cvik1eE9mH	2024-02-15 23:37:37.356+00	2024-02-15 23:37:37.356+00	VshUk7eBeK	\N	r:e1ab5fe64e1448efd24bb5c4232c82a8	2025-02-14 23:37:37.356+00	{"action": "signup", "authProvider": "password"}	\N	\N
VpqCl76hO3	2024-02-15 23:37:38.272+00	2024-02-15 23:37:38.272+00	mAKp5BK7R1	\N	r:449af2a98e0e110cdf27bd4bdd60b4ba	2025-02-14 23:37:38.272+00	{"action": "signup", "authProvider": "password"}	\N	\N
6EGJxOMTwb	2024-02-15 23:37:39.137+00	2024-02-15 23:37:39.137+00	S6wz0lK0bf	\N	r:15708696cdae8d305f79c2d018c172a0	2025-02-14 23:37:39.137+00	{"action": "signup", "authProvider": "password"}	\N	\N
aqu1wAgVZF	2024-02-15 23:37:39.988+00	2024-02-15 23:37:39.988+00	SFAISec8QF	\N	r:f1729965140b1a064b7f6c01a46d4cff	2025-02-14 23:37:39.988+00	{"action": "signup", "authProvider": "password"}	\N	\N
922AQQ523K	2024-02-15 23:37:40.884+00	2024-02-15 23:37:40.884+00	iWxl9obi8w	\N	r:44b8cb7027972a52d4c8b71593f4a04f	2025-02-14 23:37:40.884+00	{"action": "signup", "authProvider": "password"}	\N	\N
VFv0XbYOUV	2024-02-15 23:37:41.932+00	2024-02-15 23:37:41.932+00	mQXQWNqxg9	\N	r:8954bb03c0618c270285be28c9aebdfe	2025-02-14 23:37:41.932+00	{"action": "signup", "authProvider": "password"}	\N	\N
HgCGIZuzft	2024-02-15 23:37:42.785+00	2024-02-15 23:37:42.785+00	iUlyHNFGpG	\N	r:cb1a6d64eab5a068e4a8e248c4db01be	2025-02-14 23:37:42.785+00	{"action": "signup", "authProvider": "password"}	\N	\N
KI8crhgnJq	2024-02-15 23:37:43.684+00	2024-02-15 23:37:43.684+00	AsrLUQwxI9	\N	r:870dd1de644d035cd1c8f7528a04f9b4	2025-02-14 23:37:43.684+00	{"action": "signup", "authProvider": "password"}	\N	\N
PFGAFEJGHq	2024-02-15 23:37:44.564+00	2024-02-15 23:37:44.564+00	HtEtaHBVDN	\N	r:4114852a1f2fd76b6946068b0d1fd260	2025-02-14 23:37:44.564+00	{"action": "signup", "authProvider": "password"}	\N	\N
Ypb5FQSVYF	2024-02-15 23:37:45.42+00	2024-02-15 23:37:45.42+00	opW2wQ2bZ8	\N	r:a900e5bacff67bd9c92617e535450775	2025-02-14 23:37:45.42+00	{"action": "signup", "authProvider": "password"}	\N	\N
MTbD8aAKhH	2024-02-15 23:37:46.44+00	2024-02-15 23:37:46.44+00	Otwj7uJwjr	\N	r:e47cb6cc15b168974c0fc90631e09e72	2025-02-14 23:37:46.439+00	{"action": "signup", "authProvider": "password"}	\N	\N
ojTeOJYiD3	2024-02-15 23:37:47.359+00	2024-02-15 23:37:47.359+00	9223vtvaBd	\N	r:a617be2cdd51f2b2a8933efcf9f11c81	2025-02-14 23:37:47.359+00	{"action": "signup", "authProvider": "password"}	\N	\N
HgBp9LGIWS	2024-02-15 23:37:48.25+00	2024-02-15 23:37:48.25+00	dEqAHvPMXA	\N	r:cefbc42998c760e6c575bc8eed94e45e	2025-02-14 23:37:48.25+00	{"action": "signup", "authProvider": "password"}	\N	\N
kb6XCOGSxL	2024-02-15 23:37:49.166+00	2024-02-15 23:37:49.166+00	NjxsGlPeB4	\N	r:d9388fc23b19e35cc4bb459de4daea3b	2025-02-14 23:37:49.165+00	{"action": "signup", "authProvider": "password"}	\N	\N
CsPSI9N0nk	2024-02-15 23:37:50.093+00	2024-02-15 23:37:50.093+00	1as6rMOzjQ	\N	r:1838f90def65c6a568c3027a658a6caa	2025-02-14 23:37:50.092+00	{"action": "signup", "authProvider": "password"}	\N	\N
TnX8whtMt4	2024-02-15 23:37:51.046+00	2024-02-15 23:37:51.046+00	dZKm0wOhYa	\N	r:53ba55ad758a9244601cb08501758d32	2025-02-14 23:37:51.045+00	{"action": "signup", "authProvider": "password"}	\N	\N
DsE2WBVDqo	2024-02-15 23:37:51.967+00	2024-02-15 23:37:51.967+00	5nv19u6KJ2	\N	r:379e3afdecb4340400295b9ad3b83c23	2025-02-14 23:37:51.967+00	{"action": "signup", "authProvider": "password"}	\N	\N
zexlPIt9MB	2024-02-15 23:37:52.889+00	2024-02-15 23:37:52.889+00	HRhGpJpmb5	\N	r:f20096b6eb7d4035a0444451eef8126b	2025-02-14 23:37:52.889+00	{"action": "signup", "authProvider": "password"}	\N	\N
wgNr9UwhSI	2024-02-15 23:40:37.819+00	2024-02-15 23:40:37.819+00	NjxsGlPeB4	\N	r:163ea9dd16fac7ef8e67c568502fedfc	2025-02-14 23:40:37.818+00	{"action": "login", "authProvider": "password"}	\N	\N
1pDalJnHxX	2024-02-15 23:42:44.886+00	2024-02-15 23:42:44.886+00	7v2vwTHakK	\N	r:287c3b19a1e50e09f4121939640445c5	2025-02-14 23:42:44.886+00	{"action": "signup", "authProvider": "password"}	\N	\N
DBn4PQork2	2024-02-15 23:42:45.728+00	2024-02-15 23:42:45.728+00	98Wgt5CctX	\N	r:d7b0d19e416cd8e9b376fb199a2e1b27	2025-02-14 23:42:45.728+00	{"action": "signup", "authProvider": "password"}	\N	\N
jRfFd9oFpo	2024-02-15 23:42:46.675+00	2024-02-15 23:42:46.675+00	YhBomCrUsI	\N	r:4653606191b45950aca0213c77618d55	2025-02-14 23:42:46.675+00	{"action": "signup", "authProvider": "password"}	\N	\N
HJge8ROk1a	2024-02-15 23:42:47.586+00	2024-02-15 23:42:47.586+00	SJDyAlmDEV	\N	r:f3d0ec1f2707c3ded19d7b5c305891ff	2025-02-14 23:42:47.586+00	{"action": "signup", "authProvider": "password"}	\N	\N
wvXo12db9r	2024-02-15 23:42:48.526+00	2024-02-15 23:42:48.526+00	6qCK91vmgu	\N	r:7c373c3525ae066fa56e06c7e4d59855	2025-02-14 23:42:48.526+00	{"action": "signup", "authProvider": "password"}	\N	\N
yL8An4TMCE	2024-02-15 23:42:49.383+00	2024-02-15 23:42:49.383+00	Swryto7jHS	\N	r:013c032196f63ae88c5becab62d58ad7	2025-02-14 23:42:49.383+00	{"action": "signup", "authProvider": "password"}	\N	\N
iAQJdfLQEz	2024-02-15 23:42:55.863+00	2024-02-15 23:42:55.863+00	7v2vwTHakK	\N	r:79bba26eccdc9cc993887726d197607f	2025-02-14 23:42:55.863+00	{"action": "login", "authProvider": "password"}	\N	\N
fLRtSjNYUB	2024-02-15 23:44:22.493+00	2024-02-15 23:44:22.493+00	2JtaZklpt6	\N	r:7164a9a54f08e369ce695c107c751616	2025-02-14 23:44:22.493+00	{"action": "signup", "authProvider": "password"}	\N	\N
SOaoW7S3y3	2024-02-15 23:44:23.435+00	2024-02-15 23:44:23.435+00	UzIZhuMWEG	\N	r:da8f2feeda0f659833a690fcd13d0c0b	2025-02-14 23:44:23.435+00	{"action": "signup", "authProvider": "password"}	\N	\N
m8vURkBPWO	2024-02-15 23:44:24.323+00	2024-02-15 23:44:24.323+00	SEGg5uMQqx	\N	r:55b4324d8f85f391b934b4fb71e2c839	2025-02-14 23:44:24.322+00	{"action": "signup", "authProvider": "password"}	\N	\N
SjBt5FG3is	2024-02-15 23:44:25.188+00	2024-02-15 23:44:25.188+00	ThB01tcKMK	\N	r:0e820771be0128e6bfd267ff01194efd	2025-02-14 23:44:25.188+00	{"action": "signup", "authProvider": "password"}	\N	\N
HGtp4H6rZs	2024-02-15 23:44:26.056+00	2024-02-15 23:44:26.056+00	ZKRnZ2Pvpw	\N	r:33ae92a2d570ef73fb9233a6b36b4c40	2025-02-14 23:44:26.056+00	{"action": "signup", "authProvider": "password"}	\N	\N
dOZ30vVyC5	2024-02-15 23:44:26.992+00	2024-02-15 23:44:26.992+00	MWFguzNHoB	\N	r:c1d515dddadfb2c360f535a4f31a1fd7	2025-02-14 23:44:26.992+00	{"action": "signup", "authProvider": "password"}	\N	\N
oDI7uwJvH4	2024-02-16 01:17:15.459+00	2024-02-16 01:17:15.459+00	2JtaZklpt6	\N	r:54dd3662c1315ba92a59949dc4c63cdb	2025-02-15 01:17:15.458+00	{"action": "login", "authProvider": "password"}	\N	\N
\.


--
-- Data for Name: _User; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public."_User" ("objectId", "createdAt", "updatedAt", username, email, "emailVerified", "authData", _rperm, _wperm, _hashed_password, _email_verify_token_expires_at, _email_verify_token, _account_lockout_expires_at, _failed_login_count, _perishable_token, _perishable_token_expires_at, _password_changed_at, _password_history, firstname, lastname, is_restaurant_owner, is_admin, name) FROM stdin;
PZU8MGZBSu	2024-02-15 23:37:11.161+00	2024-02-15 23:37:11.161+00	coolUser123	coolUser123@gmail.com	\N	\N	{PZU8MGZBSu}	{PZU8MGZBSu}	$2y$10$xcMdg9CVH3Bs4GW/GAClU.p7yREKeg2Gaxy7ospFxGtuVxFcFPiya	\N	\N	\N	\N	\N	\N	\N	\N	coolUser123	coolUser123	t	f	coolUser123
tDqZkssIPn	2024-02-15 23:37:12.969+00	2024-02-15 23:37:12.969+00	awesomeCoder	awesomeCoder@gmail.com	\N	\N	{tDqZkssIPn}	{tDqZkssIPn}	$2y$10$Y7ayPqTD98LZdVsigjia4OHYnh6S4q3Npcp7KVxDQPgzJHCe52vJG	\N	\N	\N	\N	\N	\N	\N	\N	awesomeCoder	awesomeCoder	t	f	awesomeCoder
D6RShAUuJh	2024-02-15 23:37:13.793+00	2024-02-15 23:37:13.793+00	webMaster	webMaster@gmail.com	\N	\N	{D6RShAUuJh}	{D6RShAUuJh}	$2y$10$gK5fIOJlPhjlS0iCB4m0AOIk5UnHg5HZ8BievCw778v0L9gwaC0Eq	\N	\N	\N	\N	\N	\N	\N	\N	webMaster	webMaster	t	f	webMaster
WIBRYx5Fgz	2024-02-15 23:37:14.629+00	2024-02-15 23:37:14.629+00	techExplorer	techExplorer@gmail.com	\N	\N	{WIBRYx5Fgz}	{WIBRYx5Fgz}	$2y$10$Y2yKPCTrF38pCWZccEa4a.7bf9q2GwHOwf9O4dzAcF3edBkFIkqRS	\N	\N	\N	\N	\N	\N	\N	\N	techExplorer	techExplorer	t	f	techExplorer
ayknKzJtEy	2024-02-15 23:37:15.48+00	2024-02-15 23:37:15.48+00	codeNinja	codeNinja@gmail.com	\N	\N	{ayknKzJtEy}	{ayknKzJtEy}	$2y$10$SjuX27t8xJfqK1S/X8S3geM8SgeKXzmARIToK/L70l2tHssuwpSUq	\N	\N	\N	\N	\N	\N	\N	\N	codeNinja	codeNinja	t	f	codeNinja
Y84X9Ojgs1	2024-02-15 23:37:16.348+00	2024-02-15 23:37:16.348+00	user1234	user1234@gmail.com	\N	\N	{Y84X9Ojgs1}	{Y84X9Ojgs1}	$2y$10$lvxUoBgdzjta/dJ0FN5ai.KUbj2BGjXZ/DZkC.C5aJXhfnhvLIJ56	\N	\N	\N	\N	\N	\N	\N	\N	user1234	user1234	t	f	user1234
FmRAQO7hmZ	2024-02-15 23:37:17.189+00	2024-02-15 23:37:17.189+00	codingPro	codingPro@gmail.com	\N	\N	{FmRAQO7hmZ}	{FmRAQO7hmZ}	$2y$10$wdQgR3VPlwdFVq5e4yDlWeeVGtqyO.RGQlFSpfh/Bn24VrfQI2oyu	\N	\N	\N	\N	\N	\N	\N	\N	codingPro	codingPro	t	f	codingPro
WKW8jnYqhx	2024-02-15 23:37:23.359+00	2024-02-15 23:37:23.359+00	devGuru	devGuru@gmail.com	\N	\N	{WKW8jnYqhx}	{WKW8jnYqhx}	$2y$10$B2eAvEV5VTQ8QfzUp9u3POx6QBdHCd2kyPQTycnjr28BR/ToB9tna	\N	\N	\N	\N	\N	\N	\N	\N	devGuru	devGuru	t	f	devGuru
F4jIGBQK0X	2024-02-15 23:37:25.574+00	2024-02-15 23:37:25.574+00	javascriptLover	javascriptLover@gmail.com	\N	\N	{F4jIGBQK0X}	{F4jIGBQK0X}	$2y$10$sAaPsqrSZ1QoTAF0ML/rve2xpa4X.yyfspoSI2ciQu5LLXrYw3mFm	\N	\N	\N	\N	\N	\N	\N	\N	javascriptLover	javascriptLover	t	f	javascriptLover
O7EGuR5DRA	2024-02-15 23:37:26.496+00	2024-02-15 23:37:26.496+00	geekyCoder	geekyCoder@gmail.com	\N	\N	{O7EGuR5DRA}	{O7EGuR5DRA}	$2y$10$2QOMjaqQchp62vMdqlBP6OGQ05DI45JOHFNW6lfETlpoLxk6dH8HC	\N	\N	\N	\N	\N	\N	\N	\N	geekyCoder	geekyCoder	t	f	geekyCoder
tPCZtNvgUy	2024-02-15 23:37:27.361+00	2024-02-15 23:37:27.361+00	ArtisticSoul	ArtisticSoul@gmail.com	\N	\N	{tPCZtNvgUy}	{tPCZtNvgUy}	$2y$10$QPlLpCBycdiaxMoPf87DbumyP7paV0khqjeKjN9KZbQeiXcPwbByG	\N	\N	\N	\N	\N	\N	\N	\N	ArtisticSoul	ArtisticSoul	t	f	ArtisticSoul
5X202ssb0D	2024-02-15 23:37:28.196+00	2024-02-15 23:37:28.196+00	FitnessFreak123	FitnessFreak123@gmail.com	\N	\N	{5X202ssb0D}	{5X202ssb0D}	$2y$10$qBPgB3hscpsUXe4Aceb50e1jd4GwICKs3u6K6iKLEeTTZWq4DBEte	\N	\N	\N	\N	\N	\N	\N	\N	FitnessFreak123	FitnessFreak123	f	f	FitnessFreak123
ONgyydfVNz	2024-02-15 23:37:29.016+00	2024-02-15 23:37:29.016+00	SunnyDayz	SunnyDayz@gmail.com	\N	\N	{ONgyydfVNz}	{ONgyydfVNz}	$2y$10$OTxXBSsiaHvCZHZydZJJPeghhwSsH4fNxHuhnaB00hb3XOlItJ0Pu	\N	\N	\N	\N	\N	\N	\N	\N	SunnyDayz	SunnyDayz	f	f	SunnyDayz
adE9nQrDk3	2024-02-15 23:37:29.849+00	2024-02-15 23:37:29.849+00	MysterySolver	MysterySolver@gmail.com	\N	\N	{adE9nQrDk3}	{adE9nQrDk3}	$2y$10$lYyQVW.aWWLEfiTFufZW8uzd5H6E7JELMWndSeRpXTJAGAtxV5hK.	\N	\N	\N	\N	\N	\N	\N	\N	MysterySolver	MysterySolver	f	f	MysterySolver
I5RzFRcQ7G	2024-02-15 23:37:30.662+00	2024-02-15 23:37:30.662+00	HappyHarmony	HappyHarmony@gmail.com	\N	\N	{I5RzFRcQ7G}	{I5RzFRcQ7G}	$2y$10$ybRrlyyByKrjTxJjOF5V2eUC5G2Qh/PqWprpKcgtgCu/BNHMY5L6u	\N	\N	\N	\N	\N	\N	\N	\N	HappyHarmony	HappyHarmony	f	f	HappyHarmony
sHiqaG4iqY	2024-02-15 23:37:31.469+00	2024-02-15 23:37:31.469+00	RainbowChaser	RainbowChaser@gmail.com	\N	\N	{sHiqaG4iqY}	{sHiqaG4iqY}	$2y$10$MX8aUo7jgaDZTwYjAGqUCuWKBQaX5Q7c2dnCCLYw9x0IW39eRcK6m	\N	\N	\N	\N	\N	\N	\N	\N	RainbowChaser	RainbowChaser	f	f	RainbowChaser
sy1HD51LXT	2024-02-15 23:37:32.307+00	2024-02-15 23:37:32.307+00	MoonlightDreamer	MoonlightDreamer@gmail.com	\N	\N	{sy1HD51LXT}	{sy1HD51LXT}	$2y$10$GVS1XwC9HfMtVJg/ecyUBeitfUu0pue6zCY.LWzi44oIV8APMRr5G	\N	\N	\N	\N	\N	\N	\N	\N	MoonlightDreamer	MoonlightDreamer	f	f	MoonlightDreamer
jqDYoPT45X	2024-02-15 23:37:33.176+00	2024-02-15 23:37:33.176+00	StarStruck89	StarStruck89@gmail.com	\N	\N	{jqDYoPT45X}	{jqDYoPT45X}	$2y$10$6RRdTIPK0ZhpD2sbIfGEX.GRgKEA8AXzC5G4Oo9qRH9dbleWZ86Ci	\N	\N	\N	\N	\N	\N	\N	\N	StarStruck89	StarStruck89	f	f	StarStruck89
WKpBp0c8F3	2024-02-15 23:37:34.068+00	2024-02-15 23:37:34.068+00	WonderWoman78	WonderWoman78@gmail.com	\N	\N	{WKpBp0c8F3}	{WKpBp0c8F3}	$2y$10$0xBVGyD4EE0Ixyyd0sDNDuxLw4F/FED3DmBRS3kRnBMAFqX191tgq	\N	\N	\N	\N	\N	\N	\N	\N	WonderWoman78	WonderWoman78	f	f	WonderWoman78
R2CLtFh5jU	2024-02-15 23:37:34.928+00	2024-02-15 23:37:34.928+00	CaptainMarvel22	CaptainMarvel22@gmail.com	\N	\N	{R2CLtFh5jU}	{R2CLtFh5jU}	$2y$10$3HPtR2KOkE3.C1e6Jx8qHO7hNk1xw1HJ6vxahZqWcmNamiy77NnjC	\N	\N	\N	\N	\N	\N	\N	\N	CaptainMarvel22	CaptainMarvel22	f	f	CaptainMarvel22
RWwLSzreG2	2024-02-15 23:37:35.813+00	2024-02-15 23:37:35.813+00	PixelPioneer	PixelPioneer@gmail.com	\N	\N	{RWwLSzreG2}	{RWwLSzreG2}	$2y$10$C8jKc0MHTwMLIEjMxzSaHeOgayWpBFmQQivlIcMHG6xh2xJE9EyIK	\N	\N	\N	\N	\N	\N	\N	\N	PixelPioneer	PixelPioneer	f	f	PixelPioneer
VshUk7eBeK	2024-02-15 23:37:36.737+00	2024-02-15 23:37:36.737+00	EagleEye22	EagleEye22@gmail.com	\N	\N	{VshUk7eBeK}	{VshUk7eBeK}	$2y$10$uAvkp7OZTmJWRlkbo2Lriu2isAQNVCh3bhQh91lub7cRay5kyXd5m	\N	\N	\N	\N	\N	\N	\N	\N	EagleEye22	EagleEye22	f	f	EagleEye22
mAKp5BK7R1	2024-02-15 23:37:37.55+00	2024-02-15 23:37:37.55+00	NightOwl76	NightOwl76@gmail.com	\N	\N	{mAKp5BK7R1}	{mAKp5BK7R1}	$2y$10$8qiGVESTQ8n.JCghJhmfBOFD1ZvE8.zsTmrOlcsLe5.PPfWSjDpF.	\N	\N	\N	\N	\N	\N	\N	\N	NightOwl76	NightOwl76	f	f	NightOwl76
S6wz0lK0bf	2024-02-15 23:37:38.47+00	2024-02-15 23:37:38.47+00	OceanExplorer	OceanExplorer@gmail.com	\N	\N	{S6wz0lK0bf}	{S6wz0lK0bf}	$2y$10$r8tiYTCcIVnJv32K64V9Xe9z3jwbvEqF72JvJISa6ct5jlRzWyby6	\N	\N	\N	\N	\N	\N	\N	\N	OceanExplorer	OceanExplorer	f	f	OceanExplorer
SFAISec8QF	2024-02-15 23:37:39.331+00	2024-02-15 23:37:39.331+00	RocketMan47	RocketMan47@gmail.com	\N	\N	{SFAISec8QF}	{SFAISec8QF}	$2y$10$pCxtz1C2asXe/GLqwNSEYO9s6I9CrNU4o37dEEGSl4N8AV0hpwV6y	\N	\N	\N	\N	\N	\N	\N	\N	RocketMan47	RocketMan47	f	f	RocketMan47
iWxl9obi8w	2024-02-15 23:37:40.208+00	2024-02-15 23:37:40.208+00	CookieMonster	CookieMonster@gmail.com	\N	\N	{iWxl9obi8w}	{iWxl9obi8w}	$2y$10$rrnWU.gsEr4tobyuyChpbuLOJENNQbG2GwB.47tVGNXh7XvmIjmLS	\N	\N	\N	\N	\N	\N	\N	\N	CookieMonster	CookieMonster	f	f	CookieMonster
mQXQWNqxg9	2024-02-15 23:37:41.122+00	2024-02-15 23:37:41.122+00	MagicMinds	MagicMinds@gmail.com	\N	\N	{mQXQWNqxg9}	{mQXQWNqxg9}	$2y$10$1ENWRohLHD2I10WXgON/1uh3reX4cIeHRI3oxgOTFoXsMLcX6X4vi	\N	\N	\N	\N	\N	\N	\N	\N	MagicMinds	MagicMinds	f	f	MagicMinds
iUlyHNFGpG	2024-02-15 23:37:42.136+00	2024-02-15 23:37:42.136+00	TigerLily88	TigerLily88@gmail.com	\N	\N	{iUlyHNFGpG}	{iUlyHNFGpG}	$2y$10$SV9EWoB0r8eP88p7kWXsx.p05GEgvzd816.O9qpKz2AtOs9yTwjjy	\N	\N	\N	\N	\N	\N	\N	\N	TigerLily88	TigerLily88	f	f	TigerLily88
AsrLUQwxI9	2024-02-15 23:37:42.997+00	2024-02-15 23:37:42.997+00	DreamCatcher	DreamCatcher@gmail.com	\N	\N	{AsrLUQwxI9}	{AsrLUQwxI9}	$2y$10$UyCGB9EpuAKPJK8r3/qSQeBrOwJoLsvPF3qnj0ZtD15RyiZZ4lC0G	\N	\N	\N	\N	\N	\N	\N	\N	DreamCatcher	DreamCatcher	f	f	DreamCatcher
HtEtaHBVDN	2024-02-15 23:37:43.894+00	2024-02-15 23:37:43.894+00	SilverSurfer99	SilverSurfer99@gmail.com	\N	\N	{HtEtaHBVDN}	{HtEtaHBVDN}	$2y$10$MDw5HwtcJx69tjnXxhkSXuqsBltVwcfncWUitaSMjXBjyM4mfBR4q	\N	\N	\N	\N	\N	\N	\N	\N	SilverSurfer99	SilverSurfer99	f	f	SilverSurfer99
opW2wQ2bZ8	2024-02-15 23:37:44.768+00	2024-02-15 23:37:44.768+00	GoldenHeart22	GoldenHeart22@gmail.com	\N	\N	{opW2wQ2bZ8}	{opW2wQ2bZ8}	$2y$10$kL31h2KHlWjw84s2XYtQIuIpXYIjYIWih8uydkfQ6LXLhHiERrCJG	\N	\N	\N	\N	\N	\N	\N	\N	GoldenHeart22	GoldenHeart22	f	f	GoldenHeart22
Otwj7uJwjr	2024-02-15 23:37:45.646+00	2024-02-15 23:37:45.646+00	EternalOptimist	EternalOptimist@gmail.com	\N	\N	{Otwj7uJwjr}	{Otwj7uJwjr}	$2y$10$qqMoEy4SKJFHdkH4N2DlAOQ1kWpIRFkANgzX58tMygXpaytB4kxf.	\N	\N	\N	\N	\N	\N	\N	\N	EternalOptimist	EternalOptimist	f	f	EternalOptimist
9223vtvaBd	2024-02-15 23:37:46.645+00	2024-02-15 23:37:46.645+00	PandaPilot	PandaPilot@gmail.com	\N	\N	{9223vtvaBd}	{9223vtvaBd}	$2y$10$VkViT1MVH45UpQPxB6p5bO6pRJi4G4KesliOcGmyeujjiZV1Sqo5a	\N	\N	\N	\N	\N	\N	\N	\N	PandaPilot	PandaPilot	f	f	PandaPilot
dEqAHvPMXA	2024-02-15 23:37:47.568+00	2024-02-15 23:37:47.568+00	SailingSerenity	SailingSerenity@gmail.com	\N	\N	{dEqAHvPMXA}	{dEqAHvPMXA}	$2y$10$8fxvNAIiMSxeUpKaz94yuOSCzjKBa2rkmH5LTosY7GTKuKhraB//y	\N	\N	\N	\N	\N	\N	\N	\N	SailingSerenity	SailingSerenity	f	f	SailingSerenity
NjxsGlPeB4	2024-02-15 23:37:48.458+00	2024-02-15 23:37:48.458+00	GuitarGuru77	GuitarGuru77@gmail.com	\N	\N	{NjxsGlPeB4}	{NjxsGlPeB4}	$2y$10$/ZDiiDoaN8fKBKGEC8c.ou6ARB/J9n/NTJniPHPB2ue97GHzDwjRS	\N	\N	\N	\N	\N	\N	\N	\N	GuitarGuru77	GuitarGuru77	f	f	GuitarGuru77
1as6rMOzjQ	2024-02-15 23:37:49.38+00	2024-02-15 23:37:49.38+00	CosmicVoyager	CosmicVoyager@gmail.com	\N	\N	{1as6rMOzjQ}	{1as6rMOzjQ}	$2y$10$CuGNHjjywc42cf2WJq6c7u/pCmZVevkDho.N3fXYae7LI43xd3oUe	\N	\N	\N	\N	\N	\N	\N	\N	CosmicVoyager	CosmicVoyager	f	f	CosmicVoyager
dZKm0wOhYa	2024-02-15 23:37:50.312+00	2024-02-15 23:37:50.312+00	ZephyrZodiac	ZephyrZodiac@gmail.com	\N	\N	{dZKm0wOhYa}	{dZKm0wOhYa}	$2y$10$oC11kGYY3sFPqpwlIQ.dCOuJkYXDXnyPi/0PzGFgu4tPcnnvyzDTm	\N	\N	\N	\N	\N	\N	\N	\N	ZephyrZodiac	ZephyrZodiac	f	f	ZephyrZodiac
5nv19u6KJ2	2024-02-15 23:37:51.255+00	2024-02-15 23:37:51.255+00	WhimsicalWanderer	WhimsicalWanderer@gmail.com	\N	\N	{5nv19u6KJ2}	{5nv19u6KJ2}	$2y$10$RBrgU/5Q11.NxQAO.P8Rh.Vwxrz.kSOxxBtCpk1eX6t01JX6QRMmm	\N	\N	\N	\N	\N	\N	\N	\N	WhimsicalWanderer	WhimsicalWanderer	f	f	WhimsicalWanderer
HRhGpJpmb5	2024-02-15 23:37:52.179+00	2024-02-15 23:37:52.179+00	AquaAdventurer	AquaAdventurer@gmail.com	\N	\N	{HRhGpJpmb5}	{HRhGpJpmb5}	$2y$10$vG7IVrOlINcqM5XFUvTVju02CZOsRPFyEQR61P7Xxwf8c8wj9X5yW	\N	\N	\N	\N	\N	\N	\N	\N	AquaAdventurer	AquaAdventurer	f	f	AquaAdventurer
2JtaZklpt6	2024-02-15 23:44:20.916+00	2024-02-15 23:44:20.916+00	ali	ali@gmail.com	\N	\N	{2JtaZklpt6}	{2JtaZklpt6}	$2y$10$IMqUzsDX4C7rV/vcwXH3ouk49g0nbJ.nkvz0qbUeMl3R86pgvqbpG	\N	\N	\N	\N	\N	\N	\N	\N	ali	ali	f	t	ali
UzIZhuMWEG	2024-02-15 23:44:22.737+00	2024-02-15 23:44:22.737+00	ahmad	ahmad@gmail.com	\N	\N	{UzIZhuMWEG}	{UzIZhuMWEG}	$2y$10$3quHA907Cl3eQddiV9/fpeaXurZChe568LN7YgrhfTSsbCgm3jWFC	\N	\N	\N	\N	\N	\N	\N	\N	ahmad	ahmad	f	t	ahmad
SEGg5uMQqx	2024-02-15 23:44:23.652+00	2024-02-15 23:44:23.652+00	ramin	ramin@gmail.com	\N	\N	{SEGg5uMQqx}	{SEGg5uMQqx}	$2y$10$3nHAGf9NAVToRc8I5b/ykeJyogz6EDGg5RyAgQsTEuQAdscuCtOOe	\N	\N	\N	\N	\N	\N	\N	\N	ramin	ramin	f	t	ramin
ThB01tcKMK	2024-02-15 23:44:24.528+00	2024-02-15 23:44:24.528+00	azin	azin@gmail.com	\N	\N	{ThB01tcKMK}	{ThB01tcKMK}	$2y$10$cXn1qfVB04nOjzWeO4/RP.x2cL6Az1WDRYINLNkaQoPOuIlJz37fG	\N	\N	\N	\N	\N	\N	\N	\N	azin	azin	f	t	azin
ZKRnZ2Pvpw	2024-02-15 23:44:25.402+00	2024-02-15 23:44:25.402+00	karim	karim@gmail.com	\N	\N	{ZKRnZ2Pvpw}	{ZKRnZ2Pvpw}	$2y$10$MNjBE5FcFDpdc7gcigAo/e0PmG6vvkCtFsNIrM/F4varRfPbsyUSC	\N	\N	\N	\N	\N	\N	\N	\N	karim	karim	f	t	karim
MWFguzNHoB	2024-02-15 23:44:26.318+00	2024-02-15 23:44:26.318+00	mohammad	mohammad@gmail.com	\N	\N	{MWFguzNHoB}	{MWFguzNHoB}	$2y$10$qoNvTh5J5/7jXYAtpsw4P.mW0NDglJE6SdefGE9uK23ZKzvgTBO9q	\N	\N	\N	\N	\N	\N	\N	\N	mohammad	mohammad	f	t	mohammad
\.


--
-- Data for Name: spatial_ref_sys; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.spatial_ref_sys (srid, auth_name, auth_srid, srtext, proj4text) FROM stdin;
\.


--
-- Data for Name: geocode_settings; Type: TABLE DATA; Schema: tiger; Owner: root
--

COPY tiger.geocode_settings (name, setting, unit, category, short_desc) FROM stdin;
\.


--
-- Data for Name: pagc_gaz; Type: TABLE DATA; Schema: tiger; Owner: root
--

COPY tiger.pagc_gaz (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_lex; Type: TABLE DATA; Schema: tiger; Owner: root
--

COPY tiger.pagc_lex (id, seq, word, stdword, token, is_custom) FROM stdin;
\.


--
-- Data for Name: pagc_rules; Type: TABLE DATA; Schema: tiger; Owner: root
--

COPY tiger.pagc_rules (id, rule, is_custom) FROM stdin;
\.


--
-- Data for Name: topology; Type: TABLE DATA; Schema: topology; Owner: root
--

COPY topology.topology (id, name, srid, "precision", hasz) FROM stdin;
\.


--
-- Data for Name: layer; Type: TABLE DATA; Schema: topology; Owner: root
--

COPY topology.layer (topology_id, layer_id, schema_name, table_name, feature_column, feature_type, level, child_id) FROM stdin;
\.


--
-- Name: topology_id_seq; Type: SEQUENCE SET; Schema: topology; Owner: root
--

SELECT pg_catalog.setval('topology.topology_id_seq', 1, false);


--
-- Name: Category Category_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."Category"
    ADD CONSTRAINT "Category_pkey" PRIMARY KEY ("objectId");


--
-- Name: Food Food_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."Food"
    ADD CONSTRAINT "Food_pkey" PRIMARY KEY ("objectId");


--
-- Name: Restaurant Restaurant_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."Restaurant"
    ADD CONSTRAINT "Restaurant_pkey" PRIMARY KEY ("objectId");


--
-- Name: Score Score_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."Score"
    ADD CONSTRAINT "Score_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Audience _Audience_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_Audience"
    ADD CONSTRAINT "_Audience_pkey" PRIMARY KEY ("objectId");


--
-- Name: _GlobalConfig _GlobalConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_GlobalConfig"
    ADD CONSTRAINT "_GlobalConfig_pkey" PRIMARY KEY ("objectId");


--
-- Name: _GraphQLConfig _GraphQLConfig_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_GraphQLConfig"
    ADD CONSTRAINT "_GraphQLConfig_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Idempotency _Idempotency_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_Idempotency"
    ADD CONSTRAINT "_Idempotency_pkey" PRIMARY KEY ("objectId");


--
-- Name: _JobSchedule _JobSchedule_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_JobSchedule"
    ADD CONSTRAINT "_JobSchedule_pkey" PRIMARY KEY ("objectId");


--
-- Name: _JobStatus _JobStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_JobStatus"
    ADD CONSTRAINT "_JobStatus_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Join:roles:_Role _Join:roles:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_Join:roles:_Role"
    ADD CONSTRAINT "_Join:roles:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _Join:users:_Role _Join:users:_Role_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_Join:users:_Role"
    ADD CONSTRAINT "_Join:users:_Role_pkey" PRIMARY KEY ("relatedId", "owningId");


--
-- Name: _PushStatus _PushStatus_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_PushStatus"
    ADD CONSTRAINT "_PushStatus_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Role _Role_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_Role"
    ADD CONSTRAINT "_Role_pkey" PRIMARY KEY ("objectId");


--
-- Name: _SCHEMA _SCHEMA_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_SCHEMA"
    ADD CONSTRAINT "_SCHEMA_pkey" PRIMARY KEY ("className");


--
-- Name: _Session _Session_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_Session"
    ADD CONSTRAINT "_Session_pkey" PRIMARY KEY ("objectId");


--
-- Name: _User _User_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public."_User"
    ADD CONSTRAINT "_User_pkey" PRIMARY KEY ("objectId");


--
-- Name: _Idempotency_unique_reqId; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX "_Idempotency_unique_reqId" ON public."_Idempotency" USING btree ("reqId");


--
-- Name: _Role_unique_name; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX "_Role_unique_name" ON public."_Role" USING btree (name);


--
-- Name: _User_unique_email; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX "_User_unique_email" ON public."_User" USING btree (email);


--
-- Name: _User_unique_username; Type: INDEX; Schema: public; Owner: root
--

CREATE UNIQUE INDEX "_User_unique_username" ON public."_User" USING btree (username);


--
-- Name: case_insensitive_email; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX case_insensitive_email ON public."_User" USING btree (lower(email) varchar_pattern_ops);


--
-- Name: case_insensitive_username; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX case_insensitive_username ON public."_User" USING btree (lower(username) varchar_pattern_ops);


--
-- Name: ttl; Type: INDEX; Schema: public; Owner: root
--

CREATE INDEX ttl ON public."_Idempotency" USING btree (expire);


--
-- PostgreSQL database dump complete
--

