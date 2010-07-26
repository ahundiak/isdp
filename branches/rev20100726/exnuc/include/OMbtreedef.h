#ifndef OMBTREEDEF
#define OMBTREEDEF


typedef
    unsigned short  OFFSET_ENTRY;
typedef
    unsigned short  KEY_LENGTH;
typedef
    unsigned short  REC_PTR_COUNT;
typedef
    unsigned short  CHILD_PTR_COUNT;


/* Following are the definitions and type definitions
   required for the BTREE modules.    YCT 7/31/1985 */


#define BYTES_HALF_PAGE              ( DB_BYTES_BPAGE/2 )
#define BYTES_B_LF_HEADER            ( 20 )
#define BYTES_B_NL_HEADER            ( 10 )
#define BYTES_B_LF_OFFSET_KEY_AREA   ( DB_BYTES_BPAGE - BYTES_B_LF_HEADER )
#define BYTES_B_NL_OFFSET_KEY_AREA   ( DB_BYTES_BPAGE - BYTES_B_NL_HEADER )
#define BYTES_OFFSET_ENTRY           ( 2 )
#define BYTES_KEY_LENGTH             ( 2 )
#define BYTES_REC_PTR_COUNT          ( 2 )
#define BYTES_CHILD_PTR_COUNT          ( 2 )
#define BYTES_REC_PTR                ( 4 )
#define BYTES_CHILD_PTR                ( 4 )
#define BYTES_B_MAX_KEY              ( DB_BYTES_BPAGE             \
                                     - BYTES_B_LF_HEADER      \
                                     - BYTES_OFFSET_ENTRY     \
                                     - BYTES_KEY_LENGTH       \
                                     - BYTES_REC_PTR_COUNT    \
                                     - BYTES_REC_PTR         )



#define IS_B_LEAF(t)       ( ((t) == B_LF_RT_PAGE) || ((t) == B_LF_NR_PAGE) )
#define IS_B_ROOT(t)       ( ((t) == B_LF_RT_PAGE) || ((t) == B_NL_RT_PAGE) )
#define NOT_B_LEAF(t)      ( ((t) == B_NL_RT_PAGE) || ((t) == B_NL_NR_PAGE) )
#define NOT_B_ROOT(t)      ( ((t) == B_LF_NR_PAGE) || ((t) == B_NL_NR_PAGE) )



/* Spaces (bytes) required for an one-record-pointer leaf key entry. */

#define LF_KEY_SPACE_1(key_length)   ( BYTES_KEY_LENGTH        \
                                     + BYTES_REC_PTR_COUNT     \
                                     + (key_length)            \
                                     + BYTES_REC_PTR  )


/* Spaces (bytes) required for an one-record-pointer leaf key entry 
   and an offset entry. */

#define LF_OFFSET_KEY_SPACE_1(key_length)                      \
                                     ( BYTES_OFFSET_ENTRY      \
                                     + BYTES_KEY_LENGTH        \
                                     + BYTES_REC_PTR_COUNT     \
                                     + (key_length)            \
                                     + BYTES_REC_PTR  )

/* Spaces (bytes) required for a multiple-record-pointer leaf key entry. */

#define LF_KEY_SPACE(key_length, rec_ptr_count)                \
                                     ( BYTES_KEY_LENGTH        \
                                     + BYTES_REC_PTR_COUNT     \
                                     + (key_length)            \
                                     + (rec_ptr_count) * BYTES_REC_PTR )

/* Spaces (bytes) required for a multiple-record-pointer leaf key entry
   and an offset entry. */

#define LF_OFFSET_KEY_SPACE(key_length, rec_ptr_count)          \
                                     ( BYTES_OFFSET_ENTRY       \
                                     + BYTES_KEY_LENGTH         \
                                     + BYTES_REC_PTR_COUNT      \
                                     + (key_length)             \
                                     + (rec_ptr_count) * BYTES_REC_PTR )

/* Spaces (bytes) required for an one-record-pointer non-leaf key entry. */

#define NL_KEY_SPACE_1(key_length)   ( BYTES_KEY_LENGTH        \
                                     + BYTES_CHILD_PTR_COUNT     \
                                     + (key_length)            \
                                     + BYTES_CHILD_PTR       )  

/* Spaces (bytes) required for an one-record-pointer non-leaf key entry
   and an offset entry. */

#define NL_OFFSET_KEY_SPACE_1(key_length)                      \
                                     ( BYTES_OFFSET_ENTRY      \
                                     + BYTES_KEY_LENGTH        \
                                     + BYTES_CHILD_PTR_COUNT     \
                                     + (key_length)            \
                                     + BYTES_CHILD_PTR       )  

/* Spaces (bytes) required for a multiple-record-pointer non-leaf key entry. */

#define NL_KEY_SPACE(key_length, child_ptr_count)                \
                                     ( BYTES_KEY_LENGTH        \
                                     + BYTES_CHILD_PTR_COUNT     \
                                     + (key_length)            \
                                     + (child_ptr_count) * BYTES_CHILD_PTR )

/* Spaces (bytes) required for a multiple-record-pointer non-leaf key entry
   and an offset entry. */

#define NL_OFFSET_KEY_SPACE(key_length, child_ptr_count)         \
                                     ( BYTES_OFFSET_ENTRY      \
                                     + BYTES_KEY_LENGTH        \
                                     + BYTES_CHILD_PTR_COUNT     \
                                     + (key_length)            \
                                     + (child_ptr_count) * BYTES_CHILD_PTR )



