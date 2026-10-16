PL/SQL Developer Test script 3.0
169
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
    l_result                        phr_clob;
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
    l_lob := new_lob('abc');

    -- act
    l_result := l_lob.fsync();

    -- assert
    assert_number(i_name => 'double buffering: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'double buffering: primary buffer emptied', i_condition => l_result.primary_buffer$ is null);
    assert_number(i_name => 'double buffering: length not doubled', i_expected => 3, i_actual => l_result.length());
    assert_value(i_name => 'double buffering: content', i_expected => 'abc', i_actual => l_result.subStr(1));
    assert_number(i_name => 'double buffering: original untouched', i_expected => 0, i_actual => dbms_lob.getLength(l_lob.the_value$));

    -- act
    l_result := l_result.fsync();

    -- assert
    assert_number(i_name => 'fsync twice: length', i_expected => 3, i_actual => l_result.length());

    -- act
    l_result := phr_clob.new_tmp_lob(i_buffered_writes => false).append('abc').fsync();

    -- assert
    assert_number(i_name => 'nonbuffered: nothing to flush', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_value(i_name => 'nonbuffered: content', i_expected => 'abc', i_actual => l_result.subStr(1));

    -- act
    l_result := phr_clob.new_tmp_lob().tripple_buffered().append('abc').fsync();

    -- assert
    assert_number(i_name => 'tripple buffering: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'tripple buffering: primary buffer emptied', i_condition => l_result.primary_buffer$ is null);
    assert_number(i_name => 'tripple buffering: secondary buffer emptied', i_expected => 0, i_actual => dbms_lob.getLength(l_result.secondary_buffer$));
    assert_number(i_name => 'tripple buffering: length not doubled', i_expected => 3, i_actual => l_result.length());

    -- act
    l_result := phr_clob.new_tmp_lob().tripple_buffered(i_buffer_size => 1).append('ab').append('cd').append('ef').fsync();

    -- assert
    assert_number(i_name => 'tripple buffering, tiny secondary buffer: everything in the LOB', i_expected => 6, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_value(i_name => 'tripple buffering, tiny secondary buffer: content', i_expected => 'abcdef', i_actual => l_result.subStr(1));

    -- act
    l_result := phr_clob.new_tmp_lob().fsync();

    -- assert
    assert_true(i_name => 'empty LOB: still empty', i_condition => l_result.is_empty());

    -- act
    l_result := phr_clob.use_lob(null).fsync();

    -- assert
    assert_true(i_name => 'NULL locator: still NULL', i_condition => l_result.the_value$ is null);

    -- act
    l_result := new_lob('abc').append(big_native_lob()).fsync();

    -- assert
    assert_number(i_name => 'pending small append followed by a big LOB: length', i_expected => c_big_length + 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_value(i_name => 'pending small append followed by a big LOB: order of content', i_expected => 'abc', i_actual => l_result.subStr(1, 3));
end;
0
0
