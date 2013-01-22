import json, re, os

os.chdir(os.path.dirname(__file__))
path = open("language_agnostic_test_path").read().strip()

import ast
tree = ast.parse(open(path).read())

for x in tree.body:
  if isinstance(x, ast.Expr) and isinstance(x.value, ast.Str):
    docstring = ast.literal_eval(x.value)

docstring = re.sub('#.*$', '', docstring, flags=re.M)

index = 0

cases = {}
iii = 1
for fixture in docstring.split('r"""'):
    doc, _, body = fixture.partition('"""')
    runs = []
    for case in body.split('$')[1:]:
        index += 1
        argv, _, expect = case.strip().partition('\n')
        prog, _, argv = argv.strip().partition(' ')
        assert prog == 'prog', repr(prog)
        try:
          py_expect = json.loads(expect)
          runs += [{"expect": py_expect, "prog": argv}]
        except:
          pass
    cases["agnostic_%d" % iii] = {"usage": doc, "runs": runs}
    iii+=1

print json.dumps(cases)
