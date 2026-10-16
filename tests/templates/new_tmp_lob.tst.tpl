declare
@include _constants.inc
    l_lob                           phr_${largeTypeScalar};
    l_session_lob                   phr_${largeTypeScalar};
    l_null_boolean                  boolean;
    l_null_flag                     varchar2(1);
@include _helpers.inc
begin
    -- arrange + act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();

    -- assert
    assert_number(i_name => 'default: length', i_expected => 0, i_actual => l_lob.length());
    assert_true(i_name => 'default: is empty', i_condition => l_lob.is_empty());
    assert_true(i_name => 'default: is temporary', i_condition => not l_lob.is_persistent());
    assert_number(i_name => 'default: buffering on', i_expected => c_level_double, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'default: cache on', i_expected => 1, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'default: call duration', i_expected => dbms_lob.call, i_actual => l_lob.tmp_lob_duration$);
    assert_value(i_name => 'default: eoln', i_expected => ${defaultEoln}, i_actual => l_lob.eoln$);
    assert_true(i_name => 'default: no raw conversion charset', i_condition => l_lob.raw_conversion_charset$ is null);

    -- act
    l_lob.append(${lit:abc});

    -- assert
    assert_value(i_name => 'default: usable for appends', i_expected => ${lit:abc}, i_actual => l_lob.subStr(1));

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false, i_cache => false);

    -- assert
    assert_number(i_name => 'boolean flags off: buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'boolean flags off: cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);

    -- act
    l_session_lob := phr_${largeTypeScalar}.new_tmp_lob(i_duration => dbms_lob.session);

    -- assert
    assert_number(i_name => 'boolean overload: session duration', i_expected => dbms_lob.session, i_actual => l_session_lob.tmp_lob_duration$);

    -- act
    l_session_lob.tmp_dispose();
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => l_null_boolean);

    -- assert
    assert_number(i_name => 'boolean overload: NULL buffering flag means off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(c_flag_yes);

    -- assert
    assert_number(i_name => 'SQL-boolean overload: Y buffering', i_expected => c_level_double, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'SQL-boolean overload: default cache', i_expected => 1, i_actual => l_lob.tmp_lob_cached$);

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => c_flag_no, i_cache => c_flag_no, i_duration => dbms_lob.session);

    -- assert
    assert_number(i_name => 'SQL-boolean overload: N buffering', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
    assert_number(i_name => 'SQL-boolean overload: N cache', i_expected => 0, i_actual => l_lob.tmp_lob_cached$);
    assert_number(i_name => 'SQL-boolean overload: session duration', i_expected => dbms_lob.session, i_actual => l_lob.tmp_lob_duration$);

    -- act
    l_lob.tmp_dispose();
    l_lob := phr_${largeTypeScalar}.new_tmp_lob('YES');

    -- assert
    assert_number(i_name => 'SQL-boolean overload: YES, case-insensitive', i_expected => c_level_double, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob('garbage');

    -- assert
    assert_number(i_name => 'SQL-boolean overload: unrecognized flag means off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);

    -- act
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(l_null_flag);

    -- assert
    assert_number(i_name => 'SQL-boolean overload: NULL flag means off', i_expected => c_level_nonbuffered, i_actual => l_lob.buffering_level$);
end;
