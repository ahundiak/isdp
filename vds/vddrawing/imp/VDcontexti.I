/* $Id: VDcontexti.I,v 1.2 2001/01/19 21:58:08 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/vddrawing/imp / VDcontexti.I
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: VDcontexti.I,v $
 *	Revision 1.2  2001/01/19 21:58:08  ramarao
 *	Merged from SP.
 *	
# Revision 1.1  2000/08/01  19:49:46  pinnacle
# Created: vds/vddrawing/imp/VDcontexti.I by rchennup for Service Pack
#
# Revision 1.1  1998/04/29  16:27:20  pinnacle
# VDS 2.5.1
#
# Revision 1.5  1998/03/18  20:30:16  pinnacle
# Replaced: vddrawing/imp/VDcontexti.I for:  by mdong for vds
#
# Revision 1.4  1998/03/13  23:21:56  pinnacle
# Replaced: vddrawing/imp/VDcontexti.I for:  by azuurhou for vds
#
# Revision 1.3  1998/02/11  19:52:16  pinnacle
# Replaced: vddrawing/imp/VDcontexti.I for:  by azuurhou for vds
#
# Revision 1.2  1997/12/18  08:11:58  pinnacle
# Replaced: vddrawing/imp/VDcontexti.I for: CR 179603526 by smpathak for vds
#
# Revision 1.1  1997/05/08  13:20:44  pinnacle
# New project VDS 250
#
# Revision 1.1  1996/07/19  20:33:52  pinnacle
# Create VDS 241 project
#
# Revision 1.3  1995/11/21  23:41:12  pinnacle
# Replaced: vddrawing/imp/VDcontexti.I for:  by azuurhou for vds.240
#
# Revision 1.2  1995/03/03  23:03:04  pinnacle
# Replaced: vddrawing/imp/VDcontexti.I by azuurhou r#
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
 *	02/11/98	adz		Correction method set_setup_name
 *	03/13/98	adz		TR 179800762
 *      03/17/98        Ming            Check me->filename in VDget_setup_name()
 *
 * -------------------------------------------------------------------*/

class implementation VDcontext;

/*
 * HISTORY:
 *
 * ADZ		May 4  1993	- Dealloc to wrong structure pointer.
 * AF		Nov 9  1993	- Correction for context.(See Drawing.README)
 */

#include "OMmacros.h"
#include "OMprimitives.h"
#include "AS_status.h"
#include "AS_debug.h"
#include "v_dbgmacros.h"

%safe

static struct GRid	last_context = {0,(OM_S_OBJID)-1};
static int		last_nb_obj = 0,
			last_size_obj = 0;  
static struct GRid	*last_obj_list = NULL;

%endsafe

extern GRclassid	OPP_VDdrawing_class_id;
extern GRclassid	OPP_VDdraw_class_id;

method VDget_level(int *level)
{
int	i;

	for(i=0;i<32;i++) level[i] = me->level[i];
	return OM_S_SUCCESS;
}

method VDset_level(int *level)
{
int	i;

	for(i=0;i<32;i++) me->level[i] = level[i];
	return OM_S_SUCCESS;
}

method VDget_lbs(struct IGRlbsys *lbs)
{
	*lbs = me->lbs;
	return OM_S_SUCCESS;
}

method VDset_lbs(struct IGRlbsys *lbs)
{
	me->lbs = *lbs;
	return OM_S_SUCCESS;
}

method VDset_setup_name(char *name)
{
	int	len, size, status;
	char	buf[2], *pBuf;

	buf[0] = '\0';

	if( ! name ){
	  pBuf = buf ;
          status =
          om$vla_set_dimension( varray  = me->filename,
                                size    = 2 );
	}
	else{
          len = strlen( name );
	  pBuf = name ;
          status =
          om$vla_set_dimension( varray  = me->filename,
                                size    = len + 2 );
	}

	/*
	 * Copy the information.
	 */
	strcpy( me->filename, pBuf );
	__DBGpr_str(" SET:filename", me->filename );

quit:
	return( OM_S_SUCCESS );
}

method VDget_setup_name(char *name)
{
	int len;

        if( ! name )    return( OM_E_ABORT );
        
        len =  om$dimension_of( varray  = me->filename );
        if ( !len ) return( OM_E_ABORT );

	__DBGpr_str(" me->filename", me->filename );
        strcpy( name, me->filename );
        return( OM_S_SUCCESS );
}

/* Get size of setup file name */

method VDget_setup_name_size(int *size)
{
        *size = om$dimension_of( varray = me->filename );
        return( OM_S_SUCCESS );
}

/* Get/set name of set */

method VDset_osname(char *name)
{
int     len,
        status;

        len = strlen( name );
        status = om$vla_set_dimension(  varray  = me->osname,
                                        size    = len + 2 );
        strcpy( me->osname, name );
        return( OM_S_SUCCESS );
}

