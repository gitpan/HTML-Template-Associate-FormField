package HTML::Template::Associate::FormField;
#
# Copyright 2004 Bee Flag, Corp. All Rights Reserved.
# Masatoshi Mizuno <mizuno@beeflag.com>
#
# $Id: FormField.pm,v 1.11 2004/08/16 00:32:33 Lushe Exp $
#
use 5.004;
use UNIVERSAL qw( isa );
use CGI qw( :form );
use strict;

our $VERSION= '0.09';

sub new {
	my $class= shift;
	my $af= bless {
	  query => _new_query(shift),
	  param => {},
	 }, $class;
	$af->params(shift);
	return $af;
}
sub param {
	my($af, $key, $value)= @_;
	@_< 2 and return keys %{$af->{param}};
 	my $name;
 	$key=~/^\__(.+?)\__$/
 	  ? do { $name= $1 }:
 	    do { $name= $key; $key= '__'. $key .'__' };
	$key= uc($key);
	(@_== 3 && ref($value) eq 'HASH') ? do {
		while (my($n, $v)= each %$value) {
			$n=~/^\-/ and do {
				$n=~s/^\-//;
				$value->{$n}= $value->{"-$n"};
				delete $value->{"-$n"};
			 };
			$n=~/[A-Z]/ and do {
				$value->{lc $n}= $value->{$n};
				delete $value->{$n};
			 };
		}
		! $value->{type} ? do {
			return "";
		 }: do {
			$value->{type}=~/[Ff][Oo][Rr][Mm]$/ ? do {
				$value->{alias} and $value->{name}= $value->{alias};
			 }: do {
				$value->{name}= $value->{alias} || $name;
			 };
			$af->{param}{$key}= $value;
			return wantarray ? %{$af->{param}{$key}}: $af->{param}{$key};
		 };
	 }: do {
		return $af->_field_conv(%{$af->{param}{$key}});
	 };
}
sub params {
	my($af, $hash)= @_;
	($hash && ref($hash) eq 'HASH') and do {
		while (my($key, $value)= each %$hash) { $af->param($key, $value) }
	 };
	return $af->{param};
}

{
	local $^W= 0; no strict 'refs';
	*{__PACKAGE__."::hidden"}= sub {
		my $af= shift;
		! $af->{hidden} and do {
			my $hidden;
			$af->{hidden}=
			  HTML::Template::Associate::FormField::Hidden->new($hidden);
		 };
		return $af->{hidden};
	 };
}

