
#include "OMminimum.h"
#include "OMDB.h"
#include "OMindex.h"
#include "OMrtreedef.h"
#include <stdio.h>

/* IEEE rounding modes */

#if defined (SUNOS54) || defined (SUNOS55) || defined (SUNOS58)
#include <ieeefp.h>
#elif defined (SUNOS)
#include <sys/ieeefp.h>
#elif defined (IRIX)
#include <sys/fpu.h>
#elif defined (CLIX)
extern double OMfloatcvt();
#elif defined (NT)
#include <float.h>
extern unsigned int _controlfp();
#else
#error !! OS has no floating point round-off support !!
#endif

extern int DB_rtree_search_3d_flt();
extern int DB_rtree_insert_3d_flt();
extern int DB_rtree_cluster_obj_3d_flt();
extern int DB_rtree_delete_3d_flt();
extern int DB_rtree_get_status_3d_flt();
extern int DB_rtree_find_key_3d_flt();
extern int DB_rtree_deltree_3d_flt();
extern int DB_rtree_replace_3d_flt();

/******************* DB_rtree_search *******************************/
DB_rtree_search(
   R_PAGE_3D_FLT  *root_page_p,
   DB_3D_DBL_BOX  *range1,
   DB_3D_DBL_BOX  *range2,
   DB_vector      *vector,
   int            (*action)(),
   char           *contextp,
   OMbyte         *classStatMap
)
{
   R_PACKED_KEYENTRY_3D_FLT key_entry;
   R_PACKED_KEYENTRY_3D_FLT key_entry2;
   int  rtn;

   if ( root_page_p->Header.Key_count == 0 )
   {
      return( DB_SUCCESS );
   }

   if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type, range1, 
		                NULL, &key_entry)) != DB_SUCCESS)
   {
      return(rtn);
   }

   if ( range2 )
   {
      /*for skew pass*/

      if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type, range2, 
		                NULL, &key_entry2)) != DB_SUCCESS)
      {
         return(rtn);
      }
      rtn = DB_rtree_search_3d_flt(root_page_p,
          &key_entry.Coordinates,&key_entry2.Coordinates,
          vector, action, contextp, classStatMap);
   }
   else
   {
      rtn = DB_rtree_search_3d_flt(root_page_p,
            &key_entry.Coordinates,0,0, action, contextp, classStatMap);
   }
   return( rtn );
}


/********************** DB_rtree_create **************************/
DB_rtree_create( unsigned char tree_type, R_PAGE_3D_FLT *root_page_p )
{
   root_page_p->Header.Page_type = R_LF_RT_PAGE;
   root_page_p->Header.Rtree_type = tree_type;
   root_page_p->Header.Key_count = 0;
   root_page_p->Header.Filler_1 = 0;
   root_page_p->Header.Page_count = 1;
   return(DB_SUCCESS);
}


/********************** DB_rtree_insert *************************/
DB_rtree_insert(
   R_PAGE_3D_FLT  *root_page_p,
   DB_3D_DBL_BOX  *p_key,
   OM_p_OBJID     p_objid
)
{
   R_PACKED_KEYENTRY_3D_FLT key_entry;
   int   rtn;

   if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type, p_key, 
		             p_objid, &key_entry)) != DB_SUCCESS)
   {
      return(rtn);
   }

   rtn = DB_rtree_insert_3d_flt(root_page_p, key_entry);

   return( rtn );
}



/*********************** DB_rtree_cluster_obj *************************/
DB_rtree_cluster_obj(
   R_PAGE_3D_FLT  *root_page_p,
   DB_3D_DBL_BOX  *p_key,
   OM_p_OBJID     p_neighbor_objid
)
{
   R_PACKED_KEYENTRY_3D_FLT key_entry;
   int  rtn;

   if (root_page_p->Header.Key_count == 0)
   {
      *p_neighbor_objid = (*((OM_S_OBJID *) &NULL_OBJID));
      return( DB_SUCCESS );    
   }
   
   if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type, p_key, 
	                NULL, &key_entry)) != DB_SUCCESS)
   {
      return(rtn);
   }
   rtn = DB_rtree_cluster_obj_3d_flt(root_page_p,
		&key_entry.Coordinates, p_neighbor_objid); 
   return( rtn );
}



