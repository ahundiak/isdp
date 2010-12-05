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
// =============================
void test_load_module03(void)
{
  GModule *module3;
  GModule *module4;

  gboolean status;

  Thello hello3,hello4;

  gint result = 0;
  gint count;

  // One in local space
  module3 = g_module_open("./.libs/module03.so",G_MODULE_BIND_LOCAL);
  g_assert(module3);

  status = g_module_symbol(module3,"module03_hello",(gpointer)&hello3);
  g_assert(status);

  hello3(&result,&count);
  g_assert_cmpint(42, ==, result);
  g_assert_cmpint( 1, ==, count);

  // Another in local space
  module4 = g_module_open("./.libs/module04.so",G_MODULE_BIND_LOCAL);
  g_assert(module4);

  status = g_module_symbol(module4,"module03_hello",(gpointer)&hello4);
  g_assert(status);

  hello4(&result,&count);
  g_assert_cmpint(42, ==, result);
  g_assert_cmpint( 1, ==, count);

  g_assert(hello3 != hello4);
  
  // Tidy up
  g_assert(g_module_close(module3));
  g_assert(g_module_close(module4));


}
// Same function defined in module05 but it returns 20
void module05_hello(gint *results, gint *count)
{
  *results = 10;
  *count = -10;
}
// ========================================
void test_load_module05(void)
{
  GModule *module;
  gboolean status;

  Thello hello;

  gint result = 0;
  gint count;

  module05_hello(&result,&count);
  g_assert_cmpint(10,==,result);
 
  module = g_module_open("./.libs/module05.so",0);
  g_assert(module);

  module05_hello(&result,&count);
  g_assert_cmpint(20,==,result);

  g_assert(g_module_close(module));

  module05_hello(&result,&count);
  g_assert_cmpint(10,==,result);

}
// ===============================
int main (int   argc, char *argv[])
{

  g_test_init (&argc, &argv, NULL);

  // This verifies that reloading a module will reset static module data
  g_test_add_func ("/dload/load01", test_load_module01);
  g_test_add_func ("/dload/load01", test_load_module01);

  // Module 2 is linked
  g_test_add_func ("/dload/load02", test_load_module02);

  // Module 3 is stays in local space
  g_test_add_func ("/dload/load03", test_load_module03);

  // Module 5 overrides a regular function
  // That does not seem to be happening
  g_test_add_func ("/dload/load05", test_load_module05);

  // Write a test in which a function is loaded from a regular linked library
  // Then dload a module with a new version
  // And see if it overwrites

  // This is a toughie, reload the same module but with differences made
  // Maybe look at the code to see what it does
  // Each new file activation loads stuff
  // Actually not be hard to track module names and close then reload

  return g_test_run();
}
