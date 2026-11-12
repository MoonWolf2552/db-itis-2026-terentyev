# HW6: Подзапросы

## База данных: автосервис

Схема БД:
- **client** (client_id, full_name, phone_number, email)
- **car** (car_id, client_id, make, model, number_plate)
- **master** (master_id, full_name, specialization, phone_number)
- **order** (order_id, car_id, master_id, date_of_receipt, date_of_issue, status, price)
- **service** (service_id, title, description, price, standart_hour)
- **order_service** (order_id, servie_id, amount, actual_cots)

---

## a. Подзапросы в SELECT

### Запрос 1. Средняя цена заказа в скалярном подзапросе

```sql
SELECT
    order_id,
    price,
    (SELECT AVG(price) FROM "order") AS avg_order_price
FROM "order";
```

**Результат:**  

<img width="672" height="202" alt="image" src="https://github.com/user-attachments/assets/a3ca90d3-1459-457f-a728-061f3d1fd00a" />

**Пояснение:** скалярный подзапрос возвращает одно значение — среднюю цену заказа.

---

### Запрос 2. Количество машин у каждого клиента

```sql
SELECT
    cl.full_name,
    (SELECT COUNT(*) FROM car c WHERE c.client_id = cl.client_id) AS cars_count
FROM client cl;
```

**Результат:**  

<img width="558" height="205" alt="image" src="https://github.com/user-attachments/assets/bf99f199-0ae4-4323-861e-4fa93543ce6a" />

**Пояснение:** для каждого клиента коррелированный подзапрос считает его машины.

---

## b. Подзапросы в FROM

### Запрос 1. Мастера и количество их заказов

```sql
SELECT *
FROM (
    SELECT master_id, COUNT(*) AS cnt
    FROM "order"
    GROUP BY master_id
) t
WHERE cnt >= 1;
```

**Результат:**  

<img width="378" height="168" alt="image" src="https://github.com/user-attachments/assets/24067b64-2850-4939-ae94-58b8ab0fb725" />

**Пояснение:** подзапрос в `FROM` выступает как временная таблица с агрегированными данными.

---

### Запрос 2. Машины, которые были в заказе ровно 1 раз

```sql
SELECT *
FROM (
    SELECT car_id, COUNT(*) AS cnt
    FROM "order"
    GROUP BY car_id
) t
WHERE cnt = 1;
```

**Результат:**  

<img width="349" height="204" alt="image" src="https://github.com/user-attachments/assets/503cb485-24c7-4a8a-abb8-e20a995fdeee" />

**Пояснение:** сначала во вложенном запросе считается количество заказов по машине, затем результат фильтруется.

---

## c. Подзапросы в WHERE

### Запрос 1. Заказы дороже средней цены

```sql
SELECT *
FROM "order"
WHERE price > (SELECT AVG(price) FROM "order");
```

**Результат:**  

<img width="1505" height="102" alt="image" src="https://github.com/user-attachments/assets/c9959093-6de3-47a3-a54a-b3b3f0e8f7e7" />

**Пояснение:** скалярный подзапрос возвращает среднюю цену, с ней сравнивается цена каждого заказа.

---

### Запрос 2. Клиенты, у которых есть Toyota

```sql
SELECT *
FROM client
WHERE client_id IN (
    SELECT client_id
    FROM car
    WHERE make = 'Toyota'
);
```

**Результат:**  

<img width="927" height="67" alt="image" src="https://github.com/user-attachments/assets/0aa9aff1-9b84-49ec-8761-e0f427122128" />

**Пояснение:** подзапрос возвращает список `client_id` владельцев Toyota, `IN` фильтрует клиентов.

---

## d. Подзапросы в HAVING

### Запрос 1. Мастера с более чем 1 заказом

```sql
SELECT master_id, COUNT(*) AS cnt
FROM "order"
GROUP BY master_id
HAVING COUNT(*) > (SELECT 1);
```

**Результат:**  

<img width="380" height="68" alt="image" src="https://github.com/user-attachments/assets/a54de85c-96aa-4af8-af40-3b521762a933" />

**Пояснение:** `HAVING` фильтрует уже сгруппированные строки; подзапрос возвращает пороговое значение.

---

### Запрос 2. Машины, суммарная стоимость заказов которых выше средней цены заказа

