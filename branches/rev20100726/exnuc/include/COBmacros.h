
 /*
 COPYRIGHT
                     COPYRIGHT INTERGRAPH CORPORATION
                          < 1986, 1987, 1988 >
  
              Including software  and  its  file formats, and
              audio-visual displays; all rights reserved; may
              only  be  used   pursuant   to  the  applicable
              software     license     agreement;    contains
              confidential  and  proprietary  information  of
              intergraph and/or other  third parties which is
              protected  by  copyright,   trade  secret,  and
              trademark  law,  and  may  not  be  provided or
              otherwise made available  without prior written
              authorization.
  
  
                         RESTRICTED RIGHTS LEGEND
              Use, duplication,  or  disclosure  by  the U.S.
              Government is  subject  to  restrictions as set
              forth in subdivision  (b)(3)(ii)  of the Rights
              in Technical Data  and Computer Software clause
              at 52.227-7013.
  
  
              Intergraph Corporation
              One Madison Industrial Park
              Huntsville, Al 35807-4201
  
 */ 


/* COBmacros.h -- Internal/External COB macros */

#ifndef COBmacros_h
#define COBmacros_h



/* --------------------------- om$send macros -------------------------*/

#define _send(obj,mesg) status = om$send (targetid = obj, msg = message mesg)
#define _sendc(chan,mesg) \
	status = om$send (p_chanselect = & chan, msg = message mesg)
#define _sendf(obj,num,mesg) \
	status = om$send (targetid = obj, targetos = num, msg = message mesg)


/* ----------------- om$send status checking macros -------------------------*/
#define _check_print(stt) \
{ \
  fprintf(stderr,"OM_Gw_current_OS = %d\nOM_GO_current_OS_objid = %d\n", \
    OM_Gw_current_OS, OM_GO_current_OS_objid); \
  fprintf(stderr,"my_id = %d sender_id = %d sender_os = %d\n", my_id, \
    sender_id, sender_os ); \
  om$report_error (sts=stt); \
  goto quit; \
}
#define _check(stt) if (!((stt)&1)) _check_print(stt)
#define _check2(sts1,sts2) if (!((sts1)&(sts2)&1)) \
  {fprintf (stderr, "check %d\n", sts2); _check_print(sts1) }

#define _cob_check(stt,str) \
    if (!((stt)&1)) { fprintf(stderr,"\n%s\n",str); _check_print(stt);}
#define _cob_check2(sts1,sts2,str) \
    if (!((sts1)&(sts2)&1)) \
	{ fprintf ( stderr, "\n%s\nstatus2 = (0x)%x\n", str, sts2); \
	  _check_print(sts1) }


/* ------------------------ response macros ---------------------------- */
#omdef _put_response ( resp = TERMINATE, status = status,
	check = _check, size = sizeof(struct EX_button),
	buf = me->response_data )
{ int	   rsp;
  IGRlong  ret, siz;

  rsp = resp;
  siz = (IGRlong)size;
  status = ex$putque(msg = &ret,
		  response = &rsp,
		  byte = &siz,
		  buffer = buf);
  check ( status );
}
#endomdef

#define _move_on	_put_response(resp=MOVE_ON)


/* -----------------------------  debug macros ------------------------------*/
#ifdef VERBOSE
#define _verbose(x) x
#else
#define _verbose(x)
#endif

#ifdef DEBUG
#define _debug(x) x

#define _bugprintindent {int ii;for(ii=0;ii++<COBdebugindentlvl;) \
		fprintf(stderr,"| ");}

#omdef  _bugprint (bflag=COBtrace, str, var = NULL )
{
if (bflag) switch (str[0])
 {
    case '+':
	{  _bugprintindent; COBdebugindentlvl++; break; }
    case '-':
	{  if(COBdebugindentlvl)
		COBdebugindentlvl--;
	   _bugprintindent; break; }
    default :
	{  _bugprintindent; break; }
 }
if (bflag) fprintf (stderr, str, var);
};
#endomdef

#else	/*****   "DEBUG" is not #defined   *****/

#define _debug(x)
#omdef  _bugprint(bflag=COBtrace,str,var = NULL)
#endomdef

#endif	/*****   end of #ifdef DEBUG  *****/


#endif
