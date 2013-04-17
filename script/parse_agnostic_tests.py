import json, re, os, sys

raw = sys.stdin.read()

# https://github.com/docopt/docopt/blob/682db0bfeafa142d2efd31baa9ffe38bb94455dd/conftest.py

from itertools import combinations_with_replacement

test_names = combinations_with_replacement('fjaln', 5)

def parse_test(raw):
    raw = re.compile('#.*$', re.M).sub('', raw).strip()
    if raw.startswith('"""'):
        raw = raw[3:]

    for fixture in raw.split('r"""'):
        name = "".join(test_names.next())
        doc, _, body = fixture.partition('"""')
        cases = []
        for case in body.split('$')[1:]:
            argv, _, expect = case.strip().partition('\n')
            expect = json.loads(expect)
            prog, _, argv = argv.strip().partition(' ')
            cases.append({"prog": argv, "expect": expect})

        yield name, doc, cases

cases = [(name, {"usage": doc, "runs": cases})
            for name, doc, cases in parse_test(raw)]
cases = dict(cases)

print json.dumps(cases)
