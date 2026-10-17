PL/SQL Developer Test script 3.0
328
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
    l_lob                           phr_clob;
    l_result                        phr_clob;
    l_null_small                    varchar2(1);
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
        , i_expected                    in varchar2
        , i_actual                      in varchar2 )
    is
    begin
        if i_expected = i_actual or (i_expected is null and i_actual is null) then
            dbms_output.put_line('PASS '||i_name);
        else
            raise_application_error(c_assertion_failed_error, 'FAIL '||i_name||': expected ['||to_char(i_expected)||'] actual ['||to_char(i_actual)||']');
        end if;
    end;

    function new_lob
        ( i_value                       in varchar2 default null )
        return phr_clob
    is
        l_result                        phr_clob := phr_clob.new_tmp_lob();
    begin
        l_result.append(i_value);
        return l_result;
    end;

    function native_lob
        ( i_value                       in varchar2 default null )
        return clob
    is
        l_result                        clob;
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
        return clob
    is
        l_result                        clob := native_lob();
        l_remaining                     pls_integer := i_length;
        l_amount                        pls_integer;
    begin
        while l_remaining > 0 loop
            l_amount := least(l_remaining, c_chunk_length);
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => l_amount,
                buffer => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            );
            l_remaining := l_remaining - l_amount;
        end loop;

        return l_result;
    end;

    function new_lob_at_level
        ( i_level                       in pls_integer )
        return phr_clob
    is
    begin
        return case i_level
            when c_level_nonbuffered then phr_clob.new_tmp_lob().nonbuffered()
            when c_level_double then phr_clob.new_tmp_lob().double_buffered()
            else phr_clob.new_tmp_lob().tripple_buffered(i_buffer_size => c_small_secondary_buffer_size)
        end;
    end;

    function big_native_lob
        return clob
    is
        l_result                        clob := native_lob();
    begin
        for i in 1..c_big_chunk_count loop
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => c_chunk_length,
                buffer => 'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            );
        end loop;

        return l_result;
    end;
begin
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level).append('a[xx]b');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']');

        -- assert
        assert_value(i_name => 'delimited portion'||l_suffix, i_expected => 'ab', i_actual => l_result.subStr(1));
        assert_value(i_name => 'delimited portion: original untouched'||l_suffix, i_expected => 'a[xx]b', i_actual => l_lob.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('abc[def');

        -- act
        l_result := l_lob.fragment_delete_from_to('[');

        -- assert
        assert_value(i_name => 'open-ended, NULL end needle by default'||l_suffix, i_expected => 'abc', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to('[', l_null_small);

        -- assert
        assert_value(i_name => 'open-ended, explicit NULL end needle'||l_suffix, i_expected => 'abc', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('a[1]b[2]c');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']');

        -- assert
        assert_value(i_name => 'single iteration by default'||l_suffix, i_expected => 'ab[2]c', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']', 2);

        -- assert
        assert_value(i_name => 'two iterations'||l_suffix, i_expected => 'abc', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']', 5);

        -- assert
        assert_value(i_name => 'more iterations than occurrences'||l_suffix, i_expected => 'abc', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']', 0);

        -- assert
        assert_value(i_name => 'zero iterations: unchanged'||l_suffix, i_expected => 'a[1]b[2]c', i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']').fragment_delete_from_to('[', ']');

        -- assert
        assert_value(i_name => 'chained'||l_suffix, i_expected => 'abc', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('abc');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']');

        -- assert
        assert_value(i_name => 'start needle missing: unchanged'||l_suffix, i_expected => 'abc', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('a[1');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']');

        -- assert
        assert_value(i_name => 'end needle missing: unchanged'||l_suffix, i_expected => 'a[1', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('a[1]b[2');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']', 2);

        -- assert
        assert_value(i_name => 'end needle missing for the second occurrence only'||l_suffix, i_expected => 'ab[2', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('x<!--c1-->y<!--c2-->z');

        -- act
        l_result := l_lob.fragment_delete_from_to('<!--', '-->', 2);

        -- assert
        assert_value(i_name => 'multi-element needles'||l_suffix, i_expected => 'xyz', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('[a][b]c');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']', 2);

        -- assert
        assert_value(i_name => 'adjacent portions'||l_suffix, i_expected => 'c', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('[a]bc');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']');

        -- assert
        assert_value(i_name => 'portion at the start'||l_suffix, i_expected => 'bc', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('bc[a]');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']');

        -- assert
        assert_value(i_name => 'portion at the end'||l_suffix, i_expected => 'bc', i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append('[a]');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', ']');

        -- assert
        assert_true(i_name => 'portion is the whole content'||l_suffix, i_condition => l_result.is_empty());

        -- arrange
        l_lob := new_lob_at_level(l_level).append('a[b[c');

        -- act
        l_result := l_lob.fragment_delete_from_to('[', l_null_small, 2);

        -- assert
        assert_value(i_name => 'open-ended with more iterations: deleted up to the end once'||l_suffix, i_expected => 'a', i_actual => l_result.subStr(1));
    end loop;

    -- arrange
    l_lob := new_lob_at_level(c_level_double).append('abc');

    -- act
    begin
        l_result := l_lob.fragment_delete_from_to(l_null_small, ']');
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_true(i_name => 'NULL start needle is rejected', i_condition => l_error != c_no_error);

    -- act
    l_result := phr_clob.new_tmp_lob().fragment_delete_from_to('[', ']');

    -- assert
    assert_true(i_name => 'empty LOB: stays empty', i_condition => l_result.is_empty());

    -- act
    l_result := phr_clob.use_lob(big_native_lob()).append('[x]').fragment_delete_from_to('[', ']');

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length, i_actual => l_result.length());
end;
0
0
