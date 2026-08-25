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

--
-- Name: tiger; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA tiger;


--
-- Name: topology; Type: SCHEMA; Schema: -; Owner: -
--

CREATE SCHEMA topology;


--
-- Name: SCHEMA topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON SCHEMA topology IS 'PostGIS Topology schema';


--
-- Name: fuzzystrmatch; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS fuzzystrmatch WITH SCHEMA public;


--
-- Name: EXTENSION fuzzystrmatch; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION fuzzystrmatch IS 'determine similarities and distance between strings';


--
-- Name: postgis; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis WITH SCHEMA public;


--
-- Name: EXTENSION postgis; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis IS 'PostGIS geometry and geography spatial types and functions';


--
-- Name: postgis_tiger_geocoder; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_tiger_geocoder WITH SCHEMA tiger;


--
-- Name: EXTENSION postgis_tiger_geocoder; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_tiger_geocoder IS 'PostGIS tiger geocoder and reverse geocoder';


--
-- Name: postgis_topology; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS postgis_topology WITH SCHEMA topology;


--
-- Name: EXTENSION postgis_topology; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION postgis_topology IS 'PostGIS topology spatial types and functions';


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: addresses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.addresses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    link character varying,
    place character varying,
    cep character varying,
    number character varying,
    address character varying,
    complement character varying,
    neighborhood character varying,
    city character varying,
    state character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_by uuid,
    updated_by uuid
);


--
-- Name: apportionments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.apportionments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    service_id uuid NOT NULL,
    consumer_unit character varying NOT NULL,
    address character varying NOT NULL,
    classification character varying NOT NULL,
    percentage integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: calendar_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.calendar_events (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    date date NOT NULL,
    content jsonb DEFAULT '{}'::jsonb NOT NULL,
    project_id uuid,
    created_by uuid,
    updated_by uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: concessionaires; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.concessionaires (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    acronym character varying,
    code character varying,
    region character varying,
    phone character varying,
    email character varying,
    active boolean,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_by uuid,
    updated_by uuid,
    logo text
);


--
-- Name: customers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.customers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    address_id uuid,
    name character varying,
    email character varying,
    tax_id character varying,
    phone character varying,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_by uuid,
    updated_by uuid
);


--
-- Name: ledgers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ledgers (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid,
    service_id uuid,
    amount_cents integer DEFAULT 0 NOT NULL,
    reason character varying,
    description text,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_by uuid,
    updated_by uuid,
    paid_at timestamp(6) without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);


