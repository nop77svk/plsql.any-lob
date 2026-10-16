set define off
set serveroutput on size unlimited
whenever sqlerror exit failure rollback

prompt Cleaning up existing objects

declare
    e_Type_Not_Exists               exception;
    pragma exception_init(e_Type_Not_Exists, -4043);

    c_types_to_drop                 constant sys.odcivarchar2list := sys.odcivarchar2list
        ( 'phr_clob'
        , 'phr_nclob'
        , 'phr_blob'
        , 'arr_clob'
        , 'arr_nclob'
        , 'arr_blob'
        , 'arr_varchar2'
        , 'arr_nvarchar2'
        , 'arr_raw' );
begin
    for i in 1 .. c_types_to_drop.count
    loop
        begin
            execute immediate 'drop type ' || c_types_to_drop(i) || ' force';
            dbms_output.put_line('Dropped type ' || c_types_to_drop(i));
        exception
            when e_Type_Not_Exists then
                null;
        end;
    end loop;
end;
/

prompt Deploying prerequisites
@@src/install/prerequisites.sql

prompt Deploying phr_clob
@@src/generated/phr_clob.typ

prompt Deploying phr_nclob
@@src/generated/phr_nclob.typ

prompt Deploying phr_blob
@@src/generated/phr_blob.typ

prompt Compiling natively
@@src/install/native-compile.sql

prompt Verifying the installation

declare
    c_installation_failed_code      constant pls_integer := -20001;
    l_problem_count                 pls_integer;
begin
    select count(*)
    into l_problem_count
    from user_objects UO
    where UO.object_name in ('PHR_CLOB', 'PHR_NCLOB', 'PHR_BLOB')
        and UO.object_type in ('TYPE', 'TYPE BODY')
        and UO.status != 'VALID';

    if l_problem_count > 0 then
        raise_application_error
            ( c_installation_failed_code
            , l_problem_count || ' phr_clob/phr_nclob/phr_blob type unit(s) not VALID, check user_errors (are phr_utl_boolean and phr_utl_exc installed?)' );
    end if;

    dbms_output.put_line('phr_clob, phr_nclob and phr_blob installed and VALID');
end;
/