/* Special note: In order to produce the correct results from using
                 the following macro definitions, variables should 
                 be defined in your program with the data types as
                 follows:
                 
                   B_LF_PAGE      *leaf_page_p;
                   B_NL_PAGE      *nonleaf_page_p;
                   unsigned short offset_entry_num;
                   KEY_LENGTH     key_length;
                   REC_PTR_COUNT  *rec_ptr_count_p;
                   CHILD_PTR_COUNT  *child_ptr_count_p;
                   char           *key_p;
                   long        *rec_ptr_p;
                   OM_S_OBJID  child_ptr;
		   OM_S_OBJID  *child_ptr_p;
                   char           *key_entry_p;
                   long        *new_rec_ptr_location_p;
                   long        *new_rec_ptr_p;
                   long        *rec_ptr_p_1;
                   long        *rec_ptr_p_2;
                   short          result;                       */
                                               


/* Get a leaf key entry passing leaf_page_p and offset_entry_num as 
   input  parameters. */

#define GET_LF_KEY_ENTRY(leaf_page_p, offset_entry_num, key_length, rec_ptr_count_p, key_p, rec_ptr_p)                                                 \
        {                                                                   \
        OFFSET_ENTRY     *offset_entry_p;                                   \
        char             *key_entry_p;                                      \
                                                                            \
        offset_entry_p = (OFFSET_ENTRY *)                                   \
                              ((char *)(leaf_page_p)                        \
                              + BYTES_B_LF_HEADER                           \
                              + BYTES_OFFSET_ENTRY * (offset_entry_num));     \
        key_entry_p = *offset_entry_p + (char *)leaf_page_p;                \
                                                                            \
        key_length = *((KEY_LENGTH *)key_entry_p);            \
	rec_ptr_count_p = (REC_PTR_COUNT *)(key_entry_p +BYTES_KEY_LENGTH); \
	key_p = (char *)rec_ptr_count_p + BYTES_REC_PTR_COUNT;              \
	rec_ptr_p = (long *)(key_p + key_length);                        \
	}
	


/* Get a non-leaf key entry passing nonleaf_page_p and offset_entry_num as
   input parameters. */        

#define GET_NL_KEY_ENTRY(nonleaf_page_p, offset_entry_num, nl_key_length, key_length,child_ptr_count_p, key_p, child_ptr_p)                                                  \
        {                                                                   \
        OFFSET_ENTRY     *offset_entry_p;                                   \
        char             *key_entry_p;                                      \
                                                                            \
        offset_entry_p = (OFFSET_ENTRY *)                                   \
                              ((char *)(nonleaf_page_p)                     \
                              + BYTES_B_NL_HEADER                           \
                              + BYTES_OFFSET_ENTRY * (offset_entry_num));   \
        key_entry_p = *offset_entry_p + (char *)nonleaf_page_p;             \
                                                                            \
        key_length = *((KEY_LENGTH *)key_entry_p);            \
	child_ptr_count_p = (CHILD_PTR_COUNT *)(key_entry_p +BYTES_KEY_LENGTH); \
	key_p = (char *)child_ptr_count_p + BYTES_CHILD_PTR_COUNT;              \
	child_ptr_p =(OM_S_OBJID *)(key_p + nl_key_length);                   \
	}
	
        

/* Put a leaf key entry and all parameters are input parameters. */


#define PUT_LF_KEY_ENTRY(leaf_page_p,  offset_entry_num, key_entry_p)        \
        {                                                                    \
        unsigned short  bytes_key_entry;                                     \
        OFFSET_ENTRY    *new_offset_location_p, *p;                          \
                                                                             \
      	bytes_key_entry = LF_KEY_SPACE( *((KEY_LENGTH *)(key_entry_p)),      \
                       *((REC_PTR_COUNT *)((key_entry_p)+BYTES_KEY_LENGTH)));\
	(leaf_page_p)->Key_start -= bytes_key_entry;                         \
	DB_MOV_N_BYTES((key_entry_p),                                           \
                    ((char *)(leaf_page_p) + (leaf_page_p)->Key_start),      \
                    bytes_key_entry                          );              \
        new_offset_location_p                                                \
               = (OFFSET_ENTRY *)                                            \
                   ((char *)(leaf_page_p)                                    \
                   + BYTES_B_LF_HEADER                                       \
                   + (offset_entry_num) * BYTES_OFFSET_ENTRY);               \
        for (p = (OFFSET_ENTRY *)                                            \
                   ((char *)(leaf_page_p)                                    \
                   + BYTES_B_LF_HEADER                                       \
                   + (leaf_page_p)->Offset_entry_count * BYTES_OFFSET_ENTRY);\
             p > new_offset_location_p;                                      \
             p--        )                                                    \
        *p = *((OFFSET_ENTRY *)(p-1));        \
        *new_offset_location_p = (leaf_page_p)->Key_start;                   \
        (leaf_page_p)->Offset_entry_count++;                                 \
        (leaf_page_p)->Space_used += (BYTES_OFFSET_ENTRY + bytes_key_entry); \
	}
     


/* Put a non-leaf key entry and all parameters are input parameters. */

