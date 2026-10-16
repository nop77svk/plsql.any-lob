# Peter's AnyLOB wrappers

Object-oriented, buffered builders for Oracle `CLOB`, `NCLOB` and `BLOB` values, written in PL/SQL.

Each of `phr_clob`, `phr_nclob` and `phr_blob` is an Oracle object type wrapping a LOB locator together with an in-memory write buffer. It gives you a single, uniform API for creating temporary LOBs, appending to them cheaply, reading, searching and trimming them, and managing their lifecycle, without hand-written `DBMS_LOB` plumbing.

Part of *Peter's PL/SQL foundation* ([LOB builders](http://peterhrasko.wordpress.com/peters-plsql-foundation/lob-builders)).

## Features

- **Buffered appends** at three levels, selectable per instance:
  - non-buffered (every append goes straight to the LOB),
  - double buffering (a `VARCHAR2`/`RAW` buffer is flushed to the LOB when it reaches the small/large switch threshold),
  - tripple buffering (an additional, configurable-size secondary LOB buffer).
- **Factories** for temporary LOBs: `new_tmp_lob`, `init_tmp_lob` (from a `VARCHAR2`/`RAW`, or a deep copy of a LOB, with optional repeat count and delimiter) and `use_lob` (wrap an existing LOB locator).
- **Fluent builders** returning a configured copy of the instance: `nonbuffered`, `double_buffered`, `tripple_buffered`, `with_eoln`, `with_raw_conversion_charset`.
- **Line appends** via `appendln` with a configurable end-of-line string.
- **Read/inspect**: `length`, `is_empty`, `get_value`, `subStr`, `inStr`, `compare`, `is_persistent`, `is_secure_file`.
- **Modify**: `append` (overloads for `VARCHAR2`/`RAW`, LOBs and `BFILE`), `append_raw`, `trim`, `copy_to`, `fragment_delete`, `fragment_delete_between`, `fragment_delete_from_to`.
- **Lifecycle control**: `fsync` (flush pending buffers), `tmp_dispose`, `tmp_reinitialize`, `tmp_initialize`.
- Overloads taking `VARCHAR2` flags (`'Y'`/`'N'`) in addition to `BOOLEAN`, so the API is callable from SQL.

A short usage sketch:

```sql
declare
    l_clob phr_clob := phr_clob.new_tmp_lob();
begin
    l_clob.use_eoln(chr(10));
    l_clob.appendln('first line');
    l_clob.appendln('second line');
    dbms_output.put_line(l_clob.length());
    dbms_output.put_line(l_clob.get_value());
end;
/
```

Method-level documentation (parameters, usage notes, raised exceptions, NULL handling) lives in the comments of the type specification, [src/phr_anylob.typ](src/phr_anylob.typ).

## Repository layout

| Path | Contents |
| ---- | -------- |
| [src/phr_anylob.typ](src/phr_anylob.typ) | Single source template of the type, parametrized by `${...}` placeholders |
| [src/phr_anylob.typ.awk](src/phr_anylob.typ.awk) | Per-LOB-class placeholder definitions (CLOB / NCLOB / BLOB) |
| [src/phr_anylob.typ.sh](src/phr_anylob.typ.sh) | Generator of the three concrete types |
| [src/generated/](src/generated) | Generated `phr_clob.typ`, `phr_nclob.typ`, `phr_blob.typ` (what you actually install) |
| [src/install/](src/install) | Installation helpers: prerequisites, native compilation, cleanup |
| [tests/templates/](tests/templates) | Test templates, one per method or method family |
| [tests/phr_anylob.tst.awk](tests/phr_anylob.tst.awk), [tests/phr_anylob.tst.sh](tests/phr_anylob.tst.sh) | Test generator |
| [tests/generated/](tests/generated) | Generated PL/SQL Developer test scripts (`.tst`) per LOB class |
| [tests/all-tests.ts](tests/all-tests.ts) | PL/SQL Developer test set running all generated tests |
| [tests/phr_anylob.test.sql](tests/phr_anylob.test.sql) | Standalone SQL*Plus/SQLcl smoke test printing PASS/FAIL per check |

## Requirements

- Oracle Database with `DBMS_LOB` and `UTL_I18N` (used for SecureFile/BasicFile detection and charset-aware raw conversion).
- Two helper packages from *Peter's PL/SQL foundation* that are **not** part of this repository and must exist in the target schema: `phr_utl_boolean` (SQL-boolean conversion) and `phr_utl_exc` (exception helpers).
- To regenerate sources: a Bash environment (Cygwin, Git Bash, WSL or Linux) with `gawk`.

## Installation

1. Run [src/install/prerequisites.sql](src/install/prerequisites.sql) to create the collection types (`arr_clob`, `arr_nclob`, `arr_blob`, `arr_varchar2`, `arr_nvarchar2`, `arr_raw`).
2. Make sure `phr_utl_boolean` and `phr_utl_exc` are installed.
3. Run the generated type scripts, each one followed by `/` if your client needs it:
   - [src/generated/phr_clob.typ](src/generated/phr_clob.typ)
   - [src/generated/phr_nclob.typ](src/generated/phr_nclob.typ)
   - [src/generated/phr_blob.typ](src/generated/phr_blob.typ)
4. Optionally run [src/install/_native compile.sql](src/install/_native%20compile.sql) to recompile the types natively with optimization level 3.

To uninstall, run [src/install/_cleanup.sql](src/install/_cleanup.sql).

## Regenerating the types and tests

The three LOB classes share one template, so **do not edit the files in `generated/` by hand**. Change the template, then regenerate:

```bash
./src/phr_anylob.typ.sh
./tests/phr_anylob.tst.sh
```

## Testing

- Run [tests/phr_anylob.test.sql](tests/phr_anylob.test.sql) from SQL*Plus or SQLcl in a schema where the types are installed. It needs no framework and fails the script on the first failing check.
- Open [tests/all-tests.ts](tests/all-tests.ts) in PL/SQL Developer's Test Manager to run the generated suite for all three classes. It covers happy paths, pessimistic paths and edge cases (pending buffers, `NULL` locators, `NULL` objects, LOBs over the buffer threshold).

## Notes

- A persistent LOB locator is a pointer to the stored LOB: writes made through the object and through the original locator hit the same LOB. A temporary LOB is copied by Oracle on assignment. See `use_lob` and `get_value` in the type specification.
- Appends may be buffered. `length` and `get_value` account for pending appends, but call `fsync` (or switch the buffering level) before touching the underlying LOB directly.
- The `BFILE` append overloads exist in the types but are not covered by the generated tests.

## License

See [LICENSE](LICENSE).
