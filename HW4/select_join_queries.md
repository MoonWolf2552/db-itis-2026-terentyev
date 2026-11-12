# HW4: SELECT + JOIN

## 1. SELECT + 2 запроса с CASE

### 1.1. Категория стоимости заказа

**Что хотим получить:** вывести идентификатор заказа, его цену и категорию стоимости:
- `дешёвый` — цена меньше 5000;
- `средний` — цена от 5000 до 15000;
- `дорогой` — цена больше 15000.

```sql
SELECT
    order_id,
    price,
    CASE
        WHEN price < 5000 THEN 'дешёвый'
        WHEN price BETWEEN 5000 AND 15000 THEN 'средний'
        ELSE 'дорогой'
    END AS price_category
FROM "order"
ORDER BY price;
```

**Результат (пример):**

<img width="663" height="204" alt="image" src="https://github.com/user-attachments/assets/85320c5a-641d-4ebc-9fc6-6c67ea7d314d" />

---

### 1.2. Статус заказа по дате выдачи

**Что хотим получить:** вывести идентификатор заказа, дату приёма, дату выдачи и статус:
- если дата выдачи не заполнена (`NULL`) — `в работе`;
- если дата выдачи заполнена — `завершён`.

```sql
SELECT
    order_id,
    date_of_receipt,
    date_of_issue,
    CASE
        WHEN date_of_issue IS NULL THEN 'в работе'
        ELSE 'завершён'
    END AS order_status
FROM "order"
ORDER BY order_id;
```

**Результат (пример):**

<img width="1022" height="202" alt="image" src="https://github.com/user-attachments/assets/6495ca2e-c3c6-4e00-9b70-8afbd1d0133f" />

---

### 1.3. Выборка всех данных из таблицы

**Что хотим получить:** вывести все строки и все столбцы таблиц `"order"` и `service`.

```sql
SELECT * FROM "order";

SELECT * FROM service;
```

**Результат (пример):**

<img width="1394" height="207" alt="image" src="https://github.com/user-attachments/assets/6df836a1-039f-47dc-8453-e3d73ed0fc51" />
<img width="1334" height="237" alt="image" src="https://github.com/user-attachments/assets/2665585e-99cc-4ce0-ac39-ee24031d401c" />

---

### 1.4. Выборка отдельных столбцов

**Что хотим получить:** вывести только нужные столбцы из таблиц `"order"` и `master`.

```sql
SELECT order_id, price
FROM "order";

SELECT full_name, specialization
FROM master;
```

**Результат (пример):**

<img width="394" height="205" alt="image" src="https://github.com/user-attachments/assets/249c1791-c293-41e4-a6d2-a475060831c3" />
<img width="512" height="204" alt="image" src="https://github.com/user-attachments/assets/939667ea-20d0-49f4-a7c5-7045f96d3e36" />

---

### 1.5. Присвоение новых имён столбцам (AS)

**Что хотим получить:** вывести столбцы с русскими псевдонимами.

```sql
SELECT
    order_id AS Номер_заказа,
    price AS Стоимость
FROM "order";

SELECT
    full_name AS ФИО_мастера
FROM master;
```

**Результат (пример):**

<img width="485" height="205" alt="image" src="https://github.com/user-attachments/assets/0648a563-863b-4883-bcc6-c84d57e84401" />
<img width="223" height="202" alt="image" src="https://github.com/user-attachments/assets/b9fb0832-618c-41d7-8c4c-b39a88deac52" />

---

### 1.6. Вычисляемый столбец

**Что хотим получить:** посчитать предоплату 10% от цены заказа и полное имя автомобиля.

```sql
SELECT
    order_id,
    price,
    price * 0.1 AS deposit
FROM "order";

SELECT
    car_id,
    make,
    model,
    make || ' ' || model AS car_name
FROM car;
```

**Результат (пример):**

<img width="582" height="202" alt="image" src="https://github.com/user-attachments/assets/49419344-57f2-4f58-ba19-bccb4451c1b6" />
<img width="725" height="236" alt="image" src="https://github.com/user-attachments/assets/12a2772f-f665-461a-83ef-d7a7983991a2" />

---

### 1.7. Математические функции

**Что хотим получить:** посчитать НДС 18% с округлением и количество тысяч с округлением вверх.

```sql
SELECT
    order_id,
    price,
    ROUND(price * 0.18, 2) AS vat
FROM "order";

SELECT
    order_id,
    price,
    CEIL(price / 1000.0) AS thousands
FROM "order";
```

