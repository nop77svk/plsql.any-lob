declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_source                        phr_${largeTypeScalar};
    l_null_small                    ${smallTypeScalar}(1);
    l_null_large                    ${largeTypeScalar};
    l_null_phr                      phr_${largeTypeScalar};
    l_small_values                  ${smallTypeCollection};
    l_large_values                  ${largeTypeCollection};
    l_cursor                        sys_refcursor;
@include _helpers.inc
begin
    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => ${lit:abc});

    -- assert
    assert_value(i_name => 'small value', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));
    assert_number(i_name => 'small value: buffering on by default', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => ${lit:ab}, i_repeat => 3, i_delimiter => ${lit:,});

    -- assert
    assert_value(i_name => 'small value repeated with delimiter', i_expected => ${lit:ab,ab,ab}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => l_null_small);

    -- assert
    assert_true(i_name => 'NULL small value: empty LOB, not NULL locator', i_condition => l_lob.is_empty() and l_lob.get_value() is not null);

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => ${lit:abc}, i_repeat => 0);

    -- assert
    assert_true(i_name => 'small value repeated zero times', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => ${lit:abc}, i_buffered_writes => false, i_cache => false, i_duration => dbms_lob.session);

    -- assert
    assert_number(i_name => 'small value, boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'small value, boolean flags: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'small value, boolean flags: duration', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);
    assert_value(i_name => 'small value, boolean flags: content', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));

    -- act
    l_lob.tmp_dispose();
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => ${lit:ab}, i_buffered_writes => c_flag_no, i_cache => c_flag_no, i_repeat => 2, i_delimiter => ${lit:-});

    -- assert
    assert_number(i_name => 'small value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'small value, SQL-boolean flags: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_value(i_name => 'small value, SQL-boolean flags: content', i_expected => ${lit:ab-ab}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => native_lob(${lit:abc}));

    -- assert
    assert_value(i_name => 'native LOB value', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => big_native_lob());

    -- assert
    assert_number(i_name => 'native LOB value over the buffer threshold: length', i_expected => c_big_length, i_actual => l_lob.length());

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => native_lob(${lit:ab}), i_repeat => 2, i_delimiter => ${lit:/});

    -- assert
    assert_value(i_name => 'native LOB value repeated with delimiter', i_expected => ${lit:ab/ab}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => l_null_large);

    -- assert
    assert_true(i_name => 'NULL native LOB value: empty LOB', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => native_lob(${lit:abc}), i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'native LOB value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'native LOB value, SQL-boolean flags: content', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));

    -- arrange
    l_source := new_lob(${lit:abc});

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => l_source);
    l_source.append(${lit:d});

    -- assert
    assert_value(i_name => 'phr LOB value: deep copy', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));
    assert_value(i_name => 'phr LOB value: source untouched by the copy', i_expected => ${lit:abcd}, i_actual => l_source.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => l_source, i_repeat => 2, i_delimiter => ${lit:|});

    -- assert
    assert_value(i_name => 'phr LOB value repeated with delimiter', i_expected => ${lit:abcd|abcd}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => l_null_phr);

    -- assert
    assert_true(i_name => 'NULL phr LOB value: empty LOB', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_value => l_source, i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'phr LOB value, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'phr LOB value, SQL-boolean flags: content', i_expected => ${lit:abcd}, i_actual => l_lob.subStr(1));

    -- arrange
    l_small_values := ${smallTypeCollection}(${lit:a}, ${lit:b}, ${lit:c});

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_small_values);

    -- assert
    assert_value(i_name => 'small collection', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_small_values, i_delimiter => ${lit:,}, i_value_prefix => ${lit:[}, i_value_suffix => ${lit:]});

    -- assert
    assert_value(i_name => 'small collection with delimiter, prefix and suffix', i_expected => ${lit:[a],[b],[c]}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => ${smallTypeCollection}());

    -- assert
    assert_true(i_name => 'empty small collection', i_condition => l_lob.is_empty());

    -- arrange
    l_small_values := null;

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_small_values);

    -- assert
    assert_true(i_name => 'NULL small collection', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => ${smallTypeCollection}(${lit:a}, ${lit:b}), i_delimiter => ${lit:+}, i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'small collection, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'small collection, SQL-boolean flags: content', i_expected => ${lit:a+b}, i_actual => l_lob.subStr(1));

    -- arrange
    l_large_values := ${largeTypeCollection}(native_lob(${lit:a}), native_lob(${lit:b}), native_lob(${lit:c}));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_large_values, i_delimiter => ${lit:,}, i_value_prefix => ${lit:(}, i_value_suffix => ${lit:)});

    -- assert
    assert_value(i_name => 'LOB collection with delimiter, prefix and suffix', i_expected => ${lit:(a),(b),(c)}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => ${largeTypeCollection}());

    -- assert
    assert_true(i_name => 'empty LOB collection', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_large_values, i_delimiter => ${lit:;}, i_buffered_writes => c_flag_no);

    -- assert
    assert_number(i_name => 'LOB collection, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'LOB collection, SQL-boolean flags: content', i_expected => ${lit:a;b;c}, i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, ${lit:a} as V from dual
            union all
            select 2 as N, ${lit:b} as V from dual
            union all
            select 3 as N, ${lit:c} as V from dual
        )
        order by N;

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_cursor, i_delimiter => ${lit:,}, i_value_prefix => ${lit:<}, i_value_suffix => ${lit:>});

    -- assert
    assert_value(i_name => 'ref cursor', i_expected => ${lit:<a>,<b>,<c>}, i_actual => l_lob.subStr(1));
    assert_true(i_name => 'ref cursor: closed afterwards', i_condition => not l_cursor%isopen);

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, ${lit:a} as V from dual
            union all
            select 2 as N, ${lit:b} as V from dual
            union all
            select 3 as N, ${lit:c} as V from dual
        )
        order by N;

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_cursor, i_batch_size => 2, i_fetch_to_lobs => false, i_delimiter => ${lit:.});

    -- assert
    assert_value(i_name => 'ref cursor, small buffers, multiple batches', i_expected => ${lit:a.b.c}, i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, ${lit:a} as V from dual
            union all
            select 2 as N, ${lit:b} as V from dual
        )
        order by N;

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_cursor, i_fetch_to_lobs => c_flag_no, i_buffered_writes => c_flag_no, i_batch_size => 1);

    -- assert
    assert_number(i_name => 'ref cursor, SQL-boolean flags: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_value(i_name => 'ref cursor, SQL-boolean flags: content', i_expected => ${lit:ab}, i_actual => l_lob.subStr(1));

    -- arrange
    open l_cursor for
        select V
        from (
            select 1 as N, ${lit:a} as V from dual
            where 1 = 0
        )
        order by N;

    -- act
    l_lob := phr_${largeTypeScalar}.init_tmp_lob(i_values => l_cursor);

    -- assert
    assert_true(i_name => 'empty ref cursor', i_condition => l_lob.is_empty());
end;