#define PUT_NL_KEY_ENTRY(nonleaf_page_p,  offset_entry_num, key_entry_p, nl_key_length)\
        {                                                                    \
        unsigned short  bytes_key_entry;                                     \
        OFFSET_ENTRY    *new_offset_location_p, *p;                          \
                                                                             \
	bytes_key_entry = NL_KEY_SPACE(nl_key_length , 			     \
                       *((CHILD_PTR_COUNT *)((key_entry_p)+BYTES_KEY_LENGTH)));\
	(nonleaf_page_p)->Key_start -= bytes_key_entry;                      \
	DB_MOV_N_BYTES((key_entry_p),                                           \
                    ((char *)(nonleaf_page_p) + (nonleaf_page_p)->Key_start),\
                    bytes_key_entry                          );              \
        new_offset_location_p                                                \
             = (OFFSET_ENTRY *)                                              \
                ((char *)(nonleaf_page_p)                                    \
                + BYTES_B_NL_HEADER                                          \
                + (offset_entry_num) * BYTES_OFFSET_ENTRY);                  \
        for (p = (OFFSET_ENTRY *)                                            \
                ((char *)(nonleaf_page_p)                                    \
                + BYTES_B_NL_HEADER                                          \
                + (nonleaf_page_p)->Offset_entry_count * BYTES_OFFSET_ENTRY);\
             p > new_offset_location_p;                                      \
             p--        )                                                    \
        *p = *((OFFSET_ENTRY *)(p-1));        \
        *new_offset_location_p = (nonleaf_page_p)->Key_start;                \
       (nonleaf_page_p)->Offset_entry_count++;                               \
       (nonleaf_page_p)->Space_used += (BYTES_OFFSET_ENTRY +bytes_key_entry);\
	}
     


/* Put a record pointer in an existing leaf key entry and all parameters are
   input parameters. */

#define PUT_REC_PTR(leaf_page_p, offset_entry_num, rec_ptr_num, new_rec_ptr_p)\
        {                                                                    \
        int i;								     \
        unsigned short nbytes, leaf_key_space, hdrsz, low, nbytes1;	     \
        char           *key_entry_p, *destination_p, *source_p, xsv[512];    \
        OFFSET_ENTRY   *offset_entry_p, *oep;                                \
                                                                             \
        offset_entry_p = (OFFSET_ENTRY *)                                    \
                              ((char *)(leaf_page_p)                         \
                              + BYTES_B_LF_HEADER                            \
                              + BYTES_OFFSET_ENTRY * offset_entry_num);      \
        key_entry_p = *offset_entry_p + (char *)(leaf_page_p);               \
        leaf_key_space                                                       \
             =  LF_KEY_SPACE                                                 \
                 ( *(KEY_LENGTH *)(key_entry_p),                             \
                  ++(*(REC_PTR_COUNT *)((key_entry_p) + BYTES_KEY_LENGTH)) );\
        hdrsz = BYTES_B_LF_HEADER + (leaf_page_p)->Offset_entry_count *      \
                BYTES_OFFSET_ENTRY;                                          \
        if ((leaf_page_p)->Key_start < (unsigned short)(leaf_key_space + hdrsz)) {             \
           oep = (OFFSET_ENTRY *) ((char *)(leaf_page_p) + BYTES_B_LF_HEADER);\
           low = oep[0];						     \
           for (i=1; i< (int) (leaf_page_p)->Offset_entry_count; ++i)	     \
              if (oep[i] < (OFFSET_ENTRY) low) low = oep[i];		     \
           if (*offset_entry_p != low) {				     \
              source_p = (char *)(leaf_page_p) + *offset_entry_p;	     \
              nbytes1 = leaf_key_space - BYTES_REC_PTR;			     \
              DB_MOV_N_BYTES(source_p, xsv, nbytes1);			     \
              source_p = (char *)(leaf_page_p) + low;			     \
              destination_p = source_p + nbytes1;			     \
              nbytes = *offset_entry_p - low;				     \
              DB_MOV_N_BYTES(source_p, destination_p, nbytes);		     \
              for (i=0; i< (int) (leaf_page_p)->Offset_entry_count; ++i)     \
                 if (oep[i] < *offset_entry_p) 				     \
                    oep[i] += nbytes1;					     \
              *offset_entry_p -= nbytes;				     \
              destination_p = (char *)(leaf_page_p) + *offset_entry_p;       \
              DB_MOV_N_BYTES(xsv, destination_p, nbytes1);		     \
              key_entry_p = (char *)(leaf_page_p) + *offset_entry_p;	     \
           }								     \
           (leaf_page_p)->Key_start -= BYTES_REC_PTR;             	     \
        }								     \
        else								     \
           (leaf_page_p)->Key_start -= leaf_key_space;			     \
									     \
        *offset_entry_p = (leaf_page_p)->Key_start;                          \
	(leaf_page_p)->Space_used += BYTES_REC_PTR;                          \
	destination_p                                                        \
             = (char *)(leaf_page_p)                                         \
                 + (leaf_page_p)->Key_start;                                 \
        nbytes =  LF_KEY_SPACE                                               \
                 ( *(KEY_LENGTH *)(key_entry_p), rec_ptr_num);               \
        DB_MOV_N_BYTES((key_entry_p), destination_p, nbytes);                \
                                                                             \
        destination_p += nbytes;                                             \
        DB_MOV_N_BYTES((new_rec_ptr_p), destination_p, BYTES_REC_PTR);       \
        destination_p += BYTES_REC_PTR;                                      \
        key_entry_p += nbytes;                                               \
        nbytes = leaf_key_space - nbytes - BYTES_REC_PTR;                    \
        DB_MOV_N_BYTES(key_entry_p, destination_p, nbytes);                  \
                                                                             \
        }
	             

