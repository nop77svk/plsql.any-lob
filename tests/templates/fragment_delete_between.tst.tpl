declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_suffix                        varchar2(32);

    function error_of_fragment_delete_between
        ( i_from                        in integer
        , i_to                          in integer )
        return pls_integer
    is
        l_lob                           phr_${largeTypeScalar} := phr_${largeTypeScalar}.new_tmp_lob();
        l_result                        phr_${largeTypeScalar};
    begin
        l_lob.append(${lit:abcdef});
        l_result := l_lob.fragment_delete_between(i_from => i_from, i_to => i_to);
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
        l_result := l_lob.fragment_delete_between(2, 4);

        -- assert
        assert_value(i_name => 'middle'||l_suffix, i_expected => ${lit:aef}, i_actual => l_result.subStr(1));
        assert_value(i_name => 'middle: original untouched'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_lob.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(3, 3);

        -- assert
        assert_value(i_name => 'single element'||l_suffix, i_expected => ${lit:abdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(1, 2);

        -- assert
        assert_value(i_name => 'head'||l_suffix, i_expected => ${lit:cdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(5, 6);

        -- assert
        assert_value(i_name => 'tail'||l_suffix, i_expected => ${lit:abcd}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(5, 100);

        -- assert
        assert_value(i_name => 'upper bound beyond the end'||l_suffix, i_expected => ${lit:abcd}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(1, 6);

        -- assert
        assert_true(i_name => 'whole content'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.fragment_delete_between(10, 12);

        -- assert
        assert_value(i_name => 'both bounds beyond the end: unchanged'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(3, 2);

        -- assert
        assert_value(i_name => 'upper bound right below the lower bound: unchanged'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(1, 2).fragment_delete_between(1, 2);

        -- assert
        assert_value(i_name => 'chained'||l_suffix, i_expected => ${lit:ef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_between(2, 5).append(${lit:xyz});

        -- assert
        assert_value(i_name => 'appending after the deletion'||l_suffix, i_expected => ${lit:afxyz}, i_actual => l_result.subStr(1));
    end loop;

    -- assert
    assert_number(i_name => 'NULL lower bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(null, 2));
    assert_number(i_name => 'NULL upper bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(1, null));
    assert_number(i_name => 'both bounds NULL are rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(null, null));
    assert_number(i_name => 'upper bound far below the lower bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(4, 2));
    assert_number(i_name => 'negative lower bound is rejected', i_expected => c_invalid_argument_error, i_actual => error_of_fragment_delete_between(-1, 2));
    assert_true(i_name => 'zero lower bound is rejected', i_condition => error_of_fragment_delete_between(0, 2) != c_no_error);
    assert_number(i_name => 'valid bounds', i_expected => c_no_error, i_actual => error_of_fragment_delete_between(1, 2));

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().fragment_delete_between(1, 5);

    -- assert
    assert_true(i_name => 'empty LOB: stays empty', i_condition => l_result.is_empty());

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(big_native_lob()).fragment_delete_between(1, c_chunk_length);

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length - c_chunk_length, i_actual => l_result.length());
end;
