/* $Id: VDequip.I,v 1.2.2.1 2003/05/14 19:55:08 anand Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vdequip/imp / VDequip.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDequip.I,v $
 *	Revision 1.2.2.1  2003/05/14 19:55:08  anand
 *	Change a printf to a __DBGpr_com
 *
 *	Revision 1.2  2001/01/19 21:37:53  jayadev
 *	changes in SP by andy
 *	
 *
 * History:
 * MM/DD/YY  AUTHOR  DESCRIPTION
 * 08/25/95  rmn     Avoid error message after find_macro
 * 03/24/98  ah      For Smart Attributes, changed ACgive_structure to 
 *                   Send message to VDSroot vice ACncpx
 * 04/07/98  ah      CR179800928 Map "family_name" to "eqp_family" for posting
 * Aug 2k    Anand   CR 179901735 Added Dynapipe related attributes
 * 27 Nov 2k Anand   CR 179902127 Added Dynapipe attribute 'dp_eqpt_angle_rot'
 * 01/03/01  ah      TR MP4390 - SA Broken
 * 11/17/10  ah      SOL10 printf to dbg
 * -------------------------------------------------------------------*/

/*
  History :
    LLC :- 15_9_90     + creation date
    RM  :- 17_6_92     + Added function for center_of_gravity
    MSM :- 12-20-96    + KLUDGE for PME attributes

 */

class implementation VDequipment;

#include <ctype.h>

#include "OMmacros.h"
#include "OMprimitives.h"

#include "nddef.h"
#include "ACattrib.h"
#include "ACrg_collect.h"
#include "acrepdef.h"
#include "acrepmacros.h"
#include "acmacros.h"
#include "asbox.h"
#include "bserr.h"
#include "AS_status.h"
#include "equidef.h"
#include "VDSequipdef.h"

/* Below include files added by Anand for CR 179901735 */
#include "VDmem.h"
#include "v_dbgmacros.h"
#include "v_measmacros.h"
#include "VDchn.h"
/* Above include files added by Anand for CR 179901735 */

from    ACrg_collect    import    ACget_named_attribute;
from    ACmacro_defn    import    ACgive_upscan;
from    ACcpx_defn      import    ACgive_feet_desc;
from    GRgencs         import    GRcvt_to_wld_coords,GRgetmatrix;

extern    GRclassid    OPP_ACheader_class_id;
extern    GRclassid    OPP_ACconst_class_id;
extern    GRclassid    OPP_ACrg_collect_class_id;
extern    GRclassid    OPP_ACpretend_class_id;

#define AS_DEBUG

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACmplace_from_def from ACncpx

  Abstract

       Place an occurence of the macro in the design file.

  Algorithm

 	- remove the template 0 (representation) if exist
	- store me->graph_mac
	- connect the other template to my_id
	- Get the macro def and attach it to my_id
 	- ACput_rep
 	- construct graphic of equipment:
		if def_occ not NULL_OBJID, construct ACncpx =fake and connect
		def_occ to it.
		send to my_id ACcontext_compute (&fake)
		if fake not NULL_OBJID delete it.

  Arguments

      int 		*suc       	O 	0 FAILED 1 SUCCESS
      int		prop            I 	see macro.h
      char		rep             I 	navsea representation
      char 		*macro_name	I 	the macro to place
      int 		numb_obj	I 	the number of real template
      struct GRid 	*uplist     	I 	the list of templates
      struct GRid 	*def_occ    	I 	transfer context has to be 
						performed from this default 
						occurence
      struct GRmd_env	*mod_env	I	module env

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method ACmplace_from_def(int *rc, prop; char rep;char *macro_name;
                         int num_temp;  struct GRid *temp_list;
                         struct GRid *def_occ;
                         struct GRmd_env *md_env )

{
IGRlong           sts, msg;
IGRint            int_msg;
struct  GRid      original;
int               ideb_rep;
IGRint            cn_type=0;
struct  ACrg_coll my_att;
IGRint            name_size;


    /*| initialization */
    original.objid    = NULL_OBJID;
    original.osnum    = OM_Gw_current_OS;

/* Remove if necessary template 0 which is representation */

  if(rep && temp_list[0].objid == NULL_OBJID)
    {
     num_temp --;
     temp_list++;
     ideb_rep = 1;
    }
  else    ideb_rep = 0;

    /*| store graphic macro name */
    strcpy( my_att.name, "mac_name" );
    sts = om$send(    msg     = message ACrg_collect.ACget_named_attribute
                                        ( &msg, &my_att ),
                      targetid = temp_list[0].objid,
                      targetos = temp_list[0].osnum );
    as$status( sts = sts, action = GOTO_VALUE, value = wrapup );
    if( ! (msg&1)) printf(" no found macro name : %s\n", my_att.name );
    as$status( sts = msg, action = GOTO_VALUE, value = wrapup );

    name_size    = strlen( my_att.desc.value.att_txt ) + 1;
    sts = om$vla_set_dimension(    varray    = me->graph_mac,
                                   size      = name_size );
    as$status( sts = sts );
    strcpy( me->graph_mac, my_att.desc.value.att_txt );

/* 
   jla may 93 macro_name is now use to decide if placement is like a
   symbol or a macro. Store the info after macro name 
*/
    if(strcmp(macro_name,"VDequicon") == 0)
      {
       sts = om$vla_set_dimension( varray    = me->graph_mac,
                                   size      = name_size + 2);
       as$status( sts = sts );
       strcpy( me->graph_mac+name_size,"c");
      }

    sts = om$send(    msg     = message NDnode.NDconnect( 
                                                          num_temp,
                                                          temp_list,
                                                          original,
                                                          ND_NEW ),
                      targetid = my_id );
    as$status( sts = msg, action = GOTO_VALUE, value = wrapup );


/* 
   jla may 93 macro_name is now use to decide if placement is like a
   symbol or a macro ( &int_msg, macro_name ),
*/
    sts = om$send(    msg     = message ACcpx.ACattach
                                               ( &int_msg, "VDequidef" ),
                      targetid = my_id );
    as$status( sts = msg, action = GOTO_VALUE, value = wrapup );

    sts = om$send(    msg = message ACncpx.ACput_rep
                                        (rep& ~(AC_FREE_REP|AC_DEP_REP),~0),
                      targetid = my_id);
    as$status( sts = msg, action = GOTO_VALUE, value = wrapup );

    /*| construct graphic of equipment */


    /* JLA may 93 : The def_occ passed for the equipment is in fact the
       def_occ for its first member. Construct a "fake" equipment context
       to have recursion on context beheave properly during context compute
    */


  {
    struct GRid fake;
    fake.objid = NULL_OBJID;
    fake.osnum = def_occ->osnum;
    if(def_occ->objid != NULL_OBJID)
     {
      sts = om$construct(classid = OPP_ACncpx_class_id,
		   osnum = def_occ->osnum,
		   p_objid = &fake.objid);
      if(sts&1) om$send(msg = message Root.connect(AS_to_comp,OM_K_MAXINT,
				 	def_occ->objid,def_occ->osnum,
				 	AS_to_owner,OM_K_MAXINT),
			   targetid = fake.objid,
			   targetos = fake.osnum);
      as$status(sts = sts);
     }
					

   sts = om$send(   msg   = message ACncpx.ACcontext_compute(
							&msg,
							cn_type,
							num_temp,
							temp_list,
							&fake,
							md_env ),
			targetid = my_id );

   as$status( sts = sts );
     
   if(fake.objid != NULL_OBJID)
   {
	sts =
	om$send(msg = message Root.delete(1),
		targetid = fake.objid,
		targetos = fake.osnum);
	as$status(sts = sts);
    }

 }

wrapup :

