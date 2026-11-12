# HW6: CTE, UNION, оконные функции

## База данных: автосервис

Схема БД:
- **client** (client_id, full_name, phone_number, email)
- **car** (car_id, client_id, make, model, number_plate)
- **master** (master_id, full_name, specialization, phone_number)
- **order** (order_id, car_id, master_id, date_of_receipt, date_of_issue, status, price)
- **service** (service_id, title, description, price, standart_hour)
- **order_service** (order_id, servie_id, amount, actual_cots)

> Во всех запросах ниже используется таблица `"order"` в кавычках, так как `order` — зарезервированное слово.

---

## a. CTE

### Запрос 1. Завершённые заказы через CTE

```sql
WITH completed_orders AS (
    SELECT *
    FROM "order"
    WHERE status = 'завершён'
)
SELECT order_id, price
FROM completed_orders;
```

**Результат:**  

<img width="392" height="102" alt="image" src="https://github.com/user-attachments/assets/399dd401-97c0-4065-b1d2-431e2ab03ed4" />

**Пояснение:** CTE `completed_orders` временно сохраняет только завершённые заказы, затем по нему строится итоговая выборка.

---

### Запрос 2. Несколько CTE + UNION ALL

```sql
WITH expensive_services AS (
    SELECT *
    FROM service
    WHERE price >= 4000
),
expensive_orders AS (
    SELECT *
    FROM "order"
    WHERE price >= 10000
)
SELECT 'service' AS src, title AS name
FROM expensive_services
UNION ALL
SELECT 'order', order_id::text
FROM expensive_orders;
```

**Результат:**  

<img width="376" height="235" alt="image" src="https://github.com/user-attachments/assets/4ec8761e-e8f8-485a-9316-a198e7c434fd" />

**Пояснение:** два независимых CTE объединяются через `UNION ALL`; первый столбец показывает источник строки.

---

### Запрос 3. Рекурсивное CTE

```sql
WITH RECURSIVE nums AS (
    SELECT 1 AS n
    UNION ALL
    SELECT n + 1
    FROM nums
    WHERE n < 5
)
SELECT n, (SELECT COUNT(*) FROM "order") AS orders_count
FROM nums;
```

**Результат:**  

<img width="391" height="202" alt="image" src="https://github.com/user-attachments/assets/30910b12-327b-4ebc-b874-8875f8eea602" />

**Пояснение:** рекурсивная часть увеличивает `n`, пока не достигнет 5; для каждой строки дополнительно выводится общее количество заказов.

---

## b. UNION, INTERSECT, EXCEPT

### Запрос 1. UNION: все ФИО клиентов и мастеров

```sql
SELECT full_name FROM client
UNION
SELECT full_name FROM master;
```

**Результат:**  

<img width="291" height="374" alt="image" src="https://github.com/user-attachments/assets/ffeef1f1-c0b1-4890-ab65-9a7f25643ca2" />

**Пояснение:** `UNION` объединяет два списка и убирает дубликаты.

---

### Запрос 2. INTERSECT: совпадающие специализации и услуги

```sql
SELECT specialization FROM master
INTERSECT
SELECT title FROM service;
```

**Результат:**  

<img width="251" height="100" alt="image" src="https://github.com/user-attachments/assets/151bdd16-aba4-49ea-a4b9-039d59024a58" />

**Пояснение:** возвращаются только те значения, которые есть и в специализациях мастеров, и в названиях услуг.

---

### Запрос 3. EXCEPT: услуги, которых нет среди специализаций

```sql
SELECT title FROM service
EXCEPT
SELECT specialization FROM master;
```

**Результат:**  

<img width="196" height="168" alt="image" src="https://github.com/user-attachments/assets/36116de9-b317-4b95-b691-be938e1e5aee" />

**Пояснение:** возвращаются названия услуг, которых нет в списке специализаций мастеров.

---

## c. Оконные функции: PARTITION BY

### Запрос 1. Сумма стоимости заказов по каждому мастеру

