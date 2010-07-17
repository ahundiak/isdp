/* $Id $  */
/* --------------------------------------------------------------------
 * I/STRUCT
 *
 * File:       vsmisc/VSgetsibling.I 
 *
 * Description: Functions to get the siblings of a VSfeature object.
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log $
 *
 * History:
 *      MM/DD/YY        AUTHOR          DESCRIPTION
 *      05/24/00        Rama Rao        File Creation.
 * -------------------------------------------------------------------*/

class implementation VDSroot;

#include "acmacros.h"
#include "VDobj.h"
#include "v_datamacros.h"
#include "v_miscmacros.h"
#include "vs.h"
#include "vsdbgmacros.h"

#define vdsDEBUG        1
#define vdserrDEBUG     1

from 	VSfeature	import	VSforwardToSource, 
				VSexecuteFunctionAlongGeneration;

extern GRclassid	OPP_VSsrcPlate_class_id, OPP_VSplate_class_id,
			OPP_VSbeam_class_id, OPP_VSfeature_class_id;

IGRlong  VSgetOperName( struct GRid     *macId, 
			IGRchar		*selector,
			IGRchar		*operName   )
{
IGRint			dirIndex;
IGRlong            	sts, msg;
IGRchar			defName[DI_PATH_MAX], macName[128];
struct GRid             defCol;
struct ret_struct       str;

   vdobj$Get( objID   = macId,
	      macName = macName );
   __DBGpr_str("Macro Name ", macName );
   sprintf( defName, "%s$def", macName );
    
   defCol.objid    = NULL_OBJID;
   sts = ac$find_macro_defn( action          = ACfind_no_load,
                             macro_name      = defName,
                             p_macro_defn_id = &defCol );
   if(!(sts&1)) return MSFAIL;

   /*| find form attribut */
   dirIndex = -1;
   sts = om$send(  msg      = message NDmacro.ACgive_structure( (int *) &msg,
                         	&dirIndex, selector, &str, NULL ),
			senderid = NULL_OBJID,
                        targetid = defCol.objid,
                        targetos = defCol.osnum   );
   if( ! (sts&msg&1))      return  MSFAIL;

   if( text_type != str.type ) return MSFAIL;
   if( operName )  strcpy(operName, str.var.text_st.text_string);

return  MSSUCC;
}

int VLgetPostPlacementMacros(	const struct GRid 	*plate,
				VSlistElmtId 		*cuList )
{
IGRlong         sts, msg;
IGRint          i, j, count, mac_cnt;
IGRchar		footName[DI_PATH_MAX];
struct GRid 	tmp_id, *pChild;

   /* Initialization */
   pChild  = NULL;
   count   = 0;

   __DBGpr_obj("Evaluating Plate ", *plate );
   sts = VSgetChildrenGoThruPretends( &msg, plate, &count, &pChild );
   if( ! (sts&msg&1) || !count )      goto    wrapup;

   __DBGpr_int("Number Of Childrens found ", count );
   for( i=0, mac_cnt=0; i<count; i++ )
   {
	__DBGpr_obj("Evaluating Macro ", pChild[i] );
	if( ( VSgetOperName(&pChild[i], "~~post_placement", footName) &1 ) )
	{
	   tmp_id          = pChild[mac_cnt];
	   pChild[mac_cnt] = pChild[i];
	   pChild[i]	   = tmp_id;
	   mac_cnt++;
  	   __DBGpr_int("Yes. This is a Post Placement Macro ", mac_cnt );
	}
	else __DBGpr_com("No. Not a Post Placement Macro" );
   }
   __DBGpr_int("Number Of Post Placement Macros ", mac_cnt );
   if( !mac_cnt ) goto wrapup;
   count = mac_cnt;

   if( *(cuList->pList) )
   {
       *(cuList->pList) = _REALLOC( *(cuList->pList),
                                (*(cuList->pCount) + count), struct GRid );
   }
   else
   {
       *(cuList->pList) = _MALLOC( count, struct GRid );
   }

   if( !(*(cuList->pList)) )
   {
       printf(" Error : Not enought memory to allocate pList\n" );
       _FREE( pChild );
       return  FALSE;
   }
  
   for( i=*cuList->pCount, j=0; j<count; i++, j++ )
             (*cuList->pList)[i] = pChild[j];

   *cuList->pCount += count;

wrapup :
   _FREE( pChild );
   return  TRUE;
}

IGRint	VSaddElemToList( struct GRid    elem,
			 IGRint		*count,
			 struct GRid	**list,
			 IGRint		*max_count )
{
  if( !(*list) )
  {
     *list = _MALLOC( 10, struct GRid );
     if( ! (*list) )
     {
        printf(" Error : Not enought memory to allocate list\n");
        return FALSE;
     }
     *max_count = 10;
  }
  else if( (*max_count) == ((*count)+1) )
  {
     *max_count += 10;
     *list = _REALLOC( *list, (*max_count)+10, struct GRid );
     if( ! (*list) )
     {
        printf(" Error : Not enought memory to allocate list\n");
        return FALSE;
     }
  }
  (*list)[(*count)++] = elem ;
  return TRUE;
}