#define MOVE_LEAF_KEY(leaf_page_p, offset_entry_num, rec_ptr_num, new_rec_ptr_p) \
	{ \
	unsigned short nbytes, offnbytes, num_ent, mov_bytes; \
	char *key_entry_p, *destination_p, *offsource_p; \
	char key_save[BYTES_B_LF_OFFSET_KEY_AREA]; \
	OFFSET_ENTRY *offset_entry_p; \
	offset_entry_p = (OFFSET_ENTRY *)	\
		((char *)(leaf_page_p)		\
		+ BYTES_B_LF_HEADER		\
		+ BYTES_OFFSET_ENTRY * offset_entry_num); \
	key_entry_p = *offset_entry_p + (char *)(leaf_page_p); \
	                                \
	destination_p = key_save;	\
        num_ent = *(REC_PTR_COUNT *)((key_entry_p) + BYTES_KEY_LENGTH); \
	mov_bytes = LF_KEY_SPACE		\
		  ( (*(KEY_LENGTH *)(key_entry_p)), num_ent);	\
	DB_MOV_N_BYTES((key_entry_p), destination_p, mov_bytes);	\
					                        \
	(leaf_page_p)->Space_used -= ( mov_bytes + BYTES_OFFSET_ENTRY ); \
	(leaf_page_p)->Offset_entry_count--;	\
        if (leaf_page_p->Offset_entry_count > 0) \
          { \
    	   offsource_p = (char *)(offset_entry_p + 1);	\
	   offnbytes = BYTES_OFFSET_ENTRY * \
	      ((leaf_page_p)->Offset_entry_count - offset_entry_num); \
	   DB_MOV_N_BYTES(offsource_p, ((char *)offset_entry_p), offnbytes); \
	   COMPRESS_LF_PAGE( leaf_page_p );	\
	  } \
	else \
	  { \
	   leaf_page_p->Key_start = DB_BYTES_BPAGE; \
          } \
	nbytes = LF_KEY_SPACE  \
		  ( (*(KEY_LENGTH *)(key_save)), rec_ptr_num); \
	destination_p += nbytes; \
        if (num_ent > (unsigned short) rec_ptr_num) { \
           mov_bytes = (num_ent - rec_ptr_num) * 4; \
           DB_MOV_N_BYTES(destination_p,destination_p+4,mov_bytes); \
        } \
	DB_MOV_N_BYTES(((char *)(new_rec_ptr_p)), destination_p, \
		BYTES_REC_PTR); \
	(*(REC_PTR_COUNT *)((key_save) + BYTES_KEY_LENGTH))++;	\
	PUT_LF_KEY_ENTRY(leaf_page_p, offset_entry_num, key_save); \
	}


/* Put a logical page number in an existing non-leaf key entry and all 
   parameters are input parameters. */

#define PUT_CHILD_PTR(nonleaf_page_p, offset_entry_num, child_entry_num, new_child_ptr, nl_key_length)                                                   \
        {                                                                    \
        unsigned short nonleaf_key_space;                            \
        char           *key_entry_p, *destination_p;                         \
        OFFSET_ENTRY   *offset_entry_p;                                      \
        OM_S_OBJID     *new_child_ptr_loc_p, *p;    	\
                                                                             \
                                                                             \
        offset_entry_p = (OFFSET_ENTRY *)                                    \
                           ((char *)(nonleaf_page_p)                         \
                           + BYTES_B_NL_HEADER                               \
                           + BYTES_OFFSET_ENTRY * (offset_entry_num) );      \
        key_entry_p = *offset_entry_p + (char *)(nonleaf_page_p);            \
        nonleaf_key_space                                                    \
             =  NL_KEY_SPACE                                                 \
                 ( nl_key_length,		                             \
                  ++(*(CHILD_PTR_COUNT *)(key_entry_p + BYTES_KEY_LENGTH)) );  \
        (nonleaf_page_p)->Key_start -= nonleaf_key_space;                    \
        *offset_entry_p = (nonleaf_page_p)->Key_start;                       \
	(nonleaf_page_p)->Space_used += BYTES_CHILD_PTR;\
	destination_p                                                        \
           = (char *)(nonleaf_page_p)                                        \
                 + (nonleaf_page_p)->Key_start;                              \
        DB_MOV_N_BYTES((key_entry_p), destination_p,		\
                          nonleaf_key_space - BYTES_CHILD_PTR);		\
        new_child_ptr_loc_p = (OM_S_OBJID *) (destination_p + 	\
			NL_KEY_SPACE(nl_key_length, child_entry_num));	\
        for (p = (OM_S_OBJID *) (destination_p + nonleaf_key_space - BYTES_CHILD_PTR);	\
             p > new_child_ptr_loc_p; p--)	\
          {	\
          *p = *((OM_S_OBJID *) (p - 1));	\
	  }	\
        *new_child_ptr_loc_p = new_child_ptr;		\
        }

