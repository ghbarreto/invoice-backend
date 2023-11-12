--
-- PostgreSQL database dump
--

-- Dumped from database version 15.3 (Debian 15.3-1.pgdg120+1)
-- Dumped by pg_dump version 15.3 (Debian 15.3-1.pgdg120+1)

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
-- Name: uuid-ossp; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS "uuid-ossp" WITH SCHEMA public;


--
-- Name: EXTENSION "uuid-ossp"; Type: COMMENT; Schema: -; Owner: 
--

COMMENT ON EXTENSION "uuid-ossp" IS 'generate universally unique identifiers (UUIDs)';


--
-- Name: status_enum; Type: TYPE; Schema: public; Owner: root
--

CREATE TYPE public.status_enum AS ENUM (
    'pending',
    'overdue',
    'paid',
    'draft'
);


ALTER TYPE public.status_enum OWNER TO root;

--
-- Name: generate_unique_short_id(); Type: FUNCTION; Schema: public; Owner: root
--

CREATE FUNCTION public.generate_unique_short_id() RETURNS character varying
    LANGUAGE plpgsql
    AS $$
DECLARE
    chars VARCHAR := 'ABCDEFGHIJKLMNOPQRSTUVWXYZ';
    new_id VARCHAR;
    prefix VARCHAR := '';
BEGIN
    -- Generate a random prefix with 2 random letters
    prefix := substr(chars, floor(random() * length(chars) + 1)::integer, 1) ||
              substr(chars, floor(random() * length(chars) + 1)::integer, 1);
    
    LOOP
        -- Generate a random 6-digit number with leading zeros
        new_id := prefix || lpad(floor(random() * 1000000)::text, 5, '0');
        
        -- Check if the generated ID is unique
        EXIT WHEN NOT EXISTS (SELECT 1 FROM invoices WHERE id = new_id);
    END LOOP;
    
    RETURN new_id;
END;
$$;


ALTER FUNCTION public.generate_unique_short_id() OWNER TO root;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: business_address; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.business_address (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    business_address character varying(50),
    business_city character varying(50),
    business_zip_code character varying(20),
    business_country character varying(50),
    invoice_id character varying(10)
);


ALTER TABLE public.business_address OWNER TO root;

--
-- Name: credentials; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.credentials (
    id character varying(128) NOT NULL,
    email character varying(120),
    provider_id character varying(30)
);


ALTER TABLE public.credentials OWNER TO root;

--
-- Name: customers; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.customers (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    user_id character varying(128),
    first_name character varying(50),
    last_name character varying(50),
    address character varying(128),
    country character varying(50),
    city character varying(50),
    client_email character varying(150),
    zip_code character varying(20),
    phone character varying(40)
);


ALTER TABLE public.customers OWNER TO root;

--
-- Name: invoice_address; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.invoice_address (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    first_name character varying(50),
    last_name character varying(50),
    address character varying(128),
    country character varying(50),
    city character varying(50),
    client_email character varying(150),
    zip_code character varying(20),
    invoice_id character varying(10),
    user_id character varying(128)
);


ALTER TABLE public.invoice_address OWNER TO root;

--
-- Name: invoice_items; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.invoice_items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    item_id uuid,
    invoice_id character varying(10),
    item_amount integer,
    overcharge numeric(10,2) DEFAULT 0.0
);


ALTER TABLE public.invoice_items OWNER TO root;

--
-- Name: invoices; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.invoices (
    id character varying(10) DEFAULT public.generate_unique_short_id() NOT NULL,
    date_due timestamp with time zone,
    currency_code character varying(3),
    user_id character varying(128),
    description text,
    price numeric(10,2),
    status public.status_enum,
    is_visible boolean DEFAULT true,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);


ALTER TABLE public.invoices OWNER TO root;

--
-- Name: items; Type: TABLE; Schema: public; Owner: root
--

CREATE TABLE public.items (
    id uuid DEFAULT public.uuid_generate_v4() NOT NULL,
    name character varying(20),
    price numeric(10,2),
    stock_amount integer,
    user_id character varying(128)
);


ALTER TABLE public.items OWNER TO root;

--
-- Data for Name: business_address; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.business_address (id, business_address, business_city, business_zip_code, business_country, invoice_id) FROM stdin;
be9a47dd-d444-4536-b0d3-b386fac1c10a	123 Main St	New York	10001	USA	XL33637
\.