    if( ! ( sts&1 )){
            om$send(    msg      = message NDnode.NDdelete( md_env ),
                        targetid = my_id );
    }

    return    sts;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACconstruct_feet from ACncpx

  Abstract

	Generates the resultant feet set, given the compute parameters.
    	A NULLOBJID or a short list in feet_list are considered as temporary
 	missing feet. A corresponding error is given to give foot access.

  Algorithm

 	- if count = 2 & no cs as root -> VDSetStatus(VD_Eq_No_Rt)
	- VDGetRep -> MyRep
	- if count = 3 ACgive_structure to the cs -> RefInfo
 	- if VD_Eq_Xform & count = 3 (only need to apply a GRxform):
		send a GRxform to feet_list[0] with the matrix Mat
		Mat = CsMat * invers(me->Mat)
		save the new cs matrix (set me->Mat = CsMat)
		*fcount =1, return
	- if count =3 ->update the internal matrix (set me->Mat= RefInfo)
	- if count > 3 -> set me->Mat = Identity
	- get macro def and give_upscan
 	- if dup[0].prompt=rep ->ACgenerate_rep(gr_temp[0])
 	- loop on next the template templates (fill gr_temp):
		if(parameter) find the template in the 2 attributes boxes 
		if ref_generic NbCs ++, IndexCs = i
		else IsHeader = FALSE (TRUE=only cs and expression as templates)
	- if VD_Eq_No_Rt && NbCs =1 (equipment has no cs graphic root, we
	create a dummy cs at me->Mat position and take into account angle 
	and scale):
			- ACgive_structure(PidScale)
			- VDGetMat(cs_sys.matrix)
			- if PidScale > 0 
				normalise cs_sys.matrix 
				apply the scale factor
			- create gr_temp[Index_cs] as GRgencs with cs_sys 
			geometry and do a make_source, set DelCs=TRUE
	- if Isheader construct feet_list[0] as ACheader and ACmplace it
	- else construct feet_list[0] as ACconst and ACmplace it
	- if DelCs -> delete the temporary constructed cs
	- if bad placement, delete feet_list[0]
 	- send NDmove_to_root to feet_list[0]

  Arguments

	IGRlong 	*rc; 		 O	MSSUCC if success, MSFAIL 
						if not.
	IGRint 		cn_type; 	 I	reserved for future use
        IGRint 		count; 		 I	number of roots
	struct GRid 	list[];	         I    	list of roots the element is
						depending.
	struct GRmd_env *md_env;	 I	current md_env
	IGRint 		*fcount; 	 O	Number of feet (can be less
						than declared)
	struct GRid 	*feet_list	I/O	This array array is initialized
						at input to the nb of declared 
						feet. The method fills the 
						array.

  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method    ACconstruct_feet( IGRlong *rc; IGRint cn_type; 
                            IGRint count; struct GRid list[];
                            struct GRmd_env *md_env;
                            IGRint *fcount; struct GRid *feet_list )
{
IGRlong           sts;
IGRlong           msg;
IGRint            int_msg;
struct    GRid    def_id;
IGRint            def_nb_temp = 0;
struct    sup     *dup;
IGRint            def_prop;
struct    GRid    *gr_temp;
IGRint            g_ind;
IGRint            i, j;
IGRint            stat_ind;
int               rep;
IGRboolean	  IsHeader=TRUE;
int		  NbCs;
int		  namelen;

    /*| initialization */
    gr_temp = NULL;
    *fcount    = 0;

    def_id.objid    = NULL_OBJID;
    sts = ac$find_macro_defn(    action          = ACfind_load,
                                 macro_name      = me->graph_mac,
                                 p_macro_defn_id = &def_id );
    as$status( sts = sts );

    /*| get upscan */
    sts = om$send(    msg     = message ACmacro_defn.ACgive_upscan(
                                                              &def_nb_temp,
                                                              &def_prop,
                                                              &dup ),
                      targetid = def_id.objid,
                      targetos = def_id.osnum );
    as$status( sts = sts );
    if(def_nb_temp == 0){
	printf("\nACmacro_defn.ACgive_upscan failed for defn[%d,%d]\n",def_id.objid,def_id.osnum);
        return    0;
    }
     
    gr_temp    = (struct GRid *) om$malloc( size=sizeof( struct GRid ) * def_nb_temp );
    if( gr_temp == NULL ){

        printf(" ERROR not enougth memory to allocate gr_temp \n");
        return    0;
    }

    /* Does the macro support representation */

    if(strcmp(dup[0].prompt,"~rep") == 0)
    {
       sts = om$send( msg      = message ACncpx.ACget_rep(&rep),
                      targetid = my_id);
       /*" rep of ocurence is %x\n", rep */

       ACgenerate_rep(rep,OM_Gw_current_OS,gr_temp);

       stat_ind    = 1;
    }
    else stat_ind = 0;

/* jla the equipment could store that it should be placed as a const */
   namelen = strlen(me->graph_mac)+1;
   if(namelen < om$dimension_of(varray = me->graph_mac) &&
      strcmp(me->graph_mac+namelen,"c") == 0)		  IsHeader = FALSE;

    /*
     * CH 12 Apr 93:
     * Test if the macro to place is an ACheader or ACconst.
     * ACheader means 1 CS and expression.
     */

    NbCs = 0;
    for( i=stat_ind, g_ind=2; i<def_nb_temp; i++ )
    {
      if( dup[i].type & parameter_generic )
      {
        /*| find obj in att_box */
        for( j=0; j<2; j++ )
        {
          sts = om$send(    msg     = message ACcpx.ACreturn_foot(
                                                                &msg,
                                                                dup[i].prompt,
                                                                &gr_temp[i],
                                                                NULL,
                                                                NULL ),
                            targetid = list[j].objid,
                            targetos = list[j].osnum );
           as$status( sts = sts );

           if( msg )    break;
         }

         if( ! msg ){
                printf(" att : %s, not found in att box \n", dup[i].prompt );
                sts    = 0;
                goto    wrapup;
         }

       }
       else 
       {
        if(dup[i].type != ref_generic) IsHeader = FALSE;
	else NbCs++;

        gr_temp[i] = list[g_ind++];
       }
    }
    if(NbCs != 1) IsHeader = FALSE;

    /*| construct object */
    *fcount    = 1;
    feet_list[0].objid    = NULL_OBJID;
    feet_list[0].osnum    = OM_Gw_current_OS;

    if(IsHeader)
     {
      sts = om$construct(  classid    = OPP_ACheader_class_id,
                           p_objid    = &feet_list[0].objid,
                           osnum      = feet_list[0].osnum );
      as$status( sts = sts );

      /*| place macro */
      sts = om$send(    msg     = message ACncpx.ACmplace( 
                                                        &int_msg,
                                                        AChdr_nodisplay,
                                                        AC_NO_REP,
                                                        me->graph_mac,
                                                        def_nb_temp,
                                                        gr_temp,
                                                        md_env ),
                      targetid = feet_list[0].objid,
                      targetos = feet_list[0].osnum );
      as$status( sts = sts );

     }
    else
     {
      /*| try a const */
      sts = om$construct(    classid    = OPP_ACconst_class_id,
                             p_objid    = &feet_list[0].objid,
                             osnum      = feet_list[0].osnum );
      as$status( sts = sts );
        
      sts = om$send(    msg     = message ACncpx.ACmplace( 
                                                           &int_msg,
                                                           AChdr_nodisplay,
                                                           AC_NO_REP,
                                                           me->graph_mac,
                                                           def_nb_temp,
                                                           gr_temp,
                                                           md_env ),
                        targetid = feet_list[0].objid,
                        targetos = feet_list[0].osnum );
      as$status( sts = sts );
     }

   if( !(int_msg & sts & 1))
    {
     /*| delete the macro in case of bad placement */
     om$send(     msg      = message NDnode.NDdelete( md_env ),
                  targetid = feet_list[0].objid,
                  targetos = feet_list[0].osnum );
     feet_list[0].objid = NULL_OBJID;
     goto wrapup;
    }

   /*| move to root */

   sts = om$send(    msg     = message NDnode.NDmove_to_root
                                              ( &msg, &feet_list[0], md_env ),
                      targetid = feet_list[0].objid,
                      targetos = feet_list[0].osnum );
   as$status( sts = sts );

 /* Called this method for CR: 179700254 */
        sts = om$send( msg = message VDSroot.VDputAttrDrivenSymb(
                                        &msg,
                                        md_env,
                                        "equip.att"),
                   targetid = my_id );
        /* as$status( sts = sts ); Do not check return status */

 if(gr_temp != NULL) om$dealloc( ptr = gr_temp);

 *rc = MSSUCC;
 return    OM_S_SUCCESS;

 wrapup : if(gr_temp != NULL) om$dealloc( ptr = gr_temp);
 	  *rc = MSFAIL;
 	  return    OM_W_ABORT;
}


/*+mo
 -------------------------------------------------------------------------

  Overridden Message
        ACgive_structure from NDmacro

  Abstract
	Given a foot name returns the corresponding geometric structure.
	A default implementation which calls ACreturn_foot and then asks the
	eometry of the returned foot is provided.
	It has been overriden to get the structure of the internal foot (cs)
	and to try some synonyms. 

  Algorithm

	- VDGetRep -> MyRep
	- if foot_name is "cs" or "ref" :
		- VDGetMat(str->var.ref_st.t) and str->type = ref_generic
		- if(me->MyStatus = VD_Eq_No_Rt) ie no cs as root:
				- Mat = Identity
				- if pid mode apply the scale factor to Mat
				- multiplies str->var.ref_st.t by Mat and
				returns that matrix.
 	- else send the ACncpx.ACgive_structure (return if success)
	- try some synonyms (LocFootName) and send ACncpx.ACgive_structure 


  Arguments
      int 		*suc              O 	0 FAILED 1 SUCCESS
      int 		*direct_index     O/I 	Very dangeous used only by 
						symbol macros
      char 		*footname         I 	the name of the foot to find

      struct ret_struct *ptr_rst          O 	the found struct.
      struct GRmd_env	*md_env           I 	module environnement information


  Status/Return Code
      status == OM_S_SUCCESS	if success;
      status == OM_E_ABORT	if fails

 -------------------------------------------------------------------------
-mo*/

method    ACgive_structure( IGRint *rc; IGRint *direct_ind; IGRchar *foot_name;
                            struct ret_struct *str; 
                            struct GRmd_env *md_env )
{
IGRlong               sts, msg;
IGRint                i;
IGRchar               save_name[120];
struct    GRid        gr_foot;
struct    ret_struct  my_str;
IGRdouble             local_point[3];
IGRdouble             world_point[3];
IGRdouble             cs_origin[3];
int                   cog_index,cog_index1,cog_index2;
int		      len;
char                  cog_text[15],cog_text1[15],cog_text2[15];

