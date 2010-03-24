
/* -----------------------------------------------------------------

	This file defines routines for:

	. memory management - allocation/deallocation
	. symbol table management - for names etc.

   ----------------------------------------------------------------- */

#include "stdio.h"
#include "ctype.h"
#include "trans.h"

#define CHAR_ICOUNT		1000
#define INTEGER_ICOUNT		100
#define NAMNODE_ICOUNT		100
#define PARENT_ICOUNT		10
#define REJECT_ICOUNT		05
#define CHANNEL_ICOUNT		10
#define REST_ICOUNT		05
#define CHTYPE_ICOUNT		10
#define CTYPE_ICOUNT		50
#define FIELD_ICOUNT		50
#define ATTR_ICOUNT		50

struct namenode
{
	struct namenode *p_next;
	char *name;
};

struct Memory_block
{
	char *block;
	struct Memory_block *p_next;
};

static struct Memory_table
{
	int total_struct_count;
	int structs_per_block;
	int sizeof_struct;
	struct Memory_block *Mem;
} mtab[] =
	{
		{ 0, CHAR_ICOUNT,	sizeof(char),		NULL },
		{ 0, INTEGER_ICOUNT,	sizeof(int),		NULL },
		{ 0, NAMNODE_ICOUNT,	sizeof(struct namenode),NULL },
		{ 0, PARENT_ICOUNT,	sizeof(DROS_S_PARENT),	NULL },
		{ 0, REJECT_ICOUNT,	sizeof(DROS_S_REJECT),	NULL },
		{ 0, CHANNEL_ICOUNT,	sizeof(DROS_S_CHANNEL),	NULL },
		{ 0, REST_ICOUNT,	sizeof(DROS_S_REST),	NULL },
		{ 0, CHTYPE_ICOUNT,	sizeof(DROS_S_CHTYPE),	NULL },
		{ 0, CTYPE_ICOUNT,	sizeof(DROS_S_CTYPE),	NULL },
		{ 0, FIELD_ICOUNT,	sizeof(DROS_S_FIELD),	NULL },
		{ 0, ATTR_ICOUNT,	sizeof(DROS_S_ATTR),	NULL }
	};

char *getnode(count, node_type)
int count;
enum dros_struct_type node_type;
{
	int index, byte_size;
	struct Memory_block *Mem;
	char *ptr;

	if ((node_type < character) || (node_type > attr_struct))
	{
		fprintf(stderr, "getnode: Error in node_type %d\n",
			node_type);
		return(NULL);
	}

	if (count > mtab[node_type].structs_per_block)
	{
		fprintf(stderr, "getnode: invalid count (%d) - node_type %d\n",
			count, node_type);
		return(NULL);
	}

	index = mtab[node_type].total_struct_count %
		mtab[node_type].structs_per_block;

	if ((index == 0) ||
	    (index + count > mtab[node_type].structs_per_block))
	{
		mtab[node_type].total_struct_count +=
		mtab[node_type].structs_per_block - index;
		index = 0;
		byte_size = sizeof(struct Memory_block);
		Mem = (struct Memory_block *)malloc(byte_size);
		if (Mem)
		{
			byte_size  = mtab[node_type].structs_per_block *
				     mtab[node_type].sizeof_struct;
			Mem->block = (char *)malloc(byte_size);
		}

		if ((Mem == NULL) || (Mem->block == NULL))
		{
			fprintf(stderr, "getnode: malloc failure\n");
			return(NULL);
		}

		Mem->p_next = mtab[node_type].Mem;
		mtab[node_type].Mem = Mem;
	}
	else	Mem = mtab[node_type].Mem;

	ptr = Mem->block + index * mtab[node_type].sizeof_struct;
	mtab[node_type].total_struct_count += count;

	return(ptr);
}

struct namenode *hash_table[1024];

get_hash_index(name)
char *name;
{
	int hash_index, i;

	i = 0;
	hash_index = 0;
	while (name[i])
	{
		hash_index += (0x01FF & (name[i] << i));
		i++;
	}

	hash_index %= 1024;
	return(hash_index);
}

char *getname(name)
char *name;
{
	int hash_index;
	struct namenode *p_node;

	hash_index = get_hash_index(name);
	p_node = hash_table[hash_index];

	while (p_node)
	{
		if (!strcmp(p_node->name, name))
			return(p_node->name);
		p_node = p_node->p_next;
	}

	p_node = (struct namenode *)getnode(1, namenode_struct);
	p_node->name = getnode(strlen(name) + 2, character);
	strcpy(p_node->name, name);
	p_node->name[strlen(name)+1] = '\0';
	p_node->p_next = hash_table[hash_index];
	hash_table[hash_index] = p_node;

	return(p_node->name);
}

