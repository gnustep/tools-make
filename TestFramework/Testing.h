/* Testing - Include basic tests macros for the GNUstep Testsuite

   Copyright (C) 2005-2011 Free Software Foundation, Inc.

   Written by: Alexander Malmberg <alexander@malmberg.org>
   Updated by: Richard Frith-Macdonald <rfm@gnu.org>
 
   This package is free software; you can redistribute it and/or
   modify it under the terms of the GNU General Public
   License as published by the Free Software Foundation; either
   version 3 of the License, or (at your option) any later version.
 
   This library is distributed in the hope that it will be useful,
   but WITHOUT ANY WARRANTY; without even the implied warranty of
   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
   General Public License for more details.
 
*/

#ifndef Testing_h
#define Testing_h

#include <stdio.h>
#include <stdarg.h>

#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSException.h>
#import <Foundation/NSGarbageCollector.h>
#import <Foundation/NSObjCRuntime.h>
#import <Foundation/NSObject.h>
#import <Foundation/NSString.h>

/* A flag indicating that the testsuite is currently processing tests
 * which are actually not expected to pass, but where we hope someone
 * might have committed a bugfix.
 * The state of this flag is preserved by sets ... on exit from a set
 * it is restored to the state it had on entry.
 */
static BOOL testHopeful __attribute__((unused)) = NO;

/* A flag indicating whether the most recently executed test passed.
 * This is set by the pass() function (and therefore by any test macro).
 */
static BOOL testPassed __attribute__((unused)) = NO;

/* A variable storing the line number of the test currently being run.
 */
static unsigned testLineNumber __attribute__((unused)) = 0;

/* A variable set whenever a test macro is executed.  This contains
 * the exception which terminated the test macro, or nil if no exception
 * was raised.
 */
static NSException *testRaised __attribute__((unused)) = nil;

/* The pass() function is the low-level core of the testsuite.
 *
 * You call this with two arguments ... an integer expression indicating the
 * success or failure of the testcase (0 is a failure) and a string which
 * describes the testcase.
 *
 * The global variable 'testHopeful' can be set to a non-zero value before
 * calling this function in order to specify that if the condition is
 * not true it should be treated as a dashed hope rather than a failure.
 *
 * If there is a better higher-level test macro available, please use
 * that instead.  In particular, please use the PASS_EQUAL() macro wherever
 * you wish to test the equality of a pair of objective-c objects.
 *
 * If you are calling the function directly, please use a format string
 * beginning "%s:%d" and pass __FILE__ and __LINE__ as the first two arguments
 * so that this function will print out the location it was called from.
 *
 * This function is the most efficient option for general use, but
 * please don't use it if there is any change that the evaluation of
 * the expression used as its first argument might cause an exception
 * in any context where that might be a problem.
 */
static void pass(int passed, const char *format, ...)  __attribute__((unused)) __attribute__ ((format(printf, 2, 3)));
static void pass(int passed, const char *format, ...)
{
  va_list args;
  va_start(args, format);
  if (passed)
    {
      fprintf(stderr, "Passed test:     ");
      testPassed = YES;
    }
  else if (YES == testHopeful)
    {
      fprintf(stderr, "Dashed hope:     ");
      testPassed = NO;
    }
  else
    {
      fprintf(stderr, "Failed test:     ");
      testPassed = NO;
    }
  vfprintf(stderr, format, args);
  fprintf(stderr, "\n");
  va_end(args);
#if	defined(FAILFAST)
  if (NO == testPassed && NO == testHopeful)
    {
      exit(1);	// Abandon testing now.
    }
#endif
}

/* The testStart() function is used by the PASS macros to provide a break
 * point in the source code after the current test line has been stored in
 * testLineNumber.
 * This is provided for when debugging ... you can set a breakpoint in the
 * testStart() function for the line number reported in a test failure and
 * have the debugger stop in just the right place.
 */
static void testStart()  __attribute__((unused));
static void testStart()
{
  return;
}

