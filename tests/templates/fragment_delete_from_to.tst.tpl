declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_null_small                    ${smallTypeScalar}(1);
    l_suffix                        varchar2(32);
    l_error                         pls_integer;
@include _helpers.inc
begin
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:a[xx]b});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'delimited portion'||l_suffix, i_expected => ${lit:ab}, i_actual => l_result.subStr(1));
        assert_value(i_name => 'delimited portion: original untouched'||l_suffix, i_expected => ${lit:a[xx]b}, i_actual => l_lob.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:abc[def});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[});

        -- assert
        assert_value(i_name => 'open-ended, NULL end needle by default'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, l_null_small);

        -- assert
        assert_value(i_name => 'open-ended, explicit NULL end needle'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:a[1]b[2]c});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'single iteration by default'||l_suffix, i_expected => ${lit:ab[2]c}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]}, 2);

        -- assert
        assert_value(i_name => 'two iterations'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]}, 5);

        -- assert
        assert_value(i_name => 'more iterations than occurrences'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]}, 0);

        -- assert
        assert_value(i_name => 'zero iterations: unchanged'||l_suffix, i_expected => ${lit:a[1]b[2]c}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]}).fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'chained'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:abc});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'start needle missing: unchanged'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:a[1});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'end needle missing: unchanged'||l_suffix, i_expected => ${lit:a[1}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:a[1]b[2});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]}, 2);

        -- assert
        assert_value(i_name => 'end needle missing for the second occurrence only'||l_suffix, i_expected => ${lit:ab[2}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:x<!--c1-->y<!--c2-->z});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:<!--}, ${lit:-->}, 2);

        -- assert
        assert_value(i_name => 'multi-element needles'||l_suffix, i_expected => ${lit:xyz}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:[a][b]c});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]}, 2);

        -- assert
        assert_value(i_name => 'adjacent portions'||l_suffix, i_expected => ${lit:c}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:[a]bc});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'portion at the start'||l_suffix, i_expected => ${lit:bc}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:bc[a]});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'portion at the end'||l_suffix, i_expected => ${lit:bc}, i_actual => l_result.subStr(1));

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:[a]});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, ${lit:]});

        -- assert
        assert_true(i_name => 'portion is the whole content'||l_suffix, i_condition => l_result.is_empty());

        -- arrange
        l_lob := new_lob_at_level(l_level).append(${lit:a[b[c});

        -- act
        l_result := l_lob.fragment_delete_from_to(${lit:[}, l_null_small, 2);

        -- assert
        assert_value(i_name => 'open-ended with more iterations: deleted up to the end once'||l_suffix, i_expected => ${lit:a}, i_actual => l_result.subStr(1));
    end loop;

    -- arrange
    l_lob := new_lob_at_level(c_level_double).append(${lit:abc});

    -- act
    begin
        l_result := l_lob.fragment_delete_from_to(l_null_small, ${lit:]});
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_true(i_name => 'NULL start needle is rejected', i_condition => l_error != c_no_error);

    -- act
    l_result := phr_${largeTypeScalar}.new_tmp_lob().fragment_delete_from_to(${lit:[}, ${lit:]});

    -- assert
    assert_true(i_name => 'empty LOB: stays empty', i_condition => l_result.is_empty());

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(big_native_lob()).append(${lit:[x]}).fragment_delete_from_to(${lit:[}, ${lit:]});

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length, i_actual => l_result.length());
end;
