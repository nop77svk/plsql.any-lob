PL/SQL Developer Test script 3.0
264
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
    l_pending                       phr_clob;
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
    l_pending := new_lob('abc');

    -- act
    l_result := l_pending.nonbuffered();

    -- assert
    assert_number(i_name => 'nonbuffered: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'nonbuffered: pending appends preserved', i_expected => 'abc', i_actual => l_result.subStr(1));
    assert_number(i_name => 'nonbuffered: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'nonbuffered: primary buffer dropped', i_condition => l_result.primary_buffer$ is null);
    assert_number(i_name => 'nonbuffered: original level untouched', i_expected => c_level_double, i_actual => l_pending.buffering_level$);

    -- act
    l_result := l_result.append('d');

    -- assert
    assert_number(i_name => 'nonbuffered: appends written through', i_expected => 4, i_actual => dbms_lob.getLength(l_result.the_value$));

    -- act
    l_result := l_result.nonbuffered();

    -- assert
    assert_number(i_name => 'nonbuffered twice: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'nonbuffered twice: content', i_expected => 'abcd', i_actual => l_result.subStr(1));

    -- act
    l_lob := phr_clob.new_tmp_lob(i_buffered_writes => false).double_buffered();

    -- assert
    assert_number(i_name => 'double_buffered from nonbuffered: level', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_result := l_lob.append('abc').double_buffered();

    -- assert
    assert_number(i_name => 'double_buffered: level kept', i_expected => c_level_double, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'double_buffered: content', i_expected => 'abc', i_actual => l_result.subStr(1));
    assert_number(i_name => 'double_buffered: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));

    -- act
    l_result := phr_clob.new_tmp_lob().tripple_buffered().append('abc').double_buffered();

    -- assert
    assert_number(i_name => 'double_buffered from tripple: level', i_expected => c_level_double, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'double_buffered from tripple: content', i_expected => 'abc', i_actual => l_result.subStr(1));
    assert_true(i_name => 'double_buffered from tripple: secondary buffer dropped', i_condition => l_result.secondary_buffer$ is null);

    -- act
    l_result := phr_clob.new_tmp_lob(i_buffered_writes => false).tripple_buffered();

    -- assert
    assert_number(i_name => 'tripple_buffered: level', i_expected => c_level_tripple, i_actual => l_result.buffering_level$);
    assert_number(i_name => 'tripple_buffered: default buffer size', i_expected => 1048576, i_actual => l_result.secondary_buffer_size$);
    assert_true(i_name => 'tripple_buffered: secondary buffer created', i_condition => l_result.secondary_buffer$ is not null);

    -- act
    l_result := l_result.append('abc').append('def');

    -- assert
    assert_value(i_name => 'tripple_buffered: content', i_expected => 'abcdef', i_actual => l_result.subStr(1));
    assert_number(i_name => 'tripple_buffered: length', i_expected => 6, i_actual => l_result.length());

    -- act
    l_result := phr_clob.new_tmp_lob().tripple_buffered(i_buffer_size => 2);
    l_result := l_result.append('ab').append('cd').append('ef');

    -- assert
    assert_number(i_name => 'tripple_buffered, custom size: buffer size', i_expected => 2, i_actual => l_result.secondary_buffer_size$);
    assert_value(i_name => 'tripple_buffered, tiny secondary buffer: content', i_expected => 'abcdef', i_actual => l_result.subStr(1));

    -- act
    l_result := phr_clob.new_tmp_lob().tripple_buffered(i_buffer_size => 0);

    -- assert
    assert_number(i_name => 'tripple_buffered, zero size', i_expected => 0, i_actual => l_result.secondary_buffer_size$);

    -- act
    l_result := phr_clob.new_tmp_lob().tripple_buffered(i_buffer_size => -5);

    -- assert
    assert_number(i_name => 'tripple_buffered, negative size is clamped to zero', i_expected => 0, i_actual => l_result.secondary_buffer_size$);

    -- act
    l_result := phr_clob.new_tmp_lob().tripple_buffered().append('abc').nonbuffered();

    -- assert
    assert_number(i_name => 'nonbuffered from tripple: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
    assert_number(i_name => 'nonbuffered from tripple: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'nonbuffered from tripple: secondary buffer dropped', i_condition => l_result.secondary_buffer$ is null);

    -- act
    l_result := phr_clob.new_tmp_lob()
        .nonbuffered().append('a')
        .double_buffered().append('b')
        .tripple_buffered().append('c')
        .double_buffered().append('d')
        .nonbuffered().append('e');

    -- assert
    assert_value(i_name => 'switching all levels back and forth: content', i_expected => 'abcde', i_actual => l_result.subStr(1));

    -- act
    l_result := phr_clob.use_lob(null).nonbuffered();

    -- assert
    assert_number(i_name => 'NULL locator, nonbuffered: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
end;
0
0