/* Tests a code expression which evaluates to an integer value.
 * The expression may not contain commas unless it is bracketed.
 * The format must be a literal string printf style format.
 * If the expression evaluates to zero the test does not pass.
 * If the expression causes an exception to be raised, the exception
 * is caught and logged but the test does not pass.
 * Otherwise, the test passes.
 * Basically equivalent to pass() but with exception handling.
 */
#define PASS(expression, format, ...) \
  NS_DURING \
    { \
      int _cond; \
      id _tmp = testRaised; testRaised = nil; [_tmp release]; \
      [[NSGarbageCollector defaultCollector] collectExhaustively]; \
      testLineNumber = __LINE__; \
      testStart(); \
      _cond = (int)(expression); \
      [[NSGarbageCollector defaultCollector] collectExhaustively]; \
      pass(_cond, "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
    } \
  NS_HANDLER \
    testRaised = [localException retain]; \
    pass(0, "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
    printf("%s: %s", [[testRaised name] UTF8String], \
      [[testRaised description] UTF8String]); \
  NS_ENDHANDLER

/* Tests a code expression which evaluates to an object value.
 * The expression may not contain commas unless it is bracketed.
 * The expected value may not contain commas unless it is bracketed.
 * The format must be a literal string printf style format.
 *
 * Where the expression evaluates to an object which is identical to
 * the expect value, or where [object isEqual: expect] returns YES,
 * the test has passed.
 *
 * The particularly useful thing about this macro is that, if the
 * results of the expression and the expected object are not equal,
 * the string representation of both values is logged so that you
 * can get a better idea of what went wrong.
 */
#define PASS_EQUAL(expression, expect, format, ...) \
  NS_DURING \
    { \
      int _cond; \
      id _obj; \
      id _exp; \
      id _tmp = testRaised; testRaised = nil; [_tmp release]; \
      [[NSGarbageCollector defaultCollector] collectExhaustively]; \
      testLineNumber = __LINE__; \
      testStart(); \
      _obj = (id)(expression);\
      _exp = (id)(expect);\
      _cond = _obj == _exp || [_obj isEqual: _exp]; \
      [[NSGarbageCollector defaultCollector] collectExhaustively]; \
      pass(_cond, "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
      if (0 == _cond) \
	{ \
          NSString  *s = [_obj description]; \
          if ([s length] == 1) \
            { \
              fprintf(stderr, \
		"Expected '%s' and got '%s' (unicode codepoint %d)\n", \
                [[_exp description] UTF8String], [s UTF8String], \
		[s characterAtIndex: 0]); \
            } \
	  else \
	    { \
	      fprintf(stderr, "Expected '%s' and got '%s'\n", \
                [[_exp description] UTF8String], [s UTF8String]); \
	    } \
	} \
    } \
  NS_HANDLER \
    testRaised = [localException retain]; \
    pass(0, "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
    printf("%s: %s", [[testRaised name] UTF8String], \
      [[testRaised description] UTF8String]); \
  NS_ENDHANDLER

/* Please use the PASS_EXCEPTION() macro to handle any code where you
 * want an exception to be thrown.  The macro checks that the supplied
 * code throws the specified exception.  If the code fails to throw,
 * or throws the wrong exception, then the code does not pass.
 * You can supply nil for expectedExceptionName if you don't care about the
 * type of exception.
 * The code fragment may not contain commas unless it is surrounded by
 * brackets. eg. PASS_EXCEPTION(({code here}), name, "hello")
 * The format must be a literal string printf style format.
 */
#define PASS_EXCEPTION(code, expectedExceptionName, format, ...) \
  NS_DURING \
    id _tmp = testRaised; testRaised = nil; [_tmp release]; \
    { \
      testLineNumber = __LINE__; \
      testStart(); \
      code; \
    } \
    pass(0, "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
  NS_HANDLER \
    testRaised = [localException retain]; \
    pass((nil == (expectedExceptionName) \
      || [[testRaised name] isEqual: (expectedExceptionName)]), \
      "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
    if (NO == [(expectedExceptionName) isEqual: [testRaised name]]) \
      fprintf(stderr, "Expected '%s' and got '%s'\n", \
        [(expectedExceptionName) UTF8String], \
        [[testRaised name] UTF8String]); \
  NS_ENDHANDLER

/* Please use the PASS_RUNS() macro to handle any code where you want the
 * code to run to completion without an exception being thrown, but you don't
 * have a particular expression to be checked.
 * The code fragment may not contain commas unless it is surrounded by
 * brackets. eg. PASS_EXCEPTION(({code here}), name, "hello")
 * The format must be a literal string printf style format.
 */
#define PASS_RUNS(code, format, ...) \
  NS_DURING \
    id _tmp = testRaised; testRaised = nil; [_tmp release]; \
    { \
      testLineNumber = __LINE__; \
      testStart(); \
      code; \
    } \
    pass(1, "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
  NS_HANDLER \
    testRaised = [localException retain]; \
    pass(0, "%s:%d ... " format, __FILE__, __LINE__, ## __VA_ARGS__); \
    printf("%s: %s", [[testRaised name] UTF8String], \
      [[testRaised description] UTF8String]); \
  NS_ENDHANDLER


/* SETs are used to group multiple testcases or code which is outside of
 * the scope of the current test but could raise exceptions that should
 * be caught to allow further tests to run.
 *
 * You must pass a short description to identify the set at both its
 * start and its end.  This allows the seat to be easily identified in the
 * log, and also allows for checking to be sure that each start if a set
 * is matched by a corresponding end.
 *
 * The state of the 'testHopeful' flag is saved at the start of the set and
 * restored at the end of the set, so you can start your code by setting
 * 'testHopeful=YES;' to mark any tests within the set as being part of a
 * group of tests we don't expect to pass.
 *
 * Importantly, you may skip some or all of the tests in a set if those
 * tests are not supported in the package being tested (eg. testing of
 * functionality which depends on some external library which was not
 * available when the package being tested was buit).
 *
 * Any uncaught exception occurring inside a set will abort the entire set
 * so that remaining tests in the set will not be executed, but you may
 * also abandon remaining tests upon any test failure.
 *
 * The tests within the set are enclosed in an autorelease pool, and any
 * temporary objects are cleaned up at the end of the set.
 */

/* The START_SET() macro starts a set of grouped tests. It must be matched
 * by a corresponding END_SET() with the same string as an argument.
 * The argument is a short description to be printed in the log on entry.
 */
#define START_SET(setName) \
  { \
    BOOL _save_hopeful = testHopeful; \
    int	_save_line = __LINE__; \
    char *_save_set = malloc(strlen(setName) + 1); \
    strcpy(_save_set, setName); \
    fprintf(stderr, "Start set:       %s:%d ... %s\n", \
      __FILE__, __LINE__, _save_set); \
    fprintf(stderr, "\n"); \
    NS_DURING \
      NSAutoreleasePool *_setPool = [NSAutoreleasePool new]; \
      {


/* The END_SET() macro terminates a set of grouped tests.  It must be matched
 * by a corresponding START_SET() with the same string as an argument.
 * The argument is a short description to be printed in the log on entry.
 */
#define END_SET(setName) \
      } \
    [_setPool release]; \
    NS_HANDLER \
      if (YES == [[localException name] isEqualToString: @"SkipSet"]) \
	{ \
	  fprintf(stderr, "Skipped set:     %s\n", \
	    [[localException reason] UTF8String]); \
	} \
      else \
	{ \
	  if (YES == [[localException name] isEqualToString: @"FailSet"]) \
	    { \
	      fprintf(stderr, \
		"Failed set:      %s:%d ... need not met in %s.\n", \
	        __FILE__, _save_line, _save_set); \
	    } \
	  else \
	    { \
	      fprintf(stderr, "EXCEPTION: %s %s %s\n", \
		[[localException name] UTF8String], \
		[[localException reason] UTF8String], \
		[[[localException userInfo] description] UTF8String]); \
	      fprintf(stderr, "Failed set:      %s:%d ... problem in %s.\n", \
	        __FILE__, _save_line, _save_set); \
	    } \
	} \
    NS_ENDHANDLER \
    fprintf(stderr, "End set:       %s:%d ... %s\n", \
      __FILE__, __LINE__, _save_set); \
    if (strcmp(_save_set, setName) != 0) \
      fprintf(stderr, "Failed set:      %s:%d ... END(%s) with START(%s).\n", \
        __FILE__, __LINE__, setName, _save_set); \
    free(_save_set); \
    testHopeful = _save_hopeful; \
  }

/* The NEED macro takes a test macro as an argument and breaks out of a set
 * and reports it as failed if the test does not pass.
 */
#define	NEED(testToTry) \
  {testToTry;} \
  if (NO == testPassed) \
    { \
      if (nil != testRaised) \
	{ \
	  [testRaised raise]; \
	} \
      else \
	{ \
	  [NSException raise: @"FailSet" format: @"Test did not pass"]; \
	} \
    }

/* The SKIP() macro skips the remainder of a set of grouped tests.
 * Its argument is a literal printf style format string and variable
 * arguments to print a message giving the reason for skipping the set.
 * This should be a short one line message (for immediate display),
 * preferably with a more detailed explanation on subsequent lines.
 */
#define	SKIP(fmt, ...) \
  [NSException raise: @"SkipSet" format: @"%s %d ... " fmt, \
  __FILE__, __LINE__, ## __VA_ARGS__];


/* some good macros to compare floating point numbers */
#import <math.h>
#import <float.h>
#define EQ(x, y) (fabs((x) - (y)) <= fabs((x) + (y)) * (FLT_EPSILON * 100))
#define LE(x, y) ((x)<(y) || EQ(x, y))
#define GE(x, y) ((y)<(x) || EQ(x, y))
#define LT(x, y) (!GE(x, y))
#define GT(x, y) (!LE(x, y))

/* A convenience macro to pass an object as a string to a print function. 
 */
#define POBJECT(obj)      [[(obj) description] UTF8String]

#endif

#ifndef	CREATE_AUTORELEASE_POOL
#define	RETAIN(object)		[object retain]
#define	RELEASE(object)		[object release]
#define	AUTORELEASE(object)	[object autorelease]
#define	TEST_RETAIN(object)	({\
id __object = (id)(object); (__object != nil) ? [__object retain] : nil; })
#define	TEST_RELEASE(object)	({\
id __object = (id)(object); if (__object != nil) [__object release]; })
#define	TEST_AUTORELEASE(object)	({\
id __object = (id)(object); (__object != nil) ? [__object autorelease] : nil; })
#define	ASSIGN(object,value)	({\
id __value = (id)(value); \
id __object = (id)(object); \
if (__value != __object) \
  { \
    if (__value != nil) \
      { \
	[__value retain]; \
      } \
    object = __value; \
    if (__object != nil) \
      { \
	[__object release]; \
      } \
  } \
})
#define	ASSIGNCOPY(object,value)	({\
id __value = (id)(value); \
id __object = (id)(object); \
if (__value != __object) \
  { \
    if (__value != nil) \
      { \
	__value = [__value copy]; \
      } \
    object = __value; \
    if (__object != nil) \
      { \
	[__object release]; \
      } \
  } \
})
#define	DESTROY(object) 	({ \
  if (object) \
    { \
      id __o = object; \
      object = nil; \
      [__o release]; \
    } \
})
#define	CREATE_AUTORELEASE_POOL(X)	\
  NSAutoreleasePool *(X) = [NSAutoreleasePool new]
#define RECREATE_AUTORELEASE_POOL(X)  \
  if (X == nil) \
    (X) = [NSAutoreleasePool new]
#endif

