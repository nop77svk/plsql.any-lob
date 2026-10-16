PL/SQL Developer Test script 3.0
218
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
    c_big_chunk_count               constant pls_integer := trunc(16383 / c_chunk_length) + 1;
    c_big_length                    constant pls_integer := c_big_chunk_count * c_chunk_length;
    c_threshold                     constant pls_integer := 16383;
    c_charset                       constant varchar2(32) := 'AL32UTF8';
    l_lob                           phr_nclob;
    l_native                        nclob;
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
    -- arrange
    l_lob := phr_nclob.new_tmp_lob(i_cache => false, i_duration => dbms_lob.session);
    l_lob.append(n'abc');

    -- act
    l_lob.tmp_dispose();

    -- assert
    assert_true(i_name => 'tmp_dispose: LOB released', i_condition => l_lob.the_value$ is null);
    assert_true(i_name => 'tmp_dispose: primary buffer cleared', i_condition => l_lob.primary_buffer$ is null);
    assert_true(i_name => 'tmp_dispose: cache flag cleared', i_condition => l_lob.tmp_lob_cached$ is null);
    assert_true(i_name => 'tmp_dispose: duration cleared', i_condition => l_lob.tmp_lob_duration$ is null);
    assert_number(i_name => 'tmp_dispose: length', i_expected => 0, i_actual => l_lob.length());

    -- act
    l_lob.tmp_dispose();

    -- assert
    assert_true(i_name => 'tmp_dispose twice: still disposed', i_condition => l_lob.the_value$ is null);

    -- arrange
    l_lob := phr_nclob.use_lob(null);

    -- act
    l_lob.tmp_dispose();

    -- assert
    assert_true(i_name => 'tmp_dispose on NULL locator: no-op', i_condition => l_lob.the_value$ is null);

    -- act
    l_lob.tmp_initialize(i_cache => false, i_duration => dbms_lob.session);

    -- assert
    assert_true(i_name => 'tmp_initialize on a disposed object: new LOB', i_condition => l_lob.the_value$ is not null);
    assert_true(i_name => 'tmp_initialize on a disposed object: temporary', i_condition => not l_lob.is_persistent());
    assert_number(i_name => 'tmp_initialize on a disposed object: cache flag', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_initialize on a disposed object: duration', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);
    assert_number(i_name => 'tmp_initialize on a disposed object: length', i_expected => 0, i_actual => l_lob.length());

    -- arrange
    l_lob := phr_nclob.new_tmp_lob();
    l_lob.append(n'abc');
    l_lob.fsync();
    l_lob.append(n'def');

    -- act
    l_lob.tmp_initialize(i_cache => true);

    -- assert
    assert_number(i_name => 'tmp_initialize on a filled object: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'tmp_initialize on a filled object: pending appends dropped', i_condition => l_lob.primary_buffer$ is null);
    assert_number(i_name => 'tmp_initialize: cache flag on', i_expected => 1, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_initialize: default duration', i_expected => dbms_lob.call, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.append(n'xyz');

    -- assert
    assert_value(i_name => 'tmp_initialize: usable for appends', i_expected => n'xyz', i_actual => l_lob.subStr(1));

    -- arrange
    l_lob := phr_nclob.new_tmp_lob(i_cache => false, i_duration => dbms_lob.session);
    l_lob.append(n'abc');

    -- act
    l_lob.tmp_reinitialize();

    -- assert
    assert_number(i_name => 'tmp_reinitialize: emptied', i_expected => 0, i_actual => l_lob.length());
    assert_number(i_name => 'tmp_reinitialize: cache flag kept', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_reinitialize: duration kept', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.append(n'def');

    -- assert
    assert_value(i_name => 'tmp_reinitialize: usable for appends', i_expected => n'def', i_actual => l_lob.subStr(1));

    -- arrange
    l_lob := phr_nclob.use_lob(native_lob(n'abc'));

    -- act
    begin
        l_lob.tmp_reinitialize();
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'tmp_reinitialize on a foreign LOB is rejected', i_expected => c_invalid_data_type_error, i_actual => l_error);

    -- arrange
    l_lob := phr_nclob.new_tmp_lob();
    l_lob.tmp_dispose();

    -- act
    begin
        l_lob.tmp_reinitialize();
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'tmp_reinitialize on a disposed object is rejected', i_expected => c_invalid_data_type_error, i_actual => l_error);
end;
0
0