**Результат (пример):**

<img width="531" height="200" alt="image" src="https://github.com/user-attachments/assets/e560c378-1cf4-4cf2-a501-de3ee6efbedf" />
<img width="605" height="201" alt="image" src="https://github.com/user-attachments/assets/086b8cb8-5ac9-4691-91e6-d08cb53e3e65" />

---

### 1.8. Выборка по условию WHERE

**Что хотим получить:** вывести заказы дешевле 5000 и мастеров с `master_id > 1`.

```sql
SELECT order_id, price
FROM "order"
WHERE price < 5000;

SELECT full_name
FROM master
WHERE master_id > 1;
```

**Результат (пример):**

<img width="394" height="66" alt="image" src="https://github.com/user-attachments/assets/084edca3-ac82-4a1e-86f7-19744c4c3137" />
<img width="203" height="167" alt="image" src="https://github.com/user-attachments/assets/d4e4fc89-ad3b-4b1f-a4ea-80dc48b1bde2" />

---

### 1.9. Логические операции AND / OR

**Что хотим получить:** заказы в диапазоне 5000–15000 и заказы вне этого диапазона.

```sql
SELECT order_id, price
FROM "order"
WHERE price > 5000 AND price < 15000;

SELECT order_id, price
FROM "order"
WHERE price < 5000 OR price > 15000;
```

**Результат (пример):**

<img width="392" height="99" alt="image" src="https://github.com/user-attachments/assets/7e0b9191-0b29-4ac3-ab02-9f67cd2c2eb0" />
<img width="393" height="134" alt="image" src="https://github.com/user-attachments/assets/9515875b-c276-472b-b530-b7d6ba39159b" />

---

### 1.10. Операторы BETWEEN и IN

**Что хотим получить:** заказы с ценой от 5000 до 15000 и заказы конкретных мастеров.

```sql
SELECT order_id, price
FROM "order"
WHERE price BETWEEN 5000 AND 15000;

SELECT order_id, master_id
FROM "order"
WHERE master_id IN (1, 2, 3);
```

**Результат (пример):**

<img width="391" height="99" alt="image" src="https://github.com/user-attachments/assets/32f1eb96-8765-4914-a4f6-b67c76a6489a" />
<img width="441" height="168" alt="image" src="https://github.com/user-attachments/assets/636ad91c-ef0b-4787-a9a3-24a16c96fdfb" />

---

### 1.11. Сортировка ORDER BY

**Что хотим получить:** заказы по убыванию цены и мастеров по алфавиту.

```sql
SELECT order_id, price
FROM "order"
ORDER BY price DESC;

SELECT full_name
FROM master
ORDER BY full_name ASC;
```

**Результат (пример):**

<img width="395" height="200" alt="image" src="https://github.com/user-attachments/assets/9bb5e381-8cca-4e34-b7bb-635616ff54d0" />
<img width="199" height="205" alt="image" src="https://github.com/user-attachments/assets/0158c64d-296b-45e8-b392-4c699b9915a4" />

---

### 1.12. Оператор LIKE

**Что хотим получить:** мастеров, чья фамилия начинается на «И», и услуги, в названии которых есть «ремонт».

```sql
SELECT full_name
FROM master
WHERE full_name LIKE 'И%';

SELECT title
FROM service
WHERE title LIKE '%ремонт%';
```

**Результат (пример):**

<img width="203" height="70" alt="image" src="https://github.com/user-attachments/assets/406cd5e4-a5b2-4158-b3eb-5fc4bb545d78" />
<img width="158" height="66" alt="image" src="https://github.com/user-attachments/assets/780be088-c421-4f01-8986-a8fdd9b8b1f1" />

---

### 1.13. Уникальные значения DISTINCT

**Что хотим получить:** уникальных мастеров, у которых есть заказы, и уникальные марки автомобилей.

```sql
SELECT DISTINCT master_id
FROM "order";

SELECT DISTINCT make
FROM car;
```

**Результат (пример):**

<img width="203" height="167" alt="image" src="https://github.com/user-attachments/assets/bc3487bc-732f-4365-881d-4db8c9bb5803" />
<img width="155" height="238" alt="image" src="https://github.com/user-attachments/assets/eb99a14e-4286-4bbf-8a7a-49090ff2a19d" />

---

### 1.14. LIMIT

**Что хотим получить:** 5 самых дорогих заказов.

