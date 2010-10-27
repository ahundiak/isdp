/* $Id: VDexpproto.h,v 1.1.1.1 2001/01/04 21:07:31 cvs Exp $  */

/*************************************************************************
 * I/_product
 *
 * File:	include/prototypes/ VDexpproto.h
 *
 * Description:
 *	Prototypes for attribute expression interpreter
 *
 * Dependencies:
 *	v_slcdef.h
 *
 * Revision History:
 *	$Log: VDexpproto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:07:31  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.2  1997/12/02  23:02:36  pinnacle
 * Replaced: include/prototypes/VDexpproto.h for:  by mdong for vds
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.7  1996/06/08  00:04:54  pinnacle
 * Replaced: include/prototypes/VDexpproto.h for:  by tlbriggs for vds.240
 *
 * Revision 1.6  1996/04/22  15:19:04  pinnacle
 * Replaced: include/prototypes/VDexpproto.h for:  by tlbriggs for vds.240
 *
 * Revision 1.5  1995/10/13  08:53:36  pinnacle
 * Replaced: include/prototypes/VDexpproto.h for:  by tlbriggs for vds.240
 *
 * Revision 1.4  1995/09/17  00:01:58  pinnacle
 * Replaced: include/prototypes/VDexpproto.h for:  by tlbriggs for vds.240
 *
 * Revision 1.3  1995/08/21  19:00:00  pinnacle
 * Replaced: include/prototypes/VDexpproto.h for:  by tlbriggs for vds.240
 *
 * Revision 1.2  1995/07/27  23:21:38  pinnacle
 * Replaced: include/prototypes/VDexpproto.h for:  by tlbriggs for vds.240
 *
 * Revision 1.1  1995/07/21  19:57:10  pinnacle
 * Created: include/prototypes/VDexpproto.h by tlbriggs for vds.240
 *
 *
 * History:
 *	7/1/95	  tlb		created
 *	7/24/95   tlb		Add verbose: expConcatenate, expLogOp, expIsTrue
 *				Delete: expLogOp, exRelOp, exUnaryOp
 *	08/21/95  tlb		Update
 *	10/12/95  tlb		Add new functions
 *	04/20/96  tlb		Add expFuncUConc, expFuncAssmSelect, 
 *					expEvalMacroName
 *
 *************************************************************************/
#ifndef v_expproto_include
#	define v_expproto_include

#       include <standards.h>
#	include "v_slc.h"


/* ----- VDexpError.C -------------------------*/
void
VD_expReportError 	__((	int		pos,
				VD_execRes	*res,
				char		*fmt,
						...	));
void
VD_expSyntaxError 	__((	int		pos,
				VD_execRes	*res,
				char		*fmt,
						...	));

/* ----- VDexpMisc.C -------------------------*/

extern int
VD_expCheckListMode 	__((	char * 		name,
				int		pos,
				VD_execRes	*res	));
extern int
VD_expMakeArgList 	__((	VD_drwArgLst  		*list,
		   		int 			*num_arg,
		   		void			***arg_list,
		   		int			**arg_size	));

extern int	
VD_expStrncat 		__((	char *		str,
				VD_execRes	exp,
				int		*trunc	));

extern void
VD_expSwitchSexpr 	__((	int	num_objs, 
				int	*pos,		
				char	**sexpr		));

extern void
VD_expResetSexpr 	__((	int	pos,		
				char	*sexpr		));


/* ----- VDexpOp.C -------------------------*/
extern void
VD_expOpInit 		__((	VD_execRes      *res    ));

extern void
VD_expNoEval 		__((	VD_execRes 	* res 	));

extern int
VD_expLogOP		__(( 	long		*msg,
				int		op,
				VD_execRes	*arg1,
				VD_execRes	*res 	));
extern void
VD_expFileName 		__(( VD_execRes	*res ));

extern void
VD_expUnitConst 	__((	char 			* unit,
				const VD_execRes	*arg,
				VD_execRes		*res ));

extern int
VD_expUnitConv	 	__((	char 			* unit,
				int			pos,
				const VD_drwArgLst	*list,
		   		VD_execRes		*res ));

extern int
VD_expGetConvUnit 	__(( 	char 			* unit,
		 		double			value,
		 		VD_execRes		*res	));
extern void
VD_expSetTrue 		__(( 	VD_execRes      		*res	));

extern int
VD_expIsTrue 		__((	VD_execRes		*res	));

/* ----- VDexpPrint.C --------------------------*/
extern void
VD_expPrintObjHdr	__((struct GRobj_env	obj_env,
			    	int		num_objs 	));

extern void
VD_expPrintObjList	__((	int  			num_objs,
				struct GRobj_env	*objList	));
extern void
VD_expPrintError 	__((  	int			pos,
	 			VD_execRes		*res	));
