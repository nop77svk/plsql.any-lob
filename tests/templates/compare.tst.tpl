declare
@include _constants.inc
    c_difference_lower              constant number := -1;
    c_difference_greater            constant number := 1;
    l_abc                           phr_${largeTypeScalar};
    l_null_lob                      phr_${largeTypeScalar};
    l_null_locator                  phr_${largeTypeScalar} := phr_${largeTypeScalar}.use_lob(null);
    l_empty                         phr_${largeTypeScalar} := phr_${largeTypeScalar}.new_tmp_lob();
    l_null_native                   ${largeTypeScalar};
    l_rank                          pls_integer;
    l_sorted                        ${smallTypeCollection} := ${smallTypeCollection}();
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_abc := new_lob(${lit:abc});

    -- assert
    assert_number(i_name => 'equal contents', i_expected => 0, i_actual => l_abc.compare(new_lob(${lit:abc})));
    assert_number(i_name => 'equal contents, repeated: pending appends not consumed', i_expected => 0, i_actual => l_abc.compare(new_lob(${lit:abc})));
    assert_number(i_name => 'same object', i_expected => 0, i_actual => l_abc.compare(l_abc));
    assert_number(i_name => 'shorter, lengths first', i_expected => c_length_less, i_actual => l_abc.compare(new_lob(${lit:abcd})));
    assert_number(i_name => 'longer, lengths first', i_expected => c_length_greater, i_actual => l_abc.compare(new_lob(${lit:ab})));
    assert_number(i_name => 'shorter, lengths first, explicit flag', i_expected => c_length_less, i_actual => l_abc.compare(new_lob(${lit:abcd}), true));
    assert_number(i_name => 'shorter, contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(${lit:abcd}), false));
    assert_number(i_name => 'longer, contents only', i_expected => c_difference_greater, i_actual => new_lob(${lit:abcd}).compare(l_abc, false));
    assert_number(i_name => 'lower contents', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(${lit:abd})));
    assert_number(i_name => 'greater contents', i_expected => c_difference_greater, i_actual => new_lob(${lit:abd}).compare(l_abc));
    assert_number(i_name => 'lower contents, contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(${lit:abd}), false));
    assert_number(i_name => 'equal contents, contents only', i_expected => 0, i_actual => l_abc.compare(new_lob(${lit:abc}), false));
    assert_number(i_name => 'different content of the same length, lengths first', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(${lit:abd}), true));
    assert_number(i_name => 'empty vs empty', i_expected => 0, i_actual => l_empty.compare(phr_${largeTypeScalar}.new_tmp_lob()));
    assert_number(i_name => 'empty vs filled', i_expected => c_length_less, i_actual => l_empty.compare(l_abc));
    assert_number(i_name => 'filled vs empty', i_expected => c_length_greater, i_actual => l_abc.compare(l_empty));

    -- assert
    assert_number(i_name => 'tripple buffering vs double buffering: equal', i_expected => 0, i_actual => phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered().append(${lit:abc}).compare(l_abc));
    assert_number(i_name => 'nonbuffered vs double buffering: equal', i_expected => 0, i_actual => phr_${largeTypeScalar}.new_tmp_lob().nonbuffered().append(${lit:abc}).compare(l_abc));

    -- assert
    assert_number(i_name => 'big LOBs: equal', i_expected => 0, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).compare(phr_${largeTypeScalar}.use_lob(big_native_lob())));
    assert_number(i_name => 'big LOBs differing in the last element', i_expected => c_difference_lower, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).compare(phr_${largeTypeScalar}.use_lob(big_native_lob()).append(${lit:b}).trim(c_big_length - 1).append(${lit:b})));
    assert_number(i_name => 'big LOB vs small LOB, lengths first', i_expected => c_length_greater, i_actual => phr_${largeTypeScalar}.use_lob(big_native_lob()).compare(l_abc));

    -- assert
    assert_number(i_name => 'both NULL locators', i_expected => null, i_actual => l_null_locator.compare(l_null_locator));
    assert_number(i_name => 'both NULL locators, contents only', i_expected => null, i_actual => l_null_locator.compare(l_null_locator, false));
    assert_number(i_name => 'NULL locator vs empty LOB', i_expected => null, i_actual => l_null_locator.compare(l_empty));
    assert_number(i_name => 'empty LOB vs NULL locator', i_expected => null, i_actual => l_empty.compare(l_null_locator));
    assert_number(i_name => 'NULL locator vs filled LOB, lengths first', i_expected => c_length_less, i_actual => l_null_locator.compare(l_abc));
    assert_number(i_name => 'filled LOB vs NULL locator, lengths first', i_expected => c_length_greater, i_actual => l_abc.compare(l_null_locator));
    assert_number(i_name => 'NULL locator vs filled LOB, contents only', i_expected => null, i_actual => l_null_locator.compare(l_abc, false));
    assert_number(i_name => 'compare with a NULL object', i_expected => null, i_actual => l_abc.compare(l_null_lob));
    assert_number(i_name => 'compare with a NULL object, contents only', i_expected => null, i_actual => l_abc.compare(l_null_lob, false));

    -- act
    begin
        l_error := l_null_lob.compare(l_abc);
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'compare of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);

    -- assert
    assert_number(i_name => 'SQL-boolean Y: lengths first', i_expected => c_length_less, i_actual => l_abc.compare(new_lob(${lit:abcd}), c_flag_yes));
    assert_number(i_name => 'SQL-boolean N: contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(${lit:abcd}), c_flag_no));
    assert_number(i_name => 'SQL-boolean unrecognized flag: contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(new_lob(${lit:abcd}), 'garbage'));
    assert_number(i_name => 'SQL-boolean N: equal contents', i_expected => 0, i_actual => l_abc.compare(new_lob(${lit:abc}), c_flag_no));

    -- assert
    assert_number(i_name => 'LOB: equal contents', i_expected => 0, i_actual => l_abc.compare(native_lob(${lit:abc})));
    assert_number(i_name => 'LOB: shorter, lengths first', i_expected => c_length_less, i_actual => l_abc.compare(native_lob(${lit:abcd})));
    assert_number(i_name => 'LOB: shorter, contents only', i_expected => c_difference_lower, i_actual => l_abc.compare(native_lob(${lit:abcd}), false));
    assert_number(i_name => 'LOB: lower contents', i_expected => c_difference_lower, i_actual => l_abc.compare(native_lob(${lit:abd})));
    assert_number(i_name => 'LOB: greater contents', i_expected => c_difference_greater, i_actual => l_abc.compare(native_lob(${lit:abb})));
    assert_number(i_name => 'LOB: NULL locator, lengths first', i_expected => c_length_greater, i_actual => l_abc.compare(l_null_native));
    assert_number(i_name => 'LOB: NULL locator, contents only', i_expected => null, i_actual => l_abc.compare(l_null_native, false));
    assert_number(i_name => 'LOB: empty LOB vs empty LOB', i_expected => 0, i_actual => l_empty.compare(native_lob()));
    assert_number(i_name => 'LOB, SQL-boolean N: shorter', i_expected => c_difference_lower, i_actual => l_abc.compare(native_lob(${lit:abcd}), c_flag_no));
    assert_number(i_name => 'LOB, SQL-boolean Y: shorter', i_expected => c_length_less, i_actual => l_abc.compare(native_lob(${lit:abcd}), c_flag_yes));

    -- assert
    assert_number(i_name => 'ORDER method: equal', i_expected => 0, i_actual => l_abc.order$(new_lob(${lit:abc})));
    assert_number(i_name => 'ORDER method: lower', i_expected => c_difference_lower, i_actual => l_abc.order$(new_lob(${lit:abd})));
    assert_number(i_name => 'ORDER method: greater', i_expected => c_difference_greater, i_actual => new_lob(${lit:abd}).order$(l_abc));
    assert_number(i_name => 'ORDER method: shorter', i_expected => c_length_less, i_actual => l_abc.order$(new_lob(${lit:abcd})));
    assert_number(i_name => 'ORDER method: NULL object', i_expected => null, i_actual => l_abc.order$(l_null_lob));

    -- act
    for r in (
        select T.V as LOB
        from (
            select phr_${largeTypeScalar}.init_tmp_lob(${lit:bb}) as V from dual
            union all
            select phr_${largeTypeScalar}.init_tmp_lob(${lit:a}) as V from dual
            union all
            select phr_${largeTypeScalar}.init_tmp_lob(${lit:ccc}) as V from dual
            union all
            select phr_${largeTypeScalar}.init_tmp_lob(${lit:ba}) as V from dual
        ) T
        order by T.V
    ) loop
        l_sorted.extend();
        l_sorted(l_sorted.last()) := r.LOB.subStr(1);
    end loop;

    -- assert
    assert_number(i_name => 'ORDER BY in SQL: row count', i_expected => 4, i_actual => l_sorted.count());
    assert_value(i_name => 'ORDER BY in SQL: first', i_expected => ${lit:a}, i_actual => l_sorted(1));
    assert_value(i_name => 'ORDER BY in SQL: second', i_expected => ${lit:ba}, i_actual => l_sorted(2));
    assert_value(i_name => 'ORDER BY in SQL: third', i_expected => ${lit:bb}, i_actual => l_sorted(3));
    assert_value(i_name => 'ORDER BY in SQL: last', i_expected => ${lit:ccc}, i_actual => l_sorted(4));

    -- act
    select count(*)
    into l_rank
    from dual
    where phr_${largeTypeScalar}.init_tmp_lob(${lit:abc}) = phr_${largeTypeScalar}.init_tmp_lob(${lit:abc})
        and phr_${largeTypeScalar}.init_tmp_lob(${lit:abc}) != phr_${largeTypeScalar}.init_tmp_lob(${lit:abd})
        and phr_${largeTypeScalar}.init_tmp_lob(${lit:abc}) < phr_${largeTypeScalar}.init_tmp_lob(${lit:abd})
        and phr_${largeTypeScalar}.init_tmp_lob(${lit:abd}) > phr_${largeTypeScalar}.init_tmp_lob(${lit:abc});

    -- assert
    assert_number(i_name => 'comparison operators in SQL', i_expected => 1, i_actual => l_rank);
end;
