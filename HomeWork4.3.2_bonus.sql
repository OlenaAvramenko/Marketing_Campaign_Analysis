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