--
-- Data for Name: credentials; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.credentials (id, email, provider_id) FROM stdin;
o3zfqLReWKfMIIJCPlsfML3NqO43	henriqve.dev@gmail.com	firebase
Chw2dswewxeg0BZSrPG1xDAR3zB2	gh.barreto@hotmail.com	github.com
sZq0R42xeSgSS4V9yK48GC4l0WD3	vuxgamer@gmail.com	google.com
\.


--
-- Data for Name: customers; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.customers (id, user_id, first_name, last_name, address, country, city, client_email, zip_code, phone) FROM stdin;
a161989e-0a26-434e-821a-a8076ad8ef96	o3zfqLReWKfMIIJCPlsfML3NqO43	John	Doe	123 Main St	USA	New York	john.doe@example.com	10001	555-1234
7a3d9d30-07ee-43e6-bc27-dcce2682dcd2	o3zfqLReWKfMIIJCPlsfML3NqO43	Jane	Doe	456 Elm St	USA	Los Angeles	jane.doe@example.com	90001	555-5678
a4d9d849-853b-4c45-8605-d29b36734cc1	o3zfqLReWKfMIIJCPlsfML3NqO43	Bob	Smith	789 Oak St	Canada	Toronto	bob.smith@example.com	M5J 2H7	555-9012
\.


--
-- Data for Name: invoice_address; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.invoice_address (id, first_name, last_name, address, country, city, client_email, zip_code, invoice_id, user_id) FROM stdin;
0a3d777c-1672-49d5-a76a-f1d5841cf8f5	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	US41082	o3zfqLReWKfMIIJCPlsfML3NqO43
3dbfd388-f7e1-43b7-9d97-e68b760fda4e	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	KD81204	o3zfqLReWKfMIIJCPlsfML3NqO43
16032f92-0b1d-4c3d-adbc-dc4dfd47c0e2	gabriel	barreto	this is the address IT WORKED	Br IT WORKED	Sao IT WORKED	ITWORKED@gmail.com	4420-IT WORKED	HJ22423	o3zfqLReWKfMIIJCPlsfML3NqO43
91cd37af-7a2e-4d4f-a574-cb3fcac8708d	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	SS48389	o3zfqLReWKfMIIJCPlsfML3NqO43
7507d428-5b02-4796-a809-0353e0045223	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	NR52650	o3zfqLReWKfMIIJCPlsfML3NqO43
360419ea-15aa-4070-a5b9-98e1012c1474	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	JC33159	o3zfqLReWKfMIIJCPlsfML3NqO43
f259b5b5-621b-4d34-8c5f-1a2d5900df69	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	DP70661	o3zfqLReWKfMIIJCPlsfML3NqO43
87692199-5a21-477b-8b62-baa658ba8fb4	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	AA41388	o3zfqLReWKfMIIJCPlsfML3NqO43
cbcc21ba-f2d2-4c4c-99c2-68a6c3de2020	gabriel	barreto	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	TH20751	o3zfqLReWKfMIIJCPlsfML3NqO43
64767353-eb3d-4338-ad17-52b4a92fb1e3	gabriel	barreto	124 Church Way	Canada	Vancouver	gg@gmail.com	BD2 PK4	XL33637	o3zfqLReWKfMIIJCPlsfML3NqO43
6aeca32f-13bf-42e6-9600-bc4e64edf929	Test	Last_test	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	VV44940	o3zfqLReWKfMIIJCPlsfML3NqO43
47d2d535-ecdc-4338-8e4e-650ede8251e1	Test	Last_test	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	QJ98646	o3zfqLReWKfMIIJCPlsfML3NqO43
0640e099-d609-472f-bea6-39925bdcf602	Test	Last_test	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	SR31249	o3zfqLReWKfMIIJCPlsfML3NqO43
8a26e50b-9dc5-44fb-bdaa-f4cc5a7e205f	Test	Last_test	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	AK39980	o3zfqLReWKfMIIJCPlsfML3NqO43
f0746bfe-67f6-4972-98d3-9377e9df4a99	THIS IS THE FE POST	Last_test	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	SA63139	o3zfqLReWKfMIIJCPlsfML3NqO43
5726f9e9-d6b3-4472-b31d-b84a8822a439	THIS IS THE FE POST	Last_test	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	TZ79344	o3zfqLReWKfMIIJCPlsfML3NqO43
aa81a991-1a4f-40b6-b514-66597ba8c4eb	THIS IS THE FE POST	Last_test	this is the address	Brazil	Sao Paulo	test@gmail.com	4420-5223	ZP53934	o3zfqLReWKfMIIJCPlsfML3NqO43
\.


