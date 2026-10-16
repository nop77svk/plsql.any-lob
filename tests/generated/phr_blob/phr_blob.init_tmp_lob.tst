PL/SQL Developer Test script 3.0
393
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
    l_lob                           phr_blob;
    l_source                        phr_blob;
    l_null_small                    raw(1);
    l_null_large                    blob;
    l_null_phr                      phr_blob;
    l_small_values                  arr_raw;
    l_large_values                  arr_blob;
    l_cursor                        sys_refcursor;
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
    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => hextoraw('616263'));

    -- assert
    assert_value(i_name => 'small value', i_expected => hextoraw('616263'), i_actual => l_lob.subStr(1));
    assert_number(i_name => 'small value: buffering on by default', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => hextoraw('6162'), i_repeat => 3, i_delimiter => hextoraw('2C'));

    -- assert
    assert_value(i_name => 'small value repeated with delimiter', i_expected => hextoraw('61622C61622C6162'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => l_null_small);

    -- assert
    assert_true(i_name => 'NULL small value: empty LOB, not NULL locator', i_condition => l_lob.is_empty() and l_lob.get_value() is not null);

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => hextoraw('616263'), i_repeat => 0);

    -- assert
    assert_true(i_name => 'small value repeated zero times', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => hextoraw('616263'), i_buffered_writes => false, i_cache => false, i_duration => dbms_lob.session);

    -- assert
    assert_number(i_name => 'small value, boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'small value, boolean flags: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'small value, boolean flags: duration', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);
    assert_value(i_name => 'small value, boolean flags: content', i_expected => hextoraw('616263'), i_actual => l_lob.subStr(1));

    -- act
    l_lob.tmp_dispose();
    l_lob := phr_blob.init_tmp_lob(i_value => hextoraw('6162'), i_buffered_writes => c_flag_no, i_cache => c_flag_no, i_repeat => 2, i_delimiter => hextoraw('2D'));

    -- assert
    assert_number(i_name => 'small value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'small value, SQL-boolean flags: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_value(i_name => 'small value, SQL-boolean flags: content', i_expected => hextoraw('61622D6162'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => native_lob(hextoraw('616263')));

    -- assert
    assert_value(i_name => 'native LOB value', i_expected => hextoraw('616263'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => big_native_lob());

    -- assert
    assert_number(i_name => 'native LOB value over the buffer threshold: length', i_expected => c_big_length, i_actual => l_lob.length());

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => native_lob(hextoraw('6162')), i_repeat => 2, i_delimiter => hextoraw('2F'));

    -- assert
    assert_value(i_name => 'native LOB value repeated with delimiter', i_expected => hextoraw('61622F6162'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => l_null_large);

    -- assert
    assert_true(i_name => 'NULL native LOB value: empty LOB', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => native_lob(hextoraw('616263')), i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'native LOB value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'native LOB value, SQL-boolean flags: content', i_expected => hextoraw('616263'), i_actual => l_lob.subStr(1));

    -- arrange
    l_source := new_lob(hextoraw('616263'));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => l_source);
    l_source.append(hextoraw('64'));

    -- assert
    assert_value(i_name => 'phr LOB value: deep copy', i_expected => hextoraw('616263'), i_actual => l_lob.subStr(1));
    assert_value(i_name => 'phr LOB value: source untouched by the copy', i_expected => hextoraw('61626364'), i_actual => l_source.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => l_source, i_repeat => 2, i_delimiter => hextoraw('7C'));

    -- assert
    assert_value(i_name => 'phr LOB value repeated with delimiter', i_expected => hextoraw('616263647C61626364'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => l_null_phr);

    -- assert
    assert_true(i_name => 'NULL phr LOB value: empty LOB', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_blob.init_tmp_lob(i_value => l_source, i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'phr LOB value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'phr LOB value, SQL-boolean flags: content', i_expected => hextoraw('61626364'), i_actual => l_lob.subStr(1));

    -- arrange
    l_small_values := arr_raw(hextoraw('61'), hextoraw('62'), hextoraw('63'));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_small_values);

    -- assert
    assert_value(i_name => 'small collection', i_expected => hextoraw('616263'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_small_values, i_delimiter => hextoraw('2C'), i_value_prefix => hextoraw('5B'), i_value_suffix => hextoraw('5D'));

    -- assert
    assert_value(i_name => 'small collection with delimiter, prefix and suffix', i_expected => hextoraw('5B615D2C5B625D2C5B635D'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => arr_raw());

    -- assert
    assert_true(i_name => 'empty small collection', i_condition => l_lob.is_empty());

    -- arrange
    l_small_values := null;

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_small_values);

    -- assert
    assert_true(i_name => 'NULL small collection', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => arr_raw(hextoraw('61'), hextoraw('62')), i_delimiter => hextoraw('2B'), i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'small collection, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'small collection, SQL-boolean flags: content', i_expected => hextoraw('612B62'), i_actual => l_lob.subStr(1));

    -- arrange
    l_large_values := arr_blob(native_lob(hextoraw('61')), native_lob(hextoraw('62')), native_lob(hextoraw('63')));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_large_values, i_delimiter => hextoraw('2C'), i_value_prefix => hextoraw('28'), i_value_suffix => hextoraw('29'));

    -- assert
    assert_value(i_name => 'LOB collection with delimiter, prefix and suffix', i_expected => hextoraw('2861292C2862292C286329'), i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => arr_blob());

    -- assert
    assert_true(i_name => 'empty LOB collection', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_large_values, i_delimiter => hextoraw('3B'), i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'LOB collection, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'LOB collection, SQL-boolean flags: content', i_expected => hextoraw('613B623B63'), i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, hextoraw('61') as V from dual
            union all
            select 2 as N, hextoraw('62') as V from dual
            union all
            select 3 as N, hextoraw('63') as V from dual
        )
        order by N;

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_cursor, i_delimiter => hextoraw('2C'), i_value_prefix => hextoraw('3C'), i_value_suffix => hextoraw('3E'));

    -- assert
    assert_value(i_name => 'ref cursor', i_expected => hextoraw('3C613E2C3C623E2C3C633E'), i_actual => l_lob.subStr(1));
    assert_true(i_name => 'ref cursor: closed afterwards', i_condition => not l_cursor%isopen);

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, hextoraw('61') as V from dual
            union all
            select 2 as N, hextoraw('62') as V from dual
            union all
            select 3 as N, hextoraw('63') as V from dual
        )
        order by N;

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_cursor, i_batch_size => 2, i_fetch_to_lobs => false, i_delimiter => hextoraw('2E'));

    -- assert
    assert_value(i_name => 'ref cursor, small buffers, multiple batches', i_expected => hextoraw('612E622E63'), i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, hextoraw('61') as V from dual
            union all
            select 2 as N, hextoraw('62') as V from dual
        )
        order by N;

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_cursor, i_fetch_to_lobs => c_flag_no, i_buffered_writes => c_flag_no, i_batch_size => 1);

    -- assert
    assert_number(i_name => 'ref cursor, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'ref cursor, SQL-boolean flags: content', i_expected => hextoraw('6162'), i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, hextoraw('61') as V from dual
            where 1 = 0
        )
        order by N;

    -- act
    l_lob := phr_blob.init_tmp_lob(i_values => l_cursor);

    -- assert
    assert_true(i_name => 'empty ref cursor', i_condition => l_lob.is_empty());
end;
0
0
