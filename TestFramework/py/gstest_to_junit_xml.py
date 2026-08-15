#!/usr/bin/env python3
# vim: ts=2 sw=2 et ai mouse=: expandtab:
"""Parse GNUstep TestFramework's outputs and produce a JUnit XML file.

An example of the schema used for JUnit test files can be found in this
Apache-licensed .xsd file:

  https://github.com/windyroad/JUnit-Schema/blob/cfa434d4b8e102a8f55b8727b552a0063ee9044e/JUnit.xsd

which is not included here nor depended on for simplicity of implementation and
avoidance of licensing doubt.

There are existing packages for generating these (pypi has junit-xml), but this
code avoids pulling in any extra dependencies.

Note:
This is a prototype. Dependencies are kept to a minimum (a version of Python 3)
even if integration into gnustep-tests is optional. Ideally the program would
be written using GNUstep Base rather than Python.

   
Written by: Ivan Vucica <ivan@vucica.net>
Copyright (C) 2025 Free Software Foundation, Inc.
 
   This package is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.
"""

import abc
import dataclasses
import datetime
import re
import sys
import typing

from collections import abc as cabc
from xml.etree import ElementTree as ET

if typing.TYPE_CHECKING:
  import io


class JUnitTestResults(object):
  """Represents the entire XML file containing the JUnit test results."""

  # Note: technically the root element can maybe also be a JUnitTestSuite.
  # We won't do it, but we can allow it. Therefore, let's declare it as
  # a class that can contain testsuite nodes as its children.
  _root: '_JUnitTestSuiteContainer'

  def __init__(self, use_testsuites_as_root: bool = True):
    """Initialize an empty XML document containing the JUnit test results.

    Args:
      use_testsuites_as_root: whether to present testsuites 
    """
    super().__init__()
    if use_testsuites_as_root:
      self._root = JUnitTestSuites()

  @property
  def root(self) -> '_JUnitTestSuiteContainer':
    """Return the object representing the root node of the results XML."""
    return self._root

  @root.setter
  def root(self, new_root: '_JUnitTestSuiteContainer') -> None:
    """Reset the root node to contain a different class instead.

    Args:
      new_root: either a node representing testsuites or testsuite.
    """
    self._root = new_root

  def AsString(self) -> str:
    """Return the results as a string containing the JUnit results XML."""
    return '<?xml version="1.0"?>' + self._root.AsString()

  def __str__(self) -> str:
    return self.AsString()


class _JUnitTestSuiteContainer(abc.ABC):
  """A class that can contain JUnitTestSuites."""
  @property
  @abc.abstractmethod
  def test_suite_list(self) -> cabc.Iterable['JUnitTestSuite']:
    ...

  @abc.abstractmethod
  def add_test_suite(self, ts: 'JUnitTestSuite'):
    ...

  @abc.abstractmethod
  def XMLNode(self) -> ET.Element:
    """Return the node and its attributes, but without children.

    Returns:
      a newly constructed XML node
    """
    ...

  def AsXMLNode(self) -> ET.Element:
    """Return the node, its attributes and children.

    Returns:
      a newly constructed XML node with testsuite elements as children
    """
    n: ET.Element = self.XMLNode()
    # n.extend(ts.AsXMLNode() for ts in self.test_suite_list)
    n.extend([ts.AsXMLNode() for ts in self.test_suite_list])
    return n

  def AsString(self) -> str:
    """Return the node, its attributes and children as a single str."""
    #return ET.tostring(self.AsXMLNode(), encoding='utf-8')
    return ET.tostring(self.AsXMLNode()).decode('utf-8')

  def __str__(self):
    return self.AsString()

  def AsBytes(self) -> bytes:
    """Return the node, its attributes and children as a single bytes."""
    return ET.tostring(self.AsXMLNode())

  def __bytes__(self):
    return self.AsBytes()