method VDget_osname(char *name)
{
        if( ! name )    return( OM_E_ABORT );
	if((me->osname != NULL) && (me->osname[0] != '\0'))
        	strcpy( name, me->osname );
	else name[0] = '\0';

        return( OM_S_SUCCESS );
}

method VDset_proj_view(double *point,*vector)
{
int	i;

	for(i=0;i<3;i++) me->point[i]  = point[i];
	for(i=0;i<3;i++) me->vector[i] = vector[i];

	return OM_S_SUCCESS;
}

method VDget_proj_view(double *point,*vector)
{
int	i;

	for(i=0;i<3;i++) point[i]  = me->point[i];
	for(i=0;i<3;i++) vector[i] = me->vector[i];

	return OM_S_SUCCESS;
}

method VDget_extract_info(	struct GRid	**obj_list;
				int		*nb_obj;
				double		*vector,*point;
				int		*level;
				struct IGRlbsys *lbs)
{
int			i;
OMuint			count;
OM_S_OBJECT_LINKAGE	*obj_link;
OM_S_CHANSELECT		misc_chan;
int			status = OM_S_SUCCESS;

/*
 * get the context levels (???).
 */
	for( i=0 ; i<32 ; i++ ) level[i] = me->level[i];

/*
 * 	As result of invalid layer during extraction of new objects, open
 *	levels for all the reference files.
 */
	for( i=0 ; i<32 ; i++ ) level[i] = ~0 ;

/*
 * get the context range.
 */
	*lbs = me->lbs;

/*
 * get the drawing view vector and support point.
 */
	for( i=0 ; i<3 ; i++ ) vector[i] = me->vector[i];
	for( i=0 ; i<3 ; i++ ) point[i]  = me->point[i];

/*
 * Get the drawing macro connected under the context object
 */
	obj_link = NULL;

/*
 * AF /(AZ) 10-nov-1993
 * Context of object can be wrong or deleted in case the drawing extraction
 * is executed more than ones. To avoid this, do not give the context list
 * back.
 * 
 * if(last_context.objid == my_id && last_context.osnum == OM_Gw_current_OS)
 *  {
 *   *obj_list = last_obj_list;
 *   *nb_obj = last_nb_obj; 
 *  }
 *	if ( 0 ) {
 *		*obj_list	= last_obj_list;
 *		*nb_obj		= last_nb_obj; 
 *	}
 *	else {
 */

	last_context.objid = my_id;
	last_context.osnum = OM_Gw_current_OS;

	status =
	om$make_chanselect(	channame	= "GRcontext.to_misc",
				p_chanselect	= &misc_chan);
	as$status( action = RET_STATUS );

	status =
	om$get_channel_count(	object		= me,
				p_chanselect	= &misc_chan,
				count		= &count );
	as$status( action = RET_STATUS );

	if( count <= 0 ){
		*nb_obj = 0;
		*obj_list = NULL;
		goto wrapup;
	}

	if( count > last_size_obj ){

		if( last_obj_list )
			om$dealloc( ptr = last_obj_list );

		last_obj_list = (struct GRid *) om$malloc
				(size = count *sizeof(OM_S_OBJECT_LINKAGE));
		if( ! last_obj_list ){
			last_size_obj = 0;
			return OM_W_ABORT;
		}

		last_size_obj = count;
	}

	obj_link = (OM_S_OBJECT_LINKAGE *) last_obj_list;

	status =
	om$get_channel_objects(	object		= me,
				p_chanselect	= &misc_chan,
				list		= obj_link,
				size		= count,
				count		= &count );
	as$status( action = RET_STATUS );

	last_nb_obj = 0;

	for( i=0 ; i<count ; i++ ){

	    last_obj_list[last_nb_obj].osnum = obj_link[i].osnum;
	    last_obj_list[last_nb_obj++].objid = obj_link[i].S_objid;

	}

	*obj_list = last_obj_list;
	*nb_obj   = last_nb_obj; 

wrapup:

	return OM_S_SUCCESS;
}

int PatMatch( char * text1 , char * text2 )
{
 int 	i,j,cnt,
	rc ,count;
 char 	tmp[20];

  for(cnt=0,count=0;*(text1+cnt)!='\0';cnt++)
  if(*(text1+cnt)== '|')  count++;

 count++;
 rc = 1;
 for(i=0,cnt=0;cnt<count;cnt++)
 {
  j=0;
  while( *(text1+i)!='\0' && *(text1+i)!='|')
  {
   *(tmp+j)=*(text1+i);
   i++;
   j++;
  }
  *(tmp+j)= '\0';
  i++;
  
  rc = strcmp(tmp , text2);
  if(rc==0)
    break;

 }
 return (rc);

}

end implementation VDcontext;
