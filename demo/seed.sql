CREATE TABLE users (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  session_token VARCHAR(255) NOT NULL,
  password_digest VARCHAR(255) NOT NULL
);

CREATE TABLE restaurants (
  id INTEGER PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  owner_id INTEGER NOT NULL,

  FOREIGN KEY(owner_id) REFERENCES user(id)
);

CREATE TABLE favorites (
  id INTEGER PRIMARY KEY,
  user_id INTEGER NOT NULL,
  restaurant_id INTEGER NOT NULL,

  FOREIGN KEY(user_id) REFERENCES user(id),
  FOREIGN KEY(restaurant_id) REFERENCES restaurant(id)
);

INSERT INTO
  users (id, name, session_token, password_digest)
VALUES
  (1, "Guest", "fwWdMRzrjpUnl7ogjTiphg",
   "$2a$10$QfWj2Ny/pRdu9gNBv/lw/uaZ5bX/Jsy1fOpyTMBsHMThEjZHeV0ju"),
  (2, "Moritz", "6dS_Sx74HZI4b-h2CDfNlw",
   "$2a$10$HRP.o09UXm4iGDojA/rY1.zZ.qm7KS7Y6DqAdxwfLAxNB/hlMsZMi");

INSERT INTO
  restaurants (id, name, owner_id)
VALUES
  (1, "Nasch", 2),
  (2, "Speisekammer", 2),
  (3, "Cafe Europa", 2),
  (4, "The Matterhorn Swiss Restaurant", 2);

INSERT INTO
  favorites (id, user_id, restaurant_id)
VALUES
  (1, 1, 1),
  (2, 1, 2);
