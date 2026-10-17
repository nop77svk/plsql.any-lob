set define off
set serveroutput on size unlimited
whenever sqlerror exit failure rollback

prompt Cleaning up existing objects

declare
    e_Object_Not_Exists             exception;
    pragma exception_init(e_Object_Not_Exists, -4043);

    c_drop_statements               constant sys.odcivarchar2list := sys.odcivarchar2list
        ( 'drop type phr_clob force'
        , 'drop type phr_nclob force'
        , 'drop type phr_blob force'
        , 'drop package phr_anylob_exc'
        , 'drop type arr_clob force'
        , 'drop type arr_nclob force'
        , 'drop type arr_blob force'
        , 'drop type arr_varchar2 force'
        , 'drop type arr_nvarchar2 force'
        , 'drop type arr_raw force' );
begin
    for i in 1 .. c_drop_statements.count
    loop
        begin
            execute immediate c_drop_statements(i);
            dbms_output.put_line(c_drop_statements(i));
        exception
            when e_Object_Not_Exists then
                null;
        end;
    end loop;
end;
/

prompt Deploying prerequisites
@@src/install/scalar-collections.sql
@@src/install/phr_anylob_exc.pks

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
    where UO.object_name in ('PHR_CLOB', 'PHR_NCLOB', 'PHR_BLOB', 'PHR_ANYLOB_EXC')
        and UO.object_type in ('TYPE', 'TYPE BODY', 'PACKAGE')
        and UO.status != 'VALID';

    if l_problem_count > 0 then
        raise_application_error
            ( c_installation_failed_code
            , l_problem_count || ' phr_anylob_exc/phr_clob/phr_nclob/phr_blob unit(s) not VALID, check user_errors (is utl_ident installed?)' );
    end if;

    dbms_output.put_line('phr_anylob_exc, phr_clob, phr_nclob and phr_blob installed and VALID');
end;
/
