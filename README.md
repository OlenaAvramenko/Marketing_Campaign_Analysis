# Аналіз ефективності рекламних кампаній у Facebook та Google

## Опис проєкту
У цьому проєкті я об’єднала дані з рекламних платформ **Facebook** та **Google**, щоб створити уніфіковану таблицю з ключовими метриками по кампаніях. Потім виконала агрегацію даних для порівняння ефективності кампаній по днях.

## Використані інструменти
- **SQL** (CTE, JOIN, UNION ALL, агрегатні функції)
- **DBeaver** — як середовище для написання та виконання запитів
- Дані з **Facebook Ads** і **Google Ads**

## Моя роль у проєкті
- Побудова SQL-запиту з використанням `CTE` та `JOIN`
- Об'єднання даних з двох джерел (Facebook і Google)
- Агрегація метрик для подальшої аналітики

## SQL-запит

```sql
WITH facebook_data AS (
   SELECT 
      fb_daily.ad_date, 
      fb_campaign.campaign_name, 
      fb_adset.adset_name, 
      fb_daily.spend, 
      fb_daily.impressions, 
      fb_daily.reach, 
      fb_daily.clicks, 
      fb_daily.leads, 
      fb_daily.value,
      'Facebook Ads' AS media_source
   FROM facebook_ads_basic_daily fb_daily  
   INNER JOIN facebook_adset fb_adset
      ON fb_daily.adset_id = fb_adset.adset_id
   INNER JOIN facebook_campaign fb_campaign
      ON fb_daily.campaign_id = fb_campaign.campaign_id
),
all_ads_data AS (
   SELECT
      ad_date,
      campaign_name,
      adset_name,
      spend,
      impressions,
      reach,
      clicks,
      leads,
      value,
      media_source
   FROM facebook_data
   UNION ALL
   SELECT
      g_data.ad_date,
      g_data.campaign_name,
      g_data.adset_name,
      g_data.spend,
      g_data.impressions,
      g_data.reach,
      g_data.clicks,
      g_data.leads,
      g_data.value,
      'Google Ads' AS media_source
   FROM google_ads_basic_daily g_data
)

SELECT 
    ad_date,
    media_source,
    campaign_name,
    adset_name,
    SUM(spend) AS total_spend,
    SUM(impressions) AS total_impressions,
    SUM(clicks) AS total_clicks,
    SUM(value) AS total_value
FROM 
    all_ads_data
GROUP BY 
    ad_date, media_source, campaign_name, adset_name
ORDER BY 
    ad_date, media_source, campaign_name, adset_name;
```
## Результати
Отримано уніфіковану таблицю для аналізу рекламних кампаній у Facebook та Google з ключовими метриками: витрати, покази, кліки та value конверсій. Це дозволяє порівнювати ефективність кампаній між платформами у різні дні та за різними наборами оголошень.

## Бонусне завдання
### Опис завдання
1. Обʼєднання даних з чотирьох таблиць для визначення кампанії з найвищим ROMI серед кампаній з витратами більше 500 000.
2. Визначення групи оголошень (adset) з найвищим ROMI в кампанії з найвищим ROMI.

### SQL-запит:

```sql
with facebook_data as (
   SELECT 
      fb_daily.ad_date, 
      fb_campaign.campaign_name, 
      fb_adset.adset_name, 
      fb_daily.spend, 
      fb_daily.impressions, 
      fb_daily.reach, 
      fb_daily.clicks, 
      fb_daily.leads, 
      fb_daily.value,
      'Facebook Ads'as media_source
   FROM facebook_ads_basic_daily fb_daily  
   inner join facebook_adset fb_adset
      on fb_daily.adset_id = fb_adset.adset_id
   inner join facebook_campaign fb_campaign
      on fb_daily.campaign_id = fb_campaign.campaign_id
      ),
all_ads_data as (
   select
      ad_date,
      campaign_name,
      adset_name,
      spend,
      impressions,
      reach,
      clicks,
      leads,
      value,
      media_source
   from facebook_data
   union all
   select
      g_data.ad_date,
      g_data.campaign_name,
      g_data.adset_name,
      g_data.spend,
      g_data.impressions,
      g_data.reach,
      g_data.clicks,
      g_data.leads,
      g_data.value,
      'Google Ads'as media_source
      from google_ads_basic_daily g_data
),
-- Визначаємо кампанію з найвищим ROMI 
campaign_aggregates AS (
-- Обчислюємо ROMI для кампаній з витратами більше 500 000
    SELECT 
campaign_name,
sum (spend) as total_spend,
sum (value) as total_value,
CAST(SUM(value) AS FLOAT) / SUM(spend) - 1 AS romi
FROM all_ads_data
GROUP BY campaign_name
    HAVING SUM(spend) > 500000 -- Витрати більше 500 000
),
highest_romi_campaign as (
-- Знаходимо кампанію з найвищим ROMI
SELECT 
    campaign_name,
    romi
    FROM campaign_aggregates
    order by romi desc 
    limit 1 -- Беремо тільки кампанію з найвищим ROMI
    ),
    adset_romi_data as (
        -- Обчислюємо ROMI для кожної групи оголошень
    select 
    campaign_name,
    adset_name,
    sum (spend) as total_spend,
    sum (value) as total_value,
    cast(sum(value) as float)/sum(spend)-1 as romi
    from all_ads_data 
    group by campaign_name, adset_name
    )
    select 
    r.campaign_name,
    r.adset_name,
    r.romi
    FROM adset_romi_data r
    join highest_romi_campaign h
    on r.campaign_name = h.campaign_name
    where r.romi = (
    -- Знаходимо групу оголошень з найвищим ROMI для кампанії з найвищим ROMI
    SELECT MAX(romi) 
    FROM adset_romi_data
    WHERE campaign_name = r.campaign_name
);
```
## Результат
Кампанія з найвищим ROMI серед усіх кампаній з витратами більше 500 000 була визначена.

В межах цієї кампанії було знайдено групу оголошень (adset), що має найвищий ROMI.

# Візуалізація в Tableau
## Marketing Campaign Performance Overview
Ціль: наочно продемонструвати результати SQL-аналізу ефективності кампаній

Інструмент: Tableau Public

Ключові графіки:

Comparison of Spend and Value Over Time

ROMI by Campaign

Top Campaigns by Total Value

Comparison of ROMI Across Campaigns

🧭 Фільтри: Можна досліджувати дані по кампаніях та платформах (Facebook/Google)

🔗 Дашборд Tableau:

https://public.tableau.com/app/profile/olena.avramenko4187/viz/Visualisation_17445723619140/MarketingCampaignPerformanceOverview?publish=yes

🖼️ Скріншот дашборду:
![Dashboard Screenshot](Marketing%20Campaign%20Performance%20Overview.jpg)

