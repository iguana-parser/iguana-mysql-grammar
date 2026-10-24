# MySQL corpus

Iguana reads `repos.txt` for `--benchmark` and `--corpus-test`, as in the Java
grammar repository. Each row gives a name, extension, start symbol, repository
URL and pinned revision. The default start symbol here is `Queries`.

## Current cache scope

The initial run reuses the existing downloads under `expanded/` through
`.cache/NAME` links. Many downloads contain only selected MySQL paths, not
complete repository checkouts. Their exact selection and source revisions
are recorded in `expanded/sources.json` and per-project `provenance.json` files.
Inputs are unchanged. Invalid fixtures, fragments and other dialect extensions
remain in the selected inputs; failures are reported by the native runner.

The repository format currently filters by extension, not by path or dialect.
Deleting a selected cache and letting Iguana clone its repository can expand
the file set to include other SQL dialects. Do not compare that run with this
selected-cache run as if the input set were unchanged. Path include/exclude
filters in the official corpus configuration would make these selections
reproducible from fresh clones.

`.dump` data loads are not selected by the `.sql` entries. Zabbix is omitted
because the retained download is a release archive without a pinned Git entry.
The old derived, transformed SQL directory is not part of this corpus.

Two read-query workloads were added later. `job` is the Join Order Benchmark,
all `.sql` files of its repository: 113 queries written for PostgreSQL, plus
the schema. `clickbench` selects `mysql/*.sql` of ClickBench: the table
definition and 43 queries, one per line; the other directories are other
database systems.

## One measured pass

Use the release parser from the repository root:

```sh
target/release/iguana-mysql --benchmark --iters 1 --warmup 0 --save target/corpus-benchmark.json
```

Only clean, unambiguous parses contribute to the timing and throughput totals.
One pass gives an initial measurement, not a stable statistical comparison.
