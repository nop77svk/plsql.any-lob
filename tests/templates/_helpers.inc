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
