/* Teknik Özet: Ham GA4 etkinlik verilerinin yapılandırılmış bir tablo şemasına dönüştürülmesi.
Gerçekleştirilen İşlemler: Zaman damgalarının standartlaştırılması ve iç içe geçmiş (nested) etkinlik parametrelerinin düzleştirilmesi.
*/
SELECT
-- Unix mikrosaniye formatındaki zaman damgalarının standart tarih ve saat formatına dönüştürülmesi
  TIMESTAMP_MICROS(event_timestamp) AS event_timestamp,
  DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date, 
  user_pseudo_id,
  -- Etkinlik parametreleri dizisinden oturum kimliğinin (ga_session_id) alt sorgu ile çıkarılması
  (
    SELECT ep.value.int_value
    FROM UNNEST(event_params) AS ep
    WHERE ep.key = "ga_session_id"
  ) AS session_id,
  event_name,
  geo.country,
  device.category AS device_category,
  traffic_source.source,
  traffic_source.medium,
  traffic_source.name AS campaign
FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
-- Sorgu maliyetini ve performansını optimize etmek için 2021 yılı verilerinin partition bazlı filtrelenmesi
WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
  AND event_name IN (
    'session_start',
    'view_item',
    'add_to_cart',
    'begin_checkout',
    'add_shipping_info',
    'add_payment_info',
    'purchase'
  );

  /* Teknik Özet: Trafik kaynaklarına göre gruplandırılmış çok aşamalı dönüşüm hunisi analizi.
Gerçekleştirilen İşlemler: Oturum bazlı tekil kullanıcı takibi ve huni aşamaları arasındaki dönüşüm oranlarının hesaplanması.
*/
WITH base_events AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    user_pseudo_id,
    (
      SELECT ep.value.int_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = "ga_session_id"
    ) AS session_id,
    event_name,
    traffic_source.source,
    traffic_source.medium,
    traffic_source.name AS campaign
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20210101' AND '20211231'
    AND event_name IN (
      'session_start',
      'add_to_cart',
      'begin_checkout',
      'purchase'
    )
),

sessions AS (
  -- Benzersiz oturum başlangıçlarını temel alarak ana kitlenin tanımlanması
  SELECT DISTINCT
    user_pseudo_id,
    session_id,
    event_date,
    source,
    medium,
    campaign
  FROM base_events
  WHERE event_name = 'session_start'
),

funnel AS (
  -- Kullanıcıların satın alma yolculuğundaki ilerlemesinin sayısallaştırılması
  SELECT
    s.event_date,
    s.source,
    s.medium,
    s.campaign,
    COUNT(DISTINCT CONCAT(s.user_pseudo_id, "-", s.session_id)) AS user_sessions_count,
    COUNT(DISTINCT CASE WHEN e.event_name = 'add_to_cart' THEN CONCAT(e.user_pseudo_id, "-", e.session_id) END) AS visit_to_cart,
    COUNT(DISTINCT CASE WHEN e.event_name = 'begin_checkout' THEN CONCAT(e.user_pseudo_id, "-", e.session_id) END) AS visit_to_checkout,
    COUNT(DISTINCT CASE WHEN e.event_name = 'purchase' THEN CONCAT(e.user_pseudo_id, "-", e.session_id) END) AS visit_to_purchase
  FROM sessions s
  LEFT JOIN base_events e
    ON s.user_pseudo_id = e.user_pseudo_id
    AND s.session_id = e.session_id
  GROUP BY s.event_date, s.source, s.medium, s.campaign
)
-- Sıfıra bölünme hatalarını yöneterek temel dönüşüm metriklerinin hesaplanması
SELECT
  *,
  SAFE_DIVIDE(visit_to_cart, user_sessions_count) AS visit_to_cart_rate,
  SAFE_DIVIDE(visit_to_checkout, user_sessions_count) AS visit_to_checkout_rate,
  SAFE_DIVIDE(visit_to_purchase, user_sessions_count) AS visit_to_purchase_rate
FROM funnel
ORDER BY event_date, source, medium, campaign;

/* Açılış sayfalarının (Landing Page) satın alma dönüşüm oranlarının karşılaştırılması.
Aynı oturum içindeki giriş sayfası ile satın alma etkinliğini eşleştirir.
*/
WITH all_events AS (
  SELECT
    DATE(TIMESTAMP_MICROS(event_timestamp)) AS event_date,
    user_pseudo_id,
    (
      SELECT ep.value.int_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = "ga_session_id"
    ) AS session_id,
    event_name,
    (
      SELECT ep.value.string_value
      FROM UNNEST(event_params) AS ep
      WHERE ep.key = "page_location"
    ) AS page_path
  FROM `bigquery-public-data.ga4_obfuscated_sample_ecommerce.events_*`
  WHERE _TABLE_SUFFIX BETWEEN '20200101' AND '20201231'
    AND event_name IN ('session_start', 'purchase')
),
sessions AS (
  -- İlk giriş yapılan sayfa yolunun tespiti
  SELECT DISTINCT
    user_pseudo_id,
    session_id,
    page_path
  FROM all_events
  WHERE event_name = 'session_start'
),
purchases AS (
  -- Satın alma ile sonuçlanan oturumların tespiti
  SELECT DISTINCT
    s.page_path,
    s.user_pseudo_id,
    s.session_id
  FROM sessions s
  LEFT JOIN all_events e
    ON s.user_pseudo_id = e.user_pseudo_id
    AND s.session_id = e.session_id
  WHERE e.event_name = 'purchase'
)
-- Sayfa bazlı gruplandırma ve dönüşüm oranı hesaplama
SELECT
  s.page_path,
  COUNT(DISTINCT CONCAT(s.user_pseudo_id, "-", s.session_id)) AS unique_sessions,
  COUNT(DISTINCT CONCAT(p.user_pseudo_id, "-", p.session_id)) AS purchase_count,
  SAFE_DIVIDE(
    COUNT(DISTINCT CONCAT(p.user_pseudo_id, "-", p.session_id)),
    COUNT(DISTINCT CONCAT(s.user_pseudo_id, "-", s.session_id))
  ) AS purchase_conversion_rate
FROM sessions s
LEFT JOIN purchases p
  ON s.user_pseudo_id = p.user_pseudo_id
  AND s.session_id = p.session_id
GROUP BY s.page_path
ORDER BY purchase_conversion_rate DESC;