alter session set plsql_code_type = native;
alter session set plsql_debug = false;
alter session set plsql_optimize_level = 3;

alter type phr_clob compile specification;
alter type phr_clob compile body;

alter type phr_blob compile specification;
alter type phr_blob compile body;

alter type phr_nclob compile specification;
alter type phr_nclob compile body;

alter session set plsql_code_type = interpreted;
alter session set plsql_optimize_level = 2;
alter session set plsql_debug = true;
