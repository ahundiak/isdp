VDS  TR179801899  "Extract Frame system and Single Frame" 
Author: Ming Dong
Date  : 02/12/99

  Readme:
  -------
	o "Extract Frame system and Single Fme"”, TR179801899
	  Command should be created to extract frame system in isometric
	  view and also extract single frame.
        	                                         
  Root cause:
  -----------	              
	New command.

  Solution:
  ---------
	New command.

  Files modified/new:
  -------------------
	o Modified files:
	vds/include/VDCmdDrwFr.h
	vds/vddrawing/cmd/VDCmdDrwFri.I
	vds/smframe/drw/DrwFrame.I
	vds/vdspace/imp/VDdrw_plan.I
	vds/vddraw/imp/VDdrwsupfunc.I
	vds/smplane/imp/SMInfPlane.S
	vds/smplane/imp/SMInfPlanei.I
	vds/vdppl/vdppl.m
	vds/vddrawing/imp/vddrwimp.m

	o New files:
	vds/vdppl/COdrwfrm_iso.u
	vds/vddrawing/imp/VDdrwfrm_iso.I
	vds/config/english/forms/VDFrmIsoForm

  Testing info:
  -------------

