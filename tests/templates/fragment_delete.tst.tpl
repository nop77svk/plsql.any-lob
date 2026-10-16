declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_suffix                        varchar2(32);
    l_error                         pls_integer;

    function error_of_fragment_delete
        ( i_offset                      in integer
        , i_amount                      in integer )
        return pls_integer
    is
        l_lob                           phr_${largeTypeScalar} := phr_${largeTypeScalar}.new_tmp_lob();
        l_result                        phr_${largeTypeScalar};
    begin
        l_lob.append(${lit:abcdef});
        l_result := l_lob.fragment_delete(i_offset => i_offset, i_amount => i_amount);
        return c_no_error;
    exception
        when others then
            return sqlcode;
    end;
@include _helpers.inc
begin
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:abcdef});

        -- act
        l_result := l_lob.fragment_delete(2, 3);

        -- assert
        assert_value(i_name => 'middle'||l_suffix, i_expected => ${lit:aef}, i_actual => l_result.subStr(1));
        assert_value(i_name => 'middle: original untouched'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_lob.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(1, 1);

        -- assert
        assert_value(i_name => 'first element'||l_suffix, i_expected => ${lit:bcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(6, 1);

        -- assert
        assert_value(i_name => 'last element'||l_suffix, i_expected => ${lit:abcde}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(3, 4);

        -- assert
        assert_value(i_name => 'exactly up to the end'||l_suffix, i_expected => ${lit:ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(4, 100);

        -- assert
        assert_value(i_name => 'amount beyond the end'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(1, 6);

        -- assert
        assert_true(i_name => 'whole content'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.fragment_delete(1, 100);

        -- assert
        assert_true(i_name => 'whole content and beyond'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.fragment_delete(10, 2);

        -- assert
        assert_value(i_name => 'offset beyond the end: unchanged'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(7, 1);

        -- assert
        assert_value(i_name => 'offset just beyond the end: unchanged'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(2, 0);

        -- assert
        assert_value(i_name => 'zero amount: unchanged'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(2, 1).fragment_delete(2, 1).fragment_delete(2, 1);

        -- assert
        assert_value(i_name => 'chained'||l_suffix, i_expected => ${lit:aef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete(2, 3).append(${lit:xyz});

        -- assert
        assert_value(i_name => 'appending after the deletion'||l_suffix, i_expected => ${lit:aefxyz}, i_actual => l_result.subStr(1));
        assert_number(i_name => 'appending after the deletion: length'||l_suffix, i_expected => 6, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(big_native_lob()).fragment_delete(1, c_chunk_length);

        -- assert
        assert_number(i_name => 'LOB over the buffer threshold, head deleted: length'||l_suffix, i_expected => c_big_length + 6 - c_chunk_length, i_actual => l_result.length());
        assert_value(i_name => 'LOB over the buffer threshold, head deleted: head'||l_suffix, i_expected => ${rep:16:a}, i_actual => l_result.subStr(1, 16));

        -- act
        l_result := l_lob.append(big_native_lob()).fragment_delete(7, c_big_length);

        -- assert
        assert_value(i_name => 'LOB over the buffer threshold, tail deleted'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:xy}).fragment_delete(6, 2);

        -- assert
        assert_value(i_name => 'pending appends included'||l_suffix, i_expected => ${lit:abcdey}, i_actual => l_result.subStr(1));
    end loop;

    -- assert
    assert_number(i_name => 'NULL offset is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete(null, 1));
    assert_number(i_name => 'NULL amount is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete(1, null));
    assert_number(i_name => 'NULL offset and NULL amount are rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete(null, null));
    assert_number(i_name => 'negative offset is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete(-1, 1));
    assert_number(i_name => 'negative amount is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete(1, -1));
    assert_true(i_name => 'zero offset is rejected', i_condition => error_of_fragment_delete(0, 1) != c_no_error);
    assert_number(i_name => 'valid arguments', i_expected => c_no_error, i_actual => error_of_fragment_delete(1, 1));
    assert_number(i_name => 'zero amount is valid', i_expected => c_no_error, i_actual => error_of_fragment_delete(1, 0));

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().fragment_delete(1, 1);

    -- assert
    assert_true(i_name => 'empty LOB: stays empty', i_condition => l_result.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();
    l_lob.tmp_dispose();
    begin
        l_result := l_lob.fragment_delete(1, 1);
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'disposed LOB: no error', i_expected => c_no_error, i_actual => l_error);
end;
