declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_pending                       phr_${largeTypeScalar};
@include _helpers.inc
begin
    -- arrange
    l_pending := new_lob(${lit:abc});

    -- act
    l_result := l_pending.nonbuffered();

    -- assert
    assert_number(i_name => 'nonbuffered: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'nonbuffered: pending appends preserved', i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
    assert_number(i_name => 'nonbuffered: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'nonbuffered: primary buffer dropped', i_condition => l_result.primary_buffer$ is null);
    assert_number(i_name => 'nonbuffered: original level untouched', i_expected => c_level_double, i_actual => l_pending.buffering_level$);

    -- act
    l_result := l_result.append(${lit:d});

    -- assert
    assert_number(i_name => 'nonbuffered: appends written through', i_expected => 4, i_actual => dbms_lob.getLength(l_result.the_value$));

    -- act
    l_result := l_result.nonbuffered();

    -- assert
    assert_number(i_name => 'nonbuffered twice: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'nonbuffered twice: content', i_expected => ${lit:abcd}, i_actual => l_result.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false).double_buffered();

    -- assert
    assert_number(i_name => 'double_buffered from nonbuffered: level', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_result := l_lob.append(${lit:abc}).double_buffered();

    -- assert
    assert_number(i_name => 'double_buffered: level kept', i_expected => c_level_double, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'double_buffered: content', i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
    assert_number(i_name => 'double_buffered: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered().append(${lit:abc}).double_buffered();

    -- assert
    assert_number(i_name => 'double_buffered from tripple: level', i_expected => c_level_double, i_actual => l_result.buffering_level$);
    assert_value(i_name => 'double_buffered from tripple: content', i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
    assert_true(i_name => 'double_buffered from tripple: secondary buffer dropped', i_condition => l_result.secondary_buffer$ is null);

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false).tripple_buffered();

    -- assert
    assert_number(i_name => 'tripple_buffered: level', i_expected => c_level_tripple, i_actual => l_result.buffering_level$);
    assert_number(i_name => 'tripple_buffered: default buffer size', i_expected => 1048576, i_actual => l_result.secondary_buffer_size$);
    assert_true(i_name => 'tripple_buffered: secondary buffer created', i_condition => l_result.secondary_buffer$ is not null);

    -- act
    l_result := l_result.append(${lit:abc}).append(${lit:def});

    -- assert
    assert_value(i_name => 'tripple_buffered: content', i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));
    assert_number(i_name => 'tripple_buffered: length', i_expected => 6, i_actual => l_result.length());

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(i_buffer_size => 2);
    l_result := l_result.append(${lit:ab}).append(${lit:cd}).append(${lit:ef});

    -- assert
    assert_number(i_name => 'tripple_buffered, custom size: buffer size', i_expected => 2, i_actual => l_result.secondary_buffer_size$);
    assert_value(i_name => 'tripple_buffered, tiny secondary buffer: content', i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(i_buffer_size => 0);

    -- assert
    assert_number(i_name => 'tripple_buffered, zero size', i_expected => 0, i_actual => l_result.secondary_buffer_size$);

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(i_buffer_size => -5);

    -- assert
    assert_number(i_name => 'tripple_buffered, negative size is clamped to zero', i_expected => 0, i_actual => l_result.secondary_buffer_size$);

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered().append(${lit:abc}).nonbuffered();

    -- assert
    assert_number(i_name => 'nonbuffered from tripple: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
    assert_number(i_name => 'nonbuffered from tripple: pending appends flushed into the LOB', i_expected => 3, i_actual => dbms_lob.getLength(l_result.the_value$));
    assert_true(i_name => 'nonbuffered from tripple: secondary buffer dropped', i_condition => l_result.secondary_buffer$ is null);

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob()
        .nonbuffered().append(${lit:a})
        .double_buffered().append(${lit:b})
        .tripple_buffered().append(${lit:c})
        .double_buffered().append(${lit:d})
        .nonbuffered().append(${lit:e});

    -- assert
    assert_value(i_name => 'switching all levels back and forth: content', i_expected => ${lit:abcde}, i_actual => l_result.subStr(1));

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(null).nonbuffered();

    -- assert
    assert_number(i_name => 'NULL locator, nonbuffered: level', i_expected => c_level_nonbuffered, i_actual => l_result.buffering_level$);
end;
