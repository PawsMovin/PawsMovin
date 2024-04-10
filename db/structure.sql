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
-- Name: pg_trgm; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;


--
-- Name: EXTENSION pg_trgm; Type: COMMENT; Schema: -; Owner: -
--

COMMENT ON EXTENSION pg_trgm IS 'text similarity measurement and index searching based on trigrams';


--
-- Name: posts_trigger_change_seq(); Type: FUNCTION; Schema: public; Owner: -
--

CREATE FUNCTION public.posts_trigger_change_seq() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.tag_string != OLD.tag_string OR NEW.parent_id != OLD.parent_id OR NEW.source != OLD.source OR NEW.approver_id != OLD.approver_id OR NEW.rating != OLD.rating OR NEW.description != OLD.description OR NEW.md5 != OLD.md5 OR NEW.is_deleted != OLD.is_deleted OR NEW.is_pending != OLD.is_pending OR NEW.is_flagged != OLD.is_flagged OR NEW.is_rating_locked != OLD.is_rating_locked OR NEW.is_status_locked != OLD.is_status_locked OR NEW.is_note_locked != OLD.is_note_locked OR NEW.bit_flags != OLD.bit_flags OR NEW.has_active_children != OLD.has_active_children OR NEW.last_noted_at != OLD.last_noted_at
  THEN
     NEW.change_seq = nextval('public.posts_change_seq_seq');
  END IF;
  RETURN NEW;
END;
$$;


SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: api_keys; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.api_keys (
    id integer NOT NULL,
    user_id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying DEFAULT ''::character varying NOT NULL,
    permissions character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    permitted_ip_addresses inet[] DEFAULT '{}'::inet[] NOT NULL,
    uses integer DEFAULT 0 NOT NULL,
    last_used_at timestamp(6) without time zone,
    last_ip_address inet
);


--
-- Name: api_keys_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.api_keys_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: api_keys_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.api_keys_id_seq OWNED BY public.api_keys.id;