/************************* DB_rtree_skewsrch ***************************/
/*----
 
*** THIS ROUTINE IS COMMENTED OUT ***

     MODULE NAME:	DB_rtree_skewsrch
 
     Abstract:		Skewscan is a method of selecting elements
			from an rtree by rejecting those elements
			that do not meet the criteria.

     VALUE = DB_rtree_skewsrch( root_page_p, &skew_key, user_action, user_context, classStatMap )
 
     ON ENTRY:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------
   root_page_p  ptr to R_PAGE_2D_INT root page of rtree
   skew_key     OM_p_SKEW_DESC		        skew key criteria

   user_action  int			user action routine
   user_context ptr to character        ptr to user context block
   *classStatMap  OMbyte         

     ON EXIT:

        NAME       DATA TYPE  	            DESCRIPTION
     ----------   ------------   -----------------------------------

     MODULES INVOKED:
			DB_rtree_skewsrch_3d_flt

----*/

/*
DB_rtree_skewsrch( root_page_p, keyp, action, contextp, classStatMap )

R_PAGE_3D_FLT 	*root_page_p;
OM_p_SKEW_DESC		keyp;
int          		(*action)();
char         		*contextp;
OMbyte		*classStatMap;
{
DB_3D_FLT_BOX range1;
DB_3D_FLT_BOX range2;
int             rtn;

if ( root_page_p->Header.Key_count == 0 )
   {
     return( DB_SUCCESS );
   }

range1.xmin = (float) keyp->key.p_skew_3ddbl->range1.xmin;
range1.ymin = (float) keyp->key.p_skew_3ddbl->range1.ymin;
range1.zmin = (float) keyp->key.p_skew_3ddbl->range1.zmin;
range1.xmax = (float) keyp->key.p_skew_3ddbl->range1.xmax;
range1.ymax = (float) keyp->key.p_skew_3ddbl->range1.ymax;
range1.zmax = (float) keyp->key.p_skew_3ddbl->range1.zmax;

range2.xmin = (float) keyp->key.p_skew_3ddbl->range2.xmin;
range2.ymin = (float) keyp->key.p_skew_3ddbl->range2.ymin;
range2.zmin = (float) keyp->key.p_skew_3ddbl->range2.zmin;
range2.xmax = (float) keyp->key.p_skew_3ddbl->range2.xmax;
range2.ymax = (float) keyp->key.p_skew_3ddbl->range2.ymax;
range2.zmax = (float) keyp->key.p_skew_3ddbl->range2.zmax;

rtn = DB_rtree_skewsrch_3d_flt(root_page_p, 
        range1,
        range2,
		keyp->key.p_skew_3ddbl->sx, 
		keyp->key.p_skew_3ddbl->sy, 
		keyp->key.p_skew_3ddbl->sz, 
		action, contextp, classStatMap);

return( rtn );

}

*/


/******************* DB_rtree_delete *******************************/
DB_rtree_delete(
   R_PAGE_3D_FLT  *root_page_p,
   DB_3D_DBL_BOX  *p_key,
   OM_p_OBJID     p_objid,
   int            find_criteria
)
{
   R_PACKED_KEYENTRY_3D_FLT key_entry;
   int   rtn;

   if (root_page_p->Header.Key_count == 0) 
   {
      rtn = ( DB_KEYNOTFOUND );
   }

   if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type, p_key,
		             p_objid, &key_entry)) != DB_SUCCESS)
   {
      return(rtn);
   }

   rtn = DB_rtree_delete_3d_flt(root_page_p,
	     key_entry, find_criteria);

   return( rtn );
}



/******************* DB_rtree_deltree *******************************/

DB_rtree_deltree( OM_S_OBJID my_id, R_PAGE_3D_FLT *root_page_p )
{
   int   rtn;

   if (root_page_p->Header.Key_count == 0) 
   {
      rtn = ( DB_KEYNOTFOUND );
   }
   rtn = DB_rtree_deltree_3d_flt(my_id, root_page_p);
   return( rtn );
}



/******************* DB_rtree_get_status *******************************/

