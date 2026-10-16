set serveroutput on size unlimited
set define off
whenever sqlerror exit failure rollback

-- Requires phr_clob, phr_nclob and phr_blob compiled in the current schema. Prints PASS/FAIL per check and fails the script on any failure.

declare
    c_lf                            constant varchar2(1) := chr(10);
    c_crlf                          constant varchar2(2) := chr(13)||chr(10);
    c_multibyte                     constant varchar2(4 char) := unistr('\011B\0161\010D\0159');
    c_multibyte_length              constant pls_integer := 4;
    c_big_chunk_length              constant pls_integer := 32000;
    c_big_chunk_count               constant pls_integer := 2;
    c_eol_raw                       constant raw(1) := hextoraw('0A');
    c_payload_raw                   constant raw(1) := hextoraw('AA');
    c_length_less                   constant number := -0.1;
    c_length_greater                constant number := 0.1;
    c_equal                         constant number := 0;
    c_lob_1_lower                   constant number := -1;
    c_lob_1_greater                 constant number := 1;
    c_failed_tests_error            constant pls_integer := -20000;

    g_failures                      pls_integer := 0;

    procedure report
        ( i_test                        in varchar2
        , i_expected                    in varchar2
        , i_actual                      in varchar2 )
    is
    begin
        if i_expected = i_actual or (i_expected is null and i_actual is null) then
            dbms_output.put_line('PASS '||i_test);
        else
            g_failures := g_failures + 1;
            dbms_output.put_line('FAIL '||i_test||': expected ['||i_expected||'] actual ['||i_actual||']');
        end if;
    end;

    function tmp_clob
        ( i_value                       in varchar2 default null )
        return phr_clob
    is
        l_result                        phr_clob := phr_clob.new_tmp_lob();
    begin
        l_result.append(i_value);
        return l_result;
    end;

    function error_code_of_fragment_delete
        ( i_offset                      in integer
        , i_amount                      in integer )
        return integer
    is
        l_lob                           phr_clob := tmp_clob('abcdef');
    begin
        l_lob.fragment_delete(i_offset, i_amount);
        return null;
    exception
        when others then
            return sqlcode;
    end;

    procedure test_new_tmp_lob_overloads
    is
        c_cache_off_flag                constant varchar2(1) := 'N';
        l_default                       phr_clob := phr_clob.new_tmp_lob();
        l_sql_boolean                   phr_clob := phr_clob.new_tmp_lob('Y');
        l_session_duration              phr_clob := phr_clob.new_tmp_lob(i_cache => c_cache_off_flag, i_duration => dbms_lob.session);
    begin
        -- act
        l_default.append('a');
        l_sql_boolean.append('bc');
        l_session_duration.append('def');

        -- assert
        report('new_tmp_lob() without arguments', '1', to_char(l_default.length()));
        report('new_tmp_lob with SQL-boolean flag', '2', to_char(l_sql_boolean.length()));
        report('new_tmp_lob with cache off and session duration', '3', to_char(l_session_duration.length()));
    end;

    procedure test_append_multibyte
    is
        l_lob                           phr_clob := phr_clob.new_tmp_lob();
    begin
        -- act
        l_lob.append(c_multibyte);

        -- assert
        report('append multibyte: length', to_char(c_multibyte_length), to_char(l_lob.length()));
        report('append multibyte: content', c_multibyte, l_lob.subStr(1));
    end;

    procedure test_append_null_and_empty
    is
        l_lob                           phr_clob := tmp_clob('abc');
        l_null_varchar2                 varchar2(1);
        l_null_clob                     clob;
        l_empty_clob                    clob;
    begin
        -- arrange
        dbms_lob.createTemporary(l_empty_clob, true);

        -- act
        l_lob.append(l_null_varchar2);
        l_lob.append(l_null_clob);
        l_lob.append(l_empty_clob);

        -- assert
        report('append null/empty is no-op', 'abc', l_lob.subStr(1));

        dbms_lob.freeTemporary(l_empty_clob);
    end;

    procedure test_compare_both_null_locators
    is
        l_lob_1                         phr_clob := phr_clob.use_lob(null);
        l_lob_2                         phr_clob := phr_clob.use_lob(null);
    begin
        -- act + assert
        report('compare both NULL locators, nulls equal', to_char(c_equal), to_char(l_lob_1.compare(l_lob_2, true)));
        report('compare both NULL locators, nulls distinct', null, to_char(l_lob_1.compare(l_lob_2, false)));
    end;

    procedure test_compare_null_object
    is
        l_lob_1                         phr_clob := tmp_clob('abc');
        l_lob_2                         phr_clob;
    begin
        -- act + assert
        report('compare with NULL object', null, to_char(l_lob_1.compare(l_lob_2, true)));
    end;

    procedure test_compare_one_null_locator
    is
        l_null_lob                      phr_clob := phr_clob.use_lob(null);
        l_empty_lob                     phr_clob := tmp_clob();
        l_filled_lob                    phr_clob := tmp_clob('abc');
    begin
        -- act + assert
        report('compare NULL locator vs empty, length first', to_char(c_equal), to_char(l_null_lob.compare(l_empty_lob, false, true)));
        report('compare NULL locator vs empty, contents only', to_char(c_equal), to_char(l_null_lob.compare(l_empty_lob, false, false)));
        report('compare empty vs NULL locator', to_char(c_equal), to_char(l_empty_lob.compare(l_null_lob, false, false)));
        report('compare NULL locator vs filled', to_char(c_length_less), to_char(l_null_lob.compare(l_filled_lob, false, false)));
        report('compare filled vs NULL locator', to_char(c_length_greater), to_char(l_filled_lob.compare(l_null_lob, false, false)));
    end;

    procedure test_compare_contents
    is
        l_lob_abcd                      phr_clob := tmp_clob('abcd');
        l_lob_abxd                      phr_clob := tmp_clob('abxd');
        l_lob_abcd_copy                 phr_clob := tmp_clob('abcd');
        l_lob_abc                       phr_clob := tmp_clob('abc');
    begin
        -- act + assert
        report('compare equal contents', to_char(c_equal), to_char(l_lob_abcd.compare(l_lob_abcd_copy)));
        report('compare shorter, length first', to_char(c_length_less), to_char(l_lob_abc.compare(l_lob_abcd)));
        report('compare longer, length first', to_char(c_length_greater), to_char(l_lob_abcd.compare(l_lob_abc)));
        report('compare lower contents', to_char(c_lob_1_lower), to_char(l_lob_abcd.compare(l_lob_abxd)));
        report('compare greater contents', to_char(c_lob_1_greater), to_char(l_lob_abxd.compare(l_lob_abcd)));
        report('compare SQL-boolean overload', to_char(c_equal), to_char(l_lob_abcd.compare(l_lob_abcd_copy, 'N', 'N')));
        report('compare plain CLOB overload', to_char(c_lob_1_lower), to_char(l_lob_abcd.compare(l_lob_abxd.get_value())));
    end;

    procedure test_fragment_delete_invalid_arguments
    is
        c_invalid_argument              constant integer := phr_anylob_exc.CE_Invalid_Argument;
    begin
        -- act + assert
        report('fragment_delete NULL offset', to_char(c_invalid_argument), to_char(error_code_of_fragment_delete(null, 1)));
        report('fragment_delete NULL amount', to_char(c_invalid_argument), to_char(error_code_of_fragment_delete(1, null)));
        report('fragment_delete NULL amount, zero offset', to_char(c_invalid_argument), to_char(error_code_of_fragment_delete(0, null)));
        report('fragment_delete zero offset', to_char(c_invalid_argument), to_char(error_code_of_fragment_delete(0, 1)));
        report('fragment_delete negative offset', to_char(c_invalid_argument), to_char(error_code_of_fragment_delete(-1, 1)));
        report('fragment_delete negative amount', to_char(c_invalid_argument), to_char(error_code_of_fragment_delete(1, -1)));
        report('fragment_delete zero amount is valid', null, to_char(error_code_of_fragment_delete(1, 0)));
    end;

    procedure test_fragment_delete_ranges
    is
        l_middle                        phr_clob := tmp_clob('abcdef');
        l_tail                          phr_clob := tmp_clob('abcdef');
        l_beyond                        phr_clob := tmp_clob('abc');
        l_zero_amount                   phr_clob := tmp_clob('abc');
        l_whole                         phr_clob := tmp_clob('abc');
    begin
        -- act
        l_middle.fragment_delete(2, 3);
        l_tail.fragment_delete(4, 100);
        l_beyond.fragment_delete(10, 2);
        l_zero_amount.fragment_delete(2, 0);
        l_whole.fragment_delete(1, 3);

        -- assert
        report('fragment_delete middle', 'aef', l_middle.subStr(1));
        report('fragment_delete tail', 'abc', l_tail.subStr(1));
        report('fragment_delete beyond end', 'abc', l_beyond.subStr(1));
        report('fragment_delete zero amount', 'abc', l_zero_amount.subStr(1));
        report('fragment_delete whole', '0', to_char(l_whole.length()));
    end;

    procedure test_fragment_delete_between_and_from_to
    is
        l_between                       phr_clob := tmp_clob('abcdef');
        l_from_to                       phr_clob := tmp_clob('a[xx]b');
        l_from_to_open                  phr_clob := tmp_clob('abc[def');
        l_from_to_repeated              phr_clob := tmp_clob('a[1]b[2]c');
        l_from_to_missing               phr_clob := tmp_clob('abc');
    begin
        -- act
        l_between.fragment_delete_between(2, 4);
        l_from_to.fragment_delete_from_to('[', ']');
        l_from_to_open.fragment_delete_from_to('[', null);
        l_from_to_repeated.fragment_delete_from_to('[', ']', 2);
        l_from_to_missing.fragment_delete_from_to('[', ']');

        -- assert
        report('fragment_delete_between', 'aef', l_between.subStr(1));
        report('fragment_delete_from_to', 'ab', l_from_to.subStr(1));
        report('fragment_delete_from_to open ended', 'abc', l_from_to_open.subStr(1));
        report('fragment_delete_from_to repeated', 'abc', l_from_to_repeated.subStr(1));
        report('fragment_delete_from_to needle missing', 'abc', l_from_to_missing.subStr(1));
    end;

    procedure test_appendln_varchar2
    is
        l_value_lf                      phr_clob := phr_clob.new_tmp_lob();
        l_null_value                    phr_clob := phr_clob.new_tmp_lob();
        l_multibyte                     phr_clob := phr_clob.new_tmp_lob();
        l_null_varchar2                 varchar2(1);
    begin
        -- act
        l_value_lf.appendln('abc');
        l_null_value.appendln(l_null_varchar2);
        l_multibyte.appendln(c_multibyte);

        -- assert
        report('appendln value + LF', 'abc'||c_lf, l_value_lf.subStr(1));
        report('appendln NULL value', c_lf, l_null_value.subStr(1));
        report('appendln multibyte', c_multibyte||c_lf, l_multibyte.subStr(1));
    end;

    procedure test_eoln_configuration
    is
        l_crlf                          phr_clob := phr_clob.new_tmp_lob();
        l_no_eoln                       phr_clob := phr_clob.new_tmp_lob();
        l_with_eoln                     phr_clob;
        l_use_lob                       phr_clob;
        l_source                        clob;
        l_null_varchar2                 varchar2(1);
    begin
        -- arrange
        dbms_lob.createTemporary(l_source, true);
        l_use_lob := phr_clob.use_lob(l_source);

        -- act
        l_crlf.use_eoln(c_crlf);
        l_crlf.appendln('abc');
        l_no_eoln.use_eoln(l_null_varchar2);
        l_no_eoln.appendln('abc');
        l_no_eoln.appendln();
        l_with_eoln := phr_clob.new_tmp_lob().with_eoln(c_crlf);
        l_with_eoln := l_with_eoln.appendln('a').appendln('b');
        l_use_lob.appendln('x');

        -- assert
        report('use_eoln custom CRLF', 'abc'||c_crlf, l_crlf.subStr(1));
        report('use_eoln NULL appends no terminator', 'abc', l_no_eoln.subStr(1));
        report('with_eoln chaining', 'a'||c_crlf||'b'||c_crlf, l_with_eoln.subStr(1));
        report('use_lob instance has default LF', 'x'||c_lf, l_use_lob.subStr(1));

        dbms_lob.freeTemporary(l_source);
    end;

    procedure test_appendln_no_argument_and_chaining
    is
        l_empty_line                    phr_clob := phr_clob.new_tmp_lob();
        l_chained                       phr_clob;
    begin
        -- act
        l_empty_line.appendln();
        l_chained := phr_clob.new_tmp_lob().appendln('a').appendln('b').appendln();

        -- assert
        report('appendln no-arg', c_lf, l_empty_line.subStr(1));
        report('appendln chaining', 'a'||c_lf||'b'||c_lf||c_lf, l_chained.subStr(1));
    end;

    procedure test_appendln_clob
    is
        l_lob                           phr_clob := phr_clob.new_tmp_lob();
        l_big                           clob;
        l_null_clob                     clob;
        c_terminator_offset             constant integer := c_big_chunk_length * c_big_chunk_count + 1;
    begin
        -- arrange
        dbms_lob.createTemporary(l_big, true);
        for i in 1..c_big_chunk_count loop
            dbms_lob.writeAppend(l_big, c_big_chunk_length, rpad('x', c_big_chunk_length, 'x'));
        end loop;

        -- act
        l_lob.appendln(l_big);
        l_lob.appendln(l_null_clob);

        -- assert
        report('appendln big CLOB length', to_char(c_terminator_offset + 1), to_char(l_lob.length()));
        report('appendln big CLOB terminator', c_lf, l_lob.subStr(c_terminator_offset, 1));
        report('appendln NULL CLOB is terminator only', c_lf, l_lob.subStr(c_terminator_offset + 1, 1));

        dbms_lob.freeTemporary(l_big);
    end;

    procedure test_appendln_nclob
    is
        l_lob                           phr_nclob := phr_nclob.new_tmp_lob();
    begin
        -- act
        l_lob.appendln(to_nchar(c_multibyte));

        -- assert
        report('appendln NCLOB length', to_char(c_multibyte_length + 1), to_char(l_lob.length()));
        report('appendln NCLOB terminator', c_lf, to_char(l_lob.subStr(c_multibyte_length + 1, 1)));
    end;

    procedure test_appendln_blob
    is
        c_crlf_raw                      constant raw(2) := hextoraw('0D0A');
        l_lob                           phr_blob := phr_blob.new_tmp_lob();
        l_empty_line                    phr_blob := phr_blob.new_tmp_lob();
        l_custom_eoln                   phr_blob := phr_blob.new_tmp_lob().with_eoln(c_crlf_raw);
    begin
        -- act
        l_lob.appendln(c_payload_raw);
        l_empty_line.appendln();
        l_custom_eoln.appendln(c_payload_raw);

        -- assert
        report('appendln BLOB value + LF', rawtohex(utl_raw.concat(c_payload_raw, c_eol_raw)), rawtohex(l_lob.subStr(1)));
        report('appendln BLOB no-arg', rawtohex(c_eol_raw), rawtohex(l_empty_line.subStr(1)));
        report('appendln BLOB custom eoln', rawtohex(utl_raw.concat(c_payload_raw, c_crlf_raw)), rawtohex(l_custom_eoln.subStr(1)));
    end;
begin
    test_new_tmp_lob_overloads();
    test_append_multibyte();
    test_append_null_and_empty();
    test_compare_both_null_locators();
    test_compare_null_object();
    test_compare_one_null_locator();
    test_compare_contents();
    test_fragment_delete_invalid_arguments();
    test_fragment_delete_ranges();
    test_fragment_delete_between_and_from_to();
    test_appendln_varchar2();
    test_eoln_configuration();
    test_appendln_no_argument_and_chaining();
    test_appendln_clob();
    test_appendln_nclob();
    test_appendln_blob();

    if g_failures > 0 then
        raise_application_error(c_failed_tests_error, g_failures||' check(s) failed');
    end if;
end;
/
