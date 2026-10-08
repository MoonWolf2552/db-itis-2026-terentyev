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
