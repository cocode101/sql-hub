create or replace function itfcdmpv53w.fn_year_days(thisyear varchar) returns varchar language plpgsql as $$
declare thisyear int := thisyear;
begin
    if (thisyear%4 = 0) and (thisyear%100 = 0) and (thisyear%400 = 0)then
        return 366;
    elseif (thisyear%4 = 0) and (thisyear%100 = 0) and (thisyear%400 <> 0) then
        return 365;
    elseif (thisyear%4 = 0) then
        return 366;
    else
        return 365;
    end if;
end
$$;