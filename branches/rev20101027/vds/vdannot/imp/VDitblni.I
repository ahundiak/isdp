/* $Id: VDitblni.I,v 1.1.1.1 2001/01/04 21:07:41 cvs Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdannot/imp / VDitblni.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDitblni.I,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:41  cvs
 *	Initial import to CVS
 *	
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.2  1996/05/02  12:08:42  pinnacle
# Replaced: ./vdannot/imp/VDitblni.I for:  by azuurhou for vds.240
#
# Revision 1.1  1994/11/14  22:42:32  pinnacle
# Create vds.240 from vds.232
#
# Revision 1.1  1994/11/08  16:07:00  pinnacle
# create vds.232
#
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/

class implementation VDitbln;

#define		AS_DEBUG
#include "AS_status.h"
#include "asbox.h"
#include "dimdef.h"

from    dim_plan        import give_info;
from    DMsrc           import DMgive_structure;
from    expression      import NDgive_value,NDset_value;
from    ACcpx           import ACfind_exp_temp_obj, find_macro;
from    ACcpx_defn      import ACgive_name;

/*--------------------------------------------------------------------------*/

method GRgetobjinfo(
	IGRlong		  *msg;
	struct GRobj_info *info)
{
IGRchar	string[200];

     *msg = MSSUCC;
     sprintf( string, "item_number (%d)", me->item_nr );
     strcpy(info->type, string );
     return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------*/

method NDmove_to_root(
	IGRlong		*msg;
	struct GRid	*src_grid;
	struct GRmd_env	*md_env)
{
	IGRint status;
	extern IGRboolean ASbroadcast_in_progress;

	status =
	om$send(msg = message NDnodein.NDmove_to_root(
				msg, src_grid, md_env),
		targetid = my_id,
		mode = OM_e_wrt_message);
	as$status(action = RET_STATUS);
/*
	status =
	om$send(msg = message NDnode.NDchg_state(ND_DONT_MVRT, ND_DONT_MVRT),
		targetid = my_id);
	as$status(action = RET_STATUS);

	status =
	om$send(msg = message DMroot.set_dim_state(BIT_OR, DIM_DETACHED),
		p_chanselect = &ND_children,
		senderid = my_id);
	as$status(action = RET_STATUS);
 */
	return(OM_S_SUCCESS);
}

/*---------------------------------------------------------------------------*/

method gather_data(
	IGRint *msg;
	IGRint count;
	struct GRid list[];
	IGRpoint start_pt;
	IGRpoint end_pt;
	struct DMplan_info *plan_info;
	struct DMsenv_param *par_senv;
	struct GRmd_env *md_env)
{
	IGRint status, rc, index, type ;
	IGRshort first;
	IGRdouble text_offset;
	struct GRid prev;
	struct dim_ret_struct dim_str;

	/*| - Get environment parameters */

	status =
	om$send(msg = message DMannot.get_active_senv(par_senv),
			targetid = my_id);
	as$status(action = RET_STATUS);

	/*| - Get the dimension plane */

	/* alternative function : corr 2.0
         status =
       	 om$send(msg = message DMroot.get_dimension_plane(
                                        &rc, md_env, plan_info),
                mode = OM_e_wrt_message,
                targetid = my_id);
       	 dm$status(action = RET_STATUS);
	*/
	status =
	om$send(msg = message dim_plan.give_info(&rc, plan_info, md_env),
		targetid = list[DIM_ROOT_PLAN].objid,
		targetos = list[DIM_ROOT_PLAN].osnum);
	as$status(action = RET_STATUS);

	first = TRUE;
	if(me->dim_type == TEXT_WITH_BALLOON)
	{
		status =
		om$send(msg = message DMroot.give_previous(&rc, &first, &prev),
				targetid = my_id);
		as$status(action = RET_STATUS);
	}

	if(!first)
	{
		/*| - get bln center form the previous balloon */

		text_offset = par_senv->txt_heig * 0.5;
		status=
		om$send(msg = message DMtxbln.give_bln_center(
							&rc,
							&text_offset,
							start_pt,
							&prev,
							plan_info,
							md_env),
				targetid = my_id);
		as$status(action = RET_STATUS);
	}
	else
	{
	/* alternative function: corresponding with 2.0
                status =
                DMnode_give_structure(
                        &rc,
                        DIM_NO_INDEX,
                        ORIG_INFO,
                        (me->geom_type & DIM_IMPORTED),
                        list[AN_ROOT_ELEM1].objid,
                        my_id,
                        OM_Gw_current_OS,
                        md_env,
                        &ret_str);
                dm$status(action = RET_STATUS);
	 */
		type = ORIG_INFO;
		status =
		om$send(msg = message DMsrc.DMgive_structure(	&rc,
								type,
								FALSE,
								&dim_str,
								md_env ),
			targetid = list[AN_ROOT_ELEM1].objid,
			targetos = list[AN_ROOT_ELEM1].osnum);
		as$status(action = RET_STATUS);

		math_v_equal(start_pt, dim_str.var.dm_ptdist.point);
	}

