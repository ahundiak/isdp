/* $Id: vdAPIequips.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/***************************************************************************
 * I/VDS
 *
 * File:	include/vdAPIequips.h
 *
 * Description:
 *
 * Dependencies:
 *
 * Revision History:
 *	$Log: vdAPIequips.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.3  1996/10/29  16:44:02  pinnacle
 * AH
 *
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	10/29/96	i-paris		creation date
 *
 ***************************************************************************/

#ifndef	vdAPIequips_include
#define	vdAPIequips_include

/* Define templates collector */
#define	VD_COL_NAM_LEN	80

#define	VD_COL_INIT	0x0001
#define	VD_COL_FREE	0x0002

#define	VD_COL_OBJID	0x0010
#define	VD_COL_MDENV	0x0020
#define	VD_COL_VALUE	0x0040
#define	VD_COL_TEXT	0x0080

#define	VD_COL_TYPE	0x0100
#define	VD_COL_CLASS	0x0200

struct	VDcollector
{
	IGRchar			name[VD_COL_NAM_LEN];
	IGRushort		prop;
	struct	GRobj_env	obj;
	IGRchar			txt[VD_COL_NAM_LEN];
	IGRdouble		val;
	IGRint			typ;
	struct	OM_sd_classlist	lst;
};

extern	IGRlong
VDcstCollector	__((	long			*msg,
			int			cnt,
			struct	VDcollector	**Col	)) ;

extern	IGRlong
VDsetCollector	__((	long			*msg,
			int			idx,
			struct	VDcollector	*Col,
			char			*Nam,
			struct	GRid		*Obj,
			struct	GRmd_env	*Env,
			double			*Val,
			char			*Txt,
			int			*Typ,
			IGRboolean		public	)) ;

extern	IGRlong
VDgetCollector	__((	long			*msg,
			int			idx,
			struct	VDcollector	*Col,
			char			*Nam,
			struct	GRid		*Obj,
			struct	GRmd_env	*Env,
			double			*Val,
			char			*Txt,
			struct	OM_sd_classlist	**Cla,
			IGRboolean		public	)) ;

extern	IGRlong
VDoutCollector	__((	int			Num,
			struct	VDcollector	*Col,
			char			*msg,
			IGRboolean		public	)) ;

/* ************************************************************************** */
/*+M
Macro	vd$collectorConstruct

Abstract
	This macro construct a VDcollector structure and initialize it.

Arguments
	OUT	long			*msg		Completion Code.
	IN	int			Num		Number of rows.
	IN	struct	VDcollector	**Col		Collector.

Notes
	* The macro returns OM_S_SUCCESS if successfull.
	  
	* 'msg' is equal to MSSUCC if successfull.

	* 'Num' is the number of rows wanted for 'Col'.

	* 'Col' is the collector to allocate and initialize. 
	  'Col' must be NULL or an error occurs.
	  The structure 'Col' must be deallocated by caller with om$dealloc().

-M*/
#omdef	vd$collectorConstruct	(	msg,
					Num,
					Col	)
	VDcstCollector ( (msg), (Num), (Col) );
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro	vd$collectorSetRow

Abstract
	This macro stores values in the collector's row.

Arguments
	OUT	long			*msg		Completion Code.
	IN	int			idx		Row's index.
	IN	struct	VDcollector	*Col		Collector.
	IN	char			*Nam		Row's name.
	IN	struct	GRid		*Obj		Row's object ID.
	IN	struct	GRmd_env	*Env		Row's environment.
	IN	double			*Val		Row's numeric value.
	IN	char			*Txt		Row's text.
	IN	int			*Typ		Row's attribute type.

Notes
	* The macro returns OM_S_SUCCESS if successfull.
	  
	* 'msg' is equal to MSSUCC if successfull.

	* 'idx' is the index of the row wanted in 'Col'.

	* 'Col' is the collector. 
	  'Col' must not be NULL or an error occurs.

	* 'Nam' is the stored name of the row.
	  Default is NULL.

	* 'Obj' is the stored object ID of the row.
	  Default is NULL.

	* 'Env' is the stored object environment of the row.
	  Default is NULL.

	* 'Val' is the stored numerical value of the row.
	  Default is NULL.

	* 'Txt' is the stored alphanumerical value of the row.
	  Default is NULL.

	* 'Typ' is used internaly for macro templates' types.
	  Default is NULL.

