declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false).append(${lit:abcdef});

    -- act
    l_result := l_lob.trim(3);

    -- assert
    assert_value(i_name => 'shorter: content', i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
    assert_number(i_name => 'shorter: length', i_expected => 3, i_actual => l_result.length());
    assert_value(i_name => 'shorter: original untouched', i_expected => ${lit:abcdef}, i_actual => l_lob.subStr(1));

    -- act
    l_result := l_lob.trim(6);

    -- assert
    assert_value(i_name => 'same length: unchanged', i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

    -- act
    l_result := l_lob.trim(100);

    -- assert
    assert_value(i_name => 'longer: unchanged', i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));
    assert_number(i_name => 'longer: length', i_expected => 6, i_actual => l_result.length());

    -- act
    l_result := l_lob.trim();

    -- assert
    assert_true(i_name => 'default length: emptied', i_condition => l_result.is_empty());

    -- act
    l_result := l_lob.trim(0);

    -- assert
    assert_true(i_name => 'zero length: emptied', i_condition => l_result.is_empty());

    -- act
    l_result := l_lob.trim(1);

    -- assert
    assert_value(i_name => 'single element left', i_expected => ${lit:a}, i_actual => l_result.subStr(1));

    -- act
    l_result := new_lob(${lit:abcdef}).trim(2);

    -- assert
    assert_value(i_name => 'pending appends: content', i_expected => ${lit:ab}, i_actual => l_result.subStr(1));
    assert_number(i_name => 'pending appends: length', i_expected => 2, i_actual => l_result.length());

    -- act
    l_result := new_lob(${lit:abcdef}).trim(100);

    -- assert
    assert_value(i_name => 'pending appends, longer: unchanged', i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

    -- act
    l_result := new_lob(${lit:abcdef}).trim(0);

    -- assert
    assert_true(i_name => 'pending appends, zero length: emptied', i_condition => l_result.is_empty());

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered().append(${lit:abcdef}).trim(4);

    -- assert
    assert_value(i_name => 'tripple buffering: content', i_expected => ${lit:abcd}, i_actual => l_result.subStr(1));

    -- act
    l_result := l_result.trim(1).append(${lit:xy});

    -- assert
    assert_value(i_name => 'appending after the trim', i_expected => ${lit:axy}, i_actual => l_result.subStr(1));

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(big_native_lob()).trim(10);

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => 10, i_actual => l_result.length());

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().trim(0);

    -- assert
    assert_true(i_name => 'empty LOB: stays empty', i_condition => l_result.is_empty());

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(null).trim(5);

    -- assert
    assert_true(i_name => 'NULL locator: unchanged', i_condition => l_result.the_value$ is null);

    -- act
    begin
        l_result := l_lob.trim(-1);
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'negative length is rejected', i_expected => c_invalid_lob_length_error, i_actual => l_error);
end;
