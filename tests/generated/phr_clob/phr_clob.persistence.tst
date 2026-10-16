PL/SQL Developer Test script 3.0
280
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
    l_lob                           phr_clob;
    l_native                        clob;
    l_null_lob                      phr_clob;
    l_error                         pls_integer;
    c_secure_table                  constant varchar2(30) := 'phr_tst_clob_sf';
    c_basic_table                   constant varchar2(30) := 'phr_tst_clob_bf';

    procedure drop_persistent_tables
    is
        e_table_does_not_exist          exception;
        pragma exception_init(e_table_does_not_exist, -942);
    begin
        begin
            execute immediate 'drop table '||c_secure_table||' purge';
        exception
            when e_table_does_not_exist then
                null;
        end;

        begin
            execute immediate 'drop table '||c_basic_table||' purge';
        exception
            when e_table_does_not_exist then
                null;
        end;
    end;

    procedure create_persistent_tables
    is
    begin
        drop_persistent_tables();
        execute immediate 'create table '||c_secure_table||' (v clob) lob (v) store as securefile';
        execute immediate 'create table '||c_basic_table||' (v clob) lob (v) store as basicfile';
    end;

    function persistent_lob
        ( i_secure                      in boolean )
        return clob
    is
        l_result                        clob;
    begin
        execute immediate 'insert into '||case when i_secure then c_secure_table else c_basic_table end||' (v) values (empty_clob()) returning v into :1'
            returning into l_result;
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
    -- arrange
    create_persistent_tables();

    -- act
    l_lob := phr_clob.new_tmp_lob();

    -- assert
    assert_true(i_name => 'temporary LOB: is_persistent', i_condition => not l_lob.is_persistent());
    assert_flag(i_name => 'temporary LOB: is_persistent$', i_expected => c_flag_no, i_actual => l_lob.is_persistent$());
    assert_true(i_name => 'temporary LOB: is_secure_file', i_condition => not l_lob.is_secure_file());
    assert_flag(i_name => 'temporary LOB: is_secure_file$', i_expected => c_flag_no, i_actual => l_lob.is_secure_file$());

    -- act
    l_lob := phr_clob.use_lob(native_lob('abc'));

    -- assert
    assert_true(i_name => 'wrapped temporary LOB: is_persistent', i_condition => not l_lob.is_persistent());

    -- arrange
    l_native := persistent_lob(i_secure => true);

    -- act
    l_lob := phr_clob.use_lob(l_native);

    -- assert
    assert_true(i_name => 'SecureFile LOB: is_persistent', i_condition => l_lob.is_persistent());
    assert_flag(i_name => 'SecureFile LOB: is_persistent$', i_expected => c_flag_yes, i_actual => l_lob.is_persistent$());
    assert_true(i_name => 'SecureFile LOB: is_secure_file', i_condition => l_lob.is_secure_file());
    assert_flag(i_name => 'SecureFile LOB: is_secure_file$', i_expected => c_flag_yes, i_actual => l_lob.is_secure_file$());

    -- arrange
    l_native := persistent_lob(i_secure => false);

    -- act
    l_lob := phr_clob.use_lob(l_native, false);

    -- assert
    assert_true(i_name => 'BasicFile LOB: is_persistent', i_condition => l_lob.is_persistent());
    assert_flag(i_name => 'BasicFile LOB: is_persistent$', i_expected => c_flag_yes, i_actual => l_lob.is_persistent$());
    assert_true(i_name => 'BasicFile LOB: is_secure_file', i_condition => not l_lob.is_secure_file());
    assert_flag(i_name => 'BasicFile LOB: is_secure_file$', i_expected => c_flag_no, i_actual => l_lob.is_secure_file$());

    -- act
    l_lob := phr_clob.use_lob(null);

    -- assert
    assert_true(i_name => 'NULL locator: is_persistent', i_condition => l_lob.is_persistent() is null);
    assert_true(i_name => 'NULL locator: is_persistent$', i_condition => l_lob.is_persistent$() is null);
    assert_true(i_name => 'NULL locator: is_secure_file', i_condition => l_lob.is_secure_file() is null);
    assert_true(i_name => 'NULL locator: is_secure_file$', i_condition => l_lob.is_secure_file$() is null);

    -- act
    begin
        l_error := case when l_null_lob.is_persistent() then 1 else 0 end;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'is_persistent of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);

    -- act
    begin
        l_error := case when l_null_lob.is_secure_file() then 1 else 0 end;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'is_secure_file of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);

    -- cleanup
    rollback;
    drop_persistent_tables();
exception
    when others then
        rollback;
        drop_persistent_tables();
        raise;
end;
0
0
