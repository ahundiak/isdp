/* 
 * File:   main.c
 * Author: impd
 *
 * Created on December 4, 2010, 8:20 AM
 */
#include "config.h"

#include <stdio.h>
#include <stdlib.h>
#include <glib.h>
#include <gmodule.h>

typedef void (* Thello)(gint *result, gint *count);

extern void module02_hello(gint *result, gint *count);

gint public_var = 21;

// ========================================
void test_load_module01(void)
{
  GModule *module;
  gboolean status;

  Thello hello;

  gint result = 0;
  gint count;

  module = g_module_open("./.libs/module01.so",0);
  g_assert(module);

  status = g_module_symbol(module,"module01_hello",(gpointer)&hello);
  g_assert(status);

  hello(&result,&count);
  g_assert_cmpint(42, ==, result);
  g_assert_cmpint( 1, ==, count);

  status = g_module_close(module);
  g_assert(status);
}
// =============================
void test_load_module02(void)
{
  GModule *module;
  gboolean status;

  Thello hello;

  gint result = 0;
  gint count;

  // Already linked
  module02_hello(&result, &count);
  g_assert_cmpint(1, ==, count);

  module = g_module_open("./.libs/module02.so",0);
  g_assert(module);

  status = g_module_symbol(module,"module02_hello",(gpointer)&hello);
  g_assert(status);

  hello(&result,&count);
  g_assert_cmpint(42, ==, result);
  g_assert_cmpint( 2, ==, count);

  module02_hello(&result, &count);
  g_assert_cmpint(3, ==, count);

  status = g_module_close(module);
  g_assert(status);

  module02_hello(&result, &count);
  g_assert_cmpint(4, ==, count);

}
// ===============================
int main (int   argc, char *argv[])
{

  g_test_init (&argc, &argv, NULL);

  // This verifies that reloading a module will reset static module data
  g_test_add_func ("/dload/load", test_load_module01);
  g_test_add_func ("/dload/load", test_load_module01);

  // Module 2 is linked
  g_test_add_func ("/dload/load", test_load_module02);

  return g_test_run();
}
