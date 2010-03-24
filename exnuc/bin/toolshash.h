#ifndef HASH_D_INCLUDED
#define HASH_D_INCLUDED 1

typedef struct hash_table
{
   int                size;
   int                (*hashfn)(char *);
   int                (*compfn)(const char *, const char *);
   struct hash_record *table[1];
} S_HASHTABLE;

typedef struct hash_record
{
   char               *p_key;
   char               *value;
   struct hash_record *next;
} S_HASHRECORD;

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* toolshash.c */
struct hash_table *new_hash_table __((int tsize, int (*hashfn )(char *), int (*compfn )(const char *, const char *)));
void delete_hash_table __((struct hash_table *p_table));
struct hash_record *hash_lookup __((struct hash_table *p_table, char *p_key));
struct hash_record *hash_add __((struct hash_table *p_table, char *p_key));
int def_hashfn __((char *p_key));
void hash_dump __((struct hash_table *p_table));
void hash_process __((struct hash_table *p_table, void (*process )()));

#if defined(__cplusplus)
}
#endif

#endif