DB_rtree_get_status( R_PAGE_3D_FLT *root_page_p, OM_p_RTREESTAT status_p )
{
   int rtn;

   if (root_page_p->Header.Key_count == 0) 
   {
      return(DB_I_EMPTYTREE);
   }
   rtn = DB_rtree_get_status_3d_flt(root_page_p, status_p);
   return( rtn );
}



/************************* DB_rtree_convert_key ***********************/
#define MAXINT 0x7fffffff
#define MININT 0x80000000

#argsused

int DB_rtree_convert_key(
   unsigned char              tree_type,
   DB_3D_DBL_BOX              *p_key,
   OM_p_OBJID                 p_objid,
   R_PACKED_KEYENTRY_3D_FLT   *p_converted_key
)
{

   /* Converting keys means rounding them off, and rounding down
      for min values, while rounding up for max values.  On
      CLIX, the rounding mode can only be controled via
      assembly instructions, while SunOS and IRIX have handy
      routines for changing the rounding mode.
    */

#ifdef CLIX

   /* OMfloatcvt sets the floating point rounding mode according to
      the flag passed to it, then converts the value from double
      precision to single precision, and back to double precision.
      The value returned is a rounded off double precision value.
    */

   p_converted_key->Coordinates.xmin = (float)OMfloatcvt(p_key->xmin,0);
   p_converted_key->Coordinates.ymin = (float)OMfloatcvt(p_key->ymin,0);
   p_converted_key->Coordinates.zmin = (float)OMfloatcvt(p_key->zmin,0);

   p_converted_key->Coordinates.xmax = (float)OMfloatcvt(p_key->xmax,1);
   p_converted_key->Coordinates.ymax = (float)OMfloatcvt(p_key->ymax,1);
   p_converted_key->Coordinates.zmax = (float)OMfloatcvt(p_key->zmax,1);

#elif defined (SUNOS54) || defined (SUNOS55) || defined (SUNOS58)
   fp_rnd  save; 

   save = fpsetround ( FP_RN );

   p_converted_key->Coordinates.xmin = (float) p_key->xmin;
   p_converted_key->Coordinates.ymin = (float) p_key->ymin;
   p_converted_key->Coordinates.zmin = (float) p_key->zmin;

   fpsetround ( FP_RP );
 
   p_converted_key->Coordinates.xmax = (float) p_key->xmax;
   p_converted_key->Coordinates.ymax = (float) p_key->ymax;
   p_converted_key->Coordinates.zmax = (float) p_key->zmax;

   /* Restore original rounding mode */

   fpsetround ( save );

#elif defined (SUNOS)
   char  *save, *out, *in=NULL;

   ieee_flags("get", "direction", in, &save);
   ieee_flags("set", "direction", "negative", &out);

   p_converted_key->Coordinates.xmin = (float) p_key->xmin;
   p_converted_key->Coordinates.ymin = (float) p_key->ymin;
   p_converted_key->Coordinates.zmin = (float) p_key->zmin;
   ieee_flags("set", "direction", "positive", &out);
   p_converted_key->Coordinates.xmax = (float) p_key->xmax;
   p_converted_key->Coordinates.ymax = (float) p_key->ymax;
   p_converted_key->Coordinates.zmax = (float) p_key->zmax;

   /* Restore original rounding mode */

   ieee_flags("set", "direction", save, &out);

#elif defined (IRIX)
   int   saveMode, temp;

   saveMode = swapRM(ROUND_TO_MINUS_INFINITY);
   p_converted_key->Coordinates.xmin = (float) p_key->xmin;
   p_converted_key->Coordinates.ymin = (float) p_key->ymin;
   p_converted_key->Coordinates.zmin = (float) p_key->zmin;
   temp = swapRM(ROUND_TO_PLUS_INFINITY);
   p_converted_key->Coordinates.xmax = (float) p_key->xmax;
   p_converted_key->Coordinates.ymax = (float) p_key->ymax;
   p_converted_key->Coordinates.zmax = (float) p_key->zmax;

   /* Restore original rounding mode */

   temp = swapRM(saveMode);

#elif defined (NT)
   unsigned int   saveMode, temp;

   saveMode = _controlfp(0, 0);  /* Get the floating-point control word */
   temp = _controlfp(_RC_DOWN, _MCW_RC);
   p_converted_key->Coordinates.xmin = (float) p_key->xmin;
   p_converted_key->Coordinates.ymin = (float) p_key->ymin;
   p_converted_key->Coordinates.zmin = (float) p_key->zmin;
   temp = _controlfp(_RC_UP, _MCW_RC);
   p_converted_key->Coordinates.xmax = (float) p_key->xmax;
   p_converted_key->Coordinates.ymax = (float) p_key->ymax;
   p_converted_key->Coordinates.zmax = (float) p_key->zmax;

   /* Restore original rounding mode */

   temp = _controlfp(saveMode, 0xffffffff);

#else
#error OS has no floating point round-off support !!
#endif

   if (p_objid != NULL)
   {
      p_converted_key->Objid = *p_objid;
   }

return(DB_SUCCESS);
}



