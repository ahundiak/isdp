#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <glib.h>

#include "UMS.h"
#include "ris_err.h"

static void test1()
{
  int sts;
  char buf[256];

  // Should work
  sts = UMSInitMsg ("ris.msg", UMS_MESSAGE | UMS_KEY | UMS_KEY2 | UMS_INDEX);
  g_assert(sts == UMS_S_SUCCESS);

  // Try a failure
  // sts = UMSInitMsg ("ris.msgx", UMS_MESSAGE);
  // g_assert(sts != UMS_S_SUCCESS);

  *buf = 0;
//sts = UMSGetByNum(buf,RIS_E_ARCH_ERROR & 0x7fffffff,NULL);

  // So for some reason, need to mask this
  sts = UMSGetByNum(buf,RIS_E_ARCH_ERROR & 0x7fffffff,NULL);
  g_assert(sts == UMS_S_SUCCESS);
  g_message(buf);

  // Think keys only work if they were compiled in
  sts = UMSGetByKey(buf,"RIS_E_BAD_LOGIN",NULL);
  g_assert(sts == UMS_E_NOTFND);
//g_message(buf);
  
  // Close up
  sts = UMSClearMsg("ris.msg");
  g_assert(sts == UMS_S_SUCCESS);


//  g_assert_cmpstr ("AAA", ==, "AAA");
//  g_assert_cmpstr ("AAA", ==, "BBB");
}
int main(int argc, char *argv[])
{
  g_test_init(&argc, &argv,NULL);

  g_test_add_func ("/ums/tests/test1", test1);
  
  return g_test_run();
}
