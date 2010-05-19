/* $Id: vdsmacros.h,v 1.2 2001/03/22 23:17:19 ramarao Exp $  */

/* --------------------------------------------------------------------
 * I/VDS
 *
 * File:	vds/include / vdsmacros.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdsmacros.h,v $
 *	Revision 1.2  2001/03/22 23:17:19  ramarao
 *	Added vd$vw_fit_many_objects macro.
 *	
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1998/01/19  16:13:08  pinnacle
 * Replaced: include/vdsmacros.h for:  by azuurhou for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.2  1995/06/05  19:12:46  pinnacle
 * Replace: include/vdsmacros.h by hverstee for OPE
 *
 * Revision 1.1  1994/11/14  22:42:32  pinnacle
 * Create vds.240 from vds.232
 *
 * Revision 1.1  1994/11/08  16:07:00  pinnacle
 * create vds.232
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *
 * -------------------------------------------------------------------*/


#ifndef vdsmacros_include
#define vdsmacros_include

/*
 * 	This file depends on the following files :
 *      godef.h
 *      gr.h
 *      igr.h
 *      igrdp.h
 *	go.h
 */

/*---------------------------------------------------------------------------*/
#if defined(__STDC__) || defined(__cplusplus)
#define __(args) args
#else
#define __(args) ()
#endif

#if defined(__cplusplus)
extern "C" {
#endif

extern int VDcnst_pln __((	IGRint *msg,
				double *mat,
				double dist,
				double offset1,
				double offset2,
				char axe,
				double length,
				char *name,
				char *justif,
				unsigned char props,
				struct GRid *plan_obj,
				struct GRvg_construct *cst ));

extern int VDSOpenFile __((	char *file,
				char *product,
				char *sub_dir,
				int cur_dir,
				FILE **fp ));

extern int VDCnstPt __((	IGRlong *msg,
				double *pt,
				char *name,
				short x_offset,
				short y_offset,
				struct GRid *pt_obj,
				short props,
				struct GRvg_construct *cst ));

extern int VDvw_fit_object __(( struct GRid *object,
				IGRdouble factor,
				struct GRmd_env *md_env,
				struct GRid *ggid,
				IGRint num_ggid ));

extern int VDvw_fit_many_objects __(( 
				IGRint                  count,
				struct  GRid            *grids,
				struct  GRobj_env       *objenvs,
				IGRdouble               factor,
				struct  GRmd_env        *md_env,
				struct  GRid            *ggid,
				IGRint                  num_ggid ));

extern int VDget_codelist_attr __((
				IGRlong *msg,
				IGRint	product,
				IGRint	list_num,
				IGRint	req,
				IGRint	i_code,
				IGRchar *i_sname,
				IGRchar *i_lname,
				IGRint	*o_code,
				IGRchar *o_sname,
				IGRchar *o_lname,
				IGRchar *p_error ));

extern int vdget_name __((
				struct GRid *obj,
				IGRchar	    *name ));

extern int VD_findFileInDirOrProductPaths __((
				long            *msg ,
				const char      *fileToFind,
				const char      *dirToSearchFirst,
				const char      *dirInProdPathToSearchThen,
				char            *absPathName ));

#if defined(__cplusplus)
}
#endif

/*---------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------

  MACRO
	vd$const_plane(	msg,
			matrix,
			axe     = 'z',
			dist    = 0.,
			size    = 0.,
			name    = NULL,
			justif  = "CC",
			offset1 = 0.,
			offset2 = 0.,
			props   = 0x00,
			cst,
			obj )

  ABSTRACT 
	This macro allows to construct a plane on an axis at a given distance.
   
  ARGUMENTS

	data type	argument	I/O description

	IGRint		*msg		O : Complection code 1 if ok.
	IGRdouble	*matrix		I : 4x4 matrix.
	IGRchar		axe		I : one of the matrix axix (x, y, z).
	IGRdouble	dist		I : Dist along the axis.
	IGRdouble	size		I : Size of the plane. (see REMARKS)
	IGRchar		*name		I : If plane view scale independent,
					    this text will be displayed
					    (v.s. independent.)
	IGRchar		*justif		I : The justification on the 2 other
					    axis. (see REMARKS)
	IGRdouble	offset1		I : The offset on the first
					    following axis.
	IGRdouble	offset2		I : The offset on the 3th axis.
	IGRchar		*props		I : The properties of the root plane.
					    (see REMARKS)
	struct GRvg_construct *cst	I : Construction list.
	struct GRid	*obj		O : Objid of the constructed object.

  REMARKS
	size :	If the size is 0, -1 or -2, it means the plane is view scale 
		independent plane. (0 -> medium size, -1 -> small, -2 -> large).

	jusif :	The first letter defines the justif for the first following
		axis and the second letter for the next one.
		The justification can be (Centered, Positve, Negative).
		Example, if the selected axis is y,  the justif "PC" means: 

			Positve justif on Z axis and
			Centered on x axis.

	props :	Example, if the root as a reversed normal, the constructed
		plane will have a reversed normal. When the root plane has
		a reversed normal the distance will also be inverted.
		(only the reversed normal is taking into account).

  STATUS RETURNS

	OM_S_SUCESS : Success
	OM_W_ABORT  : Failure

  ------------------------------------------------------------------------- */

