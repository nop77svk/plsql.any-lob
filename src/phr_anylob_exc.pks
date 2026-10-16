create or replace package phr_anylob_exc
as
    ------------------------------------------------------------------------------------------------
    -- %project "Peter's PLSQL foundation"
    -- %framework LOB builders
    ------------------------------------------------------------------------------------------------
    -- Application error codes raised by the phr_clob, phr_nclob and phr_blob classes.
    ------------------------------------------------------------------------------------------------

    -- A NULL, negative or otherwise unacceptable argument value, or an unusable internal state of the object.
    CE_Invalid_Argument             constant pls_integer := -20901;

    -- The contained LOB is not of the kind the called method can work with.
    CE_Invalid_Data_Type            constant pls_integer := -20902;
end;
/
