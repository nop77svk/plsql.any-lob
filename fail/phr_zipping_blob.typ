create or replace type phr_zipping_blob
as
object
(
    ------------------------------------------------------------------------------------------------
    -- %project "Peter's PLSQL foundation"
    -- %framework LOB builders
    ------------------------------------------------------------------------------------------------
    -- Object-encapsulated BLOB abstraction
    -- %author Peter Hrasko
    -- %email peter.hrasko.sk@gmail.com
    -- %web http://peterhrasko.wordpress.com/peters-plsql-foundation/lob-builders
    ------------------------------------------------------------------------------------------------

    the_value$                      blob,

    buffering_level$                number(1,0),
    primary_buffer$                 raw(32767),
    secondary_buffer$               blob,
    secondary_buffer_size$          integer,

    tmp_lob_cached$                 number(1,0),
    tmp_lob_duration$               integer,
    
    raw_conversion_charset$         varchar2(32),

    gzip_streamer_handle$           integer,
    compression_quality             number(1),
    uncompressed_length             integer,

    -- Factory returning phr_zipping_blob instance initialized with new, empty temporary BLOB.
    --
    -- %param i_cache The value passed to the CACHE parameter of the underlying DBMS_LOB.NEWTEMPORARY() call.
    -- %param i_duration The value passed to the DURATION parameter of the underlying DBMS_LOB.NEWTEMPORARY() call.
    -- %return Instance of the phr_zipping_blob class.
    static function new_tmp_lob
        ( i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,
    -- Overload of {%link new_tmp_lob;1} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function new_tmp_lob
        ( i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,

    -- (Internal) Change the level of buffering and call .fsync() if lowering
    member procedure aux_change_buffering_level$
        ( i_target_level                in integer ),
    member procedure aux_init_secondary_buffer$,

    -- Switch off write buffering.
    member procedure use_nonbuffered_writes,
    -- Switch on double buffering.
    member procedure use_double_buffering,
    -- Switch on tripple buffering.
    member procedure use_tripple_buffering
        ( i_buffer_size                 in integer default 1048576 ),

    -- Builder returning phr_zipping_blob instance with buffering switched off.
    member function nonbuffered
        return phr_zipping_blob,
    -- Builder returning phr_zipping_blob instance with double buffering switched on.
    member function double_buffered
        return phr_zipping_blob,
    -- Builder returning phr_zipping_blob instance with tripple buffering switched on.
    member function tripple_buffered
        ( i_buffer_size                 in integer default 1048576 )
        return phr_zipping_blob,

    -- Factory returning phr_zipping_blob instance initialized to new temporary BLOB
    -- with raw value from I_VALUE.
    --
    -- %param i_value Initial value to be appended to the new temporary BLOB.
    -- %param i_cache See the {%link new_tmp_lob;1} factory.
    -- %param i_duration See the {%link new_tmp_lob;1} factory.
    -- %return Instance of the phr_zipping_blob class initialized with the value I_VALUE.
    static function init_tmp_lob
        ( i_value                       in raw
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,
    -- Overload of {%link init_tmp_lob;1} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function init_tmp_lob
        ( i_value                       in raw
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,

    -- Factory returning phr_zipping_blob instance initialized to new temporary BLOB
    -- with blob value from I_VALUE.
    --
    -- %usage Deep copy of BLOB contents.
    static function init_tmp_lob
        ( i_value                       in blob
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,
    -- Overload of {%link init_tmp_lob;3} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function init_tmp_lob
        ( i_value                       in blob
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,

    -- Factory returning phr_zipping_blob instance initialized to new temporary BLOB
    -- with the value of phr_zipping_blob instance passed within I_VALUE.
    --
    -- %usage Deep copy of phr_zipping_blob contents.
    static function init_tmp_lob
        ( i_value                       in phr_zipping_blob
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,
    -- Overload of {%link init_tmp_lob;5} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function init_tmp_lob
        ( i_value                       in phr_zipping_blob
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,

    -- Factory returning phr_zipping_blob instance initialized to new temporary BLOB
    -- and set up with the concatenated values of arr_raw_4000 I_VALUES delimited by I_DELIMITER.
    --
    -- %param i_values Collection of raw elements to be concatenated.
    -- %param i_delimiter (Optional) raw delimiter for concatenation of elements in I_VALUES.
    -- %param i_cache See the {%link new_tmp_lob;1} factory.
    -- %param i_duration See the {%link new_tmp_lob;1} factory.
    -- %return Instance of the phr_zipping_blob class initialized with the concatenation of values from I_VALUES, delimited by I_DELIMITER.
    --
    -- %usage Concatenation of, possibly delimited, raw values into one blob
    -- in a functional way, without any boilerplate collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    static function init_tmp_lob
        ( i_values                      in arr_raw_4000
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,
    -- Overload of {%link init_tmp_lob;7} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function init_tmp_lob
        ( i_values                      in arr_raw_4000
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,

    -- Factory returning phr_zipping_blob instance initialized to new temporary BLOB
    -- and set up with the concatenated values of arr_blob I_VALUES delimited by I_DELIMITER.
    -- (Refer to {%link init_tmp_lob;7} overload for detailed explanation.)
    static function init_tmp_lob
        ( i_values                      in arr_blob
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,
    -- Overload of {%link init_tmp_lob;9} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function init_tmp_lob
        ( i_values                      in arr_blob
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,

    -- Factory returning phr_zipping_blob instance initialized to new temporary BLOB
    -- and set up with the concatenated values of raw/blob values from a 1-column ref cursor,
    -- delimited by I_DELIMITER.
    --
    -- %param i_values Single-column ref cursor of either raw or blob values to be concatenated.
    -- %param i_delimiter (Optional) raw delimiter for concatenation of elements in I_VALUES.
    -- %param i_batch_size (Technical, performance-related) Bulk-fetch buffer size.
    -- %param i_fetch_to_lobs (Technical, performance-related) Determines whether the I_VALUES cursor should be fetched to arr_raw_4000 or arr_blob buffer internally.
    -- %param i_cache See the {%link new_tmp_lob;1} factory.
    -- %param i_duration See the {%link new_tmp_lob;1} factory.
    -- %return Instance of the phr_zipping_blob class initialized with the concatenation of column values from I_VALUES cursor, delimited by I_DELIMITER.
    --
    -- %usage Concatenation of, possibly delimited, raw/blob values into one blob
    -- in a functional way, without any boilerplate collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    static function init_tmp_lob
        ( i_values                      in sys_refcursor
        , i_delimiter                   in raw default null
        , i_batch_size                  in pls_integer default 100
        , i_fetch_to_lobs               in boolean default true
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,
    -- Overload of {%link init_tmp_lob;11} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    static function init_tmp_lob
        ( i_values                      in sys_refcursor
        , i_delimiter                   in raw default null
        , i_batch_size                  in pls_integer default 100
        , i_fetch_to_lobs               in varchar2 default 'Y'
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_zipping_blob,

    -- Factory returning phr_zipping_blob instance initialized directly with an existing LOB locator.
    --
    -- %param i_value The input BLOB locator this object is to be initialized with.
    -- %return Instance of the phr_zipping_blob class initialized with the existing LOB locator.
    --
    -- %usage The object gets initialized with the supplied LOB locator (reference). There's no deep copying
    -- of I_VALUE contents involved, which means that all DBMS_LOB operations on the original locator will get
    -- (somehow) reflected in this object's internal LOB locator and vice versa. Please be aware that
    -- the buffered writes implies that intertwining of writes/appends to the LOB will most probably result
    -- in different actual order of appended/written values than the order of the appendings in the code.
    -- Due to this, use either the phr_zipping_blob.append methods or the dbms_lob.writeAppend/dbms_lob.append
    -- procedures but, ideally, not both over the same LOB locator.
    static function use_lob
        ( i_value                       in blob default null )
        return phr_zipping_blob,

    -- (Internal) Destroy/free the internal temporary BLOB.
    member procedure tmp_dispose,
    -- (Internal) Reinitialize the internal temporary BLOB with the previous operational
    -- flags of write buffering, LOB caching and LOB duration.
    member procedure tmp_reinitialize,
    -- (Internal) Initialze the internal temporary BLOB with the supplied flags
    -- of LOB caching and LOB duration.
    member procedure tmp_initialize
        ( i_cache                       in boolean
        , i_duration                    in pls_integer default null ), -- dbms_lob.call will be used by default

    -- (Internal) Flush primary buffer, if any buffering is in effect.
    member procedure aux_fsync_primary_buffer$,
    -- (Internal) Flush secondary buffer, if tripple buffering is in effect.
    member procedure aux_fsync_secondary_buffer$,

    -- In case of internal write buffering being in effect, this method appends (flushes) the internal
    -- write buffers to the actual BLOB (and clears the buffers).
    -- %usage Use this to ensure, for whatever reason, that any pending raw appends
    -- (in the internal buffers) get really written to the contained blob structure.
    member procedure fsync,
    -- Execute an fsync and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function fsync
        return phr_zipping_blob,

    -- Length of the contained BLOB.
    -- %return dbms_lob.length of the contained blob with the length of the pending appends included.
    member function length return integer,

    -- Call the {%link dbms_lob.trim} (if necessary) on the contained BLOB.
    -- %param i_length The target length the contained BLOB.
    -- %usage As oppposed to the dbms_lob.trim, this takes care of any pending appends (internal write buffering) as well.
    member procedure trim
        ( i_length                      in integer default 0 ),
    -- Call the {%link trim;1} method and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function trim
        ( i_length                      in integer default 0 )
        return phr_zipping_blob,

    -- The value of the contained blob.
    -- %return The actual value of the contained blob with any pending appends included.
    -- The returned value is the actual LOB locator, not a deep copy.
    member function get_value
        return blob,
    -- Deep copy of the contained blob to another blob.
    -- %usage As oppposed to the dbms_lob.copy, this takes care of any pending appends (internal write buffering) as well.
    member procedure copy_to
        ( io_dest                       in out nocopy blob
        , i_dest_offset                 in integer default 0 ),

    -- Is the contained BLOB a temporary LOB or a persistent LOB?
    -- %return PL/SQL boolean
    -- {*} true for persistent LOB locators,
    -- {*} false for temporary LOB locators.
    member function is_persistent return boolean,
    -- Wrapper over {%link is_persistent} with {%link phr_utl_boolean "SQL-boolean"} data type return values.
    -- %return {%link phr_utl_boolean "SQL-boolean"}
    member function is_persistent$ return varchar2,

    -- (Internal) Append a raw to either the contained blob or to the internal
    -- write buffers when write buffering is in effect.
    member procedure aux_append_small$
        ( i_value                       in raw ),

    -- Append method writes/appends (arbitrary number of times) a raw value to the
    -- contained blob, possibly not immediately if the write buffering is in effect.
    --
    -- %param i_value The raw value to be appended.
    -- %param i_repeat The number of times the I_VALUE is to be appended.
    -- %param i_delimiter The ${smallTypeScaler} delimiter to be used when I_REPEAT is greater than 1.
    member procedure append
        ( i_value                       in raw
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null ),
    -- Append method writes/appends (arbitrary number of times) a blob value to the
    -- contained blob, possibly not immediately if the write buffering is in effect.
    --
    -- %param i_value The blob value to be appended.
    -- %param i_repeat See {%link append;1}.
    -- %param i_delimiter See {%link append;1}.
    member procedure append
        ( i_value                       in blob
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null ),
    -- Append method writes/appends (arbitrary number of times) the LOB contents from the supplied
    -- phr_zipping_blob to the contained blob, possibly not immediately if
    -- the write buffering is in effect.
    --
    -- %param i_value The phr_zipping_blob instance the LOB contens of are to be appended.
    -- %param i_repeat See {%link append;1}.
    -- %param i_delimiter See {%link append;1}.
    member procedure append
        ( i_value                       in phr_zipping_blob
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null ),
    -- Append method writes/appends the concatenation of values from arr_raw_4000, delimited
    -- by a raw delimiter.
    --
    -- %param i_values arr_raw_4000 to be concatenated and appended.
    -- %param i_delimiter (Optional) raw delimiter for concatenation of elements from I_VALUES.
    --
    -- %usage Concatenation of, possibly delimited, raw values into one blob
    -- in a functional way, without any boilerplate collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    member procedure append
        ( i_values                      in arr_raw_4000
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null ),
    -- Append method writes/appends the concatenation of values from arr_blob, delimited
    -- by a raw delimiter.
    --
    -- %param i_values arr_blob to be concatenated and appended.
    -- %param i_delimiter (Optional) raw delimiter for concatenation of elements from I_VALUES.
    --
    -- %usage Concatenation of, possibly delimited, blob values into one blob
    -- in a functional way, without any boilerplate collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    member procedure append
        ( i_values                      in arr_blob
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null ),
    -- Append method writes/appends the concatenation of values from the supplied single-column ref cursor
    -- returning either raw or blob, delimited by a raw delimiter.
    --
    -- %param i_values Single-column ref cursor returning the raw/blob values to be concatenated and appended.
    -- %param i_delimiter (Optional) raw delimiter for concatenation of elements from the ref cursor.
    -- %param i_batch_size (Technical, performance-related) Bulk-fetch buffer size.
    -- %param i_fetch_to_lobs (Technical, performance-related) Determines whether the I_VALUES cursor should be fetched to arr_raw_4000 or to arr_blob buffer internally.
    --
    -- %usage Concatenation of, possibly delimited, raw/blob values into one blob
    -- in a functional way, without any boilerplate collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    member procedure append
        ( i_values                      in sys_refcursor
        , i_delimiter                   in raw default null
        , i_batch_size                  in pls_integer default 100
        , i_fetch_to_lobs               in boolean default true
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null ),

    -- Call the {%link append;1} method for raw and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function append
        ( i_value                       in raw
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,
    -- Call the {%link append;2} method for blob and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function append
        ( i_value                       in blob
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,
    -- Call the {%link append;3} method for phr_zipping_blob and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function append
        ( i_value                       in phr_zipping_blob
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in raw default null )
        return phr_zipping_blob,
    -- Call the {%link append;4} method for arr_raw_4000 and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function append
        ( i_values                      in arr_raw_4000
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null )
        return phr_zipping_blob,
    -- Call the {%link append;5} method for arr_blob and return SELF.
    -- %usage Useful for method chaining. Not that useful in SQL context, as Oracle (as of version 12.2)
    -- does no support the COLLECT() aggregator to a collection of BLOBs.
    member function append
        ( i_values                      in arr_blob
        , i_delimiter                   in raw default null
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null )
        return phr_zipping_blob,
    -- Call the {%link append;6} method with ref cursor and return SELF.
    -- %usage Useful for method chaining. Unusable in SQL context due to PL/SQL boolean parameters in use. (See the next overload.)
    member function append
        ( i_values                      in sys_refcursor
        , i_delimiter                   in raw default null
        , i_batch_size                  in pls_integer default 100
        , i_fetch_to_lobs               in boolean default true
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null )
        return phr_zipping_blob,
    -- Call the {%link append;7} method with ref cursor and return SELF.
    -- %usage Useful for method chaining. Extremely useful in SQL context!
    member function append
        ( i_values                      in sys_refcursor
        , i_delimiter                   in raw default null
        , i_batch_size                  in pls_integer default 100
        , i_fetch_to_lobs               in varchar2
        , i_value_prefix                in raw default null
        , i_value_suffix                in raw default null )
        return phr_zipping_blob,

    -- Compares the contents of the contained blob with the contents of the LOB
    -- contained within the supplied blob.
    --
    -- %param i_lob_2 Instance of the phr_zipping_blob the contained blob is to be compared to.
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
    -- {*} integer (nonnegative) X when there's a difference on the contents offset X (1-based) between
    -- the the contained LOB and the supplied LOB.
    --
    -- %usage Equivalent to dbms_lob.compare with some enhancements. When i_compare_lengths_first is
    -- set, then if the lengths are distinct, the LOBs are considered distinct immediately; if the
    -- lengths match, then a regular, contents-based comparison takes place.
    member function compare
        ( i_lob_2                       in phr_zipping_blob
        , i_two_nulls_are_equal         in boolean default false
        , i_compare_lengths_first       in boolean default true )
        return number
        parallel_enable,
    -- Overload of {%link compare;1} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    member function compare
        ( i_lob_2                       in phr_zipping_blob
        , i_two_nulls_are_equal         in varchar2
        , i_compare_lengths_first       in varchar2 default 'Y' )
        return number
        parallel_enable,
    -- Compares the contents of the contained blob with the contents of the supplied blob.
    --
    -- %param i_lob_2 A blob value the contained blob is to be compared to.
    -- %param i_two_nulls_are_equal (See {%link compare;1}.)
    -- %param i_compare_lengths_first (See {%link compare;1}.)
    --
    -- %usage Overload of {%link compare;1} operating on a simple (non-object-encapsulated) blob input value.
    member function compare
        ( i_lob_2                       in blob
        , i_two_nulls_are_equal         in boolean default false
        , i_compare_lengths_first       in boolean default true )
        return number
        parallel_enable,
    -- Overload of {%link compare;3} with {%link phr_utl_boolean "SQL-boolean"} data type input flags.
    member function compare
        ( i_lob_2                       in blob
        , i_two_nulls_are_equal         in varchar2
        , i_compare_lengths_first       in varchar2 default 'Y' )
        return number
        parallel_enable,
    -- Class' ORDER function for direct comparisons of LOB contents in SQL context.
    -- %param i_lob_2 (See {%link compare;1}.)
    -- %return (See {%link compare;1}.)
    order member function order$
        ( i_lob_2                       in phr_zipping_blob )
        return number
        parallel_enable,

    -- Get a substring of the contained blob.
    --
    -- %param i_from Offset (1-based) of the contained blob from which to get the substring.
    -- %param i_length Length of the desired substring. NULL, if you need the substring up to the blob's contents.
    -- %return The part of the contained blob from offset I_FROM in the length of I_LENGHT.
    --
    -- %usage As oppposed to the dbms_lob.substr, this takes care of any pending appends (internal write buffering) as well.
    member function subStr
        ( i_from                        in pls_integer
        , i_length                      in pls_integer default null )
        return raw
        parallel_enable,

    -- Provide this phr_zipping_blob instance with a character set for appends/writes
    -- of varchar2 values with charset autoconversion in effect.
    -- %param i_charset The Oracle character set string to be used for subsequent varchar2 autoconversions.
    member procedure set_raw_conversion_charset
        ( i_charset                     in varchar2 ),
    -- Call {%link set_raw_conversion_charset;1} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function with_raw_conversion_charset
        ( i_charset                     in varchar2 )
        return phr_zipping_blob,

    -- Append a varchar2 (auto-converted to raw via preset conversion
    -- charset) value to the contained blob.
    --
    -- %param i_value A varchar2 value to be converted via preset conversin charset and appended to the contained blob.
    -- %param i_repeat (See {%link append;1}.)
    -- %param i_delimiter (See {%link append;1}.)
    --
    -- %usage This allows a developer to reduce some amount of boilerplate code when operating over
    -- varchar2 values being appended to BLOBs with a specific
    -- character set.
    member procedure append_varchar2
        ( i_value                       in varchar2
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in varchar2 default null ),
    -- Call {%link append_varchar2;1} and return SELF.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function append_varchar2
        ( i_value                       in varchar2
        , i_repeat                      in pls_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_zipping_blob
)
not final
instantiable
not persistable
;
/
create or replace type body phr_zipping_blob
is


static function new_tmp_lob
    ( i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new phr_zipping_blob(
        the_value$ => null,
        buffering_level$ => 1, -- note: there's always only the double buffering possible
        primary_buffer$ => null,
        secondary_buffer$ => null,
        secondary_buffer_size$ => null,
        tmp_lob_cached$ => case when i_cache then 1 else 0 end,
        tmp_lob_duration$ => i_duration,
        raw_conversion_charset$ => null,
        gzip_streamer_handle$ => null,
        compression_quality => 9, -- 2do!
        uncompressed_length => null
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
    return phr_zipping_blob
is
begin
    pragma inline(new_tmp_lob, 'YES');
    return phr_zipping_blob.new_tmp_lob(
        i_cache => is_true(i_cache),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_value                       in raw
    , i_cache                       in boolean
    , i_duration                    in pls_integer
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration
    );

    if i_value is not null then
        pragma inline(append, 'YES');
        l_result.append(
            i_value => i_value,
            i_repeat => i_repeat,
            i_delimiter => i_delimiter
        );
    end if;

    return l_result;
end;


static function init_tmp_lob
    ( i_value                       in raw
    , i_cache                       in varchar2
    , i_duration                    in pls_integer
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_value => i_value,
        i_cache => is_true(i_cache),
        i_duration => i_duration,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_value                       in blob
    , i_cache                       in boolean
    , i_duration                    in pls_integer
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration
    );
    pragma inline(append, 'YES');
    l_result.append(
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
    return l_result;
end;


static function init_tmp_lob
    ( i_value                       in blob
    , i_cache                       in varchar2
    , i_duration                    in pls_integer
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_value => i_value,
        i_cache => is_true(i_cache),
        i_duration => i_duration,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_value                       in phr_zipping_blob
    , i_cache                       in boolean
    , i_duration                    in pls_integer
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration
    );
    pragma inline(append, 'YES');
    l_result.append(
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
    return l_result;
end;


static function init_tmp_lob
    ( i_value                       in phr_zipping_blob
    , i_cache                       in varchar2
    , i_duration                    in pls_integer
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_value => i_value,
        i_cache => is_true(i_cache),
        i_duration => i_duration,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_values                      in arr_raw_4000
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw
    , i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration
    );

    pragma inline(append, 'YES');
    l_result.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );

    return l_result;
end;


static function init_tmp_lob
    ( i_values                      in arr_raw_4000
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw
    , i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_zipping_blob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix,
        i_cache => is_true(i_cache),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_values                      in arr_blob
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw
    , i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration
    );
    pragma inline(append, 'YES');
    l_result.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );
    return l_result;
end;


static function init_tmp_lob
    ( i_values                      in arr_blob
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw
    , i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_zipping_blob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix,
        i_cache => is_true(i_cache),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_values                      in sys_refcursor
    , i_delimiter                   in raw
    , i_batch_size                  in pls_integer
    , i_fetch_to_lobs               in boolean
    , i_value_prefix                in raw
    , i_value_suffix                in raw
    , i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration
    );
    pragma inline(append, 'YES');
    l_result.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_batch_size => i_batch_size,
        i_fetch_to_lobs => i_fetch_to_lobs,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );
    return l_result;
end;


static function init_tmp_lob
    ( i_values                      in sys_refcursor
    , i_delimiter                   in raw
    , i_batch_size                  in pls_integer
    , i_fetch_to_lobs               in varchar2
    , i_value_prefix                in raw
    , i_value_suffix                in raw
    , i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_zipping_blob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_batch_size => i_batch_size,
        i_fetch_to_lobs => is_true(i_fetch_to_lobs),
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix,
        i_cache => is_true(i_cache),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function use_lob
    ( i_value                       in blob )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob;
begin
    l_result := new phr_zipping_blob(
        the_value$ => i_value,
        buffering_level$ => 1, -- note: there's always only the double buffering possible
        primary_buffer$ => null,
        secondary_buffer$ => null,
        secondary_buffer_size$ => null,
        tmp_lob_cached$ => null,
        tmp_lob_duration$ => null,
        raw_conversion_charset$ => null,
        gzip_streamer_handle$ => null,
        compression_quality => 9, -- 2do!
        uncompressed_length => null
    );

    return l_result;
end;

----------------------------------------------------------------------------------------------------
-- Buffering-related method

member procedure aux_init_secondary_buffer$
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'Tripple buffering cannot be in effect in '||$$plsql_unit);
end;


member procedure aux_change_buffering_level$
    ( i_target_level                in integer )
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'Cannot change buffering level in '||$$plsql_unit||' as double buffering is automatically in effect');
end;


member procedure use_nonbuffered_writes
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'Double-buffering is automatically in effect in '||$$plsql_unit);
end;


member function nonbuffered
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob := self;
begin
    l_result.use_nonbuffered_writes();
    return l_result;
end;


member procedure use_double_buffering
is
begin
    null;
end;


member function double_buffered
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob := self;
begin
    pragma inline(use_double_buffering, 'YES');
    l_result.use_double_buffering();
    return l_result;
end;


member procedure use_tripple_buffering
    ( i_buffer_size                 in integer )
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'Tripple buffering cannot be in effect in '||$$plsql_unit);
end;


member function tripple_buffered
    ( i_buffer_size                 in integer )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob := self;
begin
    l_result.use_tripple_buffering(i_buffer_size);
    return l_result;
end;

----------------------------------------------------------------------------------------------------

member procedure tmp_dispose
is
    l_gzip_ctx                      phr_utl_gzip_streamer.rec_context;
begin
    if self.gzip_streamer_handle$ > 0 then
        phr_utl_gzip_streamer.finalize(
            i_handle => self.gzip_streamer_handle$,
            o_ctx => l_gzip_ctx
        );
    end if;
    self.gzip_streamer_handle$ := null; 

    if self.the_value$ is not null then
        if dbms_lob.isTemporary(self.the_value$) = 1 then
            dbms_lob.freeTemporary(self.the_value$);
        end if;

        self.the_value$ := null;
    end if;

    self.primary_buffer$ := null;

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
    E_Invalid_Compress_Handle       exception;
        pragma exception_init(E_Invalid_Compress_Handle, -29299);
begin
    self.tmp_dispose();

    self.tmp_lob_cached$ := case when i_cache then 1 else 0 end;
    self.tmp_lob_duration$ := nvl(i_duration, dbms_lob.call);

/*
    dbms_lob.createTemporary(
        lob_loc => self.the_value$,
        cache => i_cache,
        dur => nvl(i_duration, dbms_lob.call)
    );
    self.primary_buffer$ := null;
*/
    self.gzip_streamer_handle$ := phr_utl_gzip_streamer.new_context(
        i_varchar2_conv_charset => self.raw_conversion_charset$,
--        i_lob => self.the_value$,
        i_compression_quality => self.compression_quality
    );
end;

----------------------------------------------------------------------------------------------------

member procedure aux_fsync_primary_buffer$
is
begin
    null;
end;


member procedure aux_fsync_secondary_buffer$
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'Tripple buffering cannot be in effect in '||$$plsql_unit);
end;


member procedure fsync
is
     l_gzip_ctx                      phr_utl_gzip_streamer.rec_context;
begin
    dbms_output.put_line('--- fsync on handle "'||self.gzip_streamer_handle$||'"');

    if self.gzip_streamer_handle$ > 0 then
        phr_utl_gzip_streamer.finalize(
            i_handle => self.gzip_streamer_handle$,
            o_ctx => l_gzip_ctx
        );
        dbms_output.put_line('Uncompressed length = "'||l_gzip_ctx.uncompressed_length||'"');
        dbms_output.put_line('Compressed length = "'||dbms_lob.getLength(l_gzip_ctx.the_value)||'"');

        self.the_value$ := l_gzip_ctx.the_value;
        self.uncompressed_length := l_gzip_ctx.uncompressed_length;
        self.gzip_streamer_handle$ := -1;
    end if;
end;


member function fsync
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob := self;
begin
    l_result.fsync();
    return l_result;
end;

----------------------------------------------------------------------------------------------------

member function length return integer
is
begin
    return dbms_lob.getLength(self.the_value$)
        + case when self.buffering_level$ >= 1 then nvl(utl_raw.length(self.primary_buffer$),0) end
        + case when self.buffering_level$ >= 2 then nvl(dbms_lob.getLength(self.secondary_buffer$), 0) end;
end;


member procedure trim
    ( i_length                      in integer )
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'TRIM() cannot be used in '||$$plsql_unit);
end;


member function trim
    ( i_length                      in integer )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob := self;
begin
    l_result.trim(i_length);
    return l_result;
end;


member function get_value return blob
is
begin
    return self.fsync().the_value$;
end;


member procedure copy_to
    ( io_dest                       in out nocopy blob
    , i_dest_offset                 in integer )
is
begin
    if self.the_value$ is null or self.length() <= 0 then
        return;
    end if;

    dbms_lob.trim(
        lob_loc => io_dest,
        newlen => i_dest_offset + self.length()
    );

    dbms_lob.copy(
        dest_lob => io_dest,
        src_lob => self.get_value(),
        amount => self.length(),
        dest_offset => i_dest_offset
    );
end;


member function is_persistent$ return varchar2
is
begin
    return phr_utl_boolean.unify(self.is_persistent());
end;


member function is_persistent return boolean
is
begin
    return dbms_lob.isTemporary(self.the_value$) != 1;
end;

----------------------------------------------------------------------------------------------------

member procedure aux_append_small$
    ( i_value                       in raw )
is
begin
    if i_value is null then
        return;
    end if;
    
    phr_utl_gzip_streamer.append_raw(
        i_handle => self.gzip_streamer_handle$,
        i_value => i_value
    );
end;

----------------------------------------------------------------------------------------------------

member procedure append
    ( i_value                       in raw
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
is
begin
    if i_value is null or i_repeat is null or i_repeat < 1 then
        return;
    end if;
    
    phr_utl_gzip_streamer.append_raw(
        i_handle => self.gzip_streamer_handle$,
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;


member procedure append
    ( i_value                       in blob
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
is
    l_value_length                  integer := dbms_lob.getLength(i_value);
begin
    if i_value is null or i_repeat is null or i_repeat < 1 or l_value_length <= 0 then
        return;
    end if;

    if l_value_length <= 32767 then
        phr_utl_gzip_streamer.append_raw(
            i_handle => self.gzip_streamer_handle$,
            i_value => i_value,
            i_repeat => i_repeat,
            i_delimiter => i_delimiter
        );
    else
        for i in 1..i_repeat loop
            if i > 1 then
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => i_delimiter
                );
            end if;

            for j in 1..ceil(l_value_length/32767) loop
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => dbms_lob.substr(
                        lob_loc => i_value,
                        amount => 32767,
                        offset => (j-1)*32767+1
                    )
                );
            end loop;
        end loop;
    end if;
end;


member procedure append
    ( i_value                       in phr_zipping_blob
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'Appending another '||$$plsql_unit||' is not possible');
end;


member procedure append
    ( i_values                      in arr_raw_4000
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw )
is
--    l_delimiter_length              pls_integer;
    i                               pls_integer;
begin
--    l_delimiter_length := utl_raw.length(i_delimiter);

    if i_values is not null then
        i := i_values.first();
        while i is not null loop
            if i_delimiter is not null and i > i_values.first() then
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => i_delimiter
                );
            end if;
            
            if i_value_prefix is not null then
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => i_value_prefix
                );
            end if;

            phr_utl_gzip_streamer.append_raw(
                i_handle => self.gzip_streamer_handle$,
                i_value => i_values(i)
            );
            
            if i_value_suffix is not null then
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => i_value_suffix
                );
            end if;

            i := i_values.next(i);
        end loop;
    end if;
end;


member procedure append
    ( i_values                      in arr_blob
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw )
is
    i                               pls_integer;
begin
    if i_values is not null then
        i := i_values.first();
        while i is not null loop
            if i_delimiter is not null and i > i_values.first() then
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => i_delimiter
                );
            end if;

            if i_value_prefix is not null then
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => i_value_prefix
                );
            end if;

            pragma inline(append, 'YES');
            self.append(i_values(i));

            if i_value_suffix is not null then
                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => i_value_suffix
                );
            end if;

            i := i_values.next(i);
        end loop;
    end if;
end;


member procedure append
    ( i_values                      in sys_refcursor
    , i_delimiter                   in raw
    , i_batch_size                  in pls_integer
    , i_fetch_to_lobs               in boolean
    , i_value_prefix                in raw
    , i_value_suffix                in raw )
is
    type arr_values_lob             is table of blob index by pls_integer;
    l_values_lob                    arr_values_lob;
    type arr_values_small           is table of raw(4000) index by pls_integer;
    l_values_small                  arr_values_small;

    i                               pls_integer;
    l_is_first_row                  boolean := true;
begin
    loop
        if i_fetch_to_lobs then
            fetch i_values
                bulk collect into l_values_lob
                limit i_batch_size;
            exit when l_values_lob.count() <= 0;

            for i in 1..l_values_lob.last() loop
                if i_delimiter is not null and not l_is_first_row then
                    phr_utl_gzip_streamer.append_raw(
                        i_handle => self.gzip_streamer_handle$,
                        i_value => i_delimiter
                    );
                else
                    l_is_first_row := false;
                end if;

                if i_value_prefix is not null then
                    phr_utl_gzip_streamer.append_raw(
                        i_handle => self.gzip_streamer_handle$,
                        i_value => i_value_prefix
                    );
                end if;

                pragma inline(append, 'YES');
                self.append(l_values_lob(i));

                if i_value_suffix is not null then
                    phr_utl_gzip_streamer.append_raw(
                        i_handle => self.gzip_streamer_handle$,
                        i_value => i_value_suffix
                    );
                end if;
            end loop;
        else
            fetch i_values
                bulk collect into l_values_small
                limit i_batch_size;
            exit when l_values_small.count() <= 0;

            for i in 1..l_values_small.last() loop
                if i_delimiter is not null and not l_is_first_row then
                    phr_utl_gzip_streamer.append_raw(
                        i_handle => self.gzip_streamer_handle$,
                        i_value => i_delimiter
                    );
                else
                    l_is_first_row := false;
                end if;

                if i_value_prefix is not null then
                    phr_utl_gzip_streamer.append_raw(
                        i_handle => self.gzip_streamer_handle$,
                        i_value => i_value_prefix
                    );
                end if;

                phr_utl_gzip_streamer.append_raw(
                    i_handle => self.gzip_streamer_handle$,
                    i_value => l_values_small(i)
                );

                if i_value_suffix is not null then
                    phr_utl_gzip_streamer.append_raw(
                        i_handle => self.gzip_streamer_handle$,
                        i_value => i_value_suffix
                    );
                end if;
            end loop;
        end if;

        exit when i_values%notfound;
    end loop;

    close i_values;
end;

----------------------------------------------------------------------------------------------------

member function append
    ( i_value                       in raw
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
    l_new_lob                       phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
    return l_new_lob;
end;


member function append
    ( i_value                       in blob
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
    l_new_lob                       phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
    return l_new_lob;
end;


member function append
    ( i_value                       in phr_zipping_blob
    , i_repeat                      in pls_integer
    , i_delimiter                   in raw )
    return phr_zipping_blob
is
    l_new_lob                       phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
    return l_new_lob;
end;


member function append
    ( i_values                      in arr_raw_4000
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw )
    return phr_zipping_blob
is
    l_new_lob                       phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );
    return l_new_lob;
end;


member function append
    ( i_values                      in arr_blob
    , i_delimiter                   in raw
    , i_value_prefix                in raw
    , i_value_suffix                in raw )
    return phr_zipping_blob
is
    l_new_lob                       phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );
    return l_new_lob;
end;


member function append
    ( i_values                      in sys_refcursor
    , i_delimiter                   in raw
    , i_batch_size                  in pls_integer
    , i_fetch_to_lobs               in boolean
    , i_value_prefix                in raw
    , i_value_suffix                in raw )
    return phr_zipping_blob
is
    l_new_lob                       phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_batch_size => i_batch_size,
        i_fetch_to_lobs => i_fetch_to_lobs,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );
    return l_new_lob;
end;


member function append
    ( i_values                      in sys_refcursor
    , i_delimiter                   in raw
    , i_batch_size                  in pls_integer
    , i_fetch_to_lobs               in varchar2
    , i_value_prefix                in raw
    , i_value_suffix                in raw )
    return phr_zipping_blob
is
    l_new_lob                       phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_batch_size => i_batch_size,
        i_fetch_to_lobs => is_true(i_fetch_to_lobs),
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );
    return l_new_lob;
end;

----------------------------------------------------------------------------------------------------

member function compare
    ( i_lob_2                       in phr_zipping_blob
    , i_two_nulls_are_equal         in boolean
    , i_compare_lengths_first       in boolean )
    return number
    parallel_enable
is
    l_result                        number;
    l_len_1                         integer;
    l_len_2                         integer;
begin
    -- 2do! compare only after fsync
    if i_lob_2 is null then
        return null;
    elsif self.length() is null
        and i_lob_2.length() is null
    then
        if i_two_nulls_are_equal then
            return 0;
        else
            return null;
        end if;
    end if;

    if i_compare_lengths_first then
        l_len_1 := nvl(self.length(), 0);
        l_len_2 := nvl(i_lob_2.length(), 0);

        if l_len_1 < l_len_2 then
            return -0.1;
        elsif l_len_1 > l_len_2 then
            return 0.1;
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
    ( i_lob_2                       in phr_zipping_blob
    , i_two_nulls_are_equal         in varchar2
    , i_compare_lengths_first       in varchar2 )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => i_lob_2,
        i_two_nulls_are_equal => is_true(i_two_nulls_are_equal),
        i_compare_lengths_first => is_true(i_compare_lengths_first)
    );
end;


member function compare
    ( i_lob_2                       in blob
    , i_two_nulls_are_equal         in boolean
    , i_compare_lengths_first       in boolean )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => phr_zipping_blob.use_lob(i_lob_2),
        i_two_nulls_are_equal => i_two_nulls_are_equal,
        i_compare_lengths_first => i_compare_lengths_first
    );
end;


member function compare
    ( i_lob_2                       in blob
    , i_two_nulls_are_equal         in varchar2
    , i_compare_lengths_first       in varchar2 )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => phr_zipping_blob.use_lob(i_lob_2),
        i_two_nulls_are_equal => i_two_nulls_are_equal,
        i_compare_lengths_first => i_compare_lengths_first
    );
end;


order member function order$
    ( i_lob_2                       in phr_zipping_blob )
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
    ( i_from                        in pls_integer
    , i_length                      in pls_integer )
    return raw
    parallel_enable
is
begin
    raise_application_error(phr_utl_exc.CE_Not_Implemented, 'subStr not possible on non-fsync''d '||$$plsql_unit||' instance');
end;

----------------------------------------------------------------------------------------------------

member procedure set_raw_conversion_charset
    ( i_charset                     in varchar2 )
is
begin
    self.raw_conversion_charset$ := i_charset;
end;


member function with_raw_conversion_charset
    ( i_charset                     in varchar2 )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob := self;
begin
    l_result.set_raw_conversion_charset(i_charset);
    return l_result;
end;


member procedure append_varchar2
    ( i_value                       in varchar2
    , i_repeat                      in pls_integer
    , i_delimiter                   in varchar2 )
is
begin
    if self.raw_conversion_charset$ is null then
        raise_application_error(phr_utl_exc.CE_Invalid_Argument, 'No RAW conversion charset specified');
    end if;

    phr_utl_gzip_streamer.append_varchar2(
        i_handle => self.gzip_streamer_handle$,
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;


member function append_varchar2
    ( i_value                       in varchar2
    , i_repeat                      in pls_integer
    , i_delimiter                   in varchar2 )
    return phr_zipping_blob
is
    l_result                        phr_zipping_blob := self;
begin
    pragma inline(append, 'YES');
    l_result.append_varchar2(
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
    return l_result;
end;


end;
/
