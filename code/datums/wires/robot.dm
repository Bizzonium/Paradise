/datum/wires/robot
	random = 1
	holder_type = /mob/living/silicon/robot
	wire_count = 5

// /vg/ ordering

#define BORG_WIRE_MAIN_POWER 1 // The power wires do nothing whyyyyyyyyyyyyy
#define BORG_WIRE_LOCKED_DOWN 2
#define BORG_WIRE_CAMERA 4
#define BORG_WIRE_AI_CONTROL 8  // Not used on MoMMIs
#define BORG_WIRE_LAWCHECK 16 // Not used on MoMMIs

/datum/wires/robot/GetWireName(index)
	switch(index)
		if(BORG_WIRE_MAIN_POWER)
			return "Основное питание"

		if(BORG_WIRE_LOCKED_DOWN)
			return "Локдаун"

		if(BORG_WIRE_CAMERA)
			return "Камера"

		if(BORG_WIRE_AI_CONTROL)
			return "Управление ИИ"

		if(BORG_WIRE_LAWCHECK)
			return "Проверка законов"

/datum/wires/robot/get_status()
	. = ..()
	var/mob/living/silicon/robot/R = holder
	. += "Индикатор синхронизации законов [R.lawupdate ? "включен" : "отключен"]."
	. += "Индикатор подключения ИИ [R.connected_ai ? "включен" : "отключен"]."
	. += "Индикатор камеры [(R.camera && R.camera.status == 1) ? "включен" : "отключен"]."
	. += "Индикатор локдауна [R.lockcharge ? "включен" : "отключен"]."

/datum/wires/robot/UpdateCut(index, mended)

	var/mob/living/silicon/robot/R = holder
	switch(index)
		if(BORG_WIRE_LAWCHECK) //Cut the law wire, and the borg will no longer receive law updates from its AI
			if(!mended)
				if(R.lawupdate == 1)
					to_chat(R, "Протокол синхронизации законов активирован.")
					R.show_laws()
			else
				if(R.lawupdate == 0 && !R.emagged)
					R.lawupdate = 1

		if(BORG_WIRE_AI_CONTROL) //Cut the AI wire to reset AI control
			if(!mended)
				if(R.connected_ai)
					R.connected_ai = null

		if(BORG_WIRE_CAMERA)
			if(!isnull(R.camera) && !R.scrambledcodes)
				R.camera.status = mended
				R.camera.toggle_cam(usr, 0) // Will kick anyone who is watching the Cyborg's camera.

		if(BORG_WIRE_LAWCHECK)	//Forces a law update if the borg is set to receive them. Since an update would happen when the borg checks its laws anyway, not much use, but eh
			if(R.lawupdate)
				R.lawsync()

		if(BORG_WIRE_LOCKED_DOWN)
			R.SetLockdown(!mended)
	..()


/datum/wires/robot/UpdatePulsed(index)

	var/mob/living/silicon/robot/R = holder
	switch(index)
		if(BORG_WIRE_AI_CONTROL) //pulse the AI wire to make the borg reselect an AI
			if(!R.emagged)
				R.connected_ai = select_active_ai()
				R.notify_ai(1)

		if(BORG_WIRE_CAMERA)
			if(!isnull(R.camera) && R.camera.can_use() && !R.scrambledcodes)
				R.camera.toggle_cam(usr, 0) // Kick anyone watching the Cyborg's camera, doesn't display you disconnecting the camera.
				R.visible_message("Объектив камеры [R] громко фокусируется.")
				to_chat(R, "Ваш объектив камеры громко фокусируется.")

		if(BORG_WIRE_LOCKED_DOWN)
			R.SetLockdown(!R.lockcharge) // Toggle
	..()

/datum/wires/robot/CanUse(mob/living/L)
	var/mob/living/silicon/robot/R = holder
	if(R.wiresexposed)
		return 1
	return 0

/datum/wires/robot/proc/IsCameraCut()
	return wires_status & BORG_WIRE_CAMERA

/datum/wires/robot/proc/LockedCut()
	return wires_status & BORG_WIRE_LOCKED_DOWN

/datum/wires/robot/proc/CanLawCheck()
	return wires_status & BORG_WIRE_LAWCHECK

/datum/wires/robot/proc/AIHasControl()
	return wires_status & BORG_WIRE_AI_CONTROL