class JUnitTestSuites(_JUnitTestSuiteContainer):
  """Class representing the <testsuites> root element."""

  _testsuites: list[typing.Union['JUnitTestSuite', 'JUnitPackageTestSuite']]
  _timestamp: datetime.datetime

  def __init__(self, tstamp: datetime.datetime|None = None):
    super().__init__()
    if tstamp is None:
      tstamp = datetime.datetime.now()
    self._timestamp = tstamp
    self._testsuites: list['JUnitTestSuite'] = []

  @property
  def test_suite_list(self):
    return self._testsuites
  # No @test_suite_list.setter. Use add_test_suite only.

  def XMLNode(self) -> ET.Element:
    e = ET.Element('testsuites', attrib={
      # ISO8601. Some schemas demand it to be without the timezone.
      'timestamp': self._timestamp.isoformat(),
    })
    return e
  
  def add_test_suite(self, ts: typing.Union['JUnitTestSuite', 'JUnitPackageTestSuite']):
    self._testsuites.append(ts)


@dataclasses.dataclass
class JUnitTestSuiteProperty:
  """A single property of a testsuite."""
  # Potentially replaceable by a tuple or a named tuple.
  # This is slightly more informative typewise.
  key: str
  value: str|int|float


class JUnitTestSuite(_JUnitTestSuiteContainer):
  """Class representing the <testsuite> element."""

  _testsuites: list['JUnitTestSuite']
  _testcases: list['JUnitTestCase']
  _properties: list[JUnitTestSuiteProperty]  # Not a dict. This is an ordered multidict.
  _name: str
  _timestamp: datetime.datetime
 
  _system_out: str|None  # contents of stdout of this testsuite; discouraged due to potentially large size
  _system_err: str|None  # contents of stderr of this testsuite; discouraged due to potentially large size
  
  def __init__(self, name: str, timestamp: datetime.datetime):
    """A new testsuite.

    Some mandatory subelements we can recalculate:

    - tests: number of tests in this testsuite (recursively computed)
    - failures: number of tests that failed in this testsuite (intended assert fails)
    - errors: number of tests that errored in this testsuite (unexpected crash)
    - skipped: number of tests that were ignored or skipped (e.g. 'dashed hope')
    - time: xsd decimal; time in seconds it took to execute the suite

    Args:
      name: name of the testsuite
      timestamp: when the testsuite was executed
    """
    super().__init__()
    self._testsuites = []
    self._properties = []
    self._testcases = []
    self._name = name
    self._timestamp = timestamp
    self._system_out = None
    self._system_err = None

  @property
  def test_suite_list(self) -> cabc.Iterable['JUnitTestSuite']:
    return list(self._testsuites)
  # No @test_suite_list.setter. Use add_test_suite only.

  def add_test_suite(self, ts: 'JUnitTestSuite') -> None:
    self._testsuites.append(ts)

  # Not operator[] because there can be multiple instances of the same key, in XSD.
  def add_property(self, key: str, value: str|int|float) -> None:
    self._properties.append(JUnitTestSuiteProperty(
        key=key, value=value))

  @property
  def test_case_list(self) -> cabc.Iterable['JUnitTestCase']:
    return list(self._testcases)
  # No @test_case_list.setter. Use add_test_case only.

  def add_test_case(self, tc: 'JUnitTestCase') -> None:
    self._testcases.append(tc)

  @property
  def system_out(self) -> str|None:
    return self._system_out

  @system_out.setter
  def system_out(self, o: str|None) -> None:
    self._system_out = o

  @property
  def system_err(self) -> str|None:
    return self._system_err

  @system_err.setter
  def system_err(self, e: str|None) -> None:
    self._system_err = e

  def count_tests(self, kind: str) -> int:
    filters = {
        'tests': lambda _: True,
        'failures': lambda tc: tc.failure,
        'errors': lambda tc: tc.error,
        'skipped': lambda tc: tc.skipped,
    }
    check = filters[kind]
    return (sum(ts.count_tests(kind) for ts in self.test_suite_list) +
            len([tc for tc in self._testcases if check(tc)]))

  def sum_time(self) -> float:
    return (sum(ts.sum_time() for ts in self.test_suite_list) +
            sum(tc.time for tc in self._testcases))

  def XMLNode(self) -> ET.Element:
    """Return the <testsuite> element."""
    attrib: dict[str, str] = {}
    attrib['name'] = self._name
    attrib.update({k: str(self.count_tests(k))
                   for k in ['tests', 'failures', 'errors', 'skipped']})
    attrib['time'] = str(self.sum_time())

    e = ET.Element('testsuite', attrib=attrib)
    if self._properties:
      p = ET.SubElement(e, 'properties')
      for prop in self._properties:
        v: str|int|float = prop.value
        ET.SubElement(p, 'property', attrib={
            'key': prop.key, 'value': str(v)})
    return e

  def AsXMLNode(self) -> ET.Element:
    """Return the <testsuite> element and its testsuites and testcases."""
    n: ET.Element = self.XMLNode()
    n.extend([ts.AsXMLNode() for ts in self.test_suite_list])
    n.extend([tc.AsXMLNode() for tc in self.test_case_list])
    return n