-M*/
#omdef	vd$collectorSetRow	(	msg,
					idx,
					Col,
					Nam	= NULL,
					Obj	= NULL,
					Env	= NULL,
					Val	= NULL,
					Txt	= NULL,
					Typ	= NULL	)
	VDsetCollector (	(msg),
				(idx),
				(Col),
				(Nam),
				(Obj),
				(Env),
				(Val),
				(Txt),
				(Typ),
				TRUE	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro	vd$collectorGetRow

Abstract
	This macro gets the stored values from collector's row.

Arguments
	OUT	long			*msg		Completion Code.
	IN	int			idx		Row's index.
	IN	struct	VDcollector	Col[]		Collector.
	OUT	char			*Nam		Row's name.
	OUT	struct	GRid		*Obj		Row's object ID.
	OUT	struct	GRmd_env	*Env		Row's environment.
	OUT	double			*Val		Row's numeric value.
	OUT	char			*Txt		Row's text.
	OUT	struct	OM_sd_classlist	**Cla		Eligible classes.

Notes
	* The macro returns OM_S_SUCCESS if successfull.
	  
	* 'msg' is equal to MSSUCC if successfull.

	* 'idx' is the index of the row wanted in 'Col'.

	* 'Col' is the collector. 
	  'Col' must not be NULL or an error occurs.

	* 'Nam' is the stored name of the row.
	  Default is NULL.

	* 'Obj' is the stored object ID of the row.
	  Default is NULL.

	* 'Env' is the stored object environment of the row.
	  Default is NULL.

	* 'Val' is the stored numerical value of the row.
	  Default is NULL.

	* 'Txt' is the stored alphanumerical value of the row.
	  Default is NULL.

	* 'Cla' can be used in ci$locate() to fill the 'eligible_classes'
	  entry.
	  Default is NULL.

-M*/
#omdef	vd$collectorGetRow	(	msg,
					idx,
					Col,
					Nam	= NULL,
					Obj	= NULL,
					Env	= NULL,
					Val	= NULL,
					Txt	= NULL,
					Cla	= NULL	)
	VDgetCollector (	(msg),
				(idx),
				(Col),
				(Nam),
				(Obj),
				(Env),
				(Val),
				(Txt),
				(Cla),
				TRUE	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro	vd$collectorPrint

Abstract
	This macro printout the rows of a VDcollector structure.

Arguments
	IN	int			Num		Number of rows.
	IN	struct	VDcollector	Col[]		Collector.
	IN	char			*msg		User message.

Notes
	* The macro returns OM_S_SUCCESS if successfull.

	* 'Num' is the number of rows wanted for 'Col'.

	* 'Col' is the collector. 
	  'Col' must not be NULL or an error occurs.

	* 'msg' is a message displayed in the header.
	  Default is NULL.

-M*/
#omdef	vd$collectorPrint	(	Num,
					Col,
					msg	= NULL	)
	VDoutCollector ( (Num), (Col), (msg), TRUE );
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro	vd$collectorFree

Abstract
	This macro free VDcollector structure.

Arguments
	IN	struct	VDcollector	Col[]		Collector.

-M*/
#omdef	vd$collectorFree	(	Col	)
	if (Col != NULL) {
		if (Col->lst.p_classes != NULL) {
			om$dealloc (ptr = Col->lst.p_classes);
			Col->lst.p_classes = NULL;
		}
		om$dealloc (ptr = Col);
		Col = NULL;
	}
#endomdef
/* ************************************************************************** */


#include	"COmdef.h"
#include	"acrepdef.h"
#include	"ACdb_info.h"

/* 1) Occurence type (for macro and equipment) */
#define	VD_OCC_CONS	HDR_CONS	/* Construction macro	*/
#define	VD_OCC_DROP	HDR_DROP	/* Drop macro		*/
#define	VD_OCC_SYMB	HDR_SYMB	/* Symbol macro		*/
#define	VD_OCC_GRAP	HDR_GRAPHIC	/* Non associative	*/

