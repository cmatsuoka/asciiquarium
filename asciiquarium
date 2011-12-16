#!/usr/bin/env perl
#
#############################################################################
# Asciiquarium - An aquarium animation in ASCII art
#
# This program displays an aquarium/sea animation using ASCII art.
# It requires the module Term::Animation, which requires Curses. You
# can get both modules from http://search.cpan.org. Asciiquarium will
# only run on platforms with a curses library, so Windows is not supported.
#
# The current version of this program is available at:
#
# http://robobunny.com/projects/asciiquarium
#
#############################################################################
# Author:
#   Kirk Baucom <kbaucom@schizoid.com>
#
# Contributors:
#   Joan Stark: http://www.geocities.com/SoHo/7373/
#     most of the ASCII art
#
#   Claudio Matsuoka <cmatsuoka@gmail.com>
#     improved marine biodiversity (backported from the Asciiquarium Live
#     Wallaper for Android)
#     https://market.android.com/details?id=org.helllabs.android.asciiquarium
#
# License:
#
# Copyright (C) 2003 Kirk Baucom (kbaucom@schizoid.com)
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place - Suite 330, Boston, MA  02111-1307, USA.
#############################################################################

use Term::Animation 2.0;
use Term::Animation::Entity;
use Data::Dumper;
use Curses;
use Getopt::Std;
use strict;
use warnings;

my $version = "1.1";
my $new_fish = 1;
my $new_monster = 1;

our $opt_c;
getopts('c');

if ($opt_c) {			# 'classic' mode
	$new_fish = 0;
	$new_monster = 0;
}

my @random_objects = init_random_objects();

# the Z depth at which certain items occur
my %depth = (
	# no gui yet
	guiText		=> 0,
	gui		=> 1,

	# under water
	shark		=> 2,
	fish_start	=> 3,
	fish_end	=> 20,
	seaweed		=> 21, 
	castle		=> 22,

	# waterline
	water_line3	=> 2,
	water_gap3	=> 3,
	water_line2	=> 4,
	water_gap2	=> 5,
	water_line1	=> 6,
	water_gap1	=> 7,
	water_line0	=> 8,
	water_gap0	=> 9,
);

main();

####################### MAIN #######################

sub main {

	my $anim = Term::Animation->new();

	# set the wait time for getch
	halfdelay(1);
	#nodelay(1);

	$anim->color(1);

	my $start_time = time;
	my $paused = 0;
	while(1) {

		add_environment($anim);
		add_castle($anim);
		add_all_seaweed($anim);
		add_all_fish($anim);
		random_object(undef, $anim);
		
		$anim->redraw_screen();

		my $nexttime = 0;

		while(1) {
			my $in = lc(getch());

			if   ( $in eq 'q' ) { quit(); }   # Exit
			elsif( $in eq 'r' ) { last; }     # Redraw (will recreate all objects)
			elsif( $in eq 'p' ) { $paused = !$paused; }

			$anim->animate() unless($paused);
		}
		$anim->update_term_size();
		$anim->remove_all_entities();

	}

}

sub add_environment {
	my ($anim) = @_;

	my @water_line_segment = (
		q{~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~},
		q{^^^^ ^^^  ^^^   ^^^    ^^^^      },
		q{^^^^      ^^^^     ^^^    ^^     },
		q{^^      ^^^^      ^^^    ^^^^^^  }
	);

	# tile the segments so they stretch across the screen
	my $segment_size = length($water_line_segment[0]);
	my $segment_repeat = int($anim->width()/$segment_size) + 1;
	foreach my $i (0..$#water_line_segment) {
		$water_line_segment[$i] = $water_line_segment[$i]x$segment_repeat;
	}

	foreach my $i (0..$#water_line_segment) {
		$anim->new_entity(
			name		=> "water_seg_$i",
			type		=> "waterline",
			shape		=> $water_line_segment[$i],
			position	=> [ 0, $i+5, $depth{'water_line'  . $i} ],
			default_color	=> 'cyan',
			depth		=> 22,
			physical	=> 1,
		);
	}
}

