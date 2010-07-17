
/* $Id: VRtracer.h,v 1.1.1.1 2001/01/04 21:12:55 cvs Exp $  */

/*************************************************************************
 * I/ROUTE
 *
 * File:        vrinclude/VRtracer.h
 *
 * Description:
 *
 *      Structure for general route network trace
 *
 * Dependencies:
 *
 * Revision History:
 *      $Log: VRtracer.h,v $
 *      Revision 1.1.1.1  2001/01/04 21:12:55  cvs
 *      Initial import to CVS
 *
 * Revision 1.1  1998/04/30  10:52:34  pinnacle
 * ROUTE 2.5.1
 *
 * Revision 1.1  1997/07/17  18:30:54  pinnacle
 * route 2.5
 *
 * Revision 1.2  1997/03/11  22:54:40  pinnacle
 * Replaced: vrinclude/VRtracer.h for:  by hverstee for route
 *
 * Revision 1.1  1997/03/11  17:13:08  pinnacle
 * Created: vrinclude/VRtracer.h by hverstee for route
 *
 *
 *
 * History:
 *      MM/DD/YY   AUTHOR       DESCRIPTION
 *
 *      03/07/97    hv          Initial
 *
 *************************************************************************/

#ifndef VRtracer_include
#define VRtracer_include

#define VRT_TRACE_INCBUF      100        /*   buffer increase    */
#define VRT_MAX_FANOUT         10        /*   maximum fanout     */
#define VRT_MAX_RECURSE      1000        /*   for safety, max recursion  */

/*    network trace data record         */

struct VR_tracerec
{
  struct GRid         Corr;      /* correction (NULL_OBJID at start and at
                                    records where the trace crosses into
                                    a reference file                      */
  struct GRid         Comp;      /* Next component along trace            */
         IGRshort     nCPfrom;   /* component connectpoint number in      */
         IGRshort     nCPto;     /* component connectpoint number out     */
         IGRshort     nBR;       /* branch number                         */
         IGRshort     iBack;     /* branch backtrace                      */
};

/*    tracer function prototypes        */

/*    next components along network     */

extern
IGRint  VR_cmp_nxt   __((IGRlong       *msg,
                  struct GRid          *CompIn,
                  struct GRid          *CompRef,
                         IGRshort      *nNum,
                         IGRshort      *nCPin,
                         IGRshort      *nCPout,
                  struct GRid          *CorrOut,
                  struct GRid          *CompOut));

/*    next components along network     */
/*            (inline)                  */

extern
IGRint  VR_cmp_thru  __((IGRlong       *msg,
                  struct GRid          *CompIn,
                  struct GRid          *CompRef,
                         IGRshort      *nNum,
                         IGRshort      *nCPin,
                         IGRshort      *nCPout,
                  struct GRid          *CorrOut,
                  struct GRid          *CompOut));

/*    next components along network     */
/*            (into reffile)            */

extern
IGRint  VR_cmp_upR   __((IGRlong       *msg,
                  struct GRid          *CompIn,
                         IGRshort      *nCPin,
                         IGRshort      *nCPout,
                  struct GRid          *CompOut));

/*    next components along network     */
/*          (out of reffile)            */

extern
IGRint  VR_cmp_dnR   __((IGRlong       *msg,
                  struct GRid          *CompIn,
                         IGRshort      *nNum,
                         IGRshort      *nCPin,
                         IGRshort      *nCPout,
                  struct GRid          *CompOut));

/*    general network tracer            */

extern
IGRint     VR_trace __((IGRlong      *msg,
                        IGRboolean    bSpath,
                 struct GRid         *ConId,
                        IGRshort      nConEnds,
                 struct GRid         *ConEnd,
                        IGRshort     *nTrac,
                 struct VR_tracerec **TracTab,
                        IGRboolean   *bBranched,
                 struct GRmd_env     *md_env));

/*          calling sequence                          */

/*  *msg,        O - return message                     */
/*   bSpath,     I - flag, look for single path         */
/*  *ConId,      I - start component for tracer         */
/*   nConEnds,   I - number of endpoints                */
/*  *ConEnd,     I - (optional) ends of trace           */
/*  *nTrac,      O - Number of records output           */
/* **TracTab,    O - Output trace table                 */
/*  *bBranched,  O - Flag, branched trace found         */
/*  *md_env)     I - environment                        */

#omdef VR$Tracer  (p_msg,
                   b_path = FALSE,
                   p_comp,
                   numends = 0,
                   p_ends  = NULL,
                   numout,
                   Tracetab,
                   p_Branched,
                   p_mdenv)

#if !om$specified (numout) || !om$specified (Tracetab)
#omerror "No output for trace table specified"
#else

VR_trace ((p_msg), ((IGRboolean)b_path),(p_comp),((IGRshort)numends),(p_ends), 
             ((IGRshort *)numout),((struct VR_tracerec **) Tracetab),
             ((IGRboolean *)p_Branched),(p_mdenv))
#endif

#endomdef

#endif

