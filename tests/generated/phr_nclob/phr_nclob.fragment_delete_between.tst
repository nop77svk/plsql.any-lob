PL/SQL Developer Test script 3.0
261
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
    c_big_chunk_count               constant pls_integer := trunc(16383 / c_chunk_length) + 1;
    c_big_length                    constant pls_integer := c_big_chunk_count * c_chunk_length;
    c_threshold                     constant pls_integer := 16383;
    c_small_secondary_buffer_size   constant pls_integer := 2;
    c_charset                       constant varchar2(32) := 'AL32UTF8';
    l_lob                           phr_nclob;
    l_result                        phr_nclob;
    l_suffix                        varchar2(32);

    function error_of_fragment_delete_between
        ( i_from                        in integer
        , i_to                          in integer )
        return pls_integer
    is
        l_lob                           phr_nclob := phr_nclob.new_tmp_lob();
        l_result                        phr_nclob;
    begin
        l_lob.append(n'abcdef');
        l_result := l_lob.fragment_delete_between(i_from => i_from, i_to => i_to);
        return c_no_error;
    exception
        when others then
            return sqlcode;
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
        , i_expected                    in nvarchar2
        , i_actual                      in nvarchar2 )
    is
    begin
        if i_expected = i_actual or (i_expected is null and i_actual is null) then
            dbms_output.put_line('PASS '||i_name);
        else
            raise_application_error(c_assertion_failed_error, 'FAIL '||i_name||': expected ['||to_char(i_expected)||'] actual ['||to_char(i_actual)||']');
        end if;
    end;

    function new_lob
        ( i_value                       in nvarchar2 default null )
        return phr_nclob
    is
        l_result                        phr_nclob := phr_nclob.new_tmp_lob();
    begin
        l_result.append(i_value);
        return l_result;
    end;

    function native_lob
        ( i_value                       in nvarchar2 default null )
        return nclob
    is
        l_result                        nclob;
    begin
        dbms_lob.createTemporary(
            lob_loc => l_result,
            cache => true
        );

        if i_value is not null then
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => length(i_value),
                buffer => i_value
            );
        end if;

        return l_result;
    end;

    function native_lob_of_length
        ( i_length                      in pls_integer )
        return nclob
    is
        l_result                        nclob := native_lob();
        l_remaining                     pls_integer := i_length;
        l_amount                        pls_integer;
    begin
        while l_remaining > 0 loop
            l_amount := least(l_remaining, c_chunk_length);
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => l_amount,
                buffer => n'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            );
            l_remaining := l_remaining - l_amount;
        end loop;

        return l_result;
    end;

    function new_lob_at_level
        ( i_level                       in pls_integer )
        return phr_nclob
    is
    begin
        return case i_level
            when c_level_nonbuffered then phr_nclob.new_tmp_lob().nonbuffered()
            when c_level_double then phr_nclob.new_tmp_lob().double_buffered()
            else phr_nclob.new_tmp_lob().tripple_buffered(i_buffer_size => c_small_secondary_buffer_size)
        end;
    end;

    function big_native_lob
        return nclob
    is
        l_result                        nclob := native_lob();
    begin
        for i in 1..c_big_chunk_count loop
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => c_chunk_length,
                buffer => n'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            );
        end loop;

        return l_result;
    end;
begin
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level).append(n'abcdef');

        -- act
        l_result := l_lob.fragment_delete_between(2, 4);

        -- assert
        assert_value(i_name => 'middle'||l_suffix, i_expected => n'aef', i_actual => l_result.subStr(1));
        assert_value(i_name => 'middle: original untouched'||l_suffix, i_expected => n'abcdef', i_actual => l_lob.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(3, 3);

        -- assert
        assert_value(i_name => 'single element'||l_suffix, i_expected => n'abdef', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(1, 2);

        -- assert
        assert_value(i_name => 'head'||l_suffix, i_expected => n'cdef', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(5, 6);

        -- assert
        assert_value(i_name => 'tail'||l_suffix, i_expected => n'abcd', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(5, 100);

        -- assert
        assert_value(i_name => 'upper bound beyond the end'||l_suffix, i_expected => n'abcd', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(1, 6);

        -- assert
        assert_true(i_name => 'whole content'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.fragment_delete_between(10, 12);

        -- assert
        assert_value(i_name => 'both bounds beyond the end: unchanged'||l_suffix, i_expected => n'abcdef', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(3, 2);

        -- assert
        assert_value(i_name => 'upper bound right below the lower bound: unchanged'||l_suffix, i_expected => n'abcdef', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(1, 2).fragment_delete_between(1, 2);

        -- assert
        assert_value(i_name => 'chained'||l_suffix, i_expected => n'ef', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(2, 5).append(n'xyz');

        -- assert
        assert_value(i_name => 'appending after the deletion'||l_suffix, i_expected => n'afxyz', i_actual => l_result.subStr(1));
    end loop;

    -- assert
    assert_number(i_name => 'NULL lower bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(null, 2));
    assert_number(i_name => 'NULL upper bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(1, null));
    assert_number(i_name => 'both bounds NULL are rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(null, null));
    assert_number(i_name => 'upper bound far below the lower bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(4, 2));
    assert_number(i_name => 'negative lower bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(-1, 2));
    assert_true(i_name => 'zero lower bound is rejected', i_condition => error_of_fragment_delete_between(0, 2) != c_no_error);
    assert_number(i_name => 'valid bounds', i_expected => c_no_error, i_actual => error_of_fragment_delete_between(1, 2));

    -- act
    l_result := phr_nclob.new_tmp_lob().fragment_delete_between(1, 5);

    -- assert
    assert_true(i_name => 'empty LOB: stays empty', i_condition => l_result.is_empty());

    -- act
    l_result := phr_nclob.use_lob(big_native_lob()).fragment_delete_between(1, c_chunk_length);

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length - c_chunk_length, i_actual => l_result.length());
end;
0
0
