declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_null_small                    ${smallTypeScalar}(1);
@include _helpers.inc
begin
    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();

    -- act
    l_result := l_lob.with_eoln(${lit:;});

    -- assert
    assert_value(i_name => 'with_eoln: eoln of the result', i_expected => ${lit:;}, i_actual => l_result.eoln$);
    assert_value(i_name => 'with_eoln: original eoln untouched', i_expected => ${defaultEoln}, i_actual => l_lob.eoln$);

    -- act
    l_result := l_result.appendln(${lit:a}).appendln(${lit:b});

    -- assert
    assert_value(i_name => 'with_eoln: used by appendln', i_expected => ${lit:a;b;}, i_actual => l_result.subStr(1));

    -- act
    l_result := l_lob.with_eoln(${lit:<br>}).appendln(${lit:a});

    -- assert
    assert_value(i_name => 'with_eoln: multi-character eoln', i_expected => ${lit:a<br>}, i_actual => l_result.subStr(1));

    -- act
    l_result := l_lob.with_eoln(${lit:;}).with_eoln(${lit:,}).appendln(${lit:a});

    -- assert
    assert_value(i_name => 'with_eoln: last one wins', i_expected => ${lit:a,}, i_actual => l_result.subStr(1));

    -- act
    l_result := l_lob.with_eoln(l_null_small).appendln(${lit:a}).appendln();

    -- assert
    assert_true(i_name => 'with_eoln: NULL eoln is stored', i_condition => l_result.eoln$ is null);
    assert_value(i_name => 'with_eoln: NULL eoln means no line terminator', i_expected => ${lit:a}, i_actual => l_result.subStr(1));

    -- act
    l_result := l_lob.appendln(${lit:a}).appendln();

    -- assert
    assert_value(i_name => 'default eoln', i_expected => ${defaultEoln}, i_actual => l_lob.eoln$);
    assert_value(i_name => 'default eoln: a line and an empty line', i_expected => ${lit:a}||${defaultEoln}||${defaultEoln}, i_actual => l_result.subStr(1));

    -- act
    l_result := phr_${largeTypeScalar}.use_lob(native_lob(), false).with_eoln(${lit:!}).appendln(${lit:a});

    -- assert
    assert_value(i_name => 'with_eoln: nonbuffered LOB', i_expected => ${lit:a!}, i_actual => l_result.subStr(1));
end;
