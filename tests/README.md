# MySQL grammar tests

Small `.sql` inputs are paired with `.sexpr` files containing the expected
parse tree or parse-error diagnostic. Tests use Iguana's native golden-file
workflow, as in the Java grammar repository. SQL is parsed, never executed.

## Run tests

From the repository root, after building `iguana-mysql`:

```sh
build/iguana/target/debug/iguana-mysql --dir tests/queries --ext sql --start Queries --check-sexpr
build/iguana/target/debug/iguana-mysql --dir tests/expressions --ext sql --start Expression --check-sexpr
build/iguana/target/debug/iguana-mysql --dir tests/query-expression-parens --ext sql --start QueryExpressionParens --check-sexpr
```

The directories determine the start symbol. No manifest or custom test runner
is required. Exact tree comparisons detect changes in precedence, grouping,
lexical choices and ambiguity; diagnostic snapshots preserve expected errors.

## Add or update a test

Add a focused `.sql` input to the directory for its start symbol. Check the
expected interpretation against MySQL's reference or parser rules, then inspect
the parser output. Write the expected snapshot with the native command:

```sh
build/iguana/target/debug/iguana-mysql tests/queries/Select.sql --start Queries --regenerate-sexpr
```

Replace the example path and start symbol with those of the fixture being
reviewed. Review the `.sexpr` change before accepting it, especially whether
it represents success or failure and how expressions are grouped. Snapshot
regeneration records current behavior; it does not establish correctness.
Run the directory checks afterward. Use `--full-diff` to inspect long diffs.

Fixtures cover lexical forms, expressions, queries, joins, set operations,
data changes, schema definitions, stored programs, transactions, privileges
and administration. `Regression_` fixtures retain focused cases from earlier
ambiguity and conformance investigations.
