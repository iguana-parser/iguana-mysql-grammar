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

Identifiers use one lexical word token per keyword context, with a separate
backtick alternative. An empty `IdentifierContextGuard` checks `!>>` restrictions
at the beginning of the word, preserving adjacent function-call, string-prefix,
and signed-exponent distinctions. This makes the identifier rules LL(1).
Eight shared word classes define keyword membership. Each identifier context
derives its exclusions from these classes. The grammar is standalone and can
be edited manually; moving a keyword changes only its class membership.
Adding or changing a spelling requires updating its terminal and class entry,
including any corresponding function-call token.

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
checkout and a CLI built from that same revision, set `IGUANA_SRC` to the source
directory. The checkout must be clean and match the CLI revision. Replace the
placeholder below with its absolute path:

```sh
IGUANA_SRC=/absolute/path/to/iguana-rs
"$IGUANA_SRC/target/release/iguana" generate --grammar mysql.iggy --output build/iguana \
  --runtime-path "$IGUANA_SRC/iguana-runtime" \
  --bin-name iguana-mysql
cargo build --manifest-path build/iguana/Cargo.toml
```

The tested Iguana version is `v0.1.0-alpha.4`
(`538f94524fbd4fea3f27837eabced5cc8b53c181`).
Generation uses default settings, including match memoization. Add
`--first-parse true` to generate the first-parse version with the other
settings unchanged.
Generated Rust sources and build output are kept under `build/`.

Run the optional keyword consistency check before regenerating golden files:

```sh
python3 scripts/check_keyword_classes.py
```

It checks terminal and class spellings, aliases, case variants and overlapping
classes. It does not generate grammar content or determine whether a keyword
belongs in the correct MySQL context. Golden tests check representative words
from every class in each identifier context, rather than exhaustive MySQL
conformance.

The repository has golden-file tests for individual language features,
including expected parse trees and rejected inputs:

```sh
build/iguana/target/debug/iguana-mysql --dir tests/queries --ext sql --start Queries --check-sexpr
build/iguana/target/debug/iguana-mysql --dir tests/expressions --ext sql --start Expression --check-sexpr
build/iguana/target/debug/iguana-mysql --dir tests/query-expression-parens --ext sql --start QueryExpressionParens --check-sexpr
(
  for start in Identifier LabelIdentifier RoleIdentifier LValueIdentifier UnquotedIdentifier UnqualifiedFunctionName; do
    build/iguana/target/debug/iguana-mysql --dir "tests/keyword-contexts/$start" --ext sql --start "$start" --check-sexpr || exit 1
  done
)
```

`tests/keyword-contexts` checks one fixed word from each of the eight classes
directly against these rules, plus ordinary and backticked controls. Rejected
inputs are separate files so one error cannot hide later cases. Query tests
also cover the same classes in `SET ROLE` and `GRANT` statements (where
privilege alternatives can accept words rejected as role identifiers), and the
adjacent-parenthesis distinction for contextual function spellings.

The default corpus is listed in [`corpus/repos.txt`](corpus/repos.txt).
See [`corpus/README.md`](corpus/README.md) for the current cached-file scope.
Run one benchmark pass with a release build:

```sh
cargo build --release --manifest-path build/iguana/Cargo.toml --bin iguana-mysql
build/iguana/target/release/iguana-mysql --benchmark --iters 1 --warmup 0 --save build/corpus-benchmark.json
```

See [Developing grammars](https://iguana-parser.org/grammars/) for Iguana's
grammar and test workflow.
