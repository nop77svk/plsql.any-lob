declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_native                        ${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_cache => false, i_duration => dbms_lob.session);
    l_lob.append(${lit:abc});

    -- act
    l_lob.tmp_dispose();

    -- assert
    assert_true(i_name => 'tmp_dispose: LOB released', i_condition => l_lob.the_value$ is null);
    assert_true(i_name => 'tmp_dispose: primary buffer cleared', i_condition => l_lob.primary_buffer$ is null);
    assert_true(i_name => 'tmp_dispose: cache flag cleared', i_condition => l_lob.tmp_lob_cached$ is null);
    assert_true(i_name => 'tmp_dispose: duration cleared', i_condition => l_lob.tmp_lob_duration$ is null);
    assert_number(i_name => 'tmp_dispose: length', i_expected => 0, i_actual => l_lob.length());

    -- act
    l_lob.tmp_dispose();

    -- assert
    assert_true(i_name => 'tmp_dispose twice: still disposed', i_condition => l_lob.the_value$ is null);

    -- arrange
    l_lob := phr_${largeTypeScalar}.use_lob(null);

    -- act
    l_lob.tmp_dispose();

    -- assert
    assert_true(i_name => 'tmp_dispose on NULL locator: no-op', i_condition => l_lob.the_value$ is null);

    -- act
    l_lob.tmp_initialize(i_cache => false, i_duration => dbms_lob.session);

    -- assert
    assert_true(i_name => 'tmp_initialize on a disposed object: new LOB', i_condition => l_lob.the_value$ is not null);
    assert_true(i_name => 'tmp_initialize on a disposed object: temporary', i_condition => not l_lob.is_persistent());
    assert_number(i_name => 'tmp_initialize on a disposed object: cache flag', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_initialize on a disposed object: duration', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);
    assert_number(i_name => 'tmp_initialize on a disposed object: length', i_expected => 0, i_actual => l_lob.length());

    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();
    l_lob.append(${lit:abc});
    l_lob.fsync();
    l_lob.append(${lit:def});

    -- act
    l_lob.tmp_initialize(i_cache => true);

    -- assert
    assert_number(i_name => 'tmp_initialize on a filled object: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'tmp_initialize on a filled object: pending appends dropped', i_condition => l_lob.primary_buffer$ is null);
    assert_number(i_name => 'tmp_initialize: cache flag on', i_expected => 1, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_initialize: default duration', i_expected => dbms_lob.call, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.append(${lit:xyz});

    -- assert
    assert_value(i_name => 'tmp_initialize: usable for appends', i_expected => ${lit:xyz}, i_actual => l_lob.subStr(1));

    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_cache => false, i_duration => dbms_lob.session);
    l_lob.append(${lit:abc});

    -- act
    l_lob.tmp_reinitialize();

    -- assert
    assert_number(i_name => 'tmp_reinitialize: emptied', i_expected => 0, i_actual => l_lob.length());
    assert_number(i_name => 'tmp_reinitialize: cache flag kept', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'tmp_reinitialize: duration kept', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.append(${lit:def});

    -- assert
    assert_value(i_name => 'tmp_reinitialize: usable for appends', i_expected => ${lit:def}, i_actual => l_lob.subStr(1));

    -- arrange
    l_lob := phr_${largeTypeScalar}.use_lob(native_lob(${lit:abc}));

    -- act
    begin
        l_lob.tmp_reinitialize();
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'tmp_reinitialize on a foreign LOB is rejected', i_expected => c_invalid_data_type_error, i_actual => l_error);

    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();
    l_lob.tmp_dispose();

    -- act
    begin
        l_lob.tmp_reinitialize();
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'tmp_reinitialize on a disposed object is rejected', i_expected => c_invalid_data_type_error, i_actual => l_error);
end;