```sql
SELECT car_id, SUM(price) AS total
FROM "order"
GROUP BY car_id
HAVING SUM(price) > (SELECT AVG(price) FROM "order");
```

**Результат:**  

<img width="369" height="100" alt="image" src="https://github.com/user-attachments/assets/906580c5-cef9-43c1-980e-5b6a4ae1be48" />

**Пояснение:** сравнивается суммарная стоимость заказов по машине со средней ценой одного заказа.

---

## e. Оператор ALL

### Запрос 1. Услуги дешевле всех завершённых заказов

```sql
SELECT *
FROM service
WHERE price < ALL (
    SELECT price
    FROM "order"
    WHERE status = 'завершён'
);
```

**Результат:**  

<img width="1322" height="205" alt="image" src="https://github.com/user-attachments/assets/7b459b13-d8c7-452a-8bea-4b0ce4b9d567" />

**Пояснение:** условие истинно только если цена услуги меньше цены каждого завершённого заказа.

---

### Запрос 2. Мастера, у которых нет заказов в работе

```sql
SELECT *
FROM master
WHERE master_id <> ALL (
    SELECT master_id
    FROM "order"
    WHERE status = 'в работе'
);
```

**Результат:**  

<img width="971" height="99" alt="image" src="https://github.com/user-attachments/assets/5f1c2065-36e4-4492-bf11-b49cf8ffb695" />

**Пояснение:** `<> ALL` означает «не равен ни одному значению из набора».

---

## f. Оператор IN

### Запрос 1. Машины, участвовавшие в завершённых заказах

```sql
SELECT *
FROM car
WHERE car_id IN (
    SELECT car_id
    FROM "order"
    WHERE status = 'завершён'
);
```

**Результат:**  

<img width="981" height="99" alt="image" src="https://github.com/user-attachments/assets/38a36e3c-4f80-4d8e-a38c-0fdff273f0ec" />

**Пояснение:** `IN` проверяет, входит ли `car_id` в набор идентификаторов из подзапроса.

---

### Запрос 2. Услуги, которые заказывали в количестве >= 2

```sql
SELECT *
FROM service
WHERE service_id IN (
    SELECT servie_id
    FROM order_service
    WHERE amount >= 2
);
```

**Результат:**  

<img width="1244" height="64" alt="image" src="https://github.com/user-attachments/assets/43d30177-52e9-44a8-8149-eef832ce6982" />

**Пояснение:** подзапрос возвращает `servie_id`, для которых количество в заказе было не меньше 2.

---

## g. Оператор ANY

### Запрос 1. Заказы дороже хотя бы одной услуги

```sql
SELECT *
FROM "order"
WHERE price > ANY (
    SELECT price
    FROM service
);
```

**Результат:**  

<img width="1505" height="198" alt="image" src="https://github.com/user-attachments/assets/08a8bca2-9f17-4210-a559-4996512519ff" />

**Пояснение:** `> ANY` истинно, если цена заказа больше хотя бы одной цены услуги.

---

### Запрос 2. Клиенты, у которых есть BMW или Lada

```sql
SELECT *
FROM client
WHERE client_id = ANY (
    SELECT client_id
    FROM car
    WHERE make IN ('BMW', 'Lada')
);
```

**Результат:**  

<img width="979" height="100" alt="image" src="https://github.com/user-attachments/assets/fb0dcc4f-f3d9-4dd9-b391-a46925bf885d" />

**Пояснение:** `= ANY` работает как проверка вхождения в набор идентификаторов.

---

## h. EXISTS

### Запрос 1. Клиенты, у которых есть хотя бы одна машина

```sql
SELECT *
FROM client c
WHERE EXISTS (
    SELECT 1
    FROM car c2
    WHERE c2.client_id = c.client_id
);
```

**Результат:**  

<img width="1020" height="201" alt="image" src="https://github.com/user-attachments/assets/0c80482a-d578-40c9-9779-870a763e4e6b" />

**Пояснение:** `EXISTS` возвращает `TRUE`, если подзапрос находит хотя бы одну строку.

---

### Запрос 2. Услуги, которые хотя бы раз входили в заказ

```sql
SELECT *
FROM service s
WHERE EXISTS (
    SELECT 1
    FROM order_service os
    WHERE os.servie_id = s.service_id
);
```

**Результат:**  

