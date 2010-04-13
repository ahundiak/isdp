#include <stdio.h>
#include <malloc.h>
#include <string.h>
#define HASH_SRC
#include "toolshash.h"

/*---------------------------------------------------------------------------
   new_hash_table

   Constructs a hash table of the specified size
-----------------------------------------------------------------------------*/
struct hash_table *new_hash_table(
int tsize,		/* hash table size */
int (*hashfn)(char *), 	/* hashing function */
int (*compfn)(const char *, const char *)	/* comparison function */
)
{
   struct hash_table *p_new;

   p_new = 0;

   if (tsize)
   {
      p_new = (struct hash_table *) 
                 calloc(1,sizeof(struct hash_table)+
                          ((tsize-1)*sizeof(struct hash_record *)));
      p_new->size = tsize;

   }

   p_new->hashfn = (hashfn?hashfn:(int (*)(char *)) def_hashfn);
   p_new->compfn = (compfn?compfn:strcmp);
   return (p_new);
}

/*----------------------------------------------------------------------------
   delete_hash_table

   Frees all the memory allocated to a hash table 
-----------------------------------------------------------------------------*/
void delete_hash_table(p_table)
struct hash_table *p_table;
{
   int ii;

   if (! p_table)
      return;

   for (ii=0; ii < p_table->size; ++ii)
      if (p_table->table[ii])
      {
         struct hash_record *p_tmp;
         struct hash_record *p_tmp_next;

         for (p_tmp = p_table->table[ii]; p_tmp; p_tmp=p_tmp_next)
         {
            p_tmp_next = p_tmp->next;            
            free(p_tmp);
         }
      }

   free(p_table);
}

/*--------------------------------------------------------------------------
   hash_lookup

   Returns pointer to record or null on symbol existence in table
----------------------------------------------------------------------------*/
struct hash_record *hash_lookup(p_table, p_key)
struct hash_table *p_table;
char              *p_key;
{
   int hashVal;
   struct hash_record *p_tmp;
   struct hash_record *found = 0;

   hashVal = p_table->hashfn(p_key) % p_table->size;
   
   for (p_tmp=p_table->table[hashVal]; p_tmp && (!found); p_tmp=p_tmp->next)
      if (! p_table->compfn(p_key, p_tmp->p_key))
         found = p_tmp;

   return (found);
}

/*----------------------------------------------------------------------------
   hash_add

   Add a new key to the hash table.
----------------------------------------------------------------------------*/
struct hash_record *hash_add(p_table, p_key)
struct hash_table *p_table;
char              *p_key;
{
   int hashVal;
   struct hash_record *p_new;
   struct hash_record *p_tmp;

   p_new = (struct hash_record *) calloc(1,sizeof(struct hash_record));
   p_new->p_key = p_key;

   hashVal = p_table->hashfn(p_key) % p_table->size;

   p_tmp = p_table->table[hashVal];      
   p_table->table[hashVal] = p_new;
   p_new->next = p_tmp;

   return(p_new);
}

/*----------------------------------------------------------------------------
   def_hashfn

   Returns an integer hash value for the specified character 
   string.
-----------------------------------------------------------------------------*/
int def_hashfn(p_key)
char *p_key;
{
   int   hashVal = 0;
   long  grouper;
   int   ii;

   for (ii = 0; *p_key != '\0'; p_key++) 
   {
      ((char *)&grouper)[ii] = *p_key;
      if (ii == sizeof(long) - 1) 
      {
         hashVal ^= grouper;
         ii = 0;
      } 
      else 
         ii++;
   }

   if (ii != 0) 
   {
      for (; ii <= sizeof(long) - 1; ii++)
         ((char *)&grouper)[ii] = '\0';
      hashVal ^= grouper;
   }

   return (hashVal);
}

/*------------------------------------------------------------------------
  hash_dump
  
  Prints the entire contents of the specfied table 
  on <stderr>.
------------------------------------------------------------------------*/
void hash_dump(p_table)
struct hash_table *p_table;
{
   int ii, in_table;
   struct hash_record *p_rec;
   
   if (p_table)
      for (ii=0; ii < p_table->size; ++ii)
         for (p_rec=p_table->table[ii], in_table=1; p_rec; p_rec=p_rec->next)
            if (! in_table)
               fprintf(stderr, "0x%.8x:\t\"%s\"\n", p_rec, p_rec->p_key);
            else
            {
               in_table = 0;
               fprintf(stderr, "[%d]:\t\"%s\"\n", ii, p_rec->p_key);
            }
}

/*------------------------------------------------------------------------
  hash_process
  
  Calls a function for every member of the hash table.
------------------------------------------------------------------------*/
void hash_process(p_table, process)
struct hash_table *p_table;
void (*process)();
{
   int ii;
   struct hash_record *p_rec;
   
   if (p_table)
      for (ii=0; ii < p_table->size; ++ii)
         for (p_rec=p_table->table[ii]; p_rec; p_rec=p_rec->next)
            process(p_rec->value);
}


