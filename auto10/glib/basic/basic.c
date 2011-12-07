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

void test_number_assertion (void)
{
   g_assert_cmpint (4, ==, 2 + 2);
}

void test_string_setup(StringTestFixture *fix, gconstpointer tdata)
{
    fix->string = g_strdup("cerad");
}
void test_string_teardown(StringTestFixture *fix, gconstpointer tdata)
{
    g_free(fix->string);
}
void test_string(StringTestFixture *fix, gconstpointer tdata)
{
    int i = *(int*)tdata;

    g_assert_cmpstr(fix->string,==,"cerad");
    g_assert_cmpint(i, ==, 42);
}
void test_version()
{
    g_assert(GLIB_CHECK_VERSION(2, 16, 0));

}
void test_sizeof()
{
    g_assert_cmpint(4,==,sizeof(gint32));
  //g_assert_cmpint(8,==,sizeof(gint64)); // This comes back as 4 on suse for 32 bit app on 64 bit machine
    g_assert_cmpint(4,==,sizeof(gint));
    g_assert_cmpint(4,==,sizeof(glong));
    g_assert_cmpint(8,==,sizeof(gdouble));
}
void test_system()
{
#ifndef G_OS_UNIX
    g_assert(0);
#endif
    g_assert_cmpstr("/",==,G_DIR_SEPARATOR_S);

    // On solaris x86 this comes back as 4
    // Evne though tests seem to indicate that always get 8
    g_assert((G_MEM_ALIGN == 4) || (G_MEM_ALIGN == 8));

    // g_assert_cmpint(8,==,G_MEM_ALIGN);

    {
        typedef struct { gdouble d1; gint i1; gdouble d2; } T1;

        typedef double  __attribute__((aligned(8))) double8;

        typedef struct { double8 d1; gint i1; double8 d2; } T2;

        int offset; gdouble d2; gdouble *d2p;

        T2 t2;

        offset = G_STRUCT_OFFSET(T1,d2); g_assert_cmpint(12,==,offset);
        offset = G_STRUCT_OFFSET(T2,d2); g_assert_cmpint(16,==,offset);

        t2.d2 = 42.0;

        d2 = G_STRUCT_MEMBER(gdouble,&t2,offset);
        g_assert((d2 > 41.0) && (d2 < 43.0));
        
    }
    // Lots of integer byte order stuff, but not for doubles?
    g_assert_cmpint(G_BYTE_ORDER,==,G_LITTLE_ENDIAN);

    // Can't seem to get this to work
    // Could not get swap to work either
  //g_assert_cmpint(G_LITTLE_ENDIAN,==,GINT32_FROM_LE(G_BIG_ENDIAN));

    g_assert((G_PI > 3.13) && (G_PI < 3.15));

    g_assert_cmpstr("test_system",==,G_STRFUNC);
    
}


