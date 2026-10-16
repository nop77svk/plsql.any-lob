declare
@include _constants.inc
    c_dest_offset                   constant pls_integer := 3;
    l_lob                           phr_${largeTypeScalar};
    l_dest                          ${largeTypeScalar};
    l_null_dest                     ${largeTypeScalar};
    l_error                         pls_integer;
@include _helpers.inc
begin
    -- arrange
    l_lob := new_lob(${lit:abc});
    l_dest := native_lob(${lit:xxxxxxxx});

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'copy at the beginning: copied content', i_expected => ${lit:abc}, i_actual => dbms_lob.substr(l_dest, 3, 1));
    assert_number(i_name => 'copy to: source untouched', i_expected => 3, i_actual => l_lob.length());

    -- arrange
    l_dest := native_lob(${lit:xxxxxxxx});

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => c_dest_offset);

    -- assert
    assert_value(i_name => 'copy at an offset: copied content', i_expected => ${lit:abc}, i_actual => dbms_lob.substr(l_dest, 3, c_dest_offset));
    assert_value(i_name => 'copy at an offset: leading content kept', i_expected => ${lit:xx}, i_actual => dbms_lob.substr(l_dest, 2, 1));

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => c_dest_offset);

    -- assert
    assert_value(i_name => 'repeated copy: idempotent', i_expected => ${lit:abc}, i_actual => dbms_lob.substr(l_dest, 3, c_dest_offset));
    assert_number(i_name => 'repeated copy: source length untouched', i_expected => 3, i_actual => l_lob.length());

    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob(i_buffered_writes => false).append(${lit:abc});
    l_dest := native_lob(${lit:xxxxxxxx});

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'nonbuffered source: copied content', i_expected => ${lit:abc}, i_actual => dbms_lob.substr(l_dest, 3, 1));

    -- arrange
    l_lob := phr_${largeTypeScalar}.use_lob(big_native_lob());
    l_dest := native_lob();
    dbms_lob.writeAppend(l_dest, 1, ${lit:x});
    dbms_lob.append(l_dest, big_native_lob());
    dbms_lob.append(l_dest, big_native_lob());

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_number(i_name => 'LOB over the buffer threshold: copied content', i_expected => 0, i_actual => dbms_lob.compare(l_lob.get_value(), l_dest, c_big_length, 1, 1));

    -- arrange
    l_lob := phr_${largeTypeScalar}.new_tmp_lob();
    l_dest := native_lob(${lit:xxxxxxxx});

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'empty source: destination untouched', i_expected => ${lit:xxxxxxxx}, i_actual => dbms_lob.substr(l_dest, 100, 1));

    -- arrange
    l_lob := phr_${largeTypeScalar}.use_lob(null);

    -- act
    l_lob.copy_to(io_dest => l_dest, i_dest_offset => 1);

    -- assert
    assert_value(i_name => 'NULL source: destination untouched', i_expected => ${lit:xxxxxxxx}, i_actual => dbms_lob.substr(l_dest, 100, 1));

    -- act
    l_lob.copy_to(io_dest => l_null_dest, i_dest_offset => 1);

    -- assert
    assert_true(i_name => 'NULL source, NULL destination: no error, destination untouched', i_condition => l_null_dest is null);

    -- arrange
    l_lob := new_lob(${lit:abc});

    -- act
    begin
        l_lob.copy_to(io_dest => l_null_dest, i_dest_offset => 1);
        l_error := c_no_error;
    exception
        when others then
            l_error := sqlcode;
    end;

    -- assert
    assert_number(i_name => 'NULL destination is rejected', i_expected => c_value_error, i_actual => l_error);
end;
