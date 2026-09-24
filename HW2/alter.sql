-- 1. увеличить длину поля name в recipe
alter table recipe
    alter column name type varchar(100);

-- 2. значение по умолчанию для amount_type
alter table r_ingredients
    alter column amount_type set default 'г';

-- 3. check-ограничение на amount > 0
alter table r_ingredients
    add constraint chk_amount check (amount > 0);