PL/SQL Developer Test script 3.0
277
declare
    c_assertion_failed_error        constant pls_integer := -20000;
    c_no_error                      constant pls_integer := 0;
    c_invalid_argument_error        constant pls_integer := phr_utl_exc.CE_Invalid_Argument;
    c_value_error                   constant pls_integer := -6502;
    c_invalid_lob_length_error      constant pls_integer := -21560;
    c_null_self_error               constant pls_integer := -30625;
    c_invalid_data_type_error       constant pls_integer := phr_utl_exc.CE_Invalid_Data_Type;
    c_flag_yes                      constant varchar2(1) := 'Y';
    c_flag_no                       constant varchar2(1) := 'N';
    c_length_less                   constant number := -0.1;
    c_length_greater                constant number := 0.1;
    c_level_nonbuffered             constant pls_integer := 0;
    c_level_double                  constant pls_integer := 1;
    c_level_tripple                 constant pls_integer := 2;
    c_chunk_length                  constant pls_integer := 1000;
    c_big_chunk_count               constant pls_integer := trunc(32767 / c_chunk_length) + 1;
    c_big_length                    constant pls_integer := c_big_chunk_count * c_chunk_length;
    c_threshold                     constant pls_integer := 32767;
    c_small_secondary_buffer_size   constant pls_integer := 2;
    c_charset                       constant varchar2(32) := 'AL32UTF8';
    c_difference_lower              constant number := -1;
    c_difference_greater            constant number := 1;
    l_abc                           phr_blob;
    l_null_lob                      phr_blob;
    l_null_locator                  phr_blob := phr_blob.use_lob(null);
    l_empty                         phr_blob := phr_blob.new_tmp_lob();
    l_null_native                   blob;
    l_rank                          pls_integer;
    l_sorted                        arr_raw := arr_raw();
    l_error                         pls_integer;
    procedure assert_true
        ( i_name                        in varchar2
        , i_condition                   in boolean )
    is
    begin
        if i_condition then
            dbms_output.put_line('PASS '||i_name);
        else
            raise_application_error(c_assertion_failed_error, 'FAIL '||i_name);
        end if;
    end;

    procedure assert_number
        ( i_name                        in varchar2
        , i_expected                    in number
        , i_actual                      in number )
    is
    begin
        if i_expected = i_actual or (i_expected is null and i_actual is null) then
            dbms_output.put_line('PASS '||i_name);
        else
            raise_application_error(c_assertion_failed_error, 'FAIL '||i_name||': expected ['||i_expected||'] actual ['||i_actual||']');
        end if;
    end;

    procedure assert_flag
        ( i_name                        in varchar2
        , i_expected                    in varchar2
        , i_actual                      in varchar2 )
    is
    begin
        if i_expected = i_actual or (i_expected is null and i_actual is null) then
            dbms_output.put_line('PASS '||i_name);
        else
            raise_application_error(c_assertion_failed_error, 'FAIL '||i_name||': expected ['||i_expected||'] actual ['||i_actual||']');
        end if;
    end;

    procedure assert_value
        ( i_name                        in varchar2
        , i_expected                    in raw
        , i_actual                      in raw )
    is
    begin
        if i_expected = i_actual or (i_expected is null and i_actual is null) then
            dbms_output.put_line('PASS '||i_name);
        else
            raise_application_error(c_assertion_failed_error, 'FAIL '||i_name||': expected ['||rawtohex(i_expected)||'] actual ['||rawtohex(i_actual)||']');
        end if;
    end;

    function new_lob
        ( i_value                       in raw default null )
        return phr_blob
    is
        l_result                        phr_blob := phr_blob.new_tmp_lob();
    begin
        l_result.append(i_value);
        return l_result;
    end;

    function native_lob
        ( i_value                       in raw default null )
        return blob
    is
        l_result                        blob;
    begin
        dbms_lob.createTemporary(
            lob_loc => l_result,
            cache => true
        );

        if i_value is not null then
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => utl_raw.length(i_value),
                buffer => i_value
            );
        end if;

        return l_result;
    end;

    function native_lob_of_length
        ( i_length                      in pls_integer )
        return blob
    is
        l_result                        blob := native_lob();
        l_remaining                     pls_integer := i_length;
        l_amount                        pls_integer;
    begin
        while l_remaining > 0 loop
            l_amount := least(l_remaining, c_chunk_length);
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => l_amount,
                buffer => hextoraw('61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161')
            );
            l_remaining := l_remaining - l_amount;
        end loop;

        return l_result;
    end;

    function new_lob_at_level
        ( i_level                       in pls_integer )
        return phr_blob
    is
    begin
        return case i_level
            when c_level_nonbuffered then phr_blob.new_tmp_lob().nonbuffered()
            when c_level_double then phr_blob.new_tmp_lob().double_buffered()
            else phr_blob.new_tmp_lob().tripple_buffered(i_buffer_size => c_small_secondary_buffer_size)
        end;
    end;

    function big_native_lob
        return blob
    is
        l_result                        blob := native_lob();
    begin
        for i in 1..c_big_chunk_count loop
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => c_chunk_length,
                buffer => hextoraw('61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161')
            );
        end loop;

        return l_result;
    end;
