#!/usr/bin/env awk
#
# dlf.awk - dnf list fix: convert dnf list output to useful data for programs
#
# Copyright (c) 2014,2023,2025 by Landon Curt Noll.  All Rights Reserved.
#
# Permission to use, copy, modify, and distribute this software and
# its documentation for any purpose and without fee is hereby granted,
# provided that the above copyright, this permission notice and text
# this comment, and the disclaimer below appear in all of the following:
#
#       supporting documentation
#       source copies
#       source works derived from this source
#       binaries derived from this source or from derived source
#
# LANDON CURT NOLL DISCLAIMS ALL WARRANTIES WITH REGARD TO THIS SOFTWARE,
# INCLUDING ALL IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS. IN NO
# EVENT SHALL LANDON CURT NOLL BE LIABLE FOR ANY SPECIAL, INDIRECT OR
# CONSEQUENTIAL DAMAGES OR ANY DAMAGES WHATSOEVER RESULTING FROM LOSS OF
# USE, DATA OR PROFITS, WHETHER IN AN ACTION OF CONTRACT, NEGLIGENCE OR
# OTHER TORTIOUS ACTION, ARISING OUT OF OR IN CONNECTION WITH THE USE OR
# PERFORMANCE OF THIS SOFTWARE.
#
# chongo (Landon Curt Noll) /\oo/\
#
# http://www.isthe.com/chongo/index.html
# https://github.com/lcn2
#
# Share and enjoy!  :-)


# The "dnf list available" tool, in defiance of good programming
# practice, attempts to output in form that looks "pretty" for
# humans but is otherwise useless for programs.  Moreover, the
# amount of output that "dnf list available" can produce is often
# too much for a human to comprehend, making the "pretty" output
# pretty useless!
#
# This tool attempts to canonicalize standard input into 3 fields:
#
#	rpm_basename	rpm_version	rpm_repository
#
# If the tool finds wacky output (not a multiple of 3 fields),
# it will print a warning in stderr that begins with a '#'.
#
# Furthermore, against Un*x best practices, the dnf list prints
# out a so-called "header" that contains non rpm information.
# Here is a typical so-called "header":
#
#     Loaded plugins: aliases, changelog, downloadonly, kabi, keys, product-id,
#                   : refresh-packagekit, security, subscription-manager, tmprepo,
#                   : verify, versionlock
#     Loading support for Red Hat kernel ABI
#     Available Packages
#
# Or sometimes:
#
#     Loaded plugins: aliases, changelog, downloadonly, kabi, keys, product-id,
#                   : refresh-packagekit, security, subscription-manager, tmprepo,
#                   : verify, versionlock
#     Loading support for Red Hat kernel ABI
#     Installed Packages
#
# NOTE: The Loaded plugins multi-line will differ depending on dnf
#	plugin information.
#
# We will assume that we will toss lines until after we see the
# appropriate dnf list header.

# initialize buffer and field count, assume stupid header mode
#
BEGIN {
   buf = "";
   fld_cnt = 0;
   header_mode = 1;
}


# print when we have 3 or more fields
# warn when we have more than 3 fields
#
{
    # process input only if we are past stupid headers
    #
    if (header_mode == 0) {

	# always join current fields to buffer
	for (i=1; i <= NF; ++i) {
	    if (buf == "") {
		buf = sprintf("%s", $i);
	    } else {
		buf = sprintf("%s %s", buf, $i);
	    }
	}
	fld_cnt += NF;

	# dump when we have 3 or more fields
	if (fld_cnt >= 3) {

	    # warn when we have an excess of 3 fields
	    if (fld_cnt > 3) {
		print "# Warning:field_count:", NF > "/dev/stderr";
	    }

	    # dump fields
	    print buf;

	    # clear buffer
	    buf = "";
	    fld_cnt = 0;
	}
    }

    # We hope that we have found the last header
    #
    if ($0 == "Available Packages" ||
	$0 == "Installed Packages" ||
	$0 == "Recently Added Packages" ||
	$0 == "Autoremove Packages") {
	# end of stupid headers, useful data follows at next line
	header_mode = 0;
    }

# DEBUGGING
#    print "#DEBUG: NR, NF:", NR, NF > "/dev/stderr";
#    print "#DEBUG: fld_cnt:", fld_cnt > "/dev/stderr";
#    print "#DEBUG: header_mode:", header_mode > "/dev/stderr";
#    print "#DEBUG: buf:", buf > "/dev/stderr";
#    print "#DEBUG: line:", $0 > "/dev/stderr";
}


# at EOF (or end of processing due to error), dump any remaining buffer
#
END {

    # dump if we have any left over fields and not printing headers
    if (fld_cnt = 0 && header_mode == 0) {

	# warn when we have an excess of 3 fields
	if (fld_cnt > 3) {
	    print "# Warning:field_count:", NF > "/dev/stderr";
	}

	# dump fields
	print buf;
    }

    # if for some reason, we missed the end of headers, perhaps
    # because there was an unexpected change in the header format,
    # warn that we may have missed useful list data.
    #
    if (header_mode == 1) {
	    print "# Warning no_end_of_headers_found" > "/dev/stderr";
    }
}
