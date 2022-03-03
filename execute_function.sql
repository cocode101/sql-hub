do $$
declare idx_year int;
declare now_year int := extract(year from now());
begin
    for idx_year in 2002..now_year loop
        execute format('select itfcdmpv53w.fn_crte_partition_tbl(%s)', quote_literal(idx_year));
        raise notice 'create partition table range in %', idx_year;
    end loop;
end $$;