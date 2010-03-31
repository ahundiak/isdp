#ifndef _emsipch_
#define _emsipch_

#define PERMS           0666
#define SHMKEY          ((key_t) 1234)    /* Shared memory key */

#define SEMKEY1 	((key_t) 1110)    /* EMS process semaphore key */
#define SEMKEY2 	((key_t) 1111)    /* External process semaphore key */

#define END_OF_TREE     -1                /* op_type value for end_of_tree */

typedef struct _EMPartdata
{
  char number[256];
  char revision[256];
  char description[256];
  char filename[1024];
} EMPartData;

typedef struct _node_data
{
  char            intosname[32];
  int             depth;
  int      	  op_type;
  EMPartData      o_part;
  EMPartData      n_part;
}NodeInfo;

typedef struct _RevAsmTree
{
  NodeInfo info;

  struct _RevAsmTree  *parent;
  struct _RevAsmTree  *next;
  struct _RevAsmTree  *child;
  struct _RevAsmTree  *sibling;
} REVASM_TREE;


#endif /*_emsipch_*/