/* 2) Layer display type (for macro and equipment) */
#define VD_LAY_DEF	0		/* Definition		*/
#define VD_LAY_ACT	CHG_LAYER	/* Active		*/
#define VD_LAY_D_A	INCR_LAYER	/* Active + Definition	*/

/* 3) Color display type (for macro and equipment) */
#define VD_COL_DEF	0		/* Definition	*/
#define VD_COL_ACT	CHG_COLOR	/* Active	*/

/* 4) Weight display type (for macro and equipment) */
#define VD_WEI_DEF	0		/* Definition	*/
#define VD_WEI_ACT	CHG_WEIGHT	/* Active	*/

/* 5) Style display type (for macro and equipment) */
#define VD_STY_DEF	0		/* Definition	*/
#define VD_STY_ACT	CHG_STYLE	/* Active	*/

/* 6) One parent deleted property (for macro and equipment) */
#define	VD_ONE_NOT	0
#define	VD_ONE_YES	CHG_DONT_MVRT

/* 7) All chidren deleted property (for macro and equipment) */
#define	VD_ALL_NOT	0
#define	VD_ALL_YES	CHG_DEL_NO_CH

/* 8) VDS representation (for equipment only) */
#define	VD_ACT_REP	AC_VDS_REP	/* Active    representation	*/
#define	VD_SCH_REP	AC_2D_REP	/* Schematic representation	*/
#define	VD_DET_REP	AC_3D_REP	/* Detailed  representation	*/
#define	VD_ENV_REP	AC_ENV_REP	/* Enveloppe representation	*/

/* Define macro construction type (internal) */
#define exp_grap 0x03
#define exp_symb 0x02
#define exp_drop 0x01
#define exp_cons 0x00
#define sym_sym  0x12
#define ci_cons  0x20
#define ci_sym   0x22
#define ci_grap  0x23

struct	VDdescriptor
{
		IGRchar		MacLib[VD_COL_NAM_LEN];
		IGRchar		MacNam[VD_COL_NAM_LEN];
	struct	GRid		MacDef;
	enum	ACm_poss_hdr	HdrTyp;
	enum	poss_macro	MacTyp;
		IGRint		HdrSym;
		IGRint		prop;
	struct	GRid		StaBox;
	struct	ACdb_info	DbInfo;
};

/* Window names for vd$createCoordinateSystem(). */
#define	VD_WIN_NOT_NAM	0	/* No defined type	*/
#define	VD_WIN_TOP_NAM	1	/* Top window		*/
#define	VD_WIN_BOT_NAM	2	/* Bottom window	*/
#define	VD_WIN_RIG_NAM	3	/* Right window		*/
#define	VD_WIN_LEF_NAM	4	/* Left window		*/

#include	"macro.h"

extern	long
VDcreateCS		__((	long			*msg,
				double			*Cpnt,
				double			*Xvec,
				double			*Yvec,
				int			Wname,
				double			*matrix,
				char			*name,
				struct	GRobj_env	*CS		)) ;

extern	long
VDgetCollectorFromMacroDef	__((	long			*msg,
					char			*MacLib,
					char			*MacDef,
					int			*TplNum,
					struct	VDcollector	**TplCol )) ;

extern	long
VDgetCollectorFromEquipDef	__((	long			*msg,
					char			*CatName,
					char			*PartNum,
					char			*RevName,
					int			*TplNum,
					struct	VDcollector	**TplCol,
					int			*DynNum,
					struct	VDcollector	**DynCol )) ;

extern  long
VDplaceMacroOrEquip     __((    long                    *msg,
				char			*MacLib,
				char			*MacDef,
				char			*CatName,
				char			*PartNum,
				char			*RevName,
                                int                     TplNum,
                                struct  VDcollector     *TplCol,
                                int                     DynNum,
                                struct  VDcollector	*DynCol,
				enum	ACm_poss_hdr	Htyp,
                                int                     rep,
                                int                     layer,
                                int                     color,
                                int                     weight,
                                int                     style,
                                int                     delOne,
                                int                     delAll,
                                char                    *DirPath,
                                char                    *RootName,
				int			prop,
                                struct  GRid            *OccId  )) ;