	SetProc( ACgive_structure );
	Begin

    *rc    = 0;

    if( ! foot_name ){
	return OM_E_ABORT ;
    }

    /* -------------------------------------------
     * 03 Jan 2000 - ah
     * need to copy before going to VDS_give_str
     */
    strcpy(save_name,foot_name);

    /* find SA_attr */
    if (!strncmp(foot_name,"SA_",3)) {
	/*
	 * Goto to the final else to check for the attribute using the
	 * VDS ACgive_structure method.
	 */
	goto VDS_give_str;
    }


    /* KLUDGE FOR PME. WILL BE REMOVED LATER */

    if( !strcmp(foot_name,"vds_catalog"))
	strcpy( save_name, "eqp_family" );
    else if(!strcmp(foot_name,"vds_partno"))
	strcpy( save_name, "eqp_partno");
    else if(!strcmp(foot_name,"vds_partrev"))
	strcpy( save_name, "eqp_partrev");
    else if(!strcmp(foot_name,"loc_x"))
	strcpy( save_name, "cog_x");
    else if(!strcmp(foot_name,"loc_y"))
	strcpy( save_name, "cog_y");
    else if(!strcmp(foot_name,"loc_z"))
	strcpy( save_name, "cog_z");

    /* END KLUDGE */

    // CR179800928 Reconize "family_name" mainly for posting
    if(!strcmp(foot_name,"family_name")) strcpy( save_name, "eqp_family" );

    /* Comment out to_lower conversion. Causes probems with Graphic outputs.

    len = strlen( save_name );
    for ( i =0; i < len; i++ )
	save_name[i] = (char)tolower( (int)save_name[i] );

    END KLUDGE */


    /*| find foot in box template */
    for( i=0; i<2; i++ ){

      sts = om$send(    msg     = message NDmacro.ACgive_structure(
                                                                    rc,
                                                                    direct_ind,
                                                                    save_name,
                                                                    str,
                                                                    md_env ),
                        p_chanselect = &ND_father,
                        from         = i,
                        to           = i );
       if( *rc & 1 )
       {
         /* If foot_name is "cogl_x","cogl_y" or "cogl_z" get value of the
            other 2 and convert value to global coordinates */
         if(   !strcmp( foot_name, "cogl_x" )
            || !strcmp( foot_name, "cogl_y" )
            || !strcmp( foot_name, "cogl_z" ))
         {
           if(      !strcmp( foot_name, "cogl_x" ))
           {
             cog_index = 0;
             strcpy(cog_text,"cogl_x");
             cog_index1 = 1;
             strcpy(cog_text1,"cogl_y");
             cog_index2 = 2;
             strcpy(cog_text2,"cogl_z");
           }
           else if( !strcmp( foot_name, "cogl_y" ))
           {
             cog_index = 1;
             strcpy(cog_text,"cogl_y");
             cog_index1 = 0;
             strcpy(cog_text1,"cogl_x");
             cog_index2 = 2;
             strcpy(cog_text2,"cogl_z");
           }
           else
           {
             cog_index = 2;
             strcpy(cog_text,"cogl_z");
             cog_index1 = 0;
             strcpy(cog_text1,"cogl_x");
             cog_index2 = 1;
             strcpy(cog_text2,"cogl_y");
           }
           
           local_point[cog_index] = str->var.root_pm_st.value;

           /* Get first corresponding value */
           for( i=0; i<2; i++ ){
             sts = om$send(    msg     = message NDmacro.ACgive_structure(
                                                                    rc,
                                                                    direct_ind,
                                                                    cog_text1,
                                                                    str,
                                                                    md_env ),
                              p_chanselect = &ND_father,
                              from         = i,
                              to           = i );
             if( *rc & 1 )
             {
               local_point[cog_index1] = str->var.root_pm_st.value;
               break;
             }
           }

           if ( !(*rc & 1 ) )
           {
             /* Corresponding value not found */
             *rc = 0;
             return OM_W_ABORT;
           }

           /* Get second corresponding value */
           for( i=0; i<2; i++ ){
             sts = om$send(    msg     = message NDmacro.ACgive_structure(
                                                                    rc,
                                                                    direct_ind,
                                                                    cog_text2,
                                                                    str,
                                                                    md_env ),
                              p_chanselect = &ND_father,
                              from         = i,
                              to           = i );
             if( *rc & 1 )
             {
               local_point[cog_index2] = str->var.root_pm_st.value;
               break;
             }
           }

           if ( !(*rc & 1 ) )
           {
             /* Corresponding value not found */
             *rc = 0;
             return OM_W_ABORT;
           }

           if (VDget_world_coords(my_id,local_point,world_point,cs_origin)
                 != OM_S_SUCCESS)
           {
             *rc = 0;
             return OM_W_ABORT;
           }

           str->var.root_pm_st.value = world_point[cog_index];
         }
        return OM_S_SUCCESS;
       }
    }

