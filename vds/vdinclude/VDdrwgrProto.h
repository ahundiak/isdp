/* $Id: VDdrwgrProto.h,v 1.1.1.1 2001/01/04 21:08:51 cvs Exp $  */

/* I/VDS
 *
 * File:	vdinclude/VDdrwgrProto.h
 *
 * Description:
 *
 * Dependencies:
 *	$Log: VDdrwgrProto.h,v $
 *	Revision 1.1.1.1  2001/01/04 21:08:51  cvs
 *	Initial import to CVS
 *	
 * Revision 1.1  1998/04/29  16:27:20  pinnacle
 * VDS 2.5.1
 *
 * Revision 1.1  1997/05/08  13:20:44  pinnacle
 * New project VDS 250
 *
 * Revision 1.1  1996/07/19  20:33:52  pinnacle
 * Create VDS 241 project
 *
 * Revision 1.1  1995/03/08  22:15:58  pinnacle
 * Created: vdinclude/VDdrwgrProto.h by azuurhou r#
 * rno
 *
 *
 * History:
 *	MM/DD/YY	AUTHOR		DESCRIPTION
 *	03/08/95	mf		creation date
 */

#if defined(__STDC__) || defined(__cplusplus)
#ifndef __
#define __(args) args
#endif
#else
#ifndef __
#define __(args) ()
#endif
#endif

#if defined(__cplusplus)
extern "C" {
#endif

/* VDdrwgrFunk.I */
IGRint VDdrwgrSortLineText __((struct VDdrwlo_apifix *a, struct VDdrwlo_apifix *b));
IGRboolean VDdrwgrSameSymbology __((struct VDdrwlo_apifix *a, struct VDdrwlo_apifix *b));
IGRint VDdrwgrSameGeometry __((struct VDdrwlo_apifix *a, struct VDdrwlo_apifix *b));
void VDdrwgrReduceLineData __((IGRint type, struct VDdrwlo_apifix *Data, IGRint idx1, IGRint idx2, struct VDdrwlo_apifix *Redu));
IGRlong VDdrwgrLineAssembler __((IGRint *nData, struct VDdrwlo_apifix *Data));
IGRlong VDdrwgrSymbMatching __((IGRint nLine, struct VDdrwlo_apifix *Line, IGRint *nSymb, IGRint **Index));
IGRlong VDdrwgrMinLinNumber __((IGRint *nData, struct VDdrwlo_apifix *Data, IGRlong *msg));
IGRlong VDdrwgrCreateLineText __((IGRint nData, struct VDdrwlo_apifix *Data, struct GRmd_env *Env, struct GRid *Csys, IGRdouble Zgap, IGRboolean Lopt, IGRint *nLine, struct GRid **Line, IGRint *nText, struct GRid **Text, IGRlong *msg));

#if defined(__cplusplus)
}
#endif

