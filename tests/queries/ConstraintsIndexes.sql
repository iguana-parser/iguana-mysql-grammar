CREATE TABLE child (id INT, parent_id INT, PRIMARY KEY(id), UNIQUE KEY uq(parent_id), CONSTRAINT fk FOREIGN KEY(parent_id) REFERENCES parent(id) ON DELETE CASCADE, CONSTRAINT ck CHECK(id>0) ENFORCED);
CREATE INDEX ix ON child(parent_id DESC);
CREATE INDEX functional_ix ON child ((id+1));
DROP INDEX ix ON child;
