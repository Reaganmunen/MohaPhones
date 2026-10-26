-- =====================================================================================
-- Maphones: database schema for the phone & accessories shop (PostgreSQL 13+)
--
-- Run this ONCE on a brand-new, empty database:
--     createdb maphones
--     psql -d maphones -f db/schema.sql
-- (or on a hosted database:  psql "$DATABASE_URL" -f db/schema.sql)
--
-- It creates the shop tables, triggers and views carried over from the HassDent system,
-- plus the phone-shop additions (IMEI register, warranty), and seeds the starting data
-- (roles, permissions, tax rates, location, categories, brands).
-- It does NOT create a user. Open the app and use the first-time "setup" screen to create
-- the admin account.
-- It does NOT include any of the old dental clinic tables.
-- =====================================================================================

SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;

CREATE EXTENSION IF NOT EXISTS pg_trgm WITH SCHEMA public;

CREATE SEQUENCE public.adjustment_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.audit_logs_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.batches_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.brands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.cash_register_sessions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.customer_code_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.customer_groups_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.customer_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.customer_visits_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.customers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.expense_categories_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.expenses_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.grn_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.goods_received_notes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.grn_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.locations_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.loyalty_transactions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.mpesa_transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.notifications_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.permissions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.po_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.product_price_history_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.products_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.purchase_order_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.purchase_orders_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.roles_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.sale_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.sale_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.sale_return_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.sale_return_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.sale_returns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.sales_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_adjustment_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_adjustments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_movements_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_take_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_take_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_takes_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_transfer_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.transfer_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.stock_transfers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.supplier_payments_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.supplier_return_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.supplier_return_number_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.supplier_returns_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.suppliers_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.tax_rates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.units_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.user_tokens_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE SEQUENCE public.users_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

CREATE FUNCTION public.set_updated_at() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  NEW.updated_at := NOW();
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_customer_return_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.customer_id IS NOT NULL AND NEW.refund_amount > 0 THEN
    UPDATE customers SET total_spent = total_spent - NEW.refund_amount WHERE id = NEW.customer_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_customer_sale_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.customer_id IS NULL THEN RETURN NEW; END IF;

  IF NEW.status = 'completed' AND (TG_OP = 'INSERT' OR OLD.status IS DISTINCT FROM 'completed') THEN
    UPDATE customers
       SET total_spent = total_spent + NEW.total,
           purchase_count = purchase_count + 1,
           last_purchase_at = GREATEST(COALESCE(last_purchase_at, NEW.sold_at), NEW.sold_at)
     WHERE id = NEW.customer_id;
  ELSIF TG_OP = 'UPDATE' AND OLD.status = 'completed' AND NEW.status = 'voided' THEN
    UPDATE customers
       SET total_spent = total_spent - NEW.total,
           purchase_count = GREATEST(purchase_count - 1, 0)
     WHERE id = NEW.customer_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_customer_visit_stats() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE customers
     SET visit_count = visit_count + 1,
         last_visit_at = GREATEST(COALESCE(last_visit_at, NEW.visited_at), NEW.visited_at)
   WHERE id = NEW.customer_id;
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_loyalty_apply() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  UPDATE customers
     SET loyalty_points = loyalty_points + NEW.points   -- CHECK >= 0 blocks over-redeeming
   WHERE id = NEW.customer_id
   RETURNING loyalty_points INTO NEW.balance_after;
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_product_price_history() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  IF NEW.cost_price IS DISTINCT FROM OLD.cost_price
     OR NEW.selling_price IS DISTINCT FROM OLD.selling_price THEN
    INSERT INTO product_price_history
      (product_id, old_cost_price, new_cost_price, old_selling_price, new_selling_price)
    VALUES
      (NEW.id, OLD.cost_price, NEW.cost_price, OLD.selling_price, NEW.selling_price);
  END IF;
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_stock_movement_apply() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_tracks_expiry BOOLEAN;
BEGIN
  SELECT tracks_expiry INTO v_tracks_expiry FROM products WHERE id = NEW.product_id;
  IF v_tracks_expiry AND NEW.batch_id IS NULL THEN
    RAISE EXCEPTION 'Product % tracks expiry: a batch_id is required', NEW.product_id
      USING ERRCODE = '23514';
  END IF;

  -- Create the balance row at 0 if missing (race-safe), THEN apply the delta.
  -- (A single upsert with a negative value would trip the CHECK on the
  -- proposed row before ON CONFLICT is resolved.) The UPDATE row-locks the
  -- balance, so concurrent sales of the same product queue up safely.
  INSERT INTO stock_levels (product_id, location_id, on_hand)
  VALUES (NEW.product_id, NEW.location_id, 0)
  ON CONFLICT (product_id, location_id) DO NOTHING;

  UPDATE stock_levels
     SET on_hand = on_hand + NEW.quantity, updated_at = NOW()
   WHERE product_id = NEW.product_id AND location_id = NEW.location_id;

  IF NEW.batch_id IS NOT NULL THEN
    INSERT INTO batch_stock_levels (batch_id, location_id, on_hand)
    VALUES (NEW.batch_id, NEW.location_id, 0)
    ON CONFLICT (batch_id, location_id) DO NOTHING;

    UPDATE batch_stock_levels
       SET on_hand = on_hand + NEW.quantity, updated_at = NOW()
     WHERE batch_id = NEW.batch_id AND location_id = NEW.location_id;
  END IF;
  RETURN NEW;
END;
$$;

CREATE FUNCTION public.trg_stock_movement_immutable() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
BEGIN
  RAISE EXCEPTION 'stock_movements is append-only; insert a reversing movement instead';
END;
$$;

CREATE FUNCTION public.trg_sync_sale_payment() RETURNS trigger
    LANGUAGE plpgsql
    AS $$
DECLARE
  v_sale INT;
  v_paid NUMERIC(12,2);
BEGIN
  v_sale := COALESCE(NEW.sale_id, OLD.sale_id);
  SELECT COALESCE(SUM(amount), 0) INTO v_paid
    FROM payments WHERE sale_id = v_sale AND status = 'completed';
  UPDATE sales
     SET amount_paid = v_paid,
         payment_status = CASE
           WHEN v_paid >= total AND v_paid > 0 THEN 'paid'
           WHEN v_paid > 0 THEN 'partial'
           ELSE 'unpaid' END
   WHERE id = v_sale;
  RETURN NULL;
END;
$$;

CREATE TABLE public.audit_logs (
    id bigint NOT NULL,
    user_id integer,
    action character varying(50) NOT NULL,
    entity_type character varying(50) NOT NULL,
    entity_id bigint,
    old_data jsonb,
    new_data jsonb,
    ip_address inet,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.batch_stock_levels (
    batch_id integer NOT NULL,
    location_id integer NOT NULL,
    on_hand integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT batch_stock_levels_on_hand_check CHECK ((on_hand >= 0))
);

CREATE TABLE public.batches (
    id integer NOT NULL,
    product_id integer NOT NULL,
    batch_number character varying(50) NOT NULL,
    manufactured_date date,
    expiry_date date,
    unit_cost numeric(12,2),
    supplier_id integer,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT batches_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);

CREATE TABLE public.brands (
    id integer NOT NULL,
    name character varying(100) NOT NULL
);

CREATE TABLE public.cash_register_sessions (
    id integer NOT NULL,
    opened_by integer NOT NULL,
    opened_at timestamp with time zone DEFAULT now() NOT NULL,
    opening_float numeric(12,2) DEFAULT 0 NOT NULL,
    closed_by integer,
    closed_at timestamp with time zone,
    expected_cash numeric(12,2),
    counted_cash numeric(12,2),
    variance numeric(12,2) GENERATED ALWAYS AS ((counted_cash - expected_cash)) STORED,
    status character varying(10) DEFAULT 'open'::character varying NOT NULL,
    notes text,
    CONSTRAINT cash_register_sessions_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'closed'::character varying])::text[])))
);

CREATE TABLE public.categories (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    parent_id integer
);

CREATE TABLE public.customer_groups (
    id integer NOT NULL,
    name character varying(60) NOT NULL,
    discount_percent numeric(5,2) DEFAULT 0 NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    CONSTRAINT customer_groups_discount_percent_check CHECK (((discount_percent >= (0)::numeric) AND (discount_percent <= (100)::numeric)))
);

