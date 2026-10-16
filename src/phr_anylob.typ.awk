BEGIN {
	if (tolower(i_modus_operandi) == "clob")
	{
		defaultEoln = "chr(10)";
		smallTypeScalar = "varchar2";
		smallTypeCollection = "arr_varchar2";
		smallTypeLengthFunction = "sys.standard.length";
		smallTypeOverflowFunction = "sys.standard.length";
		smallTypeMaxLength = "4000";
		smallTypeConcatFunction = "sys.standard.concat";
		largeTypeScalar = "clob";
		largeTypeCollection = "arr_clob";
		largeTypeLengthFunction = "dbms_lob.getLength";
		largeTypeScalarUpper = "CLOB";
		smallLargeSwitchThreshold = "32767";
		smallReverseTypeScalar = "raw";
		rawConversionFunction = "utl_i18n.raw_to_char";
		rawConversionFunctionCharsetPar = "src_charset";
		loadLobFromFile = "loadClobFromFile";
		loadLobFromFileCharsetConversionDeclarations = "\n" \
"    l_lng_ctx                       integer := dbms_lob.DEFAULT_LANG_CTX;\n" \
"    l_lng_warn                      integer;\n" \
"    c_lng_csid                      constant integer := nvl(nls_charset_id(self.raw_conversion_charset$), dbms_lob.DEFAULT_CSID);";
		loadLobFromFileCharsetConversion = ",\n" \
"                bfile_csid => c_lng_csid,\n" \
"                lang_context => l_lng_ctx,\n" \
"                warning => l_lng_warn";
	}
	else if (tolower(i_modus_operandi) == "nclob")
	{
		defaultEoln = "nchr(10)";
		smallTypeScalar = "nvarchar2";
		smallTypeCollection = "arr_nvarchar2";
		smallTypeLengthFunction = "sys.standard.length";
		smallTypeOverflowFunction = "sys.standard.length";
		smallTypeMaxLength = "2000";
		smallTypeConcatFunction = "sys.standard.concat";
		largeTypeScalar = "nclob";
		largeTypeCollection = "arr_nclob";
		largeTypeLengthFunction = "dbms_lob.getLength";
		largeTypeScalarUpper = "NCLOB";
		smallLargeSwitchThreshold = "16383";
		smallReverseTypeScalar = "raw";
		rawConversionFunction = "utl_i18n.raw_to_nchar";
		rawConversionFunctionCharsetPar = "src_charset";
		loadLobFromFile = "loadClobFromFile";
		loadLobFromFileCharsetConversionDeclarations = "\n" \
"    l_lng_ctx                       integer := dbms_lob.DEFAULT_LANG_CTX;\n" \
"    l_lng_warn                      integer;\n" \
"    c_lng_csid                      constant integer := nvl(nls_charset_id(self.raw_conversion_charset$), dbms_lob.DEFAULT_CSID);";
		loadLobFromFileCharsetConversion = ",\n" \
"                bfile_csid => c_lng_csid,\n" \
"                lang_context => l_lng_ctx,\n" \
"                warning => l_lng_warn";
	}
	else if (tolower(i_modus_operandi) == "blob")
	{
		defaultEoln = "hextoraw('0A')";
		smallTypeScalar = "raw";
		smallTypeCollection = "arr_raw";
		smallTypeLengthFunction = "utl_raw.length";
		smallTypeOverflowFunction = "utl_raw.length";
		smallTypeMaxLength = "4000";
		smallTypeConcatFunction = "utl_raw.concat";
		largeTypeScalar = "blob";
		largeTypeCollection = "arr_blob";
		largeTypeLengthFunction = "dbms_lob.getLength";
		largeTypeScalarUpper = "BLOB";
		smallLargeSwitchThreshold = "32767";
		smallReverseTypeScalar = "varchar2";
		rawConversionFunction = "utl_i18n.string_to_raw";
		rawConversionFunctionCharsetPar = "dst_charset";
		loadLobFromFile = "loadBlobFromFile";
		loadLobFromFileCharsetConversionDeclarations = "";
		loadLobFromFileCharsetConversion = "";
	}
	else
	{
		exit 255;
	}
}

{
	gsub(/\$\{smallTypeScalar\}/, smallTypeScalar);
	gsub(/\$\{defaultEoln\}/, defaultEoln);
	gsub(/\$\{smallTypeCollection\}/, smallTypeCollection);
	gsub(/\$\{smallTypeMaxLength\}/, smallTypeMaxLength);
	gsub(/\$\{smallTypeLengthFunction\}/, smallTypeLengthFunction);
	gsub(/\$\{smallTypeOverflowFunction\}/, smallTypeOverflowFunction);
	gsub(/\$\{smallTypeSubstrFunction\}/, smallTypeSubstrFunction);
	gsub(/\$\{smallTypeConcatFunction\}/, smallTypeConcatFunction);

	gsub(/\$\{largeTypeScalar\}/, largeTypeScalar);
	gsub(/\$\{largeTypeCollection\}/, largeTypeCollection);
	gsub(/\$\{largeTypeLengthFunction\}/, largeTypeLengthFunction);
	gsub(/\$\{largeTypeScalarUpper\}/, largeTypeScalarUpper);
	gsub(/\$\{smallLargeSwitchThreshold\}/, smallLargeSwitchThreshold);

	gsub(/\$\{smallReverseTypeScalar\}/, smallReverseTypeScalar);
	gsub(/\$\{rawConversionFunction\}/, rawConversionFunction);
	gsub(/\$\{rawConversionFunctionCharsetPar\}/, rawConversionFunctionCharsetPar);

	gsub(/\$\{loadLobFromFile\}/, loadLobFromFile);
	gsub(/\$\{loadLobFromFileCharsetConversion\}/, loadLobFromFileCharsetConversion);
	gsub(/\$\{loadLobFromFileCharsetConversionDeclarations\}/, loadLobFromFileCharsetConversionDeclarations);

	print;
}
