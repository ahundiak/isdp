/*
------------------------------------------------------------------------------

	Name:			ddp_hash.c      
	Author:			R. Eade
	Creation Date:		January, 1988

	Abstract:
			Implements a simple character string hashing
			scheme.

	Revisions:
				
------------------------------------------------------------------------------
*/
#include "ddp_hash.h"
#include "ddp_error.h"

extern int Gf_verbose;

/*---------------------------------------------------------------------------
   DDP_new_hash_table

   Constructs a hash table of the specified size
-----------------------------------------------------------------------------*/
struct hash_table *DDP_new_hash_table(tsize, hashfn, compfn)
int tsize;		/* hash table size */
int (*hashfn)(); 	/* hashing function */
int (*compfn)();	/* comparison function */
{
   struct hash_table *p_new;
   int DDP_hashfn(), strcmp();

   p_new = 0;

   if (Gf_verbose)
      error(INFO,"DDP_new_hash_table: of size %d",tsize);

   if (tsize)
   {
      p_new = (struct hash_table *) 
                 calloc(1,sizeof(struct hash_table)+
                          ((tsize-1)*sizeof(struct hash_record *)));
      p_new->size = tsize;

      if (Gf_verbose)
         error(INFO,", p_table=%#x",p_new);
   }

   if (Gf_verbose)
      error(INFO,"\n");

   p_new->hashfn = (hashfn?hashfn:DDP_hashfn);
   p_new->compfn = (compfn?compfn:strcmp);
   return (p_new);
}

/*----------------------------------------------------------------------------
   DDP_delete_hash_table

   Frees all the memory allocated to a hash table 
-----------------------------------------------------------------------------*/
void DDP_delete_hash_table(p_table)
struct hash_table *p_table;
{
   int ii;

   if (Gf_verbose)
      error(INFO,"DDP_delete_hash_table: p_table=%#x\n",p_table);

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
   DDP_hash_lookup

   Returns pointer to key or null on symbol existence in table
----------------------------------------------------------------------------*/
char *DDP_hash_lookup(p_table, p_key)
struct hash_table *p_table;
char              *p_key;
{
   int hashVal;
   struct hash_record *p_tmp;
   char *p_found;

   p_found = 0;
   hashVal = p_table->hashfn(p_key) % p_table->size;
   
   for (p_tmp=p_table->table[hashVal]; p_tmp && (!p_found); p_tmp=p_tmp->next)
      if (! p_table->compfn(p_key, p_tmp->p_key))
         p_found = p_tmp->p_key;

   return (p_found);
}

/*----------------------------------------------------------------------------
   DDP_hash_add

   Add a new key to the hash table.
----------------------------------------------------------------------------*/
void DDP_hash_add(p_table, p_key)
struct hash_table *p_table;
char              *p_key;
{
   int hashVal;
   struct hash_record *p_new;
   struct hash_record *p_tmp;

   if (Gf_verbose)
      error(INFO,"DDP_hash_add: key='%s'\n",p_key);

   p_new = (struct hash_record *) calloc(1,sizeof(struct hash_record));
   p_new->p_key = p_key;

   hashVal = p_table->hashfn(p_key) % p_table->size;

   p_tmp = p_table->table[hashVal];      
   p_table->table[hashVal] = p_new;
   p_new->next = p_tmp;

   return;
}

/*----------------------------------------------------------------------------
   DDP_hashfn

   Returns an integer hash value for the specified character 
   string.
-----------------------------------------------------------------------------*/
int DDP_hashfn(p_key)
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