--
-- Data for Name: invoice_items; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.invoice_items (id, item_id, invoice_id, item_amount, overcharge) FROM stdin;
5b28d8fc-e343-4b6c-a347-0b0cb73e4a07	b9dc438a-d36d-463f-8f88-c0e25f2eb970	KD81204	1	1250.00
fb15f6af-8e84-40f9-b531-a36fa30e807d	b2be4c29-6ae7-490e-b893-41d3040de92d	KD81204	2	0.00
2118c43e-cbc7-47d0-a738-9dfe0b5786e7	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	KD81204	3	0.00
fdf1a5b8-e261-413a-9716-593ca2680bda	b9dc438a-d36d-463f-8f88-c0e25f2eb970	NR52650	1	0.00
b797c695-a3ac-40c2-ac68-b47f410c3cef	b2be4c29-6ae7-490e-b893-41d3040de92d	NR52650	2	0.00
5fc3ee99-ee97-4021-b05c-63ed0383ac12	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	NR52650	3	0.00
3282f94e-a82e-4d7d-9315-236cd5d2583e	b9dc438a-d36d-463f-8f88-c0e25f2eb970	HJ22423	22424	0.00
b4ab8667-347e-4aae-972d-6e3da92bfa89	b2be4c29-6ae7-490e-b893-41d3040de92d	HJ22423	2522222	0.00
4dedc1b2-b48a-41d6-ac6b-c0d5bd7fe1f9	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	HJ22423	32323	0.00
a4176ee0-aaed-407b-87bf-899e9df32846	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	XL33637	5	0.00
00490ff7-daf8-4dd6-842c-406737bffadd	b2be4c29-6ae7-490e-b893-41d3040de92d	VV44940	2	0.00
76d30d98-8d5c-4150-8998-ae0465f8d5ba	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	VV44940	3	0.00
4df2985f-e903-4e3b-93fa-3dc2e7dd7f63	b9dc438a-d36d-463f-8f88-c0e25f2eb970	XL33637	3	85.50
48769a46-80e6-4bc4-9bbf-14e19e7bee0d	b2be4c29-6ae7-490e-b893-41d3040de92d	XL33637	3	0.00
3d4e6061-2575-47c8-9bf4-77d5935bdb31	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	VV44940	1	1250.00
2c884dec-1473-48d8-8cba-87af8e79e5aa	b9dc438a-d36d-463f-8f88-c0e25f2eb970	AK39980	1	1250.00
4577557f-17a2-4d7b-ad4a-1fb41f4f9d42	b2be4c29-6ae7-490e-b893-41d3040de92d	AK39980	2	0.00
e7a983e3-3383-454a-a68f-40fcca55bdd8	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	AK39980	3	0.00
946b88bb-e233-4daa-968b-9d37b71bfa83	b9dc438a-d36d-463f-8f88-c0e25f2eb970	SA63139	1	1250.00
0cf18b6c-ec5e-4be6-a74a-b5103f038a47	b2be4c29-6ae7-490e-b893-41d3040de92d	SA63139	2	0.00
cd5fd9a3-a3f1-423f-8827-84eca51f17ae	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	SA63139	3	0.00
a82d3720-29c8-4821-abd8-5808f54314cf	b9dc438a-d36d-463f-8f88-c0e25f2eb970	TZ79344	1	1250.00
c9def93e-a7b6-4d07-ace8-4badc3b35a5e	b2be4c29-6ae7-490e-b893-41d3040de92d	TZ79344	2	0.00
5077a902-c2b2-411b-a509-bffb0c38bb0d	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	TZ79344	3	0.00
13b96b6b-7f1d-4372-9aa4-4f295098f525	b9dc438a-d36d-463f-8f88-c0e25f2eb970	ZP53934	1	1250.00
3caedae5-7482-455c-831a-5afb9490e4bb	b2be4c29-6ae7-490e-b893-41d3040de92d	ZP53934	2	0.00
775f8818-0892-4086-a689-d5c05067f53d	92f6232c-2d24-4860-bbdb-90c8d0d30fe4	ZP53934	3	0.00
\.