    /* If foot_name is "cogl_x","cogl_y" or "cogl_z" - failure
       Try to get values of "cog_x","cog_y" resp "cog_z" instead */
    if(      !strcmp( foot_name, "cogl_x" )) strcpy( save_name,"cog_x" );
    else if( !strcmp( foot_name, "cogl_y" )) strcpy( save_name,"cog_y" );
    else if( !strcmp( foot_name, "cogl_z" )) strcpy( save_name,"cog_z" );

    /*| get graphics foot */
    gr_foot.objid = NULL_OBJID;
    sts = om$send(    msg     = message NDmacro.ACreturn_foot(
                                                                &msg,
                                                                FEET_GRAPHICS,
                                                                &gr_foot,
                                                                NULL,
                                                                NULL ),
                      targetid = my_id );
    as$status( sts = sts );
    /*" gr_foot : %d/%d\n", gr_foot.objid, gr_foot.osnum */

    if( ! strcmp( save_name, "cog_x" )
      ||! strcmp( save_name, "cog_y" )
      ||! strcmp( save_name, "cog_z" ))
    {

      if(! strcmp( save_name, "cog_x" ))
      {
        cog_index = 0;
        strcpy(cog_text,"cog_x");
      }
      else if(! strcmp( save_name, "cog_y" ))
      {
        cog_index = 1;
        strcpy(cog_text,"cog_y");
      }
      else
      {
        cog_index = 2;
        strcpy(cog_text,"cog_z");
      }

      if( VDgive_feet_structure( rc, &gr_foot, "cog", &my_str, md_env )) {
        str->type                    = double_type;
        str->var.root_pm_st.value    = my_str.var.point_st.pt[cog_index];
        *rc    = 1;
        return    OM_S_SUCCESS;
      }
      else
      {
        /* "cog" not found - if foot_name=<cog_text> try to get
           "cogl_x" for "cog_x", "cogl_y" for "cog_y" or "cogl_z" for "cog_z"
           i.e caller wanted values of "cog_x","cog_y or "cog_z"*/
        if (!strcmp(save_name,cog_text))
        {
          /*| find "cogl_x", "cogl_y" and "cogl_z" in box template */
          /* Get "cogl_x" */
          for( i=0; i<2; i++ )
          {
            sts = om$send(    msg     = message NDmacro.ACgive_structure(
                                                                    rc,
                                                                    direct_ind,
                                                                    "cogl_x",
                                                                    str,
                                                                    md_env ),
                              p_chanselect = &ND_father,
                              from         = i,
                              to           = i );
            if( *rc & 1 )
            {
              local_point[0] = str->var.root_pm_st.value;
              break;
            }
          }
          if ( *rc & 1 )
          {
            /* Get "cogl_y" */
            for( i=0; i<2; i++ )
            {
              sts = om$send(    msg     = message NDmacro.ACgive_structure(
                                                                    rc,
                                                                    direct_ind,
                                                                    "cogl_y",
                                                                    str,
                                                                    md_env ),
                              p_chanselect = &ND_father,
                              from         = i,
                              to           = i );
              if( *rc & 1 )
              {
                local_point[1] = str->var.root_pm_st.value;
                break;
              }
            }

            if ( *rc & 1 )
            {
              /* Get "cogl_z" */
              for( i=0; i<2; i++ )
              {
                sts = om$send(    msg     = message NDmacro.ACgive_structure(
                                                                    rc,
                                                                    direct_ind,
                                                                    "cogl_z",
                                                                    str,
                                                                    md_env ),
                                 p_chanselect = &ND_father,
                                 from         = i,
                                 to           = i );
                if( *rc & 1 )
                {
                  local_point[2] = str->var.root_pm_st.value;
                  break;
                }
              }

              if ( *rc & 1 )
              {
                /* Convert value to global coordinates */

                if (VDget_world_coords(my_id,local_point,world_point,cs_origin)
                  != OM_S_SUCCESS)
                {
                  *rc = 0;
                  return OM_W_ABORT;
                }
                str->var.root_pm_st.value = world_point[cog_index];
                return OM_S_SUCCESS;
              }
            }
          }
        }

        /* Still not successful - get origin coordinates of root coord sys */
        if (VDget_world_coords(my_id,local_point,world_point,cs_origin) 
            != OM_S_SUCCESS)
        {
          *rc = 0;
          return OM_W_ABORT;
        }
        str->var.root_pm_st.value = cs_origin[cog_index];
        return OM_S_SUCCESS;
      }
    }