CREATE TABLE public.customer_notes (
    id integer NOT NULL,
    customer_id integer NOT NULL,
    note text NOT NULL,
    show_on_checkin boolean DEFAULT false NOT NULL,
    is_resolved boolean DEFAULT false NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.customer_visits (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
    visited_at timestamp with time zone DEFAULT now() NOT NULL,
    purpose character varying(100),
    served_by integer,
    notes text
);

CREATE TABLE public.customers (
    id integer NOT NULL,
    customer_code character varying(20) DEFAULT ('CUS-'::text || lpad((nextval('public.customer_code_seq'::regclass))::text, 5, '0'::text)) NOT NULL,
    full_name character varying(150) NOT NULL,
    customer_type character varying(20) DEFAULT 'individual'::character varying NOT NULL,
    organization_name character varying(150),
    phone character varying(20),
    alt_phone character varying(20),
    email character varying(150),
    address text,
    customer_group_id integer,
    credit_limit numeric(12,2) DEFAULT 0 NOT NULL,
    loyalty_points integer DEFAULT 0 NOT NULL,
    visit_count integer DEFAULT 0 NOT NULL,
    last_visit_at timestamp with time zone,
    purchase_count integer DEFAULT 0 NOT NULL,
    total_spent numeric(12,2) DEFAULT 0 NOT NULL,
    last_purchase_at timestamp with time zone,
    is_active boolean DEFAULT true NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT customers_credit_limit_check CHECK ((credit_limit >= (0)::numeric)),
    CONSTRAINT customers_customer_type_check CHECK (((customer_type)::text = ANY ((ARRAY['individual'::character varying, 'business'::character varying])::text[]))),
    CONSTRAINT customers_loyalty_points_check CHECK ((loyalty_points >= 0)),
    CONSTRAINT customers_phone_check CHECK (((phone)::text ~ '^\+?[0-9]{9,15}$'::text))
);

CREATE TABLE public.expense_categories (
    id integer NOT NULL,
    name character varying(80) NOT NULL
);

CREATE TABLE public.expenses (
    id integer NOT NULL,
    category_id integer NOT NULL,
    amount numeric(12,2) NOT NULL,
    expense_date date DEFAULT CURRENT_DATE NOT NULL,
    method character varying(20) DEFAULT 'cash'::character varying NOT NULL,
    reference character varying(100),
    description text,
    receipt_url text,
    recorded_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT expenses_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT expenses_method_check CHECK (((method)::text = ANY ((ARRAY['cash'::character varying, 'mpesa'::character varying, 'card'::character varying, 'bank_transfer'::character varying])::text[])))
);

CREATE TABLE public.goods_received_notes (
    id integer NOT NULL,
    grn_number character varying(20) DEFAULT ('GRN-'::text || lpad((nextval('public.grn_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    purchase_order_id integer,
    supplier_id integer NOT NULL,
    supplier_invoice_no character varying(50),
    location_id integer NOT NULL,
    received_date date DEFAULT CURRENT_DATE NOT NULL,
    total_cost numeric(12,2) DEFAULT 0 NOT NULL,
    notes text,
    received_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.grn_items (
    id integer NOT NULL,
    grn_id integer NOT NULL,
    purchase_order_item_id integer,
    product_id integer NOT NULL,
    batch_id integer,
    quantity integer NOT NULL,
    unit_cost numeric(12,2) NOT NULL,
    CONSTRAINT grn_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT grn_items_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);

CREATE TABLE public.locations (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    type character varying(20) DEFAULT 'shop_floor'::character varying NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    CONSTRAINT locations_type_check CHECK (((type)::text = ANY ((ARRAY['shop_floor'::character varying, 'store_room'::character varying])::text[])))
);

CREATE TABLE public.loyalty_transactions (
    id bigint NOT NULL,
    customer_id integer NOT NULL,
    sale_id integer,
    type character varying(10) NOT NULL,
    points integer NOT NULL,
    balance_after integer,
    note text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT loyalty_transactions_points_check CHECK ((points <> 0)),
    CONSTRAINT loyalty_transactions_type_check CHECK (((type)::text = ANY ((ARRAY['earn'::character varying, 'redeem'::character varying, 'adjust'::character varying, 'expire'::character varying])::text[])))
);

CREATE TABLE public.mpesa_transactions (
    id integer NOT NULL,
    sale_id integer,
    transaction_type character varying(10) DEFAULT 'stk_push'::character varying NOT NULL,
    phone character varying(20) NOT NULL,
    amount numeric(12,2) NOT NULL,
    account_reference character varying(50),
    merchant_request_id character varying(100),
    checkout_request_id character varying(100),
    mpesa_receipt_number character varying(30),
    status character varying(12) DEFAULT 'pending'::character varying NOT NULL,
    result_code integer,
    result_desc text,
    transaction_date timestamp with time zone,
    raw_callback jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT mpesa_transactions_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT mpesa_transactions_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'success'::character varying, 'failed'::character varying, 'cancelled'::character varying, 'timeout'::character varying])::text[]))),
    CONSTRAINT mpesa_transactions_transaction_type_check CHECK (((transaction_type)::text = ANY ((ARRAY['stk_push'::character varying, 'c2b'::character varying])::text[])))
);

CREATE TABLE public.notifications (
    id bigint NOT NULL,
    user_id integer,
    type character varying(20) NOT NULL,
    title character varying(150) NOT NULL,
    message text,
    entity_type character varying(50),
    entity_id bigint,
    is_read boolean DEFAULT false NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT notifications_type_check CHECK (((type)::text = ANY ((ARRAY['low_stock'::character varying, 'expiry'::character varying, 'payment'::character varying, 'reminder'::character varying, 'system'::character varying])::text[])))
);

CREATE TABLE public.payments (
    id integer NOT NULL,
    sale_id integer NOT NULL,
    method character varying(20) NOT NULL,
    amount numeric(12,2) NOT NULL,
    reference character varying(100),
    mpesa_transaction_id integer,
    status character varying(10) DEFAULT 'completed'::character varying NOT NULL,
    received_by integer,
    paid_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT payments_method_check CHECK (((method)::text = ANY ((ARRAY['cash'::character varying, 'mpesa'::character varying, 'card'::character varying, 'bank_transfer'::character varying, 'loyalty'::character varying])::text[]))),
    CONSTRAINT payments_status_check CHECK (((status)::text = ANY ((ARRAY['pending'::character varying, 'completed'::character varying, 'failed'::character varying, 'reversed'::character varying])::text[])))
);

CREATE TABLE public.permissions (
    id integer NOT NULL,
    code character varying(60) NOT NULL,
    description text
);

CREATE TABLE public.product_group_prices (
    product_id integer NOT NULL,
    customer_group_id integer NOT NULL,
    price numeric(12,2) NOT NULL,
    CONSTRAINT product_group_prices_price_check CHECK ((price >= (0)::numeric))
);

CREATE TABLE public.product_price_history (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    old_cost_price numeric(12,2),
    new_cost_price numeric(12,2),
    old_selling_price numeric(12,2),
    new_selling_price numeric(12,2),
    changed_by integer,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.product_suppliers (
    product_id integer NOT NULL,
    supplier_id integer NOT NULL,
    supplier_sku character varying(50),
    last_cost numeric(12,2),
    lead_time_days integer,
    is_preferred boolean DEFAULT false NOT NULL,
    CONSTRAINT product_suppliers_last_cost_check CHECK ((last_cost >= (0)::numeric))
);

CREATE TABLE public.products (
    id integer NOT NULL,
    sku character varying(50) NOT NULL,
    barcode character varying(64),
    name character varying(200) NOT NULL,
    description text,
    category_id integer,
    brand_id integer,
    unit_id integer NOT NULL,
    tax_rate_id integer,
    cost_price numeric(12,2) DEFAULT 0 NOT NULL,
    selling_price numeric(12,2) DEFAULT 0 NOT NULL,
    min_price numeric(12,2),
    reorder_level integer DEFAULT 0 NOT NULL,
    reorder_qty integer DEFAULT 0 NOT NULL,
    tracks_expiry boolean DEFAULT false NOT NULL,
    image_url text,
    is_active boolean DEFAULT true NOT NULL,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT products_cost_price_check CHECK ((cost_price >= (0)::numeric)),
    CONSTRAINT products_min_price_check CHECK ((min_price >= (0)::numeric)),
    CONSTRAINT products_reorder_level_check CHECK ((reorder_level >= 0)),
    CONSTRAINT products_reorder_qty_check CHECK ((reorder_qty >= 0)),
    CONSTRAINT products_selling_price_check CHECK ((selling_price >= (0)::numeric))
);

CREATE TABLE public.purchase_order_items (
    id integer NOT NULL,
    purchase_order_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity_ordered integer NOT NULL,
    quantity_received integer DEFAULT 0 NOT NULL,
    unit_cost numeric(12,2) NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    line_total numeric(12,2) DEFAULT 0 NOT NULL,
    CONSTRAINT purchase_order_items_quantity_ordered_check CHECK ((quantity_ordered > 0)),
    CONSTRAINT purchase_order_items_quantity_received_check CHECK ((quantity_received >= 0)),
    CONSTRAINT purchase_order_items_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);

CREATE TABLE public.purchase_orders (
    id integer NOT NULL,
    po_number character varying(20) DEFAULT ('PO-'::text || lpad((nextval('public.po_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    supplier_id integer NOT NULL,
    status character varying(20) DEFAULT 'draft'::character varying NOT NULL,
    order_date date,
    expected_date date,
    received_at timestamp with time zone,
    subtotal numeric(12,2) DEFAULT 0 NOT NULL,
    tax_total numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) DEFAULT 0 NOT NULL,
    notes text,
    created_by integer,
    approved_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT purchase_orders_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'ordered'::character varying, 'partially_received'::character varying, 'received'::character varying, 'cancelled'::character varying])::text[])))
);

