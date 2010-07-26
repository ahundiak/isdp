/*
   ABSTRACT :  This file contains the typedef and constant declarations
   --------    for the DIbtrees.
   
   DEPENDANCE : OMminimum.h
   ----------
*/
#ifndef dibtree
#define dibtree

/* Error Codes */
#ifndef WARN

#define WARN 0
#define SUCC 1
#define ERRO 2
#define INFO 3
#define SEVE 4

#endif


#define DIR_E_ILL_TREE 	(ERRO | 0x270)


#define DIR_NUM_BTREES      5   /* we have 5 different kinds of btrees	*/


/* tables of sizeof */
extern int DIB_ptr_sizes [DIR_NUM_BTREES];


/* table of compare functions */
extern int (*DIB_comp [DIR_NUM_BTREES]) ();

/* current data (used in compare functions)	*/
extern char **DIB_cur_data;


typedef struct BTree
        {
       	  DIchar *root		/* pointer to the root of the tree 	*/;
       	  DIchar type		/* what kind of tree is this		*/;
	  DIint  nfree		/* next free position in data		*/;
          DIint  *data		/* the entries of the B-tree		*/;
          DIint  (*cmp)() 	/* the compare routine			*/;
          DIint  size		/* the info size			*/;
          DIint  last		/* last index that has been accessed	*/;
        } btree;


#define B_TREE_LIMIT 20
#define my_data  me->tree->data
#define my_last  me->tree->last
#define my_root  me->tree->root
#define my_free  me->tree->nfree
#define my_type  me->tree->type
#define my_tree  me->tree
#define my_buf   me->buffer
#define my_size  me->tree->size
#define my_cmp   me->tree->cmp


#define print_buf()      {DIint i;printf("me->buffer (%d): ",om$dimension_of ( varray = me->buffer ));for(i = 0;i<om$dimension_of(varray=me->buffer);i++)printf("%u ",me->buffer[i]);printf ("\n");}
#define my_buf_size()    om$dimension_of(varray=me->buffer)
#define inc_my_buf(inc)  om$vla_set_dimension(varray=me->buffer,size=om$dimension_of(varray=me->buffer)+(inc))
#define set_buf_size(sz) om$vla_set_dimension(varray=me->buffer,size=(sz))

#define ind_nm(ind)          (&my_buf[my_data [(ind)]])
#define index_id(ind)        (&my_buf[my_data [(ind)]-my_size])
#define btree_add(index)     {DIBcur_index=(DIchar **)my_data;DIBcur_buffer=(DIchar *)&me->buffer[0];tsearch((DIchar*)(index),(void **)&my_root,my_cmp);}
#define btree_get(key,index) {DIint *ptr;DIBcur_index=(DIchar **)my_data;DIBcur_buffer=&me->buffer[0];DIBcur_string=(key);(index)=(ptr=(DIint *)tfind((void *)-1, (void **) &my_root, my_cmp)) ? (my_last=*ptr) : (my_last=-1);}
#ifdef IRIX5
#define btree_delete(index)  {if (*ind_nm(index))tdelete((void *)-1,(void **)&my_root,my_cmp);DIBdecr_index=(index);twalk((void *)my_root,(void (*))DIBdecr);}
#else
#define btree_delete(index)  {if (*ind_nm(index))tdelete((void *)-1,(void **)&my_root,my_cmp);DIBdecr_index=(index);twalk((void *)my_root,DIBdecr);}
#endif


#endif
