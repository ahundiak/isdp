<?xml version='1.0'?>
<xsl:stylesheet version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" standalone="yes" indent="yes"/>
  <xsl:template match="/SMS_PRS/SMS_PRS_UNIT/SMS_KEYLINES/SMS_KEYLINE/SMS_DIAG_INFO">
    <table>
        <layout>
	  <column title="Location Name" column_no="1" />
	  <column title="Distance"      column_no="2" />
        </layout>
        <row>
	  <cell column_no="1" value="Location Name"/>
	  <cell column_no="2" value="Distance"/>
        </row>
	<xsl:for-each select="SMS_KEYLINE_DATA">
	  <row>
	    <cell column_no = "1" value = "{@LOCATION_NAME}" />
	    <cell column_no = "2" value = "{@DISTANCE}" />
	  </row>
        </xsl:for-each>
    </table>
  </xsl:template>
</xsl:stylesheet>
