/******************************************************************************
/*
/*	Author	:	momo
/*
/*	Creation:	january 23th, 1991
/*
/*      CLASS  NAME:   	VRRCorentity
/*      
/*      SUBCLASS OF:   	VRCorrection
/*
/* 	Description:	This class is the R. way correction entity class of the
/*                      I/ROUTE application
/*
/*		
/*	Change History :
/*
/*
/*		  date	|  name	|	modification's description
/*		--------+-------+-----------------------------------
/*
/*
/****************************************************************************/

class specification VRRCorentity (1:0) of VRHCorentity;


instance VRRCorentity
{
};


override


  GRgetobjinfo,		/* GRgraphics   - repport the information about Piping*/
                        /*                correction entity                   */
  ASconstruct_go,	/* ASnode	- construct and connect component     */
  VRGetCmpParams,	/* VRCorrection - get component union VRparam_attr    */
  VRChgCorCmpAttrs,	/* VRCorrection - change component attributes         */
  VRGetCorCmpAttrs,     /* VRCorrection - get component attributes            */
  VRGetTempAttr,	/* VRCorrection - get template attributes	      */
  VRBuild,		/* VRCorrection - build component correction withput  */
			/*                the straight			      */
  VRGetCorLenByCmp;     /* VRCorrection - get coomponent correction length    */
                        /*                beside a given component            */

end specification VRRCorentity;