```sql
SELECT order_id, price
FROM "order"
ORDER BY price DESC
LIMIT 5;
```

**Результат (пример):**

<img width="393" height="204" alt="image" src="https://github.com/user-attachments/assets/79246cc1-2f2e-4bdf-a11d-d059ea374072" />

---

### 1.15. LIMIT + OFFSET

**Что хотим получить:** следующие 5 самых дорогих заказов (пропустить первые 5).

```sql
SELECT order_id, price
FROM "order"
ORDER BY price DESC
LIMIT 5 OFFSET 5;
```

**Результат (пример):**

<img width="382" height="77" alt="image" src="https://github.com/user-attachments/assets/a9c3c490-007c-4550-aa7a-2ebd0f9563d1" />

---

## 2. JOIN (все виды)

### 2.1. INNER JOIN

**Что хотим получить:** вывести номер заказа, марку и модель автомобиля, а также ФИО мастера.

```sql
SELECT
    o.order_id,
    c.make,
    c.model,
    m.full_name AS master_name
FROM "order" o
INNER JOIN car    c ON o.car_id    = c.car_id
INNER JOIN master m ON o.master_id = m.master_id
ORDER BY o.order_id;
```

**Результат (пример):**

<img width="781" height="203" alt="image" src="https://github.com/user-attachments/assets/91fb8408-706b-4b14-9185-0decb4af787d" />

---

### 2.2. LEFT JOIN

**Что хотим получить:** вывести ФИО всех клиентов и номера их автомобилей. Если у клиента нет автомобиля — вместо номера вывести `NULL`.

```sql
SELECT
    cl.full_name,
    c.number_plate
FROM client cl
LEFT JOIN car c ON cl.client_id = c.client_id
ORDER BY cl.full_name;
```

**Результат (пример):**

<img width="578" height="237" alt="image" src="https://github.com/user-attachments/assets/665d763d-8cf1-4308-a2c2-fd70c4026813" />

---

### 2.3. RIGHT JOIN

**Что хотим получить:** вывести номер заказа и ФИО мастера. Если у заказа нет мастера — вместо имени вывести `NULL`.

```sql
SELECT
    o.order_id,
    m.full_name AS master_name
FROM master m
RIGHT JOIN "order" o ON m.master_id = o.master_id
ORDER BY o.order_id;
```

**Результат (пример):**

<img width="462" height="202" alt="image" src="https://github.com/user-attachments/assets/d730e45a-47f1-4253-a8e7-4c51f5dfd13f" />

---

### 2.4. CROSS JOIN

**Что хотим получить:** вывести все возможные пары «мастер — услуга» (декартово произведение).

```sql
SELECT
    m.full_name AS master_name,
    s.title     AS service_title
FROM master m
CROSS JOIN service s
ORDER BY m.full_name, s.title;
```

**Результат (фрагмент):**

<img width="561" height="479" alt="image" src="https://github.com/user-attachments/assets/ef41eb05-f294-46e3-b5ee-139a5280e6f6" />

---

### 2.5. FULL OUTER JOIN

**Что хотим получить:** вывести ФИО мастера и номер заказа. В результат должны попасть:
- все мастера, даже если у них нет заказов;
- все заказы, даже если у них нет мастера.

```sql
SELECT
    m.full_name AS master_name,
    o.order_id
FROM master m
FULL OUTER JOIN "order" o ON m.master_id = o.master_id
ORDER BY m.full_name, o.order_id;
```

**Результат (пример):**

<img width="466" height="235" alt="image" src="https://github.com/user-attachments/assets/e35c15ab-f985-4017-a123-d3efce8bcb96" />

---

### 2.6. INNER JOIN + LEFT JOIN (несколько таблиц)

**Что хотим получить:** вывести номер заказа, ФИО клиента, марку автомобиля и название услуги, оказанной по заказу.

```sql
SELECT
    o.order_id,
    cl.full_name AS client_name,
    c.make,
    c.model,
    s.title AS service_title
FROM "order" o
INNER JOIN car     c  ON o.car_id    = c.car_id
INNER JOIN client  cl ON c.client_id = cl.client_id
LEFT  JOIN order_service os ON o.order_id = os.order_id
LEFT  JOIN service s        ON os.servie_id = s.service_id
ORDER BY o.order_id;
```

**Результат (пример):**

<img width="1112" height="304" alt="image" src="https://github.com/user-attachments/assets/266d418c-c576-4ad1-96cb-b7eb74d08b1c" />
