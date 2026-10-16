PL/SQL Developer Test script 3.0
345
declare
    c_assertion_failed_error        constant pls_integer := -20000;
    c_no_error                      constant pls_integer := 0;
    c_invalid_argument_error        constant pls_integer := phr_utl_exc.CE_Invalid_Argument;
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
    c_charset                       constant varchar2(32) := 'AL32UTF8';
    c_bfile_directory               constant varchar2(128) := 'DIR_ANYTHING';
    c_bfile_name                    constant varchar2(128) := 'phr_clob_test.bin';
    l_lob                           phr_clob;
    l_source                        phr_clob;
    l_null_small                    varchar2(1);
    l_null_large                    clob;
    l_null_phr                      phr_clob;
    l_small_values                  arr_varchar2;
    l_large_values                  arr_clob;
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
    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => 'abc');

    -- assert
    assert_value(i_name => 'small value', i_expected => 'abc', i_actual => l_lob.subStr(1));
    assert_number(i_name => 'small value: buffering on by default', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => 'ab', i_repeat => 3, i_delimiter => ',');

    -- assert
    assert_value(i_name => 'small value repeated with delimiter', i_expected => 'ab,ab,ab', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => l_null_small);

    -- assert
    assert_true(i_name => 'NULL small value: empty LOB, not NULL locator', i_condition => l_lob.is_empty() and l_lob.get_value() is not null);

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => 'abc', i_repeat => 0);

    -- assert
    assert_true(i_name => 'small value repeated zero times', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => 'abc', i_buffered_writes => false, i_cache => false, i_duration => dbms_lob.session);

    -- assert
    assert_number(i_name => 'small value, boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'small value, boolean flags: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'small value, boolean flags: duration', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);
    assert_value(i_name => 'small value, boolean flags: content', i_expected => 'abc', i_actual => l_lob.subStr(1));

    -- act
    l_lob.tmp_dispose();
    l_lob := phr_clob.init_tmp_lob(i_value => 'ab', i_buffered_writes => c_flag_no, i_cache => c_flag_no, i_repeat => 2, i_delimiter => '-');

    -- assert
    assert_number(i_name => 'small value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'small value, SQL-boolean flags: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_value(i_name => 'small value, SQL-boolean flags: content', i_expected => 'ab-ab', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => native_lob('abc'));

    -- assert
    assert_value(i_name => 'native LOB value', i_expected => 'abc', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => big_native_lob());

    -- assert
    assert_number(i_name => 'native LOB value over the buffer threshold: length', i_expected => c_big_length, i_actual => l_lob.length());

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => native_lob('ab'), i_repeat => 2, i_delimiter => '/');

    -- assert
    assert_value(i_name => 'native LOB value repeated with delimiter', i_expected => 'ab/ab', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => l_null_large);

    -- assert
    assert_true(i_name => 'NULL native LOB value: empty LOB', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => native_lob('abc'), i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'native LOB value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'native LOB value, SQL-boolean flags: content', i_expected => 'abc', i_actual => l_lob.subStr(1));

    -- arrange
    l_source := new_lob('abc');

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => l_source);
    l_source.append('d');

    -- assert
    assert_value(i_name => 'phr LOB value: deep copy', i_expected => 'abc', i_actual => l_lob.subStr(1));
    assert_value(i_name => 'phr LOB value: source untouched by the copy', i_expected => 'abcd', i_actual => l_source.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => l_source, i_repeat => 2, i_delimiter => '|');

    -- assert
    assert_value(i_name => 'phr LOB value repeated with delimiter', i_expected => 'abcd|abcd', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => l_null_phr);

    -- assert
    assert_true(i_name => 'NULL phr LOB value: empty LOB', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_clob.init_tmp_lob(i_value => l_source, i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'phr LOB value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'phr LOB value, SQL-boolean flags: content', i_expected => 'abcd', i_actual => l_lob.subStr(1));

    -- arrange
    l_small_values := arr_varchar2('a', 'b', 'c');

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_small_values);

    -- assert
    assert_value(i_name => 'small collection', i_expected => 'abc', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_small_values, i_delimiter => ',', i_value_prefix => '[', i_value_suffix => ']');

    -- assert
    assert_value(i_name => 'small collection with delimiter, prefix and suffix', i_expected => '[a],[b],[c]', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => arr_varchar2());

    -- assert
    assert_true(i_name => 'empty small collection', i_condition => l_lob.is_empty());

    -- arrange
    l_small_values := null;

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_small_values);

    -- assert
    assert_true(i_name => 'NULL small collection', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => arr_varchar2('a', 'b'), i_delimiter => '+', i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'small collection, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'small collection, SQL-boolean flags: content', i_expected => 'a+b', i_actual => l_lob.subStr(1));

    -- arrange
    l_large_values := arr_clob(native_lob('a'), native_lob('b'), native_lob('c'));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_large_values, i_delimiter => ',', i_value_prefix => '(', i_value_suffix => ')');

    -- assert
    assert_value(i_name => 'LOB collection with delimiter, prefix and suffix', i_expected => '(a),(b),(c)', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => arr_clob());

    -- assert
    assert_true(i_name => 'empty LOB collection', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_large_values, i_delimiter => ';', i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'LOB collection, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'LOB collection, SQL-boolean flags: content', i_expected => 'a;b;c', i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, 'a' as V from dual
            union all
            select 2 as N, 'b' as V from dual
            union all
            select 3 as N, 'c' as V from dual
        )
        order by N;

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_cursor, i_delimiter => ',', i_value_prefix => '<', i_value_suffix => '>');

    -- assert
    assert_value(i_name => 'ref cursor', i_expected => '<a>,<b>,<c>', i_actual => l_lob.subStr(1));
    assert_true(i_name => 'ref cursor: closed afterwards', i_condition => not l_cursor%isopen);

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, 'a' as V from dual
            union all
            select 2 as N, 'b' as V from dual
            union all
            select 3 as N, 'c' as V from dual
        )
        order by N;

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_cursor, i_batch_size => 2, i_fetch_to_lobs => false, i_delimiter => '.');

    -- assert
    assert_value(i_name => 'ref cursor, small buffers, multiple batches', i_expected => 'a.b.c', i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, 'a' as V from dual
            union all
            select 2 as N, 'b' as V from dual
        )
        order by N;

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_cursor, i_fetch_to_lobs => c_flag_no, i_buffered_writes => c_flag_no, i_batch_size => 1);

    -- assert
    assert_number(i_name => 'ref cursor, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'ref cursor, SQL-boolean flags: content', i_expected => 'ab', i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, 'a' as V from dual
            where 1 = 0
        )
        order by N;

    -- act
    l_lob := phr_clob.init_tmp_lob(i_values => l_cursor);

    -- assert
    assert_true(i_name => 'empty ref cursor', i_condition => l_lob.is_empty());
end;
0
0
