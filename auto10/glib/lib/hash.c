#include "config.h"
#include <glib.h>
#include "hash.h"

/* ============================
 * Use integers for indexes
 * For some reason, g_int_hash core dumps, wanted uint anyways
 */
guint isdp_g_uint_hash(gconstpointer v)
{
    return GPOINTER_TO_UINT(v);
}
guint isdp_g_int_hash(gconstpointer v)
{
    return GPOINTER_TO_INT(v);
}
gboolean isdp_g_uint_equal(gconstpointer v1, gconstpointer v2)
{
    return (GPOINTER_TO_UINT(v1) == GPOINTER_TO_UINT(v2)) ? TRUE : FALSE;
}
gboolean isdp_g_int_equal(gconstpointer v1, gconstpointer v2)
{
    return (GPOINTER_TO_INT(v1) == GPOINTER_TO_INT(v2)) ? TRUE : FALSE;
}

/* =========================================
 * Write my own simpilified interface for integer hashes
 */
GHashTable *isdp_g_hash_table_int_new(GDestroyNotify destroyFunc)
{
     return g_hash_table_new_full(isdp_g_int_hash,isdp_g_int_equal,NULL,destroyFunc);
}
void isdp_g_hash_table_int_insert(GHashTable *table, gint key, gpointer value)
{
    g_hash_table_insert(table,GINT_TO_POINTER(key),value);
}
gpointer isdp_g_hash_table_int_lookup(GHashTable *table, guint key)
{
    return g_hash_table_lookup(table,GINT_TO_POINTER(key));
}
gboolean isdp_g_hash_table_int_remove(GHashTable *table, guint key)
{
    return g_hash_table_remove(table,GINT_TO_POINTER(key));
}
