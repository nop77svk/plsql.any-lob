PL/SQL Developer Test script 3.0
182
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
    c_big_chunk_count               constant pls_integer := trunc(16383 / c_chunk_length) + 1;
    c_big_length                    constant pls_integer := c_big_chunk_count * c_chunk_length;
    c_threshold                     constant pls_integer := 16383;
    c_charset                       constant varchar2(32) := 'AL32UTF8';
    c_bfile_directory               constant varchar2(128) := 'DIR_ANYTHING';
    c_bfile_name                    constant varchar2(128) := 'phr_nclob_test.bin';
    l_lob                           phr_nclob;
    l_session_lob                   phr_nclob;
    l_null_boolean                  boolean;
    l_null_flag                     varchar2(1);
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
    -- arrange + act
    l_lob := phr_nclob.new_tmp_lob();

    -- assert
    assert_number(i_name => 'default: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'default: is empty', i_condition => l_lob.is_empty());
    assert_true(i_name => 'default: is temporary', i_condition => not l_lob.is_persistent());
    assert_number(i_name => 'default: buffering on', i_expected => c_level_double, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'default: cache on', i_expected => 1, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'default: call duration', i_expected => dbms_lob.call, i_actual => l_lob.tmp_lob_duration$);
    assert_value(i_name => 'default: eoln', i_expected => nchr(10), i_actual => l_lob.eoln$);
    assert_true(i_name => 'default: no raw conversion charset', i_condition => l_lob.raw_conversion_charset$ is null);

    -- act
    l_lob.append(n'abc');

    -- assert
    assert_value(i_name => 'default: usable for appends', i_expected => n'abc', i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_nclob.new_tmp_lob(i_buffered_writes => false, i_cache => false);

    -- assert
    assert_number(i_name => 'boolean flags off: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'boolean flags off: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);

    -- act
    l_session_lob := phr_nclob.new_tmp_lob(i_duration => dbms_lob.session);

    -- assert
    assert_number(i_name => 'boolean overload: session duration', i_expected => dbms_lob.session, i_actual => l_session_lob.tmp_lob_duration$);

    -- act
    l_session_lob.tmp_dispose();
    l_lob := phr_nclob.new_tmp_lob(i_buffered_writes => l_null_boolean);

    -- assert
    assert_number(i_name => 'boolean overload: NULL buffering flag means off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_nclob.new_tmp_lob(c_flag_yes);

    -- assert
    assert_number(i_name => 'SQL-boolean overload: Y buffering', i_expected => c_level_double, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'SQL-boolean overload: default cache', i_expected => 1, i_actual => l_lob.tmp_lob_cached$);

    -- act
    l_lob := phr_nclob.new_tmp_lob(i_buffered_writes => c_flag_no, i_cache => c_flag_no, i_duration => dbms_lob.session);

    -- assert
    assert_number(i_name => 'SQL-boolean overload: N buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'SQL-boolean overload: N cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'SQL-boolean overload: session duration', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.tmp_dispose();
    l_lob := phr_nclob.new_tmp_lob('YES');

    -- assert
    assert_number(i_name => 'SQL-boolean overload: YES, case-insensitive', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_nclob.new_tmp_lob('garbage');

    -- assert
    assert_number(i_name => 'SQL-boolean overload: unrecognized flag means off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_nclob.new_tmp_lob(l_null_flag);

    -- assert
    assert_number(i_name => 'SQL-boolean overload: NULL flag means off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
end;
0
0
