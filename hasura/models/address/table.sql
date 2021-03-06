/* TABLE */
CREATE TABLE "address" (
    id int GENERATED BY DEFAULT AS IDENTITY PRIMARY KEY,
    name text,
    created_at timestamptz DEFAULT now() NOT NULL,
    updated_at timestamptz DEFAULT now() NOT NULL,
    user_id int NOT NULL,
    city text NOT NULL,
    state text NOT NULL,
    -- Use text for zipcode to handle ZIP+4 extended zipcodes
    zipcode text NOT NULL,
    address_line_one text NOT NULL,
    address_line_two text
);

COMMENT ON TABLE address IS 'A physical billing/shipping address, attached to a user account';


/* FOREIGN KEYS */
ALTER TABLE ONLY public.address
    ADD CONSTRAINT address_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.user (id);


/* TRIGGERS */
CREATE TRIGGER set_address_updated_at
    BEFORE UPDATE ON public.address
    FOR EACH ROW
    EXECUTE FUNCTION public.set_current_timestamp_updated_at ();
