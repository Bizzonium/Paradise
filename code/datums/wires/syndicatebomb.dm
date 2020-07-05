/datum/wires/syndicatebomb
	random = TRUE
	holder_type = /obj/machinery/syndicatebomb
	wire_count = 5

#define BOMB_WIRE_BOOM 1			// Explodes if pulsed or cut while active, defuses a bomb that isn't active on cut
#define BOMB_WIRE_UNBOLT 2		// Unbolts the bomb if cut, hint on pulsed
#define BOMB_WIRE_DELAY 4		// Raises the timer on pulse, does nothing on cut
#define BOMB_WIRE_PROCEED 8		// Lowers the timer, explodes if cut while the bomb is active
#define BOMB_WIRE_ACTIVATE 16	// Will start a bombs timer if pulsed, will hint if pulsed while already active, will stop a timer a bomb on cut

/datum/wires/syndicatebomb/GetWireName(index)
	switch(index)
		if(BOMB_WIRE_BOOM)
			return "Взорвать"

		if(BOMB_WIRE_UNBOLT)
			return "Разболтировать"

		if(BOMB_WIRE_DELAY)
			return "Отложить"

		if(BOMB_WIRE_PROCEED)
			return "Преступить"

		if(BOMB_WIRE_ACTIVATE)
			return "Активировать"

/datum/wires/syndicatebomb/CanUse(mob/living/L)
	var/obj/machinery/syndicatebomb/P = holder
	if(P.open_panel)
		return TRUE
	return FALSE

/datum/wires/syndicatebomb/UpdatePulsed(index)
	var/obj/machinery/syndicatebomb/B = holder
	switch(index)
		if(BOMB_WIRE_BOOM)
			if(B.active)
				holder.visible_message("<span class='danger'>[bicon(B)] Звучит тревога! Она начала-</span>")
				B.explode_now = TRUE
		if(BOMB_WIRE_UNBOLT)
			holder.visible_message("<span class='notice'>[bicon(holder)] Болты вращаются на месте на мгновение.</span>")
		if(BOMB_WIRE_DELAY)
			if(B.delayedbig)
				holder.visible_message("<span class='notice'>[bicon(B)] Бомба уже отложена.</span>")
			else
				holder.visible_message("<span class='notice'>[bicon(B)] Бомба чирикает.</span>")
				playsound(B, 'sound/machines/chime.ogg', 30, 1)
				B.detonation_timer += 300
				B.delayedbig = TRUE
		if(BOMB_WIRE_PROCEED)
			holder.visible_message("<span class='danger'>[bicon(B)] Бомба зловеще гудит!</span>")
			playsound(B, 'sound/machines/buzz-sigh.ogg', 30, 1)
			var/seconds = B.seconds_remaining()
			if(seconds >= 61) // Long fuse bombs can suddenly become more dangerous if you tinker with them.
				B.detonation_timer = world.time + 600
			else if(seconds >= 21)
				B.detonation_timer -= 100
			else if(seconds >= 11) // Both to prevent negative timers and to have a little mercy.
				B.detonation_timer = world.time + 100
		if(BOMB_WIRE_ACTIVATE)
			if(!B.active && !B.defused)
				holder.visible_message("<span class='danger'>[bicon(B)] Вы слышите, как бомба начинает тикать!</span>")
				B.activate()
				B.update_icon()
			else if(B.delayedlittle)
				holder.visible_message("<span class='notice'>[bicon(B)] Ничего не произошло.</span>")
			else
				holder.visible_message("<span class='notice'>[bicon(B)] Бомба, кажется, колеблется на мгновение.</span>")
				B.detonation_timer += 100
				B.delayedlittle = TRUE
	..()

/datum/wires/syndicatebomb/UpdateCut(index, mended)
	var/obj/machinery/syndicatebomb/B = holder
	switch(index)
		if(BOMB_WIRE_BOOM)
			if(mended)
				B.defused = FALSE // Cutting and mending all the wires of an inactive bomb will thus cure any sabotage.
			else
				if(B.active)
					holder.visible_message("<span class='danger'>[bicon(B)] Звучит тревога! Она начала-</span>")
					B.explode_now = TRUE
				else
					B.defused = TRUE
		if(BOMB_WIRE_UNBOLT)
			if(!mended && B.anchored)
				holder.visible_message("<span class='notice'>[bicon(B)] Болты поднимаются из земли!</span>")
				playsound(B, 'sound/effects/stealthoff.ogg', 30, 1)
				B.anchored = FALSE
		if(BOMB_WIRE_PROCEED)
			if(!mended && B.active)
				holder.visible_message("<span class='danger'>[bicon(B)] Звучит тревога! Она начала-</span>")
				B.explode_now = TRUE
		if(BOMB_WIRE_ACTIVATE)
			if(!mended && B.active)
				holder.visible_message("<span class='notice'>[bicon(B)] Таймер остановился! Бомба была обезврежена!</span>")
				B.active = FALSE
				B.defused = TRUE
				B.update_icon()
	..()