#define MOVE_NONLEAF_KEY(nonleaf_page_p, offset_entry_num, child_entry_num, child_ptr_count, new_child_ptr_p, nl_key_length) \
	{ \
	unsigned short nbytes, offnbytes; \
	char *key_entry_p, *destination_p, *offsource_p; \
	char key_save[BYTES_B_NL_OFFSET_KEY_AREA]; \
	OFFSET_ENTRY *offset_entry_p; \
	offset_entry_p = (OFFSET_ENTRY *)	\
		((char *)(nonleaf_page_p)		\
		+ BYTES_B_NL_HEADER		\
		+ BYTES_OFFSET_ENTRY * offset_entry_num); \
	key_entry_p = *offset_entry_p + (char *)(nonleaf_page_p); \
	                                \
	destination_p = key_save;	\
	nbytes = NL_KEY_SPACE		\
		  ( nl_key_length, child_entry_num );	\
	DB_MOV_N_BYTES((key_entry_p), destination_p, nbytes);	\
					                        \
	destination_p += nbytes;	\
	DB_MOV_N_BYTES(((char *)(new_child_ptr_p)), destination_p, \
		BYTES_CHILD_PTR); \
	DB_MOV_N_BYTES((key_entry_p + nbytes),(destination_p + BYTES_CHILD_PTR), BYTES_CHILD_PTR *	(child_ptr_count - child_entry_num));	\
					                        \
	(*(CHILD_PTR_COUNT *)((key_save) + BYTES_KEY_LENGTH))++;	\
	(nonleaf_page_p)->Space_used -= ( nbytes + BYTES_OFFSET_ENTRY );\
	offsource_p = (char *)(offset_entry_p + 1);	\
	offnbytes = BYTES_OFFSET_ENTRY * ((nonleaf_page_p)->Offset_entry_count\
			 - (offset_entry_num + 1) );	\
	DB_MOV_N_BYTES(offsource_p, ((char *)offset_entry_p), offnbytes); \
	(nonleaf_page_p)->Offset_entry_count--;	\
	COMPRESS_NL_PAGE( nonleaf_page_p, nl_key_length );	\
		                                \
	PUT_NL_KEY_ENTRY(nonleaf_page_p, offset_entry_num, key_save, nl_key_length); \
	}
	

/* Compare two record pointers and return values 1, 0 or -1 in result 
   indicating 1st record pointer is greater than, equal to, or less than
   2nd record pointer. */            

#define COMPARE_REC_PTR(rec_ptr_p_1, rec_ptr_p_2, result)               \
        {                                                               \
        if ((*rec_ptr_p_1) > (*rec_ptr_p_2))                              \
           result = 1;                                                  \
	else 								\
	   {								\
           if ( (*rec_ptr_p_1) == ( *rec_ptr_p_2) )			\
		result = 0;						\
           else								\
		result = -1;						\
	   }								\
        }

#define PUT_LF_KEY_ENTRY_P( leaf_page_p, key_entry_p, rec_ptr_p)  	\
     {									\
        unsigned short   nbytes, leaf_key_space;			\
	char             *destination_p;				\
	OFFSET_ENTRY     *offset_entry_p, *p;				\
									\
	leaf_key_space = LF_KEY_SPACE( *(KEY_LENGTH *)(key_entry_p), 	\
	       (*(REC_PTR_COUNT *)((key_entry_p) + BYTES_KEY_LENGTH))); \
        (leaf_page_p)->Key_start -= leaf_key_space;			\
        (leaf_page_p)->Space_used += ( leaf_key_space +BYTES_OFFSET_ENTRY);\
									\
	destination_p = (char *)(leaf_page_p) + (leaf_page_p)->Key_start;\
	nbytes = BYTES_KEY_LENGTH + BYTES_REC_PTR_COUNT + 		\
		 *(KEY_LENGTH *)(key_entry_p);				\
        DB_MOV_N_BYTES((key_entry_p), destination_p, nbytes);		\
        destination_p += nbytes;					\
	nbytes = (*(REC_PTR_COUNT *)(key_entry_p + BYTES_KEY_LENGTH))  *\
                 BYTES_REC_PTR;						\
	DB_MOV_N_BYTES ((rec_ptr_p), destination_p, nbytes );		\
									\
          offset_entry_p = (OFFSET_ENTRY *)((char *)(leaf_page_p) +	\
			   BYTES_B_LF_HEADER);				\
	  for (p = (OFFSET_ENTRY *)((char *)(leaf_page_p) +		\
		 BYTES_B_LF_HEADER + 					\
		 (leaf_page_p)->Offset_entry_count * BYTES_OFFSET_ENTRY);\
             p > offset_entry_p;					\
	     p-- )  							\
          {								\
            *p = *((OFFSET_ENTRY *)(p-1));        \
          }								\
        *offset_entry_p = (leaf_page_p)->Key_start;			\
  	(leaf_page_p)->Offset_entry_count++;				\
     }



