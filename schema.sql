create table client (
    client_id serial primary key,
    full_name varchar(40),
    phone_number varchar(10),
    email varchar(25)
);

create table car (
    car_id serial primary key,
    client_id integer references client (client_id),
    make varchar(10),
    model varchar(20),
    number_plate varchar(10)
);

create table master (
    master_id serial primary key,
    full_name varchar(40),
    specialization varchar(20),
    phone_number varchar(10)
);

create table "order" (
    order_id serial primary key,
    car_id integer references car (car_id),
    master_id integer references master (master_id),
    date_of_receipt date,
    date_of_issue date,
    status varchar(10),
    price integer
);

create table service (
    service_id serial primary key,
    title varchar(20),
    description varchar(50),
    price integer,
    standart_hour integer
);

create table order_service (
    order_id integer references "order" (order_id),
    servie_id integer references service (service_id),
    amount integer,
    actual_cots integer
);