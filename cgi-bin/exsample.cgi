#!/usr/bin/perl -w
#
# Copyright 2004 Bee Flag .lp <http://beeflag.com/>, All Rights Reserved.
#
# Author: Masatoshi Mizuno, <mizuno@beeflag.com>
#
# This program is free software; you can redistribute it and/or modify it
# under the same terms as Perl itself.
#
# $:Id$
#
use CGI;
use HTML::Template;
use HTML::Template::Associate::FormField;
use strict;

my %formfields= (
 StartForm=> { type=> 'opt_form' },
 Name  => { type=> 'textfield', size=> 30, maxlength=> 100 },
 Email => { type=> 'textfield', size=> 50, maxlength=> 200 },
 Sex   => { type=> 'select', values=> [0, 1, 2],
            labels=> { 0=> 'please select !!', 1=> 'man', 2=> 'gal' } },
 ID    => { type=> 'textfield', size=> 15, maxlength=> 15 },
 Passwd=> { type=> 'password', size=> 15, maxlength=> 15,
            default=> "", override=> 1 },
 submit=> { type=> 'submit', value=> ' Please push !! ' },
 );

my $exsample_template= <<END_OF_TEMPLATE;
<html>
<head><title>Exsample template</title></head>
<body>
<h1>Exsample CGI Form</h1>
<form <tmpl_var name="__StartForm__">>
<table>
<tr><td>Name     </td><td> <tmpl_var name="__NAME__">   </td></tr>
<tr><td>E-mail   </td><td> <tmpl_var name="__EMAIL__">  </td></tr>
<tr><td>Sex      </td><td> <tmpl_var name="__SEX__">    </td></tr>
<tr><td>ID       </td><td> <tmpl_var name="__ID__">     </td></tr>
<tr><td>PASSWORD </td><td> <tmpl_var name="__PASSWD__"> </td></tr>
</table>
<tmpl_var name="__SUBMIT__">
</form>
</body>
</html>
END_OF_TEMPLATE


my $cgi = CGI->new;
my $form= HTML::Template::Associate::FormField->new($cgi, \%formfields);
my $tp  = HTML::Template->new(
           scalarref=> \$exsample_template,
           associate=> [$form],
          );

print $cgi->header, $tp->output;