#define PUT_NL_KEY_ENTRY_P( nonleaf_page_p, key_entry_p, child_ptr_p, nl_key_length)       		  	\
     {									\
        unsigned short   nbytes, nonleaf_key_space;			\
	char             *destination_p;				\
	OFFSET_ENTRY     *offset_entry_p, *p;				\
									\
	nonleaf_key_space = NL_KEY_SPACE( nl_key_length,		\
	       (*(CHILD_PTR_COUNT *)((key_entry_p) + BYTES_KEY_LENGTH))); \
        (nonleaf_page_p)->Key_start -= nonleaf_key_space;		\
        (nonleaf_page_p)->Space_used += 				\
			       ( nonleaf_key_space +BYTES_OFFSET_ENTRY);\
									\
	destination_p = (char *)(nonleaf_page_p) +			\
		        (nonleaf_page_p)->Key_start;			\
	nbytes = BYTES_KEY_LENGTH + BYTES_CHILD_PTR_COUNT + 		\
		 nl_key_length;						\
        DB_MOV_N_BYTES((key_entry_p), destination_p, nbytes);		\
        destination_p += nbytes;					\
	nbytes = (*(CHILD_PTR_COUNT *)(key_entry_p + BYTES_KEY_LENGTH))  *\
                 BYTES_CHILD_PTR;					\
	DB_MOV_N_BYTES (child_ptr_p, destination_p, nbytes);       \
									\
          offset_entry_p = (OFFSET_ENTRY *)((char *)(nonleaf_page_p) +	\
			   BYTES_B_NL_HEADER);				\
	  for (p = (OFFSET_ENTRY *)((char *)(nonleaf_page_p) +		\
		 BYTES_B_NL_HEADER + 					\
		 (nonleaf_page_p)->Offset_entry_count * BYTES_OFFSET_ENTRY);\
             p > offset_entry_p;					\
	     p-- )  							\
          {								\
           *p = *((OFFSET_ENTRY *)(p-1));        \
          }								\
        *offset_entry_p = (nonleaf_page_p)->Key_start;			\
  	(nonleaf_page_p)->Offset_entry_count++;				\
     }



#define    COMPRESS_LF_PAGE( leaf_p )           			\
          {								\
            B_LF_PAGE       *compress_page_p, page;			\
            OFFSET_ENTRY    *offset_entry_p;				\
	    char            *key_entry_p;				\
            char            *source_p, *destination_p;			\
            int  i;							\
	    int  move_bytes;						\
            								\
            compress_page_p = &page;					\
            compress_page_p->Page_type = (leaf_p)->Page_type;           \
            compress_page_p->Key_type = (leaf_p)->Key_type;		\
            compress_page_p->Nl_key_length = (leaf_p)->Nl_key_length;   \
            compress_page_p->Offset_entry_count = 0;                    \
            compress_page_p->Space_used = BYTES_B_LF_HEADER;            \
	    compress_page_p->Key_start = DB_BYTES_BPAGE;                 \
            compress_page_p->Next_p = ((leaf_p)->Next_p); \
            compress_page_p->Prior_p = ((leaf_p)->Prior_p);\
            for (i = 0; i < (int) (leaf_p)->Offset_entry_count; ++i)    \
              {								\
                offset_entry_p = (OFFSET_ENTRY *)((char *)(leaf_p) + 	\
				  BYTES_B_LF_HEADER  +			\
				  BYTES_OFFSET_ENTRY * i );		\
                key_entry_p = *offset_entry_p + (char *)(leaf_p);	\
		PUT_LF_KEY_ENTRY (compress_page_p, i, 			\
				  key_entry_p);				\
	      }								\
            move_bytes = (leaf_p)->Offset_entry_count * 2  + 		\
		   	 BYTES_B_LF_HEADER;				\
            DB_MOV_N_BYTES(compress_page_p, (leaf_p),  move_bytes);	\
            move_bytes = DB_BYTES_BPAGE - compress_page_p->Key_start;	\
            offset_entry_p = (OFFSET_ENTRY *)((char *)compress_page_p + \
		              BYTES_B_LF_HEADER  +			\
		              BYTES_OFFSET_ENTRY * 			\
                              (compress_page_p->Offset_entry_count-1) );\
            source_p = *offset_entry_p + (char *)compress_page_p;	\
            destination_p = *offset_entry_p + (char *)(leaf_p);		\
									\
	    DB_MOV_N_BYTES(source_p, destination_p, move_bytes);		\
          }			  					



#define   COMPRESS_NL_PAGE( nonleaf_p, nl_key_length )	        	\
          {								\
            B_NL_PAGE       *compress_page_p, page;			\
            OFFSET_ENTRY    *offset_entry_p;				\
	    char            *key_entry_p;				\
            char            *source_p, *destination_p;			\
            int  i;							\
	    int  move_bytes;						\
            								\
            compress_page_p = &page;					\
            compress_page_p->Page_type = (nonleaf_p)->Page_type; 	\
	    compress_page_p->Key_type = (nonleaf_p)->Key_type;		\
            compress_page_p->Nl_key_length = (nonleaf_p)->Nl_key_length;\
            compress_page_p->Offset_entry_count = 0;                    \
            compress_page_p->Space_used = BYTES_B_NL_HEADER;            \
	    compress_page_p->Key_start = DB_BYTES_BPAGE;                 \
            for (i = 0; i < (int) (nonleaf_p)->Offset_entry_count; ++i ) \
              {								\
                offset_entry_p = (OFFSET_ENTRY *)((char *)(nonleaf_p) + \
				  BYTES_B_NL_HEADER  +			\
				  BYTES_OFFSET_ENTRY * i );		\
                key_entry_p = *offset_entry_p + (char *)(nonleaf_p);	\
		PUT_NL_KEY_ENTRY (compress_page_p, i, 			\
				  key_entry_p, nl_key_length);	        \
	      }								\
            move_bytes = (nonleaf_p)->Offset_entry_count * 2  +         \
		 	 BYTES_B_NL_HEADER;				\
            DB_MOV_N_BYTES(compress_page_p, (nonleaf_p),  move_bytes);	\
            move_bytes = DB_BYTES_BPAGE - compress_page_p->Key_start;	\
            offset_entry_p = (OFFSET_ENTRY *)((char *)compress_page_p + \
		              BYTES_B_NL_HEADER  +			\
		              BYTES_OFFSET_ENTRY * 			\
                             (compress_page_p->Offset_entry_count-1) ); \
            source_p = *offset_entry_p + (char *)compress_page_p;	\
            destination_p = *offset_entry_p + (char *)(nonleaf_p);	\
									\
	    DB_MOV_N_BYTES(source_p, destination_p, move_bytes);		\
          }			  					




