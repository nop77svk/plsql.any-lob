function literal(i_text)
{
	gsub(/'/, "''", i_text);
	if (modus == "nclob")
		return "n'" i_text "'";
	else if (modus == "blob")
		return "hextoraw('" toHex(i_text) "')";
	else
		return "'" i_text "'";
}

function reverseLiteral(i_text)
{
	if (modus == "blob")
		return "'" i_text "'";
	else
		return "hextoraw('" toHex(i_text) "')";
}

function toHex(i_text,    l_result, i)
{
	l_result = "";
	for (i = 1; i <= length(i_text); i++)
		l_result = l_result sprintf("%02X", ordinal[substr(i_text, i, 1)]);
	return l_result;
}

function repeated(i_count, i_text,    l_result, i)
{
	l_result = "";
	for (i = 1; i <= i_count; i++)
		l_result = l_result i_text;
	return l_result;
}

function resolve(i_token,    l_parts, l_prefix_length)
{
	if (i_token ~ /^lit:/)
		return literal(substr(i_token, 5));
	else if (i_token ~ /^rlit:/)
		return reverseLiteral(substr(i_token, 6));
	else if (i_token ~ /^rep:/)
	{
		split(i_token, l_parts, ":");
		l_prefix_length = length("rep:" l_parts[2] ":");
		return literal(repeated(l_parts[2], substr(i_token, l_prefix_length + 1)));
	}
	else if (i_token in vars)
		return vars[i_token];

	print "Unknown placeholder ${" i_token "}" > "/dev/stderr";
	failed = 1;
	exit 254;
}

function substitute(i_line,    l_result)
{
	l_result = "";
	while (match(i_line, /\$\{[^}]*\}/))
	{
		l_result = l_result substr(i_line, 1, RSTART - 1) resolve(substr(i_line, RSTART + 2, RLENGTH - 3));
		i_line = substr(i_line, RSTART + RLENGTH);
	}
	return l_result i_line;
}

function emit(i_line)
{
	output[++outputCount] = substitute(i_line);
}

function include(i_file,    l_line, l_path)
{
	l_path = i_template_dir "/" i_file;
	while ((getline l_line < l_path) > 0)
		emit(l_line);
	close(l_path);
}

BEGIN {
	for (i = 0; i < 256; i++)
		ordinal[sprintf("%c", i)] = i;

	modus = tolower(i_modus_operandi);

	vars["rawConversionCharset"] = "AL32UTF8";

	if (modus == "clob")
	{
		vars["defaultEoln"] = "chr(10)";
		vars["smallTypeScalar"] = "varchar2";
		vars["smallTypeCollection"] = "arr_varchar2";
		vars["smallTypeLengthFunction"] = "length";
		vars["smallTypeDisplayFunction"] = "to_char";
		vars["largeTypeScalar"] = "clob";
		vars["largeTypeCollection"] = "arr_clob";
		vars["largeTypeScalarUpper"] = "CLOB";
		vars["smallLargeSwitchThreshold"] = "32767";
		vars["smallReverseTypeScalar"] = "raw";
		vars["emptyLobFunction"] = "empty_clob";
		vars["toLobFunction"] = "to_clob";
		vars["multibyteValue"] = "unistr('\\011B')";
		vars["multibyteReverseValue"] = "hextoraw('C49B')";
	}
	else if (modus == "nclob")
	{
		vars["defaultEoln"] = "nchr(10)";
		vars["smallTypeScalar"] = "nvarchar2";
		vars["smallTypeCollection"] = "arr_nvarchar2";
		vars["smallTypeLengthFunction"] = "length";
		vars["smallTypeDisplayFunction"] = "to_char";
		vars["largeTypeScalar"] = "nclob";
		vars["largeTypeCollection"] = "arr_nclob";
		vars["largeTypeScalarUpper"] = "NCLOB";
		vars["smallLargeSwitchThreshold"] = "16383";
		vars["smallReverseTypeScalar"] = "raw";
		vars["emptyLobFunction"] = "empty_clob";
		vars["toLobFunction"] = "to_nclob";
		vars["multibyteValue"] = "to_nchar(unistr('\\011B'))";
		vars["multibyteReverseValue"] = "hextoraw('C49B')";
	}
	else if (modus == "blob")
	{
		vars["defaultEoln"] = "hextoraw('0A')";
		vars["smallTypeScalar"] = "raw";
		vars["smallTypeCollection"] = "arr_raw";
		vars["smallTypeLengthFunction"] = "utl_raw.length";
		vars["smallTypeDisplayFunction"] = "rawtohex";
		vars["largeTypeScalar"] = "blob";
		vars["largeTypeCollection"] = "arr_blob";
		vars["largeTypeScalarUpper"] = "BLOB";
		vars["smallLargeSwitchThreshold"] = "32767";
		vars["smallReverseTypeScalar"] = "varchar2";
		vars["emptyLobFunction"] = "empty_blob";
		vars["toLobFunction"] = "to_blob";
		vars["multibyteValue"] = "hextoraw('C49B')";
		vars["multibyteReverseValue"] = "unistr('\\011B')";
	}
	else
	{
		exit 255;
	}
}

/^@include / {
	include($2);
	next;
}

{
	emit($0);
}

END {
	if (failed)
		exit 254;

	if (outputCount > 0)
	{
		print "PL/SQL Developer Test script 3.0";
		print outputCount;
		for (i = 1; i <= outputCount; i++)
			print output[i];
		print "0";
		print "0";
	}
}
