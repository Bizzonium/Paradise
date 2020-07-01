/datum/disease/anxiety
	name = "Тяжелая тревога"
	form = "Infection"
	max_stages = 4
	spread_text = "On contact"
	spread_flags = CONTACT_GENERAL
	cure_text = "Ethanol"
	cures = list("ethanol")
	agent = "Excess Lepidopticides"
	viable_mobtypes = list(/mob/living/carbon/human, /mob/living/carbon/human/monkey)
	desc = "Если оставить без лечения, субъект будет изрыгать бабочками."
	severity = MEDIUM

/datum/disease/anxiety/stage_act()
	..()
	switch(stage)
		if(2) //also changes say, see say.dm
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Вы чувствуете беспокойство.</span>")
		if(3)
			if(prob(10))
				to_chat(affected_mob, "<span class='notice'>Ваш живот дрожит.</span>")
			if(prob(5))
				to_chat(affected_mob, "<span class='notice'>Вы чувствуете панику.</span>")
			if(prob(2))
				to_chat(affected_mob, "<span class='danger'>Вы охвачены паникой!</span>")
				affected_mob.AdjustConfused(rand(2,3))
		if(4)
			if(prob(10))
				to_chat(affected_mob, "<span class='danger'>Вы чувствуете бабочек в животе</span>")
			if(prob(5))
				affected_mob.visible_message("<span class='danger'>[affected_mob] спотыкается в панике.</span>", \
												"<span class='userdanger'>У вас приступ паники!</span>")
				affected_mob.AdjustConfused(rand(6,8))
				affected_mob.AdjustJitter(rand(6,8))
			if(prob(2))
				affected_mob.visible_message("<span class='danger'>[affected_mob] выкашливает бабочек!</span>", \
													"<span class='userdanger'>Вы выкашливаете бабочек!</span>")
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
				new /mob/living/simple_animal/butterfly(affected_mob.loc)
	return
