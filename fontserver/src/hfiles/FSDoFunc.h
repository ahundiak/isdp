/* 
 * File:   FSDoFunc.h
 * Author: impd
 *
 * Created on March 25, 2010, 11:12 AM
 */

#ifndef _FSDOFUNC_H
#define	_FSDOFUNC_H

#include "../hfiles/FSDef.h"

extern  int     _FSDoAdd(Real **stack);
extern  int     _FSDoSub(Real **stack);
extern  int     _FSDoMul(Real **stack);
extern  int     _FSDoDiv(Real **stack);
extern  int     _FSDoPrint(Real **stack);
extern  int     _FSDoFixR(Real **stack);
extern  int     _FSDoFix(Real **stack);
extern  int     _FSDoCO(Real **stack);
extern  int     _FSDoCF(Real **stack);
extern  int     _FSDoRRFS(Real **stack);
extern  int     _FSDoRRFS1(Real **stack);
extern  int     _FSDoRRHS(Real ** stack);
extern  int     _FSDoRRHS1(Real **stack);
extern  int     _FSDoBZON(Real **stack);
extern  int     _FSDoBZON1(Real **stack);
extern  int     _FSDoLZON(Real **stack);
extern  int     _FSDoLZON1(Real **stack);
extern  int     _FSDoCFFLB(Real **stack);
extern  int     _FSDoCFFRB(Real **stack);
extern  int     _FSDoCFSLB(Real **stack);
extern  int     _FSDoCFSRB(Real **stack);
extern  int     _FSDoXHtAdj (Real xhtAdj, Real **stack);

#endif	/* _FSDOFUNC_H */