	for (index=0; index<3; index++)
	{
		plan_info->win_plan.matrix[4*index + 3] =
		plan_info->act_plan.matrix[4*index + 3] = start_pt[index];
	}

	return(OM_S_SUCCESS);
}
/*----------------------------------------------------------------------------*/

method VDget_item_number(int *n)
{
 *n = me->item_nr;
 return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/

method VDset_item_number(int n)
{
 me->item_nr = n;
 return OM_S_SUCCESS;
}

/*----------------------------------------------------------------------------*/

/* 
   Get for checkin item number and quantity corresponding to 
   a drawing macro 
*/


VDget_drawing_item_info(macro,item,quantity,md_env)
struct GRid *macro;
char *item;
int *quantity;
struct GRmd_env *md_env;
{
 return VDget_drawing_item_info_opt(macro,NULL,item,quantity,md_env);
}

/*---------------------------------------------------------------------------*/

VDget_drawing_item_info_opt(macro,item_id,item,quantity,md_env)
struct GRid *macro,*item_id;
char *item;
int *quantity;
struct GRmd_env *md_env;
{
 struct GRid obj;
 long status,loc_msg;
 struct ret_struct rst;
 int item_nb;
 int index,d_index = -1;
 

 if(item_id) item_id->objid=NULL_OBJID;
 for(index=0;index<OM_K_MAXINT;index++)
 {
  status = om$get_objid_at_index(objid = macro->objid, 
				 osnum = macro->osnum,
			         index = index,
				 p_chanselect = &ND_children,
				 objidaddr = &obj.objid,
				 osnumaddr = &obj.osnum);
  if(!(status&1)) return FALSE; /* nothing left */

  status  = om$send(msg = message VDitbln.VDget_item_number(&item_nb),
		    senderid = NULL_OBJID,
		    targetid = obj.objid,
		    targetos = obj.osnum);
  if(status == OM_S_SUCCESS)
  {
   if(item)sprintf(item,"%d",item_nb);
   if(item_id) *item_id=obj;
   break;
  }
 }

 if(quantity)
  {
   status = om$send(msg = message NDmacro.ACgive_structure(
                               (int *)&loc_msg,&d_index,"quantity",&rst,md_env),
                   targetid = macro->objid,
                   targetos = macro->osnum,
                   senderid = NULL_OBJID);
   if((status&loc_msg&1) &&  rst.type == double_type) 
 				*quantity =  rst.var.root_pm_st.value;
   else quantity = 0;
  }
   

 return TRUE;
}
/*----------------------------------------------------------------------------*/

/* Retrieve first parent of the item which is a macro */

VDget_macro_from_item(item,macro,md_env)
struct GRid *item,*macro;
struct GRmd_env *md_env;
{
 int i;
 long loc_msg,status;
 struct GRid obj;
 struct ret_struct rst;

 for(i=0;i<10;i++)
  {
   status = om$get_objid_at_index(objid = item->objid,
				osnum = item->osnum,
				p_chanselect = &ND_father,
				index = i,
				objidaddr = &obj.objid,
				osnumaddr = &obj.osnum);
   if(!(status&1)) break;
   status = om$send(msg = message NDnode.NDgive_structure(&loc_msg,&rst,md_env),
		   senderid = NULL_OBJID,
		   targetid = obj.objid,
		   targetos = obj.osnum);
   if(status&1 && rst.type&macro_generic)
    {
     *macro = obj;
     return OM_S_SUCCESS;
    }
  }

/* No macro found */

 macro->objid = NULL_OBJID;
 return OM_W_ABORT;
}

/*----------------------------------------------------------------------*/
/* METHOD  GRxform                                                      */
/* moves annotation                                                     */
/*----------------------------------------------------------------------*/

method GRxform( IGRlong           *msg;
                struct GRmd_env   *md_env;
                IGRshort          *matrix_type;
                IGRmatrix         matrix;
                GRobjid           *newobjid   )
{
IGRint              status = OM_S_SUCCESS ;
struct  GRid        myObj,temp[3],macro;
IGRint              nb_temp,s_count,i,j,
                    s_count1,k,index,ii,
                    ind, s_count2;
IGRshort            rc;
struct GRid         roots[10];
struct  GRid        parId;
IGRchar             c_name[80],*c;
OM_S_OBJECT_LINKAGE slist1[10],
                    slist[10],
                    slist2[10];
IGRdouble           val,new_val[5];


        myObj.objid     = my_id;
        myObj.osnum     = OM_Gw_current_OS;
        macro.objid     = NULL_OBJID;
        val             = 0.0;

        for( ind=0; ind<5; ind++ ){
             new_val[ind] = 0.0 ;
        }

        /*
         * get the roots of VDtxbox( located object )
         */
        status =
        om$send(msg = message DMroot.DMreturn_roots( &nb_temp, roots ),
                      targetid = myObj.objid,
                      targetos = myObj.osnum );
        if( !(status&1)) goto wrapup ;

        /* for all roots of the located object check if DMsrc is a root.
         * if it is a root then get the ACpretend on its father channel.
         */
        parId.objid = NULL_OBJID;

        for ( i=0; i < nb_temp; i++ ){

                status =
                om$get_classname(
                               objid = roots[i].objid,
                               osnum = roots[i].osnum,
                               classname = c_name );
                as$status();

                if( om$is_ancestry_valid(
                                subclassname = c_name,
                              superclassname = "DMsrc" ) == OM_S_SUCCESS ){

                        parId.objid = roots[i].objid ;
                        parId.osnum = roots[i].osnum ;
                        break;
                }
        }

        if( parId.objid == NULL_OBJID ) goto wrapup;
        /*
         * get ACpretend
         */
          status =
        om$get_channel_count(osnum   = parId.osnum,
                             objid   = parId.objid,
                             p_chanselect = &ND_father,
                             count   = (OMuint *)&s_count );

        if ( s_count > 10 ){
                goto wrapup;
        }

        status =
        om$get_channel_objects( osnum   = parId.osnum,
                                objid   = parId.objid,
                                p_chanselect = &ND_father,
                                size    = 10,
                                list    = slist,
                                count   = (OMuint *) &s_count );
       /*
        * Get the nci_macro "midpnts"
        */
        for (j=0; j < s_count; j++ ){

                om$get_channel_count(   osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                                        p_chanselect = &ND_father,
                                        count   = (OMuint *)&s_count1 );
                status =
                om$get_channel_objects( osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                                        p_chanselect = &ND_father,
                                        size    = 10,
                                        list    = slist1,
                                        count   = (OMuint *) &s_count1 );


                /*
                 * test on objects for macro midpnts.
                 */
              
                om$send(msg = message ACcpx.find_macro(&macro),
                        targetid = slist1[j].S_objid,
                        targetos = slist1[j].osnum);
                
                if( macro.objid == NULL_OBJID )continue;

                status =
                om$send(msg = message ACcpx_defn.ACgive_name( &c ),
                        targetid = macro.objid,
                        targetos = macro.osnum);
                as$status();

                if( strcmp( c, "midpnts" ) == 0 ){

                        parId.objid = slist1[j].S_objid,
                        parId.osnum = slist1[j].osnum ;

                        break;

                 }
                }
                if( macro.objid == NULL_OBJID ) return OM_S_SUCCESS;

               /*
                * get the parents of nci_macro "midpnts"
                */
                for (k=0; k < s_count1; k++ ){

                    om$get_channel_count(   osnum   = slist1[k].osnum,
                                            objid   = slist1[k].S_objid,
                                            p_chanselect = &ND_father,
                                            count   = (OMuint *)&s_count2 );
                    status = 
                     om$get_channel_objects( osnum   = slist1[k].osnum,
                                            objid   = slist1[k].S_objid,
                                            p_chanselect = &ND_father,
                                            size    = 10,
                                            list    = slist2,
                                            count   = (OMuint *) &s_count2 );
                }
                index = 3;
                for( ii = 2; ii<5; ii++ ){
                        temp[ii].objid  =  slist2[ii].S_objid;
                        temp[ii].osnum  =  slist2[ii].osnum;

                        status =
                        om$send( msg = message expression.NDgive_value( &val ),
                                 targetid = temp[ii].objid,
                                 targetos = temp[ii].osnum  );
                        as$status();

                        new_val[ii] = val;
                        new_val[ii] = new_val[ii] + matrix[index];

                        status =
                        om$send( msg = message expression.NDset_value(
                                                                  "",
                                                                  new_val[ii],
                                                                  md_env,
                                                                  &rc ),
                                 targetid = temp[ii].objid,
                                 targetos = temp[ii].osnum  );
                        as$status();

                        index = index+4;

                }

        {
        int     cn_type, wait_batch ;
        cn_type    = ND_COMP;
        nd$wait_batch(  type       = GR_GEOM_POSTED,
                        l_object   = temp,
                        l_obj_info = &cn_type,
                        nb_obj     = 3);

        nd$mod_batch(   request    = ND_INQ,
                        p_ret_mode = &wait_batch);

        nd$exec_batch(  mode = ND_IMMEDIATE );

        }
        return status;

wrapup:
        status =
        om$send(msg = message DMroot.GRxform( msg, md_env, matrix_type,
                                                matrix, newobjid ),
                mode = OM_e_wrt_message,
                targetid = my_id );

        return status ;

}

/*----------------------------------------------------------------------------*/
method replace_text(
        IGRint          *msg;
        IGRint           text_index;
        struct GRid     *text_grid;
        struct GRmd_env *md_env;
        IGRint           text_len;
        IGRuchar        *text_str )

{
 /* Control that the new text is an integer */

#if 0
printf("text %c%c\n",text_str[0],text_str[1]);
printf("text_len %d\n",text_len);
 *pos = strtol(foot_name,&ch_end,10);
 if(*ch_end == '\0') *suc = 1;
#endif


 return  om$send(msg = message DMtxbln.replace_text(msg,text_index,text_grid,
					md_env,text_len,text_str),
		  targetid = my_id,
		  mode = OM_e_wrt_message);
}
/*--------------------------------------------------------------------------*/

method GRdelete( IGRlong *msg;
                 struct  GRmd_env *md_env )
{
IGRint  status = OM_S_SUCCESS;
struct  GRid    list[10], parId, macro;
IGRint  index, count, j,
        s_count, s_count1;
IGRchar c_name[80],*c;
OM_S_OBJECT_LINKAGE slist1[10],
                    slist[10];

   parId.objid = NULL_OBJID;
   macro.objid = NULL_OBJID;

  /*
   * disconnect the ci_macro "midpnts" if it exists,
   * and delete it before deleting of the annotation itself
   */

   status =
   om$send(msg    = message DMroot.DMreturn_roots( &count, list ),
           targetid  = my_id);
   as$status( action = RET_STATUS );

   for( index=0 ; index<count ; index++ ){

       status =
       om$get_classname(objid     = list[index].objid,
                        osnum     = list[index].osnum,
                        classname = c_name );
       as$status();
       if( om$is_ancestry_valid(
                                subclassname = c_name,
                              superclassname = "DMsrc" ) == OM_S_SUCCESS ){

                 parId.objid = list[index].objid ;
                 parId.osnum = list[index].osnum ;
                 break;
      }
  }

  if( parId.objid != NULL_OBJID ){
        /*
         * get ACpretend
         */
        status =
        om$get_channel_count(osnum   = parId.osnum,
                             objid   = parId.objid,
                      p_chanselect = &ND_father,
                             count   = (OMuint *)&s_count );

        status =
        om$get_channel_objects( osnum   = parId.osnum,
                                objid   = parId.objid,
                                p_chanselect = &ND_father,
                                size    = 10,
                                list    = slist,
                                count   = (OMuint *) &s_count );
       /*
        * Get the nci_macro "midpnts"
        */

        for (j=0; j < s_count; j++ ){

                om$get_channel_count(   osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                                        p_chanselect = &ND_father,
                                        count   = (OMuint *)&s_count1 );
                status =
                om$get_channel_objects( osnum   = slist[j].osnum,
                                        objid   = slist[j].S_objid,
                           p_chanselect = &ND_father,
                                        size    = 10,
                                        list    = slist1,
                                        count   = (OMuint *) &s_count1 );

                /*
                 * test on objects for macro midpnts.
                 */

                om$send(msg = message ACcpx.find_macro(&macro),
                        targetid = slist1[j].S_objid,
                        targetos = slist1[j].osnum);

                if( macro.objid == NULL_OBJID ) continue;

                status =
                om$send(msg = message ACcpx_defn.ACgive_name( &c ),
                        targetid = macro.objid,
                        targetos = macro.osnum);
                as$status();

                if( strcmp( c, "midpnts" ) == 0 ){
                        break;
         }
         }
         if( macro.objid != NULL_OBJID ){
              status =
               om$send(msg = message GRgraphics.GRdelete( msg, md_env ),
                       targetid = slist1[j].S_objid,
                       targetos = slist1[j].osnum);
               as$status();
         }
  }

  om$send(msg = message DMroot.GRdelete( msg, md_env ),
          mode = OM_e_wrt_message,
          targetid = my_id);
  as$status();

 return(status);
}

/* ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ */

end implementation VDitbln;
