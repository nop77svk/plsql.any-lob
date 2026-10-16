    c_secure_table                  constant varchar2(30) := 'phr_tst_${largeTypeScalar}_sf';
    c_basic_table                   constant varchar2(30) := 'phr_tst_${largeTypeScalar}_bf';

    procedure drop_persistent_tables
    is
        e_table_does_not_exist          exception;
        pragma exception_init(e_table_does_not_exist, -942);
    begin
        begin
            execute immediate 'drop table '||c_secure_table||' purge';
        exception
            when e_table_does_not_exist then
                null;
        end;

        begin
            execute immediate 'drop table '||c_basic_table||' purge';
        exception
            when e_table_does_not_exist then
                null;
        end;
    end;

    procedure create_persistent_tables
    is
    begin
        drop_persistent_tables();
        execute immediate 'create table '||c_secure_table||' (v ${largeTypeScalar}) lob (v) store as securefile';
        execute immediate 'create table '||c_basic_table||' (v ${largeTypeScalar}) lob (v) store as basicfile';
    end;

    function persistent_lob
        ( i_secure                      in boolean )
        return ${largeTypeScalar}
    is
        l_result                        ${largeTypeScalar};
    begin
        execute immediate 'insert into '||case when i_secure then c_secure_table else c_basic_table end||' (v) values (${emptyLobFunction}()) returning v into :1'
            returning into l_result;
        return l_result;
    end;
