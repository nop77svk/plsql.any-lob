declare
@include _constants.inc
    c_charset_name_length_limit     constant pls_integer := 32;
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();

    -- act
    l_result := l_lob.with_raw_conversion_charset(c_charset);

    -- assert
    assert_true(i_name => 'charset is set on the result', i_condition => l_result.raw_conversion_charset$ = c_charset);
    assert_true(i_name => 'original untouched', i_condition => l_lob.raw_conversion_charset$ is null);

    -- act
    l_result := l_result.with_raw_conversion_charset('AL16UTF16');

    -- assert
    assert_true(i_name => 'last one wins', i_condition => l_result.raw_conversion_charset$ = 'AL16UTF16');

    -- act
    l_result := l_result.with_raw_conversion_charset(null);

    -- assert
    assert_true(i_name => 'NULL charset resets the setting', i_condition => l_result.raw_conversion_charset$ is null);

    -- act
    l_result := l_lob.with_raw_conversion_charset(c_charset).append(${lit:abc});

    -- assert
    assert_true(i_name => 'charset survives appends', i_condition => l_result.raw_conversion_charset$ = c_charset);
    assert_value(i_name => 'charset does not influence regular appends', i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

    -- act
    l_result := l_lob.with_raw_conversion_charset(c_charset).double_buffered().tripple_buffered().nonbuffered();

    -- assert
    assert_true(i_name => 'charset survives buffering switches', i_condition => l_result.raw_conversion_charset$ = c_charset);

    -- act
    begin
        l_result := l_lob.with_raw_conversion_charset(rpad('x', c_charset_name_length_limit + 1, 'x'));
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'charset name over the length limit is rejected', i_expected => c_value_error, i_actual => l_error);

    -- act
    l_result := l_lob.with_raw_conversion_charset(rpad('x', c_charset_name_length_limit, 'x'));

    -- assert
    assert_number(i_name => 'charset name of the length limit', i_expected => c_charset_name_length_limit, i_actual => length(l_result.raw_conversion_charset$));
end;