	       /* Below lines added by Anand for CR 179901735 */
    if( ! strncmp(foot_name,"dp_eqpt_",8) )
    {
	/*Equipment Attributes related to Extract for Dynapipe - handled here*/
	struct GRid	EqCSid;
	IGRmatrix	EqCSmat;

	SetProc(Dynapipe VDeqpt ACgive_structure); Begin

	       /* Below lines added by Anand for CR 179902056 */
	if( ! strcmp(foot_name,"dp_eqpt_parent_id") )
	{
	    struct GRid	Obj1, Obj2;
	    IGRint	One;

		/* Get ACpretend parent's id */
	    Obj1.objid = my_id;
	    Obj1.osnum = md_env->md_id.osnum;
	    vdchn$GetList( objID	= &Obj1,
			   chnName	= VDCHN_NAME_FATHER,
			   chnIDx	= VDCHN_IDX_FATHER,
			   maxCnt	= 1,
			   cnt		= &One,
			   FltrClsId	= OPP_ACpretend_class_id,
			   outIDs	= &Obj2 );
	    __DBGpr_obj(" ACpretend parent of eqpt",Obj2);

		/* Get the correction's id */
	    vdchn$GetList( objID	= &Obj2,
			   chnName	= VDCHN_NAME_FATHER,
			   chnIDx	= VDCHN_IDX_FATHER,
			   maxCnt	= 1,
			   cnt		= &One,
			   FltrClNam	= "VRCorrection",
			   outIDs	= &Obj1 );
	    __DBGpr_obj("  correction grand-parent of eqpt",Obj1);

		/* Get the Duct's id (component) */
	    vdchn$GetList( objID	= &Obj1,
			   chnName	= VDCHN_NAME_TO_COMPONENTS,
			   chnIDx	= VDCHN_IDX_TO_COMPONENTS,
			   maxCnt	= 1,
			   cnt		= &One,
			   FltrClNam	= "VRComponent",
			   outIDs	= &Obj2 );
	    __DBGpr_obj("'dp_eqpt_parent_id'",Obj2);

	    str->type = text_type;
	    sprintf(str->var.text_st.text_string, "[%d,%d]",
						       Obj2.objid, Obj2.osnum); 
	    __DBGpr_str(" attribute returned",str->var.text_st.text_string);

	    *rc = MSSUCC;
	    End
	    return OM_S_SUCCESS;
	}
	       /* Above lines added by Anand for CR 179902056 */

	/*| Get Graphics foot from equipment macro */
	EqCSid.objid = NULL_OBJID;
	sts=om$send( msg = message NDmacro.ACreturn_foot( &msg,
							  "graphics:orientCS",
							  &EqCSid, NULL, NULL ),
		targetid = my_id );
	as$status( sts = sts );
	__DBGpr_obj(" Equipment's Coord System ID",EqCSid );
	if( EqCSid.objid == NULL_OBJID )
	{
	    *rc=MSFAIL;
	    printf(" Equipment does not have 'orientCS' as output!\n");
	    End
	    return OM_E_ABORT;
	}

	sts=om$send( msg = message GRgencs.GRgetmatrix( &msg,
		    					(IGRdouble *) EqCSmat ),
		targetid = EqCSid.objid,
		targetos = EqCSid.osnum );
	as$status( sts = sts );
	__DBGpr_mat("Equipment CS matrix",EqCSmat);

	if( ! strcmp(foot_name,"dp_eqpt_ref_pnt") )
	{
	    IGRchar	szEqpRef[80];

	    sprintf(szEqpRef,"%lf,%lf,%lf", EqCSmat[ 3],
					    EqCSmat[ 7],
					    EqCSmat[11] );

	    str->type = text_type;
	    strcpy( str->var.text_st.text_string, szEqpRef );
	    __DBGpr_str(" dp_eqpt_ref_pnt",str->var.text_st.text_string);

	    *rc = MSSUCC;
	    End
	    return OM_S_SUCCESS;
	}

	if( ! strcmp(foot_name,"dp_eqpt_angle_pos") )
	{
	    IGRchar	szEqpYvec[80];

	    sprintf(szEqpYvec,"%lf,%lf,%lf", (EqCSmat[1]+EqCSmat[ 3]),
					     (EqCSmat[5]+EqCSmat[ 7]),
					     (EqCSmat[9]+EqCSmat[11]) );

	    str->type = text_type;
	    strcpy( str->var.text_st.text_string, szEqpYvec );
	    __DBGpr_str("dp_eqpt_angle_pos",str->var.text_st.text_string);

	    *rc = MSSUCC;
	    End
	    return OM_S_SUCCESS;
	}

	/* Added by Anand for JTS CR 4093 (CR 179902127) */
	if( ! strcmp(foot_name,"dp_eqpt_angle_rot") )
	{
	    IGRchar	szEqpXvec[80];

	    sprintf( szEqpXvec, "%lf,%lf,%lf", (EqCSmat[0]+EqCSmat[ 3]),
					       (EqCSmat[4]+EqCSmat[ 7]),
					       (EqCSmat[8]+EqCSmat[11]) );

	    str->type = text_type;
	    strcpy( str->var.text_st.text_string, szEqpXvec );
	    __DBGpr_str("dp_eqpt_angle_rot", str->var.text_st.text_string);

	    *rc = MSSUCC;
	    End
	    return OM_S_SUCCESS;
	}
	/* Added by Anand for JTS CR 4093 (CR 179902127) */
    }
    else if( ! strncmp(foot_name,"dp_nozz_",8)	||
	     ! strcmp(foot_name,"zone_number")	||
	     ! strcmp(foot_name,"service")	||
	     ! strcmp(foot_name,"spec_name") )
    {
	/* Nozzle Attributes related to Extract for Dynapipe - put them here */
	int			j,nNozIndx=-1;
	IGRint			NumACpretends=0;
	IGRint			NumNozzles=0,TotNumNozzles=0;
	struct GRid		*ACpretendObjs=NULL,*NozzleObjs=NULL;
	IGRchar			szNozIndx[3],szDpNozzAttr[20];
	struct GRid		*NozzList=NULL,MyID;

	SetProc(Dynapipe VDeqptNoz ACgive_structure); Begin

	__DBGpr_str(" Foot name",foot_name);
	__DBGpr_me();
	MyID.objid = my_id;
	MyID.osnum = md_env->md_id.osnum;

	vdchn$GetList ( objID	= &MyID,
			chnName	= VDCHN_NAME_CHILDREN,
			chnIDx	= VDCHN_IDX_CHILDREN,
			maxCnt	= 32767,
			cnt	= &NumACpretends,
			FltrClsId = OPP_ACpretend_class_id );
	__DBGpr_int("Number of Equipment's child objects ", NumACpretends);

	if ( NumACpretends )
	{
	    ACpretendObjs = _CALLOC(NumACpretends, struct GRid);
	    if( ACpretendObjs==NULL )
	    {
		printf(" calloc of ACpretendObjs failed\n");
		End
		return OM_E_NODYNMEM;
	    }

	    vdchn$GetList( objID	= &MyID,
			   chnName	= VDCHN_NAME_CHILDREN,
			   chnIDx	= VDCHN_IDX_CHILDREN,
			   maxCnt	= NumACpretends,
			   cnt		= &NumACpretends,
			   FltrClsId	= OPP_ACpretend_class_id,
			   outIDs	= ACpretendObjs );

	}

	for( i=0 ; i<NumACpretends ; i++ )
	{
	    vdchn$GetList ( objID	= (ACpretendObjs+i),
			    chnName	= VDCHN_NAME_CHILDREN,
			    chnIDx	= VDCHN_IDX_CHILDREN,
			    maxCnt	= 32767,
			    cnt		= &NumNozzles,
			    FltrClNam	= "VRNozzle" );
	    __DBGpr_int("Number of ACpretend child objects", NumNozzles);

	    if( NumNozzles )
	    {
		NozzleObjs = _CALLOC(NumNozzles, struct GRid);
		if( NozzleObjs==NULL )
		{
		    printf(" calloc of NozzleObjs failed\n");
		    End
		    return OM_E_NODYNMEM;
		}

		vdchn$GetList(objID	= (ACpretendObjs+i),
			      chnName	= VDCHN_NAME_CHILDREN,
			      chnIDx	= VDCHN_IDX_CHILDREN,
			      maxCnt	= NumNozzles,
			      cnt	= &NumNozzles,
			      FltrClNam	= "VRNozzle",
			      outIDs	= NozzleObjs );
	    }

	    /* Collect nozzles from each ACpretend child (NozzleObjs)
	     * to build up the list of all nozzles embedded to the
	     * VDS equipment (NozzList).
	     */

	    TotNumNozzles += NumNozzles;
	    if( TotNumNozzles )
	      if( NozzList )
		NozzList = _REALLOC(NozzList, TotNumNozzles, struct GRid);
	      else
		NozzList =  _CALLOC(TotNumNozzles, struct GRid);
//	    printf(" Num Nozzles in %dth ACpretend=%d\n",i,NumNozzles);

	    for( j=TotNumNozzles-NumNozzles ; j<TotNumNozzles ; j++ )
	    {
		if( NozzleObjs[j+NumNozzles-TotNumNozzles].objid
							    == NULL_OBJID )
		    continue;

		NozzList[j].objid =
			    NozzleObjs[j+NumNozzles-TotNumNozzles].objid;
		NozzList[j].osnum =
			    NozzleObjs[j+NumNozzles-TotNumNozzles].osnum;
//		printf("Nozzle id %d,%d\n",
//	    			 NozzList[j].objid, NozzList[j].osnum);
	    }
	    _FREE(NozzleObjs);
	}
	_FREE(ACpretendObjs);

	__DBGpr_objlist("Nozzles in equipment", TotNumNozzles, NozzList );

	if( ! strcmp( foot_name , "dp_nozz_count" ) )
	{
	    _FREE(NozzList);
	    str->type = double_type;
	    __DBGpr_int("num of Nozzles ", TotNumNozzles);
	    str->var.root_pm_st.value = (IGRdouble) TotNumNozzles;
	    *rc = MSSUCC;
	    End
	    return OM_S_SUCCESS;
	}

	if( NozzList==NULL )
	{
	    __DBGpr_com("**************\n\tNozzList EMPTY\n\t**************");
	    *rc=MSFAIL;
	    if( TotNumNozzles )
	    {
		End
		return OM_E_NODYNMEM;
	    }
	    else
	    {
		End
		return OM_E_ABORT;
	    }
	}

	strncpy( szNozIndx , &foot_name[8], 2 );
	__DBGpr_str(" Nozzle Index string",szNozIndx );
	nNozIndx=atoi( szNozIndx );
	__DBGpr_int(" Nozzle Index",nNozIndx);

	if( nNozIndx>=TotNumNozzles || nNozIndx<0 )
	{
	    __DBGpr_com(" Invalid index!");
	    *rc=MSFAIL;
	    End
	    return OM_E_INVARG;
	}

	if( ! strcmp(foot_name,"zone_number")	||
	    ! strcmp(foot_name,"service")	||
	    ! strcmp(foot_name,"spec_name") )
	    strcpy( szDpNozzAttr , foot_name );
	else
	    strcpy( szDpNozzAttr , &foot_name[11] );
	__DBGpr_str(" Attr being sought",szDpNozzAttr );

	if( ! strcmp(szDpNozzAttr,"equiv_dia")		||
	    ! strcmp(szDpNozzAttr,"insul_thk")		||
	    ! strcmp(szDpNozzAttr,"insul_type")		||
	    ! strcmp(szDpNozzAttr,"acst_insul_type")	||
	    ! strcmp(szDpNozzAttr,"acst_insul_thk")	||
	    ! strcmp(szDpNozzAttr,"press_class")	||
	    ! strcmp(szDpNozzAttr,"max_veloc")		||
	    ! strcmp(szDpNozzAttr,"size_method")	||
	    ! strcmp(szDpNozzAttr,"shape_code")		||
	    ! strcmp(szDpNozzAttr,"duct_matl")		||
	    ! strcmp(szDpNozzAttr,"duct_thk")		||
	    ! strcmp(szDpNozzAttr,"max_depth")		||
	    ! strcmp(szDpNozzAttr,"ref")		||
	    ! strcmp(szDpNozzAttr,"zone_number")	||
	    ! strcmp(szDpNozzAttr,"service")		||
	    ! strcmp(szDpNozzAttr,"spec_name")
	  )
	{
	    __DBGpr_obj("get attrib from nozzle id",*(NozzList+nNozIndx));
//	    printf(" Nozzle id %d,%d\n",
//		       NozzList[nNozIndx].objid,NozzList[nNozIndx].osnum );
	    sts = om$send( msg = message ACncpx.ACgive_structure(rc,direct_ind,
								 szDpNozzAttr,
								 str,md_env),
		      senderid = my_id,
		      targetid = (NozzList+nNozIndx)->objid,
		      targetos = (NozzList+nNozIndx)->osnum );
	    as$status( sts=sts );
	    as$status( sts=msg , action = RET_STATUS );

//	    printf(" Leaving ACgive_structure with <%s>\n",szDpNozzAttr);
	    _FREE(NozzList);

	    if( ! strcmp(szDpNozzAttr,"ref") )
	    {
		IGRchar	szNozRef[80];
		sprintf(szNozRef,"%lf,%lf,%lf", str->var.ref_st.t[3],
						str->var.ref_st.t[7],
						str->var.ref_st.t[11] );

		str->type = text_type;
		strcpy( str->var.text_st.text_string, szNozRef );
	    }

	    End
	    return OM_S_SUCCESS;
	}
	else if ( ! strcmp(szDpNozzAttr,"veloc_calc") ||
		  ! strcmp(szDpNozzAttr,"press_drop") )
	{
	    /* Hard-coded to return zero!! */
	    str->type = double_type;
	    str->var.root_pm_st.value = 0.0;
	    *rc=MSSUCC;
	    End
	    return OM_S_SUCCESS;
	}
	else{
	    __DBGpr_str(" strcmp !*FAILED*! for",szDpNozzAttr);
	}
    }
    else if( ! strcmp(foot_name,"surf_area") )
    {
	IGRint		NumMacFeet=0;
	IGRdouble	Area,CumArea;
	struct GRid	*MacFeet=NULL;

	SetProc(surf_area ACgive_structure); Begin

	sts=om$send( msg = message NDmacro.ACreturn_foot( &msg, "graphics",
		    					  &gr_foot, NULL, NULL),
		targetid = my_id );
	as$status( sts=sts );
	__DBGpr_obj(" graphics foot id",gr_foot);

	sts = vdchn$GetList( objID	= &gr_foot,
			     chnName	= VDCHN_NAME_TO_COMPONENTS,
			     chnIDx	= VDCHN_IDX_TO_COMPONENTS,
			     maxCnt	= 32767,
			     cnt	= &NumMacFeet,
			     FltrClNam	= "nci_macro" );
	__DBGpr_int(" Num objs in to_components channel of ACconst obj",
								  NumMacFeet );
	if( NumMacFeet==0 || !(sts&1) )
	{
	    *rc=MSFAIL;
	    End
	    return sts;
	}

	MacFeet = _CALLOC( NumMacFeet , struct GRid );
	if( MacFeet==NULL )
	{
	    *rc=MSFAIL;
	    End
	    return OM_E_NODYNMEM;
	}

	sts = vdchn$GetList( objID	= &gr_foot,
			     chnName	= VDCHN_NAME_TO_COMPONENTS,
			     chnIDx	= VDCHN_IDX_TO_COMPONENTS,
			     maxCnt	= NumMacFeet,
			     cnt	= &NumMacFeet,
			     outIDs	= MacFeet,
			     FltrClNam	= "nci_macro" );
	__DBGpr_objlist(" Components of ACconst", NumMacFeet, MacFeet);

	if( MacFeet==NULL || NumMacFeet==0 || !(sts&1) )
	{
	    *rc=MSFAIL;
	    End
	    return sts;
	}

	for( i=0,CumArea=0.0 ; i<NumMacFeet ; Area=0.0,i++ )
	{
	    IGRint		NumSurf=0;
	    struct GRid		SurfId;
	    OMuword		ClassId;
	    extern GRclassid	OPP_EMSsurface_class_id;

	    sts = vdchn$GetList( objID   = (MacFeet+i),
				 chnName = VDCHN_NAME_TO_COMPONENTS,
				 chnIDx  = VDCHN_IDX_TO_COMPONENTS,
				 maxCnt  = 1,
				 cnt     = &NumSurf,
				 outIDs  = &SurfId,
				FltrClsId= OPP_EMSsurface_class_id );
	    __DBGpr_obj("Grand-Component of ACconst",SurfId);
	    if( NumSurf )
	    {
		sts = vd_$get_area_props( msg     = &msg,
					  surfId  = &SurfId,
					  surfEnv = md_env,
					  area    = &Area );
		__DBGpr_dbl("Surface Area",Area);
		as$status( sts=sts );
		CumArea += Area;
	    }
	}
	__DBGpr_dbl("Cumulative Surface Area",CumArea);

	str->type = double_type;
	str->var.root_pm_st.value = CumArea;
	*rc=MSSUCC;
	End
	return OM_S_SUCCESS;

	/* Above lines added by Anand for CR 179901735 */
    }
    else
    {

VDS_give_str:

	sts = OM_S_SUCCESS;

	// For smart Attributes, changed from ACncpx
	sts = om$send(    msg     = message VDSroot.ACgive_structure(
				    rc,
				    direct_ind,
				    save_name,
				    str,
				    md_env ),
		mode     = OM_e_wrt_message,
		targetid = my_id );
	as$status( sts = sts, action = RET_STATUS );
	if( sts & *rc & 1 )    return    OM_S_SUCCESS;

	/* find in nesting feet */
	VDgive_feet_structure( rc, &gr_foot, save_name, str, md_env );

#ifdef vdsDEBUG
	printf("foot_name=%s, type=%d,value=%f\n",save_name,str->type,str->var.root_pm_st.value);
	/*" *rc : %d\n", *rc */
#endif
    }

