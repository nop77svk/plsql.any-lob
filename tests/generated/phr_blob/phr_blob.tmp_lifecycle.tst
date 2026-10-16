PL/SQL Developer Test script 3.0
265
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
    l_native                        blob;
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
    l_lob := phr_blob.new_tmp_lob(i_cache => false, i_duration => dbms_lob.session);
    l_lob.append(hextoraw('616263'));

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
    l_lob := phr_blob.use_lob(null);

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
    l_lob := phr_blob.new_tmp_lob();
    l_lob.append(hextoraw('616263'));
    l_lob.fsync();
    l_lob.append(hextoraw('646566'));

    -- act
    l_lob.tmp_initialize(i_cache => true);

    -- assert
    assert_number(i_name => 'tmp_initialize on a filled object: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'tmp_initialize on a filled object: pending appends dropped', i_condition => l_lob.primary_buffer$ is null);
    assert_number(i_name => 'tmp_initialize: cache flag on', i_expected => 1, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_initialize: default duration', i_expected => dbms_lob.call, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.append(hextoraw('78797A'));

    -- assert
    assert_value(i_name => 'tmp_initialize: usable for appends', i_expected => hextoraw('78797A'), i_actual => l_lob.subStr(1));

    -- arrange
    l_lob := phr_blob.new_tmp_lob(i_cache => false, i_duration => dbms_lob.session);
    l_lob.append(hextoraw('616263'));

    -- act
    l_lob.tmp_reinitialize();

    -- assert
    assert_number(i_name => 'tmp_reinitialize: emptied', i_expected => 0, i_actual => l_lob.length());
    assert_number(i_name => 'tmp_reinitialize: cache flag kept', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_reinitialize: duration kept', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.append(hextoraw('646566'));

    -- assert
    assert_value(i_name => 'tmp_reinitialize: usable for appends', i_expected => hextoraw('646566'), i_actual => l_lob.subStr(1));

    -- arrange
    l_lob := phr_blob.use_lob(native_lob(hextoraw('616263')));

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
    l_lob := phr_blob.new_tmp_lob();
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
