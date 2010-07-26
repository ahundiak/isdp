/* 
   transos functions for unions in class ACpreroot.

   shelley heard  3/20/92     created for 2.0.1.x release.

 */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "macro.h"
#include "parametric.h"
#include "OMport.h"


struct ACpreroot_instance 
{
   struct ret_struct fts;
};

#if defined(__STDC__) || defined(__cplusplus)
int ACpreroot_OMPORT_ACpreroot(short classid,char *ME,struct ACpreroot_instance *me )
#else
int ACpreroot$ACpreroot(classid,ME,me )
short                      classid;
char                      *ME;
struct ACpreroot_instance *me;
#endif
{
   int                 sts; 
   int                 ndx;
   int                 type;
#ifdef DEBUG
   char                type_str[32];
#endif

#if defined(__STDC__) || defined(__cplusplus)
   type = OMPORT_INTEGER_VALUE(&me->fts.type);
#else
   type = om$integer_value(&me->fts.type);
#endif

   switch (type)
   {
     case line_generic:
        for (ndx=0; ndx < 3; ndx++)
	{
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_DOUBLE(&me->fts.var.line_st.p0[ndx], 1);
           sts = OMPORT_CONV_DOUBLE(&me->fts.var.line_st.p1[ndx], 1);
           sts = OMPORT_CONV_DOUBLE(&me->fts.var.line_st.v0[ndx], 1);
#else
           sts = om$conv_double(&me->fts.var.line_st.p0[ndx], 1);
           sts = om$conv_double(&me->fts.var.line_st.p1[ndx], 1);
           sts = om$conv_double(&me->fts.var.line_st.v0[ndx], 1);
#endif
	}
 
#ifdef DEBUG
        strcpy( type_str, "line_generic" );
#endif
        break;

     case point_generic:
#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.point_st.pt[0], 1);
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.point_st.pt[1], 1);
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.point_st.pt[2], 1);
#else
        sts = om$conv_double(&me->fts.var.point_st.pt[0], 1);
        sts = om$conv_double(&me->fts.var.point_st.pt[1], 1);
        sts = om$conv_double(&me->fts.var.point_st.pt[2], 1);
#endif

#ifdef DEBUG
        strcpy( type_str, "point_generic" );
#endif
        break;

     case circle_type:
     case arc_type:
#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.circle_st.cent_p[0],1);
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.circle_st.cent_p[1],1);
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.circle_st.cent_p[2],1);

        sts = OMPORT_CONV_DOUBLE(&me->fts.var.circle_st.start_angle,1);
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.circle_st.sweep_angle,1);
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.circle_st.rad,1);
#else
        sts = om$conv_double(&me->fts.var.circle_st.cent_p[0],1);
        sts = om$conv_double(&me->fts.var.circle_st.cent_p[1],1);
        sts = om$conv_double(&me->fts.var.circle_st.cent_p[2],1);

        sts = om$conv_double(&me->fts.var.circle_st.start_angle,1);
        sts = om$conv_double(&me->fts.var.circle_st.sweep_angle,1);
        sts = om$conv_double(&me->fts.var.circle_st.rad,1);
#endif

        for (ndx=0; ndx < 16; ndx++)
        {
#if defined(__STDC__) || defined(__cplusplus)
          sts = OMPORT_CONV_DOUBLE(&me->fts.var.circle_st.mat[ndx],1); 
#else
          sts = om$conv_double(&me->fts.var.circle_st.mat[ndx],1); 
#endif
        }

#ifdef DEBUG
        strcpy(type_str,(type==circle_type)?"line_generic":"arc_type");
#endif
        break;

     case double_type :
#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_DOUBLE(&me->fts.var.root_pm_st.value,1);
#else
        sts = om$conv_double(&me->fts.var.root_pm_st.value,1);
#endif
#ifdef DEBUG
        strcpy( type_str, "double_type" );
#endif

        break;

     case debug_type :
#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_INT(&me->fts.var.dbg_st.value,1);
        sts = OMPORT_CONV_INT(&me->fts.var.dbg_st.mark_id,1);
        sts = OMPORT_CONV_INT(&me->fts.var.dbg_st.state,1);
#else
        sts = om$conv_int(&me->fts.var.dbg_st.value,1);
        sts = om$conv_int(&me->fts.var.dbg_st.mark_id,1);
        sts = om$conv_int(&me->fts.var.dbg_st.state,1);
#endif

#ifdef DEBUG
        strcpy( type_str, "debug_type" );
#endif
        break;

     case lbs_flipped :
     case lbs_not_flipped : /* same as lbs_generic */
        for (ndx=0; ndx < 16; ndx++)
        {
#if defined(__STDC__) || defined(__cplusplus)
          sts = OMPORT_CONV_DOUBLE(&me->fts.var.lb_st.matrix[ndx],1);
#else
          sts = om$conv_double(&me->fts.var.lb_st.matrix[ndx],1);
#endif
        }

        for (ndx=0; ndx < 3; ndx++)
	{
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_DOUBLE(&me->fts.var.lb_st.diag_pt1[ndx],1);
           sts = OMPORT_CONV_DOUBLE(&me->fts.var.lb_st.diag_pt2[ndx],1);
#else
           sts = om$conv_double(&me->fts.var.lb_st.diag_pt1[ndx],1);
           sts = om$conv_double(&me->fts.var.lb_st.diag_pt2[ndx],1);
#endif
	}
#ifdef DEBUG
        strcpy(type_str,(type==lbs_flipped)?"lbs_flipped":"lbs_not_flipped");
#endif
        break;

     case ref_generic :
        for (ndx=0; ndx < 16; ndx++)
        {
#if defined(__STDC__) || defined(__cplusplus)
          sts = OMPORT_CONV_DOUBLE(&me->fts.var.ref_st.t[ndx],1);
#else
          sts = om$conv_double(&me->fts.var.ref_st.t[ndx],1);
#endif
        }
#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_INT(&me->fts.var.ref_st.last_t,1);
#else
        sts = om$conv_int(&me->fts.var.ref_st.last_t,1);
#endif

#ifdef DEBUG
        strcpy( type_str, "ref_generic" );
#endif
        break;

     case macro_generic :
	/* the name filed of the structure is left alone */
#if defined(__STDC__) || defined(__cplusplus)
        sts = OMPORT_CONV_INT(&me->fts.var.macro_st.hdr_type,1);
#else
        sts = om$conv_int(&me->fts.var.macro_st.hdr_type,1);
#endif
#ifdef DEBUG
        strcpy( type_str, "macro_generic" );
#endif

        break;

     case text_type :
     case class_generic :
        /* nothing done for char strings */
#ifdef DEBUG
        strcpy(type_str,(type==text_type)?"text_type":"class_generic");
#endif
        break;

     default:  /* unknown type */
#ifdef DEBUG
     printf("Unknown ret_struct type in ACpreroot during tranos\n");
#endif
     break;
   }

#ifdef  DEBUG
#if defined(__STDC__) || defined(__cplusplus)
   printf( "ACpreroot_OMPORT_ACpreroot: type is %d (%s).\n", type, type_str );
#else
   printf( "ACpreroot$ACpreroot: type is %d (%s).\n", type, type_str );
#endif
#endif

   return(1);
}
