/* 
 * File:   hash.h
 * Author: impd
 *
 * Created on December 5, 2010, 11:37 AM
 */

#ifndef ISDP_G_HASH_H
#define	ISDP_G_HASH_H

#ifdef	__cplusplus
extern "C" {
#endif

extern guint isdp_g_uint_hash(gconstpointer v);
extern guint isdp_g_int_hash(gconstpointer v);
extern gboolean isdp_g_uint_equal(gconstpointer v1, gconstpointer v2);
extern gboolean isdp_g_int_equal(gconstpointer v1, gconstpointer v2);

extern GHashTable   *isdp_g_hash_table_int_new(GDestroyNotify destroy_func);
extern void                 isdp_g_hash_table_int_insert(GHashTable *table, gint key, gpointer value);
extern gpointer          isdp_g_hash_table_int_lookup(GHashTable *table, guint key);
extern gboolean         isdp_g_hash_table_int_remove(GHashTable *table, guint key);

#ifdef	__cplusplus
}
#endif

#endif	/* HASH_H */

