declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_native                        ${largeTypeScalar};
    l_null_lob                      phr_${largeTypeScalar};
    l_error                         pls_integer;
@include _persistent.inc
@include _helpers.inc
begin
    -- arrange
    create_persistent_tables();

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();

    -- assert
    assert_true(i_name => 'temporary LOB: is_persistent', i_condition => not l_lob.is_persistent());
    assert_flag(i_name => 'temporary LOB: is_persistent$', i_expected => c_flag_no, i_actual => l_lob.is_persistent$());
    assert_true(i_name => 'temporary LOB: is_secure_file', i_condition => not l_lob.is_secure_file());
    assert_flag(i_name => 'temporary LOB: is_secure_file$', i_expected => c_flag_no, i_actual => l_lob.is_secure_file$());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(native_lob(${lit:abc}));

    -- assert
    assert_true(i_name => 'wrapped temporary LOB: is_persistent', i_condition => not l_lob.is_persistent());

    -- arrange
    l_native := persistent_lob(i_secure => true);

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(l_native);

    -- assert
    assert_true(i_name => 'SecureFile LOB: is_persistent', i_condition => l_lob.is_persistent());
    assert_flag(i_name => 'SecureFile LOB: is_persistent$', i_expected => c_flag_yes, i_actual => l_lob.is_persistent$());
    assert_true(i_name => 'SecureFile LOB: is_secure_file', i_condition => l_lob.is_secure_file());
    assert_flag(i_name => 'SecureFile LOB: is_secure_file$', i_expected => c_flag_yes, i_actual => l_lob.is_secure_file$());

    -- arrange
    l_native := persistent_lob(i_secure => false);

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(l_native, false);

    -- assert
    assert_true(i_name => 'BasicFile LOB: is_persistent', i_condition => l_lob.is_persistent());
    assert_flag(i_name => 'BasicFile LOB: is_persistent$', i_expected => c_flag_yes, i_actual => l_lob.is_persistent$());
    assert_true(i_name => 'BasicFile LOB: is_secure_file', i_condition => not l_lob.is_secure_file());
    assert_flag(i_name => 'BasicFile LOB: is_secure_file$', i_expected => c_flag_no, i_actual => l_lob.is_secure_file$());

    -- act
    l_lob := phr_${largeTypeScalar}.use_lob(null);

    -- assert
    assert_true(i_name => 'NULL locator: is_persistent', i_condition => l_lob.is_persistent() is null);
    assert_true(i_name => 'NULL locator: is_persistent$', i_condition => l_lob.is_persistent$() is null);
    assert_true(i_name => 'NULL locator: is_secure_file', i_condition => l_lob.is_secure_file() is null);
    assert_true(i_name => 'NULL locator: is_secure_file$', i_condition => l_lob.is_secure_file$() is null);

    -- act
    begin
        l_error := case when l_null_lob.is_persistent() then 1 else 0 end;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'is_persistent of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);

    -- act
    begin
        l_error := case when l_null_lob.is_secure_file() then 1 else 0 end;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'is_secure_file of a NULL object is rejected', i_expected => c_null_self_error, i_actual => l_error);

    -- cleanup
    rollback;
    drop_persistent_tables();
exception
    when others then
        rollback;
        drop_persistent_tables();
        raise;
end;
