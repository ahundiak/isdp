<?xml version='1.0'?>

<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:template match="/">
    <HTML>
      <BODY>
        <H1>Creation of Table from Plate report</H1>
        <TABLE BORDER="3">
          <TH>Plates</TH>
          <TR>
            <TD>Name</TD><TD>Material</TD><TD>Grade</TD><TD>ASSEMBLY</TD><TD>PIECE_MARK</TD>
	      </TR>
          <xsl:for-each select="SMS_SMS/SMS_PLATES/SMS_PLATE"
                           order-by="SMS_PART_INFO/PART_NUM">
	        <TR>
              <TD><xsl:value-of select="SMS_PART_INFO/@PART_NUM" /></TD>
              <TD><xsl:value-of select="SMS_PART_INFO/@MATERIAL_TYPE" /></TD>
              <TD><xsl:value-of select="SMS_PART_INFO/@MATERIAL_GRADE" /></TD>
              <TD><xsl:value-of select="SMS_PART_INFO/SMS_PROD_INFO/@ASSEMBLY" /></TD>
              <TD><xsl:value-of select="SMS_PART_INFO/SMS_PROD_INFO/@PIECE_MARK" /></TD>

            </TR>
         </xsl:for-each>
        </TABLE>
      </BODY>
    </HTML>
  </xsl:template>
</xsl:stylesheet>
