declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_null_phr                      phr_${largeTypeScalar};
    l_null_small                    ${smallTypeScalar}(1);
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_lob := new_lob(${lit:abcabc});

    -- assert
    assert_number(i_name => 'first occurrence', i_expected => 2, i_actual => l_lob.inStr(${lit:b}));
    assert_number(i_name => 'first occurrence, repeated: pending appends not consumed', i_expected => 2, i_actual => l_lob.inStr(${lit:b}));
    assert_number(i_name => 'first element', i_expected => 1, i_actual => l_lob.inStr(${lit:a}));
    assert_number(i_name => 'last element', i_expected => 6, i_actual => l_lob.inStr(${lit:c}, 6));
    assert_number(i_name => 'multi-element needle', i_expected => 3, i_actual => l_lob.inStr(${lit:ca}));
    assert_number(i_name => 'whole content as the needle', i_expected => 1, i_actual => l_lob.inStr(${lit:abcabc}));
    assert_number(i_name => 'from offset', i_expected => 5, i_actual => l_lob.inStr(${lit:b}, 3));
    assert_number(i_name => 'second occurrence', i_expected => 5, i_actual => l_lob.inStr(${lit:b}, 1, 2));
    assert_number(i_name => 'second occurrence from offset', i_expected => 6, i_actual => l_lob.inStr(${lit:c}, 3, 2));
    assert_number(i_name => 'third occurrence does not exist', i_expected => 0, i_actual => l_lob.inStr(${lit:b}, 1, 3));
    assert_number(i_name => 'needle not present', i_expected => 0, i_actual => l_lob.inStr(${lit:x}));
    assert_number(i_name => 'needle longer than the content', i_expected => 0, i_actual => l_lob.inStr(${rep:100:a}));
    assert_number(i_name => 'offset beyond the end', i_expected => 0, i_actual => l_lob.inStr(${lit:b}, 20));
    assert_number(i_name => 'offset past the last occurrence', i_expected => 0, i_actual => l_lob.inStr(${lit:b}, 6));

    -- assert
    assert_number(i_name => 'NULL needle', i_expected => null, i_actual => l_lob.inStr(l_null_small));
    assert_number(i_name => 'zero offset', i_expected => null, i_actual => l_lob.inStr(${lit:b}, 0));
    assert_number(i_name => 'negative offset', i_expected => null, i_actual => l_lob.inStr(${lit:b}, -1));
    assert_number(i_name => 'zero occurrence', i_expected => null, i_actual => l_lob.inStr(${lit:b}, 1, 0));
    assert_number(i_name => 'negative occurrence', i_expected => null, i_actual => l_lob.inStr(${lit:b}, 1, -1));

    -- assert
    assert_number(i_name => 'nonbuffered', i_expected => 3, i_actual => phr_${largeTypeScalar}.new_tmp_lob().nonbuffered().append(${lit:abcd}).inStr(${lit:c}));
    assert_number(i_name => 'tripple buffering', i_expected => 3, i_actual => phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(c_small_secondary_buffer_size).append(${lit:abcd}).inStr(${lit:c}));
    assert_number(i_name => 'native LOB wrapped', i_expected => 3, i_actual => phr_${largeTypeScalar}.use_lob(native_lob(${lit:abcd})).inStr(${lit:c}));
    assert_number(i_name => 'LOB over the buffer threshold: needle not present', i_expected => 0, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).inStr(${lit:x}));
    assert_number(i_name => 'LOB over the buffer threshold plus pending appends: needle in the pending part', i_expected => c_big_length + 1, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).append(${lit:xy}).inStr(${lit:x}));
    assert_number(i_name => 'empty LOB', i_expected => 0, i_actual => phr_${largeTypeScalar}.new_tmp_lob().inStr(${lit:a}));
    assert_number(i_name => 'NULL locator', i_expected => null, i_actual => phr_${largeTypeScalar}.use_lob(null).inStr(${lit:a}));

    -- act
    begin
        l_error := l_null_phr.inStr(${lit:a});
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'inStr of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