/* BTREE leaf page definition. */
	
typedef	
  struct leaf_page
    {
    unsigned char    Page_type;
    unsigned char    Key_type;
    unsigned short   Nl_key_length;
    unsigned short   Offset_entry_count;
    unsigned short   Space_used;
    unsigned short   Key_start;
    short	     Filler;
    OM_S_OBJID       Next_p;
    OM_S_OBJID       Prior_p;
    unsigned char    Offset_key_area[BYTES_B_LF_OFFSET_KEY_AREA];
    } B_LF_PAGE;



/* BTREE non-leaf page definition. */

typedef
  struct
    {
    unsigned char   Page_type;
    unsigned char   Key_type;
    unsigned short  Nl_key_length;
    unsigned short  Offset_entry_count;
    unsigned short  Space_used;
    unsigned short  Key_start;
    unsigned char   Offset_key_area[BYTES_B_NL_OFFSET_KEY_AREA];
    } B_NL_PAGE;



/* element of path array used to track from root to leaf node. */

typedef
  struct
    {
    OM_S_OBJID      Child_ptr;
    unsigned short  Offset_entry_num;
    unsigned short  Child_entry_num;
    } B_PATH_ENTRY;
    


/* structure for remembering path from root to leaf node. */

typedef
  struct
    {
    unsigned char  Path_count;
    char	   Filler[3];
    B_PATH_ENTRY   Path_array[10];
    } B_PATH_HISTORY;


/* local context structure for search. */

typedef
  struct
    {
    int  search_id;
    int  key_value_length;
    int  nl_key_length;
    int  (*user_compare_routine_ptr)();
    int  (*user_action_routine_ptr)();
    char *key_value_ptr;
    char *user_context_ptr;
    } BTREE_LOCAL_CONTEXT;

						
/* prototypes for btree routines */

extern int DB_btree_adjust_tree __((KEY_LENGTH nl_key_length, int
    (*user_compare_routine_p)(), B_NL_PAGE **cur_page_pp,
    B_NL_PAGE **new_page_pp, char *cur_page_high_key_p, KEY_LENGTH
    *cur_page_high_key_length_p, char *new_page_low_key_p,
    KEY_LENGTH *new_page_low_key_length_p, B_PATH_HISTORY *insert_path_p));
extern int DB_btree_adjust_tree_hk __((KEY_LENGTH nl_key_length, int
    (*user_compare_routine_p)(), KEY_LENGTH new_key_length, char *new_key_p,
    B_NL_PAGE **cur_page_pp, B_NL_PAGE **new_page_pp,
    char *cur_page_high_key_p, KEY_LENGTH *cur_page_high_key_length_p,
    char *new_page_low_key_p, KEY_LENGTH *new_page_low_key_length_p,
    B_PATH_HISTORY *insert_path_p));
extern int DB_btree_change_path __((KEY_LENGTH nl_key_length,
    int (*user_compare_routine_p)(), B_PATH_HISTORY *insert_path_p,
    B_NL_PAGE *leaf_page_p, unsigned short save_path_count));
extern int DB_btree_check_key_exist __((KEY_LENGTH nl_key_length,
    int (*user_compare_routine_p)(), B_NL_PAGE **parent_page_pp,
    B_PATH_HISTORY *insert_path_p, unsigned short save_path_count,
    char *old_page_high_key_p, KEY_LENGTH *old_page_high_key_length_p,
    short *key_exist_p));
extern int DB_btree_choose_leaf __((B_NL_PAGE *non_leaf_p,
    KEY_LENGTH nl_key_length, int (*user_compare_routine_p)(),
    char *new_key_p, KEY_LENGTH new_key_length, OM_p_OBJID new_rec_ptr_p,
    B_PATH_HISTORY *insert_path_p));
extern int DB_btree_cluster_obj __((B_NL_PAGE *root_page_p, char *new_key_p,
    KEY_LENGTH new_key_length, int (*user_compare_routine_p)(),
    long *neighbor_objid_p));
extern int DB_btree_concatenate __((int (*user_compare)(),
    B_NL_PAGE *root_page_p, KEY_LENGTH nl_key_length,
    B_PATH_HISTORY *history_p, B_NL_PAGE *child_page_p,
    B_NL_PAGE *parent_page_p, B_LF_PAGE *neighbor_lf_page_p, int action,
    B_PATH_HISTORY left_buddy_path));
extern int DB_btree_delete __((char *key_p, KEY_LENGTH key_len, long *rid,
    B_NL_PAGE *root_page_p, int (*user_compare)()));
extern int DB_btree_deltree __((OM_S_OBJID my_id, B_NL_PAGE *page_p));
extern int DB_btree_duplicate_key __((KEY_LENGTH nl_key_length,
    int (*user_compare_routine_p)(), KEY_LENGTH new_key_length,
    char *new_key_p, long *new_rec_ptr_p, B_LF_PAGE **leaf_page_pp,
    unsigned short offset_entry_num, REC_PTR_COUNT *rec_ptr_count_p,
    long *rec_ptr_p, B_LF_PAGE **new_leaf_page_pp, char *leaf_page_high_key_p,
    KEY_LENGTH *leaf_page_high_key_length_p, char *new_leaf_page_low_key_p,
    KEY_LENGTH *new_leaf_page_low_key_length_p, B_PATH_HISTORY *insert_path_p));