/******************* DB_rtree_replace *******************************/
DB_rtree_replace(
   R_PAGE_3D_FLT  *root_page_p,
   DB_3D_DBL_BOX  *p_key,
   OM_p_OBJID     p_objid,
   int            dim,
   DB_3D_DBL_BOX  *new_keys,
   OM_p_OBJID     new_objids
)
{
   R_PACKED_KEYENTRY_3D_FLT target_key_entry;
   int   rtn;

   if (root_page_p->Header.Key_count == 0) 
   {
      rtn = ( DB_KEYNOTFOUND );
   }

   if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type, p_key,
		             p_objid, &target_key_entry)) != DB_SUCCESS)
   {
      return(rtn);
   }

   rtn = DB_rtree_replace_3d_flt(root_page_p, target_key_entry,
					 dim, new_keys, new_objids);
   return( rtn );
}




/************************** shell_sort *************************/

int shell_sort(
   double   *keys,
   int      max,
   int      *h,
   int      max_h,
   int      *assign
)	
{
int s=0;
int i=0, j;
int temp_assign;
double temp_key;
int hh;

/*
 * First, need to determine the initial interval.  This is done by
 * searching the interval array "h" for an entry which exceeds the
 * number of keys to be sorted.  The interval chosen will be the 
 * entry two positions prior to the current entry.
*/
        
while ( s == 0 )
    {
    if ( h[i] >= max )
        {
        s = i;
        }
    else
        {
        if ( ++i == max_h )
            {
            printf( " Too many entries to sort.");
            return(DB_E_BADACTION);
            }
        }
    }
for (; s>=0; s--)
    {
    hh=h[s];
    for ( j=hh; j<max; j++ )
        {
        i=j-hh;
        temp_key = keys[j];
        temp_assign = assign[j];
        while ( temp_key < keys[i] )
            {
            keys[i+hh] = keys[i];
	    keys[i] = temp_key;
	    assign[i+hh] = assign[i];
            assign[i] = temp_assign;
            i -= hh;
            if (i < 0 ) break;
            }
        }
    }
return(DB_SUCCESS);
}



/********************** DB_rtree_seed *************************/

#argsused

DB_rtree_seed(R_PAGE_3D_FLT *root_page_p, DB_3D_DBL_BOX *p_key )
{
   return( 1 );
}


/*********************** DB_rtree_find_key ***************************/
DB_rtree_find_key(
   R_PAGE_3D_FLT  *root_page_p,
   DB_3D_DBL_BOX  *p_select_key,
   OM_p_OBJID     p_objid,
   DB_3D_DBL_BOX  *p_key
)
{
   R_PACKED_KEYENTRY_3D_FLT key_entry;
   int   rtn;

   if (root_page_p->Header.Key_count == 0) 
   {
      rtn = ( DB_KEYNOTFOUND );
   }

   if (p_select_key)
   {
      if ((rtn = DB_rtree_convert_key(root_page_p->Header.Rtree_type,
                  p_select_key, p_objid, &key_entry)) != DB_SUCCESS)
          return(rtn);

      rtn = DB_rtree_find_key_3d_flt(root_page_p,
                              &key_entry, p_objid, p_key);
   }
   else
   {
      rtn = DB_rtree_find_key_3d_flt(root_page_p, NULL, p_objid, p_key);
   }

   if (rtn == DB_TERMINATE)
      return( DB_SUCCESS );
   else
      return(DB_KEYNOTFOUND);
}
