/* Test whether Objective-C runtime was compiled with thread support */

/* Dummy NXConstantString impl for so libobjc that doesn't include it */
#include <objc/NXConstStr.h>
@implementation NXConstantString
@end

/* From thr.c */
extern int __objc_init_thread_system(void);

int
main()
{
  return (__objc_init_thread_system());
}
