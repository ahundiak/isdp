#include "config.h"
#include <glib.h>
#include "../lib/hash.h"
#include "tests.h"

/* ========================
 * Just your basic test using strings
 */
void test_hash1(void)
{
    GHashTable *table;
    gchar *name;
    gboolean status;

    table = g_hash_table_new(g_str_hash,g_str_equal);

    g_hash_table_insert(table,"art","Art Hundiak");
    g_hash_table_insert(table,"dan","Dan Cutshal");
    g_hash_table_insert(table,"cerad","Mystery Person");

    name = g_hash_table_lookup(table,"art");
    g_assert_cmpstr("Art Hundiak",==,name);

    status = g_hash_table_remove(table,"dan");
    g_assert(status);

    name = g_hash_table_lookup(table,"dan");
    g_assert(!name);
    
    g_hash_table_destroy(table);

}
/* ===============
 * Make sure destroy works as expected
 */
static gboolean art_was_destroyed = 0;
static void test_destroy(gpointer data)
{
    static gboolean first = FALSE;

    if (first == FALSE)
    {
        g_assert_cmpstr(data,==,"dan");
        first = TRUE;
    }
    if (!g_strcmp0(data,"art")) art_was_destroyed = TRUE;
    
    // g_message("Destroy %s\n",data);
}
void test_hash2(void)
{
    GHashTable *table;
    gchar *name;
    gboolean status;

    // Also have direct_hash,int hash, double_hash
    table = g_hash_table_new_full(g_str_hash,g_str_equal,test_destroy,test_destroy);

    g_hash_table_insert(table,"art","Art Hundiak");
    g_hash_table_insert(table,"dan","Dan Cutshal");
    g_hash_table_insert(table,"cerad","Mystery Person");

    name = g_hash_table_lookup(table,"art");
    g_assert_cmpstr("Art Hundiak",==,name);

    status = g_hash_table_remove(table,"dan");
    g_assert(status);

    name = g_hash_table_lookup(table,"dan");
    g_assert(!name);

    g_hash_table_destroy(table);

    g_assert(art_was_destroyed);

}
void test_hash3(void)
{
    GHashTable *table;
    gchar *name;
    gboolean status;

    
    table = g_hash_table_new(isdp_g_uint_hash,isdp_g_uint_equal);

    g_hash_table_insert(table,GUINT_TO_POINTER(10),"Art Hundiak");
    g_hash_table_insert(table,GUINT_TO_POINTER(20),"Dan Cutshal");
    g_hash_table_insert(table,GUINT_TO_POINTER(30),"Mystery Person");

    name = g_hash_table_lookup(table,GUINT_TO_POINTER(10));
    g_assert_cmpstr("Art Hundiak",==,name);

    status = g_hash_table_remove(table,GUINT_TO_POINTER(20));
    g_assert(status);

    name = g_hash_table_lookup(table,GUINT_TO_POINTER(20));
    g_assert(!name);

    g_hash_table_destroy(table);

}
void test_hash4(void)
{
    GHashTable *table;
    gchar           *name;
    gboolean       status;


    table = isdp_g_hash_table_int_new(NULL);

    isdp_g_hash_table_int_insert(table,10,"Art Hundiak");
    isdp_g_hash_table_int_insert(table,20,"Dan Cutshal");
    isdp_g_hash_table_int_insert(table,30,"Mystery Person");

    name = isdp_g_hash_table_int_lookup(table,10);
    g_assert_cmpstr("Art Hundiak",==,name);

    status = isdp_g_hash_table_int_remove(table,20);
    g_assert(status);

    name = isdp_g_hash_table_int_lookup(table,20);
    g_assert(!name);

    g_hash_table_destroy(table);

}