#omdef vd$const_plane (msg,
		       matrix,
		       axe     = 'z',
		       dist    = 0.,
		       size    = 0.,
                       name    = NULL,
		       justif  = "CC",
		       offset1 = 0.,
		       offset2 = 0.,
		       props   = 0x00,
		       cst,
		       obj)
	VDcnst_pln( (msg), (matrix), (dist),
		    (offset1), (offset2), (axe), (size),
		    (name), (justif), (props), (obj), (cst) )
#endomdef

/*---------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------

  MACRO
	vd$openfile(	file_name    = NULL,
			product_name = "Vds",
			sub_path     = NULL,
			cur_dir      = TRUE,
			p_file )

  ABSTRACT 
	This macro allows to open a file.
	A product name can be specified or not.
	If cur_dir=TRUE, it will first try to open it in the current directory.
   
  ARGUMENTS

	data type	argument 	I/O description

	IGRchar		file            I : file name.
	IGRchar		product_name    I : product name or NULL.
	IGRchar		sub_path        I : subdirectory path or NULL.	
	IGRint		cur_dir		I : TRUE if first look into the 
					    current directory.
	FILE		**p_file	O : pointeur to the opened file.
			 
  STATUS RETURNS

	TRUE   : Success
	FALSE  : Failure

  ------------------------------------------------------------------------- */

#omdef vd$openfile( file_name    = NULL,
		    product_name = "Vds",
		    sub_path     = NULL,
		    cur_dir      = TRUE,
		    p_file)

	VDSOpenFile( (file_name), (product_name), (sub_path), (cur_dir),
		     (p_file))

#endomdef

/*---------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------

  MACRO
	vd$cnst_txt_pt (msg,
			pt,
			name     = NULL,
			x_offset = 0,
			y_offset = 0,
			props    = VD_X_POS,
			cst,
			obj )

  ABSTRACT 
	This macro allows to create a text point.
	A text point is a regular point with a view scale independent text.
	The text is defined by the "name" argument.
	It is possible specifying a justification (X, Y, positive or negative)
	and allow specifying if the point or/and the text are displayed
	or not.  The x and y offset are pixel offsets.

  ARGUMENTS

	data type	argument  	I/O description

	IGRlong		*msg	      	O : Complection code MSSUCC or MSFAIL.
	IGRdouble	*pt	      	I : Point location (three double).
	IGRchar		*name		I : Text. 
	IGRshort	x_offset	I : x offset in pixels.
	IGRshort	y_offset	I : y offset in pixels.
	struct GRid	*obj     	O : objid of the constructed object
	IGRshort	props		I : proporties (see vdsutil_def.h).
	struct GRvg_construct *cst	I : Construction list.


   STATUS RETURNS

	OM_S_SUCCESS   : Success

  ------------------------------------------------------------------------- */

#omdef vd$cnst_txt_pt (msg,
		       pt,
                       name     = NULL,
		       x_offset = 0,
		       y_offset = 0,
		       props    = VD_X_POS,
		       cst,
		       obj)

	VDCnstPt((msg),(pt),(name),(x_offset),(y_offset),(obj),(props),(cst))

#endomdef