extern	long
VDgetCollectorFromMacroOcc	__((	long			*msg,
					struct	VDcollector	*OccCol,
					int			*TplNum,
					struct	VDcollector	**TplCol )) ;

extern	long
VDmodifyMacro	__((	long			*msg,
			struct	VDcollector	*OccCol,
			int			TplNum,
			struct	VDcollector	TplCol[],
			int			immediate )) ;

extern	long
VDgetCollectorFromEquipOcc	__((	long			*msg,
					struct	VDcollector	*OccCol,
					int			*TplNum,
					struct	VDcollector	**TplCol,
					int			*DynNum,
					struct	VDcollector	**DynCol )) ;

extern	long
VDmodifyEquip	__((	long			*msg,
			struct	VDcollector	*OccCol,
			int			TplNum,
			struct	VDcollector	TplCol[],
			int			DynNum,
			struct	VDcollector	DynCol[],
			int			immediate )) ;

/* ************************************************************************** */
/*+M
Macro	vd$createCoordinateSystem

Abstract
	This macro creates a coordinate system from various infos.

Arguments
	OUT	long			*msg		Completion code.
	IN	double			*Cpnt		Center point.
	IN	double			*Xvec		X direction vector.
	IN	double			*Yvec		Y direction vector.
	IN	int			Wname		Window type.
	IN	double			*matrix		CS matrix.
	IN	char			*name		CS name.
	OUT	struct	GRobj_env	*CS		Resulting object.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'Cpnt' is the center point xyz coordinates.
	  Default is NULL.

	* 'Xvec' is the X direction vector xyz coordinates.
	  Default is NULL.

	* 'Yvec' is the Y direction vector xyz coordinates.
	  Default is NULL.

	* 'Wname' is the EMS window type (cf vdmacrodef.h).
	  Default is VD_WIN_NOT_NAM.

	* 'matrix' is the CS matrix.
	  It's a 4x4 matrix : 	X1 Y1 Z1 C1
				X2 Y2 Z2 C2
				X3 Y3 Z3 C3
				0  0  0  1
		where : [X1,X2,X3] are the X direction vector coordinates.
			[Y1,Y2,Y3] are the Y direction vector coordinates.
			[Z1,Z2,Z3] are the Z direction vector coordinates.
			[C1,C2,C3] are the C center point coordinates.
	  Default is NULL.

	* 'name' is the name given to the constructed coordinate system.
	  Default is NULL.

	* 'CS' is constructed coordinate system.
	  Default is NULL.

-M*/
#omdef	vd$createCoordinateSystem	(	msg,
						Cpnt	= NULL,
						Xvec	= NULL,
						Yvec	= NULL,
						Wname	= VD_WIN_NOT_NAM,
						matrix	= NULL,
						name	= NULL,
						CS	= NULL	)

	VDcreateCS (	(msg),
		     	(Cpnt),
		     	(Xvec),
		     	(Yvec),
		     	(Wname),
		     	(matrix),
		     	(name),
		     	(CS)	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro	vd$getMacDefCollector

Abstract
	This macro retrieve the collector of templates from a macro definition.
	It must be used before calling vd$place_macro().

Arguments
	OUT	long			*msg		Completion code.
	IN	char			*MacLib		Macro library name.
	IN	char			*MacDef		Macro definition name.
	OUT	int			*TplNum		Number of templates.
	OUT	struct	VDcollector	**TplCol	Collector of templates.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'MacLib' is the macro library name.
	  It can be NULL or equal to "". In that case the first macro called
	  'MacDef' is taken.
	  If not NULL, 'MacLib' is attached to the design file.
	  Default is NULL.

	* 'MacDef' is the macro definition name.

	* 'TplNum' is the number of templates of the macro definition.
	  In the case of variable templates macros this is the maximum number
	  of templates.
	  Default is NULL.

	* 'TplCol' is the array of templates of the macro definition.
	  This collector returned contains the macro templates info.
	  It can be displayed with vd$collectorPrint().
	  The others field are initialized :
	  User have to fill this collector with vd$collectorSetRow() before
	  calling vd$place_macro().
	  The returned collector MUST be deallocated with vd$collectorFree().
	  'TplNum' or 'TplCol' must be non NULL to get a result.
	  Default is NULL.

-M*/
#omdef	vd$getMacDefCollector	(	msg,
					MacLib	= NULL,
					MacDef,
					TplNum	= NULL,
					TplCol	= NULL	)

	VDgetCollectorFromMacroDef (	(msg),
					(MacLib),
					(MacDef),
					(TplNum),
					(TplCol)	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro   vd$place_macro

Abstract
        This macro place a macro occurence.

Arguments
        OUT     long                    *msg            Completion code.
	IN	char			MacLib		Macro Library.
	IN	char			MacDef		Macro Definition.
        IN      int                     TplNum          Templates number.
        IN      struct  VDcollector     *TplCol         Templates collector.
	IN	enum	ACm_poss_hdr	OccTyp		Macro Occurence type.
        IN      int                     layer           Occurence layer.
        IN      int                     color           Occurence color.
        IN      int                     weight          Occurence weight.
        IN      int                     style           Occurence style.
        IN      int                     delOne          Delete when one del.
        IN      int                     delAll          Delete when all del.
        IN      char                    *DirPath        Directory path.
        IN      char                    *RootName       Occurence root name.
        OUT     struct  GRid            *OccId          Occurence object.

Notes
        * The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'MacLib' is the macro library name.
	  It can be NULL or equal to "". In that case the first macro called
	  'MacDef' is taken.
	  If not NULL, 'MacLib' is attached to the design file.
	  Default is NULL.

	* 'MacDef' is the macro definition name.

        * 'TplNum' is the number of templates of the macro.
	  It must be inferior or equal to the maximum number of templates
	  returned by vd$getMacDefCollector().

        * 'TplCol' is the collector of templates of the macro.
	  Use vd$getMacDefCollector() to get it.
	  Fill it with templates info, using vd$collectorSetRow().

	* 'OccTyp' is the macro occurence type (see vdmacdef.h #1).
          Default is VD_OCC_CONS.

	* 'layer' is the macro occurence layer type (see vdmacdef.h #2).
          Default is VD_LAY_DEF.

        * 'color' is the macro occurence color type (see vdmacdef.h #3).
          Default is VD_COL_DEF.

        * 'weight' is the macro occurence weight type (see vdmacdef.h #4).
          Default is VD_WEI_DEF.

        * 'style' is the macro occurence style type (see vdmacdef.h #5).
          Default is VD_STY_DEF.

        * 'delOne' defined if macro occurence delete itself when one parent
          is deleted (see vdmacdef.h #6).
          Default is VD_ONE_NOT.

        * 'delAll' defined if macro occurence delete itself when all children
          are deleted (see vdmacdef.h #7).
          Default is VD_ALL_NOT.

        * 'DirPath' defined the absolute directory path where the macro
          occurence will be named.
                NULL or "" :    The local directory path is taken.
                "name"     :    The subdirectory "<localpath>:name" is taken.
                ":name"    :    The directory ":<filename>:name" is taken.
                note : "name" can be for example "A:B:C".
                       ":name" can be for example ":A:B:C".
          Default is NULL.

        * 'RootName' defined the root name of the macro occurence.
          If the macro occurence is named it will be ROOT_NAME_###, where ###
          will be a 3 digits incremental number.
                NULL   : 'MacName' is taken as root name.
                ""     : No naming.
                other  : 'RootName' is taken as root name.

        * 'OccId' is the ID of the macro occurence returned from Object Manager.
          Default is NULL. No returned ID.

-M*/
#omdef	vd$place_macro  (       msg,
				MacLib		= NULL,
				MacDef,
                                TplNum,
                                TplCol,
				OccTyp		= VD_OCC_CONS,
                                layer           = VD_LAY_DEF,
                                color           = VD_COL_DEF,
                                weight          = VD_WEI_DEF,
                                style           = VD_STY_DEF,
                                delOne          = VD_ONE_NOT,
                                delAll          = VD_ALL_NOT,
                                DirPath         = NULL,
                                RootName        = NULL,
                                OccId           = NULL  )

        VDplaceMacroOrEquip     (       (msg),
                                        (MacLib),
                                        (MacDef),
					NULL,
					NULL,
					NULL,
                                        (TplNum),
                                        (TplCol),
                                        0,
                                        NULL,
                                        (OccTyp),
                                        NULL,
                                        (layer),
                                        (color),
                                        (weight),
                                        (style),
                                        (delOne),
                                        (delAll),
                                        (DirPath),
                                        (RootName),
					AChdr_nodisplay,
                                        (OccId) );
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro	vd$getEqpDefCollector

Abstract
	This macro retrieve the collector of templates and the collector of
	attributes from an equipment definition.
	It must be used before calling vd$place_equip().

Arguments
	OUT	long			*msg		Completion code.
	IN	char			*CatName	PDM catalog name.
	IN	char			*PartNum	PDM part number.
	IN	char			*RevName	PDM revision name.
	OUT	int			*TplNum		Number of templates.
	OUT	struct	VDcollector	**TplCol	Collector of templates.
	OUT	int			*DynNum		Number of attributes.
	OUT	struct	VDcollector	**DynCol	Collector of attributes.

Notes
	* The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'CatName' is the PDU catalog name.

	* 'PartNum' is the PDU part number.

	* 'RevName' is the PDU revision name.

	* 'TplNum' is the maximum number of templates of the macro definition.

	* 'TplCol' is the array of templates of the equipment macro definition.
	  This collector returned contains the equipment macro templates info.
	  It can be displayed with vd$collectorPrint().
	  The returned collector MUST be deallocated with vd$collectorFree().
	  'TplNum' or 'TplCol' must be non NULL to get a result.
	  Default is NULL.

	* 'DynNum' is the number of dynamic attributes.

	* 'DynCol' is the collector of dynamic attributes.
	  It can be displayed with vd$collectorPrint().
	  The returned collector MUST be deallocated with vd$collectorFree().
	  'DynNum' or 'DynCol' must be non NULL to get a result.
	  Default is NULL.

-M*/
#omdef	vd$getEqpDefCollector	(	msg,
					CatName,
					PartNum,
					RevName,
					TplNum,
					TplCol,
					DynNum,
					DynCol	)

	VDgetCollectorFromEquipDef (	(msg),
					(CatName),
					(PartNum),
					(RevName),
					(TplNum),
					(TplCol),
					(DynNum),
					(DynCol)	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro   vd$place_equip

Abstract
        This macro place a VDS equipment occurence.

Arguments
        OUT     long                    *msg            Completion code.
	IN	char			*CatName	PDM catalog name.
	IN	char			*PartNum	PDM part number.
	IN	char			*RevName	PDM revision name.
        IN      int                     TplNum          Templates number.
        IN      struct  VDcollector     *TplCol         Templates collector.
        IN      int                     DynNum          Dyn. attr. number.
        IN      struct  VDcollector     *DynCol         Dyn. attr. collector.
	IN	enum	ACm_poss_hdr	OccTyp		Macro Occurence type.
	IN      int                     rep             VDS representation.
        IN      int                     layer           Occurence layer.
        IN      int                     color           Occurence color.
        IN      int                     weight          Occurence weight.
        IN      int                     style           Occurence style.
        IN      int                     delOne          Delete when one del.
        IN      int                     delAll          Delete when all del.
        IN      char                    *DirPath        Directory path.
        IN      char                    *RootName       Occurence root name.
        OUT     struct  GRid            *OccId          Occurence object.

Notes
        * The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'CatName' is the PDU catalog name.

	* 'PartNum' is the PDU part number.

	* 'RevName' is the PDU revision name.

        * 'TplNum' is the number of templates of the macro.
	  It must be inferior or equal to the maximum number of templates
	  returned by vd$getEqpDefCollector().

        * 'TplCol' is the collector of templates of the macro.
	  The macro definition used for equipments is a variable templates one.
	  Use vd$getEqpDefCollector() to get it.
	  Use vd$collectorSetRow() to modify it.

        * 'DynNum' is the number of dynamic attributes of the macro.
	  It must be equal to number of dynamic attributes returned by
	  vd$getEqpDefCollector().

        * 'DynCol' is the collector of dynamic attributes of the macro.
	  Use vd$getEquipCollector() to get it.
	  Use vd$collectorSetRow() to modify it.

	* 'OccTyp' is the macro occurence type (see vdmacdef.h #1).
          Default is VD_OCC_SYMB.

	* 'rep' is the VDS representation (see vdmacdef.h #8).
          Default is VD_ACT_REP.

	* 'layer' is the macro occurence layer type (see vdmacdef.h #2).
          Default is VD_LAY_DEF.

        * 'color' is the macro occurence color type (see vdmacdef.h #3).
          Default is VD_COL_DEF.

        * 'weight' is the macro occurence weight type (see vdmacdef.h #4).
          Default is VD_WEI_DEF.

        * 'style' is the macro occurence style type (see vdmacdef.h #5).
          Default is VD_STY_DEF.

        * 'delOne' defined if macro occurence delete itself when one parent
          is deleted (see vdmacdef.h #6).
          Default is VD_ONE_NOT.

        * 'delAll' defined if macro occurence delete itself when all children
          are deleted (see vdmacdef.h #7).
          Default is VD_ALL_NOT.

        * 'DirPath' defined the absolute directory path where the macro
          occurence will be named.
                NULL or "" :    The local directory path is taken.
                "name"     :    The subdirectory "<localpath>:name" is taken.
                ":name"    :    The directory ":<filename>:name" is taken.
                note : "name" can be for example "A:B:C".
                       ":name" can be for example ":A:B:C".
          Default is NULL.

        * 'RootName' defined the root name of the macro occurence.
          If the macro occurence is named it will be ROOT_NAME_###, where ###
          will be a 3 digits incremental number.
                NULL   : 'MacName' is taken as root name.
                ""     : No naming.
                other  : 'RootName' is taken as root name.

        * 'OccId' is the ID of the macro occurence returned from Object Manager.
          Default is NULL. No returned ID.

-M*/
#omdef	vd$place_equip  (       msg,
				CatName,
				PartNum,
				RevName,
                                TplNum,
                                TplCol,
                                DynNum,
                                DynCol,
				OccTyp		= VD_OCC_SYMB,
				rep		= VD_ACT_REP,
                                layer           = VD_LAY_DEF,
                                color           = VD_COL_DEF,
                                weight          = VD_WEI_DEF,
                                style           = VD_STY_DEF,
                                delOne          = VD_ONE_NOT,
                                delAll          = VD_ALL_NOT,
                                DirPath         = NULL,
                                RootName        = NULL,
                                OccId           = NULL  )

        VDplaceMacroOrEquip     (       (msg),
                                        (NULL),
                                        (NULL),
                                        (CatName),
                                        (PartNum),
                                        (RevName),
                                        (TplNum),
                                        (TplCol),
                                        (DynNum),
                                        (DynCol),
                                        (OccTyp),
                                        (rep),
                                        (layer),
                                        (color),
                                        (weight),
                                        (style),
                                        (delOne),
                                        (delAll),
                                        (DirPath),
                                        (RootName),
					AChdr_nodisplay,
                                        (OccId) );
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro   vd$getMacOccCollector

Abstract
	This macro retrieve the collector of templates from a macro occurence.
	It must be used before calling vd$modify_macro().

Arguments
        OUT     long                    *msg            Completion code.
	IN	struct	VDcollector	*OccCol		Macro occurence.
	OUT	int			*TplNum		Number of templates.
	OUT	struct	VDcollector	**TplCol	Collector of templates.

Notes
        * The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'OccCol' is the macro occurence VDcollector.

	* 'TplNum' is the number of templates of the macro occurence.

	* 'TplCol' is the array of templates of the macro occurence.
	  It must be free by caller with vd$collectorFree().

-M*/
#omdef	vd$getMacOccCollector	(	msg,
					OccCol,
					TplNum,
					TplCol	)

	VDgetCollectorFromMacroOcc (	(msg),
					(OccCol),
					(TplNum),
					(TplCol)	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro   vd$modify_macro

Abstract
	This macro modify a macro occurence.

Arguments
        OUT     long                    *msg            Completion code.
	IN	struct	VDcollector	*OccCol		Macro occurence.
	IN	int			TplNum		Number of templates.
	IN	struct	VDcollector	TplCol[]	Collector of templates.
	IN	int			immediate	Immediate modif. flag.

Notes
        * The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'OccCol' is the macro occurence VDcollector.
	  cf vd$getMacOccCollector() for more explanation.

	* 'TplNum' is the number of elements of the VDcollector 'TplCol'.
	  It comes from vd$getMacOccCollector() and don't have to be modified.

	* 'TplCol' is the templates' VDcollector. 
	  It comes from vd$getMacOccCollector() and have to be modified.
	  It must be free by caller with vd$collectorFree().

	* 'immediate' is a flag to execute immediatly the modification.
	  If set to FALSE user have to call himself nd$exec_batch().
	  Default is TRUE.

-M*/
#omdef	vd$modify_macro	(	msg,
				OccCol,
				TplNum,
				TplCol,
				immediate	= TRUE	)

	VDmodifyMacro (		(msg),
				(OccCol),
				(TplNum),
				(TplCol),
				(immediate)	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro   vd$getEqpOccCollector

Abstract
	This macro retrieve the collector of templates and the collector of
	dynamic attributes of a VDS equipment occurence.
	It must be used before calling vd$modify_equip().

Arguments
        OUT     long                    *msg            Completion code.
	IN	struct	VDcollector	*OccCol		Equipment occurence.
	OUT	int			*TplNum		Number of templates.
	OUT	struct	VDcollector	**TplCol	Collector of templates.
	OUT	int			*DynNum		Number of attributes.
	OUT	struct	VDcollector	**DynCol	Collector of attributes.

Notes
        * The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'OccCol' is the macro occurence VDcollector.

	* 'TplNum' is the number of templates of the equipment occurence.

	* 'TplCol' is the array of templates of the equipment occurence.
	  It must be free by caller with vd$collectorFree().

	* 'DynNum' is the number of dynamic attributes of the equipment
	  occurence.

	* 'DynCol' is the array of dynamic attributes of the equipment
	  occurence.
	  It must be free by caller with vd$collectorFree().

-M*/
#omdef	vd$getEqpOccCollector	(	msg,
					OccCol,
					TplNum,
					TplCol,
					DynNum,
					DynCol	)

	VDgetCollectorFromEquipOcc (	(msg),
					(OccCol),
					(TplNum),
					(TplCol),
					(DynNum),
					(DynCol)	);
#endomdef
/* ************************************************************************** */

/* ************************************************************************** */
/*+M
Macro   vd$modify_equip

Abstract
	This macro modify a VDS equipment.

Arguments
        OUT     long                    *msg            Completion code.
	IN	struct	VDcollector	*OccCol		Equipment occurence.
	IN	int			TplNum		Number of templates.
	IN	struct	VDcollector	TplCol[]	Collector of templates.
	IN	int			TplNum		Number of attributes.
	IN	struct	VDcollector	TplCol[]	Collector of attributes.
	IN	int			immediate	Immediate modif. flag.

Notes
        * The macro returns MSSUCC if succesfull or MSFAIL if an error
          occur in argument 'msg'.

	* 'OccCol' is the macro occurence VDcollector.
	  cf vd$getEqpOccCollector() for more explanation.

	* 'TplNum' is the number of elements of the VDcollector 'TplCol'.
	  It comes from vd$getEqpOccCollector() and don't have to be modified.

	* 'TplCol' is the templates' VDcollector. 
	  It comes from vd$getEqpOccCollector() and have to be modified.
	  It must be free by caller with vd$collectorFree().

	* 'DynNum' is the number of elements of the VDcollector 'DynCol'.
	  It comes from vd$getEqpOccCollector() and don't have to be modified.

	* 'DynCol' is the dynamic attributes' VDcollector. 
	  It comes from vd$getEqpOccCollector() and have to be modified.
	  It must be free by caller with vd$collectorFree().

	* 'immediate' is a flag to execute immediatly the modification.
	  If set to FALSE user have to call himself nd$exec_batch().
	  Default is TRUE.

-M*/
#omdef	vd$modify_equip	(	msg,
				OccCol,
				TplNum,
				TplCol,
				DynNum,
				DynCol,
				immediate	= TRUE	)

	VDmodifyEquip (		(msg),
				(OccCol),
				(TplNum),
				(TplCol),
				(DynNum),
				(DynCol),
				(immediate)	);
#endomdef
/* ************************************************************************** */

#endif	vdAPIequips_include
