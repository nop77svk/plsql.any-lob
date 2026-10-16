PL/SQL Developer Test script 3.0
249
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
    c_small_secondary_buffer_size   constant pls_integer := 2;
    c_charset                       constant varchar2(32) := 'AL32UTF8';
    c_dest_offset                   constant pls_integer := 3;
    l_lob                           phr_nclob;
    l_dest                          nclob;
    l_null_dest                     nclob;
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

    function native_lob_of_length
        ( i_length                      in pls_integer )
        return nclob
    is
        l_result                        nclob := native_lob();
        l_remaining                     pls_integer := i_length;
        l_amount                        pls_integer;
    begin
        while l_remaining > 0 loop
            l_amount := least(l_remaining, c_chunk_length);
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => l_amount,
                buffer => n'aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa'
            );
            l_remaining := l_remaining - l_amount;
        end loop;

        return l_result;
    end;

    function new_lob_at_level
        ( i_level                       in pls_integer )
        return phr_nclob
    is
    begin
        return case i_level
            when c_level_nonbuffered then phr_nclob.new_tmp_lob().nonbuffered()
            when c_level_double then phr_nclob.new_tmp_lob().double_buffered()
            else phr_nclob.new_tmp_lob().tripple_buffered(i_buffer_size => c_small_secondary_buffer_size)
        end;
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
    l_lob := new_lob(n'abc');
    l_dest := native_lob(n'xxxxxxxx');

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'copy at the beginning: copied content', i_expected => n'abc', i_actual => dbms_lob.substr(l_dest, 3, 1));
    assert_number(i_name => 'copy to: source untouched', i_expected => 3, i_actual => l_lob.length());

    -- arrange
    l_dest := native_lob(n'xxxxxxxx');

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => c_dest_offset);

    -- assert
    assert_value(i_name => 'copy at an offset: copied content', i_expected => n'abc', i_actual => dbms_lob.substr(l_dest, 3, c_dest_offset));
    assert_value(i_name => 'copy at an offset: leading content kept', i_expected => n'xx', i_actual => dbms_lob.substr(l_dest, 2, 1));

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => c_dest_offset);

    -- assert
    assert_value(i_name => 'repeated copy: idempotent', i_expected => n'abc', i_actual => dbms_lob.substr(l_dest, 3, c_dest_offset));
    assert_number(i_name => 'repeated copy: source length untouched', i_expected => 3, i_actual => l_lob.length());

    -- arrange
    l_lob := phr_nclob.new_tmp_lob(i_buffered_writes => false).append(n'abc');
    l_dest := native_lob(n'xxxxxxxx');

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'nonbuffered source: copied content', i_expected => n'abc', i_actual => dbms_lob.substr(l_dest, 3, 1));

    -- arrange
    l_lob := phr_nclob.use_lob(big_native_lob());
    l_dest := native_lob();
    dbms_lob.writeAppend(l_dest, 1, n'x');
    dbms_lob.append(l_dest, big_native_lob());
    dbms_lob.append(l_dest, big_native_lob());

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: copied content', i_expected => 0, i_actual => dbms_lob.compare(l_lob.get_value(), l_dest, c_big_length, 1, 1));

    -- arrange
    l_lob := phr_nclob.new_tmp_lob();
    l_dest := native_lob(n'xxxxxxxx');

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'empty source: destination untouched', i_expected => n'xxxxxxxx', i_actual => dbms_lob.substr(l_dest, 100, 1));

    -- arrange
    l_lob := phr_nclob.use_lob(null);

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'NULL source: destination untouched', i_expected => n'xxxxxxxx', i_actual => dbms_lob.substr(l_dest, 100, 1));

    -- act
    l_lob.copy_to(io_dest => l_null_dest, i_dest_offset => 1);

    -- assert
    assert_true(i_name => 'NULL source, NULL destination: no error, destination untouched', i_condition => l_null_dest is null);

    -- arrange
    l_lob := new_lob(n'abc');

    -- act
    begin
        l_lob.copy_to(io_dest => l_null_dest, i_dest_offset => 1);
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'NULL destination is rejected', i_expected => c_value_error, i_actual => l_error);
end;
0
0
