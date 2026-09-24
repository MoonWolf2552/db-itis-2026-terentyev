create table recipe
(
    id       serial primary key,
    name     varchar(45),
    category varchar(45),
    time_p   int,
    level    varchar(45),
    type     varchar(45)
);

create table r_steps
(
    id        serial primary key,
    recipe_id int references recipe (id),
    title     varchar(45),
    content   text,
    image     varchar(45),
    steps     text
);

create table product
(
    product_id serial primary key,
    name       varchar(45),
    measure    varchar(45)
);

create table r_ingredients
(
    id          serial primary key,
    recipe_id   int references recipe (id),
    product_id  int references product (product_id),
    amount      int,
    amount_type varchar(45)
);