sub add_castle {
	my ($anim) = @_;
	my $castle_image = q{
               T~~
               |
              /^\
             /   \
 _   _   _  /     \  _   _   _
[ ]_[ ]_[ ]/ _   _ \[ ]_[ ]_[ ]
|_=__-_ =_|_[ ]_[ ]_|_=-___-__|
 | _- =  | =_ = _    |= _=   |
 |= -[]  |- = _ =    |_-=_[] |
 | =_    |= - ___    | =_ =  |
 |=  []- |-  /| |\   |=_ =[] |
 |- =_   | =| | | |  |- = -  |
 |_______|__|_|_|_|__|_______|
};

	my $castle_mask = q{
                RR

              yyy
             y   y
            y     y
           y       y



              yyy
             yy yy
            y y y y
            yyyyyyy
};

	$anim->new_entity(
		name		=> "castle",
		shape		=> $castle_image,
		color		=> $castle_mask,
		position	=> [ $anim->width()-32, $anim->height()-13, $depth{'castle'} ],
		default_color	=> 'BLACK',
	);
}

sub add_all_seaweed {
	my ($anim) = @_;
	# figure out how many seaweed to add by the width of the screen
	my $seaweed_count = int($anim->width() / 15);
	for (1..$seaweed_count) {
		add_seaweed(undef, $anim);
	}
}

sub add_seaweed {
	my ($old_seaweed, $anim) = @_;
	my @seaweed_image = ('','');
	my $height = int(rand(4)) + 3;
	for my $i (1..$height) {
		my $left_side = $i%2;
		my $right_side = !$left_side;
		$seaweed_image[$left_side] .= "(\n";
		$seaweed_image[$right_side] .= " )\n";
	}
	my $x = int(rand($anim->width()-2)) + 1;
	my $y = $anim->height() - $height;
	my $anim_speed = rand(.05) + .25;
	$anim->new_entity(
		name		=> 'seaweed' . rand(1),
		shape		=> \@seaweed_image,
		position	=> [ $x, $y, $depth{'seaweed'} ],
		callback_args	=> [ 0, 0, 0, $anim_speed ],
		die_time	=> time() + int(rand(4*60)) + (8*60), # seaweed lives for 8 to 12 minutes
		death_cb	=> \&add_seaweed,
		default_color	=> 'green',
	);
}

# add an air bubble to a fish
sub add_bubble {
	my ($fish, $anim) = @_;

	my $cb_args = $fish->callback_args();
	my @fish_size = $fish->size();
	my @fish_pos = $fish->position();
	my @bubble_pos = @fish_pos;

	# moving right
	if($cb_args->[0] > 0) {
		$bubble_pos[0] += $fish_size[0];
	}
	$bubble_pos[1] += int($fish_size[1] / 2);
	# bubble always goes on top of the fish
	$bubble_pos[2]--;

	$anim->new_entity(
		shape		=> [ '.', 'o', 'O', 'O', 'O' ],
		type		=> 'bubble',
		position	=> \@bubble_pos,
		callback_args	=> [ 0, -1, 0, .1 ],
		die_offscreen	=> 1,
		physical	=> 1,
		coll_handler	=> \&bubble_collision, 
		default_color	=> 'CYAN',
	);
}

sub bubble_collision {
	my ($bubble, $anim) = @_;
	my $collisions = $bubble->collisions();
	foreach my $col_obj (@{$collisions}) {
		if($col_obj->type eq 'waterline') {
			$bubble->kill();
			last;
		}
	}

}

sub add_all_fish {
	my ($anim) = @_;
	# figure out how many fish to add by the size of the screen,
	# minus the stuff above the water
	my $screen_size = ($anim->height() - 9) * $anim->width();
	my $fish_count = int($screen_size / 350);
	for (1..$fish_count) {
		add_fish(undef, $anim);
	}
}

sub add_fish {
	my @parm = @_;

	if ($new_fish) {
		if (int(rand(12)) > 8) {
			add_new_fish(@parm);
		} else {
			add_old_fish(@parm);
		}
	} else {
		add_old_fish(@parm);
	}
}

