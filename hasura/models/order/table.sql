/* TABLE */
CREATE TABLE "order" (
    id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    user_id int NOT NULL,
    billing_address_id int NOT NULL,
    shipping_address_id int NOT NULL,
    is_shipped boolean DEFAULT FALSE NOT NULL,
    order_total numeric,
    status text DEFAULT 'CREATED' NOT NULL
);

COMMENT ON TABLE "order" IS 'An order from a customer, containing one or more products and quantities';


/* FOREIGN KEYS */
ALTER TABLE ONLY public.order
    ADD CONSTRAINT order_billing_address_id_fkey FOREIGN KEY
	(billing_address_id) REFERENCES public.address (id);

ALTER TABLE ONLY public.order
    ADD CONSTRAINT order_shipping_address_id_fkey FOREIGN KEY
	(shipping_address_id) REFERENCES public.address (id);

ALTER TABLE ONLY public.order
    ADD CONSTRAINT order_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (id);

ALTER TABLE ONLY public.order
    ADD CONSTRAINT order_status_fkey FOREIGN KEY (status) REFERENCES
	public.order_status (status);


/*Functions*/
CREATE OR REPLACE FUNCTION public.gen_order_total ()
    RETURNS TRIGGER
    LANGUAGE plpgsql
    STABLE
    AS $function$
DECLARE
    sumtotal numeric;
BEGIN
    SELECT
        TRUNC(SUM(p.price), 2) INTO STRICT sumtotal
    FROM
        public.order o
        INNER JOIN public.order_product op ON (o.id = op.order_id)
        INNER JOIN public.product p ON (op.product_id = p.id)
    WHERE
        o.id = OLD.id
    GROUP BY
        o.id;
    NEW.order_total := sumtotal;
    RETURN NEW;
EXCEPTION
    WHEN no_data_found THEN
        RAISE NOTICE 'No products found for %', OLD.id;
    RETURN NEW;
END;

$function$;


/* TRIGGERS */
CREATE TRIGGER set_order_updated_at
    BEFORE UPDATE ON public.order
    FOR EACH ROW
    EXECUTE FUNCTION public.set_current_timestamp_updated_at ();

CREATE TRIGGER sum_order
    BEFORE INSERT OR UPDATE ON public.order
    FOR EACH ROW
    EXECUTE PROCEDURE public.gen_order_total ();
