<h1 align="center">MySQL grammar for Iguana</h1>

A MySQL grammar for
[Iguana](https://github.com/iguana-parser/iguana-rs), written in
[Iggy](https://iguana-parser.org/docs/grammar-definition/).
The grammar is defined in [`mysql.iggy`](mysql.iggy), with syntax and
interpretations checked against Oracle's
[MySQL Reference Manual](https://dev.mysql.com/doc/refman/8.4/en/) and the
[MySQL 8.2 parser](https://github.com/mysql/mysql-server/blob/mysql-8.2.0/sql/sql_yacc.yy).

The grammar has three notable design choices:

- **Expressions** use natural recursive rules. Precedence and associativity
  select the intended tree without splitting expressions into a hierarchy of
  nonterminals. Set operations use the same approach. The
  [disambiguation documentation](https://iguana-parser.org/docs/grammar-definition/disambiguation/)
  explains the notation.
- **Layout** handles whitespace and MySQL's block, hash and dash comments.
  Follow restrictions prevent layout from stopping while another whitespace
  or comment token remains. See the
  [layout documentation](https://iguana-parser.org/docs/grammar-definition/layout/).
- **Contextual keywords** and function names are recognized according to their
  position. Lexical restrictions handle keyword boundaries and distinguish
  identifiers from function calls. The
  [single-phase parsing documentation](https://iguana-parser.org/docs/concepts/single-phase-parsing/)
  explains how token matching follows the grammar context.

## Scope

The grammar targets MySQL 8.2 with default SQL syntax modes. Double quotes
delimit strings and backticks delimit identifiers; `SET sql_mode` does not
change the parsing mode. Start symbols are `Queries` for scripts,
`SimpleStatement` for a statement, and `Expression` for an expression.

It follows MySQL syntax within this profile, but is not an exact conformance
validator. Some context-dependent restrictions, including certain `INTO`
placements and subqueries in `PURGE ... BEFORE`, remain permissive, as do a
few quoted option values and NUL in backtick identifiers. Some extensions
beyond MySQL 8.2 Community, including `QUALIFY` and `TABLESAMPLE`, are accepted.
Executable comments and client commands such as `DELIMITER` require separate
handling. Server semantic validation is outside the grammar's scope.

## Build and tests

The parser is generated from [`mysql.iggy`](mysql.iggy). With an Iguana source
checkout at `build/iguana-upstream` and a CLI built from that same revision:

```sh
iguana generate --grammar mysql.iggy --output build/iguana \
  --runtime-path "$PWD/build/iguana-upstream/iguana-runtime" \
  --bin-name iguana-mysql --match-memo false --format false
cargo build --manifest-path build/iguana/Cargo.toml
```

The tested Iguana revision is `52e2a6dd1a72d48f745876b39add86458e916f33`.
Generated Rust sources and build output are kept under `build/`.

The repository has golden-file tests for individual language features,
including expected parse trees and rejected inputs:

```sh
build/iguana/target/debug/iguana-mysql --dir tests/queries --ext sql --start Queries --check-sexpr
build/iguana/target/debug/iguana-mysql --dir tests/expressions --ext sql --start Expression --check-sexpr
build/iguana/target/debug/iguana-mysql --dir tests/query-expression-parens --ext sql --start QueryExpressionParens --check-sexpr
```

The default corpus is listed in [`corpus/repos.txt`](corpus/repos.txt).
See [`corpus/README.md`](corpus/README.md) for the current cached-file scope.
Run one benchmark pass with a release build:

```sh
cargo build --release --manifest-path build/iguana/Cargo.toml --bin iguana-mysql
build/iguana/target/release/iguana-mysql --benchmark --iters 1 --warmup 0 --save build/corpus-benchmark.json
```

See [Developing grammars](https://iguana-parser.org/grammars/) for Iguana's
grammar and test workflow.