/*---------------------------------------------------------------------------*/
/* --------------------------------------------------------------------------

  MACRO
	vd$vw_fit_object ( object, factor, md_env, ggid, num_ggid );

  ABSTRACT
	This macro does a fit operation on the given object in the views,
	given by the struct GRid ggid[], and the number of view gragads.

	In case no view gragads are defined, as default all the view gragads
	will be updated.

  ARGUMENTS

	data type	argument	I/O description

	struct GRid	*object;	I : object to fit
	IGRdouble	factor;		I : view fit factor (>1)
	struct GRmd_env	*md_env;	I : module environment
	struct GRid	*ggid;		I : list of view gragad to update
	IGRint		num_ggid;	O : number of view gragad to update

  EXAMPLE:

	Fit a selected object in all the views.

	struct	GRid	loc_obj;
	...
	sts = vd$vw_fit_object ( object	= &loc_obj );

  Return status:
	MSSUCC		oke
	MSFAIL		error

  ------------------------------------------------------------------------- */

#omdef	vd$vw_fit_object (	object,
				factor	  = 1.0 ,
				md_env	  = NULL ,
				ggid      = NULL ,
				num_ggid  = 0 )
#if ( ! om$specified( object ))
#	omerror "Must specify object to fit view "
#else
	VDvw_fit_object( (object), (factor), (md_env), (ggid), (num_ggid) );
#endif

#endomdef

/* --------------------------------------------------------------------------

  MACRO
        vd$vw_fit_many_objects 

  ABSTRACT
        This macro does a fit operation on the multiple objects in the views,
        given by the struct GRid ggid[], and the number of view gragads.

        In case no view gragads are defined, as default all the view gragads
        will be updated.

  ARGUMENTS

        data type       argument        I/O description
	
	IGRint		count;		I : Number of objects to fit
        struct GRid     *grids;         I : object to fit ( struct GRids ) OR
	struct GRobj_env *objenvs;	I : object list to fit
        IGRdouble       factor;         I : view fit factor (>1)
        struct GRmd_env *md_env;        I : module environment
        struct GRid     *ggid;          I : list of view gragad to update
        IGRint          num_ggid;       O : number of view gragad to update

  Return status:
        MSSUCC          oke
        MSFAIL          error

  ------------------------------------------------------------------------- */

#omdef  vd$vw_fit_many_objects( count     = 1,
				grids     = NULL  ^ objenvs   = NULL,
				md_env    = NULL,
                                factor    = 1.0 ,
                                ggid      = NULL ,
                                num_ggid  = 0 )

    VDvw_fit_many_objects( (count), (grids), (objenvs), (factor), (md_env),
			   (ggid), (num_ggid) );

#endomdef

/*-------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------

  MACRO
	vd$get_alias(	p_msg,
			product,
			type,
			i_code ^ i_sname ^ i_lname,
			o_code ^ o_sname ^ o_lname,
			p_error )

  ABSTRACT
	This macro retrieves the codelist information from various tables
	like VDS_CODELIST, PIPING_CODELIST, STRUCT_CODELIST etc.,

  ARGUMENTS
	data type  	argument  	I/O description

	IGRlong		*p_msg;         O : MESSAGE NUM.
	IGRint		product		I : VDS/STRUCT/PIPING/HVAC/RWAY
	IGRint		type		I : List number
	IGRint		i_code		I : Code Number
	IGRchar		*i_sname	I : Short text.
	IGRchar		*i_lname	I : Long text.
	IGRint		o_code		O : Code Number
	IGRchar		*o_sname	O : Short text.
	IGRchar		*o_lname	O : Long text.
	IGRchar		*p_error	O : return status	

  RETURN STATUS

  ------------------------------------------------------------------------- */

/* Define internal types   */

#define VD_ALIAS_CD_TO_ST   1
#define VD_ALIAS_CD_TO_LT   2
#define VD_ALIAS_ST_TO_CD   3
#define VD_ALIAS_ST_TO_LT   4
#define VD_ALIAS_LT_TO_CD   5
#define VD_ALIAS_LT_TO_ST   6

#omdef vd$get_alias( 	p_msg,
			product,
			type,
			i_code=NULL ^ i_sname=NULL ^ i_lname=NULL,
			o_code=NULL ^ o_sname=NULL ^ o_lname=NULL,
			p_error)

#if 	om$specified (i_code)  && om$specified (o_code)   || \
	om$specified (i_sname) && om$specified (o_sname)  || \
	om$specified (i_lname) && om$specified (o_lname)

#  omerror "Input and output are the same"

