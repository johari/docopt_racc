import re
import sys, json, re, os
from subprocess import Popen, PIPE, STDOUT

os.chdir(os.path.dirname(__file__))
path = open("language_agnostic_test_path").read().strip()
pattern = re.compile("'''((?:.|\n)*)'''")
# print open(path).read()
docstring = pattern.search(open(path).read()).group(1)

index = 0
testee = "ruby ../test/testee.rb"
summary = ""
only = skip = []
show = ["json", "pass", "fail"]
try:
  skip = [int(x) for x in os.environ["skip"].split(",")]
except:
  pass

try:
  only = [int(x) for x in os.environ["only"].split(",")]
except:
  pass

try:
  show = [x for x in os.environ["show"].split(",")]
except:
  pass

for fixture in docstring.split('r"""'):
    doc, _, body = fixture.partition('"""')
    for case in body.split('$')[1:]:
        index += 1
        if (only and index not in only) or (len(skip)>0 and index <= max(skip)) or index in skip:
            continue
        argv, _, expect = case.strip().partition('\n')
        prog, _, argv = argv.strip().partition(' ')
        assert prog == 'prog', repr(prog)
        p = Popen(testee + ' ' + argv,
                  stdout=PIPE, stdin=PIPE, stderr=PIPE, shell=True)
        com = p.communicate(input=doc)
        result = com[0]
        debug = com[1]
        def foo():
          print 'r"""%s"""' % doc
          print '$ prog %s\n' % argv
          print 'result>', result
          print 'expect>', expect
          print 'debug <<<'
          print debug
          print '>>>'

        try:
            py_result = json.loads(result)
            py_expect = json.loads(expect)
        except:
            summary += 'J'
            if "json" in show:
              print (' %d: BAD JSON ' % index).center(79, '=')
              foo()
              if p.returncode != 0:
                if index not in skip:
                  exit()
            continue

        if py_result == py_expect:
            summary += '.'
            if "pass" in show:
              print (' %d: PASSED ' % index).center(79, '=')
              foo()
        else:
            summary += 'F'
            if "fail" in show:
              print (' %d: FAILED ' % index).center(79, '=')
              foo()

print (' %d / %d ' % (summary.count('.'), len(summary))).center(79, '=')
print summary
