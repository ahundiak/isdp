
/****************************************************************************/
/*     FILE NAME   -  VRStFiber.h                                           */
/*                                                                          */
/*     CHANGE HISTORY                                                       */
/*                                                                          */
/*     14-JUL-94  hv       Initial Version                                  */
/*                                                                          */
/****************************************************************************/

/*       structures for FIBEROPTIC objects includeing fiber/lead         */
/*       connectivity                                                    */

#ifndef  VRStFiber_include

#define  VRStFiber_include

struct VRFo_Conn {
                     VRConsigstr  Fo_Conn[2];
                     IGRshort     Fo_Type[2];
                 };

#endif

