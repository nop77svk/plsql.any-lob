declare
@include _constants.inc
    c_invalid_charset               constant varchar2(32) := 'NO_SUCH_CHARSET';
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_null_reverse                  ${smallReverseTypeScalar}(1);
    l_suffix                        varchar2(32);
    l_error                         pls_integer;
@include _helpers.inc
begin
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level).with_raw_conversion_charset(c_charset);

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:abc});

        -- assert
        assert_value(i_name => 'value: content'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
        assert_number(i_name => 'value: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:ab}).append_${smallReverseTypeScalar}(${rlit:cd});

        -- assert
        assert_value(i_name => 'chained'||l_suffix, i_expected => ${lit:abcd}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:ab}, 3);

        -- assert
        assert_value(i_name => 'repeated'||l_suffix, i_expected => ${lit:ababab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:ab}, 3, ${rlit:,});

        -- assert
        assert_value(i_name => 'repeated with delimiter'||l_suffix, i_expected => ${lit:ab,ab,ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:ab}, 1, ${rlit:,});

        -- assert
        assert_value(i_name => 'once with delimiter: no delimiter'||l_suffix, i_expected => ${lit:ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:ab}, 0, ${rlit:,});

        -- assert
        assert_true(i_name => 'repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(l_null_reverse, 3, ${rlit:,});

        -- assert
        assert_true(i_name => 'NULL value: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:ab}, 2, l_null_reverse);

        -- assert
        assert_value(i_name => 'NULL delimiter'||l_suffix, i_expected => ${lit:abab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:x}).append_${smallReverseTypeScalar}(${rlit:abc}).append(${lit:y});

        -- assert
        assert_value(i_name => 'mixed with regular appends'||l_suffix, i_expected => ${lit:xabcy}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${multibyteReverseValue});

        -- assert
        assert_value(i_name => 'multibyte value'||l_suffix, i_expected => ${multibyteValue}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append_${smallReverseTypeScalar}(${multibyteReverseValue}, 2, ${rlit:,});

        -- assert
        assert_value(i_name => 'multibyte value repeated with delimiter'||l_suffix, i_expected => ${multibyteValue}||${lit:,}||${multibyteValue}, i_actual => l_result.subStr(1));
    end loop;

    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();

    -- act
    begin
        l_result := l_lob.append_${smallReverseTypeScalar}(${rlit:abc});
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'no charset is rejected', i_expected => c_invalid_argument_error, i_actual => l_error);

    -- act
    begin
        l_result := l_lob.with_raw_conversion_charset(c_charset).with_raw_conversion_charset(null).append_${smallReverseTypeScalar}(${rlit:abc});
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'reset charset is rejected', i_expected => c_invalid_argument_error, i_actual => l_error);

    -- act
    begin
        l_result := l_lob.append_${smallReverseTypeScalar}(l_null_reverse);
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'no charset is rejected even for a NULL value', i_expected => c_invalid_argument_error, i_actual => l_error);

    -- act
    begin
        l_result := l_lob.with_raw_conversion_charset(c_invalid_charset).append_${smallReverseTypeScalar}(${rlit:abc});
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'unknown charset: no error', i_expected => c_no_error, i_actual => l_error);
    assert_true(i_name => 'unknown charset: nothing is appended', i_condition => l_result.is_empty());

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(big_native_lob()).with_raw_conversion_charset(c_charset).append_${smallReverseTypeScalar}(${rlit:abc});

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length + 3, i_actual => l_result.length());
end;