sub hidden_out {
	my($af, $hidden)= @_;
	return HTML::Template::Associate::FormField::Hidden->new($hidden);
}
sub _field_conv {
	my($af, %attr)= @_; ! %attr and return "";
	my $_type= lc($attr{type}) || return qq{ Can't find field type. };
	my $type= $_type. '__';
	! $af->can($type) and return qq{ Can't call "$_type" a field type. };
	for my $key (qw(type alias)) { delete $attr{$key} }
	return $af->$type(\%attr);
}
sub _new_query {
	my $query= shift || {};
	my $type = ref($query);
	$type ? do {
		($ENV{MOD_PERL} && isa $query, 'SCALAR') ? do { return $query }:
		$type eq 'HASH'        ? do { return _const_param($query) }:
		! (isa $query, 'HASH') ? do { $query= {}; return _const_param($query) }:
		! $query->can('param') ? do { return _const_param($query) }:
		                         do { return $query };
	 }:                          do { $query= {}; return _const_param($query) };
}
sub _const_param {
	my $query= shift || {};
	return HTML::Template::Associate::FormField::Param->new($query);
}

sub startform__  {
	my($af, $attr)= @_;
	($attr->{enctype} && $attr->{enctype}=~/[Uu][Pp][Ll][Oo][Aa][Dd]/)
	  and $attr->{enctype}= CGI->MULTIPART;
	my $form= startform($attr);
	$af->hidden->exists and $form.= $af->hidden->get;
	return $form;
}
sub form__ { &startform__ }
sub start_form__ { &startform__ }
sub start_multipart_form__ {
	my($af, $attr)= @_;
	my $form= start_multipart_form($attr);
	$af->hidden->exists and $form.= $af->hidden->get;
	return $form;
}
sub multipart_form__ { &start_multipart_form__ }
sub start_upload_form__ { &start_multipart_form__ }
sub upload_form__ { &start_multipart_form__ }
sub opt_multipart_form__ {
	my($af, $attr)= @_;
	my $form= start_multipart_form($attr);
	$form=~s/(?:<[Ff][Oo][Rr][Mm]\s+|\s*>\n?)//g;
	return $form;
}
sub opt_upload_form__ { &opt_multipart_form__ }
sub opt_form__ {
	my($af, $attr)= @_;
	my $form= startform($attr);
	$form=~s/(?:<[Ff][Oo][Rr][Mm]\s+|\s*>\n?)//g;
	return $form;
}
sub endform__    { q{</form>} }
sub end_form__   { &endform__  }
sub hidden_out__ { shift->hidden->get }
sub hidden_field__ { CGI::hidden(&_proc_value) }
sub hidden__ { CGI::hidden(&_proc_value) }
sub textfield__ { textfield(&_proc_value) }
sub text__ { &textfield__ }
sub filefield__ { filefield(&_proc_value) }
sub file__ { &filefield__ }
sub password_field__ { password_field(&_proc_value) }
sub password__ { &password_field__ }
sub textarea__ { textarea(&_proc_value) }
sub button__   { button($_[1]) }
sub reset__    { reset($_[1]) }
sub defaults__ { defaults($_[1]) }
sub checkbox__ { checkbox(&_proc_defaults) }
sub checkbox_group__ { checkbox_group(&_proc_defaults) }
sub popup_menu__ { popup_menu(&_proc_defaults) }
sub scrolling_list__ { scrolling_list(&_proc_defaults) }
sub select__ { &popup_menu__ }
sub radio_group__    { radio_group(&_proc_default) }
sub radio__ { &radio_group__ }
sub image_button__ { image_button($_[1]) }
sub image__ { image_button($_[1]) }
sub submit__   { submit($_[1]) }

sub _proc_default {
	my($af, $attr)= @_;
	(! $attr->{override} && $af->{query}->param($attr->{name})) and do {
		$attr->{override}= 1;
		$attr->{default}= $af->{query}->param($attr->{name});
	 };
	return $attr;
}
sub _proc_defaults {
	my($af, $attr)= @_;
	(! $attr->{override} && $af->{query}->param($attr->{name})) and do {
		$attr->{override}= 1;
		$attr->{defaults}= $af->{query}->param($attr->{name});
	 };
	return $attr;
}
sub _proc_value {
	my($af, $attr)= @_;
	(! $attr->{override} && $af->{query}->param($attr->{name})) and do {
		$attr->{override}= 1;
		$attr->{value}= $af->{query}->param($attr->{name});
	 };
	return $attr;
}


package HTML::Template::Associate::FormField::Param;
use strict;

sub new {
	my($class, $hash)= @_;
	return bless $hash, $class;
}
sub param {
	my($q, $key, $value)= @_;
	@_<  2 and return keys %$q;
	@_== 3 and $q->{$key}= $value;
	return $q->{$key};
}


package HTML::Template::Associate::FormField::Hidden;
use strict;

sub new {
	my($class, $hidden)= @_;
	(! $hidden || ref($hidden) ne 'HASH') and $hidden= {};
	return bless $hidden, $class;
}
sub set {
	my($h, $key, $value)= @_;
	@_== 3 and do {
		$h->{$key} ? do {
			ref($h->{$key}) eq 'ARRAY'
			  ? do { push @{$h->{$key}}, $value }:
			    do { $h->{$key}= [$h->{$key}, $value] };
		 }:     do { $h->{$key}= $value };
	 };
	return();
}
sub unset {
	my($h, $key)= @_;
	@_== 2 and do { delete $h->{$key} };
	return();
}
sub get {
	my($h, $key)= @_;
	@_< 2 and return _create_fields($h);
	return _create_field($key, $h->{$key});
}
sub exists {
	my($h, $key)= @_;
	@_== 2 ? do {
		ref($h->{$key}) eq 'ARRAY'
		  ? do { return @{$h->{$key}} ? 1: 0 }:
		    do { return CORE::exists $h->{$key} ? 1: 0 };
	 }:     do { return %$h ? 1: 0 };
}
sub clear { my $h= shift; %$h= () }

sub _create_fields {
	my $hidden= shift || return "";
	my @hidden;
	while (my($key, $value)= each %$hidden) {
		$value and push @hidden, _create_field($key, $value);
	}
	return @hidden ? join('', @hidden): "";
}
sub _create_field {
	my $key  = &CGI::escapeHTML(shift);
	my $value= shift;
	my $result;
	for my $val (ref($value) eq 'ARRAY' ? @$value: $value) {
		$val= &CGI::escapeHTML($val) || next;
		$result.= qq{<input type="hidden" name="$key" value="$val" />\n};
	}
	return $result;
}

1;

__END__


=head1 NAME

HTML::Template::Associate::FormField

  - CGI Form for using by HTML::Template is generated.

=head1 SYNOPSIS

 use CGI;
 use HTML::Template;
 use HTML::Template::Associate::FormField;

 ## The form field setup. ( CGI.pm like )
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

 ## The template.
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

 ## The code.
 my $cgi = CGI->new;
 # Give CGI object and definition of field ・・・
 my $form= HTML::Template::Associate::FormField->new($cgi, \%formfields);
 # Give ... ::Form Field object to associate 
 my $tp  = HTML::Template->new(
            scalarref=> \$exsample_template,
            associate=> [$form],
           );
 # And output your screen
 print $cgi->header, $tp->output;

   or, a way to use not give associate・・・

 my $cgi = CGI->new;
 my $form= HTML::Template::Associate::FormField->new($cgi, \%formfields);
 my $tp  = HTML::Template->new(scalarref=> \$exsample_template);
 # set up the parameter directly
 $tp->param('__StartForm__', $form->param('StartForm'));
 $tp->param('__NAME__',   $form->param('Name'));
 $tp->param('__EMAIL__',  $form->param('Email'));
 $tp->param('__SEX__',    $form->param('Sex'));
 $tp->param('__ID__',     $form->param('ID'));
 $tp->param('__PASSWD__', $form->param('Passwd'));
 $tp->param('__SUBMIT__', $form->param('submit'));

 print $cgi->header, $tp->output;


=head1 DESCRIPTION

This is Form Field object using bridge associate option of HTML::Template.
Fill in the Form Field which made from object follow the template.
If the Form Field data which was input at the previous screen exist, it is
 easy to make code, because process (CGI pm dependense) of fill in Form is
 automatic.

=head2 Form Field Setup

=over 4

=item *

The Form of the definition data of Form Field is HASH.  And, contents of each
 key is HASH, too.

=item *

The name of each key is hadled as name of Form Field. Also, in case of hadling
 by B<HTML::Template, the name of key become enclosed with '__'> .
 For example, Field that was defined Foo correspomds to B<__FOO__> of template.

=item *

The contents of each key certainly be defined the key ,type, which shows type
 of Form Field.

=item *

The value of designate to type is same as method for making Form Field of
 CGI.pm. B<Please refer to document of CGI.pm for details>.

B<startform> , B<start_multipart_form> , B<endform> , B<textfield> ,
 B<filefield> , B<password_field> , B<textarea> , B<checkbox> , B<radio_group>
 , B<popup_menu> , B<optgroup> , B<scrolling_list> , B<image_button> ,
 B<defaults> , B<button> , B<reset>

=item *

And others, be possible to designate for extension Field type
 at B<HTML::Template::Associate::FormField> are as follows:

B<form>               ... other name of startform. I<(%)>

B<start_upload_form>  ... other name of start_multipart_form. I<(%)>

B<upload_form>        ... other name of start_multipart_form. I<(%)>

B<opt_form>           ... return only a part of attribute of startform.

B<opt_multipart_form> ... return only a part of attribute of start_multipart_form.

B<opt_upload_form>    ... other name of opt_multipart_form.

B<hidden_field>       ... return all of no indication Field which is seting up.

B<hidden>             ... other name of hidden_field

B<text>               ... other name of textfield.

B<file>               ... other name of filefield.

B<password>           ... other name of password_field.

B<radio>              ... other name of radio_group.

B<select>             ... other name of popup_menu.

B<image>              ... other name of image_button.

I<(%) In case of no indication Field was set up ,
 connect the no indication Field and return the value.>

=item *

In case of you'd like to acquire the name from CGI query - it is different name
 of the key which definition of Form Field, designate for the name of CGI query
  as alias to contents of each key.

 $cgi->param('Baz', 'Hello!!');
 my %formfields= ( 'Foo'=> { alias=> 'Baz', type=> 'textfield' } );

=back

=head1 METHOD

=head2 new

Constructor

=over 4

=item 1

Accept CGI object or HASH reference to the first parameter.

=item 2

Accept definition of CGI Form (HASH reference) to the second parameter. 

$form= HTML::Template::Associate::FormField-E<gt>B<new>($cgi, \%formfields);

=back

=head2 param

Set up or refer to definition parameter of CGI Form.

=over 4

=item *

Get all keys which is defined as Form Field.

(B<All keys which was able to get by this are enclosed by '__'>)

$form-E<gt>B<param>;

=item *

Get the Form Field which was designated.

$form-E<gt>B<param>('Foo');

    or

$form-E<gt>B<param>('__FOO__');

=back

=head2 hidden

Access to object which control no indication Field.

=over 4

=item *

Add to no indication Field.

$form-E<gt>B<hidden>-E<gt>set('Foo', 'Hoge'); 

=item *

Get all no indication Fields which was set beforehand.

$form-E<gt>B<hidden>-E<gt>get;

=item *

Get no indication Field which was designated.

$form-E<gt>B<hidden>-E<gt>get('Foo');

=item *

Erase the data of no indication field which was designated.

$form-E<gt>B<hidden>-E<gt>unset('Foo');

=item *

Find out the no indication Field was set or not.

$form-E<gt>B<hidden>-E<gt>exists ? 'true': 'false';

=item *

Erase all of no indication Field which was set.

$form-E<gt>B<hidden>-E<gt>clear;

=back

=head2 hidden_out

Export no indication Field, object.

=over 4

=item *

Get no indication field, object.

my %hash = ( 'Foo'=E<gt> 'Form Field !!' );

B<$hidden> = $form-E<gt>B<hidden_out>(\%hash);

=item *

Usable methods are same as hidden.

B<$hidden>-E<gt>set('Baz', 'Hoge');

B<$hidden>-E<gt>get;

B<$hidden>-E<gt>unset('Baz');

=item *

B<Hidden object> which was exported is not linked with startform and,
 start_multipart_form. No indication field which was formed at this object is
  please give to B<param method of HTML::Template>.

$tp= HTML::Template-E<gt>new( ..... );

$tp-E<gt>param('HIDDEN_FIELD', B<$hidden>-E<gt>get);

=back

=head1 ERRORS

In case of errors in the definition of Form field, return this error message
 instead of Form field.

=over 4

=item * Can't find field type.

There is no designation of type in definition Form field.

=item * Can't call "%s" a field type.

Errors in definition form of type.

=back

=head1 BUGS

When you call a function start_form without an action attribute by old CGI
 module, you might find a caution "Use of uninitialized value". In this case,
 let's upgrade to the latest CGI module.

When you find a bug, please email me (L<mizuno@beeflag.com>) with a light heart.


=head1 SEE ALSO

 HTML::Template, CGI


=head1 CREDITS

Generously contributed to English translation by:

Ayumi Ohno

Special Thanks!


=head1 COPYRIGHT

Copyright 2004 Bee Flag, Corp. <L<http://beeflag.com/>>, All Rights Reserved.

This program is free software; you can redistribute it and/or modify it under
 the same terms as Perl itself.


=head1 AUTHOR

Masatoshi Mizuno, <mizunoE<64>beeflagE<46>com>


