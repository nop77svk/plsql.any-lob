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
        , i_expected                    in ${smallTypeScalar}
        , i_actual                      in ${smallTypeScalar} )
    is
    begin
        if i_expected = i_actual or (i_expected is null and i_actual is null) then
            dbms_output.put_line('PASS '||i_name);
        else
            raise_application_error(c_assertion_failed_error, 'FAIL '||i_name||': expected ['||${smallTypeDisplayFunction}(i_expected)||'] actual ['||${smallTypeDisplayFunction}(i_actual)||']');
        end if;
    end;

    function new_lob
        ( i_value                       in ${smallTypeScalar} default null )
        return phr_${largeTypeScalar}
    is
        l_result                        phr_${largeTypeScalar} := phr_${largeTypeScalar}.new_tmp_lob();
    begin
        l_result.append(i_value);
        return l_result;
    end;

    function native_lob
        ( i_value                       in ${smallTypeScalar} default null )
        return ${largeTypeScalar}
    is
        l_result                        ${largeTypeScalar};
    begin
        dbms_lob.createTemporary(
            lob_loc => l_result,
            cache => true
        );

        if i_value is not null then
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => ${smallTypeLengthFunction}(i_value),
                buffer => i_value
            );
        end if;

        return l_result;
    end;

    function native_lob_of_length
        ( i_length                      in pls_integer )
        return ${largeTypeScalar}
    is
        l_result                        ${largeTypeScalar} := native_lob();
        l_remaining                     pls_integer := i_length;
        l_amount                        pls_integer;
    begin
        while l_remaining > 0 loop
            l_amount := least(l_remaining, c_chunk_length);
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => l_amount,
                buffer => ${rep:1000:a}
            );
            l_remaining := l_remaining - l_amount;
        end loop;

        return l_result;
    end;

    function new_lob_at_level
        ( i_level                       in pls_integer )
        return phr_${largeTypeScalar}
    is
    begin
        return case i_level
            when c_level_nonbuffered then phr_${largeTypeScalar}.new_tmp_lob().nonbuffered()
            when c_level_double then phr_${largeTypeScalar}.new_tmp_lob().double_buffered()
            else phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(i_buffer_size => c_small_secondary_buffer_size)
        end;
    end;

    function big_native_lob
        return ${largeTypeScalar}
    is
        l_result                        ${largeTypeScalar} := native_lob();
    begin
        for i in 1..c_big_chunk_count loop
            dbms_lob.writeAppend(
                lob_loc => l_result,
                amount => c_chunk_length,
                buffer => ${rep:1000:a}
            );
        end loop;

        return l_result;
    end;