--
-- Data for Name: invoices; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.invoices (id, date_due, currency_code, user_id, description, price, status, is_visible, created_at) FROM stdin;
US41082	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	pending	t	2023-09-20 00:26:50.725709+00
KD81204	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	pending	t	2023-09-20 00:26:50.725709+00
JC33159	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	pending	t	2023-09-20 00:26:50.725709+00
AA41388	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	pending	t	2023-09-20 00:26:50.725709+00
TH20751	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	pending	t	2023-09-20 00:26:50.725709+00
DP70661	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	draft	t	2023-09-20 00:26:50.725709+00
SS48389	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	paid	t	2023-09-20 00:26:50.725709+00
NR52650	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this is the description	150.20	overdue	t	2023-09-20 00:26:50.725709+00
XL33637	2024-09-07 19:38:21.178+00	EUR	o3zfqLReWKfMIIJCPlsfML3NqO43	Front-end Developer	1520.20	overdue	t	2023-09-20 00:26:50.725709+00
HJ22423	2024-09-07 19:38:21.178+00	GBP	o3zfqLReWKfMIIJCPlsfML3NqO43	Front-end Developer	1520.20	overdue	t	2023-09-20 00:26:50.725709+00
VV44940	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this issdwqdqtion	150.20	pending	t	2023-09-20 00:27:46.074931+00
QJ98646	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this issdwqdqtion	150.20	pending	t	2023-09-21 01:02:25.214556+00
SR31249	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this issdwqdqtion	150.20	pending	t	2023-09-21 01:03:20.741657+00
AK39980	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this issdwqdqtion	150.20	pending	t	2023-10-05 00:47:32.459981+00
SA63139	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this issdwqdqtion	150.20	pending	t	2023-10-05 00:48:18.839093+00
TZ79344	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this issdwqdqtion	150.20	pending	t	2023-10-05 00:48:36.010991+00
ZP53934	2023-09-07 19:38:21.178+00	BRL	o3zfqLReWKfMIIJCPlsfML3NqO43	this issdwqdqtion	150.20	pending	t	2023-10-05 00:48:39.58659+00
\.


--
-- Data for Name: items; Type: TABLE DATA; Schema: public; Owner: root
--

COPY public.items (id, name, price, stock_amount, user_id) FROM stdin;
b9dc438a-d36d-463f-8f88-c0e25f2eb970	Website Design	19.99	100	o3zfqLReWKfMIIJCPlsfML3NqO43
b2be4c29-6ae7-490e-b893-41d3040de92d	Docker Design	29.99	75	o3zfqLReWKfMIIJCPlsfML3NqO43
92f6232c-2d24-4860-bbdb-90c8d0d30fe4	Backend Design	9.99	50	o3zfqLReWKfMIIJCPlsfML3NqO43
\.


--
-- Name: credentials credentials_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.credentials
    ADD CONSTRAINT credentials_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: invoice_address invoice_address_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoice_address
    ADD CONSTRAINT invoice_address_pkey PRIMARY KEY (id);


--
-- Name: invoice_items invoice_items_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_pkey PRIMARY KEY (id);


--
-- Name: invoices invoices_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_pkey PRIMARY KEY (id);


--
-- Name: items items_pkey; Type: CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_pkey PRIMARY KEY (id);


--
-- Name: business_address business_address_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.business_address
    ADD CONSTRAINT business_address_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: customers customers_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.credentials(id);


--
-- Name: invoice_address invoice_address_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoice_address
    ADD CONSTRAINT invoice_address_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id) ON DELETE CASCADE;


--
-- Name: invoice_address invoice_address_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoice_address
    ADD CONSTRAINT invoice_address_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.credentials(id);


--
-- Name: invoice_items invoice_items_invoice_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_invoice_id_fkey FOREIGN KEY (invoice_id) REFERENCES public.invoices(id);


--
-- Name: invoice_items invoice_items_item_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoice_items
    ADD CONSTRAINT invoice_items_item_id_fkey FOREIGN KEY (item_id) REFERENCES public.items(id);


--
-- Name: invoices invoices_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.invoices
    ADD CONSTRAINT invoices_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.credentials(id) ON DELETE CASCADE;


--
-- Name: items items_user_id_fkey; Type: FK CONSTRAINT; Schema: public; Owner: root
--

ALTER TABLE ONLY public.items
    ADD CONSTRAINT items_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.credentials(id);


--
-- PostgreSQL database dump complete
--

