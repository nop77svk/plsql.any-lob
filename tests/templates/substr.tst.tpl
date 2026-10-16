declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_null_phr                      phr_${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_lob := new_lob(${lit:abcdef});

    -- assert
    assert_value(i_name => 'whole content', i_expected => ${lit:abcdef}, i_actual => l_lob.subStr(1));
    assert_value(i_name => 'whole content, repeated: pending appends not consumed', i_expected => ${lit:abcdef}, i_actual => l_lob.subStr(1));
    assert_value(i_name => 'from offset', i_expected => ${lit:cdef}, i_actual => l_lob.subStr(3));
    assert_value(i_name => 'from offset with length', i_expected => ${lit:cd}, i_actual => l_lob.subStr(3, 2));
    assert_value(i_name => 'length of one', i_expected => ${lit:a}, i_actual => l_lob.subStr(1, 1));
    assert_value(i_name => 'last element', i_expected => ${lit:f}, i_actual => l_lob.subStr(6, 1));
    assert_value(i_name => 'length exactly to the end', i_expected => ${lit:def}, i_actual => l_lob.subStr(4, 3));
    assert_value(i_name => 'length beyond the end', i_expected => ${lit:def}, i_actual => l_lob.subStr(4, 100));
    assert_value(i_name => 'NULL length: up to the end', i_expected => ${lit:cdef}, i_actual => l_lob.subStr(i_from => 3, i_length => null));
    assert_value(i_name => 'whole content with explicit length', i_expected => ${lit:abcdef}, i_actual => l_lob.subStr(1, 6));

    -- assert
    assert_value(i_name => 'offset beyond the end', i_expected => null, i_actual => l_lob.subStr(100, 2));
    assert_value(i_name => 'offset just beyond the end', i_expected => null, i_actual => l_lob.subStr(7, 2));
    assert_value(i_name => 'zero offset', i_expected => null, i_actual => l_lob.subStr(0, 2));
    assert_value(i_name => 'negative offset', i_expected => null, i_actual => l_lob.subStr(-1, 2));
    assert_value(i_name => 'zero length', i_expected => null, i_actual => l_lob.subStr(1, 0));
    assert_value(i_name => 'negative length', i_expected => null, i_actual => l_lob.subStr(1, -1));

    -- assert
    assert_value(i_name => 'nonbuffered', i_expected => ${lit:bc}, i_actual => phr_${largeTypeScalar}.new_tmp_lob().nonbuffered().append(${lit:abcd}).subStr(2, 2));
    assert_value(i_name => 'tripple buffering', i_expected => ${lit:bc}, i_actual => phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(c_small_secondary_buffer_size).append(${lit:abcd}).subStr(2, 2));
    assert_value(i_name => 'native LOB wrapped', i_expected => ${lit:bc}, i_actual => phr_${largeTypeScalar}.use_lob(native_lob(${lit:abcd})).subStr(2, 2));
    assert_value(i_name => 'LOB over the buffer threshold: head', i_expected => ${rep:10:a}, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).subStr(1, 10));
    assert_value(i_name => 'LOB over the buffer threshold: past the threshold', i_expected => ${lit:a}, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).subStr(c_big_length, 1));
    assert_value(i_name => 'LOB over the buffer threshold plus pending appends: tail', i_expected => ${lit:xy}, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).append(${lit:xy}).subStr(c_big_length + 1, 2));
    assert_value(i_name => 'empty LOB', i_expected => null, i_actual => phr_${largeTypeScalar}.new_tmp_lob().subStr(1));
    assert_value(i_name => 'NULL locator', i_expected => null, i_actual => phr_${largeTypeScalar}.use_lob(null).subStr(1, 2));

    -- act
    begin
        l_error := case when l_null_phr.subStr(1) is null then 1 else 0 end;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'subStr of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