CREATE TABLE public.role_permissions (
    role_id integer NOT NULL,
    permission_id integer NOT NULL
);

CREATE TABLE public.roles (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    description text
);

CREATE TABLE public.sale_items (
    id integer NOT NULL,
    sale_id integer NOT NULL,
    product_id integer NOT NULL,
    quantity integer NOT NULL,
    quantity_returned integer DEFAULT 0 NOT NULL,
    unit_price numeric(12,2) NOT NULL,
    unit_cost numeric(12,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(12,2) DEFAULT 0 NOT NULL,
    tax_rate numeric(5,2) DEFAULT 0 NOT NULL,
    tax_amount numeric(12,2) DEFAULT 0 NOT NULL,
    line_total numeric(12,2) NOT NULL,
    CONSTRAINT sale_items_check CHECK ((quantity_returned <= quantity)),
    CONSTRAINT sale_items_discount_amount_check CHECK ((discount_amount >= (0)::numeric)),
    CONSTRAINT sale_items_line_total_check CHECK ((line_total >= (0)::numeric)),
    CONSTRAINT sale_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT sale_items_quantity_returned_check CHECK ((quantity_returned >= 0)),
    CONSTRAINT sale_items_unit_price_check CHECK ((unit_price >= (0)::numeric))
);

CREATE TABLE public.sale_return_items (
    id integer NOT NULL,
    sale_return_id integer NOT NULL,
    sale_item_id integer NOT NULL,
    product_id integer NOT NULL,
    batch_id integer,
    quantity integer NOT NULL,
    refund_amount numeric(12,2) NOT NULL,
    restock boolean DEFAULT true NOT NULL,
    CONSTRAINT sale_return_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT sale_return_items_refund_amount_check CHECK ((refund_amount >= (0)::numeric))
);

CREATE TABLE public.sale_returns (
    id integer NOT NULL,
    return_number character varying(20) DEFAULT ('RET-'::text || lpad((nextval('public.sale_return_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    sale_id integer NOT NULL,
    customer_id integer,
    location_id integer NOT NULL,
    reason character varying(30) NOT NULL,
    refund_method character varying(20) NOT NULL,
    refund_amount numeric(12,2) DEFAULT 0 NOT NULL,
    notes text,
    processed_by integer,
    processed_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT sale_returns_reason_check CHECK (((reason)::text = ANY ((ARRAY['defective'::character varying, 'wrong_item'::character varying, 'changed_mind'::character varying, 'expired'::character varying, 'other'::character varying])::text[]))),
    CONSTRAINT sale_returns_refund_amount_check CHECK ((refund_amount >= (0)::numeric)),
    CONSTRAINT sale_returns_refund_method_check CHECK (((refund_method)::text = ANY ((ARRAY['cash'::character varying, 'mpesa'::character varying, 'store_credit'::character varying, 'none'::character varying])::text[])))
);

CREATE TABLE public.sales (
    id integer NOT NULL,
    sale_number character varying(20) DEFAULT ('INV-'::text || lpad((nextval('public.sale_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    customer_id integer,
    register_session_id integer,
    location_id integer NOT NULL,
    status character varying(10) DEFAULT 'completed'::character varying NOT NULL,
    subtotal numeric(12,2) DEFAULT 0 NOT NULL,
    discount_amount numeric(12,2) DEFAULT 0 NOT NULL,
    loyalty_points_used integer DEFAULT 0 NOT NULL,
    loyalty_discount numeric(12,2) DEFAULT 0 NOT NULL,
    tax_total numeric(12,2) DEFAULT 0 NOT NULL,
    total numeric(12,2) DEFAULT 0 NOT NULL,
    amount_paid numeric(12,2) DEFAULT 0 NOT NULL,
    payment_status character varying(10) DEFAULT 'unpaid'::character varying NOT NULL,
    notes text,
    sold_by integer,
    sold_at timestamp with time zone DEFAULT now() NOT NULL,
    voided_by integer,
    voided_at timestamp with time zone,
    void_reason text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT sales_discount_amount_check CHECK ((discount_amount >= (0)::numeric)),
    CONSTRAINT sales_loyalty_discount_check CHECK ((loyalty_discount >= (0)::numeric)),
    CONSTRAINT sales_loyalty_points_used_check CHECK ((loyalty_points_used >= 0)),
    CONSTRAINT sales_payment_status_check CHECK (((payment_status)::text = ANY ((ARRAY['unpaid'::character varying, 'partial'::character varying, 'paid'::character varying])::text[]))),
    CONSTRAINT sales_status_check CHECK (((status)::text = ANY ((ARRAY['held'::character varying, 'completed'::character varying, 'voided'::character varying])::text[]))),
    CONSTRAINT sales_total_check CHECK ((total >= (0)::numeric))
);

CREATE TABLE public.shop_settings (
    id smallint DEFAULT 1 NOT NULL,
    shop_name character varying(150) DEFAULT 'Hassdent'::character varying NOT NULL,
    address text,
    phone character varying(20),
    email character varying(150),
    kra_pin character varying(20),
    currency character(3) DEFAULT 'KES'::bpchar NOT NULL,
    receipt_footer text,
    loyalty_points_per_kes numeric(6,4) DEFAULT 0.0100 NOT NULL,
    loyalty_kes_per_point numeric(8,2) DEFAULT 1.00 NOT NULL,
    frequent_customer_min_visits integer DEFAULT 5 NOT NULL,
    expiry_alert_days integer DEFAULT 60 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT shop_settings_id_check CHECK ((id = 1))
);

CREATE TABLE public.stock_adjustment_items (
    id integer NOT NULL,
    stock_adjustment_id integer NOT NULL,
    product_id integer NOT NULL,
    batch_id integer,
    quantity_change integer NOT NULL,
    CONSTRAINT stock_adjustment_items_quantity_change_check CHECK ((quantity_change <> 0))
);

CREATE TABLE public.stock_adjustments (
    id integer NOT NULL,
    adjustment_number character varying(20) DEFAULT ('ADJ-'::text || lpad((nextval('public.adjustment_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    location_id integer NOT NULL,
    reason character varying(30) NOT NULL,
    notes text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stock_adjustments_reason_check CHECK (((reason)::text = ANY ((ARRAY['damaged'::character varying, 'expired'::character varying, 'lost'::character varying, 'found'::character varying, 'correction'::character varying, 'sample'::character varying, 'other'::character varying])::text[])))
);

CREATE TABLE public.stock_levels (
    product_id integer NOT NULL,
    location_id integer NOT NULL,
    on_hand integer DEFAULT 0 NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stock_levels_on_hand_check CHECK ((on_hand >= 0))
);

CREATE TABLE public.stock_movements (
    id bigint NOT NULL,
    product_id integer NOT NULL,
    batch_id integer,
    location_id integer NOT NULL,
    quantity integer NOT NULL,
    movement_type character varying(20) NOT NULL,
    unit_cost numeric(12,2),
    source_type character varying(30),
    source_id bigint,
    note text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stock_movements_movement_type_check CHECK (((movement_type)::text = ANY ((ARRAY['opening'::character varying, 'purchase'::character varying, 'sale'::character varying, 'sale_return'::character varying, 'supplier_return'::character varying, 'adjustment'::character varying, 'damage'::character varying, 'expiry_writeoff'::character varying, 'transfer_in'::character varying, 'transfer_out'::character varying, 'stock_take'::character varying])::text[]))),
    CONSTRAINT stock_movements_quantity_check CHECK ((quantity <> 0))
);

CREATE TABLE public.stock_take_items (
    id integer NOT NULL,
    stock_take_id integer NOT NULL,
    product_id integer NOT NULL,
    batch_id integer,
    system_qty integer NOT NULL,
    counted_qty integer,
    variance integer GENERATED ALWAYS AS ((counted_qty - system_qty)) STORED,
    CONSTRAINT stock_take_items_counted_qty_check CHECK ((counted_qty >= 0))
);

CREATE TABLE public.stock_takes (
    id integer NOT NULL,
    take_number character varying(20) DEFAULT ('ST-'::text || lpad((nextval('public.stock_take_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    location_id integer NOT NULL,
    status character varying(20) DEFAULT 'in_progress'::character varying NOT NULL,
    notes text,
    started_by integer,
    started_at timestamp with time zone DEFAULT now() NOT NULL,
    completed_at timestamp with time zone,
    CONSTRAINT stock_takes_status_check CHECK (((status)::text = ANY ((ARRAY['in_progress'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);

CREATE TABLE public.stock_transfer_items (
    id integer NOT NULL,
    stock_transfer_id integer NOT NULL,
    product_id integer NOT NULL,
    batch_id integer,
    quantity integer NOT NULL,
    CONSTRAINT stock_transfer_items_quantity_check CHECK ((quantity > 0))
);

CREATE TABLE public.stock_transfers (
    id integer NOT NULL,
    transfer_number character varying(20) DEFAULT ('TRF-'::text || lpad((nextval('public.transfer_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    from_location_id integer NOT NULL,
    to_location_id integer NOT NULL,
    status character varying(20) DEFAULT 'completed'::character varying NOT NULL,
    notes text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT stock_transfers_check CHECK ((from_location_id <> to_location_id)),
    CONSTRAINT stock_transfers_status_check CHECK (((status)::text = ANY ((ARRAY['draft'::character varying, 'completed'::character varying, 'cancelled'::character varying])::text[])))
);

CREATE TABLE public.supplier_payments (
    id integer NOT NULL,
    supplier_id integer NOT NULL,
    purchase_order_id integer,
    grn_id integer,
    amount numeric(12,2) NOT NULL,
    method character varying(20) NOT NULL,
    reference character varying(100),
    paid_at timestamp with time zone DEFAULT now() NOT NULL,
    paid_by integer,
    notes text,
    CONSTRAINT supplier_payments_amount_check CHECK ((amount > (0)::numeric)),
    CONSTRAINT supplier_payments_method_check CHECK (((method)::text = ANY ((ARRAY['cash'::character varying, 'mpesa'::character varying, 'bank_transfer'::character varying, 'cheque'::character varying])::text[])))
);

CREATE TABLE public.supplier_return_items (
    id integer NOT NULL,
    supplier_return_id integer NOT NULL,
    product_id integer NOT NULL,
    batch_id integer,
    quantity integer NOT NULL,
    unit_cost numeric(12,2) NOT NULL,
    CONSTRAINT supplier_return_items_quantity_check CHECK ((quantity > 0)),
    CONSTRAINT supplier_return_items_unit_cost_check CHECK ((unit_cost >= (0)::numeric))
);

CREATE TABLE public.supplier_returns (
    id integer NOT NULL,
    return_number character varying(20) DEFAULT ('SRT-'::text || lpad((nextval('public.supplier_return_number_seq'::regclass))::text, 6, '0'::text)) NOT NULL,
    supplier_id integer NOT NULL,
    grn_id integer,
    location_id integer NOT NULL,
    reason character varying(30) NOT NULL,
    credit_amount numeric(12,2) DEFAULT 0 NOT NULL,
    notes text,
    created_by integer,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT supplier_returns_reason_check CHECK (((reason)::text = ANY ((ARRAY['damaged'::character varying, 'expired'::character varying, 'wrong_item'::character varying, 'overstock'::character varying, 'other'::character varying])::text[])))
);

CREATE TABLE public.suppliers (
    id integer NOT NULL,
    name character varying(150) NOT NULL,
    contact_person character varying(100),
    phone character varying(20),
    email character varying(150),
    address text,
    kra_pin character varying(20),
    payment_terms character varying(100),
    notes text,
    is_active boolean DEFAULT true NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.tax_rates (
    id integer NOT NULL,
    name character varying(50) NOT NULL,
    rate numeric(5,2) NOT NULL,
    is_default boolean DEFAULT false NOT NULL,
    CONSTRAINT tax_rates_rate_check CHECK (((rate >= (0)::numeric) AND (rate <= (100)::numeric)))
);

CREATE TABLE public.units (
    id integer NOT NULL,
    name character varying(30) NOT NULL,
    abbreviation character varying(10)
);

CREATE TABLE public.user_tokens (
    id bigint NOT NULL,
    user_id integer NOT NULL,
    type character varying(20) NOT NULL,
    token_hash text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    used_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    CONSTRAINT user_tokens_type_check CHECK (((type)::text = ANY ((ARRAY['refresh'::character varying, 'password_reset'::character varying])::text[])))
);

CREATE TABLE public.users (
    id integer NOT NULL,
    name character varying(100) NOT NULL,
    email character varying(150) NOT NULL,
    phone character varying(20),
    password_hash text NOT NULL,
    role_id integer NOT NULL,
    is_active boolean DEFAULT true NOT NULL,
    last_login_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE VIEW public.v_customer_balances AS
 SELECT customer_id,
    (sum((total - amount_paid)))::numeric(12,2) AS outstanding
   FROM public.sales
  WHERE (((status)::text = 'completed'::text) AND (customer_id IS NOT NULL) AND (amount_paid < total))
  GROUP BY customer_id;

CREATE VIEW public.v_customer_summary AS
 SELECT c.id,
    c.customer_code,
    c.full_name,
    c.phone,
    c.alt_phone,
    c.email,
    c.customer_type,
    c.organization_name,
    c.customer_group_id,
    c.loyalty_points,
    c.credit_limit,
    c.visit_count,
    c.last_visit_at,
    c.purchase_count,
    c.total_spent,
    c.last_purchase_at,
    COALESCE(b.outstanding, (0)::numeric) AS outstanding_balance,
    (c.visit_count >= ( SELECT shop_settings.frequent_customer_min_visits
           FROM public.shop_settings
         LIMIT 1)) AS is_frequent
   FROM (public.customers c
     LEFT JOIN public.v_customer_balances b ON ((b.customer_id = c.id)))
  WHERE c.is_active;

CREATE VIEW public.v_customer_top_products AS
 SELECT s.customer_id,
    si.product_id,
    p.name,
    (sum((si.quantity - si.quantity_returned)))::integer AS qty_bought,
    max(s.sold_at) AS last_bought_at
   FROM ((public.sale_items si
     JOIN public.sales s ON (((s.id = si.sale_id) AND ((s.status)::text = 'completed'::text))))
     JOIN public.products p ON ((p.id = si.product_id)))
  WHERE (s.customer_id IS NOT NULL)
  GROUP BY s.customer_id, si.product_id, p.name;

CREATE VIEW public.v_expiring_batches AS
SELECT
    NULL::integer AS batch_id,
    NULL::integer AS product_id,
    NULL::character varying(200) AS name,
    NULL::character varying(50) AS batch_number,
    NULL::date AS expiry_date,
    NULL::integer AS days_left,
    NULL::boolean AS is_expired,
    NULL::integer AS on_hand;

CREATE VIEW public.v_product_stock AS
SELECT
    NULL::integer AS product_id,
    NULL::character varying(50) AS sku,
    NULL::character varying(200) AS name,
    NULL::integer AS reorder_level,
    NULL::integer AS reorder_qty,
    NULL::integer AS on_hand,
    NULL::boolean AS needs_reorder;

CREATE VIEW public.v_low_stock AS
 SELECT product_id,
    sku,
    name,
    reorder_level,
    reorder_qty,
    on_hand,
    needs_reorder
   FROM public.v_product_stock
  WHERE needs_reorder
  ORDER BY on_hand;

CREATE VIEW public.v_sales_daily AS
 SELECT ((s.sold_at AT TIME ZONE 'Africa/Nairobi'::text))::date AS sale_date,
    count(DISTINCT s.id) AS sales_count,
    (sum(si.line_total))::numeric(12,2) AS gross_sales,
    (sum((si.unit_cost * (si.quantity)::numeric)))::numeric(12,2) AS cost_of_goods,
    (sum(((si.line_total - si.tax_amount) - (si.unit_cost * (si.quantity)::numeric))))::numeric(12,2) AS gross_profit
   FROM (public.sales s
     JOIN public.sale_items si ON ((si.sale_id = s.id)))
  WHERE ((s.status)::text = 'completed'::text)
  GROUP BY (((s.sold_at AT TIME ZONE 'Africa/Nairobi'::text))::date);

CREATE VIEW public.v_stock_integrity_check AS
 SELECT sl.product_id,
    sl.location_id,
    sl.on_hand AS cached,
    COALESCE(m.total, (0)::bigint) AS ledger
   FROM (public.stock_levels sl
     LEFT JOIN ( SELECT stock_movements.product_id,
            stock_movements.location_id,
            sum(stock_movements.quantity) AS total
           FROM public.stock_movements
          GROUP BY stock_movements.product_id, stock_movements.location_id) m ON (((m.product_id = sl.product_id) AND (m.location_id = sl.location_id))))
  WHERE (sl.on_hand <> COALESCE(m.total, (0)::bigint));

CREATE VIEW public.v_stock_valuation AS
 SELECT p.id AS product_id,
    p.name,
    sl.location_id,
    sl.on_hand,
    p.cost_price,
    (((sl.on_hand)::numeric * p.cost_price))::numeric(12,2) AS stock_value
   FROM (public.stock_levels sl
     JOIN public.products p ON ((p.id = sl.product_id)));

ALTER TABLE ONLY public.audit_logs ALTER COLUMN id SET DEFAULT nextval('public.audit_logs_id_seq'::regclass);

ALTER TABLE ONLY public.batches ALTER COLUMN id SET DEFAULT nextval('public.batches_id_seq'::regclass);

ALTER TABLE ONLY public.brands ALTER COLUMN id SET DEFAULT nextval('public.brands_id_seq'::regclass);

ALTER TABLE ONLY public.cash_register_sessions ALTER COLUMN id SET DEFAULT nextval('public.cash_register_sessions_id_seq'::regclass);

ALTER TABLE ONLY public.categories ALTER COLUMN id SET DEFAULT nextval('public.categories_id_seq'::regclass);

ALTER TABLE ONLY public.customer_groups ALTER COLUMN id SET DEFAULT nextval('public.customer_groups_id_seq'::regclass);

ALTER TABLE ONLY public.customer_notes ALTER COLUMN id SET DEFAULT nextval('public.customer_notes_id_seq'::regclass);

ALTER TABLE ONLY public.customer_visits ALTER COLUMN id SET DEFAULT nextval('public.customer_visits_id_seq'::regclass);

ALTER TABLE ONLY public.customers ALTER COLUMN id SET DEFAULT nextval('public.customers_id_seq'::regclass);

ALTER TABLE ONLY public.expense_categories ALTER COLUMN id SET DEFAULT nextval('public.expense_categories_id_seq'::regclass);

ALTER TABLE ONLY public.expenses ALTER COLUMN id SET DEFAULT nextval('public.expenses_id_seq'::regclass);

ALTER TABLE ONLY public.goods_received_notes ALTER COLUMN id SET DEFAULT nextval('public.goods_received_notes_id_seq'::regclass);

ALTER TABLE ONLY public.grn_items ALTER COLUMN id SET DEFAULT nextval('public.grn_items_id_seq'::regclass);

ALTER TABLE ONLY public.locations ALTER COLUMN id SET DEFAULT nextval('public.locations_id_seq'::regclass);

ALTER TABLE ONLY public.loyalty_transactions ALTER COLUMN id SET DEFAULT nextval('public.loyalty_transactions_id_seq'::regclass);

ALTER TABLE ONLY public.mpesa_transactions ALTER COLUMN id SET DEFAULT nextval('public.mpesa_transactions_id_seq'::regclass);

ALTER TABLE ONLY public.notifications ALTER COLUMN id SET DEFAULT nextval('public.notifications_id_seq'::regclass);

ALTER TABLE ONLY public.payments ALTER COLUMN id SET DEFAULT nextval('public.payments_id_seq'::regclass);

ALTER TABLE ONLY public.permissions ALTER COLUMN id SET DEFAULT nextval('public.permissions_id_seq'::regclass);

ALTER TABLE ONLY public.product_price_history ALTER COLUMN id SET DEFAULT nextval('public.product_price_history_id_seq'::regclass);

ALTER TABLE ONLY public.products ALTER COLUMN id SET DEFAULT nextval('public.products_id_seq'::regclass);

ALTER TABLE ONLY public.purchase_order_items ALTER COLUMN id SET DEFAULT nextval('public.purchase_order_items_id_seq'::regclass);

ALTER TABLE ONLY public.purchase_orders ALTER COLUMN id SET DEFAULT nextval('public.purchase_orders_id_seq'::regclass);

ALTER TABLE ONLY public.roles ALTER COLUMN id SET DEFAULT nextval('public.roles_id_seq'::regclass);

ALTER TABLE ONLY public.sale_items ALTER COLUMN id SET DEFAULT nextval('public.sale_items_id_seq'::regclass);

ALTER TABLE ONLY public.sale_return_items ALTER COLUMN id SET DEFAULT nextval('public.sale_return_items_id_seq'::regclass);

ALTER TABLE ONLY public.sale_returns ALTER COLUMN id SET DEFAULT nextval('public.sale_returns_id_seq'::regclass);

ALTER TABLE ONLY public.sales ALTER COLUMN id SET DEFAULT nextval('public.sales_id_seq'::regclass);

ALTER TABLE ONLY public.stock_adjustment_items ALTER COLUMN id SET DEFAULT nextval('public.stock_adjustment_items_id_seq'::regclass);

ALTER TABLE ONLY public.stock_adjustments ALTER COLUMN id SET DEFAULT nextval('public.stock_adjustments_id_seq'::regclass);

ALTER TABLE ONLY public.stock_movements ALTER COLUMN id SET DEFAULT nextval('public.stock_movements_id_seq'::regclass);

ALTER TABLE ONLY public.stock_take_items ALTER COLUMN id SET DEFAULT nextval('public.stock_take_items_id_seq'::regclass);

ALTER TABLE ONLY public.stock_takes ALTER COLUMN id SET DEFAULT nextval('public.stock_takes_id_seq'::regclass);

ALTER TABLE ONLY public.stock_transfer_items ALTER COLUMN id SET DEFAULT nextval('public.stock_transfer_items_id_seq'::regclass);

ALTER TABLE ONLY public.stock_transfers ALTER COLUMN id SET DEFAULT nextval('public.stock_transfers_id_seq'::regclass);

ALTER TABLE ONLY public.supplier_payments ALTER COLUMN id SET DEFAULT nextval('public.supplier_payments_id_seq'::regclass);

ALTER TABLE ONLY public.supplier_return_items ALTER COLUMN id SET DEFAULT nextval('public.supplier_return_items_id_seq'::regclass);

ALTER TABLE ONLY public.supplier_returns ALTER COLUMN id SET DEFAULT nextval('public.supplier_returns_id_seq'::regclass);

ALTER TABLE ONLY public.suppliers ALTER COLUMN id SET DEFAULT nextval('public.suppliers_id_seq'::regclass);

ALTER TABLE ONLY public.tax_rates ALTER COLUMN id SET DEFAULT nextval('public.tax_rates_id_seq'::regclass);

ALTER TABLE ONLY public.units ALTER COLUMN id SET DEFAULT nextval('public.units_id_seq'::regclass);

ALTER TABLE ONLY public.user_tokens ALTER COLUMN id SET DEFAULT nextval('public.user_tokens_id_seq'::regclass);

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.batch_stock_levels
    ADD CONSTRAINT batch_stock_levels_pkey PRIMARY KEY (batch_id, location_id);

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_product_id_batch_number_key UNIQUE (product_id, batch_number);

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_name_key UNIQUE (name);

ALTER TABLE ONLY public.brands
    ADD CONSTRAINT brands_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.cash_register_sessions
    ADD CONSTRAINT cash_register_sessions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_name_key UNIQUE (parent_id, name);

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.customer_groups
    ADD CONSTRAINT customer_groups_name_key UNIQUE (name);

ALTER TABLE ONLY public.customer_groups
    ADD CONSTRAINT customer_groups_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.customer_notes
    ADD CONSTRAINT customer_notes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.customer_visits
    ADD CONSTRAINT customer_visits_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_customer_code_key UNIQUE (customer_code);

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_name_key UNIQUE (name);

ALTER TABLE ONLY public.expense_categories
    ADD CONSTRAINT expense_categories_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_grn_number_key UNIQUE (grn_number);

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_name_key UNIQUE (name);

ALTER TABLE ONLY public.locations
    ADD CONSTRAINT locations_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT loyalty_transactions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.mpesa_transactions
    ADD CONSTRAINT mpesa_transactions_checkout_request_id_key UNIQUE (checkout_request_id);

ALTER TABLE ONLY public.mpesa_transactions
    ADD CONSTRAINT mpesa_transactions_mpesa_receipt_number_key UNIQUE (mpesa_receipt_number);

ALTER TABLE ONLY public.mpesa_transactions
    ADD CONSTRAINT mpesa_transactions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_code_key UNIQUE (code);

ALTER TABLE ONLY public.permissions
    ADD CONSTRAINT permissions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.product_group_prices
    ADD CONSTRAINT product_group_prices_pkey PRIMARY KEY (product_id, customer_group_id);

ALTER TABLE ONLY public.product_price_history
    ADD CONSTRAINT product_price_history_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.product_suppliers
    ADD CONSTRAINT product_suppliers_pkey PRIMARY KEY (product_id, supplier_id);

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_barcode_key UNIQUE (barcode);

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_sku_key UNIQUE (sku);

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_po_number_key UNIQUE (po_number);

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_pkey PRIMARY KEY (role_id, permission_id);

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_name_key UNIQUE (name);

ALTER TABLE ONLY public.roles
    ADD CONSTRAINT roles_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_return_number_key UNIQUE (return_number);

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_sale_number_key UNIQUE (sale_number);

ALTER TABLE ONLY public.shop_settings
    ADD CONSTRAINT shop_settings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_adjustment_items
    ADD CONSTRAINT stock_adjustment_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_adjustments
    ADD CONSTRAINT stock_adjustments_adjustment_number_key UNIQUE (adjustment_number);

ALTER TABLE ONLY public.stock_adjustments
    ADD CONSTRAINT stock_adjustments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_levels
    ADD CONSTRAINT stock_levels_pkey PRIMARY KEY (product_id, location_id);

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_take_items
    ADD CONSTRAINT stock_take_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_takes
    ADD CONSTRAINT stock_takes_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_takes
    ADD CONSTRAINT stock_takes_take_number_key UNIQUE (take_number);

ALTER TABLE ONLY public.stock_transfer_items
    ADD CONSTRAINT stock_transfer_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_transfer_number_key UNIQUE (transfer_number);

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.supplier_return_items
    ADD CONSTRAINT supplier_return_items_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.supplier_returns
    ADD CONSTRAINT supplier_returns_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.supplier_returns
    ADD CONSTRAINT supplier_returns_return_number_key UNIQUE (return_number);

ALTER TABLE ONLY public.suppliers
    ADD CONSTRAINT suppliers_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.tax_rates
    ADD CONSTRAINT tax_rates_name_key UNIQUE (name);

ALTER TABLE ONLY public.tax_rates
    ADD CONSTRAINT tax_rates_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_name_key UNIQUE (name);

ALTER TABLE ONLY public.units
    ADD CONSTRAINT units_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);

CREATE INDEX idx_audit_entity ON public.audit_logs USING btree (entity_type, entity_id);

CREATE INDEX idx_audit_user ON public.audit_logs USING btree (user_id, created_at DESC);

CREATE INDEX idx_batches_expiry ON public.batches USING btree (expiry_date) WHERE (expiry_date IS NOT NULL);

CREATE INDEX idx_batches_product ON public.batches USING btree (product_id);

CREATE INDEX idx_cnotes_customer ON public.customer_notes USING btree (customer_id);

CREATE INDEX idx_customers_email ON public.customers USING btree (lower((email)::text));

CREATE INDEX idx_customers_name_trgm ON public.customers USING gin (full_name public.gin_trgm_ops);

CREATE INDEX idx_expenses_date ON public.expenses USING btree (expense_date DESC);

CREATE INDEX idx_grn_po ON public.goods_received_notes USING btree (purchase_order_id);

CREATE INDEX idx_grn_supplier ON public.goods_received_notes USING btree (supplier_id);

CREATE INDEX idx_grni_grn ON public.grn_items USING btree (grn_id);

CREATE INDEX idx_loyalty_customer ON public.loyalty_transactions USING btree (customer_id, created_at DESC);

CREATE INDEX idx_mov_batch ON public.stock_movements USING btree (batch_id) WHERE (batch_id IS NOT NULL);

CREATE INDEX idx_mov_created ON public.stock_movements USING btree (created_at DESC);

CREATE INDEX idx_mov_product_loc ON public.stock_movements USING btree (product_id, location_id);

CREATE INDEX idx_mov_source ON public.stock_movements USING btree (source_type, source_id);

CREATE INDEX idx_mpesa_phone ON public.mpesa_transactions USING btree (phone);

CREATE INDEX idx_mpesa_sale ON public.mpesa_transactions USING btree (sale_id);

CREATE INDEX idx_notif_user ON public.notifications USING btree (user_id, is_read, created_at DESC);

CREATE INDEX idx_payments_paid ON public.payments USING btree (paid_at DESC);

CREATE INDEX idx_payments_sale ON public.payments USING btree (sale_id);

CREATE INDEX idx_po_status ON public.purchase_orders USING btree (status);

CREATE INDEX idx_po_supplier ON public.purchase_orders USING btree (supplier_id);

CREATE INDEX idx_poi_po ON public.purchase_order_items USING btree (purchase_order_id);

CREATE INDEX idx_price_history_product ON public.product_price_history USING btree (product_id, changed_at DESC);

CREATE INDEX idx_products_active ON public.products USING btree (is_active);

CREATE INDEX idx_products_brand ON public.products USING btree (brand_id);

CREATE INDEX idx_products_category ON public.products USING btree (category_id);

CREATE INDEX idx_products_name_trgm ON public.products USING gin (name public.gin_trgm_ops);

CREATE INDEX idx_register_status ON public.cash_register_sessions USING btree (status);

CREATE INDEX idx_returns_sale ON public.sale_returns USING btree (sale_id);

CREATE INDEX idx_sales_customer ON public.sales USING btree (customer_id);

CREATE INDEX idx_sales_register ON public.sales USING btree (register_session_id);

CREATE INDEX idx_sales_sold_at ON public.sales USING btree (sold_at DESC);

CREATE INDEX idx_sales_status ON public.sales USING btree (status, payment_status);

CREATE INDEX idx_si_product ON public.sale_items USING btree (product_id);

CREATE INDEX idx_si_sale ON public.sale_items USING btree (sale_id);

CREATE INDEX idx_sp_supplier ON public.supplier_payments USING btree (supplier_id);

CREATE INDEX idx_sti_take ON public.stock_take_items USING btree (stock_take_id);

CREATE INDEX idx_user_tokens_lookup ON public.user_tokens USING btree (token_hash);

CREATE INDEX idx_user_tokens_user ON public.user_tokens USING btree (user_id, type);

CREATE INDEX idx_visits_customer ON public.customer_visits USING btree (customer_id, visited_at DESC);

CREATE UNIQUE INDEX uq_customer_group_default ON public.customer_groups USING btree (is_default) WHERE is_default;

CREATE UNIQUE INDEX uq_customers_phone ON public.customers USING btree (phone) WHERE (phone IS NOT NULL);

CREATE UNIQUE INDEX uq_location_default ON public.locations USING btree (is_default) WHERE is_default;

CREATE UNIQUE INDEX uq_tax_default ON public.tax_rates USING btree (is_default) WHERE is_default;

CREATE UNIQUE INDEX uq_users_email ON public.users USING btree (lower((email)::text));

CREATE OR REPLACE VIEW public.v_expiring_batches AS
 SELECT b.id AS batch_id,
    p.id AS product_id,
    p.name,
    b.batch_number,
    b.expiry_date,
    (b.expiry_date - CURRENT_DATE) AS days_left,
    (b.expiry_date < CURRENT_DATE) AS is_expired,
    (sum(bs.on_hand))::integer AS on_hand
   FROM ((public.batches b
     JOIN public.products p ON ((p.id = b.product_id)))
     JOIN public.batch_stock_levels bs ON ((bs.batch_id = b.id)))
  WHERE ((b.expiry_date IS NOT NULL) AND (b.expiry_date <= (CURRENT_DATE + ( SELECT shop_settings.expiry_alert_days
           FROM public.shop_settings
         LIMIT 1))))
  GROUP BY b.id, p.id
 HAVING (sum(bs.on_hand) > 0)
  ORDER BY b.expiry_date;

CREATE OR REPLACE VIEW public.v_product_stock AS
 SELECT p.id AS product_id,
    p.sku,
    p.name,
    p.reorder_level,
    p.reorder_qty,
    (COALESCE(sum(sl.on_hand), (0)::bigint))::integer AS on_hand,
    (COALESCE(sum(sl.on_hand), (0)::bigint) <= p.reorder_level) AS needs_reorder
   FROM (public.products p
     LEFT JOIN public.stock_levels sl ON ((sl.product_id = p.id)))
  WHERE p.is_active
  GROUP BY p.id;

CREATE TRIGGER customer_return_stats AFTER INSERT ON public.sale_returns FOR EACH ROW EXECUTE FUNCTION public.trg_customer_return_stats();

CREATE TRIGGER customer_sale_stats AFTER INSERT OR UPDATE OF status ON public.sales FOR EACH ROW EXECUTE FUNCTION public.trg_customer_sale_stats();

CREATE TRIGGER customer_visit_stats AFTER INSERT ON public.customer_visits FOR EACH ROW EXECUTE FUNCTION public.trg_customer_visit_stats();

CREATE TRIGGER loyalty_apply BEFORE INSERT ON public.loyalty_transactions FOR EACH ROW EXECUTE FUNCTION public.trg_loyalty_apply();

CREATE TRIGGER product_price_history AFTER UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.trg_product_price_history();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.customers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.mpesa_transactions FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.products FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.purchase_orders FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.sales FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.shop_settings FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.suppliers FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER set_updated_at BEFORE UPDATE ON public.users FOR EACH ROW EXECUTE FUNCTION public.set_updated_at();

CREATE TRIGGER stock_movement_apply BEFORE INSERT ON public.stock_movements FOR EACH ROW EXECUTE FUNCTION public.trg_stock_movement_apply();

CREATE TRIGGER stock_movement_immutable BEFORE DELETE OR UPDATE ON public.stock_movements FOR EACH ROW EXECUTE FUNCTION public.trg_stock_movement_immutable();

CREATE TRIGGER sync_sale_payment AFTER INSERT OR DELETE OR UPDATE ON public.payments FOR EACH ROW EXECUTE FUNCTION public.trg_sync_sale_payment();

ALTER TABLE ONLY public.audit_logs
    ADD CONSTRAINT audit_logs_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.batch_stock_levels
    ADD CONSTRAINT batch_stock_levels_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.batch_stock_levels
    ADD CONSTRAINT batch_stock_levels_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.batches
    ADD CONSTRAINT batches_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.cash_register_sessions
    ADD CONSTRAINT cash_register_sessions_closed_by_fkey FOREIGN KEY (closed_by) REFERENCES public.users(id);

ALTER TABLE ONLY public.cash_register_sessions
    ADD CONSTRAINT cash_register_sessions_opened_by_fkey FOREIGN KEY (opened_by) REFERENCES public.users(id);

ALTER TABLE ONLY public.categories
    ADD CONSTRAINT categories_parent_id_fkey FOREIGN KEY (parent_id) REFERENCES public.categories(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.customer_notes
    ADD CONSTRAINT customer_notes_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.customer_notes
    ADD CONSTRAINT customer_notes_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.customer_visits
    ADD CONSTRAINT customer_visits_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.customer_visits
    ADD CONSTRAINT customer_visits_served_by_fkey FOREIGN KEY (served_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.customers
    ADD CONSTRAINT customers_customer_group_id_fkey FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.expense_categories(id);

ALTER TABLE ONLY public.expenses
    ADD CONSTRAINT expenses_recorded_by_fkey FOREIGN KEY (recorded_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT fk_loyalty_sale FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.goods_received_notes
    ADD CONSTRAINT goods_received_notes_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_grn_id_fkey FOREIGN KEY (grn_id) REFERENCES public.goods_received_notes(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.grn_items
    ADD CONSTRAINT grn_items_purchase_order_item_id_fkey FOREIGN KEY (purchase_order_item_id) REFERENCES public.purchase_order_items(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT loyalty_transactions_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.loyalty_transactions
    ADD CONSTRAINT loyalty_transactions_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.mpesa_transactions
    ADD CONSTRAINT mpesa_transactions_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.notifications
    ADD CONSTRAINT notifications_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_mpesa_transaction_id_fkey FOREIGN KEY (mpesa_transaction_id) REFERENCES public.mpesa_transactions(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_received_by_fkey FOREIGN KEY (received_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.payments
    ADD CONSTRAINT payments_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_group_prices
    ADD CONSTRAINT product_group_prices_customer_group_id_fkey FOREIGN KEY (customer_group_id) REFERENCES public.customer_groups(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_group_prices
    ADD CONSTRAINT product_group_prices_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_price_history
    ADD CONSTRAINT product_price_history_changed_by_fkey FOREIGN KEY (changed_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.product_price_history
    ADD CONSTRAINT product_price_history_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_suppliers
    ADD CONSTRAINT product_suppliers_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.product_suppliers
    ADD CONSTRAINT product_suppliers_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_brand_id_fkey FOREIGN KEY (brand_id) REFERENCES public.brands(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_category_id_fkey FOREIGN KEY (category_id) REFERENCES public.categories(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_tax_rate_id_fkey FOREIGN KEY (tax_rate_id) REFERENCES public.tax_rates(id);

ALTER TABLE ONLY public.products
    ADD CONSTRAINT products_unit_id_fkey FOREIGN KEY (unit_id) REFERENCES public.units(id);

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.purchase_order_items
    ADD CONSTRAINT purchase_order_items_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_approved_by_fkey FOREIGN KEY (approved_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.purchase_orders
    ADD CONSTRAINT purchase_orders_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_permission_id_fkey FOREIGN KEY (permission_id) REFERENCES public.permissions(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.role_permissions
    ADD CONSTRAINT role_permissions_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.sale_items
    ADD CONSTRAINT sale_items_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_sale_item_id_fkey FOREIGN KEY (sale_item_id) REFERENCES public.sale_items(id);

ALTER TABLE ONLY public.sale_return_items
    ADD CONSTRAINT sale_return_items_sale_return_id_fkey FOREIGN KEY (sale_return_id) REFERENCES public.sale_returns(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_processed_by_fkey FOREIGN KEY (processed_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.sale_returns
    ADD CONSTRAINT sale_returns_sale_id_fkey FOREIGN KEY (sale_id) REFERENCES public.sales(id);

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_customer_id_fkey FOREIGN KEY (customer_id) REFERENCES public.customers(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_register_session_id_fkey FOREIGN KEY (register_session_id) REFERENCES public.cash_register_sessions(id);

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_sold_by_fkey FOREIGN KEY (sold_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.sales
    ADD CONSTRAINT sales_voided_by_fkey FOREIGN KEY (voided_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.stock_adjustment_items
    ADD CONSTRAINT stock_adjustment_items_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.stock_adjustment_items
    ADD CONSTRAINT stock_adjustment_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.stock_adjustment_items
    ADD CONSTRAINT stock_adjustment_items_stock_adjustment_id_fkey FOREIGN KEY (stock_adjustment_id) REFERENCES public.stock_adjustments(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.stock_adjustments
    ADD CONSTRAINT stock_adjustments_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.stock_adjustments
    ADD CONSTRAINT stock_adjustments_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.stock_levels
    ADD CONSTRAINT stock_levels_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.stock_levels
    ADD CONSTRAINT stock_levels_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.stock_movements
    ADD CONSTRAINT stock_movements_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.stock_take_items
    ADD CONSTRAINT stock_take_items_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.stock_take_items
    ADD CONSTRAINT stock_take_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.stock_take_items
    ADD CONSTRAINT stock_take_items_stock_take_id_fkey FOREIGN KEY (stock_take_id) REFERENCES public.stock_takes(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.stock_takes
    ADD CONSTRAINT stock_takes_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.stock_takes
    ADD CONSTRAINT stock_takes_started_by_fkey FOREIGN KEY (started_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.stock_transfer_items
    ADD CONSTRAINT stock_transfer_items_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.stock_transfer_items
    ADD CONSTRAINT stock_transfer_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.stock_transfer_items
    ADD CONSTRAINT stock_transfer_items_stock_transfer_id_fkey FOREIGN KEY (stock_transfer_id) REFERENCES public.stock_transfers(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_from_location_id_fkey FOREIGN KEY (from_location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.stock_transfers
    ADD CONSTRAINT stock_transfers_to_location_id_fkey FOREIGN KEY (to_location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_grn_id_fkey FOREIGN KEY (grn_id) REFERENCES public.goods_received_notes(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_paid_by_fkey FOREIGN KEY (paid_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_purchase_order_id_fkey FOREIGN KEY (purchase_order_id) REFERENCES public.purchase_orders(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.supplier_payments
    ADD CONSTRAINT supplier_payments_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);

ALTER TABLE ONLY public.supplier_return_items
    ADD CONSTRAINT supplier_return_items_batch_id_fkey FOREIGN KEY (batch_id) REFERENCES public.batches(id);

ALTER TABLE ONLY public.supplier_return_items
    ADD CONSTRAINT supplier_return_items_product_id_fkey FOREIGN KEY (product_id) REFERENCES public.products(id);

ALTER TABLE ONLY public.supplier_return_items
    ADD CONSTRAINT supplier_return_items_supplier_return_id_fkey FOREIGN KEY (supplier_return_id) REFERENCES public.supplier_returns(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.supplier_returns
    ADD CONSTRAINT supplier_returns_created_by_fkey FOREIGN KEY (created_by) REFERENCES public.users(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.supplier_returns
    ADD CONSTRAINT supplier_returns_grn_id_fkey FOREIGN KEY (grn_id) REFERENCES public.goods_received_notes(id) ON DELETE SET NULL;

ALTER TABLE ONLY public.supplier_returns
    ADD CONSTRAINT supplier_returns_location_id_fkey FOREIGN KEY (location_id) REFERENCES public.locations(id);

ALTER TABLE ONLY public.supplier_returns
    ADD CONSTRAINT supplier_returns_supplier_id_fkey FOREIGN KEY (supplier_id) REFERENCES public.suppliers(id);

ALTER TABLE ONLY public.user_tokens
    ADD CONSTRAINT user_tokens_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.users(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_role_id_fkey FOREIGN KEY (role_id) REFERENCES public.roles(id);

-- =====================================================================================
-- MAPHONES ADDITIONS: IMEI / serial tracking and warranty
-- =====================================================================================
ALTER TABLE products ADD COLUMN requires_imei BOOLEAN NOT NULL DEFAULT FALSE;
ALTER TABLE products ADD COLUMN warranty_months INT NOT NULL DEFAULT 0 CHECK (warranty_months >= 0);

-- One row per physical device. Quantity still lives in the stock ledger; this register says WHICH units.
CREATE TABLE product_units (
  id           BIGSERIAL PRIMARY KEY,
  product_id   INT NOT NULL REFERENCES products(id),
  imei         VARCHAR(40) NOT NULL,
  location_id  INT REFERENCES locations(id),
  status       VARCHAR(24) NOT NULL DEFAULT 'in_stock'
               CHECK (status IN ('in_stock', 'sold', 'defective', 'lost', 'supplier_return')),
  unit_cost    NUMERIC(12,2),
  supplier_id  INT,
  grn_id       INT,
  sale_item_id BIGINT,
  received_at  TIMESTAMPTZ NOT NULL DEFAULT NOW(),
  sold_at      TIMESTAMPTZ,
  created_by   INT,
  CONSTRAINT uq_product_units_imei UNIQUE (imei)
);
CREATE INDEX idx_product_units_product ON product_units (product_id, status, location_id);
CREATE INDEX idx_product_units_sale_item ON product_units (sale_item_id);

ALTER TABLE sale_items ADD COLUMN imeis TEXT[];
ALTER TABLE sale_items ADD COLUMN warranty_months INT NOT NULL DEFAULT 0;
ALTER TABLE sale_items ADD COLUMN warranty_expires DATE;

-- Should always be empty: lists IMEI products whose device count differs from their stock quantity.
CREATE VIEW v_device_integrity_check AS
SELECT p.id AS product_id, p.name, sl.location_id, sl.on_hand AS stock_quantity, COALESCE(u.n, 0) AS devices_in_stock
  FROM products p
  JOIN stock_levels sl ON sl.product_id = p.id
  LEFT JOIN (SELECT product_id, location_id, COUNT(*)::INT AS n FROM product_units WHERE status = 'in_stock' GROUP BY product_id, location_id) u
         ON u.product_id = p.id AND u.location_id = sl.location_id
 WHERE p.requires_imei AND sl.on_hand <> COALESCE(u.n, 0);

-- =====================================================================================
-- SEED DATA
-- =====================================================================================
INSERT INTO roles (id, name, description) VALUES
  (1, 'admin', 'Full access'),
  (2, 'manager', 'Runs the shop: stock, purchasing, reports'),
  (3, 'cashier', 'Serves customers and takes payments'),
  (4, 'stock_keeper', 'Receives and manages stock');

INSERT INTO permissions (id, code) VALUES
  (1,'products.view'),(2,'products.manage'),(3,'stock.view'),(4,'stock.adjust'),(5,'stock.count'),(6,'stock.transfer'),
  (7,'purchases.view'),(8,'purchases.manage'),(9,'purchases.receive'),(10,'purchases.pay'),
  (11,'sales.create'),(12,'sales.view'),(13,'sales.discount'),(14,'sales.void'),(15,'sales.refund'),
  (16,'customers.view'),(17,'customers.manage'),(18,'suppliers.manage'),(19,'expenses.manage'),
  (20,'reports.view'),(21,'users.manage'),(22,'settings.manage');

-- admin: everything (1-22); manager: 1-20; cashier: view products/stock, sell, customers; stock_keeper: stock + receiving
INSERT INTO role_permissions (role_id, permission_id)
SELECT 1, id FROM permissions
UNION ALL SELECT 2, id FROM permissions WHERE id <= 20
UNION ALL SELECT 3, id FROM permissions WHERE id IN (1, 3, 11, 12, 16, 17)
UNION ALL SELECT 4, id FROM permissions WHERE id IN (1, 2, 3, 4, 5, 6, 7, 9, 18);

INSERT INTO tax_rates (id, name, rate, is_default) VALUES (1, 'VAT 16%', 16.00, TRUE), (2, 'Zero rated', 0.00, FALSE), (3, 'Exempt', 0.00, FALSE);

INSERT INTO units (id, name, abbreviation) VALUES (1, 'Piece', 'pc'), (2, 'Box', 'box'), (3, 'Pack', 'pk'), (4, 'Set', 'set'), (5, 'Kit', 'kit');

INSERT INTO locations (id, name, type, is_default, is_active) VALUES (1, 'Shop Floor', 'shop_floor', TRUE, TRUE), (2, 'Store Room', 'store_room', FALSE, TRUE);

INSERT INTO customer_groups (id, name, discount_percent, is_default) VALUES (1, 'Retail', 0.00, TRUE), (2, 'Wholesale', 0.00, FALSE);

INSERT INTO expense_categories (id, name) VALUES
  (1,'Rent'),(2,'Utilities'),(3,'Salaries'),(4,'Transport'),(5,'Marketing'),(6,'Licences & Permits'),
  (7,'Repairs & Maintenance'),(8,'Supplies'),(9,'Airtime & Internet'),(10,'Other');

INSERT INTO shop_settings (id, shop_name, currency) VALUES (1, 'Maphones', 'KES');

INSERT INTO categories (name) VALUES
  ('Smartphones'),('Feature Phones'),('Tablets'),('Smartwatches'),('Phone Cases & Covers'),('Screen Protectors'),
  ('Chargers & Cables'),('Power Banks'),('Earphones & Headphones'),('Speakers'),('Memory Cards & Storage'),
  ('Phone Parts & Repairs'),('SIM Cards & Airtime');

INSERT INTO brands (name) VALUES
  ('Samsung'),('Apple'),('Tecno'),('Infinix'),('itel'),('Xiaomi'),('Redmi'),('Oppo'),('Realme'),('Vivo'),
  ('Nokia'),('Huawei'),('Honor'),('Oraimo'),('Anker'),('JBL'),('Generic');

-- Move every id sequence past the rows seeded above.
DO $$
BEGIN
  PERFORM setval('public.roles_id_seq', (SELECT MAX(id) FROM roles));
  PERFORM setval('public.permissions_id_seq', (SELECT MAX(id) FROM permissions));
  PERFORM setval('public.tax_rates_id_seq', (SELECT MAX(id) FROM tax_rates));
  PERFORM setval('public.units_id_seq', (SELECT MAX(id) FROM units));
  PERFORM setval('public.locations_id_seq', (SELECT MAX(id) FROM locations));
  PERFORM setval('public.customer_groups_id_seq', (SELECT MAX(id) FROM customer_groups));
  PERFORM setval('public.expense_categories_id_seq', (SELECT MAX(id) FROM expense_categories));
END $$;
