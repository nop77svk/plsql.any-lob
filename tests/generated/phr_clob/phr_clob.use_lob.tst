PL/SQL Developer Test script 3.0
196
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
    c_charset                       constant varchar2(32) := 'AL32UTF8';
    l_lob                           phr_clob;
    l_native                        clob;
    l_null_native                   clob;
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
    -- arrange
    l_native := native_lob('abc');

    -- act
    l_lob := phr_clob.use_lob(l_native);

    -- assert
    assert_value(i_name => 'default flags: content', i_expected => 'abc', i_actual => l_lob.subStr(1));
    assert_number(i_name => 'default flags: buffering on', i_expected => c_level_double, i_actual => l_lob.buffering_level$);
    assert_true(i_name => 'default flags: not marked as own temporary LOB', i_condition => l_lob.tmp_lob_cached$ is null and l_lob.tmp_lob_duration$ is null);
    assert_value(i_name => 'default flags: eoln', i_expected => chr(10), i_actual => l_lob.eoln$);

    -- act
    l_lob := phr_clob.use_lob(i_value => l_native, i_buffered_writes => false);

    -- assert
    assert_number(i_name => 'boolean flag off: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'boolean flag off: content', i_expected => 'abc', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.use_lob(i_value => l_native, i_buffered_writes => true);

    -- assert
    assert_number(i_name => 'boolean flag on: buffering', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_clob.use_lob(l_native, c_flag_no);

    -- assert
    assert_number(i_name => 'SQL-boolean flag N: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'SQL-boolean flag N: content', i_expected => 'abc', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_clob.use_lob(l_native, c_flag_yes);

    -- assert
    assert_number(i_name => 'SQL-boolean flag Y: buffering', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_clob.use_lob(l_native, 'garbage');

    -- assert
    assert_number(i_name => 'SQL-boolean flag unrecognized: buffering off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_clob.use_lob();

    -- assert
    assert_true(i_name => 'no arguments: NULL locator', i_condition => l_lob.get_value() is null);
    assert_number(i_name => 'no arguments: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'no arguments: is empty', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_clob.use_lob(l_null_native, c_flag_no);

    -- assert
    assert_true(i_name => 'NULL locator, SQL-boolean flag: length 0', i_condition => l_lob.length() = 0);

    -- arrange
    l_lob := phr_clob.use_lob(l_null_native, false);

    -- act
    begin
        l_lob.append('x');
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'append to NULL locator is rejected', i_expected => c_value_error, i_actual => l_error);

    -- act
    l_lob := phr_clob.use_lob(big_native_lob());

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length, i_actual => l_lob.length());

    -- act
    l_lob := phr_clob.use_lob(native_lob());

    -- assert
    assert_true(i_name => 'empty native LOB: is empty', i_condition => l_lob.is_empty());
    assert_true(i_name => 'empty native LOB: locator kept', i_condition => l_lob.get_value() is not null);
end;
0
0
