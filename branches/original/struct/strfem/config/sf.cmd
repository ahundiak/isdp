#include "SFcmd.h"

"STRFEM Session Startup",SFstartup0,SFstrtupCmd,0,256,,,STRFEM.o
"Convert All Elements",SFConvEl,COci,0,0,,"COconvAllEl"
^"SFMn1",SFMn1,COci,0,0,,"Blank"
^"Strfem",IMTkSf,COci,0,0,,"VDswaptask IMTkSf IMSF BAR_VDS POCKET_MODEL"
SFC_M_ConvPlate,SFConvPl,SFCoConvPl,0
SFC_M_ConvBeam,SFConvBm,SFCoConvBm,0
SFC_M_ConvStfndPl,SFStfndPl,SFCoStfndPl,0
"Define Conversion Options",SFDfCnvOp,SFCoDefOpt,0
"Extend Elements To Surface",SFextElSf,SFCoSfCv,0
"Trim Elements To Surface",SFtrimElSf,SFCoSfCv,1
