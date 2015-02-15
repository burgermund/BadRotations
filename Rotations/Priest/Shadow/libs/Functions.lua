if select(3, UnitClass("player")) == 5 then

	-- get threat situation on player and return the number
	function getThreat()
		if UnitThreatSituation("player") ~= nil then
			return UnitThreatSituation("player")
		end
		-- 0 - Unit has less than 100% raw threat (default UI shows no indicator)
		-- 1 - Unit has 100% or higher raw threat but isn't mobUnit's primary target (default UI shows yellow indicator)
		-- 2 - Unit is mobUnit's primary target, and another unit has 100% or higher raw threat (default UI shows orange indicator)
		-- 3 - Unit is mobUnit's primary target, and no other unit has 100% or higher raw threat (default UI shows red indicator)
		return 0
	end

	-- Check if SWP is on 3 units or if #enemiesTable is <3 then on #enemiesTable
	function getSWP()
		local counter = 0
		-- iterate units for SWP
		for i=1,#enemiesTable do
			local thisUnit = enemiesTable[i].unit
			-- increase counter for each SWP
			if (UnitAffectingCombat(thisUnit) or isDummy(thisUnit)) and UnitDebuffID(thisUnit,SWP,"player") then
				counter=counter+1
			end
		end
		-- return counter
		return counter
	end

	-- Check if VT is on 3 units or if #enemiesTable is <3 then on #enemiesTable
	function getVT()
		local counter = 0
		-- iterate units for SWP
		for i=1,#enemiesTable do
			local thisUnit = enemiesTable[i].unit
			-- increase counter for each SWP
			if (UnitAffectingCombat(thisUnit) or isDummy(thisUnit)) and UnitDebuffID(thisUnit,VT,"player") then
				counter=counter+1
			end
		end
		-- return counter
		return counter
	end

	-- Units not to dot with DoTEmAll
	function safeDoT(datUnit)
		local Blacklist = {
			"Volatile Anomaly",
			"Rarnok",
			"Pack Beast",
		}
		-- nil Protection
		if datUnit == nil then 
			return true 
		end
		-- Iterate the blacklist
		for i = 1, #Blacklist do
			if UnitName(datUnit) == Blacklist[i] then
				return false
			end
		end
		-- unit is not in blacklist
		return true
	end

	-- Units not to dotweave, just press damage
	function noDoTWeave(datUnit)
		local Blacklist = {
			--"Dungeoneer's Training Dummy",  -- Debug use only
			"Fortified Arcane Aberration",
			"Replicating Arcane Aberration",
			"Displacing Arcane Aberration",
			"Arcane Aberration",
			"Siegemaker",
			"Ore Crate",
			"Dominator Turret",
			"Grasping Earth",
			"Cinder Wolf",
			"Iron Gunnery Sergeant",
			"Heavy Spear",
		}
		if datUnit==nil then return false end
			for i = 1, #Blacklist do
				if UnitName(datUnit) == Blacklist[i] then
					return  true
				end
			return false
		end
	end
	--[[                    ]] -- General Functions end

	--[[                    ]] -- Defensives
		function ShadowDefensive(options)
			-- Dispersion
			if isChecked("Dispersion") and (BadBoy_data['Defensive'] == 2) and options.player.php <= getValue("Dispersion") then
				if castSpell("player",Disp,true,false) then return; end
			end

			-- Desperate Prayer
			if isKnown(DesperatePrayer) then
				if isChecked("Desperate Prayer") and (BadBoy_data['Defensive'] == 2) and options.player.php <= getValue("Desperate Prayer") then
					if castSpell("player",DesperatePrayer,true,false) then return; end
				end
			end

			-- Healthstone/HealPot
			if isChecked("Healthstone") and getHP("player") <= getValue("Healthstone") and hasHealthPot() then
				if canUse(5512) then
					UseItemByName(tostring(select(1,GetItemInfo(5512))))
				elseif canUse(healPot) then
					UseItemByName(tostring(select(1,GetItemInfo(healPot))))
				end
			end

			-- Shield
			if isChecked("PW: Shield") and (BadBoy_data['Defensive'] == 2) and options.player.php <= getValue("PW: Shield") then
				if castSpell("player",PWS,true,false) then return; end
			end

			-- Fade (Glyphed)
			if hasGlyph(GlyphOfFade) then
				if isChecked("Fade Glyph") and (BadBoy_data['Defensive'] == 2) and options.player.php <= getValue("Fade Glyph") then
					if castSpell("player",Fade,true,false) then return; end
				end
			end

			-- Fade (Aggro)
			if IsInRaid() ~= false then
				if isChecked("Fade Aggro") and BadBoy_data['Defensive']==2 and getThreat()>=3 then
					--if isChecked("Fade Aggro") and BadBoy_data['Defensive'] == 2 then
					if castSpell("player",Fade,true,false) then return; end
				end
			end
		end
	--[[                    ]] -- Defensives end

	--[[                    ]] -- Cooldowns
		function ShadowCooldowns(options)
			-- MB on CD
			if options.buttons.Cooldowns == 2 and getTalent(7,1) then
				if castSpell("target",MB,false,false) then return; end
			end

			if getBuffRemain("player",InsanityBuff)<=0 then

				-- Trinket 1
				if options.isChecked.Trinket1 and options.buttons.Cooldowns == 2 and canTrinket(13) then
					RunMacroText("/use 13")
				end

				-- Trinket 2
				if options.isChecked.Trinket2 and options.buttons.Cooldowns == 2 and canTrinket(14) then
					RunMacroText("/use 14")
				end

				-- Halo
				if isKnown(Halo) and options.buttons.Halo == 2 then
					if getDistance("player","target")<=30 and getDistance("player","target")>=17 then
						if castSpell("player",Halo,true,false) then return; end
					end
				end

				-- Mindbender
				if isKnown(Mindbender) and options.buttons.Cooldowns == 2 and options.isChecked.Mindbender then
					if castSpell("target",Mindbender) then return; end
				end

				-- Shadowfiend
				if isKnown(SF) and options.buttons.Cooldowns == 2 and options.isChecked.Shadowfiend then
					if castSpell("target",SF,true,false) then return; end
				end

				-- -- Power Infusion
				-- if isKnown(PI) and options.buttons.Cooldowns == 2 and isChecked("Power Infusion") then
				-- 	if castSpell("player",PI) then return; end
				-- end

				-- Berserking (Troll Racial)
				--if not UnitBuffID("player",176875) then
				if isKnown(Berserking) and options.buttons.Cooldowns == 2 and options.isChecked.Berserking then
					if castSpell("player",Berserking,true,false) then return; end
				end
				--end
			end
		end
	--[[                    ]] -- Cooldowns end

	--[[                    ]] -- Execute CoP start
		function ExecuteCoP(options)
			if getHP("target")<=20 then
				-- ORBS>=3 -> DP
				if options.player.ORBS>=3 and getBuffRemain("player",InsanityBuff)<=0.3*options.player.DPTIME then
					if castSpell("target",DP,true,false) then return; end
				end

				-- MB
				if castSpell("target",MB,false,false) then return; end

				-- SWD
				if castSpell("target",SWD,true,false) then return; end

				-- SoD Proc
				if getBuffStacks("player",SoDProc)>=1 then
					if castSpell("target",MSp,false,false) then return; end
				end

				-- MF Filler
				if select(1,UnitChannelInfo("player")) == nil and options.player.ORBS<3 then
					if castSpell("target",MF,false,true) then return; end
				end
			end
		end
	--[[                    ]] -- Execute CoP end
	
	--[[                    ]] -- Execute AS start
		function ExecuteAS(options)
			if getHP("target")<=20 then
				-- DP on 3+ Orbs
				if options.player.ORBS>=3 and getBuffRemain("player",InsanityBuff)<=0.3*options.player.DPTIME then
					if castSpell("target",DP,true,false) then return; end
				end

				-- MB
				if castSpell("target",MB,false,true) then return; end

				-- SoD Proc
				if getBuffStacks("player",SoDProc)>=1 then
					if castSpell("target",MSp,false,false) then return; end
				end

				-- SWD
				if castSpell("target",SWD,true,false) then return; end

				-- Insanity if noChannel
				if getBuffRemain("player",InsanityBuff)>0 then
					-- Check for current channel and cast Insanity
					if select(1,UnitChannelInfo("player")) == nil then
						if castSpell("target",MF,false,true) then return; end
					end
				end

				-- SWP / VT
				if getTimeToDie("target")>25 then
					-- SWP
					if getDebuffRemain("target",SWP,"player")<options.values.SWPRefresh then
						if castSpell("target",SWP,true,false) then return; end
					end
					-- VT
					if getDebuffRemain("target",VT,"player")<=options.values.VTRefresh and GetTime()-lastVT > 2*options.player.GCD then
						if castSpell("target",VT,true,true) then 
							lastVT=GetTime()
							return
						end
					end
				end

				-- MF Filler
				if select(1,UnitChannelInfo("player")) == nil then
					if castSpell("target",MF,false,true) then return; end
				end
			end
		end
	--[[                    ]] -- Execute AS end

	--[[                    ]] -- LF Orbs start
		function LFOrbs(options)
			if options.isChecked.ScanOrbs then
				if getSpellCD(SWD)<=0 then
					if options.player.ORBS<5 then
						for i=1,#enemiesTable do
							local thisUnit = enemiesTable[i].unit
							local hp = enemiesTable[i].hp
							if hp<20 then
								if castSpell(thisUnit,SWD,true,false,false,false,false,false,true) then return; end
							end
						end
					end
				end
			end
		end
	--[[                    ]] -- LF Orbs end

	--[[                    ]] -- LF ToF
		function LFToF(options)
			if options.isChecked.ScanToF then
				if getBuffRemain("player",ToF)<options.player.GCD then
					for i=1,#enemiesTable do
						local thisUnit = enemiesTable[i].unit
						local hp = enemiesTable[i].hp
						if hp<35 then
							if getSpellCD(MB)>0 then
								if castSpell(thisUnit,SWP,true,false) then return; end
							end
						end
					end
				end
			end
		end
	--[[                    ]] -- LF Orbs end

	--[[                    ]] -- SWP em all start
		function throwSWP(options,targetAlso)
			--if options.buttons.DoT==2 or options.buttons.DoT==4 then
				local SWPCount = getSWP()
				-- refresh SWP
				if SWPCount <= options.values.MaxTargets then
					for i=1, #enemiesTable do
						local thisUnit = enemiesTable[i].unit
						local thisHP = enemiesTable[i].hpabs
						-- check for target and safeDoT
						if safeDoT(thisUnit) then
							if not UnitIsUnit("target",thisUnit) or targetAlso then
								if UnitDebuffID(thisUnit,SWP,"player") then
									-- check remaining time and minhealth
									if getDebuffRemain(thisUnit,SWP,"player")<=options.values.SWPRefresh and thisHP>options.values.MinHealth then
										if castSpell(thisUnit,SWP,true,false) then return; end
									end
								end
							end
						end
					end
				end
				-- apply SWP
				if SWPCount<options.values.MaxTargets then
					for i=1, #enemiesTable do
						local thisUnit = enemiesTable[i].unit
						local thisHP = enemiesTable[i].hpabs
						-- check for target and safeDoT
						if safeDoT(thisUnit) then
							if not UnitIsUnit("target",thisUnit) or targetAlso then
							-- check remaining time and minhealth
								if getDebuffRemain(thisUnit,SWP,"player")<=options.values.SWPRefresh and thisHP>options.values.MinHealth then
									if castSpell(thisUnit,SWP,true,false) then return; end
								end
							end
						end
					end
				end
			--end
		end
	--[[                    ]] -- SWP em all end

	--[[                    ]] -- VT em all start
		function throwVT(options,targetAlso)
			--if options.buttons.DoT==3 or options.buttons.DoT==4 then
				local VTCount = getVT()
				-- refresh VT
				if VTCount <= options.values.MaxTargets then
					for i=1, #enemiesTable do
						local thisUnit = enemiesTable[i].unit
						local thisHP = enemiesTable[i].hpabs
						-- check for target and safeDoT
						if safeDoT(thisUnit) then
							if not UnitIsUnit("target",thisUnit) or targetAlso then
								if UnitDebuffID(thisUnit,VT,"player") then
									-- check remaining time and minhealth
									if getDebuffRemain(thisUnit,VT,"player")<=options.values.VTRefresh and thisHP>options.values.MinHealth then
										if castSpell(thisUnit,VT,true,true) then return; end
									end
								end
							end
						end
					end
				end
				-- apply VT
				if VTCount<options.values.MaxTargets then
					for i=1, #enemiesTable do
						local thisUnit = enemiesTable[i].unit
						local thisHP = enemiesTable[i].hpabs
						-- check for target and safeDoT
						if safeDoT(thisUnit) then
							if not UnitIsUnit("target",thisUnit) or targetAlso then
								-- check remaining time and minhealth
								if getDebuffRemain(thisUnit,VT,"player")<=options.values.VTRefresh and thisHP>options.values.MinHealth then
									if castSpell(thisUnit,VT,true,true) then return; end
								end
							end
						end
					end
				end
			--end
		end
	--[[                    ]] -- VT em all end

	--[[                    ]] -- Weave Throw DP start
		function ThrowDP(options)
			-- Priorize Focus
			if options.player.TwinStyle then
				if UnitExists("focus") and not UnitIsDead("focus") then
					if castSpell("focus",DP,true,false) then return; end
				end
			end
			-- Throw DP on Highest HP unit
			if #enemiesTable>=2 then
				for i=1, #enemiesTable do
					local thisUnit = enemiesTable[i].unit
					local thisHP = enemiesTable[i].hpabs
					if safeDoT(thisUnit) and not UnitIsUnit("target",thisUnit) then
						-- check remaining DP Time
						if getDebuffRemain(thisUnit,DP,"player")<=0.3*options.values.DPTIME and thisHP>options.values.MinHealth then
							if castSpell(thisUnit,DP,true,false) then return; end
						end
					end
				end
			end
		end
	--[[                    ]] -- Weave Throw DP end

	--[[                    ]] -- CoP Insanity start
		function CoPInsanity(options)

			-- MB on CD
			if castSpell("target",MB,false,false) then return; end

			-----------------
			-- DoT Weaving --
			-----------------
			-- Option Check: DoT Weave
			if options.isChecked.DoTWeave then
				-- Unit Check: DoT Weave on Unit allowed?
				if noDoTWeave("target")==false then
					if options.player.ORBS>=4 and getSpellCD(MB)<=2*options.player.GCD then
						-- apply SWP
						if not UnitDebuffID("target",SWP,"player") then
							if castSpell("target",SWP,true,false) then return; end
						end
						-- apply VT
						if not UnitDebuffID("target",VT,"player") and GetTime()-lastVT > 2*options.player.GCD then
							if castSpell("target",VT,true,true) then
								--options.player.lastVT=GetTime()
								lastVT=GetTime()
								return
							end
						end
					end
				end
			end

			----------------
			-- spend orbs --
			----------------
			-- Check for 5 Orbs
			if options.player.ORBS==5 then
				-- Check for SWP, DoTweave option, noWeave Unit
				if getDebuffRemain("target",SWP,"player")>0 or options.isChecked.DoTWeave~=true or noDoTWeave("target") then
					-- Check for VT, DoTweave option, noWeave Unit
					if getDebuffRemain("target",VT,"player")>0 or options.isChecked.DoTWeave~=true or noDoTWeave("target") then
						-- DP on target
						if castSpell("target",DP,false,true) then
							lastDP=GetTime()
							return
						end
					end
				end
			end

			-- Check for >= 3 Orbs
			if options.player.ORBS>=3 then
				-- Check for last DP
				if GetTime()-lastDP<=options.player.DPTIME+2 then
					-- Check that Insanity isnt on me
					--if getBuffRemain("player",InsanityBuff)<=0 then
						-- DP on target
						if castSpell("target",DP,false,true) then return; end
					--end
				end
			end

			-- Insanity if noChannel
			if getBuffRemain("player",InsanityBuff)>=0.3*options.player.GCD then
				-- Check for current channel and cast Insanity
				if select(1,UnitChannelInfo("player")) == nil then
					if castSpell("target",MF,false,true) then return; end
				end
			end

			--------------
			-- get orbs --
			--------------
			-- only collect Orbs if no InsanityBuff
			if getBuffRemain("player",InsanityBuff)<=0 then
				-- only collect Orbs if not channeling insanity atm
				if not select(1,UnitChannelInfo("player")) ~= "Insanity" then
					-- MB on CD
					if castSpell("target",MB,false,false) then return; end

					-- SWP
					if options.buttons.DoT==2 or options.buttons.DoT==4 then 
						throwSWP(options,false)
					end

					-- VT
					if options.buttons.DoT==3 or options.buttons.DoT==4 then
						throwVT(options,false)
					end

					-- Mind Sear
					if options.isChecked.MindSear then
						if #getEnemies("target",10)>=options.values.MindSear then
							if select(1,UnitChannelInfo("player")) ~= "Mind Sear" then
								if select(1,UnitChannelInfo("player")) == nil or select(1,UnitChannelInfo("player")) == "Mind Flay" then
									if castSpell("target",MS,false,true) then return; end
								end
							end
						end
					end

					-- Mind Spike
					if options.player.ORBS<5 then
						if #getEnemies("target",10)<options.values.MindSear and options.isChecked.MindSear
						or not options.isChecked.MindSear then
							if castSpell("target",MSp,false,true) then return; end
						end
					end
				end
			end
		end -- function end
	--[[                    ]] -- CoP Insanity end

	--[[                    ]] -- CoP SoD start
	function CoPSoD(options)
		----------------
		-- spend orbs --
		----------------
		-- Check for 3+ Orbs
		

	end -- function end
	--[[                    ]] -- CoP SoD end

	--[[                    ]] -- AS Insanity start
	function ASInsanity(options)
		-- DP on 3+ Orbs
		if options.player.ORBS>=3 then
			-- check for running DP
			if getDebuffRemain("target",DP,"player")<=0.3*options.player.DPTIME then
				if castSpell("target",DP,true,false) then return; end
			end
		end

		-- MB on CD
		if castSpell("target",MB,false,true) then return; end


		-- SWP on MaxTargets
		throwSWP(options,true)

		-- VT on target
		if getDebuffRemain("target",VT,"player")<=options.values.VTRefresh and GetTime()-lastVT > 2*options.player.GCD then
			if castSpell("target",VT,true,true) then 
				lastVT=GetTime()
				return
			end
		end

		-- VT on all
		if options.buttons.DoT==3 or options.buttons.DoT==4 then
			throwVT(options,true)
		end
		-- -- Mind Sear
		-- if options.isChecked.MindSear then
		-- 	if #getEnemies("target",10)>=options.values.MindSear then
		-- 		if select(1,UnitChannelInfo("player")) ~= "Mind Sear" then
		-- 			if select(1,UnitChannelInfo("player")) == nil or select(1,UnitChannelInfo("player")) == "Mind Flay" then
		-- 				if castSpell("target",MS,false,true) then return; end
		-- 			end
		-- 		end
		-- 	end
		-- end

		-- Insanity / MF
		if select(1,UnitChannelInfo("player")) == nil then
			if castSpell("target",MF,false,true) then return; end
		end

	end
	--[[                    ]] -- AS Insanity end

	--[[                    ]] -- AS SoD start
	function ASSoD(options)
		-- DP on 3+ Orbs
		if options.player.ORBS>=3 then
			-- check for running DP
			if getDebuffRemain("target",DP,"player")<=0.3*options.player.DPTIME then
				if castSpell("target",DP,true,false) then return; end
			end
		end

		-- SoD Proc if moving
		if isMoving("player") then
			if getBuffStacks("player",SoDProc)>=1 then
				if castSpell("target",MSp,false,false) then return; end
			end
		end

		-- MB on CD
		if castSpell("target",MB,false,true) then return; end

		-- SWP on MaxTargets
		throwSWP(options,true)

		-- VT on MaxTargets
		throwVT(options,true)

		-- SoD Proc
		if getBuffStacks("player",SoDProc)>=1 then
			if castSpell("target",MSp,false,false) then return; end
		end

		-- Mind Sear
		if options.isChecked.MindSear then
			if #getEnemies("target",10)>=options.values.MindSear then
				if select(1,UnitChannelInfo("player")) ~= "Mind Sear" then
					if select(1,UnitChannelInfo("player")) == nil or select(1,UnitChannelInfo("player")) == "Mind Flay" then
						if castSpell("target",MS,false,true) then return; end
					end
				end
			end
		end

		-- MF
		if select(1,UnitChannelInfo("player")) == nil then
			if castSpell("target",MF,false,true) then return; end
		end
	end
	--[[                    ]] -- AS SoD end



end -- Global end