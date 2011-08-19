use strict;
use warnings;

package Medical::OPCS4::Parser;
# ABSTRACT: A parser object.

use Text::CSV;
use Medical::OPCS4::Graph;

=head1 NAME

Medical::OPCS4::Parser - OPCS4 Parser object

=head1 METHODS

=head2 new

   Create a new parser object. 
   
   Do not use directly.

=cut

sub new {
   my $class = shift;
   my $self  = { };
   
   $self->{csv} = 
      Text::CSV->new({ 'sep_char' => "," });
   
   $self->{csv}->column_names( qw( opcs description) );
      
   $self->{g} =
      Medical::OPCS4::Graph->new;
   
   return bless $self, $class;
      
}

=head2 parse

   The main parser function. Accepts a tab separated file of OPCS4 codes
   along with their descriptions and parses it.

   Returns true on success and undef on failure.

=cut

sub parse {
   my $self     = shift;
   my $filename = shift;
   
   # UTF8 is needed as there is a single term with an accept character
   # in the term description:
   # M91.1	Juvenile osteochondrosis of head of femur [Legg-Calvé-Perthes]
   
   open my $io, "<:encoding(utf8)", $filename
      || die "$filename: $!";

   ##
   ## First pass: add all the nodes
      
   while ( my $rh = $self->{csv}->getline_hr( $io) ) {
      my $icd    = $rh->{icd};
      $self->{g}->add_vertex( $rh->{icd} );
      $self->{g}->set_vertex_attribute( $rh->{icd}, 'description', $rh->{description} );
   }
   
   ##   
   ## Second pass: add all the edges
   
   my @vertices = $self->{g}->vertices;
   
   foreach my $vertex ( @vertices ) {
         my $parent = $self->_get_parent( $vertex );
         $self->{g}->add_edge( $parent, $vertex );         
   }

   return $self->{g};
     
}

=head2 _get_parent

   Internal parser function used to discover the parent
   of each node. 
   
   Do not use directly.

=cut

sub _get_parent {
   my $self = shift;
   my $term = shift;

   if ( $term eq 'root' ) {
      return 'root';
   }

   my $length = length( $term );
   
   if ( $length == 5 ){
      return substr( $term, 0, 4 );
   } 
   
   elsif ( $length == 4){
      return substr($term, 0, 3);
   } 
   
   elsif ( $length == 3 ) { 
      return 'root'      
   }
   
}

=head2 graph

Returns the internal Medical::OPCS4::Graph object.

=cut

sub graph {
   my $self = shift;
   return $self->{g};
}

1;