class JUnitPackageTestSuite(JUnitTestSuite):
  """Class representing the <testsuite> element inside testsuites root.

  This one seems to be able to include package attribute (some XSDs demand
  it, even).
  """

  _package: str
  _id: int

  def __init__(self, name: str, timestamp: datetime.datetime,
               package: str, id: int):
    """Create a new testsuite that can also include a package name and id.

    Args:
      name: name of the testsuite
      timestamp: time when the testsuite was run
      package: name of the package
      id: 0-based ID of the testsuite inside the testsuites element
    """
    super().__init__(name, timestamp)
    self._package = package
    self._id = id
    
  def XMLNode(self) -> ET.Element:
    """Return the <testsuite> element with 'package' and 'id' added."""
    e = super().XMLNode()
    e.set('package', self._package)
    e.set('id', str(self._id))
    return e


@dataclasses.dataclass
class JUnitTestCaseError(object):
  typ: str
  content: str|None = None # stacktrace or similar
  message: str|None = None

  def AsXMLNode(self) -> ET.Element:
    attrs: dict[str, str] = {
        'type': self.typ,
    }
    if self.message is not None:
      attrs['message'] = self.message

    e: ET.Element = ET.Element('error', attrib=attrs)
    if self.content is not None:
      e.text = self.content  # This should be ideally cdata if it were supported.
    return e


@dataclasses.dataclass
class JUnitTestCaseFailure(object):
  typ: str
  message: str|None = None
  content: str|None = None # stacktrace or similar

  def AsXMLNode(self) -> ET.Element:
    attrs: dict[str, str] = {
        'typ': self.typ,
    }
    if self.message is not None:
      attrs['message'] = self.message

    e: ET.Element = ET.Element('failure', attrib=attrs)
    if self.content is not None:
      e.text = self.content  # This should be ideally cdata if it were supported.

    return e


@dataclasses.dataclass
class JUnitTestCaseSkipped(object):
  message: str|None = None
  content: str|None = None # stacktrace or similar

  def AsXMLNode(self) -> ET.Element:
    attrs: dict[str, str] = {}
    if self.message is not None:
      attrs['message'] = self.message

    e: ET.Element = ET.Element('skipped', attrib=attrs)
    if self.content is not None:
      e.text = self.content  # This should be ideally cdata if it were supported.
    return e


@dataclasses.dataclass
class JUnitTestCase(object):
  """Class representing a single <testcase> inside a <testsuite>."""
  name: str
  classname: str
  time: float  # decimal
  error: JUnitTestCaseError|None = None
  failure: JUnitTestCaseFailure|None = None
  skipped: JUnitTestCaseSkipped|None = None

  # https://github.com/bazelbuild/bazel/blob/076ece499d4fb2521cc251c77ca064422835da0f/src/java_tools/junitrunner/java/com/google/testing/junit/runner/model/TestCaseNode.java#L277-L284
  # https://github.com/bazelbuild/bazel/blob/2594ea48f65008e81d29bbf77b5798f4c43fc454/src/java_tools/junitrunner/java/com/google/testing/junit/runner/model/TestResult.java
  result: str|None = None  # extension: 'completed', 'interrupted', 'cancelled', 'filtered', 'skipped', 'suppressed', 'silenced'

  # Possibly better not to collect by default, this can be private information;
  # useful in CI or RBE situations; this could be enabled by a flag
  hostname: str|None = None

  def AsXMLNode(self) -> ET.Element:
    attrs: dict[str, str] = {
        'name': self.name,
        'classname': self.classname,
        'time': str(self.time),
    }
    if self.hostname is not None:
      attrs['hostname'] = self.hostname
    if self.result is not None:
      attrs['result'] = self.result

    e: ET.Element = ET.Element('testcase', attrib=attrs)

    if sum((1 if self.error else 0,
            1 if self.failure else 0,
            1 if self.skipped else 0)) > 1:  # maybe any()?
      raise ValueError(
          'Test case %s/%s has multiple of error, failure and skipped set,'
          ' must be a oneof' % (self.name, self.classname))
    if self.error:
      e.append(self.error.AsXMLNode())
      e.set('result', 'completed')
    elif self.failure:
      e.append(self.failure.AsXMLNode())
      e.set('result', 'failure')
    elif self.skipped:
      e.append(self.skipped.AsXMLNode())
      # Let's only update it if it's not already set to something.
      if self.result is None:
        e.set('result', 'skipped')
    else:
      # Assume success.
      # Let's only update it if it's not already set to something. (Future improvement)
      if self.result is None:
        e.set('result', 'completed')
    return e