    End
    return    sts;
}

/* ****************** VDget_world_coords **********************     */

VDget_world_coords(eqp_id, local_point, world_point, cs_origin )
GRobjid        eqp_id;	               /*  Equipment object id            (I) */
IGRdouble      local_point[3];         /*  Coordinate in local coord sys  (I) */
IGRdouble      world_point[3];         /*  Coordinate in global coord sys (O) */
IGRdouble      cs_origin[3];           /*  Origin of root coord sys       (O) */
/*.VDget_world_coords*/
{
    IGRlong               sts, msg;
    IGRint                i,idum;
    struct    GRid        cs_id,list,*root_buf;
    char                  classname[80];
    int                   nb_roots;
    int                   rc;
    IGRshort              mat_type;
    IGRdouble             matrix[16];
    IGRdouble             ref_point[3];
    IGRdouble             cs_origin1[3];
    IGRdouble             matrix1[9],matrix2[9];
    IGRboolean            tran1,tran2;
    IGRchar               *p_geom;
    BSrc                  bsrc;

    rc = 1;
    root_buf = NULL;

    /* First dummy call of NDget_objects in order to get number of
       roots */
    sts = om$send ( msg = message NDnode.NDget_objects( ND_ROOT,
                                                        &list,
                                                        1,
                                                        NULL,
                                                        0,
                                                        OM_K_MAXINT,
                                                        &nb_roots),
                    targetid = eqp_id,
                    senderid = NULL_OBJID );
    as$status( sts = sts, action = RET_STATUS );

    /* Allocate memory for root buffer */
    root_buf = (struct GRid *) om$malloc( 
                                       size=sizeof( struct GRid ) * nb_roots );
    if( root_buf == NULL ){
      printf(" ERROR not enough memory to allocate root_buf \n");
      return OM_W_ABORT;
    }

    /* Get the roots */
    sts = om$send ( msg = message NDnode.NDget_objects( ND_ROOT,
                                                        root_buf,
                                                        nb_roots,
                                                        NULL,
                                                        0,
                                                        OM_K_MAXINT,
                                                        &idum),
                    targetid = eqp_id,
                    senderid = NULL_OBJID );
      if ( sts != OM_S_SUCCESS ) {
        rc = 0;
        goto wrapup;
      }

    for (i=0;i<nb_roots;i=i+1) {
      om$get_classname (osnum     = root_buf[i].osnum,
                        objid     = root_buf[i].objid,
                        classname = classname);

      if(   strcmp(classname,"ASsource")
         && strcmp(classname,"ASsourcein")) continue;

      sts = om$send ( msg = message NDmacro.ACreturn_foot( &msg, "", &cs_id,
                                                           &mat_type, matrix),
                      targetid = root_buf[i].objid,
                      targetos = root_buf[i].osnum,
                      senderid = NULL_OBJID );
      if ( sts != OM_S_SUCCESS ) {
        rc = 0;
        goto wrapup;
      }

      om$get_classname (osnum     = cs_id.osnum,
                        objid     = cs_id.objid,
                        classname = classname);

      if(strcmp(classname,"GRgencs")) continue;

/***** This call may be used if transformation matrix and attach origin of
/*       reference file attachment is added
/*      sts = om$send ( msg = message GRgencs.GRcvt_to_wld_coords(
/*                                                                &msg,
/*                                                                "r",
/*                                                                1,
/*                                                                local_point,
/*                                                                ref_point),
/*                      targetid = cs_id.objid,
/*                      targetos = cs_id.osnum,
/*                      senderid = NULL_OBJID );
/*      if ( sts != OM_S_SUCCESS || msg != MSSUCC) {
/*        rc = 0;
/*        goto wrapup;
/*      }
/***************************************************************************/

      sts = om$send ( msg = message GRvg.GRgenabsg(
                                                    &msg,
                                                    &mat_type,
                                                    matrix,
                                                    &p_geom),
                      targetid = cs_id.objid,
                      targetos = cs_id.osnum,
                      senderid = NULL_OBJID );
      if ( sts != OM_S_SUCCESS || msg != MSSUCC) {
        rc = 0;
        goto wrapup;
      }

      /* Get origin coords of cs */

/******* This gives a good origin of coordinate system
/*       if coordinate system located in current file, bad if
/*       coordinate system in reference file  ***********************/

      cs_origin1[0]=((struct IGRlbsys *) p_geom)->matrix[3];
      cs_origin1[1]=((struct IGRlbsys *) p_geom)->matrix[7];
      cs_origin1[2]=((struct IGRlbsys *) p_geom)->matrix[11];

      matrix2[0] = matrix[0];
      matrix2[1] = matrix[1];
      matrix2[2] = matrix[2];
      matrix2[3] = matrix[4];
      matrix2[4] = matrix[5];
      matrix2[5] = matrix[6];
      matrix2[6] = matrix[8];
      matrix2[7] = matrix[9];
      matrix2[8] = matrix[10];

      tran1 = FALSE;
      tran2 = FALSE;
      BSmult_mats(3,3,matrix2,tran1,3,1,cs_origin1,tran2,cs_origin,&bsrc);

      if(bsrc != BSSUCC) {
        rc = 0;
        printf("BSmult_mats failed rc =%d\n",bsrc);
        goto wrapup;
      }

      cs_origin[0] = matrix[3] + cs_origin[0];
      cs_origin[1] = matrix[7] + cs_origin[1];
      cs_origin[2] = matrix[11] + cs_origin[2];

/*********************************************************************/
      /* Transform to current os */

/******* This gives the same result as previous call of GRcvt_to_wld_coords
/*       if coordinate system located in current file, differs if
/*       coordinate system in reference file ****************************/
      matrix1[0] = ((struct IGRlbsys *) p_geom)->matrix[0];
      matrix1[1] = ((struct IGRlbsys *) p_geom)->matrix[1];
      matrix1[2] = ((struct IGRlbsys *) p_geom)->matrix[2];
      matrix1[3] = ((struct IGRlbsys *) p_geom)->matrix[4];
      matrix1[4] = ((struct IGRlbsys *) p_geom)->matrix[5];
      matrix1[5] = ((struct IGRlbsys *) p_geom)->matrix[6];
      matrix1[6] = ((struct IGRlbsys *) p_geom)->matrix[8];
      matrix1[7] = ((struct IGRlbsys *) p_geom)->matrix[9];
      matrix1[8] = ((struct IGRlbsys *) p_geom)->matrix[10];

      tran1 = FALSE;
      tran2 = FALSE;
      BSmult_mats(3,3,matrix1,tran1,3,1,local_point,tran2,ref_point,&bsrc);

      if(bsrc != BSSUCC) {
        rc = 0;
        printf("BSmult_mats failed rc =%d\n",bsrc);
        goto wrapup;
      }

      ref_point[0] = cs_origin[0] + ref_point[0];
      ref_point[1] = cs_origin[1] + ref_point[1];
      ref_point[2] = cs_origin[2] + ref_point[2];

/************************************************************************/

/******* This means no change if coordinate system located in current file,
/*       curious result if coordinate system in reference file ************/

      matrix2[0] = matrix[0];
      matrix2[1] = matrix[1];
      matrix2[2] = matrix[2];
      matrix2[3] = matrix[4];
      matrix2[4] = matrix[5];
      matrix2[5] = matrix[6];
      matrix2[6] = matrix[8];
      matrix2[7] = matrix[9];
      matrix2[8] = matrix[10];

      tran1 = FALSE;
      tran2 = FALSE;
      BSmult_mats(3,3,matrix2,tran1,3,1,ref_point,tran2,world_point,&bsrc);

      if(bsrc != BSSUCC) {
        rc = 0;
        printf("BSmult_mats failed rc =%d\n",bsrc);
        goto wrapup;
      }

      world_point[0] = matrix[3] + world_point[0];
      world_point[1] = matrix[7] + world_point[1];
      world_point[2] = matrix[11] + world_point[2];

/***************************************************************************/
      goto wrapup;
    }

    /* Coordinate system not found */
    rc = 0;

wrapup:
    /* free memory */
    if (root_buf != NULL) om$dealloc(ptr=root_buf);

    return    rc;
}
/* ****************** VDgive_feet_structure () ************************    */

VDgive_feet_structure( ret, in_obj, foot_name, str, md_env )

IGRint                *ret;
struct    GRid        *in_obj;
IGRchar               *foot_name;
struct    ret_struct  *str;
struct    GRmd_env    *md_env;

/*.VDgive_feet_structure*/
{
IGRlong               sts, msg;
struct    GRid        def_id;
IGRint                nb_feet;
struct    myfeet      *my_feet;
IGRint                i;
struct    GRid        foot;


    /*| on entre dans VDgive_feet_structure */
    *ret    = 0;

    /*| find at in_obj level */

    sts = om$send(    msg     = message NDmacro.ACgive_structure(
                                                                   ret,
                                                                   NULL,
                                                                   foot_name,
                                                                   str,
                                                                   md_env ),
                      targetid = in_obj->objid,
                      targetos = in_obj->osnum,
                      senderid = NULL_OBJID );
/*    as$status( sts = sts );*/
    if( *ret & 1 )    return    OM_S_SUCCESS;
    if (sts != OM_S_SUCCESS) return sts;
    sts = om$send(    msg     = message ACcpx.find_macro( &def_id ),
                      targetid = in_obj->objid,
                      targetos = in_obj->osnum,
                      senderid = NULL_OBJID );
    if( !(sts & 1) )
	return sts;

    if( (sts = om$is_objid_valid( osnum = def_id.osnum, objid = def_id.objid ))
					!= OM_S_SUCCESS )
	return sts;
/*
    as$status( sts = sts, action = RET_STATUS );
*/
    /*" def_id : %d/%d\n", def_id.objid, def_id.osnum */

    /*| get feet desc */
    sts = om$send(    msg     = message ACcpx_defn.ACgive_feet_desc
                                                       ( &nb_feet, &my_feet ),
                      targetid = def_id.objid,
                      targetos = def_id.osnum,
                      senderid = NULL_OBJID );
    as$status( sts = sts, action = RET_STATUS );
    /*" nb_feet : %d\n", nb_feet */

    for( i=0; i<nb_feet; i++ )

        if( IS_SAME_GEOM( my_feet[i].prop, macro_generic ) ){

            /*" my_feet[%d].name : %s\n", i, my_feet[i].name */
            sts = om$send(    msg     = message NDmacro.ACreturn_foot(
                                                                &msg,
                                                                my_feet[i].name,
                                                                &foot,
                                                                NULL,
                                                                NULL ),
                              targetid = in_obj->objid,
                              targetos = in_obj->osnum,
                              senderid = NULL_OBJID );
            /*" foot : id/os = (%d/%d)\n", foot.objid, foot.osnum */
            as$status( sts = sts );
            if( !( sts&1))    continue;

            VDgive_feet_structure( ret, &foot, foot_name, str, md_env );
            if( *ret & 1 )    return OM_S_SUCCESS;

        }/*end macro in feet*/

    /*| feet not find */

return    0;
}

/*+mo
 -------------------------------------------------------------------------

  Overridden Message
       GRgetobjinfo from GRgraphics

  Abstract

	Reports information about the object. 
	It has been overriden to display the macro name when the equipment
	is located (status field).

  Arguments

	IGRlong		*msg            O   	completion code
	struct GRobj_info *info		O	structure for information about
                                 		the object


  Status/Return Code
	status == OM_S_SUCCESS	always

 -------------------------------------------------------------------------
-mo*/

method    GRgetobjinfo( IGRlong *rc; struct GRobj_info *info )

{
	*rc = MSSUCC;
	sprintf( info->type, "EQUIP-%s", me->graph_mac );
	return    OM_S_SUCCESS;
}


/*+mo
 -------------------------------------------------------------------------
  Public Message VDGetGraphMac

  Abstract

      Get the macro name of the graphics (me->graph_mac)

  Arguments
        IGRlong          *msg            O      MSSUC if success and
                                                MSFAIL if not.
        IGRchar          *MacName        I      macro name

  Status/Return Code
      status == OM_S_SUCCESS if success else OM_E_ABORT.

 -------------------------------------------------------------------------
-me*/
method VDGetGraphMac(IGRlong *msg; IGRchar *MacName )
{
IGRint            sts, name_size;


 if( MacName ){ 

	strcpy( MacName, me->graph_mac );
	*msg = MSSUCC;
	return OM_S_SUCCESS;
 }

 wrapup:

 *msg = MSFAIL;
 return OM_E_ABORT;

}


end implementation VDequipment;