--
-- Name: ar_internal_metadata; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ar_internal_metadata (
    key character varying NOT NULL,
    value character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: artist_urls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_urls (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    url text NOT NULL,
    normalized_url text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL
);


--
-- Name: artist_urls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_urls_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_urls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_urls_id_seq OWNED BY public.artist_urls.id;


--
-- Name: artist_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artist_versions (
    id integer NOT NULL,
    artist_id integer NOT NULL,
    name character varying NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    urls text[] DEFAULT '{}'::text[] NOT NULL,
    notes_changed boolean DEFAULT false
);


--
-- Name: artist_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artist_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artist_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artist_versions_id_seq OWNED BY public.artist_versions.id;


--
-- Name: artists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.artists (
    id integer NOT NULL,
    name character varying NOT NULL,
    creator_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    other_names text[] DEFAULT '{}'::text[] NOT NULL,
    linked_user_id integer,
    is_locked boolean DEFAULT false
);


--
-- Name: artists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.artists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: artists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.artists_id_seq OWNED BY public.artists.id;


--
-- Name: bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bans (
    id integer NOT NULL,
    user_id integer NOT NULL,
    reason text NOT NULL,
    banner_id integer NOT NULL,
    expires_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bans_id_seq OWNED BY public.bans.id;


--
-- Name: bulk_update_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.bulk_update_requests (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    forum_topic_id integer,
    script text NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    approver_id integer,
    forum_post_id integer,
    title text,
    creator_ip_addr inet DEFAULT '127.0.0.1'::inet NOT NULL
);


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.bulk_update_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: bulk_update_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.bulk_update_requests_id_seq OWNED BY public.bulk_update_requests.id;


--
-- Name: comment_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comment_votes (
    id integer NOT NULL,
    comment_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_ip_addr inet
);


--
-- Name: comment_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comment_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comment_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comment_votes_id_seq OWNED BY public.comment_votes.id;


--
-- Name: comments; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.comments (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    body text NOT NULL,
    creator_ip_addr inet NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updater_id integer,
    updater_ip_addr inet,
    do_not_bump_post boolean DEFAULT false NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    warning_type integer,
    warning_user_id integer
);


--
-- Name: comments_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.comments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: comments_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.comments_id_seq OWNED BY public.comments.id;


--
-- Name: destroyed_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.destroyed_posts (
    id bigint NOT NULL,
    post_id integer NOT NULL,
    md5 character varying NOT NULL,
    destroyer_id integer NOT NULL,
    destroyer_ip_addr inet NOT NULL,
    uploader_id integer,
    uploader_ip_addr inet,
    upload_date timestamp without time zone,
    post_data json NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: destroyed_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.destroyed_posts_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: destroyed_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.destroyed_posts_id_seq OWNED BY public.destroyed_posts.id;


--
-- Name: dmail_filters; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dmail_filters (
    id integer NOT NULL,
    user_id integer NOT NULL,
    words text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: dmail_filters_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dmail_filters_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmail_filters_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dmail_filters_id_seq OWNED BY public.dmail_filters.id;


--
-- Name: dmails; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.dmails (
    id integer NOT NULL,
    owner_id integer NOT NULL,
    from_id integer NOT NULL,
    to_id integer NOT NULL,
    title text NOT NULL,
    body text NOT NULL,
    is_read boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    creator_ip_addr inet NOT NULL,
    key character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: dmails_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.dmails_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: dmails_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.dmails_id_seq OWNED BY public.dmails.id;


--
-- Name: edit_histories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.edit_histories (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    body text NOT NULL,
    subject text,
    versionable_type character varying(100) NOT NULL,
    versionable_id integer NOT NULL,
    version integer NOT NULL,
    ip_addr inet NOT NULL,
    user_id integer NOT NULL,
    edit_type text DEFAULT 'original'::text NOT NULL
);


--
-- Name: edit_histories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.edit_histories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: edit_histories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.edit_histories_id_seq OWNED BY public.edit_histories.id;


--
-- Name: email_blacklists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.email_blacklists (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    domain character varying NOT NULL,
    creator_id integer NOT NULL,
    reason character varying NOT NULL
);


--
-- Name: email_blacklists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.email_blacklists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: email_blacklists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.email_blacklists_id_seq OWNED BY public.email_blacklists.id;


--
-- Name: exception_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.exception_logs (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    class_name character varying NOT NULL,
    ip_addr inet NOT NULL,
    version character varying NOT NULL,
    extra_params text,
    message text NOT NULL,
    trace text NOT NULL,
    code uuid NOT NULL,
    user_id integer
);


--
-- Name: exception_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.exception_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: exception_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.exception_logs_id_seq OWNED BY public.exception_logs.id;


--
-- Name: favorites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.favorites (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone DEFAULT now() NOT NULL
);


--
-- Name: favorites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.favorites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: favorites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.favorites_id_seq OWNED BY public.favorites.id;


--
-- Name: forum_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_categories (
    id bigint NOT NULL,
    name character varying NOT NULL,
    "order" integer NOT NULL,
    can_view integer DEFAULT 0 NOT NULL,
    can_create integer DEFAULT 10 NOT NULL
);


--
-- Name: forum_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_categories_id_seq OWNED BY public.forum_categories.id;


--
-- Name: forum_post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_post_votes (
    id bigint NOT NULL,
    forum_post_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_ip_addr inet NOT NULL
);


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_post_votes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_post_votes_id_seq OWNED BY public.forum_post_votes.id;


--
-- Name: forum_posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_posts (
    id integer NOT NULL,
    topic_id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    body text NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    creator_ip_addr inet,
    warning_type integer,
    warning_user_id integer,
    tag_change_request_id bigint,
    tag_change_request_type character varying
);


--
-- Name: forum_posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_posts_id_seq OWNED BY public.forum_posts.id;


--
-- Name: forum_subscriptions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_subscriptions (
    id integer NOT NULL,
    user_id integer,
    forum_topic_id integer,
    last_read_at timestamp without time zone,
    delete_key character varying
);


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_subscriptions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_subscriptions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_subscriptions_id_seq OWNED BY public.forum_subscriptions.id;


--
-- Name: forum_topic_visits; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topic_visits (
    id integer NOT NULL,
    user_id integer,
    forum_topic_id integer,
    last_read_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topic_visits_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topic_visits_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topic_visits_id_seq OWNED BY public.forum_topic_visits.id;


--
-- Name: forum_topics; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.forum_topics (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    title character varying NOT NULL,
    response_count integer DEFAULT 0 NOT NULL,
    is_sticky boolean DEFAULT false NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category_id integer DEFAULT 0 NOT NULL,
    creator_ip_addr inet NOT NULL
);


--
-- Name: forum_topics_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.forum_topics_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: forum_topics_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.forum_topics_id_seq OWNED BY public.forum_topics.id;


--
-- Name: help_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.help_pages (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    name character varying NOT NULL,
    wiki_page character varying NOT NULL,
    related character varying DEFAULT ''::character varying NOT NULL,
    title character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: help_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.help_pages_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: help_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.help_pages_id_seq OWNED BY public.help_pages.id;


--
-- Name: ip_bans; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.ip_bans (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    ip_addr inet NOT NULL,
    reason text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: ip_bans_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.ip_bans_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: ip_bans_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.ip_bans_id_seq OWNED BY public.ip_bans.id;


--
-- Name: mascots; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mascots (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    display_name character varying NOT NULL,
    md5 character varying NOT NULL,
    file_ext character varying NOT NULL,
    background_color character varying NOT NULL,
    artist_url character varying NOT NULL,
    artist_name character varying NOT NULL,
    active boolean DEFAULT true NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    available_on character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    hide_anonymous boolean DEFAULT false NOT NULL
);


--
-- Name: mascots_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mascots_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mascots_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mascots_id_seq OWNED BY public.mascots.id;


--
-- Name: mod_actions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.mod_actions (
    id integer NOT NULL,
    creator_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    action text,
    "values" json,
    subject_id integer,
    subject_type character varying
);


--
-- Name: mod_actions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.mod_actions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: mod_actions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.mod_actions_id_seq OWNED BY public.mod_actions.id;


--
-- Name: news_updates; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.news_updates (
    id integer NOT NULL,
    message text NOT NULL,
    creator_id integer NOT NULL,
    updater_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: news_updates_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.news_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: news_updates_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.news_updates_id_seq OWNED BY public.news_updates.id;


--
-- Name: note_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.note_versions (
    id integer NOT NULL,
    note_id integer NOT NULL,
    post_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version integer NOT NULL
);


--
-- Name: note_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.note_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: note_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.note_versions_id_seq OWNED BY public.note_versions.id;


--
-- Name: notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.notes (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    post_id integer NOT NULL,
    x integer NOT NULL,
    y integer NOT NULL,
    width integer NOT NULL,
    height integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    version integer DEFAULT 0 NOT NULL
);


--
-- Name: notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.notes_id_seq OWNED BY public.notes.id;


--
-- Name: pool_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pool_versions (
    id bigint NOT NULL,
    pool_id integer NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    added_post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    removed_post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    updater_id integer,
    updater_ip_addr inet,
    description text,
    description_changed boolean DEFAULT false NOT NULL,
    name text,
    name_changed boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    category character varying,
    version integer DEFAULT 1 NOT NULL
);


--
-- Name: pool_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pool_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pool_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pool_versions_id_seq OWNED BY public.pool_versions.id;


--
-- Name: pools; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.pools (
    id integer NOT NULL,
    name character varying NOT NULL,
    creator_id integer NOT NULL,
    description text,
    is_active boolean DEFAULT true NOT NULL,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category character varying DEFAULT 'series'::character varying NOT NULL
);


--
-- Name: pools_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.pools_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: pools_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.pools_id_seq OWNED BY public.pools.id;


--
-- Name: post_approvals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_approvals (
    id integer NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_approvals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_approvals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_approvals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_approvals_id_seq OWNED BY public.post_approvals.id;


--
-- Name: post_deletion_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_deletion_reasons (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    reason character varying NOT NULL,
    title character varying,
    prompt character varying,
    "order" integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: post_deletion_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_deletion_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_deletion_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_deletion_reasons_id_seq OWNED BY public.post_deletion_reasons.id;


--
-- Name: post_disapprovals; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_disapprovals (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    post_id integer NOT NULL,
    reason character varying DEFAULT 'legacy'::character varying,
    message text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_disapprovals_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_disapprovals_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_disapprovals_id_seq OWNED BY public.post_disapprovals.id;


--
-- Name: post_events; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_events (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    post_id bigint NOT NULL,
    action integer NOT NULL,
    extra_data jsonb NOT NULL,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: post_events_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_events_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_events_id_seq OWNED BY public.post_events.id;


--
-- Name: post_flags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_flags (
    id integer NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    reason text,
    is_resolved boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    is_deletion boolean DEFAULT false NOT NULL
);


--
-- Name: post_flags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_flags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_flags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_flags_id_seq OWNED BY public.post_flags.id;


--
-- Name: post_replacement_rejection_reasons; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_replacement_rejection_reasons (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    reason character varying NOT NULL,
    "order" integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: post_replacement_rejection_reasons_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_replacement_rejection_reasons_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_replacement_rejection_reasons_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_replacement_rejection_reasons_id_seq OWNED BY public.post_replacement_rejection_reasons.id;


--
-- Name: post_replacements; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_replacements (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    post_id integer NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    approver_id integer,
    file_ext character varying NOT NULL,
    file_size integer NOT NULL,
    image_height integer NOT NULL,
    image_width integer NOT NULL,
    md5 character varying NOT NULL,
    source character varying,
    file_name character varying,
    storage_id character varying NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    reason character varying NOT NULL,
    protected boolean DEFAULT false NOT NULL,
    uploader_id_on_approve integer,
    penalize_uploader_on_approve boolean,
    rejector_id bigint,
    rejection_reason character varying DEFAULT ''::character varying NOT NULL,
    previous_details jsonb
);


--
-- Name: post_replacements_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_replacements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_replacements_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_replacements_id_seq OWNED BY public.post_replacements.id;


--
-- Name: post_set_maintainers; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_set_maintainers (
    id bigint NOT NULL,
    post_set_id integer NOT NULL,
    user_id integer NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_set_maintainers_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_set_maintainers_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_set_maintainers_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_set_maintainers_id_seq OWNED BY public.post_set_maintainers.id;


--
-- Name: post_sets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_sets (
    id bigint NOT NULL,
    name character varying NOT NULL,
    shortname character varying NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    is_public boolean DEFAULT false NOT NULL,
    transfer_on_delete boolean DEFAULT false NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet,
    post_ids integer[] DEFAULT '{}'::integer[] NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: post_sets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_sets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_sets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_sets_id_seq OWNED BY public.post_sets.id;


--
-- Name: post_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_versions (
    id bigint NOT NULL,
    post_id integer NOT NULL,
    tags text NOT NULL,
    added_tags text[] DEFAULT '{}'::text[] NOT NULL,
    removed_tags text[] DEFAULT '{}'::text[] NOT NULL,
    locked_tags text,
    added_locked_tags text[] DEFAULT '{}'::text[] NOT NULL,
    removed_locked_tags text[] DEFAULT '{}'::text[] NOT NULL,
    updater_id integer,
    updater_ip_addr inet NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    rating character varying(1),
    rating_changed boolean DEFAULT false NOT NULL,
    parent_id integer,
    parent_changed boolean DEFAULT false NOT NULL,
    source text,
    source_changed boolean DEFAULT false NOT NULL,
    description text,
    description_changed boolean DEFAULT false NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    reason character varying,
    original_tags text DEFAULT ''::text NOT NULL
);


--
-- Name: post_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_versions_id_seq OWNED BY public.post_versions.id;


--
-- Name: post_votes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.post_votes (
    id integer NOT NULL,
    post_id integer NOT NULL,
    user_id integer NOT NULL,
    score integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_ip_addr inet
);


--
-- Name: post_votes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.post_votes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: post_votes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.post_votes_id_seq OWNED BY public.post_votes.id;


--
-- Name: posts; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.posts (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    up_score integer DEFAULT 0 NOT NULL,
    down_score integer DEFAULT 0 NOT NULL,
    score integer DEFAULT 0 NOT NULL,
    source character varying NOT NULL,
    md5 character varying NOT NULL,
    rating character(1) DEFAULT 'q'::bpchar NOT NULL,
    is_note_locked boolean DEFAULT false NOT NULL,
    is_rating_locked boolean DEFAULT false NOT NULL,
    is_status_locked boolean DEFAULT false NOT NULL,
    is_pending boolean DEFAULT false NOT NULL,
    is_flagged boolean DEFAULT false NOT NULL,
    is_deleted boolean DEFAULT false NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    approver_id integer,
    fav_string text DEFAULT ''::text NOT NULL,
    pool_string text DEFAULT ''::text NOT NULL,
    last_noted_at timestamp without time zone,
    last_comment_bumped_at timestamp without time zone,
    fav_count integer DEFAULT 0 NOT NULL,
    tag_string text DEFAULT ''::text NOT NULL,
    tag_count integer DEFAULT 0 NOT NULL,
    tag_count_general integer DEFAULT 0 NOT NULL,
    tag_count_artist integer DEFAULT 0 NOT NULL,
    tag_count_character integer DEFAULT 0 NOT NULL,
    tag_count_copyright integer DEFAULT 0 NOT NULL,
    file_ext character varying NOT NULL,
    file_size integer NOT NULL,
    image_width integer NOT NULL,
    image_height integer NOT NULL,
    parent_id integer,
    has_children boolean DEFAULT false NOT NULL,
    last_commented_at timestamp without time zone,
    has_active_children boolean DEFAULT false NOT NULL,
    bit_flags bigint DEFAULT 0 NOT NULL,
    tag_count_meta integer DEFAULT 0 NOT NULL,
    locked_tags text,
    tag_count_species integer DEFAULT 0 NOT NULL,
    tag_count_invalid integer DEFAULT 0 NOT NULL,
    description text DEFAULT ''::text NOT NULL,
    comment_count integer DEFAULT 0 NOT NULL,
    change_seq bigint NOT NULL,
    tag_count_lore integer DEFAULT 0 NOT NULL,
    bg_color character varying,
    generated_samples character varying[],
    duration numeric,
    is_comment_disabled boolean DEFAULT false NOT NULL,
    original_tag_string text DEFAULT ''::text NOT NULL,
    is_comment_locked boolean DEFAULT false NOT NULL,
    tag_count_voice_actor integer DEFAULT 0 NOT NULL
);


--
-- Name: posts_change_seq_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_change_seq_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_change_seq_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_change_seq_seq OWNED BY public.posts.change_seq;


--
-- Name: posts_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.posts_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: posts_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.posts_id_seq OWNED BY public.posts.id;


--
-- Name: quick_rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quick_rules (
    id bigint NOT NULL,
    rule_id bigint,
    reason character varying NOT NULL,
    header character varying,
    "order" integer NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: quick_rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quick_rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quick_rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quick_rules_id_seq OWNED BY public.quick_rules.id;


--
-- Name: rule_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rule_categories (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    updater_id bigint NOT NULL,
    name character varying NOT NULL,
    "order" integer NOT NULL,
    anchor character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rule_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rule_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rule_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rule_categories_id_seq OWNED BY public.rule_categories.id;


--
-- Name: rules; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rules (
    id bigint NOT NULL,
    creator_id bigint NOT NULL,
    updater_id bigint NOT NULL,
    category_id bigint NOT NULL,
    name character varying NOT NULL,
    description text NOT NULL,
    "order" integer NOT NULL,
    anchor character varying NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: rules_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rules_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rules_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rules_id_seq OWNED BY public.rules.id;


--
-- Name: schema_migrations; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.schema_migrations (
    version character varying NOT NULL
);


--
-- Name: staff_audit_logs; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_audit_logs (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    action character varying DEFAULT 'unknown_action'::character varying NOT NULL,
    "values" json
);


--
-- Name: staff_audit_logs_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staff_audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staff_audit_logs_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staff_audit_logs_id_seq OWNED BY public.staff_audit_logs.id;


--
-- Name: staff_notes; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.staff_notes (
    id bigint NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL,
    user_id bigint NOT NULL,
    creator_id integer NOT NULL,
    body character varying,
    is_deleted boolean DEFAULT false NOT NULL,
    updater_id bigint NOT NULL
);


--
-- Name: staff_notes_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.staff_notes_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: staff_notes_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.staff_notes_id_seq OWNED BY public.staff_notes.id;


--
-- Name: tag_aliases; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_aliases (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    post_count integer DEFAULT 0 NOT NULL,
    approver_id integer,
    forum_post_id integer,
    reason text DEFAULT ''::text NOT NULL
);


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_aliases_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_aliases_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_aliases_id_seq OWNED BY public.tag_aliases.id;


--
-- Name: tag_implications; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_implications (
    id integer NOT NULL,
    antecedent_name character varying NOT NULL,
    consequent_name character varying NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    forum_topic_id integer,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp without time zone,
    updated_at timestamp without time zone,
    approver_id integer,
    forum_post_id integer,
    descendant_names text[] DEFAULT '{}'::text[],
    reason text DEFAULT ''::text NOT NULL
);


--
-- Name: tag_implications_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_implications_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_implications_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_implications_id_seq OWNED BY public.tag_implications.id;


--
-- Name: tag_rel_undos; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_rel_undos (
    id bigint NOT NULL,
    tag_rel_type character varying,
    tag_rel_id bigint,
    undo_data json,
    applied boolean DEFAULT false,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: tag_rel_undos_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_rel_undos_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_rel_undos_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_rel_undos_id_seq OWNED BY public.tag_rel_undos.id;


--
-- Name: tag_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tag_versions (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    category integer NOT NULL,
    is_locked boolean NOT NULL,
    tag_id integer NOT NULL,
    updater_id integer NOT NULL,
    reason character varying DEFAULT ''::character varying NOT NULL
);


--
-- Name: tag_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tag_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tag_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tag_versions_id_seq OWNED BY public.tag_versions.id;


--
-- Name: tags; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tags (
    id integer NOT NULL,
    name character varying NOT NULL,
    post_count integer DEFAULT 0 NOT NULL,
    category smallint DEFAULT 0 NOT NULL,
    related_tags text,
    related_tags_updated_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    is_locked boolean DEFAULT false NOT NULL
);


--
-- Name: tags_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tags_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tags_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tags_id_seq OWNED BY public.tags.id;


--
-- Name: takedowns; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.takedowns (
    id bigint NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    creator_id integer,
    creator_ip_addr inet NOT NULL,
    approver_id integer,
    status character varying DEFAULT 'pending'::character varying,
    vericode character varying NOT NULL,
    source character varying,
    email character varying,
    reason text,
    reason_hidden boolean DEFAULT false NOT NULL,
    notes text DEFAULT 'none'::text NOT NULL,
    instructions text,
    post_ids text DEFAULT ''::text,
    del_post_ids text DEFAULT ''::text,
    post_count integer DEFAULT 0 NOT NULL
);


--
-- Name: takedowns_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.takedowns_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: takedowns_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.takedowns_id_seq OWNED BY public.takedowns.id;


--
-- Name: tickets; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.tickets (
    id bigint NOT NULL,
    creator_id integer NOT NULL,
    creator_ip_addr inet NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    reason character varying,
    response character varying DEFAULT ''::character varying NOT NULL,
    handler_id integer DEFAULT 0 NOT NULL,
    claimant_id integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    accused_id integer,
    model_type character varying NOT NULL,
    model_id integer NOT NULL,
    report_type character varying DEFAULT 'report'::character varying NOT NULL
);


--
-- Name: tickets_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.tickets_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: tickets_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.tickets_id_seq OWNED BY public.tickets.id;


--
-- Name: upload_whitelists; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.upload_whitelists (
    id bigint NOT NULL,
    pattern character varying NOT NULL,
    note character varying,
    reason character varying,
    allowed boolean DEFAULT true NOT NULL,
    hidden boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: upload_whitelists_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.upload_whitelists_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: upload_whitelists_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.upload_whitelists_id_seq OWNED BY public.upload_whitelists.id;


--
-- Name: uploads; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.uploads (
    id integer NOT NULL,
    source text,
    rating character(1) NOT NULL,
    uploader_id integer NOT NULL,
    uploader_ip_addr inet NOT NULL,
    tag_string text NOT NULL,
    status text DEFAULT 'pending'::text NOT NULL,
    backtrace text,
    post_id integer,
    md5_confirmation character varying,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    parent_id integer,
    md5 character varying,
    file_ext character varying,
    file_size integer,
    image_width integer,
    image_height integer,
    description text DEFAULT ''::text NOT NULL
);


--
-- Name: uploads_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.uploads_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: uploads_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.uploads_id_seq OWNED BY public.uploads.id;


--
-- Name: user_blocks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_blocks (
    id bigint NOT NULL,
    user_id bigint NOT NULL,
    target_id bigint NOT NULL,
    hide_uploads boolean DEFAULT false NOT NULL,
    hide_comments boolean DEFAULT false NOT NULL,
    hide_forum_topics boolean DEFAULT false NOT NULL,
    hide_forum_posts boolean DEFAULT false NOT NULL,
    disable_messages boolean DEFAULT false NOT NULL,
    created_at timestamp(6) without time zone NOT NULL,
    updated_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_blocks_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_blocks_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_blocks_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_blocks_id_seq OWNED BY public.user_blocks.id;


--
-- Name: user_feedback; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_feedback (
    id integer NOT NULL,
    user_id integer NOT NULL,
    creator_id integer NOT NULL,
    category character varying NOT NULL,
    body text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    creator_ip_addr inet,
    updater_id integer
);


--
-- Name: user_feedback_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_feedback_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_feedback_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_feedback_id_seq OWNED BY public.user_feedback.id;


--
-- Name: user_name_change_requests; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_name_change_requests (
    id integer NOT NULL,
    status character varying DEFAULT 'pending'::character varying NOT NULL,
    user_id integer NOT NULL,
    approver_id integer,
    original_name character varying,
    desired_name character varying,
    change_reason text,
    rejection_reason text,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL
);


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_name_change_requests_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_name_change_requests_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_name_change_requests_id_seq OWNED BY public.user_name_change_requests.id;


--
-- Name: user_password_reset_nonces; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_password_reset_nonces (
    id integer NOT NULL,
    key character varying NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    user_id integer NOT NULL
);


--
-- Name: user_password_reset_nonces_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_password_reset_nonces_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_password_reset_nonces_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_password_reset_nonces_id_seq OWNED BY public.user_password_reset_nonces.id;


--
-- Name: user_text_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_text_versions (
    id bigint NOT NULL,
    updater_id bigint NOT NULL,
    updater_ip_addr inet NOT NULL,
    user_id bigint NOT NULL,
    about_text character varying NOT NULL,
    artinfo_text character varying NOT NULL,
    blacklist_text character varying NOT NULL,
    version integer DEFAULT 1 NOT NULL,
    text_changes character varying[] DEFAULT '{}'::character varying[] NOT NULL,
    created_at timestamp(6) without time zone NOT NULL
);


--
-- Name: user_text_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_text_versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_text_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_text_versions_id_seq OWNED BY public.user_text_versions.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id integer NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone,
    name character varying NOT NULL,
    password_hash character varying NOT NULL,
    email character varying,
    email_verification_key character varying,
    level integer DEFAULT 10 NOT NULL,
    base_upload_limit integer DEFAULT 10 NOT NULL,
    last_logged_in_at timestamp without time zone,
    last_forum_read_at timestamp without time zone,
    recent_tags text,
    comment_threshold integer DEFAULT '-2'::integer NOT NULL,
    default_image_size character varying DEFAULT 'large'::character varying NOT NULL,
    favorite_tags text,
    blacklisted_tags text DEFAULT 'spoilers
guro
scat
furry -rating:s'::text,
    time_zone character varying DEFAULT 'Eastern Time (US & Canada)'::character varying NOT NULL,
    bcrypt_password_hash text,
    per_page integer DEFAULT 100 NOT NULL,
    custom_style text,
    bit_prefs bigint DEFAULT 0 NOT NULL,
    last_ip_addr inet,
    unread_dmail_count integer DEFAULT 0 NOT NULL,
    profile_about text DEFAULT ''::text NOT NULL,
    profile_artinfo text DEFAULT ''::text NOT NULL,
    avatar_id integer,
    post_count integer DEFAULT 0 NOT NULL,
    post_deleted_count integer DEFAULT 0 NOT NULL,
    post_update_count integer DEFAULT 0 NOT NULL,
    post_flag_count integer DEFAULT 0 NOT NULL,
    favorite_count integer DEFAULT 0 NOT NULL,
    wiki_update_count integer DEFAULT 0 NOT NULL,
    note_update_count integer DEFAULT 0 NOT NULL,
    forum_post_count integer DEFAULT 0 NOT NULL,
    comment_count integer DEFAULT 0 NOT NULL,
    pool_update_count integer DEFAULT 0 NOT NULL,
    set_count integer DEFAULT 0 NOT NULL,
    artist_update_count integer DEFAULT 0 NOT NULL,
    own_post_replaced_count integer DEFAULT 0 NOT NULL,
    own_post_replaced_penalize_count integer DEFAULT 0 NOT NULL,
    post_replacement_rejected_count integer DEFAULT 0 NOT NULL,
    ticket_count integer DEFAULT 0 NOT NULL
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: wiki_page_versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_page_versions (
    id integer NOT NULL,
    wiki_page_id integer NOT NULL,
    updater_id integer NOT NULL,
    updater_ip_addr inet NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    is_locked boolean NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    reason character varying,
    parent character varying
);


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_page_versions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_page_versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_page_versions_id_seq OWNED BY public.wiki_page_versions.id;


--
-- Name: wiki_pages; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.wiki_pages (
    id integer NOT NULL,
    creator_id integer NOT NULL,
    title character varying NOT NULL,
    body text NOT NULL,
    is_locked boolean DEFAULT false NOT NULL,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    updater_id integer,
    parent character varying
);


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.wiki_pages_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: wiki_pages_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.wiki_pages_id_seq OWNED BY public.wiki_pages.id;


--
-- Name: api_keys id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys ALTER COLUMN id SET DEFAULT nextval('public.api_keys_id_seq'::regclass);


--
-- Name: artist_urls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls ALTER COLUMN id SET DEFAULT nextval('public.artist_urls_id_seq'::regclass);


--
-- Name: artist_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions ALTER COLUMN id SET DEFAULT nextval('public.artist_versions_id_seq'::regclass);


--
-- Name: artists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists ALTER COLUMN id SET DEFAULT nextval('public.artists_id_seq'::regclass);


--
-- Name: bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans ALTER COLUMN id SET DEFAULT nextval('public.bans_id_seq'::regclass);


--
-- Name: bulk_update_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests ALTER COLUMN id SET DEFAULT nextval('public.bulk_update_requests_id_seq'::regclass);


--
-- Name: comment_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes ALTER COLUMN id SET DEFAULT nextval('public.comment_votes_id_seq'::regclass);


--
-- Name: comments id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments ALTER COLUMN id SET DEFAULT nextval('public.comments_id_seq'::regclass);


--
-- Name: destroyed_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destroyed_posts ALTER COLUMN id SET DEFAULT nextval('public.destroyed_posts_id_seq'::regclass);


--
-- Name: dmail_filters id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmail_filters ALTER COLUMN id SET DEFAULT nextval('public.dmail_filters_id_seq'::regclass);


--
-- Name: dmails id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails ALTER COLUMN id SET DEFAULT nextval('public.dmails_id_seq'::regclass);


--
-- Name: edit_histories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_histories ALTER COLUMN id SET DEFAULT nextval('public.edit_histories_id_seq'::regclass);


--
-- Name: email_blacklists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_blacklists ALTER COLUMN id SET DEFAULT nextval('public.email_blacklists_id_seq'::regclass);


--
-- Name: exception_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exception_logs ALTER COLUMN id SET DEFAULT nextval('public.exception_logs_id_seq'::regclass);


--
-- Name: favorites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites ALTER COLUMN id SET DEFAULT nextval('public.favorites_id_seq'::regclass);


--
-- Name: forum_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_categories ALTER COLUMN id SET DEFAULT nextval('public.forum_categories_id_seq'::regclass);


--
-- Name: forum_post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes ALTER COLUMN id SET DEFAULT nextval('public.forum_post_votes_id_seq'::regclass);


--
-- Name: forum_posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts ALTER COLUMN id SET DEFAULT nextval('public.forum_posts_id_seq'::regclass);


--
-- Name: forum_subscriptions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_subscriptions ALTER COLUMN id SET DEFAULT nextval('public.forum_subscriptions_id_seq'::regclass);


--
-- Name: forum_topic_visits id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits ALTER COLUMN id SET DEFAULT nextval('public.forum_topic_visits_id_seq'::regclass);


--
-- Name: forum_topics id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics ALTER COLUMN id SET DEFAULT nextval('public.forum_topics_id_seq'::regclass);


--
-- Name: help_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_pages ALTER COLUMN id SET DEFAULT nextval('public.help_pages_id_seq'::regclass);


--
-- Name: ip_bans id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans ALTER COLUMN id SET DEFAULT nextval('public.ip_bans_id_seq'::regclass);


--
-- Name: mascots id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mascots ALTER COLUMN id SET DEFAULT nextval('public.mascots_id_seq'::regclass);


--
-- Name: mod_actions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions ALTER COLUMN id SET DEFAULT nextval('public.mod_actions_id_seq'::regclass);


--
-- Name: news_updates id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates ALTER COLUMN id SET DEFAULT nextval('public.news_updates_id_seq'::regclass);


--
-- Name: note_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions ALTER COLUMN id SET DEFAULT nextval('public.note_versions_id_seq'::regclass);


--
-- Name: notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes ALTER COLUMN id SET DEFAULT nextval('public.notes_id_seq'::regclass);


--
-- Name: pool_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pool_versions ALTER COLUMN id SET DEFAULT nextval('public.pool_versions_id_seq'::regclass);


--
-- Name: pools id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools ALTER COLUMN id SET DEFAULT nextval('public.pools_id_seq'::regclass);


--
-- Name: post_approvals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals ALTER COLUMN id SET DEFAULT nextval('public.post_approvals_id_seq'::regclass);


--
-- Name: post_deletion_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_deletion_reasons ALTER COLUMN id SET DEFAULT nextval('public.post_deletion_reasons_id_seq'::regclass);


--
-- Name: post_disapprovals id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals ALTER COLUMN id SET DEFAULT nextval('public.post_disapprovals_id_seq'::regclass);


--
-- Name: post_events id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_events ALTER COLUMN id SET DEFAULT nextval('public.post_events_id_seq'::regclass);


--
-- Name: post_flags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags ALTER COLUMN id SET DEFAULT nextval('public.post_flags_id_seq'::regclass);


--
-- Name: post_replacement_rejection_reasons id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacement_rejection_reasons ALTER COLUMN id SET DEFAULT nextval('public.post_replacement_rejection_reasons_id_seq'::regclass);


--
-- Name: post_replacements id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements ALTER COLUMN id SET DEFAULT nextval('public.post_replacements_id_seq'::regclass);


--
-- Name: post_set_maintainers id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_set_maintainers ALTER COLUMN id SET DEFAULT nextval('public.post_set_maintainers_id_seq'::regclass);


--
-- Name: post_sets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_sets ALTER COLUMN id SET DEFAULT nextval('public.post_sets_id_seq'::regclass);


--
-- Name: post_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_versions ALTER COLUMN id SET DEFAULT nextval('public.post_versions_id_seq'::regclass);


--
-- Name: post_votes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes ALTER COLUMN id SET DEFAULT nextval('public.post_votes_id_seq'::regclass);


--
-- Name: posts id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN id SET DEFAULT nextval('public.posts_id_seq'::regclass);


--
-- Name: posts change_seq; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts ALTER COLUMN change_seq SET DEFAULT nextval('public.posts_change_seq_seq'::regclass);


--
-- Name: quick_rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_rules ALTER COLUMN id SET DEFAULT nextval('public.quick_rules_id_seq'::regclass);


--
-- Name: rule_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_categories ALTER COLUMN id SET DEFAULT nextval('public.rule_categories_id_seq'::regclass);


--
-- Name: rules id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules ALTER COLUMN id SET DEFAULT nextval('public.rules_id_seq'::regclass);


--
-- Name: staff_audit_logs id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_audit_logs ALTER COLUMN id SET DEFAULT nextval('public.staff_audit_logs_id_seq'::regclass);


--
-- Name: staff_notes id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_notes ALTER COLUMN id SET DEFAULT nextval('public.staff_notes_id_seq'::regclass);


--
-- Name: tag_aliases id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases ALTER COLUMN id SET DEFAULT nextval('public.tag_aliases_id_seq'::regclass);


--
-- Name: tag_implications id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications ALTER COLUMN id SET DEFAULT nextval('public.tag_implications_id_seq'::regclass);


--
-- Name: tag_rel_undos id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_rel_undos ALTER COLUMN id SET DEFAULT nextval('public.tag_rel_undos_id_seq'::regclass);


--
-- Name: tag_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_versions ALTER COLUMN id SET DEFAULT nextval('public.tag_versions_id_seq'::regclass);


--
-- Name: tags id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags ALTER COLUMN id SET DEFAULT nextval('public.tags_id_seq'::regclass);


--
-- Name: takedowns id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.takedowns ALTER COLUMN id SET DEFAULT nextval('public.takedowns_id_seq'::regclass);


--
-- Name: tickets id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets ALTER COLUMN id SET DEFAULT nextval('public.tickets_id_seq'::regclass);


--
-- Name: upload_whitelists id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_whitelists ALTER COLUMN id SET DEFAULT nextval('public.upload_whitelists_id_seq'::regclass);


--
-- Name: uploads id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads ALTER COLUMN id SET DEFAULT nextval('public.uploads_id_seq'::regclass);


--
-- Name: user_blocks id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_blocks ALTER COLUMN id SET DEFAULT nextval('public.user_blocks_id_seq'::regclass);


--
-- Name: user_feedback id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback ALTER COLUMN id SET DEFAULT nextval('public.user_feedback_id_seq'::regclass);


--
-- Name: user_name_change_requests id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests ALTER COLUMN id SET DEFAULT nextval('public.user_name_change_requests_id_seq'::regclass);


--
-- Name: user_password_reset_nonces id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password_reset_nonces ALTER COLUMN id SET DEFAULT nextval('public.user_password_reset_nonces_id_seq'::regclass);


--
-- Name: user_text_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_text_versions ALTER COLUMN id SET DEFAULT nextval('public.user_text_versions_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: wiki_page_versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions ALTER COLUMN id SET DEFAULT nextval('public.wiki_page_versions_id_seq'::regclass);


--
-- Name: wiki_pages id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages ALTER COLUMN id SET DEFAULT nextval('public.wiki_pages_id_seq'::regclass);


--
-- Name: api_keys api_keys_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.api_keys
    ADD CONSTRAINT api_keys_pkey PRIMARY KEY (id);


--
-- Name: ar_internal_metadata ar_internal_metadata_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ar_internal_metadata
    ADD CONSTRAINT ar_internal_metadata_pkey PRIMARY KEY (key);


--
-- Name: artist_urls artist_urls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_urls
    ADD CONSTRAINT artist_urls_pkey PRIMARY KEY (id);


--
-- Name: artist_versions artist_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artist_versions
    ADD CONSTRAINT artist_versions_pkey PRIMARY KEY (id);


--
-- Name: artists artists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (id);


--
-- Name: bans bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bans
    ADD CONSTRAINT bans_pkey PRIMARY KEY (id);


--
-- Name: bulk_update_requests bulk_update_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.bulk_update_requests
    ADD CONSTRAINT bulk_update_requests_pkey PRIMARY KEY (id);


--
-- Name: comment_votes comment_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comment_votes
    ADD CONSTRAINT comment_votes_pkey PRIMARY KEY (id);


--
-- Name: comments comments_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.comments
    ADD CONSTRAINT comments_pkey PRIMARY KEY (id);


--
-- Name: destroyed_posts destroyed_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.destroyed_posts
    ADD CONSTRAINT destroyed_posts_pkey PRIMARY KEY (id);


--
-- Name: dmail_filters dmail_filters_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmail_filters
    ADD CONSTRAINT dmail_filters_pkey PRIMARY KEY (id);


--
-- Name: dmails dmails_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.dmails
    ADD CONSTRAINT dmails_pkey PRIMARY KEY (id);


--
-- Name: edit_histories edit_histories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.edit_histories
    ADD CONSTRAINT edit_histories_pkey PRIMARY KEY (id);


--
-- Name: email_blacklists email_blacklists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.email_blacklists
    ADD CONSTRAINT email_blacklists_pkey PRIMARY KEY (id);


--
-- Name: exception_logs exception_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.exception_logs
    ADD CONSTRAINT exception_logs_pkey PRIMARY KEY (id);


--
-- Name: favorites favorites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT favorites_pkey PRIMARY KEY (id);


--
-- Name: forum_categories forum_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_categories
    ADD CONSTRAINT forum_categories_pkey PRIMARY KEY (id);


--
-- Name: forum_post_votes forum_post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_post_votes
    ADD CONSTRAINT forum_post_votes_pkey PRIMARY KEY (id);


--
-- Name: forum_posts forum_posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_posts
    ADD CONSTRAINT forum_posts_pkey PRIMARY KEY (id);


--
-- Name: forum_subscriptions forum_subscriptions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_subscriptions
    ADD CONSTRAINT forum_subscriptions_pkey PRIMARY KEY (id);


--
-- Name: forum_topic_visits forum_topic_visits_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topic_visits
    ADD CONSTRAINT forum_topic_visits_pkey PRIMARY KEY (id);


--
-- Name: forum_topics forum_topics_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.forum_topics
    ADD CONSTRAINT forum_topics_pkey PRIMARY KEY (id);


--
-- Name: help_pages help_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.help_pages
    ADD CONSTRAINT help_pages_pkey PRIMARY KEY (id);


--
-- Name: ip_bans ip_bans_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.ip_bans
    ADD CONSTRAINT ip_bans_pkey PRIMARY KEY (id);


--
-- Name: mascots mascots_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mascots
    ADD CONSTRAINT mascots_pkey PRIMARY KEY (id);


--
-- Name: mod_actions mod_actions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mod_actions
    ADD CONSTRAINT mod_actions_pkey PRIMARY KEY (id);


--
-- Name: news_updates news_updates_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.news_updates
    ADD CONSTRAINT news_updates_pkey PRIMARY KEY (id);


--
-- Name: note_versions note_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.note_versions
    ADD CONSTRAINT note_versions_pkey PRIMARY KEY (id);


--
-- Name: notes notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.notes
    ADD CONSTRAINT notes_pkey PRIMARY KEY (id);


--
-- Name: pool_versions pool_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pool_versions
    ADD CONSTRAINT pool_versions_pkey PRIMARY KEY (id);


--
-- Name: pools pools_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.pools
    ADD CONSTRAINT pools_pkey PRIMARY KEY (id);


--
-- Name: post_approvals post_approvals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_approvals
    ADD CONSTRAINT post_approvals_pkey PRIMARY KEY (id);


--
-- Name: post_deletion_reasons post_deletion_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_deletion_reasons
    ADD CONSTRAINT post_deletion_reasons_pkey PRIMARY KEY (id);


--
-- Name: post_disapprovals post_disapprovals_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_disapprovals
    ADD CONSTRAINT post_disapprovals_pkey PRIMARY KEY (id);


--
-- Name: post_events post_events_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_events
    ADD CONSTRAINT post_events_pkey PRIMARY KEY (id);


--
-- Name: post_flags post_flags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_flags
    ADD CONSTRAINT post_flags_pkey PRIMARY KEY (id);


--
-- Name: post_replacement_rejection_reasons post_replacement_rejection_reasons_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacement_rejection_reasons
    ADD CONSTRAINT post_replacement_rejection_reasons_pkey PRIMARY KEY (id);


--
-- Name: post_replacements post_replacements_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements
    ADD CONSTRAINT post_replacements_pkey PRIMARY KEY (id);


--
-- Name: post_set_maintainers post_set_maintainers_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_set_maintainers
    ADD CONSTRAINT post_set_maintainers_pkey PRIMARY KEY (id);


--
-- Name: post_sets post_sets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_sets
    ADD CONSTRAINT post_sets_pkey PRIMARY KEY (id);


--
-- Name: post_versions post_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_versions
    ADD CONSTRAINT post_versions_pkey PRIMARY KEY (id);

ALTER TABLE public.post_versions CLUSTER ON post_versions_pkey;


--
-- Name: post_votes post_votes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_votes
    ADD CONSTRAINT post_votes_pkey PRIMARY KEY (id);


--
-- Name: posts posts_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.posts
    ADD CONSTRAINT posts_pkey PRIMARY KEY (id);


--
-- Name: quick_rules quick_rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quick_rules
    ADD CONSTRAINT quick_rules_pkey PRIMARY KEY (id);


--
-- Name: rule_categories rule_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_categories
    ADD CONSTRAINT rule_categories_pkey PRIMARY KEY (id);


--
-- Name: rules rules_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT rules_pkey PRIMARY KEY (id);


--
-- Name: schema_migrations schema_migrations_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.schema_migrations
    ADD CONSTRAINT schema_migrations_pkey PRIMARY KEY (version);


--
-- Name: staff_audit_logs staff_audit_logs_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_audit_logs
    ADD CONSTRAINT staff_audit_logs_pkey PRIMARY KEY (id);


--
-- Name: staff_notes staff_notes_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_notes
    ADD CONSTRAINT staff_notes_pkey PRIMARY KEY (id);


--
-- Name: tag_aliases tag_aliases_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (id);


--
-- Name: tag_implications tag_implications_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_implications
    ADD CONSTRAINT tag_implications_pkey PRIMARY KEY (id);


--
-- Name: tag_rel_undos tag_rel_undos_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_rel_undos
    ADD CONSTRAINT tag_rel_undos_pkey PRIMARY KEY (id);


--
-- Name: tag_versions tag_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tag_versions
    ADD CONSTRAINT tag_versions_pkey PRIMARY KEY (id);


--
-- Name: tags tags_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (id);


--
-- Name: takedowns takedowns_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.takedowns
    ADD CONSTRAINT takedowns_pkey PRIMARY KEY (id);


--
-- Name: tickets tickets_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT tickets_pkey PRIMARY KEY (id);


--
-- Name: upload_whitelists upload_whitelists_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.upload_whitelists
    ADD CONSTRAINT upload_whitelists_pkey PRIMARY KEY (id);


--
-- Name: uploads uploads_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.uploads
    ADD CONSTRAINT uploads_pkey PRIMARY KEY (id);


--
-- Name: user_blocks user_blocks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT user_blocks_pkey PRIMARY KEY (id);


--
-- Name: user_feedback user_feedback_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT user_feedback_pkey PRIMARY KEY (id);


--
-- Name: user_name_change_requests user_name_change_requests_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_name_change_requests
    ADD CONSTRAINT user_name_change_requests_pkey PRIMARY KEY (id);


--
-- Name: user_password_reset_nonces user_password_reset_nonces_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_password_reset_nonces
    ADD CONSTRAINT user_password_reset_nonces_pkey PRIMARY KEY (id);


--
-- Name: user_text_versions user_text_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_text_versions
    ADD CONSTRAINT user_text_versions_pkey PRIMARY KEY (id);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: wiki_page_versions wiki_page_versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_page_versions
    ADD CONSTRAINT wiki_page_versions_pkey PRIMARY KEY (id);


--
-- Name: wiki_pages wiki_pages_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.wiki_pages
    ADD CONSTRAINT wiki_pages_pkey PRIMARY KEY (id);


--
-- Name: index_api_keys_on_key; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_api_keys_on_key ON public.api_keys USING btree (key);


--
-- Name: index_artist_urls_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_artist_id ON public.artist_urls USING btree (artist_id);


--
-- Name: index_artist_urls_on_normalized_url_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_pattern ON public.artist_urls USING btree (normalized_url text_pattern_ops);


--
-- Name: index_artist_urls_on_normalized_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_normalized_url_trgm ON public.artist_urls USING gin (normalized_url public.gin_trgm_ops);


--
-- Name: index_artist_urls_on_url_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_urls_on_url_trgm ON public.artist_urls USING gin (url public.gin_trgm_ops);


--
-- Name: index_artist_versions_on_artist_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_artist_id ON public.artist_versions USING btree (artist_id);


--
-- Name: index_artist_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_created_at ON public.artist_versions USING btree (created_at);


--
-- Name: index_artist_versions_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_name ON public.artist_versions USING btree (name);


--
-- Name: index_artist_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_id ON public.artist_versions USING btree (updater_id);


--
-- Name: index_artist_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artist_versions_on_updater_ip_addr ON public.artist_versions USING btree (updater_ip_addr);


--
-- Name: index_artists_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_artists_on_name ON public.artists USING btree (name);


--
-- Name: index_artists_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_name_trgm ON public.artists USING gin (name public.gin_trgm_ops);


--
-- Name: index_artists_on_other_names; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_artists_on_other_names ON public.artists USING gin (other_names);


--
-- Name: index_bans_on_banner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_banner_id ON public.bans USING btree (banner_id);


--
-- Name: index_bans_on_expires_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_expires_at ON public.bans USING btree (expires_at);


--
-- Name: index_bans_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bans_on_user_id ON public.bans USING btree (user_id);


--
-- Name: index_bulk_update_requests_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_bulk_update_requests_on_forum_post_id ON public.bulk_update_requests USING btree (forum_post_id);


--
-- Name: index_comment_votes_on_comment_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_comment_id ON public.comment_votes USING btree (comment_id);


--
-- Name: index_comment_votes_on_comment_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_comment_votes_on_comment_id_and_user_id ON public.comment_votes USING btree (comment_id, user_id);


--
-- Name: index_comment_votes_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_created_at ON public.comment_votes USING btree (created_at);


--
-- Name: index_comment_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comment_votes_on_user_id ON public.comment_votes USING btree (user_id);


--
-- Name: index_comments_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_id ON public.comments USING btree (creator_id);


--
-- Name: index_comments_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_id_and_post_id ON public.comments USING btree (creator_id, post_id);


--
-- Name: index_comments_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_creator_ip_addr ON public.comments USING btree (creator_ip_addr);


--
-- Name: index_comments_on_lower_body_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_lower_body_trgm ON public.comments USING gin (lower(body) public.gin_trgm_ops);


--
-- Name: index_comments_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_post_id ON public.comments USING btree (post_id);


--
-- Name: index_comments_on_to_tsvector_english_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_comments_on_to_tsvector_english_body ON public.comments USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_dmail_filters_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_dmail_filters_on_user_id ON public.dmail_filters USING btree (user_id);


--
-- Name: index_dmails_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_creator_ip_addr ON public.dmails USING btree (creator_ip_addr);


--
-- Name: index_dmails_on_is_deleted; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_deleted ON public.dmails USING btree (is_deleted);


--
-- Name: index_dmails_on_is_read; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_is_read ON public.dmails USING btree (is_read);


--
-- Name: index_dmails_on_lower_body_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_lower_body_trgm ON public.dmails USING gin (lower(body) public.gin_trgm_ops);


--
-- Name: index_dmails_on_owner_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_owner_id ON public.dmails USING btree (owner_id);


--
-- Name: index_dmails_on_to_tsvector_english_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_dmails_on_to_tsvector_english_body ON public.dmails USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_edit_histories_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_edit_histories_on_user_id ON public.edit_histories USING btree (user_id);


--
-- Name: index_edit_histories_on_versionable_id_and_versionable_type; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_edit_histories_on_versionable_id_and_versionable_type ON public.edit_histories USING btree (versionable_id, versionable_type);


--
-- Name: index_favorites_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_post_id ON public.favorites USING btree (post_id);


--
-- Name: index_favorites_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_favorites_on_user_id ON public.favorites USING btree (user_id);


--
-- Name: index_favorites_on_user_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_favorites_on_user_id_and_post_id ON public.favorites USING btree (user_id, post_id);


--
-- Name: index_forum_post_votes_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_post_votes_on_forum_post_id ON public.forum_post_votes USING btree (forum_post_id);


--
-- Name: index_forum_post_votes_on_forum_post_id_and_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_forum_post_votes_on_forum_post_id_and_user_id ON public.forum_post_votes USING btree (forum_post_id, user_id);


--
-- Name: index_forum_posts_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_creator_id ON public.forum_posts USING btree (creator_id);


--
-- Name: index_forum_posts_on_lower_body_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_lower_body_trgm ON public.forum_posts USING gin (lower(body) public.gin_trgm_ops);


--
-- Name: index_forum_posts_on_to_tsvector_english_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_to_tsvector_english_body ON public.forum_posts USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_forum_posts_on_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_posts_on_topic_id ON public.forum_posts USING btree (topic_id);


--
-- Name: index_forum_subscriptions_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_subscriptions_on_forum_topic_id ON public.forum_subscriptions USING btree (forum_topic_id);


--
-- Name: index_forum_subscriptions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_subscriptions_on_user_id ON public.forum_subscriptions USING btree (user_id);


--
-- Name: index_forum_topic_visits_on_forum_topic_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_forum_topic_id ON public.forum_topic_visits USING btree (forum_topic_id);


--
-- Name: index_forum_topic_visits_on_last_read_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_last_read_at ON public.forum_topic_visits USING btree (last_read_at);


--
-- Name: index_forum_topic_visits_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topic_visits_on_user_id ON public.forum_topic_visits USING btree (user_id);


--
-- Name: index_forum_topics_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_creator_id ON public.forum_topics USING btree (creator_id);


--
-- Name: index_forum_topics_on_is_sticky_and_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_is_sticky_and_updated_at ON public.forum_topics USING btree (is_sticky, updated_at);


--
-- Name: index_forum_topics_on_lower_title_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_lower_title_trgm ON public.forum_topics USING gin (lower((title)::text) public.gin_trgm_ops);


--
-- Name: index_forum_topics_on_to_tsvector_english_title; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_to_tsvector_english_title ON public.forum_topics USING gin (to_tsvector('english'::regconfig, (title)::text));


--
-- Name: index_forum_topics_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_forum_topics_on_updated_at ON public.forum_topics USING btree (updated_at);


--
-- Name: index_ip_bans_on_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_ip_bans_on_ip_addr ON public.ip_bans USING btree (ip_addr);


--
-- Name: index_mascots_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mascots_on_creator_id ON public.mascots USING btree (creator_id);


--
-- Name: index_mascots_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_mascots_on_md5 ON public.mascots USING btree (md5);


--
-- Name: index_mod_actions_on_action; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_mod_actions_on_action ON public.mod_actions USING btree (action);


--
-- Name: index_news_updates_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_news_updates_on_created_at ON public.news_updates USING btree (created_at);


--
-- Name: index_note_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_created_at ON public.note_versions USING btree (created_at);


--
-- Name: index_note_versions_on_note_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_note_id ON public.note_versions USING btree (note_id);


--
-- Name: index_note_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_post_id ON public.note_versions USING btree (post_id);


--
-- Name: index_note_versions_on_updater_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_id_and_post_id ON public.note_versions USING btree (updater_id, post_id);


--
-- Name: index_note_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_note_versions_on_updater_ip_addr ON public.note_versions USING btree (updater_ip_addr);


--
-- Name: index_notes_on_creator_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_creator_id_and_post_id ON public.notes USING btree (creator_id, post_id);


--
-- Name: index_notes_on_lower_body_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_lower_body_trgm ON public.notes USING gin (lower(body) public.gin_trgm_ops);


--
-- Name: index_notes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_post_id ON public.notes USING btree (post_id);


--
-- Name: index_notes_on_to_tsvector_english_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_notes_on_to_tsvector_english_body ON public.notes USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_pool_versions_on_pool_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_pool_id ON public.pool_versions USING btree (pool_id);


--
-- Name: index_pool_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_updater_id ON public.pool_versions USING btree (updater_id);


--
-- Name: index_pool_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pool_versions_on_updater_ip_addr ON public.pool_versions USING btree (updater_ip_addr);


--
-- Name: index_pools_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_creator_id ON public.pools USING btree (creator_id);


--
-- Name: index_pools_on_lower_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_lower_name ON public.pools USING btree (lower((name)::text));


--
-- Name: index_pools_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name ON public.pools USING btree (name);


--
-- Name: index_pools_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_name_trgm ON public.pools USING gin (lower((name)::text) public.gin_trgm_ops);


--
-- Name: index_pools_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_pools_on_updated_at ON public.pools USING btree (updated_at);


--
-- Name: index_post_approvals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_post_id ON public.post_approvals USING btree (post_id);


--
-- Name: index_post_approvals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_approvals_on_user_id ON public.post_approvals USING btree (user_id);


--
-- Name: index_post_deletion_reasons_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_deletion_reasons_on_creator_id ON public.post_deletion_reasons USING btree (creator_id);


--
-- Name: index_post_disapprovals_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_post_id ON public.post_disapprovals USING btree (post_id);


--
-- Name: index_post_disapprovals_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_disapprovals_on_user_id ON public.post_disapprovals USING btree (user_id);


--
-- Name: index_post_events_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_events_on_creator_id ON public.post_events USING btree (creator_id);


--
-- Name: index_post_events_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_events_on_post_id ON public.post_events USING btree (post_id);


--
-- Name: index_post_flags_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_id ON public.post_flags USING btree (creator_id);


--
-- Name: index_post_flags_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_creator_ip_addr ON public.post_flags USING btree (creator_ip_addr);


--
-- Name: index_post_flags_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_post_id ON public.post_flags USING btree (post_id);


--
-- Name: index_post_flags_on_reason_tsvector; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_flags_on_reason_tsvector ON public.post_flags USING gin (to_tsvector('english'::regconfig, reason));


--
-- Name: index_post_replacement_rejection_reasons_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacement_rejection_reasons_on_creator_id ON public.post_replacement_rejection_reasons USING btree (creator_id);


--
-- Name: index_post_replacements_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_creator_id ON public.post_replacements USING btree (creator_id);


--
-- Name: index_post_replacements_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_post_id ON public.post_replacements USING btree (post_id);


--
-- Name: index_post_replacements_on_rejector_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_replacements_on_rejector_id ON public.post_replacements USING btree (rejector_id);


--
-- Name: index_post_sets_on_post_ids; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_sets_on_post_ids ON public.post_sets USING gin (post_ids);


--
-- Name: index_post_versions_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_post_id ON public.post_versions USING btree (post_id);


--
-- Name: index_post_versions_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_updated_at ON public.post_versions USING btree (updated_at);


--
-- Name: index_post_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_updater_id ON public.post_versions USING btree (updater_id);


--
-- Name: index_post_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_versions_on_updater_ip_addr ON public.post_versions USING btree (updater_ip_addr);


--
-- Name: index_post_votes_on_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_post_id ON public.post_votes USING btree (post_id);


--
-- Name: index_post_votes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_post_votes_on_user_id ON public.post_votes USING btree (user_id);


--
-- Name: index_post_votes_on_user_id_and_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_post_votes_on_user_id_and_post_id ON public.post_votes USING btree (user_id, post_id);


--
-- Name: index_posts_on_change_seq; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_change_seq ON public.posts USING btree (change_seq);


--
-- Name: index_posts_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_created_at ON public.posts USING btree (created_at);


--
-- Name: index_posts_on_is_flagged; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_flagged ON public.posts USING btree (is_flagged) WHERE (is_flagged = true);


--
-- Name: index_posts_on_is_pending; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_is_pending ON public.posts USING btree (is_pending) WHERE (is_pending = true);


--
-- Name: index_posts_on_md5; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_posts_on_md5 ON public.posts USING btree (md5);


--
-- Name: index_posts_on_parent_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_parent_id ON public.posts USING btree (parent_id);


--
-- Name: index_posts_on_string_to_array_tag_string; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_string_to_array_tag_string ON public.posts USING gin (string_to_array(tag_string, ' '::text));
ALTER INDEX public.index_posts_on_string_to_array_tag_string ALTER COLUMN 1 SET STATISTICS 3000;


--
-- Name: index_posts_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_id ON public.posts USING btree (uploader_id);


--
-- Name: index_posts_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_posts_on_uploader_ip_addr ON public.posts USING btree (uploader_ip_addr);


--
-- Name: index_quick_rules_on_rule_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_quick_rules_on_rule_id ON public.quick_rules USING btree (rule_id);


--
-- Name: index_rule_categories_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_categories_on_creator_id ON public.rule_categories USING btree (creator_id);


--
-- Name: index_rule_categories_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rule_categories_on_updater_id ON public.rule_categories USING btree (updater_id);


--
-- Name: index_rules_on_category_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rules_on_category_id ON public.rules USING btree (category_id);


--
-- Name: index_rules_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rules_on_creator_id ON public.rules USING btree (creator_id);


--
-- Name: index_rules_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_rules_on_updater_id ON public.rules USING btree (updater_id);


--
-- Name: index_staff_audit_logs_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_audit_logs_on_user_id ON public.staff_audit_logs USING btree (user_id);


--
-- Name: index_staff_notes_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_notes_on_creator_id ON public.staff_notes USING btree (creator_id);


--
-- Name: index_staff_notes_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_notes_on_updater_id ON public.staff_notes USING btree (updater_id);


--
-- Name: index_staff_notes_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_staff_notes_on_user_id ON public.staff_notes USING btree (user_id);


--
-- Name: index_tag_aliases_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name ON public.tag_aliases USING btree (antecedent_name);


--
-- Name: index_tag_aliases_on_antecedent_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_antecedent_name_pattern ON public.tag_aliases USING btree (antecedent_name text_pattern_ops);


--
-- Name: index_tag_aliases_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_consequent_name ON public.tag_aliases USING btree (consequent_name);


--
-- Name: index_tag_aliases_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_forum_post_id ON public.tag_aliases USING btree (forum_post_id);


--
-- Name: index_tag_aliases_on_post_count; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_aliases_on_post_count ON public.tag_aliases USING btree (post_count);


--
-- Name: index_tag_implications_on_antecedent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_antecedent_name ON public.tag_implications USING btree (antecedent_name);


--
-- Name: index_tag_implications_on_consequent_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_consequent_name ON public.tag_implications USING btree (consequent_name);


--
-- Name: index_tag_implications_on_forum_post_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_implications_on_forum_post_id ON public.tag_implications USING btree (forum_post_id);


--
-- Name: index_tag_rel_undos_on_tag_rel_type_and_tag_rel_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_rel_undos_on_tag_rel_type_and_tag_rel_id ON public.tag_rel_undos USING btree (tag_rel_type, tag_rel_id);


--
-- Name: index_tag_versions_on_tag_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_versions_on_tag_id ON public.tag_versions USING btree (tag_id);


--
-- Name: index_tag_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tag_versions_on_updater_id ON public.tag_versions USING btree (updater_id);


--
-- Name: index_tags_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_tags_on_name ON public.tags USING btree (name);


--
-- Name: index_tags_on_name_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_pattern ON public.tags USING btree (name text_pattern_ops);


--
-- Name: index_tags_on_name_prefix; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_prefix ON public.tags USING gin (regexp_replace((name)::text, '([a-z0-9])[a-z0-9'']*($|[^a-z0-9'']+)'::text, '\1'::text, 'g'::text) public.gin_trgm_ops);


--
-- Name: index_tags_on_name_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_tags_on_name_trgm ON public.tags USING gin (name public.gin_trgm_ops);


--
-- Name: index_uploads_on_source; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_source ON public.uploads USING btree (source);


--
-- Name: index_uploads_on_uploader_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_id ON public.uploads USING btree (uploader_id);


--
-- Name: index_uploads_on_uploader_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_uploads_on_uploader_ip_addr ON public.uploads USING btree (uploader_ip_addr);


--
-- Name: index_user_blocks_on_target_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_blocks_on_target_id ON public.user_blocks USING btree (target_id);


--
-- Name: index_user_blocks_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_blocks_on_user_id ON public.user_blocks USING btree (user_id);


--
-- Name: index_user_feedback_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_created_at ON public.user_feedback USING btree (created_at);


--
-- Name: index_user_feedback_on_creator_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_creator_id ON public.user_feedback USING btree (creator_id);


--
-- Name: index_user_feedback_on_creator_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_creator_ip_addr ON public.user_feedback USING btree (creator_ip_addr);


--
-- Name: index_user_feedback_on_lower_body_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_lower_body_trgm ON public.user_feedback USING gin (lower(body) public.gin_trgm_ops);


--
-- Name: index_user_feedback_on_to_tsvector_english_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_to_tsvector_english_body ON public.user_feedback USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_user_feedback_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_feedback_on_user_id ON public.user_feedback USING btree (user_id);


--
-- Name: index_user_lower_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_lower_email ON public.users USING btree (lower((email)::text));


--
-- Name: index_user_name_change_requests_on_original_name; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_original_name ON public.user_name_change_requests USING btree (original_name);


--
-- Name: index_user_name_change_requests_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_name_change_requests_on_user_id ON public.user_name_change_requests USING btree (user_id);


--
-- Name: index_user_text_versions_on_updater_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_text_versions_on_updater_id ON public.user_text_versions USING btree (updater_id);


--
-- Name: index_user_text_versions_on_user_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_user_text_versions_on_user_id ON public.user_text_versions USING btree (user_id);


--
-- Name: index_users_on_email; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_email ON public.users USING btree (email);


--
-- Name: index_users_on_last_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_last_ip_addr ON public.users USING btree (last_ip_addr) WHERE (last_ip_addr IS NOT NULL);


--
-- Name: index_users_on_lower_profile_about_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_lower_profile_about_trgm ON public.users USING gin (lower(profile_about) public.gin_trgm_ops);


--
-- Name: index_users_on_lower_profile_artinfo_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_lower_profile_artinfo_trgm ON public.users USING gin (lower(profile_artinfo) public.gin_trgm_ops);


--
-- Name: index_users_on_name; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_users_on_name ON public.users USING btree (lower((name)::text));


--
-- Name: index_users_on_to_tsvector_english_profile_about; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_to_tsvector_english_profile_about ON public.users USING gin (to_tsvector('english'::regconfig, profile_about));


--
-- Name: index_users_on_to_tsvector_english_profile_artinfo; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_users_on_to_tsvector_english_profile_artinfo ON public.users USING gin (to_tsvector('english'::regconfig, profile_artinfo));


--
-- Name: index_wiki_page_versions_on_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_created_at ON public.wiki_page_versions USING btree (created_at);


--
-- Name: index_wiki_page_versions_on_updater_ip_addr; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_updater_ip_addr ON public.wiki_page_versions USING btree (updater_ip_addr);


--
-- Name: index_wiki_page_versions_on_wiki_page_id; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_page_versions_on_wiki_page_id ON public.wiki_page_versions USING btree (wiki_page_id);


--
-- Name: index_wiki_pages_on_lower_body_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_lower_body_trgm ON public.wiki_pages USING gin (lower(body) public.gin_trgm_ops);


--
-- Name: index_wiki_pages_on_lower_title_trgm; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_lower_title_trgm ON public.wiki_pages USING gin (lower((title)::text) public.gin_trgm_ops);


--
-- Name: index_wiki_pages_on_title; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX index_wiki_pages_on_title ON public.wiki_pages USING btree (title);


--
-- Name: index_wiki_pages_on_title_pattern; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_title_pattern ON public.wiki_pages USING btree (title text_pattern_ops);


--
-- Name: index_wiki_pages_on_to_tsvector_english_body; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_to_tsvector_english_body ON public.wiki_pages USING gin (to_tsvector('english'::regconfig, body));


--
-- Name: index_wiki_pages_on_updated_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX index_wiki_pages_on_updated_at ON public.wiki_pages USING btree (updated_at);


--
-- Name: posts posts_update_change_seq; Type: TRIGGER; Schema: public; Owner: -
--

CREATE TRIGGER posts_update_change_seq BEFORE UPDATE ON public.posts FOR EACH ROW EXECUTE FUNCTION public.posts_trigger_change_seq();


--
-- Name: staff_audit_logs fk_rails_02329e5ef9; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_audit_logs
    ADD CONSTRAINT fk_rails_02329e5ef9 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: post_deletion_reasons fk_rails_1d9b3de04b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_deletion_reasons
    ADD CONSTRAINT fk_rails_1d9b3de04b FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: rule_categories fk_rails_21909079f3; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_categories
    ADD CONSTRAINT fk_rails_21909079f3 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: rules fk_rails_272189fc55; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT fk_rails_272189fc55 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: tickets fk_rails_45cd696dba; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.tickets
    ADD CONSTRAINT fk_rails_45cd696dba FOREIGN KEY (accused_id) REFERENCES public.users(id);


--
-- Name: rules fk_rails_48ba033e3f; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT fk_rails_48ba033e3f FOREIGN KEY (updater_id) REFERENCES public.users(id);


--
-- Name: rule_categories fk_rails_599a487368; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rule_categories
    ADD CONSTRAINT fk_rails_599a487368 FOREIGN KEY (updater_id) REFERENCES public.users(id);


--
-- Name: rules fk_rails_62bf5195cf; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rules
    ADD CONSTRAINT fk_rails_62bf5195cf FOREIGN KEY (category_id) REFERENCES public.rule_categories(id);


--
-- Name: user_feedback fk_rails_9329a36823; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_feedback
    ADD CONSTRAINT fk_rails_9329a36823 FOREIGN KEY (updater_id) REFERENCES public.users(id);


--
-- Name: post_replacement_rejection_reasons fk_rails_95ac45c762; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacement_rejection_reasons
    ADD CONSTRAINT fk_rails_95ac45c762 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: mascots fk_rails_9901e810fa; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.mascots
    ADD CONSTRAINT fk_rails_9901e810fa FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: user_text_versions fk_rails_a72e6f79a8; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_text_versions
    ADD CONSTRAINT fk_rails_a72e6f79a8 FOREIGN KEY (updater_id) REFERENCES public.users(id);


--
-- Name: favorites fk_rails_a7668ef613; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_a7668ef613 FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: staff_notes fk_rails_bab7e2d92a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_notes
    ADD CONSTRAINT fk_rails_bab7e2d92a FOREIGN KEY (user_id) REFERENCES public.users(id);


--
-- Name: post_events fk_rails_bd327ccee6; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_events
    ADD CONSTRAINT fk_rails_bd327ccee6 FOREIGN KEY (creator_id) REFERENCES public.users(id);


--
-- Name: favorites fk_rails_d20e53bb68; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.favorites
    ADD CONSTRAINT fk_rails_d20e53bb68 FOREIGN KEY (post_id) REFERENCES public.posts(id);


--
-- Name: user_blocks fk_rails_d2416b669a; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_blocks
    ADD CONSTRAINT fk_rails_d2416b669a FOREIGN KEY (target_id) REFERENCES public.users(id);


--
-- Name: post_replacements fk_rails_e2177a7d4b; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.post_replacements
    ADD CONSTRAINT fk_rails_e2177a7d4b FOREIGN KEY (rejector_id) REFERENCES public.users(id);


--
-- Name: staff_notes fk_rails_eaa7223eea; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.staff_notes
    ADD CONSTRAINT fk_rails_eaa7223eea FOREIGN KEY (updater_id) REFERENCES public.users(id);


--
-- PostgreSQL database dump complete
--

SET search_path TO "$user", public;

INSERT INTO "schema_migrations" (version) VALUES
('20240410140320'),
('20240410120726'),
('20240410100924'),
('20240410050656'),
('20240307133355'),
('20240306215111'),
('20240306204814'),
('20240302152238'),
('20240302150135'),
('20240302142453'),
('20240302084449'),
('20240229070342'),
('20240227091418'),
('20240217235926'),
('20240217025400'),
('20240214190653'),
('20240214023511'),
('20240210054643'),
('20240206035357'),
('20240205174652'),
('20240205165127'),
('20240205164313'),
('20240205030536'),
('20240205015902'),
('20240204214246'),
('20240127150517'),
('20240127134104'),
('20240126174807'),
('20240119211758'),
('20240113112949'),
('20240101042716'),
('20231213010430'),
('20231201235926'),
('20231005213719'),
('20231002181447'),
('20230531081706'),
('20230531080817'),
('20230518182034'),
('20230517155547'),
('20230513074838'),
('20230506161827'),
('20230316084945'),
('20230314170352'),
('20230312103728'),
('20230226152600'),
('20230221153458'),
('20230221145226'),
('20230219115601'),
('20230210092829'),
('20230204141325'),
('20230203162010'),
('20221014085948'),
('20220810131625'),
('20220710133556'),
('20220516103329'),
('20220316162257'),
('20220219202441'),
('20220203154846'),
('20220106081415');

