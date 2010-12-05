/* 
 * File:   tests.h
 * Author: impd
 *
 * Created on December 5, 2010, 7:36 AM
 */

#ifndef TESTS_H
#define	TESTS_H

#ifdef	__cplusplus
extern "C" {
#endif

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

