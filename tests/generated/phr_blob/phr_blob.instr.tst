PL/SQL Developer Test script 3.0
203
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
    l_lob                           phr_blob;
    l_null_phr                      phr_blob;
    l_null_small                    raw(1);
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
    l_lob := new_lob(hextoraw('616263616263'));

    -- assert
    assert_number(i_name => 'first occurrence', i_expected => 2, i_actual => l_lob.inStr(hextoraw('62')));
    assert_number(i_name => 'first occurrence, repeated: pending appends not consumed', i_expected => 2, i_actual => l_lob.inStr(hextoraw('62')));
    assert_number(i_name => 'first element', i_expected => 1, i_actual => l_lob.inStr(hextoraw('61')));
    assert_number(i_name => 'last element', i_expected => 6, i_actual => l_lob.inStr(hextoraw('63'), 6));
    assert_number(i_name => 'multi-element needle', i_expected => 3, i_actual => l_lob.inStr(hextoraw('6361')));
    assert_number(i_name => 'whole content as the needle', i_expected => 1, i_actual => l_lob.inStr(hextoraw('616263616263')));
    assert_number(i_name => 'from offset', i_expected => 5, i_actual => l_lob.inStr(hextoraw('62'), 3));
    assert_number(i_name => 'second occurrence', i_expected => 5, i_actual => l_lob.inStr(hextoraw('62'), 1, 2));
    assert_number(i_name => 'second occurrence from offset', i_expected => 6, i_actual => l_lob.inStr(hextoraw('63'), 3, 2));
    assert_number(i_name => 'third occurrence does not exist', i_expected => 0, i_actual => l_lob.inStr(hextoraw('62'), 1, 3));
    assert_number(i_name => 'needle not present', i_expected => 0, i_actual => l_lob.inStr(hextoraw('78')));
    assert_number(i_name => 'needle longer than the content', i_expected => 0, i_actual => l_lob.inStr(hextoraw('61616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161616161')));
    assert_number(i_name => 'offset beyond the end', i_expected => 0, i_actual => l_lob.inStr(hextoraw('62'), 20));
    assert_number(i_name => 'offset past the last occurrence', i_expected => 0, i_actual => l_lob.inStr(hextoraw('62'), 6));

    -- assert
    assert_number(i_name => 'NULL needle', i_expected => null, i_actual => l_lob.inStr(l_null_small));
    assert_number(i_name => 'zero offset', i_expected => null, i_actual => l_lob.inStr(hextoraw('62'), 0));
    assert_number(i_name => 'negative offset', i_expected => null, i_actual => l_lob.inStr(hextoraw('62'), -1));
    assert_number(i_name => 'zero occurrence', i_expected => null, i_actual => l_lob.inStr(hextoraw('62'), 1, 0));
    assert_number(i_name => 'negative occurrence', i_expected => null, i_actual => l_lob.inStr(hextoraw('62'), 1, -1));

    -- assert
    assert_number(i_name => 'nonbuffered', i_expected => 3, i_actual => phr_blob.new_tmp_lob().nonbuffered().append(hextoraw('61626364')).inStr(hextoraw('63')));
    assert_number(i_name => 'tripple buffering', i_expected => 3, i_actual => phr_blob.new_tmp_lob().tripple_buffered(c_small_secondary_buffer_size).append(hextoraw('61626364')).inStr(hextoraw('63')));
    assert_number(i_name => 'native LOB wrapped', i_expected => 3, i_actual => phr_blob.use_lob(native_lob(hextoraw('61626364'))).inStr(hextoraw('63')));
    assert_number(i_name => 'LOB over the buffer threshold: needle not present', i_expected => 0, i_actual => phr_blob.use_lob(big_native_lob()).inStr(hextoraw('78')));
    assert_number(i_name => 'LOB over the buffer threshold plus pending appends: needle in the pending part', i_expected => c_big_length + 1, i_actual => phr_blob.use_lob(big_native_lob()).append(hextoraw('7879')).inStr(hextoraw('78')));
    assert_number(i_name => 'empty LOB', i_expected => 0, i_actual => phr_blob.new_tmp_lob().inStr(hextoraw('61')));
    assert_number(i_name => 'NULL locator', i_expected => null, i_actual => phr_blob.use_lob(null).inStr(hextoraw('61')));

    -- act
    begin
        l_error := l_null_phr.inStr(hextoraw('61'));
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'inStr of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
0
0
