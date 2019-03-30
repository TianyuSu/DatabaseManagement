/* Calculate the average improvement value per sqft in each block group. */

select
*
from(select
	    min(bg.geoid10) as geoid10,
      min(bg.countyfp10) as county,
      st_union(bg.geom) as geom,
	    count(pa.*) as num_prop,
      avg(pa.imp_val/pa.area_sqft) as avg_value,
      avg(pa.sale_price/pa.area_sqft) as avg_sale_price,
      min(pa.descr) as descr,
      concat(bg.geoid10, pa.descr) as GD
     from
	    somerville.gb_bg_2010 as bg
	    left join (select
	                a.id_0 as assess_id,
                  a.comm_own as comm_own,
                  a.imp_val as imp_val,
	                a.sale_price as sale_price,
                  a.sale_date as sale_date,
                  a.sqft as area_sqft,
	                a.descr as descr,
	                p.geom as geom
                from(select 
	                    *
                     from  
	                    somerville.somassess_17 AS assess
                        inner join somerville.lu_codes as c on assess.pcc = c.pcc
                     ) AS a
                   inner join somerville.parcels_17 AS p on a.mbl = p.mbl
                where 
                    a.imp_val IS NOT NULL) AS pa on ST_Intersects(bg.geom, pa.geom)
     group by
        GD) as pa_bg
where
	(descr = 'Single-Family' OR descr = 'Two-Family' OR descr = 'Three-Family' OR descr = 'Apartment, 4-8 Units' OR descr = 'Apartment, 8+ Units' OR descr = 'Condo') 
  and avg_value IS NOT NULL;


/* Calculate the percentage of properties owned by companies in each block group. */

select
    v.geoid10 as geoid10,
    v.geom as geom,
	v.num_prop as num_prop,
    inc.num_prop_inc as num_prop_inc,
    (CAST(inc.num_prop_inc AS float)*100/CAST(v.num_prop AS float)) as percentage_inc,
    v.avg_value as avg_value,
    v.avg_sale_price as avg_sale_price
from(select
        *
     from(select
	        min(bg.geoid10) as geoid10,
            st_union(bg.geom) as geom,
	        count(pa.*) AS num_prop,
            avg(pa.imp_val/pa.area_sqft) as avg_value,
            avg(pa.sale_price/pa.area_sqft) as avg_sale_price
          from
	        somerville.gb_bg_2010 as bg
	        left join (select
	                    a.id_0 as assess_id,
                        a.comm_own as comm_own,
                        a.imp_val as imp_val,
	                    a.sale_price as sale_price,
                        a.sale_date as sale_date,
                        a.sqft as area_sqft,
	                    a.descr as descr,
	                    p.geom as geom
                      from(select 
	                            *
                            from  
	                            somerville.somassess_17 AS assess
                                inner join somerville.lu_codes as c on assess.pcc = c.pcc
                                ) AS a
                        inner join somerville.parcels_17 AS p on a.mbl = p.mbl
                      where 
                        a.imp_val IS NOT NULL) AS pa on ST_Intersects(bg.geom, pa.geom)
     group by
        geoid10) as pa_bg
     where
	    pa_bg.num_prop>0) AS v
     inner join (select
                    *
                from(select
	                    min(bg.geoid10) as geoid10,
                        st_union(bg.geom) as geom,
	                    count(pa.*) AS num_prop_inc
                    from
	                    somerville.gb_bg_2010 as bg
	                left join (select
	                                a.id_0 as assess_id,
                                    a.comm_own as comm_own,
                                    a.imp_val as imp_val,
	                                a.sale_price as sale_price,
                                    a.sale_date as sale_date,
                                    a.sqft as area_sqft,
	                                a.descr as descr,
	                                p.geom as geom
                                from(select 
	                                    *
                                    from  
	                                    somerville.somassess_17 AS assess
                                        inner join somerville.lu_codes as c on assess.pcc = c.pcc
                                        ) AS a
                                inner join somerville.parcels_17 AS p on a.mbl = p.mbl
                                where 
                                    (a.imp_val IS NOT NULL) AND (a.comm_own LIKE '%LLC%' OR a.comm_own LIKE '%CORPORATION%')) AS pa on ST_Intersects(bg.geom, pa.geom)
                    group by
                        geoid10) as pa_bg
                where
	                pa_bg.num_prop_inc>0) AS inc ON v.geoid10 = inc.geoid10;


/* Check the correlation. */

select
    corr(co.percentage_inc , co.avg_value)
from (

select
    v.geoid10 as geoid10,
    v.geom as geom,
	v.num_prop as num_prop,
    inc.num_prop_inc as num_prop_inc,
    (CAST(inc.num_prop_inc AS float)*100/CAST(v.num_prop AS float)) as percentage_inc,
    v.avg_value as avg_value,
    v.avg_sale_price as avg_sale_price
from(select
        *
     from(select
	        min(bg.geoid10) as geoid10,
            st_union(bg.geom) as geom,
	        count(pa.*) AS num_prop,
            avg(pa.imp_val/pa.area_sqft) as avg_value,
            avg(pa.sale_price/pa.area_sqft) as avg_sale_price
          from
	        somerville.gb_bg_2010 as bg
	        left join (select
	                    a.id_0 as assess_id,
                        a.comm_own as comm_own,
                        a.imp_val as imp_val,
	                    a.sale_price as sale_price,
                        a.sale_date as sale_date,
                        a.sqft as area_sqft,
	                    a.descr as descr,
	                    p.geom as geom
                      from(select 
	                            *
                            from  
	                            somerville.somassess_17 AS assess
                                inner join somerville.lu_codes as c on assess.pcc = c.pcc
                                ) AS a
                        inner join somerville.parcels_17 AS p on a.mbl = p.mbl
                      where 
                        a.imp_val IS NOT NULL) AS pa on ST_Intersects(bg.geom, pa.geom)
     group by
        geoid10) as pa_bg
     where
	    pa_bg.num_prop>0) AS v
     inner join (select
                    *
                from(select
	                    min(bg.geoid10) as geoid10,
                        st_union(bg.geom) as geom,
	                    count(pa.*) AS num_prop_inc
                    from
	                    somerville.gb_bg_2010 as bg
	                left join (select
	                                a.id_0 as assess_id,
                                    a.comm_own as comm_own,
                                    a.imp_val as imp_val,
	                                a.sale_price as sale_price,
                                    a.sale_date as sale_date,
                                    a.sqft as area_sqft,
	                                a.descr as descr,
	                                p.geom as geom
                                from(select 
	                                    *
                                    from  
	                                    somerville.somassess_17 AS assess
                                        inner join somerville.lu_codes as c on assess.pcc = c.pcc
                                        ) AS a
                                inner join somerville.parcels_17 AS p on a.mbl = p.mbl
                                where 
                                    (a.imp_val IS NOT NULL) AND (a.comm_own LIKE '%LLC%' OR a.comm_own LIKE '%CORPORATION%')) AS pa on ST_Intersects(bg.geom, pa.geom)
                    group by
                        geoid10) as pa_bg
                where
	                pa_bg.num_prop_inc>0) AS inc ON v.geoid10 = inc.geoid10
    ) AS co;