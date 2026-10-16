declare
@include _constants.inc
    c_delimiter_length              constant pls_integer := 1;
    l_lob                           phr_${largeTypeScalar};
    l_result                        phr_${largeTypeScalar};
    l_source                        phr_${largeTypeScalar};
    l_null_phr                      phr_${largeTypeScalar};
    l_null_small                    ${smallTypeScalar}(1);
    l_null_native                   ${largeTypeScalar};
    l_small_values                  ${smallTypeCollection};
    l_large_values                  ${largeTypeCollection};
    l_null_small_values             ${smallTypeCollection};
    l_null_large_values             ${largeTypeCollection};
    l_cursor                        sys_refcursor;
    l_suffix                        varchar2(32);
    l_error                         pls_integer;

    function cursor_of_small
        ( i_values                      in ${smallTypeCollection} )
        return sys_refcursor
    is
        l_result                        sys_refcursor;
    begin
        open l_result for
            select X.V
            from (
                select T.column_value as V, rownum as N
                from table(i_values) T
            ) X
            order by X.N;
        return l_result;
    end;

    function cursor_of_large
        ( i_values                      in ${largeTypeCollection} )
        return sys_refcursor
    is
        l_result                        sys_refcursor;
    begin
        open l_result for
            select X.V
            from (
                select T.column_value as V, rownum as N
                from table(i_values) T
            ) X
            order by X.N;
        return l_result;
    end;
