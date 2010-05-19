<?xml version='1.0'?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:template match="/">
     <table name="Steel Band Report"
            description="Steel Band Report">

        <layout>
          <column title="Index"    column_no="1" />
	  <column title="Name"     column_no="2" />
	  <column title="Distance" column_no="3" />
	</layout>
        <xsl:for-each select="SMS_PRS/SMS_PRS_UNIT/SMS_STEELBANDS/SMS_STEELBAND"
		order-by="BAND_NUMB">
        <row>
          <cell column_no="1" value="Band Number: {SMS_STEELBAND_INFO/@BAND_NUMB}" />
	  <cell column_no="2" value="Start Stock: {SMS_STEELBAND_INFO/@START_STOCK}" />
	  <cell column_no="3" value="End Stock: {SMS_STEELBAND_INFO/@END_STOCK}" />
	</row>
        <row>
          <cell column_no="1" value="Index" />
	  <cell column_no="2" value="Name"  />
	  <cell column_no="3" value="Distance" />
	</row>
        <xsl:for-each select="SMS_STEELBAND_INFO/SMS_STEELBAND_DATA"
				order-by="INDEX">
	   <row>
              <cell column_no="1" value="{@INDEX}" />
              <cell column_no="2" value="{@NAME}" />
              <cell column_no="2" value="{@DISTANCE}" />
           </row>
         </xsl:for-each>
       </xsl:for-each>
     </table>
  </xsl:template>
</xsl:stylesheet>
