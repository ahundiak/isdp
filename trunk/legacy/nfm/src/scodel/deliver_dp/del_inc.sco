echo "find ..."
cd ../..
find \
include/ERRerrordef.h \
include/MEMbuf_def.h \
include/MEMerrordef.h \
include/MEMproto.h \
include/MEMstruct.h \
include/MSGstruct.h \
include/DEBUG.h \
include/NETdef.h \
include/NETerrordef.h \
include/NETstruct.h \
include/NFIerrordef.h \
include/NFMRinclude.h \
include/NFMapi.h \
include/NFMattr.h \
include/NFMcombine.h \
include/NFMdb.h \
include/NFMdef.h \
include/NFMdisplays.h \
include/NFMerrordef.h \
include/NFMfile.h \
include/NFMflag.h \
include/NFMitemfiles.h \
include/NFMitems.h \
include/NFMlisten.h \
include/NFMlocks.h \
include/NFMmach_id.h \
include/NFMnfs.h \
include/NFMschema.h \
include/NFMstruct.h \
include/NFMtypes.h \
include/RPSdef.h \
include/RPSerrordef.h \
include/RPSmacros.h \
include/SQLerrordef.h \
include/UNIX_or_VMS.h \
include/UTICinclude.h \
include/UTIclient.h \
include/UTIdef.h \
include/UTIerrordef.h \
include/UTIextern.h \
include/UTIglobals.h \
include/UTIinclude.h \
include/UTImacros.h \
include/UTIstruct.h \
include/UTIui.h \
include/WFcommands.h \
include/WFstruct.h \
include/NDXstruct.h \
include/ERR.h \
include/ERRproto.h \
include/NFMRformats.h \
include/NFMRproto.h \
include/NFMRstruct.h \
include/NFMUproto.h \
include/NFMAproto.h \
include/DISproto.h \
-print | sort | cpio -ov | compress > nfminc.prod
rcp -p nfminc.prod nfmcert@moorer:/usr2/nfmcert/scounix/i_nfmdp/nfminc.prod
rm nfminc.sco
echo