def tests_sum_to_junit_xml(f: 'io.TextIOBase') -> JUnitTestResults:
  """Turn IO stream for a GNUstep's tests.sum file into JUnit results.

  Files have the following structure:
  - a collection of lines, documenting whether a test succeeded or failed at
    the beginning of the line; a skipped *set* of tests may also be indicated
    (but it is not possible to know which tests were skipped)
  - a line indicating that a particular testsuite is completed

  Lines indicating test passage:
  Passed test:     (timestamp including timezone) filename_without_dir_possibly_prefixed_by_whitespace.m:LN ... message
  Note: ... might be omitted, along with file location information.
  Lines indicating ignored result (not skipped, but close):
  Dashed hope:     (2025-06-10 17:43:31.025 GMT+1)   cache.m:82 ... Oldest object evicted
  Lines indicating actual skipped set (note we don't get a timestamp)
  Skipped set:       general.m 134 ... No Blocks support in the compiler.

  Indicator that all tests in a collection have been gathered (also missing dir path)
  Completed file:  basic.m

  Args:
    f: input file (or other stream producing text)

  Returns:
    a struct representing the JUnit-style XML doc
  """

  # Since tests.sum does not let us figure out the directory anyway, we cannot
  # construct more than one level of testsuite's inside testsuites. We will
  # collect observed cases into a flat list until we have a 'Completed' line
  # (or in case of a crash we will dump them into a test with a randomly
  # generated name).
  #
  # This can be manipulated directly from the closure when constructing the
  # testsuite. But we don't really have to.
  current_cases: list['JUnitTestCase'] = []
  def line_muncher(ln: str) -> typing.Union['JUnitTestSuite', 'JUnitTestCase', None]:
    """Consume a line and produce either a testsuite or a testcase.

    In this case, testsuite will be populated by the caller.

    Args:
      ln: line as described in tests_sum_to_junit docstring

    Returns:
      either a testcase or a testsuite, or None if even the type of line is
          unrecognized. (potentially we could still output a testsuite)
    """
    case_lines = ['Passed test:', 'Failed test:',
                  'Dashed hope:', 'Failed set:', 'Skipped set:']
    pattern_testhope = r'^(?P<result>[A-Za-z]+) (?:test|hope): +\((?P<timestamp>[\d]{4}-[\d]{2}-[\d]{2} [\d]{2}:[\d]{2}:[\d]{2}(.[0-9]+ [A-Z0-9+-]+)?)\) +(?:(?P<source_file>[^: ]+):(?P<source_line>[\d]+) (?:\.\.\. )?)?(?P<message>.*)$'
    # Sets do not have a timestamp, and the colon between source file and line
    # is replaced by whitespace.
    pattern_set = r'^(?P<result>[A-Za-z]+) set: +(?P<source_file>[^: ]+)[: ](?P<source_line>[\d]+) \.\.\. (?P<message>.*)$'
    # Skipped set:       enumerateRanges.m 330 ... Blocks support unavailable
    suite_lines = ['Failed build:', 'Completed file:', 'Failed file:']
    for case_pfx in case_lines:
      if ln.startswith(case_pfx):
        # One of the case lines matched, let's figure out which one and extract the data:
        match_testhope = re.search(pattern_testhope, ln)
        if match_testhope:
          execution_time: float = 1.0  # Future improvement: instead of faking it, measure the timestamp difference from the previous one for all but the first testcase
          safe_message: str = match_testhope.group('message')  # Future improvement: instead of just verbatim printing out the message (which otherwise cannot be included in 'success' case, strangely), sanitize it first
          source_file: str = match_testhope.group('source_file') or 'unknown_source_file'
          source_line: str = match_testhope.group('source_line') or 'unknown_source_line'
          tc: JUnitTestCase = JUnitTestCase(
              name=source_file+':l'+source_line+'_'+safe_message,
              classname=source_file,
              time=execution_time)

          outcome: str = match_testhope.group('result')
          outcome = outcome.lower()
          if outcome == 'passed':
            tc.result = 'completed'
          elif outcome == 'dashed':
            tc.skipped = JUnitTestCaseSkipped(message=match_testhope.group('message'))
            # tc.result will be populated automatically
          elif outcome == 'failed':
            tc.failure = JUnitTestCaseFailure(message=match_testhope.group('message'), typ=match_testhope.group('result'))
            # tc.result will be populated automatically
          else:
            # this should not happen. not much to do. we could raise an exception
            pass
          return tc

        # If we are here, it wasn't a test or a hope; it was a set:
        match_set = re.search(pattern_set, ln)
        if match_set:
          execution_time = 1.0  # Future improvement: instead of faking it, measure the timestamp difference from the previous one for all but the first testcase
          safe_message = match_set.group('message')  # Future improvement: instead of just verbatim printing out the message (which otherwise cannot be included in 'success' case, strangely), sanitize it first
          source_file = match_set.group('source_file') or 'unknown_source_file'
          source_line = match_set.group('source_line') or 'unknown_source_line'

          tc = JUnitTestCase(
              name=source_file+':l'+source_line+'_'+safe_message,
              classname=source_file,
              time=execution_time)

          outcome = match_set.group('result')
          outcome = outcome.lower()
          if outcome == 'skipped':
            tc.skipped = JUnitTestCaseSkipped(message=match_set.group('message'))
          elif outcome == 'failed':
            tc.failure = JUnitTestCaseFailure(message=match_set.group('message'), typ=match_set.group('result'))
          else:
            # this should not happen. not much to do. we could raise an exception
            pass
          return tc

        # Nothing was matched. This should not happen since we encountered either a set or a test or a hope line.
        # Let's just print an error to stderr, and return a skipped tc, and worry later.
        print('case_line: no regex match for line: %s' % ln, file=sys.stderr)
        return JUnitTestCase(
            name='unmatched_test_line',
            classname='case_line',
            time=1,
            skipped=JUnitTestCaseSkipped(message='error in test output parser: could not match the line: ' + ln),
        )
        # Well, better luck next time.

    for suite_pfx in suite_lines:
      # These are a sign we need to collect the cases

      if ln.startswith(suite_pfx):
        # Yes, it's a suite-line. Return a testsuite object and let the caller
        # populate it with cases and add it to results.
        components = ln.split(':')
        ts: JUnitTestSuite
        if components[0] == 'Completed file':
          ts = JUnitTestSuite(
              name=components[1].strip(),
              timestamp=datetime.datetime.now(), # Unfortunately, current_cases[0].timestamp does not exist, as we don't collect it for now. Future improvement.
          )
          # Do we need more? Caller will populate with cases etc
          return ts
        elif components[0] == 'Failed build':
          ts = JUnitTestSuite(
              name=components[1].strip(),
              timestamp=datetime.datetime.now(), # We don't record time of failure of build.
          )
          # Add a failed case so we are sure to get the failure reported.
          ts.add_test_case(JUnitTestCase(
              name='build_failed',
              classname=components[1].strip(),
              time=1,
              error=JUnitTestCaseError(message='failed to build the test module', typ='build_failure')
          ))
          return ts
        elif components[0] == 'Failed file':
          ts = JUnitTestSuite(
              name=components[1].strip(),
              timestamp=datetime.datetime.now(), # Unfortunately, current_cases[0].timestamp does not exist, as we don't collect it for now. Future improvement.
          )
          # Add a failed case so we are sure to get the failure reported.
          ts.add_test_case(JUnitTestCase(
              name='suite_failed',
              classname=components[1].strip(),
              time=1,
              error=JUnitTestCaseError(message='failed running the test module', typ='file_failure')
          ))
          return ts

    # We have nothing? Unknown line? Fine.
    return None

  results: JUnitTestResults = JUnitTestResults()

  first_seen_timestamp: datetime.datetime = datetime.datetime.utcfromtimestamp(0)  # used to measure full run time duration of the testsuites, but currently unused
  # ts: JUnitTestSuite = JUnitTestSuite()  # blank one (though do we have any need for it?)
  for l in f:  # NOTE: There is a test that includes character ^M in output that this style of iteration breaks on.
    l = l.rstrip()
    if not l or l[0] == '#':  # skip blank lines; also skip comments, even though the files are not meant to have them
      continue
    # Last few lines are bottom-of-the-page report lines, we can skip them too.
    if l[0] == ' ':
      continue

    tc = line_muncher(l)
    if isinstance(tc, JUnitTestCase):
      # tc: JUnitTestCase
      current_cases.append(tc)
    elif isinstance(tc, JUnitTestSuite):
      ts: JUnitTestSuite = tc
      for tc in current_cases:
        ts.add_test_case(tc)
      # Empty the current cases
      current_cases = []

      # Built; now add it to results
      results.root.add_test_suite(ts)
    elif tc is None:
      print('gstest_to_junit_xml: small note: line_muncher failed to process a line from the input in a predictable way: %s; line was: %s' % (str(type(tc)), l), file=sys.stderr)
    else:
      print('gstest_to_junit_xml: unexpected return value type from line_muncher: %s; line was: %s' % (str(type(tc)), l), file=sys.stderr)
  
  # If we got here, and there are cases still in queue printed out, it means we
  # missed the final 'Completed file' or similar. Build a fake suite.
  if current_cases:
    ts = JUnitTestSuite(name='unhandled_cases', timestamp=datetime.datetime.now())  # Future improvement: use current_cases[0] timestamp once we start to record it
    for tc in current_cases:
      ts.add_test_case(tc)
    results.root.add_test_suite(ts)

  return results


