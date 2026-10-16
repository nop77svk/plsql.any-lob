create or replace type phr_${largeTypeScalar}
as
object
(
    ------------------------------------------------------------------------------------------------
    -- %project "Peter's PLSQL foundation"
    -- %framework LOBs abstracted
    ------------------------------------------------------------------------------------------------
    -- Object-encapsulated ${largeTypeScalarUpper} abstraction
    -- %author Peter Hrasko
    -- %email peter.hrasko.sk@gmail.com
    -- %web http://peterhrasko.wordpress.com/peters-plsql-foundation/lob-builders
    ------------------------------------------------------------------------------------------------

    the_lob                         ${largeTypeScalar},

    tmp_lob_cached$                 number(1,0),
    tmp_lob_duration$               integer,
    eoln$                           ${smallTypeScalar}(32),

    -- Factory returning a phr_${largeTypeScalar} instance initialized with new, empty temporary ${largeTypeScalarUpper}.
    --
    -- %param i_cache The value passed to the CACHE parameter of the underlying DBMS_LOB.NEWTEMPORARY() call.
    -- %param i_duration The value passed to the DURATION parameter of the underlying DBMS_LOB.NEWTEMPORARY() call.
    -- %return Instance of the phr_${largeTypeScalar} class.
    static function new_tmp_lob
        ( i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_${largeTypeScalar},
    -- Overload of {%link new_tmp_lob;1} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function new_tmp_lob
        ( i_cache                       in varchar2
        , i_duration                    in pls_integer default null )
        return phr_${largeTypeScalar},

    -- Factory returning a phr_${largeTypeScalar} instance initialized directly with an existing LOB locator.
    --
    -- %param i_value The input ${largeTypeScalarUpper} locator this object is to be initialized with.
    -- %return Instance of the phr_${largeTypeScalar} class initialized with the existing LOB locator.
    --
    -- %usage The object gets initialized with the supplied LOB locator (reference). There's no deep copying
    -- of I_VALUE contents involved, which means that all DBMS_LOB operations on the original locator will get
    -- reflected in this object's internal LOB locator and vice versa.
    static function use_lob
        ( i_value                       in ${largeTypeScalar} default null )
        return phr_${largeTypeScalar},

    -- Set the line terminator used by the {%link appendln} methods. The default terminator is LF.
    --
    -- %param i_eoln_sequence The line terminator. NULL makes appendln append no terminator.
    member procedure use_eoln
        ( i_eoln_sequence               in ${smallTypeScalar} ),
    -- Call {%link use_eoln} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function with_eoln
        ( i_eoln_sequence               in ${smallTypeScalar} )
        return phr_${largeTypeScalar},

    -- (Internal) Destroy/free the internal temporary ${largeTypeScalarUpper}.
    member procedure tmp_dispose,
    -- (Internal) Reinitialize the internal temporary ${largeTypeScalarUpper} with the previous operational
    -- flags of LOB caching and LOB duration.
    member procedure tmp_reinitialize,
    -- (Internal) Initialze the internal temporary ${largeTypeScalarUpper} with the supplied flags
    -- of LOB caching and LOB duration.
    member procedure tmp_initialize
        ( i_cache                       in boolean
        , i_duration                    in pls_integer default null ), -- dbms_lob.call will be used by default

    -- Length of the contained ${largeTypeScalarUpper}.
    -- %return dbms_lob.length of the contained ${largeTypeScalarUpper}, 0 (zero) for a NULL locator.
    member function length return integer,

    -- Is the contained LOB data of zero length, i.e., is the LOB empty (though not necessarily NULL)?
    member function is_empty return boolean,

    -- Call the {%link dbms_lob.trim} (if necessary) on the contained ${largeTypeScalarUpper}.
    -- %param i_length The target length of the contained ${largeTypeScalarUpper}.
    -- %usage Does nothing when the contained ${largeTypeScalarUpper} is not longer than I_LENGTH.
    member procedure trim
        ( i_length                      in integer default 0 ),
    -- Call the {%link trim;1} method and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function trim
        ( i_length                      in integer default 0 )
        return phr_${largeTypeScalar},

    -- The value of the contained ${largeTypeScalarUpper}.
    -- %return The actual value of the contained ${largeTypeScalarUpper}.
    -- The returned value is the actual LOB locator, not a deep copy.
    member function get_value
        return ${largeTypeScalar},

    -- Deep copy of the contained ${largeTypeScalarUpper} to another ${largeTypeScalarUpper}.
    member procedure copy_to
        ( io_dest                       in out nocopy ${largeTypeScalar}
        , i_dest_offset                 in integer default 0 ),

    -- Is the contained ${largeTypeScalarUpper} a temporary LOB or a persistent LOB?
    -- %return PL/SQL boolean
    -- {*} true for persistent LOB locators,
    -- {*} false for temporary LOB locators.
    member function is_persistent return boolean,
    -- Wrapper over {%link is_persistent} with {%link phr_utl_boolean "SQL-boolean"} data type return values.
    -- %return {%link phr_utl_boolean "SQL-boolean"}
    member function is_persistent$ return varchar2,

    -- Is the contained ${largeTypeScalarUpper} a securefile LOB?
    -- %return PL/SQL boolean
    -- {*} true for SecureFile LOB locators,
    -- {*} false for BasicFile (or temporary?) LOB locators.
    member function is_secure_file return boolean,
    -- Wrapper over {%link is_secure_file} with {%link phr_utl_boolean "SQL-boolean"} data type return values.
    -- %return {%link phr_utl_boolean "SQL-boolean"}
    member function is_secure_file$ return varchar2,

    -- Append method writes/appends a ${smallTypeScalar} value to the contained ${largeTypeScalarUpper}.
    --
    -- %param i_value The ${smallTypeScalar} value to be appended.
    member procedure append
        ( i_value                       in ${smallTypeScalar} ),

    member function append
        ( i_value                       in ${smallTypeScalar} )
        return phr_${largeTypeScalar},

    -- Append method writes/appends a ${largeTypeScalarUpper} value to the contained ${largeTypeScalarUpper}.
    --
    -- %param i_value The ${largeTypeScalarUpper} value to be appended.
    member procedure append
        ( i_value                       in ${largeTypeScalar} ),

    member function append
        ( i_value                       in ${largeTypeScalar} )
        return phr_${largeTypeScalar},

    -- Appends a ${smallTypeScalar} value followed by the line terminator (see {%link use_eoln}) to the contained ${largeTypeScalarUpper}.
    --
    -- %param i_value The ${smallTypeScalar} value to be appended. NULL appends the line terminator only.
    member procedure appendln
        ( i_value                       in ${smallTypeScalar} ),
    -- Call {%link appendln;1} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function appendln
        ( i_value                       in ${smallTypeScalar} )
        return phr_${largeTypeScalar},

    -- Appends a ${largeTypeScalarUpper} value followed by the line terminator (see {%link use_eoln}) to the contained ${largeTypeScalarUpper}.
    --
    -- %param i_value The ${largeTypeScalarUpper} value to be appended. NULL appends the line terminator only.
    member procedure appendln
        ( i_value                       in ${largeTypeScalar} ),
    -- Call {%link appendln;3} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function appendln
        ( i_value                       in ${largeTypeScalar} )
        return phr_${largeTypeScalar},

    -- Appends the line terminator (see {%link use_eoln}) only, i.e., an empty line.
    member procedure appendln,
    -- Call {%link appendln;5} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function appendln
        return phr_${largeTypeScalar},

    -- Compares the contents of the contained ${largeTypeScalarUpper} with the contents of the LOB
    -- contained within the supplied ${largeTypeScalarUpper}.
    --
    -- %param i_lob_2 An instance of the phr_${largeTypeScalar} the contained ${largeTypeScalarUpper} is to be compared to.
    -- %param i_two_nulls_are_equal Determines if two NULL LOB locators are considered to be equal.
    -- {*} true Two NULLs are considered as equal.
    -- {*} false (default) Two NULLs are considered as distinct.
    -- %param i_compare_lengths_first
    -- {*} true (default) Possibly speed up the LOBs comparison by comparing the LOBs lengths first.
    -- {*} false Do not use length-based comparison first, do contents-based comparison immediately.
    -- %return
    -- {*} 0 if the LOBs are, contents-wise, the same
    -- {*} -0.1 if the length of the contained LOB is less than the length of the supplied LOB,
    -- {*} +0.1 if the length of the contained LOB is greater than the length of the supplied LOB,
    -- {*} -1 if the contained LOB is contents-wise lower than the supplied LOB,
    -- {*} +1 if the contained LOB is contents-wise greater than the supplied LOB.
    --
    -- %usage Equivalent to dbms_lob.compare with some enhancements. When i_compare_lengths_first is
    -- set, then if the lengths are distinct, the LOBs are considered distinct immediately; if the
    -- lengths match, then a regular, contents-based comparison takes place. When exactly one of the two
    -- LOB locators is NULL, it is compared as an empty LOB, by length only. When I_LOB_2 itself is NULL, the result is NULL.
    member function compare
        ( i_lob_2                       in phr_${largeTypeScalar}
        , i_two_nulls_are_equal         in boolean default false
        , i_compare_lengths_first       in boolean default true )
        return number
        parallel_enable,

    -- Overload of {%link compare;1} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    member function compare
        ( i_lob_2                       in phr_${largeTypeScalar}
        , i_two_nulls_are_equal         in varchar2
        , i_compare_lengths_first       in varchar2 default 'Y' )
        return number
        parallel_enable,

    -- Compares the contents of the contained ${largeTypeScalarUpper} with the contents of the supplied ${largeTypeScalarUpper}.
    --
    -- %param i_lob_2 A ${largeTypeScalarUpper} value the contained ${largeTypeScalarUpper} is to be compared to.
    -- %param i_two_nulls_are_equal (See {%link compare;1}.)
    -- %param i_compare_lengths_first (See {%link compare;1}.)
    --
    -- %usage Overload of {%link compare;1} operating on a simple (non-object-encapsulated) ${largeTypeScalarUpper} input value.
    member function compare
        ( i_lob_2                       in ${largeTypeScalar}
        , i_two_nulls_are_equal         in boolean default false
        , i_compare_lengths_first       in boolean default true )
        return number
        parallel_enable,
    -- Overload of {%link compare;3} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    member function compare
        ( i_lob_2                       in ${largeTypeScalar}
        , i_two_nulls_are_equal         in varchar2
        , i_compare_lengths_first       in varchar2 default 'Y' )
        return number
        parallel_enable,

    -- Class' ORDER function for direct comparisons of LOB contents in SQL context.
    -- %param i_lob_2 (See {%link compare;1}.)
    -- %return (See {%link compare;1}.)
    order member function order$
        ( i_lob_2                       in phr_${largeTypeScalar} )
        return number
        parallel_enable,

    -- Get a substring of the contained ${largeTypeScalarUpper}.
    --
    -- %param i_from Offset (1-based) of the contained ${largeTypeScalarUpper} from which to get the substring.
    -- %param i_length Length of the desired substring. NULL, if you need the substring up to the ${largeTypeScalarUpper}'s contents.
    -- %return The part of the contained ${largeTypeScalarUpper} from offset I_FROM in the length of I_LENGTH.
    member function subStr
        ( i_from                        in integer
        , i_length                      in pls_integer default null )
        return ${smallTypeScalar}
        parallel_enable,

    -- Find the position (offset) of a I_NEEDLE within the contained ${largeTypeScalarUpper} haystack.
    --
    -- %param i_needle Substring ("needle") to find.
    -- %param i_offset Start searching for the needle at this haystack offset.
    -- %param i_occurrence Search for I_OCCURRENCE-th occurrence of the needle within the haystack.
    -- %return Offset within the haystack of the found needle or 0 (zero) if not found.
    member function inStr
        ( i_needle                      in ${smallTypeScalar}
        , i_offset                      in integer default 1
        , i_occurrence                  in simple_integer default 1 )
        return integer
        parallel_enable,

    -- Delete I_AMOUNT-long portion of contained ${largeTypeScalarUpper} starting from offset I_OFFSET
    -- and shift the trailing leftover to the former offset of the deleted ${largeTypeScalarUpper} portion,
    -- reducing the contained ${largeTypeScalarUpper} length by I_AMOUNT.
    --
    -- %param i_offset Starting (1-based) offset of the ${largeTypeScalarUpper} portion to be deleted.
    -- %param i_amount Number of ${largeTypeScalarUpper}'s to be deleted from the contained ${largeTypeScalarUpper} at offset I_OFFSET.
    --
    -- %usage Raises phr_utl_exc.CE_Invalid_Argument when I_OFFSET or I_AMOUNT is NULL, I_OFFSET is lower than 1 or I_AMOUNT is negative.
    member procedure fragment_delete
        ( i_offset                      in integer
        , i_amount                      in integer ),
    -- Call {%link fragment_delete;1} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function fragment_delete
        ( i_offset                      in integer
        , i_amount                      in integer )
        return phr_${largeTypeScalar},

    -- Delete portion of contained ${largeTypeScalarUpper} from offset I_FROM (inclusive) up to offset I_TO (inclusive)
    -- and shift the trailing leftover to the former offset of the deleted ${largeTypeScalarUpper} portion,
    -- reducing the contained ${largeTypeScalarUpper} length by I_TO-I_FROM+1.
    --
    -- %param i_from Starting (1-based) offset of the ${largeTypeScalarUpper} portion to be deleted.
    -- %param i_to Ending (1-based, inclusive) offset of the ${largeTypeScalarUpper} portion to be deleted.
    member procedure fragment_delete_between
        ( i_from                        in integer
        , i_to                          in integer ),
    -- Call {%link fragment_delete_between;1} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function fragment_delete_between
        ( i_from                        in integer
        , i_to                          in integer )
        return phr_${largeTypeScalar},

    -- Delete portion of contained ${largeTypeScalarUpper} from the first occurrence of needle I_FROM (inclusive)
    -- up to the first (subsequent) occurrence of needle I_TO (inclusive) and shift the trailing leftover
    -- to the former offset of the I_FROM needle, reducing the contained ${largeTypeScalarUpper} length
    -- by the length of the portion between the two needles.
    --
    -- %param i_from Starting (inclusive) needle of the ${largeTypeScalarUpper} portion to be deleted.
    -- %param i_to Ending (inclusive) needle of the ${largeTypeScalarUpper} portion to be deleted.
    -- %param i_max_iterations Repeat the deletion this number of times. (default: 1)
    member procedure fragment_delete_from_to
        ( i_from                        in ${smallTypeScalar}
        , i_to                          in ${smallTypeScalar} default null
        , i_max_iterations              in simple_integer default 1 ),
    member function fragment_delete_from_to
        ( i_from                        in ${smallTypeScalar}
        , i_to                          in ${smallTypeScalar} default null
        , i_max_iterations              in simple_integer default 1 )
        return phr_${largeTypeScalar}
)
not final
instantiable
;
/
create or replace type body phr_${largeTypeScalar}
is


static function new_tmp_lob
    ( i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_${largeTypeScalar}
is
    l_result                        phr_${largeTypeScalar};
begin
    l_result := new phr_${largeTypeScalar}(
        the_lob => null,
        tmp_lob_cached$ => case when i_cache then 1 else 0 end,
        tmp_lob_duration$ => i_duration,
        eoln$ => ${defaultEol}
    );

    l_result.tmp_initialize(
        i_cache => i_cache,
        i_duration => i_duration
    );

    return l_result;
end;


static function new_tmp_lob
    ( i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_${largeTypeScalar}
is
begin
    pragma inline(new_tmp_lob, 'YES');
    return phr_${largeTypeScalar}.new_tmp_lob(
        i_cache => $if $$pfcm_boolean
            $then is_true(i_cache)
            $else lower(i_cache) in ('y', 'yes', '1', 'true')
        $end,
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function use_lob
    ( i_value                       in ${largeTypeScalar} )
    return phr_${largeTypeScalar}
is
    l_result                        phr_${largeTypeScalar};
begin
    l_result := new phr_${largeTypeScalar}(
        the_lob => i_value,
        tmp_lob_cached$ => null,
        tmp_lob_duration$ => null,
        eoln$ => ${defaultEol}
    );

    return l_result;
end;


member procedure use_eoln
    ( i_eoln_sequence               in ${smallTypeScalar} )
is
begin
    self.eoln$ := i_eoln_sequence;
end;


member function with_eoln
    ( i_eoln_sequence               in ${smallTypeScalar} )
    return phr_${largeTypeScalar}
is
    l_result                        phr_${largeTypeScalar} := self;
begin
    pragma inline(use_eoln, 'YES');
    l_result.use_eoln(i_eoln_sequence);
    return l_result;
end;

----------------------------------------------------------------------------------------------------

member procedure tmp_dispose
is
begin
    if self.the_lob is not null then
        if dbms_lob.isTemporary(self.the_lob) = 1 then
            dbms_lob.freeTemporary(self.the_lob);
        end if;

        self.the_lob := null;
    end if;

    self.tmp_lob_cached$ := null;
    self.tmp_lob_duration$ := null;
end;


member procedure tmp_reinitialize
is
begin
    if self.tmp_lob_cached$ is null or self.tmp_lob_duration$ is null then
        raise_application_error(phr_utl_exc.CE_Invalid_Data_Type, $$plsql_unit||'.tmp_reinitialize(): Not a temporary LOB');
    else
        self.tmp_initialize(
            i_cache => self.tmp_lob_cached$ = 1,
            i_duration => self.tmp_lob_duration$
        );
    end if;
end;


member procedure tmp_initialize
    ( i_cache                       in boolean
    , i_duration                    in pls_integer )
is
begin
    self.tmp_dispose();

    self.tmp_lob_cached$ := case when i_cache then 1 else 0 end;
    self.tmp_lob_duration$ := nvl(i_duration, dbms_lob.CALL);

    dbms_lob.createTemporary(
        lob_loc => self.the_lob,
        cache => i_cache,
        dur => nvl(i_duration, dbms_lob.CALL)
    );
end;

----------------------------------------------------------------------------------------------------

member function length return integer
is
begin
    return nvl(${largeTypeLengthFunction}(self.the_lob), 0);
end;


member function is_empty return boolean
is
begin
    pragma inline(length, 'YES');
    return self.length() <= 0;
end;


member procedure trim
    ( i_length                      in integer )
is
begin
    pragma inline(length, 'YES');
    if i_length < self.length() then
        dbms_lob.trim(self.the_lob, i_length);
    end if;
end;


member function trim
    ( i_length                      in integer )
    return phr_${largeTypeScalar}
is
    l_result                        phr_${largeTypeScalar};
begin
    l_result := self;
    l_result.trim(i_length);
    return l_result;
end;


member function get_value return ${largeTypeScalar}
is
begin
    return self.the_lob;
end;


member procedure copy_to
    ( io_dest                       in out nocopy ${largeTypeScalar}
    , i_dest_offset                 in integer )
is
begin
    if self.the_lob is null or self.length() <= 0 then
        return;
    end if;

    dbms_lob.trim(
        lob_loc => io_dest,
        newlen => i_dest_offset + self.length()
    );

    dbms_lob.copy(
        dest_lob => io_dest,
        src_lob => self.the_lob,
        amount => self.length(),
        dest_offset => i_dest_offset
    );
end;


member function is_persistent return boolean
is
begin
    return dbms_lob.isTemporary(self.the_lob) != 1;
end;


member function is_persistent$ return varchar2
is
    l_result                        boolean := self.is_persistent();
begin
    $if $$pfcm_boolean $then
        return phr_utl_boolean.unify(l_result);
    $else
        return case l_result
            when true then 'Y'
            when false then 'N'
            else null
        end;
    $end
end;


member function is_secure_file return boolean
is
begin
    return dbms_lob.isSecureFile(self.the_lob);
end;


member function is_secure_file$ return varchar2
is
    l_result                        boolean := self.is_secure_file();
begin
    $if $$pfcm_boolean $then
        return phr_utl_boolean.unify(l_result);
    $else
        return case l_result
            when true then 'Y'
            when false then 'N'
            else null
        end;
    $end
end;

----------------------------------------------------------------------------------------------------

member procedure append
    ( i_value                       in ${smallTypeScalar} )
is
    l_value_length                  pls_integer;
begin
    if i_value is null then
        return;
    end if;

    l_value_length := ${smallTypeOverflowFunction}(i_value);
    dbms_lob.writeAppend(
        lob_loc => self.the_lob,
        amount => l_value_length,
        buffer => i_value
    );
end;


member function append
    ( i_value                       in ${smallTypeScalar} )
    return phr_${largeTypeScalar}
is
    l_new_lob                       phr_${largeTypeScalar} := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(i_value);
    return l_new_lob;
end;


member procedure append
    ( i_value                       in ${largeTypeScalar} )
is
    l_value_length                  integer;
    l_value_short                   ${smallTypeScalar}(${smallLargeSwitchThreshold});
begin
    if i_value is null then
        return;
    end if;

    l_value_length := ${largeTypeLengthFunction}(i_value);
    if l_value_length = 0 then
        return;
    end if;

    --
    if l_value_length <= ${smallLargeSwitchThreshold} then
        l_value_short := i_value;
        dbms_lob.writeAppend(
            lob_loc => self.the_lob,
            amount => l_value_length,
            buffer => l_value_short
        );
    else
        dbms_lob.append(
            dest_lob => self.the_lob,
            src_lob => i_value
        );
    end if;
end;


member function append
    ( i_value                       in ${largeTypeScalar} )
    return phr_${largeTypeScalar}
is
    l_new_lob                       phr_${largeTypeScalar} := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(i_value);
    return l_new_lob;
end;


member procedure appendln
    ( i_value                       in ${smallTypeScalar} )
is
begin
    self.append(i_value);
    self.append(self.eoln$);
end;


member function appendln
    ( i_value                       in ${smallTypeScalar} )
    return phr_${largeTypeScalar}
is
    l_new_lob                       phr_${largeTypeScalar} := self;
begin
    pragma inline(appendln, 'YES');
    l_new_lob.appendln(i_value);
    return l_new_lob;
end;


member procedure appendln
    ( i_value                       in ${largeTypeScalar} )
is
begin
    self.append(i_value);
    self.append(self.eoln$);
end;


member function appendln
    ( i_value                       in ${largeTypeScalar} )
    return phr_${largeTypeScalar}
is
    l_new_lob                       phr_${largeTypeScalar} := self;
begin
    pragma inline(appendln, 'YES');
    l_new_lob.appendln(i_value);
    return l_new_lob;
end;


member procedure appendln
is
begin
    self.append(self.eoln$);
end;


member function appendln
    return phr_${largeTypeScalar}
is
    l_new_lob                       phr_${largeTypeScalar} := self;
begin
    pragma inline(appendln, 'YES');
    l_new_lob.appendln();
    return l_new_lob;
end;

----------------------------------------------------------------------------------------------------

member function compare
    ( i_lob_2                       in phr_${largeTypeScalar}
    , i_two_nulls_are_equal         in boolean
    , i_compare_lengths_first       in boolean )
    return number
    parallel_enable
is
    l_result                        number;
    l_len_1                         integer;
    l_len_2                         integer;
    l_any_locator_is_null           boolean;
begin
    if i_lob_2 is null then
        return null;
    end if;

    l_any_locator_is_null := self.the_lob is null or i_lob_2.the_lob is null;

    if self.the_lob is null
        and i_lob_2.the_lob is null
    then
        if i_two_nulls_are_equal then
            return 0;
        else
            return null;
        end if;
    end if;

    -- dbms_lob.compare returns NULL for a NULL locator, so a NULL locator is compared as an empty LOB by length
    if i_compare_lengths_first or l_any_locator_is_null then
        l_len_1 := self.length();
        l_len_2 := i_lob_2.length();

        if l_len_1 < l_len_2 then
            return -0.1;
        elsif l_len_1 > l_len_2 then
            return 0.1;
        elsif l_any_locator_is_null then
            return 0;
        end if;
    end if;

    --
    l_result := dbms_lob.compare(
        lob_1 => self.get_value(),
        lob_2 => i_lob_2.get_value()
    );

    return l_result;
end;


member function compare
    ( i_lob_2                       in phr_${largeTypeScalar}
    , i_two_nulls_are_equal         in varchar2
    , i_compare_lengths_first       in varchar2 )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => i_lob_2,
        i_two_nulls_are_equal => $if $$pfcm_boolean
            $then is_true(i_two_nulls_are_equal)
            $else lower(i_two_nulls_are_equal) in ('y','yes','1','true')
        $end,
        i_compare_lengths_first => $if $$pfcm_boolean
            $then is_true(i_compare_lengths_first)
            $else lower(i_compare_lengths_first) in ('y','yes','1','true')
        $end
    );
end;


member function compare
    ( i_lob_2                       in ${largeTypeScalar}
    , i_two_nulls_are_equal         in boolean
    , i_compare_lengths_first       in boolean )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => phr_${largeTypeScalar}.use_lob(i_lob_2),
        i_two_nulls_are_equal => i_two_nulls_are_equal,
        i_compare_lengths_first => i_compare_lengths_first
    );
end;


member function compare
    ( i_lob_2                       in ${largeTypeScalar}
    , i_two_nulls_are_equal         in varchar2
    , i_compare_lengths_first       in varchar2 )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => phr_${largeTypeScalar}.use_lob(i_lob_2),
        i_two_nulls_are_equal => i_two_nulls_are_equal,
        i_compare_lengths_first => i_compare_lengths_first
    );
end;


order member function order$
    ( i_lob_2                       in phr_${largeTypeScalar} )
    return number
    parallel_enable
is
begin
    return self.compare(
        i_lob_2 => i_lob_2,
        i_two_nulls_are_equal => 'Y',
        i_compare_lengths_first => 'Y'
    );
end;

----------------------------------------------------------------------------------------------------

member function subStr
    ( i_from                        in integer
    , i_length                      in pls_integer )
    return ${smallTypeScalar}
    parallel_enable
is
begin
    if i_length is null then
        return dbms_lob.substr(
            lob_loc => self.get_value(),
            offset => i_from
        );
    else
        return dbms_lob.substr(
            lob_loc => self.get_value(),
            amount => i_length,
            offset => i_from
        );
    end if;
end;


member function inStr
    ( i_needle                      in ${smallTypeScalar}
    , i_offset                      in integer default 1
    , i_occurrence                  in simple_integer default 1 )
    return integer
is
begin
    return dbms_lob.instr(
        lob_loc => self.get_value(),
        pattern => i_needle,
        offset => i_offset,
        nth => i_occurrence
    );
end;

----------------------------------------------------------------------------------------------------

member procedure fragment_delete
    ( i_offset                      in integer
    , i_amount                      in integer )
is
    c_trailing_chunk_offset         constant integer := i_offset + i_amount;
    c_lob_length                    constant integer := self.length();
begin
    if i_offset is null then
        raise_application_error(phr_utl_exc.CE_Invalid_Argument, 'NULL I_OFFSET');
    elsif i_amount is null then
        raise_application_error(phr_utl_exc.CE_Invalid_Argument, 'NULL I_AMOUNT');
    elsif i_offset < 1 then
        raise_application_error(phr_utl_exc.CE_Invalid_Argument, 'Non-positive I_OFFSET of "'||i_offset||'"');
    elsif i_amount < 0 then
        raise_application_error(phr_utl_exc.CE_Invalid_Argument, 'Negative I_AMOUNT of "'||i_amount||'"');
    elsif i_amount = 0 then
        return;
    end if;

    $if utl_ident.is_oracle_server $then
        if self.is_secure_file() then
            dbms_lob.fragment_delete(
                lob_loc => self.the_lob,
                amount => i_amount,
                offset => i_offset
            );
            return;
        end if;
    $end

    if c_trailing_chunk_offset <= c_lob_length then
        dbms_lob.copy(
            src_lob => self.the_lob,
            src_offset => c_trailing_chunk_offset,
            dest_lob => self.the_lob,
            dest_offset => i_offset,
            amount => dbms_lob.LOBMAXSIZE
        );

        pragma inline(trim, 'YES');
        self.trim(c_lob_length - i_amount);
    else
        pragma inline(trim, 'YES');
        self.trim(i_offset - 1);
    end if;
end;


member function fragment_delete
    ( i_offset                      in integer
    , i_amount                      in integer )
    return phr_${largeTypeScalar}
is
    l_result                        phr_${largeTypeScalar} := self;
begin
    pragma inline(fragment_delete, 'YES');
    l_result.fragment_delete(
        i_offset => i_offset,
        i_amount => i_amount
    );
    return l_result;
end;


member procedure fragment_delete_between
    ( i_from                        in integer
    , i_to                          in integer )
is
begin
    pragma inline(fragment_delete, 'YES');
    self.fragment_delete(
        i_offset => i_from,
        i_amount => i_to - i_from + 1
    );
end;


member function fragment_delete_between
    ( i_from                        in integer
    , i_to                          in integer )
    return phr_${largeTypeScalar}
is
    l_result                        phr_${largeTypeScalar} := self;
begin
    pragma inline(fragment_delete_between, 'YES');
    l_result.fragment_delete_between(
        i_from => i_from,
        i_to => i_to
    );
    return l_result;
end;


member procedure fragment_delete_from_to
    ( i_from                        in ${smallTypeScalar}
    , i_to                          in ${smallTypeScalar}
    , i_max_iterations              in simple_integer default 1 )
is
    type rec_chunk_indices          is record (
        from_ix                         integer default 1,
        to_ix                           integer
    );
    l_chunk                         rec_chunk_indices;

    type arr_chunk_indices          is table of rec_chunk_indices index by simple_integer;
    l_chunks                        arr_chunk_indices;
begin
    for i in 1..i_max_iterations loop
        pragma inline(instr, 'YES');
        l_chunk.from_ix := self.instr(
            i_needle => i_from,
            i_offset => l_chunk.from_ix
        );
        exit when l_chunk.from_ix <= 0;

        if i_to is null then
            pragma inline(length, 'YES');
            l_chunk.to_ix := self.length();
        else
            pragma inline(instr, 'YES');
            l_chunk.to_ix := self.instr(
                i_needle => i_to,
                i_offset => l_chunk.from_ix
            );
            exit when l_chunk.to_ix <= 0;

            l_chunk.to_ix := l_chunk.to_ix + ${smallTypeLengthFunction}(i_to) - 1;
        end if;

        l_chunks(l_chunks.count+1) := l_chunk;

        l_chunk.from_ix := l_chunk.to_ix + 1;
        l_chunk.to_ix := null;
    end loop;

    for i in reverse 1..l_chunks.count loop
        pragma inline(fragment_delete_between, 'YES');
        self.fragment_delete_between(l_chunks(i).from_ix, l_chunks(i).to_ix);
    end loop;
end;


member function fragment_delete_from_to
    ( i_from                        in ${smallTypeScalar}
    , i_to                          in ${smallTypeScalar}
    , i_max_iterations              in simple_integer default 1 )
    return phr_${largeTypeScalar}
is
    l_result                        phr_${largeTypeScalar} := self;
begin
    pragma inline(fragment_delete_from_to, 'YES');
    l_result.fragment_delete_from_to(
        i_from => i_from,
        i_to => i_to,
        i_max_iterations => i_max_iterations
    );
    return l_result;
end;


end;
/
