/turf/unsimulated/floor
	name = "floor"
	icon = 'icons/turf/floors.dmi'
	icon_state = "Floor3"
	footstep_sounds = list(
	"human" = list('sound/effects/footstep/floor1.ogg','sound/effects/footstep/floor2.ogg','sound/effects/footstep/floor3.ogg','sound/effects/footstep/floor4.ogg','sound/effects/footstep/floor5.ogg'),
	"xeno"  = list('sound/effects/footstep/floor1.ogg','sound/effects/footstep/floor2.ogg','sound/effects/footstep/floor3.ogg','sound/effects/footstep/floor4.ogg','sound/effects/footstep/floor5.ogg')
	)

/turf/unsimulated/floor/grass
	name = "grass patch"
	icon_state = "grass1"

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/grass1.ogg','sound/effects/footstep/grass2.ogg','sound/effects/footstep/grass3.ogg','sound/effects/footstep/grass4.ogg'),
		"xeno"  = list('sound/effects/footstep/grass1.ogg','sound/effects/footstep/grass2.ogg','sound/effects/footstep/grass3.ogg','sound/effects/footstep/grass4.ogg')
	)

/turf/unsimulated/floor/grass/New()
	..()
	icon_state = "grass[rand(1,4)]"

/turf/unsimulated/floor/snow
	name = "snow"
	icon = 'icons/turf/snow.dmi'
	icon_state = "snow"
	footstep_sounds = list(
	"human" = list('sound/effects/footstep/carpet3.ogg','sound/effects/footstep/carpet5.ogg'),
	"xeno"  = list('sound/effects/footstep/carpet3.ogg','sound/effects/footstep/carpet5.ogg')
	)

/turf/unsimulated/floor/abductor
	name = "alien floor"
	icon_state = "alienpod1"

/turf/unsimulated/floor/abductor/New()
	..()
	icon_state = "alienpod[rand(1,9)]"

/turf/unsimulated/floor/vox
	icon_state = "dark"
	nitrogen = 100
	oxygen = 0

/turf/unsimulated/floor/carpet
	name = "Carpet"
	icon = 'icons/turf/floors/carpet.dmi'
	icon_state = "carpet"
	smooth = SMOOTH_TRUE
	canSmoothWith = null

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/carpet_human.ogg','sound/effects/footstep/carpet1.ogg','sound/effects/footstep/carpet2.ogg','sound/effects/footstep/carpet3.ogg','sound/effects/footstep/carpet4.ogg','sound/effects/footstep/carpet5.ogg'),
		"xeno"  = list('sound/effects/footstep/carpet_xeno.ogg')
	)

/turf/unsimulated/floor/wood
	icon_state = "wood"

	footstep_sounds = list(
		"human" = list('sound/effects/footstep/wood_all.ogg','sound/effects/footstep/wood1.ogg','sound/effects/footstep/wood2.ogg','sound/effects/footstep/wood3.ogg','sound/effects/footstep/wood4.ogg','sound/effects/footstep/wood5.ogg'), //@RonaldVanWonderen of Freesound.org
		"xeno"  = list('sound/effects/footstep/wood_all.ogg')  //@RonaldVanWonderen of Freesound.org
	)

/turf/unsimulated/floor/lava
	name = "lava"
	desc = "That looks... a bit dangerous"
	icon = 'icons/turf/floors/lava.dmi'
	icon_state = "smooth"
	smooth = SMOOTH_MORE
	canSmoothWith = list(/turf/unsimulated/floor/lava)
	var/lava_damage = 250
	var/lava_fire = 20
	light_range = 2
	light_color = "#FFC040"

/turf/unsimulated/floor/lava/Entered(mob/living/M, atom/OL, ignoreRest = 0)
	if(istype(M))
		M.apply_damage(lava_damage, BURN)
		M.adjust_fire_stacks(lava_fire)
		M.IgniteMob()

/turf/unsimulated/floor/lava/dense
	density = 1