begin
    -- arrange
    l_abc := new_lob(hextoraw('616263'));

    -- assert
    assert_number(i_name => 'equal contents', i_expected => 0, i_actual => l_abc.compare(new_lob(hextoraw('616263'))));
    assert_number(i_name => 'equal contents, repeated: pending appends not consumed', i_expected => 0, i_actual => l_abc.compare(new_lob(hextoraw('616263'))));
    assert_number(i_name => 'same object', i_expected => 0, i_actual => l_abc.compare(l_abc));
    assert_number(i_name => 'shorter, lengths first', i_expected => c_length_less, i_actual => l_abc.compare(new_lob(hextoraw('61626364'))));
    assert_number(i_name => 'longer, lengths first', i_expected => c_length_greater, i_actual => l_abc.compare(new_lob(hextoraw('6162'))));
    assert_number(i_name => 'shorter, lengths first, explicit flag', i_expected => c_length_less, i_actual => l_abc.compare(new_lob(hextoraw('61626364')), true));
    assert_number(i_name => 'shorter, contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(hextoraw('61626364')), false));
    assert_number(i_name => 'longer, contents only', i_expected => c_difference_greater, i_actual => new_lob(hextoraw('61626364')).compare(l_abc, false));
    assert_number(i_name => 'lower contents', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(hextoraw('616264'))));
    assert_number(i_name => 'greater contents', i_expected => c_difference_greater, i_actual => new_lob(hextoraw('616264')).compare(l_abc));
    assert_number(i_name => 'lower contents, contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(hextoraw('616264')), false));
    assert_number(i_name => 'equal contents, contents only', i_expected => 0, i_actual => l_abc.compare(new_lob(hextoraw('616263')), false));
    assert_number(i_name => 'different content of the same length, lengths first', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(hextoraw('616264')), true));
    assert_number(i_name => 'empty vs empty', i_expected => 0, i_actual => l_empty.compare(phr_blob.new_tmp_lob()));
    assert_number(i_name => 'empty vs filled', i_expected => c_length_less, i_actual => l_empty.compare(l_abc));
    assert_number(i_name => 'filled vs empty', i_expected => c_length_greater, i_actual => l_abc.compare(l_empty));

    -- assert
    assert_number(i_name => 'tripple buffering vs double buffering: equal', i_expected => 0, i_actual => phr_blob.new_tmp_lob().tripple_buffered().append(hextoraw('616263')).compare(l_abc));
    assert_number(i_name => 'nonbuffered vs double buffering: equal', i_expected => 0, i_actual => phr_blob.new_tmp_lob().nonbuffered().append(hextoraw('616263')).compare(l_abc));

    -- assert
    assert_number(i_name => 'big LOBs: equal', i_expected => 0, i_actual => phr_blob.use_lob(big_native_lob()).compare(phr_blob.use_lob(big_native_lob())));
    assert_number(i_name => 'big LOBs differing in the last element', i_expected => c_difference_lower, i_actual => phr_blob.use_lob(big_native_lob()).compare(phr_blob.use_lob(big_native_lob()).append(hextoraw('62')).trim(c_big_length - 1).append(hextoraw('62'))));
    assert_number(i_name => 'big LOB vs small LOB, lengths first', i_expected => c_length_greater, i_actual => phr_blob.use_lob(big_native_lob()).compare(l_abc));

    -- assert
    assert_number(i_name => 'both NULL locators', i_expected => null, i_actual => l_null_locator.compare(l_null_locator));
    assert_number(i_name => 'both NULL locators, contents only', i_expected => null, i_actual => l_null_locator.compare(l_null_locator, false));
    assert_number(i_name => 'NULL locator vs empty LOB', i_expected => null, i_actual => l_null_locator.compare(l_empty));
    assert_number(i_name => 'empty LOB vs NULL locator', i_expected => null, i_actual => l_empty.compare(l_null_locator));
    assert_number(i_name => 'NULL locator vs filled LOB, lengths first', i_expected => c_length_less, i_actual => l_null_locator.compare(l_abc));
    assert_number(i_name => 'filled LOB vs NULL locator, lengths first', i_expected => c_length_greater, i_actual => l_abc.compare(l_null_locator));
    assert_number(i_name => 'NULL locator vs filled LOB, contents only', i_expected => null, i_actual => l_null_locator.compare(l_abc, false));
    assert_number(i_name => 'compare with a NULL object', i_expected => null, i_actual => l_abc.compare(l_null_lob));
    assert_number(i_name => 'compare with a NULL object, contents only', i_expected => null, i_actual => l_abc.compare(l_null_lob, false));

    -- act
    begin
        l_error := l_null_lob.compare(l_abc);
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'compare of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);

    -- assert
    assert_number(i_name => 'SQL-boolean Y: lengths first', i_expected => c_length_less, i_actual => l_abc.compare(new_lob(hextoraw('61626364')), c_flag_yes));
    assert_number(i_name => 'SQL-boolean N: contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(hextoraw('61626364')), c_flag_no));
    assert_number(i_name => 'SQL-boolean unrecognized flag: contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(hextoraw('61626364')), 'garbage'));
    assert_number(i_name => 'SQL-boolean N: equal contents', i_expected => 0, i_actual => l_abc.compare(new_lob(hextoraw('616263')), c_flag_no));

    -- assert
    assert_number(i_name => 'LOB: equal contents', i_expected => 0, i_actual => l_abc.compare(native_lob(hextoraw('616263'))));
    assert_number(i_name => 'LOB: shorter, lengths first', i_expected => c_length_less, i_actual => l_abc.compare(native_lob(hextoraw('61626364'))));
    assert_number(i_name => 'LOB: shorter, contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(native_lob(hextoraw('61626364')), false));
    assert_number(i_name => 'LOB: lower contents', i_expected => c_difference_lower, i_actual => l_abc.compare(native_lob(hextoraw('616264'))));
    assert_number(i_name => 'LOB: greater contents', i_expected => c_difference_greater, i_actual => l_abc.compare(native_lob(hextoraw('616262'))));
    assert_number(i_name => 'LOB: NULL locator, lengths first', i_expected => c_length_greater, i_actual => l_abc.compare(l_null_native));
    assert_number(i_name => 'LOB: NULL locator, contents only', i_expected => null, i_actual => l_abc.compare(l_null_native, false));
    assert_number(i_name => 'LOB: empty LOB vs empty LOB', i_expected => 0, i_actual => l_empty.compare(native_lob()));
    assert_number(i_name => 'LOB, SQL-boolean N: shorter', i_expected => c_difference_lower, i_actual => l_abc.compare(native_lob(hextoraw('61626364')), c_flag_no));
    assert_number(i_name => 'LOB, SQL-boolean Y: shorter', i_expected => c_length_less, i_actual => l_abc.compare(native_lob(hextoraw('61626364')), c_flag_yes));

    -- assert
    assert_number(i_name => 'ORDER method: equal', i_expected => 0, i_actual => l_abc.order$(new_lob(hextoraw('616263'))));
    assert_number(i_name => 'ORDER method: lower', i_expected => c_difference_lower, i_actual => l_abc.order$(new_lob(hextoraw('616264'))));
    assert_number(i_name => 'ORDER method: greater', i_expected => c_difference_greater, i_actual => new_lob(hextoraw('616264')).order$(l_abc));
    assert_number(i_name => 'ORDER method: shorter', i_expected => c_length_less, i_actual => l_abc.order$(new_lob(hextoraw('61626364'))));
    assert_number(i_name => 'ORDER method: NULL object', i_expected => null, i_actual => l_abc.order$(l_null_lob));

    -- act
    for r in (
        select T.V as LOB
        from (
            select phr_blob.init_tmp_lob(hextoraw('6262')) as V from dual
            union all
            select phr_blob.init_tmp_lob(hextoraw('61')) as V from dual
            union all
            select phr_blob.init_tmp_lob(hextoraw('636363')) as V from dual
            union all
            select phr_blob.init_tmp_lob(hextoraw('6261')) as V from dual
        ) T
        order by T.V
    ) loop
        l_sorted.extend();
        l_sorted(l_sorted.last()) := r.LOB.subStr(1);
    end loop;

    -- assert
    assert_number(i_name => 'ORDER BY in SQL: row count', i_expected => 4, i_actual => l_sorted.count());
    assert_value(i_name => 'ORDER BY in SQL: first', i_expected => hextoraw('61'), i_actual => l_sorted(1));
    assert_value(i_name => 'ORDER BY in SQL: second', i_expected => hextoraw('6261'), i_actual => l_sorted(2));
    assert_value(i_name => 'ORDER BY in SQL: third', i_expected => hextoraw('6262'), i_actual => l_sorted(3));
    assert_value(i_name => 'ORDER BY in SQL: last', i_expected => hextoraw('636363'), i_actual => l_sorted(4));

    -- act
    select count(*)
    into l_rank
    from dual
    where phr_blob.init_tmp_lob(hextoraw('616263')) = phr_blob.init_tmp_lob(hextoraw('616263'))
        and phr_blob.init_tmp_lob(hextoraw('616263')) != phr_blob.init_tmp_lob(hextoraw('616264'))
        and phr_blob.init_tmp_lob(hextoraw('616263')) < phr_blob.init_tmp_lob(hextoraw('616264'))
        and phr_blob.init_tmp_lob(hextoraw('616264')) > phr_blob.init_tmp_lob(hextoraw('616263'));

    -- assert
    assert_number(i_name => 'comparison operators in SQL', i_expected => 1, i_actual => l_rank);
end;
0
0