--
-- Name: price_tables; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.price_tables (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    kind character varying NOT NULL,
    name character varying NOT NULL,
    "values" jsonb DEFAULT '[]'::jsonb NOT NULL,
    created_by uuid,
    updated_by uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: project_status_comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_status_comments (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_status_id uuid NOT NULL,
    body text NOT NULL,
    created_by uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: project_statuses; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.project_statuses (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    name character varying NOT NULL,
    created_by uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: projects; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.projects (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    client_id uuid NOT NULL,
    address_id uuid,
    utility_company character varying NOT NULL,
    utility_protocol character varying NOT NULL,
    customer_class character varying NOT NULL,
    modality character varying NOT NULL,
    framework character varying NOT NULL,
    status character varying,
    amount numeric,
    dc_protection character varying,
    system_power double precision,
    unit_control character varying NOT NULL,
    description character varying(1024),
    project_type character varying NOT NULL,
    fast_track boolean DEFAULT false NOT NULL,
    coordinates public.geography(Point,4326),
    services_names character varying[],
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_by uuid,
    updated_by uuid,
    sequence integer,
    subsequence character varying,
    integrator uuid,
    related_project_id uuid,
    deleted_at timestamp(6) without time zone,
    secondary_protocol character varying
);


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: service_entry_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.service_entry_items (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    service_id uuid NOT NULL,
    connection_type character varying NOT NULL,
    classification character varying NOT NULL,
    quantity integer NOT NULL,
    circuit_breaker character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: services; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.services (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    service_type character varying NOT NULL,
    customer_id uuid NOT NULL,
    concessionaire_id uuid NOT NULL,
    opening_date date NOT NULL,
    amount numeric NOT NULL,
    discount_coupon_percentage integer,
    observations character varying,
    supply_voltage character varying,
    coordinates public.geography(Point,4326),
    generating_consumer_unit character varying,
    pole_distance_over_30m boolean DEFAULT false NOT NULL,
    construction_address_id uuid,
    generating_address_id uuid,
    created_by uuid,
    updated_by uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: technical_details; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.technical_details (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    project_id uuid NOT NULL,
    opening_date date,
    supply_voltage character varying,
    new_project boolean DEFAULT false NOT NULL,
    zero_grid_control boolean DEFAULT false NOT NULL,
    modules character varying[] DEFAULT '{}'::character varying[],
    inverters character varying[] DEFAULT '{}'::character varying[],
    entry_standard_items character varying[] DEFAULT '{}'::character varying[],
    credit_divisions character varying[] DEFAULT '{}'::character varying[],
    created_by uuid,
    updated_by uuid,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    item_id uuid NOT NULL,
    filename character varying NOT NULL,
    s3_url character varying NOT NULL,
    s3_key character varying NOT NULL,
    size bigint DEFAULT 0 NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    created_by uuid,
    updated_by uuid
);


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    name character varying NOT NULL,
    email character varying NOT NULL,
    password_digest character varying NOT NULL,
    profile character varying DEFAULT 'user'::character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: addresses addresses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT addresses_pkey PRIMARY KEY (id);


--
-- Name: apportionments apportionments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apportionments
    ADD CONSTRAINT apportionments_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: calendar_events calendar_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT calendar_events_pkey PRIMARY KEY (id);


--
-- Name: concessionaires concessionaires_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concessionaires
    ADD CONSTRAINT concessionaires_pkey PRIMARY KEY (id);


--
-- Name: customers customers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);


--
-- Name: ledgers ledgers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledgers
    ADD CONSTRAINT ledgers_pkey PRIMARY KEY (id);


--
-- Name: price_tables price_tables_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.price_tables
    ADD CONSTRAINT price_tables_pkey PRIMARY KEY (id);


--
-- Name: project_status_comments project_status_comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_status_comments
    ADD CONSTRAINT project_status_comments_pkey PRIMARY KEY (id);


--
-- Name: project_statuses project_statuses_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_statuses
    ADD CONSTRAINT project_statuses_pkey PRIMARY KEY (id);


--
-- Name: projects projects_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT projects_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: service_entry_items service_entry_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_entry_items
    ADD CONSTRAINT service_entry_items_pkey PRIMARY KEY (id);


--
-- Name: services services_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT services_pkey PRIMARY KEY (id);


--
-- Name: technical_details technical_details_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technical_details
    ADD CONSTRAINT technical_details_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: index_apportionments_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_apportionments_on_service_id ON public.apportionments USING btree (service_id);


--
-- Name: index_calendar_events_on_date; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendar_events_on_date ON public.calendar_events USING btree (date);


--
-- Name: index_calendar_events_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_calendar_events_on_project_id ON public.calendar_events USING btree (project_id);


--
-- Name: index_customers_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_customers_on_address_id ON public.customers USING btree (address_id);


--
-- Name: index_customers_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customers_on_email ON public.customers USING btree (email);


--
-- Name: index_customers_on_tax_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_customers_on_tax_id ON public.customers USING btree (tax_id);


--
-- Name: index_ledgers_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledgers_on_project_id ON public.ledgers USING btree (project_id);


--
-- Name: index_ledgers_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_ledgers_on_service_id ON public.ledgers USING btree (service_id);


--
-- Name: index_price_tables_on_kind; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_price_tables_on_kind ON public.price_tables USING btree (kind);


--
-- Name: index_project_status_comments_on_project_status_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_status_comments_on_project_status_id ON public.project_status_comments USING btree (project_status_id);


--
-- Name: index_project_statuses_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_project_statuses_on_project_id ON public.project_statuses USING btree (project_id);


--
-- Name: index_projects_on_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_address_id ON public.projects USING btree (address_id);


--
-- Name: index_projects_on_client_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_client_id ON public.projects USING btree (client_id);


--
-- Name: index_projects_on_deleted_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_deleted_at ON public.projects USING btree (deleted_at);


--
-- Name: index_projects_on_integrator; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_integrator ON public.projects USING btree (integrator);


--
-- Name: index_projects_on_related_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_projects_on_related_project_id ON public.projects USING btree (related_project_id);


--
-- Name: index_projects_on_sequence_with_subsequence; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_sequence_with_subsequence ON public.projects USING btree (sequence, subsequence) WHERE (subsequence IS NOT NULL);


--
-- Name: index_projects_on_sequence_without_subsequence; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_projects_on_sequence_without_subsequence ON public.projects USING btree (sequence) WHERE (subsequence IS NULL);


--
-- Name: index_service_entry_items_on_service_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_service_entry_items_on_service_id ON public.service_entry_items USING btree (service_id);


--
-- Name: index_services_on_concessionaire_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_concessionaire_id ON public.services USING btree (concessionaire_id);


--
-- Name: index_services_on_construction_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_construction_address_id ON public.services USING btree (construction_address_id);


--
-- Name: index_services_on_customer_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_customer_id ON public.services USING btree (customer_id);


--
-- Name: index_services_on_generating_address_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_services_on_generating_address_id ON public.services USING btree (generating_address_id);


--
-- Name: index_technical_details_on_project_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_technical_details_on_project_id ON public.technical_details USING btree (project_id);


--
-- Name: index_uploads_on_item_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_item_id ON public.uploads USING btree (item_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: ledgers fk_rails_04e654b585; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledgers
    ADD CONSTRAINT fk_rails_04e654b585 FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: services fk_rails_05e47ee6c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT fk_rails_05e47ee6c3 FOREIGN KEY (construction_address_id) REFERENCES public.addresses(id);


--
-- Name: projects fk_rails_0a17d69f55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_0a17d69f55 FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: concessionaires fk_rails_0d8ecb3780; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concessionaires
    ADD CONSTRAINT fk_rails_0d8ecb3780 FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: customers fk_rails_0fceac5ea7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_rails_0fceac5ea7 FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: service_entry_items fk_rails_1795330033; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.service_entry_items
    ADD CONSTRAINT fk_rails_1795330033 FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: project_status_comments fk_rails_2f6ed6bd7d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_status_comments
    ADD CONSTRAINT fk_rails_2f6ed6bd7d FOREIGN KEY (project_status_id) REFERENCES public.project_statuses(id);


--
-- Name: customers fk_rails_36c947031b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_rails_36c947031b FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: project_statuses fk_rails_3cf2a2e96d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_statuses
    ADD CONSTRAINT fk_rails_3cf2a2e96d FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: customers fk_rails_3f9404ba26; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT fk_rails_3f9404ba26 FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: addresses fk_rails_4aa2d705a5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_4aa2d705a5 FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: technical_details fk_rails_4f5fcda2d1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.technical_details
    ADD CONSTRAINT fk_rails_4f5fcda2d1 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: apportionments fk_rails_510793a5de; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.apportionments
    ADD CONSTRAINT fk_rails_510793a5de FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: ledgers fk_rails_5be1bfd871; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledgers
    ADD CONSTRAINT fk_rails_5be1bfd871 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: services fk_rails_611e8e49f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT fk_rails_611e8e49f6 FOREIGN KEY (generating_address_id) REFERENCES public.addresses(id);


--
-- Name: ledgers fk_rails_720159e5c3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledgers
    ADD CONSTRAINT fk_rails_720159e5c3 FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: addresses fk_rails_727063a9f1; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.addresses
    ADD CONSTRAINT fk_rails_727063a9f1 FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: services fk_rails_7d5c8b41f6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT fk_rails_7d5c8b41f6 FOREIGN KEY (concessionaire_id) REFERENCES public.concessionaires(id);


--
-- Name: project_status_comments fk_rails_802da82f95; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_status_comments
    ADD CONSTRAINT fk_rails_802da82f95 FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: project_statuses fk_rails_8477995179; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.project_statuses
    ADD CONSTRAINT fk_rails_8477995179 FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: projects fk_rails_8d9657cec3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_8d9657cec3 FOREIGN KEY (client_id) REFERENCES public.customers(id);


--
-- Name: projects fk_rails_9d4278ee2d; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_9d4278ee2d FOREIGN KEY (address_id) REFERENCES public.addresses(id);


--
-- Name: uploads fk_rails_bbbb2854e0; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT fk_rails_bbbb2854e0 FOREIGN KEY (updated_by) REFERENCES public.users(id);


--
-- Name: ledgers fk_rails_bdbe062be5; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ledgers
    ADD CONSTRAINT fk_rails_bdbe062be5 FOREIGN KEY (service_id) REFERENCES public.services(id);


--
-- Name: services fk_rails_c2bef342a7; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.services
    ADD CONSTRAINT fk_rails_c2bef342a7 FOREIGN KEY (customer_id) REFERENCES public.customers(id);


--
-- Name: projects fk_rails_dad18dabe3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_dad18dabe3 FOREIGN KEY (integrator) REFERENCES public.users(id);


--
-- Name: projects fk_rails_e67d9e1a94; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_e67d9e1a94 FOREIGN KEY (related_project_id) REFERENCES public.projects(id);


--
-- Name: concessionaires fk_rails_e6922b7e80; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.concessionaires
    ADD CONSTRAINT fk_rails_e6922b7e80 FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: calendar_events fk_rails_ea84aebf24; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.calendar_events
    ADD CONSTRAINT fk_rails_ea84aebf24 FOREIGN KEY (project_id) REFERENCES public.projects(id);


--
-- Name: uploads fk_rails_eb1978731c; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT fk_rails_eb1978731c FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- Name: projects fk_rails_eda740735f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.projects
    ADD CONSTRAINT fk_rails_eda740735f FOREIGN KEY (created_by) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public, topology, tiger;

INSERT INTO "schema_migrations" (version) VALUES
('20260825120000'),
('20260727002520'),
('20260726130000'),
('20260726120000'),
('20260722120000'),
('20260622120000'),
('20260617091239'),
('20260616120000'),
('20260610130000'),
('20260610120000'),
('20260529114700'),
('20260526230109'),
('20260516175644'),
('20260515164002'),
('20260514120003'),
('20260514120002'),
('20260514120001'),
('20260514120000'),
('20260502210003'),
('20260502210002'),
('20260502210001'),
('20260502210000'),
('20260502200001'),
('20260502200000'),
('20260502113002'),
('20260502021250'),
('20260502020000'),
('20260502015902'),
('20260501223121'),
('20260501203600');

