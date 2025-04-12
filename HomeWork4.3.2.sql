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
)
 --Агрегація данних
SELECT 
    ad_date,
    media_source,
    campaign_name,
    adset_name,
    SUM(spend) AS total_spend,           -- Загальна сума витрат
    SUM(impressions) AS total_impressions, -- Кількість показів
    SUM(clicks) AS total_clicks,           -- Кількість кліків
    SUM(value) AS total_value              -- Загальний Value конверсій
FROM 
    all_ads_data
GROUP BY 
    ad_date, media_source, campaign_name, adset_name
ORDER BY 
    ad_date, media_source, campaign_name, adset_name;