sub add_new_fish {
	my ($old_fish, $anim) = @_;
	my @fish_image = (

q{
   \\
  / \\
>=_('>
  \\_/
   /
},
q{
   1
  1 1
663745
  111
   3
},
q{
  /
 / \\
<')_=<
 \\_/
  \\
},
q{
  2
 111
547366
 111
  3
},
q{
     ,
     \}\\
\\  .'  `\\
\}\}<   ( 6>
/  `,  .'
     \}/
     '
},
q{
     2
     22
6  11  11
661   7 45
6  11  11
     33
     3
},
q{
    ,
   /\{
 /'  `.  /
<6 )   >\{\{
 `.  ,'  \\
   \\\{
    `
},
q{
    2
   22
 11  11  6
54 7   166
 11  11  6
   33
    3
},
q{
            \\'`.
             )  \\
(`.??????_.-`' ' '`-.
 \\ `.??.`        (o) \\_
  >  ><     (((       (
 / .`??`._      /_|  /'
(.`???????`-. _  _.-`
            /__/'

},
q{
            1111
             1  1
111      11111 1 1111
 1 11  11        141 11
  1  11     777       5
 1 11  111      333  11
111       111 1  1111
            11111

},
q{
       .'`/
      /  (
  .-'` ` `'-._??????.')
_/ (o)        '.??.' /
)       )))     ><  <
`\\  |_\\      _.'??'. \\
  '-._  _ .-'???????'.)
      `\\__\\
},
q{
       1111
      1  1
  1111 1 11111      111
11 141        11  11 1
5       777     11  1
11  333      111  11 1
  1111  1 111       111
      11111
},
q{
       ,--,_
__    _\\.---'-.
\\ '.-"     // o\\
/_.'-._    \\\\  /
       `"--(/"`
},
q{
       22222
66    121111211
6 6111     77 41
6661111    77  1
       11113311
},
q{
    _,--,
 .-'---./_    __
/o \\\\     "-.' /
\\  //    _.-'._\\
 `"\\)--"`
},
q{
    22222
 112111121    66
14 77     1116 6
1  77    1111666
 11331111
},
);

	add_fish_entity($anim, @fish_image);
}

sub add_old_fish {
	my ($old_fish, $anim) = @_;
	my @fish_image = (

q{
       \
     ...\..,
\  /'       \
 >=     (  ' >
/  \      / /
    `"'"'/''
},
q{
       2
     1112111
6  11       1
 66     7  4 5
6  1      3 1
    11111311
},
q{
      /
  ,../...
 /       '\  /
< '  )     =<
 \ \      /  \
  `'\'"'"'
},
q{
      2
  1112111
 1       11  6
5 4  7     66
 1 3      1  6
  11311111
},
q{
    \
\ /--\
>=  (o>
/ \__/
    /
},
q{
    2
6 1111
66  745
6 1111
    3
},
q{
  /
 /--\ /
<o)  =<
 \__/ \
  \
},
q{
  2
 1111 6
547  66
 1111 6
  3
},
q{
       \:.
\;,   ,;\\\\\,,
  \\\\\;;:::::::o
  ///;;::::::::<
 /;` ``/////``
},
q{
       222
666   1122211
  6661111111114
  66611111111115
 666 113333311
},
q{
      .:/
   ,,///;,   ,;/
 o:::::::;;///
>::::::::;;\\\\\
  ''\\\\\\\\\'' ';\
},
q{
      222
   1122211   666
 4111111111666
51111111111666
  113333311 666
},
q{
  __
><_'>
   '
},
q{
  11
61145
   3
},
q{
 __
<'_><
 `
},
q{
 11
54116
 3
},
q{
   ..\,
>='   ('>
  '''/''
},
q{
   1121
661   745
  111311
},
q{
  ,/..
<')   `=<
 ``\```
},
q{
  1211
547   166
 113111
},
q{
   \
  / \
>=_('>
  \_/
   /
},
q{
   2
  1 1
661745
  111
   3
},
q{
  /
 / \
<')_=<
 \_/
  \
},
q{
  2
 1 1
547166
 111
  3
},
q{
  ,\
>=('>
  '/
},
q{
  12
66745
  13
},
q{
 /,
<')=<
 \`
},
q{
 21
54766
 31
},
q{
  __
\/ o\
/\__/
},
q{
  11
61 41
61111
},
q{
 __
/o \/
\__/\
},
q{
 11
14 16
11116
},
);

	add_fish_entity($anim, @fish_image);
}

sub add_fish_entity {
	my $anim = shift;
	my @fish_image = @_;
	
	# 1: body
	# 2: dorsal fin
	# 3: flippers
	# 4: eye
	# 5: mouth
	# 6: tailfin
	# 7: gills

	my @colors = ('c','C','r','R','y','Y','b','B','g','G','m','M');
	my $fish_num = int(rand($#fish_image/2));
	my $fish_index = $fish_num * 2;
	my $speed = rand(2) + .25;
	my $depth = int(rand($depth{'fish_end'} - $depth{'fish_start'})) + $depth{'fish_start'};
	my $color_mask = $fish_image[$fish_index+1];
	$color_mask =~ s/4/W/gm;
	$color_mask = rand_color($color_mask);

	if($fish_num % 2) {
		$speed *= -1;
	}
	my $fish_object = Term::Animation::Entity->new(
		type		=> 'fish',
		shape		=> $fish_image[$fish_index],
		auto_trans	=> 1,
		color		=> $color_mask,
		position	=> [ 0, 0, $depth ],
		callback	=> \&fish_callback,
		callback_args	=> [ $speed, 0, 0 ],
		die_offscreen	=> 1,
		death_cb	=> \&add_fish,
		physical	=> 1,
		coll_handler	=> \&fish_collision,
	);

	my $max_height = 9;
	my $min_height = $anim->height() - $fish_object->{'HEIGHT'};
	$fish_object->{'Y'} = int(rand($min_height - $max_height)) + $max_height;
	if($fish_num % 2) {
		$fish_object->{'X'} = $anim->width()-2;
	} else {
		$fish_object->{'X'} = 1 - $fish_object->{'WIDTH'};
	}
	$anim->add_entity($fish_object);
}

sub fish_callback {
	my ($fish, $anim) = @_;
	if(int(rand(100)) > 97) {
		add_bubble($fish, $anim);
	}
	return $fish->move_entity($anim);
}
sub fish_collision {
	my ($fish, $anim) = @_;
	my $collisions = $fish->collisions();
	foreach my $col_obj (@{$collisions}) {
		if($col_obj->type eq 'teeth' && $fish->height <= 5) {
			add_splat($anim, $col_obj->position());
			$fish->kill();
			last;
		}
	}
}

sub add_splat {
	my ($anim, $x, $y, $z) = @_;
	my @splat_image = (
q#

   .
  ***
   '

#,
q#

 ",*;`
 "*,**
 *"'~'

#,
q#
  , ,
 " ","'
 *" *'"
  " ; .

#,
q#
* ' , ' `
' ` * . '
 ' `' ",'
* ' " * .
" * ', '
#,
);

	$anim->new_entity(
		shape		=> \@splat_image,
		position	=> [ $x - 4, $y - 2, $z-2 ],
		default_color	=> 'RED',
		callback_args	=> [ 0, 0, 0, .25 ],
		transparent	=> ' ',
		die_frame	=> 15,
	);
}

sub add_shark {
	my ($old_ent, $anim) = @_;
	my @shark_image = (
q#
                              __
                             ( `\
  ,??????????????????????????)   `\
;' `.????????????????????????(     `\__
 ;   `.?????????????__..---''          `~~~~-._
  `.   `.____...--''                       (b  `--._
    >                     _.-'      .((      ._     )
  .`.-`--...__         .-'     -.___.....-(|/|/|/|/'
 ;.'?????????`. ...----`.___.',,,_______......---'
 '???????????'-'
#,
q#
                     __
                    /' )
                  /'   (??????????????????????????,
              __/'     )????????????????????????.' `;
      _.-~~~~'          ``---..__?????????????.'   ;
 _.--'  b)                       ``--...____.'   .'
(     _.      )).      `-._                     <
 `\|\|\|\|)-.....___.-     `-.         __...--'-.'.
   `---......_______,,,`.___.'----... .'?????????`.;
                                     `-`???????????`
#,
  );


	my @shark_mask = (
q#





                                           cR
 
                                          cWWWWWWWW


#,
q#





        Rc

  WWWWWWWWc


#,
  );

	my $dir = int(rand(2));
	my $x = -53;
	my $y = int(rand($anim->height() - (10 + 9))) + 9;
	my $teeth_x = -9;
	my $teeth_y = $y + 7;
	my $speed = 2;
	if($dir) {
		$speed *= -1;
		$x = $anim->width()-2;
		$teeth_x = $x + 9;
	}

	$anim->new_entity(
		type		=> 'teeth',
		shape		=> "*",
		position	=> [ $teeth_x, $teeth_y, $depth{'shark'}+1 ],
		depth		=> $depth{'fish_end'} - $depth{'fish_start'},
		callback_args	=> [ $speed, 0, 0 ],
		physical	=> 1,
	);

	$anim->new_entity(
		type		=> "shark",
		color		=> $shark_mask[$dir],
		shape		=> $shark_image[$dir],
		auto_trans	=> 1,
		position	=> [ $x, $y, $depth{'shark'} ],
		default_color	=> 'WHITE',
		callback_args	=> [ $speed, 0, 0 ],
		die_offscreen	=> 1,
		death_cb	=> \&shark_death,
		default_color	=> 'CYAN',
	);

}

# when a shark dies, kill the "teeth" too, the associated
# entity that does the actual collision
sub shark_death {
	my ($shark, $anim) = @_;
	my $teeth = $anim->get_entities_of_type('teeth');
	foreach my $obj (@{$teeth}) {
		$anim->del_entity($obj);
	}
	random_object($shark, $anim);
}

sub add_ship {
	my ($old_ent, $anim) = @_;

	my @ship_image = (	
q{
     |    |    |
    )_)  )_)  )_)
   )___))___))___)\
  )____)____)_____)\\\
_____|____|____|____\\\\\__
\                   /
},
q{
         |    |    |
        (_(  (_(  (_(
      /(___((___((___(
    //(_____(____(____(
__///____|____|____|_____
    \                   /
});

	my @ship_mask = (
q{
     y    y    y

                  w
                   ww
yyyyyyyyyyyyyyyyyyyywwwyy
y                   y
},
q{
         y    y    y

      w
    ww
yywwwyyyyyyyyyyyyyyyyyyyy
    y                   y
});

	my $dir = int(rand(2));
	my $x = -24;
	my $speed = 1;
	if($dir) {
		$speed *= -1;
		$x = $anim->width()-2;
	}

	$anim->new_entity(
		color		=> $ship_mask[$dir],
		shape		=> $ship_image[$dir],
		auto_trans	=> 1,
		position	=> [ $x, 0, $depth{'water_gap1'} ],
		default_color	=> 'WHITE',
		callback_args	=> [ $speed, 0, 0 ],
		die_offscreen	=> 1,
		death_cb	=> \&random_object,
	);
}

sub add_whale {
	my ($old_ent, $anim) = @_;
	my @whale_image = (
q{
        .-----:
      .'       `.
,????/       (o) \
\`._/          ,__)
},
q{
    :-----.
  .'       `.
 / (o)       \????,
(__,          \_.'/
});
	my @whale_mask = (
q{
             C C
           CCCCCCC
           C  C  C
        BBBBBBB
      BB       BB
B    B       BWB B
BBBBB          BBBB
},
q{
   C C
 CCCCCCC
 C  C  C
    BBBBBBB
  BB       BB
 B BWB       B    B
BBBB          BBBBB
}
);

	my @water_spout = (
q{


   :
},q{

   :
   :
},q{
  . .
  -:-
   :
},q{
  . .
 .-:-.
   :
},q{
  . .
'.-:-.`
'  :  '
},q{

 .- -.
;  :  ;
},q{


;     ;
});


	my $dir = int(rand(2));
	my $x;
	my $speed = 1;
	my $spout_align;
	my @whale_anim;
	my @whale_anim_mask;

	if($dir) {
		$spout_align = 1;
		$speed *= -1;
		$x = $anim->width()-2;
	} else {
		$spout_align = 11;
		$x = -18;
	}
	
	# no water spout
	for (1..5) {
		push(@whale_anim, "\n\n\n" . $whale_image[$dir]);
		push(@whale_anim_mask, $whale_mask[$dir]);
	}

	# animate water spout
	foreach my $spout_frame (@water_spout) {
		my $whale_frame = $whale_image[$dir];
		my $aligned_spout_frame;
		$aligned_spout_frame = join("\n" . ' 'x$spout_align, split("\n", $spout_frame));
		$whale_frame = $aligned_spout_frame . $whale_image[$dir];
		push(@whale_anim, $whale_frame);
		push(@whale_anim_mask, $whale_mask[$dir]);
	}

	$anim->new_entity(
		color		=> \@whale_anim_mask,
		shape		=> \@whale_anim,
		auto_trans	=> 1,
		position	=> [ $x, 0, $depth{'water_gap2'} ],
		default_color	=> 'WHITE',
		callback_args	=> [ $speed, 0, 0, 1 ],
		die_offscreen	=> 1,
		death_cb	=> \&random_object,
	);

}

sub add_monster {
	my @parm = @_;

	if ($new_monster) {
		add_new_monster(@parm);
	} else {
		add_old_monster(@parm);
	}
}

sub add_new_monster {
	my ($old_ent, $anim) = @_;
	my @monster_image = (
		[
"
         _???_?????????????????????_???_???????_a_a
       _{.`=`.}_??????_???_??????_{.`=`.}_????{/ ''\\_
 _????{.'  _  '.}????{.`'`.}????{.'  _  '.}??{|  ._oo)
{ \\??{/  .'?'.  \\}??{/ .-. \\}??{/  .'?'.  \\}?{/  |
",
"
                      _???_????????????????????_a_a
  _??????_???_??????_{.`=`.}_??????_???_??????{/ ''\\_
 { \\????{.`'`.}????{.'  _  '.}????{.`'`.}????{|  ._oo)
  \\ \\??{/ .-. \\}??{/  .'?'.  \\}??{/ .-. \\}???{/  |
"
	],[
"
   a_a_???????_???_?????????????????????_???_
 _/'' \\}????_{.`=`.}_??????_???_??????_{.`=`.}_
(oo_.  |}??{.'  _  '.}????{.`'`.}????{.'  _  '.}????_
    |  \\}?{/  .'?'.  \\}??{/ .-. \\}??{/  .'?'.  \\}??/ }
",
"
   a_a_????????????????????_   _
 _/'' \\}??????_???_??????_{.`=`.}_??????_???_??????_
(oo_.  |}????{.`'`.}????{.'  _  '.}????{.`'`.}????/ }
    |  \\}???{/ .-. \\}??{/  .'?'.  \\}??{/ .-. \\}??/ /
"
	]);

	my @monster_mask = (
q{                                                W W



},q{
   W W



});
	my $dir = int(rand(2));
	my $x;
	my $speed = 2;
	if($dir) {
		$speed *= -1;
		$x = $anim->width()-2;
	} else {
		$x = -54
	}
	my @monster_anim_mask;
	for(1..2) { push(@monster_anim_mask, $monster_mask[$dir]); }

	$anim->new_entity(
		shape		=> $monster_image[$dir],
		auto_trans	=> 1,
		color		=> \@monster_anim_mask,
		position	=> [ $x, 2, $depth{'water_gap2'} ],
		callback_args	=> [ $speed, 0, 0, .25 ],
		death_cb	=> \&random_object,
		die_offscreen	=> 1,
		default_color	=> 'GREEN',
	);
}

sub add_old_monster {
	my ($old_ent, $anim) = @_;
	my @monster_image = (
		[
q{
                                                          ____
            __??????????????????????????????????????????/   o  \
          /    \????????_?????????????????????_???????/     ____ >
  _??????|  __  |?????/   \????????_????????/   \????|     |
 | \?????|  ||  |????|     |?????/   \?????|     |???|     |
},q{
                                                          ____
                                             __?????????/   o  \
             _?????????????????????_???????/    \?????/     ____ >
   _???????/   \????????_????????/   \????|  __  |???|     |
  | \?????|     |?????/   \?????|     |???|  ||  |???|     |
},q{
                                                          ____
                                  __????????????????????/   o  \
 _??????????????????????_???????/    \????????_???????/     ____ >
| \??????????_????????/   \????|  __  |?????/   \????|     |
 \ \???????/   \?????|     |???|  ||  |????|     |???|     |
},q{
                                                          ____
                       __???????????????????????????????/   o  \
  _??????????_???????/    \????????_??????????????????/     ____ >
 | \???????/   \????|  __  |?????/   \????????_??????|     |
  \ \?????|     |???|  ||  |????|     |?????/   \????|     |
}
	],[
q{
    ____
  /  o   \??????????????????????????????????????????__
< ____     \???????_?????????????????????_????????/    \
      |     |????/   \????????_????????/   \?????|  __  |??????_
      |     |???|     |?????/   \?????|     |????|  ||  |?????/ |
},q{
    ____
  /  o   \?????????__
< ____     \?????/    \???????_?????????????????????_
      |     |???|  __  |????/   \????????_????????/   \???????_
      |     |???|  ||  |???|     |?????/   \?????|     |?????/ |
},q{
    ____
  /  o   \????????????????????__
< ____     \???????_????????/    \???????_??????????????????????_
      |     |????/   \?????|  __  |????/   \????????_??????????/ |
      |     |???|     |????|  ||  |???|     |?????/   \???????/ /
},q{
    ____
  /  o   \???????????????????????????????__
< ____     \??????????????????_????????/    \???????_??????????_
      |     |??????_????????/   \?????|  __  |????/   \???????/ |
      |     |????/   \?????|     |????|  ||  |???|     |?????/ /
}
	]);

	my @monster_mask = (
q{

                                                            W



},q{

     W



});
	my $dir = int(rand(2));
	my $x;
	my $speed = 2;
	if($dir) {
		$speed *= -1;
		$x = $anim->width()-2;
	} else {
		$x = -64
	}
	my @monster_anim_mask;
	for(1..4) { push(@monster_anim_mask, $monster_mask[$dir]); }

	$anim->new_entity(
		shape		=> $monster_image[$dir],
		auto_trans	=> 1,
		color		=> \@monster_anim_mask,
		position	=> [ $x, 2, $depth{'water_gap2'} ],
		callback_args	=> [ $speed, 0, 0, .25 ],
		death_cb	=> \&random_object,
		die_offscreen	=> 1,
		default_color	=> 'GREEN',
	);
}

sub add_big_fish {
	my @parm = @_;

	if ($new_fish) {
		if (int(rand(3)) > 1) {
			add_big_fish_2(@parm);
		} else {
			add_big_fish_1(@parm);
		}
	} else {
		add_big_fish_1(@parm);
	}
}

sub add_big_fish_1 {
	my ($old_ent, $anim) = @_;

	my @big_fish_image = (
q{
 ______
`""-.  `````-----.....__
     `.  .      .       `-.
       :     .     .       `.
 ,?????:   .    .          _ :
: `.???:                  (@) `._
 `. `..'     .     =`-.       .__)
   ;     .        =  ~  :     .-"
 .' .'`.   .    .  =.-'  `._ .'
: .'???:               .   .'
 '???.'  .    .     .   .-'
   .'____....----''.'=.'
   ""?????????????.'.'
               ''"'`
},q{
                           ______
          __.....-----'''''  .-""'
       .-'       .      .  .'
     .'       .     .     :
    : _          .    .   :?????,
 _.' (@)                  :???.' :
(__.       .-'=     .     `..' .'
 "-.     :  ~  =        .     ;
   `. _.'  `-.=  .    .   .'`. `.
     `.   .               :???`. :
       `-.   .     .    .  `.???`
          `.=`.``----....____`.
            `.`.?????????????""
              '`"``
});

	my @big_fish_mask = (
q{
 111111
11111  11111111111111111
     11  2      2       111
       1     2     2       11
 1     1   2    2          1 1
1 11   1                  1W1 111
 11 1111     2     1111       1111
   1     2        1  1  1     111
 11 1111   2    2  1111  111 11
1 11   1               2   11
 1   11  2    2     2   111
   111111111111111111111
   11             1111
               11111
},q{
                           111111
          11111111111111111  11111
       111       2      2  11
     11       2     2     1
    1 1          2    2   1     1
 111 1W1                  1   11 1
1111       1111     2     1111 11
 111     1  1  1        2     1
   11 111  1111  2    2   1111 11
     11   2               1   11 1
       111   2     2    2  11   1
          111111111111111111111
            1111             11
              11111
});


	my $dir = int(rand(2));
	my $x;
	my $speed = 3;
	if($dir) {
		$x = $anim->width()-1;
		$speed *= -1;
	} else {
		$x = -34;
	}
	my $max_height = 9;
	my $min_height = $anim->height() - 15;
	my $y = int(rand($min_height - $max_height)) + $max_height;
	my $color_mask = rand_color($big_fish_mask[$dir]);
	$anim->new_entity(
		shape		=> $big_fish_image[$dir],
		auto_trans	=> 1,
		color		=> $color_mask,
		position	=> [ $x, $y, $depth{'shark'} ],
		callback_args	=> [ $speed, 0, 0 ],
		death_cb	=> \&random_object,
		die_offscreen	=> 1,
		default_color	=> 'YELLOW',
	);

}

sub add_big_fish_2 {
	my ($old_ent, $anim) = @_;

	my @big_fish_image = (
q{
                _ _ _
             .='\\ \\ \\`"=,
           .'\\ \\ \\ \\ \\ \\ \\
\\'=._?????/ \\ \\ \\_\\_\\_\\_\\_\\
\\'=._'.??/\\ \\,-"`- _ - _ - '-.
  \\`=._\\|'.\\/- _ - _ - _ - _- \\
  ;"= ._\\=./_ -_ -_ \{`"=_    @ \\
   ;="_-_=- _ -  _ - \{"=_"-     \\
   ;_=_--_.,          \{_.='   .-/
  ;.="` / ';\\        _.     _.-`
  /_.='/ \\/ /;._ _ _\{.-;`/"`
/._=_.'???'/ / / / /\{.= /
/.=' ??????`'./_/_.=`\{_/
},q{
            _ _ _
        ,="`/ / /'=.
       / / / / / / /'.
      /_/_/_/_/_/ / / \\?????_.='/
   .-' - _ - _ -`"-,/ /\\??.'_.='/
  / -_ - _ - _ - _ -\\/.'|/_.=`/
 / @    _="`\} _- _- _\\.=/_. =";
/     -"_="\} - _  - _ -=_-_"=;
\\-.   '=._\}          ,._--_=_;
 `-._     ._        /;' \\ `"=.;
     `"\\`;-.\}_ _ _.;\\ \\/ \\'=._\\
        \\ =.\}\\ \\ \\ \\ \\'???'._=_.\\
         \\_\}`=._\\_\\.'`???????'=.\\
});

	my @big_fish_mask = (
q{
                1 1 1
             1111 1 11111
           111 1 1 1 1 1 1
11111     1 1 1 11111111111
1111111  11 111112 2 2 2 2 111
  111111111112 2 2 2 2 2 2 22 1
  111 1111 12 22 22 11111    W 1
   11111112 2 2  2 2 111111     1
   111111111          11111   111
  11111 11111        11     1111
  111111 11 1111 1 111111111
1111111   11 1 1 1 1111 1
1111       1111111111111
},q{
            1 1 1
        11111 1 1111
       1 1 1 1 1 1 111
      11111111111 1 1 1     11111
   111 2 2 2 2 211111 11  1111111
  1 22 2 2 2 2 2 2 211111111111
 1 W    11111 22 22 2111111 111
1     111111 2 2  2 2 21111111
111   11111          111111111
 1111     11        111 1 11111
     111111111 1 1111 11 111111
        1 1111 1 1 1 11   1111111
         1111111111111       1111
});

	my $dir = int(rand(2));
	my $x;
	my $speed = 2.5;
	if($dir) {
		$x = $anim->width()-1;
		$speed *= -1;
	} else {
		$x = -33;
	}
	my $max_height = 9;
	my $min_height = $anim->height() - 14;
	my $y = int(rand($min_height - $max_height)) + $max_height;
	my $color_mask = rand_color($big_fish_mask[$dir]);
	$anim->new_entity(
		shape		=> $big_fish_image[$dir],
		auto_trans	=> 1,
		color		=> $color_mask,
		position	=> [ $x, $y, $depth{'shark'} ],
		callback_args	=> [ $speed, 0, 0 ],
		death_cb	=> \&random_object,
		die_offscreen	=> 1,
		default_color	=> 'YELLOW',
	);
}

sub init_random_objects {
	#return ( \&add_shark );
	return (
		\&add_ship,
		\&add_whale,
		\&add_monster,
		\&add_big_fish,
		\&add_shark,
	);
}

# add one of the random objects to the screen
sub random_object {
	my ($dead_object, $anim) = @_;
	my $sub = int(rand(scalar(@random_objects)));
	$random_objects[$sub]->($dead_object, $anim);
}

sub dprint {
	open(D, ">>", "debug");
	print D @_, "\n";
	close(D);
}

sub sighandler {
	my ($sig) = @_;
	if($sig eq 'INT') { quit(); }
	elsif($sig eq 'WINCH') {
		# ignore SIGWINCH, only redraw when requested
	}
	else { quit("Exiting with SIG$sig"); }
}

sub quit {
	my ($mesg) = @_;
	print STDERR $mesg, "\n" if(defined($mesg));
	exit;
}


sub initialize {
	# this may be paranoid, but i don't want to leave
	# the user's terminal in a state that they might not
	# know how to fix if we die badly
	foreach my $sig (keys %SIG) {
		$SIG{$sig} = 'sighandler' unless(defined($SIG{$sig}));
	}
}


sub center {
	my ($width, $mesg) = @_;
	my $l = length($mesg);
	if($l < $width) {
		return ' 'x(int(($width - length($mesg))/2)) . $mesg;
	}
	elsif($l > $width) {
		return(substr($mesg, 0, ($width - ($l + 3))) . "...");
	}
	else {
		return $mesg;
	}
}

sub rand_color {
	my ($color_mask) = @_;
	my @colors = ('c','C','r','R','y','Y','b','B','g','G','m','M');
	foreach my $i (1..9) {
		my $color = $colors[int(rand($#colors))];
		$color_mask =~ s/$i/$color/gm;
	}
	return $color_mask;
}

sub VERSION_MESSAGE {
	print "asciiquarium $version\n";
	exit;
}
