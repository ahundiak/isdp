/* 
   transos functions for unions in class ACroot.

   shelley heard  3/20/92     created for 2.0.1.x release.

 */

#include "OMminimum.h"
#include "igetypedef.h"
#include "igrtypedef.h"
#include "gr.h"
#include "macro.h"
#include "parametric.h"
#include "OMport.h"

struct ACroot_instance 
{
   struct OM_sd_varlenarr_descr fts;
};

#if defined(__STDC__) || defined(__cplusplus)
int ACroot_OMPORT_ACroot(short classid,char *ME,struct ACroot_instance *me )
#else
int ACroot$ACroot(classid,ME,me )
short                   classid;
char                   *ME;
struct ACroot_instance *me;
#endif
{
   struct ret_struct  *p_fts;
   int                 sts, 
                       index, 
                       num_entries,
                       type;
#ifdef DEBUG
   char                type_str[32];
#endif

#if defined(__STDC__) || defined(__cplusplus)
   num_entries = OMPORT_INTEGER_VALUE ( &me->fts.i_count );

   p_fts = (struct ret_struct *)((unsigned int) (&me->fts) +
             OMPORT_INTEGER_VALUE (&me->fts.i_offset));
#else
   num_entries = om$integer_value ( &me->fts.i_count );

   p_fts = (struct ret_struct *)((unsigned int) (&me->fts) +
             om$integer_value (&me->fts.i_offset));
#endif

   for( index = 0 ; index < num_entries; index++)
   {
      int ndx;
      
#if defined(__STDC__) || defined(__cplusplus)
      type = OMPORT_INTEGER_VALUE(&p_fts[index].type);
#else
      type = om$integer_value(&p_fts[index].type);
#endif

      switch (type)
      {
        case line_generic:
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.p0[0], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.p0[1], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.p0[2], 1);

           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.p1[0], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.p1[1], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.p1[2], 1);

           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.v0[0], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.v0[1], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.line_st.v0[2], 1);
#else
           sts = om$conv_double(&p_fts[index].var.line_st.p0[0], 1);
           sts = om$conv_double(&p_fts[index].var.line_st.p0[1], 1);
           sts = om$conv_double(&p_fts[index].var.line_st.p0[2], 1);

           sts = om$conv_double(&p_fts[index].var.line_st.p1[0], 1);
           sts = om$conv_double(&p_fts[index].var.line_st.p1[1], 1);
           sts = om$conv_double(&p_fts[index].var.line_st.p1[2], 1);

           sts = om$conv_double(&p_fts[index].var.line_st.v0[0], 1);
           sts = om$conv_double(&p_fts[index].var.line_st.v0[1], 1);
           sts = om$conv_double(&p_fts[index].var.line_st.v0[2], 1);
#endif
 
#ifdef DEBUG
           strcpy(type_str,"line_generic");
#endif
           break;

        case point_generic:
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.point_st.pt[0], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.point_st.pt[1], 1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.point_st.pt[2], 1);
#else
           sts = om$conv_double(&p_fts[index].var.point_st.pt[0], 1);
           sts = om$conv_double(&p_fts[index].var.point_st.pt[1], 1);
           sts = om$conv_double(&p_fts[index].var.point_st.pt[2], 1);
#endif
#ifdef DEBUG
           strcpy(type_str,"point_generic");
#endif

           break;

        case circle_type:
        case arc_type:
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.circle_st.cent_p[0],1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.circle_st.cent_p[1],1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.circle_st.cent_p[2],1);

           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.circle_st.start_angle,1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.circle_st.sweep_angle,1);
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.circle_st.rad,1);
#else
           sts = om$conv_double(&p_fts[index].var.circle_st.cent_p[0],1);
           sts = om$conv_double(&p_fts[index].var.circle_st.cent_p[1],1);
           sts = om$conv_double(&p_fts[index].var.circle_st.cent_p[2],1);

           sts = om$conv_double(&p_fts[index].var.circle_st.start_angle,1);
           sts = om$conv_double(&p_fts[index].var.circle_st.sweep_angle,1);
           sts = om$conv_double(&p_fts[index].var.circle_st.rad,1);
#endif

           for (ndx=0; ndx < 16; ndx++)
           {
#if defined(__STDC__) || defined(__cplusplus)
             sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.circle_st.mat[ndx],1); 
#else
             sts = om$conv_double(&p_fts[index].var.circle_st.mat[ndx],1); 
#endif
           }

#ifdef DEBUG
           strcpy(type_str,(type==circle_type)?"line_generic":"arc_type");
#endif
           break;

        case double_type :
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.root_pm_st.value,1);
#else
           sts = om$conv_double(&p_fts[index].var.root_pm_st.value,1);
#endif

#ifdef DEBUG
           strcpy( type_str, "double_type" );
#endif
           break;

        case debug_type :
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_INT(&p_fts[index].var.dbg_st.value,1);
           sts = OMPORT_CONV_INT(&p_fts[index].var.dbg_st.mark_id,1);
           sts = OMPORT_CONV_INT(&p_fts[index].var.dbg_st.state,1);
#else
           sts = om$conv_int(&p_fts[index].var.dbg_st.value,1);
           sts = om$conv_int(&p_fts[index].var.dbg_st.mark_id,1);
           sts = om$conv_int(&p_fts[index].var.dbg_st.state,1);
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
             sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.lb_st.matrix[ndx],1);
#else
             sts = om$conv_double(&p_fts[index].var.lb_st.matrix[ndx],1);
#endif
           }

           for (ndx=0; ndx < 3; ndx++)
	   {
#if defined(__STDC__) || defined(__cplusplus)
              sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.lb_st.diag_pt1[ndx],1);
              sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.lb_st.diag_pt2[ndx],1);
#else
              sts = om$conv_double(&p_fts[index].var.lb_st.diag_pt1[ndx],1);
              sts = om$conv_double(&p_fts[index].var.lb_st.diag_pt2[ndx],1);
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
             sts = OMPORT_CONV_DOUBLE(&p_fts[index].var.ref_st.t[ndx],1);
#else
             sts = om$conv_double(&p_fts[index].var.ref_st.t[ndx],1);
#endif
           }
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_INT(&p_fts[index].var.ref_st.last_t,1);
#else
           sts = om$conv_int(&p_fts[index].var.ref_st.last_t,1);
#endif

#ifdef DEBUG
           strcpy( type_str, "ref_generic" );
#endif
           break;

        case macro_generic :
	   /* the name filed of the structure is left alone */
#if defined(__STDC__) || defined(__cplusplus)
           sts = OMPORT_CONV_INT(&p_fts[index].var.macro_st.hdr_type,1);
#else
           sts = om$conv_int(&p_fts[index].var.macro_st.hdr_type,1);
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
                printf("Unknown ret_struct type in ACroot during tranos\n");
#endif
                break;
        }
#ifdef  DEBUG
#if defined(__STDC__) || defined(__cplusplus)
      printf("ACpreroot_OMPORT_ACpreroot: type[%d] is %d (%s).\n",type,index,type_str);
#else
      printf("ACpreroot$ACpreroot: type[%d] is %d (%s).\n",type,index,type_str);
#endif
#endif
    }
    return(1);
}



