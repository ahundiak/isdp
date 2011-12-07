/* 
 * File:   tests.h
 * Author: impd
 *
 * Created on December 5, 2010, 7:36 AM
 */

#ifndef TESTS_H
#define	TESTS_H

#include <glib.h>

#ifdef	__cplusplus
extern "C" {
#endif

/* hash.c */
extern void test_hash1(void);
extern void test_hash2(void);
extern void test_hash3(void);
extern void test_hash4(void);

/* basic.c */
extern void test_number_assertion (void);
extern void test_system(void);
extern void test_version(void);
extern void test_sizeof(void);

typedef struct
{
    gchar *string;
} StringTestFixture;

extern void test_string_setup       (StringTestFixture *fix, gconstpointer tdata);
extern void test_string_teardown(StringTestFixture *fix, gconstpointer tdata);
extern void test_string                    (StringTestFixture *fix, gconstpointer tdata);

#ifdef	__cplusplus
}
#endif

#endif	/* TESTS_H */

