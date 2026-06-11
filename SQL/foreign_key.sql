-- Foreign key constraints for menu table

ALTER TABLE menu
ADD CONSTRAINT menu_r_id_fkey
FOREIGN KEY (r_id) REFERENCES restaurant(id);

ALTER TABLE menu
ADD CONSTRAINT menu_f_id_fkey
FOREIGN KEY (f_id) REFERENCES food(f_id);

-----------------------------------------------------

-- Foreign key constraints for orders table

ALTER TABLE orders
ADD CONSTRAINT orders_user_id_fkey
FOREIGN KEY (user_id) REFERENCES users(user_id);

ALTER TABLE orders
ADD CONSTRAINT orders_r_id_fkey
FOREIGN KEY (r_id) REFERENCES restaurant(id);
