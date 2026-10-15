# HW5: Агрегатные функции и GROUP BY, HAVING

## База данных: автосервис

Схема БД:
- **client** (client_id, full_name, phone_number, email)
- **car** (car_id, client_id, make, model, number_plate)
- **master** (master_id, full_name, specialization, phone_number)
- **order** (order_id, car_id, master_id, date_of_receipt, date_of_issue, status, price)
- **service** (service_id, title, description, price, standart_hour)
- **order_service** (order_id, servie_id, amount, actual_cots)

---

## a. COUNT(), SUM(), AVG(), MIN(), MAX(), STRING_AGG()

### Запрос 1. Общая статистика по заказам

```sql
SELECT 
    COUNT(*) AS total_orders,
    SUM(price) AS total_revenue,
    AVG(price) AS avg_order_price,
    MIN(price) AS min_price,
    MAX(price) AS max_price
FROM "order";
```

**Результат:**

<img width="1248" height="66" alt="image" src="https://github.com/user-attachments/assets/8907b286-3a35-4cce-88a1-3cfaa30bc789" />

---

### Запрос 2. Список всех услуг через STRING_AGG

```sql
SELECT STRING_AGG(title, ', ') AS all_services
FROM service;
```

**Результат:**

<img width="869" height="69" alt="image" src="https://github.com/user-attachments/assets/9fd16c93-e378-402e-a1dc-b9656a255a29" />

**Пояснение:** `STRING_AGG` объединяет все названия услуг в одну строку через запятую.

---

## b. GROUP BY, HAVING

### Запрос 1. Количество заказов и суммарная выручка по каждому статусу

```sql
SELECT 
    status,
    COUNT(*) AS orders_count,
    SUM(price) AS total_price
FROM "order"
GROUP BY status;
```

**Результат:**

<img width="689" height="100" alt="image" src="https://github.com/user-attachments/assets/84d9b256-38d9-441e-8f0d-37495c0b3f4f" />

---

### Запрос 2. Клиенты, у которых больше одной машины (HAVING)

```sql
SELECT 
    c.full_name,
    COUNT(car.car_id) AS cars_count
FROM client c
JOIN car ON c.client_id = car.client_id
GROUP BY c.client_id, c.full_name
HAVING COUNT(car.car_id) > 1;
```

**Результат:**

<img width="511" height="70" alt="image" src="https://github.com/user-attachments/assets/cc28bd8a-be95-4df0-80bd-a1a2a1a5a215" />

---

## c. GROUPING SETS, ROLLUP, CUBE

### Запрос 1. GROUPING SETS: выручка по мастерам и по статусам

```sql
SELECT 
    m.full_name AS master_name,
    o.status,
    SUM(o.price) AS total_price
FROM "order" o
JOIN master m ON o.master_id = m.master_id
GROUP BY GROUPING SETS (
    (m.full_name),
    (o.status),
    ()
);
```

**Результат:**

<img width="678" height="271" alt="image" src="https://github.com/user-attachments/assets/fcdb3f4a-9f01-4dfb-948e-f592ac07dcd7" />

---

### Запрос 2. ROLLUP: иерархия «марка → модель»

```sql
SELECT 
    car.make,
    car.model,
    COUNT(*) AS orders_count,
    SUM(o.price) AS total_price
FROM "order" o
JOIN car ON o.car_id = car.car_id
GROUP BY ROLLUP (car.make, car.model);
```

**Результат:**

<img width="844" height="408" alt="image" src="https://github.com/user-attachments/assets/b7e8e674-00ea-4c42-9f7e-42cd206c65e2" />

---

### Запрос 3. CUBE: все комбинации «мастер × статус»

```sql
SELECT 
    m.full_name AS master_name,
    o.status,
    COUNT(*) AS orders_count,
    SUM(o.price) AS total_price
FROM "order" o
JOIN master m ON o.master_id = m.master_id
GROUP BY CUBE (m.full_name, o.status);
```

**Результат:**

<img width="935" height="438" alt="image" src="https://github.com/user-attachments/assets/9894173e-84e4-40f7-854b-ca7d31ea9c15" />

---

## d. SELECT, FROM, WHERE, GROUP BY, HAVING, ORDER BY

### Запрос 1. Заказы дороже 5000, сгруппированные по мастерам, с сортировкой

```sql
SELECT 
    m.full_name AS master_name,
    m.specialization,
    COUNT(*) AS orders_count,
    SUM(o.price) AS total_price
FROM "order" o
JOIN master m ON o.master_id = m.master_id
WHERE o.price > 5000
GROUP BY m.master_id, m.full_name, m.specialization
HAVING SUM(o.price) > 10000
ORDER BY total_price DESC;
```

**Результат:**

<img width="1021" height="133" alt="image" src="https://github.com/user-attachments/assets/5247d47d-f4f8-4dc4-9f40-3d557dfceb5d" />

---

### Запрос 2. Услуги, которые заказывали более одного раза

```sql
SELECT 
    s.title,
    COUNT(*) AS times_ordered,
    SUM(os.amount) AS total_amount,
    AVG(os.actual_cots) AS avg_cost
FROM order_service os
JOIN service s ON os.servie_id = s.service_id
GROUP BY s.service_id, s.title
HAVING COUNT(*) > 1
ORDER BY times_ordered DESC, s.title ASC;
```

**Результат:**

<img width="903" height="101" alt="image" src="https://github.com/user-attachments/assets/6e0539a7-b5a2-48eb-95de-049b3b0a9436" />
