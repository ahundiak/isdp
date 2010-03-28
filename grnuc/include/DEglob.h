/*
   This file contains the global variables for symbology override.
   
   Dependencies: OMminimum.h
                 tools.h
*/
#ifndef DEglob_include
#define DEglob_include

extern OM_S_OBJID      *DEsos;		             /* list of valid soos    */
extern OM_S_OBJID      DElocked_views [MAX_WINDOW];  /* views wo overrides    */
extern OM_S_CHANSELECT DEso_to_windows_chanselect,   /* channel to windows    */
                       IGEgragad_winsup_chanselect,  /* window's channel      */
                       GRcontext_to_misc_chanselect, /* channel to contexts   */
                       DEso_to_contexts_chanselect;  /* channel to contexts   */

#endif
