create or replace function itfcdmpv53w.fn_crte_view_allyears(sch_name text, tbl_name text default '') returns void language plpgsql as $$
declare tmp_query text := '';
declare sch_name text := sch_name;
declare tbl_name text := tbl_name;
declare table_arr text[];
declare tbl text;
declare drop_query text;
declare tbl_row record;
declare start_year int := 2004;
declare end_year int := extract(year from now());
declare year_cnt int := 0;

begin
    for tbl_row in select table_name from information_schema."tables" where table_schema = sch_name and table_name similar to concat(tbl_name, '%y\d{4}') order by table_name
    loop
        year_cnt := year_cnt + 1;
        tmp_query := tmp_query ||
        replace(replace(tbl_row::text, '(', format('select * from %s.', 'itfcdmpv53w')), ')', ' union all ') ;
    end loop;

    if year_cnt < (end_year - start_year + 1) then
        raise exception 'Several years of data are lacking.' using hint = 'Check Partition Table List.';
        return;
    end if;

    tmp_query := substring(tmp_query, 1, length(tmp_query) - length(' union all '));
    tmp_query := format('create view %s.vw_%s as ', sch_name, tbl_name) || tmp_query;

    drop_query := format('drop view if exists %s.vw_%s', sch_name, tbl_name);

    execute drop_query;
    execute tmp_query;

    return;
end $$;

-- create view: itf_ip
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_ip_device_exposure');
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_ip_drug_exposure');
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_ip_order');
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_ip_procedure_occurrence');

--create view: itf_op
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_op_device_exposure');
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_op_drug_exposure');
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_op_order');
select itfcdmpv53w.fn_crte_view_allyears('itfcdmpv53w', 'pre_itf_op_procedure_occurrence');