PL/SQL Developer Test script 3.0
591
declare
    c_assertion_failed_error        constant pls_integer := -20000;
    c_no_error                      constant pls_integer := 0;
    c_invalid_argument_error        constant pls_integer := phr_anylob_exc.CE_Invalid_Argument;
    c_value_error                   constant pls_integer := -6502;
    c_invalid_lob_length_error      constant pls_integer := -21560;
    c_null_self_error               constant pls_integer := -30625;
    c_invalid_data_type_error       constant pls_integer := phr_anylob_exc.CE_Invalid_Data_Type;
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
    c_delimiter_length              constant pls_integer := 1;
    l_lob                           phr_blob;
    l_result                        phr_blob;
    l_source                        phr_blob;
    l_null_phr                      phr_blob;
    l_null_small                    raw(1);
    l_null_native                   blob;
    l_small_values                  arr_raw;
    l_large_values                  arr_blob;
    l_null_small_values             arr_raw;
    l_null_large_values             arr_blob;
    l_cursor                        sys_refcursor;
    l_suffix                        varchar2(32);
    l_error                         pls_integer;

    function cursor_of_small
        ( i_values                      in arr_raw )
        return sys_refcursor
    is
        l_result                        sys_refcursor;
    begin
        open l_result for
            select X.V
            from (
                select T.column_value as V, rownum as N
                from table(i_values) T
            ) X
            order by X.N;
        return l_result;
    end;

    function cursor_of_large
        ( i_values                      in arr_blob )
        return sys_refcursor
    is
        l_result                        sys_refcursor;
    begin
        open l_result for
            select X.V
            from (
                select T.column_value as V, rownum as N
                from table(i_values) T
            ) X
            order by X.N;
        return l_result;
    end;
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
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level);

        -- act
        l_result := l_lob.append(hextoraw('616263'));

        -- assert
        assert_value(i_name => 'small value: content'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_result.subStr(1));
        assert_number(i_name => 'small value: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_result.append(hextoraw('6465')).append(hextoraw('66'));

        -- assert
        assert_value(i_name => 'small value: chained'||l_suffix, i_expected => hextoraw('616263646566'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(hextoraw('6162'), 3);

        -- assert
        assert_value(i_name => 'small value repeated'||l_suffix, i_expected => hextoraw('616261626162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(hextoraw('6162'), 3, hextoraw('2C'));

        -- assert
        assert_value(i_name => 'small value repeated with delimiter'||l_suffix, i_expected => hextoraw('61622C61622C6162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(hextoraw('6162'), 1, hextoraw('2C'));

        -- assert
        assert_value(i_name => 'small value once with delimiter: no delimiter'||l_suffix, i_expected => hextoraw('6162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(hextoraw('6162'), 2, hextoraw('2D2D'));

        -- assert
        assert_value(i_name => 'small value with multi-character delimiter'||l_suffix, i_expected => hextoraw('61622D2D6162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(hextoraw('6162'), 0);

        -- assert
        assert_true(i_name => 'small value repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(hextoraw('6162'), -3, hextoraw('2C'));

        -- assert
        assert_true(i_name => 'small value repeated negative times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_small, 3, hextoraw('2C'));

        -- assert
        assert_true(i_name => 'NULL small value: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(hextoraw('61')).append(l_null_small).append(hextoraw('62'));

        -- assert
        assert_value(i_name => 'NULL small value between two values'||l_suffix, i_expected => hextoraw('6162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(hextoraw('61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161'), c_big_chunk_count);

        -- assert
        assert_number(i_name => 'small values over the buffer threshold: length'||l_suffix, i_expected => c_big_length, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(hextoraw('61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161'), c_big_chunk_count, hextoraw('2C'));

        -- assert
        assert_number(i_name => 'small values over the buffer threshold with delimiter: length'||l_suffix, i_expected => c_big_length + (c_big_chunk_count - 1) * c_delimiter_length, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(hextoraw('78')).append(hextoraw('61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161'), c_big_chunk_count).append(hextoraw('79'));

        -- assert
        assert_value(i_name => 'small values over the buffer threshold: first value'||l_suffix, i_expected => hextoraw('78'), i_actual => l_result.subStr(1, 1));
        assert_value(i_name => 'small values over the buffer threshold: last value'||l_suffix, i_expected => hextoraw('79'), i_actual => l_result.subStr(l_result.length(), 1));
        assert_number(i_name => 'small values over the buffer threshold: length'||l_suffix, i_expected => c_big_length + 2, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(native_lob(hextoraw('616263')));

        -- assert
        assert_value(i_name => 'LOB: content'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_result.subStr(1));
        assert_number(i_name => 'LOB: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(native_lob(hextoraw('6162')), 3, hextoraw('2C'));

        -- assert
        assert_value(i_name => 'LOB repeated with delimiter'||l_suffix, i_expected => hextoraw('61622C61622C6162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(native_lob(hextoraw('6162')), 0);

        -- assert
        assert_true(i_name => 'LOB repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_native, 2, hextoraw('2C'));

        -- assert
        assert_true(i_name => 'NULL LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(native_lob(), 2, hextoraw('2C'));

        -- assert
        assert_true(i_name => 'empty LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(native_lob_of_length(c_threshold));

        -- assert
        assert_number(i_name => 'LOB of the buffer threshold length: length'||l_suffix, i_expected => c_threshold, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(native_lob_of_length(c_threshold + 1));

        -- assert
        assert_number(i_name => 'LOB over the buffer threshold length: length'||l_suffix, i_expected => c_threshold + 1, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(hextoraw('78')).append(big_native_lob()).append(hextoraw('79'));

        -- assert
        assert_value(i_name => 'LOB over the buffer threshold between small values: first value'||l_suffix, i_expected => hextoraw('78'), i_actual => l_result.subStr(1, 1));
        assert_value(i_name => 'LOB over the buffer threshold between small values: last value'||l_suffix, i_expected => hextoraw('79'), i_actual => l_result.subStr(l_result.length(), 1));
        assert_number(i_name => 'LOB over the buffer threshold between small values: length'||l_suffix, i_expected => c_big_length + 2, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(big_native_lob(), 2, hextoraw('2C'));

        -- assert
        assert_number(i_name => 'LOB over the buffer threshold repeated with delimiter: length'||l_suffix, i_expected => c_big_length * 2 + c_delimiter_length, i_actual => l_result.length());
        assert_value(i_name => 'LOB over the buffer threshold repeated with delimiter: delimiter'||l_suffix, i_expected => hextoraw('2C'), i_actual => l_result.subStr(c_big_length + 1, 1));

        -- arrange
        l_source := new_lob(hextoraw('616263'));

        -- act
        l_result := l_lob.append(l_source);

        -- assert
        assert_value(i_name => 'phr LOB: content'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_result.subStr(1));
        assert_value(i_name => 'phr LOB: source untouched'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_source.subStr(1));
        assert_number(i_name => 'phr LOB: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(l_source, 2, hextoraw('7C'));

        -- assert
        assert_value(i_name => 'phr LOB repeated with delimiter'||l_suffix, i_expected => hextoraw('6162637C616263'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(l_source, 0);

        -- assert
        assert_true(i_name => 'phr LOB repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_phr, 2, hextoraw('7C'));

        -- assert
        assert_true(i_name => 'NULL phr LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(phr_blob.new_tmp_lob(), 2, hextoraw('7C'));

        -- assert
        assert_true(i_name => 'empty phr LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(phr_blob.use_lob(big_native_lob()));

        -- assert
        assert_number(i_name => 'phr LOB over the buffer threshold: length'||l_suffix, i_expected => c_big_length, i_actual => l_result.length());

        -- arrange
        l_small_values := arr_raw(hextoraw('61'), hextoraw('62'), hextoraw('63'));

        -- act
        l_result := l_lob.append(l_small_values);

        -- assert
        assert_value(i_name => 'small collection'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_result.subStr(1));
        assert_number(i_name => 'small collection: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(l_small_values, hextoraw('2C'));

        -- assert
        assert_value(i_name => 'small collection with delimiter'||l_suffix, i_expected => hextoraw('612C622C63'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(l_small_values, hextoraw('2C'), hextoraw('5B'), hextoraw('5D'));

        -- assert
        assert_value(i_name => 'small collection with delimiter, prefix and suffix'||l_suffix, i_expected => hextoraw('5B615D2C5B625D2C5B635D'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(i_values => l_small_values, i_value_prefix => hextoraw('3C'));

        -- assert
        assert_value(i_name => 'small collection with prefix only'||l_suffix, i_expected => hextoraw('3C613C623C63'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(i_values => l_small_values, i_value_suffix => hextoraw('3E'));

        -- assert
        assert_value(i_name => 'small collection with suffix only'||l_suffix, i_expected => hextoraw('613E623E633E'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(arr_raw(), hextoraw('2C'), hextoraw('5B'), hextoraw('5D'));

        -- assert
        assert_true(i_name => 'empty small collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_small_values, hextoraw('2C'), hextoraw('5B'), hextoraw('5D'));

        -- assert
        assert_true(i_name => 'NULL small collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(arr_raw(hextoraw('61'), l_null_small, hextoraw('63')), hextoraw('2C'));

        -- assert
        assert_value(i_name => 'small collection with a NULL element'||l_suffix, i_expected => hextoraw('612C2C63'), i_actual => l_result.subStr(1));

        -- arrange
        l_small_values := arr_raw(hextoraw('61'), hextoraw('62'), hextoraw('63'));
        l_small_values.delete(1);

        -- act
        l_result := l_lob.append(l_small_values, hextoraw('2C'));

        -- assert
        assert_value(i_name => 'sparse small collection: no leading delimiter'||l_suffix, i_expected => hextoraw('622C63'), i_actual => l_result.subStr(1));

        -- arrange
        l_small_values := arr_raw();
        l_small_values.extend(c_big_chunk_count);
        for i in 1..c_big_chunk_count loop
            l_small_values(i) := hextoraw('61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161');
        end loop;

        -- act
        l_result := l_lob.append(l_small_values);

        -- assert
        assert_number(i_name => 'small collection over the buffer threshold: length'||l_suffix, i_expected => c_big_length, i_actual => l_result.length());

        -- arrange
        l_large_values := arr_blob(native_lob(hextoraw('61')), native_lob(hextoraw('62')), native_lob(hextoraw('63')));

        -- act
        l_result := l_lob.append(l_large_values);

        -- assert
        assert_value(i_name => 'LOB collection'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_result.subStr(1));
        assert_number(i_name => 'LOB collection: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(l_large_values, hextoraw('2C'), hextoraw('28'), hextoraw('29'));

        -- assert
        assert_value(i_name => 'LOB collection with delimiter, prefix and suffix'||l_suffix, i_expected => hextoraw('2861292C2862292C286329'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(arr_blob(), hextoraw('2C'));

        -- assert
        assert_true(i_name => 'empty LOB collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_large_values, hextoraw('2C'));

        -- assert
        assert_true(i_name => 'NULL LOB collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(arr_blob(native_lob(hextoraw('61')), l_null_native, native_lob(hextoraw('63'))), hextoraw('2C'));

        -- assert
        assert_value(i_name => 'LOB collection with a NULL element'||l_suffix, i_expected => hextoraw('612C2C63'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(arr_blob(native_lob(hextoraw('61')), big_native_lob(), native_lob(hextoraw('63'))), hextoraw('2C'));

        -- assert
        assert_number(i_name => 'LOB collection with a LOB over the buffer threshold: length'||l_suffix, i_expected => c_big_length + 2 + 2 * c_delimiter_length, i_actual => l_result.length());
        assert_value(i_name => 'LOB collection with a LOB over the buffer threshold: last value'||l_suffix, i_expected => hextoraw('63'), i_actual => l_result.subStr(l_result.length(), 1));

        -- arrange
        l_small_values := arr_raw(hextoraw('61'), hextoraw('62'), hextoraw('63'));
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, hextoraw('2C'), 100, true, hextoraw('5B'), hextoraw('5D'));

        -- assert
        assert_value(i_name => 'ref cursor fetched to LOBs'||l_suffix, i_expected => hextoraw('5B615D2C5B625D2C5B635D'), i_actual => l_result.subStr(1));
        assert_true(i_name => 'ref cursor fetched to LOBs: closed afterwards'||l_suffix, i_condition => not l_cursor%isopen);
        assert_number(i_name => 'ref cursor fetched to LOBs: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, hextoraw('2C'), 2, false);

        -- assert
        assert_value(i_name => 'ref cursor fetched to small values, multiple batches'||l_suffix, i_expected => hextoraw('612C622C63'), i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(i_values => l_cursor, i_batch_size => 1);

        -- assert
        assert_value(i_name => 'ref cursor, batch of one row'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, hextoraw('2C'), 2, c_flag_no, hextoraw('3C'), hextoraw('3E'));

        -- assert
        assert_value(i_name => 'ref cursor, SQL-boolean flag N'||l_suffix, i_expected => hextoraw('3C613E2C3C623E2C3C633E'), i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, hextoraw('2C'), 100, c_flag_yes);

        -- assert
        assert_value(i_name => 'ref cursor, SQL-boolean flag Y'||l_suffix, i_expected => hextoraw('612C622C63'), i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(arr_raw());

        -- act
        l_result := l_lob.append(l_cursor, hextoraw('2C'), 100, true, hextoraw('5B'), hextoraw('5D'));

        -- assert
        assert_true(i_name => 'empty ref cursor: nothing appended'||l_suffix, i_condition => l_result.is_empty());
        assert_true(i_name => 'empty ref cursor: closed afterwards'||l_suffix, i_condition => not l_cursor%isopen);

        -- arrange
        l_cursor := cursor_of_small(arr_raw(hextoraw('61'), l_null_small, hextoraw('63')));

        -- act
        l_result := l_lob.append(l_cursor, hextoraw('2C'), 100, false);

        -- assert
        assert_value(i_name => 'ref cursor with a NULL row'||l_suffix, i_expected => hextoraw('612C2C63'), i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_large(arr_blob(native_lob(hextoraw('61')), native_lob(hextoraw('62')), big_native_lob()));

        -- act
        l_result := l_lob.append(l_cursor, hextoraw('2C'), 2, true);

        -- assert
        assert_number(i_name => 'ref cursor of LOBs, including one over the buffer threshold: length'||l_suffix, i_expected => c_big_length + 2 + 2 * c_delimiter_length, i_actual => l_result.length());
        assert_value(i_name => 'ref cursor of LOBs, including one over the buffer threshold: head'||l_suffix, i_expected => hextoraw('612C622C'), i_actual => l_result.subStr(1, 4));
    end loop;

    -- act
    begin
        l_result := l_null_phr.append(hextoraw('61'));
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'append to a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
0
0
