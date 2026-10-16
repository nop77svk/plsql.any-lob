declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_native                        ${largeTypeScalar};
    l_null_native                   ${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_native := native_lob(${lit:abc});

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(l_native);

    -- assert
    assert_value(i_name => 'default flags: content', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));
    assert_number(i_name => 'default flags: buffering on', i_expected => c_level_double, i_actual => l_lob.buffering_level$);
    assert_true(i_name => 'default flags: not marked as own temporary LOB', i_condition => l_lob.tmp_lob_cached$ is null and l_lob.tmp_lob_duration$ is null);
    assert_value(i_name => 'default flags: eoln', i_expected => ${defaultEoln}, i_actual => l_lob.eoln$);

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(i_value => l_native, i_buffered_writes => false);

    -- assert
    assert_number(i_name => 'boolean flag off: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'boolean flag off: content', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(i_value => l_native, i_buffered_writes => true);

    -- assert
    assert_number(i_name => 'boolean flag on: buffering', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(l_native, c_flag_no);

    -- assert
    assert_number(i_name => 'SQL-boolean flag N: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'SQL-boolean flag N: content', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(l_native, c_flag_yes);

    -- assert
    assert_number(i_name => 'SQL-boolean flag Y: buffering', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(l_native, 'garbage');

    -- assert
    assert_number(i_name => 'SQL-boolean flag unrecognized: buffering off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob();

    -- assert
    assert_true(i_name => 'no arguments: NULL locator', i_condition => l_lob.get_value() is null);
    assert_number(i_name => 'no arguments: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'no arguments: is empty', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(l_null_native, c_flag_no);

    -- assert
    assert_true(i_name => 'NULL locator, SQL-boolean flag: length 0', i_condition => l_lob.length() = 0);

    -- arrange
    l_lob := phr_${largeTypeScalar}.use_lob(l_null_native, false);

    -- act
    begin
        l_lob.append(${lit:x});
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'append to NULL locator is rejected', i_expected => c_value_error, i_actual => l_error);

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(big_native_lob());

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length, i_actual => l_lob.length());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(native_lob());

    -- assert
    assert_true(i_name => 'empty native LOB: is empty', i_condition => l_lob.is_empty());
    assert_true(i_name => 'empty native LOB: locator kept', i_condition => l_lob.get_value() is not null);
end;
