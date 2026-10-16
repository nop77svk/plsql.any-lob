declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_null_lob                      phr_${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();

    -- assert
    assert_number(i_name => 'new LOB: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'new LOB: is empty', i_condition => l_lob.is_empty());

    -- act
    l_lob := new_lob(${lit:abc});

    -- assert
    assert_number(i_name => 'pending appends: length', i_expected => 3, i_actual => l_lob.length());
    assert_number(i_name => 'pending appends: not yet in the LOB', i_expected => 0, i_actual => dbms_lob.getLength(l_lob.the_value$));
    assert_true(i_name => 'pending appends: is not empty', i_condition => not l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false).append(${lit:abcd});

    -- assert
    assert_number(i_name => 'nonbuffered: length', i_expected => 4, i_actual => l_lob.length());
    assert_true(i_name => 'nonbuffered: is not empty', i_condition => not l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered().append(${lit:abcde});

    -- assert
    assert_number(i_name => 'tripple buffering: length', i_expected => 5, i_actual => l_lob.length());

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob().tripple_buffered(i_buffer_size => 1).append(${lit:ab}).append(${lit:cd}).append(${lit:ef});

    -- assert
    assert_number(i_name => 'tripple buffering, pending in both buffers: length', i_expected => 6, i_actual => l_lob.length());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(big_native_lob());

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: length', i_expected => c_big_length, i_actual => l_lob.length());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(big_native_lob()).append(${lit:abc});

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold plus pending appends: length', i_expected => c_big_length + 3, i_actual => l_lob.length());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(null);

    -- assert
    assert_number(i_name => 'NULL locator: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'NULL locator: is empty', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(native_lob());

    -- assert
    assert_number(i_name => 'empty native LOB: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'empty native LOB: is empty', i_condition => l_lob.is_empty());

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();
    l_lob.tmp_dispose();

    -- assert
    assert_number(i_name => 'disposed LOB: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'disposed LOB: is empty', i_condition => l_lob.is_empty());

    -- act
    begin
        l_error := l_null_lob.length();
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'length of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);

    -- act
    begin
        l_error := case when l_null_lob.is_empty() then 1 else 0 end;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'is_empty of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);
end;