extern int DB_btree_find_neighbor_action __((KEY_LENGTH nl_key_length,
    char *child_page_p, B_PATH_HISTORY *history_p, char **neighbor_page_pp,
    B_PATH_HISTORY *left_buddy_path_p, int *action_p, int *underflow));
extern int DB_btree_findleaf __((char *inq_key_p, KEY_LENGTH inq_key_len,
    long *inq_rec_ptr_p, KEY_LENGTH nl_key_len, int (*user_compare)(),
    int *one_more_check, long **cur_page_pp, B_PATH_HISTORY *history_ptr));
extern int DB_btree_insert __((B_NL_PAGE *cur_page_p, char *new_key_p,
    KEY_LENGTH new_key_length, long *new_rec_ptr_p, int
    (*user_compare_routine_p)()));
extern int DB_btree_insert_key __((KEY_LENGTH nl_key_length, int
    (*user_compare_routine_p)(), KEY_LENGTH new_key_length,
    char *new_key_p, long *new_rec_ptr_p, B_NL_PAGE **cur_page_pp,
    B_NL_PAGE **new_page_pp, char *cur_page_high_key_p, KEY_LENGTH
    *cur_page_high_key_length_p, char *new_page_low_key_p, KEY_LENGTH
    *new_page_low_key_length_p, B_PATH_HISTORY *insert_path_p));
extern int DB_btree_insert_highest_key __((KEY_LENGTH nl_key_length,
    int (*user_compare_routine_p)(), KEY_LENGTH new_key_length,
    char *new_key_p, long *new_rec_ptr_p, B_NL_PAGE **cur_page_pp,
    B_NL_PAGE **new_page_pp, char *cur_page_high_key_p,
    KEY_LENGTH *cur_page_high_key_length_p, char *new_page_low_key_p,
    KEY_LENGTH *new_page_low_key_length_p, B_PATH_HISTORY *insert_path_p));
extern int DB_btree_make_root __((KEY_LENGTH nl_key_length, int
    (*user_compare_routine_p)(), B_NL_PAGE *root_page_p, 
    B_NL_PAGE *new2_page_p, char *new1_page_high_key_p,
    KEY_LENGTH new1_page_high_key_length, char *new2_page_low_key_p,
    KEY_LENGTH new2_page_low_key_length));

extern int DB_btree_put_child_ptr __((KEY_LENGTH nl_key_length,
    int (*user_compare_routine_p)(), B_NL_PAGE *nonleaf_page_p,
    unsigned short offset_entry_num, unsigned short child_entry_num,
    CHILD_PTR_COUNT child_ptr_count, B_NL_PAGE *new_child_page_p,
    B_NL_PAGE **new_nonleaf_page_pp, char *old_page_high_key_p,
    KEY_LENGTH *old_page_high_key_length_p, char *new_page_low_key_p,
    KEY_LENGTH *new_page_low_key_length_p));
extern int DB_btree_put_lf_key __((int (*user_compare_routine_p)(),
    B_LF_PAGE *leaf_page_p, OFFSET_ENTRY offset_entry_num, KEY_LENGTH
    new_key_length, char *new_key_p, long *new_rec_ptr_p,
    B_LF_PAGE **new_leaf_page_pp, char *old_page_high_key_p, 
    KEY_LENGTH *old_page_high_key_length_p, char *new_page_low_key_p,
    KEY_LENGTH *new_page_low_key_length_p));
extern int DB_btree_put_nl_key __((KEY_LENGTH nl_key_length,
    int (*user_compare_routine_p)(), B_NL_PAGE *nonleaf_page_p,
    OFFSET_ENTRY offset_entry_num, KEY_LENGTH new_key_length,
    char *new_key_p, B_NL_PAGE **new_page_pp,
    B_NL_PAGE **new_nonleaf_page_pp, char *old_page_high_key_p, 
    KEY_LENGTH *old_page_high_key_length_p, char *new_page_low_key_p,
    KEY_LENGTH *new_page_low_key_length_p));
extern int DB_btree_put_record_pointer __((int (*user_compare_routine_p)(),
    B_LF_PAGE *leaf_page_p, unsigned short offset_entry_num, unsigned
    short rec_ptr_num, KEY_LENGTH key_length, REC_PTR_COUNT rec_ptr_count,
    long *new_rec_ptr_p, B_LF_PAGE **new_leaf_page_pp, char
    *old_page_high_key_p, KEY_LENGTH *old_page_high_key_length_p,
    char *new_page_low_key_p, KEY_LENGTH *new_page_low_key_length_p));
extern int DB_btree_split_leaf __((B_LF_PAGE *full_page_p, B_LF_PAGE
    **empty_page_pp, char *full_high_key_p, KEY_LENGTH *full_high_key_len_p,
    char *empty_low_key_p, KEY_LENGTH *empty_low_key_len_p));
extern int DB_btree_split_nonleaf __((KEY_LENGTH nl_key_length,
    B_NL_PAGE *full_page_p, B_NL_PAGE **empty_page_pp,
    char *full_high_key_p, KEY_LENGTH *full_high_key_len_p,
    char *empty_low_key_p, KEY_LENGTH *empty_low_key_len_p));
extern int DB_btree_update_keys_on_path __((KEY_LENGTH nl_key_length,
    B_PATH_HISTORY *history_p));

#endif  /* OMBTREEDEF */
