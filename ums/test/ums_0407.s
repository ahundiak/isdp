<TP>Certification_Report_0407
:Certification Report 0407:

Product:          UMS
Product Version:  02.01.01.01
Product Date:     19-MAR-1993

Test Date:     07-APR-1993
Test Time:     17:27:45
Product Installed under:  /usr/ip32/ums
                  at:     17:25:06 04/07/93
                  from:   TCPIP: gondor.ums70.<password>
                  on:   CLIX susie 3.1 r.7.0.17 IP220

Current Hardware Configuration on susie:
/bin/inqcptype
STREAMS

/bin/inqcpuid
C100

/bin/inqdiskless

/bin/inqfpeg

/bin/inqfpen

/bin/inqgra
ROP

/bin/inqifb

/bin/inqifbtype
IFB_2MEG_1MPIX

/bin/inqiop
80186

/bin/inqlgexist

/bin/inqmemory
15724544

/bin/inqnativex

/bin/inqrop

/bin/inqscreens

/bin/inqsecure
1

/bin/inqswap
71000

/bin/inqzbuf


Current Software Configuration on susie:
Products Currently Installed:
Name      Number    Date        Version     Title
------------------------------------------------------------
ACC       SS01191   29-SEP-1992 07.00.01.57 CLIPPER Advanced
COMPILSUP SS01038   12-NOV-1992 07.00.03.01 Compiler Support
COMPTOOLS SS01325   29-SEP-1992 07.00.01.03 Compiler Tools  
DELTOOLS  SS01040   10-MAR-1993 07.00.08.02 Delivery Tools  
DNS       SS09999   18-MAY-1992 06.01.00.01 Domain Name Syst
ELM       SS01149   16-NOV-1992 07.00.01.00 ELM Mail System 
EMACS     SS01013   02-FEB-1993 07.00.01.03 Emacs Screen Edi
ENVIRON_S SS01073   05-FEB-1993 07.00.10.00 Clipper Graphics
FORMS     SN01014   05-APR-1993 02.00.04.00 I/Forms Developm
FORMS_S   SN01087   05-APR-1993 02.00.04.00 I/Forms Runtime 
HELPDP    SN0J254   26-MAR-1993 08.01.02.00 I/Help Developme
HELPRT    SN0J255   26-MAR-1993 08.01.02.00 I/Help Runtime P
I_LICENSE SS01257   05-FEB-1993 07.00.00.03 Intergraph Netwo
NQS       SS01126   25-MAR-1993 07.00.01.01 Network Queuing 
NS        SS01261   14-DEC-1992 07.00.05.00 Naming Services 
PB        SS01387   12-JAN-1993 06.06.00.05 Electronic Phone
PEAK      SS01986   14-JAN-1993 06.05.00.03 Performance Eval
RESOURCES SS01050   28-JAN-1993 07.00.09.00 Graphics Resourc
SCREENMGR SS01045   17-DEC-1992 07.00.09.00 Screen Manager  
SENDMAIL  SS01093   05-FEB-1993 07.00.08.00 Sendmail        
SYSTEMV   SS01044   17-FEB-1993 07.00.08.01 System V 3.1 Fil
TCPIP     SS01066   05-FEB-1993 07.00.00.08 TCPIP           
UMS       SN0J256   19-MAR-1993 02.01.01.01 I/UMS User Messa
UNIXBOOT  SS01043   05-MAR-1993 07.00.17.01 System V 3.1 Boo
XNSINGR   SS01636   19-NOV-1992 07.00.00.01 Workstation Netw
------------------------------------------------------------

BEGIN Cert Testing Wed Apr  7 17:27:52 CDT 1993

umscompile test.txt
----------------------------------------------------------
----------------------------------------------------------
test.h IS SAME as standard.h
test.msg IS SAME as standard.msg

*** SUCCESS:  umscompile test.txt
********************************************************************
umscomptxt test.txt
----------------------------------------------------------
----------------------------------------------------------
umcomptxt CORRECTLY did not generate test.h
test.msg IS SAME as standard.msg

*** SUCCESS:  umscomptxt test.txt
********************************************************************
umscompile -p TEST.h -m TEST.msg test.txt
----------------------------------------------------------
----------------------------------------------------------
TEST.h IS SAME as standard.h
TEST.msg IS SAME as standard.msg

*** SUCCESS:  umscompile -p TEST.h -m TEST.msg test.txt
********************************************************************
umscompile -m TEST.msg -F test.txt
----------------------------------------------------------
----------------------------------------------------------
test.inc IS SAME as standard.inc
TEST.msg IS SAME as standard.msg

*** SUCCESS:  umscompile -m TEST.msg -F test.txt
********************************************************************

END Cert Testing Wed Apr  7 17:27:58 CDT 1993


<ETP>
