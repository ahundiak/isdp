echo
echo "linking NFMlib.o"
echo
ld \
	-u _MEMno_buffers \
	-u _MEMwrite \
	-u _MEMsplit_copy_buffer \
	-u _RPScreate_report_file \
	-u _NETclose_c \
	-u _MEMreset_buffer_no \
	-u _MEMbuffer_size \
	-u _MEMwrite_format \
	-u _NETbuffer_receive_c \
	-u _MEMreset_buffer \
	-u _MEMopen \
	-u _MEMbuild_array \
	-u _MEMappend \
	-u _MEMwrite_data \
	-u _MEMprint_buffer \
	-u _NETbuffer_send_c \
	-u _MEMprint_buffers \
	-u _MEMbuild_struct \
	-u _MEMclose \
	-u _NFMconnect \
	-u _NFMdecrypt \
	-u _NFMls_nodes \
	-u _NFMload_user_info \
	-u _poll \
	-u _l64a \
	-r -o ${PDU}/config/dload/init/NFMlib.o \
        ${PDU}/lib/NFMRtic.o \
	${NFM}/lib/libnfmmem.a \
	${NFM}/lib/libnfmnet.a \
	${NFM}/lib/libnfmrpsreq.a \
	${NFM}/lib/libnfmrspec.a \
	${NFM}/lib/libnfmerr.a \
	${NFM}/lib/libnfmtools.a \
	${NFM}/lib/libsystools.a \
	${NFM}/lib/libtli.a \
	${NFM}/lib/libfilexfer.a \
	${NFM}/lib/libnfmu.a \
	${NFM}/lib/libnfmwf.a \
	${NFM}/lib/libcmdtools.a \
	/usr/lib/libUMS.a \
	${PDU}/config/dload/init/poll.o \
	${PDU}/config/dload/init/_poll.o \
	${PDU}/config/dload/init/l64a.o \
	${PDU}/config/dload/init/_l64a.o \
	${PDU}/config/dload/init/chrtest.o