IGRlong	VSgetSiblings(	IGRlong		*msg,
			struct GRid	plate,
			IGRint		*count,
			struct GRid	**list )
{
IGRlong			sts;
IGRint			i, j, loc_cnt, pl_count, max_count=0;
struct GRid		*mc=NULL, *src_plates=NULL;
VSlistElmtId		fctArgs;

   SetProc( VSgetSiblings ); Begin

   if( !msg || !count || !list ) return OM_E_INVARG;

   *count  = 0;
   loc_cnt = 0;
   *list   = NULL;
   sts = *msg = MSSUCC;

   if( !vd_$is_ancestry_valid( object  = &plate, 
                               classid = OPP_VSplate_class_id ) &&
       !vd_$is_ancestry_valid( object  = &plate,
                               classid = OPP_VSbeam_class_id ) ) 
   {
	return sts;
   }

   fctArgs.pList  = &mc;
   fctArgs.pCount = &loc_cnt;

   __DBGpr_obj("Input Plate ID ", plate );
   *msg = -2;
   sts = om$send(  msg = message VSfeature.VSforwardToSource( msg, 
							      OM_e_wrt_object, 
			 message VSfeature.VSexecuteFunctionAlongGeneration(
				&plate, VLgetPostPlacementMacros, 
				(void*)&fctArgs, FALSE ) ),
		senderid = NULL_OBJID,
		targetid = plate.objid,
		targetos = plate.osnum  );
   if( *msg == -2 )
   {
	sts = VLgetPostPlacementMacros( &plate, &fctArgs );
	if( sts & 1 )   *msg = MSSUCC;	
   }
   if( ! (sts&(*msg)&1)){ sts = MSFAIL; goto wrapup; }
   __DBGpr_int("Number of PP macros returned ", loc_cnt );

   for( i=0; i<loc_cnt; ++i )
   {
      pl_count = 0;
      _FREE( src_plates );
      sts = VSgetChildrenGoThruPretends( msg, &mc[i], &pl_count, &src_plates );
      if( ! (sts&(*msg)&1) || !pl_count )      continue;
      __DBGpr_int("Number Of Childrens found ", pl_count );

      for( j=0; j<pl_count; ++j )
      {
	 //vdobj$Print( objID = &src_plates[j] );
         if( vd_$is_ancestry_valid( object  = &src_plates[j],
                                    classid = OPP_VSsrcPlate_class_id ) )
         {
	     if( !VSaddElemToList( src_plates[j], count, list, 
			      &max_count ) ) goto wrapup;
	     __DBGpr_int("Adding to the output list ", *count );
         }
      }
   }

   if( vd_$is_ancestry_valid( object  = &plate,
                              classid = OPP_VSsrcPlate_class_id ) )
   {
      IGRint		isConsumed=0, num_parents=0;
      IGRchar         	footName[DI_PATH_MAX];
      struct GRid  	par_surf, templateID;

      sts = om$send(  msg     = message NDmacro.ACtest_consumed( &isConsumed ),
			senderid = NULL_OBJID,
			targetid = plate.objid,
			targetos = plate.osnum );
      __DBGpr_int("Is Consumed? ", isConsumed );
      if( !(sts&1) || isConsumed ) { sts = MSSUCC; goto wrapup; }

      vdobj$GetParent( 	objID	   = &plate,
		 	idx        = 0,
		 	parentID   = &par_surf );
      __DBGpr_obj("Parent Surface Macro for this plate ", par_surf );
      if( !( VSgetOperName( &par_surf, "~~post_placement", 
			   footName) &1 ) )  { sts = MSSUCC; goto wrapup; }

      sts = om$send ( msg =  message NDnode.NDget_objects( ND_ROOT, NULL, 0,
				NULL, 0, OM_K_MAXINT, &num_parents ),
                        senderid = NULL_OBJID,
                        targetid = par_surf.objid,
                        targetos = par_surf.osnum );
      if( !(sts&1)) { sts = MSSUCC; goto wrapup; }
      __DBGpr_int("Number of Parents for this macro ", num_parents );

      for( i=0; i<num_parents; ++i )
      {
	vdobj$GetParent(  objID      = &par_surf,
			  idx	     = i,
			  parentID   = &templateID );

        if( vd_$is_ancestry_valid( object  = &templateID,
                              classid = OPP_VSfeature_class_id ) )	
	{
             if( !VSaddElemToList( templateID, count, list,
                              &max_count ) ) goto wrapup;
             __DBGpr_int("Adding to the output list ", *count );
	}
      }	
   }

   sts = MSSUCC;

wrapup:
   _FREE( mc );
   _FREE( src_plates );
   End
   return sts;
}

end implementation VDSroot;
