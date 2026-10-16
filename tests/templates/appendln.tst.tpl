declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_null_small                    ${smallTypeScalar}(1);
    l_null_phr                      phr_${largeTypeScalar};
    l_suffix                        varchar2(32);
    l_error                         pls_integer;
@include _helpers.inc
begin
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level);

        -- act
        l_result := l_lob.appendln(${lit:abc});

        -- assert
        assert_value(i_name => 'value: content'||l_suffix, i_expected => ${lit:abc}||${defaultEoln}, i_actual => l_result.subStr(1));
        assert_number(i_name => 'value: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.appendln(${lit:a}).appendln(${lit:b}).appendln(${lit:c});

        -- assert
        assert_value(i_name => 'chained lines'||l_suffix, i_expected => ${lit:a}||${defaultEoln}||${lit:b}||${defaultEoln}||${lit:c}||${defaultEoln}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.appendln();

        -- assert
        assert_value(i_name => 'no value: empty line'||l_suffix, i_expected => ${defaultEoln}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.appendln(l_null_small);

        -- assert
        assert_value(i_name => 'NULL value: empty line'||l_suffix, i_expected => ${defaultEoln}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.appendln(${lit:a}).appendln().appendln(${lit:b});

        -- assert
        assert_value(i_name => 'empty line in the middle'||l_suffix, i_expected => ${lit:a}||${defaultEoln}||${defaultEoln}||${lit:b}||${defaultEoln}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:a}).appendln(${lit:b}).append(${lit:c});

        -- assert
        assert_value(i_name => 'mixed with append'||l_suffix, i_expected => ${lit:a}||${lit:b}||${defaultEoln}||${lit:c}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.with_eoln(${lit:;}).appendln(${lit:a}).appendln(${lit:b});

        -- assert
        assert_value(i_name => 'custom eoln'||l_suffix, i_expected => ${lit:a;b;}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.with_eoln(l_null_small).appendln(${lit:a}).appendln().appendln(${lit:b});

        -- assert
        assert_value(i_name => 'NULL eoln: lines are concatenated'||l_suffix, i_expected => ${lit:ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.appendln(${rep:1000:a});
        l_result := l_result.appendln(${rep:1000:b});

        -- assert
        assert_number(i_name => 'long lines: length'||l_suffix, i_expected => 2 * c_chunk_length + 2 * ${smallTypeLengthFunction}(${defaultEoln}), i_actual => l_result.length());
    end loop;

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(big_native_lob()).appendln(${lit:abc});

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length + 3 + ${smallTypeLengthFunction}(${defaultEoln}), i_actual => l_result.length());

    -- act
    begin
        l_result := l_null_phr.appendln(${lit:a});
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'appendln to a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
