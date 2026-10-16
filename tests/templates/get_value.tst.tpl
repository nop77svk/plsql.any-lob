declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_value                         ${largeTypeScalar};
    l_null_lob                      phr_${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_lob := new_lob(${lit:abc});

    -- act
    l_value := l_lob.get_value();

    -- assert
    assert_value(i_name => 'pending appends: content', i_expected => ${lit:abc}, i_actual => dbms_lob.substr(l_value, 100, 1));
    assert_number(i_name => 'pending appends: length', i_expected => 3, i_actual => dbms_lob.getLength(l_value));

    -- act
    l_value := l_lob.get_value();

    -- assert
    assert_number(i_name => 'repeated calls: appends not duplicated', i_expected => 3, i_actual => dbms_lob.getLength(l_value));
    assert_number(i_name => 'repeated calls: object length', i_expected => 3, i_actual => l_lob.length());

    -- act
    l_value := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false).append(${lit:abc}).get_value();

    -- assert
    assert_value(i_name => 'nonbuffered: content', i_expected => ${lit:abc}, i_actual => dbms_lob.substr(l_value, 100, 1));

    -- act
    l_value := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered().append(${lit:abc}).get_value();

    -- assert
    assert_value(i_name => 'tripple buffering: content', i_expected => ${lit:abc}, i_actual => dbms_lob.substr(l_value, 100, 1));

    -- act
    l_value := phr_${largeTypeScalar}.new_tmp_lob().get_value();

    -- assert
    assert_true(i_name => 'empty LOB: not NULL', i_condition => l_value is not null);
    assert_number(i_name => 'empty LOB: length', i_expected => 0, i_actual => dbms_lob.getLength(l_value));

    -- act
    l_value := phr_${largeTypeScalar}.use_lob(big_native_lob()).append(${lit:abc}).get_value();

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold plus pending appends: length', i_expected => c_big_length + 3, i_actual => dbms_lob.getLength(l_value));

    -- act
    l_value := phr_${largeTypeScalar}.use_lob(null).get_value();

    -- assert
    assert_true(i_name => 'NULL locator: NULL', i_condition => l_value is null);

    -- act
    l_value := phr_${largeTypeScalar}.use_lob(null, false).get_value();

    -- assert
    assert_true(i_name => 'NULL locator, nonbuffered: NULL', i_condition => l_value is null);

    -- act
    begin
        l_value := l_null_lob.get_value();
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'get_value of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
