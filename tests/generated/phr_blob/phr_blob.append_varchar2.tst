PL/SQL Developer Test script 3.0
291
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
    c_invalid_charset               constant varchar2(32) := 'NO_SUCH_CHARSET';
    l_lob                           phr_blob;
    l_result                        phr_blob;
    l_null_reverse                  varchar2(1);
    l_suffix                        varchar2(32);
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
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level).with_raw_conversion_charset(c_charset);

        -- act
        l_result := l_lob.append_varchar2('abc');

        -- assert
        assert_value(i_name => 'value: content'||l_suffix, i_expected => hextoraw('616263'), i_actual => l_result.subStr(1));
        assert_number(i_name => 'value: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append_varchar2('ab').append_varchar2('cd');

        -- assert
        assert_value(i_name => 'chained'||l_suffix, i_expected => hextoraw('61626364'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_varchar2('ab', 3);

        -- assert
        assert_value(i_name => 'repeated'||l_suffix, i_expected => hextoraw('616261626162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_varchar2('ab', 3, ',');

        -- assert
        assert_value(i_name => 'repeated with delimiter'||l_suffix, i_expected => hextoraw('61622C61622C6162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_varchar2('ab', 1, ',');

        -- assert
        assert_value(i_name => 'once with delimiter: no delimiter'||l_suffix, i_expected => hextoraw('6162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_varchar2('ab', 0, ',');

        -- assert
        assert_true(i_name => 'repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append_varchar2(l_null_reverse, 3, ',');

        -- assert
        assert_true(i_name => 'NULL value: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append_varchar2('ab', 2, l_null_reverse);

        -- assert
        assert_value(i_name => 'NULL delimiter'||l_suffix, i_expected => hextoraw('61626162'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(hextoraw('78')).append_varchar2('abc').append(hextoraw('79'));

        -- assert
        assert_value(i_name => 'mixed with regular appends'||l_suffix, i_expected => hextoraw('7861626379'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_varchar2(unistr('\011B'));

        -- assert
        assert_value(i_name => 'multibyte value'||l_suffix, i_expected => hextoraw('C49B'), i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_varchar2(unistr('\011B'), 2, ',');

        -- assert
        assert_value(i_name => 'multibyte value repeated with delimiter'||l_suffix, i_expected => hextoraw('C49B')||hextoraw('2C')||hextoraw('C49B'), i_actual => l_result.subStr(1));
    end loop;

    -- arrange
    l_lob := phr_blob.new_tmp_lob();

    -- act
    begin
        l_result := l_lob.append_varchar2('abc');
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'no charset is rejected', i_expected => c_invalid_argument_error, i_actual => l_error);

    -- act
    begin
        l_result := l_lob.with_raw_conversion_charset(c_charset).with_raw_conversion_charset(null).append_varchar2('abc');
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'reset charset is rejected', i_expected => c_invalid_argument_error, i_actual => l_error);

    -- act
    begin
        l_result := l_lob.append_varchar2(l_null_reverse);
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'no charset is rejected even for a NULL value', i_expected => c_invalid_argument_error, i_actual => l_error);

    -- act
    begin
        l_result := l_lob.with_raw_conversion_charset(c_invalid_charset).append_varchar2('abc');
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'unknown charset: no error', i_expected => c_no_error, i_actual => l_error);
    assert_true(i_name => 'unknown charset: nothing is appended', i_condition => l_result.is_empty());

    -- act
    l_result := phr_blob.use_lob(big_native_lob()).with_raw_conversion_charset(c_charset).append_varchar2('abc');

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length + 3, i_actual => l_result.length());
end;
0
0
