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
