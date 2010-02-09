#!/usr/bin/perl
use strict;
use warnings;
use Mail::Sendmail qw(sendmail %mailcfg);
use Net::Twitter::Lite;

sub llegoLaLuz;
sub sefueLaLuz;
sub correo;
sub twitter;
sub apagar;

# Configuración
chomp( my $twitter_user   = `cat twitter.user.txt` );
chomp( my $twitter_passwd = `cat twitter.passwd.txt` );
my $ac_file = '/proc/acpi/ac_adapter/AC0/state';
my $localidad = '#Tachira #Cardenas #AltosParamillo';

# Averiguamos el estado del adaptador de AC.
chomp(my $ac = `cat $ac_file`);

if ( $ac =~ /on-line/ ) {
    llegoLaLuz;
}
elsif ( $ac =~ /off-line/ ) {
    sefueLaLuz;
}

sub llegoLaLuz {

    #Notifico por correo que llego la luz
    my $mensaje = "Llego la Luz en $localidad";
    correo $mensaje, 'Llego la luz', 'info@covetel.com.ve';
    twitter $mensaje;
}

sub sefueLaLuz {
    my $mensaje = "oH! Se ha ido la luz en $localidad";
    correo $mensaje, 'Se fue la Luz', 'info@covetel.com.ve';
    twitter $mensaje;
	apagar; 
}

sub correo {
    $mailcfg{smtp} = [qw /mail.cantv.net rt.tachira.covetel.com.ve/];
    my ( $mensaje, $asunto, $para ) = @_;
    my %mail = (
        To      => $para,
        From    => 'acpibot@covetel.com.ve',
        Subject => $asunto,
        Message => $mensaje,
    );
    sendmail(%mail) or die $Mail::Sendmail::error;
}

sub twitter {
    my ( $mensaje ) = @_;
    $mensaje .= ' #covetel';
    $mensaje .= ' - ' . localtime;
    my $t = Net::Twitter::Lite->new(
        username => $twitter_user,
        password => $twitter_passwd,
    );
    my $result = eval { $t->update($mensaje) };
}

sub apagar {
	my @servidores = ('192.168.1.240');
	my $usuario = "acpibot";
	foreach my $servidor (@servidores) {		
		my $comando = "ssh -l $usuario $servidor 'sudo /sbin/shutdown -h now'"; 
		system($comando);
	}
}
1;