def usage(argv: list[str]) -> None:
  """Print out usage instructions when the program is incorrectly started.

  Args:
    argv: command line arguments per unix conventions, where the first element
        is the invocation command.
  """
  print()
  print('usage: %s tests.sum junit_test_result.xml' % argv[0], file=sys.stderr)
  print()


def main(argv: list[str]) -> int|None:
  """Main entrypoint for the program.

  Args:
    argv: command line arguments per unix conventions, where the first element
        is the invocation command.

  Returns:
    status code to return from the binary; typically zero which indicates
        success. Caller should handle None and return zero to the OS in that
        case.
  """
  if len(argv) != 3:
    print("%s takes exactly two arguments (%d provided)" % (argv[0], len(argv)-1), file=sys.stderr)
    usage(argv)
    return 1

  # Minimal flag quasi-parsing, for prototype.
  if argv[1] == "--check" and argv[2] == "--quiet":
    # Two arguments just so this prototype does not need to do actual flag
    # parsing, while still futureproofing us. Accepts two arguments solely
    # so check for len(argv) above doesn't need to be more complex.
    #
    # The "--check" simply indicates "the wrapper can be executed", so
    # gnustep-tests can avoid doing any JUnit-related operations if the
    # test output processor doesn't even work.
    return 0

  with open(argv[1], 'rt') as f:
    junit_xml = tests_sum_to_junit_xml(f)
  with open(argv[2], 'wt') as f:
    f.write(junit_xml.AsString())

  print('', file=sys.stderr)
  print('if you installed junit2html from pip, try running: junit2html %s %s.html' % (argv[2], argv[2]), file=sys.stderr)
  print('also:                                              junit2html %s --summary-matrix' % argv[2], file=sys.stderr)
  print('', file=sys.stderr)

  return 0


if __name__ == "__main__":
  sys.exit(main(sys.argv) or 0)
