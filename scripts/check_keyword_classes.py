"""Check keyword spelling coverage, case classes, aliases and class overlap.

This is a development check, not a generator or a parser dependency. It reads
the finite word regexes used by keyword terminals and the eight word classes;
it does not try to interpret arbitrary Iggy regexes or validate classification
against MySQL. Run before regenerating golden files.

Keyword terminals follow the grammar's uppercase naming convention, including
*_CALL_OPEN tokens. Mixed-case rules such as SourceCountWord, JsonFormatWord,
RedoLogNameWord and TemporalKeyword describe context-specific spellings and
are intentionally outside this check.
"""

import argparse
from functools import lru_cache
import json
from pathlib import Path
import re


CLASSES = (
    "ReservedWord", "UnambiguousKeywordWord", "Ambiguous1Word", "Ambiguous2Word",
    "Ambiguous3Word", "Ambiguous4Word", "FunctionOnlyWord", "ContextualKeywordWord",
)
RULE = re.compile(r"(?m)^([A-Za-z][A-Za-z0-9_]*)[ \t]*(?:\n[ \t]+)?="
                  r"[^\n]*(?:\n[ \t]+[^\n]+)*")
TOKEN = re.compile(r'"(?:\\.|[^"\\])*"|\[[^\]]*\]|//[^\n]*|[A-Za-z][A-Za-z0-9_]*|[^\s]')
BOUNDARY = " !>> IdentifierPart"


def check(source):
    rules = {match[1]: match.group().split("=", 1)[1].strip()
             for match in RULE.finditer(source)}

    # A spelling is a tuple of character sets. This preserves case variants
    # without expanding every combination of upper/lowercase characters.
    def parse(body):
        tokens = [match.group() for match in TOKEN.finditer(body)
                  if not match.group().startswith("//")]
        position = 0

        def alternative():
            nonlocal position
            result = sequence()
            while position < len(tokens) and tokens[position] == "|":
                position += 1
                result |= sequence()
            return result

        def sequence():
            nonlocal position
            result = {()}
            while position < len(tokens) and tokens[position] not in ("|", ")"):
                token = tokens[position]
                position += 1
                if token == "(":
                    part = alternative()
                    if position == len(tokens) or tokens[position] != ")":
                        raise ValueError("Unclosed keyword group")
                    position += 1
                elif token.startswith('"'):
                    part = {tuple(frozenset(char) for char in json.loads(token))}
                elif token.startswith("["):
                    chars = token[1:-1]
                    if not chars or any(char in chars for char in "\\^"):
                        raise ValueError("Unsupported keyword character class: " + token)
                    values = set()
                    index = 0
                    while index < len(chars):
                        if index + 2 < len(chars) and chars[index + 1] == "-":
                            start, end = ord(chars[index]), ord(chars[index + 2])
                            if start > end:
                                raise ValueError("Reversed character range: " + token)
                            values.update(chr(value) for value in range(start, end + 1))
                            index += 3
                        else:
                            values.add(chars[index])
                            index += 1
                    part = {(frozenset(values),)}
                elif token in rules:
                    part = expand(token)
                else:
                    raise ValueError("Unsupported keyword regex token: " + token)
                result = {left + right for left in result for right in part}
            return result

        result = alternative()
        if position != len(tokens):
            raise ValueError("Unexpected keyword regex token: " + tokens[position])
        return result

    @lru_cache(None)
    def expand(name):
        if name not in rules:
            raise ValueError("Missing keyword class: " + name)
        return parse(rules[name])

    def word(shape):
        return bool(shape) and all(char.isalnum() or char == "_"
                                   for cell in shape for char in cell) and any(
            char.isalpha() for cell in shape for char in cell)

    def describe(shape):
        return "".join(next(iter(cell)) if len(cell) == 1 else "[" + "".join(sorted(cell)) + "]"
                       for cell in shape)

    membership = {}
    by_length = {}
    for name in CLASSES:
        for shape in expand(name):
            if not word(shape):
                raise ValueError("Non-word spelling in " + name)
            for previous in by_length.get(len(shape), ()):
                if membership[previous] != name and all(left & right for left, right in zip(shape, previous)):
                    raise ValueError(f"{describe(shape)} overlaps {membership[previous]} and {name}")
            membership[shape] = name
            by_length.setdefault(len(shape), []).append(shape)

    terminals = {}
    for name, body in rules.items():
        if not name.isupper():
            continue
        call = name.endswith("_CALL_OPEN")
        bounded = body.endswith(BOUNDARY)
        try:
            shapes = parse(body[:-len(BOUNDARY)] if bounded else body)
        except ValueError:
            if bounded or call:
                raise ValueError("Cannot read keyword terminal: " + name) from None
            continue  # Punctuation and other non-word terminals are outside this check.
        if call:
            if any(not shape or shape[-1] != frozenset("(") for shape in shapes):
                raise ValueError("Call token must end with '(': " + name)
            shapes = {shape[:-1] for shape in shapes}
        if not all(word(shape) for shape in shapes):
            if bounded or call:
                raise ValueError("Expected keyword spellings in " + name)
            continue
        if not bounded and not call:
            raise ValueError("Keyword terminal lacks !>> IdentifierPart: " + name)
        for shape in shapes:
            terminals.setdefault(shape, set()).add(name)

    missing = terminals.keys() - membership.keys()
    orphaned = membership.keys() - terminals.keys()
    if missing or orphaned:
        errors = [f"Unclassified keyword {describe(shape)} ({', '.join(sorted(terminals[shape]))})"
                  for shape in sorted(missing, key=describe)]
        errors += [f"Class spelling {describe(shape)} ({membership[shape]}) has no keyword terminal"
                   for shape in sorted(orphaned, key=describe)]
        raise ValueError("\n".join(errors))
    return len(terminals)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--grammar", type=Path,
                        default=Path(__file__).resolve().parents[1] / "mysql.iggy")
    args = parser.parse_args()
    try:
        count = check(args.grammar.read_text(encoding="utf-8"))
    except (ValueError, OSError, RecursionError) as error:
        parser.exit(1, str(error) + "\n")
    print(f"OK: {count} keyword spellings agree with {len(CLASSES)} disjoint classes")


if __name__ == "__main__":
    main()
