/*f <VLnameFunk.I> contains a function used by in the I/LOFT sources to give
    name to the macro occurences. */

class implementation VLabstract;

#include	<stdio.h>
#include	"vlprototype.h"
#include	"DItypedef.h"
#include	"DIdef.h"
#include	"DIglob.h"
#include	"DIprims.h"
#include	"DImacros.h"
#include	"msdef.h"

extern	int	DIfast_trans();
extern	char	*strrchr();
extern	int	strtol();

void VLoccNaming ( target_dir, mac_name, occ_name, msg )

/*d This function creates a name for a macro occurence in target_dir */

/*h 03/02/93 : Copied from generate_occ_name() VDS function by Marc FOURNIER. */
/*h 04/02/93 : Add target_dir in argument list */
	IGRchar			*target_dir;	/*I search directory */
	IGRchar			*mac_name;	/*I macro name     */
	IGRchar			*occ_name;	/*O occurence name */
	IGRlong			*msg;	  	/*O error message  */

{
/*c Beginning of function */

			IGRchar		occ_zero[DI_PATH_MAX];
			IGRchar		full_name[DI_PATH_MAX];
	struct		GRid		obj_id;
			IGRchar		*c;
			IGRchar		*c1;
			IGRint		i;
			IGRlong		loc_msg;

	sprintf ( occ_zero, "%s_00", mac_name);
	strcpy ( occ_name, occ_zero);

	/*c Search identic name */
	if( target_dir ) sprintf( full_name, "%s:%s", target_dir, occ_name );
	else	strcpy( full_name, occ_name );
	loc_msg = di$translate ( objname = full_name,
			      p_objid = &obj_id.objid,
			      p_osnum = &obj_id.osnum );

	if (loc_msg == DIR_S_SUCCESS) {

		/*c If objname like name_## find pointer on suffix */
		c = (IGRchar *) strrchr ( full_name, '_');
		if (c != NULL) {
			i = strtol ( c+1, &c1, 10);
			if (*c1 != '\0') c = NULL;
		}
		if (c == NULL) c = full_name + strlen(full_name);

		/*c Find correct suffix */
		for (i=0; i<1000; i++) {
			if (i<100) sprintf ( c, "_%02d", i);
			else	   sprintf ( c, "_%03d", i);
			loc_msg = di$translate ( objname = full_name,
                             		      p_objid = &obj_id.objid,
                             		      p_osnum = &obj_id.osnum );
			if (loc_msg != DIR_S_SUCCESS) break;
		}

		/*c Generate name + suffix */
		if (i >= 1000) occ_name[0] = '\0';
		else {
			c = (IGRchar *) strrchr ( full_name, ':');
			if (c == NULL) c = full_name;
			else	       c = c +1;
			strcpy ( occ_name, c);
		}
	}

	*msg	= MSSUCC;

/*c End of function */
} 

void VLoccNaming1 ( target_dir, mac_name, occ_name, msg )
	IGRchar			*target_dir;	/*I search directory */
	IGRchar			*mac_name;	/*I macro name     */
	IGRchar			*occ_name;	/*O occurence name */
	IGRlong			*msg;	  	/*O error message  */
{
IGRchar         occ_zero[DI_PATH_MAX];
IGRchar		full_name[DI_PATH_MAX];
struct GRid	obj_id;
IGRchar		*c;
IGRchar		*c1;
IGRint		i=-1, j;
IGRlong		loc_msg;

	if( target_dir ) sprintf( full_name, "%s:%s", target_dir, mac_name );
        else  strcpy( full_name, mac_name );

	/*c If objname like name_## find pointer on suffix */
	c = (IGRchar *) strrchr ( full_name, ':');
	c = (IGRchar *) strrchr ( c, '_');

	if (c != NULL) {
		i = strtol ( c+1, &c1, 10);
		if (*c1 != '\0') c = NULL;
	}
	if (c == NULL) { c = full_name + strlen(full_name); i=-1; }

	if( i == -1 )
	{
           sprintf ( occ_zero, "%s_00", mac_name);
           strcpy  ( occ_name, occ_zero);
           i++;
	}
	else strcpy ( occ_name, mac_name );

	if( target_dir ) sprintf( full_name, "%s:%s", target_dir, occ_name );
	else	strcpy( full_name, occ_name );

	/*c Search identical name */
	loc_msg = di$translate ( objname = full_name,
			      p_objid = &obj_id.objid,
			      p_osnum = &obj_id.osnum );

	if (loc_msg == DIR_S_SUCCESS) {

		/*c Find correct suffix */
		for (j=i; j<1000; j++) {
			if (j<100) sprintf ( c, "_%02d", j);
			else	   sprintf ( c, "_%03d", j);
			loc_msg = di$translate ( objname = full_name,
                             		      p_objid = &obj_id.objid,
                             		      p_osnum = &obj_id.osnum );
			if (loc_msg != DIR_S_SUCCESS) break;
		}

		/*c Generate name + suffix */
		if (i >= 1000) occ_name[0] = '\0';
		else {
			c = (IGRchar *) strrchr ( full_name, ':');
			if (c == NULL) c = full_name;
			else	       c = c +1;
			strcpy ( occ_name, c);
		}
	}

	*msg	= MSSUCC;

return  /* OM_S_SUCCESS */; /* 10/9/96 slj - function is type void shouldn't */
			    /* return a value */
}

end implementation VLabstract;
