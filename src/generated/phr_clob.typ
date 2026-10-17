create or replace type phr_clob
as
object
(
    ------------------------------------------------------------------------------------------------
    -- %project "Peter's PLSQL foundation"
    -- %framework LOB builders
    ------------------------------------------------------------------------------------------------
    -- Object-encapsulated CLOB abstraction
    -- %author Peter Hrasko
    -- %email peter.hrasko.sk@gmail.com
    -- %web http://peterhrasko.wordpress.com/peters-plsql-foundation/lob-builders
    ------------------------------------------------------------------------------------------------

    the_value$                      clob,

    buffering_level$                number(1,0),
    primary_buffer$                 varchar2(32767),
    secondary_buffer$               clob,
    secondary_buffer_size$          integer,

    tmp_lob_cached$                 number(1,0),
    tmp_lob_duration$               integer,

    raw_conversion_charset$         varchar2(32),
    eoln$                           varchar2(32),

    -- Factory returning a phr_clob instance initialized with new, empty temporary CLOB.
    --
    -- %param i_buffered_writes Should the LOB appends be internally resolved via an in-memory varchar2 buffer?
    -- %param i_cache The value passed to the CACHE parameter of the underlying DBMS_LOB.NEWTEMPORARY() call.
    -- %param i_duration The value passed to the DURATION parameter of the underlying DBMS_LOB.NEWTEMPORARY() call.
    -- %return Instance of the phr_clob class.
    static function new_tmp_lob
        ( i_buffered_writes             in boolean default true
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_clob,
    -- Overload of {%link new_tmp_lob;1} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function new_tmp_lob
        ( i_buffered_writes             in varchar2
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_clob,

    -- (Internal) Change the level of buffering (clamped to 0..2) and call .fsync() beforehand so that no pending appends are lost.
    member procedure aux_change_buffering_level$
        ( i_target_level                in integer ),

    -- (Internal) (Re)create the secondary buffer used by the tripple buffering.
    member procedure aux_init_secondary_buffer$,

    -- Switch off write buffering. Any pending appends get flushed first.
    member procedure use_nonbuffered_writes,

    -- Switch on double buffering. Any pending appends get flushed first.
    member procedure use_double_buffering,

    -- Switch on tripple buffering. Any pending appends get flushed first.
    --
    -- %param i_buffer_size The size (in characters/bytes) the secondary buffer is allowed to grow to before it gets flushed
    -- to the contained CLOB. Negative values are treated as zero.
    member procedure use_tripple_buffering
        ( i_buffer_size                 in simple_integer default 1048576 ),

    -- Use the specified varchar2 as EOLN for line-appends.
    --
    -- %param i_eoln The line terminator appended by {%link appendln;1}. NULL means no line terminator.
    member procedure use_eoln
        ( i_eoln                        in varchar2 ),

    -- Builder returning a copy of this phr_clob instance with buffering switched off.
    -- %usage Calls {%link use_nonbuffered_writes} on a copy of this instance, so the buffering of the original instance
    -- is not affected. The persistent LOB inside stays shared (see {%link use_lob;1}).
    member function nonbuffered
        return phr_clob,

    -- Builder returning a copy of this phr_clob instance with double buffering switched on.
    -- %usage Calls {%link use_double_buffering} on a copy of this instance, so the buffering of the original instance
    -- is not affected. The persistent LOB inside stays shared (see {%link use_lob;1}).
    member function double_buffered
        return phr_clob,

    -- Builder returning a copy of this phr_clob instance with tripple buffering switched on.
    -- %param i_buffer_size See {%link use_tripple_buffering}.
    -- %usage Calls {%link use_tripple_buffering} on a copy of this instance, so the buffering of the original instance
    -- is not affected. The persistent LOB inside stays shared (see {%link use_lob;1}).
    member function tripple_buffered
        ( i_buffer_size                 in simple_integer default 1048576 )
        return phr_clob,

    -- Builder returning a copy of this phr_clob instance with the specified varchar2 as EOLN for line-appends.
    -- %param i_eoln See {%link use_eoln}.
    member function with_eoln
        ( i_eoln                        in varchar2 )
        return phr_clob,

    -- Factory returning a phr_clob instance initialized to new temporary CLOB
    -- with varchar2 value from I_VALUE.
    --
    -- %param i_value Initial value to be appended to the new temporary CLOB.
    -- %param i_buffered_writes See the {%link new_tmp_lob;1} factory.
    -- %param i_cache See the {%link new_tmp_lob;1} factory.
    -- %param i_duration See the {%link new_tmp_lob;1} factory.
    -- %return Instance of the phr_clob class initialized with the value I_VALUE.
    static function init_tmp_lob
        ( i_value                       in varchar2
        , i_buffered_writes             in boolean default true
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Overload of {%link init_tmp_lob;1} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function init_tmp_lob
        ( i_value                       in varchar2
        , i_buffered_writes             in varchar2
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Factory returning a phr_clob instance initialized to new temporary CLOB
    -- with CLOB value from I_VALUE.
    --
    -- %usage Deep copy of CLOB contents.
    static function init_tmp_lob
        ( i_value                       in clob
        , i_buffered_writes             in boolean default true
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,
    -- Overload of {%link init_tmp_lob;3} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function init_tmp_lob
        ( i_value                       in clob
        , i_buffered_writes             in varchar2
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Factory returning a phr_clob instance initialized to new temporary CLOB
    -- with the value of the phr_clob instance passed within I_VALUE.
    --
    -- %usage Deep copy of phr_clob contents.
    static function init_tmp_lob
        ( i_value                       in phr_clob
        , i_buffered_writes             in boolean default true
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Overload of {%link init_tmp_lob;5} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function init_tmp_lob
        ( i_value                       in phr_clob
        , i_buffered_writes             in varchar2
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Factory returning a phr_clob instance initialized to new temporary CLOB
    -- and set up with the concatenated values of arr_varchar2 I_VALUES delimited by I_DELIMITER.
    --
    -- %param i_values Collection of varchar2 elements to be concatenated.
    -- %param i_delimiter (Optional) varchar2 delimiter for concatenation of elements in I_VALUES.
    -- %param i_buffered_writes See the {%link new_tmp_lob;1} factory.
    -- %param i_cache See the {%link new_tmp_lob;1} factory.
    -- %param i_duration See the {%link new_tmp_lob;1} factory.
    -- %return Instance of the phr_clob class initialized with the concatenation of values from I_VALUES, delimited by I_DELIMITER.
    --
    -- %usage Concatenation of, possibly delimited, varchar2 values into one clob
    -- in a functional way, without any collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    static function init_tmp_lob
        ( i_values                      in arr_varchar2
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null
        , i_buffered_writes             in boolean default true
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_clob,

    -- Overload of {%link init_tmp_lob;7} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function init_tmp_lob
        ( i_values                      in arr_varchar2
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null
        , i_buffered_writes             in varchar2
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_clob,

    -- Factory returning a phr_clob instance initialized to new temporary CLOB
    -- and set up with the concatenated values of arr_clob I_VALUES delimited by I_DELIMITER.
    -- (Refer to {%link init_tmp_lob;7} overload for detailed explanation.)
    static function init_tmp_lob
        ( i_values                      in arr_clob
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null
        , i_buffered_writes             in boolean default true
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_clob,

    -- Overload of {%link init_tmp_lob;9} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function init_tmp_lob
        ( i_values                      in arr_clob
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null
        , i_buffered_writes             in varchar2
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_clob,

    -- Factory returning a phr_clob instance initialized to new temporary CLOB
    -- and set up with the concatenated values of varchar2/CLOB values from a 1-column ref cursor,
    -- delimited by I_DELIMITER.
    --
    -- %param i_values Single-column ref cursor of either varchar2 or CLOB values to be concatenated.
    -- %param i_delimiter (Optional) varchar2 delimiter for concatenation of elements in I_VALUES.
    -- %param i_batch_size (Technical, performance-related) Bulk-fetch buffer size.
    -- %param i_fetch_to_lobs (Technical, performance-related) Determines whether the I_VALUES cursor should be fetched to arr_varchar2 or arr_clob buffer internally.
    -- %param i_buffered_writes See the {%link new_tmp_lob;1} factory.
    -- %param i_cache See the {%link new_tmp_lob;1} factory.
    -- %param i_duration See the {%link new_tmp_lob;1} factory.
    -- %return Instance of the phr_clob class initialized with the concatenation of column values from I_VALUES cursor, delimited by I_DELIMITER.
    --
    -- %usage Concatenation of, possibly delimited, varchar2/CLOB values into one CLOB
    -- in a functional way, without any collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    static function init_tmp_lob
        ( i_values                      in sys_refcursor
        , i_delimiter                   in varchar2 default null
        , i_batch_size                  in simple_integer default 100
        , i_fetch_to_lobs               in boolean default true
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null
        , i_buffered_writes             in boolean default true
        , i_cache                       in boolean default true
        , i_duration                    in pls_integer default null )
        return phr_clob,

    -- Overload of {%link init_tmp_lob;11} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function init_tmp_lob
        ( i_values                      in sys_refcursor
        , i_delimiter                   in varchar2 default null
        , i_batch_size                  in simple_integer default 100
        , i_fetch_to_lobs               in varchar2 default 'Y'
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null
        , i_buffered_writes             in varchar2
        , i_cache                       in varchar2 default 'Y'
        , i_duration                    in pls_integer default null )
        return phr_clob,

    -- Factory returning a phr_clob instance initialized directly with an existing LOB locator.
    --
    -- %param i_value The input CLOB locator this object is to be initialized with. NULL is allowed,
    -- yielding an instance with a NULL locator that behaves as an empty LOB for {%link length} and {%link is_empty}.
    -- %param i_buffered_writes See the {%link new_tmp_lob;1} factory.
    -- %return Instance of the phr_clob class initialized with the existing LOB locator.
    --
    -- %usage There's no deep copying of I_VALUE contents performed by this method itself. A persistent LOB locator
    -- is a pointer to the stored LOB, so all the writes/appends made through this object (once flushed from the
    -- internal buffers) are applied to the stored LOB, and all the DBMS_LOB operations made over the original locator
    -- are applied to the very same stored LOB. Mind the LOB locator read consistency, though: a locator sees the changes
    -- made through another locator of the same LOB only after it gets re-read. A temporary LOB, on the other hand,
    -- gets copied by Oracle whenever assigned, so this object works over its own copy of the temporary LOB;
    -- use {%link get_value} to get hold of its up-to-date contents. Also be aware that the buffered writes imply
    -- that intertwining of writes/appends to the LOB will most probably result in a different actual order of
    -- appended/written values than the order of the appendings in the code. Due to this, use either the
    -- phr_clob.append methods or the dbms_lob.writeAppend/dbms_lob.append procedures but, ideally,
    -- not both over the same LOB locator.
    -- Appending to an instance with a NULL locator raises ORA-06502.
    static function use_lob
        ( i_value                       in clob default null
        , i_buffered_writes             in boolean default true )
        return phr_clob,

    -- Overload of {%link use_lob;1} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    static function use_lob
        ( i_value                       in clob default null
        , i_buffered_writes             in varchar2 )
        return phr_clob,

    -- (Internal) Destroy/free the internal temporary CLOB, together with any pending appends
    -- in the primary buffer, and forget its caching and duration flags.
    member procedure tmp_dispose,

    -- (Internal) Reinitialize the internal temporary CLOB (emptying it) with the previous operational
    -- flags of LOB caching and LOB duration.
    --
    -- %raises ORA-20902 (phr_anylob_exc.CE_Invalid_Data_Type) if the contained LOB is not a temporary LOB created by this
    -- object, e.g., after {%link use_lob} or {%link tmp_dispose}.
    member procedure tmp_reinitialize,

    -- (Internal) Initialize the internal temporary CLOB (disposing of the previous one, if any)
    -- with the supplied flags of LOB caching and LOB duration.
    --
    -- %param i_cache The value passed to the CACHE parameter of the underlying DBMS_LOB.CREATETEMPORARY() call.
    -- %param i_duration The value passed to the DURATION parameter of the underlying DBMS_LOB.CREATETEMPORARY() call.
    -- NULL means DBMS_LOB.CALL.
    member procedure tmp_initialize
        ( i_cache                       in boolean
        , i_duration                    in pls_integer default null ), -- dbms_lob.call will be used by default

    -- (Internal) Flush the primary buffer to the contained CLOB (or to the secondary buffer
    -- when tripple buffering is in effect), if any buffering is in effect.
    member procedure aux_fsync_primary_buffer$,

    -- (Internal) Flush the secondary buffer to the contained CLOB, if tripple buffering is in effect.
    member procedure aux_fsync_secondary_buffer$,

    -- In case of internal write buffering being in effect, this method appends (flushes) the internal
    -- write buffers to the actual CLOB (and clears the buffers).
    -- %usage Use this to ensure, for whatever reason, that any pending varchar2 appends
    -- (in the internal buffers) get really written to the contained CLOB structure.
    member procedure fsync,

    -- Execute an fsync on a copy of this instance and return the copy.
    -- %return A phr_clob instance with the pending appends flushed into the LOB. The instance gets copied,
    -- but a persistent LOB inside it stays shared (see {%link use_lob;1}), while the pending appends of the original
    -- instance remain in its own buffers.
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function fsync
        return phr_clob,

    -- Length of the contained CLOB.
    -- %return dbms_lob.length of the contained CLOB with the length of the pending appends included.
    -- Zero if the contained LOB locator is NULL.
    member function length return integer,

    -- Is the contained LOB data of zero length, i.e., is the LOB empty (though not necessarily NULL)?
    -- %return true also for a NULL LOB locator, as {%link length} is zero then.
    member function is_empty return boolean,

    -- Call the {%link dbms_lob.trim} (if necessary) on the contained CLOB.
    -- %param i_length The target length of the contained CLOB. Nothing happens when
    -- I_LENGTH is greater than or equal to the current length, including the pending appends.
    -- %raises ORA-21560 for a negative I_LENGTH.
    -- %usage As opposed to the dbms_lob.trim, this takes care of any pending appends (internal write buffering) as well.
    member procedure trim
        ( i_length                      in integer default 0 ),

    -- Call the {%link trim;1} method on a copy of this instance and return the copy.
    -- %return A phr_clob instance trimmed to I_LENGTH. The instance gets copied,
    -- but a persistent LOB inside it stays shared (see {%link use_lob;1}).
    -- %usage Useful for method chaining. Very useful in SQL context.
    member function trim
        ( i_length                      in integer default 0 )
        return phr_clob,

    -- The value of the contained CLOB.
    -- %return The LOB locator of the contained CLOB with any pending appends included (flushed into
    -- the LOB). NULL if the contained LOB locator is NULL. For a persistent LOB, the returned locator points to the very same
    -- stored LOB; a temporary LOB gets copied by Oracle whenever assigned, so treat the returned value as a snapshot.
    member function get_value
        return clob,

    -- Deep copy of the contained CLOB to another CLOB.
    --
    -- %param io_dest The destination CLOB. It is first trimmed to I_DEST_OFFSET + length - 1,
    -- so it has to be at least that long (otherwise ORA-22926 is raised) and whatever followed the copied portion is lost.
    -- %param i_dest_offset Offset (1-based) within I_DEST the contents are copied to.
    -- %usage Nothing happens, and I_DEST is left untouched, when the contained CLOB is NULL or empty.
    -- A NULL I_DEST raises ORA-06502 otherwise.
    -- As opposed to the dbms_lob.copy, this takes care of any pending appends (internal write buffering) as well.
    member procedure copy_to
        ( io_dest                       in out nocopy clob
        , i_dest_offset                 in integer default 1 ),

    -- Is the contained CLOB a temporary LOB or a persistent LOB?
    -- %return PL/SQL boolean
    -- {*} true for persistent LOB locators,
    -- {*} false for temporary LOB locators,
    -- {*} NULL for a NULL LOB locator.
    member function is_persistent return boolean,

    -- Wrapper over {%link is_persistent} with VARCHAR2 return values.
    -- %return 'Y' for true, 'N' for false, NULL for NULL.
    member function is_persistent$ return varchar2,

    -- Is the contained CLOB a securefile LOB?
    -- %return PL/SQL boolean
    -- {*} true for SecureFile LOB locators,
    -- {*} false for BasicFile and temporary LOB locators,
    -- {*} NULL for a NULL LOB locator.
    member function is_secure_file return boolean,

    -- Wrapper over {%link is_secure_file} with VARCHAR2 return values.
    -- %return 'Y' for true, 'N' for false, NULL for NULL.
    member function is_secure_file$ return varchar2,

    -- (Internal) Append a varchar2 to either the contained CLOB or to the internal
    -- write buffers when write buffering is in effect.
    member procedure aux_append_small$
        ( i_value                       in varchar2 ),

    -- Append method writes/appends (arbitrary number of times) a varchar2 value to the
    -- contained CLOB, possibly not immediately if the write buffering is in effect.
    --
    -- %param i_value The varchar2 value to be appended. NULL is ignored.
    -- %param i_repeat The number of times the I_VALUE is to be appended. Nothing is appended for values below 1.
    -- %param i_delimiter The varchar2 delimiter to be inserted between the repetitions when I_REPEAT is greater than 1.
    member procedure append
        ( i_value                       in varchar2
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null ),

    -- Append method writes/appends (arbitrary number of times) a CLOB value to the
    -- contained CLOB, possibly not immediately if the write buffering is in effect.
    --
    -- %param i_value The CLOB value to be appended. NULL and empty values are ignored.
    -- %param i_repeat See {%link append;1}.
    -- %param i_delimiter See {%link append;1}.
    member procedure append
        ( i_value                       in clob
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null ),

    -- Append method writes/appends (arbitrary number of times) the LOB contents from the supplied
    -- phr_clob to the contained CLOB, possibly not immediately if
    -- the write buffering is in effect.
    --
    -- %param i_value The phr_clob instance the LOB contents of are to be appended. NULL and empty instances are ignored.
    -- %param i_repeat See {%link append;1}.
    -- %param i_delimiter See {%link append;1}.
    member procedure append
        ( i_value                       in phr_clob
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null ),

    -- Append method writes/appends (arbitrary number of times) the BFILE contents to the
    -- contained CLOB, possibly not immediately if the write buffering is in effect
    -- and the BFILE is sufficiently small.
    --
    -- %param i_value The BFILE value to be appended.
    -- %param i_repeat See {%link append;1}.
    -- %param i_delimiter See {%link append;1}.
    member procedure append
        ( i_value                       in bfile
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null ),

    -- Append method writes/appends the concatenation of values from arr_varchar2, delimited
    -- by a varchar2 delimiter.
    --
    -- %param i_values arr_varchar2 to be concatenated and appended. NULL and empty collections are ignored,
    -- NULL elements contribute nothing but their delimiter, prefix and suffix.
    -- %param i_delimiter (Optional) varchar2 delimiter for concatenation of elements from I_VALUES.
    -- %param i_value_prefix (Optional) varchar2 to be prepended to each element.
    -- %param i_value_suffix (Optional) varchar2 to be appended to each element.
    --
    -- %usage Concatenation of, possibly delimited, varchar2 values into one CLOB
    -- in a functional way, without any collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    member procedure append
        ( i_values                      in arr_varchar2
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null ),

    -- Append method writes/appends the concatenation of values from arr_clob, delimited
    -- by a varchar2 delimiter.
    --
    -- %param i_values arr_clob to be concatenated and appended. NULL and empty collections are ignored,
    -- NULL elements contribute nothing but their delimiter, prefix and suffix.
    -- %param i_delimiter (Optional) varchar2 delimiter for concatenation of elements from I_VALUES.
    -- %param i_value_prefix (Optional) varchar2 to be prepended to each element.
    -- %param i_value_suffix (Optional) varchar2 to be appended to each element.
    --
    -- %usage Concatenation of, possibly delimited, CLOB values into one CLOB
    -- in a functional way, without any collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code.
    member procedure append
        ( i_values                      in arr_clob
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null ),

    -- Append method writes/appends the concatenation of values from the supplied single-column ref cursor
    -- returning either varchar2 or CLOB, delimited by a varchar2 delimiter.
    --
    -- %param i_values Single-column ref cursor returning the varchar2/CLOB values to be concatenated and appended.
    -- %param i_delimiter (Optional) varchar2 delimiter for concatenation of elements from the ref cursor.
    -- %param i_batch_size (Technical, performance-related) Bulk-fetch buffer size.
    -- %param i_fetch_to_lobs (Technical, performance-related) Determines whether the I_VALUES cursor should be fetched to arr_varchar2 or to arr_clob buffer internally.
    -- %param i_value_prefix (Optional) varchar2 to be prepended to each value.
    -- %param i_value_suffix (Optional) varchar2 to be appended to each value.
    --
    -- %usage Concatenation of, possibly delimited, varchar2/CLOB values into one CLOB
    -- in a functional way, without any collection-iterating-FOR-loop + first-value-identifying-IF-branch
    -- boilerplate code. The cursor gets fully fetched and closed by this method.
    member procedure append
        ( i_values                      in sys_refcursor
        , i_delimiter                   in varchar2 default null
        , i_batch_size                  in simple_integer default 100
        , i_fetch_to_lobs               in boolean default true
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null ),

    -- Call the {%link append;1} method for varchar2 on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_value                       in varchar2
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Call the {%link append;2} method for CLOB on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_value                       in clob
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Call the {%link append;3} method for phr_clob on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_value                       in phr_clob
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Call the {%link append;4} method for BFILE on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_value                       in bfile
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in varchar2 default null )
        return phr_clob,

    -- Call the {%link append;5} method for arr_varchar2 on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_values                      in arr_varchar2
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null )
        return phr_clob,

    -- Call the {%link append;6} method for arr_clob on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Not that useful in SQL context, as Oracle (as of version 12.2)
    -- does no support the COLLECT() aggregator to a collection of CLOBs. The instance gets copied,
    -- but a persistent LOB inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_values                      in arr_clob
        , i_delimiter                   in varchar2 default null
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null )
        return phr_clob,

    -- Call the {%link append;7} method with ref cursor on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Unusable in SQL context due to PL/SQL boolean parameters in use. (See the next overload.)
    -- The instance gets copied, but a persistent LOB inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_values                      in sys_refcursor
        , i_delimiter                   in varchar2 default null
        , i_batch_size                  in simple_integer default 100
        , i_fetch_to_lobs               in boolean default true
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null )
        return phr_clob,

    -- Overload of {%link append;7} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    -- %usage Useful for method chaining. Extremely useful in SQL context! The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function append
        ( i_values                      in sys_refcursor
        , i_delimiter                   in varchar2 default null
        , i_batch_size                  in simple_integer default 100
        , i_fetch_to_lobs               in varchar2
        , i_value_prefix                in varchar2 default null
        , i_value_suffix                in varchar2 default null )
        return phr_clob,

    -- AppendLn method writes/appends a varchar2 value to the contained CLOB,
    -- followed by the (custom) EOLN sequence, possibly not immediately if the write buffering is in effect.
    --
    -- %param i_value The varchar2 value to be appended. NULL (default) appends the EOLN sequence only.
    -- %usage When the EOLN is NULL (see {%link use_eoln}), nothing but I_VALUE is appended.
    member procedure appendln
        ( i_value                       in varchar2 default null ),

    -- AppendLn method writes/appends a varchar2 value to the contained CLOB,
    -- followed by the (custom) EOLN sequence, possibly not immediately if the write buffering is in effect,
    -- on a copy of this instance, returning the copy as the result.
    --
    -- %param i_value See {%link appendln;1}.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function appendln
        ( i_value                       in varchar2 default null )
        return phr_clob,

    -- Compares the contents of the contained CLOB with the contents of the LOB
    -- contained within the supplied CLOB.
    --
    -- %param i_lob_2 An instance of the phr_clob the contained CLOB is to be compared to.
    -- %param i_compare_lengths_first
    -- {*} true (default) Possibly speed up the LOBs comparison by comparing the LOBs lengths first.
    -- {*} false Do not use length-based comparison first, do contents-based comparison immediately.
    -- %return
    -- {*} 0 if the LOBs are, contents-wise, the same
    -- {*} -0.1 if I_COMPARE_LENGTHS_FIRST is set and the length of the contained LOB is less than the length of the supplied LOB,
    -- {*} +0.1 if I_COMPARE_LENGTHS_FIRST is set and the length of the contained LOB is greater than the length of the supplied LOB,
    -- {*} -1 or +1 (as returned by dbms_lob.compare) if the contents differ and the contained LOB is,
    -- at the first differing element, less or greater than the supplied LOB, respectively,
    -- {*} NULL if I_LOB_2 is NULL, or if dbms_lob.compare returns NULL (e.g., when at least one of the LOB locators
    -- is NULL and the lengths comparison is not decisive).
    --
    -- %usage Equivalent to dbms_lob.compare with some enhancements. When i_compare_lengths_first is
    -- set, then if the lengths are distinct, the LOBs are considered distinct immediately; if the
    -- lengths match, then a regular, contents-based comparison takes place. A NULL LOB locator is
    -- considered to be of zero length, and the pending appends are taken into account.
    member function compare
        ( i_lob_2                       in phr_clob
        , i_compare_lengths_first       in boolean default true )
        return number
        parallel_enable,

    -- Overload of {%link compare;1} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    -- %param i_compare_lengths_first Any value but a "true" flag (e.g., NULL) means false.
    member function compare
        ( i_lob_2                       in phr_clob
        , i_compare_lengths_first       in varchar2 )
        return number
        parallel_enable,

    -- Compares the contents of the contained CLOB with the contents of the supplied CLOB.
    --
    -- %param i_lob_2 A CLOB value the contained CLOB is to be compared to.
    -- A NULL value is compared as a NULL LOB locator, i.e., as a LOB of zero length.
    -- %param i_compare_lengths_first (See {%link compare;1}.)
    -- %return (See {%link compare;1}.)
    --
    -- %usage Overload of {%link compare;1} operating on a simple (non-object-encapsulated) CLOB input value.
    member function compare
        ( i_lob_2                       in clob
        , i_compare_lengths_first       in boolean default true )
        return number
        parallel_enable,

    -- Overload of {%link compare;3} with VARCHAR2 input flags (true: 'y', 'yes', '1', 'true', case-insensitive).
    member function compare
        ( i_lob_2                       in clob
        , i_compare_lengths_first       in varchar2 )
        return number
        parallel_enable,

    -- Class' ORDER function for direct comparisons of LOB contents in SQL context.
    -- %param i_lob_2 (See {%link compare;1}.)
    -- %return (See {%link compare;1}.) The comparison is done with I_COMPARE_LENGTHS_FIRST set,
    -- i.e., shorter LOBs sort before longer ones.
    order member function order$
        ( i_lob_2                       in phr_clob )
        return number
        parallel_enable,

    -- Get a substring of the contained CLOB.
    --
    -- %param i_from Offset (1-based) of the contained CLOB from which to get the substring.
    -- %param i_length Length of the desired substring. NULL, if you need the substring up to the CLOB's end.
    -- %return The part of the contained CLOB from offset I_FROM in the length of I_LENGTH
    -- (or shorter, if the end of the CLOB is reached first). NULL if I_FROM or I_LENGTH is not positive,
    -- if I_FROM is beyond the end of the CLOB, or if the contained LOB locator is NULL.
    --
    -- %usage As opposed to the dbms_lob.substr, this takes care of any pending appends (internal write buffering) as well.
    member function subStr
        ( i_from                        in integer
        , i_length                      in pls_integer default null )
        return varchar2
        parallel_enable,

    -- Find the position (offset) of a I_NEEDLE within the contained CLOB haystack.
    --
    -- %param i_needle Substring ("needle") to find.
    -- %param i_offset Start searching for the needle at this haystack offset (1-based).
    -- %param i_occurrence Search for I_OCCURRENCE-th occurrence of the needle within the haystack.
    -- %return Offset within the haystack of the found needle or 0 (zero) if not found. NULL if I_NEEDLE is NULL,
    -- if I_OFFSET or I_OCCURRENCE is not positive, or if the contained LOB locator is NULL.
    --
    -- %usage As opposed to the dbms_lob.instr, this takes care of any pending appends (internal write buffering) as well.
    member function inStr
        ( i_needle                      in varchar2
        , i_offset                      in integer default 1
        , i_occurrence                  in simple_integer default 1 )
        return integer
        parallel_enable,

    -- Configure this phr_clob instance with a character set for appends/writes
    -- of raw values with charset autoconversion in effect.
    -- %param i_charset The Oracle character set string to be used for subsequent raw autoconversions.
    -- At most 32 characters long; NULL resets the setting.
    member procedure set_raw_conversion_charset
        ( i_charset                     in varchar2 ),

    -- Call {%link set_raw_conversion_charset;1} on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function with_raw_conversion_charset
        ( i_charset                     in varchar2 )
        return phr_clob,

    -- Append a raw (auto-converted to varchar2 via preset conversion
    -- charset) value to the contained CLOB.
    --
    -- %param i_value A raw value to be converted via preset conversion charset and appended to the contained CLOB.
    -- %param i_repeat (See {%link append;1}.)
    -- %param i_delimiter (See {%link append;1}.) A raw value, converted the same way as I_VALUE.
    -- %raises ORA-20901 (phr_anylob_exc.CE_Invalid_Argument) if no conversion charset has been set
    -- (see {%link set_raw_conversion_charset}), even when I_VALUE is NULL.
    --
    -- %usage This allows a developer to reduce some amount of boilerplate code when operating over
    -- raw values being appended to CLOBs with a specific
    -- character set.
    member procedure append_raw
        ( i_value                       in raw
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in raw default null ),

    -- Call {%link append_raw;1} on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function append_raw
        ( i_value                       in raw
        , i_repeat                      in simple_integer default 1
        , i_delimiter                   in raw default null )
        return phr_clob,

    -- Delete I_AMOUNT-long portion of contained CLOB starting from offset I_OFFSET
    -- and shift the trailing leftover to the former offset of the deleted CLOB portion,
    -- reducing the contained CLOB length by I_AMOUNT.
    --
    -- %param i_offset Starting (1-based) offset of the CLOB portion to be deleted.
    -- %param i_amount Number of CLOB's to be deleted from the contained CLOB at offset I_OFFSET.
    -- %raises ORA-20901 (phr_anylob_exc.CE_Invalid_Argument) for a NULL or negative I_OFFSET, or a NULL or negative I_AMOUNT.
    -- ORA-21560 for a zero I_OFFSET (offsets are 1-based) combined with a non-zero I_AMOUNT.
    --
    -- %usage Zero I_AMOUNT does nothing, whatever the I_OFFSET is. I_AMOUNT reaching beyond the end of
    -- the CLOB deletes everything from I_OFFSET onwards; I_OFFSET beyond the end deletes nothing.
    member procedure fragment_delete
        ( i_offset                      in integer
        , i_amount                      in integer ),

    -- Call {%link fragment_delete;1} on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function fragment_delete
        ( i_offset                      in integer
        , i_amount                      in integer )
        return phr_clob,

    -- Delete portion of contained CLOB from offset I_FROM (inclusive) up to offset I_TO (inclusive)
    -- and shift the trailing leftover to the former offset of the deleted CLOB portion,
    -- reducing the contained CLOB length by I_TO-I_FROM+1.
    --
    -- %param i_from Starting (1-based) offset of the CLOB portion to be deleted.
    -- %param i_to Ending (1-based, inclusive) offset of the CLOB portion to be deleted.
    -- %raises ORA-20901 (phr_anylob_exc.CE_Invalid_Argument) for a NULL I_FROM or I_TO, or for I_TO being less than I_FROM - 1.
    -- See {%link fragment_delete;1} for the rest.
    member procedure fragment_delete_between
        ( i_from                        in integer
        , i_to                          in integer ),

    -- Call {%link fragment_delete_between;1} on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function fragment_delete_between
        ( i_from                        in integer
        , i_to                          in integer )
        return phr_clob,

    -- Delete portion of contained CLOB from the first occurrence of needle I_FROM (inclusive)
    -- up to the first (subsequent) occurrence of needle I_TO (inclusive) and shift the trailing leftover
    -- to the former offset of the I_FROM needle, reducing the contained CLOB length
    -- by the length of the portion between the two needles.
    --
    -- %param i_from Starting (inclusive) needle of the CLOB portion to be deleted.
    -- %param i_to Ending (inclusive) needle of the CLOB portion to be deleted.
    -- NULL (default) means the portion reaches up to the end of the CLOB.
    -- %param i_max_iterations Repeat the deletion this number of times. (default: 1)
    -- Each next search for the I_FROM needle starts right after the previously deleted portion in the original
    -- CLOB. Values below 1 delete nothing.
    -- %raises ORA-20901 (phr_anylob_exc.CE_Invalid_Argument) for a NULL I_FROM.
    --
    -- %usage The CLOB stays untouched if the I_FROM needle is not found. When the I_TO needle is not found
    -- after an occurrence of I_FROM, that occurrence is not deleted and the iterations end.
    member procedure fragment_delete_from_to
        ( i_from                        in varchar2
        , i_to                          in varchar2 default null
        , i_max_iterations              in simple_integer default 1 ),

    -- Call {%link fragment_delete_from_to;1} on a copy of this instance and return the copy.
    -- %usage Useful for method chaining. Very useful in SQL context. The instance gets copied, but a persistent LOB
    -- inside it stays shared (see {%link use_lob;1}).
    member function fragment_delete_from_to
        ( i_from                        in varchar2
        , i_to                          in varchar2 default null
        , i_max_iterations              in simple_integer default 1 )
        return phr_clob
)
not final
instantiable
;
/
create or replace type body phr_clob
is


static function new_tmp_lob
    ( i_buffered_writes             in boolean
    , i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new phr_clob(
        the_value$ => null,
        buffering_level$ => case when i_buffered_writes then 1 else 0 end,
        primary_buffer$ => null,
        secondary_buffer$ => null,
        secondary_buffer_size$ => null,
        tmp_lob_cached$ => case when i_cache then 1 else 0 end,
        tmp_lob_duration$ => i_duration,
        raw_conversion_charset$ => null,
        eoln$ => chr(10)
    );

    l_result.tmp_initialize(
        i_cache => i_cache,
        i_duration => i_duration
    );

    return l_result;
end;


static function new_tmp_lob
    ( i_buffered_writes             in varchar2
    , i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_clob
is
begin
    pragma inline(new_tmp_lob, 'YES');
    return phr_clob.new_tmp_lob(
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true'),
        i_cache => lower(i_cache) in ('y', 'yes', '1', 'true'),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_value                       in varchar2
    , i_buffered_writes             in boolean
    , i_cache                       in boolean
    , i_duration                    in pls_integer
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration,
        i_buffered_writes => i_buffered_writes
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
    ( i_value                       in varchar2
    , i_buffered_writes             in varchar2
    , i_cache                       in varchar2
    , i_duration                    in pls_integer
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_value => i_value,
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true'),
        i_cache => lower(i_cache) in ('y', 'yes', '1', 'true'),
        i_duration => i_duration,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_value                       in clob
    , i_buffered_writes             in boolean
    , i_cache                       in boolean
    , i_duration                    in pls_integer
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration,
        i_buffered_writes => i_buffered_writes
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
    ( i_value                       in clob
    , i_buffered_writes             in varchar2
    , i_cache                       in varchar2
    , i_duration                    in pls_integer
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_value => i_value,
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true'),
        i_cache => lower(i_cache) in ('y', 'yes', '1', 'true'),
        i_duration => i_duration,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_value                       in phr_clob
    , i_buffered_writes             in boolean
    , i_cache                       in boolean
    , i_duration                    in pls_integer
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration,
        i_buffered_writes => i_buffered_writes
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
    ( i_value                       in phr_clob
    , i_buffered_writes             in varchar2
    , i_cache                       in varchar2
    , i_duration                    in pls_integer
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_value => i_value,
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true'),
        i_cache => lower(i_cache) in ('y', 'yes', '1', 'true'),
        i_duration => i_duration,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_values                      in arr_varchar2
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2
    , i_buffered_writes             in boolean
    , i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration,
        i_buffered_writes => i_buffered_writes
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
    ( i_values                      in arr_varchar2
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2
    , i_buffered_writes             in varchar2
    , i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_clob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix,
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true'),
        i_cache => lower(i_cache) in ('y', 'yes', '1', 'true'),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_values                      in arr_clob
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2
    , i_buffered_writes             in boolean
    , i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration,
        i_buffered_writes => i_buffered_writes
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
    ( i_values                      in arr_clob
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2
    , i_buffered_writes             in varchar2
    , i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_clob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix,
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true'),
        i_cache => lower(i_cache) in ('y', 'yes', '1', 'true'),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function init_tmp_lob
    ( i_values                      in sys_refcursor
    , i_delimiter                   in varchar2
    , i_batch_size                  in simple_integer
    , i_fetch_to_lobs               in boolean
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2
    , i_buffered_writes             in boolean
    , i_cache                       in boolean
    , i_duration                    in pls_integer )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new_tmp_lob(
        i_cache => i_cache,
        i_duration => i_duration,
        i_buffered_writes => i_buffered_writes
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
    , i_delimiter                   in varchar2
    , i_batch_size                  in simple_integer
    , i_fetch_to_lobs               in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2
    , i_buffered_writes             in varchar2
    , i_cache                       in varchar2
    , i_duration                    in pls_integer )
    return phr_clob
is
begin
    pragma inline(init_tmp_lob, 'YES');
    return init_tmp_lob(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_batch_size => i_batch_size,
        i_fetch_to_lobs => lower(i_fetch_to_lobs) in ('y', 'yes', '1', 'true'),
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix,
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true'),
        i_cache => lower(i_cache) in ('y', 'yes', '1', 'true'),
        i_duration => i_duration
    );
end;

----------------------------------------------------------------------------------------------------

static function use_lob
    ( i_value                       in clob
    , i_buffered_writes             in boolean )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := new phr_clob(
        the_value$ => i_value,
        buffering_level$ => case when i_buffered_writes then 1 else 0 end,
        primary_buffer$ => null,
        secondary_buffer$ => null,
        secondary_buffer_size$ => null,
        tmp_lob_cached$ => null,
        tmp_lob_duration$ => null,
        raw_conversion_charset$ => null,
        eoln$ => chr(10)
    );

    return l_result;
end;


static function use_lob
    ( i_value                       in clob
    , i_buffered_writes             in varchar2 )
    return phr_clob
is
begin
    return use_lob(
        i_value => i_value,
        i_buffered_writes => lower(i_buffered_writes) in ('y', 'yes', '1', 'true')
    );
end;

----------------------------------------------------------------------------------------------------
-- Buffering-related method

member procedure aux_init_secondary_buffer$
is
begin
    if self.secondary_buffer$ is not null then
        dbms_lob.freeTemporary(self.secondary_buffer$);
    end if;

    dbms_lob.createTemporary(
        lob_loc => self.secondary_buffer$,
        cache => true,
        dur => nvl(self.tmp_lob_duration$, dbms_lob.call)
    );
end;


member procedure aux_change_buffering_level$
    ( i_target_level                in integer )
is
    l_target_level                  integer := i_target_level;
begin
    if l_target_level < 0 then
        l_target_level := 0;
    elsif l_target_level > 2 then
        l_target_level := 2;
    end if;

    pragma inline(fsync, 'YES');
    self.fsync();
    self.buffering_level$ := l_target_level;
end;


member procedure use_nonbuffered_writes
is
begin
    pragma inline(aux_change_buffering_level$, 'YES');
    self.aux_change_buffering_level$(0);

    self.primary_buffer$ := null;
    self.secondary_buffer$ := null;
end;


member function nonbuffered
    return phr_clob
is
    l_result                        phr_clob := self;
begin
    l_result.use_nonbuffered_writes();
    return l_result;
end;


member procedure use_double_buffering
is
begin
    pragma inline(aux_change_buffering_level$, 'YES');
    self.aux_change_buffering_level$(1);

    self.primary_buffer$ := null;
    self.secondary_buffer$ := null;
end;


member function double_buffered
    return phr_clob
is
    l_result                        phr_clob := self;
begin
    pragma inline(use_double_buffering, 'YES');
    l_result.use_double_buffering();

    return l_result;
end;


member procedure use_tripple_buffering
    ( i_buffer_size                 in simple_integer )
is
begin
    pragma inline(aux_change_buffering_level$, 'YES');
    self.aux_change_buffering_level$(2);

    self.primary_buffer$ := null;
    self.secondary_buffer_size$ := greatest(nvl(i_buffer_size, 1048576), 0);

    pragma inline(aux_init_secondary_buffer$, 'YES');
    self.aux_init_secondary_buffer$();
end;


member function tripple_buffered
    ( i_buffer_size                 in simple_integer )
    return phr_clob
is
    l_result                        phr_clob := self;
begin
    pragma inline(use_tripple_buffering, 'YES');
    l_result.use_tripple_buffering(
        i_buffer_size => i_buffer_size
    );

    return l_result;
end;


member procedure use_eoln
    ( i_eoln                        in varchar2 )
is
begin
    self.eoln$ := i_eoln;
end;


member function with_eoln
    ( i_eoln                        in varchar2 )
    return phr_clob
is
    l_result                        phr_clob := self;
begin
    pragma inline(use_eoln, 'YES');
    l_result.use_eoln(
        i_eoln => i_eoln
    );

    return l_result;
end;

----------------------------------------------------------------------------------------------------

member procedure tmp_dispose
is
begin
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
        raise_application_error(phr_anylob_exc.CE_Invalid_Data_Type, $$plsql_unit||'.tmp_reinitialize(): Not a temporary LOB');
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
    self.tmp_lob_duration$ := nvl(i_duration, dbms_lob.call);

    dbms_lob.createTemporary(
        lob_loc => self.the_value$,
        cache => i_cache,
        dur => nvl(i_duration, dbms_lob.call)
    );
    self.primary_buffer$ := null;
end;

----------------------------------------------------------------------------------------------------

member procedure aux_fsync_primary_buffer$
is
    l_buffer_length                 integer;
begin
    if self.primary_buffer$ is not null then
        l_buffer_length := sys.standard.length(self.primary_buffer$);

        if self.buffering_level$ = 1 then
            dbms_lob.writeAppend(
                lob_loc => self.the_value$,
                amount => l_buffer_length,
                buffer => self.primary_buffer$
            );
        elsif self.buffering_level$ > 1 then
            dbms_lob.writeAppend(
                lob_loc => self.secondary_buffer$,
                amount => l_buffer_length,
                buffer => self.primary_buffer$
            );
        else
            raise_application_error(phr_anylob_exc.CE_Invalid_Argument, 'Invalid internal buffering level of "'||self.buffering_level$||'"');
        end if;

        self.primary_buffer$ := null;
    end if;
end;


member procedure aux_fsync_secondary_buffer$
is
begin
    if self.buffering_level$ >= 2 and self.secondary_buffer$ is not null then
        dbms_lob.append(
            dest_lob => self.the_value$,
            src_lob => self.secondary_buffer$
        );
        pragma inline(aux_init_secondary_buffer$, 'YES');
        self.aux_init_secondary_buffer$();
    end if;
end;


member procedure fsync
is
begin
    if self.buffering_level$ >= 1 then
        pragma inline(aux_fsync_primary_buffer$, 'YES');
        self.aux_fsync_primary_buffer$();
    end if;

    if self.buffering_level$ >= 2 then
        pragma inline(aux_fsync_secondary_buffer$, 'YES');
        self.aux_fsync_secondary_buffer$();
    end if;
end;


member function fsync
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := self;
    l_result.fsync();
    return l_result;
end;

----------------------------------------------------------------------------------------------------

member function length return integer
is
begin
    return nvl(dbms_lob.getLength(self.the_value$), 0)
        + case when self.buffering_level$ >= 1 then nvl(sys.standard.length(self.primary_buffer$), 0) else 0 end
        + case when self.buffering_level$ >= 2 then nvl(dbms_lob.getLength(self.secondary_buffer$), 0) else 0 end;
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
    if i_length < self.length() then
        self.fsync();
        dbms_lob.trim(self.the_value$, i_length);
    end if;
end;


member function trim
    ( i_length                      in integer )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := self;
    l_result.trim(i_length);
    return l_result;
end;


member function get_value return clob
is
begin
    if self.buffering_level$ >= 1 then
        return self.fsync().the_value$;
    else
        return self.the_value$;
    end if;
end;


member procedure copy_to
    ( io_dest                       in out nocopy clob
    , i_dest_offset                 in integer )
is
begin
    if self.the_value$ is null or self.length() <= 0 then
        return;
    end if;

    dbms_lob.trim(
        lob_loc => io_dest,
        newlen => i_dest_offset + self.length() - 1
    );

    self.fsync();

    dbms_lob.copy(
        dest_lob => io_dest,
        src_lob => self.the_value$,
        amount => self.length(),
        dest_offset => i_dest_offset
    );
end;


member function is_persistent return boolean
is
begin
    return dbms_lob.isTemporary(self.the_value$) != 1;
end;


member function is_persistent$ return varchar2
is
    l_result                        boolean := self.is_persistent();
begin
    return case l_result
        when true then 'Y'
        when false then 'N'
        else null
    end;
end;


member function is_secure_file return boolean
is
begin
    return dbms_lob.isSecureFile(self.the_value$);
end;


member function is_secure_file$ return varchar2
is
    l_result                        boolean := self.is_secure_file();
begin
    return case l_result
        when true then 'Y'
        when false then 'N'
        else null
    end;
end;

----------------------------------------------------------------------------------------------------

member procedure aux_append_small$
    ( i_value                       in varchar2 )
is
begin
    if i_value is null then
        return;
    end if;

    if self.buffering_level$ >= 1 then
        if nvl(sys.standard.length(self.primary_buffer$),0) + nvl(sys.standard.length(i_value),0) > 32767 then
            pragma inline(aux_fsync_primary_buffer$, 'YES');
            self.aux_fsync_primary_buffer$();
            self.primary_buffer$ := i_value;
        else
            self.primary_buffer$ := sys.standard.concat(self.primary_buffer$, i_value);
        end if;

        if self.buffering_level$ >= 2
            and dbms_lob.getLength(self.secondary_buffer$) > self.secondary_buffer_size$
        then
            pragma inline(aux_fsync_secondary_buffer$, 'YES');
            self.aux_fsync_secondary_buffer$();
        end if;
    else
        dbms_lob.writeAppend(self.the_value$, nvl(sys.standard.length(i_value),0), i_value);
    end if;
end;

----------------------------------------------------------------------------------------------------

member procedure append
    ( i_value                       in varchar2
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
is
    l_value_length                  pls_integer;
begin
    if i_value is null or i_repeat is null or i_repeat < 1 then
        return;
    end if;

    l_value_length := sys.standard.length(i_value);

    for i in 1..i_repeat loop
        if i_delimiter is not null and i > 1 then
            pragma inline(aux_append_small$,'YES');
            self.aux_append_small$(i_delimiter);
        end if;

        if l_value_length > 0 then
            pragma inline(aux_append_small$,'YES');
            self.aux_append_small$(i_value);
        end if;
    end loop;
end;


member procedure append
    ( i_value                       in clob
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
is
    l_value_length                  integer;
    l_value_short                   varchar2(32767);
begin
    if i_value is null or i_repeat is null or i_repeat < 1 then
        return;
    end if;

    l_value_length := dbms_lob.getLength(i_value);
    if l_value_length = 0 then
        return;
    end if;

    --
    if l_value_length <= 32767 then
        l_value_short := i_value;
    end if;

    for i in 1..i_repeat loop
        if i_delimiter is not null and i > 1 then
            pragma inline(aux_append_small$,'YES');
            self.aux_append_small$(i_delimiter);
        end if;

        if l_value_length > 32767 then
            self.fsync();
            dbms_lob.append(self.the_value$, i_value);
        elsif l_value_length > 0 then
            pragma inline(aux_append_small$,'YES');
            self.aux_append_small$(l_value_short);
        end if;
    end loop;
end;


member procedure append
    ( i_value                       in phr_clob
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
is
begin
    if i_value is null or i_repeat is null or i_repeat < 1 then
        return;
    end if;

    pragma inline(append, 'YES');
    self.append(
        i_value => i_value.get_value(),
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
end;


member procedure append
    ( i_value                       in bfile
    , i_repeat                      in simple_integer default 1
    , i_delimiter                   in varchar2 default null )
is
    l_infile                        bfile := i_value;
    c_explicitly_open_the_infile    constant boolean := dbms_lob.isOpen(l_infile) = 0;
    l_infile_size                  integer;
    l_buf_short                     varchar2(32767);
    l_buf_long                      clob;
    l_dest_offset                   integer := 1;
    l_src_offset                    integer := 1;
    l_lng_ctx                       integer := dbms_lob.DEFAULT_LANG_CTX;
    l_lng_warn                      integer;
    c_lng_csid                      constant integer := nvl(nls_charset_id(self.raw_conversion_charset$), dbms_lob.DEFAULT_CSID);
begin
    if c_explicitly_open_the_infile then
        dbms_lob.open(l_infile, dbms_lob.FILE_READONLY);
    end if;
    l_infile_size := dbms_lob.getLength(l_infile);

    if l_infile_size <= 32767 then
        dbms_lob.loadClobFromFile(
            dest_lob => l_buf_short,
            src_bfile => l_infile,
            amount => dbms_lob.LOBMAXSIZE,
            dest_offset => l_dest_offset,
            src_offset => l_src_offset,
                bfile_csid => c_lng_csid,
                lang_context => l_lng_ctx,
                warning => l_lng_warn
        );
        self.append(
            i_value => l_buf_short,
            i_repeat => i_repeat,
            i_delimiter => i_delimiter
        );
    elsif self.buffering_level$ >= 2 and l_infile_size <= self.secondary_buffer_size$ then
        begin
            dbms_lob.createTemporary(
                lob_loc => l_buf_long,
                cache => true,
                dur => dbms_lob.CALL
            );
            dbms_lob.loadClobFromFile(
                dest_lob => l_buf_long,
                src_bfile => l_infile,
                amount => dbms_lob.LOBMAXSIZE,
                dest_offset => l_dest_offset,
                src_offset => l_src_offset,
                bfile_csid => c_lng_csid,
                lang_context => l_lng_ctx,
                warning => l_lng_warn
            );
            self.append(
                i_value => l_buf_long,
                i_repeat => i_repeat,
                i_delimiter => i_delimiter
            );
            dbms_lob.freeTemporary(l_buf_long);
        exception
            when others then
                if dbms_lob.isTemporary(l_buf_long) = 1 then
                    dbms_lob.freeTemporary(l_buf_long);
                end if;
                raise;
        end;
    else
        for i in 1..i_repeat loop
            self.fsync();
            l_dest_offset := self.length() + 1;
            l_src_offset := 1;

            dbms_lob.loadClobFromFile(
                dest_lob => self.the_value$,
                src_bfile => l_infile,
                amount => dbms_lob.LOBMAXSIZE,
                dest_offset => l_dest_offset,
                src_offset => l_src_offset,
                bfile_csid => c_lng_csid,
                lang_context => l_lng_ctx,
                warning => l_lng_warn
            );

            if i_delimiter is not null and i > 1 and i < i_repeat then
                self.append(i_delimiter);
            end if;
        end loop;
    end if;

    if c_explicitly_open_the_infile then
        dbms_lob.close(l_infile);
    end if;
exception
    when others then
        if c_explicitly_open_the_infile then
            dbms_lob.close(l_infile);
        end if;
        raise;
end;


member procedure append
    ( i_values                      in arr_varchar2
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2 )
is
    i                               pls_integer;
begin
    if i_values is not null then
        i := i_values.first();
        while i is not null loop
            if i_delimiter is not null and i > i_values.first() then
                pragma inline(aux_append_small$, 'YES');
                self.aux_append_small$(i_delimiter);
            end if;

            if i_value_prefix is not null then
                pragma inline(aux_append_small$, 'YES');
                self.aux_append_small$(i_value_prefix);
            end if;

            pragma inline(aux_append_small$, 'YES');
            self.aux_append_small$(i_values(i));

            if i_value_suffix is not null then
                pragma inline(aux_append_small$, 'YES');
                self.aux_append_small$(i_value_suffix);
            end if;

            i := i_values.next(i);
        end loop;
    end if;
end;


member procedure append
    ( i_values                      in arr_clob
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2 )
is
    i                               pls_integer;
begin
    if i_values is not null then
        i := i_values.first();
        while i is not null loop
            if i_delimiter is not null and i > i_values.first() then
                pragma inline(append, 'YES');
                self.append(i_delimiter);
            end if;

            if i_value_prefix is not null then
                pragma inline(append, 'YES');
                self.append(i_value_prefix);
            end if;

            pragma inline(append, 'YES');
            self.append(i_values(i));

            if i_value_suffix is not null then
                pragma inline(append, 'YES');
                self.append(i_value_suffix);
            end if;

            i := i_values.next(i);
        end loop;
    end if;
end;


member procedure append
    ( i_values                      in sys_refcursor
    , i_delimiter                   in varchar2
    , i_batch_size                  in simple_integer
    , i_fetch_to_lobs               in boolean
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2 )
is
    type arr_values_lob             is table of clob index by simple_integer;
    l_values_lob                    arr_values_lob;
    type arr_values_small           is table of varchar2(4000) index by simple_integer;
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
                    pragma inline(aux_append_small$, 'YES');
                    self.aux_append_small$(i_delimiter);
                else
                    l_is_first_row := false;
                end if;

                if i_value_prefix is not null then
                    pragma inline(aux_append_small$, 'YES');
                    self.aux_append_small$(i_value_prefix);
                end if;

                pragma inline(append, 'YES');
                self.append(l_values_lob(i));

                if i_value_suffix is not null then
                    pragma inline(aux_append_small$, 'YES');
                    self.aux_append_small$(i_value_suffix);
                end if;
            end loop;
        else
            fetch i_values
                bulk collect into l_values_small
                limit i_batch_size;
            exit when l_values_small.count() <= 0;

            for i in 1..l_values_small.last() loop
                if i_delimiter is not null and not l_is_first_row then
                    pragma inline(aux_append_small$, 'YES');
                    self.aux_append_small$(i_delimiter);
                else
                    l_is_first_row := false;
                end if;

                if i_value_prefix is not null then
                    pragma inline(aux_append_small$, 'YES');
                    self.aux_append_small$(i_value_prefix);
                end if;

                pragma inline(aux_append_small$, 'YES');
                self.aux_append_small$(l_values_small(i));

                if i_value_suffix is not null then
                    pragma inline(aux_append_small$, 'YES');
                    self.aux_append_small$(i_value_suffix);
                end if;
            end loop;
        end if;

        exit when i_values%notfound;
    end loop;

    close i_values;
end;

----------------------------------------------------------------------------------------------------

member function append
    ( i_value                       in varchar2
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
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
    ( i_value                       in clob
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
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
    ( i_value                       in bfile
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
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
    ( i_value                       in phr_clob
    , i_repeat                      in simple_integer
    , i_delimiter                   in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
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
    ( i_values                      in arr_varchar2
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
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
    ( i_values                      in arr_clob
    , i_delimiter                   in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
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
    , i_delimiter                   in varchar2
    , i_batch_size                  in simple_integer
    , i_fetch_to_lobs               in boolean
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
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
    , i_delimiter                   in varchar2
    , i_batch_size                  in simple_integer
    , i_fetch_to_lobs               in varchar2
    , i_value_prefix                in varchar2
    , i_value_suffix                in varchar2 )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
begin
    pragma inline(append, 'YES');
    l_new_lob.append(
        i_values => i_values,
        i_delimiter => i_delimiter,
        i_batch_size => i_batch_size,
        i_fetch_to_lobs => lower(i_fetch_to_lobs) in ('y','yes','1','true'),
        i_value_prefix => i_value_prefix,
        i_value_suffix => i_value_suffix
    );

    return l_new_lob;
end;

----------------------------------------------------------------------------------------------------

member procedure appendln
    ( i_value                       in varchar2 default null )
is
begin
    if i_value is not null then
        pragma inline(append, 'YES');
        self.append(i_value);
    end if;

    if self.eoln$ is not null then
        pragma inline(append, 'YES');
        self.append(self.eoln$);
    end if;
end;


member function appendln
    ( i_value                       in varchar2 default null )
    return phr_clob
is
    l_new_lob                       phr_clob := self;
begin
    pragma inline(appendln, 'YES');
    l_new_lob.appendln(i_value);

    return l_new_lob;
end;

----------------------------------------------------------------------------------------------------

member function compare
    ( i_lob_2                       in phr_clob
    , i_compare_lengths_first       in boolean )
    return number
    parallel_enable
is
    l_result                        number;
    l_len_1                         integer;
    l_len_2                         integer;
begin
    if i_lob_2 is null then
        return null;
    end if;

    if i_compare_lengths_first then
        l_len_1 := self.length();
        l_len_2 := i_lob_2.length();

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
    ( i_lob_2                       in phr_clob
    , i_compare_lengths_first       in varchar2 )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => i_lob_2,
        i_compare_lengths_first => lower(i_compare_lengths_first) in ('y','yes','1','true')
    );
end;


member function compare
    ( i_lob_2                       in clob
    , i_compare_lengths_first       in boolean )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => phr_clob.use_lob(i_lob_2),
        i_compare_lengths_first => i_compare_lengths_first
    );
end;


member function compare
    ( i_lob_2                       in clob
    , i_compare_lengths_first       in varchar2 )
    return number
    parallel_enable
is
begin
    pragma inline(compare, 'YES');
    return self.compare(
        i_lob_2 => phr_clob.use_lob(i_lob_2),
        i_compare_lengths_first => i_compare_lengths_first
    );
end;


order member function order$
    ( i_lob_2                       in phr_clob )
    return number
    parallel_enable
is
begin
    return self.compare(
        i_lob_2 => i_lob_2,
        i_compare_lengths_first => true
    );
end;

----------------------------------------------------------------------------------------------------

member function subStr
    ( i_from                        in integer
    , i_length                      in pls_integer )
    return varchar2
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
    ( i_needle                      in varchar2
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

member procedure set_raw_conversion_charset
    ( i_charset                     in varchar2 )
is
begin
    self.raw_conversion_charset$ := i_charset;
end;


member function with_raw_conversion_charset
    ( i_charset                     in varchar2 )
    return phr_clob
is
    l_result                        phr_clob;
begin
    l_result := self;
    l_result.set_raw_conversion_charset(i_charset);
    return l_result;
end;


member procedure append_raw
    ( i_value                       in raw
    , i_repeat                      in simple_integer
    , i_delimiter                   in raw )
is
begin
    if self.raw_conversion_charset$ is null then
        raise_application_error(phr_anylob_exc.CE_Invalid_Argument, 'No RAW conversion charset specified');
    end if;

    pragma inline(append, 'YES');
    self.append(
        i_value => utl_i18n.raw_to_char(
            data => i_value,
            src_charset => self.raw_conversion_charset$
        ),
        i_repeat => i_repeat,
        i_delimiter => utl_i18n.raw_to_char(
            data => i_delimiter,
            src_charset => self.raw_conversion_charset$
        )
    );
end;


member function append_raw
    ( i_value                       in raw
    , i_repeat                      in simple_integer
    , i_delimiter                   in raw )
    return phr_clob
is
    l_result                        phr_clob := self;
begin
    pragma inline(append, 'YES');
    l_result.append_raw(
        i_value => i_value,
        i_repeat => i_repeat,
        i_delimiter => i_delimiter
    );
    return l_result;
end;

----------------------------------------------------------------------------------------------------

member procedure fragment_delete
    ( i_offset                      in integer
    , i_amount                      in integer )
is
    c_trailing_chunk_offset         constant integer := i_offset + i_amount;
    c_lob_length                    constant integer := self.length();
begin
    if i_amount = 0 then
        return;
    elsif i_offset < 0 then
        raise_application_error(phr_anylob_exc.CE_Invalid_Argument, 'Negative I_OFFSET of "'||i_offset||'"');
    elsif i_offset is null then
        raise_application_error(phr_anylob_exc.CE_Invalid_Argument, 'NULL I_OFFSET');
    elsif i_amount < 0 then
        raise_application_error(phr_anylob_exc.CE_Invalid_Argument, 'Negative I_AMOUNT of "'||i_amount||'"');
    elsif i_amount is null then
        raise_application_error(phr_anylob_exc.CE_Invalid_Argument, 'NULL I_AMOUNT');
    end if;

    --
    if self.is_secure_file() then
        $if utl_ident.is_oracle_server $then
            pragma inline(fsync, 'YES');
            self.fsync();

            dbms_lob.fragment_delete(
                lob_loc => self.the_value$,
                amount => i_amount,
                offset => i_offset
            );
        $else
            raise_application_error(phr_anylob_exc.CE_Not_Implemented, 'Cannot call dbms_lob.fragment_delete() outside of Oracle server');
        $end
    elsif c_trailing_chunk_offset <= c_lob_length then
        pragma inline(fsync, 'YES');
        self.fsync();

        dbms_lob.copy(
            src_lob => self.the_value$,
            src_offset => c_trailing_chunk_offset,
            dest_lob => self.the_value$,
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
    return phr_clob
is
    l_result                        phr_clob := self;
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
    return phr_clob
is
    l_result                        phr_clob := self;
begin
    pragma inline(fragment_delete_between, 'YES');
    l_result.fragment_delete_between(
        i_from => i_from,
        i_to => i_to
    );
    return l_result;
end;


member procedure fragment_delete_from_to
    ( i_from                        in varchar2
    , i_to                          in varchar2
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

            l_chunk.to_ix := l_chunk.to_ix + sys.standard.length(i_to) - 1;
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
    ( i_from                        in varchar2
    , i_to                          in varchar2
    , i_max_iterations              in simple_integer default 1 )
    return phr_clob
is
    l_result                        phr_clob := self;
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