```sql
SELECT
    order_id,
    master_id,
    price,
    SUM(price) OVER (PARTITION BY master_id) AS total_by_master
FROM "order";
```

**Результат:**  

<img width="888" height="201" alt="image" src="https://github.com/user-attachments/assets/c6c231cc-ff81-4bfb-94a5-033edcf0c7e4" />

**Пояснение:** `PARTITION BY master_id` делит строки на группы по мастеру; сумма считается внутри каждой группы, но строки не сворачиваются.

---

### Запрос 2. Количество машин по каждой марке

```sql
SELECT
    car_id,
    make,
    model,
    COUNT(*) OVER (PARTITION BY make) AS cnt_by_make
FROM car;
```

**Результат:**  

<img width="759" height="235" alt="image" src="https://github.com/user-attachments/assets/531208df-4ef2-4d50-bddf-5f43c466e182" />

**Пояснение:** для каждой машины выводится количество машин той же марки.

---

## d. Оконные функции: PARTITION BY + ORDER BY

### Запрос 1. Накопительная сумма заказов по мастеру

```sql
SELECT
    order_id,
    master_id,
    date_of_receipt,
    price,
    SUM(price) OVER (
        PARTITION BY master_id
        ORDER BY date_of_receipt
    ) AS running_total_by_master
FROM "order";
```

**Результат:**  

<img width="1274" height="203" alt="image" src="https://github.com/user-attachments/assets/b592474e-8e90-4a5d-a25f-de75f1413056" />

**Пояснение:** внутри каждого мастера заказы упорядочиваются по дате, а `SUM` накапливает стоимость.

---

### Запрос 2. Нумерация услуг внутри одинаковой цены

```sql
SELECT
    service_id,
    title,
    price,
    ROW_NUMBER() OVER (
        PARTITION BY price
        ORDER BY service_id
    ) AS rn_by_price
FROM service;
```

**Результат:**  

<img width="861" height="237" alt="image" src="https://github.com/user-attachments/assets/2a9c0acd-dec6-4dc9-bab3-498260138425" />

**Пояснение:** строки группируются по цене, внутри каждой цены услуги нумеруются по `service_id`.

---

## e. ROWS

### Запрос 1. Средняя цена: предыдущая + текущая строка

```sql
SELECT
    order_id,
    price,
    AVG(price) OVER (
        ORDER BY order_id
        ROWS BETWEEN 1 PRECEDING AND CURRENT ROW
    ) AS avg_prev_cur
FROM "order";
```

**Результат:**  

<img width="640" height="205" alt="image" src="https://github.com/user-attachments/assets/24d6f983-ed96-4581-8e9e-8a70b292fbb3" />

**Пояснение:** окно для каждой строки включает одну предыдущую строку и текущую.

---

### Запрос 2. Сумма: 2 предыдущие + текущая строка

```sql
SELECT
    service_id,
    price,
    SUM(price) OVER (
        ORDER BY service_id
        ROWS BETWEEN 2 PRECEDING AND CURRENT ROW
    ) AS sum_2prev_cur
FROM service;
```

**Результат:**  

<img width="672" height="235" alt="image" src="https://github.com/user-attachments/assets/1dfae84e-6656-426f-8c45-ebd4101828e4" />

**Пояснение:** `ROWS` задаёт физическое количество строк в окне: две предыдущие и текущая.

---

## f. RANGE

### Запрос 1. Средняя цена в диапазоне price − 5000 … price

```sql
SELECT
    order_id,
    price,
    AVG(price) OVER (
        ORDER BY price
        RANGE BETWEEN 5000 PRECEDING AND CURRENT ROW
    ) AS avg_range
FROM "order";
```

**Результат:**  

<img width="603" height="201" alt="image" src="https://github.com/user-attachments/assets/533fe3da-f5d1-4f40-b5a5-011791661334" />

**Пояснение:** `RANGE` включает строки не по физическому количеству, а по значениям: от `price - 5000` до текущего `price`.

---

### Запрос 2. Количество услуг в диапазоне price ± 1000

