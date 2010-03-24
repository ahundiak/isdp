#ifndef HASH_D_INCLUDED
#define HASH_D_INCLUDED 1

struct hash_table
{
   int                size;
   int                (*hashfn)();
   int                (*compfn)();
   struct hash_record *table[1];
};

struct hash_record
{
   char               *p_key;
   char               *value;
   struct hash_record *next;
};

#endif