#else

# if	om$specified (i_code) && om$specified (o_sname)
	VDget_codelist_attr((p_msg),(product),(type), VD_ALIAS_CD_TO_ST,
			(i_code),(i_sname),(i_lname),
			(o_code),(o_sname),(o_lname),(p_error))
#  else
#  if	om$specified (i_code) && om$specified (o_lname)
	VDget_codelist_attr((p_msg),(product),(type), VD_ALIAS_CD_TO_LT,
			(i_code),(i_sname),(i_lname),
			(o_code),(o_sname),(o_lname),(p_error))
#   else
#   if	om$specified (i_sname) && om$specified (o_code)
	VDget_codelist_attr((p_msg),(product),(type), VD_ALIAS_ST_TO_CD,
			(i_code),(i_sname),(i_lname),
			(o_code),(o_sname),(o_lname),(p_error))
#    else
#    if	om$specified (i_sname) && om$specified (o_lname)
	VDget_codelist_attr((p_msg),(product),(type), VD_ALIAS_ST_TO_LT,
			(i_code),(i_sname),(i_lname),
			(o_code),(o_sname),(o_lname),(p_error))
#     else
#     if om$specified (i_lname) && om$specified (o_code)
	VDget_codelist_attr((p_msg),(product),(type), VD_ALIAS_LT_TO_CD,
			(i_code),(i_sname),(i_lname),
			(o_code),(o_sname),(o_lname),(p_error))
#      else
#      if om$specified (i_lname) && om$specified (o_sname)
        VDget_codelist_attr((p_msg),(product),(type), VD_ALIAS_LT_TO_ST,
			(i_code),(i_sname),(i_lname),
			(o_code),(o_sname),(o_lname),(p_error))
#      endif
#     endif
#    endif
#   endif
#  endif
# endif
#endif

#endomdef

/* --------------------------------------------------------------------------

  MACRO
        vd$get_name( obj, name)

  ABSTRACT
        This macro returns the short name of the given object.

  ARGUMENTS
	data type	argument	I/O description

	struct GRid	*obj		I	the given  object
	IGRchar		*name		O	the name of the object

  REMARKS
	If there is no name, name is set to '\0'.

  RETURN STATUS
        OM_E_ABORT		Invalid input defined.
	OM_S_SUCCESS 		Otherwise.

  ------------------------------------------------------------------------- */

#omdef vd$get_name    (obj, name )

        vdget_name((obj),(name))

#endomdef

/*---------------------------------------------------------------------------*/
/*-------------------------------------------------------------------------

  MACRO
	vd$file_path(	msg,
			fileToFind,
			dirToSearchFirst,
			dirInProdPathToSearchThen,
			absPathName )

  ABSTRACT 
         * Finds the absolute pathname of 'fileToFind' (which maybe a pathname)
         * by searching first in 'dirToSearchFirst' and then in the
	 * sub-directories 'dirInProdPathToSearchThen' in the product paths.
	 * For instance, if
	 *	fileToFind			= "a/b/F",
         * 	dirToSearchFirst		= "."
	 * and	dirInProdPathToSearchThen	= "config/d",
         * then the following files will be looked for:
         * 1 "./a/b/F"
         * 2 "<user-path>/config/d/a/b/F"
         * 3 "<struct>/config/d/a/b/F"
         * 4 "<vds>/config/d/a/b/F"
         * etc.
         * If 'fileToFind' contains an absolute pathname then it is not
         * looked for in other directories.
	 * All Paths are defined with MAXPATHLEN.
 
   
  ARGUMENTS

	data type	argument 			I/O description

	IGRlong         *msg ;				Return Message.
	const char      *fileToFind		   	Name of filename.
	const char	*dirToSearchFirst		Sub-directory to check.
	const char      *dirInProdPathToSearchThen	Path to check with.
	char            *absPathName    		Path of the filename.

  STATUS RETURNS

	TRUE   : Success
	FALSE  : Failure

  ------------------------------------------------------------------------- */

#omdef vd$file_path(	msg,
		    	fileToFind,
		    	dirToSearchFirst,
			dirInProdPathToSearchThen,
		    	absPathName )

	VD_findFileInDirOrProductPaths( (msg), 
                        (fileToFind), (dirToSearchFirst),
                        (dirInProdPathToSearchThen), (absPathName) )

#endomdef

#endif
