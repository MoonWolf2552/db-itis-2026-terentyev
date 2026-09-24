-- 1. изменить уровень рецепта
update recipe
set level = 'средний'
where id = 1;

-- 2. обновить заголовок шага
update r_steps
set title = 'подготовка (обновлено)'
where id = 1;

-- 3. увеличить количество ингредиентов в 2 раза для рецепта 1
update r_ingredients
set amount = amount * 2
where recipe_id = 1;

-- 4. задать единицу измерения по умолчанию там, где пусто
update r_ingredients
set amount_type = 'г'
where amount_type is null;

-- 5. увеличить время приготовления на 10% для сложных блюд
update recipe
set time_p = time_p * 1.1
where level = 'сложный';