```sql
SELECT
    service_id,
    price,
    COUNT(*) OVER (
        ORDER BY price
        RANGE BETWEEN 1000 PRECEDING AND 1000 FOLLOWING
    ) AS cnt_near
FROM service;
```

**Результат:**  

<img width="615" height="233" alt="image" src="https://github.com/user-attachments/assets/9fb952d5-f408-4d24-8900-4f4b0a047a7f" />

**Пояснение:** окно включает услуги, цена которых отличается от текущей не более чем на 1000 в обе стороны.

---

## g. Ранжирующие оконные функции

### Запрос 1. ROW_NUMBER

```sql
SELECT
    order_id,
    price,
    ROW_NUMBER() OVER (ORDER BY price DESC) AS rn
FROM "order";
```

**Результат:**  

<img width="521" height="201" alt="image" src="https://github.com/user-attachments/assets/9cbdd976-a886-45ff-b525-7448365425e2" />

**Пояснение:** `ROW_NUMBER` присваивает уникальный номер каждой строке без пропусков.

---

### Запрос 2. RANK

```sql
SELECT
    order_id,
    price,
    RANK() OVER (ORDER BY price DESC) AS rnk
FROM "order";
```

**Результат:**  

<img width="532" height="198" alt="image" src="https://github.com/user-attachments/assets/e96f266f-5c77-436d-833c-895d64b7631b" />

**Пояснение:** при одинаковой цене строки получают одинаковый ранг, после группы одинаковых значений ранг пропускается.

---

### Запрос 3. DENSE_RANK

```sql
SELECT
    service_id,
    price,
    DENSE_RANK() OVER (ORDER BY price) AS dense_rnk
FROM service;
```

**Результат:**  

<img width="630" height="236" alt="image" src="https://github.com/user-attachments/assets/5c66879b-dd08-424c-a4fd-ce76d66fd33c" />

**Пояснение:** в отличие от `RANK`, после одинаковых значений следующий ранг увеличивается на 1, без пропусков.

---

## h. Функции смещения

### Запрос 1. LAG

```sql
SELECT
    order_id,
    price,
    LAG(price) OVER (ORDER BY order_id) AS prev_price
FROM "order";
```

**Результат:**  

<img width="620" height="198" alt="image" src="https://github.com/user-attachments/assets/11b00670-6f43-493a-853f-8e9bde8da88c" />

**Пояснение:** `LAG` возвращает цену предыдущей строки в порядке `order_id`.

---

### Запрос 2. LEAD

```sql
SELECT
    order_id,
    price,
    LEAD(price) OVER (ORDER BY order_id) AS next_price
FROM "order";
```

**Результат:**  

<img width="616" height="198" alt="image" src="https://github.com/user-attachments/assets/777ab31c-f5e0-4958-958f-4d44e5cdfffe" />

**Пояснение:** `LEAD` возвращает цену следующей строки в порядке `order_id`.

---

### Запрос 3. FIRST_VALUE

```sql
SELECT
    order_id,
    price,
    FIRST_VALUE(price) OVER (
        ORDER BY order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS first_price
FROM "order";
```

**Результат:**  

<img width="627" height="201" alt="image" src="https://github.com/user-attachments/assets/6994dc70-329d-4edd-b2c9-fb302e3f5c2d" />

**Пояснение:** `FIRST_VALUE` возвращает первое значение цены во всём окне.

---

### Запрос 4. LAST_VALUE

```sql
SELECT
    order_id,
    price,
    LAST_VALUE(price) OVER (
        ORDER BY order_id
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS last_price
FROM "order";
```

**Результат:**  

<img width="615" height="201" alt="image" src="https://github.com/user-attachments/assets/1b631b0b-5cec-49e0-9709-9c8e4904a11a" />

**Пояснение:** `LAST_VALUE` возвращает последнее значение цены во всём окне; рамка задана явно, чтобы окно не обрезалось текущей строкой.
на `c.car_id` и считает заказы для каждой машины.