@include _helpers.inc
begin
    for l_level in c_level_nonbuffered..c_level_tripple loop
        l_suffix := ' [level '||l_level||']';

        -- arrange
        l_lob := new_lob_at_level(l_level);

        -- act
        l_result := l_lob.append(${lit:abc});

        -- assert
        assert_value(i_name => 'small value: content'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
        assert_number(i_name => 'small value: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_result.append(${lit:de}).append(${lit:f});

        -- assert
        assert_value(i_name => 'small value: chained'||l_suffix, i_expected => ${lit:abcdef}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:ab}, 3);

        -- assert
        assert_value(i_name => 'small value repeated'||l_suffix, i_expected => ${lit:ababab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:ab}, 3, ${lit:,});

        -- assert
        assert_value(i_name => 'small value repeated with delimiter'||l_suffix, i_expected => ${lit:ab,ab,ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:ab}, 1, ${lit:,});

        -- assert
        assert_value(i_name => 'small value once with delimiter: no delimiter'||l_suffix, i_expected => ${lit:ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:ab}, 2, ${lit:--});

        -- assert
        assert_value(i_name => 'small value with multi-character delimiter'||l_suffix, i_expected => ${lit:ab--ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${lit:ab}, 0);

        -- assert
        assert_true(i_name => 'small value repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(${lit:ab}, -3, ${lit:,});

        -- assert
        assert_true(i_name => 'small value repeated negative times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_small, 3, ${lit:,});

        -- assert
        assert_true(i_name => 'NULL small value: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(${lit:a}).append(l_null_small).append(${lit:b});

        -- assert
        assert_value(i_name => 'NULL small value between two values'||l_suffix, i_expected => ${lit:ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${rep:1000:a}, c_big_chunk_count);

        -- assert
        assert_number(i_name => 'small values over the buffer threshold: length'||l_suffix, i_expected => c_big_length, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(${rep:1000:a}, c_big_chunk_count, ${lit:,});

        -- assert
        assert_number(i_name => 'small values over the buffer threshold with delimiter: length'||l_suffix, i_expected => c_big_length + (c_big_chunk_count - 1) * c_delimiter_length, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(${lit:x}).append(${rep:1000:a}, c_big_chunk_count).append(${lit:y});

        -- assert
        assert_value(i_name => 'small values over the buffer threshold: first value'||l_suffix, i_expected => ${lit:x}, i_actual => l_result.subStr(1, 1));
        assert_value(i_name => 'small values over the buffer threshold: last value'||l_suffix, i_expected => ${lit:y}, i_actual => l_result.subStr(l_result.length(), 1));
        assert_number(i_name => 'small values over the buffer threshold: length'||l_suffix, i_expected => c_big_length + 2, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(native_lob(${lit:abc}));

        -- assert
        assert_value(i_name => 'LOB: content'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
        assert_number(i_name => 'LOB: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(native_lob(${lit:ab}), 3, ${lit:,});

        -- assert
        assert_value(i_name => 'LOB repeated with delimiter'||l_suffix, i_expected => ${lit:ab,ab,ab}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(native_lob(${lit:ab}), 0);

        -- assert
        assert_true(i_name => 'LOB repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_native, 2, ${lit:,});

        -- assert
        assert_true(i_name => 'NULL LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(native_lob(), 2, ${lit:,});

        -- assert
        assert_true(i_name => 'empty LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(native_lob_of_length(c_threshold));

        -- assert
        assert_number(i_name => 'LOB of the buffer threshold length: length'||l_suffix, i_expected => c_threshold, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(native_lob_of_length(c_threshold + 1));

        -- assert
        assert_number(i_name => 'LOB over the buffer threshold length: length'||l_suffix, i_expected => c_threshold + 1, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(${lit:x}).append(big_native_lob()).append(${lit:y});

        -- assert
        assert_value(i_name => 'LOB over the buffer threshold between small values: first value'||l_suffix, i_expected => ${lit:x}, i_actual => l_result.subStr(1, 1));
        assert_value(i_name => 'LOB over the buffer threshold between small values: last value'||l_suffix, i_expected => ${lit:y}, i_actual => l_result.subStr(l_result.length(), 1));
        assert_number(i_name => 'LOB over the buffer threshold between small values: length'||l_suffix, i_expected => c_big_length + 2, i_actual => l_result.length());

        -- act
        l_result := l_lob.append(big_native_lob(), 2, ${lit:,});

        -- assert
        assert_number(i_name => 'LOB over the buffer threshold repeated with delimiter: length'||l_suffix, i_expected => c_big_length * 2 + c_delimiter_length, i_actual => l_result.length());
        assert_value(i_name => 'LOB over the buffer threshold repeated with delimiter: delimiter'||l_suffix, i_expected => ${lit:,}, i_actual => l_result.subStr(c_big_length + 1, 1));

        -- arrange
        l_source := new_lob(${lit:abc});

        -- act
        l_result := l_lob.append(l_source);

        -- assert
        assert_value(i_name => 'phr LOB: content'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
        assert_value(i_name => 'phr LOB: source untouched'||l_suffix, i_expected => ${lit:abc}, i_actual => l_source.subStr(1));
        assert_number(i_name => 'phr LOB: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(l_source, 2, ${lit:|});

        -- assert
        assert_value(i_name => 'phr LOB repeated with delimiter'||l_suffix, i_expected => ${lit:abc|abc}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(l_source, 0);

        -- assert
        assert_true(i_name => 'phr LOB repeated zero times: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_phr, 2, ${lit:|});

        -- assert
        assert_true(i_name => 'NULL phr LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(phr_${largeTypeScalar}.new_tmp_lob(), 2, ${lit:|});

        -- assert
        assert_true(i_name => 'empty phr LOB: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(phr_${largeTypeScalar}.use_lob(big_native_lob()));

        -- assert
        assert_number(i_name => 'phr LOB over the buffer threshold: length'||l_suffix, i_expected => c_big_length, i_actual => l_result.length());

        -- arrange
        l_small_values := ${smallTypeCollection}(${lit:a}, ${lit:b}, ${lit:c});

        -- act
        l_result := l_lob.append(l_small_values);

        -- assert
        assert_value(i_name => 'small collection'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
        assert_number(i_name => 'small collection: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(l_small_values, ${lit:,});

        -- assert
        assert_value(i_name => 'small collection with delimiter'||l_suffix, i_expected => ${lit:a,b,c}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(l_small_values, ${lit:,}, ${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'small collection with delimiter, prefix and suffix'||l_suffix, i_expected => ${lit:[a],[b],[c]}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(i_values => l_small_values, i_value_prefix => ${lit:<});

        -- assert
        assert_value(i_name => 'small collection with prefix only'||l_suffix, i_expected => ${lit:<a<b<c}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(i_values => l_small_values, i_value_suffix => ${lit:>});

        -- assert
        assert_value(i_name => 'small collection with suffix only'||l_suffix, i_expected => ${lit:a>b>c>}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${smallTypeCollection}(), ${lit:,}, ${lit:[}, ${lit:]});

        -- assert
        assert_true(i_name => 'empty small collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_small_values, ${lit:,}, ${lit:[}, ${lit:]});

        -- assert
        assert_true(i_name => 'NULL small collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(${smallTypeCollection}(${lit:a}, l_null_small, ${lit:c}), ${lit:,});

        -- assert
        assert_value(i_name => 'small collection with a NULL element'||l_suffix, i_expected => ${lit:a,,c}, i_actual => l_result.subStr(1));

        -- arrange
        l_small_values := ${smallTypeCollection}(${lit:a}, ${lit:b}, ${lit:c});
        l_small_values.delete(1);

        -- act
        l_result := l_lob.append(l_small_values, ${lit:,});

        -- assert
        assert_value(i_name => 'sparse small collection: no leading delimiter'||l_suffix, i_expected => ${lit:b,c}, i_actual => l_result.subStr(1));

        -- arrange
        l_small_values := ${smallTypeCollection}();
        l_small_values.extend(c_big_chunk_count);
        for i in 1..c_big_chunk_count loop
            l_small_values(i) := ${rep:1000:a};
        end loop;

        -- act
        l_result := l_lob.append(l_small_values);

        -- assert
        assert_number(i_name => 'small collection over the buffer threshold: length'||l_suffix, i_expected => c_big_length, i_actual => l_result.length());

        -- arrange
        l_large_values := ${largeTypeCollection}(native_lob(${lit:a}), native_lob(${lit:b}), native_lob(${lit:c}));

        -- act
        l_result := l_lob.append(l_large_values);

        -- assert
        assert_value(i_name => 'LOB collection'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));
        assert_number(i_name => 'LOB collection: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- act
        l_result := l_lob.append(l_large_values, ${lit:,}, ${lit:(}, ${lit:)});

        -- assert
        assert_value(i_name => 'LOB collection with delimiter, prefix and suffix'||l_suffix, i_expected => ${lit:(a),(b),(c)}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${largeTypeCollection}(), ${lit:,});

        -- assert
        assert_true(i_name => 'empty LOB collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(l_null_large_values, ${lit:,});

        -- assert
        assert_true(i_name => 'NULL LOB collection: nothing appended'||l_suffix, i_condition => l_result.is_empty());

        -- act
        l_result := l_lob.append(${largeTypeCollection}(native_lob(${lit:a}), l_null_native, native_lob(${lit:c})), ${lit:,});

        -- assert
        assert_value(i_name => 'LOB collection with a NULL element'||l_suffix, i_expected => ${lit:a,,c}, i_actual => l_result.subStr(1));

        -- act
        l_result := l_lob.append(${largeTypeCollection}(native_lob(${lit:a}), big_native_lob(), native_lob(${lit:c})), ${lit:,});

        -- assert
        assert_number(i_name => 'LOB collection with a LOB over the buffer threshold: length'||l_suffix, i_expected => c_big_length + 2 + 2 * c_delimiter_length, i_actual => l_result.length());
        assert_value(i_name => 'LOB collection with a LOB over the buffer threshold: last value'||l_suffix, i_expected => ${lit:c}, i_actual => l_result.subStr(l_result.length(), 1));

        -- arrange
        l_small_values := ${smallTypeCollection}(${lit:a}, ${lit:b}, ${lit:c});
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, ${lit:,}, 100, true, ${lit:[}, ${lit:]});

        -- assert
        assert_value(i_name => 'ref cursor fetched to LOBs'||l_suffix, i_expected => ${lit:[a],[b],[c]}, i_actual => l_result.subStr(1));
        assert_true(i_name => 'ref cursor fetched to LOBs: closed afterwards'||l_suffix, i_condition => not l_cursor%isopen);
        assert_number(i_name => 'ref cursor fetched to LOBs: original untouched'||l_suffix, i_expected => 0, i_actual => l_lob.length());

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, ${lit:,}, 2, false);

        -- assert
        assert_value(i_name => 'ref cursor fetched to small values, multiple batches'||l_suffix, i_expected => ${lit:a,b,c}, i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(i_values => l_cursor, i_batch_size => 1);

        -- assert
        assert_value(i_name => 'ref cursor, batch of one row'||l_suffix, i_expected => ${lit:abc}, i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, ${lit:,}, 2, c_flag_no, ${lit:<}, ${lit:>});

        -- assert
        assert_value(i_name => 'ref cursor, SQL-boolean flag N'||l_suffix, i_expected => ${lit:<a>,<b>,<c>}, i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(l_small_values);

        -- act
        l_result := l_lob.append(l_cursor, ${lit:,}, 100, c_flag_yes);

        -- assert
        assert_value(i_name => 'ref cursor, SQL-boolean flag Y'||l_suffix, i_expected => ${lit:a,b,c}, i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_small(${smallTypeCollection}());

        -- act
        l_result := l_lob.append(l_cursor, ${lit:,}, 100, true, ${lit:[}, ${lit:]});

        -- assert
        assert_true(i_name => 'empty ref cursor: nothing appended'||l_suffix, i_condition => l_result.is_empty());
        assert_true(i_name => 'empty ref cursor: closed afterwards'||l_suffix, i_condition => not l_cursor%isopen);

        -- arrange
        l_cursor := cursor_of_small(${smallTypeCollection}(${lit:a}, l_null_small, ${lit:c}));

        -- act
        l_result := l_lob.append(l_cursor, ${lit:,}, 100, false);

        -- assert
        assert_value(i_name => 'ref cursor with a NULL row'||l_suffix, i_expected => ${lit:a,,c}, i_actual => l_result.subStr(1));

        -- arrange
        l_cursor := cursor_of_large(${largeTypeCollection}(native_lob(${lit:a}), native_lob(${lit:b}), big_native_lob()));

        -- act
        l_result := l_lob.append(l_cursor, ${lit:,}, 2, true);

        -- assert
        assert_number(i_name => 'ref cursor of LOBs, including one over the buffer threshold: length'||l_suffix, i_expected => c_big_length + 2 + 2 * c_delimiter_length, i_actual => l_result.length());
        assert_value(i_name => 'ref cursor of LOBs, including one over the buffer threshold: head'||l_suffix, i_expected => ${lit:a,b,}, i_actual => l_result.subStr(1, 4));
    end loop;

    -- act
    begin
        l_result := l_null_phr.append(${lit:a});
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'append to a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
