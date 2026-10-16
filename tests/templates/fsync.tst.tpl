declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
@include _helpers.inc
begin
    -- arrange
    l_lob := new_lob(${lit:abc});

    -- act
    l_result := l_lob.fsync();

    -- assert
    assert_number(i_name => 'double buffering: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'double buffering: primary buffer emptied', i_condition => l_result.primary_buffer$ is null);
    assert_number(i_name => 'double buffering: length not doubled', i_expected => 3, i_actual => l_result.length());
    assert_value(i_name => 'double buffering: content', i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
    assert_number(i_name => 'double buffering: original untouched', i_expected => 0, i_actual => dbms_lob.getLength(l_lob.the_value$));

    -- act
    l_result := l_result.fsync();

    -- assert
    assert_number(i_name => 'fsync twice: length', i_expected => 3, i_actual => l_result.length());

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false).append(${lit:abc}).fsync();

    -- assert
    assert_number(i_name => 'nonbuffered: nothing to flush', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_value(i_name => 'nonbuffered: content', i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered().append(${lit:abc}).fsync();

    -- assert
    assert_number(i_name => 'tripple buffering: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'tripple buffering: primary buffer emptied', i_condition => l_result.primary_buffer$ is null);
    assert_number(i_name => 'tripple buffering: secondary buffer emptied', i_expected => 0, i_actual => dbms_lob.getLength(l_result.secondary_buffer$));
    assert_number(i_name => 'tripple buffering: length not doubled', i_expected => 3, i_actual => l_result.length());

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(i_buffer_size => 1).append(${lit:ab}).append(${lit:cd}).append(${lit:ef}).fsync();

    -- assert
    assert_number(i_name => 'tripple buffering, tiny secondary buffer: everything in the LOB', i_expected => 6, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_value(i_name => 'tripple buffering, tiny secondary buffer: content', i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().fsync();

    -- assert
    assert_true(i_name => 'empty LOB: still empty', i_condition => l_result.is_empty());

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(null).fsync();

    -- assert
    assert_true(i_name => 'NULL locator: still NULL', i_condition => l_result.the_value$ is null);

    -- act
    l_result := new_lob(${lit:abc}).append(big_native_lob()).fsync();

    -- assert
    assert_number(i_name => 'pending small append followed by a big LOB: length', i_expected => c_big_length + 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_value(i_name => 'pending small append followed by a big LOB: order of content', i_expected => ${lit:abc}, i_actual => l_result.subStr(1, 3));
end;
