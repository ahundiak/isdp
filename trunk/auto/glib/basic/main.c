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

#include "tests.h"

int main (int   argc, char *argv[])
{
  int i = 42;

  g_test_init (&argc, &argv, NULL);
   
  g_test_add_func ("/basic/number assertion", test_number_assertion);

  g_test_add("/basic/string test", StringTestFixture, &i, test_string_setup, test_string, test_string_teardown);

  g_test_add_func("/basic/version",test_version);
  g_test_add_func("/basic/sizeof",  test_sizeof);
  g_test_add_func("/basic/system",  test_system);

  g_test_add_func("/hash/test1",test_hash1);
  g_test_add_func("/hash/test2",test_hash2);
  g_test_add_func("/hash/test3",test_hash3);
  g_test_add_func("/hash/test4",test_hash3);

  return g_test_run();
}