extern void
VD_expPrintWarn 	__((	char 			*str	));

extern void
VD_expPrintAttr 	__((	VD_execRes	*attr, 
		 		VD_execRes	*res	));

extern void
VD_expPrintLinePrefix 	__((  		));


/* ----- VDexpKeyWord.C --------------------------- */
extern int
VD_expFuncInit 		__(( 	void 	));

extern int
VD_expDynFuncInit 	__(( 	void 	));

extern int
VD_expAddDynFunc 	__(( char * 		name,
		   		VD_expFunc_t  	func,
		   		int		num_args,
		   		short		is_fixed,
		   		short		list_mode	));
extern int
VD_expIsFunction 	__(( 	char 		*name,
				int		*tok,
				int		*index		));

extern void
VD_expCallFunction 	__(( 	const VD_execRes	*func,
				int			pos,
	 			VD_drwArgLst		*list,
    				VD_execRes		*res	));

/* ----- VDexpLex.l --------------------------- */
extern void
VD_expLexInit 		__((	));


/* ----- VDexpFunc.C ------------------------------*/
extern void
VD_expFuncMax 		__((	const VD_drwArgLst 	*list,
				int			pos,
				VD_execRes 		*res	));
extern void
VD_expFuncMin 		__((	const VD_drwArgLst 	*list,
				int			pos,
				VD_execRes 		*res	));
extern void
VD_expFuncSum 		__((	const VD_drwArgLst 	*list,
				int			pos,
				VD_execRes 		*res	));
extern void
VD_expFuncConc 		__((	const VD_drwArgLst 	*list,
				int			pos,
				VD_execRes 		*res	));
extern void
VD_expFuncUConc		__((	const VD_drwArgLst 	*list,
				int			pos,
				VD_execRes 		*res	));
extern void
VD_expFuncUnique	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    			VD_execRes		*res	));
extern void
VD_expFuncFirst 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	 		VD_execRes		*res	));
extern void
VD_expFuncQuote 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	 		VD_execRes		*res	));
extern void
VD_expFuncTrunc 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	 		VD_execRes		*res	));
extern void
VD_expFuncRound 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	 		VD_execRes		*res	));
extern void
VD_expFuncDecimal 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	 		VD_execRes		*res	));

extern void
VD_expFuncFtin2         __((    const VD_drwArgLst      *list,
                                int                     pos,
                                VD_execRes              *res    ));

extern void
VD_expFuncFtin4         __((    const VD_drwArgLst      *list,
                                int                     pos,
                                VD_execRes              *res    ));

extern void
VD_expFuncFtin8         __((    const VD_drwArgLst      *list,
                                int                     pos,
                                VD_execRes              *res    ));

extern void
VD_expFuncFtin16        __((    const VD_drwArgLst      *list,
                                int                     pos,
                                VD_execRes              *res    ));

extern void
VD_expFuncFtin32        __((    const VD_drwArgLst      *list,
                                int                     pos,
                                VD_execRes              *res    ));

extern void
VD_expFuncFtin64        __((    const VD_drwArgLst      *list,
                                int                     pos,
                                VD_execRes              *res    ));

extern void
VD_expFuncModulo 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	 		VD_execRes		*res	));
extern void
VD_expFuncPplFile 	__((	const VD_drwArgLst 	*list,
				int			pos,
				VD_execRes 		*res	));
extern void
VD_expFuncPplFunc 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	     		VD_execRes		*res	));

extern void
VD_cvrtFrmt             __((    const VD_execRes        *Val,
                                double                  factor,
                                VD_execRes              *res    ));

/* ----- VDexpDb.C -------------------------*/
extern void
VD_expDbSelect 		__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	     		VD_execRes		*res	));
extern void
VD_expDbDynSelect 	__(( 	const VD_drwArgLst	*list,
				int			pos,
	    	     		VD_execRes		*res	));

/* ----- VDexpObj.I -------------------------*/
extern void
VD_expObjInit 		__(( 	int			*num_objs,
				struct GRobj_env 	*Obj	));
extern void
VD_expObjId 		__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjOsnum 		__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjName 		__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjMacroName 	__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjFile 		__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjCurFile	__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjDynTable 	__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjPdmId 		__((	struct GRobj_env 	obj_env,
				int			pos,
				VD_execRes 		*res 	));
extern void
VD_expObjPrintAttr 	__(( 	struct GRobj_env   	obj,
				int			pos,
				VD_execRes		*res	));

extern void
VD_expObjAttr 		__(( 	struct GRobj_env   	obj,
				VD_execRes		*attr,
				int			pos,
				VD_execRes		*res  	));
extern void
VD_expObjCodedAttr	__(( 	struct GRobj_env   	obj,
				VD_execRes		*attr,
				int			pos,
				VD_execRes		*res,
				int			is_long_flag  	));

#endif