<img width="1336" height="232" alt="image" src="https://github.com/user-attachments/assets/c9d2e5dc-8175-4310-acdd-eb5f347bfcb3" />

**Пояснение:** для каждой услуги проверяется наличие связанной записи в `order_service`.

---

## i. Сравнение по нескольким столбцам

### Запрос 1. Заказы, где пара (car_id, master_id) соответствует Toyota + двигатель

```sql
SELECT *
FROM "order" o
WHERE (o.car_id, o.master_id) IN (
    SELECT c.car_id, m.master_id
    FROM car c
    CROSS JOIN master m
    WHERE c.make = 'Toyota'
      AND m.specialization = 'Двигатель'
);
```

**Результат:**  

<img width="1503" height="62" alt="image" src="https://github.com/user-attachments/assets/a611c8d5-38c0-4dc5-a102-5cda3c486e9a" />

**Пояснение:** сравниваются сразу два столбца: идентификатор машины и идентификатор мастера.

---

### Запрос 2. Строки order_service с такими же (order_id, servie_id), как у дорогих фактических работ

```sql
SELECT *
FROM order_service
WHERE (order_id, servie_id) IN (
    SELECT order_id, servie_id
    FROM order_service
    WHERE actual_cots > 3000
);
```

**Результат:**  

<img width="852" height="135" alt="image" src="https://github.com/user-attachments/assets/3b335516-f9b6-476b-8080-a0d5d58cdacd" />

**Пояснение:** пара значений `(order_id, servie_id)` сравнивается с набором пар из подзапроса.

---

## j. Коррелированные подзапросы — 5 запросов

### Запрос 1. Средняя цена заказа у мастера для каждого заказа

```sql
SELECT
    o.order_id,
    o.price,
    (
        SELECT AVG(o2.price)
        FROM "order" o2
        WHERE o2.master_id = o.master_id
    ) AS avg_master_price
FROM "order" o;
```

**Результат:**  

<img width="686" height="201" alt="image" src="https://github.com/user-attachments/assets/112c815b-20bc-4352-a319-93aa31157fa4" />

**Пояснение:** подзапрос ссылается на `o.master_id` из внешнего запроса и выполняется для каждой строки.

---

### Запрос 2. Количество машин у каждого клиента

```sql
SELECT
    c.full_name,
    (
        SELECT COUNT(*)
        FROM car c2
        WHERE c2.client_id = c.client_id
    ) AS cnt_cars
FROM client c;
```

**Результат:**  

<img width="528" height="204" alt="image" src="https://github.com/user-attachments/assets/b73f60f6-061d-4c6b-a635-0cb57cfdfa22" />

**Пояснение:** для каждого клиента коррелированный подзапрос считает только его машины.

---

### Запрос 3. Сколько раз каждая услуга встречается в order_service

```sql
SELECT
    s.title,
    (
        SELECT COUNT(*)
        FROM order_service os
        WHERE os.servie_id = s.service_id
    ) AS usage_count
FROM service s;
```

**Результат:**  

<img width="470" height="238" alt="image" src="https://github.com/user-attachments/assets/21c2e472-4158-4f7b-9840-fd40c145570f" />

**Пояснение:** подзапрос зависит от `s.service_id` и считает использования услуги.

---

### Запрос 4. Суммарная стоимость заказов по каждому мастеру

```sql
SELECT
    m.full_name,
    (
        SELECT SUM(o.price)
        FROM "order" o
        WHERE o.master_id = m.master_id
    ) AS total_price
FROM master m;
```

**Результат:**  

<img width="476" height="198" alt="image" src="https://github.com/user-attachments/assets/0a5167a0-5efb-433c-9840-ec550c5195d5" />

**Пояснение:** для каждого мастера отдельно суммируются цены его заказов.

---

### Запрос 5. Количество заказов для каждой машины

```sql
SELECT
    c.car_id,
    c.number_plate,
    (
        SELECT COUNT(*)
        FROM "order" o
        WHERE o.car_id = c.car_id
    ) AS orders_count
FROM car c;
```

**Результат:**  

<img width="703" height="235" alt="image" src="https://github.com/user-attachments/assets/182cc3a7-5e60-42a9-84f2-82ea998036b2" />

**Пояснение:** подзапрос ссылается на `c.car_id` и считает заказы для каждой машины.
