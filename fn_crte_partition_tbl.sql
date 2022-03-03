create or replace function itfcdmpv53w.fn_crte_partition_tbl(thisyear varchar) returns void language plpgsql as $$
    declare thisyear varchar := thisyear;
    declare firstdayofyear varchar := to_date(thisyear, 'YYYY-MM-DD');
    declare daysofyear varchar := itfcdmpv53w.fn_year_days(thisyear);
    declare lastdayofyear varchar = '';

    declare table_arr varchar[] := array['pre_mmodexip_mmohiprc', 'pre_mmodexop_mmohoprc'];
    declare tbl varchar;
    declare tmp_crte_sql varchar;
    declare tmp_drop_sql varchar;
    declare tmp_drop_idx varchar;
    declare tmp_crte_idx varchar;
begin
    -- partition 해당연도-01-01 ~ 다음연도-01-01
    if daysofyear = '365' then
        lastdayofyear :=  to_date((firstdayofyear::date + interval  '365 days')::varchar, 'YYYY-MM-DD');
        -- raise notice 'this year is %, first day is %, lasd day is %', thisyear, firstdayofyear, lastdayofyear;
    else
        lastdayofyear :=  to_date((firstdayofyear::date + interval  '366 days')::varchar, 'YYYY-MM-DD');
        -- raise notice 'this year is leap year %, first day is %, lasd day is %', thisyear, firstdayofyear, lastdayofyear;
    end if;

    foreach tbl in array table_arr loop

        tmp_crte_sql := format('create UNLOGGED table itfcdmpv53w.%s_y%s partition of itfcdmpv53w.%s
        for values from (%s) to (%s)'
        ,tbl, thisyear, tbl
        ,quote_literal(firstdayofyear), quote_literal(lastdayofyear));

        tmp_drop_sql := format('drop table if exists itfcdmpv53w.%s_y%s cascade', tbl, thisyear);

       tmp_drop_idx := format('drop index if exists itfcdmpv53w.%s_y%s_lastupdtdt_idx', tbl, thisyear);
       tmp_crte_idx := format('create index on itfcdmpv53w.%s_y%s (lastupdtdt)', tbl, thisyear);

        -- raise notice '%', tmp_drop_sql;
        -- raise notice '%', tmp_crte_sql;
        -- raise notice '%', tmp_drop_idx;
        -- raise notice '%', tmp_crte_idx;

        execute tmp_drop_sql;
        execute tmp_crte_sql;
        execute tmp_drop_idx;
        execute tmp_crte_idx;

    end loop;
    return;
end
$$;