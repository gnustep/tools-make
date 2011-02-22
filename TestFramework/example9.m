#import	"Testing.h"
#import	<NSFoundation/NSGeometry.h>

/* A ninth test ... unsupported tests
 *
 * If you run the test with 'gnustep-tests example9.m' it should
 * report one set skipped.
 */
int
main()
{
  #define	HAVE_XXX	NO

  /* Start a set, but only if we have the XXX library.
   */
  START_SET(HAVE_XXX)

  /* Here we demonstrate that the 'expression' evaluated by the PASS
   * macro can actually be an arbitrarily complex piece of code as
   * long as the last statement returns an integral value which can
   * be used to represent a pass (non zero) or fail (if zero).
   * Where such a code fragment contains commas, it must be written
   * inside brackets to let the macro preprocessor know that the whole
   * code fragement is the first parameter to the macro.
   */
  PASS(({
    NSRange	r = NSMakeRange(1, 10);
    
    NSEqualRanges(r, NSMakeRange(1, 10));
  }), "a long code-fragment/expression works")

  /* Here we end the set with a message to be displayed if the set is
   * skipped.  The first line will be displayed immediately when the set
   * is skipped, and lets the user know that some functionality is missing.
   * The remainder of the message is written to the log file so the user
   * can find out what to do about the problem.
   */
  END_SET("Feature 'foo' is unsupported.\nThis is because the 'XXX' package was built without the 'YYY' library.\nIf you need 'foo' then please obtain 'YYY' and build and install 'XXX' again before re-running this testsuite.")

  return 0;
}
