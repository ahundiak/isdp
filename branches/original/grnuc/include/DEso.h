/*
   This file contains the basic definitions for symbology override.
   
   Dependencies: OMminimum.h
                 igrtypedef.h
                 igetypedef.h
                 sys/types.h
*/
#ifndef DEso_include
#define DEso_include

#define DE_EMPTY     0x000000	/* This entry is available		*/
#define DE_DELETED   0x000001	/* This entry has been deleted  	*/
#define DE_SOE	     0x000002	/* A manual S.O. entry (soe)		*/
#define DE_OVERLAP   0x000004	/* A 0/1 overlap			*/
#define DE_INVIS     0x000008	/* Invisible entry			*/
#define DE_HIDDEN    0x000010	/* Hidden entry				*/
#define DE_VIS       0x000020	/* Visible entry			*/

#define NULL_INDEX -1		/* A non-valid index			*/

#define DE_MINIMUM 128	/* smallest possible soo			*/


#define DEfind_refname(tmp_name, name) \
{  \
    char *ptr1; \
      for (ptr1 = &tmp_name [strlen ( tmp_name )]; \
           (ptr1 != tmp_name) && (*ptr1 != '/'); ptr1--); \
      if (ptr1 != tmp_name) \
        ptr1++; \
      strcpy ( &name [4], ptr1 ); \
}


typedef struct soe
{     
  short             type	/* Type of entry		 	*/;
  short             view  	/* Index of the view of the S.O. 	*/;
  OM_S_OBJID        objid	/* Objid of graphic object	 	*/;
  double            u1, u2	/* The parameters			*/;
  struct IGRdisplay osymb	/* The symbology of the override 	*/;
  short             context	/* Index of the context of the S.O.	*/;
  short             dirty       /* The dirty bit (bdrys are not sorted)	*/;
} DEsoe	/* S.O. entry 				 			*/;


struct DEcv_soo_info
{
  short             num_bounds;
  double            *bounds;
  struct IGRdisplay *attr;
};

extern GRobjid *DEsos	/* This variable contains the list of
                           the valid sobts	 		*/;

#endif
