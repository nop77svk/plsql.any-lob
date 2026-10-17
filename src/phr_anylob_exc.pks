create or replace package phr_anylob_exc
as

------------------------------------------------------------------------------------------------
-- %project "Peter's PLSQL foundation"
-- %framework LOB builders
------------------------------------------------------------------------------------------------
-- Application error codes raised by the phr_clob, phr_nclob and phr_blob classes.
------------------------------------------------------------------------------------------------

E_Not_Implemented                   exception;
CE_Not_Implemented                  constant simple_integer := -20900;
    pragma exception_init(E_Not_Implemented, CE_Not_Implemented);

-- A NULL, negative or otherwise unacceptable argument value, or an unusable internal state of the object.
E_Invalid_Argument                  exception;
CE_Invalid_Argument                 constant simple_integer := -20901;
    pragma exception_init(E_Invalid_Argument, CE_Invalid_Argument);

-- The contained LOB is not of the kind the called method can work with.
E_Invalid_Data_Type                 exception;
CE_Invalid_Data_Type                constant simple_integer := -20902;
    pragma exception_init(E_Invalid_Data_Type, CE_Invalid_Data_Type);



end;
/
